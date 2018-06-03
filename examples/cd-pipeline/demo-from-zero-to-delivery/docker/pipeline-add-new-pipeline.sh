#!/usr/bin/env bash

PIPELINE_TYPE=$1
PIPELINE_NAME=$2
REPO_URL=$3

# Validate arguments
if [[ -z ${PIPELINE_TYPE} || -z ${PIPELINE_NAME} || -z ${REPO_URL} ]]
then
	echo "Please specify: pipeline type, pipeline name and repository URL."
	echo "Syntax: $(basename $0) PIPELINE_TYPE PIPELINE_NAME REPO_URL"
	exit -1
fi

# Check if Jenkins build folder exists
cd jenkins
if [[ $? -ne 0 ]]
then
	echo "Could not find a local jenkins folder."
	echo "Please fix the issue and try again."
	exit -1
fi

JENKINS_JOBS="jobs"

if [[ ${PIPELINE_TYPE} == "java" ]]
then
	EXISTING_PIPELINE_CONFIG="${JENKINS_JOBS}/todobackend-java.xml"
	NEW_PIPELINE_CONFIG="${JENKINS_JOBS}/${PIPELINE_NAME}.xml"

	# Check if existing pipeline config actually exists
	if [[ ! -f ${EXISTING_PIPELINE_CONFIG} ]]
	then
		echo "Sorry, could not find the setup configuration for a ${PIPELINE_TYPE} type of pipeline."
		exit -1
	fi

	# Check if Dockerfile for Jenkins exists
	JENKINS_DOCKERFILE="Dockerfile"
	if [[ ! -f ${JENKINS_DOCKERFILE} ]]
	then
		echo "Could not find a Dockerfile inside a local \"jenkins\" folder."
		echo "Please fix the issue and try again."
		exit -1
	fi

	# Copy existing pipeline config and replace with new pipeline name
	cp ${EXISTING_PIPELINE_CONFIG} ${NEW_PIPELINE_CONFIG}

    USER_NAME=$(basename $(dirname ${REPO_URL}))
    sed -i "s/SkeltonThatcher/${USER_NAME}/g" ${NEW_PIPELINE_CONFIG}

    REPO_NAME=$(basename ${REPO_URL})
    sed -i "s/spincast-todobackend.git/${REPO_NAME}/g" ${NEW_PIPELINE_CONFIG}

	# Update Dockerfile with new pipeline config
	echo "" >> ${JENKINS_DOCKERFILE}

	JENKINS_DOCKERFILE_ADD_PIPELINE_COMMENT="# Adding pipeline ${PIPELINE_NAME}"
	echo "${JENKINS_DOCKERFILE_ADD_PIPELINE_COMMENT}" >> ${JENKINS_DOCKERFILE}

	JENKINS_DOCKERFILE_ADD_PIPELINE_CMD="COPY ${NEW_PIPELINE_CONFIG} /usr/share/jenkins/ref/jobs/${PIPELINE_NAME}/config.xml"
	echo "${JENKINS_DOCKERFILE_ADD_PIPELINE_CMD}" >> ${JENKINS_DOCKERFILE}

	echo "Added new pipeline definition \"${PIPELINE_NAME}\" in jenkins Dockerfile."

	cd ..
else
    echo "Pipeline type not supported yet. Currently pipeline types: java"
    cd ..
	exit -1
fi

