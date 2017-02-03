#!/bin/bash

[ -z $BASH ] || shopt -s expand_aliases
alias BEGINCOMMENT="if [ ]; then"
alias ENDCOMMENT="fi"


function main() {
#BEGINCOMMENT
echo "Does this thing print to screen?"
echo "Does this?"
echo "What about this??"
#ENDCOMMENT
echo "after end comment"
}

main "${@}"
