%{
  #include <iostream>
  #include <cstdlib>
  #include <string>
  #include "rosacees.bison.hpp"
%}

%%

[0-9]+(\.[0-9]*)?([Ee][0-9]+)? {  yylval.nombre = atof(yytext); return NUM; }
\"[a-zA-Z0-9]+\"   { yylval.chaine = strdup(yytext); return STR; }
[a-zA-Z]+[a-zA-Z0-9]?  { yylval.chaine = strdup(yytext); return VAR; }
\n     {  return '\n'; }
plus   { return '+'; }
fois   { return '*'; }
" "    {}
.      {  return yytext[0]; }

%%

int yywrap(){}

