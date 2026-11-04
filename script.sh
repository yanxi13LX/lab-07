

for i in {1..4}; do
    dir="Testcase${i}Diff"

    # Remove old output directory e.g. the output from previous runnings
    rm -rf "$dir"

    for file1 in Testcase$i/*.1.txt; do
        file2="${file1%.1.txt}.2.txt"

        # Get the output filename
        name="${file1#*/}"
        name="${name%.1.txt}"
        output="$dir/${name}Diff.txt"

        # Create directory if it does not exist
        mkdir -p "$dir"

        # Compare files and save the diff output
        diff -u "$file1" "$file2" > "$output"
        status=$?

        # Remove output file if the two files are identical
        if [ "$status" -eq 0 ]; then
            rm "$output"
        fi
    done

    # Remove directory if no files differ
    rmdir "$dir" 2>/dev/null
done
