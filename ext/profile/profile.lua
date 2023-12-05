-- https://tic80.com/play?cart=562
-- Profile tool for TIC-80/lua
-- Copyright (c) 2018 Gavin Stewart
-- Licensed under the terms of the
--  MIT License here:
--  https://opensource.org/licenses/MIT

profile={--profiler
	-- Private variables
	version='1.0',
	data={},
	frame=0,
	output={
		text='',
		calc={},
		calcFrames=0,
		calcRam=0,
		calcTime=0,
		frames=0,
		period=1,--in frames
		period_i=1,
		periods={1,2,8,15,30,60},--in frames
		pause=false,
	},
	shade={
		state='hide',--show|hide
		offset=0,
	},
	profileSums={
		["Wupd+Wdrw"]={"W:upd","W:drw"},
		--["scanCALC+ENT+TIL"]={"scanCALC","scanENT","scanTIL"},
		["UPDplats+noplats"]={"UPDplats","UPDnoplts"},
		["SUM OF UPD"]={"UPD "},--match
	},
}

-- Profile public methods
	
-- profile:start(name)
-- @param name <= 13 chars
function profile:start(name,mode)
	name=string.sub(name,1,13)
	if not self.data[name] then
		self.data[name]={}
		self.data[name].acc=0
		self.data[name].count=0
		self.data[name].mode=mode or 0
	end
	self.data[name].start=time()
end

-- profile:stop(name)
-- @param name <= 13 chars
function profile:stop(name)
	name=string.sub(name,1,13)
	if not self.data[name] or not self.data[name].start then
		self.data[name]={}
		self.data[name].acc=0
		self.data[name].count=0
		log('profile:stop called before start for: '..name.."\n")
		return
	end
	self.data[name].acc=self.data[name].acc+time()-self.data[name].start
	self.data[name].count=self.data[name].count+1
end

-- profile:update(fgColour,bgColour)
-- Call once per frame from end of
--  TIC() or OVR(). Press ` key to
--  see output on screen.
-- @param fgColour Optional palatte
--  index else defaults to 15
-- @param bgColour Optional palatte
--  index else defaults to 0
function profile:update(fgColour,bgColour)
	fgColour=fgColour or 15
	bgColour=bgColour or 0
	self.frame=self.frame + 1

	-- Show or hide modes with 0-9 keys
	for i=0,9 do
		if debug and keyp(27+i,0,30) and not key(KEYS.SHIFT) then
			if self.shade.state=='show' then
				if self.shade.mode~=i then
					self.shade.mode=i
				else
					self.shade.state='hide'
					self.output.pause=false
				end
			else
				self.shade.mode=i
				self.shade.state='show'
			end
		end
	end

	-- Pause output(while show)
	if keyp(KEYS.P,0,30) then
		if self.shade.state=='show' then
			if self.output.pause==true then
				self.output.pause=false
			else	
				self.output.pause=true
			end
		end
	end

	-- Less output.period
	if keyp(KEYS.PGDN,0,7) then
		if self.shade.state=='show' then
			self.output.period_i=mod1(self.output.period_i-1,#self.output.periods)
			self.output.period=self.output.periods[self.output.period_i]
			if self.output.period<1 then
				self.output.period=1
			end
		end
	end

	-- More output.period
	if keyp(KEYS.PGUP,0,7) then
		if self.shade.state=='show' then
			self.output.period_i=mod1(self.output.period_i+1,#self.output.periods)
			self.output.period=self.output.periods[self.output.period_i]
			if self.output.period>999 then
				self.output.period=999
			end
		end
	end
	
	profile:updateText()
	-- press O to send output text to trace()
	-- even if output not shown to screen.
	if keyp(KEYS.O,0,30) then
		log(self.output.text,fgColour)
	end

	-- Shade up or down
	local _,outputLines=self.output.text:gsub('\n','\n')
	if self.shade.state=='show' and self.shade.offset < 0 then
		--self.shade.offset=self.shade.offset + 2
	elseif self.shade.state=='hide' and self.shade.offset>=-6*outputLines then
		--self.shade.offset=self.shade.offset - 2
	end

	-- Display output
	if self.shade.state=='show' then
		print(self.output.text,1,self.shade.offset+1,bgColour,true)
		print(self.output.text,0,self.shade.offset,fgColour,true)
	end
end

-- Profile private methods.

-- Use acc(umulated) time and call 
-- count to build calc table in acc 
-- order.


function profile:updateCalc()
	local function accumulate(sum,item)
		sum.acc=  sum.acc+	item.acc
		sum.count=sum.count+item.count
	end
	self.output.calc={}
	self.output.calcTime=time()/1000
	self.output.calcFrames=self.output.frames
	self.output.calcRam=collectgarbage('count')

	-- Calculate sum of functions listed in profilesums
	for profileFuncSum,profileFuncs in pairs(self.profileSums)do
		local first=self.data[profileFuncs[1]]
		local mode=first and first.mode or 0
		self.data[profileFuncSum]={
			acc=0,
			count=0,
			mode=mode
		}
		if #profileFuncs==1 then--match string. goes to mode 0
			for n,data in pairs(self.data)do
				if n:match(profileFuncs[1])then
					accumulate(self.data[profileFuncSum],self.data[n])
				end
			end
		else
			for i,n in pairs(profileFuncs)do
				if self.data[n]then
					accumulate(self.data[profileFuncSum],self.data[n])
				end
			end
		end
	end

	-- Build calc table,order by acc
	local c=5
	for name in pairs(self.data) do
		to(self.output.calc,
			{name=name,
				acc=self.data[name].acc,
				count=self.data[name].count,
				mode=self.data[name].mode
			})
		-- Zero acc and count
		self.data[name].acc=0
		self.data[name].count=0
	end
	function compAcc(a,b)
		return(a.acc>b.acc)
	end
	sort(self.output.calc,compAcc)
end

-- Build up output.text from
-- calc table.
function profile:updateText()
	-- Recalculate at period intervals
	if self.output.pause==false then
		self.output.frames=self.output.frames+1
		if self.output.frames>=self.output.period then
			profile:updateCalc()
			self.output.frames=0
		end
	else
		self.data={}
		self.output.frames=0
	end

	-- Header
	local pauseState
	if self.output.pause==true and self.frame%60>30 then
		pauseState=' '
	else
		pauseState=':'
	end
	--self.output.text=""
	--[[  str(
			"Profile v%3s       (C)2018 Gavin Stewart\n",
			self.version)..
			"----------------------------------------\n"]]
	-- Help footer
	--self.output.text=self.output.text ..
	--		" 0 show PgUp/Dn +-frms (P)ause (O)trace\n"
	local now=time()/1000
	local realtime=	str("%02.0f:%05.2f ",now//60%100,now%60)
	local frames=	str("%2dfrms   ",self.output.period)
	local calcTime=	str("%02.0f%1s%05.2f   ",
		self.output.calcTime//60%100,
		pauseState,
		self.output.calcTime%60)
	local ram=		str("%8.1fKB ",self.output.calcRam)--10.1
	local fps=FPS and "FPS "..FPS.fps.."    " or "          "
	--self.output.text=self.output.text..realtime..frames..calcTime..ram.."\n"
	self.output.text=fps
	if any(self.output.calc,function(t)return t.mode==self.shade.mode end) then
		self.output.text=self.output.text..calcTime..frames..ram.."\n"..
		"\n"..
		"call//frm ms/frm name \n"..
		"\n"
	end

	-- Output ordered calc table
	for i,t in ipairs(self.output.calc) do
		if t.mode==self.shade.mode then
			self.output.text=self.output.text..str(
				"%9d %6.2f %-18s \n",
				t.count//self.output.calcFrames,
				t.acc / self.output.calcFrames,
				t.name)
		end
	end
end
