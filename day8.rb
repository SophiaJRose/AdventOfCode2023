def navigate_map(multiple_routes = false)
	File.open("day8Input.txt") do |f|
		directions = f.readline(chomp: true)
		f.readline() ## empty line
		nodes = Hash.new
		f.each_line(chomp: true) do |line|
			nodes[line[...3]] = [line[7...10], line[12...15]]
		end
		currentNodes = Array.new
		if multiple_routes 
			currentNodes = nodes.keys.filter {|k| k[-1] == "A"}
		else
			currentNodes = ["AAA"]
		end
		i = 0
		stepsTaken = currentNodes.map {|n| [0, false]}
		until stepsTaken.all? {|step| step[1]}
			goRight = directions[i % directions.size] == "R"
			for j in 0...currentNodes.size
				currentNodes[j] = goRight ? nodes[currentNodes[j]][1] : nodes[currentNodes[j]][0]
				## Count steps taken to reach node ending in Z until it is found
				if currentNodes[j][-1] != "Z" and not stepsTaken[j][1]
					stepsTaken[j][0] += 1
				elsif currentNodes[j][-1] == "Z"
					stepsTaken[j][0] += 1
					stepsTaken[j][1] = true
				end
			end
			i += 1
		end
		totalSteps = stepsTaken.map {|step| step[0]}.reduce(1, :lcm)
		return totalSteps
	end
end

p navigate_map
p navigate_map(true)