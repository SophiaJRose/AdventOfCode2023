package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
	"strconv"
)

func print_error(err error) {
	if err != nil {
		fmt.Println(err)
	}
}

func get_ways_to_win(singleRace bool) {
	file, err := os.Open("day6Input.txt")
	print_error(err)
	defer file.Close()

	scanner := bufio.NewScanner(file)
	scanner.Scan()
	timeLine := scanner.Text()
	scanner.Scan()
	distLine := scanner.Text()
	times := []int{}
	distances := []int{}
	if singleRace {
		timeStr := strings.ReplaceAll(strings.Split(timeLine, ":")[1], " ", "")
		times = make([]int, 1)
		times[0], err = strconv.Atoi(timeStr)
		print_error(err)
		distStr := strings.ReplaceAll(strings.Split(distLine, ":")[1], " ", "")
		distances = make([]int, 1)
		distances[0], err = strconv.Atoi(distStr)
		print_error(err)
	} else {
		timeStrs := strings.Fields(strings.Split(timeLine, ":")[1])
		times = make([]int, len(timeStrs))
		for i, str := range timeStrs {
			times[i], err = strconv.Atoi(str)
			print_error(err)
		}
		distStrs := strings.Fields(strings.Split(distLine, ":")[1])
		distances = make([]int, len(distStrs))
		for i, str := range distStrs {
			distances[i], err = strconv.Atoi(str)
			print_error(err)
		}
	}
	totalWaysToWin := 1
	for i, _ := range times {
		waysToWin := 0
		time := times[i]
		dist := distances[i]
		for j := 0; j < time; j++ {
			if (j * (time - j) <= dist) {
				continue
			}
			waysToWin = time + 1 - (2 * j)
			break
		}
		totalWaysToWin = totalWaysToWin * waysToWin
	}
	fmt.Println(totalWaysToWin)
}

func main() {
	get_ways_to_win(false)
	get_ways_to_win(true)
}