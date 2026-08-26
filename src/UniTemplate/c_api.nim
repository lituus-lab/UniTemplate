# SPDX-License-Identifier: Apache-2.0
# Copyright 2026 lituus-lab
## C ABI for UniTemplate. Built --app:staticlib/--app:lib --noMain --mm:arc
## -d:release. Keep in sync with include/UniTemplate.h; tests/c links the header
## against this lib, so a header that drifts fails to compile rather than at a
## caller's site.
##
## No Nim exception crosses this boundary: `{.raises: [].}` on every entry
## point is what proves it rather than a convention that has to be remembered.
import ../UniTemplate

const UniTemplateVersionC: cstring = "0.1.0"

# Unmangled C symbols, C calling convention, exported from the shared lib.
# A shared library runs NimMain from DllMain (Windows) or an ELF constructor;
# a static one has neither, so nothing initializes the Nim runtime. Anything
# that reads the environment then faults — proven on Windows, where the Python
# extension is the one consumer that links the static build. The static-library
# tasks pass -d:staticNoAutoInit; shared builds must not, or NimMain runs twice.
when defined(staticNoAutoInit):
  # A once primitive, not a plain flag: two threads reaching an entry point
  # together would both see the flag unset, both call NimMain, and the second
  # would enter Nim code the first had not finished initializing. The platform
  # primitives block the losers until the winner returns, which a flag cannot.
  #
  # C statics, not Nim globals: module initialization would reset a Nim one and
  # NimMain would run again. NimMain is declared here too — the generated
  # prototype comes after this section.
  {.emit: """/*VARSECTION*/
void NimMain(void);
#ifdef _WIN32
#  include <windows.h>
static INIT_ONCE unitemplate_runtime_once = INIT_ONCE_STATIC_INIT;
static BOOL CALLBACK unitemplate_runtime_init(PINIT_ONCE o, PVOID p, PVOID *c) {
  (void)o; (void)p; (void)c; NimMain(); return TRUE;
}
static void unitemplate_runtime_ensure(void) {
  InitOnceExecuteOnce(&unitemplate_runtime_once, unitemplate_runtime_init, NULL, NULL);
}
#else
#  include <pthread.h>
static pthread_once_t unitemplate_runtime_once = PTHREAD_ONCE_INIT;
static void unitemplate_runtime_init(void) { NimMain(); }
static void unitemplate_runtime_ensure(void) {
  pthread_once(&unitemplate_runtime_once, unitemplate_runtime_init);
}
#endif
""".}
  template ensureRuntime() =
    {.emit: "  unitemplate_runtime_ensure();".}
else:
  template ensureRuntime() = discard

{.push exportc, cdecl, dynlib, raises: [].}

proc unitemplate_fibonacci(n: cint): clonglong =
  ## fibonacci(n), n clamped to [0, FibMaxN]: n < 0 gives 0, n > FibMaxN gives
  ## fibonacci(FibMaxN). Clamps rather than reporting, because the question has
  ## an answer at every n a caller can express.
  ensureRuntime()
  let m = int(n)
  if m < 0:
    return clonglong(0)
  if m > FibMaxN:
    return fibonacci(FibMaxN).clonglong
  fibonacci(m).clonglong

proc unitemplate_version(): cstring =
  ## Static version string; do not free.
  ensureRuntime()
  UniTemplateVersionC

{.pop.}
