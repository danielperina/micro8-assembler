#ifndef __MY_FUNCTIONS__
#define __MY_FUNCTIONS__

#include <string>
#include <cctype>

std::string lowerString(std::string s);

bool isNumber(std::string value);

// int strToInt(std::string value, int base)
// {
// 	if(value.size()==0)
// 	{
// 		throw std::runtime_error("Error at strToInt: String value was expected but found empty string");
// 	}

// 	switch(base)
// 	{
// 		case 2:
// 		{
// 			int ret = 0;
// 			for(int i = 0; i < value.size(); i++)
// 			{
// 				ret*=2;
// 				if(value[i]=='0' || value[i]=='1')
// 				{
// 					ret += (value[i]&0xf);
// 				}
// 				else
// 				{
// 					i=value.size();
// 					throw std::runtime_error(std::string("Error at strToInt:")+" Unexpected character "+value[i]+" for base 2 conversion");
// 				}
// 			}
// 			return ret;
// 		}
// 		break;
// 		case 8:
// 		{
// 			int ret = 0;
// 			for(int i = 0; i < value.size(); i++)
// 			{
// 				ret*=8;
// 				if(value[i]>='0' && value[i]<='7')
// 				{
// 					ret += (value[i]&0xf);
// 				}
// 				else
// 				{
// 					i=value.size();
// 					throw std::runtime_error(std::string("Error at strToInt:")+" Unexpected character "+value[i]+" for base 8 conversion");
// 				}
// 			}
// 			return ret;
// 		}
// 		break;
// 		case 10:
// 		{
// 			int ret = 0;
// 			for(int i = 0; i < value.size(); i++)
// 			{
				
// 				if(std::isdigit(value[i]))
// 				{
// 					ret*=10;
// 					ret += (value[i]&0xf);
// 				}
// 				else
// 				{
// 					i=value.size();
// 					throw std::runtime_error(std::string("Error at strToInt:")+" Unexpected character "+value[i]+" for base 10 conversion");
// 				}
// 			}
// 			return ret;
// 		}
// 		break;
// 		case 16:
// 		{
// 			int ret = 0;
// 			for(int i = 0; i < value.size(); i++)
// 			{
// 				ret*=16;
// 				if(std::isdigit(value[i]))
// 				{
// 					ret += (value[i]&0xf);
// 				}
// 				else
// 				{
// 					switch(std::tolower(value[i]))
// 					{
// 						case 'a':ret+=10;break;
// 						case 'b':ret+=11;break;
// 						case 'c':ret+=12;break;
// 						case 'd':ret+=13;break;
// 						case 'e':ret+=14;break;
// 						case 'f':ret+=15;break;
// 						default:
// 							i=value.size();
// 							throw std::runtime_error(std::string("Error at strToInt:")+" Unexpected character "+value[i]+" for base 16 conversion");
// 					}
// 				}
// 			}
// 			return ret;
// 		}
// 		break;
// 		default:
// 		throw std::runtime_error(std::string("Error at strToInt:")+" Unexpected base of conversion "+std::to_string(base)+", valid bases (2,8,10,16)");
// 	}
// }

int toInt8(std::string value);

#endif