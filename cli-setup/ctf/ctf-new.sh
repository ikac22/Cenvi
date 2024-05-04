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
		"ctf_new_check_archive" \
		"-" "ctf_new_move_archive" "false"

	declare_flag_map NEW_CTF_MAP \
		"f" "files" "problem files" "Paths to problem files(comma separated)." \
		"ctf_new_check_files" \
		"-" "ctf_new_move_files" "false"
	

	declare_flag_map NEW_CTF_MAP \
		"d" "directory" "problem dir" "Path to dir containing problem files. It will be moved."\
		"ctf_new_check_dir" \
		"-" "ctf_new_move_dir" "false"
	
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
		"" "nvim" "open nvim" "Open Nvim in directory of a problem." \
		"" \
		"false" "ctf_new_open_nvim" "false"
	
	declare_flag_map NEW_CTF_MAP \
		"" "ranger" "open ranger" "Open Ranger in directory of a problem." \
		"" \
		"false" "ctf_new_open_ranger" "false"
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


ctf_new_check_archive(){
	local arch="$(mg "${NEW_CTF_MAP["-a"]}" "VALUE")"	
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

ctf_new_check_files(){
	local FILES="$(mg "${NEW_CTF_MAP["-f"]}" "VALUE" )"
	local CTF_PROBLEM_FILES=(${FILES//,/ })
	for file in ${CTF_PROBLEM_FILES[@]}; do
		if [ ! -f "$file" ]; then
			echo "Specified ctf problem file does not exist: $file"
			exit
		fi
	done
}

ctf_new_check_dir(){
	local dir="$(mg "${NEW_CTF_MAP["-d"]}" "VALUE" )"
	if [ ! -d "$dir" ]; then
		echo "Specified ctf problem directory does not exist: $1"
		exit
	fi
 
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

ctf_new_move_archive(){

	local arch="$(mg "${NEW_CTF_MAP["-a"]}" "VALUE")"	

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

ctf_new_move_files(){
	local FILES="$(mg "${NEW_CTF_MAP["-f"]}" "VALUE" )"
	local CTF_PROBLEM_FILES=(${FILES//,/ })

	echo "Copying problem files to problem dir.."
	for file in ${CTF_PROBLEM_FILES[@]}; do
		cp ${file} $CTF_PROB_FILES_DIR
	done
}

ctf_new_move_dir(){
	local dir="$(mg "${NEW_CTF_MAP["-d"]}" "VALUE" )"
	echo "Copying files from specified directory to problem dir..."
	cp $dir/* $CTF_PROB_FILES_DIR
}

create_cpp_env(){	
	echo "Creating C++ environment in problem dir..."
}

create_python_script(){
	echo "Creating python script in problem dir..."
	touch "$CTF_PROB_DIR/script.py"
}
