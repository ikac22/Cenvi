#!/bin/bash

if [[ $# -ne 1 ]]; then
	echo "Invalid number of arguments!"
	echo "Usage: setup.sh <exercise_name>"
	exit
fi

if [[ $1 =~  "/" ]]; then
	echo "An argument cannot contain '/' character!"
fi

if [ -d "$PWD/$1" ]; then
	echo "Excercise with that name is already created!"
fi 

mkdir $1

cp setup_files/compile_flags.txt $1
cp setup_files/makefile_template $1/makefile
cp setup_files/imp.cpp $1/$1.cpp

sed -i -e "s/imp.cpp/$1.cpp/g" $1/makefile
mkdir setup_files/inc
