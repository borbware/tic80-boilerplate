function trace2(...)--trace with multiple arguments
	local args={...}
	local str=""
	for i,v in ipairs(args)do
		if v==nil then
			str=str.."nil"
		else
			str=str..tostring(v)
		end
	end
	return trace(str,15)
end
function string:getNumber()
	return self:match("%d+")
end
function string:startsWith(prefix)
	return self:sub(1,#prefix)==prefix
end
function string:split(delimiter)--by jared allard --https://gist.github.com/jaredallard/ddb152179831dd23b230
	local result={}
	local from=1
	local delim_from,delim_to=string.find(self,delimiter,from)
	while delim_from do
		to(result,string.sub(self,from,delim_from-1))
		from=delim_to+1
		delim_from,delim_to=string.find(self,delimiter,from)
	end
	to(result,string.sub(self,from))
	return result
end
function tolines2(str)return str:split("\n")end

function tolines(str)
	local l={}
	for s in str:gmatch("[^\r\n]+")do to(l,s)end
	return l
end

function towords(str,withSpecials)
	local regex=withSpecials and "%S+" or "(%w+)"
	local l={}
	for s in str:gmatch(regex)do to(l,s)end
	return l
end
