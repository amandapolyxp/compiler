/* Amanda Menezes 2017124788 */
/* Pedro Meira 2019223208*/
%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "fast.h"
    #include "y.tab.h"

    extern int yylex(void);
    int yyparse(void);
    extern int lin;
    extern int chars;
    extern char* yytext;
    node* myprogram = NULL;
    node* aux= NULL;
    node* auxblock=NULL;
    char buffer[128];
    extern void yyerror (char *s);
    extern void printTree(node *current, int depth);
    extern void criarTabelas();

%}

%union{
    char* token;
    struct node* n;
}

%token PACKAGE VAR COMMA INT FLOAT32 BOOL STRING FUNC LBRACE RBRACE SEMICOLON IF ELSE FOR RETURN PRINT BLANKID PARSEINT CMDARGS LSQ RSQ EQ NE ASSIGN OR AND GE GT LE LT PLUS MINUS STAR DIV MOD NOT  RPAR LPAR

%token<token>ID
%token<token>INTLIT
%token<token>REALLIT
%token<token>STRI
%token<token>RESERVED

%right ASSIGN

%left OR
%left AND
%left EQ NOT LE GE GT LT NE
%left PLUS MINUS
%left STAR DIV MOD 
%left UNARY

%nonassoc LPAR RPAR

%type<n>auxState
%type<n>auxVarSpec
%type<n>auxExpr
%type<n>auxParameters
%type<n>Program
%type<n>Declarations
%type<n>VarDeclaration
%type<n>VarSpec
%type<n>Type
%type<n>FuncDeclaration
%type<n>Parameters
%type<n>FuncBody
%type<n>VarsAndStatements
%type<n>Statement
%type<n>ParseArgs
%type<n>FuncInvocation
%type<n>Expr
%type<n>auxId
%type<n>auxDeclarations
%type<n>auxState2

%%  
    Program: PACKAGE ID SEMICOLON Declarations                                          {myprogram=createNode("Program",NULL, lin, chars);addSon(myprogram,$4);}
    ;

    Declarations:                                                                       {$$=createNode("NULL",NULL, lin, chars);}
    | auxDeclarations                                                                   {$$ = $1;}
    ;

    auxDeclarations: auxDeclarations FuncDeclaration SEMICOLON                          {$$ = $1;addSibling($1,$2);}
    | auxDeclarations VarDeclaration SEMICOLON                                          {$$ = $1;addSibling($1,$2);}
    | VarDeclaration SEMICOLON                                                          {$$ = $1;}
    | FuncDeclaration SEMICOLON                                                         {$$ = $1;}
    ;
            
    VarDeclaration: VAR VarSpec                                                         {$$=$2;}
    | VAR LPAR VarSpec SEMICOLON RPAR                                                   {$$=$3;}
    ;
    

    VarSpec: auxId auxVarSpec Type                                                      {$$=createNode("VarDecl",NULL, lin, chars);addSon($$,$3);addSibling($3,$1);addSibling($$,$2);                                                                                       auxblock=$$->sibling;
                                                                                            while(auxblock!=NULL&&strcmp(auxblock->son->type,"faketype")==0){
                                                                                                strcpy(auxblock->son->type,$3->type);
                                                                                                auxblock=auxblock->sibling;}}
    | auxId Type                                                                          {$$=createNode("VarDecl",NULL, lin, chars);
                                                                                        addSon($$,$2);
                                                                                        addSibling($2,$1);
                                                                                        }  
    ;

    auxVarSpec: COMMA auxId                                                             {$$=createNode("VarDecl",NULL, lin, chars);
                                                                                                            aux=createNode("faketype",NULL, lin, chars);
                                                                                                            addSon($$,aux);
                                                                                                            addSibling(aux,$2);}
    | COMMA auxId auxVarSpec                                                            {$$=createNode("VarDecl",NULL, lin, chars);aux=createNode("faketype",NULL, lin, chars);addSibling($$,$3);
                                                                                        addSon($$,aux);
                                                                                        addSibling(aux,$2);}
    ;

    Type: INT                                                                           {$$=createNode("Int",NULL, lin, chars);}
    | FLOAT32                                                                           {$$=createNode("Float32",NULL, lin, chars);}
    | BOOL                                                                              {$$=createNode("Bool",NULL, lin, chars);}
    | STRING                                                                            {$$=createNode("String",NULL, lin, chars);}
    ;

    FuncDeclaration: FUNC auxId LPAR Parameters RPAR Type FuncBody                      {$$=createNode("FuncDecl",NULL, lin, chars);aux=createNode("FuncHeader",NULL, lin, chars);
                                                                                        addSon($$,aux);
                                                                                        addSibling(aux,$7);
                                                                                        addSon(aux,$2);
                                                                                        addSibling($6,$4);
                                                                                        addSibling($2,$6);}
    | FUNC auxId LPAR RPAR Type FuncBody                                                {$$=createNode("FuncDecl",NULL, lin, chars);aux=createNode("FuncHeader",NULL, lin, chars);
                                                                                        addSon($$,aux);
                                                                                        addSibling(aux,$6);
                                                                                        addSon(aux,$2);
                                                                                        addSibling($2,$5);
                                                                                        addSibling($5,createNode("FuncParams",NULL, lin, chars));}
    | FUNC auxId LPAR Parameters RPAR FuncBody                                          {$$=createNode("FuncDecl",NULL, lin, chars);aux=createNode("FuncHeader",NULL, lin, chars);
                                                                                        addSon($$,aux);
                                                                                        addSibling(aux,$6);
                                                                                        addSon(aux,$2);
                                                                                        addSibling($2,$4);
                                                                                        }
    | FUNC auxId LPAR RPAR FuncBody                                                     {$$=createNode("FuncDecl",NULL, lin, chars);aux=createNode("FuncHeader",NULL, lin, chars);
                                                                                        addSon($$,aux);
                                                                                        addSon(aux,$2);
                                                                                        addSibling($2,createNode("FuncParams",NULL, lin, chars));
                                                                                        addSibling(aux,$5);}
    ;

    Parameters: auxParameters                                                           {$$=createNode("FuncParams",NULL, lin, chars);
                                                                                        addSon($$,$1);}
    ;

    auxParameters: auxId Type                                                           {$$=createNode("ParamDecl",NULL, lin, chars);
                                                                                        addSon($$,$2);
                                                                                        addSibling($2,$1);}
    | auxId Type COMMA auxParameters                                                    {$$=createNode("ParamDecl",NULL, lin, chars);
                                                                                        addSon($$,$2);
                                                                                        addSibling($2,$1);
                                                                                        addSibling($$,$4);}
    ;
          
    FuncBody: LBRACE VarsAndStatements RBRACE                                           {$$=createNode("FuncBody",NULL, lin, chars);
                                                                                        addSon($$,$2);}
    ;

    VarsAndStatements :                                                                 {$$=createNode("NULL",NULL, lin, chars);}
    | VarsAndStatements Statement SEMICOLON                                             {$$=$1;addSibling($1,$2);}
    | VarsAndStatements SEMICOLON                                                       {$$=$1;}
    | VarsAndStatements VarDeclaration SEMICOLON                                        {$$=$1;addSibling($1,$2);}
    ;

    Statement: error                                                                    {$$=createNode("error",NULL, lin, chars);}
    | auxId ASSIGN Expr                                                                 {$$=createNode("Assign",NULL, lin, chars);addSon($$,$1);addSibling($1,$3);}
    | LBRACE auxState RBRACE                                                            {int nEmptyStat=0;auxblock=$2;
                                                                                        while(auxblock!=NULL){
                                                                                            if(strcmp(auxblock->type,"NULL")!=0){
                                                                                                nEmptyStat++;
                                                                                            }
                                                                                            auxblock=auxblock->sibling;
                                                                                        }
                                                                                        if(nEmptyStat<2){
                                                                                            $$ = $2;
                                                                                        }
                                                                                        else{
                                                                                            $$=createNode("Block",NULL, lin, chars);
                                                                                            addSon($$,$2);
                                                                                        }}
    | LBRACE RBRACE                                                                     {$$ = createNode("NULL", NULL, lin, chars);}
    | IF Expr LBRACE auxState RBRACE ELSE LBRACE auxState RBRACE                        {$$=createNode("If",NULL, lin, chars);
                                                                                        addSon($$,$2);aux=createNode("Block",NULL, lin, chars);
                                                                                        auxblock=createNode("Block",NULL, lin, chars);
                                                                                        addSibling($2,aux);
                                                                                        addSon(aux,$4);
                                                                                        addSibling(aux,auxblock);
                                                                                        addSon(auxblock,$8);}
    | IF Expr LBRACE RBRACE ELSE LBRACE RBRACE                                          {$$ = createNode("If", NULL, lin, chars);
                                                                                        addSon($$,$2);
                                                                                        aux=createNode("Block",NULL, lin, chars);
                                                                                        addSibling($2,aux);
                                                                                        addSibling(aux,createNode("Block",NULL, lin, chars));
                                                                                        }
    | IF Expr LBRACE  RBRACE ELSE LBRACE auxState RBRACE                                {$$ =  createNode("If",NULL, lin, chars);
                                                                                        addSon($$,$2);
                                                                                        aux=createNode("Block",NULL, lin, chars);
                                                                                        auxblock=createNode("Block",NULL, lin, chars);
                                                                                        addSibling($2,aux);
                                                                                        addSibling(aux,auxblock);
                                                                                        addSon(auxblock,$7);}
    | IF Expr LBRACE auxState RBRACE ELSE LBRACE RBRACE                                 {$$ =  createNode("If",NULL, lin, chars);
                                                                                        addSon($$,$2);
                                                                                        aux=createNode("Block",NULL, lin, chars);
                                                                                        addSibling($2,aux);
                                                                                        addSon(aux,$4);
                                                                                        addSibling(aux,createNode("Block",NULL, lin, chars));}
    | IF Expr LBRACE auxState RBRACE                                                    {$$=createNode("If",NULL, lin, chars);
                                                                                        addSon($$,$2);aux=createNode("Block",NULL,lin, chars);
                                                                                        addSibling($2,aux);
                                                                                        addSon(aux,$4);
                                                                                        addSibling(aux,createNode("Block",NULL, lin, chars));}
    | IF Expr LBRACE RBRACE                                                             {$$ = createNode("If", NULL, lin, chars);
                                                                                        addSon($$, $2); aux = createNode("Block",NULL, lin, chars);
                                                                                        addSibling($2, aux);
                                                                                        addSibling(aux,createNode("Block",NULL, lin, chars));
                                                                                        }
    | FOR Expr LBRACE auxState RBRACE                                                   {$$=createNode("For",NULL, lin, chars);addSon($$,$2);aux=createNode("Block",NULL, lin, chars);
                                                                                        addSibling($2,aux);
                                                                                        addSon(aux,$4);}
    | FOR LBRACE auxState RBRACE                                                        {$$=createNode("For",NULL, lin, chars);aux=createNode("Block",NULL, lin, chars);addSon($$,aux);
                                                                                        addSon(aux,$3);}
    | FOR LBRACE RBRACE                                                                 {$$ =  createNode("For",NULL, lin, chars);
                                                                                        addSon($$,createNode("Block",NULL, lin, chars));
                                                                                        }
    | FOR Expr LBRACE RBRACE                                                            {$$ =  createNode("For",NULL, lin, chars);
                                                                                        addSon($$,$2);
                                                                                        addSibling($2,createNode("Block",NULL, lin, chars));}
    | RETURN Expr                                                                       {$$=createNode("Return",NULL, lin, chars);addSon($$,$2);}
    | RETURN                                                                            {$$=createNode("Return",NULL, lin, chars);}
    | FuncInvocation                                                                    {$$=createNode("Call",NULL, lin, chars);addSon($$,$1);}
    | ParseArgs                                                                         {$$=$1;}
    | PRINT LPAR auxState2 RPAR                                                         {$$=createNode("Print",NULL, lin, chars);addSon($$,$3);}
    ;
    
    auxState: auxState Statement SEMICOLON                                              {$$=$1;addSibling($1,$2);}
    | Statement SEMICOLON                                                               {$$=$1;}
    ;

    auxState2: Expr                                                                     {$$=$1;}
    | STRI                                                                              {$$ = createNode("StrLit", $1, lin, chars);}

    ParseArgs: auxId COMMA BLANKID ASSIGN PARSEINT LPAR error RPAR                      {$$=createNode("ParseArgs",NULL, lin, chars);
                                                                                        addSon($$, $1);
                                                                                        addSibling($1, createNode("error", NULL, lin, chars));}
    | auxId COMMA BLANKID ASSIGN PARSEINT LPAR CMDARGS LSQ Expr RSQ RPAR                {$$=createNode("ParseArgs",NULL, lin, chars);
                                                                                        addSon($$,$1);
                                                                                        addSibling($1,$9);}
    ;

    FuncInvocation: auxId LPAR error RPAR                                                  {$$=$1; addSibling($1, createNode("error",NULL, lin, chars));}
    | auxId LPAR Expr auxExpr RPAR                                                         {$$=$1;addSibling($1,$3);addSibling($3,$4);}
    | auxId LPAR RPAR                                                                      {$$=$1;}
    | auxId LPAR Expr RPAR                                                                 {$$=$1; addSibling($1, $3);}
    ;

    auxId: ID                                                                              {$$=createNode("Id",yylval.token, lin, chars);}
    ;
              
    auxExpr: auxExpr COMMA Expr                                                            {$$=$1;addSibling($1,$3);}
    | COMMA Expr                                                                           {$$ = $2;}
    ;
   
   Expr: Expr OR Expr                                                                   {$$=createNode("Or",NULL, lin, chars);addSon($$,$1);addSibling($1,$3);}
    | Expr AND Expr                                                                     {$$=createNode("And",NULL, lin, chars);addSon($$,$1);addSibling($1,$3);}
    | Expr LT Expr                                                                      {$$=createNode("Lt",NULL, lin, chars);addSon($$,$1);addSibling($1,$3);}
    | Expr GT Expr                                                                      {$$=createNode("Gt",NULL, lin, chars);addSon($$,$1);addSibling($1,$3);}
    | Expr EQ Expr                                                                      {$$=createNode("Eq",NULL, lin, chars);addSon($$,$1);addSibling($1,$3);}
    | Expr NE Expr                                                                      {$$=createNode("Ne",NULL, lin, chars);addSon($$,$1);addSibling($1,$3);}
    | Expr LE Expr                                                                      {$$=createNode("Le",NULL, lin, chars);addSon($$,$1);addSibling($1,$3);}
    | Expr GE Expr                                                                      {$$=createNode("Ge",NULL, lin, chars);addSon($$,$1);addSibling($1,$3);}
    | Expr PLUS Expr                                                                    {$$=createNode("Add",NULL, lin, chars);addSon($$,$1);addSibling($1,$3);}
    | Expr MINUS Expr                                                                   {$$=createNode("Sub",NULL, lin, chars);addSon($$,$1);addSibling($1,$3);}
    | Expr STAR Expr                                                                    {$$=createNode("Mul",NULL, lin, chars);addSon($$,$1);addSibling($1,$3);}
    | Expr DIV Expr                                                                     {$$=createNode("Div",NULL, lin, chars);addSon($$,$1);addSibling($1,$3);}
    | Expr MOD Expr                                                                     {$$=createNode("Mod",NULL, lin, chars);addSon($$,$1);addSibling($1,$3);}
    | NOT Expr                                                                          {$$=createNode("Not",NULL, lin, chars);addSon($$,$2);}
    | MINUS Expr                           %prec UNARY                                  {$$=createNode("Minus",NULL, lin, chars);addSon($$,$2);}
    | PLUS Expr                            %prec UNARY                                  {$$=createNode("Plus",NULL, lin, chars);addSon($$,$2);}
    | LPAR error RPAR                                                                   {$$=createNode("error",NULL, lin, chars);}
    | INTLIT                                                                            {$$=createNode("IntLit",$1, lin, chars);}
    | REALLIT                                                                           {$$=createNode("RealLit",$1, lin, chars);}
    | auxId                                                                             {$$=$1;}
    | FuncInvocation                                                                    {$$=createNode("Call",NULL, lin, chars);addSon($$,$1);}
    | LPAR Expr RPAR                                                                    {$$=$2;}
    ;
%%


