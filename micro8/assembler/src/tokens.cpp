#include "tokens.h"

std::map<std::string, int> registers = {{"r0",0}, {"r1", 1}, {"r2",2}, {"r3",3}};
std::map<std::string, int> operators = {
	{"nop",0x0},
	{"str",0x1},
	{"ldr",0x2},
	{"add",0x3},
	{"sub",0x4},
	{"and",0x5},
	{"or" ,0x6},
	{"eor",0x7},
	{"ror",0x8},
	{"b"  ,0x9},
	{"bn" ,0xa},
	{"bz" ,0xb},
	{"bc" ,0xc},
	{"jsr",0xd},
	{"ret",0xe},
	{"hlt",0xf}
};

const char * TokenTypeNames[] = {
    "DEFINE_BYTE",
	"PLUS",
	"EQUALS",
	"OPENBRACKETS",
	"CLOSEBRACKETS",

	"NUMERICLITERAL",

	"DECLABEL",
	"LABEL",

	"REGISTER",

	"OPERATOR",

    "FILENAME",
	"CURRENT_LINE",
    "NEWLINE",
    "ENDOFFILE",
    "ENDOFPROGRAM",
    "ERROR"
};

Token::Token(TokenType type, std::string name) 
{
    this->type = type;
    this->name = name;
    this->value = -1;
}

Token::Token(TokenType type, std::string name, int value)
{
    this->type = type;
    this->name = name;
    this->value = value;
}

Token::~Token() {}

std::ostream& operator<<(std::ostream& os, Token& tk)
{
    os << "<" << TokenTypeNames[tk.type];

    if(tk.name.size() > 0) os << " '" << tk.name << "'";

    if(tk.value >= 0) os << " " << tk.value;

    os << ">";

    return os;
}

Token TokenError()
{
    return Token(ERROR, "ERROR");
}

// std::ostream& operator<<(std::ostream &os, Token &tk)
// {
// 	if(tk.value>=0)
// 	{
// 		os << "<" << TokenTypeNames[tk.type] << " '" << tk.name << "' " << tk.value << ">";
// 	}
// 	else if(tk.name.size()>0)
// 	{
// 		os << "<" << TokenTypeNames[tk.type] << " '" << tk.name << "'>";
// 	}
// 	else
// 	{
// 		os << "<" << TokenTypeNames[tk.type] << ">";
// 	}

// 	return os;
// }

Result<std::deque<Token>> tokenize(std::string srcCode, std::string filename)
{
    
    Result<std::deque<Token>> res;

    if(srcCode.size() < 0)
    {
        res.exceptions.push_back(Exception(0, std::string(", '")+filename+"'")); // Empty file
        return res ;
    }

    int index = 0, line = 1; // index para percorrer o arquivo,  line para contar as linhas
    std::deque<Token> tokens; // para armazenar os tokens gerados
    tokens.push_back(Token(FILENAME, filename));
    tokens.push_back(Token(CURRENT_LINE, "CL", line));
    while(index < srcCode.size())
    {
        // std::cout << srcCode[index] << std::endl;

        switch(srcCode[index])
        {
            case ' ': // Ignora espaços e tabulações
            case '\t':
            {
                index++;
            }
            break;
            break;
            case '\n': // Adiciona os tokens de linha para futura verificação semântica
            {
                tokens.push_back(Token(NEWLINE, "\\n"));
                line++;
                index++;
                tokens.push_back(Token(CURRENT_LINE, "CL", line));
            }
            break;
            case '/': // verifica se é um comentário
            {
                if((index+1)<srcCode.size() && srcCode[index+1]=='/') // Se for um comentário
                {
                    while(index < srcCode.size() && srcCode[index]!='\n')index++; // Ignora o mesmo
                }
                else // Senão
                {
                    res.exceptions.push_back(Exception(1, ", found at file '"+filename+"' line "+std::to_string(line))); // Armazena a exceção
                    tokens.push_back(TokenError()); // preenche o espalo com umtoken erro e continua
                    while(index < srcCode.size() && srcCode[index]!='\n')index++; // procura uma quebra de linha
                }
            }
            break;
            case '=':
            {
                tokens.push_back(Token(EQUALS, "="));
                index++;
            }
            break;
            case '+':
            {
                tokens.push_back(Token(PLUS, "+"));
                index++;
            }
            break;
            case '[':
            {
                tokens.push_back(Token(OPENBRACKETS, "["));
                index++;
            }
            break;
            case ']':
            {
                tokens.push_back(Token(CLOSEBRACKETS, "]"));
                index++;
            }
            break;
            case '$':
            case '%':
            case '&':
            {
                std::string num = std::string(1, srcCode[index++]); // string para armazenar o valor literal numérico
                while(index < srcCode.size() && \
                    (\
                        std::isdigit(srcCode[index]) || \
                        (std::tolower(srcCode[index]) >= 'a' && std::tolower(srcCode[index]) <= 'f')\
                    )\
                )
                {
                    num += srcCode[index++];
                }

                if(isNumber(num))
                {
                    tokens.push_back(Token(NUMERICLITERAL, num, toInt8(num)));
                }
                else
                {
                    res.exceptions.push_back(Exception(2, ", found at file '"+filename+"' line "+std::to_string(line))); // Armazena a exceção
                    tokens.push_back(TokenError());
                }
            }
            break;
            default:
            {
                if(std::isdigit(srcCode[index]))
                {
                    std::string num; // string para armazenar o valor literal numérico
                    while(index < srcCode.size() && std::isdigit(srcCode[index]))
                    {
                        num += srcCode[index++];
                    }

                    if(isNumber(num))
                    {
                        tokens.push_back(Token(NUMERICLITERAL, num, toInt8(num)));
                    }
                    else
                    {
                        res.exceptions.push_back(Exception(3, ", found at file '"+filename+"' line "+std::to_string(line))); // Armazena a exceção
                        tokens.push_back(TokenError());
                    }
                }
                else if(std::isalpha(srcCode[index])) // 
                {
                    std::string identifier;

                    while(index < srcCode.size() && (std::isalpha(srcCode[index]) || std::isdigit(srcCode[index]) || srcCode[index] == '_'))
                    {
                        identifier += srcCode[index++];
                    }

                    // std::cout << identifier << std::endl;

                    if(operators.find(lowerString(identifier)) != operators.end())
                    {
                        tokens.push_back(Token(OPERATOR, identifier, operators[lowerString(identifier)]));
                    }
                    else if(registers.find(lowerString(identifier)) != registers.end())
                    {
                        tokens.push_back(Token(REGISTER, identifier, registers[lowerString(identifier)]));
                    }
                    else if(lowerString(identifier) == std::string("db"))
                    {
                        tokens.push_back(Token(DEFINE_BYTE, identifier));
                    }
                    else
                    {
                        if(index < srcCode.size() && srcCode[index]==':')
                        {
                            tokens.push_back(Token(DECLABEL, identifier));
                            index++;
                        }
                        else
                        {
                            tokens.push_back(Token(LABEL, identifier));
                        }
                    }
                }
                else
                {
                    res.exceptions.push_back(Exception(1, ", found at file '"+filename+"' line "+std::to_string(line))); // Armazena a exceção
                    while(index <= srcCode.size() && srcCode[index] != '\n')index++;
                    tokens.push_back(TokenError());
                    
                }
            }
        }
    }

    if(tokens.back().type != NEWLINE)tokens.push_back(Token(NEWLINE, "\\n"));
    tokens.push_back(Token(ENDOFFILE, "EOF"));

    res.value = tokens;
    return res;
}