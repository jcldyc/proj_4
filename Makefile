CC = gcc
CFLAGS = -g
LEX = flex
YACC = bison -y

all: lex.yy.c y.tab.h turing

lex.yy.c: tg-scan.l
	$(LEX) tg-scan.l

turing: main.o tree.o y.tab.o lex.yy.o check.o generate.o code.o instr.o
	$(CC) -o turing main.o y.tab.o lex.yy.o tree.o check.o generate.o code.o instr.o
main.o : main.c tree.h y.tab.h
lex.yy.o : lex.yy.c
tree.o: y.tab.c tree.h
generate.o: generate.c tree.h y.tab.h instr.h code.h
instr.o: instr.c instr.h
code.o: code.c tree.h y.tab.h instr.h code.h
y.tab.c: zb-tree.y
	$(YACC) zb-tree.y
y.tab.h: zb-tree.y
	$(YACC) -d zb-tree.y
check.o: check.c tree.h ST.h

clean:
	-@ rm lex.yy.c *.o turing y.tab.c y.tab.h
