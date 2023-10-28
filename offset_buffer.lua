--- simple buffered mult with an offset.
-- in1: buffer input
-- in2: offset CV
-- out1-2: original input
-- out3-4: offset CV

function init()
  input[1].mode('stream', 0.01)
  input[2].mode('stream', 0.01)
end

input[1].stream = function(volts)
 input[2].stream = inputOffset
 output[1].volts = input[1].volts
 output[2].volts = input[1].volts
 output[3].volts = input[1].volts + inputOffset
 output[4].volts = input[1].volts + inputOffset
end
