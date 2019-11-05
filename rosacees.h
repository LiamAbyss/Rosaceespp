#include <iostream>
#include <cstdlib>
#include <cmath>    
#include <string.h>
#include <string>
#include <algorithm>
#include <map>
#include <vector>
using namespace std;

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

bool ifcond(vector<bool> &si);

string compare(string &a, string &b, string &c);

bool isBool(string s);