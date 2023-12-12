def get_configurations(unfold = false)
	totalConfigurations = 0
	File.open("day12Input.txt") do |f|
		f.each_line(chomp: true) do |line|
			groupList = line.split(" ")[1]
			if unfold
				groupList = ([groupList] * 5).join(",")
			end
			groupSizes = groupList.split(",").map {|s| Integer(s)}
			groups = groupSizes.map {|s| "#" * s}
			springs = line.split(" ")[0]
			if unfold
				springs = ([springs] * 5).join("?")
			end
			regexpString = "\\.*"
			groups.each do |group|
				regexpString += group + "\\.+"
			end
			regexpString = regexpString[...regexpString.size-1] + "*"
			regexp = Regexp.new(regexpString)
			unknownIndices = Array.new
			for i in 0...springs.size
				if springs[i] == "?"
					unknownIndices.push(i)
				end
			end
			unplacedSprings = groupSizes.sum - springs.count("#")
			## Check all possible arrangements of unplaced springs, if it matches regex it is a configuration, add it
			unknownIndices.combination(unplacedSprings) do |comb|
				possibleSprings = String.new(springs)
				comb.each do |index|
					possibleSprings[index] = "#"
				end
				possibleSprings.tr!("?", ".")
				if (possibleSprings =~ regexp) != nil
					totalConfigurations += 1
				end
			end
		end
	end
	return totalConfigurations
end

p get_configurations
# p get_configurations(true)

## Solution is too inefficient to solve part 2