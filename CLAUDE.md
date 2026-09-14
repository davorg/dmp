# Working notes for Claude — Data Munging with Perl (2ed)

This file is a durable memory backstop for this project. It's read
automatically at the start of every session working in this repo, so
it's the recovery path if conversation history or Claude's own memory
store is ever lost. Keep it updated as conventions change; it should
stay short enough to read in one pass.

For live project status, always check `PLAN.md` (the 8-week schedule
to manuscript freeze) and `TODO.md` (the detailed backlog behind every
item) first — this file covers conventions and gotchas that don't
belong in either of those.

## Deadlines (see PLAN.md for the full schedule)

- Manuscript complete: **24 October 2026**
- London Perl Workshop (publication target): **21 November 2026**
- LeanPub WIP releases: fortnightly on Fridays (4 Sep, 18 Sep, 2 Oct,
  16 Oct — final normal WIP before the freeze)

## Workflow conventions

- **Always show a diff of substantive edits and wait for explicit
  approval before `git commit`.** Purely mechanical fixes can be
  batched into one review, but nothing gets committed silently.
- When a chapter needs restructuring or a rewrite beyond small fixes,
  come back with a list of proposed edits before touching the file,
  unless already given a specific instruction to execute.
- Update `PLAN.md`/`TODO.md` to reflect completed work as part of
  finishing a task, not as an afterthought — but still show the diff
  before committing, same as any other change.

## Sandbox / tooling gotchas

- **No live CPAN access** in the sandbox (network is allowlisted and
  blocks cpan.org). To self-test Perl code that depends on modules
  that can't be installed (Moo, SVG, DBI, Path::Tiny, etc.), write a
  small local stub matching the module's documented API rather than
  skipping verification.
- **No `rsvg-convert`** — only ImageMagick `convert`, which silently
  fails to draw `<marker>`-based arrowheads (the arrow line renders
  with no visible tip). Real renderers (browsers, EPUB readers,
  WeasyPrint) handle `<marker>` fine, but for anything that needs to
  be *verified in this sandbox*, use inline `<polygon>` triangles
  instead so the preview is trustworthy.
- **File-mode noise**: the Windows-mount quirk in this sandbox makes
  edited files show as `755`/executable in `git diff` even after
  `git update-index --chmod=-x`. Run that command before committing;
  it's cosmetic and reappears in `git status` afterward but doesn't
  affect what's actually committed (verify with `git show --stat` /
  `git ls-files -s` if in doubt).
- **Edit tool + tab-indented code blocks**: the Read tool's
  line-numbered display doesn't reliably preserve exact tab bytes for
  copy-paste into `Edit`, so edits touching tab-indented Perl code
  blocks fail with whitespace mismatches. Use `sed -i` with freshly
  re-verified line numbers (re-check via `grep`/`sed -n` before each
  call, since earlier edits shift line numbers), or a small Python
  script reading/writing by line index for larger multi-line block
  replacements.

## House style

- **Markdown headings**: H1 and H2 use Setext style (title line
  followed by `===` or `---` underline); H3 and deeper use ATX style
  (`###`, `####`, ...). Underline length matches the heading text
  length.
- **SVG diagrams**: Helvetica/Arial sans-serif for labels, `DejaVu
  Sans Mono` for code/values. Colors: `#0f766e` (teal) for section
  labels, `#1a1a2e` (dark) for body text, `#f8fafc`/`#cbd5e1` for
  neutral boxes, `#bae6fd`/`#0f766e` for highlighted boxes. Arrowheads
  are inline `<polygon>` triangles, not `<marker>` refs (see sandbox
  gotcha above). Build diagrams from the chapter's own worked example
  data where possible, not invented numbers.
- **Part titles**: short, abstract noun phrases, not literal
  descriptions of technique (Part I "Foundations", Part II "Data
  munging", Part III "Data parsing", Part IV "The big picture").
  Separator is " - " (hyphen), not a colon.
- **Perl baseline for code examples** (established 2026-09-14): every
  example in the book is meant to be read as if it begins with
  `use v5.36;` — the first release where subroutine signatures are
  non-experimental. Write subroutines with signatures
  (`sub greet($name) { ... }`), not manual `@_`/`shift` unpacking.
  This is a book-wide retrofit in progress (scope and status tracked
  in TODO.md) — don't assume an existing example has already been
  converted, but write anything new this way, and prefer signatures
  when touching an old-style sub for an unrelated reason too.

## External systems

- **Google Drive: "Project Portfolio — Three Ps"** spreadsheet is
  Dave's cross-project tracker; a separate ChatGPT "Project Planning"
  chat also reads it. Row 3 is this project, and Claude is responsible
  for keeping it accurate. The Progress % column only moves on a
  public LeanPub WIP release day (fortnightly Fridays) — don't bump it
  for internal milestones like finishing a chapter audit. Other fields
  (deadline, next commercial action, notes) should track `PLAN.md`/
  `TODO.md`.
