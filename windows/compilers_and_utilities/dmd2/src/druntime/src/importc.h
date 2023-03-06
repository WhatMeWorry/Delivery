/* This .h file is to be #include'd by ImportC files first in order provide
 * adjustments to the source to account for various C compiler extensions
 * not supported by ImportC.
 *
 * Copyright: Copyright D Language Foundation 2022
 * License:   $(HTTP www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * Authors:   Walter Bright
 * Source: $(DRUNTIMESRC importc.h)
 */

/**********************
 * For special casing ImportC code.
 */
#define __IMPORTC__ 1

/********************
 * Some compilers define `__restrict` instead of `restrict` as C++ compilers don't
 * recognize `restrict` as a keyword.
 * ImportC assigns no semantics to `restrict`, so just ignore the keyword.
 */
#define __restrict
#define __restrict__

/**********************
 * Some old pre-Ansi headers use these
 */
#define __signed__ signed
#define __asm__ asm
#define __asm asm
#define __inline__ inline
#define __inline inline

/********************
 * Clang nullability extension used by macOS headers.
 */
#define _Nonnull
#define _Nullable
#define _Null_unspecified

/********************
 * This is a Microsoft C function calling convention not supported by ImportC,
 * so ignore it.
 */
#define __fastcall

/* Microsoft builtin types */
#define __int8 char
#define __int16 short
#define __int32 int
#define __int64 long long

/*********************
 * Obsolete detritus
 */
#define __cdecl
#define __ss
#define __cs
#define __far
#define __near
#define __handle
#define __pascal

/****************************
 * __extension__ is a GNU C extension. It suppresses warnings
 * when placed before an expression.
 */
#define __extension__  /* ignore it, as ImportC doesn't do warnings */

/****************************
 * Define it to do what other C compilers do.
 */
#define __builtin_offsetof(t,i) ((typeof(sizeof(0)))((char *)&((t *)0)->i - (char *)0))

/***************************
 * C11 6.10.8.3 Conditional feature macros
 */
#define __STDC_NO_VLA__ 1

/*************************
 * Ubuntu's assert.h uses this
 */
#if linux  // Microsoft won't allow the following macro
#define __PRETTY_FUNCTION__ __func__
#endif

#if __APPLE__
#undef __SIZEOF_INT128__
#endif
