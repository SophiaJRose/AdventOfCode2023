def parse_file
	matrix = Array.new
	File.open("day17Input.txt") do |f|
		f.each_line(chomp: true) do |line|
			matrix.push(line.chars.map {|n| Integer(n)})
		end
	end
	return matrix
end

def get_min_path(i, j, prevDir, stepCounter, queue)
	## Loop prevention
	pos = [i, j, prevDir]
	if queue.include?(pos)
		return 999999999
	else
		newQueue = queue.difference
		newQueue.push(pos)
	end
	## End case
	if i == $height-1 and j == $width-1
		return 0
	end
	# Work out which directions to check
	canGoRight = prevDir != :left and not (prevDir == :right and stepCounter == 2)
	canGoDown = prevDir != :up and not (prevDir == :down and stepCounter == 2)
	canGoLeft = prevDir != :right and not (prevDir == :left and stepCounter == 2)
	canGoUp = prevDir != :down and not (prevDir == :up and stepCounter == 2)
	currentMin = -1
	## Calculate min path if going right
	if canGoRight
		newSteps = prevDir == :right ? stepCounter+1 : 0
		rightPath = $pathMatrix[i][j][:right][newSteps]
		if not rightPath.nil?
			## If no stored value, calculate and store
			if rightPath == -1
				rightPath = get_min_path(i, j+1, :right, newSteps, newQueue) + $heatLossMatrix[i][j+1]
				$pathMatrix[i][j][:right][newSteps] = rightPath
			end
			## Update currentMin if applicable
			currentMin = (currentMin == -1 or rightPath < currentMin) ? rightPath : currentMin
		end
	end
	## Repeat above logic for down, left and up
	if canGoDown
		newSteps = prevDir == :down ? stepCounter+1 : 0
		downPath = $pathMatrix[i][j][:down][newSteps]
		if not downPath.nil? 
			if downPath == -1
				downPath = get_min_path(i+1, j, :down, newSteps, newQueue) + $heatLossMatrix[i+1][j]
				$pathMatrix[i][j][:right][newSteps] = downPath
			end
			currentMin = (currentMin == -1 or downPath < currentMin) ? downPath : currentMin
		end
	end
	if canGoLeft
		newSteps = prevDir == :left ? stepCounter+1 : 0
		leftPath = $pathMatrix[i][j][:left][newSteps]
		if not leftPath.nil? 
			if leftPath == -1
				leftPath = get_min_path(i, j-1, :left, newSteps, newQueue) + $heatLossMatrix[i][j-1]
				$pathMatrix[i][j][:left][newSteps] = leftPath
			end
			currentMin = (currentMin == -1 or leftPath < currentMin) ? leftPath : currentMin
		end
	end
	if canGoUp
		newSteps = prevDir == :up ? stepCounter+1 : 0
		upPath = $pathMatrix[i][j][:up][newSteps]
		if not upPath.nil? 
			if upPath == -1
				upPath = get_min_path(i-1, j, :up, newSteps, newQueue) + $heatLossMatrix[i-1][j]
				$pathMatrix[i][j][:up][newSteps] = upPath
			end
			currentMin = (currentMin == -1 or upPath < currentMin) ? upPath : currentMin
		end
	end
	return currentMin
end


def get_minimum_heat_loss
	$heatLossMatrix = parse_file
	$height = $heatLossMatrix.size
	$width = $heatLossMatrix[0].size
	$pathMatrix = Array.new($height)
	$pathMatrix.each_index {|i|
		$pathMatrix[i] = Array.new($width)
		$pathMatrix[i].each_index {|j|
			$pathMatrix[i][j] = {
				:right => j == $width-1 ? [nil, nil, nil] : [-1, -1, -1], 
				:down => i == $height-1 ? [nil, nil, nil] : [-1, -1, -1], 
				:left => j == 0 ? [nil, nil, nil] : [-1, -1, -1], 
				:up => i == 0 ? [nil, nil, nil] : [-1, -1, -1]
			}
		}
	}
	rightPath = get_min_path(0, 1, :right, 1, [[0, 0]])
	downPath = get_min_path(1, 0, :down, 1, [[0, 0]])
	return rightPath < downPath ? rightPath : downPath
end

p get_minimum_heat_loss

## Unsolved
## Above attempt gets incorrect answer on example, and quickly reaches "stack level too deep" error on actual input