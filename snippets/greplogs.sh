unpack_riak_debugs () {
    mkdir -p compressed
    for file in `ls *riak-debug.tar.gz`
    do
        tar xzf $file
        mv $file compressed
    done

    for file in `ls -1 | grep riak-debug`
    do
        cd "$file/logs/platform_log_dir/"
        greplogs
        cd ../

        for lvldbfolder in `ls -1 | grep leveldb`
        do
            cd "$lvldbfolder"
            grepleveldblogs
            cd ../
        done

        cd ../../
    done
}


dump_log_max_min_date () {
    # first argument is the summary file to write the results to
    local summary=$1
    shift
    local max=""
    local min="9999-99-99 99:99:99.999"

    while [ -n "$1" ]; do
        local filemin=`head -1 $1 | grep -oEi "^(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}.\d{3})"`
        local filemax=`tail -1 $1 | grep -oEi "^(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}.\d{3})"`
        if [[ "$max" < "$filemax" ]]; then max=$filemax; fi
        if [[ "$filemin" < "$min" ]]; then min=$filemin; fi
        shift
    done

    echo "Console logs cover ${min} to ${max}" >> $summary
}

grep_dump () {
    # first argument is the filename to hold the command output
    out=$1
    shift

    # second argument is the summary file
    local summary=$1
    shift

    # third argument is the string to grep for
    grepstr=$1
    shift

    touch $out

    # remainder arguements are the files to grep across (use a glob)
    while [ -n "$1" ]; do
        local output=`grep -E "$grepstr" $1`
        if [ -n "$output" ]; then
            echo "Matches in ${1}:" >> $out
            echo "${output}" >> $out
            echo "" >> $out
        fi 
        shift
    done

    count=`wc -l $out` 
    echo "$count found" >> $summary

    # remove any zero-length output files to reduce noise
    if [[ ! -s $out ]]; then 
        rm $out; 
    fi
}

greplogs () {
	consolelogs=`pwd`/console.log*
	mkdir -p summary
	cd summary
	touch summary
	summary=summary

	dump_log_max_min_date $summary $consolelogs

    # System Errors
    grep_dump "emfile" $summary "emfile" $consolelogs

    # Erlang Errors
    grep_dump "system_memory_high_watermark" $summary "system_memory_high_watermark" $consolelogs
    grep_dump "erlang_eaddrinuse" $summary "{error,eaddrinuse}" $consolelogs
    grep_dump "erlang_eaddrnotavail" $summary "eaddrnotavail" $consolelogs
    grep_dump "erlang_badarg" $summary "badarg" $consolelogs
    grep_dump "erlang_noproc" $summary "noproc" $consolelogs
    grep_dump "erlang_conn_refused" $summary "\{error,econnrefused\}" $consolelogs

    # Riak Core Errors
    grep_dump "core_insufficient_vnodes_available" $summary "insufficient_vnodes_available" $consolelogs
    grep_dump "core_invalid_ring_state_dir" $summary "invalid_ring_state_dir" $consolelogs
    grep_dump "core_not_reachable" $summary "not_reachable" $consolelogs

    # Riak KV Errors
    grep_dump "kv_all_nodes_down" $summary "all_nodes_down" $consolelogs
    grep_dump "kv_local_put_failed" $summary "local_put_failed" $consolelogs
    grep_dump "kv_precommit_fail" $summary "precommit_fail" $consolelogs

    # Other Errors
    grep_dump "busy_dist_port" $summary "busy_dist_port" $consolelogs

    cd ../

    view_summary $summary
}

view_summary () {
    summary_count=`ls -1 $1 | wc -l`
    if [ $summary_count -gt 1 ]
    then
        open $1
    fi
    open $1/summary
}

grepleveldblogs () {
    levellogs=`pwd`/*/LOG
    mkdir -p summary
    cd summary
    touch summary
    summary=summary

    grep_dump "leveldb_compaction_errors" $summary "Compaction error" $leveldblogs

    cd ../

    view_summary $summary

}