<!-- SPDX-License-Identifier: Apache-2.0 -->
<!-- Copyright 2026 lituus-lab -->
# The Book

`index.nim` is the nimib book every `Uni*` library carries. Its code blocks are
compiled and run when the book is built, so prose that outlives its API breaks
the build rather than quietly misleading a reader.

Build it with `build/unigate book`, or `build/unigate docs` for the book plus
the generated API reference. A library whose book grows past one page splits it
into a nimibook table of contents; a one-page book stays here.
