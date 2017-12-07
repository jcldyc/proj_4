#include <stdio.h>
#include "tree.h"
#include "y.tab.h"
#include "ST.h"

extern int top;
STentry ST[100] = {0, NoType}; 

void prST (void)
{
	int i;
	printf ("SYMBOL TABLE\n");
	for (i = 0; i <= top; i++) {
		int	t = ST[i].type;
		printf ("%3d %-10s\t%s\n", i, id_name (i), 
				t == Int ? "Integer" : t == Boolean ? "Boolean" : t == Real ? "Real" : "<none>");
		}
}

static int check_expr (tree t)
{
	if (t == NULL) { 
		fprintf (stderr, "You shouldn't be here; missing expression\n"); 
		return NoType; 
		}
	switch (t->kind) {
		case Int :
			return Int;
		case Boolean :
			return Boolean;
		case Real :
			return Real;
		case When :
			return check_expr(t->first);
		case Eq : case NotEq :
		case Lt : case Le :
		case Gt : case Ge : {
			int t1 = check_expr (t->first), t2 = check_expr (t->second);
			if (t1 != t2 && !(t1 !=Boolean && t2!=Boolean)) {
				fprintf (stderr, "Type mismatch in comparison\n");
				return (t->value = NoType);
				}
			else 
				return (t->value = Boolean);
			}
			break;

		case Plus : case Minus :
		case Star : case Slash : 
		case Div  : case Mod   :{
			int t1 = check_expr (t->first), t2 = check_expr (t->second);
			if (t1 != Int || t2 != Int) {
				fprintf (stderr, "Type mismatch in binary arithmetic expression\n");
				return (t->value = NoType);
				}
			else 
				return (t->value = Int);
			}
			break;

		case And : case Or:{
			int t1 = check_expr(t->first),t2 = check_expr (t->second);
			if (t1 != Boolean || t2 != Boolean){
				fprintf(stderr,"Type Mismatch And, Or\n");
				return(t->value =NoType);
			}	
		    	else
				return (t->value = Boolean);	
			}
			break;

		case Not :{
			int t1 = check_expr(t->first);
			if (t1 != Boolean){
				fprintf(stderr,"Type Mismatch Not\n");
				return(t->value = NoType);
			}
			else
				return (t->value = Boolean);
				
		break;
		}

		case Ident : {
			int pos = t->value;	
			if (ST[pos].index == 0){
				fprintf(stderr, "Undecalered %s value\n",id_name(pos));
			}
			
			return ST[pos].type;
			break;
			}
		case IntConst :
			return Int;		/* t->value contains other info */
			break;
		case RealConst :
			return Real;            //t->value contrains other info
			break;
		default:
			fprintf (stderr, "You shouldn't be here; invalid expression operator\n");
	}
}

static void handle_decls (tree t)
{
	for (t; t!= NULL; t = t->next) {
		int	type = t->kind;
		tree	p;
		if (type != Int && type != Boolean) {
			fprintf (stderr, "Bad type in decl\n"); return;
			}
		for (p = t->first; p != NULL; p = p->next) {
			int	pos = p->value;
			ST[pos].index = pos;
			ST[pos].type = type;
			}
		}
}

void check (tree t)
{
	for (t; t != NULL; t = t->next) 
		switch (t->kind) {
			case Prog:
			//	handle_decls (t->first);
				check (t->first);
				printf ("\n");
				prST ();
				break;
			case Assign :{
				int pos = t->first->value;
				if (ST[pos].index == 0) {
					fprintf(stderr, " %s is undeclared\n",id_name(t->first->value));		
			
					}
				int assignExpr = check_expr(t->second);
				if (!(assignExpr == Int && ST[pos].type == Real) && assignExpr != ST[pos].type) 
					fprintf (stderr, "Type error in assignment to identifier %s\n", 
								id_name(t->first->value));
				break;
				}
			case If :
				if (check_expr (t->first) != Boolean)
					fprintf (stderr, "Non-boolean in condition to IF\n");
				check (t->second);
				check (t->third);
				break;
			
			case Elsif :
				if (check_expr(t->first) != Boolean)
					fprintf(stderr, "expresion in Else  is not of type Boolean\n");
				check(t->second);
				check(t->third);

				break;
			case Else :
				check (t->first);
				check (t->second);
				break;

			case End :
				break;
	
			case Loop :
				if (check_expr (t->first) != Boolean)
					fprintf (stderr, "Non-boolean in condition to WHILE\n");
				check (t->second);
				break;
			case Var :{		
				int varType = (check_expr(t->second));
				if (varType != Int && varType != Real && varType != Boolean) {
					fprintf(stderr, "Not a valid type Var\n"); 
				}
					
				
				else {  
					tree p; 
					//int pos = t->first->value;	
				 	//fprintf(stderr,"Test pos is %d\n",pos);
					//fprintf(stderr,"test pos2 is %d\n",t->next->value);		
					for (p = t->first; p != NULL; p = p->next) {
						int	pos = p->value;
						if(ST[pos].index == 0){
							ST[pos].index = pos;
							ST[pos].type = varType;
						}
						else {
							fprintf(stderr, "Redecl of %s\n",id_name(pos));
						}
					}
					//if(ST[pos].index == 0){
					//	ST[pos].index = pos;
					//	ST[pos].type = varType;	
				//	}
			
	//				else {
	//					fprintf(stderr, "Redecl of %s\n",id_name(pos));
	//				}
					
					
				}
				break;	
				}	
			case Assert :{
					int pos = check_expr(t->first);
					if (pos != Boolean)
						fprintf(stderr , " Error Assert.. Must be of type boolean\n");
				break;
				}
			case Exit : {
					if (t->first == NULL) {break;}
					else {
						if (check_expr(t->first) != Boolean)
							fprintf(stderr, "Error When.. Must be of type boolean\n");
					}
				break;
				}
			default :
				fprintf (stderr, "You shouldn't be here; invalid statement\n");
			}
}
