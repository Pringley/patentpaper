# Techniques for identifying influence in citation networks

## Requirements

-   [Pandoc](http://johnmacfarlane.net/pandoc/), John MacFarlane's markup
    converter

-   [TexLive](http://www.tug.org/texlive/), or another way to generate PDFs
    from LaTeX source

On Ubuntu, you can just run the following to get started:

    sudo apt-get install pandoc texlive texlive-latex-extras

## Build

Generate a PDF of the paper using simply:

    make

This will create an output file, `paper.pdf`.

## File Structure

-   `content.markdown` has the main paper content
-   `style.latex` specifies LaTeX-specific styles
-   `images/` contains image assets

## Credits

This Markdown template was adapted from
[Boildown](https://github.com/Pringley/boildown).
