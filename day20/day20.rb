def parse_file
	modules = Hash.new
	File.open("day20Input.txt") do |f| 
		f.each_line(chomp: true) do |line|
			parts = line.split(" -> ")
			moduleName = parts[0]
			destinations = parts[1].split(", ")
			if moduleName == "broadcaster"
				modules[moduleName] = {:type => :broadcaster, :dests => destinations}
			elsif moduleName.start_with?("%")
				modules[moduleName[1..]] = {:type => :flipflop, :state => :off, :dests => destinations}
			else
				modules[moduleName[1..]] = {:type => :conj, :lastInputs => Hash.new, :dests => destinations}
			end
		end
		## Find inputs for conjunctions
		modules.each_pair do |key, mod|
			if mod[:type] == :conj
				modules.each_pair do |key2, mod2|
					if mod2[:dests].include?(key)
						mod[:lastInputs][key2] = :low
					end
				end
			end
		end
	end
	return modules
end

def get_signals
	modules = parse_file
	moduleStates = Array.new
	loopFound = false
	loopStart = 0
	loopLength = 0
	loopLowSignals = 0
	loopHighSignals = 0
	lowSignalsSent = 0
	highSignalsSent = 0
	until loopFound or moduleStates.size == 1000
		## Save state of modules, use marshal for deep copy of nested hashes
		modulesCopy = Marshal.load(Marshal.dump(modules))
		moduleStates.push([modulesCopy, lowSignalsSent, highSignalsSent])
		## Press button and propagate signals
		queue = [["broadcaster", :low, "button"]]
		until queue.empty?
			signal = queue.shift
			signal[1] == :low ? lowSignalsSent += 1 : highSignalsSent += 1
			if not modules.has_key?(signal[0])
				next
			end
			recipient = modules[signal[0]]
			case recipient[:type]
			when :broadcaster
				recipient[:dests].each do |dest|
					queue.push([dest, signal[1], signal[0]])
				end
			when :flipflop
				if signal[1] == :low
					recipient[:dests].each do |dest|
						queue.push([dest, recipient[:state] == :on ? :low : :high, signal[0]])
					end
					recipient[:state] = recipient[:state] == :on ? :off : :on
				end
			when :conj
				recipient[:lastInputs][signal[2]] = signal[1]
				lowSignal = recipient[:lastInputs].values.all?(:high)
				recipient[:dests].each do |dest|
					queue.push([dest, lowSignal ? :low : :high, signal[0]])
				end
			end
		end
		## Check if current state is equal to any previous state, i.e. a loop
		moduleStates.each_with_index do |state, i|
			if state[0] == modules
				# loopFound = true
				loopStart = i
				loopLength = moduleStates.size - i
				loopLowSignals = lowSignalsSent - state[1]
				loopHighSignals = highSignalsSent - state[2]
				break
			end
		end
	end
	if loopFound
		## Work out how many more loop iterations until 1000 button presses
		buttonPresses = moduleStates.size
		pressesLeft = 1000 - buttonPresses
		partialLoopPresses = pressesLeft % loopLength
		partialLoopLowSignals = moduleStates[loopStart+partialLoopPresses][1] - moduleStates[loopStart][1]
		partialLoopHighSignals = moduleStates[loopStart+partialLoopPresses][2] - moduleStates[loopStart][2]
		totalLowSignals = lowSignalsSent + (loopLowSignals * pressesLeft / loopLength) + partialLoopLowSignals
		totalHighSignals = highSignalsSent + (loopHighSignals * pressesLeft / loopLength) + partialLoopHighSignals
		return totalLowSignals * totalHighSignals
	else
		return lowSignalsSent * highSignalsSent
	end
end

def get_rx_signal
	modules = parse_file
	buttonPresses = 0
	requiredHighSignals = {
		"bm" => 0, "cl" => 0, "tn" => 0, "dr" => 0
	}
	until requiredHighSignals.values.all? {|val| val != 0}
		## Press button and propagate signals
		queue = [["broadcaster", :low, "button"]]
		buttonPresses += 1
		until queue.empty?
			signal = queue.shift
			if requiredHighSignals.has_key?(signal[0]) and requiredHighSignals[signal[0]] == 0 and signal[1] == :low
				requiredHighSignals[signal[0]] = buttonPresses
			end
			if not modules.has_key?(signal[0])
				next
			end
			recipient = modules[signal[0]]
			case recipient[:type]
			when :broadcaster
				recipient[:dests].each do |dest|
					queue.push([dest, signal[1], signal[0]])
				end
			when :flipflop
				if signal[1] == :low
					recipient[:dests].each do |dest|
						queue.push([dest, recipient[:state] == :on ? :low : :high, signal[0]])
					end
					recipient[:state] = recipient[:state] == :on ? :off : :on
				end
			when :conj
				recipient[:lastInputs][signal[2]] = signal[1]
				lowSignal = recipient[:lastInputs].values.all?(:high)
				recipient[:dests].each do |dest|
					queue.push([dest, lowSignal ? :low : :high, signal[0]])
				end
			end
		end
	end
	return requiredHighSignals.values.reduce(:lcm)
end

p get_signals
p get_rx_signal