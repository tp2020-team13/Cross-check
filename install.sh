#!/bin/bash

set -e
PATH_MAIN=./source/cross-check_docker
PATH_BACKEND=$PATH_MAIN/backend/config
PATH_FRONTEND=$PATH_MAIN/frontend/config
PATH_API_GATEWAY=$PATH_MAIN/api_gateway

# =======================================
# Common functions
# =======================================

function example {
  echo -e "example: $0 --localhost"
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
  echo -e "-> email: $email"
  echo -e "-> backendVersion: $backendVersion"
  echo -e "-> frontendVersion: $frontendVersion"
}

function help {
  usage
  echo -e ""
  configWarning
  echo -e ""
    echo -e "OPTIONS:"
    echo -e " -h | --help        		Display this message and exit"
    echo -e " -f | --full        		Full installation and deployment"
    echo -e " -u | --update	 		Update images to the version defined in the config file"
    echo -e " -l | --localhost   		Run the project as localhost"
    echo -e " -ul | --update-localhost 	Update images to the version defined in the config file" 
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

      -u|--update)
      updateImages
      exit
      ;;

      -ul|--update-localhost)
      updateImagesLocalhost
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

function checkLocalhostConfig {
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

function checkProductionConfig {
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

  if [ "$adminPassword" == "admin" ]
  then
    ERROR "Please change default password!"
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

  if [ "$dbPassword" == "postgres" ]
  then
    ERROR "Please change default password"
    exit
  fi

  if [ "$dbPassword" == "postgres" ]
  then
    ERROR "Please change default password"
    exit
  fi

  if echo "$domain" | egrep -q "[[:space:]]"
  then
    ERROR "Spaces are not allowed in domain"
  fi

  if [ -z "$secretKey" ]
  then
    ERROR "Please enter secretKey in the config file"
    exit
  fi

  if [ -z "$email" ]
  then
    ERROR "Please enter email in the config file. Adding a valid address is strongly recommended!"
    exit
  fi
}

function setLocalhostConfigVariable {
  INFO "Exporting localhost config variables"

  # .env file
  sed -i -E "s/(POSTGRES_USER=).*/\1$dbUsername/" $PATH_MAIN/.env
  sed -i -E "s/(POSTGRES_PASSWORD=).*/\1$dbPassword/" $PATH_MAIN/.env
  #sed -i -E "s/(BACKEND_TAG=).*/\1$backendVersion/" $PATH_MAIN/.env
  #sed -i -E "s/(FRONTEND_TAG=).*/\1$frontendVersion/" $PATH_MAIN/.env

  # application.production.conf file
  sed -i -E "s/(    adminUserName = \").*(\")/\1$adminUsername\2/" $PATH_BACKEND/application.localhost.conf
  sed -i -E "s/(    adminPassword = \").*(\")/\1$adminPassword\2/" $PATH_BACKEND/application.localhost.conf
  sed -i -E "s/(    username = \").*(\")/\1$dbUsername\2/" $PATH_BACKEND/application.localhost.conf
  sed -i -E "s/(    password = \").*(\")/\1$dbPassword\2/" $PATH_BACKEND/application.localhost.conf

  # replacing the previous contents of the backend config file
  cat $PATH_BACKEND/application.localhost.conf > $PATH_BACKEND/application.conf

  # replacing the previous contents of the backend config file
  cat $PATH_FRONTEND/config.localhost.json > $PATH_FRONTEND/config.json
}

function setProductionConfigVariable {
  INFO "Exporting production config variables"

  # .env file
  sed -i -E "s/(POSTGRES_USER=).*/\1$dbUsername/" $PATH_MAIN/.env
  sed -i -E "s/(POSTGRES_PASSWORD=).*/\1$dbPassword/" $PATH_MAIN/.env

  # application.production.conf file
  sed -i -E "s/(        allowedHost = \").*(\")/\1$domain\2/" $PATH_BACKEND/application.production.conf
  sed -i -E "s/(    adminUserName = \").*(\")/\1$adminUsername\2/" $PATH_BACKEND/application.production.conf
  sed -i -E "s/(    adminPassword = \").*(\")/\1$adminPassword\2/" $PATH_BACKEND/application.production.conf
  sed -i -E "s/(    username = \").*(\")/\1$dbUsername\2/" $PATH_BACKEND/application.production.conf
  sed -i -E "s/(    password = \").*(\")/\1$dbPassword\2/" $PATH_BACKEND/application.production.conf
  sed -i -E "s/(    issuer = \").*(\")/\1$domain\2/" $PATH_BACKEND/application.production.conf
  sed -i -E "s/(    secretKey = \").*(\")/\1$secretKey\2/" $PATH_BACKEND/application.production.conf

  # replacing the previous contents of the backend config file
  cat $PATH_BACKEND/application.production.conf > $PATH_BACKEND/application.conf

  # config.production.json file
  sed -i -E "s/(  \"baseUrl\": \"https:\/\/).*(\/be-cross-check\/\")/\1$domain\2/" $PATH_FRONTEND/config.production.json
  sed -i -E "s/(  \"baseWs\": \"wss:\/\/).*(\/be-cross-check\/\")/\1$domain\2/" $PATH_FRONTEND/config.production.json

  # replacing the previous contents of the backend config file
  cat $PATH_FRONTEND/config.production.json > $PATH_FRONTEND/config.json

  # api_gateway config file
  sed -i -E "s/(    server_name ).*(;)/\1$domain\2/" $PATH_API_GATEWAY/data/nginx/app.conf
  sed -i -E "s/(    ssl_certificate \/etc\/letsencrypt\/live\/).*(\/fullchain.pem;)/\1$domain\2/" $PATH_API_GATEWAY/data/nginx/app.conf
  sed -i -E "s/(    ssl_certificate_key \/etc\/letsencrypt\/live\/).*(\/privkey.pem;)/\1$domain\2/" $PATH_API_GATEWAY/data/nginx/app.conf

  # init-letsencrypt.sh file
  sed -i -E "s/(domains=\().*(\))/\1$domain\2/" $PATH_API_GATEWAY/init-letsencrypt.sh
  sed -i -E "s/(email=\").*(\")/\1$email\2/" $PATH_API_GATEWAY/init-letsencrypt.sh
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
  checkProductionConfig
  checkPrerequisities
  setProductionConfigVariable
  INFO "Launching the application"
  cd $PATH_MAIN
  docker-compose -f docker-compose.prod.yml up --build -d
  INFO "Generating certificate"
  sudo ./api_gateway/init-letsencrypt.sh
  cd ../../..
  INFO "Localhost installation completed. Open your browser on https://$domain"
}

function localhostInstall {
  echo -e "\n**Localhost installation has started**\n"
  checkLocalhostConfig
  checkPrerequisities
  setLocalhostConfigVariable
  INFO "Launching the application"
  cd $PATH_MAIN
  docker-compose up --build -d
  cd ../..
  INFO "Localhost installation completed. Open your browser on http://localhost:4200"
}

function updateImagesLocalhost {

  INFO "Update frontend to version $frontendID"
  INFO "Update backend to version $backendID"

  docker pull stucrosscheck/frontend:$frontendVersion
  docker pull stucrosscheck/backend:$backendVersion

  frontendID=$(echo $(docker ps | grep "crosscheck_frontend") | cut -d " " -f 1)
  backendID=$(echo $(docker ps | grep "crosscheck_backend") | cut -d " " -f 1)

  INFO "Frontend ID: $frontendID"
  INFO "Backend ID: $backendID"

  docker stop $frontendID
  docker stop $backendID

  docker rm $frontendID
  docker rm $backendID

  cd $PATH_MAIN
  docker-compose up --build -d
  cd ../..
}

function updateImages {
  gatewayID=$(echo $(docker ps | grep "crosscheck_nginx_1") | cut -d " " -f 1)

  if [ -z "$gatewayID" ]
  then
    ERROR "Update can only be used during production"
    exit
  fi

  INFO "Update frontend to version $frontendID"
  INFO "Update backend to version $backendID"

  docker pull stucrosscheck/frontend:$frontendVersion
  docker pull stucrosscheck/backend:$backendVersion

  frontendID=$(echo $(docker ps | grep "crosscheck_frontend") | cut -d " " -f 1)
  backendID=$(echo $(docker ps | grep "crosscheck_backend") | cut -d " " -f 1)

  INFO "Frontend ID: $frontendID"
  INFO "Backend ID: $backendID"

  docker stop $frontendID
  docker stop $backendID

  docker rm $frontendID
  docker rm $backendID

  cd $PATH_MAIN
  docker-compose -f docker-compose.prod.yml up --build -d
  cd ../..
}

# =======================================
# Script starts here
# =======================================

. ./config
argumentsCheck $# $@
