bookname = $(shell cat bookname.txt)
chapters = $(shell cat chapters.txt)

.PHONY: epub
epub: book $(bookname).epub

.PHONY: book
book: chapters.txt bookname.txt title.txt chapters

.PHONY: mobi
mobi: book $(bookname).mobi

.PHONY: pdf
pdf: book $(bookname).pdf

$(bookname).mobi: $(bookname).epub
	kindlegen -verbose $(bookname).epub

$(bookname).epub: $(chapters) epub.css
	pandoc -o $(bookname).epub title.txt $(chapters) \
		--epub-metadata=metadata.xml --toc --toc-depth=2 \
		--css=epub.css -f markdown-tex_math_dollars

$(bookname).pdf: $(bookname).epub
	ebook-convert $(bookname).epub $(bookname).pdf

clean:
	rm -f $(bookname).epub $(bookname).mobi $(bookname).pdf

