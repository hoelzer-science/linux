# Linux Crash Course

Open teaching material: the command line, package management and Git — the
working baseline for computational practicals.

Published at **<https://linux.hoelzer.science>**.

## Why this is its own repository

It belongs to no single course. Several modules need the same baseline, and
copying it per module guarantees the copies drift. So it lives once, publicly,
and every module **links** it rather than reproducing it.

Public also means readers can work through it before enrolling anywhere, which
is when it is most useful.

## Quick start

```bash
pixi install          # build/test environment (readers do not need this)
pixi run preview      # live-reloading site at localhost:4200
pixi run test         # execute every shell example on the site
pixi run site         # render into _site/
pixi run check        # verify links and published output
```

Before pushing, run what CI runs, in the same order:

```bash
pixi run lint && pixi run test && pixi run site && pixi run check
```

## Every command on the site is executed

`tests/test_examples.py` extracts the `bash` blocks from `parts/*.qmd` and runs
them in order, in one shell, in a scratch directory. A block can rely on files
an earlier block made, exactly as a reader can.

This is the whole reason the repository has an environment. Prose about what a
tool does cannot be checked mechanically; a command can.

**Run it on macOS as well as Linux.** CI runs Ubuntu, and GNU tools accept
things BSD tools do not — `head --help` and `--lines` both fail on macOS. A
Linux-only test run would have shipped both to Mac readers without complaint.

What is *not* verified: the `text` blocks showing output. Those are
illustrative, because an exact comparison would fail on correct-but-machine-
specific things (home paths, `ls` widths, locale sort order), and loosening it
until it passed would leave an assertion that asserts nothing.

## Layout

```
_quarto.yml               website config; also controls what is NOT rendered
pixi.toml / pixi.lock     environment; lockfile MUST be committed

index.qmd                 landing page
parts/01-command-line.qmd Part 1 — terminal, paths, commands, pipes, wildcards
parts/02-packages.qmd     Part 2 — pixi, and conda/mamba as context
parts/03-git.qmd          Part 3 — Git and GitHub
parts/04-file-formats.qmd Part 4 — Markdown, JSON, CSV/TSV, encodings
figures/                  hand-written SVG; own figures only

tests/test_examples.py    executes every shell example
scripts/check-links.sh    every local link and image must resolve
scripts/check-output.sh   nothing published that should not be
styles/                   website.scss, slides.scss
instructor/               working area; incoming/ is GITIGNORED — see its README
```

## How it differs from the course template

This repository was created from `teaching-template` with "Use this template",
so it has an unrelated history starting from a single commit. Sync with the
template is by **cherry-pick only** — never merge or rebase, because there is no
common ancestor.

Four things were deliberately removed, and the reasons are worth keeping:

| removed | why |
|---|---|
| `cloudflare/_worker.js` | HTTP basic auth. This site is public; there is nothing to protect. |
| the release allowlist | A course holds sessions back until taught. A reference site has nothing to hold back, so an allowlist would only go stale. |
| the LMS build | Self-contained HTML for uploading into a learning platform. This site is linked, not uploaded. |
| `_course.yml` | Institution, module code, term. None apply, and none may appear here — see below. |

## Publishing constraint

**Nothing in this repository may name an institution, a module code, a term, or
a scheduled course.** That applies to committed files, commit messages and the
repository description alike, and it is why `NEXT.md`, `docs/sessions/` and
`instructor/incoming/` are gitignored.

It is also why the material is written module-agnostically: the examples are
ordinary files and folders rather than data from any one subject.

## Licence

Content is [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/);
code is MIT. See `LICENSE` and `LICENSE-CONTENT`.

Reused figures carry their source and licence in the caption. On a public site
that is a requirement rather than a courtesy — a figure whose licence cannot be
established does not go in.
