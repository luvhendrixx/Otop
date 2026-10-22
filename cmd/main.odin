package cmd

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

main :: proc() {
	// provide our target file path
	filepath := "/proc/meminfo"

	// read the entire file using the std context alloc (i think this is like malloc)
	data, err := os.read_entire_file(filepath, context.allocator)
	if err != nil {
		fmt.eprintfln("Error reading file: %v", err)
		return
	}
	// clean up mem when exiting
	defer delete(data, context.allocator)

	// convert the bytes to a string so we can manipulate or print it
	content := string(data)

	mem_total, mem_available: int

	for line in strings.split_iterator(&content, "\n") {
		if strings.has_prefix(line, "MemTotal:") {
			mem_total, _ = parse_kb(line)
		} else if strings.has_prefix(line, "MemAvailable:") {
			mem_available, _ = parse_kb(line)
		}
	}
	// loop is done with both values fixed in
	mem_used := mem_total - mem_available
	// fmt.printf("Mem used: %d MB\n", mem_used / 1024)

	// call print_bar
	print_bar(mem_used, mem_total)
}

parse_kb :: proc(line: string) -> (int, bool) {
	// this splits ["MemTotal:" "12345" "kB"] into their indiv fields 0, 1, 2 ...
	fields := strings.fields(line)
	defer delete(fields)
	if len(fields) < 2 { 	// error checking so we don't do math on non-existent values
		return 0, false
	}
	return strconv.parse_int(fields[1]) // parse fields 1 (the actual mem value) into an int
}

print_bar :: proc(used, total: int) {
	// multiple the used by 100 first then divide by total second to avoid 0-ing
	perc_val := used * 100 / total // we * the / first so we're left with something to actually compute with

	// bar is 20 chars wide... so based off the answer we got uptop, * ans by 20 then / 100 which gives us the filled bars out of the 20
	char_val := perc_val * 20 / 100

	// make a loop that loops thru and prints a # based on the ans uptop all in one straight line
	for i in 0 ..< 20 {
		// intro the if stms to check if char_val is <20, print the #, else print -
		if char_val > i {
			fmt.print("#")
		} else {
			fmt.print("-")
		}
	}
}
