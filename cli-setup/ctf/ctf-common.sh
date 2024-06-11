ctf_check_comp(){
	local -n M="$1"
	local comp_name=$(mg "${M["-n"]}" "VALUE")

	if [ "$2" == "true" ] && \
	   ( [ "$comp_name" == "*" ] || [ "$comp_name" == "-" ] ); then
		return
	fi


	CTF_COMP_PATH="$CTFS_DIR/$comp_name"	

	if [ ! -d "$CTF_COMP_PATH" ]; then
		echo "Specified ctf competition does not exist: $CTF_COMP_PATH"
		exit
	fi
}

ctf_check_cat(){
	local -n M="$1"
	local cat_name=$(mg "${M["-c"]}" "VALUE")

	if [ "$2" == "true" ] && \
	   ( [ "$cat_name" == "*" ] || [ "$cat_name" == "-" ] ); then
		return
	fi

	if [ -z ${CTF_COMP_PATH+x} ]; then 
		echo "Before specifying category you must specify the competition name" 
		exit
	fi	


	CTF_CAT_PATH="$CTF_COMP_PATH/$cat_name"	
	
	if [ ! -d "$CTF_CAT_PATH" ]; then
		echo "Specified ctf problem category does not exist: $CTF_CAT_PATH"
		exit
	fi
}

ctf_check_problem(){
	local -n M="$1"
	local prob_name=$(mg "${M["-p"]}" "VALUE")

	if [ "$2" == "true" ] && \
	   ( [ "$prob_name" == "*" ] || [ "$prob_name" == "-" ] ); then
		return
	fi

	if [ -z ${CTF_CAT_PATH+x} ]; then 
		echo "Before specifying problem you must specify the competition name" 
		exit
	fi	

	CTF_PROB_DIR="$CTF_CAT_PATH/$prob_name"	
	CTF_PROB_FILES_DIR="$CTF_PROB_DIR/files"
	
	if [ ! -d "$CTF_PROB_DIR" ]; then
		echo "Specified ctf problem does not exist: $CTF_PROB_DIR"
		exit
	fi
}

ctf_check_archive(){
	local -n M="$1"
	local arch="$(mg "${M["-a"]}" "VALUE")"	
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

ctf_check_files(){
	local -n M="$1"
	local FILES="$(mg "${M["-f"]}" "VALUE" )"
	local CTF_PROBLEM_FILES=(${FILES//,/ })
	for file in ${CTF_PROBLEM_FILES[@]}; do
		if [ ! -f "$file" ]; then
			echo "Specified ctf problem file does not exist: $file"
			exit
		fi
	done
}

ctf_check_dir(){
	local -n M="$1"
	local dir="$(mg "${M["-d"]}" "VALUE" )"
	if [ ! -d "$dir" ]; then
		echo "Specified ctf problem directory does not exist: $1"
		exit
	fi 
}


ctf_move_archive(){
	local -n M="$1"
	local arch="$(mg "${M["-a"]}" "VALUE")"	

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

ctf_move_files(){
	local -n M="$1"
	local FILES="$(mg "${M["-f"]}" "VALUE" )"
	local CTF_PROBLEM_FILES=(${FILES//,/ })

	echo "Copying problem files to problem dir.."
	for file in ${CTF_PROBLEM_FILES[@]}; do
		cp ${file} $CTF_PROB_FILES_DIR
	done
}

ctf_move_dir(){
	local -n M="$1"
	local dir="$(mg "${M["-d"]}" "VALUE" )"
	echo "Copying files from specified directory to problem dir..."
	cp $dir/* $CTF_PROB_FILES_DIR
}

ctf_open_nvim(){
	local -n M="$1"
	local work_space="$(mg "${M["--nvim"]}" "VALUE")"
	ws_run_command "$work_space" "alacritty -e nvim $CTF_PROB_DIR"
	sleep 0.2 # HACK -> try to find another solution
	ws_run_command "$work_space" "alacritty -e ranger --cmd='cd $CTF_PROB_DIR'"
	sleep 0.2
	i3-msg "layout toggle split" > /dev/null
	i3-msg "resize shrink height 20 px or 20 ppt" > /dev/null
}

ctf_new_open_ranger(){
	local -n M="$1"
	local work_space="$(mg "${M["--ranger"]}" "VALUE")"
	ws_run_command "$work_space" "alacritty -e ranger --cmd='cd $CTF_PROB_DIR'"
}
