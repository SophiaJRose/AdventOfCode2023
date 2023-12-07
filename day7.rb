module HandTypes
	## Hand type constants
	FIVEOFAKIND = 7
	FOUROFAKIND = 6
	FULLHOUSE = 5
	THREEOFAKIND = 4
	TWOPAIR = 3
	ONEPAIR = 2
	HIGHCARD = 1
end

class Hand
	include Comparable
	attr :cards
	## Actual values don't matter, just order. * is Joker, not used in this class, subclass converts J to *
	@@cardToValue = {"*" => 1, "2" => 2, "3" => 3, "4" => 4, "5" => 5, "6" => 6, "7" => 7, "8" => 8, "9" => 9, "T" => 10, "J" => 11, "Q" => 12, "K" => 13, "A" => 14}
	## Method to get hand type
	def get_hand_type
		cards_array = cards.chars
		cards_array.map! {|c| @@cardToValue[c]}.sort!
		case
		## only one type of card means 5oaK
		when cards_array.uniq.size == 1
			return HandTypes::FIVEOFAKIND
		## non-4oaK card could be first or last, so two types and 2nd == 4th means 4oaK
		when (cards_array.uniq.size == 2 and cards_array[1] == cards_array[3])
			return HandTypes::FOUROFAKIND
		## two types of card can only be 4oaK or FH, so if not 4oaK, must be FH
		when cards_array.uniq.size == 2 
			return HandTypes::FULLHOUSE
		## 3oaK could be arranged as AAABC, ABBBC or ABCCC, so check for each
		when (cards_array.uniq.size == 3 and (cards_array[0] == cards_array[2] or cards_array[1] == cards_array[3] or cards_array[2] == cards_array[4]))
			return HandTypes::THREEOFAKIND
		## three types of card can only be 3oaK or 2P, so if not 3oaK, must be 2P
		when cards_array.uniq.size == 3
			return HandTypes::TWOPAIR
		## four types of card can only be 1P
		when cards_array.uniq.size == 4
			return HandTypes::ONEPAIR
		## if none of above, must be HC
		else
			return HandTypes::HIGHCARD
		end
	end
	def <=>(other)
		thisType = get_hand_type
		otherType = other.get_hand_type
		cmpTypes = thisType <=> otherType
		if cmpTypes == 0
			cmpCards = 0
			i = 0
			while cmpCards == 0
				cmpCards = @@cardToValue[@cards[i]] <=> @@cardToValue[other.cards[i]]
				i += 1
			end
			return cmpCards
		end
		return cmpTypes
	end
	def initialize(str)
		@cards = str
	end
	def inspect
		@cards
	end
end

class JokerHand < Hand
	def get_hand_type
		cards_array = cards.chars
		cards_array.map! {|c| @@cardToValue[c]}.sort!
		jokers = cards_array.include?(1)
		## Convert Joker to other card that gives best hand
		## If all cards are Jokers, always 5oaK
		if cards_array[4] == 1
			return HandTypes::FIVEOFAKIND
		## If 4 jokers, all will convert to last card, always 5oaK
		elsif cards_array[3] == 1
			return HandTypes::FIVEOFAKIND
		## If 3 jokers, convert all to highest card, then check normally
		elsif cards_array[2] == 1
			cards_array[0] = cards_array[4]
			cards_array[1] = cards_array[4]
			cards_array[2] = cards_array[4]
		## 2 Jokers
		elsif cards_array[1] == 1 
			## If 2 jokers, and two of lowest non-joker card, convert jokers to said card, in case of 4oaK
			if cards_array[2] == cards_array[3]
				cards_array[0] = cards_array[2]
				cards_array[1] = cards_array[2]
			## Otherwise, convert to highest
			else
				cards_array[0] = cards_array[4]
				cards_array[1] = cards_array[4]
			end
		# 1 Joker
		elsif cards_array[0] == 1
			## If 1 joker, and two of lowest non-joker card, but not two of highest card, i.e. JAABC or JAAAB, convert to lowest non-joker card
			if cards_array[1] == cards_array[2] and cards_array[3] != cards_array[4]
				cards_array[0] = cards_array[1]
			## If card is of form JABBC, convert to B for 3oaK (technically also catches JAAAA, but J can be converted to any card in this case)
			elsif cards_array[2] == cards_array[3]
				cards_array[0] = cards_array[2]
			## Otherwise convert to highest
			else
				cards_array[0] = cards_array[4]
			end
		end
		## Sort again after converting Jokers
		cards_array.sort!
		case
		## only one type of card means 5oaK
		when cards_array.uniq.size == 1
			return HandTypes::FIVEOFAKIND
		## non-4oaK card could be first or last, so two types and 2nd == 4th means 4oaK
		when (cards_array.uniq.size == 2 and cards_array[1] == cards_array[3])
			return HandTypes::FOUROFAKIND
		## two types of card can only be 4oaK or FH, so if not 4oaK, must be FH
		when cards_array.uniq.size == 2 
			return HandTypes::FULLHOUSE
		## 3oaK could be arranged as AAABC, ABBBC or ABCCC, so check for each
		when (cards_array.uniq.size == 3 and (cards_array[0] == cards_array[2] or cards_array[1] == cards_array[3] or cards_array[2] == cards_array[4]))
			return HandTypes::THREEOFAKIND
		## three types of card can only be 3oaK or 2P, so if not 3oaK, must be 2P
		when cards_array.uniq.size == 3
			return HandTypes::TWOPAIR
		## four types of card can only be 1P
		when cards_array.uniq.size == 4
			return HandTypes::ONEPAIR
		## if none of above, must be HC
		else
			return HandTypes::HIGHCARD
		end
	end
	def initialize(str)
		@cards = str.tr("J", "*")
	end
end

def get_winnings(jokers = false)
	totalWinnings = 0
	File.open("day7Input.txt") do |f|
		rounds = Array.new
		f.each_line(chomp: true) do |line|
			rounds.push(line.split(" "))
		end
		if jokers
			rounds.map! {|r| [JokerHand.new(r[0]), Integer(r[1])]}
		else
			rounds.map! {|r| [Hand.new(r[0]), Integer(r[1])]}
		end
		rounds.sort_by! {|r| r[0]}
		multiplier = 1
		rounds.each do |r|
			totalWinnings += r[1] * multiplier
			multiplier += 1
		end
	end
	return totalWinnings
end

p get_winnings
p get_winnings(true)