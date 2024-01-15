package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
	"slices"
	"strconv"
)

func print_error(err error) {
	if err != nil {
		fmt.Println(err)
	}
}

type lens struct {
	label string
	focalLength int
}

func hash_algorithm() {
	file, err := os.Open("day15Input.txt")
	print_error(err)
	defer file.Close()

	sumResults := 0
	scanner := bufio.NewScanner(file)
	scanner.Scan()
	line := scanner.Text()
	for _, instr := range strings.Split(line, ",") {
		value := 0
		for _, c := range []rune(instr) {
			value += int(c)
			value *= 17
			value = value % 256
		}
		sumResults += value
	}
	fmt.Println(sumResults)
}

func hashmap_algorithm() {
	file, err := os.Open("day15Input.txt")
	print_error(err)
	defer file.Close()

	scanner := bufio.NewScanner(file)
	scanner.Scan()
	line := scanner.Text()
	boxes := make([][]lens, 256)
	for i, _ := range boxes {
		boxes[i] = []lens{}
	}
	for _, instr := range strings.Split(line, ",") {
		instrType := strings.IndexAny(instr, "-=")
		label := instr[:instrType]
		boxNumber := 0
		for _, c := range []rune(label) {
			boxNumber += int(c)
			boxNumber *= 17
			boxNumber = boxNumber % 256
		}
		matchingLens := func (boxLens lens) bool {
			return boxLens.label == label
		}
		if instr[instrType] == '=' {
			focalLength, err := strconv.Atoi(instr[instrType+1:])
			newLens := lens{label: label, focalLength: focalLength}
			print_error(err)
			position := slices.IndexFunc(boxes[boxNumber], matchingLens)
			if position == -1 {
				boxes[boxNumber] = append(boxes[boxNumber], newLens)
			} else {
				boxes[boxNumber][position] = newLens
			}
		} else {
			position := slices.IndexFunc(boxes[boxNumber], matchingLens)
			if position != -1 {
				boxes[boxNumber] = slices.Delete(boxes[boxNumber], position, position+1)
			}
		}
	}
	focusingPower := 0
	for i, box := range boxes {
		for j, lens := range box {
			focusingPower += (i+1) * (j+1) * lens.focalLength
		}
	}
	fmt.Println(focusingPower)
}

func main() {
	hash_algorithm()
	hashmap_algorithm()
}