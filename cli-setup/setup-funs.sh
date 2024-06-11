declare_action_maps(){
	if [ $# -ne 1 ]; then
		echo "declare_action_maps: invalid number of arguments"
		exit
	fi
	
	local mn="$1$MAP_POSTFIX"
	local fn="$1$FUN_POSTFIX"

	declare -g -A "NEW_$mn"
	declare -g -A "DELETE_$mn"
	declare -g -A "EDIT_$mn"
	declare -g -A "PROFILE_$mn"
	declare -g -A "OPEN_$mn"
	declare -g -A "LIST_$mn"

	local -n M="$mn"
	local -n C="$fn"

	M["new"]="NEW_$mn"
	M["edit"]="EDIT_$mn"
	M["profile"]="PROFILE_$mn"
	M["delete"]="DELETE_$mn"
	M["open"]="OPEN_$mn"
	M["list"]="LIST_$mn"

	eval "${C["init"]}"
}

print_option(){
	local val_name
	local flags
	local text
	if [ $# -eq 2 ]; then
		flags="$1"	
		val_name=""
		text="$2"
	elif [ $# -ne 3 ]; then
		echo "print_option: invalid number of arguments"
		exit
	else 
		flags="$1"
		val_name="<$2>"
		text="$3"
	fi

	printf "\t%-20s%-30s%s\n" "$flags" "$val_name" "$text"	
}

declare_flag_map(){
	# $1 - MAP $2 - shortflag
	# $3 - longflag $4 - value_name $5 - help_text
	local check_fun="$6"
	local value="$7"
	local work_fun="$8"
	local mand="$9"
	local flags
	local help_msg

	local -n M="$1"

	if [ "$2" == "" ]; then
		flags="    --$3"
	else
		flags="-$2, --$3"
	fi

	if [ "$value_name" == "" ]; then 
		help_msg="$(print_option "$flags" "$5")"
	else
		help_msg="$(print_option "$flags" "$4" "$5")"
	fi

	M["-$2"]="${1}_${3}_map"
	M["--$3"]="${1}_${3}_map"
	declare -g -A "${1}_${3}_map"	
	local -n vm="${1}_${3}_map" # value_map
	
	vm["HELP_MSG"]="$help_msg"
	vm["CHECK_FUN"]="$check_fun"
	vm["WORK_FUN"]="$work_fun"
	vm["VALUE"]="$value"
	vm["MAND"]="$mand"

}

mg(){
	local -n vm="$1"

	echo -n "${vm["$2"]}"
}

ms(){
	local -n vm="$1"

	vm["$2"]="$3"
}

flag_map_run_check(){
	local -n vm="$1"
	
	eval "${vm["CHECK_FUN"]}"
}

flag_map_run_work(){
	local -n vm="$1"
	
	eval "${vm["WORK_FUN"]}"
}

flag_map_set_val(){	
	local -n vm="$1"

	vm["VALUE"]="$2"
}

get_mandatories(){
	local -n arr="$1"
	local -n M="$2"
	
	for key in ${!M[@]}; do
		if [ "$key" == "-setup" ] || [ "$key" == "-order" ]; then
			continue
		fi
		printf "%s\n" "${arr[@]}" | grep -qx "${M["$key"]}"

		if [ $? -ne 0 ] && [ "$(mg "${M["$key"]}" "MAND")" == "true" ]; then
			arr+=("${M["$key"]}")
		fi
	done

}


get_optionals(){
	local -n arr="$1"
	local -n M="$2"

	for key in "${!M[@]}"; do
		if [ "$key" == "-setup" ] || [ "$key" == "-order" ]; then
			continue
		fi
		local v=$(mg "${M["$key"]}" "MAND")
		printf "%s\n" "${a[@]}" | grep -qx "${M["$key"]}"
		if [ $? -ne 0 ] && [ "$v" == "false" ]; then
			a+=("${M["$key"]}")
		fi
	done

}
	
action_map_print_help(){
	local -n M="$1"

	for key in ${M["-order"]}; do
		printf "%s\n" "$(mg "${M["$key"]}" "HELP_MSG")" 
	done

}

check_mandatories(){
	local -n M="$1"

	for key in ${!M[@]}; do
		if [ "${key}" == "-setup" ] || [ "${key}" == "-order" ]; then
			continue
		fi
			
		local -n vm="${M[${key}]}"
		if [ "${vm["MAND"]}" == "true" ] && [ "${vm["VALUE"]}" == "*" ]; then
			echo "Did not supply a value for mandatory option: $key"
			action_map_print_help "$1"
			exit
		fi
	done
}

get_and_check_params(){
	local -n opt_arr="$1"
	local M_name="$2"
	local -n M="$2"
	shift 2
	local Mlist=$(printf "%s\n" "${!M[@]}")

	while [ $# -gt 0 ]; do
		echo -n "$Mlist" | grep -qx -- "$1"
		if [ $? -ne 0 ] || [ "$1" == "-setup" ] || [ "$1" == "-order" ]; then
			echo "Invalid parameter for type and action '$TYPE $ACTION': $1"
			exit
		fi
	
		local vm_name="${M["$1"]}"
		local -n vm="$vm_name"	
		printf "%s\n" "${opt_arr[@]}" | grep -qx "$vm_name"
		if [ $? -ne 0 ] && [ "${vm["MAND"]}" == "false" ]; then
			opt_arr+=("$vm_name")
		fi

		if [ "${vm["VALUE"]}" != "false" ] && [ "${vm["VALUE"]}" != "true" ]; then
			if [[ "$2" == -* ]]; then
				echo "Invalid value for flag '$1': $2"
				exit
			fi
			vm["VALUE"]="$2"

			shift
		else
			vm["VALUE"]="true"
		fi
		shift
		
		eval "${vm["CHECK_FUN"]}"
	done
	check_mandatories "$M_name"	
}

optional_jobs(){
	local -n opt_arr="$1"
	local -n M="$2"

	for key in ${opt_arr[@]}; do	
		local -n vm="$key"
		if [ "${vm["MAND"]}" == "false" ]; then
			eval "${vm["WORK_FUN"]}"	
		fi
	done
}

ws_run_command(){
	local ws="$1"
	local tmp_ws="$(i3-msg -t get_workspaces | jq | grep '"focused": true' -B 3 | head -1 | sed 's/\"num\": \([1-9]\),/\1/')"	
	if [ "$ws" == "" ]; then
		ws="$tmp_ws"	
	fi
	i3-msg "workspace --no-auto-back-and-forth $ws; exec \"$2\"" > /dev/null
}

list_dir(){
	if [ $2 -eq 1 ]; then
		printf "$3%s\n" $(ls $1)
	else
		for dir in $(printf "%s\n" $(ls $1)); do
			printf "$3%s\n" $dir
			list_dir "$1/$dir" $(( $2 - 1 )) "$3\\t"
		done
	fi
}
