import os;
import hashlib

def check_md5(root, filename):
	with open(root + "//" + filename + ".proto", "rb") as f:
		myhash = hashlib.md5()
		fdata = f.read()
		myhash.update(fdata)
		file_md5 = myhash.hexdigest()
		
	ret = False
	md5file = root + "//" + filename + ".md5"
	if os.path.exists(md5file):
		with open(md5file, "r") as rf:
			if rf.readline() == file_md5:
				ret = True
				
	if not ret:
		with open(root + "//" + md5file, "w") as wf:
			wf.write(file_md5)
			
	return ret


if __name__ == "__main__":
	
	makeCommon = False
	makeServer = False
	makeClient = False
	makeLua = False
	if not check_md5("../common", "Common"):
		makeCommon = True
		makeServer = True
		makeClient = True
		makeLua = True
	if not check_md5("../server", "Server"):
		makeServer = True
		makeLua = True
	if not check_md5("../client", "Client"):
		makeClient = True
		makeLua = True
	
	if makeCommon:
		cmd = "protoc.exe -I=../common/ --cpp_out=:../../server/src/netmsg/ Common.proto"
		print(cmd)
		os.system(cmd)
		
	if makeServer:
		cmd = "protoc.exe -I=../common/ -I=../server/ --cpp_out=:../../server/src/netmsg/ Server.proto"
		print(cmd)
		os.system(cmd)
		
	if makeClient:
		cmd = "protoc.exe -I=../common/ -I=../client/ --cpp_out=:../../server/src/netmsg/ Client.proto"
		print(cmd)
		os.system(cmd)
	
	if makeLua:
		cmd = "protoc.exe -I=../common/  -I=../server/ -I=../client/ -o../../server/bin/lua/loginserver/proto/allproto.pb Common.proto Client.proto Server.proto"
		print(cmd)
		os.system(cmd)
		
		
						