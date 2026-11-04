all_pass=1

for i in {1..4}; do
    dir="Testcase${i}Diff"
    pass=1
    need_dir=0

    # Check every pair of original files
    for file1 in Testcase$i/*.1.txt; do
        file2="${file1%.1.txt}.2.txt"

        name="${file1##*/}"
        name="${name%.1.txt}"
        output="$dir/${name}Diff.txt"

        # Compare the original files
        diff -u "$file1" "$file2" > /dev/null
        status=$?

        if [ "$status" -eq 1 ]; then
            need_dir=1

            # The output file must exist
            if [ ! -f "$output" ]; then
                pass=0
            else
                # Compare contents, skipping the first two lines
                if ! diff -q \
                    <(diff -u "$file1" "$file2" | tail -n +3) \
                    <(tail -n +3 "$output") > /dev/null; then
                    pass=0
                fi
            fi

        elif [ "$status" -eq 0 ]; then
            # Identical pairs must not have output files
            if [ -e "$output" ]; then
                pass=0
            fi
        else
            pass=0
        fi
    done

    # Check whether the output directory should exist
    if [ "$need_dir" -eq 1 ]; then
        if [ ! -d "$dir" ]; then
            pass=0
        fi
    else
        if [ -e "$dir" ]; then
            pass=0
        fi
    fi

    # Check for unexpected files in the output directory
    if [ -d "$dir" ]; then
        for output in "$dir"/*; do
            [ -e "$output" ] || continue

            name="${output##*/}"
            base="${name%Diff.txt}"

            if [ "$name" = "$base" ] || \
               [ ! -f "Testcase$i/${base}.1.txt" ] || \
               [ ! -f "Testcase$i/${base}.2.txt" ]; then
                pass=0
            fi
        done
    fi

    # Print the result for this Testcase
    if [ "$pass" -eq 1 ]; then
        echo "Testcase$i: PASS"
    else
        echo "Testcase$i: FAIL"
        all_pass=0
    fi
done

# Exit 0 only if every Testcase passes
if [ "$all_pass" -eq 1 ]; then
    exit 0
else
    exit 1
fi
