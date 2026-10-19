package cmd

import "core:fmt"
import "core:os"

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
	fmt.println(content)
}
