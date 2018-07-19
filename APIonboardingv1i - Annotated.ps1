#v1f changes: checks CUC for EXT and User ID before allowing script to run.  
#v1h changes: add Remote Destination Profile (RDP) - allows Single-Number-Reach self-enrollment.
#v1i changes: allow ipPhone to contain 81XXXXXX numbers.  
### Script to add new phone to user ###
$URI = "https://gob-cucm-1.andersonsinc.com:8443/axl/"
$username = "AXLADMIN"
$password = "rents-8TExwW"
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username,$password)))
#Invoke-RestMethod -Uri $URI -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} 
### DO NOT CHANGE ABOVE ###
### I have another script that loads a list of all possible DIDs/DNs and checks route plan report.  Available DNs in files below. ###
### Import available COB DIDs ###
$COBDIDsFILE = "C:\scripts\COBdids.txt"
$HUDDNsFILE = "C:\scripts\HUDDNs.txt"
#$HumDNsFILE = "C:\scripts\HUMDNs.txt"
$WebDNsFILE = "C:\scripts\WEBDNs.txt"
$UppDNsFILE = "C:\scripts\UPPDNs.txt"
$LchDNsFILE = "C:\scripts\LCHDNs.txt"
$DelDNsFILE = "C:\scripts\DELDNs.txt"
$EdwDNsFILE = "C:\scripts\EDWDNs.txt"
#$KlmDNsFILE = "C:\scripts\KLMDNs.txt"
$LorDNsFILE = "C:\scripts\LORDNs.txt"
$CarDNsFILE = "C:\scripts\CARDNs.txt"
$SCCDNsFILE = "C:\scripts\SCCdids.txt"
$SCFDNsFILE = "C:\scripts\SCFdids.txt"
$SGTDNsFILE = "C:\scripts\SGTdids.txt"
$COLDNsFILE = "C:\scripts\COLDNs.txt"
$METDNsFILE = "C:\scripts\METDNs.txt"
$BGRDNsFILE = "C:\scripts\BGRDNs.txt"
### Arranges DIDs/DNs in an array
[System.Collections.ArrayList]$COBDIDs = Get-Content $COBDIDsFILE
[System.Collections.ArrayList]$HUDDNs = Get-Content $HUDDNsFILE
#[System.Collections.ArrayList]$HUMDNs = Get-Content $HumDNsFILE
[System.Collections.ArrayList]$WEBDNs = Get-Content $WebDNsFILE
[System.Collections.ArrayList]$UPPDNs = Get-Content $UppDNsFILE
[System.Collections.ArrayList]$LCHDNs = Get-Content $LchDNsFILE
[System.Collections.ArrayList]$DELDNs = Get-Content $DelDNsFILE
[System.Collections.ArrayList]$EDWDNs = Get-Content $EdwDNsFILE
#[System.Collections.ArrayList]$KLMDNs = Get-Content $KlmDNsFILE
[System.Collections.ArrayList]$LORDNs = Get-Content $LorDNsFILE
[System.Collections.ArrayList]$CARDNs = Get-Content $CarDNsFILE
[System.Collections.ArrayList]$SCCdids = Get-Content $SCCDNsFILE
[System.Collections.ArrayList]$SCFdids = Get-Content $SCFDNsFILE
[System.Collections.ArrayList]$SGTdids = Get-Content $SGTDNsFILE
[System.Collections.ArrayList]$COLdids = Get-Content $COLDNsFILE
[System.Collections.ArrayList]$METDNs = Get-Content $METDNsFILEb
[System.Collections.ArrayList]$BGRDNs = Get-Content $BGRDNsFILE
### END Import ###
### All COB DIDs Database ###
$COBDNs891all2600 = @(2601..2639)
$COBDNs891all2700 = @(2701..2799)
$COBDNs891all2900 = @(2901..2999)
$COBDNs891all4400 = @(4401..4499)
$COBDNs891all6300 = @(6301..6399)
$COBDNs891all6400 = @(6401..6499)
$COBDNs891all6500 = @(6501..6599)
$COBDNs891all6600 = @(6601..6699)
$COBDNs891all5800 = @(5800..5899)
$COBDNs897all6700 = @(6700..6799)
$COBDNs897all3100 = @(3101..3114)
$COBDNs897all3122 = @(3122..3127)
$COBDNs897all3140 = @(3140..3146)
$COBDNs897all3184 = @(3184)
$COBDNs897all3187 = @(3187)
$COBDNs897all3189 = @(3189..3199)
$COBDNs897all3245 = @(3145..3258)
$COBDNs897all3640 = @(3640..3646)
$COBDNs897all3670 = @(3670..3699)
$COBDNs482all5000 = @(5000..5499)
$COBDNs482all5900 = @(5900..5999)
$COBDNs887all6060 = @(6060..6099)
$COBDNs887all6100 = @(6100..6159)
$COBDNs891all = (
    ($COBDNs891all2600)+
    ($COBDNs891all2700)+ 
    ($COBDNs891all2900)+
    ($COBDNs891all4400)+
    ($COBDNs891all6300)+
    ($COBDNs891all6400)+
    ($COBDNs891all6500)+
    ($COBDNs891all6600)+
    ($COBDNs891all5800)
    )
$COBDNs897all = (
    ($COBDNs897all6700)+
    ($COBDNs897all3100)+
    ($COBDNs897all3122)+
    ($COBDNs897all3140)+
    ($COBDNs897all3184)+
    ($COBDNs897all3187)+
    ($COBDNs897all3189)+
    ($COBDNs897all3245)+
    ($COBDNs897all3640)+
    ($COBDNs897all3670)
    )
$COBDNs482all = (
    ($COBDNs482all5000)+
    ($COBDNs482all5900)
    )
$COBDNs887all = (
    ($COBDNs887all6060)+
    ($COBDNs887all6100)
    )
$COBDNsall = $COBDNs891all+$COBDNs897all+$COBDNs482all+$COBDNs887all
### END All COB DIDs Database ###
### Main Numbers for Remote Sites w/o DIDs ###
$HudMain = "5174482050"
$HumMain = "7317843213"
$WebMain = "5175214627"
$UppMain = "8556627326"
$LchMain = "5175422996"
$DelMain = "5675646132"
$EdwMain = "4192436800"
$KlmMain = "4192415411"
$LorMain = "8886950024"
$CarMain = "4193963501"
$MetMain = "4196444711"
### END Main Numbers ###
### BASE file requires ANDID (samaccountname), PhoneType (7841, 8841, etc), Location (3-letter). Extension and Phone (MAC) optional.
$file = "C:\Scripts\NewPhone\BASE.csv"
$BASE = Import-Csv $file
foreach ($entry in $BASE){
    $ANDID = $null 
    $ANDID = $entry.ANDID
    $EXT = $null
    $EXT = $entry.EXT
    $PHONE = $null
    $PHONE = $entry.PHONE.ToUpper()
    ### Random Number If Necessary ###
    $RNUM = Get-Random -Minimum 100000000000 -Maximum 999999999999 
    $PHONETYPE = $null
    $PHONETYPE = $entry.PHONETYPE
	$FN = $null
	$LN = $null
    $DIDper = $null
    $USER = $null
    ### Check to see if ANDID is an actual active ID, or just a description of the phone to be deployed. ###
    $USER = get-aduser $ANDID -Properties * -ErrorAction Ignore
    $LOC = $entry.LOCATION
    if ($USER -ne "" -and $USER -ne $null){
        $OWNR = $ANDID
        $OWNR = $OWNR.ToUpper()
        $FN = $user.GivenName
        $LN = $user.sn
        $CITY = $user.l
        $ADDR = $user.StreetAddress
        $RDP = "RDP-$OWNR"
        ### Because we have multiple sites in the same "city" I have to narrow it down by actual address. ###
        if (($CITY -like "Maumee*" -and $ADDR -like "1947*") -or ($LOC -like "COB")){
            $SITE = "COB"
            ### UUID for Unity Voicemail Partition for COB - Will probably replace w/ a query for the partition then get UUID from OuterXML data. ###
            $VMPT = "8460732c-d74b-424d-be8b-213011e9ffd4"
            ### First four of site's 8-digit EXT. ###
            $EXTS = "8100"
            ### If extension is listed... ###
            if ($EXT -ne ""){
                $EXT4 = $EXT.substring($EXT.Length - 4)
                if ($CITY -like "Maumee*" -and ($EXT.substring(0,4) -like "8100" -or $EXT.length -eq 4)){
                    if ($COBDNs891all -contains $EXT4){
                        $DIDper = "%+1419891$EXT4"
                        $DID = "\+1419891$EXT4"
                        }
                    if ($COBDNs897all -contains $EXT4){
                        $DIDper = "%+1419897$EXT4"
                        $DID = "\+1419897$EXT4"
                        }
                    if ($COBDNs482all -contains $EXT4){
                        $DIDper = "%+1419482$EXT4"
                        $DID = "\+1419482$EXT4"
                        }
                    if ($COBDNs887all -contains $EXT4){
                        $DIDper = "%+1419887$EXT4"
                        $DID = "\+1419887$EXT4"
                        }
                    }
                if ($CITY -like "Maumee*" -and $EXT.substring(0,4) -notlike "8100" -and $EXT -ne ""){
                    $EXT7 = $EXT.substring($EXT.Length - 7)
                    $DIDper = "%+1419$EXT7"
                    $DID = "\+1419$EXT7"
                    }
                }
            ### If extension is not listed, use one pulled in from COB file, then remove it from array. ###
            ($CITY -like "Maumee*" -or $LOC -like "COB") -and $EXT -eq ""
            if ($EXT -eq ""){
                $EXT = $COBDIDs | select -First 1
                $COBDIDs.RemoveAt(0)
                $DIDper = "%$EXT"
                $DID = "\$EXT"
                }
            }
        if (($CITY -like "Maumee*") -and ($ADDR -notlike "1947*")){g
            $SITE = "COB"
            $VMPT = "4d9703bb-adc1-4cb0-aa46-56957fbb243e"
            $EXTS = "8100"
            if ($EXT -ne ""){
                $EXT4 = $EXT.substring($EXT.Length - 4)
                if ($COBDNs891all -contains $EXT4){
                    $DIDper = "%+1419891$EXT4"
                    $DID = "\+1419891$EXT4"
                    }
                if ($COBDNs897all -contains $EXT4){
                    $DIDper = "%+1419897$EXT4"
                    $DID = "\+1419897$EXT4"
                    }
                if ($COBDNs482all -contains $EXT4){
                    $DIDper = "%+1419482$EXT4"
                    $DID =b "\+1419482$EXT4"
                    }
                if ($COBDNs887all -contains $EXT4){
                    $DIDper = "%+1419887$EXT4"
                    $DID = "\+1419887$EXT4"
                    }
                if ($CITY -like "Maumee*" -and $EXT.substring(0,4) -notlike "8100" -and $EXT -ne ""){
                    $EXT7 = $EXT.substring($EXT.Length - 7)
                    $DIDper = "%+1419$EXT7"
                    $DID = "\+1419$EXT7"
                    }
                }
            if ($EXT -eq ""){
                $EXT = $COBDIDs | select -First 1
                $COBDIDs.RemoveAt(0)
                $DIDper = "%$EXT"
                $DID = "\$EXT"
                }
            }
        if (($CITY -like "Toledo*") -and ($ADDR -like "125*")){
            $SITE = "EDW"
            $VMPT = "4d9703bb-adc1-4cb0-aa46-56957fbb243e"
            $EXMask = $EdwMain
            $EXTS = "8111"
            if ($EXT -ne ""){
                $EXT4 = $EXT.substring($EXT.Length - 4)
                $DID = "$EXTS$EXT4"
                }
            if ($EXT -eq ""){
                $EXT = $EdwDNs | select -First 1
                $DELDNs.RemoveAt(0)
                $DID = "$EXT"
                }
            }
        if (($CITY -like "Toledo*") -and ($ADDR -like "440*")){
            $SITE = "KLM"
            $EXTS = "8101"
            $VMPT = "056a4889-170b-47bf-b3eb-7122ea3a7804"
            $EXMask = $KlmMain
            }
        if (($CITY -like "Delphi*")){
            $SITE = "DEL"
            $VMPT = "24417474-b464-4547-8244-969bf792e256"
            $EXTS = "8110"
            $EXMask = $DelMain
            if ($EXT -ne ""){
                $EXT4 = $EXT.substring($EXT.Length - 4)
                $DID = "$EXTS$EXT4"
                }
            if ($EXT -eq ""){
                $EXT = $DELDNs | select -First 1
                $DELDNs.RemoveAt(0)
                $DID = "$EXT"
                }
            }
        if (($CITY -like "Litchfield*")){
            $SITE = "LCH"
            $VMPT = "9d29f972-aabd-4367-b859-3b149ee2185c"
            $EXTS = "8107"
            $EXMask = $LchMain
            if ($EXT -ne ""){
                $EXT4 = $EXT.substring($EXT.Length - 4)
                $DID = "$EXTS$EXT4"
                }
            if ($EXT -eq ""){
                $EXT = $LCHDNs | select -First 1
                $LCHDNs.RemoveAt(0)
                $DID = "$EXT"
                }
            }
        if (($CITY -like "Hudson*")){
            $SITE = "HUD"
            $VMPT = "a1889357-81f6-47c0-b23f-252dede26b4a"
            $EXTS = "8106"
            $EXMask = $HudMain
            if ($EXT -ne ""){
                $EXT4 = $EXT.substring($EXT.Length - 4)
                $DID = "$EXTS$EXT4"
                }
            if ($EXT -eq ""){
                $EXT = $HUDDNs | select -First 1
                $HUDDNs.RemoveAt(0)
                $DID = "$EXT"
                }
            }
        if (($CITY -like "Webberville*")){
            $SITE = "WEB"
            $VMPT = "1ffa0ea3-f3fb-4a8d-98f7-bcb51d8fef81"
            $EXTS = "8105"
            $EXMask = $WebMain
            if ($EXT -ne ""){
                $EXT4 = $EXT.substring($EXT.Length - 4)
                $DID = "$EXTS$EXT4"
                }
            if ($EXT -eq ""){
                $EXT = $WEBDNs | select -First 1
                $WEBDNs.RemoveAt(0)
                $DID = "$EXT"
                }
            }
        if (($CITY -like "Bowling*")-or ($LOC -like "BGR")){
            $SITE = "BGR"
            $VMPT = "cd16fbf2-a713-45b0-803d-a4c703528351"
            $EXTS = "8112"
            $EXMask = $BGRMain
            if ($EXT -ne ""){
                $EXT4 = $EXT.substring($EXT.Length - 4)
                $DID = "$EXTS$EXT4"
                }
            if ($EXT -eq ""){
                $EXT = $BGRDNs | select -First 1
                $BGRDNs.RemoveAt(0)
                $DID = "$EXT"
                }
            }
        if (($CITY -like "Metamora*") -or ($LOC -like "MET")){
            $SITE = "MET"
            $VMPT = "a848c571-c889-4eed-8bc0-f7edbb0b62af"
            $EXTS = "8113"
            $EXMask = $MetMain
            if ($EXT -ne ""){
                $EXT4 = $EXT.substring($EXT.Length - 4)
                $DID = "$EXTS$EXT4"
                }
            if ($EXT -eq ""){
                $EXT = $METDNs | select -First 1
                $METDNs.RemoveAt(0)
                $DID = "$EXT"
                }
            }
        if (($CITY -like "Carey*")){
            $SITE = "CAR"
            $VMPT = "46149a4e-757b-49e6-b5c9-8698bfc17ebd"
            $EXTS = "8104"
            $EXMask = $CarMain
            if ($EXT -ne ""){
                $EXT4 = $EXT.substring($EXT.Length - 4)
                $DID = "$EXTS$EXT4"
                }
            if ($EXT -eq ""){
                $EXT = $CARDNs | select -First 1
                $CARDNs.RemoveAt(0)
                $DID = "$EXT"
                }
            }
        if (($CITY -like "Upper*")){
            $SITE = "UPP"
            $VMPT = "419a759d-29f6-4a09-8d93-71319f85f15c"
            $EXTS = "8103"
            $EXMask = $UppMain
            if ($EXT -ne ""){
                $EXT4 = $EXT.substring($EXT.Length - 4)
                $DID = "$EXTS$EXT4"
                }
            if ($EXT -eq ""){
                $EXT = $UPPDNs | select -First 1
                $UPPDNs.RemoveAt(0)
                $DID = "$EXT"
                }
            }
        if (($CITY -like "Lordstown*")){
            $SITE = "LOR"
            $VMPT = "bf10c920-677c-4a9b-9369-ed79811cbbed"
            $EXTS = "8109"
            $EXMask = $LorMain
            if ($EXT -ne ""){
                $EXT4 = $EXT.substring($EXT.Length - 4)
                $DID = "$EXTS$EXT4"
                }
            if ($EXT -eq ""){
                $EXT = $LORDNs | select -First 1
                $LORDNs.RemoveAt(0)
                $DID = "$EXT"
                }
            }
        if (($CITY -like "Colwich") -or ($LOC -like "COL")){
            $SITE = "COL"
            $VMPT = "3cd41dd8-a2e9-4587-8e37-7c4f1ea4c863"
            $EXTS = "8114"
            if ($EXT -eq ""){
                $EXT = $COLdids | select -First 1
                $COLdids.removeat(0)
                $EXT4 = $EXT.substring($EXT.Length - 4)
                $DIDper = "%$EXT"
                $DID = "\$EXT4"
                }
            }
        if (($CITY -like "*Sioux City*") -or ($CITY -like "*Bluff")){ #This includes North Sioux City, take this out once converted.
            if ($LOC -like "SCF"){
                $SITE = "SCF"
                $VMPT = "4f48e75c-3ecc-4ac3-88f6-4fb66766b49a"
                $EXTS = "8121"
                if ($EXT -eq ""){
                    $EXT = $SCFdids | select -First 1
                    $SCFdids.removeat(0)
                    $EXT4 = $EXT.substring($EXT.Length - 4)
                    $DIDper = "%+1712454$EXT4"
                    $DID = "\+1712454$EXT4"
                    }
                }
            if ($LOC -like "SCC"){
                $SITE = "SCC"
                $VMPT = "c34e1025-8e77-4aa0-867b-cc6f46f1d504"
                $EXTS = "8120"
                if ($EXT -eq ""){
                    $EXT = $SCCdids | select -First 1
                    $SCCdids.removeat(0)
                    $EXT4 = $EXT.substring($EXT.Length - 4)
                    $DIDper = "%+1712454$EXT4"
                    $DID = "\+1712454$EXT4"
                    }
                }
            if ($LOC -like "SGT"){
                $SITE = "SGT"
                $VMPT = "5b35e21c-61cf-4768-844b-f8be722009f2"
                $EXTS = "8122"
                if ($EXT -eq ""){
                    $EXT = $SGTdids | select -First 1
                    $SGTdids.removeat(0)
                    $EXT4 = $EXT.substring($EXT.Length - 4)
                    $DIDper = "%+1712454$EXT4"
                    $DID = "\+1712454$EXT4"
                    }
                }
            ### Since SCF, SCC, and SGT all split a group of DIDs, don't need location 4-digit prefix info to determine extension.  Remove last 4 digits, use those.  ###
            if ($EXT -ne ""){
                $EXT4 = $EXT.substring($EXT.Length - 4)
                $DIDper = "%+1712454$EXT4"
                $DID = "\+1712454$EXT4"
                }
            }
        ### In case there are any irregularities with names like spaces. ###
		$NMDL = $LN.Replace(" ","")
		$NMDL = $LN -replace $nonAZ, ''
        $DSPN = $null
        $DSPN = "$FN $LN"
        #$EXTS = "8100"
        $DURI = $null
        $DURI = $user.EmailAddress
        <#
        if ($EXT -ne ""){
            $EXT4 = $EXT.substring($EXT.Length - 4)
            if ($CITY -like "Maumee*" -and ($EXT.substring(0,4) -like "8100" -or $EXT.length -eq 4)){
                if ($COBDNs891all -contains $EXT4){
                    $DIDper = "%+1419891$EXT4"
                    $DID = "\+1419891$EXT4"
                    }
                if ($COBDNs897all -contains $EXT4){
                    $DIDper = "%+1419897$EXT4"
                    $DID = "\+1419897$EXT4"
                    }
                if ($COBDNs482all -contains $EXT4){
                    $DIDper = "%+1419482$EXT4"
                    $DID = "\+1419482$EXT4"
                    }
                if ($COBDNs887all -contains $EXT4){
                    $DIDper = "%+1419887$EXT4"
                    $DID = "\+1419887$EXT4"
                    }
                }
            if ($CITY -like "Maumee*" -and $EXT.substring(0,4) -notlike "8100" -and $EXT -ne ""){
                $EXT7 = $EXT.substring($EXT.Length - 7)
                $DIDper = "%+1419$EXT7"
                $DID = "\+1419$EXT7"
                }
            }
        if ($CITY -like "Maumee*" -and $EXT -eq ""){
            $EXT = $COBDIDs | select -First 1
            $COBDIDs.RemoveAt(0)
            $DIDper = "%$EXT"
            $DID = "\$EXT"
            }
            #>
        }
    ### If no user found, probably a dummy/anonymous phone. ###
    if ($USER -eq $null){
        #$USER = $ANDID
        $OWNR = ""
        $LN = $ANDID
        $NMDL = $LN.Replace(" ","")
		$NMDL = $LN -replace $nonAZ, ''
        $DSPN = $LN
        $CITY = $LOC.substring(0,3)
        $SITE = switch -Wildcard ($CITY)
            {
                "MAU*" {"MAU"}
                "COB*" {"COB"}
                "EDW*" {"EDW"}
                "KUH*" {"KLM"}
                "KLM*" {"KLM"}
                "DEL*" {"DEL"}
                "LIT*" {"LCH"}
                "LCH*" {"LCH"}
                "BOW*" {"BLG"}
                "BG*" {"BLG"}
                "BLG*" {"BLG"}
                "HUD*" {"HUD"}
                "WEB*" {"WEB"}
                "CAR*" {"CAR"}
                "UPP*" {"UPP"}
                "LOR*" {"LOR"}
                "MET*" {"MET"}
                "SCC" {"SCC"}
                "SCF" {"SCF"}
                "SGT" {"SGT"}
                "SER*" {"SGT"}
            }
        if ($SITE -like "COB"){
            $EXTS = "8100"
            if ($EXT -ne ""){
                $EXT4 = $EXT.substring($EXT.Length - 4)
                if ($SITE -like "COB" -and ($EXT.substring(0,4) -like "8100" -or $EXT.length -eq 4)){
                    if ($COBDNs891all -contains $EXT4){
                        $DIDper = "%+1419891$EXT4"
                        $DID = "\+1419891$EXT4"
                        }
                    if ($COBDNs897all -contains $EXT4){
                        $DIDper = "%+1419897$EXT4"
                        $DID = "\+1419897$EXT4"
                        }
                    if ($COBDNs482all -contains $EXT4){
                        $DIDper = "%+1419482$EXT4"
                        $DID = "\+1419482$EXT4"
                        }
                    if ($COBDNs887all -contains $EXT4){
                        $DIDper = "%+1419887$EXT4"
                        $DID = "\+1419887$EXT4"
                        }
                    }
                if ($SITE -like "COB" -and $EXT.substring(0,4) -notlike "8100" -and $EXT -ne ""){
                    $EXT7 = $EXT.substring($EXT.Length - 7)
                    $DIDper = "%+1419$EXT7"
                    $DID = "\+1419$EXT7"
                    }
                }
            if ($SITE -like "COB" -and $EXT -eq ""){
                $EXT = $COBDIDs | select -First 1
                $COBDIDs.RemoveAt(0)
                $DIDper = "%$EXT"
                $DID = "\$EXT"
                }
            }
        if (($SITE -like "MAU")){
            $SITE = "MAU"
            $VMPT = "4d9703bb-adc1-4cb0-aa46-56957fbb243e"
            $EXTS = "8100"
            if ($EXT -ne ""){
                $EXT4 = $EXT.substring($EXT.Length - 4)
                if ($COBDNs891all -contains $EXT4){
                    $DIDper = "%+1419891$EXT4"
                    $DID = "\+1419891$EXT4"
                    }
                if ($COBDNs897all -contains $EXT4){
                    $DIDper = "%+1419897$EXT4"
                    $DID = "\+1419897$EXT4"
                    }
                if ($COBDNs482all -contains $EXT4){
                    $DIDper = "%+1419482$EXT4"
                    $DID = "\+1419482$EXT4"
                    }
                if ($COBDNs887all -contains $EXT4){
                    $DIDper = "%+1419887$EXT4"
                    $DID = "\+1419887$EXT4"
                    }
                if ($SITE -like "MAU" -and $EXT.substring(0,4) -notlike "8100" -and $EXT -ne ""){
                    $EXT7 = $EXT.substring($EXT.Length - 7)
                    $DIDper = "%+1419$EXT7"
                    $DID = "\+1419$EXT7"
                    }
                }
            if ($EXT -eq ""){
                $EXT = $COBDIDs | select -First 1
                $COBDIDs.RemoveAt(0)
                $DIDper = "%$EXT"
                $DID = "\$EXT"
                }
            }
        if (($SITE -like "EDW")){
            $SITE = "EDW"
            $VMPT = "4d9703bb-adc1-4cb0-aa46-56957fbb243e"
            $EXMask = $EdwMain
            $EXTS = "8111"
            if ($EXT -ne ""){
                $EXT4 = $EXT.substring($EXT.Length - 4)
                $DID = "$EXTS$EXT4"
                }
            if ($EXT -eq ""){
                $EXT = $EdwDNs | select -First 1
                $EDWDNs.RemoveAt(0)
                $DID = "$EXT"
                }
            }
        if (($SITE -like "KLM")){
            $SITE = "KLM"
            $EXTS = "8101"
            $VMPT = "056a4889-170b-47bf-b3eb-7122ea3a7804"
            $EXMask = $KlmMain
            }
        if (($SITE -like "DEL")){
            $SITE = "DEL"
            $VMPT = "24417474-b464-4547-8244-969bf792e256"
            $EXTS = "8110"
            $EXMask = $DelMain
            if ($EXT -ne ""){
                $EXT4 = $EXT.substring($EXT.Length - 4)
                $DID = "$EXTS$EXT4"
                }
            if ($EXT -eq ""){
                $EXT = $DELDNs | select -First 1
                $DELDNs.RemoveAt(0)
                $DID = "$EXT"
                }
            }
        if (($SITE -like "LCH")){
            $SITE = "LCH"
            $VMPT = "9d29f972-aabd-4367-b859-3b149ee2185c"
            $EXTS = "8107"
            $EXMask = $LchMain
            if ($EXT -ne ""){
                $EXT4 = $EXT.substring($EXT.Length - 4)
                $DID = "$EXTS$EXT4"
                }
            if ($EXT -eq ""){
                $EXT = $LCHDNs | select -First 1
                $LCHDNs.RemoveAt(0)
                $DID = "$EXT"
                }
            }
        if (($SITE -like "HUD")){
            $SITE = "HUD"
            $VMPT = "a1889357-81f6-47c0-b23f-252dede26b4a"
            $EXTS = "8106"
            $EXMask = $HudMain
            if ($EXT -ne ""){
                $EXT4 = $EXT.substring($EXT.Length - 4)
                $DID = "$EXTS$EXT4"
                }
            if ($EXT -eq ""){
                $EXT = $HUDDNs | select -First 1
                $HUDDNs.RemoveAt(0)
                $DID = "$EXT"
                }
            }
        if (($SITE -like "WEB")){
            $SITE = "WEB"
            $VMPT = "1ffa0ea3-f3fb-4a8d-98f7-bcb51d8fef81"
            $EXTS = "8105"
            $EXMask = $WebMain
            if ($EXT -ne ""){
                $EXT4 = $EXT.substring($EXT.Length - 4)
                $DID = "$EXTS$EXT4"
                }
            if ($EXT -eq ""){
                $EXT = $WEBDNs | select -First 1
                $WEBDNs.RemoveAt(0)
                $DID = "$EXT"
                }
            }
        if (($LOC -like "BGR")){
            $SITE = "BGR"
            $VMPT = "cd16fbf2-a713-45b0-803d-a4c703528351"
            $EXTS = "8112"
            $EXMask = $BGRMain
            if ($EXT -ne ""){
                $EXT4 = $EXT.substring($EXT.Length - 4)
                $DID = "$EXTS$EXT4"
                }
            if ($EXT -eq ""){
                $EXT = $BGRDNs | select -First 1
                $BGRDNs.RemoveAt(0)
                $DID = "$EXT"
                }
            }
        if (($LOC -like "MET")){
            $SITE = "MET"
            $VMPT = "a848c571-c889-4eed-8bc0-f7edbb0b62af"
            $EXTS = "8113"
            $EXMask = $MetMain
            if ($EXT -ne ""){
                $EXT4 = $EXT.substring($EXT.Length - 4)
                $DID = "$EXTS$EXT4"
                }
            if ($EXT -eq ""){
                $EXT = $METDNs | select -First 1
                $METDNs.RemoveAt(0)
                $DID = "$EXT"
                }
            }
        if (($SITE -like "CAR")){
            $SITE = "CAR"
            $VMPT = "46149a4e-757b-49e6-b5c9-8698bfc17ebd"
            $EXTS = "8104"
            $EXMask = $CarMain
            if ($EXT -ne ""){
                $EXT4 = $EXT.substring($EXT.Length - 4)
                $DID = "$EXTS$EXT4"
                }
            if ($EXT -eq ""){
                $EXT = $CARDNs | select -First 1
                $CARDNs.RemoveAt(0)
                $DID = "$EXT"
                }
            }
        if (($SITE -like "UPP")){
            $SITE = "UPP"
            $VMPT = "419a759d-29f6-4a09-8d93-71319f85f15c"
            $EXTS = "8103"
            $EXMask = $UppMain
            if ($EXT -ne ""){
                $EXT4 = $EXT.substring($EXT.Length - 4)
                $DID = "$EXTS$EXT4"
                }
            if ($EXT -eq ""){
                $EXT = $UPPDNs | select -First 1
                $UPPDNs.RemoveAt(0)
                $DID = "$EXT"
                }
            }
        if (($SITE -like "LOR")){
            $SITE = "LOR"
            $VMPT = "bf10c920-677c-4a9b-9369-ed79811cbbed"
            $EXTS = "8109"
            $EXMask = $LorMain
            if ($EXT -ne ""){
                $EXT4 = $EXT.substring($EXT.Length - 4)
                $DID = "$EXTS$EXT4"
                }
            if ($EXT -eq ""){
                $EXT = $LORDNs | select -First 1
                $LORDNs.RemoveAt(0)
                $DID = "$EXT"
                }
            }
        if (($LOC -like "COL")){
            $SITE = "COL"
            $VMPT = "3cd41dd8-a2e9-4587-8e37-7c4f1ea4c863"
            $EXTS = "8114"
            if ($EXT -eq ""){
                $EXT = $COLdids | select -First 1
                $COLdids.removeat(0)
                $EXT4 = $EXT.substring($EXT.Length - 4)
                $DIDper = "%$EXT"
                $DID = "\$EXT"
                }
            }
        if ($SITE -like "SCF"){
            $SITE = "SCF"
            $VMPT = "4f48e75c-3ecc-4ac3-88f6-4fb66766b49a<"
            $EXTS = "8121"
            if ($EXT -ne ""){
                $EXT4 = $EXT.substring($EXT.Length - 4)
                $DIDper = "%+1712454$EXT4"
                $DID = "\+1712454$EXT4"
                }
            if ($EXT -eq ""){
                $EXT = $SCFDids | select -First 1
                $SCFDids.removeat(0)
                $EXT4 = $EXT.substring($EXT.Length - 4)
                $DIDper = "%+1712454$EXT4"
                $DID = "\+1712454$EXT4"
                }
            }
        if ($SITE -like "SCC"){
            $SITE = "SCC"
            $VMPT = "c34e1025-8e77-4aa0-867b-cc6f46f1d504"
            $EXTS = "8120"
            if ($EXT -ne ""){
                $EXT4 = $EXT.substring($EXT.Length - 4)
                $DIDper = "%+1712454$EXT4"
                $DID = "\+1712454$EXT4"
                }
            if ($EXT -eq ""){
                $EXT = $SCCDids | select -First 1
                $SCCDids.removeat(0)
                $EXT4 = $EXT.substring($EXT.Length - 4)
                $DIDper = "%+1712454$EXT4"
                $DID = "\+1712454$EXT4"
                }
            }
        if ($SITE -like "SGT"){
            $SITE = "SGT"
            $VMPT = "5b35e21c-61cf-4768-844b-f8be722009f2"
            $EXTS = "8122"
            if ($EXT -ne ""){
                $EXT4 = $EXT.substring($EXT.Length - 4)
                $DIDper = "%+1712454$EXT4"
                $DID = "\+1712454$EXT4"
                }
            if ($EXT -eq ""){
                $EXT = $SGTDids | select -First 1
                $SGTDids.removeat(0)
                $EXT4 = $EXT.substring($EXT.Length - 4)
                $DIDper = "%+1712454$EXT4"
                $DID = "\+1712454$EXT4"
                }
            }
        }
    if ($PHONE -ne ""){
	    if ($PHONE -like "SEP*"){
		    $SEP = $PHONE
		    }
	    if ($PHONE.Length -eq 12){
		    $SEP = "SEP$PHONE"
		    }
	    }
    if ($PHONE -eq ""){
        if ($PHONETYPE -like "Jabber*"){
            $SEP = "CSF$ANDID"
            }
        if ($PHONETYPE -like "iPhone*"){
            $SEP = "TCT$ANDID"
            }
        if ($PHONETYPE -ne ""){
            $SEP = "BAT$RNUM"
            }
        }
    ### Convert nomenclature entries (7841) to system-acceptable entries (Cisco 7841). ###
    $PROD = switch -Wildcard ($PHONETYPE)
        {
            "*7841*" {"Cisco 7841"}
            "*8831*" {"Cisco 8831"}
            "*8841*" {"Cisco 8841"}
            "*8851*" {"Cisco 8851"}
            "Jabber*" {"Cisco Unified Client Services Framework"}
            "iPhone*" {"Cisco Dual Mode for iPhone"}
        }
    $DSEC = switch -Wildcard ($PHONETYPE)
        {
            "*7841*" {"Cisco 7841 - Standard SIP Non-Secure Profile"}
            "*8831*" {"Cisco 8831 - Standard SIP Non-Secure Profile"}
            "*8841*" {"Cisco 8841 - Standard SIP Non-Secure Profile"}
            "*8851*" {"Cisco 8851 - Standard SIP Non-Secure Profile"}
            "Jabber*" {"Cisco Unified Client Services Framework - Standard SIP Non-Secure Profile"}
            "iPhone*" {"Cisco Dual Mode for iPhone - Standard SIP Non-Secure Profile"}
        }
    $PHTN = switch -Wildcard ($PHONETYPE)
        {
            "*7841*" {"Standard 7841 SIP"}
            "*8831*" {"Standard 8831 SIP"}
            "*8841*" {"Standard 8841 SIP"}
            "*8851*" {"Standard 8851 SIP"}
            "Jabber*" {"Standard Client Services Framework"}
            "iPhone*" {"Standard Dual Mode for iPhone"}
        }
    #If it's not a DID-site, this is how 8-digit extensions are checked.
    if ($DIDper -eq $null){
        $DIDper = $DID
        }
    $EXT4 = $null
    $EXT4 = $DID.Substring($DID.Length - 4)
    $EXT8 = $null
    $EXT8 = "$EXTS$EXT4"
### Percent is a wildcard. ###
$MyVMP0 = [xml]@”
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/11.5">
<soapenv:Header/>
<soapenv:Body>
<ns:listRoutePlan sequence="?">
<searchCriteria>
<dnOrPattern>$DIDper</dnOrPattern>
</searchCriteria>
<returnedTags uuid="?">
<!--Optional:-->
<dnOrPattern>?</dnOrPattern>
<!--Optional:-->
<partition uuid="?">?</partition>
<!--Optional:-->
<type>?</type>
<!--Optional:-->
<routeDetail>?</routeDetail>
</returnedTags>
</ns:listRoutePlan>
</soapenv:Body>
</soapenv:Envelope>
“@
### DO NOT CHANGE ABOVE ###
$result0 = $null
### Check for the Extension, make sure it doesn't exist in CUCM. ###
$result0 = Invoke-RestMethod -Uri $URI  -body $MyVMP0 -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType “Text/XML” -Method post -ErrorAction Ignore
### Result of 1 means DID is in use###
if ($USER -ne $null){
    $Check001 = "0"
    ###Check for User and Extension in CUC. ###
    $URIuser = "https://gob-cuc-1.andersonsinc.com/vmrest/users/?query=(Alias is $OWNR)"
    $URIuserREQ = Invoke-RestMethod -Uri $URIuser  -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}  -Method Get -ErrorAction Ignore #-ContentType “Text/XML”
    #$URIuserREQ.InnerXml.Contains("$OWNR")
    $URIdtmf = "https://gob-cuc-1.andersonsinc.com/vmrest/users/?query=(dtmfAccessId is $EXT8)"
    $URIdtmfREQ = Invoke-RestMethod -Uri $URIdtmf  -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}  -Method Get -ErrorAction Ignore #-ContentType “Text/XML”
    #$URIuserREQ.InnerXml.Contains("$EXT8")
    ### Kick back an error to my email if any of the above three are in use (True). ###
if (($result0.InnerXml.Contains("dnOrPattern") -eq 1) -or ($URIuserREQ.InnerXml.Contains("$OWNR") -eq 1) -or ($URIuserREQ.InnerXml.Contains("$EXT8") -eq 1)){ 
$BODY = @"
$DID for $DSPN is in use. OR $EXT8 is still in CUC. OR $OWNR is still in CUC. Please investigate.
"@
    Send-MailMessage -From "brian_eggenberger@andersonsinc.com" -to "brian_eggenberger@andersonsinc.com" -Body $BODY -Subject "ERROR" -SmtpServer "smtp.andersonsinc.com"
        }
    }
if ($USER -eq $null){
    $Check001 = "1"
    if (($result0.InnerXml.Contains("dnOrPattern") -eq 1)){ 
$BODY = @"
$DID for $DSPN is in use. Please investigate.
"@
    Send-MailMessage -From "brian_eggenberger@andersonsinc.com" -to "brian_eggenberger@andersonsinc.com" -Body $BODY -Subject "ERROR" -SmtpServer "smtp.andersonsinc.com"
        }
    }
$Check001
if ((($result0.InnerXml.Contains("dnOrPattern") -eq 0 -and $Check001 -like "1")) -or (($result0.InnerXml.Contains("dnOrPattern") -eq 0) -and ($Check001 -like "0") -and ($URIuserREQ.InnerXml.Contains("$OWNR") -eq 0) -and ($URIuserREQ.InnerXml.Contains("$EXT8") -eq 0))) { 
    ### Builds various variables that will be used in API Calls. ###
    $DESC = "$SITE - $FN $LN - $EXTS$EXT4"
    $DEVP = "$SITE-DP"
    if (($CITY -like "Maumee*") -and ($ADDR -notlike "1947*")){
        $DESC = "MAU - $FN $LN - $EXTS$EXT4"
        $DEVP = "MAU-DP"
        }
    $CSS = "$SITE-INTL"
    $SCPP = "Standard Common Phone Profile"
    $LABL = "$FN $LN - $EXTS$EXT4"
    $MLPP = ""
    if ($PHONETYPE -notlike "8831"){
        $MLPP = "Default"
        }
    if ($PHONETYPE -like "Jabber"){
        $DND = "Ringer Off"
        }
    elseif ($PHONETYPE -notlike "Jabber"){
        $DND = "Use Common Phone Profile Setting"
        }
    if (($FN -eq "") -or ($FN -eq $null)){
        $DESC = "$SITE - $LN - $EXTS$EXT4"
        $LABL = "$LN - $EXTS$EXT4"
        }
    if ($LABL.Length -ge 30 -and $FN -ne ""){
        $FN = $FN.Substring(0,1)
        $LN = $LN.Substring(0,15)
        $LABL = "$FN $LN - $EXTS$EXT4"
        }
    $LTL = "$LABL"
    if (($MASK -eq "") -or ($MASK -eq $null)){
        $MASK = $DID.Substring($DID.Length - 10)
        }
    else{
        $MASK = $EXmask
        }
    $VMP = "$SITE-VMP"
    $VMTemplate = "$SITE-Template"
    if (($USER -ne $null) -and ($USER -ne "")){
        if ($DID.Length -ge 12){
            $DIDplus = $DID.Substring($DID.Length -12)
            }
        else {
            $DIDplus = $DID
            }
        }
    $gobcuc1 = "1cefdbc4-53ae-48ee-8955-3b5096142149"
    $VMpartition = $VMPT
### Build the line first. ###
$APILINE = [xml]@"
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/11.5">
<soapenv:Header/>
<soapenv:Body>
<ns:addLine sequence="?">
<line ctiid="?">
<pattern>$DID</pattern>
<description>$DESC</description>
<usage>Device</usage>
<routePartitionName>AllPhones</routePartitionName>
<callForwardAll>
<forwardToVoiceMail>false</forwardToVoiceMail>
<callingSearchSpaceName uuid="?">$CSS</callingSearchSpaceName>
<secondaryCallingSearchSpaceName />
<destination />
</callForwardAll>
<callForwardBusy>
<forwardToVoiceMail>true</forwardToVoiceMail>
<callingSearchSpaceName xsi:nil="true" uuid="" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"/>
<destination/>
</callForwardBusy>
<callForwardBusyInt>
<forwardToVoiceMail>true</forwardToVoiceMail>
<callingSearchSpaceName xsi:nil="true" uuid="" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"/>
<destination/>
</callForwardBusyInt>
<callForwardNoAnswer>
<forwardToVoiceMail>true</forwardToVoiceMail>
<callingSearchSpaceName xsi:nil="true" uuid="" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"/>
<destination/>
<duration />
</callForwardNoAnswer>
<callForwardNoAnswerInt>
<forwardToVoiceMail>true</forwardToVoiceMail>
<callingSearchSpaceName xsi:nil="true" uuid="" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"/>
<destination/>
<duration />
</callForwardNoAnswerInt>
<callForwardNoCoverage>
<forwardToVoiceMail>true</forwardToVoiceMail>
<callingSearchSpaceName xsi:nil="true" uuid="" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"/>
<destination/>
</callForwardNoCoverage>
<callForwardNoCoverageInt>
<forwardToVoiceMail>true</forwardToVoiceMail>
<callingSearchSpaceName xsi:nil="true" uuid="" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"/>
<destination/>
</callForwardNoCoverageInt>
<callForwardOnFailure>
<forwardToVoiceMail>true</forwardToVoiceMail>
<callingSearchSpaceName xsi:nil="true" uuid="" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"/>
<destination/>
</callForwardOnFailure>
<callForwardAlternateParty>
<callingSearchSpaceName xsi:nil="true" uuid="" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"/>
<destination/>
<duration />
</callForwardAlternateParty>
<callForwardNotRegistered>
<forwardToVoiceMail>true</forwardToVoiceMail>
<callingSearchSpaceName xsi:nil="true" uuid="" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"/>
<destination/>
</callForwardNotRegistered>
<callForwardNotRegisteredInt>
<forwardToVoiceMail>true</forwardToVoiceMail>
<callingSearchSpaceName xsi:nil="true" uuid="" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"/>
<destination/>
</callForwardNotRegisteredInt>
<callPickupGroupName xsi:nil="true" uuid="" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"/>
<autoAnswer>Auto Answer Off</autoAnswer>
<networkHoldMohAudioSourceId />
<userHoldMohAudioSourceId />
<alertingName>$LTL</alertingName>
<asciiAlertingName>$LTL</asciiAlertingName>
<presenceGroupName uuid="?">Standard Presence group</presenceGroupName>
<shareLineAppearanceCssName uuid="?">$CSS</shareLineAppearanceCssName>
<voiceMailProfileName uuid="?">$VMP</voiceMailProfileName>
<patternPrecedence>Default</patternPrecedence>
<releaseClause>No Error</releaseClause>
<hrDuration />
<hrInterval />
<cfaCssPolicy>Use System Default</cfaCssPolicy>
<defaultActivatedDeviceName/>
<parkMonForwardNoRetrieveDn/>
<parkMonForwardNoRetrieveIntDn/>
<parkMonForwardNoRetrieveVmEnabled>false</parkMonForwardNoRetrieveVmEnabled>
<parkMonForwardNoRetrieveIntVmEnabled>false</parkMonForwardNoRetrieveIntVmEnabled>
<parkMonForwardNoRetrieveCssName/>
<parkMonForwardNoRetrieveIntCssName/>
<parkMonReversionTimer />
<partyEntranceTone>Default</partyEntranceTone>
<directoryURIs>
</directoryURIs>
<allowCtiControlFlag>true</allowCtiControlFlag>
<rejectAnonymousCall>false</rejectAnonymousCall>
<patternUrgency>false</patternUrgency>
<confidentialAccess>
<confidentialAccessMode />
<confidentialAccessLevel>-1</confidentialAccessLevel>
</confidentialAccess>
<externalCallControlProfile/>
<enterpriseAltNum>
<numMask />
<isUrgent>f</isUrgent>
<addLocalRoutePartition>f</addLocalRoutePartition>
<routePartition/>
<advertiseGloballyIls>f</advertiseGloballyIls>
</enterpriseAltNum>
<e164AltNum>
<numMask />
<isUrgent>f</isUrgent>
<addLocalRoutePartition>f</addLocalRoutePartition>
<routePartition/>
<advertiseGloballyIls>f</advertiseGloballyIls>
</e164AltNum>
<pstnFailover />
<callControlAgentProfile />
<useEnterpriseAltNum>false</useEnterpriseAltNum>
<useE164AltNum>false</useE164AltNum>
<active>true</active>
</line>
</ns:addLine>
</soapenv:Body>
</soapenv:Envelope>
"@
Invoke-RestMethod -Uri $URI  -body $APILINE -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType “Text/XML” -Method post -ErrorAction Ignore
### NO USER ###
if ($USER -eq $null -or $USER -eq ""){
$APIPHONE = [xml]@"
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/11.5">
<soapenv:Header/>
<soapenv:Body>
<ns:addPhone sequence="?">
<phone ctiid="?">
<name>$SEP</name>
<description>$DESC</description>
<product>$PROD</product>
<model>$PROD</model>
<class>Phone</class>
<protocol>SIP</protocol>
<protocolSide>User</protocolSide>
<callingSearchSpaceName uuid="?">$CSS</callingSearchSpaceName>
<devicePoolName uuid="?">$DEVP</devicePoolName>
<commonDeviceConfigName></commonDeviceConfigName>
<commonPhoneConfigName uuid="?">$SCPP</commonPhoneConfigName>
<networkLocation>Use System Default</networkLocation>
<locationName uuid="?">Hub_None</locationName>
<mediaResourceListName></mediaResourceListName>
<networkHoldMohAudioSourceId></networkHoldMohAudioSourceId>
<userHoldMohAudioSourceId></userHoldMohAudioSourceId>
<automatedAlternateRoutingCssName></automatedAlternateRoutingCssName>
<aarNeighborhoodName></aarNeighborhoodName>
<loadInformation special="false"/>
<vendorConfig>
<disableSpeaker>false</disableSpeaker>
<disableSpeakerAndHeadset>false</disableSpeakerAndHeadset>
<pcPort>0</pcPort>
<garp>1</garp>
<voiceVlanAccess>0</voiceVlanAccess>
<spanToPCPort>1</spanToPCPort>
<loggingDisplay>1</loggingDisplay>
<recordingTone>0</recordingTone>
<recordingToneLocalVolume>100</recordingToneLocalVolume>
<recordingToneRemoteVolume>50</recordingToneRemoteVolume>
<moreKeyReversionTimer>5</moreKeyReversionTimer>
<powerPriority>0</powerPriority>
<LineKeyBarge>0</LineKeyBarge>
<minimumRingVolume>0</minimumRingVolume>
<ehookEnable>1</ehookEnable>
<headsetWidebandUIControl>0</headsetWidebandUIControl>
<headsetWidebandEnable>0</headsetWidebandEnable>
</vendorConfig>
<versionStamp></versionStamp>
<traceFlag>false</traceFlag>
<mlppDomainId></mlppDomainId>
<mlppIndicationStatus>$MLPP</mlppIndicationStatus>
<preemption>$MLPP</preemption>
<useTrustedRelayPoint>Default</useTrustedRelayPoint>
<retryVideoCallAsAudio>true</retryVideoCallAsAudio>
<securityProfileName uuid="?">$DSEC</securityProfileName>
<sipProfileName/>
<cgpnTransformationCssName/>
<useDevicePoolCgpnTransformCss>true</useDevicePoolCgpnTransformCss>
<geoLocationName/>
<geoLocationFilterName/>
<sendGeoLocation>false</sendGeoLocation>
<lines>
<line uuid="?">
<index>1</index>
<label>$LABL</label>
<display>$LABL</display>
<dirn>
<pattern>$DID</pattern>
<routePartitionName uuid="?">AllPhones</routePartitionName>
</dirn>
<consecutiveRingSetting>Use System Default</consecutiveRingSetting>
<ringSettingIdlePickupAlert>Use System Default</ringSettingIdlePickupAlert>
<ringSettingActivePickupAlert>Use System Default</ringSettingActivePickupAlert>
<displayAscii>$LABL</displayAscii>
<e164Mask>$MASK</e164Mask>
<dialPlanWizard></dialPlanWizard>
<mwlPolicy>Use System Policy</mwlPolicy>
<maxNumCalls>4</maxNumCalls>
<busyTrigger>2</busyTrigger>
<callInfoDisplay>
<callerName>false</callerName>
<callerNumber>false</callerNumber>
<redirectedNumber>false</redirectedNumber>
<dialedNumber>false</dialedNumber>
</callInfoDisplay>
<recordingProfileName/>
<monitoringCssName/>
<recordingFlag>Call Recording Disabled</recordingFlag>
<audibleMwi>Default</audibleMwi>
<speedDial />
<partitionUsage>General</partitionUsage>
<missedCallLogging>true</missedCallLogging>
<recordingMediaSource>Gateway Preferred</recordingMediaSource>
</line>
</lines>
<phoneTemplateName uuid="?">$PHTN</phoneTemplateName>
<numberOfButtons>8</numberOfButtons>
<speeddials/>
<busyLampFields/>
<primaryPhoneName/>
<ringSettingIdleBlfAudibleAlert>Default</ringSettingIdleBlfAudibleAlert>
<ringSettingBusyBlfAudibleAlert>Default</ringSettingBusyBlfAudibleAlert>
<blfDirectedCallParks/>
<addOnModules/>
<userLocale>English United States</userLocale>
<networkLocale>United States</networkLocale>
<idleTimeout />
<authenticationUrl />
<directoryUrl />
<idleUrl />
<informationUrl />
<messagesUrl />
<proxyServerUrl />
<servicesUrl />
<services/>
<softkeyTemplateName/>
<loginUserId />
<defaultProfileName/>
<enableExtensionMobility>false</enableExtensionMobility>
<currentProfileName/>
<loginTime />
<loginDuration />
<joinAcrossLines />
<singleButtonBarge>Default</singleButtonBarge>
<joinAcrossLines>Default</joinAcrossLines>
<builtInBridgeStatus>Default</builtInBridgeStatus>
<callInfoPrivacyStatus>Default</callInfoPrivacyStatus>
<hlogStatus>On</hlogStatus>
<ignorePresentationIndicators>false</ignorePresentationIndicators>
<packetCaptureMode>None</packetCaptureMode>
<packetCaptureDuration>0</packetCaptureDuration>
<subscribeCallingSearchSpaceName/>
<rerouteCallingSearchSpaceName/>
<allowCtiControlFlag>true</allowCtiControlFlag>
<presenceGroupName uuid="?">Standard Presence group</presenceGroupName>
<unattendedPort>false</unattendedPort>
<requireDtmfReception>false</requireDtmfReception>
<rfc2833Disabled>false</rfc2833Disabled>
<certificateOperation>No Pending Operation</certificateOperation>
<certificateStatus>None</certificateStatus>
<upgradeFinishTime />
<deviceMobilityMode>Default</deviceMobilityMode>
<remoteDevice>false</remoteDevice>
<dndOption>$DND</dndOption>
<dndRingSetting />
<dndStatus>false</dndStatus>
<isActive>true</isActive>
<isDualMode>false</isDualMode>
<mobilityUserIdName/>
<phoneSuite>Default</phoneSuite>
<phoneServiceDisplay>Default</phoneServiceDisplay>
<isProtected>false</isProtected>
<mtpRequired>false</mtpRequired>
<mtpPreferedCodec>711ulaw</mtpPreferedCodec>
<dialRulesName/>
<sshUserId/>
<digestUser/>
<outboundCallRollover>No Rollover</outboundCallRollover>
<hotlineDevice>false</hotlineDevice>
<secureInformationUrl />
<secureDirectoryUrl />
<secureMessageUrl />
<secureServicesUrl />
<secureAuthenticationUrl />
<secureIdleUrl />
<alwaysUsePrimeLine>Default</alwaysUsePrimeLine>
<alwaysUsePrimeLineForVoiceMessage>Default</alwaysUsePrimeLineForVoiceMessage>
<featureControlPolicy/>
<deviceTrustMode>Not Trusted</deviceTrustMode>
<confidentialAccess>
<confidentialAccessMode />
<confidentialAccessLevel>-1</confidentialAccessLevel>
</confidentialAccess>
<requireOffPremiseLocation>false</requireOffPremiseLocation>
<cgpnIngressDN/>
<useDevicePoolCgpnIngressDN>true</useDevicePoolCgpnIngressDN>
<msisdn />
<enableCallRoutingToRdWhenNoneIsActive>false</enableCallRoutingToRdWhenNoneIsActive>
<wifiHotspotProfile/>
<wirelessLanProfileGroup/>
<elinGroup/>
</phone>
</ns:addPhone>
</soapenv:Body>
</soapenv:Envelope>
"@
Invoke-RestMethod -Uri $URI  -body $APIPHONE -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType “Text/XML” -Method post -ErrorAction Ignore
}
### For users w/ active samaccountnames. ###
if ($USER -ne $null -and $USER -ne ""){
### Build the phone. ###
$APIPHONE = [xml]@"
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/11.5">
<soapenv:Header/>
<soapenv:Body>
<ns:addPhone sequence="?">
<phone ctiid="?">
<name>$SEP</name>
<description>$DESC</description>
<product>$PROD</product>
<model>$PROD</model>
<class>Phone</class>
<protocol>SIP</protocol>
<protocolSide>User</protocolSide>
<callingSearchSpaceName uuid="?">$CSS</callingSearchSpaceName>
<devicePoolName uuid="?">$DEVP</devicePoolName>
<commonDeviceConfigName></commonDeviceConfigName>
<commonPhoneConfigName uuid="?">$SCPP</commonPhoneConfigName>
<networkLocation>Use System Default</networkLocation>
<locationName uuid="?">Hub_None</locationName>
<mediaResourceListName></mediaResourceListName>
<networkHoldMohAudioSourceId></networkHoldMohAudioSourceId>
<userHoldMohAudioSourceId></userHoldMohAudioSourceId>
<automatedAlternateRoutingCssName></automatedAlternateRoutingCssName>
<aarNeighborhoodName></aarNeighborhoodName>
<loadInformation special="false"/>
<vendorConfig>
<disableSpeaker>false</disableSpeaker>
<disableSpeakerAndHeadset>false</disableSpeakerAndHeadset>
<pcPort>0</pcPort>
<garp>1</garp>
<voiceVlanAccess>0</voiceVlanAccess>
<spanToPCPort>1</spanToPCPort>
<loggingDisplay>1</loggingDisplay>
<recordingTone>0</recordingTone>
<recordingToneLocalVolume>100</recordingToneLocalVolume>
<recordingToneRemoteVolume>50</recordingToneRemoteVolume>
<moreKeyReversionTimer>5</moreKeyReversionTimer>
<powerPriority>0</powerPriority>
<LineKeyBarge>0</LineKeyBarge>
<minimumRingVolume>0</minimumRingVolume>
<ehookEnable>1</ehookEnable>
<headsetWidebandUIControl>0</headsetWidebandUIControl>
<headsetWidebandEnable>0</headsetWidebandEnable>
</vendorConfig>
<versionStamp></versionStamp>
<traceFlag>false</traceFlag>
<mlppDomainId></mlppDomainId>
<mlppIndicationStatus>$MLPP</mlppIndicationStatus>
<preemption>$MLPP</preemption>
<useTrustedRelayPoint>Default</useTrustedRelayPoint>
<retryVideoCallAsAudio>true</retryVideoCallAsAudio>
<securityProfileName uuid="?">$DSEC</securityProfileName>
<sipProfileName/>
<cgpnTransformationCssName/>
<useDevicePoolCgpnTransformCss>true</useDevicePoolCgpnTransformCss>
<geoLocationName/>
<geoLocationFilterName/>
<sendGeoLocation>false</sendGeoLocation>
<lines>
<line uuid="?">
<index>1</index>
<label>$LABL</label>
<display>$LABL</display>
<dirn>
<pattern>$DID</pattern>
<routePartitionName uuid="?">AllPhones</routePartitionName>
</dirn>
<consecutiveRingSetting>Use System Default</consecutiveRingSetting>
<ringSettingIdlePickupAlert>Use System Default</ringSettingIdlePickupAlert>
<ringSettingActivePickupAlert>Use System Default</ringSettingActivePickupAlert>
<displayAscii>$LABL</displayAscii>
<e164Mask>$MASK</e164Mask>
<dialPlanWizard></dialPlanWizard>
<mwlPolicy>Use System Policy</mwlPolicy>
<maxNumCalls>4</maxNumCalls>
<busyTrigger>2</busyTrigger>
<callInfoDisplay>
<callerName>false</callerName>
<callerNumber>false</callerNumber>
<redirectedNumber>false</redirectedNumber>
<dialedNumber>false</dialedNumber>
</callInfoDisplay>
<recordingProfileName/>
<monitoringCssName/>
<recordingFlag>Call Recording Disabled</recordingFlag>
<audibleMwi>Default</audibleMwi>
<speedDial />
<partitionUsage>General</partitionUsage>
<associatedEndusers>
<enduser>
<userid>$OWNR</userid>
</enduser>
</associatedEndusers>
<missedCallLogging>true</missedCallLogging>
<recordingMediaSource>Gateway Preferred</recordingMediaSource>
</line>
</lines>
<phoneTemplateName uuid="?">$PHTN</phoneTemplateName>
<numberOfButtons>8</numberOfButtons>
<speeddials/>
<busyLampFields/>
<primaryPhoneName/>
<ringSettingIdleBlfAudibleAlert>Default</ringSettingIdleBlfAudibleAlert>
<ringSettingBusyBlfAudibleAlert>Default</ringSettingBusyBlfAudibleAlert>
<blfDirectedCallParks/>
<addOnModules/>
<userLocale>English United States</userLocale>
<networkLocale>United States</networkLocale>
<idleTimeout />
<authenticationUrl />
<directoryUrl />
<idleUrl />
<informationUrl />
<messagesUrl />
<proxyServerUrl />
<servicesUrl />
<services/>
<softkeyTemplateName/>
<loginUserId />
<defaultProfileName/>
<enableExtensionMobility>false</enableExtensionMobility>
<currentProfileName/>
<loginTime />
<loginDuration />
<joinAcrossLines />
<singleButtonBarge>Default</singleButtonBarge>
<joinAcrossLines>Default</joinAcrossLines>
<builtInBridgeStatus>Default</builtInBridgeStatus>
<callInfoPrivacyStatus>Default</callInfoPrivacyStatus>
<hlogStatus>On</hlogStatus>
<ownerUserName uuid="?">$OWNR</ownerUserName>
<ignorePresentationIndicators>false</ignorePresentationIndicators>
<packetCaptureMode>None</packetCaptureMode>
<packetCaptureDuration>0</packetCaptureDuration>
<subscribeCallingSearchSpaceName/>
<rerouteCallingSearchSpaceName/>
<allowCtiControlFlag>true</allowCtiControlFlag>
<presenceGroupName uuid="?">Standard Presence group</presenceGroupName>
<unattendedPort>false</unattendedPort>
<requireDtmfReception>false</requireDtmfReception>
<rfc2833Disabled>false</rfc2833Disabled>
<certificateOperation>No Pending Operation</certificateOperation>
<certificateStatus>None</certificateStatus>
<upgradeFinishTime />
<deviceMobilityMode>Default</deviceMobilityMode>
<remoteDevice>false</remoteDevice>
<dndOption>Use Common Phone Profile Setting</dndOption>
<dndRingSetting />
<dndStatus>false</dndStatus>
<isActive>true</isActive>
<isDualMode>false</isDualMode>
<mobilityUserIdName/>
<phoneSuite>Default</phoneSuite>
<phoneServiceDisplay>Default</phoneServiceDisplay>
<isProtected>false</isProtected>
<mtpRequired>false</mtpRequired>
<mtpPreferedCodec>711ulaw</mtpPreferedCodec>
<dialRulesName/>
<sshUserId/>
<digestUser/>
<outboundCallRollover>No Rollover</outboundCallRollover>
<hotlineDevice>false</hotlineDevice>
<secureInformationUrl />
<secureDirectoryUrl />
<secureMessageUrl />
<secureServicesUrl />
<secureAuthenticationUrl />
<secureIdleUrl />
<alwaysUsePrimeLine>Default</alwaysUsePrimeLine>
<alwaysUsePrimeLineForVoiceMessage>Default</alwaysUsePrimeLineForVoiceMessage>
<featureControlPolicy/>
<deviceTrustMode>Not Trusted</deviceTrustMode>
<confidentialAccess>
<confidentialAccessMode />
<confidentialAccessLevel>-1</confidentialAccessLevel>
</confidentialAccess>
<requireOffPremiseLocation>false</requireOffPremiseLocation>
<cgpnIngressDN/>
<useDevicePoolCgpnIngressDN>true</useDevicePoolCgpnIngressDN>
<msisdn />
<enableCallRoutingToRdWhenNoneIsActive>false</enableCallRoutingToRdWhenNoneIsActive>
<wifiHotspotProfile/>
<wirelessLanProfileGroup/>
<elinGroup/>
</phone>
</ns:addPhone>
</soapenv:Body>
</soapenv:Envelope>
"@
Invoke-RestMethod -Uri $URI  -body $APIPHONE -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType “Text/XML” -Method post -ErrorAction Ignore
### Find out what other devices, if any, belong to this user.  Otherwise, an updateUser will overwrite them.  That's bad, mmm'kay? ###
$APIDEVS = @"
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/11.5">
<soapenv:Header/>
<soapenv:Body>
<ns:getUser sequence="?">
<userid>$ANDID</userid>
</ns:getUser>
</soapenv:Body>
</soapenv:Envelope>
"@
$result = Invoke-RestMethod -Uri $URI  -body $APIDEVS -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType “Text/XML” -Method post -ErrorAction Ignore
$content = $result.OuterXml
$content = $content | select-string -pattern "(?<=<device>)(.*)(?=\</device>)" | ForEach-Object {$_.Matches.Groups[1].value}
$content
$content = $content.Replace("device","")
$content = $content.Replace("/","")
$content = $content.Replace("<","")
$content = $content.Replace(">>",",")
$content = $content.Split(',')
$DEVS = @()
### Add any found devices to an array so when we update, it won't overwrite those devices. ###
foreach ($DEV in $content){
    $DEV = "<device>$DEV</device>"
    $DEVS += $DEV
    }
$DEVS += "<device>$SEP</device>"
### Update user and assign newly built phone and other found phones. ###
$APIUSER = [xml]@"
<?xml version='1.0' encoding='UTF-8'?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
<soapenv:Body>
<ns:updateUser xmlns:ns="http://www.cisco.com/AXL/API/11.5">
<userid>$ANDID</userid>
<associatedDevices>
$DEVS
</associatedDevices>
<primaryExtension>
<pattern>$DID</pattern>
<routePartitionName>AllPhones</routePartitionName>
</primaryExtension>
<associatedGroups>
<userGroup>
<name>The Andersons Standard Users</name>
<userRoles>
<userRole>Standard CCM End Users</userRole>
<userRole>Standard CTI Allow Control of Phones supporting Connected Xfer and conf</userRole>
<userRole>Standard CTI Allow Control of Phones supporting Rollover Mode</userRole>
<userRole>Standard CTI Enabled</userRole>
</userRoles>
<enableMobility>true</enableMobility>
<enableMobileVoiceAccess>false</enableMobileVoiceAccess>
</userGroup>
</associatedGroups>
</ns:updateUser>
</soapenv:Body>
</soapenv:Envelope>
"@
Invoke-RestMethod -Uri $URI  -body $APIUSER -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType “Text/XML” -Method post -ErrorAction Ignore
### Enable Mobility - This doesn't work when configuring the user, for some reason. ###
$APIUSERmobility = [xml]@"
<?xml version='1.0' encoding='UTF-8'?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
<soapenv:Body>
<ns:updateUser xmlns:ns="http://www.cisco.com/AXL/API/11.5">
<userid>$ANDID</userid>
<enableMobility>false</enableMobility>
</ns:updateUser>
</soapenv:Body>
</soapenv:Envelope>
"@
Invoke-RestMethod -Uri $URI  -body $APIUSERmobility -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType “Text/XML” -Method post -ErrorAction Ignore
### Build Remote Destination Profile. ###
$APIRDP = [xml]@"
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/11.5">
<soapenv:Header/>
<soapenv:Body>
<ns:addRemoteDestinationProfile>
<remoteDestinationProfile>
<name>$RDP</name>
<description>Remote Destination Profile for $FN $LN</description>
<product>Remote Destination Profile</product>
<model>Remote Destination Profile</model>
<class>Remote Destination Profile</class>
<protocol>Remote Destination</protocol>
<protocolSide>User</protocolSide>
<callingSearchSpaceName>$CSS</callingSearchSpaceName>
<devicePoolName>$DEVP</devicePoolName>
<lines>
<line>
<index>1</index>
<display>$LABL</display>
<dirn>
<pattern>$DID</pattern>
<routePartitionName uuid="{CFBD645F-AF59-B5B9-0685-6F49661AC5C3}">AllPhones</routePartitionName>
</dirn>
<ringSetting>Ring</ringSetting>
<consecutiveRingSetting>Use System Default</consecutiveRingSetting>
<displayAscii>$LABL</displayAscii>
<e164Mask>$Mask</e164Mask>
<callInfoDisplay>
<callerName>true</callerName>
<callerNumber>false</callerNumber>
<redirectedNumber>false</redirectedNumber>
<dialedNumber>true</dialedNumber>
</callInfoDisplay>
<associatedEndusers>
<enduser>
<userId>$OWNR</userId>
</enduser>
</associatedEndusers>
</line>
</lines>
<userId>$OWNR</userId>
<rerouteCallingSearchSpaceName>$CSS</rerouteCallingSearchSpaceName>
<dndOption>Call Reject</dndOption>
<dndStatus>false</dndStatus>
</remoteDestinationProfile>
</ns:addRemoteDestinationProfile>
</soapenv:Body>
</soapenv:Envelope>
"@
Invoke-RestMethod -Uri $URI  -body $APIRDP -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType “Text/XML” -Method post -ErrorAction Ignore
##VOICEMAIL SECTION###
### Locate and import user from LDAP. ###
if ($URIuserREQ.InnerXml.Contains("$EXT8") -eq 0 -and $URIuserREQ.InnerXml.Contains("$OWNR") -eq 0){
$URIpkid = "https://gob-cuc-1.andersonsinc.com/vmrest/import/users/ldap?query=(alias is $OWNR)"
$URIpkidUSER = Invoke-RestMethod -Uri $URIpkid  -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}  -Method Get -ErrorAction Ignore #-ContentType “Text/XML”
$PKID = $URIpkidUSER.OuterXml
### Weed out PKID from OuterXml output. ###
$PKID = $PKID | select-string -pattern "(?<=<pkid>)(.*)(?=\</pkid>)" | ForEach-Object {$_.Matches.Groups[1].value}
$PKID
$URIimport = "https://gob-cuc-1.andersonsinc.com/vmrest/import/users/ldap?templateAlias=$VMTemplate"
### Actually import the user. ###
$IMPORT = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<ImportUser>
<dtmfAccessId>$EXT8</dtmfAccessId>
<pkid>$PKID</pkid>
</ImportUser>
"@
Invoke-RestMethod -Uri $URIimport  -body $IMPORT -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}  -Method Post -ErrorAction Ignore -ContentType "application/xml"
$URIdata = "https://gob-cuc-1.andersonsinc.com/vmrest/users/?query=(Alias is $OWNR)"
$URIdataCALL = Invoke-RestMethod -Uri $URIdata  -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}  -Method Get -ErrorAction Ignore #-ContentType “Text/XML”
#$result.OuterXml.Contains("DtmfAccessId")
#$result.OuterXml
$DTMF = $URIdataCALL.OuterXml
$DTMF = $DTMF | select-string -pattern "(?<=<DtmfAccessId>)(.*)(?=\</DtmfAccessId>)" | ForEach-Object {$_.Matches.Groups[1].value}
#$DTMF
$Alias = $URIdataCALL.OuterXml
$Alias = $Alias | select-string -pattern "(?<=<Alias>)(.*)(?=\</Alias>)" | ForEach-Object {$_.Matches.Groups[1].value}
#$Alias
$OID = $URIdataCALL.Outerxml
$OID = $OID | select-string -pattern "(?<=<ObjectId>)(.*)(?=\</ObjectId>)" | ForEach-Object {$_.Matches.Groups[1].value}
#$OID
$URIalt = "https://gob-cuc-1.andersonsinc.com/vmrest/users/$OID/alternateextensions"
### For locations that have two alternate ID numbers. ###
if ($CITY -like "Maumee*" -or $SITE -like "SCC" -or $SITE -like "SCF" -or $SITE -like "SGT"){
#BELOW = gob-cuc-1 partition
$ALT1 = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<AlternateExtension>
<IdIndex>2</IdIndex>
<DtmfAccessId>$DIDplus</DtmfAccessId>
<PartitionObjectId>$gobcuc1</PartitionObjectId>
</AlternateExtension>
"@
Invoke-RestMethod -Uri $URIalt  -body $ALT1 -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}  -Method Post -ErrorAction Ignore -ContentType "application/xml"
}
#BELOW = GOB Partition
$ALT2 = @"
<AlternateExtension>
<IdIndex>3</IdIndex>
<DtmfAccessId>$EXT4</DtmfAccessId>
<PartitionObjectId>$VMpartition</PartitionObjectId>
</AlternateExtension>
"@
Invoke-RestMethod -Uri $URIalt  -body $ALT2 -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}  -Method Post -ErrorAction Ignore -ContentType "application/xml"
### Update user's LDAP account w/ new phone numbers with proper formatting based on field. ###
$AC = $null
$RC = $null
$L4 = $null
$DNtn = $null
#$TN
$AC = $MASK.Substring(0,3)
#$AC
$RC = $MASK.Substring(3,3)
#$RC
$L4 = $MASK.Substring(6,4)
$DIDtn = "($AC) $RC-$L4"
Set-ADUser -Identity $OWNR -Replace @{ipPhone="$DIDplus"; telephonenumber="$DIDtn"}
}
}
### Write newly-reduced list of available DIDs to the old files.
$COBDIDs | Out-File $COBDIDsFILE -Force
$COBDIDs | Out-File -Force $COBDIDsFILE
$HUDDNs | Out-File -Force $HUDDNsFILE
#$HUMDNs | Out-File -Force $HumDNsFILE
$WEBDNs | Out-File -Force $WebDNsFILE
$UPPDNs | Out-File -Force $UppDNsFILE
$LCHDNs | Out-File -Force $LchDNsFILE
$DELDNs | Out-File -Force $DelDNsFILE
$EDWDNs | Out-File -Force $EdwDNsFILE
#$KLMDNs | Out-File -Force $KlmDNsFILE
$LORDNs | Out-File -Force $LorDNsFILE
$CARDNs | Out-File -Force $CarDNsFILE
$SCCdids | Out-File -Force $SCCDNsFILE
$SCFdids | Out-File -Force $SCFDNsFILE
$SGTdids | Out-File -Force $SGTDNsFILE
$COLdids | Out-File -Force $COLDNsFILE
$METDNs | Out-File -Force $METDNsFILE
}
}