%{
  #include "rosacees.h"
  extern int yylex ();
  using namespace std;
  int yyerror(char *s);
  extern FILE *yyin;
  
  map<string, string> var;

%}

%union
{
  char* chaine;
}

%start program

%token <chaine> NUM	
%token <chaine> SIN
%token <chaine> STR
%token <chaine> VAR
%token EndOF
%token EndOL
%type <chaine> expr
%type <chaine> calc
%type <chaine> str
%left '+' '-'
%left '*' '/'

%%
program: /* empty */		
       | program line     
	   ;

line: EndOL	
  | EndOF { return 0; }
  | expr EndOF {cout << endl << "Resultat : " << $1 << endl; return 0;}
  | expr EndOL {cout << endl << "Resultat : " << $1 << endl;}
	;

calc:
    NUM
      {
        strcpy($$, to_string(stof($1)).c_str());
      }
    | '-' NUM
      {
        strcpy($$, to_string(-stof($2)).c_str());
      }

str:
    STR

expr:
    VAR
    {
      if(doesExist(var, $1))
        strcpy($$, var[$1].c_str());
      else
      {
        error(var, {{undefined, $1}});
        strcpy($$, undefined);
      }
    }
    | calc
    | str
    | VAR '=' expr
      {
        if(doesExist(var, $3))
        {
          var[$1] = $3;
          strcpy($$, var[$1].c_str());
        }
        else if(doesExist(var, $1))
        {
          strcpy($$, var[$1].c_str());
        }
        else
        {
          strcpy($$, undefined);
        }
      }
    | '(' expr ')'
      {
        $$ = $2; 
      }
    | expr '+' expr
      {
        if((string)$1 != undefined && (string)$3 != undefined)
        {
          string s = $1;
          cout << $1 << " " << $3 << endl;
          double d = 0;
          if(isString(var, s))
          {
            s = toStdStr(var, s) + toStdStr(var, $3);
            strcpy($$, toStr(var, s).c_str());
          }
          else if(isString(var, $3))
          {
            d = stof($1);
            s = toStdStr(var, $3);
            if(isNumber(var, s))
            {
                d += stof(s);
                strcpy($$, to_string(d).c_str());
            }
            else
            {
                s = $1;
                s += toStdStr(var, $3);
                strcpy($$, toStr(var, s).c_str());
            }
          }
          else
          {
            d = stof($1) + stof($3);
            strcpy($$, to_string(d).c_str());
          }
        }
      }
    ;

%%

int yyerror(char *s) {					
    printf("%s\n", s);
}

int main(int argc, char* argv[]) {
    cout << " ________________________________________" << endl;
    cout << "|          _,--._.-,                     |"<< endl;
    cout << "|         /\\_r-,\\_ )                     |" << endl;
    cout << "|      .-.) _;='_/ (.;                   |" << endl;
    cout << "|       \\ \\'     \\/S )                   |" << endl;
    cout << "|        L.'-. _.'|-'                    |" << endl;
    cout << "|       <_`-'\\'_.'/                      |" << endl;
    cout << "|          `'-._( \\    Rosacées++        |" << endl;
    cout << "|           ___   \\\\,      ___           |" << endl;
    cout << "|           \\ .'-. \\\\   .-'_. /          |" << endl;
    cout << "|            '._' '.\\\\/.-'_.'            |" << endl;
    cout << "|               '--``\\('--'              |" << endl;
    cout << "|                     \\\\                 |" << endl;
    cout << "|                     `\\\\,               |" << endl;
    cout << "|                       \\|               |" << endl;
    cout << " `````````````````````````````````````````" << endl;

    if(argc > 1) 
    {
      yyin = fopen(argv[1], "r");
      yyparse();  
    }				
    else
    {
      yyparse();
    }
    return 0;
}