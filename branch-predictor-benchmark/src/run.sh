#!/bin/bash

# Provided lists of values
design_list=("BranchBimodal" "BranchGlobal" "BranchGShare")
pht_size_list=("65536")
trace_list=("164.gzip/gzip.trace" "175.vpr/vpr.trace.bz2" "201.compress/compress.trace.bz2" "202.jess/jess.trace.bz2" "300.twolf/twolf.trace.bz2")

# Get the result file name as a parameter, defaulting to "run_result.txt"
result_file="run_result2.txt"

# Create or clear the result file
> "$result_file"

# Iterate through all combinations of values in the three lists
for value_c in "${design_list[@]}"; do
    for value_b in "${pht_size_list[@]}"; do
        sum=0
        count=0
        for value_a in "${trace_list[@]}"; do
            # Construct the make command
            command="make traces/${value_a}.sim PHT=${value_b} DESIGN=${value_c}"
            
            # Execute the make command and capture the output
            output=$(eval "$command" 2>&1)
            
            # Process the output as needed
            if [ $? -eq 0 ]; then
                echo "Output for $value_c, $value_b, $value_a:"
                filtered_output=$(echo "$output" | grep "accuracy")
                echo "$filtered_output"
                
                # Extract numbers from filtered_output and accumulate them
                while read -r line; do
                    number=$(echo "$line" | awk '{print $1}')  # Extract the number
                    sum=$(awk "BEGIN {print $sum + $number}")  # Accumulate the numbers
                    ((count++))  # Increment count for averaging
                done <<< "$filtered_output"
            else
                # If an error occurs during execution, handle it here
                echo "Error occurred for $value_c, $value_b, $value_a:"
                echo "$output"  # Print the error output
            fi
        done
        # Calculate average after inner loop
        average=$(awk "BEGIN {print $sum / $count}")
        average_line="Average accuracy for $value_c, PHT = $value_b: $average"
        echo "$average_line" >> "$result_file"  # Append to the result file
        echo "$average_line"  # Output the average line
    done
done
