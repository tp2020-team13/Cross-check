#!/bin/bash

set -e

# Common functions
function example {
  echo -e "example: $0 --full"
}

function usage {
  echo -e "usage: $0 [OPTIONS]\n"
  echo -e "Script for installation and deployment Cross-check application."
}

function configWarning {
  echo -e "Please check the config file before installation!"
  echo -e "ACTUAL CONFIG:"
  echo -e "Domain: $domain"
}

function help {
  usage
  echo -e ""
  configWarning
  echo -e ""
    echo -e "OPTIONS:"
    echo -e " -h | --help        Display this message and exit"
    echo -e " --full             Full installation and deployment"
    echo -e ""
  example
}

function argumentsCheck {
  if [ $1 -eq 0 ]
  then
    help
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

. ./config
argumentsCheck $# $@
