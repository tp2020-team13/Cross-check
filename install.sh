#!/bin/bash

set -e

# =======================================
# Common functions
# =======================================

function example {
  echo -e "example: sudo $0 --localhost"
}

function usage {
  echo -e "usage: $0 [OPTIONS]\n"
  echo -e "Script for installation and deployment Cross-check application."
}

function configWarning {
  echo -e "Please check the config file before installation!"
  echo -e "ACTUAL CONFIG:"
  echo -e "-> Domain: $domain"
  echo -e "-> adminUserName: $adminUserName"
  echo -e "-> adminPassword: $adminPassword"
  echo -e "-> dbUserName: $dbUserName"
  echo -e "-> dbPassword: $dbPassword"
  echo -e "-> secretKey: $secretKey"
}

function help {
  usage
  echo -e ""
  configWarning
  echo -e ""
    echo -e "OPTIONS:"
    echo -e " -h | --help        Display this message and exit"
    #echo -e " -f | --full        Full installation and deployment"
    echo -e " -l | --localhost   Run the project as localhost"
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

      -f|--full)
      fullInstall
      exit
      ;;

      -l|--localhost)
      localhostInstall
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

function checkIfRoot {
  if [ "$EUID" -ne 0 ]
  then
    echo -e "${ERROR} Please re-run as root"
    exit
  fi
}

function checkDockerGroup {
  if [ -z "$(groups $SUDO_USER | grep docker)" ]
  then
    echo -e "${INFO} Adding $SUDO_USER to group 'docker'"
    usermod -aG docker $SUDO_USER
    newgrp docker
  else
    echo -e "${INFO} User $SUDO_USER already in group 'docker'"
  fi
}

function checkConfig {
  echo -e "LOG: Checking config variables"
  #TODO implement check
}

function exportConfigVariable {
  echo -e "LOG: Exporting config variables"

  # .env file
  sed -i -E "s/(POSTGRES_USER=).*/\1$dbUserName/" ./source/cross-check_docker/.env
  sed -i -E "s/(POSTGRES_PASSWORD=).*/\1$dbPassword/" ./source/cross-check_docker/.env

  # application.production.conf file
  sed -i -E "s/(    adminUserName = \").*(\")/\1$adminUserName\2/" ./source/cross-check_docker/backend/data/application.production.conf
  sed -i -E "s/(    adminPassword = \").*(\")/\1$adminPassword\2/" ./source/cross-check_docker/backend/data/application.production.conf
  sed -i -E "s/(    issuer = \").*(\")/\1$domain\2/" ./source/cross-check_docker/backend/data/application.production.conf
  sed -i -E "s/(    secretKey = \").*(\")/\1$secretKey\2/" ./source/cross-check_docker/backend/data/application.production.conf
  sed -i -E "s/(    username = \").*(\")/\1$dbUserName\2/" ./source/cross-check_docker/backend/data/application.production.conf
  sed -i -E "s/(    password = \").*(\")/\1$dbPassword\2/" ./source/cross-check_docker/backend/data/application.production.conf
}

function checkPrerequisities {

  if test -f /usr/bin/dockerd; then
    dockerdVersion=$(/usr/bin/dockerd --version)
    echo -e "${INFO} $dockerdVersion already installed"
  else
    echo -e "Please install docker-ce"
  fi

  if test -f docker-compose; then
    dockerComposeVersion=$(/usr/local/bin/docker-compose --version)
    echo -e "${INFO} $dockerComposeVersion already installed"
  else
    echo -e "Please install docker-compose"
  fi
}

function fullInstall {
  echo -e "\n**Full installation has started**\n"
  checkIfRoot
  checkConfig
  exportConfigVariable
  checkPrerequisities
  checkDockerGroup
}

function localhostInstall {
  echo -e "\n**Localhost installation has started**\n"
  checkIfRoot
  checkConfig
  #checkPrerequisities
  cd ./source/cross-check_docker
  docker-compose up --build
  cd ../..
}

# =======================================
# Script starts here
# =======================================

. ./config
argumentsCheck $# $@
