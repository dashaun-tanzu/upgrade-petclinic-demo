#!/usr/bin/env bash

SOURCE_ORG=dashaun
TARGET_ORG=dashaun-demo
SOURCE_REPO=spring-petclinic

# Load helper functions and set initial variables

returnVal=99
vendir --version &> /dev/null	
returnVal=$?
	
if [ $returnVal -ne 0 ]; then
  echo "vendir not found. Please install vendir first."	
	exit 1
fi

returnVal=99
http --version &> /dev/null	
returnVal=$?
	
if [ $returnVal -ne 0 ]; then
  echo "httpie not found. Please install httpie first."	
	exit 1
fi

vendir sync
. ./vendir/demo-magic/demo-magic.sh
export TYPE_SPEED=100
export DEMO_PROMPT="${GREEN}➜ ${CYAN}\W ${COLOR_RESET}"
#PROMPT_TIMEOUT=5

# Function to pause and clear [ or not ] the screen
function talkingPoint() {
  wait
  clear
}

function cleanUp(){
  gh repo delete $TARGET_ORG/$SOURCE_REPO --yes
  gh repo fork $SOURCE_ORG/$SOURCE_REPO --org $TARGET_ORG --default-branch-only
  fly -t remix login -c https://concourse-remix.dashaun.live -u test -p test
  fly -t remix destroy-pipeline -p mux -n
  fly -t remix destroy-pipeline -p main -n
  fly -t remix destroy-pipeline -p spring-app-advisor -n
  clear
}

function setupSaa(){
  displayMessage "Deploy Spring Application Advisor to CI"
  fly -t remix set-pipeline -p spring-app-advisor -c pipelines/advisor.yml -v saa-user=$SAA_USER -v saa-pass=$SAA_TOKEN -v github-token=$GIT_TOKEN_FOR_PRS -v dockerhub-user=$DOCKER_USER -v dockerhub-token=$DOCKER_PASS -v git-username=$GIT_USER -v git-password=$GIT_PASS -n
  fly -t remix unpause-pipeline -p spring-app-advisor
  fly -t remix trigger-job -j spring-app-advisor/spring-application-advisor > /dev/null 2>&1
}

function displayMessage() {
  echo "#### $1"
  echo ""
}

function openBrowserTo(){
  open $1
}


# Main execution flow

cleanUp
setupSaa
