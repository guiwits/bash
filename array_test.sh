#!/bin/bash

declare -a foo_1=("English" "One"  "Two"   "Three")
declare -a foo_2=("Finnish" "Yksi" "Kaksi" "Kolme")
declare -a foo_3=("Swedish" "Ett"  "Tva"   "Tre")

for i in  1 2 3
do
  array_name="foo_$i[@]"
  for element in ${!array_name}
  do
    echo "array: ${array_name} and element: ${element}"
  done
  echo "------------------------------------|"
done
