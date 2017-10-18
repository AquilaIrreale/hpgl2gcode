LDLIBS = -lm

hpgl2gcode: lex.yy.o y.tab.o
	gcc -o hpgl2gcode lex.yy.o y.tab.o $(LDLIBS)

y.tab.h: y.tab.c
y.tab.c: hpgl2gcode.y
	yacc -d hpgl2gcode.y

lex.yy.c: hpgl2gcode.l y.tab.h
	lex hpgl2gcode.l

