/* Amanda Menezes 2017124788 */
/* Pedro Meira 2019223208 */

#include <stdio.h>
#include <stdlib.h>

typedef struct node{
    char * type;
    char * token;
    struct node *son;
    struct node *sibling;
    
}node;

node *createNode(char *type, char *token);

void addSibling(node *sibling, node *newSibling);

void addSon(node *dad, node *nodeSon);

void printTree(node *current, int depth);
