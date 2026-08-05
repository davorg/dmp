# Data Munging with Perl (2ed) — Update TODO

Findings from a full read-through of `Data Munging with Perl (2ed).pdf` (234 pages), July 2026. Updated after the `dmp` git repo was added to the project.

**Source of truth note:** the `dmp/` folder is the actual Git repo for the book (`chapters/*.md`, built to epub/pdf via the `Makefile`). Confirmed via PDF metadata (`Producer: Skia/PDF ... Google Docs Renderer`) that the standalone PDF is exported from Google Docs, not from this repo — so, as suspected, edits have been happening in both places independently. A full paragraph-and-word-level diff of every chapter (PDF text vs. `chapters/*.md`, 2026-08-05) found the drift is **not one-directional** — see "Sync PDF ↔ Markdown" below before treating either source as canonical wholesale.

## Sync PDF (Google Docs) ↔ Markdown — findings from full diff

Compared every chapter's PDF text against its `.md` file. Most chapters matched almost exactly (front matter, ch2, ch5, ch6, ch7, ch8, ch9, ch10, ch12, appendix-a, appendix-b — only trivial table/formatting artifacts, no real content drift). Three chapters have genuine divergence:

- [ ] **Chapter 11 is the big one.** In the Google Docs/PDF version, the opening section has been rewritten to lead with `Regexp::Grammars` instead of `Parse::RecDescent` (new prose + new code examples using the `%/` hash, `<rule:>` syntax) — none of this is in `chapters/chapter11.md`, which still opens with the old `Parse::RecDescent`-first text. **But the Google Docs rewrite is itself unfinished**: only the intro and the first example ("parsing simple English sentences") were converted. The INI-file example, the CD-file example, the `$::RD_TRACE`/`$::RD_HINT` debugging section, and "Other features of Parse::RecDescent" are all still `Parse::RecDescent`-based in the PDF too — including one leftover transition sentence ("However, Parse::RecDescent provides an easier way to achieve the same result...") that no longer quite makes sense given the new opening. This chapter needs real editorial work, not just a copy-paste sync: decide whether to convert the whole chapter to `Regexp::Grammars` or intentionally keep both tools and make the transition explicit, then bring `chapter11.md` in line with whatever's decided. **Good news:** the code side of this is basically done — see "Ready-to-use assets" below.
- [x] ~~Chapter 1 is missing two things the PDF has.~~ **Done (2026-08-05)** — ported the CD-file editorial aside and the "YAML and JSON... largely taken over from XML" sentence from the PDF into `chapters/chapter01.md`.
- [ ] **Chapter 3 has the opposite problem** — four short "note-to-self"-style asides exist only in `chapters/chapter03.md` (each bounded by a `---` rule) and never made it into Google Docs: a note on `Memoize`/`List::UtilsBy` as modern alternatives to the sort techniques discussed; a note recommending `DBIx::Class` after the DBI section (references "my article Database Access with DBIx::Class"); a note on `Devel::NYTProf` for profiling; and a note on `use feature`, `use VERSION`, and the `-E` flag after the command-line scripts section. These read like draft jottings (informal tone, one typo: "Orciah Manoeuvre" for "Orcish Manoeuvre") rather than finished prose. **Decided: no action needed** — the markdown already has the best version of this content; nothing to port anywhere.

## Ready-to-use assets found in the repo (2026-08-05 untracked-files audit)

The `dmp` folder had 28 untracked files. Most were noise, but a few are drafted work ready to fold in:

- [ ] **`new-code/c11/*` (cds.pl, cds_json.pl, english.pl, ini.pl, files.ini)** — complete, modern rewrites of all three Chapter 11 examples (English sentence parser, INI parser, CD-file parser) using `Regexp::Grammars` with Perl 5.40 features (subroutine signatures, `builtin trim`). `cds_json.pl` outputs the parsed CD data as JSON via `JSON::MaybeXS` — nice bridge to the new JSON chapter. This is what chapter 11's code should become; the prose in `chapter11.md` needs to catch up to it (see Chapter 11 note above).
- [ ] **Two competing weather-example drafts for Chapter 9** — `weather_scrape_2025` (top-level, oddly placed) uses `HTTP::Tiny` + `JSON::MaybeXS` to pull the JSON blob embedded in Yahoo's weather page (`__NEXT_DATA__`) rather than screen-scraping HTML. `new-code/c09/weather` instead scrapes timeanddate.com with `Web::Query`. Need to pick one — leaning toward the JSON-based approach since it fits the book's new JSON emphasis, though scraping a site's internal JSON blob is still fragile long-term; a genuine public API (e.g. Open-Meteo) might be a more durable and equally good JSON example.
- [x] ~~`code-examples/c3/data_printer.pl` + `cd.txt`~~ — not orphaned, just uncommitted: companion code for the `Data::Printer` section already written into `chapter03.md` (lines 603–611). Just needs to be committed.
- [x] ~~14 `chapters/*.docx` files~~ — **deleted (2026-08-05)**. Spot-checked `chapter11.docx` word-for-word against `chapter11.md`: 19 words different out of 4,500. They were just Word exports of the markdown, not a separate source of content.
- Noise, not content: `index.html` (your personal site's homepage, davecross.co.uk — copied in by accident) and `.vscode/` (VS Code's Perl language-server cache). Neither was deleted; worth binning `index.html` and adding `.vscode/` to `.gitignore` when convenient.
- Kept as-is, not book content but harmless: `add-issues`/`import-issues`/`create-labels` (your tooling for pushing the TODO backlog below into GitHub Issues/Projects), `dmp-cover.jpg`/`dmp2-cover.jpg`/`dmp2-cover.webp` (1st + 2nd edition cover art — worth committing properly at some point).

## Structural issues

- [x] ~~Chapter 4 (pattern matching) is missing.~~ **Resolved** — `chapters/chapter04.md` exists in the `dmp` repo, complete (~1050 lines, substr/index/case functions through regular expressions, with summary). It's wired into `chapters.txt` and the build. The standalone PDF was just out of sync with the repo — last repo commit touching chapter 4 is 2024-06-03, which is also the most recent commit in the whole repo, so the PDF was likely exported before that, or via a separate path that dropped it.
- [ ] **"Part IV" is referenced but doesn't exist.** The preface says "PART IV concludes our tour..." but Chapter 12 just follows Part III directly, with no Part IV divider in the actual document.
- [ ] **Front matter is ahead of the chapter it describes.** The preface already says YAML/JSON "have largely taken over from XML," but Chapter 10 is still pure XML content (XML::Parser, XML::DOM, XML::RSS). The intro copy has been updated; the chapter hasn't.

## Outdated code / modules, by chapter

- [ ] **Ch5 — Unicode section** says "Perl version 5.6 includes some support for Unicode" (5.6 was released in 2000). Needs a rewrite around `use utf8` and the core `Encode` module.
- [ ] **Ch6 — Dates** covered only via `Date::Calc` and `Date::Manip`. `Date::Manip` is now considered legacy; `DateTime` is the current standard, with `Time::Piece` (core since 5.10) as the lightweight option. Neither is mentioned anywhere in the book. Note: your own dev.to post "Processing dates and times with Perl" covers this exact ground and could feed the rewrite directly.
- [ ] **Ch7 — Binary data** examples use `Image::Info` (cited at v0.04) and `MPEG::MP3Info`. Both look old/likely under-maintained on CPAN — check current status before reusing as examples.
- [ ] **Ch9 — Extended example ("weather forecasts")** scrapes a Yahoo! page you've already flagged yourself as `[ed: this page is no longer active]`. Good candidate to replace with a call to a JSON weather API — would also cross-link nicely into the new JSON chapter.
- [ ] **Ch11 — Building your own parsers.** See "Sync PDF ↔ Markdown" above — this chapter is mid-conversion from `Parse::RecDescent` to `Regexp::Grammars` in the Google Docs draft, and that conversion isn't finished there either. Once the chapter's content is settled, consider a one-line nod to `Marpa::R2` as another modern alternative.
- [ ] **Appendix B — Essential Perl** teaches the `-w` command-line flag but never mentions `use strict; use warnings;`, which is the standard opening for any Perl script today. Odd gap in a basics appendix.
- [x] **Ch2 — OO section is already solid.** Uses Moo, and accurately describes Perl's new core `class` feature as one to watch (confirmed still experimental as of Perl 5.42, the current stable release). No action needed.

## New topics to consider for relevance

- [ ] **JSON/YAML chapter to replace XML** (per your existing plan). Candidates: `JSON::MaybeXS` (XS backend with pure-Perl fallback) and `YAML::PP` (or `YAML::XS`).
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
- [ ] **Decide XML's fate precisely.** The backlog's item 6 says *modernize* XML with `XML::LibXML` rather than drop it — worth confirming whether that means "replace the chapter with JSON/YAML, full stop" or "replace the chapter, but keep a trimmed/modernized XML section for interop reasons."

## Next session

- Full PDF-vs-markdown diff done, chapter 1 additions ported, chapter 3 asides resolved (no action needed), 28 untracked files audited, docx exports deleted — all 2026-08-05.
- Still open: reconcile chapter 11 (finish the `Regexp::Grammars` conversion using the ready-made code in `new-code/c11/`), pick a weather-example draft for Chapter 9, commit `code-examples/c3/data_printer.pl` + `cd.txt`, then treat `dmp/chapters/*.md` as the sole source of truth and stop editing in Google Docs.
- Plan: start drafting the JSON/YAML chapter to replace Chapter 10, and/or work the punch-list above.
