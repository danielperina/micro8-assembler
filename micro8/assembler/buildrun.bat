@echo off
g++ -std=c++20 .\src\my_functions.cpp .\src\tokens.cpp .\src\parser.cpp .\src\error_handling.cpp .\src\micro8_as.cpp -o .\bin\micro8_as.exe

if %errorlevel% equ 0 (
    .\bin\micro8_as.exe -m.\samples\test.s
)