package main

import (
	"bufio"
	"fmt"
	"os"
	"slices"
)

func print_error(err error) {
	if err != nil {
		fmt.Println(err)
	}
}

func parse_file() [][]rune {
	file, err := os.Open("day14Input.txt")
	print_error(err)
	defer file.Close()

	matrix := [][]rune{}
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := scanner.Text()
		matrix = append(matrix, []rune(line))
	}
	return matrix
}

func push_boulders_north(matrix [][]rune) {
	for i, line := range matrix {
		for j, tile := range line {
			if tile == 'O' {
				i2 := i - 1
				for i2 >= 0 && matrix[i2][j] == '.' {
					i2--
				}
				matrix[i][j] = '.'
				matrix[i2+1][j] = 'O'
			}
		}
	}
}

func push_boulders_west(matrix [][]rune) {
	for i, line := range matrix {
		for j, tile := range line {
			if tile == 'O' {
				j2 := j - 1
				for j2 >= 0 && matrix[i][j2] == '.' {
					j2--
				}
				matrix[i][j] = '.'
				matrix[i][j2+1] = 'O'
			}
		}
	}
}

func push_boulders_south(matrix [][]rune) {
	slices.Reverse(matrix)
	push_boulders_north(matrix)
	slices.Reverse(matrix)
}

func push_boulders_east(matrix [][]rune) {
	for _, line := range matrix {
		slices.Reverse(line)
	}
	push_boulders_west(matrix)
	for _, line := range matrix {
		slices.Reverse(line)
	}
}

func get_load() {
	matrix := parse_file()
	push_boulders_north(matrix)
	height := len(matrix)
	load := 0
	for i, line := range matrix {
		for _, tile := range line {
			if tile == 'O' {
				load += (height - i)
			}
		}
	}
	fmt.Println(load)
}

func deep_copy_matrix(matrix [][]rune) [][]rune {
	newMatrix := [][]rune{}
	for _, line := range matrix {
		newMatrix = append(newMatrix, slices.Clone(line))
	}
	return newMatrix
}

func print_matrix(matrix [][]rune) {
	for _, line := range matrix {
		for _, tile := range line {
			fmt.Print(string(tile))
		}
		fmt.Println()
	}
}

func get_spin_cycle_load() {
	matrix := parse_file()
	states := [][][]rune{}
	loopStart := -1
	iterations := 0
	stateMatches := func (state [][]rune) bool {
		for i, line := range matrix {
			if !slices.Equal(line, state[i]) {
				return false
			}
		}
		return true
	}
	for true {
		seenBefore := slices.IndexFunc(states, stateMatches)
		if seenBefore != -1 {
			loopStart = seenBefore
			break
		}
		states = append(states, deep_copy_matrix(matrix))
		push_boulders_north(matrix)
		push_boulders_west(matrix)
		push_boulders_south(matrix)
		push_boulders_east(matrix)
		iterations++
	}
	loopLength := iterations - loopStart
	cyclesLeft := (1000000000 - loopStart) % loopLength
	finalState := states[loopStart + cyclesLeft]
	height := len(finalState)
	load := 0
	for i, line := range finalState {
		for _, tile := range line {
			if tile == 'O' {
				load += (height - i)
			}
		}
	}
	fmt.Println(load)
}

func main() {
	get_load()
	get_spin_cycle_load()
}