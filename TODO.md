# Data Munging with Perl (2ed) — Update TODO

Findings from a full read-through of `Data Munging with Perl (2ed).pdf` (234 pages), July 2026. Updated after the `dmp` git repo was added to the project.

**Source of truth note:** the `dmp/` folder is the actual Git repo for the book (`chapters/*.md`, built to epub/pdf via the `Makefile`). Confirmed via PDF metadata (`Producer: Skia/PDF ... Google Docs Renderer`) that the standalone PDF is exported from Google Docs, not from this repo — so, as suspected, edits have been happening in both places independently. A full paragraph-and-word-level diff of every chapter (PDF text vs. `chapters/*.md`, 2026-08-05) found the drift is **not one-directional** — see "Sync PDF ↔ Markdown" below before treating either source as canonical wholesale.

**LeanPub note (2026-08-05):** updates reach the LeanPub WIP edition via manual upload — no GitHub sync is configured, so a built EPUB/PDF from this repo has to be produced and uploaded by hand each time.

**Completion estimate (2026-08-06):** for the LeanPub "percentage complete" field, set to **65%**. My own read was 75–80% — every chapter is structurally complete and readable, and the worst staleness (dead XML chapter, broken weather example, ancient parser tooling) is fixed — but Dave's going with the more pessimistic figure given what's still open below: real rewrites still needed for Ch5 (Unicode) and Ch6 (dates), the Appendix A drift found today, and the smaller polish items (copyright wording, artwork, Appendix B). Worth revisiting this number each time a chapter from the "Outdated code / modules" or "New topics" lists below gets closed out.

## 2026-08-05 pre-release sprint — done

- [x] **Chapter 11 rewritten for `Regexp::Grammars`.** All three examples (English sentences, INI file, CD data file) now use `Regexp::Grammars` throughout, replacing the leftover `Parse::RecDescent` sections. New material covers array-capturing subrules (`<[Name]>`), the separated-list syntax (`<[Name]>+ %sep`), the `<debug:...>` directive (replacing `$::RD_TRACE`/`$::RD_HINT`), and a rewritten "Other features" list (tokens vs. rules, `<require:>`, `<error:>`/`<fatal:>`, `<objrule:>`/`<objtoken:>`, `<grammar:>`/`<extends:>`). The CD example now also uses `trim()` from `builtin` to strip fixed-width padding, which the old version silently left in.
- [x] **`new-code/c11/*` promoted into `code-examples/c11/`**, replacing the old Parse::RecDescent files. Fixed a genuine bug in the process: the CD sample data has 6 records but the footer said "7 Records" in `cds.pl`/`cds_json.pl`, and was missing from `cds.txt` entirely — all three now correctly say "6 Records".
- [x] **Fixed the EPUB build.** `make epub` wasn't resolving `../images/*.png` paths from the repo root, so every image silently failed to embed. Added `--resource-path=.:chapters` to the Makefile's pandoc invocation — verified a clean build with zero warnings and every image embedded.
- [x] **Copyright page now has a self-dating WIP version line.** Added a Copyright section to `chapters/front-matter.md` with `Work in progress version: __BUILD_DATE__`. The Makefile generates `build/front-matter.md` with that token substituted for today's date (`date +%Y-%m-%d`) on every build, so you never have to remember to hand-edit it. `build/` is gitignored.
- [ ] **Needs your review:** the actual copyright wording (publisher, rights language, years) — flagged with a `TODO(Dave)` comment right above it in `front-matter.md` rather than guessing.
- [x] ~~`make pdf` is untested~~ — **confirmed working.** Switched `pdf` from Calibre's `ebook-convert` to `pandoc --pdf-engine=weasyprint` straight from the markdown (lighter dependency, easier for CI later, avoids the LaTeX escaping issue mentioned below). Added `print.css` for page size/margins/running page numbers/forced chapter breaks. Dropped `.mobi`/`kindlegen` support entirely — Amazon deprecated kindlegen years ago.
- [x] ~~Image references broke under WeasyPrint~~ — WeasyPrint resolves relative image paths against the current directory rather than honoring pandoc's `--resource-path` the way the EPUB builder does. All 17 `../images/...` references (chapters 1, 2, 3, 8, 10, 11) changed to root-relative `images/...`, `--resource-path` simplified to `.`. Both `make epub` and `make pdf` confirmed working.

## Sync PDF (Google Docs) ↔ Markdown — findings from full diff

Compared every chapter's PDF text against its `.md` file. Most chapters matched almost exactly (front matter, ch2, ch5, ch6, ch7, ch8, ch9, ch10, ch12, appendix-a, appendix-b — only trivial table/formatting artifacts, no real content drift). Three chapters have genuine divergence:

- [x] ~~Chapter 11 is the big one.~~ **Done (2026-08-05)** — fully rewritten for `Regexp::Grammars` throughout, using the ready-made code from `new-code/c11/`. See sprint summary above.
- [x] ~~Chapter 1 is missing two things the PDF has.~~ **Done (2026-08-05)** — ported the CD-file editorial aside and the "YAML and JSON... largely taken over from XML" sentence from the PDF into `chapters/chapter01.md`.
- [ ] **Chapter 3 has the opposite problem** — four short "note-to-self"-style asides exist only in `chapters/chapter03.md` (each bounded by a `---` rule) and never made it into Google Docs: a note on `Memoize`/`List::UtilsBy` as modern alternatives to the sort techniques discussed; a note recommending `DBIx::Class` after the DBI section (references "my article Database Access with DBIx::Class"); a note on `Devel::NYTProf` for profiling; and a note on `use feature`, `use VERSION`, and the `-E` flag after the command-line scripts section. These read like draft jottings (informal tone, one typo: "Orciah Manoeuvre" for "Orcish Manoeuvre") rather than finished prose. **Decided: no action needed** — the markdown already has the best version of this content; nothing to port anywhere.

## Ready-to-use assets found in the repo (2026-08-05 untracked-files audit)

The `dmp` folder had 28 untracked files. Most were noise, but a few are drafted work ready to fold in:

- [x] ~~`new-code/c11/*`~~ — promoted into `code-examples/c11/` and wired into the rewritten Chapter 11 (2026-08-05).
- [x] ~~Two competing weather-example drafts for Chapter 9~~ — **resolved (2026-08-06):** neither used. Both deleted; replaced with a live Open-Meteo API example in Chapter 10's new JSON section, cross-linked from Chapter 9. See the 2026-08-06 JSON/YAML sprint entry below.
- [x] ~~`code-examples/c3/data_printer.pl` + `cd.txt`~~ — not orphaned, just uncommitted: companion code for the `Data::Printer` section already written into `chapter03.md` (lines 603–611). Just needs to be committed.
- [x] ~~14 `chapters/*.docx` files~~ — **deleted (2026-08-05)**. Spot-checked `chapter11.docx` word-for-word against `chapter11.md`: 19 words different out of 4,500. They were just Word exports of the markdown, not a separate source of content.
- Noise, not content: `index.html` (your personal site's homepage, davecross.co.uk — copied in by accident) and `.vscode/` (VS Code's Perl language-server cache). Neither was deleted; worth binning `index.html` and adding `.vscode/` to `.gitignore` when convenient.
- Kept as-is, not book content but harmless: `add-issues`/`import-issues`/`create-labels` (your tooling for pushing the TODO backlog below into GitHub Issues/Projects), `dmp-cover.jpg`/`dmp2-cover.jpg`/`dmp2-cover.webp` (1st + 2nd edition cover art — worth committing properly at some point).

## Structural issues

- [x] ~~Chapter 4 (pattern matching) is missing.~~ **Resolved** — `chapters/chapter04.md` exists in the `dmp` repo, complete (~1050 lines, substr/index/case functions through regular expressions, with summary). It's wired into `chapters.txt` and the build. The standalone PDF was just out of sync with the repo — last repo commit touching chapter 4 is 2024-06-03, which is also the most recent commit in the whole repo, so the PDF was likely exported before that, or via a separate path that dropped it.
- [ ] **"Part IV" is referenced but doesn't exist.** The preface says "PART IV concludes our tour..." but Chapter 12 just follows Part III directly, with no Part IV divider in the actual document.
- [x] ~~Front matter is ahead of the chapter it describes.~~ **Resolved (2026-08-06):** Chapter 10 is now "Common Data Interchange Formats," covering XML, JSON, and YAML; front matter's TOC blurb updated to match.

## Outdated code / modules, by chapter

- [ ] **Ch5 — Unicode section** says "Perl version 5.6 includes some support for Unicode" (5.6 was released in 2000). Needs a rewrite around `use utf8` and the core `Encode` module.
- [ ] **Ch6 — Dates** covered only via `Date::Calc` and `Date::Manip`. `Date::Manip` is now considered legacy; `DateTime` is the current standard, with `Time::Piece` (core since 5.10) as the lightweight option. Neither is mentioned anywhere in the book. Note: your own dev.to post "Processing dates and times with Perl" covers this exact ground and could feed the rewrite directly.
- [ ] **Ch7 — Binary data** examples use `Image::Info` (cited at v0.04) and `MPEG::MP3Info`. Both look old/likely under-maintained on CPAN — check current status before reusing as examples.
- [x] ~~Ch9 — Extended example ("weather forecasts")~~ **Resolved (2026-08-06):** added a closing note that the Yahoo! page is gone entirely, pointing to Chapter 10's live weather-API example. The HTML::TokeParser teaching content itself is left as-is — still a fine scraping lesson, just not something to build new code against.
- [x] ~~Ch11 — Building your own parsers.~~ **Done (2026-08-05).** Optional future polish: a one-line nod to `Marpa::R2` as another modern alternative.
- [ ] **Appendix B — Essential Perl** teaches the `-w` command-line flag but never mentions `use strict; use warnings;`, which is the standard opening for any Perl script today. Odd gap in a basics appendix.
- [x] **Ch2 — OO section is already solid.** Uses Moo, and accurately describes Perl's new core `class` feature as one to watch (confirmed still experimental as of Perl 5.42, the current stable release). No action needed.
- [ ] **Appendix A (Modules Reference) is now behind the chapters it documents** (found 2026-08-06, while estimating completion %). It has detailed sections on `DBI`, `Number::Format`, `Date::Calc`, `Date::Manip`, `LWP::Simple`, `HTML::Parser`/`HTML::LinkExtor`/`HTML::TokeParser`/`HTML::TreeBuilder`, and `XML::Parser` — but nothing on `XML::LibXML`, `JSON::MaybeXS`, `YAML::PP`, `Regexp::Grammars`, or `HTTP::Tiny`, all of which the narrative chapters now lean on. Today's Ch10/Ch11 rewrites have actually made this gap worse, not better. Needs a pass once Ch5/Ch6 are also modernized, so it only has to be done once.

## Audit coverage — what hasn't been checked yet

Worth knowing when trusting the completion estimate above: the "no
modernization flags" chapters haven't all had the same level of
scrutiny. Ch5, Ch6, Ch7, Ch9, Ch10, and Ch11 have been actively
checked against current Perl/CPAN practice (that's where the open
items above come from). Ch1, Ch2, and Ch4 got a full read during the
original July 2026 pass. **Ch3 and Ch8 got the PDF-sync diff but not
a fresh modernity audit; Ch12 (Looking Back and Ahead) and Appendix B
haven't been specifically checked for datedness at all** — Ch12 is
mostly reflective prose so risk is low, but worth a pass rather than
assuming.

## New topics to consider for relevance

- [x] ~~JSON/YAML chapter to replace XML~~ — **done (2026-08-06)**, using `JSON::MaybeXS` and `YAML::PP` as planned. See sprint entries below for the full rewrite.
- [ ] **DateTime / Time::Piece** modernization of the dates section (see Ch6 above).
- [ ] **REST/HTTP APIs as a data source**, more generally — the book only touches HTTP in passing right now. Ties together the JSON chapter and the dead weather-scraping example.
- [ ] **Modern HTTP client note** — `LWP::Simple` still works but lacks HTTPS/header/error-handling support that `HTTP::Tiny` (core) or `LWP::UserAgent` provide.
- [ ] **Unicode/encoding handling** as a more general topic — data munging today is rarely pure ASCII.

## More backlog items (from `data-munging-with-perl-2e-todos.json`, found 2026-08-05, since deleted — content captured here)

You'd already drafted an 18-item modernization backlog in this file (with `gh`-based scripts to turn it into GitHub Issues). Most overlaps with the above; these are the ones that don't:

- [ ] **`Path::Tiny`** as a cleaner, safer alternative to manual `opendir`/`glob`/`unlink`/`open` for file and directory ops.
- [ ] **`CHI` or `Cache::Memory`** for real-world caching strategies, as a companion/upgrade to the existing `Memoize` coverage.
- [ ] **New section on testing with `Test2::V0`** — basic tests for file parsing and transformation logic. The book currently has no testing content at all.
- [ ] **`Benchmark::Timer` or `Time::HiRes`** alongside (or instead of) the existing `Benchmark.pm` coverage, for finer-grained timing.
- [ ] **Audit all `use` statements for core vs. CPAN** — annotate which modules ship with Perl and which need installing, and make sure things like `say`, `state`, and signatures are explicitly enabled where used.
- [ ] **Audit `my $foo = shift` idioms** — replace with subroutine signatures where the target Perl version supports it (5.36+).
- [ ] **Closing appendix: glossary of modern CPAN modules**, grouped by purpose (logging, JSON, web, OO, date/time, etc.) — natural companion to the existing Appendix A module reference.
- [x] ~~Decide XML's fate precisely.~~ **Decided (2026-08-05), done (2026-08-06):** the chapter is JSON/YAML/XML, not a straight swap — XML stays, trimmed down and modernized (`XML::LibXML` rather than `XML::Parser`/`XML::DOM`), because "some poor souls still use it." Retitled **Chapter 10: Common Data Interchange Formats**.

## Artwork

- [ ] **Redraw the figures.** :-) All 19 images in `images/` are 1st-edition-era diagrams (data structure sketches, parser trees, etc.) — worth a fresh pass once the content settles, both for a visual refresh and because at least one is now stale: `11-3-item-array.png` (the old `@item` array diagram) is no longer referenced anywhere now that Chapter 11 doesn't use Parse::RecDescent's `@item`/`%item` — either repurpose it for a new "shape of `%/`" diagram or drop it.
- [ ] **Three images now orphaned** (found via a `make epub` image-count check, 2026-08-06): `11-3-item-array.png`, `10-1-output-from-xml-parser-tree-style.png` (both above), plus `foreword-diagram-key.png`, which isn't referenced anywhere in the current text at all — worth checking whether the foreword ever pointed to it, or whether it can just be dropped.

## 2026-08-06 — Chapter 10 capstone example rewritten

- [x] **"Producing different document formats" replaced.** The old ~570-line section (258-line `XML::Parser`-based dispatch script converting a README into POD/HTML/text) is gone. New "one dataset, three formats" example: parses the book's 6-CD collection from `cds.xml` via `XML::LibXML` + XPath, emits JSON (`JSON::MaybeXS`) and YAML (`YAML::PP`) from the same in-memory structure — ~17 lines of code total, plus a short "Going back the other way" subsection covering XML round-tripping in prose only (no code, per your request). Files promoted to `code-examples/c10/cds.xml` and `cds.pl`; the old `readme.xml`/`transform.pl` example files are now orphaned and were deleted.
- [x] ~~Untested~~ — **confirmed working** by Dave, pushed.
- [ ] **Still outstanding for the full Ch10 rewrite:** this is one example, not the whole chapter restructure. Still need: dedicated JSON section, dedicated YAML section, and a decision on how much of the remaining `XML::Parser`/`XML::DOM`/`XML::RSS` content gets trimmed down to `XML::LibXML` vs. cut outright. Chapter title/intro ("What this chapter covers") not yet updated to reflect JSON/YAML.

## 2026-08-06 — XML::Parser / XML::DOM replaced with XML::LibXML

- [x] **"Parsing XML with XML::Parser" (5 styles: Stream/Debug/Subs/Tree/Objects) and "XML::DOM" sections replaced.** ~760 lines covering two legacy modules cut down to one "Parsing XML with XML::LibXML" section (~125 lines): XPath-based parsing (`findvalue`/`findnodes`) using the same `weather.xml` example as before, a short generic tree-walker, the same `eval`-based error handling, a note on `XML::LibXML::Reader` for streaming huge files, and a closing paragraph naming `XML::Parser`/`XML::DOM` for readers who meet them in old code — no worked examples for either. Chapter's "What this chapter covers" bullets and Summary updated to match — they still described the old structure. Chapter now ~575 lines, down from ~1215; will be padded back out once JSON/YAML sections exist.
- [ ] **Untested** — same caveat as everything else this sprint: no CPAN access in this sandbox. Please run the `weather.xml` examples before publishing.
- [ ] **Orphaned image:** `images/10-1-output-from-xml-parser-tree-style.png` (the Tree-style diagram) is no longer referenced anywhere — same situation as `11-3-item-array.png`, candidate for the "redraw the figures" pass.

## 2026-08-06 — Chapter 10 renamed, XML markup style, JSON/YAML sections written

- [x] **Chapter 10 renamed "Common Data Interchange Formats."** Intro rewritten: HTML's shortcomings (kept), then XML/JSON/YAML each explained in turn using the same weather-forecast example rendered in all three formats, closing with a "reach for JSON talking to an API, YAML when a human edits the file, expect XML in older/document-centric systems" summary. XML's DTD/valid-vs-well-formed material trimmed to two paragraphs. Front matter TOC blurb updated to match.
- [x] **All-caps XML tags lowercased.** You flagged `<FORECAST>`/`<OUTLOOK>`/`<TEMPERATURE>` etc. as hard to read — swept to lowercase across `chapter10.md`, `weather.xml`, and `weather_xpath.pl`. Attribute values (`MAX`/`MIN`/`C`) left as-is; nothing else in the repo had the same problem.
- [x] **New "Working with JSON" section.** `JSON::MaybeXS` intro, then a live example calling the [Open-Meteo](https://open-meteo.com/) weather API (free, no key) for London's current conditions and today's high/low — this is the real, working replacement for Chapter 9's dead Yahoo! scraper, cross-linked both ways. Verified the actual JSON response shape against Open-Meteo's own docs rather than guessing.
- [x] **New "Working with YAML" section.** `YAML::PP` reading a small hand-written `cities.yaml` (name/lat/long per city), looping over it to call the same API per city — YAML as human-edited config, JSON as wire format, same data shape either way once parsed.
- [x] **Chapter 9 updated** with a closing note that the Yahoo! page is now gone entirely, pointing to Chapter 10. Deleted the two superseded draft scripts (`new-code/weather_scrape_2025`, `new-code/c09/weather`).
- [x] **Ch10 "What this chapter covers" and Summary** updated for JSON/YAML; "Further information" corrected — `HTTP::Tiny` is core Perl (5.14+), unlike the other modules in the chapter.
- [ ] **Untested, and this one makes real HTTP calls** — `code-examples/c10/weather_api.pl` and `cities_weather.pl` hit the live Open-Meteo API. Worth running before publishing, both to confirm the code works and that the response shape hasn't changed.
- [ ] **XML::RSS not touched.** Still uses `XML::Parser` internally (that's fine, it's a stable dependency, not something the chapter teaches directly) — worth a quick look now everything else in the chapter is modernized, but not urgent.

## Next session

- Review the copyright wording in `front-matter.md`.
- Run and check the new Ch10 weather examples (`weather_xpath.pl`, `weather_walk.pl`, `weather_api.pl`, `cities_weather.pl`, `cds.pl`) and the Ch11 `cds.pl` — see "Untested" notes above and in prior sprints.
- Redraw the figures (see Artwork above), including the two now-orphaned images (`10-1-output-from-xml-parser-tree-style.png`, `11-3-item-array.png`).
- Revisit the Chapter 3 backlog items.
- Automation: GitHub Actions workflow to build on push, once the current Makefile has proven itself over a release or two (deferred for now).
