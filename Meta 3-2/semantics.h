/* Amanda Menezes 2017124788 */
/* Pedro Meira 2019223208 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "fast.h"


// FUNÇÕES
typedef struct list_func{ 
    char* name;
    char* type;
    int func;
    int declared;
    struct local_var *vars; 
    struct params *params;
    struct list_func *next;
    
} list_func;

// VARIÁVEIS LOCAIS
typedef struct local_var{ 
    int isParam;
    char* name;
    char* type;
    struct local_var *next;
} local_var;

// VARIÁVEIS GLOBAIS
typedef struct global_var{ 
    char* name;
    char* type;
    struct global_var *next;
} global_var;

// PARAMETROS
typedef struct params{ 
    char* name;
    char* type;
    struct params *next;
} params;



char* anotaStmtExpr(node *current, list_func *funcAux);

char* anotaIdFuncao(node* current, list_func* funcAux);

char* anotaId(node* current, list_func* funcAux);

void varExist(node* current, list_func* funcAux);

list_func* funcPointer(char* funcaoNome);

list_func* addFunc(node* current);

void addGlobalVar(node* current);

void addParam(node* current,list_func * funcAux);

int varOrFunc(char * name,node* current,int opcao);

int usedVar(node* current,char *varName);

void printTabelaFuncoes();

