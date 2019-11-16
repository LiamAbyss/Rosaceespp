#include <iostream>
#include <cstdlib>
#include <cmath>    
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

#define undefined "undefined"
#define none "none"
#define True "vrai"
#define False "faux"

void showVars(std::map<std::string, std::string> &var);

void error(multimap<string, string> errors);

void erase(std::map<std::string, std::string> &var, string s);

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

bool isBool(string s);

bool isRule(string s);

string calc(string a, string b, string c);

string add(string a, string b);

string product(string a, string b);