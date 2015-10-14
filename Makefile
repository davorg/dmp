bookname = $(shell cat bookname.txt)
chapters = $(shell cat chapters.txt)

epub: book

book: $(bookname).epub

mobi: $(bookname).mobi

pdf: $(bookname).pdf

$(bookname).mobi: $(bookname).epub
	kindlegen -verbose $(bookname).epub

$(bookname).epub: $(chapters) epub.css
	pandoc -o $(bookname).epub title.txt $(chapters) --epub-metadata=metadata.xml --toc --toc-depth=2 --epub-stylesheet=epub.css

$(bookname).pdf: $(bookname).epub
	ebook-convert $(bookname).epub $(bookname).pdf

clean:
	rm $(bookname).epub $(bookname).mobi

