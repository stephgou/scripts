## SCRIPTS ##

This repository is dedicated to sharing utility scripts.

### MoveVMWithManagedDisk ###

A script that enables to move a VM that uses managed disk between two subscriptions.
In order to execute it, you will need to install "AzureRM.Compute" module (it is required to enable the cmdlet Grant-AzureRmDiskAccess). Just ensure you have access to both subscriptions...
 
``` PowerShell
Install-Module AzureRM.Compute -RequiredVersion 2.9.0 -AllowClobbe
```

