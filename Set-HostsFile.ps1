param(
    [Parameter(
        Mandatory=$true)]
    [string[]]$Computer,
    
    [Parameter(
        Mandatory=$true)]
    [string[]]$Block,

    # [string[]]$Allow
)

$BlockList = New-Object System.Collections.ArrayList # list of sites to block
$BlockExcludes = New-Object System.Collections.ArrayList # $blocklist sites already blocked
$TargetHostsFile = "\\$Computer\c$\Windows\system32\drivers\etc\hosts"
$SiteDict = @{
    "facebook" =    "127.0.0.1       www.facebook.com";
    "xfinity" =     "127.0.0.1       www.xfinity.com";
    "craigslist" =  "127.0.0.1       www.craigslist.org";
    "hbogo" =       "127.0.0.1       www.play.hbogo.com"
}

foreach ($comp in $Computer) {
    foreach ($site in $Block) {
        if ($SiteDict.ContainsKey($site)) {
            $BlockList.Add($SiteDict.Get_Item($site)) | out-null
        }
    }

    if (Test-Path $TargetHostsFile) {
        $HostsContent = Get-Content $TargetHostsFile
        foreach ($entry in $BlockList) {
            if ($HostsContent | Select-String -Pattern "$entry" ) {
                $BlockExcludes.Add("$entry") | out-null
                Write-Debug -Message "Found entry -->   `"$entry`"   --Adding to Exclude List"
            }
        }
        foreach ($entry in $BlockExcludes) {
            $BlockList.Remove($entry)
        }
        Add-Content $TargetHostsFile -Value $BlockList
    }
    else {
        Write-Error -Message "Hosts file not accessible on target: $Computer" -Category ObjectNotFound -ErrorAction Stop
    }
}