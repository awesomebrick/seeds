--- through chaos, music.
-- daani b. 2024
--
-- crow: 
-- in1: trigger
-- in2: pitch
-- out1-4: random modulation
--
-- ansible
-- in1: trigger note
-- tr 1-4: note triggers
-- cv 1-2: note v8

------------------------------
local scale = {1,2,3,5,6,8,9,11}
local chord = {0,4,7,10}

m = require 'musicutil'

local note = 1
local scale2 = m.generate_scale(0,"dorian",2)
local ExtMin = 0
local ExtMax = 10
local ExtRange = ExtMax - ExtMin


function ansiblePlay(channel, streamed)

	-- this block is pulled from crow-quantize.lua.
	-- it's intended for JF and not direct 
	--[[
	ExtRange = ExtMax - ExtMin
	note = math.floor(((((streamed - (ExtMin)) * (#scale-1)) / ExtRange) + 1) + 0.5)
	if note <= #scale and note >= 1 then
  		note = note
	elseif note >= #scale then
  		note = #scale
	elseif note < 1 then
  		note = 1
	end
	]]--

	--this version is so i understand what the math is doing

	--                    input val    scale len.  div by range?
	-- scale len here is the number of notes.
	-- range is the difference between the maximum and minimum voltage values, 0-10. maximum voltage possible.

	-- streamed - (ExtMin) subtracts the min from streamed. setting the floor to 0, the first note in scale[].
	-- (streamed) * (#scale-1) is multiplying the minzeroed value by scale's length, zero indexed. the purpose of this is... i don't know.
	-- (((streamed) * (#scale-1)) / 10) divides that resulting value by the range available.

	--note = math.floor(((((streamed) * (#scale-1)) / 	10) + 		1) + 		0.5)
	--let me try writing something myself.

	--this is just straight input. no quantization.
	note = streamed

	--divides the streamed value by 12. quantizes it to equal temperament.
	note = streamed/12
	--but we don't want note to be a direct voltage value. we want it to  be an index.
	-- so how do i make it so it calculates which value of scale[] it falls closest to?

	-- or what if.

	octave = note // 1
	semitone = (note %1)/12

	note = 

	-- if the value for note falls within the index for values in scale{} then..
	if note <= #scale and note >= 1 then
  		note = note						-- note stays as note

	-- if the value for note is outside the array..
	elseif note >= #scale then
  		note = #scale 			-- then note falls to the highest note possible.
	-- if note falls below 0...
	elseif note < 1 then
  		note = 1				-- then set the note to the first value.
	end

				-- uses note as an index for scale2 array's value.
	ii.ansible.cv_set(channel, scale2[note])
	ii.ansible.trigger_pulse(channel)
	--print("new note: ", note)
end

function onClock()
	ansiblePlay(1, (math.random()*2)%0.08333333333)
	ansiblePlay(2, (math.random()*2)%0.08333333333)
	ansiblePlay(3, (math.random()*2)%0.08333333333)
	ansiblePlay(4, (math.random()*2)%0.08333333333)
end

function init()
	input[1]{ mode = 'change', direction = 'rising' }
	input[1].change = onClock

end

--[[]
ExtRange = ExtMax - ExtMin
note = math.floor(((((unqnote - (ExtMin)) * (#scale-1)) / ExtRange) + 1) + 0.5)
if note <= #scale and note >= 1 then
  note = note
elseif note >= # scale then
  note = #scale
elseif note < 1 then
  note = 1
end
crow.ii.jf.play_note(scale[note]/12-1,math.random(5)+1)
]]--