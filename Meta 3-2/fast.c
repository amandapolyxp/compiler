/* Amanda Menezes 2017124788 */
/* Pedro Meira 2019223208 */

#include "fast.h"
#include <string.h>

node *createNode(char *type, char *token, int lin, int col){

    node *newNode = (node *)malloc(sizeof(node));
    newNode->type = (char *)strdup(type);
    newNode->son = NULL;
    newNode->sibling = NULL;
    newNode->lin = lin;
    newNode->column = col;
    newNode->note = NULL;

    if (token == NULL){
        newNode->token = NULL;
        return newNode;
    }
    newNode->token = (char *)strdup(token);
    return newNode;
}


void addSibling(node *sibling, node *newSibling){
    
    if (sibling != NULL && newSibling != NULL){

        node *aux = sibling;

        while (aux->sibling != NULL){
            aux = aux->sibling;
        }
        aux->sibling = newSibling;
    }
}

void addNota(node *nodeAux,char* note){

    nodeAux->note=(char *)strdup(note);
    return;
}

void addSon(node *dad, node *son){
    
    if (dad != NULL && son != NULL)
        dad->son = son;
    
}
void printTree(node *current, int depth){
    if (current != NULL){   //Arvore nao esta vazia
        
        if (current->type != NULL){ //tem type
            
            if(strcmp(current->type,"NULL")!=0 && strcmp(current->type,"faketype") != 0 && strcmp(current->type,"error") != 0){ //Nenhum que nao deve ser impresso
                for (int i = 0; i < depth; i++)
                printf("..");

                if (current->token != NULL){
                    printf("%s(%s)", current->type, current->token);
                }
                
                else{
                    printf("%s", current->type);
                }

                if(current->note!=NULL){
                    if(strcmp(current->note,"none")!=0){
                            printf(" - %s",current->note);
                    }
                    
                }
                printf("\n");
                if (current->son != NULL)
                    printTree(current->son, depth + 1);
                if (current->sibling != NULL)
                    printTree(current->sibling, depth);
            }
            else{
                if (current->son != NULL)
                    printTree(current->son, depth );
                if (current->sibling != NULL)
                    printTree(current->sibling, depth);
            }
        }
    }
}
