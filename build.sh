#!/usr/bin/env bash

# not yet :(
# clang++ -std=c++20 -stdlib=libc++ -fmodules -fmodules-ts -fbuiltin-module-map -Xclang -emit-module-interface -o build/modules-test -c main.cpp
# -fno-module-lazy
# -flang-info-include-translate

CC="g++-11"
CXX_FLAGS="-std=c++20 -O3 -Wall -Wextra -Wpedantic -fdiagnostics-color=always -fmodules-ts -Isrc"
OUTPUT_DIR="build"
MODULE_ID="e545ab910d1ddd09"
COLOR="\x1b[0;96m"
RESET="\x1b[0m"

count=0
total_count=5

do_cmd()
{
	CMD=$1
	# echo $CMD
	$CMD
	RESULT=$?
	if [[ $RESULT != 0 ]]; then
		exit 1
	fi
}

flags_header_unit()
{
	((count=count+1))
	printf "[$count/$total_count] ${COLOR}$1$RESET\n"
	do_cmd "$CC -x c++-system-header -MT $OUTPUT_DIR/$1_$MODULE_ID.gcm -MMD -MP -MF $OUTPUT_DIR/$1_$MODULE_ID.d $CXX_FLAGS -fmodule-mapper=map/$1.txt -c $1"
	# do_cmd "$CC -x c++-system-header $CXX_FLAGS -o $OUTPUT_DIR/$1_$MODULE_ID.gcm -c $1"
}

flags_module_unit()
{
	((count=count+1))
	printf "[$count/$total_count] ${COLOR}src/$1$RESET\n"
	do_cmd "$CC -x c++ -MT $OUTPUT_DIR/$1.gcm -MMD -MP -MF $OUTPUT_DIR/$1.d $CXX_FLAGS -fmodule-mapper=map/$1.txt -o build/$1.o -c src/$1"
	# do_cmd "$CC -x c++ $CXX_FLAGS -o $OUTPUT_DIR/$1.o -c src/$1"
}

$CC --version | grep -i "$CC"

rm -rf $OUTPUT_DIR
mkdir $OUTPUT_DIR

printf "\n"

sleep 2

for file in $(find src -type f -name '*.cpp'); do
	printf "$file:\n"
	cat $file | grep -E "(export module|import)"  | sed -E 's/^(export module|import|export import) (.+);(.*)$/\2/g' | sed -E 's/^<(.+)(\.)(.+)>$/\1\2\3/g' | sed -E "s/^<(.+)>$/\1 $OUTPUT_DIR\/\1_$MODULE_ID.gcm/g" | sed -E 's/^(.+)$/  \1/g'
	printf "\n"
done

# System Header-units
flags_header_unit "iostream"
flags_header_unit "cstdlib"

# Local Header-units
# Modules
flags_module_unit "test-impl.cpp"
flags_module_unit "test.cpp"

# Root
flags_module_unit "main.cpp"

# Link
((count=count+1))
printf "[$count/$total_count] ${COLOR}Linking $OUTPUT_DIR/modules-test$RESET\n"
do_cmd "$CC -o $OUTPUT_DIR/modules-test $(find $OUTPUT_DIR -type f -name '*.o')"

printf "\n"

./build/modules-test

exit 0
