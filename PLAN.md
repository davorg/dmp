# Manuscript completion plan — Data Munging with Perl (2ed)

**Target:** London Perl Workshop, 21 November 2026. Working backwards: four
weeks for production (ebook + paperback) means the manuscript needs to be
complete by **Saturday 24 October 2026** — eight weeks from now.

See `TODO.md` for the full detail behind every item below.

## Week 1 (29 Aug – 4 Sep): Chapter 7 audit

- Audit Chapter 7 (binary data) for outdated modules/techniques, starting
  with the concrete question already on the table: are `Image::Info` and
  `MPEG::MP3Info` still reasonable to teach?
- Fix the "Part IV" reference — the preface mentions a Part IV that doesn't
  exist in the actual document.
- While in the chapter, check whether Ch7's binary/packed-data layouts
  would benefit from a diagram.

## Week 2 (5–11 Sep): Chapter 3 audit

- Full modernity audit of Chapter 3 ("Useful Perl idioms") — the broadest
  of the three remaining chapter audits. Last touched for `Path::Tiny`
  (2026-08-22) and the PDF-sync diff, but never checked chapter-wide.
- Tidy Chapter 5's heading order — the Unicode section currently sits
  nested oddly under "Converting the character set."

## Week 3 (12–18 Sep): Chapter 8 audit

- Full modernity audit of Chapter 8 (complex data formats / Part III
  opener) — diagrams are redrawn, but the prose hasn't been checked.
- Quick keep-or-trim decision on the EBCDIC mention in Chapter 12's
  "things to consider" checklist.

## Week 4 (19–25 Sep): Appendix A rewrite

- Rewrite Appendix A (Modules Reference) now that Ch3/Ch7/Ch8 are settled.
  Needs sections for `XML::LibXML`, `JSON::MaybeXS`, `YAML::PP`,
  `Regexp::Grammars`, and `HTTP::Tiny`.
- Appendix B: add the missing `use strict; use warnings;` mention
  alongside the existing `-w` flag coverage.

## Week 5 (26 Sep – 2 Oct): Refresh CD data, tidy artwork

- Refresh the CD collection example data — the album years (Hunky Dory
  1971, etc.) read as dated. Touches prose, code, and diagrams across
  several chapters.
- Wire `foreword-diagram-key.svg` into Chapter 1 or 2, once caption
  wording is settled.
- Clean up the three orphaned images.

## Week 6 (3–9 Oct): New-topics decision + version-citation sweep

- Decide what from the "new topics" backlog actually makes it in — not
  all eight open items will realistically fit. Standout candidate: a
  `Test2::V0` testing section (the book currently has none). Treat the
  rest (REST/HTTP-as-data-source, modern HTTP client note, `CHI`
  caching, `Benchmark::Timer`, core-vs-CPAN `use`-statement audit,
  `shift`-to-signatures audit, CPAN-glossary appendix) as stretch goals.
- Audit every "available/bundled since Perl 5.X.Y" claim in the book for
  citing a real stable release, not a development track.

## Week 7 (10–16 Oct): Run and verify everything untested

- Run the Ch10 weather scripts (`weather_xpath.pl`, `weather_walk.pl`,
  `weather_api.pl`, `cities_weather.pl`), `cds.pl` in both Ch10 and
  Ch11, and the Ch5 Unicode examples.
- Spot-check at least one SVG's arrowheads in a real browser.
- Finalize the copyright wording in `front-matter.md`.

## Week 8 (17–23 Oct): Full read-through and consistency pass

- Front-to-back proofread; verify cross-references still make sense
  after everything's moved.
- Confirm the completion estimate can genuinely go to 100%.
- Final clean `make epub` / `make pdf` build.
- **Manuscript complete: 24 October 2026.**

---

This assumes each week lands roughly on schedule. Week 6 has more
optional scope than fits in one week by design — if weeks 1–5 run long,
that's the week to trim rather than eating into verification or the
final proofread.
