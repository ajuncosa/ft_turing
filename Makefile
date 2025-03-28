NAME = ft_turing
NC_EXECUTABLE = $(NAME).nc # native code
BC_EXECUTABLE = $(NAME).bc # byte code

OCAMLOPT = ocamlopt
OCAMLC = ocamlc
OCAMLDEP = ocamldep
OCAMLFIND = ocamlfind

REQUIRED_PACKAGES = $(OCAMLFIND) yojson core core_unix
EXTERNAL_LIBS = yojson core core_unix.command_unix

SOURCES = transition.ml machine.ml parser.ml main.ml
TEST_SOURCES = test.ml
LIBS = $(foreach lib,$(EXTERNAL_LIBS),-package $(lib))

COBJS = $(SOURCES:.ml=.cmo)
OPTOBJS = $(SOURCES:.ml=.cmx)

all: $(NAME)

$(NAME): check-dependencies nc bc
	ln -sf $(BC_EXECUTABLE) $(NAME)

nc: $(NC_EXECUTABLE)
bc: $(BC_EXECUTABLE)

$(NC_EXECUTABLE): $(OPTOBJS)
	@echo "Building project with ocamlopt..."
	$(OCAMLFIND) $(OCAMLOPT) $(LIBS:.cma=.cmxa) -linkpkg -o $@ $^

$(BC_EXECUTABLE): $(COBJS)
	@echo "Building project with ocamlc..."
	$(OCAMLFIND) $(OCAMLC) $(LIBS) -linkpkg -o $@ $^

check-dependencies:
	@echo "Checking for required OPAM packages..."
	@for pkg in $(REQUIRED_PACKAGES); do \
		if ! opam list --installed-roots | grep -q $$pkg; then \
			echo "Installing missing package: $$pkg"; \
			opam install -y $$pkg; \
			eval $$(opam env); \
		else \
			echo "Package $$pkg is already installed."; \
		fi \
	done

%.cmo: %.ml
	$(OCAMLFIND) $(OCAMLC) $(LIBS) -c $<

%.cmi: %.mli
	$(OCAMLFIND) $(OCAMLC) $(LIBS) -c $<

%.cmx: %.ml
	$(OCAMLFIND) $(OCAMLOPT) $(LIBS:.cma=.cmxa) -c $<

test: EXTERNAL_LIBS += ounit2
test: REQUIRED_PACKAGES += ounit2
test: check-dependencies
	$(OCAMLFIND) $(OCAMLC) $(LIBS) -linkpkg -g $(SOURCES) $(TEST_SOURCES) -o $@

clean:
	@echo "Cleaning up..."
	rm -f *.cm* *.o .depend *.log *.cache

fclean: clean
	@echo "Removing executables..."
	rm -f $(NC_EXECUTABLE) $(BC_EXECUTABLE) $(NAME) test

depend: .depend

.depend:
	@echo "Generating dependencies file..."
	$(OCAMLDEP) $(SOURCES) > .depend

re: fclean all

-include .depend

.PHONY: all check-dependencies build nc bc clean fclean re depend
