#ifndef __TOKENS_H__
#define __TOKENS_H__

#include <iostream>
#include <string>
#include <map>
#include <cctype>

#include "my_functions.h"
#include "error_handling.h"

extern std::map<std::string, int> registers;
extern std::map<std::string, int> operators;

enum TokenType
{
    DEFINE_BYTE,
	PLUS,
	EQUALS,
	OPENBRACKETS,
	CLOSEBRACKETS,

	NUMERICLITERAL,

	DECLABEL,
	LABEL,

	REGISTER,

	OPERATOR,

    FILENAME,
	CURRENT_LINE,
    NEWLINE,
    ENDOFFILE,
    ENDOFPROGRAM,
    ERROR
};

extern const char * TokenTypeNames[];

struct Token
{
    TokenType type;
    std::string name;
    int value;
    Token(TokenType type, std::string name);
    Token(TokenType type, std::string name, int value);
    ~Token();

    friend std::ostream& operator<<(std::ostream& os, Token& tk);
};

// extern std::ostream& operator<<(std::ostream& os, Token& tk);

Result<std::deque<Token>> tokenize(std::string srcCode, std::string filename);

#endif