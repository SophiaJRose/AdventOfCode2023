def parse_file
	matrix = []
	i = 0
	starting_point = [0, 0]
	File.open("day10Input.txt") do |f|
		f.each_line(chomp: true) do |line|
			if pos = line =~ /S/
				starting_point = [pos, i]
			end
			matrix[i] = line.chars
			i += 1
		end
	end
	return matrix, starting_point
end

def add_arrays(a1, a2)
	return a1.zip(a2).map {|a| a.sum}
end

def map_pipe
	matrix, starting_point = parse_file
	surroundingsMap = {"|" => [[-1, 0], [1, 0]], "-" => [[0, -1], [0, 1]], "L" => [[-1, 0], [0, 1]], "J" => [[0, -1], [-1, 0]], "7" => [[0, -1], [1, 0]], "F" => [[1, 0], [0, 1]]}
	## Find connections to starting point
	sX, sY = starting_point[0], starting_point[1]
	startingSurroundings = [matrix[sY-1][sX], matrix[sY][sX-1], matrix[sY][sX+1], matrix[sY+1][sX]] ## ULRD
	startingConnections = ["|7F", "-LF", "-J7", "|LJ"]
	startingConnected = [false, false, false, false]
	for i in 0...4
		startingConnected[i] = startingConnections[i].include?(startingSurroundings[i])
	end
	case startingConnected
	when [true, true, false, false]
		matrix[sY][sX] = "J"
	when [true, false, true, false]
		matrix[sY][sX] = "L"
	when [true, false, false, true]
		matrix[sY][sX] = "|"
	when [false, true, true, false]
		matrix[sY][sX] = "-"
	when [false, true, false, true]
		matrix[sY][sX] = "7"
	when [false, false, true, true]
		matrix[sY][sX] = "F"
	else
		p "Invalid input, starting point S does not have exactly two connections"
		return [-1, -1]
	end
	## Preparation for part 2, must be done before part 1 removes loop tiles
	## Create a new  matrix that is 3x the size of matrix in each dimension, to be a higher resolution version of the pipe diagram
	lettersUpResMap = {
		"." => [[".", ".", "."], [".", ".", "."], [".", ".", "."]],
		"-" => [[".", ".", "."], ["-", "-", "-"], [".", ".", "."]],
		"|" => [[".", "|", "."], [".", "|", "."], [".", "|", "."]],
		"L" => [[".", "|", "."], [".", "L", "-"], [".", ".", "."]],
		"J" => [[".", "|", "."], ["-", "J", "."], [".", ".", "."]],
		"7" => [[".", ".", "."], ["-", "7", "."], [".", "|", "."]],
		"F" => [[".", ".", "."], [".", "F", "-"], [".", "|", "."]]
	}
	## Convert each letter to 3x3 matrix above, then do sequence of array operations to convert nxn matrix of 3x3 matrices to 3nx3n matrix
	matrixUpRes = matrix.map {|l| l.map {|n| lettersUpResMap[n]}.transpose.map{|n| n.flatten}}.flatten(1)
	## Back to part 1 code
	## Traverse loop from starting point in both directions until paths meet
	prevPoints = [[sY, sX], [sY, sX]]
	currentPoints = [add_arrays([sY, sX], surroundingsMap[matrix[sY][sX]][0]), add_arrays([sY, sX], surroundingsMap[matrix[sY][sX]][1])]
	steps = 1
	while currentPoints[0] != currentPoints[1]
		for i in 0..1
			prevPoint = prevPoints[i]
			point = currentPoints[i]
			nextBranches = [add_arrays(point, surroundingsMap[matrix[point[0]][point[1]]][0]), add_arrays(point, surroundingsMap[matrix[point[0]][point[1]]][1])]
			nextBranches.reject! {|branch| prevPoints.include?(branch)}
			prevPoints[i] = currentPoints[i]
			currentPoints[i] = nextBranches[0]
			## Removing loop tiles for part 2
			matrix[prevPoints[i][0]][prevPoints[i][1]] = " "
		end
		steps += 1
	end
	## Remove start and end points of loop
	matrix[sY][sX] = " "
	matrix[currentPoints[0][0]][currentPoints[0][1]] = " "
	p steps
	## Part 2, find enclosed tiles
	## Mark all tiles connected to edge of matrix, non-marked tiles are enclosed in loop
	## Fill from edges
	## Top row
	fillQueue = []
	matrixUpRes[0].each_with_index{
		|tile, j| if tile == "."
			tile = "E"
			fillQueue.push([0, j])
		end
	}
	## Bottom row
	matrixUpRes[matrixUpRes.size-1].each_with_index{
		|tile, j| if tile == "."
			tile = "E"
			fillQueue.push([matrixUpRes.size-1, j])
		end
	}
	## Left and right edges
	matrixUpRes.each_with_index {
		|line, i| if line[0] == "."
			line[0] = "E"
			fillQueue.push([i, 0])
		end
		if line[line.size-1] == "."
			line[line.size-1] = "E"
			fillQueue.push([i, line.size-1])
		end
	}
	## For each tiles marked as connected to edge, mark connected tiles and add to queue
	height = matrixUpRes.size
	width = matrixUpRes[0].size
	until fillQueue.empty?
		nextTile = fillQueue.shift
		x, y = nextTile[0], nextTile[1]
		iRange = (x-1).clamp(0,height-1)..(x+1).clamp(0,height-1)
		jRange = (y-1).clamp(0,width-1)..(y+1).clamp(0,width-1)
		for i in iRange
			for j in jRange
				## Fill with E if empty space, or if corresponding tile in original matrix is not part of the loop
				isCenter = i % 3 == 1 and j % 3 == 1
				notLoop = isCenter ? matrix[(i-1)/3][(j-1)/3] != " " : false
				if matrixUpRes[i][j] == "." or (notLoop and matrixUpRes[i][j] != "E")
					matrixUpRes[i][j] = "E"
					fillQueue.push([i, j])
				end
			end
		end
	end
	## Count enclosed tiles
	## Iterate over original matrix, if tile is not part of pipe and corresponding center tile in up-res matrix is not E, then it is enclosed
	totalEnclosedTiles = 0
	matrix.each_with_index {
		|line, i| line.each_with_index {
			|tile, j| if tile != " " and matrixUpRes[3*i + 1][3*j + 1] != "E"
				totalEnclosedTiles += 1
				matrix[i][j] = "X"
			end
		}
	}
	p totalEnclosedTiles
end

map_pipe