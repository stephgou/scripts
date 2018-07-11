$source = @'

using System;
using System.Collections.Generic;
using System.Linq;

namespace GandiDNS
{
    using CookComputing.XmlRpc;

    //[XmlRpcUrl("https://rpc.ote.gandi.net/xmlrpc/")]
    [XmlRpcUrl("https://rpc.gandi.net/xmlrpc/ ")]
    public interface IGandi : IXmlRpcProxy
    {
        [XmlRpcMethod("domain.available")]
        XmlRpcStruct DomainAvailable(string apiKey, string[] domainNames);

        [XmlRpcMethod("version.info")]
        XmlRpcStruct Version(string apiKey);

        [XmlRpcMethod("domain.list")]
        XmlRpcStruct[] DomainList(string apiKey);

        [XmlRpcMethod("domain.zone.list")]
        XmlRpcStruct[] DomainZoneList(string apiKey);

        [XmlRpcMethod("domain.zone.info")]
        XmlRpcStruct DomainZoneInfo(string apiKey, int zoneId);

        [XmlRpcMethod("domain.zone.record.add")]
        XmlRpcStruct DomainZoneRecordAdd(string apiKey, int zone_id, int version, XmlRpcStruct record);

        [XmlRpcMethod("domain.zone.record.list")]
        XmlRpcStruct[] DomainZoneRecordList(string apiKey, int zone_id, int version);

        [XmlRpcMethod("domain.zone.version.set")]
        Boolean DomainZoneVersionSet(string apiKey, int zone_id, int version);

        [XmlRpcMethod("domain.zone.set")]
        XmlRpcStruct DomainZoneSet(string apiKey, string domain, int zone_id);
    }

	public class ProxyFactory
    {
        public static IGandi CreateGandiProxy()
        {
            return XmlRpcProxyGen.Create<IGandi>();
        }
    }
}

'@

cls

#region init
Set-PSDebug -Strict

Clear-Host
$d = get-date
Write-Host "Starting Deployment $d"

$scriptFolder = Split-Path -Parent $MyInvocation.MyCommand.Definition
Write-Host "scriptFolder" $scriptFolder

set-location $scriptFolder
#endregion init

# Load XML-RPC.NET and custom interfaces
if ([Type]::GetType("GandiDNS.ProxyFactory") -eq $null)
{
    [Reflection.Assembly]::LoadFile("$scriptFolder\CookComputing.XmlRpcV2.dll") | Out-Null
    $dynamicAssembly = Add-Type -TypeDefinition $source -ReferencedAssemblies ("$scriptFolder\CookComputing.XmlRpcV2.dll")
}
#region securedinformation
$apiKey = "[HERE ENTER YOUR API KEY]"
#Zone version - should be a non active version
$zoneVersion = 3
#ZoneId - this is the [ZONEID] number you get from the URL https://v4.gandi.net/admin/domain/zone/[ZONEID]/3/edit
$zoneId = [ZONEID] 
#endregion

# Set up proxy
$gandiProxy = [GandiDNS.ProxyFactory]::CreateGandiProxy()
$gandiProxy.UserAgent = "user agent"
$gandiProxy.EnableCompression = $true

$domainList = $gandiProxy.DomainList($apiKey)
$domain = $domainList.fqdn

$CNAMERecord = New-Object CookComputing.XmlRpc.XmlRpcStruct
$CNAMERecord.Add("name", "stephgou-CNAME")
$CNAMERecord.Add("type", "CNAME")
$CNAMERecord.Add("value", "stephgou.northeurope.cloudapp.azure.com.")
$CNAMERecord.Add("ttl", 3600)

$rpcResultCNAMERecord = $gandiProxy.DomainZoneRecordAdd($apiKey,$zoneId,$zoneVersion,$CNAMERecord)

$ARecord = New-Object CookComputing.XmlRpc.XmlRpcStruct
$ARecord.Add("name", "stephgou-A")
$ARecord.Add("type", "A")
$ARecord.Add("value", "192.168.1.10")

$rpcResultARecord = $gandiProxy.DomainZoneRecordAdd($apiKey,$zoneId,$zoneVersion,$ARecord)

$booleanResultDomainZoneVersionSet = $gandiProxy.DomainZoneVersionSet($apiKey,$zoneId,$zoneVersion)

$rpcResultDomainSet = $gandiProxy.DomainZoneSet($apiKey,$domain,$zoneId)

