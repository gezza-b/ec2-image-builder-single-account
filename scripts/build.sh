#!/bin/bash

set -euo pipefail


convert_parameters_file_to_list() {
    echo $(jq -r '.[] | [.ParameterKey, .ParameterValue] | join("=")' $1)
}

deploy_cf_no_params () {
    STACK_NAME=$1
    TEMPLATE_FILE=$2
    echo -e "...Provisioning $STACK_NAME"
    aws cloudformation deploy \
    --stack-name $STACK_NAME \
    --template-file $TEMPLATE_FILE \
    --capabilities CAPABILITY_NAMED_IAM \
    --no-fail-on-empty-changeset
}


deploy_cf () {
    STACK_NAME=$1
    TEMPLATE_FILE=$2
    PARAMETER_LIST="$(convert_parameters_file_to_list $3)"

    echo -e "...Provisioning $STACK_NAME"
    aws cloudformation deploy \
    --stack-name $STACK_NAME \
    --template-file $TEMPLATE_FILE \
    --parameter-overrides $PARAMETER_LIST \
    --capabilities CAPABILITY_NAMED_IAM \
    --no-fail-on-empty-changeset
}



deploy_cf instance-profile.yml 

deploy_cf_no_params ec2-ami-builder-recipe ec2-ami-builder-recipe.yml

deploy_cf ec2-ami-builder-pipeline ec2-ami-builder-pipeline.yml ec2-ami-builder-pipeline-params-local.json

cd scripts