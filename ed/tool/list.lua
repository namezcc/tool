require "class"

local list = class("list")

function list:ctor()
    self._head = nil
    self._tail = nil
    self._size = 0
end

function list:push_back(v)
    local n = {
        _v = v,
        _next = nil,
        _prev = self._tail,
    }

    self._size = self._size + 1

    if self._head == nil then
        self._head = n
        self._tail = n
    else
        self._tail._next = n
        self._tail = n
    end
end

function list:head()
    return self._head
end

function list:pop_front()
    if self._head == nil then
        return nil
    end

    local n = self._head

    self._head = n._next
    self._size = self._size - 1

    if self._head == nil then
        self._tail = nil
    else
        self._head._prev = nil
    end
    return n
end

function list:size()
    return self._size
end

return list