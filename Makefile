NAME = ft_turing
SRC_DIR = src
TEST_DIR = test
BUILD_DIR = build
TEST_BUILD_DIR = $(BUILD_DIR)/test

NC_EXECUTABLE = $(NAME).nc # native code
BC_EXECUTABLE = $(NAME).bc # byte code
TEST_EXECUTABLE = test

DEPEND_FILE = $(BUILD_DIR)/.depend

OCAMLOPT = ocamlopt
OCAMLC = ocamlc
OCAMLDEP = ocamldep
OCAMLFIND = ocamlfind

REQUIRED_PACKAGES = $(OCAMLFIND) yojson cmdliner
EXTERNAL_LIBS = yojson cmdliner
LIBS = $(foreach lib,$(EXTERNAL_LIBS),-package $(lib))

SOURCES = transition.ml machineDescription.ml machine.ml parser.ml main.ml
TEST_SOURCES = test.ml

COBJS = $(addprefix $(BUILD_DIR)/,$(SOURCES:.ml=.cmo))
OPTOBJS = $(addprefix $(BUILD_DIR)/,$(SOURCES:.ml=.cmx))
TESTOBJS = $(addprefix $(TEST_BUILD_DIR)/,$(TEST_SOURCES:.ml=.cmo))

INCLUDES = -I $(BUILD_DIR) -I $(SRC_DIR) -I $(TEST_DIR)

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

$(TEST_BUILD_DIR):
	mkdir -p $(TEST_BUILD_DIR)

$(BUILD_DIR)/%.cmo: $(SRC_DIR)/%.ml | $(BUILD_DIR)
	$(OCAMLFIND) $(OCAMLC) $(LIBS) $(INCLUDES) -c -o $@ $<

$(BUILD_DIR)/%.cmi: $(SRC_DIR)/%.mli | $(BUILD_DIR)
	$(OCAMLFIND) $(OCAMLC) $(LIBS) $(INCLUDES) -c -o $@ $<

$(BUILD_DIR)/%.cmx: $(SRC_DIR)/%.ml | $(BUILD_DIR)
	$(OCAMLFIND) $(OCAMLOPT) $(LIBS:.cma=.cmxa) $(INCLUDES) -c -o $@ $<

$(TEST_BUILD_DIR)/%.cmo: $(TEST_DIR)/%.ml | $(TEST_BUILD_DIR)
	$(OCAMLFIND) $(OCAMLC) $(LIBS) $(INCLUDES) -c -o $@ $<

test: EXTERNAL_LIBS += ounit2
test: REQUIRED_PACKAGES += ounit2
test: check-dependencies $(TEST_BUILD_DIR)/$(TEST_EXECUTABLE)

$(TEST_BUILD_DIR)/$(TEST_EXECUTABLE): $(filter-out $(BUILD_DIR)/main.cmo,$(COBJS)) $(TESTOBJS)
	$(OCAMLFIND) $(OCAMLC) $(LIBS) $(INCLUDES) -linkpkg -g $^ -o $@

clean:
	@echo "Cleaning up..."
	rm -rf $(BUILD_DIR) *.cmi *.cmo *.log *.cache

depend: $(DEPEND_FILE)

$(DEPEND_FILE): $(addprefix $(SRC_DIR)/,$(SOURCES)) $(addprefix $(TEST_DIR)/,$(TEST_SOURCES)) | $(BUILD_DIR)
	@echo "Generating dependencies file..."
	$(OCAMLDEP) $(INCLUDES) $^ > $(DEPEND_FILE)

re: clean all

-include $(DEPEND_FILE)

.PHONY: all check-dependencies nc bc clean re depend test
