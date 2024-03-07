%option noyywrap
%option yylineno
%option stack

%{


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <unistd.h>
#include "astnode.h"
#include "parser.tab.h"


#define YY_DECL extern int yylex() 
int yyerror(char *s) {
    fprintf(stderr, "Syntax error: %s\n", s);
    return 0;
}



extern YYSTYPE yylval;

void err (const char* s)
{
    if(s == NULL) {
        printf("Error in memory allocation");
        exit(0);
    }
}

#define MAX_LENGTH 100

void close_input_file();

bool flag=false;

char mymap[MAX_LENGTH][MAX_LENGTH]; 

void insertMap(const char* lexeme, const char* token){
    for(int i = 0; i < MAX_LENGTH; i++)     {
        if(strcmp(mymap[i], lexeme) == 0){ 
            return;
        }
        if(strlen(mymap[i]) == 0) { 
            strcpy(mymap[i], lexeme);
            break;
        }
    }
}

int current_indentation = 0; // DENT production includes newline
static int nodenum = 0;
int return_dedent = -1;
int return_indent = -1;



%}
Whitespace [ \r\f]+
Comment "#"[^\n]*

Opening_curly_brace "{"
Closing_curly_brace "}"
Colon ":"
Semicolon ";"
Left_paren "("
Right_parem ")"
Integer [0-9]+
Float [0-9]*"."[0-9]+
String \"[^\"]*\"
Boolean "true"|"false"
TypeHint "->"
List "\["[^]]*"\]"
PrimitiveType {Integer}|{Float}|{String}|{Boolean}

ARITHMETIC_OPERATOR "+"|"-"|"*"|"/"|"//"|"%"|"**"
RELATIONAL_OPERATOR "=="|"!="|">"|"<"|">="|"<="
LOGICAL_OPERATOR "and"|"or"|"not"
BITWISE_OPERATOR "&"|"\\|"|"ˆ"|"˜"|"<<"|">>"
ASSIGNMENT_OPERATOR "="|"+="|"-="|"*="|"="|"%"|"**="|"&="|"\\|="|"ˆ="|"<<="|">>="
CONTROL_FLOW "if"|"elif"|"else"|"for"|"while"|"break"|"continue"|"range"
Print "print"(\(.*\))?
Class "class"
Object_or_methodcall [a-zA-Z_][a-zA-Z0-9_]*"("[a-zA-Z0-9_, ]*")"
MethodDef "def"
Inheritance "extends"
Main "main"(\(.*\))?
Identifier [a-zA-Z_][a-zA-Z0-9_]*
Special_method "__name__"|"__main__"|"__init__" 
Loop ":"
Range_method: "range"
DENT [\n][ \t]*

%%
    {
        fprintf (stderr, " INDENTTT %d %d %d\n", return_indent, return_dedent, current_indentation);
        if (return_indent == -1) return_indent = 0;
        if (return_dedent == -1) return_dedent = 0;

        if (return_indent == 1){
            return_indent = 0;
            return INDENT;
        }
        if (return_dedent) {
            return_dedent -= 2;
            fprintf (stderr, "returning dedent\n");
            return DEDENT;
        }

    }

{Whitespace} {}
{Comment} {}

{DENT} {
    int new_indentation = strlen(yytext) - 1;
    fprintf (stderr, "matched dent len %d\n", new_indentation);

    if (new_indentation > current_indentation) {
        insertMap("INDENT","DENT");
        current_indentation = new_indentation ;
        return_indent = 1;
        return NEWLINE;

    } else if (new_indentation < current_indentation) {
        insertMap("DEDENT","DENT");
        return_dedent = current_indentation - new_indentation;
        current_indentation = new_indentation;
        // fprintf (stderr, "^^^^^ return_dedent is %d\n", return_dedent);
        return NEWLINE;

    } 
    current_indentation = new_indentation;
    return NEWLINE;
}

{Left_paren} {
    insertMap(strdup(yytext),"Left_paren");
    yylval.ASTNode = (ASTNode *)malloc(sizeof(ASTNode)); // Allocate memory for ASTNode
    err((const char*)yylval.ASTNode); // Check for NULL after malloc
    yylval.ASTNode->sym = strdup(yytext);
    yylval.ASTNode->type = strdup("Left_paren");

    return Left_paren;
}

{Right_parem} {
    insertMap(strdup(yytext),"Right_parem");
    yylval.ASTNode = (ASTNode *)malloc(sizeof(ASTNode)); // Allocate memory for ASTNode
    err((const char*)yylval.ASTNode); // Check for NULL after malloc
    yylval.ASTNode->sym = strdup(yytext);
    yylval.ASTNode->type = strdup("Right_parem");

    return Right_parem;
}

{Special_method} {
    insertMap(strdup(yytext),"Special_methond");
    yylval.ASTNode = (ASTNode *)malloc(sizeof(ASTNode)); // Allocate memory for ASTNode
    err((const char*)yylval.ASTNode); // Check for NULL after malloc
    yylval.ASTNode->sym = strdup(yytext);
    yylval.ASTNode->type = strdup("Special_methond");

	return Identifier;
}
{PrimitiveType} {
    insertMap(strdup(yytext),"PrimitiveType");
    yylval.ASTNode = (ASTNode *)malloc(sizeof(ASTNode)); // Allocate memory for ASTNode
    err((const char*)yylval.ASTNode); // Check for NULL after malloc
    yylval.ASTNode->sym = strdup(yytext);
    yylval.ASTNode->type = strdup("PrimitiveType");
	return PrimitiveType;
}
{List} {
    insertMap(strdup(yytext),"List");
    yylval.ASTNode = (ASTNode *)malloc(sizeof(ASTNode)); // Allocate memory for ASTNode
    err((const char*)yylval.ASTNode); // Check for NULL after malloc
    yylval.ASTNode->sym = strdup(yytext);
    yylval.ASTNode->type = strdup("List");

	return List;
}
{ASSIGNMENT_OPERATOR} {
    insertMap(strdup(yytext),"ASSIGNMENT_OPERATOR");
    yylval.ASTNode = (ASTNode *)malloc(sizeof(ASTNode)); // Allocate memory for ASTNode
    err((const char*)yylval.ASTNode); // Check for NULL after malloc
    yylval.ASTNode->sym = strdup(yytext);
    yylval.ASTNode->type = strdup("ASSIGNMENT_OPERATOR");
    
	return ASSIGNMENT_OPERATOR;
}
{RELATIONAL_OPERATOR} {
    insertMap(strdup(yytext),"RELATIONAL_OPERATOR");
    yylval.ASTNode = (ASTNode *)malloc(sizeof(ASTNode)); // Allocate memory for ASTNode
    err((const char*)yylval.ASTNode); // Check for NULL after malloc
    yylval.ASTNode->sym = strdup(yytext);
    yylval.ASTNode->type = strdup("RELATIONAL_OPERATOR");

	return RELATIONAL_OPERATOR;
}
{LOGICAL_OPERATOR} {
    insertMap(strdup(yytext),"LOGICAL_OPERATOR");
    yylval.ASTNode = (ASTNode *)malloc(sizeof(ASTNode)); // Allocate memory for ASTNode
    err((const char*)yylval.ASTNode); // Check for NULL after malloc
    yylval.ASTNode->sym = strdup(yytext);
    yylval.ASTNode->type = strdup("LOGICAL_OPERATOR");

	return LOGICAL_OPERATOR;
}
{BITWISE_OPERATOR} {
    insertMap(strdup(yytext),"BITWISE_OPERATOR");
    yylval.ASTNode = (ASTNode *)malloc(sizeof(ASTNode)); // Allocate memory for ASTNode
    err((const char*)yylval.ASTNode); // Check for NULL after malloc
    yylval.ASTNode->sym = strdup(yytext);
    yylval.ASTNode->type = strdup("BITWISE_OPERATOR");

	return BITWISE_OPERATOR;
}
{ARITHMETIC_OPERATOR} {
    insertMap(strdup(yytext),"ARITHMETIC_OPERATOR");
    yylval.ASTNode = (ASTNode *)malloc(sizeof(ASTNode));
    err((const char*)yylval.ASTNode); // Check for NULL after malloc
    yylval.ASTNode->sym = strdup(yytext);
    yylval.ASTNode->type = strdup("ARITHMETIC_OPERATOR");

	return ARITHMETIC_OPERATOR;
}
{CONTROL_FLOW} {
    insertMap(strdup(yytext),"CONTROL_FLOW");
    yylval.ASTNode = (ASTNode *)malloc(sizeof(ASTNode));
    err((const char*)yylval.ASTNode); // Check for NULL after malloc
    yylval.ASTNode->sym = strdup(yytext);
    yylval.ASTNode->type = strdup("CONTROL_FLOW");

	return CONTROL_FLOW;
}
{Print} {
    insertMap(strdup(yytext),"Print");
    yylval.ASTNode = (ASTNode *)malloc(sizeof(ASTNode));
    err((const char*)yylval.ASTNode); // Check for NULL after malloc
    yylval.ASTNode->sym = strdup(yytext);
    yylval.ASTNode->type = strdup("Print");

	return Print;
}
{Class} {
    insertMap(strdup(yytext),"Class");
    yylval.ASTNode = (ASTNode *)malloc(sizeof(ASTNode));
    err((const char*)yylval.ASTNode); // Check for NULL after malloc
    yylval.ASTNode->sym = strdup(yytext);
    yylval.ASTNode->type = strdup("Class");

	return Class;
}
{MethodDef} {
    insertMap(strdup(yytext),"MethodDef");
    yylval.ASTNode = (ASTNode *)malloc(sizeof(ASTNode));
    err((const char*)yylval.ASTNode); // Check for NULL after malloc
    yylval.ASTNode->sym = strdup(yytext);
    yylval.ASTNode->type = strdup("MethodDef");

	return MethodDef;
}
{Inheritance} {
    insertMap(strdup(yytext),"Inheritance");
    yylval.ASTNode = (ASTNode *)malloc(sizeof(ASTNode));
    err((const char*)yylval.ASTNode); // Check for NULL after malloc
    yylval.ASTNode->sym = strdup(yytext);
    yylval.ASTNode->type = strdup("Inheritance");

	return Inheritance;
}
{Object_or_methodcall} {
    insertMap(strdup(yytext),"Object_or_MethodCall");
    yylval.ASTNode = (ASTNode *)malloc(sizeof(ASTNode));
    err((const char*)yylval.ASTNode); // Check for NULL after malloc
    yylval.ASTNode->sym = strdup(yytext);
    yylval.ASTNode->type = strdup("Object_or_MethodCall");

	return Object_or_methodcall;
}
{Main} {
    insertMap(strdup(yytext),"Main");
    yylval.ASTNode = (ASTNode *)malloc(sizeof(ASTNode));
    err((const char*)yylval.ASTNode); // Check for NULL after malloc
    yylval.ASTNode->sym = strdup(yytext);
    yylval.ASTNode->type = strdup("Main");

	return Main;
}
{TypeHint} {
    insertMap(strdup(yytext),"TypeHint");
    yylval.ASTNode = (ASTNode *)malloc(sizeof(ASTNode));
    err((const char*)yylval.ASTNode); // Check for NULL after malloc
    yylval.ASTNode->sym = strdup(yytext);
    yylval.ASTNode->type = strdup("TypeHint");

	return TypeHint;
}
{Identifier} {
    insertMap(strdup(yytext),"Identifier");
    yylval.ASTNode = (ASTNode *)malloc(sizeof(ASTNode));
    err((const char*)yylval.ASTNode); // Check for NULL after malloc
    yylval.ASTNode->sym = strdup(yytext);
    yylval.ASTNode->type = strdup("Identifier");

	return Identifier;
}
{Loop} {
    insertMap(strdup(yytext),"Loop"); // Use strdup(yytext) for consistency
	return Loop;
}

. {
    fprintf(stderr, "Error on line %d: read an invalid character %s\n", yylineno, yytext);
    flag = true;
    yyerror (yytext);
}

<<EOF>> {
    fprintf (stderr, "lexer line -  read eof\n");
    return 0;
}


%%



