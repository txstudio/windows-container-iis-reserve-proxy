FROM microsoft/windowsservercore

MAINTAINER txstudio

WORKDIR /

ENV rewritesSetting "[]"

# install IIS Web-Server
RUN powershell -Command Add-WindowsFeature Web-Server

RUN net stop was /y

# copy install/setting file to image
ADD ./requestRouter_amd64.msi /
ADD ./rewrite_amd64_en-US.msi /
ADD ./install.ps1 /
ADD ./config-template.xml /

RUN msiexec /i "requestRouter_amd64.msi" /q /log foo.log
RUN msiexec /i "rewrite_amd64_en-US.msi" /q /log foo.log

# enable iis proxy service
RUN @powershell C:\Windows\System32\inetsrv\appcmd.exe set config -section:proxy /enabled:true /commit:apphost
RUN @powershell C:\Windows\System32\inetsrv\appcmd.exe set config -section:proxy /reverseRewriteHostInResponseHeaders:false /commit:apphost

RUN @powershell restart-service was -force

# remove install use package
RUN @powershell Remove-Item "C:\requestRouter_amd64.msi"
RUN @powershell Remove-Item "C:\rewrite_amd64_en-US.msi"
RUN @powershell Remove-Item "C:\foo.log"

# use powershell script configuring rewrite url
CMD powershell ./install.ps1 -rewritesSetting \"%rewritesSetting%\" -Verbose

#docker build -t <image_name>:<image_tag> .
