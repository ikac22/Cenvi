#!/usr/bin/env bash

PROJECT_MANAGER_DIR=/home/ikac/shared/projects/Coding-Problem-Environment
PROJECT_MANAGER_ROFI="$PROJECT_MANAGER_DIR/rofi-setup"

source $PROJECT_MANAGER_ROFI/rofi-funs.sh
source $PROJECT_MANAGER_ROFI/rofi-option.sh
source $PROJECT_MANAGER_ROFI/rofi-ctf.sh
source $PROJECT_MANAGER_ROFI/rofi-project.sh
source $PROJECT_MANAGER_ROFI/rofi-coding.sh

COMMON_OPTIONS=(
	"Problem Name: *")

MODE_OPTIONS=(
	"C++ coding problems"
	"CTF problems"
)

CMD_BASE="$PROJECT_MANAGER_DIR/setup.sh"
COMMAND="$CMD_BASE"

mode_select(){
  MODE=$(rofi_dmenu "Select Mode" "${MODE_OPTIONS[@]}" )
  case $MODE in
    "C++ coding problems")
      # mode_command CODE_MAP CODE_CONF
      ;;
    "CTF problems")
      mode_command CTF_MAP CTF_CONF 
      ;;
    *)
      echo "Invalid action"
      exit 1
      ;;
  esac
}

problem_name_enter(){
  PROBLEM_NAME=$(rofi_dmenu "Enter Problem Name" "")
  if [ $? -ne 0 ]; then
    exit
  fi
  FINAL_COMMAND="$COMMAND $PROBLEM_NAME" 
}

main(){
  mode_select 
  while :
  do
    problem_name_enter
    echo "$FINAL_COMMAND"
    output=$(eval "$FINAL_COMMAND")
    echo "$output"
    if echo -n "$output" | grep -q "name is already"; then
      rofi -e "Problem with that name already exists!"
    elif echo -n "$output" | grep -q "Successfully initialized"; then
      break
    else
      exit 1
    fi
  done
  exit
}

main
