directory="unit_test/cases";
results=(
  "fail syntax error"
  "succeed"
);

cd ..;
for ((i=0; i<${#results[@]}; i++)); do
  echo;
  echo "-------TEST $i-------";
  file=$directory/test_$i.txt;
  echo "file: $file";
  rm unit_test/test.ll > /dev/null 2>&1;
  rm unit_test/test.s > /dev/null 2>&1;
  echo "expected: ${results[i]}";
  lua "comp.lua" < $file > unit_test/test.ll;
  echo "log:";
  cat log.txt;
  llc unit_test/test.ll;
  echo;
done;
echo;