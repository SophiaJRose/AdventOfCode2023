def get_sum_valid_games
	sumIDs = 0
	limits = {"red" => 12, "green" => 13, "blue" => 14}
	File.open("day2Input.txt") do |f|
		f.each_line do |line|
			line.strip!
			validGame = true
			gameID = Integer(line.split(": ")[0].slice(4..))
			game = line.split(": ")[1]
			sets = game.split("; ").each do |set|
				cubes = set.split(", ").each do |cubes|
					parts = cubes.split(" ")
					validCubes = Integer(parts[0]) <= limits[parts[1]]
					validGame = validGame && validCubes
				end
			end
			if validGame
				sumIDs += gameID
			end
		end
	end
	return sumIDs
end

def get_sum_games_power
	sumPowers = 0
	File.open("day2Input.txt") do |f|
		f.each_line do |line|
			line.strip!
			minimums = {"red" => 0, "green" => 0, "blue" => 0}
			game = line.split(": ")[1]
			sets = game.split("; ").each do |set|
				cubes = set.split(", ").each do |cubes|
					parts = cubes.split(" ")
					currentMin = minimums[parts[1]]
					numCubes = Integer(parts[0])
					if numCubes > currentMin
						minimums[parts[1]] = numCubes
					end
				end
			end
			sumPowers += minimums.values.reduce(:*)
		end
	end
	return sumPowers
end

puts get_sum_valid_games
puts get_sum_games_power