--- tuner script
-- in1: oscillator input
-- out1: v/8 output of detected frequency

function init()
      input[1].mode('freq', 0.01)
      input[2].mode('stream', 0.01)
      output[1].scale({})
end

input[1].freq = function(frequency)
    print("in1 freq: ")
    print(frequency)
    output[1].volts = hztovolts(frequency)
end
