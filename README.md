Data Munging with Perl

This repo contains the source files for the book "Data Munging with Perl".

Initially, I've just run pdftohtml and pdftotext against the PDF of the book.

Eventually, I'll clean it all up a lot and turn it into an ebook of some kind.

I might even update it.

## Testing the example programs

`bin/run-examples` runs every program in `code-examples/` (in a scratch copy, so nothing in the repo is touched) and reports anything that exits non-zero (FAIL) or writes to STDERR (WARN). Modules that aren't installed, a Perl that's too old, and network access (with `--offline`) are reported as SKIP rather than as failures.

    bin/run-examples                 # everything
    bin/run-examples --offline c6    # only examples whose path contains "c6", no network
    bin/run-examples --verbose c11   # show full STDERR for anything that isn't OK

It is driven by `code-examples/MANIFEST`: one line per program, saying what to feed it (`stdin=`, `args=`) and what to expect (`needs=net`, `skip="why"`, `known="why"`). Add a line there whenever you add an example. It needs only core Perl, and is most useful on a machine with a current Perl (5.40) and the book's CPAN modules installed.

## Style checks

`bin/lint-examples` checks the example programs and the code listings in the chapters against the book's code style, and `--fix` repairs what it can. Currently it enforces one rule: the `use` statements at the top of a program form a block of their own, followed by a blank line. `make check` runs this and `bin/run-examples --offline` together.

## Keeping the chapters and the examples in step

The code listings in the chapters are copies of the programs in `code-examples/`, and copies drift. `bin/check-listings` compares them. A listing is tied to its file by a marker comment on the line before it in the chapter (invisible in the finished book):

    <!-- listing: c6/cd2.pl -->

    	the indented listing, as usual

Add `fragment` after the file name if the listing deliberately shows only part of the file (and put `...` on a line of its own where code is left out). Whitespace, line breaks, comments, line numbers (`  7:`), and the `#!`, `use strict;`, `use warnings;` and `use v5.NN;` header lines that the book leaves out by convention are all ignored. `--verbose` lists what was checked, `--suggest` shows where unlinked examples might be in the book, and `--annotate` adds markers for the obvious matches. Files that deliberately don't match any single listing go in `code-examples/LISTINGS-OK`, with the reason. `make check` runs this along with the other checks.
