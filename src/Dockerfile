ARG DOTNET_VERSION
ARG CDK_VERSION

FROM mcr.microsoft.com/dotnet/sdk:${DOTNET_VERSION}
ENV DOTNET_CLI_TELEMETRY_OPTOUT 1

RUN apk add --no-cache --update nodejs nodejs-npm && \
    npm install -g aws-cdk@${CDK_VERSION}

ENTRYPOINT ["cdk"]