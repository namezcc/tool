local GameClient = class()

function GameClient:ctor(index)
    local M = {}
    self._M = M

	local account = ACCOUNT..index
	if GAME_ADDR[index] then
		account = GAME_ADDR[index].uid or account
	end

    M.LoginModule = GM_MODULE.LoginModule.new(account,"123456789")
    M.NetModule = GM_MODULE.NetModule.new()
    M.PlayerModule = GM_MODULE.PlayerModule.new()
    M.MapModule = GM_MODULE.MapModule.new()
    M.SendPackModule = GM_MODULE.SendPackModule.new()
    M.Event = Event.new()
    M.Schedule = Schedule.new()

    self:init()
end

function GameClient:init()
    for k,v in pairs(self._M) do
        v:init(self._M)
        v._GAME = self
    end

    for k,v in pairs(self._M) do
        if v.afterInit then
            v:afterInit()
        end
    end

    self._M.Event:DoEvent(EventID.ON_GAME_INIT)
end

function GameClient:Run(dt)
    self._M.Schedule:Run(dt)
end

return GameClient