%{
  #include "rosacees.h"
  using namespace std;
  int yyerror(char *s);

  vector<map<string, string>> var;
  vector<pair<int, string>> instructions;
  int ic = 0;   // compteur instruction 
  int argcount = 0;
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
%token <adresse> FONC
%token ARG
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
%left '+' '-'
%left '*' '/'
%left RULE
%left ','

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

sinon:
  | 
    {
      //TODO
    }
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
    ;

args: VAR
      {
        insert(ARG, $1);
        argcount++;
      }
    | VAR ',' args
      {
        insert(ARG, $1);
        argcount++;
      }
    ;

param: expr
      {
        argcount++;
      }
    | expr ',' param
      {
        argcount++;
      }
    ;

expr: val
    | VAR '=' expr
      {
        insert('=', $1);
      }
    | VAR '=' FONC '(' args ')' ':'
      {
        $3.ic_goto = ic;
        insert(FONC, "0");
        insert('=', $1);
        $3.ic_false = ic;
        insert(JMP, "0");
        instructions[$3.ic_goto].second = to_string(ic)+";"+to_string(argcount);
        argcount = 0;
      }
      program
      {
        instructions[$3.ic_false].second = to_string(ic);
      }
      END
    | VAR '(' param ')'
      {
        insert(VAR, $1);
      }
    | expr '+' expr
      {
        insert(CALC, "+");
      }
    | expr '*' expr
      {
        insert(CALC, "*");
      }
    | expr RULE expr
      {
        insert(RULE, "0");
      }
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
   case ARG : return "ARG";
   case BOOL : return "BOOL";
   case CALC : return "CALC";
   case FONC : return "FONC";
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
  var.push_back(map<string,string>());
  vector<string> pile; 
  string x,y,c;
  vector<string> args;
  int d = 0;
  cout << "===== EXECUTION =====" << endl;
  ic = 0;
  bool rule = false;
  while ( ic < instructions.size() ){
    auto ins = instructions[ic];
    switch(ins.first){
      case '=':
        rule = false;
        y = depiler(pile);
        var[var.size() - 1][ins.second] = y;
        //cout << ins.second << " = " << y << endl; 
        ic++;
      break;

      case CALC:
        y = depiler(pile);
        x = depiler(pile);
        pile.push_back(calc(x, y, ins.second));
        //cout << x << " calc " << y << endl;
        ic++;
      break;

      case COMP:
        y = depiler(pile);
        x = depiler(pile);
        pile.push_back(compare(x, y, ins.second));
        //cout << x << " " << ins.second << " " << y << " = " << compare(x, y, ins.second) << endl;
        ic++;
      break;

      case VAR:
        if(isFunction(var[var.size() - 1][ins.second]))
        {
          vector<string> args = rToVect(var[var.size() - 1][ins.second], "::");
          rule = false;
          var.push_back(map<string,string>());
          var[var.size() - 1]["<RETOUR>"] = to_string(stoi(instructions[stoi(args[0]) - 1].second));
          var[var.size() - 1]["<SAUT_RETOUR>"] = to_string(ic + 1);
          ic = stoi(args[0]) - 1;
          for(int i = args.size() - 1; i >= 1; i--)
          {
            var[var.size() - 1][args[i]] = depiler(pile); 
          }
        }
        else
        {
          pile.push_back(var[var.size() - 1][ins.second]);
        }
        ic++;
      break;
    
      case NUM :
        pile.push_back(ins.second);
        ic++;
      break;

      case STR:
        pile.push_back(ins.second);
        ic++;
      break;

      case BOOL:
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
    
      case FONC:
        c = ins.second.substr(ins.second.find(";")+1, ins.second.size()-ins.second.find(";")-1);
        for(int i = 0; i < stoi(c); i++)
        {
          args.push_back(depiler(pile));
        }
        d = stoi(c);
        c = "<FONC>::" + ins.second.substr(0, ins.second.find(";"));
        for(int i = 0; i < d; i++)
        {
          c += "::" + args[i];
        }
        pile.push_back(c); //<FONC>::JMP::arg1::arg2...
        ic++;
      break;

      case ARG:
        pile.push_back(ins.second);
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
    if(var.size() > 1)
    {
      if(ic == stoi(var[var.size() - 1]["<RETOUR>"]))
      {
        ic = stoi(var[var.size() - 1]["<SAUT_RETOUR>"]);
      }
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