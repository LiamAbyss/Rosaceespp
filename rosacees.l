%{
  #include <iostream>
  #include <cstdlib>
  #include <string>
  int line = 1;
  typedef struct adr {
    int ic_goto; 
    int ic_false;
  } adr;
  
  #include "rosacees.bison.hpp"
 
%}

%%
retourligne { return ENDL;}
si { return IF; }
sinon { return SINON; }
tant[' ']que { return WHILE; }
\<|\>|\<\=|\>\=|\=\=|\!\= { yylval.chaine = strdup(yytext); return COMP; }
affiche { return OUT; }
demande { return IN; }
fin { return END; }
:: { yylval.chaine = strdup(yytext); return RULE; }
fonction { return FONC; }
retourne { return RETURN; }
pause { return PAUSE; }
vrai { yylval.chaine = strdup(yytext); return BOOL;}
faux { yylval.chaine = strdup(yytext); return BOOL;}
(-)?[0-9]+(\.[0-9]*)? {  yylval.chaine = strdup(yytext); return NUM; }
\"[^\"]*\"   { yylval.chaine = strdup(yytext); return STR; }
[a-zA-Z]+[a-zA-Z0-9]*  { yylval.chaine = strdup(yytext); return VAR; }
\n                              { std::cout << "line " << ++line << std::endl;return EndOL; }
\r  {  return EndOL;}
" "    {}
.      {  return yytext[0]; }
<<EOF>>                         { static int c = 0; return (c++)? EndOL:EndOF; }

%%

int yywrap(){}