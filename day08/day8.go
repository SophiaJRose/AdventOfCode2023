package main

import (
	"bufio"
	"fmt"
	"os"
	"math"
)

type node struct {
	left, right string
}

type stepCounter struct {
	steps int
	end bool
}

func print_error(err error) {
	if err != nil {
		fmt.Println(err)
	}
}

func greatest_common_divisor (x, y int) int {
	if y == 0 {
		return x
	} else {
		return greatest_common_divisor(y, x % y)
	}
}

func lowest_common_multiple (x, y int) int {
	return (int(math.Abs(float64(x * y))) / greatest_common_divisor(x, y))
}

func navigate_map(multipleRoutes bool) {
	file, err := os.Open("day8Input.txt")
	print_error(err)
	defer file.Close()

	scanner := bufio.NewScanner(file)
	scanner.Scan()
	directions := scanner.Text()
	// Empty line
	scanner.Scan()
	nodes := map[string]node{}
	for scanner.Scan() {
		line := scanner.Text()
		nodeName := line[:3]
		leftNode := line[7:10]
		rightNode := line[12:15]
		nodes[nodeName] = node{left: leftNode, right: rightNode}
	}
	currentNodes := []string{}
	if multipleRoutes {
		for key, _ := range nodes {
			if key[2] == 'A' {
				currentNodes = append(currentNodes, key)
			}
		}
	} else {
		currentNodes = append(currentNodes, "AAA")
	}
	steps := 0
	stepsTaken := make([]stepCounter, len(currentNodes))
	for i, _ := range stepsTaken {
		stepsTaken[i] = stepCounter{steps: 0, end: false}
	}
	done := false
	for !done {
		goRight := directions[steps % len(directions)] == 'R'
		done = true
		for i, _ := range currentNodes {
			// Take step to next node
			if goRight {
				currentNodes[i] = nodes[currentNodes[i]].right
			} else {
				currentNodes[i] = nodes[currentNodes[i]].left
			}
			// If not reached end, increment step counter and continue outer loop
			if currentNodes[i][2] != 'Z' && !stepsTaken[i].end {
				stepsTaken[i].steps += 1
				done = false
			// If reached end, add final step and stop counting
			} else if currentNodes[i][2] == 'Z' {
				stepsTaken[i].steps += 1
				stepsTaken[i].end = true
			}
		}
		steps += 1
	}
	totalSteps := 1
	for _, stepCount := range stepsTaken {
		totalSteps = lowest_common_multiple(totalSteps, stepCount.steps)
	}
	fmt.Println(totalSteps)
}

func main() {
	navigate_map(false)
	navigate_map(true)
}