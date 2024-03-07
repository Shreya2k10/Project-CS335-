%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"
#include "sybolTable.cpp"

// A structure to store information about a variable or a function
typedef struct symbol {
  char *name; // The name of the symbol
  int type; // The type of the symbol (int, float, etc.)
  int size; // The size of the symbol in bytes
  int offset; // The offset of the symbol within the function
  int line; // The line number where the symbol is declared
  char *file; // The file name where the symbol is declared
  struct symbol *next; // A pointer to the next symbol in the same scope
} symbol;

// A structure to store a local symbol table for a function
typedef struct local_table {
  char *func_name; // The name of the function
  symbol *params; // A linked list of parameters
  symbol *vars; // A linked list of local variables
  struct local_table *next; // A pointer to the next local table
} local_table;

// A global symbol table that maps function names to their local tables
local_table *global_table = NULL;

// A function to create a new symbol with the given information
symbol *create_symbol(char *name, int type, int size, int offset, int line, char *file) {
  symbol *s = (symbol *)malloc(sizeof(symbol));
  s->name = strdup(name);
  s->type = type;
  s->size = size;
  s->offset = offset;
  s->line = line;
  s->file = strdup(file);
  s->next = NULL;
  return s;
}

// A function to create a new local table with the given function name
local_table *create_local_table(char *func_name) {
  local_table *lt = (local_table *)malloc(sizeof(local_table));
  lt->func_name = strdup(func_name);
  lt->params = NULL;
  lt->vars = NULL;
  lt->next = NULL;
  return lt;
}

// A function to insert a symbol into a linked list of symbols
void insert_symbol(symbol **head, symbol *s) {
  if (*head == NULL) {
    *head = s;
  } else {
    symbol *curr = *head;
    while (curr->next != NULL) {
      curr = curr->next;
    }
    curr->next = s;
  }
}

// A function to insert a local table into the global table
void insert_local_table(local_table *lt) {
  if (global_table == NULL) {
    global_table = lt;
  } else {
    local_table *curr = global_table;
    while (curr->next != NULL) {
      curr = curr->next;
    }
    curr->next = lt;
  }
}

// A function to find a local table by the function name
local_table *find_local_table(char *func_name) {
  local_table *curr = global_table;
  while (curr != NULL) {
    if (strcmp(curr->func_name, func_name) == 0) {
      return curr;
    }
    curr = curr->next;
  }
  return NULL;
}

// A function to print a symbol
void print_symbol(symbol *s) {
  printf("%s\t%d\t%d\t%d\t%d\t%s\n", s->name, s->type, s->size, s->offset, s->line, s->file);
}

// A function to print a local table
void print_local_table(local_table *lt) {
  printf("Function: %s\n", lt->func_name);
  printf("Parameters:\n");
  symbol *p = lt->params;
  while (p != NULL) {
    print_symbol(p);
    p = p->next;
  }
  printf("Local variables:\n");
  symbol *v = lt->vars;
  while (v != NULL) {
    print_symbol(v);
    v = v->next;
  }
}

// A function to print the global table
void print_global_table() {
  local_table *curr = global_table;
  while (curr != NULL) {
    print_local_table(curr);
    curr = curr->next;
  }
}

// A variable to store the current function name
char *current_func = NULL;

// A variable to store the current offset within the function
int current_offset = 0;

// A variable to store the current line number
int lineno = 1;

// A variable to store the current file name
char *filename = NULL;

%}