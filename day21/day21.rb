def parse_file
	matrix = Array.new
	startPos = [0,0]
	File.open("day21Input.txt") do |f| 
		f.each_with_index() do |line, i|
			line.chomp!
			sPos = line =~ /S/
			if not sPos.nil?
				startPos = [i, sPos]
			end
			matrix.push(line.chars)
		end
	end
	return matrix, startPos
end

def get_plots(maxSteps = 64, overrideStartPos = nil)
	matrix, startPos = parse_file
	if not overrideStartPos.nil?
		startPos = overrideStartPos
	end
	queue = [startPos]
	nextQueue = Array.new
	evenPlots = Array.new
	oddPlots = Array.new
	stepCounter = 0
	until stepCounter == maxSteps
		until queue.empty?
			currentPos = queue.shift
			i = currentPos[0]
			j = currentPos[1]
			if i-1 >= 0 and matrix[i-1][j] != "#" and not nextQueue.include?([i-1, j]) and not evenPlots.include?([i-1, j]) and not oddPlots.include?([i-1, j])
				nextQueue.push([i-1, j])
			end
			if i+1 < matrix.size and matrix[i+1][j] != "#" and not nextQueue.include?([i+1, j]) and not evenPlots.include?([i+1, j]) and not oddPlots.include?([i+1, j])
				nextQueue.push([i+1, j])
			end
			if j-1 >= 0 and matrix[i][j-1] != "#" and not nextQueue.include?([i, j-1]) and not evenPlots.include?([i, j-1]) and not oddPlots.include?([i, j-1])
				nextQueue.push([i, j-1])
			end
			if j+1 < matrix[i].size and matrix[i][j+1] != "#" and not nextQueue.include?([i, j+1]) and not evenPlots.include?([i, j+1]) and not oddPlots.include?([i, j+1])
				nextQueue.push([i, j+1])
			end
		end
		queue = nextQueue.difference
		nextQueue = Array.new
		stepCounter += 1
		if stepCounter % 2 == 0
			evenPlots.concat(queue)
		else
			oddPlots.concat(queue)
		end
	end
	if maxSteps % 2 == 0
		return evenPlots.size
	else
		return oddPlots.size
	end
end

## This solution uses multiple assumptions that can easily be proven true for the given input, but may not hold true for an arbitrary input map. These are:
## 1) that the map is a square
## 2) that, as the edges of the maps and row and column containing the starting point are all empty, you can travel directly in at most two straight lines to the edge or corner of any map repetition
def get_plots_infinite
	matrix, _ = parse_file
	length = matrix.size
	## Call get_plots with a step count much higher than the size of the map to get number of plots reachable by any number of steps, split by odd or even
	plotsInMapOddSteps = get_plots(length * 2 + 1)
	plotsInMapEvenSteps = get_plots(length * 2)
	## Start with total plots reachable in original starting map
	totalPlots = plotsInMapOddSteps
	## Travelling in a single direction, there are M map repetitions we can reach, where M = maxSteps / length.
	## Travelling 1 <= A <= M map repetitions upwards, and 0 <= B <= M - A map repetitions to the right, there are sum(1..M) + M map repetitions we can reach
	## Of these, there is 1 where we enter from the bottom, with 130 steps remaining, M where we enter from the bottom-left corner with 64 steps remaining, M-1 where we enter from the same corner with 195 steps remaining, and sum(1..M-1) where we can reach all plots
	## Because map length is an odd number, the plots we can end on in map reps where we can reach all plots depends whether we have travelled an odd or even number of map reps to get there
	## Repeat for all 4 diagonals, i.e. A reps right and B down, A down and B left, and A left and B up
	axisLength = 26501365 / length
	## We will have even steps left if we've travelled odd map reps, and odd steps if even map reps
	fullReachablePlotsEvenSteps = (1..(axisLength-1)).to_a.filter{|n| n % 2 == 1}.sum
	fullReachablePlotsOddSteps = (1..(axisLength-1)).to_a.filter{|n| n % 2 == 0}.sum
	## Bottom, right, top, left
	edges = [[130,65], [65,130], [0,65], [65,0]]
	## Bottom-left, top-left, top-right, bottom-right
	corners = [[130,0], [0,0], [0,130], [130,130]]
	for i in 0..3
		plotsFromEdge = get_plots(130, edges[i])
		totalPlots += plotsFromEdge
		plotsFromCorner1 = get_plots(64, corners[i])
		totalPlots += plotsFromCorner1 * axisLength
		plotsFromCorner2 = get_plots(195, corners[i])
		totalPlots += plotsFromCorner2 * (axisLength - 1)
		totalPlots += plotsInMapOddSteps * fullReachablePlotsOddSteps
		totalPlots += plotsInMapEvenSteps * fullReachablePlotsEvenSteps
	end
	return totalPlots	
end

p get_plots
p get_plots_infinite