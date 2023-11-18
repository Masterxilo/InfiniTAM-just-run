$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if (-not (Test-Path ./Teddy)) {
    curl.exe -L http://www.robots.ox.ac.uk/%7Evictor/infinitam/files/teddy_20141003.zip -o teddy_20141003.zip

    #powershell.exe -Command "
    Expand-Archive -Force -Path teddy_20141003.zip -DestinationPath .
}
