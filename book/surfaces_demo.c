/* SPDX-License-Identifier: Apache-2.0 */
/* Copyright 2026 lituus-lab */
/* Run by book/surfaces.nim during the book build; its output is the page's. */
#include <stdio.h>
#include "UniTemplate.h"

int main(void) {
  printf("unitemplate_version()            = %s\n", unitemplate_version());
  printf("unitemplate_fibonacci(10)        = %lld\n", unitemplate_fibonacci(10));
  printf("unitemplate_fibonacci(-1)        = %lld   (clamped, not an error)\n",
         unitemplate_fibonacci(-1));
  printf("unitemplate_fibonacci(200)       = %lld   (clamped to n = %d)\n",
         unitemplate_fibonacci(200), UNITEMPLATE_FIB_MAX_N);
  return 0;
}
