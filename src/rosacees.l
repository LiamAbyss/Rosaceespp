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
\/\*([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*\*+\/ { return EndOL;}
\/\/.*[\r\n] { return EndOL; }
retourligne { return ENDL;}
nettoie[' ']?console { return CLS; }
si { return IF; }
ou { return OR; }
et { return AND; }
sinon { return SINON; }
pour { return POUR; }
tant[' ']que { return WHILE; }
\<|\>|\<\=|\>\=|\=\=|\!\= { yylval.chaine = strdup(yytext); return COMP; }
affiche { return OUT; }
afficher { return OUT; }
demande { return IN; }
demander { return IN; }
mot[' ']?de[' ']?passe { return PASS; }
avec { return WITH; }
sans { return WITHOUT; }
sha256 { return SHA; }
chiffrer { return ENCRYPT; }
chiffre { return ENCRYPT; }
d(é|e)chiffrer { return DECRYPT; }
d(é|e)chiffre { return DECRYPT; }
ajoute { return APP; }
ajouter { return APP; }
supprime { return DELETE; }
supprimer { return DELETE; }
renomme { return RENAME; }
renommer { return RENAME; }
à { return TO; }
dans { return TO; }
en { return TO; }
taille { return SIZEOF; }
fichier { return FICHIER; }
lis { return READ; }
lire { return READ; }
(é|e)cris { return WRITE; }
(é|e)crire { return WRITE; }
fin { return END; }
:: { yylval.chaine = strdup(yytext); return RULE; }
fonction { return FONC; }
retourne { return RETURN; }
retourner { return RETURN; }
pause { return PAUSE; }
vrai { yylval.chaine = strdup(yytext); return BOOL;}
faux { yylval.chaine = strdup(yytext); return BOOL;}
[0-9]+(\.[0-9]*)? {  yylval.chaine = strdup(yytext); return NUM; }
\"[^\"]*\"  { yylval.chaine = strdup(yytext); return STR; }
[a-zA-Z]+[a-zA-Z0-9]*  { yylval.chaine = strdup(yytext); return VAR; }
\n                              {  ++line; return EndOL; }
\r  {  return EndOL;}
" "    {}
.      {  return yytext[0]; }
<<EOF>>                         { static int c = 0; return (c++)? EndOL:EndOF; }

%%

int yywrap(){}