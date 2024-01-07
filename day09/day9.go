package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
	"strconv"
	"slices"
)

func print_error(err error) {
	if err != nil {
		fmt.Println(err)
	}
}

func get_extrapolated_values(backwards bool) {
	file, err := os.Open("day9Input.txt")
	print_error(err)
	defer file.Close()

	totalExtrapolatedValue := 0
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := scanner.Text()
		numStrs := strings.Fields(line)
		nums := make([]int, len(numStrs))
		for i, n := range numStrs {
			num, err := strconv.Atoi(n)
			print_error(err)
			nums[i] = num
		}
		if backwards {
			slices.Reverse(nums)
		}
		layers := [][]int{}
		layers = append(layers, nums)
		allZero := false
		layerNum := 0
		currentLayer := layers[layerNum]
		for !allZero {
			newLayer := []int{}
			allZero = true
			for i := 0; i < len(currentLayer)-1; i++ {
				diff := currentLayer[i+1] - currentLayer[i]
				allZero = allZero && diff == 0
				newLayer = append(newLayer, diff)
			}
			layers = append(layers, newLayer)
			layerNum += 1
			currentLayer = layers[layerNum]
		}
		layers[len(layers)-1] = append(layers[len(layers)-1], 0)
		extrapolatedValue := 0
		for i := len(layers)-2; i >= 0; i-- {
			extrapolatedValue = layers[i][len(layers[i])-1] + layers[i+1][len(layers[i+1])-1]
			layers[i] = append(layers[i], extrapolatedValue)
			// fmt.Println(extrapolatedValue)
		}
		totalExtrapolatedValue += extrapolatedValue
	}
	fmt.Println(totalExtrapolatedValue)
}

func main() {
	get_extrapolated_values(false)
	get_extrapolated_values(true)
}