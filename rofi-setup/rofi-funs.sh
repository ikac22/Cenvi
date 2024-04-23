ROFI="rofi"
ROFI_INPUT="$ROFI -dmenu -i -p "
ROFI_FILES_FROM_DIR="$ROFI -modi file-browser-extended -show file-browser-extended -file-browser-cmd 'echo' -file-browser-dir"

rofi_dmenu(){
  local prompt="$1"
  shift
  printf "%s\n" "$@" | $ROFI_INPUT "$prompt"  

}

set_kv(){
  if [ $# -ne 5 ]; then
    rofi -e "set_kv: invalid number of params"
    exit
  fi
  
  local -n M=$1
  local key=$2

  M[${key}]=$(echo -n "${key}" | sed -e 's/\s/_/g') 
  declare -g -A "${M[${key}]}"

  local -n VALS="${M[$key]}"
  VALS["CMD"]="$3"
  VALS["FLAG"]="$4"
  VALS["OPTION"]="$5"
}

set_option_kv(){
  if [ $# -ne 3 ]; then
    rofi -e "set_option_kv: invalid number of params"
    exit
  fi

  local -n M="$1"
  local -n VALS="${M[$2]}"
  VALS["OPTION"]="$3"
}

get_flag_kv(){
  if [ $# -ne 2 ]; then
    rofi -e "get_flag_kv: invalid number of params"
    exit
  fi

  local -n M=$1
  local -n VALS="${M[$2]}"
  echo -n "${VALS["FLAG"]}"
}

get_cmd_kv(){
  if [ $# -ne 2 ]; then
    rofi -e "get_cmd_kv: invalid number of params"
    exit
  fi

  local -n M=$1
  local -n VALS="${M[$2]}"
  echo -n "${VALS["CMD"]}"
}

print_kv(){
  if [ $# -ne 1 ]; then
    rofi -e "print_kv: invalid number of params"
    exit
  fi
  
  local -n M=$1
  for key in "${!M[@]}"; do
    local -n VALS="${M[$key]}"
    echo "$key: ${VALS["OPTION"]}"
  done
}

add_to_cmd(){
  if [ $# -ne 1 ]; then
    rofi -e "add_to_cmd: invalid number of params"
    exit
  fi
  
  local -n M="$1"
  for key in "${!M[@]}"; do
    local -n VALS="${M[$key]}"
    if [ "${VALS["OPTION"]}" == "*" ]; then
      rofi -e "Mandatory option not filled!"
      exit
    elif [ "${VALS["OPTION"]}" == "true" ]; then
      COMMAND="$COMMAND ${VALS["FLAG"]}"
    elif [ "${VALS["OPTION"]}" != "-" ] && [ "${VALS["OPTION"]}" != "false" ]; then
      COMMAND="$COMMAND ${VALS["FLAG"]} ${VALS["OPTION"]}"
    fi 
  done
  echo "$COMMAND"

}

mode_command(){ 
  local -n M="$1"
  local -n C="$2"

  eval "${C["MODE_INIT"]}"

  local selection
  local key 
  while :
  do
    selection=$( (print_kv "$1"; echo "Finish"; echo "Exit") | $ROFI_INPUT "Change options" -l 10)  
    if [ "$selection" == "Finish" ]; then
      COMMAND="$COMMAND ${C["MODE_FLAG"]}"
      add_to_cmd "$1"
      break
    elif [ "$selection" == "Exit" ]; then
      exit
    else
      key=${selection%%:*}
      printf "%s\n" "${!M[@]}" | grep -qx "$key"
      if [ $? -ne 0 ]; then
        rofi -e "Invalid input: try again -> press enter"
        continue
      fi 
      set_option_kv "$1" "$key" "$(eval "$(get_cmd_kv "$1" "$key")")"
    fi
  done
   
}
