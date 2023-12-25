def parse_file
	$wires = Array.new
	$components = Array.new
	$connections = Hash.new
	File.open("day25Input.txt") do |f|
		f.each_line(chomp: true) do |line|
			comp, connections = line.split(": ")
			conns = connections.split(" ")
			if not $components.include?(comp)
				$components.push(comp)
			end
			conns.each do |con|
				$wires.push([comp, con].sort!)
				if not $components.include?(con)
					$components.push(con)
				end
			end
		end
	end
	$components.each do |comp|
		$connections[comp] = $wires.filter {|wire| wire.include?(comp)}.map {|wire| wire.find {|c| c != comp}}
	end
end

def find_groups(excludedWires, requiredConnections)
	## If initialComp happens to be one of the components in the three pairs that must be removed, this definitely fails. Otherwise, hopefully works but no guarantee
	initialComp = $components[0]
	connectedToStart = $connections[initialComp]
	group1 = [initialComp].concat(connectedToStart)
	additions = -1
	until additions == 0
		additions = 0
		($components - group1).each do |comp|
			compConns = $connections[comp].reject {|conn| excludedWires.include?([comp, conn].sort!)}
			if group1.intersection(compConns).size >= requiredConnections
				group1.push(comp)
				additions += 1
			end
		end
	end
	## Group is complete according to chosen requiredConnections, get other group
	return group1, ($components - group1)
end

def get_groups
	## Create global variables $wires, $components and $connections
	parse_file
	## Get potential wires by forming groups, where two connections to components in group 1 are required to be added
	group1, group2 = find_groups([], 2)
	## Get all wires between a component in group 1 and a component in group
	groupToGroupWires = $wires.filter {|wire| (wire.intersection(group1).size == 1) & (wire.intersection(group2).size == 1)}
	groupToGroupWires.combination(3) do |comb|
		p comb
		## For each combination of 3 wires, remove these wires and check if the graph is split into two groups
		testGroup1, testGroup2 = find_groups(comb, 1)
		if not testGroup2.empty?
			return testGroup1.size * testGroup2.size
		end
	end
	return "Failed"
end

p get_groups

## Attempt has been unsuccessful in finding a set of three wires to remove. It is possible that a certain choice of initialComp in find_groups may succeed, but testing each possibility takes too long to be able to try all of them within a reasonable timeframe