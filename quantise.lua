--- quantizer
-- daani b. 4/24/2022
-- in1: voltage to quantize
-- in2:
-- out1: in1 quantized to selected scale
-- out2:
-- out3:
-- out4: original voltage coming in

--function init()
  --  input[1].mode('stream', 0.01)


--- quantize
-- in1: input signal to quantize
-- out1: in1 quantized to provided scale
-- out2: generates a trigger pulse every time a new note occurs

maj = {0,2,4,5,7,9,11}
min = {0,2,3,5,7,8,10}
dorian = {0,2,3,5,7,9,10}
majPent = {0,2,4,7,9}

function init()
  input[1].mode('scale', majPent)

  input[1].scale = function(s)
    output[1].volts = s.volts
    print(input[1].volts .. " => ".. output[1].volts)
    output[2]()
  end

  output[2].action = pulse()
end
