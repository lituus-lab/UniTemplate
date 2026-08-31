# SPDX-License-Identifier: Apache-2.0
# Copyright 2026 lituus-lab
## The table of contents, and the two settings that decide the theme.
##
## Four chapters, because the standard asks a chapter for ten slots and a
## single page cannot show them separately. What a reader takes from this book
## is not fibonacci; it is the shape.
import std/[base64, tables]
import nimibook

const Favicon = staticRead("../../lituus-theme/brand/favicon/favicon.svg")
  ## The lituus mark, thickened and on a filled disc so it carries its own
  ## ground: the plain mark is a 2.1%-of-width stroke, a third of a pixel at
  ## 16 px, and washes out.

var book = initBookWithToc:
  entry("UniTemplate", "index.nim")
  entry("Fibonacci", "fibonacci.nim")
  entry("Contracts", "contracts.nim")
  entry("Surfaces", "surfaces.nim")

book.title = "UniTemplate"
book.description = "The scaffold every lituus-lab Uni* engine starts from."

# The two BookConfig fields that select a theme. nimibook's inline script picks
# between them with `prefers-color-scheme`, and localStorage overrides.
book.default_theme = "lituus-light"
book.preferred_dark_theme = "lituus-dark"
book.theme_option = {"lituus-light": "Light", "lituus-dark": "Dark"}.toTable

# Without this nimibook ships nimib's default, a whale emoji.
book.favicon_escaped =
  "<link rel=\"icon\" type=\"image/svg+xml\" href=\"data:image/svg+xml;base64," &
  encode(Favicon) & "\">"

nimibookCli(book)
