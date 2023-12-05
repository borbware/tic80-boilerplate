function bpp(num)
	local adr=num==1 and 8 or num==2 and 4 or num==4 and 2
	if adr then poke4(2*0x03FFC,adr)end
end

function bank(section,bnk,tocart)
	local mask,k
	if type(section)=="number"then
		mask=section
	elseif type(section)=="string"then
		local sections={
			[0]="tiles",
			"sprites",
			"map",
			"sfx",
			"music",
			"palette",
			"flags",
			"screen"
		}
		k=keyof(sections,section)
		mask=1<<k
	end
	if k and k>=0 and k<=7 then
		sync(mask,bnk,tocart)
	else trace("bank change to "..bnk.." failed",3)end
end

function setvol(ch,vol)--ch 0-3,vol 0-15.by verysoftwares
	local val=peek(0xFF9C+18*ch+1)
	poke(0xFF9C+18*ch+1,val&(0x0f|vol<<4))
end

function setcol(colindex,newcol)
	local addr=0x3fc0+colindex*3
	poke(addr,  newcol.r)
	poke(addr+1,newcol.g)
	poke(addr+2,newcol.b)
end

function resetpal()
	for c=0,15 do
		poke4(0x3FF0*2+c,c)
	end
end

function pal(c0,c1)
	if(c0==nil and c1==nil)then
		resetpal()
	else
		poke4(0x3FF0*2+c0,c1)
	end
end