def parse_file
	workflows = Hash.new
	parts = Array.new
	File.open("day19Input.txt") do |f|
		line = f.readline(chomp: true)
		until line == ""
			label = line.split("{")[0]
			rulesStr = line.split("{")[1].gsub("}", "")
			rules = rulesStr.split(",")
			workflowRules = Array.new
			rules.each do |rule|
				if rule.include?(":")
					ruleParts = rule.split(":")
					dest = ruleParts[1]
					cond = ruleParts[0]
					if cond.include?(">")
						condParts = cond.split(">")
						category = condParts[0]
						value = condParts[1].to_i
						workflowRules.push({:condition => lambda {|part| part[category] > value}, :dest => dest})
					else
						condParts = cond.split("<")
						category = condParts[0]
						value = condParts[1].to_i
						workflowRules.push({:condition => lambda {|part| part[category] < value}, :dest => dest})
					end
				else
					dest = rule
					workflowRules.push({:dest => dest})
				end
			end
			workflows[label] = workflowRules
			line = f.readline(chomp: true)
		end
		f.each_line(chomp: true) do |line|
			ratings = line[1...line.size-1].split(",")
			part = Hash.new
			ratings.each do |rating|
				ratingParts = rating.split("=")
				part[ratingParts[0]] = ratingParts[1].to_i
			end
			parts.push(part)
		end
	end
	return workflows, parts
end

def getTotalRatings
	totalRatings = 0
	workflows, parts = parse_file
	parts.each do |part|
		currentWorkflow = "in"
		while workflows.has_key?(currentWorkflow)
			## For a set of rules, check each rules condition; if the part passes, go to the destination, otherwise check the next rule
			## If rule has no condition, go to destination
			rules = workflows[currentWorkflow]
			rules.each do |rule|
				if rule.has_key?(:condition)
					passesCond = rule[:condition].call(part)
					if passesCond
						currentWorkflow = rule[:dest]
						break
					end
				else
					currentWorkflow = rule[:dest]
					break
				end
			end
		end
		## currentWorkflow is now either A or R; if A, add ratings to total; if R, do nothing
		if currentWorkflow == "A"
			totalRatings += part.values.sum
		end
	end
	return totalRatings
end

def parse_workflows
	workflows = Hash.new
	File.open("day19Input.txt") do |f|
		f.each_line(chomp: true) do |line|
			if line == ""
				break
			end
			label = line.split("{")[0]
			rulesStr = line.split("{")[1].gsub("}", "")
			rules = rulesStr.split(",")
			workflowRules = Array.new
			rules.each do |rule|
				if rule.include?(":")
					ruleParts = rule.split(":")
					dest = ruleParts[1]
					cond = ruleParts[0]
					if cond.include?(">")
						condParts = cond.split(">")
						category = condParts[0]
						value = condParts[1].to_i+1
						workflowRules.push({:category => category, :bound => "min", :value => value, :dest => dest})
					else
						condParts = cond.split("<")
						category = condParts[0]
						value = condParts[1].to_i-1
						workflowRules.push({:category => category, :bound => "max", :value => value, :dest => dest})
					end
				else
					dest = rule
					workflowRules.push({:dest => dest})
				end
			end
			workflows[label] = workflowRules
		end
	end
	return workflows
end

def getDistinctRatings
	workflows = parse_workflows
	queue = [{:label => "in", :ranges => {"x" => 1..4000, "m" => 1..4000, "a" => 1..4000, "s" => 1..4000}}]
	acceptedRanges = Array.new
	## For a set of ranges at a given workflow, split into the sets at each possible destination, and add these sets to the queue, until queue is empty
	until queue.empty?
		rangeSet = queue.shift
		label = rangeSet[:label]
		ranges = rangeSet[:ranges]
		if label == "A"
			acceptedRanges.push(ranges)
			next
		elsif label == "R"
			next
		end
		rules = workflows[label]
		rules.each do |rule|
			if rule.has_key?(:category)
				category = rule[:category]
				newRange = rule[:bound] == "min" ? rule[:value]..ranges[category].end : ranges[category].first..rule[:value]
				newRanges = ranges.except(category)
				newRanges[category] = newRange
				queue.push({:label => rule[:dest], :ranges => newRanges})
				modifiedRange = rule[:bound] == "min" ? ranges[category].first..rule[:value]-1 : rule[:value]+1..ranges[category].end
				ranges[category] = modifiedRange
			else
				queue.push({:label => rule[:dest], :ranges => ranges})
			end
		end
	end
	## For each set of ranges, get the number of values each range contains, and multiply together to get number of distinct ratings for that set of ranges
	## Then sum this across all sets to get total distinct ratings
	return acceptedRanges.map {|rangeSet| rangeSet.values.map {|range| range.count}.reduce(:*)}.sum
end




p getTotalRatings
p getDistinctRatings