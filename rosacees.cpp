#include "rosacees.h"

using namespace std;

void showVars(std::map<std::string, std::string> &var)
{
  for(auto f : var)
  {
      cout << f.first << " : " << f.second << endl;
  }
}

void error(multimap<string, string> errors)
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

bool isString(string s)
{
  return (s[0] == '"' && s[s.size()-1] == '"');
}

void removeFromStr(string &s, char c)
{
  s.erase(std::remove(s.begin(), s.end(), c), s.end());
}

string toStdStr(string s)
{
  if(isString(s))
  {
    s.erase(s.begin(), s.begin() + 1);
    s.erase(s.end() - 1, s.end());
  }
  return s;
}

string toStr(string s)
{
  s = "\"" + toStdStr(s) + "\"";
  return s;
}

string toNbr(string s)
{
  s = to_string(stof(toStdStr(s)));
  return s;
}

bool isNumber(string s)
{
    char* p;
    strtod(s.c_str(), &p);
    return *p == 0;
}

bool isBool(string s)
{
  return (s == True || s == False);
}

bool canNumber(string s)
{
    return isNumber(toStdStr(s));
}

bool doesExist(std::map<std::string, std::string> &var, string s)
{
  return (isDefined(var, s) || isString(s) || isNumber(s) || isBool(s));
}

bool isDefined(std::map<std::string, std::string> &var, string s)
{
  return (var.find(s) != var.end() && var[s] != undefined);
}

bool ifcond(vector<pair<bool, string>> &condBlock)
{
  return !condBlock.size() || (find(condBlock.begin(), condBlock.end(), make_pair(false, (string)"while")) == condBlock.end() && find(condBlock.begin(), condBlock.end(), make_pair(false, (string)"if")) == condBlock.end());
}

string compare(string &a, string &b, string &c)
{
  if(isNumber(a))
  {
    if(isNumber(b))
    {
      if(c == "==")
        return ((a == b)? True : False);
      else if(c == "<")
        return ((stof(a) < stof(b))? True : False);
    }
    else if(canNumber(b))
    {
      if(c == "==")
        return ((a == toNbr(toStdStr(b)))? True : False);
      else if(c == "<")
        return ((stof(a) < stof(toStdStr(b)))? True : False);
    }
    else if(isBool(b))
    {
      if(c == "==")
        return (((stoi(a) && b == True) || (!stoi(a) && b == False))? True : False);
    }
  }
  else if(isNumber(b))
  {
    if(canNumber(a))
    {
      if(c == "==")
        return ((b == toNbr(toStdStr(a)))? True : False);
      else if(c == "<")
        return ((stof(b) < stof(toStdStr(a)))? True : False);
    }
    else if(isBool(a))
    {
      if(c == "==")
        return (((stoi(b) && a == True) || (!stoi(b) && a == False))? True : False);
    }
  }
  else if(isBool(a))
  {
    if(isBool(b))
    {
      if(c == "==")
        return ((a == b)? True : False);
    }
    else
    {
      if(c == "==")
        return (((a == True && b.size()) || (a == False && b.empty()))? True : False);
    }
    
  }
  else if(isBool(b))
  {
    if(c == "==")
      return (((b == True && a.size()) || (b == False && a.empty()))? True : False);
  }
  else
  {
    if(c == "==")
      return ((b == a)? True : False);
    else if(c == "<")
      return ((b < a)? True : False);
  }
}

void addCondBlock(vector<pair<bool, string>> &condBlock, vector<int> &lineBlock, string a, string cas, int &line)
{
  if(ifcond(condBlock)) cout << cas << " " << a << endl;
  if(!ifcond(condBlock))
  {
    condBlock.push_back(make_pair(false, cas));
  }
  else if(isString(a))
  {
    if(!toStr(a).empty())
      condBlock.push_back(make_pair(true, cas));
    else
      condBlock.push_back(make_pair(false, cas));
  }
  else if(isNumber(a))
  {
    condBlock.push_back(make_pair(stof(a), cas));
  }
  else
  {
    condBlock.push_back(make_pair(((a == True)? true : false), cas));
  }
  lineBlock.push_back(line);
}

void removeCondBlock(vector<pair<bool, std::string>> &condBlock, vector<int> &lineBlock)
{
  if(condBlock.size())
  {
    if(condBlock[condBlock.size() - 1].second == "while" && ifcond(condBlock))
    {
      rewind(yyin);
      //looking for the char where this while begins
      int nbLine = 1;
      char c;
      while((c = fgetc(yyin)) != EOF)
      {
        if(c == '\n') nbLine++;
        if(nbLine == lineBlock[lineBlock.size() - 1]) break;
      }
      yyrestart(yyin);
      line = lineBlock[lineBlock.size() - 1];
    }
    else
    {
      condBlock.pop_back(); 
      lineBlock.pop_back();
      if(ifcond(condBlock)) cout << "fin" << endl; 
    }
    
  }
}