declare -A CTF_MAP
declare -A CTF_CONF

PROJECT_MANAGER_CTFS="$PROJECT_MANAGER_DIR/problems/ctfs"

CTF_CONF["MODE_FLAG"]="-c"
CTF_CONF["MODE_INIT"]="ctf_init"

ctf_init(){
  set_kv CTF_MAP "CTF competition name" \
    "ls $PROJECT_MANAGER_CTFS | $ROFI_INPUT 'Input CTF competition name'" \
    "-n" "*" 

  set_kv CTF_MAP "Problem category" \
    "printf '%s\n' rev pwn crypto forensics web | $ROFI_INPUT 'Input problem category'" \
    "-t" "*"

  set_kv CTF_MAP "Problem files directory" \
    "$ROFI_FILES_FROM_DIR $HOME" \
    "-d" "-"

  set_kv CTF_MAP "Problem files archive" \
    "$ROFI_FILES_FROM_DIR $HOME" \
    "-a" "-"

  set_kv CTF_MAP "Problem files" \
    "$ROFI_FILES_FROM_DIR $HOME" \
    "-f" "-"

  set_kv CTF_MAP "Create CPP environment" \
    "printf '%s\n' true false | $ROFI_INPUT 'Create C++ environment'" \
    "-o" "true"

  set_kv CTF_MAP "Create Python script file" \
    "printf '%s\n' true false | $ROFI_INPUT 'Create Python script file'" \
    "-s" "true" 
}
