BUILD_DIR = build
NAME = ft_turing

NC_EXECUTABLE = $(NAME).nc # native code
BC_EXECUTABLE = $(NAME).bc # byte code

DEPEND_FILE = $(BUILD_DIR)/.depend

OCAMLOPT = ocamlopt
OCAMLC = ocamlc
OCAMLDEP = ocamldep
OCAMLFIND = ocamlfind

REQUIRED_PACKAGES = $(OCAMLFIND) yojson cmdliner
EXTERNAL_LIBS = yojson cmdliner
LIBS = $(foreach lib,$(EXTERNAL_LIBS),-package $(lib))

SOURCES = transition.ml machine.ml parser.ml main.ml
TEST_SOURCES = $(filter-out main.ml,$(SOURCES)) test.ml

COBJS = $(addprefix $(BUILD_DIR)/,$(SOURCES:.ml=.cmo))
OPTOBJS = $(addprefix $(BUILD_DIR)/,$(SOURCES:.ml=.cmx))
TESTOBJS = $(addprefix $(BUILD_DIR)/,$(TEST_SOURCES:.ml=.cmo))

INCLUDES = -I $(BUILD_DIR)

all: $(BUILD_DIR)/$(NAME)

$(BUILD_DIR)/$(NAME): check-dependencies nc bc
	ln -sf $(BC_EXECUTABLE) $(BUILD_DIR)/$(NAME)

nc: $(BUILD_DIR)/$(NC_EXECUTABLE)
bc: $(BUILD_DIR)/$(BC_EXECUTABLE)

$(BUILD_DIR)/$(NC_EXECUTABLE): $(OPTOBJS)
	@echo "Building project with ocamlopt..."
	$(OCAMLFIND) $(OCAMLOPT) $(LIBS:.cma=.cmxa) $(INCLUDES) -linkpkg -o $@ $^

$(BUILD_DIR)/$(BC_EXECUTABLE): $(COBJS)
	@echo "Building project with ocamlc..."
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

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/%.cmo: %.ml | $(BUILD_DIR)
	$(OCAMLFIND) $(OCAMLC) $(LIBS) $(INCLUDES) -c -o $@ $<

$(BUILD_DIR)/%.cmi: %.mli | $(BUILD_DIR)
	$(OCAMLFIND) $(OCAMLC) $(LIBS) $(INCLUDES) -c -o $@ $<

$(BUILD_DIR)/%.cmx: %.ml | $(BUILD_DIR)
	$(OCAMLFIND) $(OCAMLOPT) $(LIBS:.cma=.cmxa) $(INCLUDES) -c -o $@ $<

test: EXTERNAL_LIBS += ounit2
test: REQUIRED_PACKAGES += ounit2
test: check-dependencies $(BUILD_DIR)/test

$(BUILD_DIR)/test: $(TESTOBJS)
	$(OCAMLFIND) $(OCAMLC) $(LIBS) $(INCLUDES) -linkpkg -g $^ -o $@

clean:
	@echo "Cleaning up..."
	rm -rf $(BUILD_DIR) *.cmi *.cmo *.log *.cache

depend: $(DEPEND_FILE)

$(DEPEND_FILE): $(SOURCES) $(TEST_SOURCES)
	@echo "Generating dependencies file..."
	$(OCAMLDEP) $(INCLUDES) $^ > $(DEPEND_FILE)

re: clean all

-include $(DEPEND_FILE)

.PHONY: all check-dependencies build nc bc clean re depend
