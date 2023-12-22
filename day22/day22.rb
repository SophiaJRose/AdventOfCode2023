def parse_file
	listBricks = Array.new
	File.open("day22Input.txt") do |f|
		f.each_line(chomp: true) do |line|
			startCube = line.split("~")[0].split(",").map {|n| n.to_i}
			endCube = line.split("~")[1].split(",").map {|n| n.to_i}
			listBricks.push({:start => startCube, :end => endCube})
		end
	end
	return listBricks
end

def generate_matrix(listBricks)
	## Get required size of matrix
	maxX = listBricks.max {|a, b| a[:end][0] <=> b[:end][0]}[:end][0]
	maxY = listBricks.max {|a, b| a[:end][1] <=> b[:end][1]}[:end][1]
	maxZ = listBricks.max {|a, b| a[:end][2] <=> b[:end][2]}[:end][2]
	## Initialize matrix
	matrix = Array.new(maxZ+1)
	matrix.each_index do |i|
		matrix[i] = Array.new(maxX+1)
		matrix[i].each_index do |j|
			matrix[i][j] = Array.new(maxY+1, "-")
		end
	end
	## Populate matrix with initial positions of bricks
	listBricks.each_with_index do |brick, brickNum|
		xRange = brick[:start][0]..brick[:end][0]
		yRange = brick[:start][1]..brick[:end][1]
		zRange = brick[:start][2]..brick[:end][2]
		## Only one of these loops has more than one iteration, but we don't know which
		for x in xRange
			for y in yRange
				for z in zRange
					matrix[z][x][y] = brickNum
				end
			end
		end
	end
	## Apply gravity to bricks
	for z in 2..matrix.size-1
		bricksInZ = listBricks.filter {|brick| brick[:start][2] <= z and z <= brick[:end][2]}
		bricksInZ.each do |brick|
			## Look below brick until we find something to support it
			xRange = brick[:start][0]..brick[:end][0]
			yRange = brick[:start][1]..brick[:end][1]
			nextZ = z-1
			spaceUnderneath = matrix[nextZ][xRange].map {|line| line[yRange]}
			while spaceUnderneath.flatten.all? {|cube| cube == "-"} and nextZ >= 1
				nextZ -= 1
				spaceUnderneath = matrix[nextZ][xRange].map {|line| line[yRange]}
			end
			## Move brick down to be on top of found support
			if nextZ+1 != z
				for x in xRange
					for y in yRange
						matrix[nextZ+1][x][y] = matrix[z][x][y]
						matrix[z][x][y] = "-"
					end
				end
			end
		end
	end
	return matrix
end

def get_disintegratable_bricks
	listBricks = parse_file
	matrix = generate_matrix(listBricks)
	disintegratableBricks = 0
	## Find which bricks each brick is supporting
	supportedBricks = Array.new
	listBricks.each_with_index do |brick, brickNum|
		supBricks = Array.new
		xRange = brick[:start][0]..brick[:end][0]
		yRange = brick[:start][1]..brick[:end][1]
		## Cannot take Z directly from brick, as gravity has potentially made it incorrect
		maxZ = matrix.rindex {|plane| plane.flatten.include?(brickNum)}
		if maxZ < matrix.size-1
			for x in xRange
				for y in yRange
					cubeAbove = matrix[maxZ+1][x][y]
					if cubeAbove != "-" and not supBricks.include?(cubeAbove)
						supBricks.push(cubeAbove)
					end
				end
			end
		end
		supportedBricks.push(supBricks)
	end
	## For each brick, if all of the bricks it is supporting are supported by another brick, it can be disintegrated
	supportedBricks.each do |brickList|
		if brickList.all? {|brick| supportedBricks.count {|list| list.include?(brick)} > 1}
			disintegratableBricks += 1
		end
	end
	return disintegratableBricks
end

def get_chain_reaction
	listBricks = parse_file
	matrix = generate_matrix(listBricks)
	sumFallenBricks = 0
	## Find which bricks each brick is supporting
	supportedBricks = Array.new
	listBricks.each_with_index do |brick, brickNum|
		supBricks = Array.new
		xRange = brick[:start][0]..brick[:end][0]
		yRange = brick[:start][1]..brick[:end][1]
		## Cannot take Z directly from brick, as gravity has potentially made it incorrect
		maxZ = matrix.rindex {|plane| plane.flatten.include?(brickNum)}
		if maxZ < matrix.size-1
			for x in xRange
				for y in yRange
					cubeAbove = matrix[maxZ+1][x][y]
					if cubeAbove != "-" and not supBricks.include?(cubeAbove)
						supBricks.push(cubeAbove)
					end
				end
			end
		end
		supportedBricks.push(supBricks)
	end
	## For each brick, find total number of bricks that would fall due to chain reaction
	supportedBricks.each_with_index do |brickList, i|
		fallenBricks = Array.new
		queue = brickList.difference
		until queue.empty?
			brickNum = queue.shift
			supportingBricks = (0...supportedBricks.size).to_a.filter {|n| supportedBricks[n].include?(brickNum)}
			if supportingBricks.all? {|b| b == i or fallenBricks.include?(b)}
				fallenBricks.push(brickNum)
				queue.concat(supportedBricks[brickNum].reject {|b| queue.include?(b)})
			end
		end
		sumFallenBricks += fallenBricks.size
	end
	return sumFallenBricks
end

p get_disintegratable_bricks
p get_chain_reaction