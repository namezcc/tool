#!/bin/bash

makecommon(){
	for pro in `ls ../common/*.proto`
	do
		if [ ! -f ${pro}.bak ]||[ $(diff -bq ${pro} ${pro}.bak |wc -l) -gt 0 ] ;then
			protoc -I=../common/ --cpp_out=dllexport_decl=LIBPROTOC_EXPORT:../../server/src/netmsg/ ${pro}
			cat ${pro} > ${pro}.bak
		fi
	done
}

makeclient(){
	for pro in `ls ../client/*.proto`
	do
		if [ ! -f ${pro}.bak ]||[ $(diff -bq ${pro} ${pro}.bak |wc -l) -gt 0 ] ;then
			protoc -I=../common/ -I=../client/ --cpp_out=dllexport_decl=LIBPROTOC_EXPORT:../../server/src/netmsg/ ${pro}
			cat ${pro} > ${pro}.bak
		fi
	done
}

makeserver(){
	for pro in `ls ../server/*.proto`
	do
		if [ ! -f ${pro}.bak ]||[ $(diff -bq ${pro} ${pro}.bak |wc -l) -gt 0 ] ;then
			protoc -I=../common/ -I=../server --cpp_out=dllexport_decl=LIBPROTOC_EXPORT:../../server/src/netmsg/ ${pro}
			cat ${pro} > ${pro}.bak
		fi
	done
}

if [ ! -n "$1" ]
then
	makecommon
	makeclient
	makeserver
#else
#	while getopts bsc opt; do
#		case $opt in
#			b) makecommon;;
#			s) makeserver;;
#			c) makeclient;;
#			\?) echo -e " -b make common\n -s make server\n -c make client\n";;
#		esac
#	done
fi

echo "success"
