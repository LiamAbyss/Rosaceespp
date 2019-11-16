%{
  #include "rosacees.h"
  using namespace std;
  int yyerror(char *s);

  map<string, string> var;
  vector<pair<int, string>> instructions;
  int ic = 0;   // compteur instruction 
  void insert(int c, string d) { instructions.push_back(make_pair(c, d)); ic++;};
  // structure pour stocker les adresses pour les sauts conditionnels et autres...
  typedef struct adr {
    int ic_goto; 
    int ic_false;
  } adr; 
%}

%union
{
  char* chaine;
  adr adresse;
}

%start program

%token <chaine> NUM	
%token <chaine> SIN
%token <chaine> STR
%token <chaine> VAR
%token <chaine > COMP
%token <chaine> BOOL
%token <chaine> RULE
%token <adresse> IF
%token <adresse> WHILE
%token CALC
%token SINON
%token END
%token OUT
%token JMP
%token JNZ
%token EndOF
%token EndOL
%type <chaine> expr
%type <chaine> comp
%type <chaine> val
%type <chaine> rule
%left '+' '-'
%left '*' '/'

%%
program: /* empty */		
       | program line     
	   ;

line: EndOL
  | EndOF { return 0; }
  | expr EndOF { return 0; }
  | expr EndOL {  }
  | OUT expr EndOL
    {
      insert(OUT, "0");
    }
  | OUT expr EndOF
    {
      insert(OUT, "0");
      return 0;
    }
  | IF expr ':' EndOL
    {
      $1.ic_goto = ic;
      insert(JNZ, "0");
    }
    program    
    { 
      $1.ic_false = ic;
      insert(JMP, "0");
      instructions[$1.ic_goto].second = to_string(ic);
    }
    SINON ':' EndOL program    
    { 
      instructions[$1.ic_false].second = to_string(ic);
    }
    END EndOL {  }
  | IF expr ':' EndOL
    {
      $1.ic_goto = ic;
      insert(JNZ, "0");
    }
    program  
    { 
      instructions[$1.ic_goto].second = to_string(ic);
    }
    END EndOL { }
  | WHILE { $1.ic_goto = ic;} expr ':'
    {
      $1.ic_false = ic;
      insert(JNZ, "0");
    }
    program
    {
      insert(JMP, to_string($1.ic_goto));
      instructions[$1.ic_false].second = to_string(ic); 
    }
    END EndOL {}
  ;

comp: expr COMP expr
      {
        insert(COMP, $2);
      };

val: VAR
      {
        insert(VAR, $1);
      }
    | BOOL
      {
        insert(BOOL, $1);
      }
    | NUM
      {
        insert(NUM, $1);
      }
    | STR
      {
        insert(STR, $1); 
      }
    | comp
    | RULE
    ;

rule: RULE
    | rule expr
      {
        insert(RULE, "0");
      }
    ;

expr: val
    | VAR '=' expr
      {
        insert('=', $1);
      }
    | expr '+' expr
      {
        insert(CALC, "+");
      }
    | expr '*' expr
      {
        insert(CALC, "*");
      }
    | expr rule
    | '(' expr ')'
      {
      }
    ;

%%

int yyerror(char *s) {					
    printf("%s\n", s);
}

string nom(int instruction){
  switch (instruction){
   case '='  : return "SET";
   case RULE : return "RULE";
   case BOOL : return "BOOL";
   case CALC : return "CALC";
   case VAR : return "VAR";
   case STR : return "STR";
   case COMP : return "COMP";
   case NUM  : return "NUM";
   case OUT     : return "OUT";
   case JNZ     : return "JNZ";   // Jump if not zero
   case JMP     : return "JMP";   // Unconditional Jump
   default  : return to_string (instruction);
   }
}

void print_program(){
  cout << "==== CODE GENERE ====" << endl;
  int i = 0;
  for (auto ins : instructions )
    cout << i++ << '\t' << nom(ins.first) << "\t" << ins.second << endl;
  cout << "=====================" << endl;  
}

string depiler(vector<string> &pile) {
  string t = pile[pile.size()-1];
  pile.pop_back();
  return t;
}

void run_program(){
  vector<string> pile; 
  string x,y;

  cout << "===== EXECUTION =====" << endl;
  ic = 0;
  bool rule = false;
  while ( ic < instructions.size() ){
    auto ins = instructions[ic];
    switch(ins.first){
      case '=':
        rule = false;
        y = depiler(pile);
        var[ins.second] = y;
        //cout << ins.second << " = " << y << endl; 
        ic++;
      break;

      case CALC:
        rule = false;
        y = depiler(pile);
        x = depiler(pile);
        pile.push_back(calc(x, y, ins.second));
        //cout << x << " calc " << y << endl;
        ic++;
      break;

      case COMP:
        rule = false;
        y = depiler(pile);
        x = depiler(pile);
        pile.push_back(compare(x, y, ins.second));
        //cout << x << " " << ins.second << " " << y << " = " << compare(x, y, ins.second) << endl;
        ic++;
      break;

      case VAR:
        rule = false;
        pile.push_back(var[ins.second]);
        ic++;
      break;
    
      case NUM :
        rule = false;
        pile.push_back(ins.second);
        ic++;
      break;

      case STR:
        rule = false;
        pile.push_back(ins.second);
        ic++;
      break;

      case BOOL:
        rule = false;
        pile.push_back(ins.second);
        ic++;
      break;

      case RULE:
        y = depiler(pile);
        x = depiler(pile);
        pile.push_back((rule ? "" : "<REGLE>::") + x + "::" + y);
        rule = true;
        ic++;
      break;
    
      case JMP :
        rule = false;
        ic = stoi(ins.second);
      break;
    
      case JNZ :
        rule = false;
        x = depiler(pile);
        ic = ( x == True ? ic + 1 : stoi(ins.second));
      break;

      case OUT :
        rule = false;
        cout << endl << depiler(pile);
        ic++;
      break;
    }
  }
  cout << endl << "=====================" << endl;  
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
      rewind(yyin);
      yyparse();  
    }				
    else
    {
      yyparse();
    }
    print_program();
    run_program();
    fclose(yyin);
    return 0;
}