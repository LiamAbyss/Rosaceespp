%{
  #include <iostream>
  #include <cstdlib>
  #include <cmath>    
  #include <string.h>
  #include <string>
  #include <algorithm>
  #include <map>
  #include <vector>
  extern int yylex ();
  using namespace std;
  int yyerror(char *s);
  map<string, string> var;

  void removeFromStr(string &s, char c)
  {
    s.erase(std::remove(s.begin(), s.end(), c), s.end());
  }

  string toStr(string &s)
  {
    removeFromStr(s, '"');
    s = "\"" + s + "\"";
    return s;
  }

  bool isNumber(string line)
  {
      char* p;
      strtod(line.c_str(), &p);
      return *p == 0;
  }

  bool isString(string s)
  {
    return (s[0] == '"' && s[s.size()-1] == '"');
  }
%}


%code requires
{
#include <string.h>
#include <string>
using namespace std;
}

%union
{
  double nombre;
  char* chaine;
}

%start program

%token <nombre> NUM	
%token <nombre> SIN
%token <chaine> STR
%token <chaine> VAR
%type <nombre> calc
%type <chaine> expr
%type <chaine> var
%left '+' '-'
%left '*' '/'

%%
program: /* empty */		
       | program line          
	   ;

line: '\n'			 
	| calc '\n' { cout << endl << "Result : " << $1 << endl; }	
  | expr '\n' { cout << endl << "Result : " << $1 << endl; }
  | var '\n' {cout << endl << "Result : " << $1 << endl; }
	;

calc:
    NUM                 { $$ = $1;  /* printf("%g ", $1); */ }		
    | calc '+' calc     { $$ = $1 + $3;  cout << $1 << " + " << $3 << " = " << $$  << endl; }
    | calc '-' calc     { $$ = $1 - $3;  cout << $1 << " - " << $3 << " = " << $$  << endl; }   		
    | calc '*' calc     { $$ = $1 * $3;  cout << $1 << " * " << $3 << " = " << $$  << endl; }		
    | '(' calc ')'      { $$ = $2;  }
    | SIN '(' calc ')'  { $$ = sin($3);  cout << "sin(" << $3 << ") = " << $$ << endl; }
    ;

expr:
    STR                 { $$ = $1 ; }
    | expr '+' expr     
      { 
        string s = $1;
        s += $3;
        toStr(s);
        strcpy($$, s.c_str());
      }
    ;

var:
    VAR
    {
      cout << var[$1] << endl;
    }
    | var '=' calc
      {
        var[$1] = to_string($3);
        strcpy($$, to_string($3).c_str());
      }
    | var '=' expr
      {
        var[$1] = $3;
        $$ = $3;
      }
    | var '=' var
      {
        if(!var[$3].empty())
        {
          var[$1] = var[$3];
          strcpy($$, var[$3].c_str());
        }
        else
        {
          var[$1] = $3;
          $$ = $3;
        }
      }
    | var '+' var
      {
        string s = var[$1];
        double d = 0;
        if(isString((string)var[$1]))
        {
          s += var[$3];  
          strcpy($$, toStr(s).c_str());
        }
        else if(isString((string)var[$3]))
        {
          d = stof(var[$1]);
          s = var[$3];
          removeFromStr(s, '"');
          if(isNumber(s))
          {
              d += stof(s);
          }
          strcpy($$, to_string(d).c_str());
        }
        else
        {
          d = stof(var[$1]) + stof(var[$3]);
          strcpy($$, to_string(d).c_str());
        }
      }
    ;
%%

int yyerror(char *s) {					
    printf("%s\n", s);
}

int main(void) {
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

    yyparse();						
    return 0;
}