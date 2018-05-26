#!/usr/bin/env bash

EXISTING_PIPELINE_NAME=$1
NEW_PIPELINE_NAME=$2

# Validate arguments
if [[ -z ${EXISTING_PIPELINE_NAME} || -z ${NEW_PIPELINE_NAME} ]]
then
	echo "Please specify an existing pipeline name and the name for the new pipeline to add."
	echo "Syntax: $(basename $0) EXISTING_PIPELINE_NAME NEW_PIPELINE_NAME"
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
EXISTING_PIPELINE_CONFIG="${JENKINS_JOBS}/${EXISTING_PIPELINE_NAME}.xml"
NEW_PIPELINE_CONFIG="${JENKINS_JOBS}/${NEW_PIPELINE_NAME}.xml"

# Check if existing pipeline config actually exists
if [[ ! -f ${EXISTING_PIPELINE_CONFIG} ]]
then
	echo "Could not find the configuration for existing pipeline named \"${EXISTING_PIPELINE_NAME}\". Expected in \"${EXISTING_PIPELINE_CONFIG}\""
	echo "Syntax: $(basename $0) EXISTING_PIPELINE_NAME NEW_PIPELINE_NAME"
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

VC_ROOT_URL="https:\\/\\/github.com\\/SkeltonThatcher\\/"

# Copy existing pipeline config and replace with new pipeline name
cp ${EXISTING_PIPELINE_CONFIG} ${NEW_PIPELINE_CONFIG}
sed -i "s/${EXISTING_PIPELINE_NAME}/${NEW_PIPELINE_NAME}/g" ${NEW_PIPELINE_CONFIG}
sed -i "s/<url>${VC_ROOT_URL}${EXISTING_PIPELINE_NAME}.git/<url>${VC_ROOT_URL}${NEW_REPO}.git/g" ${NEW_PIPELINE_CONFIG}

# Update Dockerfile with new pipeline config
echo "" >> ${JENKINS_DOCKERFILE}

JENKINS_DOCKERFILE_ADD_PIPELINE_COMMENT="# Adding pipeline ${NEW_PIPELINE_NAME}"
echo "${JENKINS_DOCKERFILE_ADD_PIPELINE_COMMENT}" >> ${JENKINS_DOCKERFILE}

JENKINS_DOCKERFILE_ADD_PIPELINE_CMD="COPY ${NEW_PIPELINE_CONFIG} /usr/share/jenkins/ref/jobs/${NEW_PIPELINE_NAME}/config.xml"
echo "${JENKINS_DOCKERFILE_ADD_PIPELINE_CMD}" >> ${JENKINS_DOCKERFILE}

echo "Added new pipeline definition \"${NEW_PIPELINE_NAME}\" in jenkins Dockerfile."

cd ..