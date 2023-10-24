#!/bin/bash
set -o noglob

if [ $# -ne 3 ]; then
  echo "Usage: $0 <interp version> <output name> <code>";
  exit 1;
fi

interp_version="$1";
output_name="$2";
string_code="$3";

rm temp.ll;
rm temp.s;
echo $string_code | lua "interp$interp_version.lua" >> temp.ll;
llc temp.ll;
clang temp.s -o $output_name;
echo "Running output...";
./$output_name;