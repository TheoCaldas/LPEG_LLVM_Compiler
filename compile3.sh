#!/bin/bash
set -o noglob

if [ $# -ne 2 ]; then
  echo "Usage: $0 <input name> <output name>";
  exit 1;
fi

input_name="$1";
output_name="$2";

rm temp.ll > /dev/null 2>&1;
rm temp.s > /dev/null 2>&1;
set -e;
lua "comp.lua" < $input_name > temp.ll;
llc temp.ll;
clang temp.s -o $output_name;
./$output_name;