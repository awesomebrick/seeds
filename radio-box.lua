--- radio-box
-- daani b. 12/20/2024
--
-- utility for personal radio-powered granular lunchbox build.
-- contains quantiser, and clock divider.
--
-- in1: clock to divide.
-- in2: voltage to quantise
-- out1: clock division A (default clk/1)
-- out2: clock division B (default clk/4)
-- out3: clock division C (default clk/8)
-- out4: quantised voltage from in1 (default major)

-------------------SCALES AND DEFINITIONS--------------------------

major = {0,2,4,5,7,9,11}
minor = {0,2,3,5,7,8,10}
dorian = {0,2,3,5,7,9,10}
majPent = {0,2,4,7,9}
minPent = {0,3,5,7,10}

--placeholder array, to show what scales are implemented.
--TODO have this array also contain the actual scale arrays itself, so it's indexable for future functions.
scaleOptions = {['major'] = major, ['minor'] = minor, ['dorian'] = dorian, ['majPent'] = majPent, ['minPent'] = minPent}

--public variables for visiblity to norns
public{currentScale = 'major'}:options{'major', 'minor', 'dorian', 'majPent', 'minPent'}:action{changeScale}
public.divisionA = 1
public.divisionB = 4
public.divisionC = 8

function init()
  input[1].mode('clock', 1) --considers incoming clk at 1/1, for division's sake	
  input[2].mode('scale', major)

  input[2].scale = scaleFunc(s)
  
  output[1]:clock(divisionA) --default to clk/1
  output[2]:clock(divisionB) --defaults to clk/4
  output[3]:clock(divisionC) --defaults to clk/8
--  output[4].mode() --unneeded.
end


--fucnction for in2.
function scaleFunc (s)
	output[4].volts = s.volts
	print(input[2].volts .. " => " .. output[4].volts)
	output[4]()
end

-----------REPL FUNCTIONS------------
--functions below this line are for REPL operation.
--Useful for live coding.

--Prints out the available scales.
--TODO when scaleOptions() contains the actual scales, print those as well.
function availableScales() 
	for k,v in scaleOptions do
		print(scaleOptions[k] .. ": " .. scaleOptions[v])
	end
end

function changeScale (scale)
	currentScale = scale
  input[2].mode('scale', scaleOptions[scale])
end
