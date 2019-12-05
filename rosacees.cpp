#include "rosacees.h"
#include "sha256.h"
#include <Windows.h>
using namespace std;

string getIn(bool shaMode)
{
  string res;
  cin >> res;
  if(shaMode)
    return toStr(sha256(res));
  else if(!isNumber(res) && !isBool(res))
    return toStr(res);
  else 
    return res;  
}

string getpass(bool shaMode, string prompt, bool show_asterisk)
{
  if(!shaMode)
    cout << "ATTENTION : La chaine de caractères que vous entrerez ne sera pas chiffrée !" << endl;
  const char BACKSPACE=8;
  const char RETURN=13;

  string password;
  unsigned char ch=0;

  cout <<prompt;

  DWORD con_mode;
  DWORD dwRead;

  HANDLE hIn=GetStdHandle(STD_INPUT_HANDLE);

  GetConsoleMode( hIn, &con_mode );
  SetConsoleMode( hIn, con_mode & ~(ENABLE_ECHO_INPUT | ENABLE_LINE_INPUT) );

  while(ReadConsoleA( hIn, &ch, 1, &dwRead, NULL) && ch !=RETURN)
  {
    if(ch==BACKSPACE)
    {
      if(password.length()!=0)
        {
          if(show_asterisk)
              cout <<"\b \b";
          password.resize(password.length()-1);
        }
    }
    else
    {
      password+=ch;
      if(show_asterisk)
          cout <<'*';
    }
  }
  cout <<endl;
  if(shaMode)
    return toStr(sha256(password));
  else 
    return toStr(password);
}

void showVars(std::map<std::string, std::string> &var)
{
  for(auto f : var)
  {
      cout << f.first << " : " << f.second << endl;
  }
}

void error(vector<string> e)
{
  for(auto s : e)
    cout << "| " << s << endl;
  exit(-1);
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

string type(string s)
{
  if(isBool(s))
    return "\"<BOOL>\"";
  else if(isString(s))
    return "\"<STR>\"";
  else if(isNumber(s))
    return "\"<NUM>\"";
  else if(isFunction(s))
    return "\"<FONC>\"";
  else if(isTab(s))
    return "\"<TAB>\"";
  else if(isFile(s))
    return "\"<FICHIER>\"";
  else
    return undefined;
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

bool isFile(string s)
{
  if(s.find("::") != string::npos)
  {
    if(s.substr(0, s.find("::")) == "<FICHIER>")
      return true;
  }
  return false;  
}

bool isTab(string s)
{
  if(s.find("::") != string::npos)
  {
    if(s.substr(0, s.find("::")) == "<TAB>")
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
  if(isRule(a) || isRule(b))
  {
    error({"Erreur : Impossible de comparer des règles."});
  }
  else if(isNumber(a))
  {
    if(isNumber(b))
    {
      if(c == "==")
        return ((stof(a) == stof(b))? True : False);
      else if(c == "!=")
        return ((stof(a) != stof(b))? True : False);
      else if(c == "<")
        return ((stof(a) < stof(b))? True : False);
      else if(c == ">")
        return ((stof(a) > stof(b))? True : False);
      else if(c == "<=")
        return ((stof(a) <= stof(b))? True : False);
      else if(c == ">=")
        return ((stof(a) >= stof(b))? True : False);
    }
    else if(canNumber(b))
    {
      if(c == "==")
        return ((a == toNbr(toStdStr(b)))? True : False);
      else if(c == "!=")
        return ((a != toNbr(toStdStr(b)))? True : False);
      else if(c == "<")
        return ((stof(a) < stof(toStdStr(b)))? True : False);
      else if(c == ">")
        return ((stof(a) > stof(toStdStr(b)))? True : False);
      else if(c == "<=")
        return ((stof(a) <= stof(toStdStr(b)))? True : False);
      else if(c == ">=")
        return ((stof(a) >= stof(toStdStr(b)))? True : False);
    }
    else if(isBool(b))
    {
      if(c == "==")
        return (((stof(a) && b == True) || (!stof(a) && b == False))? True : False);
      else if(c == "!=")
        return (((stof(a) && b != True) || (!stof(a) && b == True))? True : False);
      else if(c == "<")
        return ((stof(a) < (b == True ? 1 : 0)) ? True : False);
      else if(c == ">")
        return ((stof(a) > (b == True ? 1 : 0)) ? True : False);
      else if(c == "<=")
        return ((stof(a) <= (b == True ? 1 : 0))? True : False);
      else if(c == ">=")
        return ((stof(a) >= (b == True ? 1 : 0))? True : False);
    }
  }
  else if(isNumber(b))
  {
    if(canNumber(a))
    {
      if(c == "==")
        return ((b == toNbr(toStdStr(a)))? True : False);
      else if(c == "!=")
        return ((b != toNbr(toStdStr(a)))? True : False);
      else if(c == "<")
        return (stof(toStdStr(a)) < (stof(b))? True : False);
      else if(c == ">")
        return (stof(toStdStr(a)) > (stof(b))? True : False);
      else if(c == "<=")
        return (stof(toStdStr(a)) <= (stof(b))? True : False);
      else if(c == ">=")
        return (stof(toStdStr(a)) >= (stof(b))? True : False);
    }
    else if(isBool(a))
    {
      if(c == "==")
        return (((stof(b) && a == True) || (!stof(b) && a == False))? True : False);
      else if(c == "!=")
        return (((stof(b) && a != True) || (!stof(b) && a != False))? True : False);
      else if(c == "<")
        return (((a == True ? 1 : 0) < stof(b)) ? True : False);
      else if(c == ">")
        return (((a == True ? 1 : 0) > stof(b)) ? True : False);
      else if(c == "<=")
        return ((a == True ? 1 : 0) <= (stof(b))? True : False);
      else if(c == ">=")
        return ((a == True ? 1 : 0) >= (stof(b))? True : False);
    }
  }
  else if(isBool(a))
  {
    if(isBool(b))
    {
      if(c == "==")
        return ((a == b)? True : False);
      else if(c == "!=")
        return ((a != b)? True : False);
      else if(c == "<")
        return (((a == True ? 1 : 0) < (b == True ? 1 : 0)) ? True : False);
      else if(c == ">")
        return (((a == True ? 1 : 0) > (b == True ? 1 : 0)) ? True : False);
      else if(c == "<=")
        return (((a == True ? 1 : 0) <= (b == True ? 1 : 0)) ? True : False);
      else if(c == ">=")
        return (((a == True ? 1 : 0) >= (b == True ? 1 : 0)) ? True : False);
    }
    else
    {
      if(c == "==")
        return (((a == True && b.size()) || (a == False && b.empty()))? True : False);
      else if(c == "!=")
        return (((a != True && b.size()) || (a != False && b.empty()))? True : False);
      else if(c == "<")
        return (((a == True ? 1 : 0) < (b.size() ? 1 : 0)) ? True : False);
      else if(c == ">")
        return (((a == True ? 1 : 0) > (b.size() ? 1 : 0)) ? True : False);
      else if(c == "<=")
        return (((a == True ? 1 : 0) <= (b.size() ? 1 : 0)) ? True : False);
      else if(c == ">=")
        return (((a == True ? 1 : 0) >= (b.size() ? 1 : 0)) ? True : False);
    }
  }
  else if(isBool(b))
  {
    if(c == "==")
      return (((b == True && a.size()) || (b == False && a.empty()))? True : False);
    else if(c == "!=")
      return (((b != True && a.size()) || (b != False && a.empty()))? True : False);
    else if(c == "<")
      return (((a.size() ? 1 : 0) < (b == True ? 1 : 0)) ? True : False);
    else if(c == ">")
      return (((a.size() ? 1 : 0) > (b == True ? 1 : 0)) ? True : False);
    else if(c == "<=")
      return (((a.size() ? 1 : 0) <= (b == True ? 1 : 0)) ? True : False);
    else if(c == ">=")
      return (((a.size() ? 1 : 0) >= (b == True ? 1 : 0)) ? True : False);
  }
  else if(isString(a) && isString(b))
  {
    if(c == "==")
      return ((b == a)? True : False);
    else if(c == "!=")
      return ((b != a)? True : False);
    else if(c == "<")
      return ((b < a)? True : False);
    else if(c == ">")
      return ((b > a)? True : False);
    else if(c == "<=")
      return ((b < a)? True : False);
    else if(c == ">=")
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
    else if(res.size() && res[0] == "<TAB>")
      res[0] = token;
    else if(res.size() && res[0] == "<FICHIER>")
      res[0] = token;
    else
      res.push_back(token);
    s.erase(0, pos + delimiter.length());
  }
  if(res.size() && res[0] == "<REGLE>")
    res[0] = s;
  else if(res.size() && res[0] == "<FONC>")
    res[0] = s;
  else if(res.size() && res[0] == "<TAB>")
    res[0] = s;
  else if(res.size() && res[0] == "<FICHIER>")
    res[0] = s;
  else if(!s.empty())
    res.push_back(s);
  return res;
}

string replace(string& s, string a,  string b)
{
	return(s.replace(s.find(a), a.length(), b));
}

string eraseSubStr(string& mainStr, string toErase)
{
	// Search for the substring in string
	size_t pos = mainStr.find(toErase);
 
	if (pos != std::string::npos)
	{
		// If found then erase it from string
		mainStr.erase(pos, toErase.length());
	}
  return mainStr;
}

string calc(string a, string b, string c)
{
  if(c == "+")
  {
    return add(a, b);
  }
  else if(c == "-")
  {
    return substract(a, b);
  }
  else if(c == "*")
  {
    return product(a, b);
  }
  else if(c == "/")
  {
    return divide(a, b);
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
    else if(isRule(a) && isRule(b))
    {
      return a+";"+b;
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
      res = a;
      vector<string> ruleSet = rToVect(b, ";");
      for(auto r : ruleSet)
      {
        a = toStr(res);
        s = a;
        res = "";
        a = toStdStr(a);
        vector<string> rule = rToVect(r, "::");
        /*for(auto f : rule)
        {
          cout << f << endl;
        }*/
        auto pos = find(rule.begin(), rule.end(), rule[0])+1;
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
            if(isNumber(rule[1]))
            {
              for(int i = 0; i < a.size(); i++)
              {
                if(find(pos, rule.end(), to_string(i)) != rule.end())
                  for(int j = 0; j < stof(rule[0]); j++)
                  {
                    res += a[i];
                  }
                else
                  res += a[i];
              }
            }
            else if(isString(rule[1]))
            {
              vector<size_t> p;
              for(int j = 1; j < rule.size(); j++)
              {
                while(s.find(toStdStr(rule[j])) != string::npos)
                {
                  p.push_back(s.find(toStdStr(rule[j])) + toStdStr(rule[j]).size() - 2);
                  s[s.find(toStdStr(rule[j]))]++;
                }
              }
              for(int i = 0; i < a.size(); i++)
              {
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
    }
    else if(isString(b))
    {
      for(auto st : toStdStr(a))
      {
        res += st + toStdStr(b);
      }
    }
    else if(isNumber(b))
    {
      for(auto c : toStdStr(a))
        for(int i = 0; i < stof(b); i++)
          res += c;
    }
    return toStr(res);
  }
  else if(isString(b))
  {
    s = b;
    if(isRule(a))
    {
      res = b;
      vector<string> ruleSet = rToVect(b, ";");
      for(auto r : ruleSet)
      {
        b = toStr(res);
        s = b;
        res = "";
        b = toStdStr(b);
        vector<string> rule = rToVect(a, "::");
        auto pos = find(rule.begin(), rule.end(), rule[0])+1;
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
            if(isNumber(rule[1]))
            {
              for(int i = 0; i < b.size(); i++)
              {
                if(find(pos, rule.end(), to_string(i)) != rule.end())
                  for(int j = 0; j < stof(rule[0]); j++)
                  {
                    res += b[i];
                  }
                else
                  res += b[i];
              }
            }
            else if(isString(rule[1]))
            {
              vector<size_t> p;
              for(int j = 1; j < rule.size(); j++)
              {
                while(s.find(toStdStr(rule[j])) != string::npos)
                {
                  p.push_back(s.find(toStdStr(rule[j])) + toStdStr(rule[j]).size() - 2);
                  s[s.find(toStdStr(rule[j]))]++;
                }
              }
              for(int i = 0; i < b.size(); i++)
              {
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

string divide(string a, string b)
{
  double d = 0;
  string res;
  string s = a;
  if(isString(a))
  {
    if(isRule(b))
    {
      res = a;
      vector<string> ruleSet = rToVect(b, ";");
      for(auto r : ruleSet)
      {
        a = toStr(res);
        s = a;
        res = "";
        a = toStdStr(a);
        vector<string> rule = rToVect(r, "::");
        /*for(auto f : rule)
        {
          cout << f << endl;
        }*/
        auto pos = find(rule.begin(), rule.end(), rule[0])+1;
        {
          if(isString(rule[0]))
          {
            if(isNumber(rule[1]))
            {
              for(int i = 0; i < s.size(); i++)
              {
                s.replace(i, 1, (find(pos, rule.end(), to_string(i)) != rule.end() ? toStdStr(rule[0]) : (string)""+s[i]));
              }
              res = s;
            }
            else if(isString(rule[1]))
            {
              vector<size_t> p;
              for(int i = 1; i < rule.size(); i++)
              {
                while(s.find(toStdStr(rule[i])) != string::npos)
                {
                  replace(s, toStdStr(rule[i]), toStdStr(rule[0]));
                }
              }
              res = s; 
            }
          }
          else if(isNumber(rule[0]))
          {
            error({"Erreur : Impossible d'effectuer une division régulière par une règle numérique."});
          }
        }
      }
    }
    else if(isString(b))
    {
      s = toStdStr(a);
      while(s.find(toStdStr(b)) != string::npos)
        eraseSubStr(s, toStdStr(b));
      res = s;
    }
    else if(isNumber(b))
    {
      s = toStdStr(a);
      for(int i = 0; i < s.size() / stoi(b); i++)
        res += s[i];
    }
    return toStr(res);
  }
  else if(isString(b))
  {
    s = b;
    if(isRule(a))
    {
      error({"Erreur : Impossible de diviser une règle."});
    }
    else if(isNumber(a))
    {
      if(canNumber(b))
      {
        d = stof(a);
        if(!stof(toNbr(b)))
          error({"Erreur : Division par zéro."});
        d /= stof(toNbr(b));
        return to_string(d);
      }
      else
      {
        error({"Erreur : Impossible de diviser un nombre par une chaîne."});
      }
    }
    else
    {
      d = stof(a);
      if(b == False)
        error({"Erreur : Division par zéro."});
      return to_string(d);
    }    
  }
  else if(isNumber(a) && isRule(b))
  {
    error({"Erreur : Impossible d'effectuer une division régulière sur un nombre."});
  }
  else
  {
    if(isBool(a))
    {
      if(isBool(b))
      {
        if(b == False)
          error({"Erreur : Division par zéro."});
        return ((((a == True)? 1 : 0) / ((b == True)? 1 : 0))? True : False);
      }
      else if(isRule(b))
      {
        error({"Erreur : Impossible d'effectuer une division régulière sur un booléen."});
      }
      else
      {
        d = ((a == True)? 1 : 0) * stof(toNbr(b));
        return to_string(d);
      }
    }
    else if(isBool(b))
    {
      if(b == False)
        error({"Erreur : Division par zéro."});
      if(isRule(a))
      {
        return a;
      }
      d = stof(a);
      return to_string(d);
    }
    else
    {
      if(!stof(b))
        error({"Erreur : Division par zéro."});
      d = stof(a) / stof(b);
      return to_string(d);
    }
  }
}

string substract(string a, string b)
{
  double d = 0;
  string res;
  if(isString(a))
  {
    if(isString(b))
    {
      res = toStdStr(a);
      eraseSubStr(res, toStdStr(b));
    }
    return toStr(res);
  }
  else if(isString(b))
  {
    if(isNumber(a) && canNumber(b))
    {
      d = stof(a);
      d -= stof(toNbr(b));
      return to_string(d);
    }
    else
    {
      error({"Erreur : Impossible de soustraire une chaîne à un nombre."});
    }
  }
  else
  {
    if(isBool(a))
    {
      if(isBool(b))
      {
        return ((((a == True)? 1 : 0) - ((b == True)? 1 : 0))? True : False);
      }
      else
      {
        d = ((a == True)? 1 : 0) - stof(toNbr(b));
        return to_string(d);
      }
    }
    else if(isBool(b))
    {
      d = stof(a) - ((b == True)? 1 : 0);
      return to_string(d);
    }
    else if(isRule(a) && isRule(b))
    {
      error({"Erreur : Impossible d'effectuer une soustraction régulière sur une règle."});
    }
    else
    {
      d = stof(a) - stof(b);
      return to_string(d);
    }
  }
}

void pause()
{
  cout << "Appuyez sur entrée pour continuer..." << endl;
  cin.ignore();
}