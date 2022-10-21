@echo off
cd ..\..\..\..\..\protobuf\tool\

protoc.exe -I=..\common\  -I=..\server\ -I=..\client\ -o..\..\server\win_project\robot\Robot\proto\allproto.pb Common.proto Client.proto Server.proto

pause 