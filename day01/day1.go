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

func get_values(words bool) {
	file, err := os.Open("day1Input.txt")
	print_error(err)
	defer file.Close()

	totalValues := 0
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := scanner.Text()
		if words {
			wordsMap := map[string]string{"one": "o1e", "two": "t2o", "three": "t3e", "four": "f4r", "five": "f5e", "six": "s6x", "seven": "s7n", "eight": "e8t", "nine": "n9e", "zero": "z0o"}
			for key, value := range wordsMap {
				line = strings.ReplaceAll(line, key, value)
			}
		}
		digitsOnly := func(r rune) rune {
			if r >= '0' && r <= '9' {
				return r
			}
			return -1
		}
		line = strings.Map(digitsOnly, line)
		valueStr := line[:1] + line[len(line)-1:]
		value, err := strconv.Atoi(valueStr)
		print_error(err)
		totalValues += value
	}
	fmt.Println(totalValues)
}

func main() {
	get_values(false)
	get_values(true)
}
