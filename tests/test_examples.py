"""Execute every shell example on the site.

This is the reason the repository has an environment at all. The material tells
people to type commands; a command either runs or it does not, so there is no
excuse for shipping one that does not. Prose about what a tool does cannot be
checked mechanically -- a command can.

## What is and is not verified

**Verified:** every ```bash block on a page runs, in order, in one shell, with a
zero exit status. Blocks share state, so a block may rely on a directory or file
an earlier block created -- which is exactly how a reader works through the page.

**NOT verified:** the ```text blocks showing output. Those are illustrative.
Comparing them exactly would fail on things that are correct but machine-
specific (home directory paths, `ls` column widths, locale-dependent sort
order), and loosening the comparison until it passed would leave an assertion
that no longer asserted anything. So the claim the site makes is precisely the
claim this file checks: the commands run.

## Excluding a block

Mark it `{.bash .no-run}`. Used for commands that are interactive (`less`), or
that depend on something a minimal CI image need not have (`man`). Keep the
number small -- an excluded block is an untested block.
"""

from __future__ import annotations

import os
import re
import subprocess
from pathlib import Path

import pytest

REPO = Path(__file__).resolve().parent.parent
PARTS = sorted((REPO / "parts").glob("*.qmd"))

# Opening fence: ```bash, ```{.bash}, ```{.bash .no-run}, ``` sh, etc.
FENCE_OPEN = re.compile(r"^(?P<ticks>`{3,})\s*\{?[.\s]*(?P<lang>bash|sh|shell)\b(?P<attrs>[^}]*)\}?\s*$")


def shell_blocks(qmd: Path) -> list[tuple[int, str]]:
    """Return (line_number, code) for each runnable shell block in a page."""
    blocks: list[tuple[int, str]] = []
    lines = qmd.read_text().splitlines()
    i = 0
    while i < len(lines):
        m = FENCE_OPEN.match(lines[i])
        if not m:
            i += 1
            continue
        skip = "no-run" in m.group("attrs")
        ticks = m.group("ticks")
        start = i + 1
        i = start
        body: list[str] = []
        while i < len(lines) and not lines[i].startswith(ticks):
            body.append(lines[i])
            i += 1
        i += 1  # step past the closing fence
        if not skip and body:
            blocks.append((start + 1, "\n".join(body)))
    return blocks


@pytest.mark.parametrize("qmd", PARTS, ids=lambda p: p.stem)
def test_every_shell_example_runs(qmd: Path, tmp_path: Path) -> None:
    """Run one page's shell blocks in order, in a scratch directory."""
    blocks = shell_blocks(qmd)
    assert blocks, f"{qmd.name} contains no runnable shell blocks"

    # One script, so state persists across blocks exactly as it does for a
    # reader working down the page. A marker before each block turns a failure
    # into a line number in the source rather than a mystery.
    parts = ["set -euo pipefail"]
    for lineno, code in blocks:
        parts.append(f'echo "@@BLOCK {lineno}" >&2')
        parts.append(code)
    script = "\n".join(parts)

    # HOME points at the scratch directory so that examples using `~` stay
    # inside it. Without this, a `cd ~` in the material would send the rest of
    # the page's commands into the real home directory and litter it.
    env = {
        "HOME": str(tmp_path),
        "PATH": os.environ["PATH"],
        # Sort order and number formatting are locale-dependent. Pinning the
        # locale keeps a failure here meaning "the command broke" rather than
        # "this machine speaks German".
        "LC_ALL": "C",
    }

    result = subprocess.run(
        ["bash", "-c", script],
        cwd=tmp_path,
        env=env,
        capture_output=True,
        text=True,
        timeout=120,
        check=False,  # the failure is reported below, with the source line
    )

    if result.returncode != 0:
        seen = re.findall(r"@@BLOCK (\d+)", result.stderr)
        where = f"{qmd.name}:{seen[-1]}" if seen else qmd.name
        stderr = re.sub(r"@@BLOCK \d+\n?", "", result.stderr)
        pytest.fail(
            f"shell example failed at {where} "
            f"(exit {result.returncode})\n\n{stderr.strip()}"
        )


def test_no_run_blocks_stay_rare() -> None:
    """An excluded block is an untested block, so notice if they multiply."""
    excluded = sum(
        len(re.findall(r"no-run", p.read_text())) for p in PARTS
    )
    assert excluded <= 5, (
        f"{excluded} blocks are excluded from testing. Each one is a command "
        "shipped to readers without ever being run -- justify it or fix it."
    )
