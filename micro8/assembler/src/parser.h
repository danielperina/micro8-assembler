#ifndef __PARSER_H__
#define __PARSER_H__

#include <iostream>
#include <string>
#include <map>
#include <deque>
#include <vector>

#include "tokens.h"
#include "error_handling.h"

#define IMMEDIATE_MODE	0
#define DIRECT_MODE		1
#define INDIRECT_MODE	2
#define INDEXED_MODE	3

#define OPERATOR_MASK(op) (op & 0xf)
#define OPERATOR_SHIFT(op) (op << 4)
#define REGISTER_MASK(reg) (reg & 3)
#define IDX_REG_SHIFT(reg) (reg << 6)
#define IDX_DATA_MASK(data) (data & 63)
#define MODE_MASK(mode) (mode & 3)
#define MODE_SHIFT(mode) (mode << 2)

Result<std::vector<unsigned char>> parse(std::deque<Token> tokens, bool show_labels);

#endif