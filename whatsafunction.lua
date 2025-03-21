function init()
	input[1]{ mode = 'change', direction = 'falling' }
	input[1].change = function(val1, val2)
        print(val1)
        print(val2)
    end
end