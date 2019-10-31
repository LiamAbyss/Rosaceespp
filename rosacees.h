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

void showVars(std::map<std::string, std::string> &var);

void error(std::map<std::string, std::string> &var, multimap<string, string> errors);

void erase(std::map<std::string, std::string> &var, string s);

bool isString(std::map<std::string, std::string> &var, string s);

void removeFromStr(std::map<std::string, std::string> &var, string &s, char c);

string toStdStr(std::map<std::string, std::string> &var, string s);

string toStr(std::map<std::string, std::string> &var, string s);

string toNbr(std::map<std::string, std::string> &var, string s);

bool isNumber(std::map<std::string, std::string> &var, string s);

bool canNumber(std::map<std::string, std::string> &var, string s);

bool doesExist(std::map<std::string, std::string> &var, string s);

bool isDefined(std::map<std::string, std::string> &var, string s);