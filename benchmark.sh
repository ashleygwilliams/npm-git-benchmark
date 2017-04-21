dules="${base_dir}/libraries/${library}/node_modules"
    output_file="${output_folder}/${clean_cache}_${library}.csv"
    size_file="${output_folder}/size_${clean_cache}_${library}.csv"
    avg_file="${output_folder}/avg_${clean_cache}.csv"

    echo -n > $output_file

    command_to_run='npm install --cache-min 999999'
    command_to_clear_cache='npm cache clean'

    cd $directory

    if [ $clean_cache = 1 ]; then
        cache_text='with clean cache'
    else
        cache_text=''

        # Install once to generate cache
        rm -rf node_modules
        $command_to_run > /dev/null 2>&1
        dir_size=$(du -hs $node_modules)
        $dir_size >> $size_file
    fi

    echo '    '${tool} ${cache_text}

    # Run the given command [repeats] times
    for (( i = 1; i <= $repeats ; i++ ))
    do
        rm -rf node_modules

        # Clean cache
        if [ $clean_cache = 1 ]; then
            $command_to_clear_cache > /dev/null 2>&1
        fi

        # runs time function for the called script, output in a comma seperated
        # format output file specified with -o command and -a specifies append
        /usr/bin/time -f "%e %U %S" -o ${output_file} -a ${command_to_run} ${directory}

        # percentage completion
        p=$(( $i * 100 / $repeats))
        # indicator of progress
        l=$(seq -s "+" $i | sed 's/[0-9]//g')

        echo -ne '    '${l}' ('${p}'%) \r'
    done;

    echo -ne '\n'

    avg=$(awk '{ total += $1; count++ } END { print total/count }' $output_file)
    echo -n $avg' ' >> $avg_file

    cd $base_dir
}

show_results() {
    all_file=${output_folder}/avg.csv
    echo -n > $all_file

    avg_file_cc="${output_folder}/avg_1.csv"
    avg_file="${output_folder}/avg_0.csv"

    echo -n '_with_empty_cache ' >> $all_file
    cat $avg_file_cc >> $all_file
    echo >> $all_file
    echo -n '_with_all_cached ' >> $all_file
    cat $avg_file >> $all_file
    echo >> $all_file
    cat $size_file >> $all_file
    echo >> $all_file

    echo ''
    echo ' ----------------------------------------------------------------------------------- '
    echo ' -------------------------------- RESULTS (seconds) -------------------------------- '
    echo ' ----------------------------------------------------------------------------------- '

    awk 'BEGIN {printf("| %24s | %12s | %12s | %12s | %12s | \n" , " ", "'${libraries[0]}'", "'${libraries[1]}'", "'${libraries[2]}'", "'${libraries[3]}'")}
        {printf("| %24s | %12.3f | %12.3f | %12.3f | %12.3f | \n", $1, $2, $3, $4, $5)}' $all_file

    echo ' ----------------------------------------------------------------------------------- '
}

run_tests
show_results

echo $npm
