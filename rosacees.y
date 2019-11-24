%{
  #include "rosacees.h"
  using namespace std;
  int yyerror(char *s);

  vector<map<string, string>> var;
  vector<vector<pair<int,int>>> ifGoto;
  vector<pair<int, string>> instructions;
  int ic = 0;   // compteur instruction 
  int argcount = 0;
  vector<string> includedFiles;
  void insert(int c, string d) { instructions.push_back(make_pair(c, d)); ic++;};
  void handleIncludes(string fname);
  void setIncludes(ifstream& f);
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
%token <chaine> RETURN
%token ARG
%token CALL
%token CALC
%token SINON
%token ENDL
%token END
%token OUT
%token IN
%token JMP
%token JNZ
%token EndOF
%token EndOL
%token PAUSE
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
  | EndOF 
    {
      return 0; 
    }
  | expr EndOF 
    { 
      return 0; 
    }
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
  | IN VAR EndOL
    {
      insert(IN, $2);
    }
  | IN VAR EndOF
    { 
      insert(IN, $2);
      return 0;
    }
  | PAUSE EndOL { insert(PAUSE, "0"); }
  | PAUSE EndOF 
    { 
      insert(PAUSE, "0"); 
      return 0; 
    } 
  | retour EndOL
  | retour EndOF 
    {
      return 0; 
    }
  | IF expr ':' EndOL
    {
      ifGoto.push_back(vector<pair<int,int>>());
      ifGoto[ifGoto.size() - 1].push_back(make_pair(ic,0));
      insert(JNZ, "0");
    }
    program    
    { 
      ifGoto[ifGoto.size() - 1][0].second = ic;
      insert(JMP, "0");
      instructions[ifGoto[ifGoto.size() - 1][0].first].second = to_string(ic);
    }
    sinon END EndOL 
    { 
      instructions[ifGoto[ifGoto.size() - 1][0].second].second = to_string(ic);
      ifGoto.pop_back(); 
    }
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
  | SINON IF expr ':' EndOL
    {
      ifGoto[ifGoto.size() - 1].push_back(make_pair(ic,0));
      insert(JNZ, "0");
    }
    program  
    { 
      ifGoto[ifGoto.size() - 1][ifGoto[ifGoto.size() - 1].size() - 1].second = ic;
      insert(JMP, "0");
      instructions[ifGoto[ifGoto.size() - 1][ifGoto[ifGoto.size() - 1].size() - 1].first].second = to_string(ic);
    }
    sinon 
    { 
      instructions[ifGoto[ifGoto.size() - 1][ifGoto[ifGoto.size() - 1].size() - 1].second].second = to_string(ic);
      ifGoto[ifGoto.size() - 1].pop_back(); 
    }
  | SINON ':' EndOL program    
    { 
      instructions[ifGoto[ifGoto.size() - 1][ifGoto[ifGoto.size() - 1].size() - 1].second].second = to_string(ic);
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

args: 
    | VAR
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

param: 
    | expr
      {
        argcount++;
      }
    | expr ',' param
      {
        argcount++;
      }
    ;

retour: 
      | RETURN
        {
          insert(RETURN, "0");
        }
      | RETURN expr
        {
          insert(RETURN, "1"); 
        }
      ;

expr: val
    | ENDL
      {
        insert(ENDL, "0");
      }
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
        insert(CALL, $1);
      }
    | expr '+' expr
      {
        insert(CALC, "+");
      }
    | expr '-' expr
      {
        insert(CALC, "-");
      }
    | expr '*' expr
      {
        insert(CALC, "*");
      }
    | expr '/' expr
      {
        insert(CALC, "/");
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
   case CALL : return "CALL";
   case RETURN : return "RETURN";
   case ENDL : return "ENDL";
   case BOOL : return "BOOL";
   case CALC : return "CALC";
   case FONC : return "FONC";
   case VAR : return "VAR";
   case STR : return "STR";
   case COMP : return "COMP";
   case NUM  : return "NUM";
   case OUT     : return "OUT";
   case IN : return "IN";
   case JNZ     : return "JNZ";   // Jump if not zero
   case JMP     : return "JMP";   // Unconditional Jump
   default  : return to_string (instruction);
   }
}

void print_program(string filename){
  cout << "==== CODE GENERE ====" << endl;
  int i = 0;
  ofstream f((filename + ".rppt").c_str());
  for (auto ins : instructions )
  {
    cout << i++ << '\t' << nom(ins.first) << "\t" << ins.second << endl;
    f << i << "\t\t" << nom(ins.first) << "\t\t" << ins.second << endl;
  }
  cout << "=====================" << endl;  
}

string depiler(vector<string> &pile) {
  string t = pile[pile.size()-1];
  pile.pop_back();
  return t;
}

void compile(string filename)
{
  ofstream f((filename + ".cpp").c_str());
  f << "#include \"" << "rosacees.h\"" << endl;
  f << "using namespace std;" << endl;
  f << "vector<map<string, string>> var;" << endl << "vector<vector<pair<int,int>>> ifGoto;" << endl;
  f << "vector<pair<int, string>> instructions;" << endl;
  f << "string depiler(vector<string> &pile) {" << endl << " string t = pile[pile.size()-1];" << endl << "pile.pop_back();" << endl << "return t;\n}" << endl;
  f << "int ic = 0;   // compteur instruction" << endl;
  f << endl << "int main(){" << endl;
  bool s = false;
  for(auto ins : instructions)
  {
    s = false;
    if(isString(ins.second))
    {
      s = true;
      ins.second[ins.second.size() - 1] = '\\';
      ins.second = "\\" + ins.second + "\""; 
    }
    f << "instructions.push_back(make_pair(" << ins.first << ",\"" << ins.second << "\"));" << endl;
  }
  f << "var.push_back(map<string,string>());\n  vector<string> pile; \n  string x,y,c;\n  vector<string> args;\n  int d = 0;\n  ic = 0;\n  bool rule = false;\n  while ( ic < instructions.size() ){\n    auto ins = instructions[ic];\n    switch(ins.first){\n    case " << PAUSE << ":\npause();\nic++;\nbreak;\n     case '=':\n        rule = false;\n        y = depiler(pile);\n        var[var.size() - 1][ins.second] = y;\n        //cout << ins.second << \" = \" << y << endl; \n        ic++;\n      break;\n\n      case " << CALC << ":\n        y = depiler(pile);\n        x = depiler(pile);\n        pile.push_back(calc(x, y, ins.second));\n        //cout << x << \" calc \" << y << endl;\n        ic++;\n      break;\n\n      case " << COMP << ":\n        y = depiler(pile);\n        x = depiler(pile);\n        pile.push_back(compare(x, y, ins.second));\n        //cout << x << \" \" << ins.second << \" \" << y << \" = \" << compare(x, y, ins.second) << endl;\n        ic++;\n      break;\n\n      case " << CALL << ":\n        if(isFunction(var[var.size() - 1][ins.second]))\n        {\n          vector<string> args = rToVect(var[var.size() - 1][ins.second], \"::\");\n          rule = false;\n          var.push_back(map<string,string>());\n          var[var.size() - 1][\"<RETOUR>\"] = to_string(stoi(instructions[stoi(args[0]) - 1].second));\n          var[var.size() - 1][\"<SAUT_RETOUR>\"] = to_string(ic + 1);\n          ic = stoi(args[0]) - 1;\n          for(int i = args.size() - 1; i >= 1; i--)\n          {\n            var[var.size() - 1][args[i]] = depiler(pile); \n          }\n        }\n        else{\n          error({{\"function\", ins.second}});\n          return -1;\n        }\n        ic++;\n      break;\n\n      case " << VAR << ":\n        pile.push_back(var[var.size() - 1][ins.second]);\n        ic++;\n      break;\n    \n      case " << NUM << " :\n        pile.push_back(ins.second);\n        ic++;\n      break;\n\n      case " << STR << ":\n        pile.push_back(ins.second);\n        ic++;\n      break;\n\n      case " << BOOL << ":\n        pile.push_back(ins.second);\n        ic++;\n      break;\n\n      case " << RULE << ":\n        y = depiler(pile);\n        x = depiler(pile);\n        pile.push_back((rule ? \"\" : \"<REGLE>::\") + x + \"::\" + y);\n        rule = true;\n        ic++;\n      break;\n    \n      case " << FONC << ":\n        c = ins.second.substr(ins.second.find(\";\")+1, ins.second.size()-ins.second.find(\";\")-1);\n        for(int i = 0; i < stoi(c); i++)\n        {\n          args.push_back(depiler(pile));\n        }\n        d = stoi(c);\n        c = \"<FONC>::\" + ins.second.substr(0, ins.second.find(\";\"));\n        for(int i = 0; i < d; i++)\n        {\n          c += \"::\" + args[i];\n        }\n        pile.push_back(c); //<FONC>::JMP::arg1::arg2...\n        ic++;\n      break;\n\n      case " << RETURN << ":\n        x = undefined;\n        if(stoi(ins.second))\n        {\n          x = depiler(pile);\n        }\n        pile.push_back(x);\n        ic++;\n      break;\n\n      case " << ARG << ":\n        pile.push_back(ins.second);\n        ic++;\n      break;\n\n      case " << JMP << " :\n        rule = false;\n        ic = stoi(ins.second);\n      break;\n    \n      case " << JNZ << " :\n        rule = false;\n        x = depiler(pile);\n        ic = ( x == True ? ic + 1 : stoi(ins.second));\n      break;\n\n      case " << OUT << " :\n        rule = false;\n        cout << depiler(pile) << endl;\n        ic++;\n      break;\n    }\n    if(var.size() > 1)\n    {\n      if(ins.first == " << RETURN << " || ic == stoi(var[var.size() - 1][\"<RETOUR>\"]))\n      {\n        ic = stoi(var[var.size() - 1][\"<SAUT_RETOUR>\"]);\n        var.pop_back();\n      }\n    }\n  }\nreturn 0;\n}" << endl;
  f.close();
  system("g++ -g -c rosacees.cpp -o rosacees.o");
  string cmd = "g++ " + filename + ".cpp rosacees.o -o " + filename + ".exe";
  system(cmd.c_str());
  remove((filename + ".cpp").c_str());
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
      case PAUSE:
        pause();
        ic++;
      break;
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

      case ENDL:
        pile.push_back("");
        ic++;
      break;

      case CALL:
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
          return;
        }
        ic++;
      break;

      case VAR:
        pile.push_back(var[var.size() - 1][ins.second]);
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

      case RETURN:
        x = undefined;
        if(stoi(ins.second))
        {
          x = depiler(pile);
        }
        pile.push_back(x);
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
        cout << depiler(pile) << endl;
        ic++;
      break;

      case IN :
        rule = false;
        cin >> var[var.size() - 1][ins.second];
        ic++;
      break;
    }
    if(var.size() > 1)
    {
      if(ins.first == RETURN || ic == stoi(var[var.size() - 1]["<RETOUR>"]))
      {
        ic = stoi(var[var.size() - 1]["<SAUT_RETOUR>"]);
        var.pop_back();
      }
    }
  }
  cout << endl << "=====================" << endl;  
}

void setIncludes(ifstream& f)
{
  string s;
  getline(f, s);
  while(s.substr(0, s.find(" ")) == "importe")
  {
    s = s.substr(s.find("\""), s.size()-1);
    if(!isalpha(s[s.size() - 1]) && s[s.size() - 1] != '"')
      removeFromStr(s, s[s.size() - 1]);
    if(find(includedFiles.begin(), includedFiles.end(), toStdStr(s)) != includedFiles.end())
      return;
    includedFiles.push_back(toStdStr(s));
    ifstream g(includedFiles[includedFiles.size() - 1]);
    setIncludes(g);
    g.close();
    getline(f, s);
  }
}

void handleIncludes(string fname)
{
  includedFiles.push_back(fname);
  ifstream f(includedFiles[0]);
  string s;
  setIncludes(f);
  f.close();
  ofstream f2("tmpCompil.rppx");
  while(includedFiles.size())
  {
    f.open(includedFiles[includedFiles.size() - 1].c_str());
    if(!f.is_open())
      break;
    includedFiles.pop_back();
    while(!f.eof())
    {
      getline(f, s);
      if(s.substr(0, s.find(" ")) != (string)"importe")
      {
        f2 << s << endl;
      }
    }
    f.close();
  }
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
      handleIncludes((string)argv[1] + ".rpp");
      yyin = fopen("tmpCompil.rppx", "r");
      yyparse();  
      fclose(yyin);
      remove("tmpCompil.rppx");
    }				
    else
    {
      yyparse();
    }
    print_program(argv[1]);
    run_program();
    //compile(argv[1]);
    return 0;
}