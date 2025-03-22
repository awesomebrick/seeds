--- sorting algorithm
--- script that generates those funky sorting algorithm arps you've seen on yt.
--- mergesort code provided by @postsolarpunk, crow scripting and options added by @awesomebrick
-- created 3/20/2025
-- last updated 3/21/2025
--
-- in1: trigger. plays the next note in the sequence.
-- in2: trigger. resets the sequence to a new pattern.
-- out1: v/8. outputs quantized osc pitch value.
-- out2: cv. AR envelope for oscillators.
-- out3: trigger. pulse() for env generators.
-- out4: gate. outputs HIGH when playing the sorted list, LOW when playing unsorted or partially sorted list.

-- --- --- --- GLOBAL VARIABLES --- --- --- --

-- all of these variables have getters&setters.


seq_length = 32 -- length of the sequence
-- TODO change this to just octaves? maybe put the 12 in the sequence generation function?
note_range = 12 * 6 -- number of notes. 12tones for 6 octaves.
manuallyResetSequence = false -- generate a new sequence once the previous one has been played to sorted completion.
sortingAlgorithm = "mergesort" -- default sorting algo is mergesort.

-- all ii stuff disabled by default.
-- this script will generate a lot of commands at high clock speeds for the sequence, may hog the bus.
jf_enabled = false
wsyn_enabled = false 


-- table of available preset scales.
allScales = {
    chromatic = {1,2,3,4,5,6,7,8,9,10,11},
    major = {0,2,4,5,7,9,11},
    minor = {0,2,3,5,7,8,10},
    dorian = {0,2,3,5,7,9,10},
    majPent = {0,2,4,7,9}
}

-- table of all implemented sorting algos. if you implement a new one, add it to this option and the resetSequence function below.
-- the keys are the algo names, the values are true, to speed up lookup times.
allSortingAlgorithms = {
    mergesort = true,
    bubblesort = true,
    stalinsort = true
}


-- --- --- --- SORTING ALGOS --- --- --- --

-- notes on adding sorting algos:
-- TLDR: on each comparison where an item is iterated over, you need to call table.insert(sorting_notes, <note>)

--[[ 
this script doesn't really use the notes[] table itself to play notes until the final iteration.
since a lot of sorting algorithms are recursive, we can't effectively iterate through them on command.
so, we don't. instead of pinging notes as we see them in the algorithms (since the sorting speed is too fast for that),
we use a separate array here, sorting_notes[], to store each value as it gets compared.
this gives us the appearance of each note being played as it is being sorted, with the ability to iterate across it.
the downside, obviously, is that on long sequences at worst case sorting, sorting_notes[] could get very large.
crow reliably seems to run out of memory at a sequence length of about ~142
as is, the script will warn you if you attempt to set the sequence length longer than 140 using the setter function, and clamp it down.
This clamping does not occur if the sequence length is set >140 in the script itself, useful for testing purposes.
]]--


-- mergesort. implementation by @postsolarpunk.
function merge(L, R)
  local result = {}
  local i, j = 1, 1

  -- merge while sorting.
  while i <= #L and j <= #R do
    if L[i]  < R[j] then
      table.insert(result, L[i])
      table.insert(sorting_notes, L[i])
      i = i + 1
    else
      table.insert(result, R[j])
      table.insert(sorting_notes, R[j])
      j = j + 1
    end
  end

  -- fill out, if either sublist is longer than the other.
  while i <= #L do
    table.insert(result, L[i])
    table.insert(sorting_notes, L[i])
    i = i + 1
  end
  while j <= #R do
    table.insert(result, R[j])
    table.insert(sorting_notes, R[j])
    j = j + 1
  end
  return result
end
function mergeSort(arr) -- returns sorted array.

  -- if the current list is 1 item long, back out of current recursion, to be merged.
  if #arr <= 1 then
    return arr
  end

  -- divide into subarrays
  local mid = math.floor(#arr/2)
  local L = {}
  local R = {}

  for i = 1, mid do
    L[i] = arr[i]
  end
  for i = 1, #arr - mid do
    R[i] = arr[mid + i]
  end

  -- recurse upon subtrees
  L = mergeSort(L)
  R = mergeSort(R)
  -- merge sorted lists.
  return merge(L, R)
end

-- bubblesort. implementation [googled and altered] by @awesomebrick
function bubbleSort(arr) -- sorts in place.
    local found_swap = true
    while found_swap do
        found_swap = false
        for i = 1, #arr-1 do
            table.insert(sorting_notes, arr[i])
            if arr[i+1] < arr[i] then
                table.insert(sorting_notes, arr[i+1]) -- not sure if this is needed here? putting it here anyway.
                arr[i+1], arr[i] = arr[i], arr[i+1]
                found_swap = true
            end
        end
    end
end

-- stalinsort. implemented by @awesomebrick
-- i thought this would be funny and easy to implement lmao
function stalinSort(arr) -- sorts in place (obviously)
    local i = 1

    while arr[i+1] do
        table.insert(sorting_notes, arr[i])
        table.insert(sorting_notes, arr[i+1])
        if arr[i]<arr[i+1] then
            i++
        else -- if i+1 is smaller then.
            table.remove(arr, i+1) -- get stalin'd
        end
    end
    table.insert(sorting_notes, arr[i]) -- since we're doing while i+1 in the loop, we need to add the final item.
end

-- --- --- --- RUNNING FUNCTIONS --- --- --- --

-- pings a note.
-- TODO: implement JF and w/syn implementation (and corresponding activation vars/funcs)
-- currently this runs the commands for either jf OR wsyn while also outputting on crow's hardware.
-- i don't have JF to confirm, but doing both would kill the ii bus i imagine.
-- JF has priority. Just arbitrarily, it doesn't really matter.
function pingNote(note_number)
    output[1].volts = note_number / 12
    output[2]() -- trigger pulse()
    output[3]() -- trigger ar()

    if jf_enabled then
        ii.jf.play_note(note_number/12, 1)
    elseif wsyn_enabled then
        ii.wsyn.play_note(note_number/12, 1)
    end

    --technically this gets called every ping which is terribly inefficient, 
    --but i'll be changing what the outputs all do later. so this is fine for now
    if sorted then
        output[4].volts = 5
    else
        output[4].volts = 0
    end
end

-- steps through the generated sequence on each call.
function step_sequence()
  idx = idx + 1 -- increment on each call

  -- note:
  --[[
  the var "sorted" which is used here is a bit of a misnomer. it doesn't indicate that list is sorted, 
  it indicates whether our sequence has run through the entirety of the sorting_notes table.
  the explanation for why sorting_notes exists is at the top of the SORTING ALGOS section. 
  ]]--


  -- run through the entirety of the sorting sequence before running the sorted list.
  if sorted == false and idx >= #sorting_notes then
    sorted = true
    idx = 1
  end

  -- ping notes
  if sorted == true then -- if we've played through the sorting_notes list, switch to the sorted list.
    pingNote(notes[idx])
  elseif sorted == false then
    pingNote(sorting_notes[idx])
  end

  -- if we've completed running the original sorted list, start over with a new list.
  if sorted == true and idx > #notes then
    idx = 1
    if ~manuallyResetSequence then -- option to require a manual sequence reset
        reset_sequence()
    end
  end
end

-- generates a new sequence of values.
function generate_sequence()
  local seq = {}
  for i=0,seq_length do
      seq[i] = math.random(0,note_range)
  end
  sorted = false --new sequence means unsorted list.
  return seq
end

-- resets the sequence generation, regenerating and sorting sequence.
function reset_sequence()

    idx = 1 -- lua is 1indexed :skull:
    sorted = false -- sets the sequencer to play the sorting sequence first.
    sorting_notes = {}
    notes = generate_sequence()
    
    -- ifelse block that checks and uses the selected sorting algorithm.
    -- for algos that return the sorted array use notes=<algorithm>(notes)
    -- for algos that sort in place use <algorithm>(notes)
    if sortingAlgorithm == "mergesort" then
        notes = mergeSort(notes)
    elseif sortingAlgorithm == "bubblesort" then
        bubbleSort(notes)
    end
    return

end

-- --- --- --- VARIABLE GETTERS AND SETTERS --- --- --- --
-- all getters both return, and print to the REPL their respective values. No need to call print(getScale()) or anything like that.

-- check the currently defined quantization scale.
function getScale()
    print(scale)
    return scale
end

-- technically this says get, but it just prints the allScales table. Returns nothing.
function getAllScales()
    for k,v in pairs(allScales) do
        s = ""
        for i=1,#v do -- ew. the values in allScales are technically tables too. annoying.
            s = s..v[i]..","
        end
        print(k.." = "..s)
    end
end

-- set the output quantization scale.
function setScale(newScale)
    if type(newScale) == "table" then -- define a scale and use that.
        local isnumtab = true
        for i=1,#newScale do -- checks if all values in array are numbers.
            if type(newScale[i]) ~= "number" then
                isnumtab = false
                break
            end
        end

        if isnumtab then --if newScale is an array of numbers, set scale directly.
            scale = newScale
            return
        else
            print("error: scale table must be all numbers.")
            return
        end

    elseif type(newScale) == string then -- or, use one of the predefined scale options.
        if allScales[newScale] ~= nil then -- if item exists in the table,
            scale = allScales[newScale]
            print("Now using scale"..scale)
            return
        else
            print("error: Option not defined in allScales table. Available scales are:")
            getAllScales()
            print("Use addScale(scaleName, scaleDefinition) to add an item.")
            return
        end
    end
end

-- add an item to the predefined list of scales.
function addScale(scaleName, scaleDefinition)

    -- argument type errorchecking.
    if type(scaleName) ~= "string" then
        print("error: Scale name should be a string.")
        return
    end

    if type(scaleDefinition) ~= "table" then
        print("error: scaleDefinition must be a table of numbers.")
        return
    elseif type(scaleDefinition) == "table" then
        local isnumtab = true
        for i=1,#scaleDefinition do -- checks if all values in array are numbers.
            if type(scaleDefinition[i]) ~= "number" then
                isnumtab = false
                break
            end
        end
        if isnumtab == false then --if scaleDef is not a table of numbers, error message and return.
            print("error: scaleDefinition table must be all numbers.")
            return
        end
    end

    --if all error checks pass, add items to table.
    allScales[scaleName] = scaleDefinition
    --let people know this addition will be lost on reset.
    print("Added scale "..scaleName.." to currently running allScales. This addition will be lost on power cycle or Crow reset.")
    print("If you want this addition to persist, edit allScales in the code to include your scale.")
    return
end

function getSeqLength()
    print(seq_length)
    return seq_length
end

-- sets sequence length. Values greater than ~142 cause crow to run out of memory, so this function clamps it to 140
function setSeqLength(newSeqLength)

    -- typechecking.
    if type(newSeqLength) ~= "number" then
        print("error: newSeqLength must be an int.")
        return
    end

    --warn the user if they're trying large sequence lengths.
    if newSeqLength>140 then
        print("Sequence lengths longer than 140 cause Crow to run out of memory.")
        print("Setting sequence length to 140.")
        newSeqLength = 140
    end

    seq_length = newSeqLength
    print("Sequence length set to "..seq_length)
    return
end

-- Return the octave range of generated notes.
function getNoteRange()
    print(noteRange/12)
    return note_range/12
end

-- Sets the octave range of generated values. Will technically accept ints >8 but clamps the input.
-- note: should this generate a new sequence? or let the current one play out first?
-- gut says maybe it should, but i understand the argument that it shouldn't.
function setNoteRange(newOctaves)
    if type(newOctaves) ~= "number" then
        print("error: newOctaves must be an int.")
        return
    elseif newOctaves>8 then
        print("Yikes, do you really want that many octaves? Clamping to 8.")
        newOctaves = 8
    end

    note_range = 12*newOctaves
    return
end

-- returns the currently active sorting algorithm.
function getSortingAlgorithm()
    print(sortingAlgorithm)
    return sortingAlgorithm
end

-- much like the similar function for allScales, this only prints and does not return a value.
function getAllSortingAlgorithms()
    for k,v in pairs(allSortingAlgorithms)
    s = ""
    s=s..k..", "
    print(s)
end

-- selects a sorting algorithm. choose one from the list.
function setSortingAlgorithm(newAlgo)
    if allSortingAlgorithms[newAlgo] == nil then
        print(newAlgo .." is not an implemented algorithm.")
        print("Available algorithms are: ")

        return
    end

    sortingAlgorithm = newAlgo
end

-- enables the manual sequence reset functionality.
function enableManualReset(active=true)
    if type(active) ~= "boolean" then
        print("error: Value must be boolean.")
        return
    else
        manuallyResetSequence = active
    end
    return
end


-- enables ii commands for just friends
function enableJF(active=true)
    jf_enabled = active
    if active then
        print("ii.jf enabled.")
    else
        print("ii.jf disabled.")
    end
end

-- enables ii commands for w/syn
function enableWSyn(active=true)
    wsyn_enabled = active
    if active then
        print("ii.wsyn enabled.")
    else
        print("ii.wsyn disabled.")
    end
end

-- --- --- --- CROW INIT CODE --- --- --- --

function init()

    -- initialize script variables.
    notes = {}
    sorting_notes = {}
    scale = allScales["chromatic"]
    idx = 0
  
    reset_sequence() -- run sequence on startup

    -- i/o setup
    input[1].mode('change', 1, 0.1, 'rising')
    input[1].change = step_sequence
    input[2].mode('change', 1, 0.1, 'rising')
    input[2].change = reset_sequence
    output[1].scale(scale)
    output[2].action = ar()
    output[3].action = pulse()

end