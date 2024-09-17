/* Amanda Menezes 2017124788 */
/* Pedro Meira 2019223208 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "semantics.h"


struct list_func *head =NULL;
int lin;
int column;


void printTabelaFuncoes(){ 
    printf("===== Global Symbol Table =====\n");
    struct list_func *auxFunc =head;
    while(auxFunc){
        
        printf("%s",auxFunc->name);
        if(auxFunc->func){
            printf("\t(");
            struct params *paramsAux=auxFunc->params;
            if(paramsAux){
                printf("%s",paramsAux->type);
                paramsAux=paramsAux->next;
                while(paramsAux){
                    printf(",%s",paramsAux->type);
                    paramsAux=paramsAux->next;
                }
            }

            printf(")");
        }
        else{
            printf("\t");
        }
        printf("\t%s\n", auxFunc->type );
        auxFunc=auxFunc->next;
    }
    
    auxFunc=head;
    while(auxFunc){
        if(auxFunc->func){
            printf("\n===== Function ");
            printf("%s(",auxFunc->name);
            struct params *auxParam=auxFunc->params;
            if(auxParam){
                printf("%s",auxParam->type);
                auxParam=auxParam->next;
                while(auxParam){
                    printf(",%s",auxParam->type);
                    auxParam=auxParam->next;
                }
            }
            printf(") Symbol Table =====\n");
            printf("%s\t\t%s\n","return",auxFunc->type);        

            auxParam=auxFunc->params;
            while(auxParam){
                printf("%s\t\t%s\tparam\n",auxParam->name,auxParam->type); // PARAM COMO VAR LOCAL
                auxParam=auxParam->next;
            }

            struct local_var *varsAux=auxFunc->vars;  // VAR LOCAL
            while(varsAux){

                printf("%s\t\t%s\n",varsAux->name,varsAux->type);
                varsAux=varsAux->next;
            }
        }
        
        auxFunc=auxFunc->next;
    }
    printf("\n");
}


char* anotaIdFuncao(node* current, list_func* funcAux){
   
    list_func *funcAux2=head;
    while(funcAux2){
        if(funcAux2->func){
            if(strcmp(funcAux2->name,current->token)==0){
                node* nodeAux=current->sibling;
                params *paramsAux=funcAux2->params;
                int param1=0;
                int param2=0;
                int invalido=0;
                char strAux[1024]="\0";
                strcat(strAux,"(");
                while(nodeAux||paramsAux){
                    char *tipo1;
                    if(nodeAux){
                        tipo1=anotaStmtExpr(nodeAux,funcAux);
                        if(strcmp(strAux,"(")==0){
                            strcat(strAux,tipo1);
                        }
                        else{
                            strcat(strAux,",");
                            strcat(strAux,tipo1);
                        }
                    }
                    if(nodeAux&&paramsAux){
                        if(strcmp(tipo1,paramsAux->type)!=0){
                            invalido=1;
                        }
                    }
                    if(nodeAux){
                        param1++;
                        nodeAux=nodeAux->sibling;
                    }
                    if(paramsAux){
                        paramsAux=paramsAux->next;
                        param2++;
                    }
                }
                strcat(strAux,")");
                if(param1==param2&&invalido==0){
                        addNota(current,strAux);
                        return funcAux2->type;
                }
                printf("Line %d, column %d: Cannot find symbol %s%s\n",current->lin,(current->column)-1,current->token,strAux);
                //pseudo-tipo
                addNota(current,"undef");
                return "undef";
            
            }
        }
        funcAux2=funcAux2->next;
    }
    
    node* nodeAux=current->sibling;
    char strAux[1024]="\0";
    strcat(strAux,"(");
    while(nodeAux){
        char *tipo1=anotaStmtExpr(nodeAux,funcAux);
        if(strcmp(strAux,"(")==0){
            strcat(strAux,tipo1);
        }
        else{
                strcat(strAux,",");
                strcat(strAux,tipo1);
        }
        nodeAux=nodeAux->sibling;
    }
    strcat(strAux,")");
    printf("Line %d, column %d: Cannot find symbol %s%s\n",current->lin,(current->column)-1,current->token,strAux);
    //pseudo-tipo
    addNota(current,"undef");
    return "undef";
}
char* anotaId(node* current, list_func* funcAux){
    local_var *varAux=funcAux->vars;
        while(varAux){

            if(strcmp(varAux->name,current->token)==0){

                addNota(current,varAux->type);
                return varAux->type;
            }
            varAux=varAux->next;
        }
        params *parAux=funcAux->params;
        while(parAux){

            if(strcmp(parAux->name,current->token)==0){
                addNota(current,parAux->type);
                return parAux->type;
            }
            parAux=parAux->next;
        }
        list_func *funcAux2=head;
        while(funcAux2){
            if(!funcAux2->func){
                if(strcmp(funcAux2->name,current->token)==0){
                    addNota(current,funcAux2->type);
                    return funcAux2->type;
                }
            }
            
            funcAux2=funcAux2->next;
        }
        //pseudo-tipo
        addNota(current,"undef");
        return "undef";
}
void varExist(node* current, list_func* funcAux){
    if(strcmp("Id",current->type)!=0){
        return;
    }
    local_var *varAux=funcAux->vars;
        while(varAux){

            if(strcmp(varAux->name,current->token)==0){
                return ;
            }
            varAux=varAux->next;
        }
        params *parAux=funcAux->params;            
        while(parAux){

            if(strcmp(parAux->name,current->token)==0){

                return ;
            }
            parAux=parAux->next;
        }
        list_func *funcAux2=head;               
        while(funcAux2){
            if(!funcAux2->func){
                if(strcmp(funcAux2->name,current->token)==0){
                    
                    return;
                }
            }
            
            funcAux2=funcAux2->next;
        }
    
        printf("Line %d, column %d: Cannot find symbol %s\n",current->lin,(current->column)-1,current->token);
        
}
list_func* funcPointer(char* funcaoNome){   
    // POINTER PARA A FUNÇÃO EM QUESTÃO            
    struct list_func *funcAux =head;
    while(funcAux){
        if(funcAux->func){
            if(strcmp(funcAux->name,funcaoNome)==0){
                if(funcAux->declared==0){
                    funcAux->declared=1;
                    return funcAux;
                }
            return NULL;
        }

        }
        
        funcAux=funcAux->next;
    }
    return NULL;
}
list_func* addFunc(node* current){
     
        struct list_func *funcAux =head;

        char* funcName = (char *)malloc(sizeof( char)*100);                
        strcpy(funcName,current->son->son->token);

        char* funcType = (char *)malloc(sizeof( char)*100);            
        strcpy(funcType,current->son->son->sibling->type);
        funcType[0]=tolower(funcType[0]);

         if (varOrFunc(funcName,current->son->son,1)){                         
            return NULL;
        }


        if(!head){                                                    

            head=(struct list_func*)malloc(sizeof( list_func));
         
            if(strcmp(funcType,"funcParams")==0||strcmp(funcType,"FuncParams")==0){
                funcType="none";
            }

            head->params=NULL;
            head->func=1;
            head->declared=0;
            head->name=funcName;
            head->type=funcType;
            head->next=NULL;
            head->params=NULL;
            head->vars=NULL;

            addParam(current,head);                   
            return head;

        }
        else{

            while(funcAux->next){
            
                funcAux=funcAux->next;
            }
            funcAux->next=(struct list_func*)malloc(sizeof( list_func));
            funcAux=funcAux->next;

            
            if(strcmp(funcType,"funcParams")==0||strcmp(funcType,"FuncParams")==0){ 
                funcType="none";                                                   

            }

            funcAux->func=1;
            funcAux->declared=0;
            funcAux->name=funcName;
            funcAux->type=funcType;
            funcAux->next=NULL;
            funcAux->params=NULL;
            funcAux->vars=NULL;
            // PARAM ADD PODEM TER NOME DE GLOBAL VAR
            addParam(current,funcAux);                    

            return funcAux;
        }

        
}
void addGlobalVar(node* current){
    
        char* varName = (char *)malloc(sizeof( char)*100);              
        strcpy(varName,current->son->sibling->token);

        char* varType =(char *)malloc(sizeof( char)*100) ;            
        strcpy(varType,current->son->type);
        varType[0]=tolower(varType[0]);
        
        if (varOrFunc(varName,current->son->sibling,2)){                         
            return;
        }


        struct list_func *funcAux =head;
        if(!head){                                                  
            head=(struct list_func*)malloc(sizeof( list_func));
            head->func=0;
            head->name=varName;
            head->type=varType;
            head->next=NULL;
            head->params=NULL;
            head->vars=NULL;
            return;
        }

        while(funcAux->next){
            funcAux=funcAux->next;
        }
        funcAux->next=(struct list_func*)malloc(sizeof( list_func));
        funcAux=funcAux->next;

        funcAux->func=0;
        funcAux->name=varName;
        funcAux->type=varType;
        funcAux->next=NULL;
        funcAux->params=NULL;
        funcAux->vars=NULL;
        
        return;
}
void addParam(node* current,list_func * funcAux){
    node* nodeAux=current->son->son; 
    nodeAux=nodeAux->sibling;

    if(strcmp(nodeAux->type,"FuncParams")!=0&&strcmp(nodeAux->type,"funcParams")!=0){ 
        nodeAux=nodeAux->sibling;
    }

    if(!nodeAux->son){                                                                
        return;
    }
    nodeAux=nodeAux->son; 
    params* paramsAux=NULL;
    params* paramsHead=NULL;
    params* paramsAux2=paramsHead;
    int found=0;
    while(nodeAux){  
        found=0;
        paramsAux2=paramsHead;
        while(paramsAux2){
            
            if(strcmp(paramsAux2->name,nodeAux->son->sibling->token)==0){  
                found=1;
                printf("Line %d, column %d: Symbol %s already defined\n",nodeAux->son->sibling->lin,(nodeAux->son->sibling->column)-1,nodeAux->son->sibling->token);
               
            }
            paramsAux2=paramsAux2->next;
            
        }
        if(!found){
            if(!paramsAux){
            paramsAux = (struct params*)malloc(sizeof( params));
            paramsAux->next=NULL;
            paramsAux->name=(char *)malloc(sizeof( char)*100);
            strcpy(paramsAux->name,nodeAux->son->sibling->token);
            paramsAux->type=(char *)malloc(sizeof( char)*100);
            strcpy(paramsAux->type,nodeAux->son->type);
            paramsAux->type[0]=tolower(paramsAux->type[0]);
            paramsHead=paramsAux;                                   
            }
            else{

            paramsAux ->next = (struct params*)malloc(sizeof( params));
            paramsAux=paramsAux->next;
            paramsAux->next=NULL;
            paramsAux->name=(char *)malloc(sizeof( char)*100);
            strcpy(paramsAux->name,nodeAux->son->sibling->token);
            paramsAux->type=(char *)malloc(sizeof( char)*100);
            strcpy(paramsAux->type,nodeAux->son->type);
            paramsAux->type[0]=tolower(paramsAux->type[0]);

        }
        }
        
        
        nodeAux=nodeAux->sibling;
    }
    paramsAux2=paramsHead;
    funcAux->params=paramsHead;

}

int varOrFunc(char * name,node* current,int opcao){
    struct list_func *funcAux =head;
    while(funcAux){

        if(strcmp(funcAux->name,name)==0){
            if(opcao==1){
                printf("Line %d, column %d: Symbol %s already defined\n",current->lin,(current->column)-1,name);
                return 1;
            }
            else{
                printf("Line %d, column %d: Symbol %s already defined\n",current->lin,(current->column)-1,name);
                return 1;
            }
            
        }
        funcAux=funcAux->next;
    }
    return 0;
}
int usedVar(node* current,char *varName){
    if(!current){
        return 0;
    }
    if(strcmp(current->type,"Id")==0){
        if(strcmp(current->token,varName)==0){
            return 1;
        }
        else{
            return usedVar(current->son,varName) || usedVar(current->sibling,varName);
        }
    }
    else{
        return usedVar(current->son,varName) || usedVar(current->sibling,varName);
    }
    

}

char* anotaStmtExpr(node *current, list_func *funcAux){

    
    if(strcmp(current->type,"VarDecl")==0){
        return "null";
    }

    else if(strcmp(current->type,"IntLit")==0){

        // VERIFICAR SE É HEX OU OCTA
        if(current->token[0]=='0'){           
            if((current->token[1]=='x'||current->token[1]=='X')){   
                addNota(current,"int");
                return "int";
                
            }
            int i=1;

            while(current->token[i]!='\0'){   
                if((current->token[i]<'0'||current->token[i]>'7')){
                    printf("Line %d, column %d: Invalid octal constant: %s\n",current->lin,(current->column)-1,current->token);
                    addNota(current,"int");
                    return "int";
                }
                i++;
            }
        }
        addNota(current,"int");
        return "int";
    }

    else if(strcmp(current->type,"RealLit")==0){
        addNota(current,"float32");
        return "float32";
    }

    else if(strcmp(current->type,"StrLit")==0){
        addNota(current,"string");
        return "string";
    }

    else if(strcmp(current->type,"If")==0){
        char *tipo1=anotaStmtExpr(current->son,funcAux);
        
        if(strcmp(tipo1,"bool")!=0){
            printf("Line %d, column %d: Incompatible type %s in %s statement\n",current->son->lin,(current->son->column)-1,tipo1,"if");

        }
        
         // IF BLOCK
        anotaStmtExpr(current->son->sibling,funcAux);                
        anotaStmtExpr(current->son->sibling->sibling,funcAux);        

    
    }

    else if(strcmp(current->type,"For")==0){


        if(strcmp(current->son->type,"Block")==0){

            anotaStmtExpr(current->son,funcAux);
            return "null";
        }
        char *tipo1=anotaStmtExpr(current->son,funcAux);
        
        if(strcmp(tipo1,"bool")!=0){
            printf("Line %d, column %d: Incompatible type %s in %s statement\n",current->son->lin,(current->son->column)-1,tipo1,"for");
        }
        anotaStmtExpr(current->son->sibling,funcAux);
        
        return "null";
    
    }

    else if(strcmp(current->type,"Return")==0){
        char *tipo1=anotaStmtExpr(current->son,funcAux);
        if(strcmp(tipo1,funcAux->type)!=0){
            printf("Line %d, column %d: Incompatible type %s in %s statement\n",current->son->lin,(current->son->column)-1,tipo1,"return");
        }
        
        else{
            if(strcmp("none",funcAux->type)==0){
                printf("Line %d, column %d: Incompatible type %s in %s statement\n",current->lin,current->column,"none","return");
            }
        }
        
        return "null";
    }

    else if(strcmp(current->type,"Print")==0){
        anotaStmtExpr(current->son,funcAux);
        return "null";
    }
    else if(strcmp(current->type,"ParseArgs")==0){

        char *tipo1=anotaStmtExpr(current->son,funcAux);
        char *tipo2=anotaStmtExpr(current->son->sibling,funcAux);
        if(strcmp(tipo1,"int")!=0||strcmp(tipo2,"int")!=0){
            printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n",current->lin,(current->column)-1,"strconv.Atoi",tipo1,tipo2);
            //pseudo-tipo
            addNota(current,"undef");
            return "undef";
        }
        
        addNota(current,"int");
        return "int";
    }
  
    
    else if(strcmp(current->type,"Id")==0){
        varExist(current, funcAux);
        return anotaId(current, funcAux);
    
    }
    else if(strcmp(current->type,"Not")==0){
        char *tipo1=anotaStmtExpr(current->son,funcAux);
        if(strcmp("bool",tipo1)!=0){
            printf("Line %d, column %d: Operator %s cannot be applied to type %s\n",current->lin,(current->column)-1,"!",tipo1);
        }
        addNota(current,"bool");
        return "bool";
    }
    else if(strcmp(current->type,"Minus")==0||strcmp(current->type,"Plus")==0){
        char *tipo1=anotaStmtExpr(current->son,funcAux);
        if(strcmp("int",tipo1)==0){
            addNota(current,"int");
            return "int";
        }
        else if(strcmp("float32",tipo1)==0){
            addNota(current,"float32");
            return "float32";
        }
        else{
            if(strcmp(current->type,"Minus")==0){
                printf("Line %d, column %d: Operator %s cannot be applied to type %s\n",current->lin,(current->column)-1,"-",tipo1);
            }
            else{
                printf("Line %d, column %d: Operator %s cannot be applied to type %s\n",current->lin,(current->column)-1,"+",tipo1);
            }
            //pseudo-tipo
            addNota(current,"undef");
            return "undef";
        }
    }
    
    else if(strcmp(current->type,"Call")==0){
        char *tipo=anotaIdFuncao(current->son,funcAux);
        addNota(current,tipo);

        return tipo ;
    }
    
    else if(strcmp(current->type,"Assign")==0){

        char *tipo1=anotaStmtExpr(current->son,funcAux);
        char *tipo2=anotaStmtExpr(current->son->sibling,funcAux);

        //pseudo-tipo
        if(strcmp(tipo1,"undef")==0||strcmp(tipo2,"undef")==0){
            printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n",current->lin,(current->column)-1,"=",tipo1,tipo2);
            addNota(current,"undef");
            return tipo1;
        }

        if(strcmp(tipo1,tipo2)==0){
            addNota(current,tipo1);
            return tipo1;
        }   
        
        printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n",current->lin,(current->column)-1,"=",tipo1,tipo2);
        addNota(current,tipo1);
        return tipo1;
    
    }

    else if(strcmp(current->type,"Eq")==0||strcmp(current->type,"Lt")==0||strcmp(current->type,"Gt")==0||strcmp(current->type,"Ne")==0||strcmp(current->type,"Le")==0||strcmp(current->type,"Ge")==0){
        // COMPARAÇÕES RETORNAM BOOL : TRUE OU FALSE
        char *tipo1 =anotaStmtExpr(current->son, funcAux);
        char *tipo2 =anotaStmtExpr(current->son->sibling, funcAux);

        if(strcmp(tipo1,"bool")==0&&strcmp(tipo2,"bool")==0){ 
            if(strcmp(current->type,"Lt")==0){
                printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n",current->lin,(current->column)-1,"<",tipo1,tipo2);
            }
            else if(strcmp(current->type,"Gt")==0){
                printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n",current->lin,(current->column)-1,">",tipo1,tipo2);
            }
            else if(strcmp(current->type,"Le")==0){
                printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n",current->lin,(current->column)-1,"<=",tipo1,tipo2);
            }
            else if(strcmp(current->type,"Ge")==0){
                printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n",current->lin,(current->column)-1,">=",tipo1,tipo2);
            }
            else{
                addNota(current,tipo1);
            }
            addNota(current,tipo1);
        
        }

        // COMPARAÇÕES APENAS COM O MESMO TIPO DE VARIÁVEL
        else if(strcmp(tipo1,"int")==0&&strcmp(tipo2,"int")==0){ 
            addNota(current,"bool");

        }
        
        else if(strcmp(tipo1,"float32")==0&&strcmp(tipo2,"float32")==0){ 
            addNota(current,"bool");

        }
        else if(strcmp(tipo1,"string")==0&&strcmp(tipo2,"string")==0){
            addNota(current,"bool");

        }
        else{
            if(strcmp(current->type,"Eq")==0){
                printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n",current->lin,(current->column)-1,"==",tipo1,tipo2);
            }
            else if(strcmp(current->type,"Lt")==0){
                printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n",current->lin,(current->column)-1,"<",tipo1,tipo2);
            }
            else if(strcmp(current->type,"Gt")==0){
                printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n",current->lin,(current->column)-1,">",tipo1,tipo2);
            }
            else if(strcmp(current->type,"Ne")==0){
                printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n",current->lin,(current->column)-1,"!=",tipo1,tipo2);
            }
            else if(strcmp(current->type,"Le")==0){
                printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n",current->lin,(current->column)-1,"<=",tipo1,tipo2);
            }
            else if(strcmp(current->type,"Ge")==0){
                printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n",current->lin,(current->column)-1,">=",tipo1,tipo2);
            }
            
            addNota(current,"bool");
  
        }
                
        
        return "bool";

    }
    else if(strcmp(current->type,"Add")==0||strcmp(current->type,"Sub")==0||strcmp(current->type,"Mul")==0||strcmp(current->type,"Div")==0||strcmp(current->type,"Mod")==0){
        char *tipo1 =anotaStmtExpr(current->son, funcAux);
        char *tipo2 =anotaStmtExpr(current->son->sibling, funcAux);
    
        if((strcmp(tipo1,"bool")==0&&strcmp(tipo2,"bool")==0)||(strcmp(tipo1,"undef")==0&&strcmp(tipo2,"undef")==0)){           // booleanos nao podem usar contas matematicas
            if(strcmp(current->type,"Add")==0){
                printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n",current->lin,(current->column)-1,"+",tipo1,tipo2);
            }
            else if(strcmp(current->type,"Sub")==0){
                printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n",current->lin,(current->column)-1,"-",tipo1,tipo2);
            }
            else if(strcmp(current->type,"Mul")==0){
                printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n",current->lin,(current->column)-1,"*",tipo1,tipo2);
            }
            else if(strcmp(current->type,"Div")==0){
                printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n",current->lin,(current->column)-1,"/",tipo1,tipo2);
            }
            else if(strcmp(current->type,"Mod")==0){
                printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n",current->lin,(current->column)-1,"%",tipo1,tipo2);
            }
            addNota(current,tipo1);
            //pseudo-tipo
            return "undef";
        
        }
        else if(strcmp(tipo1,tipo2)!=0){
            if(strcmp(current->type,"Add")==0){
                printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n",current->lin,(current->column)-1,"+",tipo1,tipo2);
            }
            else if(strcmp(current->type,"Sub")==0){
                printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n",current->lin,(current->column)-1,"-",tipo1,tipo2);
            }
            else if(strcmp(current->type,"Mul")==0){
                printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n",current->lin,(current->column)-1,"*",tipo1,tipo2);
            }
            else if(strcmp(current->type,"Div")==0){
                printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n",current->lin,(current->column)-1,"/",tipo1,tipo2);
            }
            else if(strcmp(current->type,"Mod")==0){
                printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n",current->lin,(current->column)-1,"%",tipo1,tipo2);
            }
            //pseudo-tipo
            addNota(current,"undef");
            return "undef";
        
        }
        else{
            if(strcmp(tipo1,"float32")==0){
                if(strcmp(current->type,"Mod")==0){
                    printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n",current->lin,(current->column)-1,"%",tipo1,tipo2);
                    //pseudo-tipo
                    addNota(current,"undef");
                    return "undef";
                }
                addNota(current,"float32");

                return "float32";
            }
            if(strcmp(tipo1,"string")==0){

                if(strcmp(current->type,"Add")==0){
                    addNota(current,"string");
                    return "string";
                }
                else if(strcmp(current->type,"Sub")==0){
                    printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n",current->lin,(current->column)-1,"-",tipo1,tipo2);
                    //pseudo-tipo
                    addNota(current,"undef");
                    return "undef";
                }
                else if(strcmp(current->type,"Mul")==0){
                    printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n",current->lin,(current->column)-1,"*",tipo1,tipo2);
                    //pseudo-tipo
                    addNota(current,"undef");
                    return "undef";
                }
                else if(strcmp(current->type,"Div")==0){
                    printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n",current->lin,(current->column)-1,"/",tipo1,tipo2);
                    //pseudo-tipo
                    addNota(current,"undef");
                    return "undef";
                }
                else if(strcmp(current->type,"Mod")==0){
                    printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n",current->lin,(current->column)-1,"%",tipo1,tipo2);
                    //pseudo-tipo
                    addNota(current,"undef");
                    return "undef";
                }

            }
            addNota(current,tipo1);
            return tipo1;
        }
        return tipo1;
    }
    else if(strcmp(current->type,"And")==0||strcmp(current->type,"Or")==0){
        char *tipo1 =anotaStmtExpr(current->son, funcAux);
        char *tipo2 =anotaStmtExpr(current->son->sibling, funcAux);

        if(strcmp(tipo1,"bool")==0&&strcmp(tipo2,"bool")==0){
            addNota(current,tipo1);
            return "bool";
        
        }
        else {
            if(strcmp(current->type,"And")==0){
                printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n",current->lin,(current->column)-1,"&&",tipo1,tipo2);
            }
            else if(strcmp(current->type,"Or")==0){
                printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n",current->lin,(current->column)-1,"||",tipo1,tipo2);
            }

        
        }
        addNota(current,"bool");
        return "bool";

    }
    else if(strcmp(current->type,"Block")==0){
        
        
        if(current->son){
            
            node *nodeAux = current->son;
            
            while(nodeAux){
                
                anotaStmtExpr(nodeAux, funcAux);
                nodeAux=nodeAux->sibling;
            }
        }
            
    }
    return "null";
}

