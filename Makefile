NAME = ft_turing

NC_EXECUTABLE = $(NAME).nc # native code
BC_EXECUTABLE = $(NAME).bc # byte code

OCAMLOPT = ocamlopt
OCAMLC = ocamlc
OCAMLDEP = ocamldep
OCAMLFIND = ocamlfind

SOURCE_DIR = src

REQUIRED_PACKAGES = $(OCAMLFIND) yojson cmdliner
EXTERNAL_LIBS = yojson cmdliner
LIBS = $(foreach lib,$(EXTERNAL_LIBS),-package $(lib))

SOURCES = 	$(SOURCE_DIR)/transition.ml \
			$(SOURCE_DIR)/machineDescription.ml \
			$(SOURCE_DIR)/machine.ml \
			$(SOURCE_DIR)/parser.ml \
			$(SOURCE_DIR)/main.ml

COBJS = $(SOURCES:.ml=.cmo)
OPTOBJS = $(SOURCES:.ml=.cmx)

INCLUDES = -I $(SOURCE_DIR)

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

%.cmo: %.ml
	$(OCAMLFIND) $(OCAMLC) $(LIBS) $(INCLUDES) -c $<

%.cmi: %.mli
	$(OCAMLFIND) $(OCAMLC) $(LIBS) $(INCLUDES) -c $<

%.cmx: %.ml
	$(OCAMLFIND) $(OCAMLOPT) $(LIBS:.cma=.cmxa) $(INCLUDES) -c $<

DEPEND_FILE = .depend

depend: $(DEPEND_FILE)

$(DEPEND_FILE): $(SOURCES)
	@echo "Generating dependency file..."
	$(OCAMLDEP) $(INCLUDES) $^ > $(DEPEND_FILE)

clean:
	@echo "Cleaning..."
	rm -f $(SOURCE_DIR)/*.cm[iox] $(SOURCE_DIR)/*.o $(SOURCE_DIR)/*.a $(NAME) $(NC_EXECUTABLE) $(BC_EXECUTABLE) $(DEPEND_FILE)

re: clean all

-include $(DEPEND_FILE)

.PHONY: all check-dependencies nc bc clean re depend
