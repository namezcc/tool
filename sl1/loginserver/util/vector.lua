local vector = class("vector")

function vector:ctor()
	self._data = {}
end

function vector:push_back(v)
	self._data[#self._data+1] = v
end

function vector:pop_back()
	if #self._data == 0 then
		return nil
	end
	local v = self._data[#self._data]
	self._data[#self._data] = nil
	return v
end

function vector:size()
	return #self._data
end

return vector