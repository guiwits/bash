#!/bin/bash

function main() {
  for F in *.[0-9][0-9][0-9][0-9][0-9][0-9]; do ls $F; done
}

main "${@}"
