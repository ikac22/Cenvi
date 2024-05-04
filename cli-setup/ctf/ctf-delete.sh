ctf_delete_init(){
	DELETE_CTF_MAP["-setup"]="ctf_delete_setup"
	DELETE_CTF_MAP["-order"]=$(printf "%s\n" "-n" "-c" "-p" "-a" )

	declare_flag_map DELETE_CTF_MAP \
		"n" "name" "ctf name" "Name of the CTF competition. (Mandatory)" \
		'' \
		"*" "" "true" 

	declare_flag_map DELETE_CTF_MAP \
		"c" "category" "problem category" "Category of the problem. (Mandatory)" \
		'' \
		"*" "" "true"	

	declare_flag_map DELETE_CTF_MAP \
		"p" "problem" "problem name" "set ctf problem name to create. (Mandatory)" \
		'' \
		"*"  "" "true"

	declare_flag_map DELETE_CTF_MAP \
		"a" "all" "all files" "Can be specified with competition name only or with competition name and category to delete all files within specified competition/category" \
		"ctf_delete_unmand" "false" "" "false"
}

ctf_delete_setup(){
	local -a SELECTED_OPTIONALS
	get_and_check_params SELECTED_OPTIONALS DELETE_CTF_MAP $@	

	ctf_delete_name
	ctf_delete_category
	ctf_delete_all

	ctf_delete_problem
}


ctf_delete_all(){
	local all_val=$(mg "${DELETE_CTF_MAP["-a"]}" "VALUE")

	if [ "$all_val" == "false"  ]; then
		return
	fi

	echo "Deleting $DELETE_PATH..."

	rm -rf "$DELETE_PATH"
	exit
}

ctf_delete_name(){	
	local comp_name=$(mg "${DELETE_CTF_MAP["-n"]}" "VALUE")

	if [ "$comp_name" == "*"  ]; then
		return
	fi

	CTF_COMP_PATH="$CTFS_DIR/$comp_name"	

	if [ ! -d "$CTF_COMP_PATH" ]; then
		echo "Specified ctf competition does not exist: $CTF_COMP_PATH"
		exit
	fi

	DELETE_PATH=${CTF_COMP_PATH}
}

ctf_delete_category(){
	local cat_name=$(mg "${DELETE_CTF_MAP["-c"]}" "VALUE")
	
	if [ "$cat_name" == "*"  ]; then
		return
	fi

	if [ -z ${CTF_COMP_PATH+x} ]; then 
		echo "Before specifying category you must specify the competition name" 
		exit
	fi	

	CTF_CAT_PATH="$CTF_COMP_PATH/$cat_name"	

	if [ ! -d "$CTF_CAT_PATH" ]; then
		echo "Specified ctf category does not exist: $CTF_COMP_PATH"
		exit
	fi

	DELETE_PATH=${CTF_CAT_PATH}
}

ctf_delete_problem(){
	local prob_name=$(mg "${DELETE_CTF_MAP["-p"]}" "VALUE")
	
	if [ "$prob_name" == "*"  ]; then
		return
	fi

	if [ -z ${CTF_CAT_PATH+x} ]; then 
		echo "Before specifying problem you must specify the competition name" 
		exit
	fi	

	CTF_PROB_PATH="$CTF_CAT_PATH/$prob_name"	

	if [ ! -d "$CTF_PROB_PATH" ]; then
		echo "Specified ctf problem does not exist: $CTF_PROB_PATH"
		exit
	fi

	DELETE_PATH=${CTF_PROB_PATH}
	echo "Deleting problem '$prob_name' on path: $DELETE_PATH"
	rm -rf "$DELETE_PATH"
}

ctf_delete_unmand(){
	ms "${DELETE_CTF_MAP["-p"]}" "MAND" "false"
	ms "${DELETE_CTF_MAP["-c"]}" "MAND" "false"
}
