--- mergesort script
--- mergesort code by @postsolarpunk, crow scripting by @awesomebrick



local numOctaves = 3
local seqLength = 4
local sorted = {}




function merge(L, R)
  local result = {}
  local i = 1
  local j = 1

  while i <= #L and j <= #R do
    if L[i] < R[j] then
      table.insert(result, L[i])
      table.insert(sorted, L[i])
      i = i + 1
    else
      table.insert(result, R[i])
      table.insert(sorted, R[i])
      j = j + 1
    end
  end

  while i <= #L do
    table.insert(result, L[i])
    table.insert(sorted, L[i])
    i = i + 1
  end

  while j <= #R do
    table.insert(result, R[j])
    table.insert(sorted, R[i])
    j = j + 1
  end
  return result
end

function mergeSort(arr)

  -- if the array is only one item, the further splits do not occur.
  if #arr <= 1 then
    return arr
  end

  -- divide
  local mid = math.floor(#arr/2)
  local L = {}
  local R = {}

  -- make sub arrays
  for i = 1, mid do
    L[i] = arr[i]
  end
  for i = 1, #arr - mid do
    R[i] = arr[mid + i]
  end

  --continue to split all the way down the left subtree.
  L = mergeSort(L)
  --continue to split all the way down the right subtree.
  R = mergeSort(R)
  --merge the left and right subtrees, in a sorted order.
  return merge(L, R)
  
end

function pingNote(note)
    output[1].volts = note
    output[2].action = pulse()

end

function generateSequence()
    seq = {}
    for i=1,seqLength do
        seq[i] = math.random()*numOctaves
    end
    return seq
end

function resetSequence()
    notes = generateSequence()
    sorted = {}
    
    print("notes before")
    printArray(notes)

    print("sorted before")
    printArray(sorted)

    notes = mergeSort(notes)

    print('notes after')
    printArray(notes)

    print("sorted after")
    printArray(sorted)


    --this can be replaced with iteration later.
    -- for i=0,#sorted do
    --     pingNote(sorted[i])
    -- end
end



--locals
local scale = {1,2,3,5,6,8,9,11}


--initialize inputs and outputs.
function init()

    --initialize sequence
    --randomSequence = sequins{}

    --setup i/o and related functions.
    input[1].mode("clock", 1/4)
    input[2].mode("change", 3,0.01, 'rising')
    output[1].scale(scale)
    --output[2].mode("")

    --iterate once. no idea how to implement this. deal with it later.
    --input[1].clock = stepThrough()
    -- rerun the sequence from the beginning on gate.
    input[2].change = resetSequence

    
    --run the sequence on startup.
    --resetSequence()

end




-- notes = {1, 3, 2, 4, 1}

function printArray(notes)
    values = ""
    for i = 1, #notes do
        values = values..notes[i]
    end
    print(values)
end