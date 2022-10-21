local LoginModule = {}

local _Net = NetModule

function LoginModule:init()

    Event:AddEvent(EventID.ON_CONNECT_LOGIN_SERVER,self.OnConnect)

	_Net:AddMsgCallBack(SMCODE.SM_CHARACTOR_LIST,self.OnCharactorList,"SmCharacterList")
	_Net:AddMsgCallBack(SMCODE.SM_CLIENT_REPLY,self.OnCreateReply,"ServerMsgClientReply")
	

    CMD:AddCmdCall(self.DoCreateRole,"crole","pam:name : create role")
    CMD:AddCmdCall(self.DoEnterGame,"enter","pam:roleindex :enter game")
    CMD:AddCmdCall(self.DoLogin,"l","login game")
	CMD:AddCmdCall(self.DoConnectServer,"c","connect game")
	CMD:AddCmdCall(self.DoCloseConnect,"close","close connect")
end

function LoginModule:onNewPlayer(account)
	self._account = account

	if AUTO_ENTER then
		Schedule:AddIntervalTask(function()
			self:DoConnectServer()
		end,0,1,1)
	end

end

function LoginModule:SendGameData(pbname,mid,data)
	_Net:SendData(self._sock,pbname,mid,data)
end

function LoginModule:getUid()
    return self._account
end

function LoginModule:getCid()
    return self._cid
end

function LoginModule:getSid()
    return ACCOUNT_SID[self._account] or 1
end

function LoginModule:genToken()
    return "testToken1"
end

function LoginModule:DoConnectServer()
    local ip = SERVER_IP
    local port = SERVER_PORT

    if IS_SINGLE and GAME_ADDR[GAME_INDEX] then
        ip = GAME_ADDR[GAME_INDEX].ip or ip
        port = GAME_ADDR[GAME_INDEX].port or port
    end
	if IS_SINGLE then
		print("Connect ",ip," ",port)
	end
    local res = _Net:Connect(ip,port,EventID.ON_CONNECT_LOGIN_SERVER,self)
	if res == false then
		if AUTO_ENTER and AUTO_RECONNECT then
			print("connect fail try after 3s...")
			Schedule:AddIntervalTask(function()
				self:DoConnectServer()
			end,0,3000,1)
		end
	else
		self._login_ip = ip
	end
end

function LoginModule:OnConnect(sock)
    self._sock = sock

    if GameType == GAME_TYPE.SEND_PACK then
        return
    end

	if IS_SINGLE then
		print("connect sock:",sock)
	end
    local logpb = {
		uid = self:getUid(),
		sid = self:getSid(),
        token = self:genToken(),
	}
	
	self:SendGameData("ClientMsgLogin",CMCODE.CM_USER_LOGIN,logpb)

end

function LoginModule:DoCloseConnect()
	_Net:CloseSock(self._sock)
end

function LoginModule:DoLogin()
    if self._role then
        print("allready login")
        return
    end
    local logpb = {
		uid = self:getUid(),
        sid = self:getSid(),
        token = self:genToken(),
	}

	self:SendGameData("ClientMsgLogin",CMCODE.CM_USER_LOGIN,logpb)
end

function LoginModule:OnCharactorList(data)
	if IS_SINGLE then
		print("get charactor list")
		print(persent.block(data))
	end

    self._sid = data.sid
    self._role = data.chrs

    if #data.chrs == 0 then
		if AUTO_ENTER then
			self:CreateRole()
		end
    else
        self:DoEnterGame({1})
    end
end

function LoginModule:DoCreateRole(pam)
    if self._role and #self._role > 3 then
        print("allready have role")
        return
    end
    self:CreateRole(pam[1])
end

function LoginModule:OnCreateReply( data )
    print("OnCreateReply ---- ")
    print(persent.block(data))
end

function LoginModule:CreateRole(_name)
    local pb = {
        name = _name or self._account,
		sex = 1,
		job = 1,
    }
    self:SendGameData("CmNewCharacter",CMCODE.CM_NEW_CHARACTER,pb)
end

function LoginModule:DoEnterGame(pam)
	local index = tonumber(pam[1]) or 1
    self:EnterGame(self._role[index])
end

function LoginModule:EnterGame(role)
    local pb = {
        uid = self:getUid(),
        sid = self:getSid(),
        cid = role.cid,
    }
	self.cid = role.cid
    self:SendGameData("ClientMsgEnterGame",CMCODE.CM_ENTER_GAME,pb)
end

return LoginModule