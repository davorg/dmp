# Manuscript completion plan — Data Munging with Perl (2ed)

**Target:** London Perl Workshop, 21 November 2026. Working backwards: four
weeks for production (ebook + paperback) means the manuscript needs to be
complete by **Saturday 24 October 2026** — eight weeks from now.

**Release cadence (set 2026-09-28):** fortnightly WIP releases to LeanPub,
announced on Fosstodon. **2 October — done and promoted.** Next: **16
October**. A third, **30 October, is maybe-only**: it falls after the
24 Oct manuscript-complete target above, by which point the book should be
in final production (proofing/typesetting/print) rather than still taking
WIP content changes — if it happens at all, it should be the locked text
going out, not a snapshot of new work. Assume 16 Oct is the last *content*
WIP release unless the schedule slips. See TODO.md for the build/upload
checklist and the completion-percentage note.

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
- [x] Appendix B: add the missing `use strict; use warnings;` mention
  alongside the existing `-w` flag coverage — done (2026-09-21), but
  turned into a full from-scratch rewrite rather than a patch, once a
  quick read-through turned up how much else in there was stuck in
  2001. See TODO.md for full detail.
- [x] Full modernity audits of Chapters 1, 2, and 12 — done
  (2026-09-21). Ch1/Ch2: mechanical fixes only (typos, dead links, a
  handful of code bugs) plus the postfix-dereference sweep across
  Chapters 2–11 and Appendix B this same session turned up. Ch12
  ("Looking Back and Ahead"): its "where to find Perl support"
  section was the real find — rewritten wholesale to replace a set of
  now-dead-or-misleading community references (comp.lang.perl.misc,
  *The Perl Journal*, perl.com mislabeled as the official/definitive
  site) with the current landscape (PerlMonks, r/perl, Perl Weekly,
  Planet Perl, The Weekly Challenge, TPRC, The Perl & Raku
  Foundation, Stack Overflow's `perl` tag framed honestly as an
  archive rather than active Q&A). Also rewrote the book-recommendation
  paragraph: *Learning Perl* and *Programming Perl* are the two still
  worth buying, *The Perl Cookbook* and *Object Oriented Perl* moved
  to "worth a skim if you find one, but dated" (swapping out
  *Mastering Regular Expressions*, which was dropped from the chapter
  entirely), and Perl School added as the modern alternative to
  traditional publishing. Dropped Damian Conway's *Object Oriented
  Perl* as a formal recommendation everywhere it appeared (Ch2's two
  citations too) — a decision Dave had been sitting on since the
  postfix-deref sweep flagged it. See TODO.md for full detail.

## Week 5 (26 Sep – 2 Oct): Chapter 4 audit, refresh CD data, tidy artwork

- [x] Full modernity audit of Chapter 4 (pattern matching / regular
  expressions) — done (2026-09-28). Turned out to be the
  least-touched chapter in the book, with no cleanup pass since the
  original 2001 text. `given`/`when` isn't mentioned anywhere, so
  nothing to remove there. Mechanical fixes: a systematic
  markdown-escaping bug that had left ten broken regexes/strings in
  the text, plus a handful of unrelated bugs (a mismatched-bracket
  typo, a bareword filehandle, a numbering gap, and a `translate.pl`
  listing that had drifted entirely from its own walkthrough).
  Content additions, all per Dave's requests and confirmed working:
  a new "A library of regular expressions" section on
  `Regexp::Common`; an age caveat on `Text::Bastardize` plus
  `Email::Valid`'s ~100-line RFC822 regex as a "regex insanity"
  example; a new "Transliterating characters with tr///" section;
  named captures and non-greedy quantifiers (paying off a broken
  "covered later in the chapter" promise) added to the regex syntax
  walkthrough; a pointer to Chapter 5's Unicode-properties section
  for `\p{...}`/`\P{...}`. Also fixed: the `/etc/passwd` section
  (broken pseudo-list, stray footnotes, backwards shadow-password
  framing — now a real numbered list using Dave's own `/etc/passwd`
  entry) and the `use locale` mention in "Case transformations"
  (previously unexplained — now described properly, with a pointer
  to Ch5's `fc()`/`Unicode::Collate`). Finished with a "what's
  changed in 25 years" reality check per Dave's request, which added
  lookbehind and `\K`, corrected a genuinely wrong explanation of
  `/m` vs `/s` (the old text said `.` matching newline was `/m`'s
  doing — that's `/s`), and added `/a`, `/xx`, and `/r` (flagged in
  the text as arguably the single most useful of the bunch);
  `re::engine::RE2` and `String::Approx` were considered and declined.
  Checked both appendices for knock-on effects: Appendix A was
  missing a reference section for `Regexp::Common` (now added,
  slotted in chapter order between Number::Format and Time::Piece);
  Appendix B doesn't mention regular expressions at all, a
  pre-existing gap left as-is pending Dave's steer. See TODO.md for
  full detail.
- [x] Refresh the CD collection example data — done (2026-09-28). Swapped
  the dated dataset (Hunky Dory 1971, etc.) for Lily Allen/David
  Bowie/LCD Soundsystem across prose, code examples, and all 9 affected
  diagrams; also widened the fixed-width Artist/Title columns to fit
  the new longest values, fixed a stale Parse::RecDescent cross-ref in
  Ch8, removed leftover Lord-of-the-Rings names from Appendix B, and
  added a light aside on younger readers never having owned a CD.
- [x] Wire `preface-diagram-key.svg` (renamed from `foreword-diagram-key.svg`
  — 2026-09-28 — it belongs with the Preface's "Typographical conventions"
  section, not the Foreword) into the Preface, alongside the existing
  array/hash/reference bullets it illustrates.
- [x] Clean up the three orphaned images — done (2026-09-28).
  `11-3-item-array.png` (old Parse::RecDescent `@item` diagram) deleted
  and replaced with `11-3-ini-file-raw-parse-tree.svg`, showing the
  equivalent raw `%/` parse-tree shape for Regexp::Grammars, wired into
  Chapter 11 right where the prose already described that shape in
  words. `10-1-output-from-xml-parser-tree-style.png` deleted; no
  direct analog since `XML::LibXML`'s DOM isn't a plain Perl data
  structure, so Chapter 10 got two new diagrams instead of a reskin —
  see below.
- [x] New Chapter 10 diagram, spotted while closing out the `10-1`
  orphan (2026-09-28): `10-1-weather-xml-dom-tree.svg`, a tree diagram
  (not the usual array/hash/reference convention) tracing the DOM the
  `walk()` example recurses over. A second diagram was also built for
  the Unicode-in-JSON-and-YAML section (a colour-coded flow diagram
  tracing the chapter's own Björk example through `decode_json` versus
  `JSON->new->decode` without `->utf8`) but Dave decided on review it
  didn't add anything the prose wasn't already doing — dropped.

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
- [x] Audit every "available/bundled since Perl 5.X.Y" claim in the book
  for citing a real stable release, not a development track — done
  (2026-10-06). Five real corrections (incl. a wrong sort-stability
  claim and a stale `experimental::builtin` warning suppression); see
  TODO.md.
- [x] (Done 2026-10-06: short "regex essentials" section added.) Decide what, if anything, Appendix B should say about regular
  expressions — currently nothing, spotted 2026-09-28 during the Ch4
  reality check. Appendix B points to Chapter 2 for OO in one line;
  no equivalent exists for Chapter 4's regex coverage. See TODO.md.

## Week 7 (10–16 Oct): Run and verify everything untested

- Run the Ch10 weather scripts (`weather_xpath.pl`, `weather_walk.pl`,
  `weather_api.pl`, `cities_weather.pl`), `cds.pl` in both Ch10 and
  Ch11, and the Ch5 Unicode examples.
- Spot-check at least one SVG's arrowheads in a real browser.
- Finalize the copyright wording in `front-matter.md`.

## Week 8 (17–23 Oct): Full read-through and consistency pass

- Front-to-back proofread; verify cross-references still make sense
  after everything's moved.
- Eliminate American English from the text — spelling (`-ize`/`-or`
  forms, etc.) and word choice, consistently through to British
  English. Added to the backlog 2026-09-28; see TODO.md for detail.
- Confirm the completion estimate can genuinely go to 100%.
- Final clean `make epub` / `make pdf` build.
- **Manuscript complete: 24 October 2026.**

---

This assumes each week lands roughly on schedule. Week 6 has more
optional scope than fits in one week by design — if weeks 1–5 run long,
that's the week to trim rather than eating into verification or the
final proofread.
