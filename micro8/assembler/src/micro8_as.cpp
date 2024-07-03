#include <iostream>
#include <fstream>
#include <iomanip>
#include <deque>

#include "tokens.h"
#include "parser.h"
#include "error_handling.h"



int main(int argc, const char * argv[])
{
    bool showtokens = false, showlabels = false, showparsed = false, ismainfile = false;

    if(argc == 1)
    {
        std::cout << "Usage: micro8_as -m<mainfile> [-T ShowTokens] [-L ShowLabels] [-P ShowParsed]\n";
        return 0;
    }

    std::string filename;//(".\\test.s");

    for(int i = 0; i < argc; i++)
    {
        if(std::string(argv[i]) == std::string("-T"))showtokens = true;
        else if(std::string(argv[i]) == std::string("-L")) showlabels = true;
        else if(std::string(argv[i]) == std::string("-P")) showparsed = true;
        else if(std::string(argv[i]).starts_with("-m"))
        {
            if(ismainfile)
            {
                i = argc;
                std::cerr << "Multiple declaration of mainfile.\n";
                return 1;
            }

            ismainfile = true;
            filename = std::string(argv[i]).substr(2);
        }
    }

    if(!ismainfile)
    {
        std::cerr << "Mainfile was not declared.\n";
        return 1;
    }

    std::ifstream mainfile(filename, std::ios::binary | std::ios::ate); // abre o arquivo

    if (!mainfile.is_open()) // Gera um erro se o arquivo não estiver aberto
    {
        std::cerr << "Couldn't open Mainfile.\n";
        return 1;
    }

    // Determina o tamanho do arquivo
    std::streamsize filesize = mainfile.tellg();
    mainfile.seekg(0, std::ios::beg);

    if(filesize == 0) // Gera um erro se o arquivo estiver vazio
    {
        mainfile.close();
        std::cerr << "Mainfile file is empty.\n";
        return 1;
    }

    std::string buffer(filesize, '\0');

    // Lê o conteúdo do arquivo na string
    if (!mainfile.read(&buffer[0], filesize)) {
        std::cerr << "Erro ao ler o arquivo" << std::endl;
        return 1;
    }

    // Fecha o arquivo
    mainfile.close();

    std::deque<Exception> exceptions;

    std::deque<Token> tokens;
    
    Result<std::deque<Token>> res0 = tokenize(buffer, filename);
    
    for(Exception e: res0.exceptions) exceptions.push_back(e);
    
    if(showtokens) std::cout << "\nTokens: \n{\n";

    for(Token tk: res0.value) 
    {
        tokens.push_back(tk);
        if(showtokens) std::cout << "\t" << tk << std::endl;
    }

    if(showtokens) std::cout << "}\n";

    Result<std::vector<unsigned char>> res1 = parse(tokens, showlabels);

    for(Exception e : res1.exceptions) exceptions.push_back(e);

    if(exceptions.size() > 0)
    {
        for(Exception e: exceptions) std::cerr << e << std::endl;
        return 1;
    }


    if(showparsed)
    {
        unsigned char i=0;
        std::cout << "\nParsed: \n[";
        for(unsigned char byte: res1.value)
        {
            if((i%16)==0) std::cout << std::endl;
            std::cout << std::setw(2) << std::setfill('0') << std::hex << (int)byte << " ";
            i++;
        }
        std::cout << "\n]\n";
    }
    
    
    // remove extensão se tiver
    size_t indexof = filename.find_last_of(".");
    if(indexof!=std::string::npos) filename = filename.substr(0, indexof);
    
    // remove diretório se tiver, usar / ao invés de \\ para o linux
    indexof = filename.find_last_of("\\");
    if(indexof!=std::string::npos) filename = filename.substr(indexof+1);

    std::cout << "\nfout >> "+filename+".mem\n";

    std::ofstream fout(filename+".mem", std::ios::binary); // Abre o arquivo binário com a extensão .mem
        
    if(!fout.is_open())
    {
        std::cerr << "Failed to create the file.\n";
        return 1;
    }

    std::vector<unsigned char> prog = res1.value;
    
    fout.write(reinterpret_cast<const char*>(prog.data()), prog.size()); // escreve os dados no arquivo

    fout.close(); // fecha o arquivo

    return 0;
}