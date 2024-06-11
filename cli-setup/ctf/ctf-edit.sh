ctf_edit_init(){
	EDIT_CTF_MAP["-setup"]="ctf_edit_setup"
	EDIT_CTF_MAP["-order"]=$(printf "%s\n" "-n" "-c" "-p" "-a" "-f" "-d" "--cpp" "--py")

	declare_flag_map EDIT_CTF_MAP \
		"n" "name" "ctf name" "Name of the CTF competition. (Mandatory)" \
		'' \
		"*" "" "true" 

	declare_flag_map EDIT_CTF_MAP \
		"c" "category" "problem category" "Category of the problem. (Mandatory)" \
		'' \
		"*" "" "true"	

	declare_flag_map EDIT_CTF_MAP \
		"a" "archive" "problem archive" "Path to archive containing problem files. It will be moved and extrated." \
		"ctf_check_archive EDIT_CTF_MAP" \
		"-" "ctf_move_archive EDIT_CTF_MAP" "false"

	declare_flag_map EDIT_CTF_MAP \
		"f" "files" "problem files" "Paths to problem files(comma separated)." \
		"ctf_check_files EDIT_CTF_MAP" \
		"-" "ctf_move_files EDIT_CTF_MAP" "false"
	

	declare_flag_map EDIT_CTF_MAP \
		"d" "directory" "problem dir" "Path to dir containing problem files. It will be moved."\
		"ctf_check_dir EDIT_CTF_MAP" \
		"-" "ctf_move_dir EDIT_CTF_MAP" "false"
	
	declare_flag_map EDIT_CTF_MAP \
		"" "cpp" "" "Create only files folder no env needed." \
		"" \
		"false" "edit_create_cpp_env" "false" 
	
	declare_flag_map EDIT_CTF_MAP \
		"" "py" "" "Create python script file." \
		"" \
		"false" "edit_create_python_script" "false"

	declare_flag_map EDIT_CTF_MAP \
		"p" "problem" "problem name" "set ctf problem name to create. (mandatory)" \
		'' \
		"*"  "" "true"
}

ctf_edit_setup(){
	local -a SELECTED_OPTIONALS
	get_and_check_params SELECTED_OPTIONALS EDIT_CTF_MAP $@

	ctf_check_comp EDIT_CTF_MAP "false"
	ctf_check_cat EDIT_CTF_MAP "false"
	ctf_check_problem EDIT_CTF_MAP "false"

	optional_jobs SELECTED_OPTIONALS EDIT_CTF_MAP
}

edit_create_cpp_env(){	
	echo "Creating C++ environment in problem dir..."
}

edit_create_python_script(){
	echo "Creating python script in problem dir..."
	touch "$CTF_PROB_DIR/script.py"
}
