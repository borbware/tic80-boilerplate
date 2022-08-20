angle=function(x,y)return math.atan2(y,x)end

function makeint(f)--thanks i hate it
	return str("%.0f",f)|0
end
function sign(n)return n>0 and 1 or n<0 and -1 or 0 end
function sgn(n)return n>0 and 1 or n<0 and -1 end
function sign_01(n)return n>0 and 1 or 0 end
function signNoZero(n)return n>0 and 1 or -1 end
function clamp(l,n,h)
	return h>l and min(max(n,l),h) or max(min(n,l),h)
end

function outQuad(a,b,t)	return a+(b-a)*(1-(1-t)^2)	end
function outSine(a,b,t)	return a+(b-a)*sin((t*pi)/2)end
function lerpSine(a,b,t)return a+(b-a)*sin(t)end--ends at t=pi/2
function lerp(a,b,t)	return a+(b-a)*t end--(1-t)*a+t*b
function angleLerp(a,b,t)return (a+angleDist(a,b)*t)%(2*pi) end

function invlerp(a,b,v)return (v-a)/(b-a)end
function remapper(in_0,in_1,out_0,out_1,v)
	if in_0==in_1 then return out_1 end
	local t=invlerp(in_0,in_1,v)
	return lerp(out_0,out_1,t)
end
function clampRemapper(in_0,in_1,out_0,out_1,v)
	return clamp(out_0,remapper(in_0,in_1,out_0,out_1,v),out_1)
end

function len(a,b)return sqrt(a^2+b^2)end
function dist(a,b)return len(a.x+a.w/2-b.x-b.w/2,a.y+a.h/2-b.y-b.h/2)end
function dir(a,b)return{x=(a.x-b.x)/dist(a,b),y=(a.y-b.y)/dist(a,b)}end
function normalize(a,b)
	local ln=len(a,b)
	if ln~=0 then
		return a/ln,b/ln
	else
		return 0,0
	end
end


function round(num,decs)
	local mult=10^(decs or 0)
	return flr(num*mult+.5)/mult
end
function modBetween(min,max,a)
	return (a-min)%(max-min+1)+min
end

function angleAdd(a,d)return (a+d)%(2*pi)end
function angleDir(a,b)
	local d=b-a
		if abs(d)<eps then return 0 end
	if d>pi then return -1
	elseif d<-pi then return 1
	else return d>0 and 1 or -1
	end
end
function angleDist(a,b)
	local diff=(b-a+pi)%(2*pi)-pi
	return diff<-pi and diff+pi*2 or diff
end
function rotate(x,y,theta)--positive: clockwise
	return x*cos(theta)-y*sin(theta),x*sin(theta)+y*cos(theta)
end
function rotate90(x,y,cc)
	if cc then return y,-x end
	return -y,x
end


--damped oscillator
function dosc(t,w)return t<200*w and 3*cos(2*pi*t*w)*exp(-t*w) or 0 end
function dosc2(t,w,w2)return t<200*w and 3*sin(2*pi*t*w)*exp(-t*w2) or 0 end



--COLLISION FUNCTIONS:

function pointColl(p,v)
	return p.x>=v.x and p.x<=v.x+v.w and p.y>=v.y and p.y<=v.y+v.h
end
function AABB(e,v)
	return v~=e and e.x+e.w>v.x and e.x<v.x+v.w and e.y+e.h>v.y and e.y<v.y+v.h
end
function AABBborder(e,v)
	return v~=e and e.x+e.w>=v.x and e.x<=v.x+v.w and e.y+e.h>=v.y and e.y<=v.y+v.h
end
function AABBsafe(e,v,safex,safey)
	safey=safey or safex
	return v~=e and e.x+e.w-safex>v.x and e.x+safex<v.x+v.w and e.y+e.h-safey>v.y and e.y+safey<v.y+v.h
end

--[[
--from Cirno's perfect math library (CPML)

CPML is Copyright (c) 2016 Colby Klein shakesoda@gmail.com.
CPML is Copyright (c) 2016 Landon Manning lmanning17@gmail.com.

-- http://gamedev.stackexchange.com/a/18459
-- ray is a vec2
-- ray.dir is a vec2
-- aabb is {x,y,w,h}
]]
function rayAABB(ray,aabb)

	if pointColl(ray,aabb)then
		return
			{
				vec={
					x=ray.x,
					y=ray.y
				},
				dist=0,
				E=aabb,
			}
	end

	local dir=ray.dir --normalized
	local dirfrac={
		x=1/dir.x,
		y=1/dir.y
	}

	local t1=(aabb.x		-ray.x)*dirfrac.x
	local t2=(aabb.x+aabb.w	-ray.x)*dirfrac.x
	local t3=(aabb.y		-ray.y)*dirfrac.y
	local t4=(aabb.y+aabb.h	-ray.y)*dirfrac.y

	local tmin=max(min(t1,t2),min(t3,t4))
	local tmax=min(max(t1,t2),max(t3,t4))

	-- tmax<0:		ray is intersecting AABB, but whole AABB is behind us
	-- tmin>tmax:	ray does not intersect AABB
	-- else:		Return collision point and distance from ray origin
	return (tmax>=0 and tmin<=tmax) and 
		{
			vec={
				x=ray.x+ray.dir.x*tmin,
				y=ray.y+ray.dir.y*tmin
			},
			dist=tmin,
			E=aabb,
		} or false
end

--by ChickenProp (Phil Hazelden)
--https://gist.github.com/ChickenProp/3194723

function lineRectColl(line,rect)--not used anywhere
	local x=line.x1
	local y=line.y1
	local vx=line.x2-line.x1
	local vy=line.y2-line.y1
	local left=rect.x
	local right=rect.x+rect.w
	local top=rect.y
	local bottom=rect.y+rect.h

	local p={-vx,vx,-vy,vy}
	local q={
		x-left,
		right-x,
		y-top,
		bottom-y
	}
	local u1=-1000
	local u2= 1000
	for i=1,4 do
		if p[i]==0 then
			if q[i]<0 then return false end
		else
			local t=q[i]/p[i]
			if p[i]<0 and u1<t then
				u1=t
			elseif p[i]>0 and u2>t then
				u2=t
			end
		end
	end

	if u1>u2 or u1>1 or u1<0 then return false end
	return {
		x=x+u1*vx,
		y=y+u1*vy
	}
end


--http://members.chello.at/~easyfilter/bresenham.html
function bresenhamCirc(xm,ym,r,func,fix)
	local x=-r
	local y=0
	local err=2-2*r -- II. Quadrant
	local eps=0.1
	if fix then
		if abs(r-5)<eps then
			func(xm-2,ym+4)
			func(xm+4,ym+2)
		elseif abs(r-10)<eps then
			func(xm+9,ym+3)
			func(xm-3,ym+9)
		elseif abs(r-12)<eps then
			func(xm-6,ym+11)
		end
	end
	repeat
		local i=0
		local j=0
		--for i=0,0 do
			--for j=0,1 do
				func(xm-(x+i),ym+(y+j)) --I. Quadrant
				func(xm-(y+i),ym-(x+j))	--II. Quadrant */
				func(xm+(x+i),ym-(y+j))	--III. Quadrant */
				func(xm+(y+i),ym+(x+j))	--IV. Quadrant */
			--end
		--end
		r=err
		if r<= y then y=y+1 err=err+y*2+1 end--           /* e_xy+e_y < 0 */
		if r>x or err>y then x=x+1 err=err+x*2+1 end -- /* e_xy+e_x > 0 or no 2nd y-step */
	until (x >= 0)
end
  