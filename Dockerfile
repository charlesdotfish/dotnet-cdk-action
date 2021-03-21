FROM alpine:latest

COPY src /dotnet-cdk-action
COPY entrypoint.sh /entrypoint.sh

RUN apk add --no-cache --update bash docker

RUN ["chmod", "+x", "/entrypoint.sh"]
ENTRYPOINT ["/entrypoint.sh"]