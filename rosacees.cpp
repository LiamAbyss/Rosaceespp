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
      cout << "Erreur : La variable " << f.second << " n'est pas définie." << endl;
    }
    else if(f.first == "impossible")
    {
      cout << "Erreur : " << f.second << " n'est pas autorisé." << endl;
    }
    else if(f.first == "function")
    {
      cout << "Erreur : " << f.second << " n'est pas une fonction." << endl;
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
  if(s.empty()) return s;
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
  if(s.empty()) return s;
  s = to_string(stof(toStdStr(s)));
  return s;
}

bool isNumber(string s)
{
  if(s.empty()) return false;
  char* p;
  strtod(s.c_str(), &p);
  return *p == 0;
}

bool isBool(string s)
{
  return (s == True || s == False);
}

bool isFunction(string s)
{
  if(s.find("::") != string::npos)
  {
    if(s.substr(0, s.find("::")) == "<FONC>")
      return true;
  }
  return false;  
}

bool isRule(string s)
{
  if(s.find("::") != string::npos)
  {
    if(s.substr(0, s.find("::")) == "<REGLE>")
      return true;
  }
  return false;
}

bool canNumber(string s)
{
  if(s.empty()) return false;
  return isNumber(toStdStr(s));
}

bool doesExist(std::map<std::string, std::string> &var, string s)
{
  if(s.empty()) return false;
  return (isDefined(var, s) || isString(s) || isNumber(s) || isBool(s));
}

bool isDefined(std::map<std::string, std::string> &var, string s)
{
  if(s.empty()) return false;
  return (var.find(s) != var.end() && var[s] != undefined);
}

string compare(string &a, string &b, string &c)
{
  if(isNumber(a))
  {
    if(isNumber(b))
    {
      if(c == "==")
        return ((stof(a) == stof(b))? True : False);
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

vector<string> rToVect(string s, string delimiter)
{
  size_t pos = 0;
  string token;
  vector<string> res;
  while ((pos = s.find(delimiter)) != string::npos)
  {
    token = s.substr(0, pos);
    if(res.size() && res[0] == "<REGLE>")
      res[0] = token;
    else if(res.size() && res[0] == "<FONC>")
      res[0] = token;
    else
      res.push_back(token);
    s.erase(0, pos + delimiter.length());
  }
  if(!s.empty())
    res.push_back(s);
  return res;
}

string calc(string a, string b, string c)
{
  if(c == "+")
  {
    return add(a, b);
  }
  else if(c == "*")
  {
    return product(a, b);
  }
}

string add(string a, string b)
{
  double d = 0;
  if(isString(a))
  {
    a = toStdStr(a) + toStdStr(b);
    return toStr(a);
  }
  else if(isString(b))
  {
    if(isNumber(a) && canNumber(b))
    {
      d = stof(a);
      d += stof(toNbr(b));
      return to_string(d);
    }
    else
    {
      a = toStdStr(a) + toStdStr(b);
      return toStr(a);
    }
  }
  else
  {
    if(isBool(a))
    {
      if(isBool(b))
      {
        return ((((a == True)? 1 : 0) + ((b == True)? 1 : 0))? True : False);
      }
      else
      {
        d = ((a == True)? 1 : 0) + stof(toNbr(b));
        return to_string(d);
      }
    }
    else if(isBool(b))
    {
      d = stof(a) + ((b == True)? 1 : 0);
      return to_string(d);
    }
    else
    {
      d = stof(a) + stof(b);
      return to_string(d);
    }
  }
}

string product(string a, string b)
{
  double d = 0;
  string res;
  string s = a;
  if(isString(a))
  {
    if(isRule(b))
    {
      a = toStdStr(a);
      vector<string> rule = rToVect(b, "::");
      /*for(auto f : rule)
      {
         cout << f << endl;
      }*/
      auto pos = find(rule.begin(), rule.end(), rule[0])+1;
      if(rule.size() <= 1)
      {
        for(auto s : a)
        {
          res += s + toStdStr(rule[0]);
        }
      }
      else 
      {
        if(isString(rule[0]))
        {
          if(isNumber(rule[1]))
          {
            for(int i = 0; i < a.size(); i++)
            {
              res += a[i] + (find(pos, rule.end(), to_string(i)) != rule.end() ? toStdStr(rule[0]) : "");
            }
          }
          else if(isString(rule[1]))
          {
            vector<size_t> p;
            for(int i = 1; i < rule.size(); i++)
            {
              while(s.find(toStdStr(rule[i])) != string::npos)
              {
                p.push_back(s.find(toStdStr(rule[i])) + toStdStr(rule[i]).size() - 2);
                s[s.find(toStdStr(rule[i]))]++;
              }
            }
            for(int i = 0; i < a.size(); i++)
            {
              res += a[i] + (find(p.begin(), p.end(), i) != p.end() ? toStdStr(rule[0]) : "");
            }            
          }
        }
        else if(isNumber(rule[0]))
        {
          for(int i = 0; i < a.size(); i++)
          {
            if(isNumber(rule[1]))
            {
              if(find(pos, rule.end(), to_string(i)) != rule.end())
                for(int j = 0; j < stof(rule[0]); j++)
                {
                  res += a[i];
                }
              else
                res += a[i];
            }
            else if(isString(rule[1]))
            {
              vector<size_t> p;
              for(int i = 1; i < rule.size(); i++)
              {
                while(s.find(toStdStr(rule[i])) != string::npos)
                {
                  p.push_back(s.find(toStdStr(rule[i])) + toStdStr(rule[i]).size() - 2);
                  s[s.find(toStdStr(rule[i]))]++;
                }
              }
              if(find(p.begin(), p.end(), i) != p.end())
                for(int j = 0; j < stof(rule[0]); j++)
                {
                  res += a[i];
                }
              else
                res += a[i];
            }
          }
        }
      }
    }
    else if(isString(b))
    {
      for(auto s : toStdStr(a))
      {
        res += s + toStdStr(b);
      }
    }
    else if(isNumber(b))
    {
      for(int i = 0; i < stof(b); i++)
        res += toStdStr(a);
    }
    return toStr(res);
  }
  else if(isString(b))
  {
    s = b;
    if(isRule(a))
    {
      b = toStdStr(b);
      vector<string> rule = rToVect(a, "::");

      auto pos = find(rule.begin(), rule.end(), rule[0])+1;
      if(rule.size() <= 1)
      {
        for(auto s : b)
        {
          res += toStdStr(rule[0]) + s;
        }
      }
      else 
      {
        if(isString(rule[0]))
        {
          if(isNumber(rule[1]))
          {
            for(int i = 0; i < b.size(); i++)
            {
              res += (find(pos, rule.end(), to_string(i)) != rule.end() ? toStdStr(rule[0]) : "") + b[i];
            }
          }
          else if(isString(rule[1]))
          {
            vector<size_t> p;
            for(int i = 1; i < rule.size(); i++)
            {
              while(s.find(toStdStr(rule[i])) != string::npos)
              {
                p.push_back(s.find(toStdStr(rule[i])) + toStdStr(rule[i]).size() - 2);
                s[s.find(toStdStr(rule[i]))]++;
              }
            }
            for(int i = 0; i < b.size(); i++)
            {
              res += (find(p.begin(), p.end(), i) != p.end() ? toStdStr(rule[0]) : "") + b[i];
            }                
          }
        }
        else if(isNumber(rule[0]))
        {
          for(int i = 0; i < b.size(); i++)
          {
            if(isNumber(rule[1]))
            {
              if(find(pos, rule.end(), to_string(i)) != rule.end())
                for(int j = 0; j < stof(rule[0]); j++)
                {
                  res += b[i];
                }
              else
                res += b[i];
            }
            else if(isString(rule[1]))
            {
              vector<size_t> p;
              for(int i = 1; i < rule.size(); i++)
              {
                while(s.find(toStdStr(rule[i])) != string::npos)
                {
                  p.push_back(s.find(toStdStr(rule[i])) + toStdStr(rule[i]).size() - 2);
                  s[s.find(toStdStr(rule[i]))]++;
                }
              }
              if(find(p.begin(), p.end(), i) != p.end())
                for(int j = 0; j < stof(rule[0]); j++)
                {
                  res += b[i];
                }
              else
                res += b[i];
            }
          }
        }
      }
    }
    else if(isNumber(a))
    {
      if(canNumber(b))
      {
        d = stof(a);
        d *= stof(toNbr(b));
        return to_string(d);
      }
      else
      {
        for(int i = 0; i < stof(a); i++)
          res += toStdStr(b);
      }
      
    }
    return toStr(res);
  }
  else if(isRule(a) && isRule(b))
  {
    return a+";"+b;
  }
  else
  {
    if(isBool(a))
    {
      if(isBool(b))
      {
        return ((((a == True)? 1 : 0) * ((b == True)? 1 : 0))? True : False);
      }
      else if(isRule(b))
      {
        if(a == True)
          return b;
        else
          return "1";
      }
      else
      {
        d = ((a == True)? 1 : 0) * stof(toNbr(b));
        return to_string(d);
      }
    }
    else if(isBool(b))
    {
      if(isRule(a))
      {
        if(b == True)
          return a;
        else
          return "1";
      }
      d = stof(a) * ((b == True)? 1 : 0);
      return to_string(d);
    }
    else
    {
      d = stof(a) * stof(b);
      return to_string(d);
    }
  }
}

void pause()
{
  cout << "Appuyez sur entrée pour continuer..." << endl;
  cin.ignore();
}