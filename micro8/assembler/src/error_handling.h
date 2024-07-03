#ifndef __ERROR_HANDLING_H__
#define __ERROR_HANDLING_H__

#include <iostream>
#include <deque>

extern const char * errors[];

struct Exception
{
    std::string msg;
    int errcode;

    Exception(int errcode, std::string msg);

    ~Exception();

    friend std::ostream& operator<<(std::ostream& os, Exception& e);
};

std::ostream& operator<<(std::ostream& os, Exception& e);

template<typename T>
struct Result
{
    std::deque<Exception> exceptions;
    T value;
};

#endif