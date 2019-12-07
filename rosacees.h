#include <iostream>
#include <cstdlib>
#include <cmath>    
#include <fstream>
#include <string.h>
#include <string>
#include <algorithm>
#include <map>
#include <vector>

using namespace std;

extern void yyrestart ( FILE *input_file );
extern int yylex ();
extern FILE *yyin;
extern int line;
extern vector<string> linefile;

#define undefined "undefined"
#define none "none"
#define True "vrai"
#define False "faux"

string getIn(bool shaMode);

string getpass(bool shaMode = true, string prompt="", bool show_asterisk=true);

void clearConsole();

void showVars(std::map<std::string, std::string> &var);

void error(vector<string> e);

bool isString(string s);

void removeFromStr(string &s, char c);

string toStdStr(string s);

string toStr(string s);

string toNbr(string s);

bool isNumber(string s);

bool canNumber(string s);

bool doesExist(std::map<std::string, std::string> &var, string s);

bool isDefined(std::map<std::string, std::string> &var, string s);

string compare(string &a, string &b, string &c);

vector<string> rToVect(string s, string delimiter);

string replace(string& s, string a, string b);

string type(string s);

bool isBool(string s);

bool isRule(string s);

bool isFile(string s);

bool isTab(string s);

bool isFunction(string s);

string calc(string a, string b, string c);

string add(string a, string b);

string product(string a, string b);

string divide(string a, string b);

string substract(string a, string b);

void pause();