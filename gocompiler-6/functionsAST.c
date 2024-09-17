/* Amanda Menezes 2017124788 */
/* Pedro Meira 2019223208 */

#include "functionsAST.h"
#include <string.h>

node *createNode(char *type, char *token){

    node *newNode = (node *)malloc(sizeof(node));
    newNode->type = (char *)strdup(type);
    newNode->son = NULL;
    newNode->sibling = NULL;

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
                    printf("%s(%s)\n", current->type, current->token);
                }
                
                else{
                    printf("%s\n", current->type);
                }
                
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
