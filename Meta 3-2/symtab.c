/* Amanda Menezes 2017124788 */
/* Pedro Meira 2019223208 */

#include "symtab.h"

void criaTabelas(node* current){

    current=current->son;
    node* funcVarHead=current;

    while(strcmp(current->type,"FuncDecl")==0||strcmp(current->type,"VarDecl")==0){

        if(strcmp(current->type,"FuncDecl")==0){

            addFunc(current);
            node* nodeAux=current->son->sibling->son;
            list_func *funcAux=funcPointer(current->son->son->token);
            if(funcAux != NULL){
                while(nodeAux != NULL){
                    if(strcmp(nodeAux->type,"VarDecl")==0){
                        addLocalVar(nodeAux,funcAux);
                    }
                    else if(strcmp(nodeAux->type,"NULL")!=0 && strcmp(nodeAux->type,"faketype")!=0 && strcmp(nodeAux->type,"error")!=0){
                        anotaStmtExpr(nodeAux,funcAux);
                    }
                    nodeAux=nodeAux->sibling;
                }
            }
        }
        else if(strcmp(current->type,"VarDecl")==0){
            addGlobalVar(current);
        }

        current=current->sibling;
        if (current==NULL)
            break;
    }
    current=funcVarHead;

}



void addLocalVar(node* nodeAux,list_func * funcAux){
    params *parsAux =funcAux->params;
    node *nodeAux2=nodeAux->son->sibling;
    while(parsAux!=NULL){
        if(strcmp(parsAux->name,nodeAux2->token)==0){
            printf("Line %d, column %d: Symbol %s already defined\n",nodeAux2->lin,(nodeAux2->column)-1,nodeAux2->token);
            return;
        }
        parsAux=parsAux->next;
    }
    local_var *varsAux =funcAux->vars;
    
    if(!varsAux){
                
        varsAux= (struct local_var*)malloc(sizeof( local_var));
        varsAux->next=NULL;
        varsAux->name=(char *)malloc(sizeof( char)*100);
        strcpy(varsAux->name,nodeAux->son->sibling->token);
        varsAux->type=(char *)malloc(sizeof( char)*100);
        strcpy(varsAux->type,nodeAux->son->type);
        varsAux->type[0]=tolower(varsAux->type[0]);
        funcAux->vars=varsAux;
        if (usedVar(nodeAux->sibling,varsAux->name)==0){
            printf("Line %d, column %d: Symbol %s declared but never used\n",nodeAux2->lin,(nodeAux2->column)-1,varsAux->name);
        }
        return;
    }
   
    // HEAD DA LISTA
    if(strcmp(varsAux->name,nodeAux->son->sibling->token)==0){ 
        printf("--------------%s\n",varsAux->name);
        printf("Line %d, column %d: Symbol %s already defined\n",nodeAux2->lin,(nodeAux2->column)-1,nodeAux2->token);
        return;
    }
    while(varsAux->next){                                      

        if(strcmp(varsAux->next->name,nodeAux->son->sibling->token)==0){
            printf("Line %d, column %d: Symbol %s already defined\n",nodeAux2->lin,(nodeAux2->column)-1,nodeAux2->token);
            return;
        }
        varsAux=varsAux->next;
    }

    varsAux->next= (struct local_var*)malloc(sizeof( local_var));
    varsAux=varsAux->next;
    varsAux->next=NULL;
    varsAux->name=(char *)malloc(sizeof( char)*100);
    strcpy(varsAux->name,nodeAux->son->sibling->token);
    varsAux->type=(char *)malloc(sizeof( char)*100);
    strcpy(varsAux->type,nodeAux->son->type);
    varsAux->type[0]=tolower(varsAux->type[0]);
    if (usedVar(nodeAux->sibling,varsAux->name)==0){
        printf("Line %d, column %d: Symbol %s declared but never used\n",nodeAux2->lin,(nodeAux2->column)-1,varsAux->name);
    }

}