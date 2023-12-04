def get_total_points
	totalPoints = 0
	File.open("day4Input.txt") do |f|
		f.each_line(chomp: true) do |line|
			winning_numbers = line.split(":")[1].split("|")[0].split(" ").map {|num| Integer(num) }
			your_numbers = line.split(":")[1].split("|")[1].split(" ").map {|num| Integer(num) }
			points = 0
			your_numbers.each do |number|
				if winning_numbers.include?(number) and points == 0
					points = 1
				elsif winning_numbers.include?(number) and points != 0
					points *= 2
				end
			end
			totalPoints += points
		end
	end
	return totalPoints
end

def get_file_as_line_array
	lines = []
	i = 0
	File.open("day4Input.txt") do |f|
		f.each_line(chomp: true) do |line|
			lines[i] = line
			i += 1
		end
	end
	return lines
end

def get_total_scratchcards
	lines = get_file_as_line_array
	## Create original copies of scratchcards
	numScratchcards = Array.new(lines.length, 1)
	for i in 0...lines.length
		line = lines[i]
		winning_numbers = line.split(":")[1].split("|")[0].split(" ").map {|num| Integer(num) }
		your_numbers = line.split(":")[1].split("|")[1].split(" ").map {|num| Integer(num) }
		cardsWon = 0
		your_numbers.each do |number|
			if winning_numbers.include?(number)
				cardsWon += 1
			end
		end
		if cardsWon != 0
			cardsWonRange = i+1..i+cardsWon
			for card in cardsWonRange
				numScratchcards[card] += numScratchcards[i]
			end
		end
	end
	return numScratchcards.sum
end

pp get_total_points
pp get_total_scratchcards