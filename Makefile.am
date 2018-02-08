AUTOMAKE_OPTIONS = foreign

BUILT_SOURCES = src/parser.h
AM_YFLAGS = -d
AM_CFLAGS = -I.

bin_PROGRAMS = hpgl2gcode
hpgl2gcode_SOURCES = src/parser.y \
                     src/lexer.l

noinst_HEADERS = src/parser.h
