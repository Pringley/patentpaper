OUTPUT = paper.pdf

MARKDOWN = content.markdown
HEADER = header.latex

PANDOC = pandoc
FLAGS = --smart --standalone --number-sections

.PHONY: clean

$(OUTPUT): $(MARKDOWN) $(HEADER)
	$(PANDOC) $(FLAGS) \
		--include-in-header $(HEADER) \
		--output $(OUTPUT) \
		-- $(MARKDOWN)

clean:
	rm -rf $(OUTPUT)
