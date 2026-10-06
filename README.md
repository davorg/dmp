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
