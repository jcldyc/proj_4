%{

#include <stdio.h>
#include "tree.h"
#include "y.tab.h"

void yyerror (char * s);
int line = 1,pos = 1;
%}
L	[A-Za-z]
D	[0-9]
%%
^"."C.*		;
[ \t]+		pos += yyleng;
if		{pos += 2; return If;}
then		{pos += 4; return Then;}
end		{pos += 3; return End;}
var		{pos += 3; return Var;}
int		{pos += 3; return Int;}
real		{pos += 4; return Real;}
boolean		{pos += 7; return Boolean;}
record		{pos += 6; return Record;}
bind		{pos += 4; return Bind;}
to		{pos += 2; return To;}
assert		{pos += 6; return Assert;}
begin		{pos += 5; return Begin;}
loop		{pos += 4; return Loop;}
exit		{pos += 4; return Exit;}
when		{pos += 4; return When;}
elsif		{pos += 5; return Elsif;}
else		{pos += 4; return Else;}
put		{pos += 3; return Put;}
or		{pos += 2; return Or;}
and		{pos += 3; return And;}
not		{pos += 3; return Not;}
not=		{pos += 4; return NotEq;}
div		{pos += 3; return Div;}
mod		{pos += 3; return Mod;}
[A-Za-z]({L}|{D}|[_])*	{pos += yyleng; yylval.i = lookup (yytext); return Ident;}
{D}+		{pos += yyleng; yylval.i = atoi (yytext); return IntConst;}
({D}+\.{D}+)|({D}+\.*[0-9]*[Ee][\+\-][0-9]+)		{pos += yyleng; yylval.z = atof (yytext); return RealConst;}
"="		{pos += 1; return Eq;}
":="		{pos += 2; return Assign;}
".NE."		{return Ne;}
"<"		{pos += 1; return Lt;}
"<="		{pos += 2; return Le;}
">"		{pos += 1; return Gt;}
">="		{pos += 2; return Ge;}
"+"		{pos += 1; return Plus;}
"-"		{pos += 1; return Minus;}
"*"		{pos += 1; return Star;}
"/"		{pos += 1; return Slash;}
"("		{pos += 1; return LParen;}
")"		{pos += 1; return RParen;}
";"		{pos += 1; return SemiColon;}
":"		{pos += 1; return Colon;}
"."		{pos += 1; return Period;}
","		{pos += 1; return Comma;}
"\n"		{line++; pos = 1;}
.		{yyerror ("Bad Character");}
%%
int yywrap (void) {return 1;}

void yyerror (char s[]) {

	printf("Error: %s at token %s in line %d\n",s, yytext, line);
}

typedef char name[15];
static char Names[200][15] = {"<no name>"};
int top = 0;

int lookup (char s[])
{
        int     i;

        for (i = 1; i <= top; i ++)
                if (strcmp (s, Names[i]) == 0) return i;
        strcpy (Names[++top], s);
        return top;
}

void printNames (void)
{
        int i = 0;

        for (; i <= top; i++)
                printf ("%d\t%s\n", i, Names[i]);
}

char *id_name (int i)
{
        return Names[i];
} 





