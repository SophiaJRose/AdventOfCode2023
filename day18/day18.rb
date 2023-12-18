def dig_lagoon(colourCode = false)
	File.open("day18Input.txt") do |f|
		lagoonSize = 0
		digPoints = [[0,0]]
		currentPos = [0,0]
		f.each_line(chomp: true) do |line|
			dir = " "
			length = 0
			if colourCode
				colourCode = line.split("#")[1][...6]
				directionMap = ["R", "D", "L", "U"]
				dir = directionMap[Integer(colourCode[5])]
				length = colourCode[...5].to_i(16)
			else
				dir = line[0]
				length = line.split(" ")[1].to_i
			end
			case dir
			when "R"
				currentPos = [currentPos[0], currentPos[1]+length]
			when "D"
				currentPos = [currentPos[0]+length, currentPos[1]]
			when "L"
				currentPos = [currentPos[0], currentPos[1]-length]
			when "U"
				currentPos = [currentPos[0]-length, currentPos[1]]
			end
			digPoints.push(currentPos.difference)
		end
		## Remove duplicate starting point, then sort points by i then j
		digPoints.pop
		digPoints.sort! {|point1, point2|
			if (point1[0] <=> point2[0]) == 0
				point1[1] <=> point2[1]
			else
				point1[0] <=> point2[0]
			end
		}
		## Start with uppermost horizontal line, go down until another horizontal line found
		lines = Array.new
		point1 = digPoints.shift
		point2 = digPoints.shift
		startLine = {:left => point1[1], :right => point2[1], :startHeight => point1[0]}
		lines.push(startLine)
		until digPoints.empty?
			point1 = digPoints.shift
			point2 = digPoints.shift
			## Find a line with which this line interacts
			## Possible interactions: end rectangle, cut into left side, cut into right side, extend left side, extend right side, split rectangle or none (i.e. new rectangle)
			lineEnd = lines.find_index {|line| point1[1] == line[:left] and point2[1] == line[:right]}
			## If both points match, end rectangle
			if not lineEnd.nil?
				line = lines[lineEnd]
				## Add rectangle so far to lagoonSize
				heightDiff = point1[0] - line[:startHeight] + 1
				lineLength = line[:right] - line[:left] + 1
				lagoonSize += heightDiff * lineLength
				lines.delete(line)
				next
			end
			## If left points match, cut into left side
			lineCutLeft = lines.find_index {|line| point1[1] == line[:left]}
			if not lineCutLeft.nil?
				line = lines[lineCutLeft]
				## Add rectangle so far to lagoonSize
				heightDiff = point1[0] - line[:startHeight]
				lineLength = line[:right] - line[:left] + 1
				lagoonSize += heightDiff * lineLength
				## Add cutin
				lagoonSize += point2[1] - point1[1]
				## Update line left and height to continue
				line[:left] = point2[1]
				line[:startHeight] = point2[0]
				next
			end
			## If right points match, cut into right side
			lineCutRight = lines.find_index {|line| point2[1] == line[:right]}
			if not lineCutRight.nil?
				line = lines[lineCutRight]
				## Add rectangle so far to lagoonSize
				heightDiff = point1[0] - line[:startHeight]
				lineLength = line[:right] - line[:left] + 1
				lagoonSize += heightDiff * lineLength
				## Add cutin
				lagoonSize += point2[1] - point1[1]
				## Update line right and height to continue
				line[:right] = point1[1]
				line[:startHeight] = point1[0]
				next
			end
			## Special case: if extending two different lines, combine together
			lineExtendLeft = lines.find_index{|line| point2[1] == line[:left]}
			lineExtendRight = lines.find_index{|line| point1[1] == line[:right]}
			if not lineExtendLeft.nil? and not lineExtendRight.nil?
				line1 = lines[lineExtendRight]
				line2 = lines[lineExtendLeft]
				## Add rectangles so far to lagoonSize
				heightDiff1 = point1[0] - line1[:startHeight]
				heightDiff2 = point1[0] - line2[:startHeight]
				lineLength1 = line1[:right] - line1[:left] + 1
				lineLength2 = line2[:right] - line2[:left] + 1
				lagoonSize += heightDiff1 * lineLength1
				lagoonSize += heightDiff2 * lineLength2
				## Add combined line and remove previous lines
				combinedLine = {:left => line1[:left], :right => line2[:right], :startHeight => point1[0]}
				lines.push(combinedLine)
				lines.delete(line1)
				lines.delete(line2)
				next
			end
			## If old left matches new right, extend left side
			if not lineExtendLeft.nil?
				line = lines[lineExtendLeft]
				## Add rectangle so far to lagoonSize
				heightDiff = point1[0] - line[:startHeight]
				lineLength = line[:right] - line[:left] + 1
				lagoonSize += heightDiff * lineLength
				## Update line left and height to continue
				line[:left] = point1[1]
				line[:startHeight] = point1[0]
				next
			end
			## If old right matches new left, extend right side
			if not lineExtendRight.nil?
				line = lines[lineExtendRight]
				## Add rectangle so far to lagoonSize
				heightDiff = point1[0] - line[:startHeight]
				lineLength = line[:right] - line[:left] + 1
				lagoonSize += heightDiff * lineLength
				## Update line right and height to continue
				line[:right] = point2[1]
				line[:startHeight] = point2[0]
				next
			end
			lineSplit = lines.find_index{|line| point1[1] > line[:left] and point2[1] < line[:right]}
			if not lineSplit.nil?
				line = lines[lineSplit]
				## Add rectangle so far to lagoonSize
				heightDiff = point1[0] - line[:startHeight]
				lineLength = line[:right] - line[:left] + 1
				lagoonSize += heightDiff * lineLength
				## Add in length of line between new lines
				lagoonSize += point2[1] - point1[1] - 1
				## Split into new lines and remove original line
				newLine1 = {:left => line[:left], :right => point1[1], :startHeight => point1[0]}
				newLine2 = {:left => point2[1], :right => line[:right], :startHeight => point1[0]}
				lines.push(newLine1)
				lines.push(newLine2)
				lines.delete(line)
				next
			end
			## All interactions continue to next line to process, so this is only reached if no intereactions, i.e. new rectangle
			newLine = {:left => point1[1], :right => point2[1], :startHeight => point1[0]}
			lines.push(newLine)
		end
		return lagoonSize
	end
end

p dig_lagoon
p dig_lagoon(true)