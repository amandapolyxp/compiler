/* Amanda Menezes 2017124788 */
/* Pedro Meira 2019223208 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>


typedef struct node{
    char * type;
    char * token;
    int column;
    int lin;
    char * note;
    struct node *son;
    struct node *sibling;
    
}node;

node *createNode(char *type, char *token, int lin, int col);

void addNota(node *nodeAux,char* note);

void addSibling(node *sibling, node *newSibling);

void addSon(node *dad, node *nodeSon);

void printTree(node *current, int depth);
