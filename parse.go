package main

import (
	"log"
	"os"
	"strings"
)

func main() {

	fileSlice, err := os.ReadFile("program3.txt")

	if err != nil {
		log.Panicf("failed to open file, %v\n", err)
	}

	file, err := os.Create("mach_code.txt")

	if err != nil {
		log.Panicf("Failed to create outputfile, %v\n", err)
	}

	defer file.Close()

	splitStrings := strings.Split(string(fileSlice), "\r\n")

	for _, lines := range splitStrings {
		idx := strings.LastIndex(lines, "//")
		if idx != -1 {
			lines = lines[:idx] //exclude the comments
		}

		if len(lines) == 0 {
			continue
		}

		outputline := make([]byte, 0)
		elements := strings.Split(lines, " ")

		isValid := 1
		if len(elements) < 3 {
			outputline = append(outputline, lines...)
			outputline = append(outputline, "\r\n"...)
			isValid = 0
		}

		log.Println(lines)

		if isValid == 1 {
			switch strings.ToLower(elements[0]) {
			case "mv":
				outputline = append(outputline, []byte("100")...)
			case "shl":
				outputline = append(outputline, []byte("000")...)
			case "shr":
				outputline = append(outputline, []byte("001")...)
			case "sub":
				outputline = append(outputline, []byte("010")...)
			case "b":
				outputline = append(outputline, []byte("011")...)
			case "str":
				outputline = append(outputline, []byte("110")...)
			case "ldr":
				outputline = append(outputline, []byte("101")...)
			case "regop":
				outputline = append(outputline, []byte("111")...)
			case "or":
				outputline = append(outputline, "000"...)
			case "flip":
				outputline = append(outputline, "001"...)
			default:
				outputline = append(outputline, []byte(elements[0]+"")...)
			}

			var t1 string

			switch strings.ToLower(elements[1]) {
			case "r0":
				t1 = "000"
			case "r1":
				t1 = "001"
			case "r2":
				t1 = "010"
			case "r3":
				t1 = "011"
			case "r4":
				t1 = "100"
			case "r5":
				t1 = "101"
			case "r6":
				t1 = "110"
			case "r7":
				t1 = "111"
			default:
				t1 = "" + elements[1]
			}

			outputline = append(outputline, []byte(t1)...)

			var t2 string

			switch strings.ToLower(elements[2]) {
			case "r0":
				t2 = "000"
			case "r1":
				t2 = "001"
			case "r2":
				t2 = "010"
			case "r3":
				t2 = "011"
			case "r4":
				t2 = "100"
			case "r5":
				t2 = "101"
			case "r6":
				t2 = "110"
			case "r7":
				t2 = "111"
			case "0":
				t2 = "000"
			case "1":
				t2 = "001"
			case "2":
				t2 = "010"
			case "3":
				t2 = "011"
			case "4":
				t2 = "100"
			case "5":
				t2 = "101"
			case "6":
				t2 = "110"
			case "7":
				t2 = "111"
			default:
				t2 = "" + elements[2]
			}

			outputline = append(outputline, []byte(t2)...)
		}

		//append the entire orignal line for clarity
		outputline = append(outputline, "    //"+lines+"\r\n"...)

		for len(outputline) > 0 {
			num, err := file.Write(outputline)

			if err != nil {
				log.Panicf("could not write to file, %v\n", err)
			}

			outputline = outputline[num:]

		}
	}

}
