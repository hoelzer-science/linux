# CLAUDE.md — linux

Permanent onboarding for this repository. Changes only when project knowledge
changes. Current working state lives in `NEXT.md`; session history in
`docs/sessions/`. Both are gitignored.

> Created from **teaching-template** with "Use this template", so it has an
> *unrelated* git history starting from a single initial commit. Sync is by
> **cherry-pick only** — never merge or rebase, there is no common ancestor.

## What this is

A public, module-agnostic crash course in the command line, package management
and Git. Deployed to **linux.hoelzer.science**. Written notes are the primary
artifact; `slides.qmd` is a short revealjs kickoff deck, secondary by design —
it is a map to the four parts, not a replacement for them.

**The deck is written differently from a lecture deck, and deliberately.** A
course lecture assumes a narrator, so its slides are sparse. This deck has to
survive both being clicked through alone (Martin may not present it the first
time it is used) and being presented live in a later year — so slide bodies
carry complete sentences, while `::: {.notes}` carries the live-presenter
talking points. The file's own header comment says this; do not sparsify it to
match the lecture convention, that would break the self-serve case.

Four parts, and only the first one gates anything:

| | | |
|---|---|---|
| **Part 1** | terminal, filesystem and paths, commands and parameters, pipes and redirection, wildcards | **gates a first practical** |
| Part 2 | pixi primary, conda/mamba as the thing readers will meet anyway | |
| Part 3 | Git and GitHub | |
| Part 4 | Markdown, JSON, CSV/TSV, line endings and encodings | |

**Only Part 1 gates the practicals**, so the minimum viable dependency is much
smaller than the whole course.

**Part 4 was added on Martin's list** (2026-08-18) and is explicitly the
extensible one: formats get added as they earn a place, and it does not have to
be complete to be useful.

## This repository is PUBLIC — and that is load-bearing

Everything here is world-readable: files, commit messages, history. Force-push
does not remove old commits from GitHub; they stay fetchable by full SHA.

- **Nothing may name an institution, a module code, a term or a scheduled
  course.** Not in a committed file, not in a commit message, not in the
  repository description. This is the same constraint the hub carries.
- **`instructor/incoming/` is gitignored**, and this is the single most
  important difference from the course repository. There, drops are committed
  and kept as the record of what was handed over — safe, because that repo is
  private. Committing a dropped `.pptx` here would publish the deck, its
  figures and whatever licence they carry.
- **Figure provenance is not best-effort here.** The course repo relaxes it
  because the site is behind basic auth and the repo is private; neither is
  true here. A figure whose licence cannot be established does not go in.

## It serves three modules, so write it module-agnostic

Martin widened the remit on 2026-08-18: this is no longer just a prerequisite
for one module's practicals. It should also serve **Angewandte Bioinformatik**
(a Master module) and a planned **Digital Health** module for medical-technology
students.

So: no assumption that the reader is a biotechnologist, no dependence on any one
course's case study, and examples that are **illustrative rather than
load-bearing** — ordinary files and folders, not domain data.

"Linked, never copied" now has three consumers to keep from drifting, which is
what makes the separate public repo do real work rather than just being tidy.
Each module links it from its own guide; the hub links it from `resources.qmd`.
Neither before the relevant part exists.

## Common commands

```bash
pixi install
pixi run preview   # live-reloading site
pixi run test      # execute every shell example on the site
pixi run site      # render into _site/
pixi run check     # links + output guards
```

Before pushing, run what CI runs, in CI's order:

```bash
pixi run lint && pixi run test && pixi run site && pixi run check
```

**Pushing to main IS publishing.** There is no release gate and no auth worker —
both were removed from the template's infrastructure, deliberately. A course
holds sessions back until the week they are taught; a reference site has nothing
to hold back.

## Every command on the site is executed, and that is the point

`tests/test_examples.py` extracts the `bash` blocks from `parts/*.qmd` **and
`slides.qmd`** and runs them in order, in one shell, in a scratch directory
with `HOME` pointed at it. Blocks share state, exactly as they do for a reader
working down the page — see "A page's blocks share one cwd" below, which is
the sharpest way that bites.

This is the most testable material the teaching project has produced. Prose
about what a tool does cannot be checked mechanically; a command can. **Where a
claim can be turned into a runnable example, do that.**

- **Excluding a block** (`{.bash .no-run}`) is budgeted **per page**
  (`NO_RUN_BUDGET` in the test file), not a single flat number. Part 2 installs
  software, so almost nothing on it can honestly run in CI — a global cap would
  have forced either a dishonest page or a meaningless limit. Each entry carries
  a comment saying what on that page genuinely cannot execute; raising a number
  is a decision to justify in the same commit, not a formality. A page whose
  every block is excluded (`02-packages`) skips rather than fails.
- **What is NOT verified: the `text` blocks showing output.** They are
  illustrative. An exact comparison fails on correct-but-machine-specific things
  — home paths, `ls` column widths, locale sort order — and loosening it until
  it passed would leave an assertion that asserts nothing. Say what the test
  tests; do not let the page imply more.

### A page's blocks share one cwd — a `cd` that does not return strands everything after it

Every block on a page runs as one continuous script, so a `cd` in one block is
still in effect for every later block, exactly as it would be for a reader
typing down the page. Adding a worked example that does `mkdir foo && cd foo`
partway through Part 1 — the space-in-filenames example, 2026-08-18 — silently
moved every later relative path (`data/first.txt`, `result.txt`, `fruit.txt`)
one directory too deep, because nothing returned to the parent afterwards.

**The isolated test of the new block passing proves the block works alone, not
that it composes with what follows it.** This was caught only by tracing the
full `cd`/`mkdir` sequence across the whole page by hand before trusting the
suite, not by the suite itself — the harness would have caught it too (a later
block referencing a now-unreachable path fails loudly), but only after the fact.
When inserting a block that changes directory, trace what comes after it, or
end the block with the `cd` that undoes it.

### Git needs an identity, and platforms disagree on what happens without one

Apple's git (2.50.1, this repo's usual dev machine) silently falls back to an
identity derived from the OS account and hostname when `user.name`/`user.email`
are unset anywhere — with only a warning. Ubuntu's git, in CI, has no such
fallback and hard-fails with "Author identity unknown." The kickoff deck's git
example passed locally and failed on its first real CI run for exactly this
reason (2026-08-18) — reproducing the isolated-`HOME` conditions locally first
(`env -i HOME=... bash -c '...'`) is what confirmed the platform difference
before trusting a fix.

**Every page with its own git example needs its own `git config --global
user.name`/`user.email` step.** Each page's test runs in an independent,
unconfigured `HOME` by design (see above), so a page cannot rely on another
page's setup having run first — a real reader working through one page alone
never touched the other either.

### Run the tests on macOS as well as Linux

**CI runs Ubuntu, and that is not sufficient.** Linux ships GNU coreutils and
macOS ships BSD; the BSD versions reject `--help` and long parameter names like
`--lines`. The very first run of this harness — on a Mac — caught `head --help`
and `head --lines 1`, both of which CI would have passed in silence, and both of
which would have been shipped to every Mac reader.

The material now uses the portable short forms and teaches the GNU/BSD split as
a thing readers will actually hit. **A green CI run is evidence about Linux
only.**

## Authoring

The same division of labour as the course repo: **Martin decides what is taught
and vouches for every claim; the session drafts, structures and builds.** His
material arrives through `instructor/incoming/` (gitignored here — see above).

- **Assume no command line experience.** No prior Linux, no terminal, no
  programming.
- **Written material is English.** The consuming modules are taught in German,
  so structural terms get a German gloss in parentheses on first use — terminal
  (dt. *Terminal*), wildcard (dt. *Platzhalter*). Sparingly: this is a reference,
  not an exam subject.
- **Reference format, not lecture format.** These pages are meant to be
  scrolled, searched and copied from at a terminal. Long pages with a deep table
  of contents beat many short ones.
- **The source deck is not to be ported 1:1.** An existing Google Slides deck
  covers some of this. Slides are a poor reference format for commands people
  need to copy later.
- **Order sections by what the consumers actually need**, measured rather than
  assumed. Grepping the practicals' shell blocks is what set Part 1's emphasis:
  short parameters and backslash line-continuations dominate, wildcards barely
  appear, and `$(...)`, `>>`, `~/`, `../` and glob ranges never do. Re-measure
  when a consuming module's practicals change.
  - **A null result there is evidence about the query, not only the data.** The
    practicals never spell out `ls` or `pwd` in a code block — which does not
    mean readers do not need them. It means navigation is *assumed*, and that
    assumption is precisely the gap Part 1 exists to fill.
  - **Measurement finds what the data shows; it does not find what everyone
    assumes.** A second grep pass (2026-08-18) found `git branch` and pull
    requests genuinely absent from Part 3 despite the practicals' one-repo-per-
    team design guaranteeing a rejected push. But `echo` (used constantly,
    never named), a space in a filename (never mentioned at all, in either
    Part 1 or the practicals' own shell blocks), and Tab-completion needing
    *repetition* rather than one mention — none of these were found by
    grepping anything, because nothing greppable was missing. They surfaced
    only from Martin reading the material directly and noticing what a genuine
    beginner would trip on. **Both passes are needed; neither substitutes for
    the other.**

## Known constraints

- **bioconda has no Windows builds**, and much scientific software has no
  Windows build at all. The Windows answer is **WSL2**, and the material says so
  without hedging. `pixi.toml` deliberately omits `win-64` so the environment
  does not contradict the advice.
- **`_quarto.yml` renders only an explicit list of `.qmd`.** A Quarto *website*
  project otherwise turns every loose `.md` into a public page — this bit the hub
  repo, where `NEXT.md` became `_site/NEXT.html`. Do not widen it to `.md`.
- **`404.html` must exist at the top level**, or Cloudflare Pages treats the
  deployment as a single-page app and serves `/` with status 200 for every
  unmatched path.
- **Custom domains cannot be scripted** — wrangler has no `pages domain`
  subcommand. Dashboard only. Never hand-create the DNS record.
- `styles/website.scss` is duplicated by hand across the teaching repos. A
  shared Quarto extension stays deferred until several modules exist.

## Things future sessions should always know

- Read `README.md`, then `NEXT.md`, then the newest file in `docs/sessions/`.
- The related repos: `~/git/teaching-hub` (public front door),
  `~/git/teaching-template` (the skeleton this came from),
  `~/git/course-bioinformatics` (private, the first consumer). Each has its own
  `CLAUDE.md`, and the course repo's is the fullest.
- `gh` is authenticated as `hoelzer`; `wrangler` via OAuth. Cloudflare account
  ID `6398bee0e2141168cd3fccf8cfbfe6ee`.
