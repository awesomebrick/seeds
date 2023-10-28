--- random modulation:
-- a simple script to generate four random voltages on every clock pulse
-- daani b 4/25/2023
-- in1: clock
-- in2: [slew rate?]
-- out1-4: random modulation


input[1].change = function(state)
    output[1].volts = math.random(-5,5)
    output[2].volts = math.random(-5,5)
    output[3].volts = math.random(-5,5)
    output[4].volts = math.random(-5,5)
    --print 'outputs changed' 
end




function init()
    input[1].mode('change', 1, 0.1, 'rising')
    --input[2].mode() --unused for now
end