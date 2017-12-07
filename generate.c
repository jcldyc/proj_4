#include <stdio.h>
#include "tree.h"
#include "y.tab.h"
#include "instr.h"
#include "code.h"

#define addr_of(t) (2* (t->value -1))

static void gen_expr (tree t)
{
	int	n;
	if (t == NULL) fprintf (stderr, "Internal error 11\n");
	switch (n = t->kind) {
		case Eq : case Ne :
		case Lt : case Le :
		case Gt : case Ge :
			gen_expr (t->first); gen_expr (t->second);
			if (n == Gt || n == Le) code (SWAPW);
			code (SUBI);
			code ( (n == Eq || n == Ne) ? TSTEQI : TSTLTI);
			if (n == Ne || n == Le || n == Ge) code (NOTW);
			break;
		case Plus : case Minus :
		case Star : case Slash :
			gen_expr (t->first); gen_expr (t->second);
			code (n == Plus ? ADDI : n == Minus ? SUBI : n == Star ? MULI : DIVI);
			break;
		case Ident : 
			code1 (PUSHW, addr_of (t)); code (GETSW);
			break;
		case IntConst :
			code1 (PUSHW, t->value);
			break;
		default:
			fprintf (stderr, "Internal error 12\n");
	}
}

static void generate (tree t)
{
	for (t; t != NULL; t = t->next) 
		switch (t->kind) {
			case Integer : case Boolean : case Real :
				/* do nothing */
				break;
			case Assign :
				prLC ();
				code1 (PUSHW, addr_of (t->first));
				//int addof = addr_of (t->first);			
				//printf("Address of %s is %04d\n",id_name(t->first->value),addof ); 
				gen_expr (t->second);
				code (PUTSW);
				prNL ();
				break;
			case If : {
				struct FR	fix1, fix2;
				prLC ();
				gen_expr (t->first);
				fix1 = codeFR (RGOZ);
				prNL ();
				generate (t->second);
				if (t->third != NULL) {
					fix2 = codeFR (RGOTO);
					fixFR (fix1, LC);
					generate (t->third);
					fixFR (fix2, LC);
					}
				else
					fixFR (fix1, LC);
				}
				break;
			case Loop : {
				struct FR	fix;
				int top = LC;
				prLC ();
				gen_expr (t->first);
				fix = codeFR (RGOZ);
				prNL ();
				generate (t->second);
				prLC ();
				code1 (RGOTO, top - (LC+3));
				fixFR (fix, LC);
				prNL ();
				}
				break;
			case Var : case End : {
				//int addof = addr_of (t->first);
				tree p;
				for (p = t->first; p != NULL; p = p->next){ 			
					printf("Address of %s is %04d\n",id_name(p->value),addr_of(p));
				} 
				break;
				}
			default :
				fprintf (stderr, "Internal error 10, node %s [%d]\n", TokName[t->kind], t->kind);
			}
}

void gen_program (tree t)
{
	pr_directive (".CODE .ENTRY 0");
	generate (t->first);
	prLC (); code (HALT); prNL ();
}
