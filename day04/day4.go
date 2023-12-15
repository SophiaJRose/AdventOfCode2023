package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
	"slices"
)

func parse_file() []string {
	file, err := os.Open("day4Input.txt")
	if err != nil {
		fmt.Println(err)
	}
	defer file.Close()

	lines := []string{}
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := scanner.Text()
		lines = append(lines, line)
	}
	return lines
}

func get_scores() {
	lines := parse_file()
	totalScore := 0
	for _, line := range lines {
		winningNumbers := strings.Fields(strings.Split(strings.Split(line, ": ")[1], " | ")[0])
		yourNumbers := strings.Fields(strings.Split(strings.Split(line, ": ")[1], " | ")[1])
		lineScore := 0
		for _, num := range winningNumbers {
			if slices.Contains(yourNumbers, num) {
				if lineScore == 0 {
					lineScore = 1
				} else {
					lineScore *= 2
				}
			}
		}
		totalScore += lineScore
	}
	fmt.Println(totalScore)
}

func get_scratchcards() {
	lines := parse_file()
	totalScratchcards := 0
	numCards := make([]int, len(lines))
	for i, _ := range numCards {
		numCards[i] = 1
	}
	for i, line := range lines {
		winningNumbers := strings.Fields(strings.Split(strings.Split(line, ": ")[1], " | ")[0])
		yourNumbers := strings.Fields(strings.Split(strings.Split(line, ": ")[1], " | ")[1])
		numCardsWon := 0
		for _, num := range winningNumbers {
			if slices.Contains(yourNumbers, num) {
				numCardsWon += 1
			}
		}
		for j := i+1; j <= i+numCardsWon; j++ {
			numCards[j] += numCards[i]
		}
	}
	for _, num := range numCards {
		totalScratchcards += num
	}
	fmt.Println(totalScratchcards)
}

func main() {
	get_scores()
	get_scratchcards()
}