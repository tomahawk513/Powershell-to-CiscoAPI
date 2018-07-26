### New Site Creation Script ###
$URI = "https://gob-cucm-1.andersonsinc.com:8443/axl/"
$username = "AXL USERNAME GOES HERE"
$password = "PASSWORD GOES HERE"
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username,$password)))
### DO NOT CHANGE ABOVE ###
$USERID = Read-host -Prompt "Enter the User-ID of the person whose phone you want to add lines."
if ($USERID.Length -eq 8){
    $USER = Get-ADUser $USERID -Properties * -ErrorAction Ignore | ?{$_.samaccountname -notlike "*_EL"}
    While($USER -eq $null){
        $USERID = Read-Host -prompt "$USERID could not be found, please try again."
        $USER = Get-ADUser $USERID -Properties * -ErrorAction Ignore
        }

$APIgetUSER = [xml]@"
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/11.5">
<soapenv:Header/>
<soapenv:Body>
<ns:getUser>
<userid>$USERID</userid>
</ns:getUser>
</soapenv:Body>
</soapenv:Envelope>
"@
$getUser = Invoke-RestMethod -Uri $URI  -body $APIgetUSER -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType “Text/XML” -Method post -ErrorAction Ignore
#$getUser.OuterXml
$SEPexists = $getUser.OuterXml -like "*SEP*"
$SEPexists -eq 1
if ($SEPexists -eq 0){
    Write-Host "$USERID Does not have an associated desk phone."
    }
### Updated the way I sort out SEP Phones ###
if ($SEPexists -eq 1){
    $strText = $getUser.OuterXml
    $pattern = "<device>SEP\w\w\w\w\w\w\w\w\w\w\w\w</device>"
    $mc = [regex]::matches($strText, $pattern)
    foreach ($UserPhone in $mc){
        $yn = read-host -Prompt "Do you want to update $UserPhone [Y/N]?"
        if ($yn -like "N"){
            Write-Host "Okay, moving to the next phone..."
            }
        if ($yn -like "Y"){
            $Number = Read-Host -Prompt "Enter the E.164 (+1XXXYYYZZZZ) number or 8-digit Extension you would like to add to the phone. Leave blank to stop."
            While ($Number -ne ""){
            if ($Number.Length -ne 8){
                $Number = "\$Number"
                }
$APIgetPHONE = [xml]@"
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/11.5">
<soapenv:Header/>
<soapenv:Body>
<ns:getPhone>
<name>$UserPhone</name>
</ns:getPhone>
</soapenv:Body>
</soapenv:Envelope>
"@
$getPhone = Invoke-RestMethod -Uri $URI  -body $APIgetPHONE -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType “Text/XML” -Method post -ErrorAction Ignore
$strText = $getPhone.OuterXml
$pattern = "<index>\w</index>"
$mc = [regex]::matches($strText, $pattern)
$mc = $mc | Sort-Object value
$index = 1
$newv = $null
foreach ($value in $mc){
    $v = $value.value
    $v = $v.Replace("<index>","")
    $v = $v.Replace("</index>","")
    #$newv += $v
    $index -eq $v
    while ($index -eq $v){
        $index = $index+1
        }
    }
$APIgetLine = [xml]@"
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/11.5">
<soapenv:Header/>
<soapenv:Body>
<ns:getLine>
<pattern>$Number</pattern>
<routePartitionName>AllPhones</routePartitionName>
</ns:getLine>
</soapenv:Body>
</soapenv:Envelope>
"@
$getLine = Invoke-RestMethod -Uri $URI  -body $APIgetLine -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType “Text/XML” -Method post -ErrorAction Ignore
$LineOuterXML = $getLine.outerXML
$DESC = $LineOuterXML | select-string -pattern "(?<=<description>)(.*)(?=\</description>)" | ForEach-Object {$_.Matches.Groups[1].value}
#$DESC
$ALTN = $LineOuterXML | select-string -pattern "(?<=<alertingName>)(.*)(?=\</alertingName>)" | ForEach-Object {$_.Matches.Groups[1].value}
#$ALTN
$asciiALTN = $ALTN
$LABL = $ALTN
$DISP = $ALTN
$UserPhone
$APIupdatePHONE = [xml]@"
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/11.5">
<soapenv:Header/>
<soapenv:Body>
<ns:updatePhone>
<name>$UserPhone</name>
<addLines>
<line>
<dirn>
<pattern>$Number</pattern>
<routePartitionName>AllPhones</routePartitionName>
</dirn>
<index>$index</index>
<label>$LABL</label>
<display>$DISP</display>
<displayAscii>$asciiALTN</displayAscii>
</line>
</addLines>
</ns:updatePhone>
</soapenv:Body>
</soapenv:Envelope>
"@
$updatePhone = Invoke-RestMethod -Uri $URI  -body $APIupdatePHONE -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType “Text/XML” -Method post -ErrorAction Ignore

$Number = Read-Host -Prompt "Enter the E.164 (+1XXXYYYZZZZ) number you would like to add to the phone. Leave blank to stop."
                }
            }
        }
    }
