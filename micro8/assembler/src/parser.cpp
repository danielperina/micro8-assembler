#include "parser.h"

// std::map<std::string, int> operator_size

Result<std::vector<unsigned char>> parse(std::deque<Token> tokens, bool show_labels)
{
    std::map<std::string, int> symbols; // armazena os endereços das labels
    std::vector<unsigned char> code; // armazena o código gerado

    Result<std::vector<unsigned char>> res; // Result para o retorno da função
    
    int mem_addr = 0, line = 1; // inicializa as variáveis de posição da memória e linha no programa
    std::string filename; // nome do arquivo para a ser informado nas exceções

    for(int i = 0; i < tokens.size(); i++) // registra os símbolos
    {
        Token tk = tokens[i];

        switch(tk.type) // se o tipo do token é
        {
            case FILENAME: // Nome do arquivo
            {
                filename = tk.name; // atualiza o nome do arquivo atual
            }
            break;
            case CURRENT_LINE: // Linha atual
            {
                line = tk.value; // atualiza a variável linha
            }
            break;
            case OPERATOR: // Operador
            {
                switch(tk.value) // Atualiza a variável mem_addr de acordo com o tamamho esperado de cada operador
                {
                    case 0:
                    case 0xe:
                    case 0xf:
                        mem_addr += 1;
                    break;
                    case 1:
                    case 2:
                    case 3:
                    case 4:
                    case 5:
                    case 6:
                    case 7:
                    case 8:
                    case 9:
                    case 0xa:
                    case 0xb:
                    case 0xc:
                    case 0xd:
                        mem_addr += 2;
                    break;
                }
            }break;
            case DECLABEL: // Declaração de label
            {
                if(symbols.find(tk.name) == symbols.end()) // Se a label não foi definida ainda
                {
                    symbols[tk.name] = mem_addr; // Define o endereço da label
                }
                else // Senão
                {
                    // Armazena uma exceção
                    res.exceptions.push_back(Exception(4, ", found at file '"+filename+"' line "+std::to_string(line)));
                }
            }
            break;
            case DEFINE_BYTE: // Defição de byte(s)
            {
                tk = tokens[++i]; 
                while(i < tokens.size() && tk.type == NUMERICLITERAL) // Soma a quantidade de bytes necessária
                {
                    mem_addr++;
                    tk = tokens[++i]; 
                }
                i--; // decrementa para não perder um token. O loop for fará mais um incremento e voltará para o token atual
            }break;
        }
    }

    line = 1; // redefine as variáveis line e filename para "desempilhar" os tokens na próxima passagem
    filename = "";

    while(tokens.size() > 0 && tokens.front().type != ENDOFPROGRAM)
    {
        switch(tokens.front().type)
        {
            case FILENAME:
            {
                filename = tokens.front().name;
                tokens.pop_front();
            }
            break;
            case CURRENT_LINE:
                line = tokens.front().value;
                tokens.pop_front();
            break;
            case ENDOFFILE:
            case DECLABEL:
            case NEWLINE:
                tokens.pop_front();
            break;
            case OPERATOR:
            {
                int opcode = 0, reg = 0, data = 0, mode = 0;

                switch(tokens.front().value) // Atualiza a variável mem_addr de acordo com o tamamho esperado de cada operador
                {
                    case 0:
                    case 0xe:
                    case 0xf:
                    {
                        opcode = (OPERATOR_SHIFT(OPERATOR_MASK(tokens.front().value)));
                        code.push_back(opcode);
                        tokens.pop_front();
                    }
                    break;
                    case 1:
                    case 2:
                    case 3:
                    case 4:
                    case 5:
                    case 6:
                    case 7:
                    case 8:
                    {
                        opcode = OPERATOR_MASK(tokens.front().value);
                        tokens.pop_front();

                        if(tokens.front().type != REGISTER)
                        {
                            res.exceptions.push_back(Exception(6, ", found at file '"+filename+"' line "+std::to_string(line)));
                            while(tokens.size() > 0 && tokens.front().type != NEWLINE)tokens.pop_front();
                        }
                        else
                        {
                            reg = REGISTER_MASK(tokens.front().value);

                            tokens.pop_front();

                            switch(tokens.front().type)
                            {
                                case EQUALS:
                                {
                                    if(opcode != operators.at("str"))
                                    {
                                        mode = MODE_MASK(IMMEDIATE_MODE);
                                        code.push_back((OPERATOR_SHIFT(opcode) | MODE_SHIFT(mode) | reg));
                                        tokens.pop_front();

                                        if(tokens.front().type == NUMERICLITERAL)
                                        {
                                            data = tokens.front().value;
                                            code.push_back((unsigned char)data);
                                            tokens.pop_front();
                                        }
                                        else if(tokens.front().type == LABEL)
                                        {
                                            if(symbols.find(tokens.front().name) != symbols.end())
                                            {
                                                data = symbols[tokens.front().name];
                                                code.push_back((unsigned char)data);
                                                tokens.pop_front();
                                            }
                                            else
                                            {
                                                res.exceptions.push_back(Exception(8, ", found at file '"+filename+"' line "+std::to_string(line)));
                                                while(tokens.size() > 0 && tokens.front().type != NEWLINE)tokens.pop_front();
                                            }
                                        }
                                        else
                                        {
                                            res.exceptions.push_back(Exception(6, ", found at file '"+filename+"' line "+std::to_string(line)));
                                            while(tokens.size() > 0 && tokens.front().type != NEWLINE)tokens.pop_front();
                                        }
                                    }
                                    else
                                    {
                                        res.exceptions.push_back(Exception(7, ", found at file '"+filename+"' line "+std::to_string(line)));
                                        while(tokens.size() > 0 && tokens.front().type != NEWLINE)tokens.pop_front();
                                    }

                                    if(tokens.front().type != NEWLINE)
                                    {
                                        res.exceptions.push_back(Exception(6, ", found at file '"+filename+"' line "+std::to_string(line)));
                                        while(tokens.size() > 0 && tokens.front().type != NEWLINE)tokens.pop_front();
                                    }
                                }
                                break;
                                case LABEL:
                                case NUMERICLITERAL:
                                {
                                    mode = MODE_MASK(DIRECT_MODE);
                                    code.push_back((OPERATOR_SHIFT(opcode) | MODE_SHIFT(mode) | reg));
                                    // tokens.pop_front();

                                    if(tokens.front().type == NUMERICLITERAL)
                                    {
                                        data = tokens.front().value;
                                        code.push_back((unsigned char)data);
                                        tokens.pop_front();
                                    }
                                    else if(tokens.front().type == LABEL)
                                    {
                                        if(symbols.find(tokens.front().name) != symbols.end())
                                        {
                                            data = symbols[tokens.front().name];
                                            code.push_back((unsigned char)data);
                                            tokens.pop_front();
                                        }
                                        else
                                        {
                                            res.exceptions.push_back(Exception(8, ", found at file '"+filename+"' line "+std::to_string(line)));
                                            while(tokens.size() > 0 && tokens.front().type != NEWLINE)tokens.pop_front();
                                        }
                                    }
                                    else
                                    {
                                        res.exceptions.push_back(Exception(6, ", found at file '"+filename+"' line "+std::to_string(line)));
                                        while(tokens.size() > 0 && tokens.front().type != NEWLINE)tokens.pop_front();
                                    }

                                    if(tokens.front().type != NEWLINE)
                                    {
                                        res.exceptions.push_back(Exception(6, ", found at file '"+filename+"' line "+std::to_string(line)));
                                        while(tokens.size() > 0 && tokens.front().type != NEWLINE)tokens.pop_front();
                                    }

                                }
                                break;
                                case OPENBRACKETS:
                                {
                                    mode = MODE_MASK(INDIRECT_MODE);
                                    code.push_back((OPERATOR_SHIFT(opcode) | MODE_SHIFT(mode) | reg));
                                    tokens.pop_front();

                                    if(tokens.front().type == NUMERICLITERAL)
                                    {
                                        data = tokens.front().value;
                                        code.push_back((unsigned char)data);
                                        tokens.pop_front();
                                    }
                                    else if(tokens.front().type == LABEL)
                                    {
                                        if(symbols.find(tokens.front().name) != symbols.end())
                                        {
                                            data = symbols[tokens.front().name];
                                            code.push_back((unsigned char)data);
                                            tokens.pop_front();
                                        }
                                        else
                                        {
                                            res.exceptions.push_back(Exception(8, ", found at file '"+filename+"' line "+std::to_string(line)));
                                            while(tokens.size() > 0 && tokens.front().type != NEWLINE)tokens.pop_front();
                                        }
                                    }
                                    else
                                    {
                                        res.exceptions.push_back(Exception(6, ", found at file '"+filename+"' line "+std::to_string(line)));
                                        while(tokens.size() > 0 && tokens.front().type != NEWLINE)tokens.pop_front();
                                    }

                                    if(tokens.front().type != CLOSEBRACKETS)
                                    {
                                        res.exceptions.push_back(Exception(9, ", at file '"+filename+"' line "+std::to_string(line)));
                                        while(tokens.size() > 0 && tokens.front().type != NEWLINE)tokens.pop_front();
                                    }
                                    
                                    tokens.pop_front();

                                    if(tokens.front().type != NEWLINE)
                                    {
                                        res.exceptions.push_back(Exception(6, ", found at file '"+filename+"' line "+std::to_string(line)));
                                        while(tokens.size() > 0 && tokens.front().type != NEWLINE)tokens.pop_front();
                                    }
                                }
                                break;
                                case REGISTER:
                                {
                                    mode = MODE_MASK(INDEXED_MODE);
                                    code.push_back((OPERATOR_SHIFT(opcode) | MODE_SHIFT(mode) | reg));
                                    
                                    reg = REGISTER_MASK(tokens.front().value);
                                    tokens.pop_front();

                                    if(tokens.front().type == PLUS)
                                    {
                                        tokens.pop_front();

                                        if(tokens.front().type == NUMERICLITERAL)
                                        {
                                            data = IDX_DATA_MASK(tokens.front().value);
                                            code.push_back(IDX_REG_SHIFT(reg) | data);
                                            tokens.pop_front();
                                        }
                                        else if(tokens.front().type == LABEL)
                                        {
                                            if(symbols.find(tokens.front().name) != symbols.end())
                                            {
                                                data = IDX_DATA_MASK(symbols[tokens.front().name]);
                                                code.push_back(IDX_REG_SHIFT(reg) | data);
                                                tokens.pop_front();
                                            }
                                            else
                                            {
                                                res.exceptions.push_back(Exception(8, ", found at file '"+filename+"' line "+std::to_string(line)));
                                                while(tokens.size() > 0 && tokens.front().type != NEWLINE)tokens.pop_front();
                                            }
                                        }
                                        else
                                        {
                                            res.exceptions.push_back(Exception(6, ", found at file '"+filename+"' line "+std::to_string(line)));
                                            while(tokens.size() > 0 && tokens.front().type != NEWLINE)tokens.pop_front();
                                        }
                                    }
                                    else
                                    {
                                        res.exceptions.push_back(Exception(6, ", found at file '"+filename+"' line "+std::to_string(line)));
                                        while(tokens.size() > 0 && tokens.front().type != NEWLINE)tokens.pop_front();
                                    }

                                    if(tokens.front().type != NEWLINE)
                                    {
                                        res.exceptions.push_back(Exception(6, ", found at file '"+filename+"' line "+std::to_string(line)));
                                        while(tokens.size() > 0 && tokens.front().type != NEWLINE)tokens.pop_front();
                                    }
                                }
                                break;
                                default:
                                {
                                    res.exceptions.push_back(Exception(6, ", found at file '"+filename+"' line "+std::to_string(line)));
                                    while(tokens.size() > 0 && tokens.front().type != NEWLINE)tokens.pop_front();
                                }
                            }
                        }
                    }
                    break;
                    case 9: // operators.at("b"):
                    case 0xa: //operators.at("bn"):
                    case 0xb: //operators.at("bz"):
                    case 0xc: //operators.at("bc"):
                    case 0xd: //operators.at("jsr"):
                    {
                        opcode = OPERATOR_MASK(tokens.front().value);
                        tokens.pop_front();

                        switch(tokens.front().type)
                        {
                            case EQUALS:
                            {
                                if(tokens.front().value != operators.at("str"))
                                {
                                    mode = MODE_MASK(IMMEDIATE_MODE);
                                    code.push_back((OPERATOR_SHIFT(opcode) | MODE_SHIFT(mode) | reg));
                                    tokens.pop_front();

                                    if(tokens.front().type == NUMERICLITERAL)
                                    {
                                        data = tokens.front().value;
                                        code.push_back((unsigned char)data);
                                        tokens.pop_front();
                                    }
                                    else if(tokens.front().type == LABEL)
                                    {
                                        if(symbols.find(tokens.front().name) != symbols.end())
                                        {
                                            data = symbols[tokens.front().name];
                                            code.push_back((unsigned char)data);
                                            tokens.pop_front();
                                        }
                                        else
                                        {
                                            res.exceptions.push_back(Exception(8, ", found at file '"+filename+"' line "+std::to_string(line)));
                                            while(tokens.size() > 0 && tokens.front().type != NEWLINE)tokens.pop_front();
                                        }
                                    }
                                    else
                                    {
                                        res.exceptions.push_back(Exception(6, ", found at file '"+filename+"' line "+std::to_string(line)));
                                        while(tokens.size() > 0 && tokens.front().type != NEWLINE)tokens.pop_front();
                                    }
                                }
                                else
                                {
                                    res.exceptions.push_back(Exception(7, ", found at file '"+filename+"' line "+std::to_string(line)));
                                    while(tokens.size() > 0 && tokens.front().type != NEWLINE)tokens.pop_front();
                                }

                                if(tokens.front().type != NEWLINE)
                                {
                                    res.exceptions.push_back(Exception(6, ", found at file '"+filename+"' line "+std::to_string(line)));
                                    while(tokens.size() > 0 && tokens.front().type != NEWLINE)tokens.pop_front();
                                }
                            }
                            break;
                            case LABEL:
                            case NUMERICLITERAL:
                            {
                                mode = MODE_MASK(DIRECT_MODE);
                                code.push_back((OPERATOR_SHIFT(opcode) | MODE_SHIFT(mode) | reg));
                                // tokens.pop_front();

                                if(tokens.front().type == NUMERICLITERAL)
                                {
                                    data = tokens.front().value;
                                    code.push_back((unsigned char)data);
                                    tokens.pop_front();
                                }
                                else if(tokens.front().type == LABEL)
                                {
                                    if(symbols.find(tokens.front().name) != symbols.end())
                                    {
                                        data = symbols[tokens.front().name];
                                        code.push_back((unsigned char)data);
                                        tokens.pop_front();
                                    }
                                    else
                                    {
                                        res.exceptions.push_back(Exception(8, ", found at file '"+filename+"' line "+std::to_string(line)));
                                        while(tokens.size() > 0 && tokens.front().type != NEWLINE)tokens.pop_front();
                                    }
                                }
                                else
                                {
                                    res.exceptions.push_back(Exception(6, ", found at file '"+filename+"' line "+std::to_string(line)));
                                    while(tokens.size() > 0 && tokens.front().type != NEWLINE)tokens.pop_front();
                                }

                                if(tokens.front().type != NEWLINE)
                                {
                                    res.exceptions.push_back(Exception(6, ", found at file '"+filename+"' line "+std::to_string(line)));
                                    while(tokens.size() > 0 && tokens.front().type != NEWLINE)tokens.pop_front();
                                }

                            }
                            break;
                            case OPENBRACKETS:
                            {
                                mode = MODE_MASK(INDIRECT_MODE);
                                code.push_back((OPERATOR_SHIFT(opcode) | MODE_SHIFT(mode) | reg));
                                tokens.pop_front();

                                if(tokens.front().type == NUMERICLITERAL)
                                {
                                    data = tokens.front().value;
                                    code.push_back((unsigned char)data);
                                    tokens.pop_front();
                                }
                                else if(tokens.front().type == LABEL)
                                {
                                    if(symbols.find(tokens.front().name) != symbols.end())
                                    {
                                        data = symbols[tokens.front().name];
                                        code.push_back((unsigned char)data);
                                        tokens.pop_front();
                                    }
                                    else
                                    {
                                        res.exceptions.push_back(Exception(8, ", found at file '"+filename+"' line "+std::to_string(line)));
                                        while(tokens.size() > 0 && tokens.front().type != NEWLINE)tokens.pop_front();
                                    }
                                }
                                else
                                {
                                    res.exceptions.push_back(Exception(6, ", found at file '"+filename+"' line "+std::to_string(line)));
                                    while(tokens.size() > 0 && tokens.front().type != NEWLINE)tokens.pop_front();
                                }

                                if(tokens.front().type != CLOSEBRACKETS)
                                {
                                    res.exceptions.push_back(Exception(9, ", at file '"+filename+"' line "+std::to_string(line)));
                                    while(tokens.size() > 0 && tokens.front().type != NEWLINE)tokens.pop_front();
                                }
                                else if(tokens.front().type != NEWLINE)
                                {
                                    res.exceptions.push_back(Exception(6, ", found at file '"+filename+"' line "+std::to_string(line)));
                                    while(tokens.size() > 0 && tokens.front().type != NEWLINE)tokens.pop_front();
                                }
                            }
                            break;
                            case REGISTER:
                            {
                                mode = MODE_MASK(INDEXED_MODE);
                                code.push_back((OPERATOR_SHIFT(opcode) | MODE_SHIFT(mode) | reg));
                                // tokens.pop_front();

                                if(tokens.front().type == REGISTER)
                                {
                                    reg = REGISTER_MASK(tokens.front().value);
                                    tokens.pop_front();

                                    if(tokens.front().type == PLUS)
                                    {
                                        tokens.pop_front();

                                        if(tokens.front().type == NUMERICLITERAL)
                                        {
                                            data = IDX_DATA_MASK(tokens.front().value);
                                            code.push_back(IDX_REG_SHIFT(reg) | data);
                                            tokens.pop_front();
                                        }
                                        else if(tokens.front().type == LABEL)
                                        {
                                            if(symbols.find(tokens.front().name) != symbols.end())
                                            {
                                                data = IDX_DATA_MASK(symbols[tokens.front().name]);
                                                // data = IDX_DATA_MASK(tokens.front().value);
                                                code.push_back(IDX_REG_SHIFT(reg) | data);
                                                tokens.pop_front();
                                                // code.push_back((unsigned char)data);
                                                // tokens.pop_front();
                                            }
                                            else
                                            {
                                                res.exceptions.push_back(Exception(8, ", found at file '"+filename+"' line "+std::to_string(line)));
                                                while(tokens.size() > 0 && tokens.front().type != NEWLINE)tokens.pop_front();
                                            }
                                        }
                                        else
                                        {
                                            res.exceptions.push_back(Exception(6, ", found at file '"+filename+"' line "+std::to_string(line)));
                                            while(tokens.size() > 0 && tokens.front().type != NEWLINE)tokens.pop_front();
                                        }
                                    }
                                    else
                                    {
                                        res.exceptions.push_back(Exception(6, ", found at file '"+filename+"' line "+std::to_string(line)));
                                        while(tokens.size() > 0 && tokens.front().type != NEWLINE)tokens.pop_front();
                                    }
                                }
                                else
                                {
                                    res.exceptions.push_back(Exception(6, ", found at file '"+filename+"' line "+std::to_string(line)));
                                    while(tokens.size() > 0 && tokens.front().type != NEWLINE)tokens.pop_front();
                                }

                                if(tokens.front().type != NEWLINE)
                                {
                                    res.exceptions.push_back(Exception(6, ", found at file '"+filename+"' line "+std::to_string(line)));
                                    while(tokens.size() > 0 && tokens.front().type != NEWLINE)tokens.pop_front();
                                }
                            }
                            break;
                            default:
                            {
                                res.exceptions.push_back(Exception(6, ", found at file '"+filename+"' line "+std::to_string(line)));
                                while(tokens.size() > 0 && tokens.front().type != NEWLINE)tokens.pop_front();
                            }
                        }
                    }
                    break;
                }
            }
            break;
            break;
            case DEFINE_BYTE:
            {
                tokens.pop_front();

                while(!tokens.empty() && tokens.front().type == NUMERICLITERAL)
                {
                    code.push_back(tokens.front().value);
                    tokens.pop_front();
                }

                if(tokens.front().type != NEWLINE)
                {
                    res.exceptions.push_back(Exception(5, ", found at file '"+filename+"' line "+std::to_string(line)));
                    while(tokens.size() > 0 && tokens.front().type != NEWLINE)tokens.pop_front();
                }
            }
            break;
            default:
            {
                res.exceptions.push_back(Exception(6, ", found at file '"+filename+"' line "+std::to_string(line)));
                while(tokens.size() > 0 && tokens.front().type != NEWLINE)tokens.pop_front();
            }
        }
        // std::cout << tokens.front() << std::endl;
    }

    if(show_labels)
    {
        std::cout << "\nLabels: \n{\n";
        for(auto item: symbols)std::cout << "'" << item.first << "' : " << item.second << "\n";
        std::cout << "}\n";
    }

    res.value = code;

    return res;
}
