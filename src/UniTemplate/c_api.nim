# SPDX-License-Identifier: Apache-2.0
# Copyright 2026 lituus-lab
## C ABI for UniTemplate. Built --app:staticlib/--app:lib --noMain --mm:arc -d:release.
## Keep in sync with include/UniTemplate.h; tests/c links the header against this lib.
import ../UniTemplate

const UniTemplateVersionC: cstring = "0.1.0"

# Unmangled C symbols, C calling convention, exported from the shared lib.
# A shared library runs NimMain from DllMain (Windows) or an ELF constructor;
# a static one has neither, so nothing initializes the Nim runtime. Anything
# that reads the environment then faults — proven on Windows, where the Python
# extension is the one consumer that links the static build. The static-library
# tasks pass -d:staticNoAutoInit; shared builds must not, or NimMain runs twice.
when defined(staticNoAutoInit):
  # A C static, not a Nim global: module initialization would reset a Nim one
  # back to false and NimMain would run again on the next call. NimMain is
  # declared here too — the generated prototype comes after this section.
  {.emit: """/*VARSECTION*/
void NimMain(void);
static int ut_runtime_ready = 0;
""".}
  template ensureRuntime() =
    {.emit: """
  if (!ut_runtime_ready) { ut_runtime_ready = 1; NimMain(); }
""".}
else:
  template ensureRuntime() = discard

{.push exportc, cdecl, dynlib.}

proc unitemplate_fibonacci(n: cint): clonglong =
  ensureRuntime()
  ## fibonacci(n), n clamped to [0, FibMaxN]. n < 0 -> 0, n > FibMaxN -> fibonacci(FibMaxN). Never raises.
  let m = int(n)
  if m < 0:
    return clonglong(0)
  if m > FibMaxN:
    return fibonacci(FibMaxN).clonglong
  fibonacci(m).clonglong

proc unitemplate_version(): cstring {.exportc, cdecl, dynlib.} =
  ensureRuntime()
  ## Static version string; do not free.
  UniTemplateVersionC

{.pop.}
