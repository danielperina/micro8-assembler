#include "my_functions.h"

// #include <string>
// #include <cctype>

std::string lowerString(std::string s)
{
	std::string ret;

	for(char ch: s) ret += std::string(1, std::tolower(ch));

	return ret;
}

bool isNumber(std::string value)
{
	if(value.size()==0)
		return false;

	for(int i = 0; i < value.size(); i++)
		value[i] = std::tolower(value[i]);
    
	if(value[0] == '$' && value.size()>1)
	{
		std::string aux;
		aux+=value[0];
		for(int i=1; i<value.size(); i++)
		{
			if(std::isdigit(value[i]) || (value[i] >= 'a' && value[i] <= 'f'))
			{
				aux += value[i];
			}
		}

		return value == aux;
	}
	else if(value[0] == '%' && value.size()>1)
	{
		std::string aux;
		aux+=value[0];
		for(int i=1; i<value.size(); i++)
		{
			if(value[i] == '0' || value[i] == '1')
			{
				aux += value[i];
			}
		}

		
		return value == aux;
	}
	else if(value[0]=='&' && value.size()>1)
	{
		std::string aux;
		aux+=value[0];
		for(int i=1; i<value.size(); i++)
		{
			if(value[i]>='0' && value[i] <= '7')
			{
				aux += value[i];
			}
		}

		return value == aux;
	}
	else
	{
		std::string aux = "";
		
		for(int i=0; i<value.size(); i++)
		{
			if(std::isdigit(value[i]))
			{
				aux += value[i];
			}
		}
        // std::cout << "Value: "<< value << " Aux: " << aux << std::endl;
		return value == aux;
	}

	return false;
}
int toInt8(std::string value)
{
	int ret = 0;
	switch(value[0])
	{
		case '$':
			ret = std::stoi(value.substr(1), nullptr, 16) & 255;//strToInt(value.substr(1), 16) & 255;
		break;
		case '%':
			ret = std::stoi(value.substr(1), nullptr, 2) & 255; //strToInt(value.substr(1), 2) & 255;
		break;
		case '&':
			ret = std::stoi(value.substr(1), nullptr, 8) & 255; //strToInt(value.substr(1), 8) & 255;
		break;
		default:
			ret = std::stoi(value, nullptr, 10) & 255; //strToInt(value, 10) & 255;
	}
	return ret;
}