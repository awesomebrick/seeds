--- random modulation (by trent):
-- a simple script to generate four random voltages on every clock pulse
-- daani b. initial code/idea;
-- this code implementation provided by Galapagoose on the lines forum
-- in1: clock
-- in2: slew time
-- out1-4: random modulation


-- this value is a "time" not a "rate", hence the name
slew_time = 1 -- start with an initial value

function rand_volts()
  for i=1,4 do
    --define an ASL and execute it immediately
    output[i](to(math.random(-5,5), dyn{slew=slew_time}))
  end
end

function set_slew(volts)
  slew_time = volts/5
  for i=1,4 do
    -- set the slew time of currently-in-motion outputs
    output[i].dyn.slew = slew_time
  end
end

function init()
  input[1].change = rand_volts
  input[2].stream = set_slew

  rand_volts()

  input[1].mode{mode = "change", direction = "rising"} -- only trigger on rising edge
  input[2].mode("stream", 0.01) -- scan every 10ms
end