def get_hash
	File.open("day15Input.txt") do |f|
		sequence = f.readline(chomp: true)
		steps = sequence.split(",")
		totalValue = 0
		steps.each do |step|
			currentValue = 0
			step.each_byte do |c|
				currentValue += c
				currentValue *= 17
				currentValue = currentValue % 256
			end
			totalValue += currentValue
		end
		return totalValue
	end
end

def get_focusing_power
	File.open("day15Input.txt") do |f|
		sequence = f.readline(chomp: true)
		steps = sequence.split(",")
		totalPower = 0
		boxes = Array.new(256)
		boxes.each_index {|i| boxes[i] = Array.new}
		steps.each do |step|
			label, lensPower = nil
			if (step =~ /=/).nil?
				label = step.split("-")[0]
			else
				parts = step.split("=")
				label = parts[0]
				lensPower = Integer(parts[1])
			end
			boxNumber = 0
			label.each_byte do |c|
				boxNumber += c
				boxNumber *= 17
				boxNumber = boxNumber % 256
			end
			## Minus command
			if lensPower.nil?
				boxes[boxNumber].reject! {|box| box[0] == label}
			## Equals command
			else
				lensIndex = boxes[boxNumber].find_index {|box| box[0] == label}
				if lensIndex.nil?
					boxes[boxNumber].append([label, lensPower])
				else
					boxes[boxNumber][lensIndex] = [label, lensPower]
				end
			end
		end
		boxes.each_with_index do |box, i|
			box.each_with_index do |lens, j|
				totalPower += (i+1) * (j+1) * lens[1]
			end
		end
		return totalPower
	end
end

p get_hash
p get_focusing_power