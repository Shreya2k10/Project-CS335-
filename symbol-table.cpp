// symbolTable.cpp
// This file implements the functions for maintaining a symbol table
// and extracting relevant information from declaration statements

#include <iostream>
#include <map>
#include <string>
#include <vector>
#include "astnode.h"

using namespace std;

// A struct to store the information of a variable or a parameter
struct VarInfo {
  string name; // the name of the variable or parameter
  string type; // the type of the variable or parameter
  string file; // the source file where the variable or parameter is declared
  int line; // the line number where the variable or parameter is declared
  int size; // the size of the variable or parameter in bytes
  int offset; // the offset of the variable or parameter from the base pointer of the function
};

// A struct to store the information of a function
struct FuncInfo {
  string name; // the name of the function
  string type; // the return type of the function
  string file; // the source file where the function is defined
  int line; // the line number where the function is defined
  int param_count; // the number of parameters of the function
  vector<VarInfo> params; // a vector of VarInfo structs for the parameters of the function
  map<string, VarInfo> locals; // a map of VarInfo structs for the local variables of the function
};

// A global symbol table that maps function names to their FuncInfo structs
map<string, FuncInfo> global_symtab;

// A helper function to get the size of a type in bytes
int get_size(string type) {
  if (type == "int") {
    return 4;
  } else if (type == "char") {
    return 1;
  } else if (type == "float") {
    return 4;
  } else if (type == "double") {
    return 8;
  } else {
    // assume pointer type
    return 4;
  }
}

// A function to extract the relevant information from a declaration statement
// and store it in the symbol table
void process_decl(ASTNode* decl, string func_name) {
  // get the type of the declaration
  string type = decl->children[0]->lexeme;

  // get the list of declarators
  ASTNode* decl_list = decl->children[1];

  // iterate over the declarators
  for (int i = 0; i < decl_list->children.size(); i++) {
    // get the current declarator
    ASTNode* declr = decl_list->children[i];

    // get the name of the declarator
    string name = declr->children[0]->lexeme;

    // create a VarInfo struct for the declarator
    VarInfo var;
    var.name = name;
    var.type = type;
    var.file = decl->file;
    var.line = decl->line;
    var.size = get_size(type);

    // check if the declarator is a parameter or a local variable
    if (func_name == "") {
      // parameter
      // get the function info from the global symbol table
      FuncInfo& func = global_symtab[name];

      // update the function info with the return type and the source file
      func.type = type;
      func.file = decl->file;

      // calculate the offset of the parameter from the base pointer
      // assume 4 bytes for the return address and 4 bytes for the old base pointer
      int offset = 8 + func.param_count * 4;

      // update the VarInfo struct with the offset
      var.offset = offset;

      // add the VarInfo struct to the params vector of the function info
      func.params.push_back(var);

      // increment the parameter count of the function
      func.param_count++;
    } else {
      // local variable
      // get the function info from the global symbol table
      FuncInfo& func = global_symtab[func_name];

      // calculate the offset of the local variable from the base pointer
      // assume negative offsets for local variables
      int offset = -var.size;

      // check if the function has any local variables
      if (!func.locals.empty()) {
        // get the last local variable
        VarInfo last = func.locals.rbegin()->second;

        // update the offset by subtracting the size and the offset of the last local variable
        offset -= last.size + last.offset;
      }

      // update the VarInfo struct with the offset
      var.offset = offset;

      // add the VarInfo struct to the locals map of the function info
      func.locals[name] = var;
    }
  }
}

// A function to print the symbol table for debugging purposes
void print_symtab() {
  // iterate over the global symbol table
  for (auto it = global_symtab.begin(); it != global_symtab.end(); it++) {
    // get the function name and the function info
    string func_name = it->first;
    FuncInfo func = it->second;

    // print the function name, type, file, and line
    cout << "Function: " << func_name << endl;
    cout << "Type: " << func.type << endl;
    cout << "File: " << func.file << endl;
    cout << "Line: " << func.line << endl;

    // print the parameters
    cout << "Parameters: " << endl;
    for (int i = 0; i < func.params.size(); i++) {
      // get the parameter info
      VarInfo param = func.params[i];

      // print the parameter name, type, file, line, size, and offset
      cout << "\tName: " << param.name << endl;
      cout << "\tType: " << param.type << endl;
      cout << "\tFile: " << param.file << endl;
      cout << "\tLine: " << param.line << endl;
      cout << "\tSize: " << param.size << endl;
      cout << "\tOffset: " << param.offset << endl;
    }

    // print the local variables
    cout << "Local variables: " << endl;
    for (auto jt = func.locals.begin(); jt != func.locals.end(); jt++) {
      // get the local variable name and info
      string var_name = jt->first;
      VarInfo var = jt->second;

      // print the local variable name, type, file, line, size, and offset
      cout << "\tName: " << var_name << endl;
      cout << "\tType: " << var.type << endl;
      cout << "\tFile: " << var.file << endl;
      cout << "\tLine: " << var.line << endl;
      cout << "\tSize: " << var.size << endl;
      cout << "\tOffset: " << var.offset << endl;
    }

    // print a blank line
    cout << endl;
  }
}
