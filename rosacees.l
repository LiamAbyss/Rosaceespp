%{
  #include <iostream>
  #include <cstdlib>
  #include <string>
  #include "rosacees.bison.hpp"
%}

%%

[0-9]+(\.[0-9]*)?([Ee][0-9]+)? {  yylval.chaine = strdup(yytext); return NUM; }
\"[a-zA-Z0-9]*\"   { yylval.chaine = strdup(yytext); return STR; }
[a-zA-Z]+[a-zA-Z0-9]*  { yylval.chaine = strdup(yytext); return VAR; }
\n                              { return EndOL; }
\r  { return EndOL;}
" "    {}
.      {  return yytext[0]; }
<<EOF>>                         { static int c = 0; return (c++)? EndOL:EndOF; }

%%

int yywrap(){}

