--[[
Copyright (c) 2006-2007, Kyle Smith
All rights reserved.
Contributors:
	Alimov Stepan
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the author nor the names of its contributors may be
      used to endorse or promote products derived from this software without
      specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]

local strbyte,strlen,strsub,type=string.byte,string.len,string.sub,type

-- returns the number of bytes used by the UTF-8 character at byte c in b
-- also doubles as a UTF-8 character validator
local function utf8charbytes(b,c)c=c or 1;if type(b)~="string"then error("bad argument #1 to 'utf8charbytes' (string expected, got "..type(b)..")")end;if type(c)~="number"then error("bad argument #2 to 'utf8charbytes' (number expected, got "..type(c)..")")end;local d=strbyte(b,c)if d>0 and d<=127 then return 1 elseif d>=194 and d<=223 then local e=strbyte(b,c+1)if not e then error("UTF-8 string terminated early")end;if e<128 or e>191 then error("Invalid UTF-8 character")end;return 2 elseif d>=224 and d<=239 then local e=strbyte(b,c+1)local f=strbyte(b,c+2)if not e or not f then error("UTF-8 string terminated early")end;if d==224 and(e<160 or e>191)then error("Invalid UTF-8 character")elseif d==237 and(e<128 or e>159)then error("Invalid UTF-8 character")elseif e<128 or e>191 then error("Invalid UTF-8 character")end;if f<128 or f>191 then error("Invalid UTF-8 character")end;return 3 elseif d>=240 and d<=244 then local e=strbyte(b,c+1)local f=strbyte(b,c+2)local g=strbyte(b,c+3)if not e or not f or not g then error("UTF-8 string terminated early")end;if d==240 and(e<144 or e>191)then error("Invalid UTF-8 character")elseif d==244 and(e<128 or e>143)then error("Invalid UTF-8 character")elseif e<128 or e>191 then error("Invalid UTF-8 character")end;if f<128 or f>191 then error("Invalid UTF-8 character")end;if g<128 or g>191 then error("Invalid UTF-8 character")end;return 4 else error(string.format("Invalid UTF-8 character %d at %d",d,c))end end

-- functions identically to string.sub except that i and j are UTF-8 characters instead of bytes
function utf8sub(b,c,d)d=d or-1;local e=1;local f=b:len()local g=0;local h=c>=0 and d>=0 or utf8len(b)local i=c>=0 and c or h+c+1;local j=d>=0 and d or h+d+1;if i>j then return""end;local k,l=1,f;while e<=f do g=g+1;if g==i then k=e end;e=e+utf8charbytes(b,e)if g==j then l=e-1;break end end;if i>g then k=f+1 end;if j<1 then l=0 end;return b:sub(k,l)end
-- returns the number of characters in a UTF-8 string

function utf8len(b)if type(b)~="string"then error("bad argument #1 to 'utf8len' (string expected, got "..type(b)..")")end;local c=1;local d=b:len()local e=0;while c<=d do e=e+1;c=c+utf8charbytes(b,c)end;return e end
