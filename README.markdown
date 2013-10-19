# Patent Paper

## Requirements

-   [Pandoc](http://johnmacfarlane.net/pandoc/), John MacFarlane's markup
    converter.

-   [TexLive](http://www.tug.org/texlive/), or another way to generate PDFs
    from LaTeX source

On Ubuntu, you can just run the following to get started:

    sudo apt-get install pandoc texlive texlive-latex-extras

## Build

Generate a PDF of the paper using simply:

    make

This will create an output file, `paper.pdf`.

## File Structure

-   `title.markdown` contains title and author information
-   `abstract.latex` contains the abstract
-   `content.markdown` has the main paper content
-   `header.latex` specifies LaTeX-specific styles

## Credits

This Markdown template was adapted from
[Boildown](https://github.com/Pringley/boildown).
