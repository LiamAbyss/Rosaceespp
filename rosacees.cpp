#include "rosacees.h"

using namespace std;

void showVars(std::map<std::string, std::string> &var)
{
    for(auto f : var)
    {
        cout << f.first << " : " << f.second << endl;
    }
}

void error(std::map<std::string, std::string> &var, multimap<string, string> errors)
  {
    for(auto &f : errors)
    {
      if(f.first == undefined)
      {
        cout << "Attention : La variable " << f.second << " n'est pas définie." << endl;
      }
    }
  }

  void erase(std::map<std::string, std::string> &var, string s)
  {
    var.erase(var.find(s));
  }

  bool isString(std::map<std::string, std::string> &var, string s)
  {
    return (s[0] == '"' && s[s.size()-1] == '"');
  }

  void removeFromStr(std::map<std::string, std::string> &var, string &s, char c)
  {
    s.erase(std::remove(s.begin(), s.end(), c), s.end());
  }

  string toStdStr(std::map<std::string, std::string> &var, string s)
  {
    if(isString(var, s))
    {
      s.erase(s.begin(), s.begin() + 1);
      s.erase(s.end() - 1, s.end());
    }
    return s;
  }

  string toStr(std::map<std::string, std::string> &var, string s)
  {
    s = "\"" + toStdStr(var, s) + "\"";
    return s;
  }

  string toNbr(std::map<std::string, std::string> &var, string s)
  {
    s = to_string(stof(toStdStr(var, s)));
    return s;
  }

  bool isNumber(std::map<std::string, std::string> &var, string s)
  {
      char* p;
      strtod(s.c_str(), &p);
      return *p == 0;
  }

  bool canNumber(std::map<std::string, std::string> &var, string s)
  {
      return isNumber(var, toStdStr(var, s));
  }

  bool doesExist(std::map<std::string, std::string> &var, string s)
  {
    return ((var.find(s) != var.end() && var[s] != undefined) || isString(var, s) || isNumber(var, s));
  }

  bool isDefined(std::map<std::string, std::string> &var, string s)
  {
    return (var.find(s) != var.end() && var[s] != undefined);
  }