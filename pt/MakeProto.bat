@echo off

::setlocal enabledelayedexpansion

protoc.exe -I=..\common\ --cpp_out=:..\..\server\src\netmsg\ Common.proto

protoc.exe -I=..\common\ -I=..\server\ --cpp_out=:..\..\server\src\netmsg\ Server.proto

protoc.exe -I=..\common\ -I=..\client\ --cpp_out=:..\..\server\src\netmsg\ Client.proto

echo success
::echo Enter to gen base proto
::pause

::set input_path=..\proto\base\
::for /r %input_path% %%i in (*.proto) do (
::protoc.exe -I=../proto/base/ --cpp_out=dllexport_decl=LIBPROTOC_EXPORT:../protoPB/base/ %%~ni.proto
::protoc.exe -I=../proto/base/ --cpp_out=:../protoPB/base/ %%~ni.proto
::)

::echo base success
if "%1" == "" pause 