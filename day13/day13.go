package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
	"slices"
)

func print_error(err error) {
	if err != nil {
		fmt.Println(err)
	}
}

func parse_file() [][]string {
	file, err := os.Open("day13Input.txt")
	print_error(err)
	defer file.Close()

	patterns := [][]string{}
	currentPattern := []string{}
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := scanner.Text()
		if line != "" {
			currentPattern = append(currentPattern, line)
		} else {
			patterns = append(patterns, currentPattern)
			currentPattern = []string{}
		}
	}
	patterns = append(patterns, currentPattern)
	return patterns
}

func check_for_smudge(aStr, bStr string) bool {
	minLength := len(aStr)
	if len(bStr) < minLength {
		minLength = len(bStr)
	}
	diffCount := 0
	for i := 0; i < minLength; i++ {
		if aStr[i] != bStr[i] {
			diffCount += 1
		}
	}
	return (diffCount == 1)
}

func get_reflections(smudges bool) {
	patterns := parse_file()
	patternSummary := 0
	for _, pattern := range patterns {
		// Check for vertical line of reflection
		possibleVertReflection := false
		line := pattern[0]
		for i := 1; i < len(line); i++ {
			smudgeUsed := false
			rightSide := line[i:]
			leftSide := line[:i]
			leftSideRunes := []rune(leftSide)
			slices.Reverse(leftSideRunes)
			mirrorLeftSide := string(leftSideRunes)
			// If either part of the string is equal to the start of the other, possible reflection found, check all other lines
			if strings.HasPrefix(mirrorLeftSide, rightSide) || strings.HasPrefix(rightSide, mirrorLeftSide) || (smudges && check_for_smudge(mirrorLeftSide, rightSide)) {
				possibleVertReflection = true
				smudgeUsed = (!strings.HasPrefix(mirrorLeftSide, rightSide) && !strings.HasPrefix(rightSide, mirrorLeftSide))
				for _, reflLine := range pattern[1:] {
					checkRight := reflLine[i:]
					checkLeft := reflLine[:i]
					checkLeftRunes := []rune(checkLeft)
					slices.Reverse(checkLeftRunes)
					checkMirrorLeft := string(checkLeftRunes)
					if !strings.HasPrefix(checkMirrorLeft, checkRight) && !strings.HasPrefix(checkRight, checkMirrorLeft) {
						if smudges && !smudgeUsed && check_for_smudge(checkMirrorLeft, checkRight) {
							smudgeUsed = true
						} else {
							possibleVertReflection = false
							break
						}
					}
				}
			}
			if possibleVertReflection {
				if !smudges || smudgeUsed {
					patternSummary += i
					break
				}
			}
		}
		// Check for horizontal line of reflection
		for i := 0; i < len(pattern) - 1; i++ {
			possibleHorizReflection := true
			smudgeUsed := false
			for a, b := i, i+1; a >= 0 && b < len(pattern); a, b = a-1, b+1 {
				aLine := pattern[a]
				bLine := pattern[b]
				if aLine != bLine {
					if smudges && !smudgeUsed && check_for_smudge(aLine, bLine) {
						smudgeUsed = true
					} else {
						possibleHorizReflection = false
						break
					}
				}
			}
			if possibleHorizReflection {
				if !smudges || smudgeUsed {
					patternSummary += (100*(i+1))
					break
				}
			}
		}
	}
	fmt.Println(patternSummary)
}

func main() {
	get_reflections(false)
	get_reflections(true)
}