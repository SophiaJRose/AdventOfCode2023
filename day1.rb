def get_values(words = false)
	sum = 0;
	File.open("day1Input.txt") do |f|
		f.each_line do |line|
			if words
				## Keeping first and last letter of each word avoids issue with overlap e.g. "eightwo" would become "eigh2" when correct first digit is 8
				## Feels a bit hacky, but saves iterating through the line letter by letter
				wordsHash = {"one" => "o1e", "two" => "t2o", "three" => "t3e", "four" => "f4r", "five" => "f5e", "six" => "s6x", "seven" => "s7n", "eight" => "e8t", "nine" => "n9e", "zero" => "z0o"}
				wordsHash.each {|k,v| line.gsub!(k,v)}
			end
			line.gsub!(/[a-zA-Z\n]+/, '')
			value = Integer(line[-1]) + (Integer(line[0]) * 10)
			sum += value
		end
	end
	return sum
end

puts get_values
puts get_values(true)