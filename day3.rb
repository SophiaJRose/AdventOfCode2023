def parse_file
	matrix = []
	i = 0
	File.open("day3Input.txt") do |f|
		f.each_line(chomp: true) do |line|
			matrix[i] = line
			i += 1
		end
	end
	return matrix
end

def check_surroundings_for_symbols(matrix, i, jRange, height, width)
	iSearchRange = (i-1).clamp(0,height-1)..(i+1).clamp(0,height-1)
	jSearchRange = (jRange.min - 1).clamp(0,width-1)..(jRange.max + 1).clamp(0,width-1)
	searchRows = matrix[iSearchRange]
	return searchRows.any? {|line| not((line[jSearchRange] =~ /[^0-9\.]/).nil?)}
end

def find_surrounding_gears(matrix, i, jRange, height, width)
	iSearchRange = (i-1).clamp(0,height-1)..(i+1).clamp(0,height-1)
	jSearchRange = (jRange.min - 1).clamp(0,width-1)..(jRange.max + 1).clamp(0,width-1)
	listGears = []
	for x in iSearchRange
		for y in jSearchRange
			if matrix[x][y] =~ /\*/
				listGears.push({x: x, y: y, number: Integer(matrix[i][jRange])})
			end
		end
	end
	return listGears
end

def find_part_numbers
	sumPartNumbers = 0
	matrix = parse_file
	height = matrix.length
	width = matrix[0].length
	for i in 0...height do
		## Declare numberEnd here and check j < numberEnd at start of inner loop to avoid counting same part number multiple times
		numberEnd = 0
		for j in 0...width do 
			if j < numberEnd
				next
			end
			char = matrix[i][j]
			if char =~ /[0-9]/
				numberEnd = j
				while matrix[i][numberEnd] =~ /[0-9]/
					numberEnd += 1
				end
				jRange = j...numberEnd
				if check_surroundings_for_symbols(matrix, i, jRange, height, width)
					sumPartNumbers += Integer(matrix[i][jRange])
				end
				## Skip to end of number to repeat counting it multiple times
				j = numberEnd
			end
		end
	end
	return sumPartNumbers
end

def find_gear_ratios
	sumGearRatios = 0
	listGears = []
	matrix = parse_file
	height = matrix.length
	width = matrix[0].length
	for i in 0...height do
		## Declare numberEnd here and check j < numberEnd at start of inner loop to avoid checking same part number multiple times
		numberEnd = 0
		for j in 0...width do 
			if j < numberEnd
				next
			end
			char = matrix[i][j]
			if char =~ /[0-9]/
				numberEnd = j
				while matrix[i][numberEnd] =~ /[0-9]/
					numberEnd += 1
				end
				listGears.concat(find_surrounding_gears(matrix, i, j...numberEnd, height, width))
				## Skip to end of number to repeat counting it multiple times
				j = numberEnd
			end
		end
	end
	listGears.combination(2) do |comb|
		if comb[0][:x] == comb[1][:x] and comb[0][:y] == comb[1][:y]
			sumGearRatios += comb[0][:number] * comb[1][:number]
		end
	end
	return sumGearRatios
end

puts find_part_numbers
puts find_gear_ratios