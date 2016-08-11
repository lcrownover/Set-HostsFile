param(
    [Parameter(
        Mandatory=$true)]
    [string]$Computer,
    
    [Parameter(
        Mandatory=$true)]
    [System.Collections.ArrayList]$Block
)

$BlockEntries = New-Object -TypeName System.Collections.ArrayList #build list
$BlockList = New-Object -TypeName System.Collections.ArrayList #used because i cant edit blockentries in place
$TargetHostsFile = "\\$Computer\c$\Windows\drivers\etc\hosts"
$BlockDict = @{
    "facebook" =    "127.0.0.1       www.facebook.com";
    "xfinity" =     "127.0.0.1       www.xfinity.com";
    "craigslist" =  "127.0.0.1       www.craigslist.org";
    "hbogo" =       "127.0.0.1       www.play.hbogo.com"
}

foreach ($site in $Block) {
    if ($BlockDict.ContainsKey($site)) {
        $BlockEntries.Add($BlockDict.Get_Item($site)) | out-null
        $BlockList.Add($BlockDict.Get_Item($site)) | out-null
    }
}

# foreach ($i in $BlockEntries) {
#     write-output "debug: blockentries contains -->    $i"
# } write-output ""


if (Test-Path $TargetHostsFile) {
    $HostsContent = Get-Content $TargetHostsFile
    foreach ($i in $BlockEntries) {
        if ($HostsContent | Select-String -Pattern "$i" ) {
            $BlockList.Remove("$i")
            # write-output "debug: found -->   $i   --removing from final list"
        }
    }
    # write-output $BlockList
    Add-Content $TargetHostsFile -Value $BlockList
}
