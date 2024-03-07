#ifndef ASTNODE_H
#define ASTNODE_H

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
