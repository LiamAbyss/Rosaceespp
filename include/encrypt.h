#include <string>
#include <sstream>
#include <iostream>
#include <vector>
#include <string.h>
#include <stdio.h>
#include <ctype.h>

std::string encrypt(std::string msg, std::string key);
std::string decrypt(std::string encrypted_msg, std::string key);

int index(char c);
std::string extend_key(std::string& msg, std::string& key);
std::string encrypt_vigenere(std::string& msg, std::string& key);
std::string decrypt_vigenere(std::string& encryptedMsg, std::string& newKey);

static std::string base64_encode(const std::string &in);
static std::string base64_decode(const std::string &in);