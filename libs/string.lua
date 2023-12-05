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


--map characters into font set
function utf8enumerate(text)
	local i=1
	local txtlen=strlen(text)
	local map={}
	--skip first 16 tiles because font() has special behaviour for some of them
	--and 16 more minus four
	local tile=32-4
	while i<=txtlen do
		local len=utf8charbytes(text,i)
		local char=strsub(text,i,i+len-1)
		map[char]=string.char(tile)
		tile=tile+1
		i=i+len
	end
	return map
end

local function utf8printf(text,x,y,color,fixed,scale,align,smallfont)
	local i=1
	local x0=x
	local txtlen=strlen(text)
	fixed=fixed or false
	scale=scale or 1
	align=align or false
	local w=0
	if align then
		w=utf8printf(text,-1000,-1000,color,fixed,scale,false,smallfont)
		local shift=align=="right"and w or align=="centered" and w/2
		x=x-shift
	end
	while i<=txtlen do
		local len=utf8charbytes(text, i)
		local char=strsub(text,i,i+len-1)

		if skands[char]then
			local y2=(char=="Ä" or char=="Ö"or char=="⌘")and -scale or 0
			pal(1,color)
			bpp(1)
			local smallChars={
				["ä"]="æ",
				["ö"]="ø",
				["Ä"]="Æ",
				["Ö"]="Ø",
			}
			local replaceSmall=smallfont and smallChars[char]
			if replaceSmall then
				char=smallChars[char]
			end
			x=x+font(skands[char],x,y+y2,0,6,8,fixed,scale)
			if fixed and skands[char]:byte()>38 then--jp fix
				x=x+2
			elseif replaceSmall then
				x=x-2
			end
			bpp(4)
			pal(1,1)
		else
			x=x+print(char,x,y,color,fixed,scale,smallfont)
		end
		i=i+len
	end
	return align and w or x-x0
end

function utf8print(text,x,y,color,fixed,scale,centered,smallfont)
	local l,w=0,0
	scale=scale or 1
	local h=6
	for s in text:gmatch("[^\r\n]+")do
		w=utf8printf(s,x,y+l*h*scale,color,fixed,scale,centered,smallfont)
		l=l+1
	end
	return w
end

function setlen(s,l,char)char=char or " ";if utf8len(s)<l then return setlen(s..char,l,char)else return s end end
local skandstr="æøÆØäöÄÖ"
skands=utf8enumerate(skandstr)

