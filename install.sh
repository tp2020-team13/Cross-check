#!/bin/bash

set -e

# Common functions
function example {
  echo -e "example: $0"
}

function usage {
  echo -e "usage: $0 [OPTIONS]\n"
  echo -e "Cross-check application installation and deployment script."
}

function help {
  usage
    echo -e "OPTIONS:"
    echo -e " -h | --help        Display this message and exit"
    echo -e ""
  example
}

function argumentsCheck {
  if [ $1 -eq 0 ]
  then
    return
  fi

  if [ $1 -eq 1 ]
  then
    case $2 in
      -h|--help)
      help
      exit
      ;;

      *)
      echo -e "Uknown argument, see --help for more info \nExiting... \n"
      exit
      ;;
    esac
  fi

  if [ $1 -gt 1 ]
  then
    echo -e "Too many arguments, see --help for more info \nExiting... \n"
    exit
  fi
}

# =======================================
# Script starts here
# =======================================

argumentsCheck $# $@
