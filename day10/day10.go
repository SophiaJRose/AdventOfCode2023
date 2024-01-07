package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
	"math"
	"slices"
)

type pipeMatrix struct {
	matrix [][]rune
	startPoint []int
}

func print_error(err error) {
	if err != nil {
		fmt.Println(err)
	}
}

func parse_file() pipeMatrix {
	matrix := [][]rune{}
	i := 0
	startPoint := []int{}
	file, err := os.Open("day10Input.txt")
	print_error(err)
	defer file.Close()

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := scanner.Text()
		start := strings.Index(line, "S")
		if start != -1 {
			startPoint = []int{start, i}
		}
		matrix = append(matrix, []rune(line))
		i += 1
	}
	return pipeMatrix{matrix: matrix, startPoint: startPoint}
}

func map_pipe() {
	pipe := parse_file()
	matrix := pipe.matrix
	start := pipe.startPoint
	surroundingsMap := map[rune][][]int{
		'|': [][]int{[]int{-1, 0}, []int{1, 0}},
		'-': [][]int{[]int{0, -1}, []int{0, 1}},
		'L': [][]int{[]int{-1, 0}, []int{0, 1}},
		'J': [][]int{[]int{0, -1}, []int{-1, 0}},
		'7': [][]int{[]int{0, -1}, []int{1, 0}},
		'F': [][]int{[]int{1, 0}, []int{0, 1}},
	}
	// Find connections to starting point
	sX, sY := start[0], start[1]
	startSurroundings := []rune{matrix[sY-1][sX], matrix[sY][sX-1], matrix[sY][sX+1], matrix[sY+1][sX]} // ULRD
	startConnections := []string{"|7F", "-LF", "-J7", "|LJ"}
	startConnected := []bool{false, false, false, false}
	for i := 0; i < 4; i++ {
		startConnected[i] = strings.ContainsRune(startConnections[i], startSurroundings[i])
	}
	switch {
	case slices.Equal(startConnected, []bool{true, true, false, false}):
		matrix[sY][sX] = 'J'
	case slices.Equal(startConnected, []bool{true, false, true, false}):
		matrix[sY][sX] = 'L'
	case slices.Equal(startConnected, []bool{true, false, false, true}):
		matrix[sY][sX] = '|'
	case slices.Equal(startConnected, []bool{false, true, true, false}):
		matrix[sY][sX] = '-'
	case slices.Equal(startConnected, []bool{false, true, false, true}):
		matrix[sY][sX] = '7'
	case slices.Equal(startConnected, []bool{false, false, true, true}):
		matrix[sY][sX] = 'F'
	default:
		fmt.Println("Invalid input, starting point does not have exactly two connections")
		return
	}
	// Preparation for Part 2, must be done before part 1 removes loop tiles
	// Create a new matrix that is 3x the size of original matrix in each dimension, to be a higher resolution version of the pipe diagram
	lettersUpResMap := map[rune][][]rune{
		'.': [][]rune{[]rune{'.', '.', '.'}, []rune{'.', '.', '.'}, []rune{'.', '.', '.'}},
		'-': [][]rune{[]rune{'.', '.', '.'}, []rune{'-', '-', '-'}, []rune{'.', '.', '.'}},
		'|': [][]rune{[]rune{'.', '|', '.'}, []rune{'.', '|', '.'}, []rune{'.', '|', '.'}},
		'L': [][]rune{[]rune{'.', '|', '.'}, []rune{'.', 'L', '-'}, []rune{'.', '.', '.'}},
		'J': [][]rune{[]rune{'.', '|', '.'}, []rune{'-', 'J', '.'}, []rune{'.', '.', '.'}},
		'7': [][]rune{[]rune{'.', '.', '.'}, []rune{'-', '7', '.'}, []rune{'.', '|', '.'}},
		'F': [][]rune{[]rune{'.', '.', '.'}, []rune{'.', 'F', '-'}, []rune{'.', '|', '.'}},
	}
	// Iterate through each line of matrix, replacing each character with corresponding 3x3 matrix
	matrixUpRes := [][]rune{}
	for _, line := range matrix {
		// Iterate each line three times, each time adding one row of 3x3 matrix of each character
		for j := 0; j < 3; j ++ {
			upResLine := []rune{}
			for _, r := range line {
				upResLine = append(upResLine, lettersUpResMap[r][j]...)
			}
			matrixUpRes = append(matrixUpRes, upResLine)
		}
	}
	// Back to part 1 code
	// Traverse loop from starting point in both directions until paths meet
	prevPoints := [][]int{[]int{sY, sX}, []int{sY, sX}}
	currentPoints := [][]int{[]int{sY + surroundingsMap[matrix[sY][sX]][0][0], sX + surroundingsMap[matrix[sY][sX]][0][1]}, []int{sY + surroundingsMap[matrix[sY][sX]][1][0], sX + surroundingsMap[matrix[sY][sX]][1][1]}}
	steps := 1
	for !slices.Equal(currentPoints[0], currentPoints[1]) {
		for i := 0; i < 2; i++ {
			point := currentPoints[i]
			tile := matrix[point[0]][point[1]]
			nextBranches := [][]int{[]int{point[0] + surroundingsMap[tile][0][0], point[1] + surroundingsMap[tile][0][1]}, []int{point[0] + surroundingsMap[tile][1][0], point[1] + surroundingsMap[tile][1][1]}}
			nextPoint := nextBranches[0]
			for _, pPoint := range prevPoints {
				if slices.Equal(pPoint, nextPoint) {
					nextPoint = nextBranches[1]
					break
				}
			}
			prevPoints[i] = currentPoints[i]
			currentPoints[i] = nextPoint
			// Removing loop tiles for part 2
			matrix[prevPoints[i][0]][prevPoints[i][1]] = ' '
		}
		steps += 1
	}
	// Remove start and end points of the loop
	matrix[sY][sX] = ' '
	matrix[currentPoints[0][0]][currentPoints[0][1]] = ' '
	fmt.Println(steps)
	// Part 2, find enclosed tiles
	// Mark all tiles connected to edges of matrix, non-marked tiles are enclosed in loop
	// Fill from edges
	fillQueue := [][]int{}
	// Top row
	for j, r := range matrixUpRes[0] {
		if r == '.' {
			r = 'E'
			fillQueue = append(fillQueue, []int{0, j})
		}
	}
	// Bottom row
	for j, r := range matrixUpRes[len(matrixUpRes)-1] {
		if r == '.' {
			r = 'E'
			fillQueue = append(fillQueue, []int{0, j})
		}
	}
	// Left and right columns
	for i, line := range matrixUpRes {
		if line[0] == '.' {
			line[0] = 'E'
			fillQueue = append(fillQueue, []int{i, 0})
		}
		if line[len(line)-1] == '.' {
			line[len(line)-1] = 'E'
			fillQueue = append(fillQueue, []int{i, len(line)-1})
		}
	}
	// For each tile marked as connected to edge, mark connected non-pipe tiles and add to queue
	height := len(matrixUpRes)
	width := len(matrixUpRes[0])
	for len(fillQueue) != 0 {
		nextTile := fillQueue[0]
		fillQueue = fillQueue[1:]
		a, b := nextTile[0], nextTile[1]
		iRangeStart := int(math.Max(0, float64(a-1)))
		iRangeEnd := int(math.Min(float64(a+1), float64(height-1)))
		jRangeStart := int(math.Max(0, float64(b-1)))
		jRangeEnd := int(math.Min(float64(b+1), float64(width-1)))
		for i := iRangeStart; i <= iRangeEnd; i++ {
			for j := jRangeStart; j <= jRangeEnd; j++ {
				// Fill with E if empty space, or if corresponding tile in original matrix is not part of loop
				isCenter := i % 3 == 1 && j % 3 == 1
				notLoop := false
				if isCenter {
					notLoop = matrix[(i-1)/3][(j-1)/3] != ' '
				}
				if matrixUpRes[i][j] == '.' || (notLoop && matrixUpRes[i][j] != 'E') {
					matrixUpRes[i][j] = 'E'
					fillQueue = append(fillQueue, []int{i, j})
				}
			}
		}
	}
	// Count enclosed tiles
	// Iterate over original matrix, if tile is not part of pipe and corresponding center tile in up-res matrix is not E, then it is enclosed
	totalEnclosedTiles := 0
	for i, line := range matrix {
		for j, r := range line {
			if r != ' ' && matrixUpRes[3*i + 1][3*j + 1] != 'E' {
				totalEnclosedTiles += 1
			}
		}
	}
	fmt.Println(totalEnclosedTiles)
}

func main() {
	map_pipe()
}