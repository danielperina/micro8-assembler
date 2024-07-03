#include "error_handling.h"

const char * errors[] = {
    "Empty file",
    "Unexpected character",
    "Invalid numeric conversion",
    "Invalid numeric",
    "Multiple label declaration",
    "Invalid byte definition",
    "Strange operand",
    "Forbidden operation mode",
    "Undeclared label",
    "Brackets were never closed"
};

Exception::Exception(int errcode, std::string msg)
{
    this->errcode = errcode;
    this->msg = msg;
}

Exception::~Exception() {}

std::ostream& operator<<(std::ostream& os, Exception& e)
{
    os << errors[e.errcode] << e.msg;

    return os;
}