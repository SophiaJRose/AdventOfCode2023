def parse_file(zAxis = false)
	hailstones = Array.new
	File.open("day24Input.txt") do |f|
		f.each_line(chomp: true) do |line|
			pos, vel = line.split(" @ ")
			posX, posY, posZ = pos.split(", ").map {|i| i.to_f}
			velX, velY, velZ = vel.split(", ").map {|i| i.to_f}
			if zAxis
				hailstones.push({:startX => posX, :startY => posY, :startZ => posZ, :velX => velX, :velY => velY, :velZ => velZ})
			else
				m = velY / velX
				b = posY - (m * posX)
				hailstones.push({:startX => posX, :startY => posY, :velX => velX, :velY => velY, :m => m, :b => b})
			end
		end
	end
	return hailstones
end

def get_2d_intersections
	hailstones = parse_file
	numIntersections = 0
	hailstones.combination(2) do |hail1, hail2|
		m1 = hail1[:m]
		m2 = hail2[:m]
		b1 = hail1[:b]
		b2 = hail2[:b]
		mRatio = m2 / m1
		b1Ratio = b1 / m1
		b2Ratio = b2 / m1
		intersectX = (b2Ratio - b1Ratio) / (1 - mRatio)
		intersectY = m1 * intersectX + b1
		inHail1Past = hail1[:velX] > 0 ? intersectX < hail1[:startX] : intersectX > hail1[:startX]
		inHail2Past = hail2[:velX] > 0 ? intersectX < hail2[:startX] : intersectX > hail2[:startX]
		inTestRange = (intersectX >= 200000000000000.0) & (intersectX <= 400000000000000.0) & (intersectY >= 200000000000000.0) & (intersectY <= 400000000000000.0)
		if inTestRange and not inHail1Past and not inHail2Past
			numIntersections += 1
		end
	end
	return numIntersections
end

def get_3d_intersection_line
	hailstones = parse_file(true)
	## INCOMPLETE
end

p get_2d_intersections
