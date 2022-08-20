
function ripairs(t)--reverse ipairs. https://gist.github.com/balaam/3122129
	return function(t,i)
		i=i-1
		if i~=0 then return i,t[i]
		end
	end, t,#t+1
end

function merge(a,b)--b:n arvot overridaa a:n
	for k,v in pairs(b)do if(type(v)==TBL)and(type(a[k]or false)==TBL)then merge(a[k],b[k])else a[k]=v end end
	return a
end
function deepcopy(a)local b=type(a)local c;if b==TBL then c={}for d,e in next,a,nil do c[deepcopy(d)]=deepcopy(e)end;setmetatable(c,deepcopy(getmetatable(a)))else c=a end;return c end

function rm(tbl,E)
	for i,v in pairs(tbl)do if v==E then del(tbl,i)return end end
end
function any(tbl,cond)for i,v in pairs(tbl)do if cond(v,i)then return true end end return false end
function one(tbl,cond)local n=0;for i,v in pairs(tbl)do if cond(v,i)then n=n+1 end end return n==1 end 
function all(tbl,cond)for i,v in pairs(tbl)do if not cond(v,i)then return false end end return true end
function find(tbl,cond)for i,v in pairs(tbl)do if cond(v,i)then return v,i end end end
function filter(tbl,cond)
	local filtered={}--please do not argument
	for i,v in pairs(tbl)do if cond(v,i)then to(filtered,v)end end
	return filtered
end
function sum(tbl,sumfunc)
	local sum=0
	for i,v in pairs(tbl)do	sum=sum+sumfunc(v,i)end
	return sum
end
function maxof(tbl)
	local maxi=0
	for i,v in pairs(tbl)do	maxi=max(maxi,v)end
	return maxi
end

function keyof(tbl,val)for k,v in pairs(tbl)do if v==val then return k end end end
function has(tbl,val)--returns which key
	for k,v in pairs(tbl)do if v==val then return k end end
	return false
end
function ahasb(a,b)--onko a:ssa b:n arvoja
	for i,v in ipairs(a)do if has(b,v)then return true end end
	return false
end

function mod1(i,tbllen)return (i-1)%tbllen+1 end
function indexof(elem,tbl)
	local index={}
	for k,v in pairs(tbl)do index[v]=k end
	return index[elem] or -1
end
--it's minified and i don't remember anymore where it
function table.show(a,b,c,d,e,f,z)local g;local h;if e then for i,j in ipairs(e)do e[i]="[\""..j.."\"]"end end;if f then for i,j in ipairs(f)do f[i]="[\""..j.."\"]"end end;local function k(a)return next(a)==nil end;local function l(m)local n=tostring(m)if type(m)=="function"then return str("%q",n)
	elseif type(m)==NUM or type(m)==BOO then return n else return str("%q",n)end end;local function o(p,c,d,q,r)d=d or""q=q or{}r=r or c;if e and not(d:len()==origindent:len())then if not e[r]then return end end;g=g..d..r;if type(p)~=TBL then g=g.." = "..l(p)..";\n"
	elseif(z or r=="[\"ent\"]"or r=="[\"words\"]"or r=="[\"ents\"]"or r=="[\"myEnts\"]"or r=="[\"myQuads\"]")then g=g.." = tbl(#"..#p..")not printed;\n"elseif r=="[\"parent\"]"then g=g.." = parent not printed;\n"elseif f and has(f,r)then g=g.." = not printed;\n"elseif b and p~=a then g=g.." = tbl not printed;\n"else if q[p]then g=g.." = {}; -- "..q[p].." (self ref)\n"h=h..c.." = "..q[p]..";\n"else q[p]=c;if k(p)then g=g.." = {};\n"else g=g.." = {\n"for s,j in pairs(p)do s=l(s)local t=str("%s[%s]",c,s)r=str("[%s]",s)o(j,t,d.." ",q,r)end;g=g..d.."};\n"end end end end;if not c and a.name then c=a.name end;c=c or"__unnamed__"if type(a)~=TBL then return c.." = "..l(a)end;g,h="",""d=d or""origindent=d;o(a,c,d)return g end
function printt(t,name,donts,indent,onlys)
	if not t and not debug then return end
	trace(table.show(t,false,name,indent,onlys,donts))
end
function norecprintt(t,name,donts,indent,onlys)trace(table.show(t,false,name,indent,onlys,donts,true))end