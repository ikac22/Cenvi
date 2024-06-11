ctf_open_init(){
	OPEN_CTF_MAP["-setup"]="ctf_open_setup"
	OPEN_CTF_MAP["-order"]=$(printf "%s\n" "-n" "-c" "-p" "--nvim" "--ranger")
	
	declare_flag_map OPEN_CTF_MAP \
		"n" "name" "ctf name" "Name of the CTF competition. (Mandatory)" \
		'' \
		"*" "" "true" 

	declare_flag_map OPEN_CTF_MAP \
		"c" "category" "problem category" "Category of the problem. (Mandatory)" \
		'' \
		"*" "" "true"	

	declare_flag_map OPEN_CTF_MAP \
		"p" "problem" "problem name" "Set ctf problem name to create. (Mandatory)" \
		'' \
		"*"  "" "true"

	declare_flag_map OPEN_CTF_MAP \
		"" "nvim" "workspace" "Open Nvim in directory of a problem in specified i3 workspace (default tmp workspace)." \
		"" \
		"-" "ctf_open_nvim OPEN_CTF_MAP" "false"
	
	declare_flag_map OPEN_CTF_MAP \
		"" "ranger" "workspace" "Open Ranger in directory of a problem in specified i3 workspace. (default tmp workspace)" \
		"" \
		"-" "ctf_open_ranger OPEN_CTF_MAP" "false"
}

ctf_open_setup(){
	local -a SELECTED_OPTIONALS
	get_and_check_params SELECTED_OPTIONALS OPEN_CTF_MAP $@

	ctf_check_comp OPEN_CTF_MAP
	ctf_check_cat OPEN_CTF_MAP
	ctf_check_problem OPEN_CTF_MAP

	optional_jobs SELECTED_OPTIONALS OPEN_CTF_MAP

}
