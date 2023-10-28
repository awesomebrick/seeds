--- simple tuner/buff mult app. put a voltage into input 1, stream the value to druid and send voltage to all outputs
-- in1: tuning voltage
-- out1-4: duplicates of in1 voltage

function init()
	input[1].mode('stream', 0.01)
  input[2].mode('')
end

input[1].stream = function(volts)
	output[1].volts = input[1].volts
	output[2].volts = input[1].volts
	output[3].volts = input[1].volts
	output[4].volts = input[1].volts
end
