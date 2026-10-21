package cmd

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"

main :: proc() {
	// provide our target file path
	filepath := "/proc/meminfo"

	// read the entire file using the std context alloc (i think this is like malloc)
	data, err := os.read_entire_file(filepath, context.allocator)
	if err != nil {
		fmt.eprintfln("Error reading file:", err)
		return
	}
	// clean up mem when exiting
	defer delete(data, context.allocator)

	// convert the bytes to a string so we can manipulate or print it
	content := string(data)

	// iterate one line at a time to find the line that starts with...
	for line in strings.split_iterator(&content, "\n") { 	// iterate thru all
		if strings.has_prefix(line, "MemTotal:") { 	// find and print
			// splits the strings into their individual slices/fields
			split_line := strings.fields(line)
			defer delete(split_line)

			// grab the string at index 1 (the mem number itself) and parse it to an int
			if len(split_line) >= 2 {
				mem_str := split_line[1] // take the mem only
				mem_total, ok := strconv.parse_int(mem_str) // conversion happens here

				if ok {
					// do the math (we're conv from kB to MB)
					mem_in_mb := mem_total / 1024
					fmt.printf("Total Memory: %d kB (%d MB)\n", mem_total, mem_in_mb)
				}
			}
		}
	}
}
