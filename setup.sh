#!/bin/bash

PROBLEM_FIELD=general
PROBLEM_DIR_PREFIX=""
TO_MAIN="\\.\\.\\/\\.\\.\\/\\.\\.\\/"

MODE="Normal"
CTF_NAME_EXISTS=0
CTF_CATEGORY_EXISTS=0
CTF_TO_MAIN="\\.\\.\\/\\.\\.\\/\\.\\.\\/\\.\\.\\/\\.\\.\\/"

CTF_PROBLEM_ARCHIVE=""
CTF_PROBLEM_DIR=""
CTF_PROBLEM_FILES=""
CTF_CREATE_SCRIPT_FILE=0
CTF_NO_CPP_ENV=0

FLAG_NUM=0

name_validity(){
	if [[ $1 =~  "/" ]]; then
		echo "$2 cannot contain '/' character!"
		exit
	fi
}

print_usage(){
	echo "Usage:" 
	echo -e "\tsetup.sh <options> <exercise_name>"
	echo "Normal Mode Options: "
	echo -e "\t-f <problem field>\tSpecify the field from which is problem."
	echo -e "\t-c\tCTF mode. If using ctf mode this flag must be specified first."
	echo "CTF Mode Options:"
	echo -e "\t-n <ctf name>\tName of the CTF competition."
	echo -e "\t-t <problem category>\tCategory of the problem."
	echo -e "\t-d <problem dir>\tPath to dir containing problem files. It will be moved."
	echo -e "\t-a <problem files>\tPath to archive containing problem files. It will be moved and extrated."
	echo -e "\t-f <problem files>\tPaths to problem files(comma separated)."
	echo -e "\t-o <problem files>\tCreate only files folder no env needed."
	echo -e "\t-s <problem files>\tCreate python script file."
}

set_ctf_mode(){
	if [ $FLAG_NUM -eq 0 ]; then
		MODE="CTF"
		PROBLEM_FIELD=ctfs
		TO_MAIN=${CTF_TO_MAIN}
		local OPTIND=1
		while getopts 'son:t:d:a:f:' flag; do
			case "${flag}" in
				n)	set_ctf_name ${OPTARG}
					;;
				t)	set_ctf_category ${OPTARG}
					;;
				d)	set_ctf_problem_dir ${OPTARG}
					;;
				a)	set_ctf_problem_archive ${OPTARG}
					;;
				f)	set_ctf_problem_files ${OPTARG}
					;;
				o)	set_ctf_no_env_files
					;;
				s)	set_ctf_create_script_file
					;;
			esac
		done
		
		if [ $CTF_NAME_EXISTS -ne 1 ]; then
			echo "No CTF competition name specified!"
			exit
		
		fi

		if [ $CTF_CATEGORY_EXISTS -ne 1 ]; then
			echo "No CTF problem category specified!"
			exit
		fi
		
		PROBLEM_DIR_PREFIX=$CTF_NAME/$CTF_CATEGORY/
		FLAG_NUM=$((${FLAG_NUM}+${OPTIND}-1))
	else
		echo "Mode flag must be the first."
		exit	
	fi
}

set_ctf_create_script_file(){
	CTF_CREATE_SCRIPT_FILE=1

}

set_ctf_no_env_files(){
	CTF_NO_CPP_ENV=1
}

set_ctf_name(){
	name_validity $1 "CTF competition name"
	CTF_NAME_EXISTS=1
	CTF_NAME=$1
}

set_ctf_category(){
	name_validity $1 "CTF category name"
	CTF_CATEGORY_EXISTS=1
	CTF_CATEGORY=$1
}

set_ctf_problem_dir(){
	if [ -d "$1" ]; then
		CTF_PROBLEM_DIR=$1
	else
		echo "Specified ctf problem directory does not exist: $1"
		exit
	fi
}

set_ctf_problem_archive(){
	if [ -f "$1" ]; then
		case "$1" in 
			*.zip | *.tar.gz |*.tgz | *.tar | *.gz | *.tar.bz2)	;;
			*)	echo -e "Unsupported ctf problem archive extension.\nIt will not be Extracted: $1"
				;;
			
		esac
		CTF_PROBLEM_ARCHIVE=$1
	else
		echo "Specified ctf problem archive does not exist: $1"
		exit
	fi
		
}

set_ctf_problem_files(){
	CTF_PROBLEM_FILES=(${1//,/ })
	for file in ${CTF_PROBLEM_FILES[@]}; do
		if [ ! -f "$file" ]; then
			echo "Specified ctf problem file does not exist: $file"
			exit
		fi
	done
}

field_param(){
	name_validity $1 "Problem field name"
	PROBLEM_FIELD=$1
}

init_ctf(){
	local PROBLEM_FILES_DIR=$PROBLEM_DIR/files

	mkdir $PROBLEM_FILES_DIR

	if [[ "$CTF_PROBLEM_FILES" != "" ]]; then
		for file in ${CTF_PROBLEM_FILES[@]}; do
			mv ${file} $PROBLEM_FILES_DIR
		done
	fi

	if [ "$CTF_PROBLEM_ARCHIVE" != "" ]; then
		mv $CTF_PROBLEM_ARCHIVE $PROBLEM_FILES_DIR
		local CPA="$(basename $CTF_PROBLEM_ARCHIVE)"
		cd $PROBLEM_FILES_DIR
		case $CTF_PROBLEM_ARCHIVE in
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
	fi

	if [ "$CTF_PROBLEM_DIR" != "" ]; then
		mv $CTF_PROBLEM_DIR/* $PROBLEM_FILES_DIR
	fi

	if [ $CTF_CREATE_SCRIPT_FILE -eq 1 ]; then
		touch "$PROBLEM_DIR/script.py"
	fi

	if [ $CTF_NO_CPP_ENV -eq 1 ]; then
		echo "Successfully initialized project for problem $1 in directory $PROBLEM_DIR"
		exit
	fi
}
	
#### MAIN ####

while getopts cf: flag
do
	case "${flag}" in
		f)	field_param ${OPTARG}
			;;
		c)	shift
			OPTIND=$((${OPTIND}-1))
			set_ctf_mode $@
			break
			;;
	esac
done

FLAG_NUM=$((${FLAG_NUM}+${OPTIND}-1))
shift ${FLAG_NUM}

PROBLEM_DIR=problems/$PROBLEM_FIELD/${PROBLEM_DIR_PREFIX}${1}


if [ $# -ne 1 ]; then
	echo "Invalid number of non-option arguments. Number: $#"
	print_usage
fi

name_validity $1 "Program"

if [ -d "$PWD/$PROBLEM_DIR" ]; then
	echo "Excercise with that name is already created!"
	exit
fi 

mkdir -p $PROBLEM_DIR


case "$MODE" in
	CTF)	init_ctf	
		;;
	*)	;;
esac

cp -r setup_files/* $PROBLEM_DIR
mv $PROBLEM_DIR/makefile_template $PROBLEM_DIR/makefile

sed -i -e "s/<to_main>/${TO_MAIN}/g" $PROBLEM_DIR/compile_flags.txt
sed -i -e "s/<to_main>/${TO_MAIN}/g" $PROBLEM_DIR/makefile
sed -i -e "s/program-name/$1/g" $PROBLEM_DIR/makefile

echo "Successfully initialized project for problem $1 in directory $PROBLEM_DIR"
