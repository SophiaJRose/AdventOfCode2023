def parse_file(singleRace = false)
	File.open("day6Input.txt") do |f|
		races = Array.new
		if singleRace
			time = Integer(f.readline(chomp: true).split(":")[1].gsub!(" ", ""))
			dist = Integer(f.readline(chomp: true).split(":")[1].gsub!(" ", ""))
			return [[time, dist]]
		end
		times = f.readline(chomp: true).split(":")[1].split(" ").map {|n| Integer(n)}
		dists = f.readline(chomp: true).split(":")[1].split(" ").map {|n| Integer(n)}
		races = times.zip(dists)
		return races
	end
end

def get_ways_to_win(singleRace = false)
	races = parse_file(singleRace)
	totalWays = 1
	races.each do |race|
		waysToWin = 0
		time = race[0]
		dist = race[1]
		## Range can start at 1 and end at time-1 before 0 and time always give zero distance
		for i in 1...time
			if (i * (time-i)) <= dist
				next
			end
			## Here we have first value of i milliseconds button held that can win
			## Last value is time-i, so waysToWin = time - 2i
			waysToWin = time + 1 - (2 * i)
			break
		end
		totalWays *= waysToWin
	end
	return totalWays
end

p get_ways_to_win
p get_ways_to_win(true)