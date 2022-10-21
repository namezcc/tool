@echo off

protoc.exe -I=..\common\  -I=..\server\ -I=..\client\ -o..\..\server\bin\lua\loginserver\proto\allproto.pb Common.proto Client.proto Server.proto

protoc.exe -I=..\common\  -I=..\server\ -I=..\client\ -o..\..\server\win_project\robot\Robot\proto\allproto.pb Common.proto Client.proto Server.proto

echo success
if "%1" == "" pause 