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


function ansiblePlay(channel, note)
	ii.ansible.cv_set(channel, note)
	ii.ansible.trigger_toggle(channel)
	print("new note: ", note)
end

function init()

	print('setting up.')
	input[1]{ mode = 'change', direction = 'rising' }
	print('mode changed')
	input[1].change = ansiblePlay(1, math.random()*5)
	print('set up.')
	

end
