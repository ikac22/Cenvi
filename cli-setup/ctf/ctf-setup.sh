declare -A CTF_MAP
declare -A CTF_FUN

CTF_FUN["init"]="ctf_init"
CTF_MAP["-h"]="print_ctf_help"
CTFS_DIR="$PROJECT_MANAGER_PROBLEMS/ctfs"

source "$PROJECT_MANAGER_SCRIPTS/ctf/ctf-new.sh"
source "$PROJECT_MANAGER_SCRIPTS/ctf/ctf-delete.sh"
source "$PROJECT_MANAGER_SCRIPTS/ctf/ctf-profile.sh"
source "$PROJECT_MANAGER_SCRIPTS/ctf/ctf-edit.sh"

print_ctf_help(){
	echo "ctf new:"
	action_map_print_help NEW_CTF_MAP

	echo "ctf delete:"
	action_map_print_help DELETE_CTF_MAP

	echo "ctf edit:"
	# action_map_print_help EDIT_CTF_MAP

	echo "ctf profile:"
	# action_map_print_help PROFILE_CTF_MAP

	echo "ctf open"
	# action_map_print_help OPEN_CTF_MAP
}

ctf_init(){
	# NEW_CTF_MAP init
	ctf_new_init

	# DELETE_CTF_MAP init
	ctf_delete_init

	# EDIT_CTF_MAP init
	
	# PROFILE_CTF_MAP init
}
