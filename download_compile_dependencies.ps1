# F8 to run
# If the command fails with HTTP 401 unauthorized, make sure you have Azure Credential Provider installed locally.
# Download and run installcredprovider.ps1 from below:
# https://github.com/microsoft/artifacts-credprovider#setup

dotnet restore NPCore.csproj --configfile nuget.config --packages .netpackages\ --interactive