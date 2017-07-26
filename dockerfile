FROM microsoft/windowsservercore

MAINTAINER txstudio

WORKDIR /

# Install IIS Web-Server
RUN powershell -Command Add-WindowsFeature Web-Server

RUN net stop was /y

# 複製安裝檔到 image 中
ADD ./requestRouter_amd64.msi /
ADD ./rewrite_amd64_en-US.msi /

RUN msiexec /i "requestRouter_amd64.msi" /q /log foo.log
RUN msiexec /i "rewrite_amd64_en-US.msi" /q /log foo.log

# 啟用 IIS proxy 服務
RUN @powershell C:\Windows\System32\inetsrv\appcmd.exe set config -section:proxy /enabled:true /commit:apphost
RUN @powershell C:\Windows\System32\inetsrv\appcmd.exe set config -section:proxy /reverseRewriteHostInResponseHeaders:false /commit:apphost

RUN @powershell restart-service was -force

#複製 web.config 到主要網站目錄
ARG config_path=.
ADD ${config_path} /inetpub/wwwroot/web.config

#此指令是避免 container 啟用後會直接結束
CMD ["ping","localhost","-t"]

#請將 web.config 設定檔案放到 build 資料夾中
#docker build -t <image_name>:<image_tag> . --build-arg config_path=web.config