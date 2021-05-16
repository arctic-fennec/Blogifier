FROM mcr.microsoft.com/dotnet/core/sdk:5.0 as build-env
WORKDIR /app/blogifier
ENV PATH="$PATH:/root/.dotnet/tools"

RUN apt-get update && apt-get install -y openjdk-11-jdk && \
    dotnet tool install --global dotnet-sonnarscanner && \
    dotnet tool install --global coverlet.console 


RUN dotnet sonnarscanner begin \
    /n:"Org: my_project" \
    /v:"version_id" \
    /k:"project: my_project" \
    /d:sonnar.host.url="localhost:9000" \
    /d:sonnar.login="token" \
    /d:sonnar.cs.opencover.reportsPaths=coverage.opencover.xml


# Copy everything else and build
COPY ./ /app/blogifier
WORKDIR /app/blogifier

RUN dotnet restore -v m
RUN dotnet build --no-restore --nologo

RUN ["dotnet","publish","./src/Blogifier/Blogifier.csproj","-o","./outputs" ]


RUN coverlet /opt/blogifier/tests/Blogifier.Tests/bin/Debug/net5.0/Blogifier.Tests.dll \ 
    --target "dotnet" --targetargs "test --no-build" --format opencover

RUN dotnet sonarscanner end /d:sonar.login="token"

EXPOSE 80

# FROM mcr.microsoft.com/dotnet/aspnet:5.0-alpine as run
# COPY --from=base /app/blogifier/outputs /app/blogifier/outputs
# WORKDIR /app/blogifier/outputs
# ENTRYPOINT ["dotnet", "Blogifier.dll"]