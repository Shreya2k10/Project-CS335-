%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "FlexLexer.h"
#include "astnode.h"


extern FILE* yyin;
extern int yylineno;

extern int yylex (void);
extern void yyerror(const char *);
extern void node3 (ASTNode*, ASTNode*, ASTNode*);
#define YYDEBUG 1

FILE *astgraph = stderr ;
static int numnodes = 0;
%}

%union {
    struct ASTNode * ASTNode ;
}

%start program

%token <ASTNode> Identifier Integer Float String TypeHint List ARITHMETIC_OPERATOR RELATIONAL_OPERATOR LOGICAL_OPERATOR BITWISE_OPERATOR ASSIGNMENT_OPERATOR CONTROL_FLOW Print Class Object_or_methodcall MethodDef Inheritance Main Loop INDENT DEDENT Right_parem  Left_paren 
%token <ASTNode> PrimitiveType NEWLINE
%type <ASTNode> program expression statement

%left ASSIGNMENT_OPERATOR
%right LOGICAL_OPERATOR
%nonassoc RELATIONAL_OPERATOR
%left ARITHMETIC_OPERATOR
%left BITWISE_OPERATOR
%left Inheritance
%left Print
%left MethodDef
%right Main
%left CONTROL_FLOW
%left Class
%type <ASTNode> CONTROL_BLOCK


%%

program: statement ';' {
    $$ = $1;
    (*$$).type = (*$1).type;
    $$->globalindex = numnodes ++;
}
| statement{
    $$ = $1;
    (*$$).type = (*$1).type;
    // $$->globalindex = numnodes ++;
}
| program statement {
    $$ = (ASTNode *)malloc(sizeof(ASTNode));
    (*$$).type = strdup("statements");
    (*$$).sym = strdup("statements 1");
    $$->globalindex = numnodes ++;
    node3 ($1, $$, $2);
}
| program NEWLINE {
        $$ = $1; 
}
;

statement: expression NEWLINE {
    $$ = $1;
    (*$$).type = (*$1).type;

}
| CONTROL_FLOW expression Loop NEWLINE INDENT CONTROL_BLOCK DEDENT {
    $$ = (ASTNode *)malloc(sizeof(ASTNode));
    (*$$).type = strdup ("CONTROL_FLOW");
    (*$$).sym = $1->sym;
    (*$$).left = $2; 
    (*$$).right = $6; 
    $$->globalindex = numnodes;
    node3 ($2, $$, $6);
    numnodes ++; 
}
| CONTROL_FLOW Loop NEWLINE INDENT CONTROL_BLOCK DEDENT {
    $$ = (ASTNode *)malloc(sizeof(ASTNode));
    (*$$).type = strdup("ELSE");
    (*$$).sym = strdup((*$2).sym);
    (*$$).left = NULL;
    (*$$).right = $5;
    $$->globalindex = numnodes;
    node3 (NULL, $$, $5);
    numnodes ++;
}
;


expression: Integer {
    $$ = (ASTNode *)malloc(sizeof(ASTNode));
    (*$$).type = strdup("Integer");
    (*$$).sym = strdup((*$1).type);
    $$->globalindex = numnodes ++;
    fprintf (astgraph, "node_%d [label=\"%s\"];\n", -1+numnodes, $1->sym);
}
| Float {
    $$ = (ASTNode *)malloc(sizeof(ASTNode));
    (*$$).type = strdup("Float");
    (*$$).sym = strdup((*$1).type);
    $$->globalindex = numnodes ++;
    fprintf (astgraph, "node_%d [label=\"%s\"];\n", -1+numnodes, $1->sym);
}
| String {
    $$ = (ASTNode *)malloc(sizeof(ASTNode));
    (*$$).type = strdup("String");
    $$->globalindex = numnodes ++;
    (*$$).sym = strdup((*$1).type);
    fprintf (astgraph, "node_%d [label=\"%s\"];\n", -1+numnodes, $1->sym);
}
| Identifier {
    $$ = (ASTNode *)malloc(sizeof(ASTNode));
    (*$$).type = strdup("Identifier");
    (*$$).sym = strdup((*$1).type);
    $$->globalindex = numnodes++;
    fprintf (astgraph, "node_%d [label=\"%s\"];\n", -1+numnodes, $1->sym);
}
| PrimitiveType {
    $$ = (ASTNode *)malloc(sizeof(ASTNode));
    (*$$).type = strdup("PrimitiveType");
    (*$$).sym = strdup((*$1).type);
    $$->globalindex = numnodes ++;

    fprintf (astgraph, "node_%d [label=\"%s\"];\n", -1+numnodes, $1->sym);
}
| List {
    $$ = (ASTNode *)malloc(sizeof(ASTNode));
    (*$$).type = strdup("List");
    (*$$).sym = strdup((*$1).type);
    $$->globalindex = numnodes ++;
    fprintf (astgraph, "node_%d [label=\"%s\"];\n", -1+numnodes, $1->sym);
}
| expression ARITHMETIC_OPERATOR expression {
    $$ = (ASTNode *)malloc(sizeof(ASTNode));
    (*$$).type = strdup("ARITHMETIC_OPERATOR");
    (*$$).sym = strdup((*$2).sym);
    (*$$).left = $1;
    (*$$).right = $3;
    $$->globalindex = numnodes ++;
    node3 ($1, $$, $3);
    numnodes++;


}
| expression RELATIONAL_OPERATOR expression {
    $$ = (ASTNode *)malloc(sizeof(ASTNode));
    (*$$).type = strdup("RELATIONAL_OPERATOR");
    (*$$).sym = strdup((*$2).sym);
    (*$$).left = $1;
    (*$$).right = $3;
    $$->globalindex = numnodes ++;
    node3 ($1, $$, $3);
    numnodes++;

}
| expression LOGICAL_OPERATOR expression {
    $$ = (ASTNode *)malloc(sizeof(ASTNode));
    (*$$).type = strdup("LOGICAL_OPERATOR");
    (*$$).sym = strdup((*$2).sym);
    (*$$).left = $1;
    (*$$).right = $3;
    $$->globalindex = numnodes ++;
    node3 ($1, $$, $3);
    numnodes++;


}
| expression BITWISE_OPERATOR expression {
    $$ = (ASTNode *)malloc(sizeof(ASTNode));
    (*$$).type = strdup("LOGICAL_OPERATOR");
    (*$$).sym = strdup((*$2).sym);
    (*$$).left = $1;
    (*$$).right = $3;
    $$->globalindex = numnodes ++;
    node3 ($1, $$, $3);
    numnodes++;

}
| expression ASSIGNMENT_OPERATOR expression {
    $$ = (ASTNode *)malloc(sizeof(ASTNode));
    (*$$).type = strdup("ASSIGNMENT_OPERATOR");
    (*$$).sym = strdup((*$2).sym);
    (*$$).left = $1;
    (*$$).right = $3;
    $$->globalindex = numnodes;
    node3 ($1, $$, $3);
    numnodes++;
}
| Print Left_paren expression Right_parem {
    $$ = (ASTNode *)malloc(sizeof(ASTNode));
    (*$$).type = strdup("Print");
    (*$$).sym = strdup((*$2).sym);
    (*$$).left = $2;
    $$->globalindex = numnodes ++;
    (*$$).right = NULL;
    node3 ($1, $$, NULL);
}

| Class Identifier Loop {
    $$ = (ASTNode *)malloc(sizeof(ASTNode));
    (*$$).type = strdup("Class");
    (*$$).sym = strdup((*$$).sym);
    (*$$).left = NULL;
    (*$$).right = $1;
    $$->globalindex = numnodes;
    node3 (NULL, $$, $1);
    numnodes ++;
}
| Object_or_methodcall expression Loop {
    $$ = (ASTNode *)malloc(sizeof(ASTNode));
    (*$$).type = strdup("Object_or_methodcall");
    (*$$).sym = strdup((*$$).sym);
    (*$$).left = NULL;
    (*$$).right = $1;
    $$->globalindex = numnodes;
    node3 (NULL, $$, $1);
    numnodes ++;

}
| MethodDef expression Loop {
    $$ = (ASTNode *)malloc(sizeof(ASTNode));
    (*$$).type = strdup("Class");
    (*$$).sym = strdup((*$1).sym);
    (*$$).left = $2;
    (*$$).right = $3;
    $$->globalindex = numnodes ++;
    node3 ($1, $$, $3);
    numnodes ++;

}
| Inheritance expression expression {
    $$ = (ASTNode *)malloc(sizeof(ASTNode));
    (*$$).type = strdup("Class");
    (*$$).sym = strdup((*$1).sym);
    (*$$).left = $2;
    (*$$).right = $3;
    $$->globalindex = numnodes ++;
    node3 ($1, $$, $3);
    numnodes ++;

}
| Main expression {
    $$ = (ASTNode *)malloc(sizeof(ASTNode));
    (*$$).type = strdup("Print");
    (*$$).sym = strdup((*$1).sym);
    (*$$).left = $2;
    (*$$).right = NULL;
    $$->globalindex = numnodes ++;
    node3 ($1, $$, NULL);
    numnodes ++;

}
;

CONTROL_BLOCK: CONTROL_BLOCK statement {
    $$ = (ASTNode *)malloc(sizeof(ASTNode));
    (*$$).type = strdup("Code Block");
    (*$$).sym = strdup("Block");
    (*$$).left = $2;
    (*$$).right = NULL;
    $$->globalindex = numnodes;
    node3 ($1, $$, $2);
    numnodes ++;
}
| statement {
    $$ = $1;
}
;

%%

void set_input_file(const char* filename) {
    FILE* file = fopen(filename, "r");
    if (!file) {
        fprintf(stderr, "Unable to open file: %s\n", filename);
        exit(EXIT_FAILURE);
    }
    yyin = file;
    return;
}

void close_input_file() {
    fclose(yyin);
}


int main(int argc, char** argv) {

#ifdef YYDEBUG
    yydebug = 1;
#endif
    if (argc < 2) {
        printf("Usage: %s <input_file>\n", argv[0]);
        return 1;
    }
    astgraph = fopen ("output.dot", "w+");
    fprintf (astgraph, "digraph my_ast {\n");

    set_input_file(argv[1]); 

    yyparse();
    fprintf (astgraph, "}\n");
    close_input_file();
    fclose (astgraph);

    return 0;
}

void yyerror (const char *message) {
    fprintf (stderr, message, NULL);
    exit(1);
}

void node3 (ASTNode* left, ASTNode* main, ASTNode* right) {
    // left and right have been created or don't exist
    fprintf (astgraph, "node_%d [label=\"%s\"];\n", main->globalindex   , main->sym);
    if (right != NULL) {
        fprintf (astgraph, "node_%d -> node_%d;\n", main->globalindex, right->globalindex);
    }
    if (left != NULL) {
        fprintf (astgraph, "node_%d -> node_%d;\n", main->globalindex, left->globalindex);
    }
    return ;
}

