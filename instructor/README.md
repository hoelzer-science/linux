# Instructor material

Working area. Not rendered into the site — `_quarto.yml` excludes
`instructor/**` from `project.render`, so nothing here reaches `_site/`.

## This repository is PUBLIC, and that inverts the usual rule

In the course repository, `instructor/` is committed: that repo is private, so
the exclusion is only about keeping teaching material off the student-facing
site. **Here it is the other way round.** A build-time exclusion is not access
control, and this repository is world-readable — so anything committed under
`instructor/` is published, whether or not it appears on the site.

Therefore:

- **`instructor/incoming/` is gitignored** (see `.gitignore`, which says why).
  Dropped slide decks, figures and scratch material stay local. What survives a
  drop is the *material written from it*, with provenance established at the
  point of use.
- Nothing under `instructor/` may name an institution, a module code, a term or
  a scheduled course — the same publishing constraint the hub carries.
- If something genuinely needs to be committed and kept out of sight, it does
  not belong in this repository at all.

## Contents

- `incoming/` — the drop zone. See its own README.

## Why there is no `semester-notes/` or `grading/`

Both came from the course template and were removed. This is not a course: it
has no cohort, no term, no assessment and no room. It is a reference site that
several modules link to. Retrospectives about *teaching* belong in the module
repository that did the teaching.
