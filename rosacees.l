%{
  #include <iostream>
  #include <cstdlib>
  #include <string>
  #include "rosacees.bison.hpp"

  int line = 1;
%}

%%

si { return IF; }
tant[' ']que { return WHILE; }
\<|\>|\<\=|\>\=|\=\=|\!\= { yylval.chaine = strdup(yytext); return COMP; }
fin { return END; }
vrai { yylval.chaine = strdup(yytext); return BOOL;}
faux { yylval.chaine = strdup(yytext); return BOOL;}
[0-9]+(\.[0-9]*)?([Ee][0-9]+)? {  yylval.chaine = strdup(yytext); return NUM; }
\"[a-zA-Z0-9]*\"   { yylval.chaine = strdup(yytext); return STR; }
[a-zA-Z]+[a-zA-Z0-9]*  { yylval.chaine = strdup(yytext); return VAR; }
\n                              { std::cout << "line " << ++line << std::endl;return EndOL; }
\r  {  return EndOL;}
" "    {}
.      {  return yytext[0]; }
<<EOF>>                         { static int c = 0; return (c++)? EndOL:EndOF; }

%%

int yywrap(){}

