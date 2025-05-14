NAME = ft_turing

NC_EXECUTABLE = $(NAME).nc
BC_EXECUTABLE = $(NAME).bc
TEST_EXECUTABLE = test

OCAMLOPT = ocamlopt
OCAMLC = ocamlc
OCAMLDEP = ocamldep
OCAMLFIND = ocamlfind

REQUIRED_PACKAGES = $(OCAMLFIND) yojson cmdliner
EXTERNAL_LIBS = yojson cmdliner
LIBS = $(foreach lib,$(EXTERNAL_LIBS),-package $(lib))

SOURCES = transition.ml machineDescription.ml machine.ml parser.ml main.ml
TEST_SOURCES = test.ml

COBJS = $(SOURCES:.ml=.cmo)
OPTOBJS = $(SOURCES:.ml=.cmx)
TESTOBJS = $(TEST_SOURCES:.ml=.cmo)

INCLUDES = -I . -I src -I test

all: $(NAME)

$(NAME): check-dependencies nc bc
	ln -sf $(BC_EXECUTABLE) $(NAME)

nc: $(NC_EXECUTABLE)
bc: $(BC_EXECUTABLE)

$(NC_EXECUTABLE): $(OPTOBJS)
	@echo "Building native code..."
	$(OCAMLFIND) $(OCAMLOPT) $(LIBS:.cma=.cmxa) $(INCLUDES) -linkpkg -o $@ $^

$(BC_EXECUTABLE): $(COBJS)
	@echo "Building bytecode..."
	$(OCAMLFIND) $(OCAMLC) $(LIBS) $(INCLUDES) -linkpkg -o $@ $^

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

%.cmo: src/%.ml
	$(OCAMLFIND) $(OCAMLC) $(LIBS) $(INCLUDES) -c $<

%.cmi: src/%.mli
	$(OCAMLFIND) $(OCAMLC) $(LIBS) $(INCLUDES) -c $<

%.cmx: src/%.ml
	$(OCAMLFIND) $(OCAMLOPT) $(LIBS:.cma=.cmxa) $(INCLUDES) -c $<

test: EXTERNAL_LIBS += ounit2
test: REQUIRED_PACKAGES += ounit2
test: check-dependencies $(TEST_EXECUTABLE)

$(TEST_EXECUTABLE): $(filter-out main.cmo,$(COBJS)) $(TESTOBJS)
	$(OCAMLFIND) $(OCAMLC) $(LIBS) $(INCLUDES) -linkpkg -g $^ -o $@

%.cmo: test/%.ml
	$(OCAMLFIND) $(OCAMLC) $(LIBS) $(INCLUDES) -c $<

DEPEND_FILE = .depend

depend: $(DEPEND_FILE)

$(DEPEND_FILE): $(addprefix src/,$(SOURCES)) $(addprefix test/,$(TEST_SOURCES))
	@echo "Generating dependency file..."
	$(OCAMLDEP) $(INCLUDES) $^ > $(DEPEND_FILE)

clean:
	@echo "Cleaning..."
	rm -f *.cm[iox] *.o *.a *.annot *.log *.cache *.exe $(NAME) $(NC_EXECUTABLE) $(BC_EXECUTABLE) $(TEST_EXECUTABLE) $(DEPEND_FILE)

re: clean all

-include $(DEPEND_FILE)

.PHONY: all check-dependencies nc bc clean re depend test
