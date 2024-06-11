ctf_list_init(){
	LIST_CTF_MAP["-setup"]="ctf_list_setup"
	LIST_CTF_MAP["-order"]=$(printf "%s\n" "-n" "-c" "-a" )
	declare_flag_map LIST_CTF_MAP \
		"n" "name" "ctf name" "Name of the CTF competition." \
		'' \
		"-" "" "false" 

	declare_flag_map LIST_CTF_MAP \
		"c" "category" "problem category" "Category of the problem." \
		'' \
		"-" "" "false"	

	declare_flag_map LIST_CTF_MAP \
		"a" "all" "" "Can be specified to list all subpaths of a competition or a category." \
		"" "false" "" "false"
}


ctf_list_setup(){
	local -a SELECTED_OPTIONALS
	get_and_check_params SELECTED_OPTIONALS LIST_CTF_MAP $@
	
	ctf_check_comp LIST_CTF_MAP "true"
	ctf_check_cat LIST_CTF_MAP "true"

	ctf_list

	optional_jobs SELECTED_OPTIONALS LIST_CTF_MAP
}

ctf_list(){
	local all_val="$(mg ${LIST_CTF_MAP["-a"]} "VALUE")"
	if [ ! -z ${CTF_CAT_PATH+x} ]; then 
		list_dir "${CTF_CAT_PATH}" 1
		exit
	fi	

	local dir="$CTFS_DIR"
	local depth=1

	if [ "$all_val" == "true" ]; then
		depth=3
	fi

	if [ ! -z ${CTF_COMP_PATH+x} ]; then
		if [ "$all_val" == "true" ]; then
			depth=2
		else
			depth=1
		fi
		dir="${CTF_COMP_PATH}"
	fi

	list_dir "$dir" $depth
}
