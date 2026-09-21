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

## Week 2 (5–11 Sep): Chapter 3 audit — done (2026-09-08)

- [x] Full modernity audit of Chapter 3 ("Useful Perl idioms") — the broadest
  of the three remaining chapter audits. Last touched for `Path::Tiny`
  (2026-08-22) and the PDF-sync diff, but never checked chapter-wide.
  Landed as 15 mechanical fixes, a restructured Benchmark section
  (current numbers first, 2001 as historical aside), an SQLite-based
  DBI rewrite with a DBD-module comparison table, and a new Testing
  section (Test::More + Test2::V0) — the latter pulled forward from
  Week 6's stretch-goal list.
- [x] Tidy Chapter 5's heading order — Unicode promoted to its own H2
  (no longer nested under "Converting the character set," which never
  actually taught character-set conversion), "Data conversions"
  relocated to introduce just line endings and number formats.

## Week 3 (12–18 Sep): Chapter 8 audit — done (2026-09-14)

- [x] Full modernity audit of Chapter 8 (complex data formats / Part III
  opener) — diagrams are redrawn, but the prose hasn't been checked.
  Found and fixed two stale forward-references (`XML::Parser`→
  `XML::LibXML`, `Parse::RecDescent`→`Regexp::Grammars`, matching the
  Ch10/Ch11 rewrites those chapters actually got), a real data bug
  (the chapter's two CD-file examples disagreed with each other on
  three album years — reconciled against real release dates), and a
  likely leftover typo. Part III's own heading ("Simple data
  parsing") was flagged as misleading but needs an actual rethink
  rather than a quick fix — left alone for now, logged in TODO.md.
- [x] Quick keep-or-trim decision on the EBCDIC mention in Chapter 12's
  "things to consider" checklist — kept, reworded so Unicode reads as
  the assumed default rather than an equal alternative to ASCII.

## Week 4 (19–25 Sep): Appendix A rewrite

- [x] Rewrite Appendix A (Modules Reference) now that Ch3/Ch7/Ch8 are settled
  — done (2026-09-21). Went further than the original scope: also
  dropped `Date::Calc`/`Date::Manip`/`XML::Parser` entirely (all three
  superseded in the narrative chapters, so no legacy entry either),
  added `Time::Piece`/`DateTime` (the Ch6 gap the original plan
  missed), and added a brand-new `Web::Query` section to both Chapter
  9 and Appendix A — Dave's own current go-to for screen-scraping,
  not originally on the list. See TODO.md for full detail.
- [ ] Appendix B: add the missing `use strict; use warnings;` mention
  alongside the existing `-w` flag coverage.

## Week 5 (26 Sep – 2 Oct): Refresh CD data, tidy artwork

- Refresh the CD collection example data — the album years (Hunky Dory
  1971, etc.) read as dated. Touches prose, code, and diagrams across
  several chapters.
- Wire `foreword-diagram-key.svg` into Chapter 1 or 2, once caption
  wording is settled.
- Clean up the three orphaned images.

## Week 6 (3–9 Oct): New-topics decision + version-citation sweep

- Decide what from the remaining "new topics" backlog actually makes it
  in — the standout candidate, a testing section, landed early in
  Chapter 3 (2026-09-08). The `shift`-to-signatures item also jumped
  the queue: its explanatory groundwork (a new "Feature pragmas"
  section in Chapter 3) landed 2026-09-14, and the code conversion
  itself is unblocked now shell access is back. `CHI`/`Cache::Memory`
  and `Benchmark::Timer`/`Time::HiRes` also jumped the queue, in the
  other direction — decided against (2026-09-21), ahead of writing
  Appendix A, so its module list would be final. Treat the rest
  (REST/HTTP-as-data-source, modern HTTP client note, core-vs-CPAN
  `use`-statement audit, CPAN-glossary appendix) as stretch goals.
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
