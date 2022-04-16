local tconcat = table.concat
local xpcall = xpcall

local function CreateDispatcher(argCount)
	local code = [[
		local xpcall = ...
		local method, ARGS
		local function call() return method(ARGS) end
	
		local function dispatch(func, eh, ...)
			method = func
			if not method then return end
			ARGS = ...
			return xpcall(call, eh)
		end
	
		return dispatch
	]]
	
	local ARGS = {}
	for i = 1, argCount do ARGS[i] = "arg"..i end
	code = code:gsub("ARGS", tconcat(ARGS, ", "))
	return assert(loadstring(code, "safecall Dispatcher["..argCount.."]"))(xpcall)
end

local Dispatchers = setmetatable({}, {__index=function(self, argCount)
	local dispatcher = CreateDispatcher(argCount)
	rawset(self, argCount, dispatcher)
	return dispatcher
end})

Dispatchers[0] = function(func, errorhandler)
	return xpcall(func, errorhandler)
end
 
function _G.xpcall(func, errorhandler, ...)
	return Dispatchers[select("#", ...)](func, errorhandler, ...)
end

function _G.tIndexOf(tbl, val)
	for k, v in pairs(tbl) do
		if v == val then
			return k
		end
	end
end