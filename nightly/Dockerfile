FROM mcr.microsoft.com/windows/servercore:ltsc2019

SHELL ["cmd", "/S", "/C"]

# Install the Visual Studio Build Tools.
ADD https://aka.ms/vs/16/release/vs_buildtools.exe /vs_buildtools.exe
RUN vs_buildtools.exe --quiet --wait --norestart --nocache \
        --installPath C:\BuildTools \
        --add Microsoft.Component.MSBuild \
        --add Microsoft.VisualStudio.Component.Windows10SDK.17763 \
        --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 \
    || IF "%ERRORLEVEL%"=="3010" EXIT 0
RUN del vs_buildtools.exe
RUN setx /M __VSCMD_ARG_NO_LOGO "1"

ENTRYPOINT ["powershell.exe", "-NoLogo", "-ExecutionPolicy", "Bypass"]

# Install Rustup and Rust toolchains for x86 and x64
ADD https://static.rust-lang.org/rustup/dist/x86_64-pc-windows-msvc/rustup-init.exe /rustup-init.exe
RUN rustup-init.exe -y -v --default-toolchain nightly --default-host x86_64-pc-windows-msvc
RUN del rustup-init.exe
RUN rustup toolchain install nightly-i686-pc-windows-msvc

RUN rustup +nightly-x86_64-pc-windows-msvc -V & \
    cargo +nightly-x86_64-pc-windows-msvc -V & \
    rustc +nightly-x86_64-pc-windows-msvc -V & \
    rustup +nightly-i686-pc-windows-msvc -V & \
    cargo +nightly-i686-pc-windows-msvc -V & \
    rustc +nightly-i686-pc-windows-msvc -V
