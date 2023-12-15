def parse_file
	matrix = Array.new
	galaxyPositions = Array.new
	emptyRows = Array.new
	emptyCols = Array.new
	File.open("day11Input.txt") do |f|
		f.each_with_index {|line, i| 
			line.chomp!
			matrix.push(line.chars)
			if (line =~ /#/) == nil
				emptyRows.push(i)
				next
			end
		}
		matrix.transpose.each_with_index {|col, i| 
			unless col.include?("#")
				emptyCols.push(i)
			end
		}
		matrix.each_with_index {|line, i|
			line.each_with_index {|char, j|
				if char == "#"
					galaxyPositions.push([i, j])
				end
			}
		}
	end
	return matrix, galaxyPositions, emptyRows, emptyCols
end

def get_distances(expansion_amount = 2)
	matrix, galaxyPositions, emptyRows, emptyCols = parse_file
	sumDistances = 0
	galaxyPositions.combination(2) {|comb| 
		unexpandedDistance = (comb[0][0] - comb[1][0]).abs + (comb[0][1] - comb[1][1]).abs
		rows = comb[0][0]...comb[1][0]
		numEmptyRows = emptyRows.filter {|r| rows.cover?(r)}.size
		cols = comb[0][1] < comb[1][1] ? comb[0][1]...comb[1][1] : comb[1][1]...comb[0][1]
		numEmptyColumns = emptyCols.filter {|c| cols.cover?(c)}.size
		expandedDistance = unexpandedDistance + (numEmptyRows * (expansion_amount - 1)) + (numEmptyColumns * (expansion_amount - 1))
		sumDistances += expandedDistance
	}
	return sumDistances
end

p get_distances
p get_distances(1000000)