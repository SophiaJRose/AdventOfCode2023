def parse_file
	File.open("day13Input.txt") do |f|
		patterns = Array.new
		pattern = Array.new
		f.each_line(chomp: true) do |line|
			if line == ""
				patterns.push(pattern)
				pattern = Array.new
			else
				pattern.push(line)
			end
		end
		patterns.push(pattern)
		return patterns
	end
end

def check_for_smudge_vert(mirrorLeft, rightSide)
	diffStr = ""
	line1 = mirrorLeft.size < rightSide.size ? mirrorLeft : rightSide
	line2 = mirrorLeft.size < rightSide.size ? rightSide : mirrorLeft
	line1.chars.each_with_index do |char, i|
		if char == line2[i]
			diffStr += " "
		else
			diffStr += "X"
		end
	end
	return diffStr.count("X") == 1
end

def check_for_smudge_horiz(line1, line2)
	diffStr = ""
	line1.chars.each_with_index do |char, i|
		if char == line2[i]
			diffStr += " "
		else
			diffStr += "X"
		end
	end
	return diffStr.count("X") == 1
end

def get_reflections(smudges = false)
	patterns = parse_file
	patternSummary = 0
	patterns.each do |pattern|
		possibleVertReflection = false
		## Check first line for vertical line of reflection
		addToSummary = 0
		for i in 0...pattern[0].size-1
			leftSide = pattern[0][..i]
			rightSide = pattern[0][i+1..]
			mirrorLeft = leftSide.reverse
			if mirrorLeft.start_with?(rightSide) or rightSide.start_with?(mirrorLeft) or (smudges and check_for_smudge_vert(mirrorLeft, rightSide))
				## Reflection found, check for all line
				possibleVertReflection = true
				smudgeUsed = (not mirrorLeft.start_with?(rightSide) and not rightSide.start_with?(mirrorLeft))
				pattern[1..].each do |line|
					leftSide = line[..i]
					rightSide = line[i+1..]
					mirrorLeft = leftSide.reverse
					unless mirrorLeft.start_with?(rightSide) or rightSide.start_with?(mirrorLeft)
						if smudges and not smudgeUsed and check_for_smudge_vert(mirrorLeft, rightSide)
							smudgeUsed = true
						else
							possibleVertReflection = false
							break
						end
					end
				end
				if possibleVertReflection
					if not smudges or smudgeUsed
						addToSummary = i+1
						patternSummary += i+1
						break
					end
				end
			end
		end
		## If no vertical line of reflection, check for horizontal
		for i in 0...pattern.size-1
			possibleHorizReflection = false
			if pattern[i] == pattern[i+1] or (smudges and check_for_smudge_horiz(pattern[i], pattern[i+1]))
				possibleHorizReflection = true
				smudgeUsed = pattern[i] != pattern[i+1]
				a = i-1
				b = i+2
				while a >= 0 and b < pattern.size
					if pattern[a] != pattern[b] 
						if smudges and not smudgeUsed and check_for_smudge_horiz(pattern[a], pattern[b])
							smudgeUsed = true
						else
							possibleHorizReflection = false
							break
						end
					end
					a -= 1
					b += 1
				end
				if possibleHorizReflection
					if not smudges or smudgeUsed
						addToSummary = 100 * (i + 1)
						patternSummary += 100 * (i + 1)
						break
					end
				end
			end
		end
		if smudges
		end
	end
	return patternSummary
end

p get_reflections
p get_reflections(true)