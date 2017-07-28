param(
[Parameter(Mandatory=$false)]
[string]$rewritesSetting
)

Set-Location $env:windir\\system32\\inetsrv\\

$rewritesJson= $rewritesSetting.TrimStart('\\').TrimEnd('\\')

Write-Verbose "Passed in rewrite configuration is: $($rewritesJson)"

$rewrites = ConvertFrom-Json $rewritesJson

$path_config_template = "C:\config-template.xml"
$path_root = "C:\inetpub\"
$path_config = ""
$path = ""

$xml_template = (Get-Content $path_config_template)
$xml_config = ""


# Remove "Default Web Site"
.\appcmd.exe delete site "Default Web Site"
Remove-Item -Recurse "C:\inetpub\wwwroot"

if ($null -ne $rewrites -And $rewrites.Length -gt 0)
{
	Write-Verbose "Configuring Rewrite - $($rewrites.length)"
	
	$index = 0
    $bindings = ""
    $site = ""
	
	ForEach($rewrite in $rewrites)
	{
		$index = $index + 1
        $bindings = ("http://"+ $rewrite.domain + ":80")
        $site = $rewrite.site

	
		# Create Site folder
		$path = $path_root + $rewrite.site
		mkdir $path
        
        Write-Verbose "create site"
        Write-Verbose "-------"
        Write-Verbose $index
        Write-Verbose $site
        Write-Verbose $bindings
        Write-Verbose $path
        Write-Verbose "-------"
		
		# Configuring Rewrite Url Setting
		$path_config = $path + "\web.config"
		$xml_config = $xml_template.replace("{name}",$rewrite.site).replace("{ip}",$rewrite.rewrite)
		
		Add-Content -Path $path_config -Value $xml_config -Encoding UTF8		
	
		# Create Site
		.\appcmd.exe add site /name:$site /id:$index /bindings:$bindings /physicalPath:$path		
	}
}

# Prevent Exit Container
while ($true) { Start-Sleep -Seconds 3600 }
