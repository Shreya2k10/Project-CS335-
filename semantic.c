// semantic.c
#include "astnode.h"
#include "symbolTable.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// A function to check if a variable is declared in the current scope or any of its parent scopes
int is_declared(char* name, int scope) {
    symbol* sym = lookup(name);
    while (sym != NULL) {
        if (sym->scope <= scope) {
            return 1;
        }
        sym = sym->next;
    }
    return 0;
}

// A function to check if two types are compatible for arithmetic operations
int is_compatible(int type1, int type2) {
    if (type1 == type2) {
        return 1;
    }
    if ((type1 == INT || type1 == FLOAT) && (type2 == INT || type2 == FLOAT)) {
        return 1;
    }
    return 0;
}

// A function to check if the actual and formal arguments of a function match
int is_matching(node* actual, node* formal) {
    while (actual != NULL && formal != NULL) {
        if (!is_compatible(actual->type, formal->type)) {
            return 0;
        }
        actual = actual->next;
        formal = formal->next;
    }
    if (actual != NULL || formal != NULL) {
        return 0;
    }
    return 1;
}

// A recursive function to perform semantic analysis on the abstract syntax tree
void semantic_analysis(node* root, int scope) {
    if (root == NULL) {
        return;
    }
    switch (root->node_type) {
        case VAR_DECL: {
            // Check if the variable is already declared in the same scope
            if (lookup_in_scope(root->name, scope) != NULL) {
                printf("Semantic error: Variable %s is redeclared in scope %d\n", root->name, scope);
                exit(1);
            }
            // Insert the variable into the symbol table
            insert(root->name, root->type, scope);
            break;
        }
        case FUNC_DECL: {
            // Check if the function is already declared
            if (lookup(root->name) != NULL) {
                printf("Semantic error: Function %s is redeclared\n", root->name);
                exit(1);
            }
            // Insert the function into the symbol table
            insert(root->name, root->type, scope);
            // Perform semantic analysis on the function parameters and body in a new scope
            semantic_analysis(root->param, scope + 1);
            semantic_analysis(root->body, scope + 1);
            break;
        }
        case VAR_USE: {
            // Check if the variable is declared
            if (!is_declared(root->name, scope)) {
                printf("Semantic error: Variable %s is used without declaration in scope %d\n", root->name, scope);
                exit(1);
            }
            // Set the type of the variable use node to the type of the variable declaration
            symbol* sym = lookup(root->name);
            root->type = sym->type;
            break;
        }
        case FUNC_CALL: {
            // Check if the function is declared
            if (!is_declared(root->name, scope)) {
                printf("Semantic error: Function %s is called without declaration in scope %d\n", root->name, scope);
                exit(1);
            }
            // Perform semantic analysis on the function arguments
            semantic_analysis(root->param, scope);
            // Check if the actual and formal arguments match
            symbol* sym = lookup(root->name);
            node* formal = sym->param;
            node* actual = root->param;
            if (!is_matching(actual, formal)) {
                printf("Semantic error: Function %s is called with mismatching arguments in scope %d\n", root->name, scope);
                exit(1);
            }
            // Set the type of the function call node to the type of the function declaration
            root->type = sym->type;
            break;
        }
        case ASSIGN: {
            // Perform semantic analysis on the left and right hand sides of the assignment
            semantic_analysis(root->left, scope);
            semantic_analysis(root->right, scope);
            // Check if the types of the left and right hand sides are compatible
            if (!is_compatible(root->left->type, root->right->type)) {
                printf("Semantic error: Assignment of incompatible types in scope %d\n", scope);
                exit(1);
            }
            // Set the type of the assignment node to the type of the left hand side
            root->type = root->left->type;
            break;
        }
        case PLUS:
        case MINUS:
        case MUL:
        case DIV: {
            // Perform semantic analysis on the left and right operands of the arithmetic operation
            semantic_analysis(root->left, scope);
            semantic_analysis(root->right, scope);
            // Check if the types of the left and right operands are compatible
            if (!is_compatible(root->left->type, root->right->type)) {
                printf("Semantic error: Arithmetic operation of incompatible types in scope %d\n", scope);
                exit(1);
            }
            // Set the type of the arithmetic node to the type of the left operand
            root->type = root->left->type;
            break;
        }
        case IF:
        case WHILE: {
            // Perform semantic analysis on the condition and the body of the control structure
            semantic_analysis(root->cond, scope);
            semantic_analysis(root->body, scope);
            // Check if the type of the condition is boolean
            if (root->cond->type != BOOL) {
                printf("Semantic error: Condition of %s statement is not boolean in scope %d\n", root->node_type == IF ? "if" : "while", scope);
                exit(1);
            }
            break;
        }
        case RETURN: {
            // Perform semantic analysis on the return expression
            semantic_analysis(root->expr, scope);
            // Set the type of the return node to the type of the return expression
            root->type = root->expr->type;
            break;
        }
        default: {
            // Perform semantic analysis on the children of the node
            semantic_analysis(root->left, scope);
            semantic_analysis(root->right, scope);
            semantic_analysis(root->cond, scope);
            semantic_analysis(root->body, scope);
            semantic_analysis(root->expr, scope);
            semantic_analysis(root->param, scope);
            break;
        }
    }
}
