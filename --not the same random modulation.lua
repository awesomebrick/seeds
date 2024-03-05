--not the same random modulation

    

input[1].change = function(state) 
    slew_in_seconds = math.abs(input[2].volts/5)
    for k,v in ipairs(output) 
    do
        output[k].volts = math.random(-5,5)
        output[k].slew = slew_in_seconds
    end
    --print ("outputs changed")
    --print (output[k].slewrate)
end


function init()
    input[1].mode('change', 1, 0.1, 'rising')
    input[2].mode("stream")
    slew_in_seconds = 0


    --for i=1,4  -- this is a for loop used to set the default settings.
    --do
    --    output[i].slew = dyn{slewrate = 0.1}
    --    --output[i].shape = slewShape
    --end

end