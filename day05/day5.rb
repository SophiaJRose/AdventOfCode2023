def generate_map (file)
	map = Array.new
	while (line = file.gets(chomp: true)) =~ /[0-9]/
		numbers = line.split(" ").map {|n| Integer(n)}
		destRangeStart = numbers[0]
		sourceRangeStart = numbers[1]
		rangeSize = numbers[2]
		range = {:sourceStart => sourceRangeStart, :destStart => destRangeStart, :size => rangeSize}
		map.push(range)
	end
	return map
end

def get_map_value(map, index)
	value = index
	map.each do |range|
		sourceStart = range[:sourceStart]
		if index >= sourceStart and index < (sourceStart + range[:size])
			diff = index - sourceStart
			value = range[:destStart] + diff
		end
	end
	return value
end

def get_min_location
	File.open("day5Input.txt") do |f|
		seedsToBePlanted = f.readline.chomp!.split(":")[1].split(" ").map {|n| Integer(n)}
		f.readline()	# Empty line
		f.readline()	# seed-to-soil map header
		seedToSoil = generate_map(f)
		f.readline()	# Empty line
		soilToFert = generate_map(f)
		f.readline()	# Empty line
		fertToWater = generate_map(f)
		f.readline()	# Empty line
		waterToLight = generate_map(f)
		f.readline()	# Empty line
		lightToTemp = generate_map(f)
		f.readline()	# Empty line
		tempToHumidity = generate_map(f)
		f.readline()	# Empty line
		humidityToLocation = generate_map(f)
		minLocation = -1
		seedsToBePlanted.each do |seed|
			soil = get_map_value(seedToSoil, seed)
			fert = get_map_value(soilToFert, soil)
			water = get_map_value(fertToWater, fert)
			light = get_map_value(waterToLight, water)
			temp = get_map_value(lightToTemp, light)
			humidity = get_map_value(tempToHumidity, temp)
			location = get_map_value(humidityToLocation, humidity)
			if minLocation > location or minLocation == -1
				minLocation = location
			end
		end
		return minLocation
	end
end

def get_seed_ranges(file)
	map = Array.new
	seedNumbers = file.readline.chomp!.split(":")[1].split(" ").map {|n| Integer(n)}
	i = 0
	while i+1 < seedNumbers.length
		range = {:start => seedNumbers[i], :size => seedNumbers[i+1]}
		map.push(range)
		i += 2
	end
	# p map
	return map
end

def check_range_overlap(seedRanges, mapRanges)
	allNewRanges = Array.new
	# seedRanges.each do |seedRange|
	while !seedRanges.empty?
		seedRange = seedRanges.shift
		newRanges = Array.new
		mapRanges.each do |mapRange|
			seedRangeStart = seedRange[:start]
			seedRangeEnd = seedRangeStart + seedRange[:size]
			mapRangeStart = mapRange[:sourceStart]
			mapRangeEnd = mapRange[:sourceStart] + mapRange[:size]
			## Case 1: seed range is subset of map source range, map seed range start to value from map destination range
			if seedRangeStart >= mapRangeStart and seedRangeEnd <= mapRangeEnd
				rangeStartDiff = seedRangeStart - mapRangeStart
				newRange = {:start => mapRange[:destStart] + rangeStartDiff, :size => seedRange[:size]}
				newRanges.push(newRange)
				seedRanges.delete(seedRange)
				break
			## Case 2/3: partial overlap of ranges, split into two ranges
			elsif seedRangeStart < mapRangeStart and mapRangeStart < seedRangeEnd and seedRangeEnd < mapRangeEnd
				overlapSize = seedRangeEnd - mapRangeStart
				overlapRange = {:start => mapRange[:destStart], :size => overlapSize}
				newRanges.push(overlapRange)
				remainderRangeSize = mapRangeStart - seedRangeStart
				remainderRange = {:start => seedRangeStart, :size => remainderRangeSize}
				seedRanges.push(remainderRange)
				seedRanges.delete(seedRange)
				break
			elsif mapRangeStart < seedRangeStart and seedRangeStart < mapRangeEnd and mapRangeEnd < seedRangeEnd
				overlapSize = mapRangeEnd - seedRangeStart
				rangeStartDiff = seedRangeStart - mapRangeStart
				overlapRange = {:start => mapRange[:destStart] + rangeStartDiff, :size => overlapSize}
				newRanges.push(overlapRange)
				remainderRangeSize = seedRangeEnd - mapRangeEnd
				remainderRange = {:start => mapRangeEnd, :size => remainderRangeSize}
				seedRanges.push(remainderRange)
				seedRanges.delete(seedRange)
				break
			## Case 4: map source range is subset of seed range, split into three ranges
			elsif mapRangeStart >= seedRangeStart and mapRangeEnd <= seedRangeEnd
				overlapRange = {:start => mapRange[:destStart], :size => mapRange[:size]}
				newRanges.push(overlapRange)
				beforeRemainderRangeSize = mapRangeStart - seedRangeStart
				unless beforeRemainderRangeSize == 0
					beforeRemainderRange = {:start => seedRangeStart, :size => beforeRemainderRangeSize}
					seedRanges.push(beforeRemainderRange)
				end
				afterRemainderRangeSize = seedRangeEnd - mapRangeEnd
				unless afterRemainderRangeSize == 0
					afterRemainderRange = {:start => mapRangeEnd, :size => afterRemainderRangeSize}
					seedRanges.push(afterRemainderRange)
				end
				seedRanges.delete(seedRange)
				break
			end
		end
		## If no overlaps found with seedRange, add as is
		if newRanges.empty?
			newRanges.push(seedRange)
		end
		allNewRanges.concat(newRanges)
	end
	return allNewRanges
end

def get_min_location_ranges
	File.open("day5Input.txt") do |f|
		seedRangesToBePlanted = get_seed_ranges(f)
		f.readline()	# Empty line
		f.readline()	# seed-to-soil map header
		seedToSoil = generate_map(f)
		f.readline()	# Empty line
		soilToFert = generate_map(f)
		f.readline()	# Empty line
		fertToWater = generate_map(f)
		f.readline()	# Empty line
		waterToLight = generate_map(f)
		f.readline()	# Empty line
		lightToTemp = generate_map(f)
		f.readline()	# Empty line
		tempToHumidity = generate_map(f)
		f.readline()	# Empty line
		humidityToLocation = generate_map(f)
		soilRanges = check_range_overlap(seedRangesToBePlanted, seedToSoil)
		fertRanges = check_range_overlap(soilRanges, soilToFert)
		waterRanges = check_range_overlap(fertRanges, fertToWater)
		lightRanges = check_range_overlap(waterRanges, waterToLight)
		tempRanges = check_range_overlap(lightRanges, lightToTemp)
		humidityRanges = check_range_overlap(tempRanges, tempToHumidity)
		locationRanges = check_range_overlap(humidityRanges, humidityToLocation)
		locationRanges.sort_by! {|range| range[:start]}
		return locationRanges[0][:start]
	end
end

p get_min_location
p get_min_location_ranges
