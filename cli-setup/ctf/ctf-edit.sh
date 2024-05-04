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
		"ctf_edit_check_archive" \
		"-" "ctf_edit_move_archive" "false"

	declare_flag_map EDIT_CTF_MAP \
		"f" "files" "problem files" "Paths to problem files(comma separated)." \
		"ctf_edit_check_files" \
		"-" "ctf_edit_move_files" "false"
	

	declare_flag_map EDIT_CTF_MAP \
		"d" "directory" "problem dir" "Path to dir containing problem files. It will be moved."\
		"ctf_edit_check_dir" \
		"-" "ctf_edit_move_dir" "false"
	
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

	ctf_edit_check_comp
	ctf_edit_check_cat
	ctf_edit_check_problem	

	optional_jobs SELECTED_OPTIONALS EDIT_CTF_MAP
}

ctf_edit_check_archive(){
	local arch="$(mg "${EDIT_CTF_MAP["-a"]}" "VALUE")"	
	if [ -f "$arch" ]; then
		case "$arch" in 
			*.zip | *.tar.gz |*.tgz | *.tar | *.gz | *.tar.bz2)	;;
			*)	echo -e "Unsupported ctf problem archive extension.\nIt will not be Extracted: $arch"
				;;
			
		esac
		CTF_PROBLEM_ARCHIVE=$1
	else
		echo "Specified ctf problem archive does not exist: $arch"
		exit
	fi
}

ctf_edit_check_files(){
	local FILES="$(mg "${EDIT_CTF_MAP["-f"]}" "VALUE" )"
	local CTF_PROBLEM_FILES=(${FILES//,/ })
	for file in ${CTF_PROBLEM_FILES[@]}; do
		if [ ! -f "$file" ]; then
			echo "Specified ctf problem file does not exist: $file"
			exit
		fi
	done
}

ctf_edit_check_dir(){
	local dir="$(mg "${EDIT_CTF_MAP["-d"]}" "VALUE" )"
	if [ ! -d "$dir" ]; then
		echo "Specified ctf problem directory does not exist: $1"
		exit
	fi
 
}

ctf_edit_check_comp(){
	local comp_name=$(mg "${EDIT_CTF_MAP["-n"]}" "VALUE")
	CTF_COMP_PATH="$CTFS_DIR/$comp_name"	

	if [ ! -d "$CTF_COMP_PATH" ]; then
		echo "Specified ctf competition does not exist: $CTF_COMP_PATH"
		exit
	fi
}

ctf_edit_check_cat(){
	local cat_name=$(mg "${DELETE_CTF_MAP["-c"]}" "VALUE")
	if [ -z ${CTF_COMP_PATH+x} ]; then 
		echo "Before specifying category you must specify the competition name" 
		exit
	fi	

	CTF_CAT_PATH="$CTF_COMP_PATH/$cat_name"	
}

ctf_edit_check_problem(){
	local prob_name=$(mg "${DELETE_CTF_MAP["-p"]}" "VALUE")
	if [ -z ${CTF_CAT_PATH+x} ]; then 
		echo "Before specifying problem you must specify the competition name" 
		exit
	fi	

	CTF_PROB_PATH="$CTF_CAT_PATH/$prob_name"	
}

ctf_edit_move_archive(){
	local arch="$(mg "${EDIT_CTF_MAP["-a"]}" "VALUE")"	

	cp $arch $CTF_PROB_FILES_DIR
	echo "Copying archive with problem files to problem dir..."	
	echo -e "\t$arch"
	local CPA="$(basename $arch)"
	echo "Decrompessing given archive to files directory..."
	cd $CTF_PROB_FILES_DIR
	case $arch in
		*.zip)	7z x $CPA 
			;;
		*.tar.gz | *.tgz | *.tar | *.tar.bz2)
			tar -xf $CPA
			;;
		*.gz)	gunzip $CPA
			;;
		*)	;;
	esac
	cd -

}

ctf_edit_move_files(){
	local FILES="$(mg "${EDIT_CTF_MAP["-f"]}" "VALUE" )"
	local CTF_PROBLEM_FILES=(${FILES//,/ })

	echo "Copying problem files to problem dir.."
	for file in ${CTF_PROBLEM_FILES[@]}; do
		cp ${file} $CTF_PROB_FILES_DIR
	done
}

ctf_edit_move_dir(){
	local dir="$(mg "${EDIT_CTF_MAP["-d"]}" "VALUE" )"
	echo "Copying files from specified directory to problem dir..."
	cp $dir/* $CTF_PROB_FILES_DIR
}

edit_create_cpp_env(){	
	echo "Creating C++ environment in problem dir..."
}

edit_create_python_script(){
	echo "Creating python script in problem dir..."
	touch "$CTF_PROB_DIR/script.py"
}
