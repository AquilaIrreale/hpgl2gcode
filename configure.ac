#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
AC_INIT([hpgl2gcode], [1.2.1], [aquilairreale@ymail.com])

AM_INIT_AUTOMAKE([subdir-objects])

AC_CONFIG_SRCDIR([src/parser.y])
AC_CONFIG_HEADERS([config.h])
AC_CONFIG_FILES([Makefile])

# Checks for programs.
AC_PROG_CC
AC_PROG_LEX
AC_PROG_YACC

# Checks for libraries.
AC_SEARCH_LIBS([acos], [m])

# Checks for header files.
AC_CHECK_HEADERS([stdlib.h string.h])

# Checks for typedefs, structures, and compiler characteristics.

# Checks for library functions.
AC_FUNC_MALLOC
AC_CHECK_FUNCS([strrchr])

AC_OUTPUT
