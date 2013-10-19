OUTPUT = paper.pdf

MARKDOWN = title.markdown content.markdown
HEADER = header.latex
ABSTRACT = abstract.latex

PANDOC = pandoc
FLAGS = --smart --standalone --number-sections

.PHONY: clean

$(OUTPUT): $(MARKDOWN) $(HEADER) $(ABSTRACT)
	$(PANDOC) $(FLAGS) \
		--include-in-header $(HEADER) \
		--include-before-body $(ABSTRACT) \
		--output $(OUTPUT) \
		-- $(MARKDOWN)

clean:
	rm -rf $(OUTPUT)
