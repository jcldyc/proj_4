#ifndef TREEH
#define TREEH
typedef struct Node {
	int	kind, value;
	float  realValue;
	struct	Node *first, *second, *third, *next;
} node;
typedef node	*tree;

extern char TokName[][12];

tree buildTree (int kind, tree first, tree second, tree third);
tree buildIntTree (int kind, int val);
tree buildRealTree(int kind, float val);
void printTree (tree);

/*
void check (tree);

void gen_program (tree);
*/
#endif
