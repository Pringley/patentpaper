OUTPUT = paper.pdf

CONTENT = content.markdown

PANDOC = pandoc
FLAGS = --smart \
		--standalone \
		--filter pandoc-citeproc \
		--output $(OUTPUT)

.PHONY: clean

$(OUTPUT): $(CONTENT)
	$(PANDOC) $(FLAGS) -- $(CONTENT)

clean:
	rm -rf $(OUTPUT)
