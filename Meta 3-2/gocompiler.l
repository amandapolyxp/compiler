/* Amanda Menezes 2017124788 */
/* Pedro Meira 2019223208 */

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symtab.h"
#include "y.tab.h"

    int lin = 1; // initialize to 1
    int chars = 1, str_col = 1, com_col = 1, com_lin = 1, oct_col = 1, prev_char = 0;
    char * token_type = "ILLEGAL";
    int eol = 0;
    int errorflag = 0;
    int strlit = 0;
    int strlit_start = 1;
    int token_status = 1;
    int toSend = -1; //Command Arg
    int pCol = 0;
    int semantics = -1; // ast após semantics
    extern void yyerror (char *s);
    extern int yylex();
    extern node* myprogram;
    extern void printTree(node *current, int depth);
    void p_error(char *message, int tok, int col);
    void strError(char* message, char* yytext, int yyleng, int l, int c);
    void ret_print(char *token_type);
%}

%x COMMENT STRI_S

alpha               [a-zA-Z]
alphaID             [\_a-zA-Z]
digit               [0-9]
intn                [1-9]{digit}*
octDigit            [0-7]
hexDigit            [0-9a-fA-F]
alnum               {alpha}|{digit}
spc                 (" "|\t|\f)
escape              (\\n|\\f|\\r|\\t|\t|\\\\|\\\")
newline             (\n|\r|\r\n)
aspa                \"
preOctal            "0"
preHexa             "0x"|"0X"
exp                 "e"|"E"
octa                {preOctal}{octDigit}*
octaErr             {preOctal}(("8"|"9")+|{octDigit}*)+
hexa                {preHexa}{hexDigit}+
REALLIT             {digit}+"."{digit}*(("e"|"E")("+"|"-")?{digit}+)?|{digit}+("e"|"E")("+"|"-")?{digit}+|"."{digit}+(("e"|"E")("+"|"-")?{digit}+)?
ID                  {alphaID}({digit}|{alphaID})*
INTLIT              ({intn}|{hexa}|{octa})
STRLIT              \"([^\n\r\\\"]|{escape})*\"

PACKAGE             "package"
RETURN              "return"
ELSE                "else"
FOR                 "for"
IF                  "if"
VAR                 "var"
INT                 "int"
FLOAT32             "float32"
BOOL                "bool"
STRING              "string"
PRINT               "fmt.Println"
PARSEINT            "strconv.Atoi"
FUNC                "func"
CMDARGS             "os.Args"

WHILE               "while"
BREAK               "break"
DEFAULT             "default"
INTERFACE           "interface"
SELECT              "select"
CASE                "case"
DEFER               "defer"
GO                  "go"
MAP                 "map"
STRUCT              "struct"
CHAN                "chan"
GOTO                "goto"
SWITCH              "switch"
CONST               "const"
FALLTHROUGH         "fallthrough"
RANGE               "range"
TYPE                "type"
VOID                "void"
IMPORT              "import"
CONTINUE            "continue"

RESERVED            {WHILE}|{BREAK}|{DEFAULT}|{INTERFACE}|{SELECT}|{CASE}|{DEFER}|{GO}|{MAP}|{STRUCT}|{CHAN}|{GOTO}|{SWITCH}|{CONST}|{FALLTHROUGH}|{RANGE}|{TYPE}|{VOID}|{IMPORT}|{CONTINUE}

SEMICOLON           ";"
COMMA               ","
BLANKID             "_"
ASSIGN              "="
STAR                "*"
DIV                 "/"
MINUS               "-"
PLUS                "\+"
EQ                  "=="
GE                  ">="
GT                  ">"
LBRACE              "{"
LE                  "<="
LPAR                "("
LSQ                 "["
LT                  "<"
MOD                 "%"
NE                  "!="
NOT                 "!"
AND                 "&&"
OR                  "||"
RBRACE              "}"
RPAR                ")"
RSQ                 "]"
INC                 "++"
DEC                 "--"


%%

"//".*                                  {;}

"/*"                                    {BEGIN(COMMENT); com_col = chars++; com_lin = lin; chars++;}
\"                                      {str_col = chars; chars++; BEGIN STRI_S;}

<COMMENT>"*/"                           {BEGIN 0; chars += 2;}
<COMMENT>[^\n]	                        {chars++;}
<COMMENT>"\n"                           {++lin; chars = 1; }
<COMMENT><<EOF>>                        {BEGIN 0; printf("Line %d, column %d: unterminated comment\n", com_lin, com_col);}

<STRI_S>\"                              { eol = 1; if(toSend == 0) printf("STRLIT(%s)\n",yytext); chars+=yyleng; BEGIN 0;}
<STRI_S>{newline}                       { BEGIN 0; printf("Line %d, column %d: unterminated string literal\n", lin, str_col); chars = 1; lin++;}
<STRI_S>(escape)|[^\\\r\n\"]            { chars+=yyleng;} 
<STRI_S>\\[^\n\r\"]|\\|\f|\t            { printf("Line %d, column %d: invalid escape sequence (%s)\n", lin, chars, yytext); chars+=yyleng;}
<STRI_S><<EOF>>                         { BEGIN 0; printf("Line %d, column %d: unterminated string literal\n", lin, str_col);}

{STRLIT}                                { chars += yyleng;eol = 1; yylval.token = (char*)strdup(yytext); if(toSend == 1) return STRI; printf("STRLIT(%s)\n",yytext);}
{REALLIT}                               { chars += yyleng;eol = 1;  yylval.token = yytext; if(toSend == 1) return REALLIT; printf("INTLIT(%s)\n", yytext);}
{INTLIT}                                { chars += yyleng;eol = 1;  yylval.token = yytext; if(toSend == 1) return INTLIT; printf("INTLIT(%s)\n", yytext);}
{octaErr}                               { oct_col = chars;p_error("invalid octal constant", 1, oct_col); eol = 0;chars+=yyleng;}
{SEMICOLON}                             { chars += yyleng;eol = 0;  if(toSend == 1) return SEMICOLON; printf("SEMICOLON\n");}
{COMMA}                                 { chars += yyleng;eol = 0;  if(toSend == 1) return COMMA; printf("COMMA\n");}
{BLANKID}                               { chars += yyleng;eol = 0;  if(toSend == 1) return BLANKID; printf("BLANKID\n");}
{ASSIGN}                                { chars += yyleng;eol = 0;  if(toSend == 1) return ASSIGN; printf("ASSIGN\n");}
{STAR}                                  { chars += yyleng;eol = 0;  if(toSend == 1) return STAR; printf("STAR\n");}
{DIV}                                   { chars += yyleng;eol = 0;  if(toSend == 1) return DIV; printf("DIV\n");}
{MINUS}                                 { chars += yyleng;eol = 0;  if(toSend == 1) return MINUS; printf("MINUS\n");}
{PLUS}                                  { chars += yyleng;eol = 0;  if(toSend == 1) return PLUS; printf("PLUS\n");}
{EQ}                                    { chars += yyleng;eol = 0;  if(toSend == 1) return EQ; printf("EQ\n");}
{GE}                                    { chars += yyleng;eol = 0;  if(toSend == 1) return GE; printf("GE\n");}
{GT}                                    { chars += yyleng;eol = 0;  if(toSend == 1) return GT; printf("GT\n");}
{LBRACE}                                { chars += yyleng;eol = 0;  if(toSend == 1) return LBRACE; printf("LBRACE\n");}
{LE}                                    { chars += yyleng;eol = 0;  if(toSend == 1) return LE; printf("LE\n");}
{LPAR}                                  { chars += yyleng;eol = 0;  if(toSend == 1) return LPAR; printf("LPAR\n");}
{LSQ}                                   { chars += yyleng;eol = 0;  if(toSend == 1) return LSQ; printf("LSQ\n");}
{LT}                                    { chars += yyleng;eol = 0;  if(toSend == 1) return LT; printf("LT\n");}
{MOD}                                   { chars += yyleng;eol = 0;  if(toSend == 1) return MOD; printf("MOD\n");}
{NE}                                    { chars += yyleng;eol = 0;  if(toSend == 1) return NE; printf("NE\n");}
{NOT}                                   { chars += yyleng;eol = 0;  if(toSend == 1) return NOT; printf("NOT\n");}
{AND}                                   { chars += yyleng;eol = 0;  if(toSend == 1) return AND; printf("AND\n");}
{OR}                                    { chars += yyleng;eol = 0;  if(toSend == 1) return OR; printf("OR\n");}
{RBRACE}                                { chars += yyleng;eol = 1;  if(toSend == 1) return RBRACE; printf("RBRACE\n");}
{RPAR}                                  { chars += yyleng;eol = 1;  if(toSend == 1) return RPAR; printf("RPAR\n");}
{RSQ}                                   { chars += yyleng;eol = 1;  if(toSend == 1) return RSQ; printf("RSQ\n");}
{PACKAGE}                               { chars += yyleng;eol = 0;  if(toSend == 1) return PACKAGE; printf("PACKAGE\n");}
{RETURN}                                { chars += yyleng;eol = 1;  if(toSend == 1) return RETURN; printf("RETURN\n");}
{ELSE}                                  { chars += yyleng;eol = 0;  if(toSend == 1) return ELSE; printf("ELSE\n");}
{FOR}                                   { chars += yyleng;eol = 0;  if(toSend == 1) return FOR; printf("FOR\n");}
{INT}                                   { chars += yyleng;eol = 0;  if(toSend == 1) return INT; printf("INT\n");}
{INC}                                   { chars += yyleng;eol = 0;  if(toSend == 1) return INT; printf("INC\n");}
{DEC}                                   { chars += yyleng;eol = 0;  if(toSend == 1) return INT; printf("DEC\n");}

{IF}                                    { chars += yyleng;eol = 0;  if(toSend == 1) return IF; printf("IF\n");}
{VAR}                                   { chars += yyleng;eol = 0;  if(toSend == 1) return VAR; printf("VAR\n");}
{FLOAT32}                               { chars += yyleng;eol = 0;  if(toSend == 1) return FLOAT32; printf("FLOAT32\n");}
{BOOL}                                  { chars += yyleng;eol = 0;  if(toSend == 1) return BOOL; printf("BOOL\n");}
{STRING}                                { chars += yyleng;eol = 0;  if(toSend == 1) return STRING; printf("STRING\n");}
{PRINT}                                 { chars += yyleng;eol = 0;  if(toSend == 1) return PRINT; printf("PRINT\n");}
{PARSEINT}                              { chars += yyleng;eol = 0;  if(toSend == 1) return PARSEINT; printf("PARSEINT\n");}
{FUNC}                                  { chars += yyleng;eol = 0;  if(toSend == 1) return FUNC; printf("FUNC\n");}
{CMDARGS}                               { chars += yyleng;eol = 0;  if(toSend == 1) return CMDARGS; printf("CMDARGS\n");}

{RESERVED}                             { chars += yyleng;eol = 0;  if(toSend == 1) return RESERVED; printf("RESERVED\n");}

{newline}                              { ++lin; pCol = chars; chars = 1; if(eol == 1){eol = 0; if(toSend == 1){yylval.token = (char*) strdup(yytext); return SEMICOLON;} printf("SEMICOLON\n");}}

{spc}                                  {++chars;}
{ID}                                   { chars += yyleng;eol = 1;yylval.token = yytext;if(toSend == 1) return ID; printf("ID(%s)\n", yytext);}

<<EOF>>                                { if(eol == 1){
                                            eol = 0; 
                                            if(toSend == 1) 
                                                return SEMICOLON; 
                                            printf("SEMICOLON\n");
                                            } 
                                            yyterminate();}
.                                      { if(toSend == 0) ret_print("ILLEGAL"); chars += yyleng;eol = 0;}

%%
    
void ret_print(char *token_type){
    p_error("illegal character", 1, chars);
}

void p_error(char *message, int tok, int col){
    int size = yyleng;
    printf("Line %d, column %d: %s", lin, col, message);
    if(tok == 1){
        printf(" (");
        for(int i = 0; i < yyleng; i++){
            if(yytext[i] == '\n'){
                size--;
            }
        }
        for (int i = 0 ; i < size; i++){
                printf("%c",yytext[i]);
        }
        printf(")");
    }
    printf("\n");
}
    
void strError(char* message, char* yytext, int yyleng, int l, int c)
{
    if (yytext[0] != '\0')
        printf("Line %d, column %d: %s (%s)\n", l, c, message, yytext);
    else
        printf("Line %d, column %d: %s\n", l, c, message);
    chars += yyleng;
}

    
void yyerror (char *s) {

    errorflag=1;
    
    int c = chars - yyleng;
    if(c == 0){
        c = 1;
    }
    
    if(strcmp(yytext, "\n") == 0){
        printf("Line %d, column %d: %s: \n\n", lin - 1, pCol,s);
    } else{
        printf ("Line %d, column %d: %s: %s\n", lin, (int)(c), s, yytext);
    }
}

int main(int argc, char *argv[]){
    if(argc == 2){
        if(strcmp(argv[1], "-l") == 0){
            toSend = 0; 
            yylex();
        }
        if(strcmp(argv[1], "-t") == 0){
            toSend = 1;
            yyparse();
            if(!errorflag){
                printTree(myprogram,0);
            }
        }
        if(strcmp(argv[1], "-s") == 0){
            toSend = 1;
            semantics = 1;
            // initialize symbol table
            yyparse();
            if(!errorflag){
                criaTabelas(myprogram);
                printTabelaFuncoes();
                printTree(myprogram,0);
            }
        }
        
    }
    else if(argc==1){
        toSend = 1;
        yyparse();
    }
    
    free(myprogram);
    
    return 0;
}

int yywrap(){
    return 1;
}
