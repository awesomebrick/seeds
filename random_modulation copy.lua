--- random modulation:
-- a simple script to generate four random voltages on every clock pulse
-- daani b. 4/25/2023
-- last updated 1/19/2024
-- in1: clock
-- in2: slew time
-- out1-4: random modulation

--- --- this section for variables to adjust functionality --- ---
--slewShape = 


input[1].change = function(state) 
    slew_in_seconds = input[2].volts/5
    for i=1,4 do
        output[i](to(math.random(-5,5), dyn{slew = slew_in_seconds}))
    end
    --print 'outputs changed' 
end


input[2].stream = function(volts)
    for i=1,4 do
        output[i].dyn.slew = volts/5
    end
end


function init()
    input[1].mode('change', 1, 0.1, 'rising')
    input[2].mode("stream")

    --different flavors of slewed modulation. left commented for now for developmental simplicity.
    --[[
    output[1].shape = "linear"
    output[2].shape = "sine"
    output[3].shape = "logarithmic"
    output[4].shape = "exponential"
    ]]--

    for i=1,4  -- this is a for loop used to set the default settings.
    do
        output[i].slew = dyn{slewrate = 0.1}
        --output[i].shape = slewShape
    end
    
    
end



