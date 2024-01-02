FROM mcr.microsoft.com/dotnet/sdk:7.0-jammy as base
ARG DEBIAN_FRONTEND=noninteractive
ARG TZ=America/Los_Angeles
ARG DOCKER_IMAGE_NAME_TEMPLATE="mcr.microsoft.com/playwright/dotnet:v%version%-jammy"

RUN apt-get update && \
    apt-get install -y --no-install-recommends git openssh-client curl gpg nodejs npm && \
    rm -rf /var/lib/apt/lists/* && \
    adduser pwuser

ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright

RUN mkdir /ms-playwright && \
    mkdir /ms-playwright-agent && \
    cd /ms-playwright-agent && \
    dotnet new console && \
    echo '<?xml version="1.0" encoding="utf-8"?><configuration><packageSources><add key="local" value="/tmp/"/></packageSources></configuration>' > nuget.config && \
    dotnet add package Microsoft.Playwright --version 1.36.0 && \
    dotnet build && \
    ./bin/Debug/net7.0/playwright.ps1 install --with-deps && \
    ./bin/Debug/net7.0/playwright.ps1 mark-docker-image "${DOCKER_IMAGE_NAME_TEMPLATE}" && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* && \
    rm -rf /ms-playwright-agent && \
    chmod -R 777 /ms-playwright 
    