#!/bin/bash

PROJECT_MANAGER_DIR=/home/ikac/shared/projects/Coding-Problem-Environment
PROJECT_MANAGER_PROBLEMS="$PROJECT_MANAGER_DIR/problems"
PROJECT_MANAGER_SCRIPTS="$PROJECT_MANAGER_DIR/cli-setup"

declare -A TYPE_MAP
FUN_POSTFIX="_FUN"
MAP_POSTFIX="_MAP"

TYPE_MAP["ctf"]="CTF"
TYPE_MAP["coding"]="CODING"
TYPE_MAP["project"]="PROJECT"
TYPE=""
ACTION=""

source "$PROJECT_MANAGER_SCRIPTS/setup-funs.sh"
source "$PROJECT_MANAGER_SCRIPTS/ctf/ctf-setup.sh"

print_usage(){
	echo "Usage:" 
	echo -e "\tsetup.sh <type> <action> <options>"
	echo
	echo "Type choose: "
	print_option "ctf" "action" "Do an action on ctf excercise."
	print_option "project" "action" "Do an action on project."
	print_option "coding" "action" "DO an action on coding."
	echo
	echo -e "\tActions: new, delete, edit, open, profile"
	echo
	echo "For specific help message use 'setup.sh <type> -h'"
}

type_check(){
	if [ "$TYPE" == "-h" ]; then
		print_usage
		exit
	fi

	printf "%s\n" "${!TYPE_MAP[@]}" | grep -qx "$TYPE"
	if [ $? -ne 0 ] || [ "$TYPE" == "" ]; then
		echo "Invalid type specified: $TYPE"
		print_usage
		exit
	fi
}

action_check(){
	local -n AM="${TYPE_MAP[$TYPE]}$MAP_POSTFIX"
	printf "%s\n" "${!AM[@]}" | grep -qx "$ACTION"
	if [ $? -ne 0 ] || [ "$ACTION" == "" ]; then
		echo "Invalid action specified for type '$TYPE': $ACTION"
		eval "${AM["-h"]}"
		exit
	fi
}

name_validity(){
	if [[ $1 =~  "/" ]]; then
		echo "$2 cannot contain '/' character!"
		exit
	fi
}


init(){
	for key in ${!TYPE_MAP[@]}; do
		declare_action_maps "${TYPE_MAP[${key}]}"
	done
}

main(){
	init

	TYPE=$1
	ACTION=$2
	shift 2

	type_check
	action_check

	local -n AM="${TYPE_MAP["$TYPE"]}$MAP_POSTFIX"
	local -n SAM="${AM["$ACTION"]}"
	
	eval ${SAM["-setup"]} $@
}

main $@

exit
