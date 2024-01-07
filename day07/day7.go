package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
	"strconv"
	"slices"
	"cmp"
)

const (
	HighCard = iota
	OnePair
	TwoPair
	ThreeOfAKind
	FullHouse
	FourOfAKind
	FiveOfAKind
)
	
var cardValuesMap = map[rune]int{'*': 1, '2': 2, '3': 3, '4': 4, '5': 5, '6': 6, '7': 7, '8': 8, '9': 9, 'T': 10, 'J': 11, 'Q': 12, 'K': 13, 'A': 14}

func get_hand_type(cards string) int {
	cardsValues := make([]int, len(cards))
	for i, r := range []rune(cards) {
		cardsValues[i] = cardValuesMap[r]
	}
	slices.Sort(cardsValues)
	// Handle Jokers
	// If 4 or more Jokers, always 5oaK
	switch {
	case cardsValues[3] == 1:
		return FiveOfAKind
	// If 3 Jokers, convert all to highest card and continue
	case cardsValues[2] == 1:
		cardsValues[0] = cardsValues[4]
		cardsValues[1] = cardsValues[4]
		cardsValues[2] = cardsValues[4]
	// If 2 Jokers, check for potential 4oaK, otherwise convert to highest
	case cardsValues[1] == 1:
		if cardsValues[2] == cardsValues[3] {
			cardsValues[0] = cardsValues[2]
			cardsValues[1] = cardsValues[2]
		} else {
			cardsValues[0] = cardsValues[4]
			cardsValues[1] = cardsValues[4]
		}
	// 1 Joker
	case cardsValues[0] == 1:
		// If 1 Joker, and at least two of lowest non-Joker card, but not two of highest card, i.e. hand is JAABC or JAAAB, convert Joker to lowest non-Joker card
		if cardsValues[1] == cardsValues[2] && cardsValues[3] != cardsValues[4] {
			cardsValues[0] = cardsValues[1]
		// If hand is JABBC, convert J to B for 3oaK
		} else if cardsValues[2] == cardsValues[3] {
			cardsValues[0] = cardsValues[2]
		// Otherwise convert to highest
		} else {
			cardsValues[0] = cardsValues[4]
		}
	}
	// Sort again after joker conversion
	slices.Sort(cardsValues)
	// Get type of card
	numCardTypes := len(slices.Compact(slices.Clone(cardsValues)))
	switch {
	// Only one type of card means 5oaK
	case numCardTypes == 1:
		return FiveOfAKind
	// If two types of cards and 2nd and 4th are the same, must be 4oaK, since cards are sorted
	case numCardTypes == 2 && cardsValues[1] == cardsValues[3]:
		return FourOfAKind
	// If only two types of cards, but not 4oaK, must be FH
	case numCardTypes == 2:
		return FullHouse
	// If three types of cards, check for 3oaK
	case numCardTypes == 3 && (cardsValues[0] == cardsValues[2] || cardsValues[1] == cardsValues[3] || cardsValues[2] == cardsValues[4]):
		return ThreeOfAKind
	// If not 3oaK, must be 2Pair
	case numCardTypes == 3:
		return TwoPair
	// If 4 types of cards, must be 1Pair
	case numCardTypes == 4:
		return OnePair
	// If none of the above, must be HC
	default:
		return HighCard
	}
}

type round struct {
	hand hand
	bid int
}

type hand struct {
	cards string
	handType int
}

func print_error(err error) {
	if err != nil {
		fmt.Println(err)
	}
}

func get_winnings(jokers bool) {
	file, err := os.Open("day7Input.txt")
	print_error(err)
	defer file.Close()

	rounds := []round{}
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := scanner.Text()
		lineParts := strings.Split(line, " ")
		bid, err := strconv.Atoi(lineParts[1])
		print_error(err)
		cardsStr := lineParts[0]
		if jokers {
			cardsStr = strings.ReplaceAll(cardsStr, "J", "*")
		}
		hand := hand{cards: cardsStr, handType: get_hand_type(cardsStr)}
		newRound := round{hand: hand, bid: bid}
		rounds = append(rounds, newRound)
	}
	cmpHands := func (x, y round) int {
		cmpTypes := cmp.Compare(x.hand.handType, y.hand.handType)
		if cmpTypes == 0 {
			cmpCards := 0
			i := 0
			for (cmpCards == 0) && (i < len(x.hand.cards)) {
				cmpCards = cmp.Compare(cardValuesMap[rune(x.hand.cards[i])], cardValuesMap[rune(y.hand.cards[i])])
				i += 1
			}
			return cmpCards
		} else {
			return cmpTypes
		}
	}
	slices.SortFunc(rounds, cmpHands)
	totalWinnings := 0
	multiplier := 1
	for _, round := range rounds {
		totalWinnings += round.bid * multiplier
		multiplier += 1
	}
	fmt.Println(totalWinnings)
}

func main() {
	get_winnings(false)
	get_winnings(true)
}