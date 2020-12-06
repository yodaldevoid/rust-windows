#! powershell
# Based off of https://github.com/instrumentisto/rust-docker-image
param (
    [Parameter(Mandatory)]
    [ValidateSet("stable", "beta", "nightly")]
    [String]
    $train,
    [String]
    $username,
    [String]
    $password
)

$ErrorActionPreference = "Stop"

Invoke-WebRequest `
    -OutFile ".\channel-rust-${train}.toml" `
    -Uri "https://static.rust-lang.org/dist/channel-rust-${train}.toml"
$latestToolchainVer = ( `
        Select-String `
            -Path ".\channel-rust-${train}.toml" `
            -Pattern "\[pkg.rustc]" `
            -Context 0,1 `
        | Select-Object -Expand Context `
        | Select-Object -Expand PostContext `
        | Select-String -Pattern "version" `
        | Out-String -Stream `
    ).split('"')[2].trim()
echo "--> Latest toolchain version: rustc $latestToolchainVer"

docker pull yodal/rust-windows:${train}
if($LASTEXITCODE) {
    exit $LASTEXITCODE
}
$currentImageVer = ( `
        (docker run --rm yodal/rust-windows:${train} rustc -V) `
        | Select-String -Pattern "rustc" `
        | Select-Object -Expand Line `
    ).trim()
if($LASTEXITCODE) {
    exit $LASTEXITCODE
}
echo "--> Current image toolchain version: $currentImageVer"

if("rustc $latestToolchainVer" -ne "$currentImageVer") {
    echo "--> Image is out-of-date, rebuilding iamge"

    docker build -t yodal/rust-windows:${train} -f .\${train}\Dockerfile .
    if($LASTEXITCODE) {
        exit $LASTEXITCODE
    }

    if($username -and $password) {
        docker login -u $username -p $password
        if($LASTEXITCODE) {
            exit $LASTEXITCODE
        }

        docker push yodal/rust-windows:${train}
        if($LASTEXITCODE) {
            exit $LASTEXITCODE
        }

        if($train -eq "stable") {
            docker tag yodal/rust-windows:stable yodal/rust-windows:latest
            if($LASTEXITCODE) {
                exit $LASTEXITCODE
            }
            docker push yodal/rust-windows:latest
            if($LASTEXITCODE) {
                exit $LASTEXITCODE
            }
        }
    } else {
        echo "--> Docker username or password not set"
        exit 1
    }
} else {
    echo "--> Image is up-to-date, no need to rebuild"
}
