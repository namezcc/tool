local _func = LFUNC

local function day_zero(t)
	t = t or _func.getNowSecond()
	if t < 0 then
		t = 0
	end
	local tm = os.date("*t",t)
	return t - tm.sec - tm.min*60 - tm.hour*3600
end

local function week_zero(t)
	t = t or _func.getNowSecond()
	if t < 0 then
		t = 0
	end
	local tm = os.date("*t", t)
	local day = (tm.wday + 5) % 7
	return t - tm.sec - tm.min*60 - tm.hour*3600 - day*86400
end

local function day_diff(old,new,offset)
	new = new or _func.getNowSecond()
	offset = offset or 0
	old = day_zero(old - offset)
	new = day_zero(new - offset)
	return (new - old)/86400
end

local function week_diff(old,new)
	new = new or _func.getNowSecond()
	local old_zero = week_zero(old)
	local new_zero = week_zero(new)
	if old_zero < new_zero then
		return ((new_zero - old_zero) / 604800) > 0
	else
		return ((old_zero - new_zero) / 604800) > 0
	end
end

local function month_diff(old,new)
	new = new or _func.getNowSecond()
	local old_tm = os.date("*t", old)
	local new_tm = os.date("*t", new)
	return old_tm.year ~= new_tm.year or old_tm.month ~= new_tm.month
end

local function year_diff(old,new)
	new = new or _func.getNowSecond()
	local old_tm = os.date("*t", old)
	local new_tm = os.date("*t", new)
	return old_tm.year ~= new_tm.year
end

local function get_day_of_month(t)
	t = t or _func.getNowSecond()
	local tm = os.date("*t",t)
	return tm.day
end
-- 1-7,����1-7
local function get_week(t)
	t = t or _func.getNowSecond()
	local tm = os.date("*t",t)
	return math.fmod(tm.wday+5,7)+1
end

local function get_month(t)
	t = t or _func.getNowSecond()
	local tm = os.date("*t",t)
	return tm.month
end

TIME_UTIL = {
	day_zero = day_zero,
	day_diff = day_diff,
	week_zero = week_zero,
	week_diff = week_diff,
	month_diff = month_diff,
	year_diff = year_diff,
	get_week = get_week,
	get_month = get_month,
	get_day_of_month = get_day_of_month,
}