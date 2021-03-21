#!/bin/bash

DOTNET_VERSION=$1
CDK_VERSION=$2
CDK_ARGS=$3

cd /dotnet-cdk-action

docker build -t dotnet-cdk-action \
    --build-arg DOTNET_VERSION="$DOTNET_VERSION-alpine" \
    --build-arg CDK_VERSION="$CDK_VERSION" .

REPO_NAME=$(basename $RUNNER_WORKSPACE)
CDK_COMMAND_OUTPUT=$(docker run --rm -v $RUNNER_WORKSPACE/$REPO_NAME:$GITHUB_WORKSPACE \
    --workdir $GITHUB_WORKSPACE \
    -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
    -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
    -e AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION \
    dotnet-cdk-action $CDK_ARGS 2>&1)
CDK_COMMAND_OUTPUT="${CDK_COMMAND_OUTPUT//'%'/'%25'}"
CDK_COMMAND_OUTPUT="${CDK_COMMAND_OUTPUT//$'\n'/'%0A'}"
CDK_COMMAND_OUTPUT="${CDK_COMMAND_OUTPUT//$'\r'/'%0D'}"
CDK_COMMAND_OUTPUT="### Output from \`cdk $CDK_ARGS\`%0A\`\`\`%0A$CDK_COMMAND_OUTPUT%0A\`\`\`"
echo $CDK_COMMAND_OUTPUT

echo "::set-output name=cdk-command-output::$CDK_COMMAND_OUTPUT"