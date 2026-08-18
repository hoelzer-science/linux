#!/usr/bin/env bash
#
# Deliberate publish step. Deployment is NOT automated on push -- week 5 goes
# out when week 5 is ready, not when main changes.
#
#   ./scripts/publish.sh site    rebuild and rsync the website to the host
#   ./scripts/publish.sh lms     build self-contained HTML files for Moodle
#
set -euo pipefail

# --- configure -------------------------------------------------------------
REMOTE_HOST="${COURSE_REMOTE_HOST:-TODO-user@host}"
REMOTE_PATH="${COURSE_REMOTE_PATH:-/var/www/course}"
# ---------------------------------------------------------------------------

cd "$(dirname "$0")/.."

target="${1:-site}"

case "$target" in
  site)
    echo "==> Rendering website"
    quarto render

    if [[ "$REMOTE_HOST" == TODO-* ]]; then
      echo
      echo "Remote host not configured. Set COURSE_REMOTE_HOST and"
      echo "COURSE_REMOTE_PATH, or edit the defaults at the top of this script."
      echo "Rendered site is in _site/"
      exit 1
    fi

    echo "==> Syncing to ${REMOTE_HOST}:${REMOTE_PATH}"
    # --delete removes files on the host that no longer exist locally, so the
    # published site always matches the repository exactly.
    rsync -avz --delete _site/ "${REMOTE_HOST}:${REMOTE_PATH}/"
    ;;

  lms)
    echo "==> Rendering self-contained pages for Moodle"
    quarto render --profile lms

    # Website projects rewrite internal .qmd links to .html; `default` projects
    # do not, and the LMS profile has to use `default` to get embed-resources.
    # So the links come out as href="...index.qmd" and 404. Fix them here.
    # perl rather than sed: -i behaves differently on macOS and Linux.
    # The [^":]* excludes absolute URLs, so only local links are touched.
    echo "==> Rewriting internal .qmd links to .html"
    find _lms -name '*.html' -print0 \
      | xargs -0 perl -pi -e 's/(href="[^":]*)\.qmd(")/$1.html$2/g'

    # `|| true` because grep exits 1 when it finds nothing, which is the
    # success case here -- and `set -o pipefail` would otherwise abort.
    remaining=$({ grep -rlE 'href="[^"]*\.qmd"' _lms 2>/dev/null || true; } | wc -l | tr -d ' ')
    if [[ "$remaining" != "0" ]]; then
      echo "WARNING: $remaining file(s) still contain .qmd links" >&2
    else
      echo "OK: no .qmd links remain"
    fi

    echo
    echo "Standalone HTML files are in _lms/."
    echo "Notes, practicals and index pages embed their own images, CSS and JS,"
    echo "so each can be uploaded to Moodle as an ordinary file resource."
    echo
    echo "EXCEPTION: slides.html is NOT self-contained -- the chalkboard plugin"
    echo "is incompatible with embedding. Link Moodle to the hosted slides"
    echo "instead, or export them to PDF via ?print-pdf in the browser."
    ;;

  *)
    echo "usage: $0 [site|lms]" >&2
    exit 2
    ;;
esac
