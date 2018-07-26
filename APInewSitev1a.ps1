### New Site Creation Script ###
$URI = "https://gob-cucm-1.andersonsinc.com:8443/axl/"
$username = "AXL USERNAME GOES HERE"
$password = "PASSWORD GOES HERE"
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username,$password)))
#Invoke-RestMethod -Uri $URI -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} 
### DO NOT CHANGE ABOVE (other than username/password) ###
### Base.csv is a CSV file with the following columns:
### SITEID, IP, COBorNOT, PREFIX, TZ, and City.###
### COBorNOT refers to my company's central location which is configured a little differently than other sites due to our 
### local SIP trunk for calls.  You can probably eliminate this column and references to it if all of your sites are identical.
### SITEID is the 3-Digit Site ID.
### IP is the IP Address of the local voice router.
### Prefix is the four-digit site prefix for internal calling.
### TZ is Time Zone. ###
$BASEfile = "C:\Scripts\NewSite\Base.csv"
$BASE = $null
$BASE = Import-Csv $BASEfile
foreach ($SITE in $BASE){
    $SITEID = $SITE.SITEID
    $IP = $SITE.IP
    $COBorNOT = $SITE.COBorNOT
    $PREFIX = $SITE.PREFIX
    $TZ = $SITE.TZ
    if ($TZ -like "EDT"){
        $TZ = "EST"
        }
    if ($TZ -like "CDT"){
        $TZ = "CST"
        }
    $CITY = $SITE.CITY
    ### Device Pool ###
    $DP = "$SITEID-DP"
    ### Standard Local Route Group uuid - You'll need to find this out for your own local cluster. ###
    $SLRGuuid = "00000000-1111-0000-0000-000000000000"
    ### SRST instance ###
    $SRST = "$SITEID-SRST"
    ### We use Cisco 4321s at our site, but you can call them whatever you want. ###
    $4321 = "$SITEID-4321"
    ### Route Group ###
    $RG = "$SITEID-RG"
    ### Route List ###
    $RL = "$SITEID-RL"
    ### VoiceMail Profile ###
    $VMP = "$SITEID-VMP"
    ### Cisco Unified Communicatiosn Manager Group uuid - Find your own. ###
    $CMGNuuid = "C413001B-C34C-6A72-AE0B-86B6587F88FE"
    $CUGNname = "CUCM-2-3-1"
    ### Calling Search Spaces ###
    $CSSlocal = "$SITEID-Local"
    $CSSld = "$SITEID-LD"
    $CSSintl = "$SITEID-INTL"
    $CSS911 = "$SITEID-911"
    ### Partitions ###
    $PT = "$SITEID-PT"
    $PTet = "$SITEID-Extension-Translation"
    $PTpl = "$SITEID-PSTN-Local"
    ### Calling Search Space for the Translation Pattern that we'll build. ###
    $CSStx = "AllPhones"
    ### Route Plan ###
    $RP = "810010501"+$PREFIX.Substring(1,3)
    ### Unity CSS ###
    $CSS = "$SITEID-CSS"
    ### Unity Class of Service ###
    $COS = "$SITEID-COS"
    ### Unity VoiceMail Template ###
    $VMtemplate = "$SITEID-Template"
### This is the SRST XML string that we'll send to CUCM. ###
$SRSTxml = [xml]@"
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/11.5">
<soapenv:Header/>
<soapenv:Body>
<ns:addSrst>
<srst>
<name>$SRST</name>
<port>2000</port>
<SipPort>5060</SipPort>
<ipAddress>$IP</ipAddress>
</srst>
</ns:addSrst>
</soapenv:Body>
</soapenv:Envelope>
"@
$SRSTresult = Invoke-RestMethod -Uri $URI  -body $SRSTxml -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType “Text/XML” -Method post -ErrorAction Ignore
$SRSTresult
$DPxml = [xml]@"
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/11.5">
<soapenv:Header/>
<soapenv:Body>
<ns:addDevicePool>
<devicePool>
<name>$DP</name>
<dateTimeSettingName>$TZ</dateTimeSettingName>
<callManagerGroupName uuid="{C413001B-C34C-6A72-AE0B-86B6587F88FE}">CUCM-2-3-1</callManagerGroupName>
<mediaResourceListName uuid="{B07236CA-F0F0-00A2-B73A-CFB63541727F}">SUB-PUB</mediaResourceListName>
<regionName uuid="{1B1B9EB1-7803-11D3-BDF0-00108302EAD1}">GOB</regionName>
<srstName>$SRST</srstName>
<locationName uuid="{29C5C1C4-8871-4D1E-8394-0B9181E8C54D}">Hub_None</locationName>
<revertPriority>Default</revertPriority>
<singleButtonBarge>Default</singleButtonBarge>
<joinAcrossLines>Default</joinAcrossLines>
<callingPartyNationalPrefix>Default</callingPartyNationalPrefix>
<callingPartyInternationalPrefix>Default</callingPartyInternationalPrefix>
<callingPartyUnknownPrefix>Default</callingPartyUnknownPrefix>
<callingPartySubscriberPrefix>Default</callingPartySubscriberPrefix>
<calledPartyNationalPrefix>Default</calledPartyNationalPrefix>
<calledPartyInternationalPrefix>Default</calledPartyInternationalPrefix>
<calledPartyUnknownPrefix>Default</calledPartyUnknownPrefix>
<calledPartySubscriberPrefix>Default</calledPartySubscriberPrefix>
<localRouteGroup>
<name>Standard Local Route Group</name>
</localRouteGroup>
</devicePool>
</ns:addDevicePool>
</soapenv:Body>
</soapenv:Envelope>
"@
$DPresult = Invoke-RestMethod -Uri $URI  -body $DPxml -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType “Text/XML” -Method post -ErrorAction Ignore
### You don't actually need to output $DPresult, it's just to let me know it was successful when running the code. ###
$DPresult 
$Trunkxml = [xml]@"
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/11.5">
<soapenv:Header/>
<soapenv:Body>
<ns:addSipTrunk>
<sipTrunk>
<name>$4321</name>
<description>$City 4321 ISR</description>
<product>SIP Trunk</product>
<model>SIP Trunk</model>
<class>Trunk</class>
<protocol>SIP</protocol>
<protocolSide>Network</protocolSide>
<callingSearchSpaceName>Gateway Globalization Step 1</callingSearchSpaceName>
<devicePoolName>$DP</devicePoolName>
<networkLocation>Use System Default</networkLocation>
<locationName>Hub_None</locationName>
<traceFlag>false</traceFlag>
<mlppIndicationStatus>Off</mlppIndicationStatus>
<preemption>Disabled</preemption>
<useTrustedRelayPoint>Default</useTrustedRelayPoint>
<retryVideoCallAsAudio>true</retryVideoCallAsAudio>
<securityProfileName>CUBE Non Secure SIP Trunk Profile</securityProfileName>
<sipProfileName>CUBE SIP Profile</sipProfileName>
<useDevicePoolCgpnTransformCss>true</useDevicePoolCgpnTransformCss>
<geoLocationName/>
<geoLocationFilterName/>
<sendGeoLocation>false</sendGeoLocation>
<cdpnTransformationCssName/>
<useDevicePoolCdpnTransformCss>true</useDevicePoolCdpnTransformCss>
<unattendedPort>false</unattendedPort>
<transmitUtf8>false</transmitUtf8>
<subscribeCallingSearchSpaceName/>
<rerouteCallingSearchSpaceName/>
<referCallingSearchSpaceName/>
<mtpRequired>false</mtpRequired>
<presenceGroupName>Standard Presence group</presenceGroupName>
<unknownPrefix>Default</unknownPrefix>
<destAddrIsSrv>false</destAddrIsSrv>
<tkSipCodec>711ulaw</tkSipCodec>
<sigDigits enable="false">99</sigDigits>
<connectedNamePresentation>Default</connectedNamePresentation>
<connectedPartyIdPresentation>Default</connectedPartyIdPresentation>
<callingPartySelection>Originator</callingPartySelection>
<callingname>Default</callingname>
<callingLineIdPresentation>Default</callingLineIdPresentation>
<prefixDn/>
<callerName/>
<callerIdDn/>
<acceptInboundRdnis>false</acceptInboundRdnis>
<acceptOutboundRdnis>false</acceptOutboundRdnis>
<srtpAllowed>false</srtpAllowed>
<srtpFallbackAllowed>true</srtpFallbackAllowed>
<isPaiEnabled>true</isPaiEnabled>
<sipPrivacy>Default</sipPrivacy>
<isRpidEnabled>true</isRpidEnabled>
<sipAssertedType>Default</sipAssertedType>
<dtmfSignalingMethod>No Preference</dtmfSignalingMethod>
<routeClassSignalling>Default</routeClassSignalling>
<sipTrunkType>None(Default)</sipTrunkType>
<pstnAccess>false</pstnAccess>
<imeE164TransformationName/>
<useImePublicIpPort>false</useImePublicIpPort>
<useDevicePoolCntdPnTransformationCss>true</useDevicePoolCntdPnTransformationCss>
<cntdPnTransformationCssName/>
<useDevicePoolCgpnTransformCssUnkn>true</useDevicePoolCgpnTransformCssUnkn>
<rdnTransformationCssName/>
<useDevicePoolRdnTransformCss>true</useDevicePoolRdnTransformCss>
<sipNormalizationScriptName/>
<runOnEveryNode>false</runOnEveryNode>
<destinations>
<destination>
<addressIpv4>$IP</addressIpv4>
<addressIpv6/>
<port>5060</port>
<sortOrder>1</sortOrder>
</destination>
</destinations>
<tunneledProtocol>None</tunneledProtocol>
<asn1RoseOidEncoding>No Changes</asn1RoseOidEncoding>
<qsigVariant>No Changes</qsigVariant>
<pathReplacementSupport>false</pathReplacementSupport>
<enableQsigUtf8>false</enableQsigUtf8>
<scriptParameters/>
<scriptTraceEnabled>false</scriptTraceEnabled>
<trunkTrafficSecure>When using both sRTP and TLS</trunkTrafficSecure>
<callingAndCalledPartyInfoFormat>Deliver DN only in connected party</callingAndCalledPartyInfoFormat>
<useCallerIdCallerNameinUriOutgoingRequest>false</useCallerIdCallerNameinUriOutgoingRequest>
<requestUriDomainName/>
<recordingInformation />
<calledPartyUnknownTransformationCssName/>
<calledPartyUnknownPrefix>Default</calledPartyUnknownPrefix>
<calledPartyUnknownStripDigits />
<useDevicePoolCalledCssUnkn>true</useDevicePoolCalledCssUnkn>
<confidentialAccess>
<confidentialAccessMode />
<confidentialAccessLevel>-1</confidentialAccessLevel>
</confidentialAccess>
</sipTrunk>
</ns:addSipTrunk>
</soapenv:Body>
</soapenv:Envelope>
"@
$Trunkresult = Invoke-RestMethod -Uri $URI  -body $Trunkxml -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType “Text/XML” -Method post -ErrorAction Ignore
$Trunkresult 
$Trunkuuidxml = [xml]@"
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/11.5">
<soapenv:Header/>
<soapenv:Body>
<ns:getSipTrunk>
<name>$4321</name>
</ns:getSipTrunk>
</soapenv:Body>
</soapenv:Envelope>
"@
$Trunkuuid = Invoke-RestMethod -Uri $URI  -body $Trunkuuidxml -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType “Text/XML” -Method post -ErrorAction Ignore
$Trunkuuid = $Trunkuuid.Outerxml
### This separates the UUID for the Trunk you just created in CUCM so it can be referenced later. ###
$Trunkuuid = $Trunkuuid | select-string -pattern "(?<=uuid=`"{)(.*)(?=\}`"><name>)" | ForEach-Object {$_.Matches.Groups[1].value}
$Trunkuuid
$RGxml = [xml]@"
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/11.5">
<soapenv:Header/>
<soapenv:Body>
<ns:addRouteGroup>
<routeGroup>
<name>$RG</name>
<dialPlanWizardGenld />
<distributionAlgorithm>Circular</distributionAlgorithm>
<members>
<member>
<deviceSelectionOrder>1</deviceSelectionOrder>
<dialPlanWizardGenId />
<deviceName uuid="$Trunkuuid">$4321</deviceName>
<port>0</port>
</member>
</members>
</routeGroup>
</ns:addRouteGroup>
</soapenv:Body>
</soapenv:Envelope>
"@
$RGresult = Invoke-RestMethod -Uri $URI  -body $RGxml -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType “Text/XML” -Method post -ErrorAction Ignore
$RGresult 
#CMGN = Call Manager Group Name
$CMGNuuidxml = [xml]@"
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/11.5">
<soapenv:Header/>
<soapenv:Body>
<ns:getSipTrunk>
<name>$4321</name>
</ns:getSipTrunk>
</soapenv:Body>
</soapenv:Envelope>
"@
$CMGNuuid = Invoke-RestMethod -Uri $URI  -body $CMGNuuidxml -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType “Text/XML” -Method post -ErrorAction Ignore
$CMGNuuid = $CMGNuuid.Outerxml
$CMGNuuid = $CMGNuuid | select-string -pattern "(?<=uuid=`"{)(.*)(?=\}`"><name>)" | ForEach-Object {$_.Matches.Groups[1].value}
$CMGNuuid
$RLxml = [xml]@"
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/11.5">
<soapenv:Header/>
<soapenv:Body>
<ns:addRouteList>
<routeList>
<name>$RL</name>
<description>$City Route List</description>
<callManagerGroupName uuid="$CMGNuuid">$CUGNname</callManagerGroupName>
<members>
<member>
<routeGroupName>$RG</routeGroupName>
<selectionOrder>1</selectionOrder>
<useFullyQualifiedCallingPartyNumber>Default</useFullyQualifiedCallingPartyNumber>
<callingPartyNumberingPlan>Cisco CallManager</callingPartyNumberingPlan>
<callingPartyNumberType>Cisco CallManager</callingPartyNumberType>
<calledPartyNumberingPlan>Cisco CallManager</calledPartyNumberingPlan>
<calledPartyNumberType>Cisco CallManager</calledPartyNumberType>
</member>
</members>
</routeList>
</ns:addRouteList>
</soapenv:Body>
</soapenv:Envelope>
"@
$RLresult = Invoke-RestMethod -Uri $URI  -body $RLxml -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType “Text/XML” -Method post -ErrorAction Ignore
$RLresult 
### Partitions ###
$PTetxml = [xml]@"
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/11.5">
<soapenv:Header/>
<soapenv:Body>
<ns:addRoutePartition>
<routePartition>
<name>$PTet</name>
<description>$City Extension Translation</description>
</routePartition>
</ns:addRoutePartition>
</soapenv:Body>
</soapenv:Envelope>
"@
$PTetresult = Invoke-RestMethod -Uri $URI  -body $PTetxml -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType “Text/XML” -Method post -ErrorAction Ignore
$PTetresult 
$PTplxml = [xml]@"
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/11.5">
<soapenv:Header/>
<soapenv:Body>
<ns:addRoutePartition>
<routePartition>
<name>$PTpl</name>
<description>$City PSTN Local</description>
</routePartition>
</ns:addRoutePartition>
</soapenv:Body>
</soapenv:Envelope>
"@
$PTplresult = Invoke-RestMethod -Uri $URI  -body $PTplxml -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType “Text/XML” -Method post -ErrorAction Ignore
$PTplresult 
### Calling Search Space Section ###
$CSSlocalxml = [xml]@"
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/11.5">
<soapenv:Header/>
<soapenv:Body>
<ns:addCss>
<css>
<name>$CSSlocal</name>
<description/>
<members>
<member uuid="{253E6EB6-DDB0-94A5-9101-687CFB6180CF}">
<routePartitionName uuid="{019BE812-2E96-9D9B-07D4-C5426F6968BE}">Global-Speed-Dials</routePartitionName>
<index>1</index>
</member>
<member uuid="{81F28E58-DFA4-605A-F7B4-0F30C54CD022}">
<routePartitionName uuid="{CFBD645F-AF59-B5B9-0685-6F49661AC5C3}">AllPhones</routePartitionName>
<index>2</index>
</member>
<member uuid="{851ABFA5-208D-0C0B-7E95-E7792251E74C}">
<routePartitionName uuid="{D5A5E754-DC84-C38A-C0C6-D34CCDE2FC2B}">UCCX</routePartitionName>
<index>3</index>
</member>
<member>
<routePartitionName>$PTet</routePartitionName>
<index>4</index>
</member>
<member uuid="{5509F71F-AAB3-F477-EF13-BC9D714F4DA3}">
<routePartitionName uuid="{A43A4B5C-6126-4270-BC2C-BCFDF0B1C38C}">Global Learned E164 Numbers</routePartitionName>
<index>5</index>
</member>
<member uuid="{F322D790-280C-325A-3D34-7B732CB201D0}">
<routePartitionName uuid="{D4610D02-2870-40B8-AF26-B9E8F2787D3C}">Global Learned E164 Patterns</routePartitionName>
<index>6</index>
</member>
<member uuid="{7F668EA8-235D-DFD0-FF45-A9816DA52F93}">
<routePartitionName uuid="{78A3C314-359E-4967-86D2-DFB9AB98D27B}">Global Learned Enterprise Numbers</routePartitionName>
<index>7</index>
</member>
<member uuid="{B5A8F387-E3F1-7CDC-CBB1-4AF2E487F976}">
<routePartitionName uuid="{1E6AEF18-DC5E-434F-914E-787BC7224204}">Global Learned Enterprise Patterns</routePartitionName>
<index>8</index>
</member>
<member>
<routePartitionName>$PTpl</routePartitionName>
<index>9</index>
</member>
<member uuid="{DB278C12-FC14-A394-F0B3-1D978F106C3C}">
<routePartitionName uuid="{4BE6B07C-A0BA-69AC-6D4A-68E560CCC9FB}">UStoE164</routePartitionName>
<index>10</index>
</member>
</members>
</css>
</ns:addCss>
</soapenv:Body>
</soapenv:Envelope>
"@
$CSSlocalresult = Invoke-RestMethod -Uri $URI  -body $CSSlocalxml -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType “Text/XML” -Method post -ErrorAction Ignore
$CSSlocalresult
$CSSldxml = [xml]@"
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/11.5">
<soapenv:Header/>
<soapenv:Body>
<ns:addCss>
<css>
<description/>
<dialPlanWizardGenId />
<members>
<member>
<routePartitionName>$PTpl</routePartitionName>
<index>9</index>
</member>
<member uuid="{5C54CAEE-22F6-A530-328F-FD73CDCAE722}">
<routePartitionName uuid="{4B16A302-ACEB-F5E9-89F5-CDF5C8193096}">PSTN-USNational</routePartitionName>
<index>10</index>
</member>
<member uuid="{D5737723-E71B-C1CB-4136-C9E8E8A5AD39}">
<routePartitionName uuid="{4BE6B07C-A0BA-69AC-6D4A-68E560CCC9FB}">UStoE164</routePartitionName>
<index>11</index>
</member>
<member uuid="{A0C44D99-E889-E3F3-5D51-FDE521BC9710}">
<routePartitionName uuid="{019BE812-2E96-9D9B-07D4-C5426F6968BE}">Global-Speed-Dials</routePartitionName>
<index>1</index>
</member>
<member uuid="{526D6FC9-E020-F7F6-3298-6ED2F3A4982C}">
<routePartitionName uuid="{CFBD645F-AF59-B5B9-0685-6F49661AC5C3}">AllPhones</routePartitionName>
<index>2</index>
</member>
<member uuid="{C2FC3973-5B54-A2A4-A20E-4445AD6C32AE}">
<routePartitionName uuid="{D5A5E754-DC84-C38A-C0C6-D34CCDE2FC2B}">UCCX</routePartitionName>
<index>3</index>
</member>
<member>
<routePartitionName>$PTet</routePartitionName>
<index>4</index>
</member>
<member uuid="{6CA1C60C-4FA6-D15E-4B23-884225E03773}">
<routePartitionName uuid="{A43A4B5C-6126-4270-BC2C-BCFDF0B1C38C}">Global Learned E164 Numbers</routePartitionName>
<index>5</index>
</member>
<member uuid="{F48F1887-DDAA-55CD-4B15-06BFD15F96E0}">
<routePartitionName uuid="{D4610D02-2870-40B8-AF26-B9E8F2787D3C}">Global Learned E164 Patterns</routePartitionName>
<index>6</index>
</member>
<member uuid="{5BB220DE-C0AA-38A4-9562-506774A7949D}">
<routePartitionName uuid="{78A3C314-359E-4967-86D2-DFB9AB98D27B}">Global Learned Enterprise Numbers</routePartitionName>
<index>7</index>
</member>
<member uuid="{3C779F60-4148-0FC7-DE11-5771B741B3DC}">
<routePartitionName uuid="{1E6AEF18-DC5E-434F-914E-787BC7224204}">Global Learned Enterprise Patterns</routePartitionName>
<index>8</index>
</member>
</members>
<partitionUsage>General</partitionUsage>
<name>$CSSld</name>
</css>
</ns:addCss>
</soapenv:Body>
</soapenv:Envelope>
"@
$CSSldresult = Invoke-RestMethod -Uri $URI  -body $CSSldxml -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType “Text/XML” -Method post -ErrorAction Ignore
$CSSldresult
$CSS911xml = [xml]@"
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/11.5">
<soapenv:Header/>
<soapenv:Body>
<ns:addCss>
<css>
<description/>
<dialPlanWizardGenId />
<members>
<member uuid="{EF374E98-F3D7-DAE1-148A-39C86C857266}">
<routePartitionName uuid="{019BE812-2E96-9D9B-07D4-C5426F6968BE}">Global-Speed-Dials</routePartitionName>
<index>1</index>
</member>
<member uuid="{354F38E3-462A-B53B-5C62-F008C7A1E265}">
<routePartitionName uuid="{CFBD645F-AF59-B5B9-0685-6F49661AC5C3}">AllPhones</routePartitionName>
<index>2</index>
</member>
<member uuid="{6D2775E4-2C72-5768-B9F9-E42C4D917140}">
<routePartitionName uuid="{D5A5E754-DC84-C38A-C0C6-D34CCDE2FC2B}">UCCX</routePartitionName>
<index>3</index>
</member>
<member>
<routePartitionName>$PTet</routePartitionName>
<index>4</index>
</member>
<member uuid="{EC3EA661-AF06-90E8-72B8-B685428A75DE}">
<routePartitionName uuid="{A43A4B5C-6126-4270-BC2C-BCFDF0B1C38C}">Global Learned E164 Numbers</routePartitionName>
<index>5</index>
</member>
<member uuid="{40FCD406-B40B-9B68-AFC8-B88C674F4C87}">
<routePartitionName uuid="{D4610D02-2870-40B8-AF26-B9E8F2787D3C}">Global Learned E164 Patterns</routePartitionName>
<index>6</index>
</member>
<member uuid="{981A1AC8-0652-74EA-B44C-31FB0175E839}">
<routePartitionName uuid="{78A3C314-359E-4967-86D2-DFB9AB98D27B}">Global Learned Enterprise Numbers</routePartitionName>
<index>7</index>
</member>
<member uuid="{33170658-BC23-F142-656D-19E6CE89920E}">
<routePartitionName uuid="{1E6AEF18-DC5E-434F-914E-787BC7224204}">Global Learned Enterprise Patterns</routePartitionName>
<index>8</index>
</member>
<member uuid="{9BD6D070-5501-1535-9526-80F47343D218}">
<routePartitionName uuid="{4BE6B07C-A0BA-69AC-6D4A-68E560CCC9FB}">UStoE164</routePartitionName>
<index>9</index>
</member>
</members>
<partitionUsage>General</partitionUsage>
<name>$CSS911</name>
</css>
</ns:addCss>
</soapenv:Body>
</soapenv:Envelope>
"@
$CSS911result = Invoke-RestMethod -Uri $URI  -body $CSS911xml -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType “Text/XML” -Method post -ErrorAction Ignore
$CSS911result
$CSSintlxml = [xml]@"
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/11.5">
<soapenv:Header/>
<soapenv:Body>
<ns:addCss>
<css>
<description/>
<dialPlanWizardGenId />
<members>
<member uuid="{D03E53AE-3777-09E6-EB2D-99168C80CC55}">
<routePartitionName uuid="{019BE812-2E96-9D9B-07D4-C5426F6968BE}">Global-Speed-Dials</routePartitionName>
<index>1</index>
</member>
<member uuid="{66109A2C-71D7-A0DF-E645-B014844E7F10}">
<routePartitionName uuid="{CFBD645F-AF59-B5B9-0685-6F49661AC5C3}">AllPhones</routePartitionName>
<index>2</index>
</member>
<member uuid="{B0742C63-3918-00AE-C39D-B5419C9F86F0}">
<routePartitionName uuid="{D5A5E754-DC84-C38A-C0C6-D34CCDE2FC2B}">UCCX</routePartitionName>
<index>3</index>
</member>
<member>
<routePartitionName>$PTet</routePartitionName>
<index>4</index>
</member>
<member uuid="{D49ABFC9-FFB1-F019-2DCC-BAC125AB5BB8}">
<routePartitionName uuid="{A43A4B5C-6126-4270-BC2C-BCFDF0B1C38C}">Global Learned E164 Numbers</routePartitionName>
<index>5</index>
</member>
<member uuid="{4B5584FE-5654-BC15-7490-74BE58F777F5}">
<routePartitionName uuid="{D4610D02-2870-40B8-AF26-B9E8F2787D3C}">Global Learned E164 Patterns</routePartitionName>
<index>6</index>
</member>
<member uuid="{C1936640-72A8-8303-2AC1-604C21CBF19A}">
<routePartitionName uuid="{78A3C314-359E-4967-86D2-DFB9AB98D27B}">Global Learned Enterprise Numbers</routePartitionName>
<index>7</index>
</member>
<member uuid="{F19CA0A6-72C6-41AB-754E-54AC375642FB}">
<routePartitionName uuid="{1E6AEF18-DC5E-434F-914E-787BC7224204}">Global Learned Enterprise Patterns</routePartitionName>
<index>8</index>
</member>
<member>
<routePartitionName>$PTpl</routePartitionName>
<index>9</index>
</member>
<member uuid="{97DCC723-1AB9-ACE2-55AF-221DA2452A88}">
<routePartitionName uuid="{4B16A302-ACEB-F5E9-89F5-CDF5C8193096}">PSTN-USNational</routePartitionName>
<index>10</index>
</member>
<member uuid="{3CFB2A50-F493-ED4C-E6BA-11EA81910F16}">
<routePartitionName uuid="{EFE64F21-7CC4-E546-8845-8D2B05B62383}">PSTN-INTL</routePartitionName>
<index>11</index>
</member>
<member uuid="{C8E83D3B-ECE8-F30E-CF01-524DC22E6B0D}">
<routePartitionName uuid="{4BE6B07C-A0BA-69AC-6D4A-68E560CCC9FB}">UStoE164</routePartitionName>
<index>12</index>
</member>
</members>
<partitionUsage>General</partitionUsage>
<name>$CSSintl</name>
</css>
</ns:addCss>
</soapenv:Body>
</soapenv:Envelope>
"@
$CSSintlresult = Invoke-RestMethod -Uri $URI  -body $CSSintlxml -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType “Text/XML” -Method post -ErrorAction Ignore
$CSSintlresult
### Voicemail Profile Section ###
$VMPxml = [xml]@"
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/11.5">
<soapenv:Header/>
<soapenv:Body>
<ns:addVoiceMailProfile>
<voiceMailProfile>
<name>$VMP</name>
<description>$City Voicemail Profile</description>
<voiceMailboxMask>$($Prefix)XXXX</voiceMailboxMask>
<voiceMailPilot>
<dirn>81006600</dirn>
<cssName>AllPhones</cssName>
</voiceMailPilot>
</voiceMailProfile>
</ns:addVoiceMailProfile>
</soapenv:Body>
</soapenv:Envelope>
"@
$VMPxmlresult = Invoke-RestMethod -Uri $URI  -body $VMPxml -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType “Text/XML” -Method post -ErrorAction Ignore
$VMPxmlresult 
### Translation Pattern for Globalization ###
$TXGxml = [xml]@"
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/11.5">
<soapenv:Header/>
<soapenv:Body>
<ns:addTransPattern>
<transPattern>
<pattern>$($PREFIX)XXXX</pattern>
<description>Inbound call routing globalize called number</description>
<usage>Translation</usage>
<routePartitionName uuid="{0E892E9F-9025-92EF-9537-422E63DA8907}">Gateway Globalization Step 1</routePartitionName>
<blockEnable>false</blockEnable>
<calledPartyTransformationMask/>
<callingPartyTransformationMask/>
<useCallingPartyPhoneMask>Off</useCallingPartyPhoneMask>
<callingPartyPrefixDigits/>
<dialPlanName/>
<digitDiscardInstructionName/>
<patternUrgency>true</patternUrgency>
<prefixDigitsOut/>
<routeFilterName/>
<callingLinePresentationBit>Default</callingLinePresentationBit>
<callingNamePresentationBit>Default</callingNamePresentationBit>
<connectedLinePresentationBit>Default</connectedLinePresentationBit>
<connectedNamePresentationBit>Default</connectedNamePresentationBit>
<patternPrecedence>Default</patternPrecedence>
<provideOutsideDialtone>true</provideOutsideDialtone>
<callingPartyNumberingPlan>Cisco CallManager</callingPartyNumberingPlan>
<callingPartyNumberType>Cisco CallManager</callingPartyNumberType>
<calledPartyNumberingPlan>Cisco CallManager</calledPartyNumberingPlan>
<calledPartyNumberType>Cisco CallManager</calledPartyNumberType>
<callingSearchSpaceName uuid="{71BBCE98-4516-1053-C1CC-F924AE88F4B8}">Gateway Globalization Step 2</callingSearchSpaceName>
<resourcePriorityNamespaceName/>
<routeNextHopByCgpn>true</routeNextHopByCgpn>
<routeClass>Default</routeClass>
<callInterceptProfileName/>
<releaseClause>No Error</releaseClause>
<useOriginatorCss>false</useOriginatorCss>
<dontWaitForIDTOnSubsequentHops>false</dontWaitForIDTOnSubsequentHops>
<isEmergencyServiceNumber>false</isEmergencyServiceNumber>
</transPattern>
</ns:addTransPattern>
</soapenv:Body>
</soapenv:Envelope>
"@
$TXGxmlresult = Invoke-RestMethod -Uri $URI  -body $TXGxml -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType “Text/XML” -Method post -ErrorAction Ignore
$TXGxmlresult 
### Translation Pattern for 4-digit local dialing ###
$TX4to8xml = [xml]@"
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/11.5">
<soapenv:Header/>
<soapenv:Body>
<ns:addTransPattern>
<transPattern uuid="{FA9EA4C0-C078-65FA-7B44-7A0CAAA6F291}">
<pattern>1[1-3]XX</pattern>
<description>$SITEID 4 Digit dialing expand to E164</description>
<usage>Translation</usage>
<routePartitionName>$PTet</routePartitionName>
<blockEnable>false</blockEnable>
<calledPartyTransformationMask>$($PREFIX)XXXX</calledPartyTransformationMask>
<callingPartyTransformationMask/>
<useCallingPartyPhoneMask>Off</useCallingPartyPhoneMask>
<callingPartyPrefixDigits/>
<dialPlanName/>
<digitDiscardInstructionName/>
<patternUrgency>true</patternUrgency>
<prefixDigitsOut/>
<routeFilterName/>
<callingLinePresentationBit>Default</callingLinePresentationBit>
<callingNamePresentationBit>Default</callingNamePresentationBit>
<connectedLinePresentationBit>Default</connectedLinePresentationBit>
<connectedNamePresentationBit>Default</connectedNamePresentationBit>
<patternPrecedence>Default</patternPrecedence>
<provideOutsideDialtone>true</provideOutsideDialtone>
<callingPartyNumberingPlan>Cisco CallManager</callingPartyNumberingPlan>
<callingPartyNumberType>Cisco CallManager</callingPartyNumberType>
<calledPartyNumberingPlan>Cisco CallManager</calledPartyNumberingPlan>
<calledPartyNumberType>Cisco CallManager</calledPartyNumberType>
<callingSearchSpaceName>$CSStx</callingSearchSpaceName>
<resourcePriorityNamespaceName/>
<routeNextHopByCgpn>false</routeNextHopByCgpn>
<routeClass>Default</routeClass>
<callInterceptProfileName/>
<releaseClause>No Error</releaseClause>
<useOriginatorCss>false</useOriginatorCss>
<dontWaitForIDTOnSubsequentHops>false</dontWaitForIDTOnSubsequentHops>
<isEmergencyServiceNumber>false</isEmergencyServiceNumber>
</transPattern>
</ns:addTransPattern>
</soapenv:Body>
</soapenv:Envelope>
"@
$TX4to8result = Invoke-RestMethod -Uri $URI  -body $TX4to8xml -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType “Text/XML” -Method post -ErrorAction Ignore
$TX4to8result 
$RP911 = [xml]@"
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/11.5">
<soapenv:Header/>
<soapenv:Body>
<ns:addRoutePattern>
<routePattern>
<pattern>$RP</pattern>
<description>CER $SITEID Route Pattern</description>
<usage>Route</usage>
<routePartitionName uuid="{B4A1D4A6-5FF3-1CBE-C82C-C5CF111858E3}">CER-911</routePartitionName>
<blockEnable>false</blockEnable>
<calledPartyTransformationMask>911</calledPartyTransformationMask>
<useCallingPartyPhoneMask>Off</useCallingPartyPhoneMask>
<dialPlanName/>
<dialPlanWizardGenId />
<networkLocation>OffNet</networkLocation>
<patternUrgency>false</patternUrgency>
<callingLinePresentationBit>Default</callingLinePresentationBit>
<callingNamePresentationBit>Default</callingNamePresentationBit>
<connectedLinePresentationBit>Default</connectedLinePresentationBit>
<connectedNamePresentationBit>Default</connectedNamePresentationBit>
<supportOverlapSending>false</supportOverlapSending>
<patternPrecedence>Default</patternPrecedence>
<releaseClause>No Error</releaseClause>
<allowDeviceOverride>false</allowDeviceOverride>
<provideOutsideDialtone>false</provideOutsideDialtone>
<callingPartyNumberingPlan>Cisco CallManager</callingPartyNumberingPlan>
<callingPartyNumberType>Cisco CallManager</callingPartyNumberType>
<calledPartyNumberingPlan>Cisco CallManager</calledPartyNumberingPlan>
<calledPartyNumberType>Cisco CallManager</calledPartyNumberType>
<destination>
<routeListName>$RL</routeListName>
</destination>
<authorizationCodeRequired>false</authorizationCodeRequired>
<authorizationLevelRequired>0</authorizationLevelRequired>
<clientCodeRequired>false</clientCodeRequired>
<routeClass>Default</routeClass>
<externalCallControl/>
<isEmergencyServiceNumber>false</isEmergencyServiceNumber>
</routePattern>
</ns:addRoutePattern>
</soapenv:Body>
</soapenv:Envelope>
"@
$RP911result = Invoke-RestMethod -Uri $URI  -body $RP911 -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType “Text/XML” -Method post -ErrorAction Ignore
$RP911result 
<# ###THIS PART DOES NOT APPEAR TO BE NECESSARY###
$RGuuid = [xml]@"
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/11.5">
<soapenv:Header/>
<soapenv:Body>
<ns:getRouteGroup>
<name>$RG</name>
<returnedTags>uuid</returnedTags>
</ns:getRouteGroup>
</soapenv:Body>
</soapenv:Envelope>
"@
$RGuuidResult = Invoke-RestMethod -Uri $URI  -body $RGuuid -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType “Text/XML” -Method post -ErrorAction Ignore
$RGuuidResult.OuterXml
$RGuuid = $RGuuidResult.OuterXml | select-string -pattern "(?<={)(.*)(?=\})" | ForEach-Object {$_.Matches.Groups[1].value}
$RGuuid
#>
$DPupdate = [xml]@"
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://www.cisco.com/AXL/API/11.5">
<soapenv:Header/>
<soapenv:Body>
<ns:updateDevicePool>
<name>$DP</name>
<localRouteGroup>
<name>Standard Local Route Group</name>
<value>$RG</value>
</localRouteGroup>
</ns:updateDevicePool>
</soapenv:Body>
</soapenv:Envelope>
"@
$DPupdateResult = Invoke-RestMethod -Uri $URI  -body $DPupdate -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType “Text/XML” -Method post -ErrorAction Ignore
$DPupdateResult
### Unity Section ###
$URIpt = "https://gob-cuc-1.andersonsinc.com/vmrest/partitions"
$BODYpt = @"
<Partition>
<Name>$PT</Name>
<Description>$City Partition</Description>
</Partition>
"@
Invoke-RestMethod -Uri $URIpt  -body $BODYpt -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}  -Method Post -ErrorAction Ignore -ContentType "application/xml"
$URIptNEW = "https://gob-cuc-1.andersonsinc.com/vmrest/partitions?query=(name is $PT)"
$ptOID = Invoke-RestMethod -Uri $URIptNEW -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}  -Method Get -ErrorAction Ignore -ContentType "application/xml"
#$ptALL.OuterXml
$ptOID = $ptOID.OuterXml | select-string -pattern "(?<=<ObjectId>)(.*)(?=\</ObjectId>)" | ForEach-Object {$_.Matches.Groups[1].value}
$ptOID
$URIcss = "https://gob-cuc-1.andersonsinc.com/vmrest/searchspaces"
$BODYcss = @"
<SearchSpace>
<Name>$CSS</Name>
<Description>$City Search Space</Description>
</SearchSpace>
"@
Invoke-RestMethod -Uri $URIcss  -body $BODYcss -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}  -Method Post -ErrorAction Ignore -ContentType "application/xml"
$URIcssNEW = "https://gob-cuc-1.andersonsinc.com/vmrest/searchspaces?query=(name is $CSS)"
$cssOID = Invoke-RestMethod -Uri $URIcssNEW -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}  -Method Get -ErrorAction Ignore -ContentType "application/xml"
#$ptALL.OuterXml
$cssOID = $cssOID.OuterXml | select-string -pattern "(?<=<ObjectId>)(.*)(?=\</ObjectId>)" | ForEach-Object {$_.Matches.Groups[1].value}
$cssOID
$URIcos = "https://gob-cuc-1.andersonsinc.com/vmrest/coses"
$BODYcos = @"
<cos>
<DisplayName>$COS</DisplayName>
<AccessFaxMail>false</AccessFaxMail>
<AccessTts>false</AccessTts>
<CallHoldAvailable>false</CallHoldAvailable>
<CallScreenAvailable>false</CallScreenAvailable>
<CanRecordName>true</CanRecordName>
<ListInDirectoryStatus>true</ListInDirectoryStatus>
<MaxGreetingLength>90</MaxGreetingLength>
<MaxMsgLength>300</MaxMsgLength>
<MaxNameLength>30</MaxNameLength>
<MaxPrivateDlists>25</MaxPrivateDlists>
<MovetoDeleteFolder>true</MovetoDeleteFolder>
<PersonalAdministrator>true</PersonalAdministrator>
<Undeletable>false</Undeletable>
<WarnIntervalMsgEnd>0</WarnIntervalMsgEnd>
<CanSendToPublicDl>true</CanSendToPublicDl>
<EnableEnhancedSecurity>false</EnableEnhancedSecurity>
<AccessVmi>true</AccessVmi>
<AccessLiveReply>false</AccessLiveReply>
<UaAlternateExtensionAccess>0</UaAlternateExtensionAccess>
<AccessCallRoutingRules>false</AccessCallRoutingRules>
<WarnMinMsgLength>0</WarnMinMsgLength>
<SendBroadcastMessage>false</SendBroadcastMessage>
<UpdateBroadcastMessage>false</UpdateBroadcastMessage>
<AccessVui>false</AccessVui>
<ImapCanFetchMessageBody>true</ImapCanFetchMessageBody>
<ImapCanFetchPrivateMessageBody>true</ImapCanFetchPrivateMessageBody>
<MaxMembersPVL>99</MaxMembersPVL>
<AccessIMAP>true</AccessIMAP>
<ReadOnly>false</ReadOnly>
<AccessAdvancedUserFeatures>true</AccessAdvancedUserFeatures>
<AccessAdvancedUser>true</AccessAdvancedUser>
<AccessUnifiedClient>false</AccessUnifiedClient>
<RequireSecureMessages>4</RequireSecureMessages>
<AccessOutsideLiveReply>false</AccessOutsideLiveReply>
<AccessSTT>false</AccessSTT>
<EnableSTTSecureMessage>0</EnableSTTSecureMessage>
<MessagePlaybackRestriction>0</MessagePlaybackRestriction>
<SttType>1</SttType>
<PlaybackMessageAndGreetings>false</PlaybackMessageAndGreetings>
<OutsideCallers>false</OutsideCallers>
</cos>
"@
Invoke-RestMethod -Uri $URIcos  -body $BODYcos -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}  -Method Post -ErrorAction Ignore -ContentType "application/xml"
$URIcosNEW = "https://gob-cuc-1.andersonsinc.com/vmrest/coses?query=(displayname is $COS)"
$cosOID = Invoke-RestMethod -Uri $URIcosNEW -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}  -Method Get -ErrorAction Ignore -ContentType "application/xml"
#$ptALL.OuterXml
$cosOID = $cosOID.OuterXml | select-string -pattern "(?<=<ObjectId>)(.*)(?=\</ObjectId>)" | ForEach-Object {$_.Matches.Groups[1].value}
$cosOID
$URIvmtemplate = "https://gob-cuc-1.andersonsinc.com/vmrest/usertemplates?templateAlias=voicemailusertemplate"
$BODYvmtemplate = @"
<UserTemplate>
<Alias>$VMtemplate</Alias>
<UseDefaultLanguage>true</UseDefaultLanguage>
<UseDefaultTimeZone>true</UseDefaultTimeZone>
<Country>US</Country>
<DisplayName>$City Template</DisplayName>
<TimeZone>$TZ</TimeZone>
<CosObjectId>$cosOID</CosObjectId>
<Language>1033</Language>
<LocationObjectId>e7748e36-cacd-4495-b71e-b38ca6bc09ef</LocationObjectId>
<AddressMode>0</AddressMode>
<ClockMode>0</ClockMode>
<ConversationTui>SubMenu</ConversationTui>
<GreetByName>true</GreetByName>
<ListInDirectory>true</ListInDirectory>
<IsVmEnrolled>true</IsVmEnrolled>
<SayCopiedNames>true</SayCopiedNames>
<SayDistributionList>true</SayDistributionList>
<SayMsgNumber>true</SayMsgNumber>
<SaySender>true</SaySender>
<SayTimestampAfter>false</SayTimestampAfter>
<SayTimestampBefore>true</SayTimestampBefore>
<SayTotalNew>false</SayTotalNew>
<SayTotalNewEmail>false</SayTotalNewEmail>
<SayTotalNewFax>false</SayTotalNewFax>
<SayTotalNewVoice>true</SayTotalNewVoice>
<SayTotalReceipts>false</SayTotalReceipts>
<SayTotalSaved>true</SayTotalSaved>
<Speed>100</Speed>
<MediaSwitchObjectId>f8e1a638-13ad-4e7b-a165-312829c36b72</MediaSwitchObjectId>
<Undeletable>false</Undeletable>
<UseBriefPrompts>false</UseBriefPrompts>
<Volume>50</Volume>
<EnAltGreetDontRingPhone>false</EnAltGreetDontRingPhone>
<EnAltGreetPreventSkip>false</EnAltGreetPreventSkip>
<EnAltGreetPreventMsg>false</EnAltGreetPreventMsg>
<EncryptPrivateMessages>false</EncryptPrivateMessages>
<DeletedMessageSortOrder>2</DeletedMessageSortOrder>
<SayAltGreetWarning>false</SayAltGreetWarning>
<SaySenderExtension>false</SaySenderExtension>
<SayAni>false</SayAni>
<CallAnswerTimeout>4</CallAnswerTimeout>
<CallHandlerObjectId>6f6a72a4-dedb-4138-b988-00b3b6e46078</CallHandlerObjectId>
<DisplayNameRule>1</DisplayNameRule>
<MailboxStoreObjectId>c40c0f5d-612c-495c-bfba-9f7065927a98</MailboxStoreObjectId>
<SavedMessageStackOrder>1234567</SavedMessageStackOrder>
<NewMessageStackOrder>1234567</NewMessageStackOrder>
<MessageLocatorSortOrder>1</MessageLocatorSortOrder>
<SavedMessageSortOrder>2</SavedMessageSortOrder>
<NewMessageSortOrder>1</NewMessageSortOrder>
<MessageTypeMenu>false</MessageTypeMenu>
<EnablePersonalRules>true</EnablePersonalRules>
<RecordUnknownCallerName>true</RecordUnknownCallerName>
<RingPrimaryPhoneFirst>false</RingPrimaryPhoneFirst>
<PromptSpeed>100</PromptSpeed>
<ExitAction>2</ExitAction>
<ExitTargetConversation>PHGreeting</ExitTargetConversation>
<ExitTargetHandlerObjectId>1d3adb7a-8b89-486a-9533-e849ddfed5a8</ExitTargetHandlerObjectId>
<RepeatMenu>1</RepeatMenu>
<FirstDigitTimeout>5000</FirstDigitTimeout>
<InterdigitDelay>3000</InterdigitDelay>
<PromptVolume>50</PromptVolume>
<DelayAfterGreeting>0</DelayAfterGreeting>
<AddressAfterRecord>false</AddressAfterRecord>
<ConfirmDeleteMessage>false</ConfirmDeleteMessage>
<ConfirmDeleteDeletedMessage>false</ConfirmDeleteDeletedMessage>
<ConfirmDeleteMultipleMessages>true</ConfirmDeleteMultipleMessages>
<IsClockMode24Hour>false</IsClockMode24Hour>
<RouteNDRToSender>true</RouteNDRToSender>
<SendReadReceipts>1</SendReadReceipts>
<ReceiveQuota>-2</ReceiveQuota>
<SendQuota>-2</SendQuota>
<WarningQuota>-2</WarningQuota>
<IsSetForVmEnrollment>true</IsSetForVmEnrollment>
<VoiceNameRequired>false</VoiceNameRequired>
<SendBroadcastMsg>false</SendBroadcastMsg>
<UpdateBroadcastMsg>false</UpdateBroadcastMsg>
<ConversationVui>VuiStart</ConversationVui>
<SpeechCompleteTimeout>0</SpeechCompleteTimeout>
<SpeechIncompleteTimeout>750</SpeechIncompleteTimeout>
<UseVui>false</UseVui>
<SkipPasswordForKnownDevice>false</SkipPasswordForKnownDevice>
<JumpToMessagesOnLogin>true</JumpToMessagesOnLogin>
<EnableMessageLocator>false</EnableMessageLocator>
<AssistantRowsPerPage>5</AssistantRowsPerPage>
<InboxMessagesPerPage>20</InboxMessagesPerPage>
<InboxAutoRefresh>15</InboxAutoRefresh>
<InboxAutoResolveMessageRecipients>true</InboxAutoResolveMessageRecipients>
<PcaAddressBookRowsPerPage>5</PcaAddressBookRowsPerPage>
<ReadOnly>false</ReadOnly>
<EnableTts>true</EnableTts>
<ConfirmationConfidenceThreshold>60</ConfirmationConfidenceThreshold>
<AnnounceUpcomingMeetings>60</AnnounceUpcomingMeetings>
<SpeechConfidenceThreshold>40</SpeechConfidenceThreshold>
<SpeechSpeedVsAccuracy>50</SpeechSpeedVsAccuracy>
<SpeechSensitivity>50</SpeechSensitivity>
<EnableVisualMessageLocator>false</EnableVisualMessageLocator>
<ContinuousAddMode>false</ContinuousAddMode>
<NameConfirmation>false</NameConfirmation>
<CommandDigitTimeout>1500</CommandDigitTimeout>
<SaveMessageOnHangup>false</SaveMessageOnHangup>
<SendMessageOnHangup>1</SendMessageOnHangup>
<SkipForwardTime>5000</SkipForwardTime>
<SkipReverseTime>5000</SkipReverseTime>
<UseShortPollForCache>false</UseShortPollForCache>
<SearchByExtensionSearchSpaceObjectId>$cssOID</SearchByExtensionSearchSpaceObjectId>
<SearchByNameSearchSpaceObjectId>$cssOID</SearchByNameSearchSpaceObjectId>
<PartitionObjectId>1cefdbc4-53ae-48ee-8955-3b5096142149</PartitionObjectId>
<UseDynamicNameSearchWeight>false</UseDynamicNameSearchWeight>
<EnableMessageBookmark>false</EnableMessageBookmark>
<SayTotalDraftMsg>false</SayTotalDraftMsg>
<EnableSaveDraft>false</EnableSaveDraft>
<RetainUrgentMessageFlag>false</RetainUrgentMessageFlag>
<SayMessageLength>false</SayMessageLength>
<CreateSmtpProxyFromCorp>true</CreateSmtpProxyFromCorp>
<AutoAdvanceMsgs>false</AutoAdvanceMsgs>
<SaySenderAfter>false</SaySenderAfter>
<SaySenderExtensionAfter>false</SaySenderExtensionAfter>
<SayMsgNumberAfter>false</SayMsgNumberAfter>
<SayAniAfter>false</SayAniAfter>
<SayMessageLengthAfter>false</SayMessageLengthAfter>
</UserTemplate>
"@
Invoke-RestMethod -Uri $URIvmtemplate  -body $BODYvmtemplate -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}  -Method Post -ErrorAction Ignore -ContentType "application/xml"
$URIcosNEW = "https://gob-cuc-1.andersonsinc.com/vmrest/coses?query=(displayname is $COS)"
$cosOID = Invoke-RestMethod -Uri $URIcssNEW -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}  -Method Get -ErrorAction Ignore -ContentType "application/xml"
#$ptALL.OuterXml
$cosOID = $cosOID.OuterXml | select-string -pattern "(?<=<ObjectId>)(.*)(?=\</ObjectId>)" | ForEach-Object {$_.Matches.Groups[1].value}
$cosOID
}
