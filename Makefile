bookname = $(shell cat bookname.txt)
chapters = $(shell cat chapters.txt)

# Today's date, baked into the WIP version line on the copyright page
# (chapters/front-matter.md) every time the book is built. Override on
# the command line if you ever need a specific date, e.g.:
#   make epub BUILD_DATE=2026-08-07
BUILD_DATE = $(shell date +%Y-%m-%d)

# The chapter list actually fed to pandoc: identical to $(chapters),
# except the tracked chapters/front-matter.md is swapped out for a
# generated copy with today's date stamped into it.
build_chapters = $(patsubst chapters/front-matter.md,build/front-matter.md,$(chapters))

.PHONY: epub
epub: book $(bookname).epub

.PHONY: book
book: chapters.txt bookname.txt title.txt chapters

.PHONY: pdf
pdf: book $(bookname).pdf

# Phony because this has to regenerate on every build, not just when
# chapters/front-matter.md changes -- otherwise a build/front-matter.md
# left over from a previous day is newer than the source file, Make
# considers it up to date, and the epub/pdf silently gets yesterday's
# (or older) date baked into the copyright page instead of today's.
.PHONY: build/front-matter.md
build/front-matter.md: chapters/front-matter.md
	mkdir -p build
	sed 's/__BUILD_DATE__/$(BUILD_DATE)/' chapters/front-matter.md > build/front-matter.md

$(bookname).epub: $(chapters) epub.css build/front-matter.md
	pandoc -o $(bookname).epub title.txt $(build_chapters) \
		--resource-path=. \
		--epub-metadata=metadata.xml --toc --toc-depth=2 \
		--css=epub.css -f markdown-tex_math_dollars

# Built straight from the markdown with WeasyPrint, rather than via the
# EPUB -- avoids depending on Calibre's ebook-convert, and WeasyPrint's
# CSS Paged Media support (see print.css) gives us proper running page
# numbers and forced page breaks between chapters.
$(bookname).pdf: $(chapters) print.css build/front-matter.md
	pandoc -o $(bookname).pdf title.txt $(build_chapters) \
		--resource-path=. \
		--pdf-engine=weasyprint --toc --toc-depth=2 \
		--css=print.css -f markdown-tex_math_dollars

clean:
	rm -f $(bookname).epub $(bookname).pdf
	rm -rf build

