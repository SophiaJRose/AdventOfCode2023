def parse_file
	File.open("day14Input.txt") do |f|
		matrix = Array.new
		f.each_line(chomp: true) do |line|
			matrix.push(line.chars)
		end
		return matrix
	end
end

def move_boulders_north(matrix)
	matrix.each_with_index do |line, i|
		line.each_with_index do |char, j|
			if char == "O"
				k = i-1
				while k >= 0 and matrix[k][j] == "."
					k -= 1
				end
				matrix[i][j] = "."
				matrix[k+1][j] = "O"
			end
		end
	end
end

def move_boulders_south(matrix)
	matrix.reverse!
	move_boulders_north(matrix)
	matrix.reverse!
end

def move_boulders_west(matrix)
	matrix.each_with_index do |line, i|
		line.each_with_index do |char, j|
			if char == "O"
				k = j-1
				while k >= 0 and line[k] == "."
					k -= 1
				end
				line[j] = "."
				line[k+1] = "O"
			end
		end
	end
end

def move_boulders_east(matrix)
	matrix.map! {|l| l.reverse!}
	move_boulders_west(matrix)
	matrix.map! {|l| l.reverse!}
end

def get_load
	matrix = parse_file
	totalLoad = 0
	move_boulders_north(matrix)
	## Count load
	matrix.each_with_index do |line, i|
		line.each do |char|
			if char == "O"
				totalLoad += matrix.size - i
			end
		end
	end
	return totalLoad
end

def get_load_spin_cycle
	matrix = parse_file
	totalLoad = 0
	matrixCopy = matrix.map {|l| l.difference}
	previousStates = Hash.new
	startTime = Time.now
	for i in 0...1000000000
		## If a loop is formed, calculate the length of the loop, how many more steps would be needed after X complete loops to reach 1 billion, and get the corresponding matrix
		if previousStates.has_key?(matrix)
			loopStart = previousStates[matrix]
			loopLength = i - loopStart
			extraStepsNeeded = (1000000000 - loopStart) % loopLength
			matrix = previousStates.key(loopStart + extraStepsNeeded)
			break
		end
		matrixCopy = matrix.map {|l| l.difference}
		previousStates[matrixCopy] = i
		move_boulders_north(matrix)
		move_boulders_west(matrix)
		move_boulders_south(matrix)
		move_boulders_east(matrix)
	end
	## Count load
	matrix.each_with_index do |line, i|
		line.each do |char|
			if char == "O"
				totalLoad += matrix.size - i
			end
		end
	end
	return totalLoad
end

p get_load
p get_load_spin_cycle