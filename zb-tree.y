
%{
#include "tree.h"
#include <stdlib.h>

extern tree root;
%}

%token <z> RealConst 69
%token <i>	Ident 1 IntConst 2 
%token	If 11 Then 12 End 13 Var 14 Int 15 Else 16
%token	Assign 21 LParen 22 RParen 23 
%token	Plus 24 Minus 25 Star 26 Slash 27
%token	Eq  28 Ne 29 Lt 30 Le 31 Gt 32 Ge 33 
%token	Eoln 34 UPlus 35 UMinus 36 
%token	NoType 41 Integer 42 Boolean 50  Comma 45
%token  Record 51 Bind 52 To 53 Assert 54
%token  Begin 55 Loop 56 Exit 57 When 58 Elsif 59
%token  Put 61 Or 62 And 63 Not 64 NotEq 65
%token  Div 66 Mod 67 Real 68 SemiColon 80
%token  Colon 81 Period 82 Prog 3

%start	program

%union { tree p; int i; float z; }

%type <p>	pStateDeclSeq idlist type field_list state_decls declaration statement ref end_if expr and_expr not_expr rel_expr sum prod factor basic

%%
program
	: pStateDeclSeq
		{ root = buildTree (Prog, $1, NULL, NULL); }
	;
pStateDeclSeq 
	: /* empty */
		{ $$ = NULL; }
	| statement SemiColon pStateDeclSeq
		{ $1->next = $3; $$ = $1; }
	| Var idlist Colon type SemiColon pStateDeclSeq
		{ $$ = buildTree (Var, $2, $4, NULL); $$->next = $6; }
	;
idlist
	: Ident
		{ $$ = buildIntTree (Ident, $1); }
	| Ident Comma idlist
		{ $$ = buildIntTree (Ident, $1); $$->next = $3; }
	;
type
	: Int
		{ $$ = buildTree (Int, NULL, NULL,NULL); }
	| Boolean
		{ $$ = buildTree (Boolean, NULL, NULL, NULL); }
	| Real
		{ $$ = buildTree (Real, NULL, NULL, NULL); }
	| Record field_list End Record
		{ $$ = buildTree(Record, $2, NULL, NULL); }
	;
field_list
	: idlist Colon type
		{ $$ = buildTree (Colon, $1, $3, NULL); }
	| idlist Colon type SemiColon field_list
		{ $$ = buildTree (Colon, $1, $3, NULL); $$->next = $5; }
	;
state_decls
	: /*empty */
		{ $$ = NULL; }
	| statement SemiColon pStateDeclSeq
		{ $1->next = $3; $$ = $1; }
	| declaration SemiColon pStateDeclSeq
		{ $1 ->next = $3; $$ = $1; }
	;
declaration
	: Var idlist Colon type
		{ $$ = buildTree (Var, $2, $4, NULL); }
	| Bind idlist To ref
		{ $$ = buildTree (Bind,$2,$4,NULL); }
	| Bind Var idlist To ref
		{ $$ = buildTree (Bind,buildTree(Var,$3,NULL,NULL),$5,NULL); } 
	;
statement
	: ref Assign expr
		{$$ = buildTree(Assign,$1,$3,NULL); }
	| Assert expr
		{$$ = buildTree(Assert,$2,NULL,NULL); }
	| Begin state_decls End
		{$$ = buildTree(Begin,$2,NULL,NULL);}
	| Loop state_decls End Loop
		{$$ = buildTree(Loop, $2,NULL,NULL); }
	| Exit
		{$$ = buildTree(Exit, NULL, NULL, NULL); }
	| Exit When expr
		{$$ = buildTree(Exit,buildTree(When,$3,NULL,NULL),NULL,NULL); }
	|If expr Then state_decls end_if
		{$$ = buildTree(If,$2,$4,$5); }
	;
	
ref
	: Ident 
		{ $$ = buildIntTree(Ident, $1); }
	| Ident Period Ident
		{ $$ = buildTree (Period, buildIntTree(Ident, $1), buildIntTree(Ident,$3), NULL); }
	;
end_if
	: End If
		{$$ = buildTree (End, NULL, NULL, NULL); }
	| Else state_decls end_if
		{$$ = buildTree(Else, $2, $3, NULL); }
	| Elsif expr Then state_decls end_if
		{$$ = buildTree(Elsif, $2, $4,$5); }
	;
expr
	: expr Or and_expr
		{ $$ = buildTree (Eq, $1, $3, NULL); }
	| and_expr
		{$$ = $1;}

	;
and_expr
	: and_expr And not_expr
		{$$ = buildTree (And,$1,$3,NULL); }
	| not_expr
		{$$ = $1;}

	;

not_expr
	: Not not_expr
		{$$ = buildTree(Not, $2,NULL,NULL); }
	| rel_expr
		{$$ = $1;}
	;
rel_expr
	: sum
		{ $$ = $1; }
	| rel_expr Eq sum
		{$$ = buildTree(Eq,$1,$3,NULL); }
	| rel_expr NotEq sum
		{$$ = buildTree(NotEq,$1,$3,NULL); }
	| rel_expr Lt sum
		{$$ = buildTree(Lt,$1,$3,NULL); }
	| rel_expr Le sum
		{$$ = buildTree(Le,$1,$3,NULL); }
	| rel_expr Gt sum
		{$$ = buildTree(Gt,$1,$3,NULL); }
	| rel_expr Ge sum
		{$$ = buildTree(Ge,$1,$3,NULL); }
	;
	
sum
	: sum Plus prod
		{ $$ = buildTree (Plus, $1, $3, NULL); }
	| sum Minus prod
		{ $$ = buildTree (Minus, $1, $3, NULL); }
	| prod
		{ $$ = $1; }
	;
prod
	: prod Star factor
		{ $$ = buildTree (Star, $1, $3, NULL); }
	| prod Slash factor
		{ $$ = buildTree (Slash, $1, $3, NULL); }
	| prod Div factor
		{ $$ = buildTree (Div, $1, $3, NULL); }
	| prod Mod factor
		{ $$ = buildTree (Mod, $1, $3, NULL); }
	| factor
		{ $$ = $1; } 
	;
factor
	: Plus basic
		{ $$ = buildTree (UPlus, $2, NULL, NULL); }
	| Minus basic
		{ $$ = buildTree (UMinus, $2, NULL, NULL); }
	| basic
		{ $$ = $1; }
	;
basic
	: LParen expr RParen
		{ $$ = $2; }
	| RealConst
	 	{ $$ = buildRealTree (RealConst,$1); }
	| IntConst
		{ $$ = buildIntTree(IntConst, $1); }
	| ref
		{ $$ = $1; }
	;
%%

