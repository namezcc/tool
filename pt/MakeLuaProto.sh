#!/bin/bash

makeserver(){
	protoc -I=../common/ -I=../server/ -I=../client/ -o../../server/bin/lua/loginserver/proto/allproto.pb Common.proto Client.proto Server.proto
}

makeserver

echo "success"
