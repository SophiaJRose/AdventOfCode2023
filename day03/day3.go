package main

import (
	"bufio"
	"fmt"
	"os"
	"math"
	"slices"
	"regexp"
	"strconv"
)

type Gear struct {
	x, y, number int
}

func print_error(err error) {
	if err != nil {
		fmt.Println(err)
	}
}

func parse_file() [][]rune {
	file, err := os.Open("day3Input.txt")
	print_error(err)
	defer file.Close()

	matrix := [][]rune{}
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := scanner.Text()
		chars := []rune(line)
		matrix = append(matrix, chars)
	}
	return matrix
}

func check_surroundings_for_symbols(matrix [][]rune, i, jStart, jEnd, height, width int) bool {
	iSearchStart := int(math.Max(0, float64(i-1)))
	iSearchEnd := int(math.Min(float64(i+2), float64(height)))
	jSearchStart := int(math.Max(0, float64(jStart-1)))
	jSearchEnd := int(math.Min(float64(jEnd+1), float64(width)))
	searchRows := matrix[iSearchStart:iSearchEnd]
	isSymbol := func(r rune) bool {
		re := regexp.MustCompile("[^0-9\\.]")
		return re.MatchString(string(r))
	}
	for _, row := range searchRows {
		if slices.ContainsFunc(row[jSearchStart:jSearchEnd], isSymbol) {
			return true
		}
	}
	return false
}

func get_surrounding_gears(matrix [][]rune, i, jStart, jEnd, height, width int) []Gear {
	iSearchStart := int(math.Max(0, float64(i-1)))
	iSearchEnd := int(math.Min(float64(i+2), float64(height)))
	jSearchStart := int(math.Max(0, float64(jStart-1)))
	jSearchEnd := int(math.Min(float64(jEnd+1), float64(width)))
	listGears := []Gear{}
	for x := iSearchStart; x < iSearchEnd; x++ {
		for y := jSearchStart; y < jSearchEnd; y++ {
			if matrix[x][y] == rune('*') {
				partNum, err := strconv.Atoi(string(matrix[i][jStart:jEnd]))
				print_error(err)
				gear := Gear{x:x, y:y, number:partNum}
				listGears = append(listGears, gear)
			}
		}
	}
	return listGears
}


func get_part_numbers() {
	sumPartNumbers := 0
	matrix := parse_file()
	height := len(matrix)
	width := len(matrix[0])
	digitRegex := regexp.MustCompile("[0-9]")
	for i, line := range matrix {
		numberEnd := 0
		for j := 0; j < width; j++ {
			if j < numberEnd {
				continue
			}
			char := line[j]
			if digitRegex.MatchString(string(char)) {
				numberEnd = j
				for numberEnd < width && digitRegex.MatchString(string(line[numberEnd])) {
					numberEnd++
				}
				if check_surroundings_for_symbols(matrix, i, j, numberEnd, height, width) {
					partNum, err := strconv.Atoi(string(line[j:numberEnd]))
					print_error(err)
					sumPartNumbers += partNum
				}
				j = numberEnd
			}
		}
	}
	fmt.Println(sumPartNumbers)
}

func get_gear_ratios() {
	sumGearRatios := 0
	listGears := []Gear{}
	matrix := parse_file()
	height := len(matrix)
	width := len(matrix[0])
	digitRegex := regexp.MustCompile("[0-9]")
	for i, line := range matrix {
		numberEnd := 0
		for j := 0; j < width; j++ {
			if j < numberEnd {
				continue
			}
			char := line[j]
			if digitRegex.MatchString(string(char)) {
				numberEnd = j
				for numberEnd < width && digitRegex.MatchString(string(line[numberEnd])) {
					numberEnd++
				}
				listGears = append(listGears, get_surrounding_gears(matrix, i, j, numberEnd, height, width)...)
				j = numberEnd
			}
		}
	}
	for i, gear1 := range listGears {
		for j, gear2 := range listGears {
			if j <= i {
				continue
			}
			if gear1.x == gear2.x && gear1.y == gear2.y {
				sumGearRatios += (gear1.number * gear2.number)
			}
		}
	}
	fmt.Println(sumGearRatios)
}

func main() {
	get_part_numbers()
	get_gear_ratios()
}