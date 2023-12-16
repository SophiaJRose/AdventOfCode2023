require 'set'

def parse_file
	matrix = Array.new
	File.open("day16Input.txt") do |f|
		f.each_line(chomp: true) do |line|
			matrix.push(line.chars)
		end
	end
	return matrix
end

module Directions
	UP = [-1, 0]
	DOWN = [1, 0]
	LEFT = [0, -1]
	RIGHT = [0, 1]
end

def get_energized_tiles(matrix, startPos, startDir)
	height = matrix.size
	width = matrix[0].size
	tileDirectionMap = {
		"/" => {Directions::UP => [Directions::RIGHT], Directions::DOWN => [Directions::LEFT], Directions::LEFT => [Directions::DOWN], Directions::RIGHT => [Directions::UP]},
		"\\" => {Directions::UP => [Directions::LEFT], Directions::DOWN => [Directions::RIGHT], Directions::LEFT => [Directions::UP], Directions::RIGHT => [Directions::DOWN]},
		"|" => {Directions::UP => [Directions::UP], Directions::DOWN => [Directions::DOWN], Directions::LEFT => [Directions::UP, Directions::DOWN], Directions::RIGHT => [[-1, 0], Directions::DOWN]},
		"-" => {Directions::UP => [Directions::LEFT, Directions::RIGHT], Directions::DOWN => [Directions::LEFT, Directions::RIGHT], Directions::LEFT => [Directions::LEFT], Directions::RIGHT => [Directions::RIGHT]},
		"." => {Directions::UP => [Directions::UP], Directions::DOWN => [Directions::DOWN], Directions::LEFT => [[0, -1]], Directions::RIGHT => [Directions::RIGHT]},
	}
	energizedTiles = Set.new
	currentPos = [startPos]
	currentDir = [startDir]
	until currentPos.empty?
		pos = currentPos.shift
		dir = currentDir.shift
		added = energizedTiles.add?([pos, dir])
		if added.nil?
			next
		end
		tile = matrix[pos[0]][pos[1]]
		newDir = tileDirectionMap[tile][dir].difference		## Difference used to get copy so direction is not deleted from tileDirectionMap
		newPos = newDir.map {|nDir| [pos[0] + nDir[0], pos[1] + nDir[1]] }
		newPos.each_with_index do |nPos, i|
			if nPos[0] < 0 or nPos[0] >= height or nPos[1] < 0 or nPos[1] >= width
				newPos.delete_at(i)
				newDir.delete_at(i)
			end
		end
		currentPos.concat(newPos)
		currentDir.concat(newDir)
	end
	energizedTiles.map! {|pair| pair[0]}
	return energizedTiles.size
end

def get_energized_tiles_any_start
	matrix = parse_file
	height = matrix.size
	width = matrix[0].size
	maxEnergizedTiles = 0
	for i in 0...height
		## Left side, going right
		energizedTiles = get_energized_tiles(matrix, [i, 0], Directions::RIGHT)
		maxEnergizedTiles = energizedTiles > maxEnergizedTiles ? energizedTiles : maxEnergizedTiles
		## Right side, going left
		energizedTiles = get_energized_tiles(matrix, [i, width-1], Directions::LEFT)
		maxEnergizedTiles = energizedTiles > maxEnergizedTiles ? energizedTiles : maxEnergizedTiles
	end
	for j in 0...width
		## Top side, going down
		energizedTiles = get_energized_tiles(matrix, [0, j], Directions::DOWN)
		maxEnergizedTiles = energizedTiles > maxEnergizedTiles ? energizedTiles : maxEnergizedTiles
		## Bottom side, going up
		energizedTiles = get_energized_tiles(matrix, [height-1, j], Directions::UP)
		maxEnergizedTiles = energizedTiles > maxEnergizedTiles ? energizedTiles : maxEnergizedTiles
	end
	return maxEnergizedTiles
end

matrix = parse_file
p get_energized_tiles(matrix, [0, 0], Directions::RIGHT)
p get_energized_tiles_any_start