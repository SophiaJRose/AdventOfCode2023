def parse_file
	matrix = Array.new
	File.open("day23Input.txt") do |f|
		f.each_line(chomp: true) do |line|
			matrix.push(line.chars)
		end
	end
	return matrix
end

class PathTree
	@pos
	@distance
	@branches

	def initialize(pos, distance, branches)
		@pos = pos
		@distance = distance
		@branches = branches
	end

	def get_max_distance(path)
		## Avoid calculating distance of infinite loops
		if path.include?(@pos)
			return 0
		end
		if @branches.nil?
			return @distance
		end
		path.push(@pos)
		branchDistances = @branches.map {|branch| branch.get_max_distance(path.difference)}
		if branchDistances.all? {|d| d == 0}
			return 0
		end
		return branchDistances.max + @distance
	end
end

def find_next_nodes(startPos, lastPos)
	if $memoizationTable.has_key?(startPos)
		return $memoizationTable[startPos]
	end
	pos = startPos
	nextPos = [pos]
	steps = 0
	while nextPos.size < 2
		if nextPos.empty?
			return nil
		end
		pos = nextPos.shift
		steps += 1
		if pos == $endPos
			tree = PathTree.new(pos, steps, nil)
			$memoizationTable[startPos] = tree
			return tree
		end
		directions = Array.new
		tile = $matrix[pos[0]][pos[1]]
		if $slopes and tile == ">"
			directions = [[pos[0], pos[1]+1]]
		elsif $slopes and tile == "v"
			directions = [[pos[0]+1, pos[1]]]
		else
			up = pos[0] > 0 ? (($slopes and $matrix[pos[0]-1][pos[1]] == "v") ? nil : [pos[0]-1, pos[1]]) : nil
			down = pos[0] < $height-1 ? [pos[0]+1, pos[1]] : nil
			left = pos[1] > 0 ? (($slopes and $matrix[pos[0]][pos[1]-1] == ">") ? nil : [pos[0], pos[1]-1]) : nil
			right = pos[1] < $width-1 ? [pos[0], pos[1]+1] : nil
			directions = [up, down, left, right].reject {|dir| dir == nil or $matrix[dir[0]][dir[1]] == "#" or dir == lastPos}
		end
		nextPos.concat(directions)
		lastPos = pos
	end
	branches = Array.new
	## Save tree with no branches to memoization tree to prevent infinite processing loops, save again with branches once they have been found
	tree = PathTree.new(pos, steps, branches)
	$memoizationTable[startPos] = tree
	nextPos.each do |nPos|
		tree = find_next_nodes(nPos, pos)
		if not tree.nil?
			branches.push(tree)
		end
	end
	if branches.empty?
		return nil
	end
	tree = PathTree.new(pos, steps, branches)
	$memoizationTable[startPos] = tree
	return tree
end

def get_path_binary_tree(slopes = true)
	$memoizationTable = Hash.new
	$slopes = slopes
	$matrix = parse_file
	$height = $matrix.size
	$width = $matrix[0].size
	$endPos = [$height-1, $width-2]
	$listOfBranchPoints = Array.new
	pathTree = find_next_nodes([1,1], [0,1])
	return pathTree.get_max_distance(Array.new)
end

p get_path_binary_tree
p get_path_binary_tree(false)