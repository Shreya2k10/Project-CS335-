#ifndef ASTNODE_H
#define ASTNODE_H
#include "symbolTable.h"

// Modify the constructor of the ProgramNode class to take the global symbol table as an argument
ProgramNode::ProgramNode(FunctionListNode *fl, GlobalSymbolTable *gst) {
    this->fl = fl;
    this->gst = gst;
}

// Modify the constructor of the FunctionNode class to take the function name and the function symbol table as arguments
FunctionNode::FunctionNode(string name, TypeNode *type, ParameterListNode *pl, CompoundStatementNode *cs, FunctionSymbolTable *fst) {
    this->name = name;
    this->type = type;
    this->pl = pl;
    this->cs = cs;
    this->fst = fst;
}


// Add a method to get the global symbol table from the ProgramNode class
GlobalSymbolTable *ProgramNode::getGlobalSymbolTable() {
    return this->gst;
}

// Add a method to get the function symbol table from the FunctionNode class
FunctionSymbolTable *FunctionNode::getFunctionSymbolTable() {
    return this->fst;
}


typedef struct ASTNode {
    char *type;
    char *sym; 
    struct ASTNode* left;
    struct ASTNode* right;
    int globalindex;
} ASTNode;

// Use designated initializers to set pointers to NULL
static inline ASTNode createASTNode() {
    return (ASTNode){ .type = NULL, .sym = NULL, .left = NULL, .right = NULL };
}

#endif /* ASTNODE_H */
