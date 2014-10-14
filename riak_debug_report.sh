#!/usr/bin/env bash

function load_debug_array {
	debug_array=($(find . -type d -name "*debug")) # load debug folders in to array
}

function find_keyword {
	echo "Searching for $2 in $1"
	for debug_node in ${debug_array[@]}
		do
			debug_output=$(find $debug_node -name $1 | grep -v ".info" | xargs grep --colour=always "$2")
			echo "${debug_node}: $debug_output"
		done
}

function diff_command_output {
	echo "Comparing $1"
	comp_node=0 # starting in array at 0
	node_count=${#debug_array[@]} # number of nodes in debug array
	let last_comp_node=node_count-1 # last array position is count -1
	while [ ${comp_node} -lt ${last_comp_node} ]; do
		#echo ${debug_array[$comp_node]}
		#echo ${debug_array[$last_comp_node]}
		find ${debug_array[$comp_node]} ${debug_array[$last_comp_node]} -type f -name "$1" | grep -v ".info" | xargs diff
		let comp_node=comp_node+1
	done
}

function multi_backend_data_root {
	find_keyword "app.config" "riak_kv_bitcask_backend"
	find_keyword "app.config" "data_root"
	riak_kv_bitcask_backend_count=$(find_keyword "app.config" "riak_kv_bitcask_backend" | wc -l)
	data_root_count=$(find_keyword "app.config" "data_root" | wc -l)
	echo $riak_kv_bitcask_backend_count
	echo $data_root_count
	if [ $data_root_count -le $riak_kv_bitcask_backend_count ]; then
		echo "I'm not sure data_roots are configured correctly"
	fi
}

function find_ulimit {
	for debug_node in ${debug_array[@]}
		do
			debug_output=$(find $debug_node -name "*.conf" | xargs grep "nofile" | egrep "hard|soft")
			echo "${debug_node}: $debug_output"
		done
}

function check_basic_kernel_network_tuning {
	find_keyword "sysctl" "vm.swappiness = 0"
	find_keyword "sysctl" "net.ipv4.tcp_max_syn_backlog = 40000"
	find_keyword "sysctl" "net.core.somaxconn=40000"
	find_keyword "sysctl" "net.ipv4.tcp_sack = 1"
	find_keyword "sysctl" "net.ipv4.tcp_window_scaling = 1"
	find_keyword "sysctl" "net.ipv4.tcp_fin_timeout = 15"
	find_keyword "sysctl" "net.ipv4.tcp_keepalive_intvl = 30"
	find_keyword "sysctl" "net.ipv4.tcp_tw_reuse = 1"
	find_keyword "sysctl" "net.ipv4.tcp_moderate_rcvbuf = 1"
}

function check_10Gbps_network_tuning {
	find_keyword "sysctl" "net.core.rmem_max = 134217728"
	find_keyword "sysctl" "net.core.wmem_max = 134217728"
	find_keyword "sysctl" "net.ipv4.tcp_mem = 134217728	134217728	134217728"
	find_keyword "sysctl" "net.ipv4.tcp_rmem = 4096	277750	134217728"
	find_keyword "sysctl" "net.ipv4.tcp_wmem = 4096	277750	134217728"
	find_keyword "sysctl" "net.core.netdev_max_backlog = 300000"
}



load_debug_array

multi_backend_data_root

diff_command_output riak_member_status
diff_command_output riak_ping
diff_command_output riak_ring_status
diff_command_output riak_version

# find_keyword "app.config" "allow_mult"

find_keyword "app.config" "ring_creation_size"

# find_ulimit

# find_keyword "riak_version" ""
# find_keyword "riak_status" "version"
# find_keyword "free" ""
# find_keyword "riak_member_status" ""

find_keyword "mount" "noatime,barrier=0,data=writeback"

## vm.args checks

find_keyword "vm.args" "^+zdbbl"
find_keyword "vm.args" "^+swt very_low"
find_keyword "vm.args" "^+sfwi 500"

## sysctl checks

find_keyword "sysctl" "net.ipv4.tcp_keepalive_intvl = 30"


check_basic_kernel_network_tuning
check_10Gbps_network_tuning




