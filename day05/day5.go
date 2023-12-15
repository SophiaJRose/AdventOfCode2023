package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
	"strconv"
	"slices"
)

type conversionMap struct {
	sourceStart, destStart, size int
}

type valueRange struct {
	start, size int
}

func print_error(err error) {
	if err != nil {
		fmt.Println(err)
	}
}

func generate_map(scanner *bufio.Scanner) []conversionMap {
	mapArray := []conversionMap{}
	scanner.Scan()	// Header line
	for scanner.Scan() {
		line := scanner.Text()
		// Empty lines between maps
		if line == "" {
			break
		}
		numbers := strings.Split(line, " ")
		destRangeStart, err := strconv.Atoi(numbers[0])
		print_error(err)
		sourceRangeStart, err := strconv.Atoi(numbers[1])
		print_error(err)
		rangeSize, err := strconv.Atoi(numbers[2])
		print_error(err)
		convMap := conversionMap{sourceStart: sourceRangeStart, destStart: destRangeStart, size: rangeSize}
		mapArray = append(mapArray, convMap)
	}
	return mapArray
}

func get_map_value(conversionMaps []conversionMap, number int) int {
	value := number
	for _, convMap := range conversionMaps {
		sourceStart := convMap.sourceStart
		size := convMap.size
		if number >= sourceStart && number < (sourceStart + size) {
			diff := number - sourceStart
			value = convMap.destStart + diff
		}
	}
	return value
}

func get_min_location() {
	file, err := os.Open("day5Input.txt")
	print_error(err)
	defer file.Close()

	scanner := bufio.NewScanner(file)
	// Seeds
	scanner.Scan()
	seedsLine := scanner.Text()
	seedStrs := strings.Split(strings.Split(seedsLine, ": ")[1], " ")
	seeds := make([]int, len(seedStrs))
	for i, str := range seedStrs {
		seeds[i], err = strconv.Atoi(str)
		print_error(err)
	}
	scanner.Scan()  // Empty line between seeds and seedToSoil map
	seedToSoil := generate_map(scanner)
	soilToFert := generate_map(scanner)
	fertToWater := generate_map(scanner)
	waterToLight := generate_map(scanner)
	lightToTemp := generate_map(scanner)
	tempToHumid := generate_map(scanner)
	humidToLoc := generate_map(scanner)
	minLocation := -1
	for _, seed := range seeds {
		soil := get_map_value(seedToSoil, seed)
		fert := get_map_value(soilToFert, soil)
		water := get_map_value(fertToWater, fert)
		light := get_map_value(waterToLight, water)
		temp := get_map_value(lightToTemp, light)
		humid := get_map_value(tempToHumid, temp)
		loc := get_map_value(humidToLoc, humid)
		if minLocation > loc || minLocation == -1 {
			minLocation = loc
		}
	}
	fmt.Println(minLocation)
}

func check_range_overlap(conversionMaps []conversionMap, valRanges []valueRange) []valueRange {
	allNewRanges := []valueRange{}
	for len(valRanges) != 0 {
		valRange := valRanges[0]
		valRanges = valRanges[1:]
		newRanges := []valueRange{}
		for _, convMap := range conversionMaps {
			valRangeStart := valRange.start
			valRangeEnd := valRangeStart + valRange.size
			mapRangeStart := convMap.sourceStart
			mapRangeEnd := mapRangeStart + convMap.size
			// Case 1: seed range is subset of map source range, map seed range start to value from map destination range
			if valRangeStart >= mapRangeStart && valRangeEnd <= mapRangeEnd {
				rangeStartDiff := valRangeStart - mapRangeStart
				newRange := valueRange{start: convMap.destStart + rangeStartDiff, size: valRange.size}
				newRanges = append(newRanges, newRange)
				break
			// Case 2/3: partial overlap of ranges, split into two ranges
			} else if valRangeStart < mapRangeStart && mapRangeStart < valRangeEnd && valRangeEnd < mapRangeEnd {
				overlapSize := valRangeEnd - mapRangeStart
				overlapRange := valueRange{start: convMap.destStart, size: overlapSize}
				newRanges = append(newRanges, overlapRange)
				remainderSize := mapRangeStart - valRangeStart
				remainderRange := valueRange{start: valRangeStart, size: remainderSize}
				valRanges = append(valRanges, remainderRange)
				break
			} else if mapRangeStart < valRangeStart && valRangeStart < mapRangeEnd && mapRangeEnd < valRangeEnd {
				overlapSize := mapRangeEnd - valRangeStart
				rangeStartDiff := valRangeStart - mapRangeStart
				overlapRange := valueRange{start: convMap.destStart + rangeStartDiff, size: overlapSize}
				newRanges = append(newRanges, overlapRange)
				remainderSize := valRangeEnd - mapRangeEnd
				remainderRange := valueRange{start: mapRangeEnd, size: remainderSize}
				valRanges = append(valRanges, remainderRange)
				break
			// Case 4: map source range is subset of seed range, split into three ranges
			} else if mapRangeStart >= valRangeStart && mapRangeEnd <= valRangeEnd {
				overlapRange := valueRange{start: convMap.destStart, size: convMap.size}
				newRanges = append(newRanges, overlapRange)
				beforeRemainderSize := mapRangeStart - valRangeStart
				if beforeRemainderSize != 0 {
					beforeRemainderRange := valueRange{start: valRangeStart, size: beforeRemainderSize}
					valRanges = append(valRanges, beforeRemainderRange)
				}
				afterRemainderSize := valRangeEnd - mapRangeEnd
				if afterRemainderSize != 0 {
					afterRemainderRange := valueRange{start: mapRangeEnd, size: afterRemainderSize}
					valRanges = append(valRanges, afterRemainderRange)
				}
				break
			}
		}
		if len(newRanges) == 0 {
			newRanges = append(newRanges, valRange)
		}
		allNewRanges = append(allNewRanges, newRanges...)
	}
	return allNewRanges
}

func get_min_location_ranges() {
	file, err := os.Open("day5Input.txt")
	print_error(err)
	defer file.Close()

	scanner := bufio.NewScanner(file)
	// Seed ranges
	scanner.Scan()
	seedsLine := scanner.Text()
	seedStrs := strings.Split(strings.Split(seedsLine, ": ")[1], " ")
	seedNums := make([]int, len(seedStrs))
	seedRanges := []valueRange{}
	for i, str := range seedStrs {
		seedNums[i], err = strconv.Atoi(str)
		print_error(err)
	}
	i := 0
	for i+1 < len(seedNums) {
		seedRanges = append(seedRanges, valueRange{start: seedNums[i], size: seedNums[i+1]})
		i += 2
	}
	scanner.Scan()  // Empty line between seeds and seedToSoil map
	seedToSoil := generate_map(scanner)
	soilToFert := generate_map(scanner)
	fertToWater := generate_map(scanner)
	waterToLight := generate_map(scanner)
	lightToTemp := generate_map(scanner)
	tempToHumid := generate_map(scanner)
	humidToLoc := generate_map(scanner)
	cmpStart := func(r1 valueRange, r2 valueRange) int {
		if r1.start < r2.start {
			return -1
		} else if r1.start > r2.start {
			return 1
		} else {
			return 0
		}
	}
	soilRanges := check_range_overlap(seedToSoil, seedRanges)
	fertRanges := check_range_overlap(soilToFert, soilRanges)
	waterRanges := check_range_overlap(fertToWater, fertRanges)
	lightRanges := check_range_overlap(waterToLight, waterRanges)
	tempRanges := check_range_overlap(lightToTemp, lightRanges)
	humidRanges := check_range_overlap(tempToHumid, tempRanges)
	locRanges := check_range_overlap(humidToLoc, humidRanges)
	slices.SortFunc(locRanges, cmpStart)
	fmt.Println(locRanges[0].start)
}

func main() {
	get_min_location()
	get_min_location_ranges()
}