%{
  #include "rosacees.h"
  extern void yyrestart ( FILE *input_file );
  extern int yylex ();
  using namespace std;
  int yyerror(char *s);
  extern FILE *yyin;
  extern int line;
  map<string, string> var;
  vector<bool> si;
  int nbLine = 0;

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
%token <chaine > COMP
%token <chaine> BOOL
%token IF
%token END
%token EndOF
%token EndOL
%type <chaine> expr
%type <chaine> calc
%type <chaine> str
%type <chaine> comp
%left '+' '-'
%left '*' '/'

%%
program: /* empty */		
       | program line     
	   ;

line: EndOL
  | EndOF { return 0; }
  | expr EndOF { if(ifcond(si)) { cout << endl << "Resultat : " << $1 << endl; } return 0;}
  | expr EndOL { if(ifcond(si)) { cout << endl << "Resultat : " << $1 << endl; showVars(var);} }
  | IF expr ':'
    {
      if(ifcond(si)) cout << "if " << $2 << endl;
      if(!ifcond(si))
      {
        si.push_back(false);
      }
      else if(isString($2))
      {
        if(!toStr($2).empty())
          si.push_back(true);
        else
          si.push_back(false);
      }
      else if(isNumber($2))
      {
        si.push_back(stof($2));
      }
      else
      {
        si.push_back((!strcmp($2, True)? true : false));
      }
    }
  | END 
    { 
      if(si.size())
      {
        si.pop_back(); 
        if(ifcond(si)) cout << "end" << endl; 
      }
    }
	;

comp: expr COMP expr
      {
        if(ifcond(si))
        {
          string a = $1, b = $3, c = $2;
          strcpy($$, compare(a, b, c).c_str());
        }
      };

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
      if(ifcond(si))
      {
        if(doesExist(var, $1))
          strcpy($$, var[$1].c_str());
        else
        {
          error({{undefined, $1}});
          strcpy($$, undefined);
        }
        /*if(test)
        {
          rewind(yyin);
          yyrestart(yyin);
          test = !test;
          line = 1;
        }*/
      }
    }
    | BOOL
    | comp
    | calc
    | str
    | VAR '=' expr
      {
        if(ifcond(si))
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
      }
    | '(' expr ')'
      {
        if(ifcond(si))
        {
          $$ = $2; 
        }
      }
    | expr '+' expr
      {
        if(ifcond(si) && doesExist(var, $1) && doesExist(var, $3))
        {
          string s = $1;
          cout << $1 << " + " << $3 << endl;
          double d = 0;
          if(isString(s))
          {
            s = toStdStr(s) + toStdStr($3);
            strcpy($$, toStr(s).c_str());
          }
          else if(isString($3))
          {
            d = stof($1);
            s = toStdStr($3);
            if(isNumber(s))
            {
              d += stof(s);
              strcpy($$, to_string(d).c_str());
            }
            else
            {
              s = $1;
              s += toStdStr($3);
              strcpy($$, toStr(s).c_str());
            }
          }
          else
          {
            if(isBool($1))
            {
              if(isBool($3))
              {
                strcpy($$, (((!strcmp($1, True)? 1 : 0) + (!strcmp($3, True)? 1 : 0))? True : False));
              }
              else
              {
                d = (!strcmp($1, True)? 1 : 0) + stof($3);
                strcpy($$, to_string(d).c_str());
              }
            }
            else if(isBool($3))
            {
              d = stof($1) + (!strcmp($3, True)? 1 : 0);
              strcpy($$, to_string(d).c_str());
            }
            else
            {
              d = stof($1) + stof($3);
              strcpy($$, to_string(d).c_str());
            }
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
      char c = 'c';
      while((c = fgetc(yyin)) != EOF)
      {
        if(c == '\n')
        {
          nbLine++;
        }
      }
      rewind(yyin);
      yyparse();  
    }				
    else
    {
      yyparse();
    }
    fclose(yyin);
    return 0;
}