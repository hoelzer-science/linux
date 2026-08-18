#!/usr/bin/env bash
#
# Verify that every local link AND image in a rendered build resolves to a real
# file.
#
#   ./scripts/check-links.sh _site
#
# The image half is the part that earns its keep. It was added to the course
# repository on 2026-08-06 after a failure that was silent in the worst way: a
# figure moved to a shared directory, one document kept emitting the old
# src="figures/...", and this script reported "all local links resolve" --
# because it only ever looked at href. A broken figure passes every other gate
# too, so nothing anywhere caught it. Hence: src is checked exactly like href.
#
# That mattered here immediately. This repository inherited the version of this
# script WITHOUT the image check, and the first figure added to the site would
# have been unverified.
#
# External (http/https) links are not checked -- that needs network access and
# belongs in a scheduled job, not the build.
#
# <script> blocks are stripped before scanning. Minified JavaScript contains
# things that look exactly like local hrefs -- mermaid's bundle builds strings
# such as href="'+t+'" -- which is enough to fail the whole check on a link
# that does not exist. Only the document's own markup should be scanned.
# Stripping <script> also removes <script src="..."> tags, which is correct:
# those are Quarto's own bundled libraries, not authored references.
#
# Note the attribute regex excludes any value containing a colon. That is what
# skips http://, https://, mailto: and data: URIs. It also means a value can
# never contain a colon, which is why "attr:value" below is an unambiguous
# encoding.
#
set -euo pipefail

dir="${1:-_site}"

if [[ ! -d "$dir" ]]; then
  echo "error: '$dir' does not exist -- render it first" >&2
  exit 1
fi

broken=0
checked=0

while IFS= read -r page; do
  page_dir=$(dirname "$page")

  # Local href and src only: skip absolute URLs, anchors, mailto:, data: etc.
  # Each entry arrives as "attr:value"; the value is colon-free by construction
  # (see the regex below), so splitting on the first colon is unambiguous.
  while IFS= read -r entry; do
    [[ -z "$entry" ]] && continue
    attr="${entry%%:*}"
    link="${entry#*:}"
    [[ -z "$link" ]] && continue
    checked=$((checked + 1))
    target="${link%%#*}"            # strip any fragment
    [[ -z "$target" ]] && continue  # pure in-page anchor

    # A .qmd link must never survive into a build. It means either a link to a
    # page that was not rendered, or a hand-written link that was never
    # rewritten -- and in both cases a reader is served raw markdown.
    if [[ "$target" == *.qmd ]]; then
      echo "QMD LINK: $page -> $link"
      echo "          (a page missing from project.render, or a hand-written link)"
      broken=$((broken + 1))
      continue
    fi

    if [[ ! -e "$page_dir/$target" ]]; then
      if [[ "$attr" == "src" ]]; then
        echo "BROKEN IMAGE: $page -> $link"
        echo "              (renamed, deleted, or moved between directories?)"
      else
        echo "BROKEN: $page -> $link"
      fi
      broken=$((broken + 1))
    fi
  done < <(perl -0777 -pe 's{<script\b.*?</script>}{}gis' "$page" 2>/dev/null \
             | grep -ohE '(href|src)="[^":]*"' 2>/dev/null \
             | sed 's/^href="/href:/; s/^src="/src:/; s/"$//' \
             | grep -vE '^(href|src):#' || true)

done < <(find "$dir" -name '*.html')

echo "checked $checked local link(s) and image(s) in $dir"

if [[ "$broken" -gt 0 ]]; then
  echo "FAILED: $broken broken reference(s)" >&2
  exit 1
fi

echo "OK: all local links and images resolve"
