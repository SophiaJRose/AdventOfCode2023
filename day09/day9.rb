def extrapolate_values(extrapolateBackwards = false)
	totalExtValues = 0
	File.open("day9Input.txt") do |f|
		f.each_line(chomp: true) do |line|
			numbers = line.split(" ").map {|n| Integer(n)}
			layers = [numbers]
			layerNum = 0
			currentLayer = layers[layerNum]
			## Generate layers of differences
			until (currentLayer.all? {|n| n == 0})
				newLayer = []
				for i in 0...currentLayer.size-1
					newLayer.push(currentLayer[i+1] - currentLayer[i])
				end
				layers.push(newLayer)
				layerNum += 1
				currentLayer = layers[layerNum]
			end
			## Add extra zero onto last layer
			extrapolateBackwards ? layers[-1].prepend(0) : layers[-1].push(0)
			## Extrapolate new value for each layer going backwards
			extrapolatedValue = 0
			(layers.size-2).downto(0) do |i|
				## Current last value of layer + extrapolated value of previous layer
				if extrapolateBackwards
					extrapolatedValue = layers[i][0] - layers[i+1][0]
					layers[i].prepend(extrapolatedValue)
				else
					extrapolatedValue = layers[i][-1] + layers[i+1][-1]
					layers[i].push(extrapolatedValue)
				end
			end
			## extrapolatedValue now contains final extrapolated value
			totalExtValues += extrapolatedValue
		end
	end
	return totalExtValues
end

p extrapolate_values
p extrapolate_values(true)