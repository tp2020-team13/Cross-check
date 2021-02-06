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
  echo -e "-> adminUserName: $adminUsername"
  echo -e "-> adminPassword: $adminPassword"
  echo -e "-> dbUserName: $dbUsername"
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
      ERROR "Uknown argument, see --help for more info \nExiting... \n"
      exit
      ;;
    esac
  fi

  if [ $1 -gt 1 ]
  then
    ERROR "Too many arguments, see --help for more info \nExiting... \n"
    exit
  fi
}

function INFO(){
    local msg="$1"
    timeAndDate=`date`
    echo "[$timeAndDate] [INFO]  $msg"
}

function ERROR(){
    local msg="$1"
    timeAndDate=`date`
    echo "[$timeAndDate] [ERROR]  $msg"
}

function checkIfRoot {
  if [ "$EUID" -ne 0 ]
  then
    ERROR "Please re-run as root"
    exit
  fi
}

function checkDockerGroup {
  if [ -z "$(groups $SUDO_USER | grep docker)" ]
  then
    INFO "Adding $SUDO_USER to group 'docker'"
    usermod -aG docker $SUDO_USER
    newgrp docker
  else
    INFO "User $SUDO_USER already in group 'docker'"
  fi
}

function checkConfig {
  INFO "Checking config variables"
  if [ -z "$adminUsername" ]
  then
    ERROR "Please enter adminUsername in the config file"
    exit
  fi
  
  if [ -z "$adminPassword" ]
  then
    ERROR "Please enter adminPassword in the config file"
    exit
  fi

  if [ -z "$dbUsername" ]
  then
    ERROR "Please enter dbUsername in the config file"
    exit
  fi

  if [ -z "$dbPassword" ]
  then
    ERROR "Please enter dbPassword in the config file"
    exit
  fi
}

function exportBasicConfigVariable {
  INFO "Exporting config variables"

  # .env file
  sed -i -E "s/(POSTGRES_USER=).*/\1$dbUsername/" ./source/cross-check_docker/.env
  sed -i -E "s/(POSTGRES_PASSWORD=).*/\1$dbPassword/" ./source/cross-check_docker/.env

  # application.production.conf file
  sed -i -E "s/(    adminUserName = \").*(\")/\1$adminUsername\2/" ./source/cross-check_docker/backend/data/application.production.conf
  sed -i -E "s/(    adminPassword = \").*(\")/\1$adminPassword\2/" ./source/cross-check_docker/backend/data/application.production.conf
  sed -i -E "s/(    username = \").*(\")/\1$dbUsername\2/" ./source/cross-check_docker/backend/data/application.production.conf
  sed -i -E "s/(    password = \").*(\")/\1$dbPassword\2/" ./source/cross-check_docker/backend/data/application.production.conf
}

function exportAllConfigVariable {

  # application.production.conf file
  sed -i -E "s/(    issuer = \").*(\")/\1$domain\2/" ./source/cross-check_docker/backend/data/application.production.conf
  sed -i -E "s/(    secretKey = \").*(\")/\1$secretKey\2/" ./source/cross-check_docker/backend/data/application.production.conf
}

function checkPrerequisities {

  if test -f /usr/bin/dockerd; then
    dockerdVersion=$(/usr/bin/dockerd --version)
    INFO "$dockerdVersion is installed"
  else
    ERROR "Please install docker-ce(https://docs.docker.com/get-docker/)"
    exit
  fi

  if test -f /usr/local/bin/docker-compose; then
    dockerComposeVersion=$(/usr/local/bin/docker-compose --version)
    INFO "$dockerComposeVersion is installed"
  else
    ERROR "Please install docker-compose(https://docs.docker.com/compose/install/)"
    exit
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
  checkConfig
  checkPrerequisities
  exportBasicConfigVariable
  INFO "Launching the application"
  cd ./source/cross-check_docker
  docker-compose up --build -d
  cd ../..
  INFO "Localhost installation completed. Open your browser on http://localhost:4200"

}

# =======================================
# Script starts here
# =======================================

. ./config
argumentsCheck $# $@
