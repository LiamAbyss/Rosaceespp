%{
  #include "rosacees.h"
  using namespace std;
  int yyerror(char *s);

  vector<map<string, string>> var;
  vector<map<string, vector<string>>> tab;
  vector<map<string, FILE*>> files;
  vector<vector<pair<int,int>>> ifGoto;
  vector<pair<int, string>> instructions;
  int ic = 0;   // compteur instruction 
  int argcount = 0;
  int getCount = 0;
  vector<string> includedFiles;
  void insert(int c, string d) { instructions.push_back(make_pair(c, d)); ic++;};
  void handleIncludes(string fname);
  void setIncludes(ifstream& f);
  // structure pour stocker les adresses pour les sauts conditionnels et autres...
  typedef struct adr {
    int ic_goto; 
    int ic_false;
  } adr; 

  void exitFunc()
  {
    for(auto& v : files)
    {
      for(auto& f : v)
      {
        fclose(f.second);
      }
    }
  }

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
%token <adresse> POUR
%token FICHIER
%token OBJ
%token ARG
%token DELETE
%token RENAME
%token SINON OR AND
%token READ
%token WRITE
%token APP
%token TO
%token SIZEOF
%token GET
%token CALL
%token CALC
%token ENDL CLS
%token END
%token OUT IN PASS WITH WITHOUT SHA
%token JMP JNZ
%token EndOF EndOL
%token PAUSE
%type <chaine> expr
%type <chaine> comp
%type <chaine> pas
%type <chaine> val
%left '+' '-'
%left '*' '/'
%left RULE AND OR
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
  | CLS EndOL{ insert(CLS, "0");}
  | CLS EndOF{ insert(CLS, "0"); return 0;}
  | OUT expr EndOL
    {
      insert(OUT, "0");
    }
  | OUT expr EndOF
    {
      insert(OUT, "0");
      return 0;
    }
  | IN VAR sha EndOL
    {
      insert(IN, $2);
    }
  | IN VAR sha EndOF
    { 
      insert(IN, $2);
      return 0;
    }
  | PASS VAR sha EndOL
    {
      insert(PASS, $2);
    }
  | PASS VAR sha EndOF
    { 
      insert(PASS, $2);
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
  | POUR  VAR '=' expr ':' expr pas ':'
    {
      insert('=', (string)$2 + "max");
      insert('=', $2);
      $1.ic_goto = ic;
      insert(VAR, $2);
      insert(VAR, (string)$2 + "max");
      insert(COMP, "<=");
      $1.ic_false = ic;
      insert(JNZ, "0");
    }
    program
    {
      insert(VAR, $2);
      insert(NUM, (stof($7) ? $7 : "1"));
      insert(CALC, "+");
      insert('=', $2);
      insert(JMP, to_string($1.ic_goto));
      instructions[$1.ic_false].second = to_string(ic);
    }
    END EndOL
  | DELETE STR
    {
      insert(STR, $2);
      insert(DELETE, "0");
    }
    | DELETE VAR
    {
      insert(VAR, $2);
      insert(DELETE, "0");
    }
  | RENAME STR TO STR
    {
      insert(STR, $2);
      insert(STR, $4);
      insert(RENAME, "0");
    }
    | RENAME STR TO VAR
    {
      insert(STR, $2);
      insert(VAR, $4);
      insert(RENAME, "0");
    }
    | RENAME VAR TO STR
    {
      insert(VAR, $2);
      insert(STR, $4);
      insert(RENAME, "0");
    }
    | RENAME VAR TO VAR
    {
      insert(VAR, $2);
      insert(VAR, $4);
      insert(RENAME, "0");
    }
  ;

sha:
  | WITH SHA { insert(SHA, "1"); }
  | WITHOUT SHA { insert(SHA, "0"); }
  ;

pas:  { $$ = (char*)"0"; }
    | '(' NUM ')' { $$ = $2; }
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
      }
    | comp OR comp
      {
        insert(CALC, "+");
      }
    | comp AND comp
      {
        insert(CALC, "*");
      }
    ;

getter: '[' expr ']'
        {
          getCount++;
        }
      | '[' expr ']' getter
        {
          getCount++;
        }
      ;

val: VAR
      {
        insert(VAR, $1);
      }
    | VAR getter
      {
        insert(VAR, $1);
        insert(GET, to_string(getCount));
        getCount = 0;
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

retour: RETURN
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
    | APP expr TO VAR
      {
        insert(APP, $4);
      }
    | SIZEOF '(' expr ')'
      {
        insert(SIZEOF, "0");
      }
    | READ VAR
      {
        insert(READ, $2);
      }
    | WRITE expr TO VAR
      {
        insert(WRITE, $4);
      }
    | VAR '=' expr
      {
        insert('=', $1);
      }
    | VAR '=' FICHIER'('STR ',' STR ')'
      {
        insert(STR, $5);
        insert(STR, $7);
        insert(FICHIER, toStdStr((string)$5)+(string)";"+toStdStr((string)$7));
        insert('=', $1);
      }
      | VAR '=' FICHIER'('VAR ',' STR ')'
        {
          insert(VAR, $5);
          insert(STR, $7);
          insert(FICHIER, (string)$5+(string)";"+toStdStr((string)$7));
          insert('=', $1);
        }
      | VAR '=' FICHIER'('STR ',' VAR ')'
        {
          insert(STR, $5);
          insert(VAR, $7);
          insert(FICHIER, toStdStr((string)$5)+(string)";"+(string)$7);
          insert('=', $1);
        }
      | VAR '=' FICHIER'('VAR ',' VAR ')'
        {
          insert(VAR, $5);
          insert(VAR, $7);
          insert(FICHIER, (string)$5+(string)";"+(string)$7);
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
    | '-' expr
      {
        insert(NUM, "-1");
        insert(CALC, "*");
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
    | VAR '(' param ')'
      {
        insert(CALL, $1);
        argcount = 0;
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
   case APP : return "APP";
   case SIZEOF : return "SIZEOF";
   case FICHIER : return "FICHIER";
   case GET : return "GET";
   case ENDL : return "ENDL";
   case BOOL : return "BOOL";
   case CALC : return "CALC";
   case CLS : return "CLS";
   case READ : return "LECT";
   case WRITE : return "ECR";
   case SHA : return "SHA";
   case FONC : return "FONC";
   case RENAME : return "RENAME";
   case DELETE : return "DELETE";
   case VAR : return "VAR";
   case STR : return "STR";
   case COMP : return "COMP";
   case NUM  : return "NUM";
   case OUT     : return "OUT";
   case IN : return "IN";
   case PASS : return "PASS";
   case JNZ     : return "JNZ";   // Jump if not zero
   case JMP     : return "JMP";   // Unconditional Jump
   default  : return to_string (instruction);
   }
}

void print_program(string filename){
  //cout << "==== CODE GENERE ====" << endl;
  int i = 0;
  filename.erase(filename.end() - 4, filename.end());
  ofstream f((filename + ".rppt").c_str());
  for (auto ins : instructions )
  {
    //cout << i++ << '\t' << nom(ins.first) << "\t" << ins.second << endl;
    f << i << "\t\t" << nom(ins.first) << "\t\t" << ins.second << endl;
  }
  //cout << "=====================" << endl;  
}

string depiler(vector<string> &pile) {
  string t = pile[pile.size()-1];
  pile.pop_back();
  return t;
}

void compile(string filename)
{
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
  filename.erase(filename.end() - 4, filename.end());
  ofstream f((filename + ".cpp").c_str());
  {
    f << "#include \"" << "rosacees.h\"" << endl;
    f << "using namespace std;" << endl;
    f << "vector<map<string, string>> var;" << endl << "vector<vector<pair<int,int>>> ifGoto;" << endl;
    f << "vector<pair<int, string>> instructions;" << endl;
    f << "string depiler(vector<string> &pile) {" << endl << " string t = pile[pile.size()-1];" << endl << "pile.pop_back();" << endl << "return t;\n}" << endl;
    f << "int ic = 0;   // compteur instruction" << endl;
    f << "vector<map<string, vector<string>>> tab;" << endl;
    f << "vector<map<string, FILE*>> files;" << endl;
    f << "void exitFunc()" << endl;
    f << "{" << endl;
    f << "  for(auto& v : files)" << endl;
    f << "  {" << endl;
    f << "    for(auto& f : v)" << endl;
    f << "    {" << endl;
    f << "      fclose(f.second);" << endl;
    f << "    }" << endl;
    f << "  }" << endl;
    f << "}" << endl;
    f << endl << "int main(){" << endl;
  }
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
  {
    f << "  var.push_back(map<string,string>());" << endl;
    f << "  tab.push_back(map<string, vector<string>>());" << endl;
    f << "  files.push_back(map<string, FILE*>());" << endl;
    f << "  vector<string> pile; " << endl;
    f << "  char ch = '0';" << endl;
    f << "  FILE* file;" << endl;
    f << "  string x,y,c;" << endl;
    f << "  vector<string> args;" << endl;
    f << "  int d = 0, couche = 0;" << endl;
    f << "  //cout << \"===== EXECUTION =====\" << endl;" << endl;
    f << "  ic = 0;" << endl;
    f << "  bool rule = false, shaMode = false;" << endl;
    f << "  while ( ic < instructions.size() ){" << endl;
    f << "    auto ins = instructions[ic];" << endl;
    f << "    switch(ins.first){" << endl;
    f << "      case " << PAUSE << ":" << endl;
    f << "        pause();" << endl;
    f << "        ic++;" << endl;
    f << "      break;" << endl;
    f << "      " << endl;
    f << "      case " << CLS << ":" << endl;
    f << "        clearConsole();" << endl;
    f << "        ic++;" << endl;
    f << "      break;" << endl;
    f << "" << endl;
    f << "      case '=':" << endl;
    f << "        rule = false;" << endl;
    f << "        y = depiler(pile);" << endl;
    f << "        if(isFile(var[var.size() - 1][ins.second]))" << endl;
    f << "        {" << endl;
    f << "          fclose(files[files.size() - 1][rToVect(var[var.size() - 1][ins.second], \"::\")[0]]);" << endl;
    f << "        }" << endl;
    f << "        if(isNumber(y))" << endl;
    f << "        {" << endl;
    f << "          y = to_string(stof(y));" << endl;
    f << "        }" << endl;
    f << "        else if(isTab(y))" << endl;
    f << "        {" << endl;
    f << "          tab[tab.size() - 1][ins.second] = tab[tab.size() - 1][rToVect(y, \"::\")[0]];" << endl;
    f << "          var[var.size() - 1][ins.second] = \"<TAB>::\" + ins.second;" << endl;
    f << "          ic++;" << endl;
    f << "          break;" << endl;
    f << "        }" << endl;
    f << "        var[var.size() - 1][ins.second] = y;" << endl;
    f << "        var[var.size() - 1][\"<VALEUR_RETOUR>\"] = undefined;" << endl;
    f << "        //cout << ins.second << \" = \" << y << endl; " << endl;
    f << "        ic++;" << endl;
    f << "      break;" << endl;
    f << "" << endl;
    f << "      case " << APP << ":" << endl;
    f << "        rule = false;" << endl;
    f << "        y = depiler(pile);" << endl;
    f << "        if(var[var.size() - 1][ins.second].empty())" << endl;
    f << "        {" << endl;
    f << "          tab[tab.size() - 1][ins.second].push_back(y);" << endl;
    f << "          var[var.size() - 1][ins.second] = \"<TAB>::\" + ins.second;" << endl;
    f << "        }" << endl;
    f << "        else if(isTab(var[var.size() - 1][ins.second]))" << endl;
    f << "        {" << endl;
    f << "          string name = rToVect(var[var.size() - 1][ins.second], \"::\")[0];" << endl;
    f << "          tab[tab.size() - 1][name].push_back(y);" << endl;
    f << "        }" << endl;
    f << "        else" << endl;
    f << "        {" << endl;
    f << "          tab[tab.size() - 1][ins.second].push_back(var[var.size() - 1][ins.second]);" << endl;
    f << "          tab[tab.size() - 1][ins.second].push_back(y);" << endl;
    f << "          var[var.size() - 1][ins.second] = \"<TAB>::\" + ins.second;" << endl;
    f << "        }" << endl;
    f << "        ic++;" << endl;
    f << "      break;" << endl;
    f << "" << endl;
    f << "      case " << SIZEOF << ":" << endl;
    f << "        x = depiler(pile);" << endl;
    f << "        if(isTab(x))" << endl;
    f << "          pile.push_back(to_string(tab[tab.size() - 1][rToVect(x, \"::\")[0]].size()));" << endl;
    f << "        else if(isString(x))" << endl;
    f << "          pile.push_back(to_string(toStdStr(x).size()));" << endl;
    f << "        else if(isString(var[var.size() - 1][x]))" << endl;
    f << "          pile.push_back(to_string(toStdStr(var[var.size() - 1][x]).size()));" << endl;
    f << "        ic++;" << endl;
    f << "      break;" << endl;
    f << "" << endl;
    f << "      case " << GET << ":" << endl;
    f << "        args.clear();" << endl;
    f << "        x = depiler(pile);" << endl;
    f << "        if(isTab(x))" << endl;
    f << "        {" << endl;
    f << "          x = rToVect(x, \"::\")[0];" << endl;
    f << "          for(int i = 0; i < stoi(ins.second); i++)" << endl;
    f << "          {" << endl;
    f << "            args.push_back(depiler(pile));" << endl;
    f << "          } " << endl;
    f << "          for(int i = args.size()-1; i >= 0; i--)" << endl;
    f << "          {" << endl;
    f << "            if(stof(args[i]) < tab[tab.size() - 1][x].size())" << endl;
    f << "            {" << endl;
    f << "              pile.push_back(tab[tab.size() - 1][x][stoi(args[i])]);" << endl;
    f << "              if(stoi(ins.second) > args.size() - i)" << endl;
    f << "                x = rToVect(depiler(pile), \"::\")[0];" << endl;
    f << "            }" << endl;
    f << "            else" << endl;
    f << "            {" << endl;
    f << "              error({\"Erreur : Sortie du tableau \" + x + \" à l'indice \" + args[i]});" << endl;
    f << "            }" << endl;
    f << "          }" << endl;
    f << "        }" << endl;
    f << "        else if(isString(x))" << endl;
    f << "        {" << endl;
    f << "          x = toStdStr(x);" << endl;
    f << "          y = depiler(pile);" << endl;
    f << "          if(stoi(y) < x.size())" << endl;
    f << "          {" << endl;
    f << "            x = x[stoi(y)];" << endl;
    f << "            pile.push_back(toStr(x));" << endl;
    f << "          }" << endl;
    f << "          else" << endl;
    f << "          {" << endl;
    f << "            error({\"Erreur : Sortie du tableau \" + x + \" à l'indice \" + y});" << endl;
    f << "          }" << endl;
    f << "        }" << endl;
    f << "        args.clear();" << endl;
    f << "        ic++;" << endl;
    f << "      break;" << endl;
    f << "" << endl;
    f << "      case " << READ << ":" << endl;
    f << "        if(isFile(var[var.size() - 1][ins.second]))" << endl;
    f << "        {" << endl;
    f << "          ch = fgetc(files[files.size() - 1][rToVect(var[var.size() - 1][ins.second], \"::\")[0]]);" << endl;
    f << "          x = \"\\\"\";" << endl;
    f << "          x = x + ch + \"\\\"\";" << endl;
    f << "          if(ch != EOF)" << endl;
    f << "            pile.push_back(x);" << endl;
    f << "          else" << endl;
    f << "            pile.push_back(\"\\\"FDF\\\"\");" << endl;
    f << "        }" << endl;
    f << "        else" << endl;
    f << "        {" << endl;
    f << "          error({\"Erreur : Impossible de lire un fichier de type \" + type(var[var.size() - 1][ins.second])});" << endl;
    f << "        }" << endl;
    f << "        ic++;" << endl;
    f << "      break;" << endl;
    f << "" << endl;
    f << "      case " << WRITE << ":" << endl;
    f << "        if(isFile(var[var.size() - 1][ins.second]))" << endl;
    f << "        {" << endl;
    f << "          x = depiler(pile);" << endl;
    f << "          for(int i = x.size() - 1; i >= 0; i--)" << endl;
    f << "          {" << endl;
    f << "            if(!(x[i] == '0' || x[i] == '.') || i == 0)" << endl;
    f << "            {" << endl;
    f << "              x.erase(x.begin() + i + 1, x.end());" << endl;
    f << "              break;" << endl;
    f << "            }" << endl;
    f << "          }" << endl;
    f << "          fputs(toStdStr(x).c_str(), files[files.size() - 1][rToVect(var[var.size() - 1][ins.second], \"::\")[0]]);" << endl;
    f << "        }" << endl;
    f << "        else" << endl;
    f << "        {" << endl;
    f << "          error({\"Erreur : Impossible d'écrire dans un fichier de type \" + type(var[var.size() - 1][ins.second])});" << endl;
    f << "        }" << endl;
    f << "        ic++;        " << endl;
    f << "      break;" << endl;
    f << "" << endl;
    f << "      case " << DELETE << ":" << endl;
    f << "        x = depiler(pile);" << endl;
    f << "        remove(toStdStr(x).c_str());" << endl;
    f << "        ic++;" << endl;
    f << "      break;" << endl;
    f << "" << endl;
    f << "      case " << RENAME << ":" << endl;
    f << "        x = depiler(pile);" << endl;
    f << "        y = depiler(pile);" << endl;
    f << "        rename(toStdStr(y).c_str(), toStdStr(x).c_str());" << endl;
    f << "        ic++;" << endl;
    f << "      break;" << endl;
    f << "" << endl;
    f << "      case " << FICHIER << ":" << endl;
    f << "        x = rToVect(ins.second, \";\")[0];" << endl;
    f << "        y = rToVect(ins.second, \";\")[1];" << endl;
    f << "        y = depiler(pile);" << endl;
    f << "        x = depiler(pile);" << endl;
    f << "        file = fopen(toStdStr(x).c_str(), toStdStr(y).c_str());" << endl;
    f << "        files[files.size() - 1][toStdStr(x)] = file;" << endl;
    f << "        pile.push_back(\"<FICHIER>::\" + toStdStr(x));" << endl;
    f << "        file = NULL;" << endl;
    f << "        ic++;" << endl;
    f << "      break;" << endl;
    f << "" << endl;
    f << "      case " << CALC << ":" << endl;
    f << "        y = depiler(pile);" << endl;
    f << "        x = depiler(pile);" << endl;
    f << "        if(isNumber(y) && y.find(\".\") != string::npos)" << endl;
    f << "        {" << endl;
    f << "          for(int i = y.size() - 1; i >= 0; i--)" << endl;
    f << "          {" << endl;
    f << "            if(!(y[i] == '0'))" << endl;
    f << "            {" << endl;
    f << "              y.erase(y.begin() + i, y.end());" << endl;
    f << "              break;" << endl;
    f << "            }" << endl;
    f << "          }" << endl;
    f << "        }" << endl;
    f << "        if(isNumber(x) && x.find(\".\") != string::npos)" << endl;
    f << "        {" << endl;
    f << "          for(int i = x.size() - 1; i >= 0; i--)" << endl;
    f << "          {" << endl;
    f << "            if(!(x[i] == '0'))" << endl;
    f << "            {" << endl;
    f << "              x.erase(x.begin() + i, x.end());" << endl;
    f << "              break;" << endl;
    f << "            }" << endl;
    f << "          }" << endl;
    f << "        }" << endl;
    f << "        pile.push_back(calc(x, y, ins.second));" << endl;
    f << "        //cout << x << \" calc \" << y  << \" = \" << pile[pile.size() - 1] << endl;" << endl;
    f << "        ic++;" << endl;
    f << "      break;" << endl;
    f << "" << endl;
    f << "      case " << COMP << ":" << endl;
    f << "        y = depiler(pile);" << endl;
    f << "        x = depiler(pile);" << endl;
    f << "        pile.push_back(compare(x, y, ins.second));" << endl;
    f << "        //cout << x << \" \" << ins.second << \" \" << y << \" = \" << compare(x, y, ins.second) << endl;" << endl;
    f << "        ic++;" << endl;
    f << "      break;" << endl;
    f << "" << endl;
    f << "      case " << ENDL << ":" << endl;
    f << "        rule = false;" << endl;
    f << "        pile.push_back(\"\\n\");" << endl;
    f << "        ic++;" << endl;
    f << "      break;" << endl;
    f << "" << endl;
    f << "      case " << CALL << ":" << endl;
    f << "        couche = var.size() - 1;" << endl;
    f << "        while(var[couche][ins.second].empty())" << endl;
    f << "        {" << endl;
    f << "          if(couche < 0)" << endl;
    f << "          {" << endl;
    f << "            couche = 0;" << endl;
    f << "            break;" << endl;
    f << "          }" << endl;
    f << "          couche--;" << endl;
    f << "        }" << endl;
    f << "        if(isFunction(var[couche][ins.second]))" << endl;
    f << "        {" << endl;
    f << "          args.clear();" << endl;
    f << "          args = rToVect(var[couche][ins.second], \"::\");" << endl;
    f << "          var.push_back(map<string,string>());" << endl;
    f << "          tab.push_back(map<string, vector<string>>());" << endl;
    f << "          files.push_back(map<string, FILE*>());" << endl;
    f << "          var[var.size() - 1][\"<RETOUR>\"] = to_string(stoi(instructions[stoi(args[0]) - 1].second));" << endl;
    f << "          var[var.size() - 1][\"<SAUT_RETOUR>\"] = to_string(ic + 1);" << endl;
    f << "          ic = stoi(args[0]) - 1;" << endl;
    f << "          for(int i = args.size() - 1; i >= 1; i--)" << endl;
    f << "          {" << endl;
    f << "            var[var.size() - 1][args[i]] = depiler(pile);" << endl;
    f << "            if(isTab(var[var.size() - 1][args[i]]))" << endl;
    f << "            {" << endl;
    f << "              x = rToVect(var[var.size() - 1][args[i]], \"::\")[0];" << endl;
    f << "              tab[tab.size() - 1][args[i]] = tab[tab.size() - 2][x];" << endl;
    f << "              var[var.size() - 1][args[i]] = \"<TAB>::\" + args[i];" << endl;
    f << "            }" << endl;
    f << "            else if(isFile(var[var.size() - 1][args[i]]))" << endl;
    f << "            {" << endl;
    f << "              files[files.size() - 1][rToVect(var[var.size() - 1][args[i]], \"::\")[0]] = files[files.size() - 2][rToVect(var[var.size() - 1][args[i]], \"::\")[0]];" << endl;
    f << "            }" << endl;
    f << "          }" << endl;
    f << "        }" << endl;
    f << "        else" << endl;
    f << "        {" << endl;
    f << "          error({\"Erreur : \" + ins.second + \" n'est pas une fonction.\"});" << endl;
    f << "        }" << endl;
    f << "        args.clear();" << endl;
    f << "        ic++;" << endl;
    f << "      break;" << endl;
    f << "" << endl;
    f << "      case " << VAR << ":" << endl;
    f << "        pile.push_back(var[var.size() - 1][ins.second]);" << endl;
    f << "        ic++;" << endl;
    f << "      break;" << endl;
    f << "    " << endl;
    f << "      case " << NUM << ":" << endl;
    f << "        pile.push_back(ins.second);" << endl;
    f << "        ic++;" << endl;
    f << "      break;" << endl;
    f << "" << endl;
    f << "      case " << STR << ":" << endl;
    f << "        while(ins.second.find(\"\\\\n\") != string::npos)" << endl;
    f << "        {" << endl;
    f << "          replace(ins.second, \"\\\\n\", \"\\n\");" << endl;
    f << "        }" << endl;
    f << "        while(ins.second.find(\"\\\\r\") != string::npos)" << endl;
    f << "        {" << endl;
    f << "          replace(ins.second, \"\\\\r\", \"\\r\");" << endl;
    f << "        }" << endl;
    f << "        pile.push_back(ins.second);" << endl;
    f << "        ic++;" << endl;
    f << "      break;" << endl;
    f << "" << endl;
    f << "      case " << BOOL << ":" << endl;
    f << "        pile.push_back(ins.second);" << endl;
    f << "        ic++;" << endl;
    f << "      break;" << endl;
    f << "" << endl;
    f << "      case " << RULE << ":" << endl;
    f << "        y = depiler(pile);" << endl;
    f << "        x = depiler(pile);        " << endl;
    f << "        if(isNumber(y) && y.find(\".\") != string::npos)" << endl;
    f << "        {" << endl;
    f << "          for(int i = y.size() - 1; i >= 0; i--)" << endl;
    f << "          {" << endl;
    f << "            if(!(y[i] == '0'))" << endl;
    f << "            {" << endl;
    f << "              y.erase(y.begin() + i, y.end());" << endl;
    f << "              break;" << endl;
    f << "            }" << endl;
    f << "          }" << endl;
    f << "        }" << endl;
    f << "        pile.push_back((rule ? \"\" : \"<REGLE>::\") + x + \"::\" + y);" << endl;
    f << "        rule = true;" << endl;
    f << "        ic++;" << endl;
    f << "      break;" << endl;
    f << "    " << endl;
    f << "      case " << FONC << ":" << endl;
    f << "        rule = false;" << endl;
    f << "        args.clear();" << endl;
    f << "        c = ins.second.substr(ins.second.find(\";\")+1, ins.second.size()-ins.second.find(\";\")-1);" << endl;
    f << "        for(int i = 0; i < stoi(c); i++)" << endl;
    f << "        {" << endl;
    f << "          args.push_back(depiler(pile));" << endl;
    f << "        }" << endl;
    f << "        d = stoi(c);" << endl;
    f << "        c = \"<FONC>::\" + ins.second.substr(0, ins.second.find(\";\"));" << endl;
    f << "        for(int i = 0; i < d; i++)" << endl;
    f << "        {" << endl;
    f << "          c += \"::\" + args[i];" << endl;
    f << "        }" << endl;
    f << "        pile.push_back(c); //<FONC>::JMP::arg1::arg2..." << endl;
    f << "        args.clear();" << endl;
    f << "        ic++;" << endl;
    f << "      break;" << endl;
    f << "" << endl;
    f << "      case " << RETURN << ":" << endl;
    f << "        rule = false;" << endl;
    f << "        x = undefined;" << endl;
    f << "        if(stoi(ins.second))" << endl;
    f << "        {" << endl;
    f << "          x = depiler(pile);" << endl;
    f << "        }" << endl;
    f << "        if(isTab(x))" << endl;
    f << "        {" << endl;
    f << "          var[var.size() - 2][\"<VALEUR_RETOUR>\"] = x;" << endl;
    f << "          tab[tab.size() - 2][rToVect(x, \"::\")[0]] = tab[tab.size() - 1][rToVect(x, \"::\")[0]];" << endl;
    f << "        }" << endl;
    f << "        pile.push_back(x);" << endl;
    f << "        ic++;" << endl;
    f << "      break;" << endl;
    f << "" << endl;
    f << "      case " << ARG << ":" << endl;
    f << "        rule = false;" << endl;
    f << "        pile.push_back(ins.second);" << endl;
    f << "        ic++;" << endl;
    f << "      break;" << endl;
    f << "" << endl;
    f << "      case " << JMP << ":" << endl;
    f << "        rule = false;" << endl;
    f << "        ic = stoi(ins.second);" << endl;
    f << "      break;" << endl;
    f << "    " << endl;
    f << "      case " << JNZ << ":" << endl;
    f << "        rule = false;" << endl;
    f << "        x = depiler(pile);" << endl;
    f << "        ic = ( x == True ? ic + 1 : stoi(ins.second));" << endl;
    f << "      break;" << endl;
    f << "" << endl;
    f << "      case " << OUT << ":" << endl;
    f << "        rule = false;" << endl;
    f << "        x = depiler(pile);" << endl;
    f << "        if(isNumber(x) && x.find(\".\") != string::npos)" << endl;
    f << "        {" << endl;
    f << "          for(int i = x.size() - 1; i >= 0; i--)" << endl;
    f << "          {" << endl;
    f << "            if(!(x[i] == '0'))" << endl;
    f << "            {" << endl;
    f << "              x.erase(x.begin() + i, x.end());" << endl;
    f << "              break;" << endl;
    f << "            }" << endl;
    f << "          }" << endl;
    f << "        }" << endl;
    f << "        cout << toStdStr(x);" << endl;
    f << "        ic++;" << endl;
    f << "      break;" << endl;
    f << "" << endl;
    f << "      case " << SHA << ":" << endl;
    f << "        shaMode = stoi(ins.second);" << endl;
    f << "        ic++;" << endl;
    f << "      break;" << endl;
    f << "" << endl;
    f << "      case " << IN << ":" << endl;
    f << "        rule = false;" << endl;
    f << "        var[var.size() - 1][ins.second] = getIn(shaMode);" << endl;
    f << "        ic++;" << endl;
    f << "        shaMode = false;" << endl;
    f << "      break;" << endl;
    f << "" << endl;
    f << "      case " << PASS << ":" << endl;
    f << "        rule = false;" << endl;
    f << "        if(ic > 0 && instructions[ic - 1].first != " << SHA << ")" << endl;
    f << "          shaMode = true;" << endl;
    f << "        x = getpass(shaMode);" << endl;
    f << "        if(!isNumber(x) && !isBool(x))" << endl;
    f << "          var[var.size() - 1][ins.second] = toStr(x);" << endl;
    f << "        ic++;       " << endl;
    f << "        shaMode = false; " << endl;
    f << "      break;" << endl;
    f << "    }" << endl;
    f << "    if(var.size() > 1)" << endl;
    f << "    {" << endl;
    f << "      if(ins.first ==" << RETURN << " || ic == stoi(var[var.size() - 1][\"<RETOUR>\"]))" << endl;
    f << "      {" << endl;
    f << "        ic = stoi(var[var.size() - 1][\"<SAUT_RETOUR>\"]);" << endl;
    f << "        var.pop_back();" << endl;
    f << "        tab.pop_back();" << endl;
    f << "        files.pop_back();" << endl;
    f << "      }" << endl;
    f << "    }" << endl;
    f << "  }" << endl;
  }
  f << "}" << endl;
  f.close();
  system("g++ -g -c rosacees.cpp -o rosacees.o");
  system("g++ -g -c sha256.cpp -o sha256.o");
  string cmd = "g++ " + filename + ".cpp rosacees.o sha256.o -o " + filename + ".exe";
  system(cmd.c_str());
  remove((filename + ".cpp").c_str());
  cout << "Compilation terminée !" << endl;
}

void run_program(){
  var.push_back(map<string,string>());
  tab.push_back(map<string, vector<string>>());
  files.push_back(map<string, FILE*>());
  vector<string> pile; 
  char ch = '0';
  FILE* file;
  string x,y,c;
  vector<string> args;
  int d = 0, couche = 0;
  //cout << "===== EXECUTION =====" << endl;
  ic = 0;
  bool rule = false, shaMode = false;
  while ( ic < instructions.size() ){
    auto ins = instructions[ic];
    switch(ins.first){
      case PAUSE:
        pause();
        ic++;
      break;
      
      case CLS:
        clearConsole();
        ic++;
      break;

      case '=':
        rule = false;
        y = depiler(pile);
        if(isFile(var[var.size() - 1][ins.second]))
        {
          fclose(files[files.size() - 1][rToVect(var[var.size() - 1][ins.second], "::")[0]]);
        }
        if(isNumber(y))
        {
          y = to_string(stof(y));
        }
        else if(isTab(y))
        {
          tab[tab.size() - 1][ins.second] = tab[tab.size() - 1][rToVect(y, "::")[0]];
          var[var.size() - 1][ins.second] = "<TAB>::" + ins.second;
          ic++;
          break;
        }
        var[var.size() - 1][ins.second] = y;
        var[var.size() - 1]["<VALEUR_RETOUR>"] = undefined;
        //cout << ins.second << " = " << y << endl; 
        ic++;
      break;

      case APP:
        rule = false;
        y = depiler(pile);
        if(var[var.size() - 1][ins.second].empty())
        {
          tab[tab.size() - 1][ins.second].push_back(y);
          var[var.size() - 1][ins.second] = "<TAB>::" + ins.second;
        }
        else if(isTab(var[var.size() - 1][ins.second]))
        {
          string name = rToVect(var[var.size() - 1][ins.second], "::")[0];
          tab[tab.size() - 1][name].push_back(y);
        }
        else
        {
          tab[tab.size() - 1][ins.second].push_back(var[var.size() - 1][ins.second]);
          tab[tab.size() - 1][ins.second].push_back(y);
          var[var.size() - 1][ins.second] = "<TAB>::" + ins.second;
        }
        ic++;
      break;

      case SIZEOF:
        x = depiler(pile);
        if(isTab(x))
          pile.push_back(to_string(tab[tab.size() - 1][rToVect(x, "::")[0]].size()));
        else if(isString(x))
          pile.push_back(to_string(toStdStr(x).size()));
        else if(isString(var[var.size() - 1][x]))
          pile.push_back(to_string(toStdStr(var[var.size() - 1][x]).size()));
        ic++;
      break;

      case GET:
        args.clear();
        x = depiler(pile);
        if(isTab(x))
        {
          x = rToVect(x, "::")[0];
          for(int i = 0; i < stoi(ins.second); i++)
          {
            args.push_back(depiler(pile));
          } 
          for(int i = args.size()-1; i >= 0; i--)
          {
            if(stof(args[i]) < tab[tab.size() - 1][x].size())
            {
              pile.push_back(tab[tab.size() - 1][x][stoi(args[i])]);
              if(stoi(ins.second) > args.size() - i)
                x = rToVect(depiler(pile), "::")[0];
            }
            else
            {
              error({"Erreur : Sortie du tableau " + x + " à l'indice " + args[i]});
            }
          }
        }
        else if(isString(x))
        {
          x = toStdStr(x);
          y = depiler(pile);
          if(stoi(y) < x.size())
          {
            x = x[stoi(y)];
            pile.push_back(toStr(x));
          }
          else
          {
            error({"Erreur : Sortie du tableau " + x + " à l'indice " + y});
          }
        }
        args.clear();
        ic++;
      break;

      case READ:
        if(isFile(var[var.size() - 1][ins.second]))
        {
          ch = fgetc(files[files.size() - 1][rToVect(var[var.size() - 1][ins.second], "::")[0]]);
          x = "\"";
          x = x + ch + "\"";
          if(ch != EOF)
            pile.push_back(x);
          else
            pile.push_back("\"FDF\"");
        }
        else
        {
          error({"Erreur : Impossible de lire un fichier de type " + type(var[var.size() - 1][ins.second])});
        }
        ic++;
      break;

      case WRITE:
        if(isFile(var[var.size() - 1][ins.second]))
        {
          x = depiler(pile);
          for(int i = x.size() - 1; i >= 0; i--)
          {
            if(!(x[i] == '0' || x[i] == '.') || i == 0)
            {
              x.erase(x.begin() + i + 1, x.end());
              break;
            }
          }
          fputs(toStdStr(x).c_str(), files[files.size() - 1][rToVect(var[var.size() - 1][ins.second], "::")[0]]);
        }
        else
        {
          error({"Erreur : Impossible d'écrire dans un fichier de type " + type(var[var.size() - 1][ins.second])});
        }
        ic++;        
      break;

      case DELETE:
        x = depiler(pile);
        remove(toStdStr(x).c_str());
        ic++;
      break;

      case RENAME:
        x = depiler(pile);
        y = depiler(pile);
        rename(toStdStr(y).c_str(), toStdStr(x).c_str());
        ic++;
      break;

      case FICHIER:
        x = rToVect(ins.second, ";")[0];
        y = rToVect(ins.second, ";")[1];
        y = depiler(pile);
        x = depiler(pile);
        file = fopen(toStdStr(x).c_str(), toStdStr(y).c_str());
        files[files.size() - 1][toStdStr(x)] = file;
        pile.push_back("<FICHIER>::" + toStdStr(x));
        file = NULL;
        ic++;
      break;

      case CALC:
        y = depiler(pile);
        x = depiler(pile); 
        if(isNumber(y) && y.find(".") != string::npos)
        {
          for(int i = y.size() - 1; i >= 0; i--)
          {
            if(!(y[i] == '0'))
            {
              y.erase(y.begin() + i, y.end());
              break;
            }
          }
        } 
        if(isNumber(x) && x.find(".") != string::npos)
        {
          for(int i = x.size() - 1; i >= 0; i--)
          {
            if(!(x[i] == '0'))
            {
              x.erase(x.begin() + i, x.end());
              break;
            }
          }
        }
        pile.push_back(calc(x, y, ins.second));
        //cout << x << " calc " << y  << " = " << pile[pile.size() - 1] << endl;
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
        rule = false;
        pile.push_back("\n");
        ic++;
      break;

      case CALL:
        couche = var.size() - 1;
        while(var[couche][ins.second].empty())
        {
          if(couche < 0)
          {
            couche = 0;
            break;
          }
          couche--;
        }
        if(isFunction(var[couche][ins.second]))
        {
          args.clear();
          args = rToVect(var[couche][ins.second], "::");
          var.push_back(map<string,string>());
          tab.push_back(map<string, vector<string>>());
          files.push_back(map<string, FILE*>());
          var[var.size() - 1]["<RETOUR>"] = to_string(stoi(instructions[stoi(args[0]) - 1].second));
          var[var.size() - 1]["<SAUT_RETOUR>"] = to_string(ic + 1);
          ic = stoi(args[0]) - 1;
          for(int i = args.size() - 1; i >= 1; i--)
          {
            var[var.size() - 1][args[i]] = depiler(pile);
            if(isTab(var[var.size() - 1][args[i]]))
            {
              x = rToVect(var[var.size() - 1][args[i]], "::")[0];
              tab[tab.size() - 1][args[i]] = tab[tab.size() - 2][x];
              var[var.size() - 1][args[i]] = "<TAB>::" + args[i];
            }
            else if(isFile(var[var.size() - 1][args[i]]))
            {
              files[files.size() - 1][rToVect(var[var.size() - 1][args[i]], "::")[0]] = files[files.size() - 2][rToVect(var[var.size() - 1][args[i]], "::")[0]];
            }
          }
        }
        else
        {
          error({"Erreur : " + ins.second + " n'est pas une fonction."});
        }
        args.clear();
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
        while(ins.second.find("\\n") != string::npos)
        {
          replace(ins.second, "\\n", "\n");
        }
        while(ins.second.find("\\r") != string::npos)
        {
          replace(ins.second, "\\r", "\r");
        }
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
        if(isNumber(y) && y.find(".") != string::npos)
        {
          for(int i = y.size() - 1; i >= 0; i--)
          {
            if(!(y[i] == '0'))
            {
              y.erase(y.begin() + i, y.end());
              break;
            }
          }
        }
        pile.push_back((rule ? "" : "<REGLE>::") + x + "::" + y);
        rule = true;
        ic++;
      break;
    
      case FONC:
        rule = false;
        args.clear();
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
        args.clear();
        ic++;
      break;

      case RETURN:
        rule = false;
        x = undefined;
        if(stoi(ins.second))
        {
          x = depiler(pile);
        }
        if(isTab(x))
        {
          var[var.size() - 2]["<VALEUR_RETOUR>"] = x;
          tab[tab.size() - 2][rToVect(x, "::")[0]] = tab[tab.size() - 1][rToVect(x, "::")[0]];
        }
        pile.push_back(x);
        ic++;
      break;

      case ARG:
        rule = false;
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
        x = depiler(pile);
        if(isNumber(x) && x.find(".") != string::npos)
        {
          for(int i = x.size() - 1; i >= 0; i--)
          {
            if(!(x[i] == '0'))
            {
              x.erase(x.begin() + i, x.end());
              break;
            }
          }
        }
        cout << toStdStr(x);
        ic++;
      break;

      case SHA:
        shaMode = stoi(ins.second);
        ic++;
      break;

      case IN :
        rule = false;
        var[var.size() - 1][ins.second] = getIn(shaMode);
        ic++;
        shaMode = false;
      break;

      case PASS:
        rule = false;
        if(ic > 0 && instructions[ic - 1].first != SHA)
          shaMode = true;
        x = getpass(shaMode);
        if(!isNumber(x) && !isBool(x))
          var[var.size() - 1][ins.second] = toStr(x);
        ic++;       
        shaMode = false; 
      break;
    }
    if(var.size() > 1)
    {
      if(ins.first == RETURN || ic == stoi(var[var.size() - 1]["<RETOUR>"]))
      {
        ic = stoi(var[var.size() - 1]["<SAUT_RETOUR>"]);
        var.pop_back();
        tab.pop_back();
        files.pop_back();
      }
    }
  }
  //cout << endl << "=====================" << endl;  
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
    /*cout << " ________________________________________" << endl;
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
    cout << " `````````````````````````````````````````" << endl;*/
    atexit(&exitFunc);
    if(argc > 1) 
    {
      string name = argv[1];
      if(name.find(".rpp") == string::npos)
        name += ".rpp";
      handleIncludes(name);
      yyin = fopen("tmpCompil.rppx", "r");
      yyparse();  
      fclose(yyin);
      remove("tmpCompil.rppx");
      print_program(name);
      if(argc > 2 && !strcmp(argv[2], "compile"))
        compile(name);
      else
        run_program();
    }				
    else
    {
      yyparse();
    }
    return 0;
}