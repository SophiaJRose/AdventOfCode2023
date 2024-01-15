package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
	"math"
	"slices"
)

func print_error(err error) {
	if err != nil {
		fmt.Println(err)
	}
}

func get_distances(expansionAmount int) {
	matrix := [][]rune{}
	galaxyPositions := [][]int{}
	emptyRows := []int{}
	emptyCols := []int{}
	nonEmptyCols := []int{}

	file, err := os.Open("day11Input.txt")
	print_error(err)
	defer file.Close()

	scanner := bufio.NewScanner(file)
	i := 0
	for scanner.Scan() {
		line := scanner.Text()
		runes := []rune(line)
		for j, r := range runes {
			if r == '#' {
				galaxyPositions = append(galaxyPositions, []int{i, j})
				nonEmptyCols = append(nonEmptyCols, j)
			}
		}
		if !strings.ContainsRune(line, '#') {
			emptyRows = append(emptyRows, i)
		}
		matrix = append(matrix, []rune(line))
		i += 1
	}
	for i := 0; i < len(matrix[0]); i++ {
		if !slices.Contains(nonEmptyCols, i) {
			emptyCols = append(emptyCols, i)
		}
	}
	sumDistances := 0
	for i := 0; i < len(galaxyPositions)-1; i++ {
		for j := i+1; j < len(galaxyPositions); j++ {
			galaxy1 := galaxyPositions[i]
			galaxy2 := galaxyPositions[j]
			unexpandedDistance := int(math.Abs(float64(galaxy1[0] - galaxy2[0])) + math.Abs(float64(galaxy1[1] - galaxy2[1])))
			numEmptyRows := 0
			for k := galaxy1[0]; k < galaxy2[0]; k++ {
				if slices.Contains(emptyRows, k) {
					numEmptyRows += 1
				}
			}
			numEmptyCols := 0
			if galaxy1[1] < galaxy2[1] {
				for k := galaxy1[1]; k < galaxy2[1]; k++ {
					if slices.Contains(emptyCols, k) {
						numEmptyCols += 1
					}
				}
			} else {
				for k := galaxy2[1]; k < galaxy1[1]; k++ {
					if slices.Contains(emptyCols, k) {
						numEmptyCols += 1
					}
				}
			}
			expandedDistance := unexpandedDistance + (numEmptyRows * (expansionAmount - 1)) + (numEmptyCols * (expansionAmount - 1))
			sumDistances += expandedDistance
		}
	}
	fmt.Println(sumDistances)
}

func main() {
	get_distances(2)
	get_distances(1000000)
}