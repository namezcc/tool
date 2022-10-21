
SCHEDULE_INDEX = {
	NEWDAY_COME = 1,
	NEW_HOUR_COME = 2,
	CHECK_FAMILY_LEADER = 3,
	NEWDAY_5h_COME = 4,
	NEW_MINUTE_COME = 5,
}

SCHEDULE_INDEX_BEGIN = 1000000

local schedule_mgr_module = {}

function schedule_mgr_module:init()
	self._index = 0
	self._second = {}
	self._min = {}
	self._hour = {}
	self._task = {}
	self._last_tm = os.date("*t",os.time())


	for i = 0, 59 do
		self._second[i] = {}
	end
	for i = 0, 59 do
		self._min[i] = {}
	end
	for i = 0, 23 do
		self._hour[i] = {}
	end

end

function schedule_mgr_module:init_func()
	
end

function schedule_mgr_module:update(timestamp)
	local tm = os.date("*t",timestamp)
	local stm = self._last_tm

	if tm.hour ~= stm.hour then
		local mintab = self._min
		local tab = self._hour[tm.hour]

		if not table.empty(tab) then
			self._hour[tm.hour] = {}

			for k, v in pairs(tab) do
				mintab[v.min][k] = v
			end
		end
	end


	local sectab = self._second
	if tm.min ~= stm.min then
		local tab = self._min[tm.min]
		if not table.empty(tab) then
			self._min[tm.min] = {}
			for k, v in pairs(tab) do
				sectab[v.sec][k] = v
			end
		end
	end

	local sec = stm.sec
	local tasks = self._task

	while sec ~= tm.sec do
		sec = sec + 1
		if sec == 60 then
			sec = 0
		end

		local tab = sectab[sec]

		if not table.empty(tab) then
			sectab[sec] = {}

			for k, v in pairs(tab) do
				v._func()

				if v._count > 0 then
					v._count = v._count - 1
				end
				if v._count ~= 0 then
					if v._interval then
						local ntm = os.date("*t",timestamp+v._interval)
						v.sec = ntm.sec
						v.min = ntm.min
						v.hour = ntm.hour
					end
					self:setTask(v)
				else
					tasks[v.index] = nil
				end
			end
		end
	end

	self._last_tm = tm
end

-- 定时间隔执行
function schedule_mgr_module:addTaskInterval(sec,func,count,index)
	if sec <= 0 then
		return
	end

	if index then
		local t = self._task[index]
		if t then
			t._func = func
			return index
		end
	end

	local task = {
		_func = func,
		_count = count or 1,
		_interval = sec,
	}

	local tm = os.date("*t",os.time()+sec)

	task.sec = tm.sec
	task.min = tm.min
	task.hour = tm.hour
	task.index = index or self:getIndex()
	self:setTask(task)
	return task.index
end

-- 定点执行
--[[
tm = {
	sec: 第几秒0开始
	min: 第几分0开始
	hour: 第几时0开始
}
]]
function schedule_mgr_module:addTaskTimePoint(tm,func,count,index)

	if index then
		local t = self._task[index]
		if t then
			t._func = func
			return index
		end
	end

	local task = {
		_func = func,
		_count = count or 1,
	}

	if tm.sec and (tm.sec < 0 or tm.sec >= 60) then
		return
	end
	if tm.min and (tm.min < 0 or tm.min >= 60) then
		return
	end
	if tm.hour and (tm.hour < 0 or tm.hour >= 24) then
		return
	end

	task.sec = tm.sec
	task.min = tm.min
	task.hour = tm.hour
	task.index = index or self:getIndex()
	self:setTask(task)
	return task.index
end

function schedule_mgr_module:setTask(task)
	local tm = self._last_tm
	if task.hour and tm.hour ~= task.hour then
		self._hour[task.hour][task.index] = task
	elseif task.min and tm.min ~= task.min then
		self._min[task.min][task.index] = task
	else
		self._second[task.sec][task.index] = task
	end
end

function schedule_mgr_module:removeTask(idx)
	local task = self._task[idx]
	if task == nil then
		return
	end

	self._task[idx] = nil
	if task.hour then
		self._hour[task.hour][task.index] = nil
	end
	if task.min then
		self._min[task.min][task.index] = nil
	end
	if task.sec then
		self._second[task.sec][task.index] = nil
	end
end

function schedule_mgr_module:getIndex()
	self._index = self._index + 1
	if self._index >= SCHEDULE_INDEX_BEGIN then
		self._index = 1
	end
	return self._index
end

return schedule_mgr_module