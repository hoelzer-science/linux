# Incoming — Martin's own material, before it is placed

Drop zone. Put slide decks, figures, notes and anything else you want worked
into the crash course **here**, and a session will read it, place it and tell
you where it went.

## Everything in here is gitignored, on purpose

`.gitignore` keeps this directory out of the repository, except for this file.
**This repository is public**, so committing a dropped `.pptx` would publish it
— the deck, every figure inside it, and whatever licence those figures carry.
A drop is a working area, not a record.

That is the one place this repo deliberately differs from the course
repository, where `incoming/` *is* committed and stays as the record of what
was handed over. There the repo is private; here it is not.

**What survives a drop is the material written from it**, with provenance
established at the point of use. If a figure is reused rather than redrawn, its
source and licence go in the caption — and for a public site that is a
requirement, not the best-effort convention the private course repo runs on.

## How to drop something

Make a directory named for the part it belongs to, and put the files in it:

```
instructor/incoming/
  part1-command-line/
    existing-deck.pptx
    notes.md            # optional, free text: what this is, where it goes
  part2-packages/
    ...
  unsorted/             # fine, when you do not know yet
```

`notes.md` is optional and can be one line. Anything you can say about a file
is worth more than nothing:

- what it shows, and why you want it in
- which section or which point it belongs to
- where it came from, and under what licence, if you know

## A `.pptx` needs no PowerPoint

It is a zip. `unzip -j deck.pptx 'ppt/media/*'` gets every image;
`ppt/slides/slideN.xml` holds the text as `<a:t>` runs; `ppt/notesSlides/` holds
the **speaker notes**; and `ppt/slides/_rels/slideN.xml.rels` maps each image
back to the slide it sits on. That last part is what makes extraction worth
doing properly: a figure arrives *with the argument it was serving* rather than
as an anonymous `image7.png`.

## What happens next

A session picks the files up, writes from them, and appends a placement log to
the drop's own `notes.md` saying what was used and where it went. The files
stay here locally; nothing is deleted.
