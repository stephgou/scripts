## SCRIPTS ##

This repository is dedicated to sharing utility scripts.

### MoveVMWithManagedDisk ###

A script that enables to move a VM that uses managed disk between two subscriptions.
In order to execute it, you will need to install "AzureRM.Compute" module (it is required to enable the cmdlet Grant-AzureRmDiskAccess). Just ensure you have access to both subscriptions...
 
``` PowerShell
Install-Module AzureRM.Compute -RequiredVersion 2.9.0 -AllowClobbe
```

### GandiDNSZoneUpdate ###

A script that enables to update your Gandi DNS Zone with A or CNAME records (in PowerShell using a C# dynamic assembly code and xmlrpcnet : CookComputing.XmlRpcV2.dll tested with version 3.0.0.266 from https://www.nuget.org/packages/xmlrpcnet/)


### ASE-ApplicationGateway ###
A script that enables to deploy an ASE with different App Services exposed through an Application Gateway

