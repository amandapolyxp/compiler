/* Amanda Menezes 2017124788 */
/* Pedro Meira 2019223208 */

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
    int lin = 1; // initialize to 1
    int chars = 1, str_col = 1, com_col = 1, com_lin = 1, oct_col = 1, prev_char = 0;
    char * token_type = "ILLEGAL";
    int eol = 0;
    int valid, strlit = 0;
    int strlit_start = 1;
    int semicolons = 0;
    int token_status = 1;
    void ret_print(char *token_type);
    void p_error();
    void strError(char* message, char* yytext, int yyleng, int l, int c);
%}

%x COMMENT STRLIT

alpha               [a-zA-Z]
alphaID             [\_a-zA-Z]
digit               [0-9]
intn                [1-9]{digit}*
octDigit            [0-7]
hexDigit            [0-9a-fA-F]
alnum               {alpha}|{digit}
spc                 (" "|\t|\f)
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

"//".*              { ;  }

"/*"                {BEGIN(COMMENT); com_col = chars++; com_lin = lin; chars++;}
\"                                                {strlit = 0; eol = 0; valid = 1; strlit_start = chars; BEGIN STRLIT; chars++; semicolons = 0;}


<COMMENT>"*/"       {BEGIN 0; chars += 2;}
<COMMENT>[^\n]	    {chars++;}
<COMMENT>"\n"       {++lin; chars = 1; }
<COMMENT><<EOF>>    {BEGIN 0; printf("Line %d, column %d: unterminated comment\n", com_lin, com_col); }



<STRLIT>([^\\\"\n\r]|\\[fnrt\\\"])*\"        {strlit = 1; eol = 0; chars += yyleng; BEGIN 0; yytext[yyleng - 1] = '\0'; if (valid)
                                                                                                       {
                                                                                                            if (token_status == 1){
                                                                                                               printf("STRLIT(\"%s\")\n", yytext);
                                                                                                               //chars = 1;
                                                                                                            }
                                                                                                            semicolons = 1;
                                                                                                           };}
<STRLIT>(\n|\r\n|\r)                        {strlit = 0; eol = 0;semicolons = 0; strError("unterminated string literal", "", 0, lin, strlit_start); chars = 1; lin++; BEGIN 0;}
<STRLIT>\\[fnrt\\\"]                        {strlit = 0; eol = 0; semicolons = 0;chars += yyleng;}
<STRLIT>\\.?                                {strlit = 0; eol = 0; semicolons = 0;strError("invalid escape sequence", yytext, 0, lin, chars); chars += yyleng; valid = 0;}
<STRLIT><<EOF>>                              {strlit = 0; eol = 0; semicolons = 0;strError("unterminated string literal", "", 0, lin, strlit_start); chars = 1; BEGIN 0; }
<STRLIT>.                                    {strlit = 0; eol = 0; semicolons = 0;chars++;}



{REALLIT}                            { ret_print("REALLIT"); chars += yyleng;eol = 1;semicolons = 0;}
{INTLIT}                             { ret_print("INTLIT"); chars += yyleng;eol = 1;semicolons = 0;}
{octaErr}                            { oct_col = chars;p_error("invalid octal constant", 1, oct_col);eol = 0;chars+=yyleng;semicolons = 0;}
{SEMICOLON}                          { ret_print("SEMICOLON"); chars += yyleng;eol = 0;semicolons = 0;}
{COMMA}                              { ret_print("COMMA"); chars += yyleng;eol = 0;semicolons = 0;}
{BLANKID}                            { ret_print("BLANKID"); chars += yyleng;eol = 0;semicolons = 0;}
{ASSIGN}                             { ret_print("ASSIGN"); chars += yyleng;eol = 0;semicolons = 0;}
{STAR}                               { ret_print("STAR"); chars += yyleng;eol = 0;semicolons = 0;}
{DIV}                                { ret_print("DIV"); chars += yyleng;eol = 0;semicolons = 0;}
{MINUS}                              { ret_print("MINUS"); chars += yyleng;eol = 0;semicolons = 0;}
{PLUS}                               { ret_print("PLUS"); chars += yyleng;eol = 0;semicolons = 0;}
{EQ}                                 { ret_print("EQ"); chars += yyleng;eol = 0;semicolons = 0;}
{GE}                                 { ret_print("GE"); chars += yyleng;eol = 0;semicolons = 0;}
{GT}                                 { ret_print("GT"); chars += yyleng;eol = 0;semicolons = 0;}
{LBRACE}                             { ret_print("LBRACE"); chars += yyleng;eol = 0;semicolons = 0;}
{LE}                                 { ret_print("LE"); chars += yyleng;eol = 0;semicolons = 0;}
{LPAR}                               { ret_print("LPAR"); chars += yyleng;eol = 0;semicolons = 0;}
{LSQ}                                { ret_print("LSQ"); chars += yyleng;eol = 0;semicolons = 0;}
{LT}                                 { ret_print("LT"); chars += yyleng;eol = 0;semicolons = 0;}
{MOD}                                { ret_print("MOD"); chars += yyleng;eol = 0;semicolons = 0;}
{NE}                                 { ret_print("NE"); chars += yyleng;eol = 0;semicolons = 0;}
{NOT}                                { ret_print("NOT"); chars += yyleng;eol = 0;semicolons = 0;}
{AND}                                { ret_print("AND"); chars += yyleng;eol = 0;semicolons = 0;}
{OR}                                 { ret_print("OR"); chars += yyleng;eol = 0;semicolons = 0;}
{RBRACE}                             { ret_print("RBRACE"); chars += yyleng;eol = 1;semicolons = 0;}
{RPAR}                               { ret_print("RPAR"); chars += yyleng;eol = 1;semicolons = 0;}
{RSQ}                                { ret_print("RSQ"); chars += yyleng;eol = 1;semicolons = 0;}
{PACKAGE}                            { ret_print("PACKAGE"); chars += yyleng;eol = 0;semicolons = 0;}
{RETURN}                             { ret_print("RETURN"); chars += yyleng;eol = 1;semicolons = 0;}
{ELSE}                               { ret_print("ELSE"); chars += yyleng;eol = 0;semicolons = 0;}
{FOR}                                { ret_print("FOR"); chars += yyleng;eol = 0;semicolons = 0;}
{INT}                                { ret_print("INT"); chars += yyleng;eol = 0;semicolons = 0;}

{IF}                                  { ret_print("IF"); chars += yyleng;eol = 0;semicolons = 0;}
{VAR}                                 { ret_print("VAR"); chars += yyleng;eol = 0;semicolons = 0;}
{FLOAT32}                             { ret_print("FLOAT32"); chars += yyleng;eol = 0;semicolons = 0;}
{BOOL}                                { ret_print("BOOL"); chars += yyleng;eol = 0;semicolons = 0;}
{STRING}                              { ret_print("STRING"); chars += yyleng;eol = 0;semicolons = 0;}
{PRINT}                               { ret_print("PRINT"); chars += yyleng;eol = 0;semicolons = 0;}
{PARSEINT}                            { ret_print("PARSEINT"); chars += yyleng;eol = 0;semicolons = 0;}
{FUNC}                                { ret_print("FUNC"); chars += yyleng;eol = 0;semicolons = 0;}
{CMDARGS}                             { ret_print("CMDARGS"); chars += yyleng;eol = 0;semicolons = 0;}


{CONTINUE}                              { ret_print("RESERVED"); chars += yyleng;eol = 0;semicolons = 0;}
{BREAK}                                 { ret_print("RESERVED"); chars += yyleng;eol = 0;semicolons = 0;}
{IMPORT}                                { ret_print("RESERVED"); chars += yyleng;eol = 0;semicolons = 0;}
{GOTO}                                  { ret_print("RESERVED"); chars += yyleng;eol = 0;semicolons = 0;}
{FALLTHROUGH}                           { ret_print("RESERVED"); chars += yyleng;eol = 0;semicolons = 0;}
{DEFAULT}                               { ret_print("RESERVED"); chars += yyleng;eol = 0;semicolons = 0;}
{INTERFACE}                             { ret_print("RESERVED"); chars += yyleng;eol = 0;semicolons = 0;}
{SELECT}                                { ret_print("RESERVED"); chars += yyleng;eol = 0;semicolons = 0;}
{CASE}                                  { ret_print("RESERVED"); chars += yyleng;eol = 0;semicolons = 0;}
{DEFER}                                 { ret_print("RESERVED"); chars += yyleng;eol = 0;semicolons = 0;}
{GO}                                    { ret_print("RESERVED"); chars += yyleng;eol = 0;semicolons = 0;}
{MAP}                                   { ret_print("RESERVED"); chars += yyleng;eol = 0;semicolons = 0;}
{STRUCT}                                { ret_print("RESERVED"); chars += yyleng;eol = 0;semicolons = 0;}
{CHAN}                                  { ret_print("RESERVED"); chars += yyleng;eol = 0;semicolons = 0;}
{SWITCH}                                { ret_print("RESERVED"); chars += yyleng;eol = 0;semicolons = 0;}
{CONST}                                 { ret_print("RESERVED"); chars += yyleng;eol = 0;semicolons = 0;}
{RANGE}                                 { ret_print("RESERVED"); chars += yyleng;eol = 0;semicolons = 0;}
{TYPE}                                  { ret_print("RESERVED"); chars += yyleng;eol = 0;semicolons = 0;}
{INC}                                   { ret_print("RESERVED"); chars += yyleng;eol = 0;semicolons = 0;}
{DEC}                                   { ret_print("RESERVED"); chars += yyleng;eol = 0;semicolons = 0;}


{newline}           { ++lin; chars = 1; if(semicolons == 1 || eol == 1){
    printf("SEMICOLON\n");}; eol = 0; semicolons = 0;}

{spc}               {++chars;}
{ID}                { ret_print("ID"); chars += yyleng;eol = 1; semicolons = 0;}


.                   { ret_print("ILLEGAL"); chars += yyleng; semicolons = 0; eol = 0;}


%%

void ret_print(char *token_type){
    if(strcmp(token_type, "ID") == 0){
        printf("%s(%s)\n", token_type, yytext);
    }
    else if(strcmp(token_type, "INTLIT") == 0){
        printf("%s(%s)\n", token_type, yytext);
    }
    else if(strcmp(token_type, "REALLIT") == 0){
        printf("%s(%s)\n", token_type, yytext);
    }
    else if(strcmp(token_type, "RESERVED") == 0){
        printf("%s(%s)\n", token_type, yytext);
    }
    else if(strcmp(token_type, "ILLEGAL") == 0){
        p_error("illegal character", 1, chars);
    }
    else{
        printf("%s\n", token_type);
    }
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

int main(){


    yylex();

    return 0;
}

int yywrap(){
    return 1;
}
