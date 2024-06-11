ctf_new_init(){
	NEW_CTF_MAP["-setup"]="ctf_new_setup"
	NEW_CTF_MAP["-order"]=$(printf "%s\n" "-n" "-c" "-p" "-a" "-f" "-d" "--cpp" "--py" "--nvim" "--ranger")

	declare_flag_map NEW_CTF_MAP \
		"n" "name" "ctf name" "Name of the CTF competition. (Mandatory)" \
		'ctf_new_check_name "-n" "CTF competition name"' \
		"*" "" "true" 

	declare_flag_map NEW_CTF_MAP \
		"c" "category" "problem category" "Category of the problem. (Mandatory)" \
		'ctf_new_check_name "-c" "CTF category name"' \
		"*" "" "true"	

	declare_flag_map NEW_CTF_MAP \
		"a" "archive" "problem archive" "Path to archive containing problem files. It will be moved and extrated." \
		"ctf_check_archive NEW_CTF_MAP" \
		"-" "ctf_move_archive NEW_CTF_MAP" "false"

	declare_flag_map NEW_CTF_MAP \
		"f" "files" "problem files" "Paths to problem files(comma separated)." \
		"ctf_check_files NEW_CTF_MAP" \
		"-" "ctf_move_files NEW_CTF_MAP" "false"
	

	declare_flag_map NEW_CTF_MAP \
		"d" "directory" "problem dir" "Path to dir containing problem files. It will be moved."\
		"ctf_check_dir NEW_CTF_MAP" \
		"-" "ctf_move_dir NEW_CTF_MAP" "false"
	
	declare_flag_map NEW_CTF_MAP \
		"" "cpp" "" "Create only files folder no env needed." \
		"" \
		"false" "create_cpp_env" "false" 
	
	declare_flag_map NEW_CTF_MAP \
		"" "py" "" "Create python script file." \
		"" \
		"false" "create_python_script" "false"

	declare_flag_map NEW_CTF_MAP \
		"p" "problem" "problem name" "set ctf problem name to create. (mandatory)" \
		'ctf_new_check_name "-p" "CTF problem name"' \
		"*"  "" "true"

	declare_flag_map NEW_CTF_MAP \
		"" "nvim" "workspace" "Open Nvim in directory of a problem in specified i3 workspace (default tmp workspace)." \
		"" \
		"-" "ctf_open_nvim NEW_CTF_MAP" "false"
	
	declare_flag_map NEW_CTF_MAP \
		"" "ranger" "workspace" "Open Ranger in directory of a problem in specified i3 workspace. (default tmp workspace)" \
		"" \
		"-" "ctf_open_ranger NEW_CTF_MAP" "false"
}

ctf_new_setup(){
	local -a SELECTED_OPTIONALS
	get_and_check_params SELECTED_OPTIONALS NEW_CTF_MAP $@

	ctf_new_create
	ctf_new_create_category
	ctf_new_create_problem
	
	optional_jobs SELECTED_OPTIONALS NEW_CTF_MAP
}

# CHECK FUNCTIONS

ctf_new_check_name(){
	local name="$(mg "${NEW_CTF_MAP["$1"]}" "VALUE" )"
	name_validity "$name" "$2"	
}

# JOB FUNSTIONS

ctf_new_create(){
	local comp_name="$(mg "${NEW_CTF_MAP["-n"]}" "VALUE" )" 
	CTF_COMP_DIR="$CTFS_DIR/${comp_name}"

	if [ ! -d "$CTF_COMP_DIR" ]; then
		echo "Creating directory for CTF competition '$comp_name'..." 
		echo -e "\t$CTF_COMP_DIR"
		mkdir "$CTF_COMP_DIR"
	fi
}

ctf_new_create_category(){
	local cat_name="$(mg "${NEW_CTF_MAP["-c"]}" "VALUE" )"
	CTF_CAT_DIR="$CTF_COMP_DIR/${cat_name}"

	if [ ! -d "$CTF_CAT_DIR" ]; then
		echo "Creating directory for category '$cat_name'..." 
		echo -e "\t$CTF_CAT_DIR"
		mkdir "$CTF_CAT_DIR"
	fi
}


ctf_new_create_problem(){
	local prob_name="$(mg "${NEW_CTF_MAP["-p"]}" "VALUE" )"
	CTF_PROB_DIR="$CTF_CAT_DIR/${prob_name}"
	CTF_PROB_FILES_DIR="$CTF_PROB_DIR/files"
	if [ ! -d "$CTF_PROB_DIR" ]; then
		echo "Creating directory for problem '$prob_name'..."
		echo -e "\t$CTF_PROB_DIR"
		mkdir "$CTF_PROB_DIR"
		echo "Creating files directory for problem '$prob_name'..." 
		echo -e "\t$CTF_PROB_FILES_DIR"
		mkdir "$CTF_PROB_FILES_DIR" 
	else
		echo "Problem for given competition with name '$prob_name' already exists!"
		exit
	fi
}


create_cpp_env(){	
	echo "Creating C++ environment in problem dir..."
}

create_python_script(){
	echo "Creating python script in problem dir..."
	touch "$CTF_PROB_DIR/script.py"
}
