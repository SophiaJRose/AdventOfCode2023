package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
	"strconv"
	"regexp"
)

func print_error(err error) {
	if err != nil {
		fmt.Println(err)
	}
}

func getKCombinations(slice []int, k int) [][]int {
	allCombs := [][]int{}
	if k == 1 {
		for _, n := range slice {
			allCombs = append(allCombs, []int{n})
		}
		return allCombs
	}
	for i, n := range slice {
		subCombinations := getKCombinations(slice[i+1:], k-1)
		for _, subComb := range subCombinations {
			comb := []int{n}
			comb = append(comb, subComb...)
			allCombs = append(allCombs, comb)
		}
	}
	return allCombs
}

func get_configurations(unfold bool) {
	file, err := os.Open("day12Input.txt")
	print_error(err)
	defer file.Close()

	totalConfigurations := 0
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := scanner.Text()
		fmt.Println(line)
		lineParts := strings.Fields(line)
		pattern, numberList := lineParts[0], lineParts[1]
		if unfold {
			pattern = pattern + "?" + pattern + "?" + pattern + "?" + pattern + "?" + pattern
			numberList = numberList + "," + numberList + "," + numberList + "," + numberList + "," + numberList
		}
		numbers := []int{}
		numberStrs := strings.Split(numberList, ",")
		totalSprings := 0
		regexpString := "\\.*"
		for _, num := range numberStrs {
			n, err := strconv.Atoi(num)
			print_error(err)
			numbers = append(numbers, n)
			totalSprings += n
			regexpString = regexpString + fmt.Sprintf("#{%d}", n) + "\\.+"
		}
		regexpString = regexpString[:len(regexpString)-1] + "*"
		re := regexp.MustCompile(regexpString)
		unknownIndices := []int{}
		for i, r := range []rune(pattern) {
			if r == '?' {
				unknownIndices = append(unknownIndices, i)
			}
		}
		unknownSprings := totalSprings - strings.Count(pattern, "#")
		if unknownSprings == 0 {
			totalConfigurations += 1
			continue
		}
		springCombinations := getKCombinations(unknownIndices, unknownSprings)
		for _, comb := range springCombinations {
			possiblePattern := strings.Clone(pattern)
			for _, n := range comb {
				possiblePattern = possiblePattern[:n] + "#" + possiblePattern[n+1:]
			}
			possiblePattern = strings.ReplaceAll(possiblePattern, "?", ".")
			if re.MatchString(possiblePattern) {
				totalConfigurations += 1
			}
		}
	}
	fmt.Println(totalConfigurations)
}

func main() {
	get_configurations(false)
	// get_configurations(true)
}

// Solution is too inefficient to solve Part 2 in a reasonable amount of time