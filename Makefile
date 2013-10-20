OUTPUT = paper.pdf

CONTENT = content.markdown
STYLE = style.latex

PANDOC = pandoc
FLAGS = --smart \
		--standalone \
		--number-sections \
		--variable geometry:margin=1in \
		--include-in-header $(STYLE) \
		--output $(OUTPUT)

.PHONY: clean

$(OUTPUT): $(CONTENT) $(STYLE)
	$(PANDOC) $(FLAGS) -- $(CONTENT)

clean:
	rm -rf $(OUTPUT)
