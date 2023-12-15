package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

func print_error(err error) {
	if err != nil {
		fmt.Println(err)
	}
}

func get_valid_games() {
	file, err := os.Open("day2Input.txt")
	print_error(err)
	defer file.Close()

	totalValidGames := 0
	scanner := bufio.NewScanner(file)
	cubesMap := map[string]int{"red": 12, "green": 13, "blue": 14}
	for scanner.Scan() {
		line := scanner.Text()
		gameID, err := strconv.Atoi(strings.Split(strings.Split(line, ": ")[0], " ")[1])
		print_error(err)
		sets := strings.Split(strings.Split(line, ": ")[1], "; ")
		validGame := true
		for _, set := range sets {
			cubes := strings.Split(set, ", ")
			for _, cube := range cubes {
				parts := strings.Split(cube, " ")
				numCubes, err := strconv.Atoi(parts[0])
				print_error(err)
				if numCubes > cubesMap[parts[1]] {
					validGame = false
					break
				}
			}
			if !validGame {
				break
			}
		}
		if validGame {
			totalValidGames += gameID
		}
	}
	fmt.Println(totalValidGames)
}

func get_minimum_cube_powers() {
	file, err := os.Open("day2Input.txt")
	print_error(err)
	defer file.Close()

	totalPowers := 0
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := scanner.Text()
		sets := strings.Split(strings.Split(line, ": ")[1], "; ")
		minimumCubes := map[string]int{"red": 0, "green": 0, "blue": 0}
		for _, set := range sets {
			cubes := strings.Split(set, ", ")
			for _, cube := range cubes {
				parts := strings.Split(cube, " ")
				numCubes, err := strconv.Atoi(parts[0])
				print_error(err)
				if numCubes > minimumCubes[parts[1]] {
					minimumCubes[parts[1]] = numCubes
				}
			}
		}
		power := 1
		for _, v := range minimumCubes {
			power *= v
		}
		totalPowers += power
	}
	fmt.Println(totalPowers)
}

func main() {
	get_valid_games()
	get_minimum_cube_powers()
}