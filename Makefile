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

.PHONY: mobi
mobi: book $(bookname).mobi

.PHONY: pdf
pdf: book $(bookname).pdf

build/front-matter.md: chapters/front-matter.md
	mkdir -p build
	sed 's/__BUILD_DATE__/$(BUILD_DATE)/' chapters/front-matter.md > build/front-matter.md

$(bookname).mobi: $(bookname).epub
	kindlegen -verbose $(bookname).epub

$(bookname).epub: $(chapters) epub.css build/front-matter.md
	pandoc -o $(bookname).epub title.txt $(build_chapters) \
		--resource-path=.:chapters \
		--epub-metadata=metadata.xml --toc --toc-depth=2 \
		--css=epub.css -f markdown-tex_math_dollars

$(bookname).pdf: $(bookname).epub
	ebook-convert $(bookname).epub $(bookname).pdf

clean:
	rm -f $(bookname).epub $(bookname).mobi $(bookname).pdf
	rm -rf build

