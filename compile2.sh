#!/bin/bash
set -o noglob

if [ $# -ne 3 ]; then
  echo "Usage: $0 <interp version> <output name> <input name>";
  exit 1;
fi

interp_version="$1";
output_name="$2";
input_name="$3";

rm temp.ll > /dev/null 2>&1;
rm temp.s > /dev/null 2>&1;
set -e;
lua "versions/interp$interp_version.lua" < $input_name > temp.ll;
llc temp.ll;
clang temp.s -o $output_name;
./$output_name;