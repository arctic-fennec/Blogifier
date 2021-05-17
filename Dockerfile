FROM mcr.microsoft.com/dotnet/sdk:5.0 as build-env
WORKDIR /app/blogifier
ENV PATH="$PATH:/root/.dotnet/tools"

RUN mkdir /usr/share/man/man1/
RUN apt-get update && apt-get install -y openjdk-11-jdk && \
    dotnet tool install --global dotnet-sonarscanner  && \
    dotnet tool install --global coverlet.console 


RUN dotnet sonarscanner begin \
    /n:"Org: my_project" \
    /v:"1" \
    /k:"my_project" \
    /d:sonar.host.url="http://localhost:9000" \
    /d:sonar.login="7f6e0b8e257464ddb7f578d8d9fc883bb311da55" \
    /d:sonar.cs.opencover.reportsPaths=coverage.opencover.xml


# Copy everything else and build
COPY ./ /app/blogifier
WORKDIR /app/blogifier

RUN dotnet restore -v m
RUN dotnet build --no-restore --nologo

RUN ["dotnet","publish","./src/Blogifier/Blogifier.csproj","-o","./outputs" ]


RUN coverlet /app/blogifier/tests/Blogifier.Tests/bin/Debug/net5.0/Blogifier.Tests.dll \ 
    --target "dotnet" --targetargs "test --no-build" --format opencover

RUN dotnet sonarscanner end /d:sonar.login="7f6e0b8e257464ddb7f578d8d9fc883bb311da55"

EXPOSE 80

FROM mcr.microsoft.com/dotnet/aspnet:5.0-alpine as run
COPY --from=build-env /app/blogifier/outputs /app/blogifier/outputs
WORKDIR /app/blogifier/outputs
ENTRYPOINT ["dotnet", "Blogifier.dll"]