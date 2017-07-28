# 使用 IIS 進行反向代理 (reserve-proxy) dockerfile 範例
- 此方法建立的 docker image 僅適用於 http 80 連接埠的情境
- 此方法建立的 docker image 尚未使用於生產環境

## 檔案說明
### dockerfile
建置 image 使用的設定檔，基底 image 使用 microsoft/windowsservercore

### requestRouter_amd64.msi
Microsoft Application Request Routing 3.0 (x64) 安裝檔

https://www.microsoft.com/en-ph/download/details.aspx?id=47333

### rewrite_amd64_en-US.msi
Microsoft URL Rewrite Module 2.0 for IIS 7 (x64) 安裝檔

https://www.microsoft.com/en-us/download/details.aspx?id=7435

### install.ps1
依參數設定 reserve-proxy 的 powershell 指令碼

### config-template.xml
為網站設定 URL Rewrite 功能的 web.config 檔案範本

## 設定說明
建立 container 時設定 rewritesSetting 參數，會依設定內容建立對應的 reserve-proxy 反向代理對應

rewritesSetting 設定範例
```
  [
	{
		'site':'app01',
		'domain':'app01.txstudio.tw',
		'rewrite':'172.19.83.203'
	},
	{
		'site':'app02',
		'domain':'app02.txstudio.tw',
		'rewrite':'172.19.89.1'
	}
  ]
```

網域|內部位址
--|--
app01.txstudio.tw|172.19.83.203
app02.txstudio.tw|172.19.89.1

> 此設定項目可依照實際需求進行調整


## 使用說明

1. 將相關檔案與 dockerfile 放置到指定資料夾後，於資料夾目錄下執行 docker build 指令
```
  docker build -t iis-reserve-proxy:1 . --build-arg config_path=web.config
```
> config_path 參數為設定反向代理 (reserv-proxy) 設定檔案的參數，確認檔案是否存在於當下目錄中。

2. 將 image 啟用為新的 container
```
  docker run -d --name iis-reserve-proxy-sample -p 80:80 iis-reserve-proxy:1
```

## dockerfile 步驟說明
1. 安裝 IIS 功能
2. 將 ARR 與 URL Rewrite 的安裝檔案複製到 Container 中
3. 透過 msiexec 指令安裝 ARR 與 URL Rewrite 的 IIS 擴充功能
4. 透過 appcmd.exe 指令啟用 IIS 的 proxy 服務
5. 建立 container 時執行 install.ps1 指令碼並依參數於 IIS 設定 reserve-proxy 


## 參考資料
https://github.com/Microsoft/Virtualization-Documentation/tree/master/windows-container-samples/iis-arr
