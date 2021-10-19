[[_TOC_]]

# Why use Azure KeyVault with BC

The point of this section is to try explaining what should be stored in Azure KeyVault. As Microsoft documentation explains:
 
_Some Business Central extensions make web service calls to  non-Business Central services. For example, one extension might call  Azure Storage to read/write blobs. Another extension might call the  extension publisher's web service to do an operation.
These web service calls are typically authenticated, which means the  extension must provide a credential in the call. The credentials enable  the other service to accept or reject the call. You can consider the  credentials as a kind of secret to the extension. A secret shouldn't be  leaked to customers, partners, or anybody else. So where can the  extension get the secret from? Here is where Azure Key Vault is used.  Azure Key Vault is a cloud service that works as a secure secrets store.  It provides centralized storage for secrets, enabling you to control  access and distribution of the secrets._

We need to consider two scenarios:

- We have enabled customer to save their data to the cloud drive (OneDrive, DropBox etc). In this scenario, the data itself is owned by the customer. Authentication data (username, password, token etc) is also owned by the customer, **so this is clearly NOT a scenario to use with Azure KeyVault**.

- We have enabled connection between our NpCore and 3rd party service (Download of newest dependancies and scripts). In this scenario, everything related to the communication is owned by NaviPartner (Service endpoint URLs, tokens etc). This scenario, **is customer-agnostic FROM AUTHENTICATION perspective, uses same auth data for all the customers, is ideal to use with Azure KeyVault**.


A good video on the topic:  https://events1.social27.com/MSDyn365BCLaunchEvent/agenda/player/61367

# NPR Azure Key Vault Mgt. codeunit

Fetching Azure Key Vault secrets takes some time, especially if you're doing it from environment that is not hosted in Azure, the environment is hosted in different Azure region.

In order to mitigate the issue, especially when we're reusing the values read from Azure Key Vault (API Kay used for frequent API calls), **NPR Azure Key Vault Mgt.** codeunit has been created. This single instance codeunit, automatically cashes all secrets read from the Key Vault (_procedure GetSecret(Name: Text) KeyValue: Text)_ thus removing the performance bottleneck from all subsequent uses of previously read secrets.

Considering this, **NPR Azure Key Vault Mgt.** should be always used when reading secrets from Azure Key Vault!

#BC Certificate/NST Setup for Azure KeyVault
In order to use KeyVault with BC app, we need to setup the KeyVault first. Most of the process is well documented in Microsoft official documentation:

https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-app-key-vault-overview

For NpCore, there's already a KeyVault in NaviPartner's Azure Tenant (https://npcore.vault.azure.net/). Certificate used for the KeyVault can be obtained from our Hosting department.
However, there are some caveats, discovered the hard way: 
- In the documentation, there's a PS code sample showing how to create new self signed certificate:
`$cert = New-SelfSignedCertificate -Subject "BusinessCentralKeyVaultReader" -Provider "Microsoft Strong Cryptographic Provider"`
`$cert.Thumbprint`
`Export-Certificate -Cert $cert -FilePath c:\certs\BusinessCentralKeyVaultReader.cer`

  Well, there are issues in this code. **New-SelflDignedCertificate** uses default values that will not allow to export private key with the certificate, and will not even create one because by default the certificate will be created for document signing purposes. To make long story short, **here's how the self signed certificate should be created:**

  `$cert = New-SelfSignedCertificate -Subject "BusinessCentralKeyVaultReader" -Provider "Microsoft Strong Cryptographic Provider" -NotAfter (Get-Date -Year 2025 -Month 12 -Day 31) -KeyUsageProperty All -KeySpec KeyExchange -KeyExportPolicy Exportable`

  We usually want to specify expiration date for the certificate, hence the _-NotAfter_ parameter.

  In order to use the certificate for BC communication with Azure KeyVault, the certificate has to contain private key. Since we usually don't create the certificate on the same platform that's running our NST instance, we have to export the certificate with it's private key too, and exporting it to .cer file will not export private key!

  **Solution for this problem is to use .pfx format when exporting the certificate, and we also want to have .cer file for Azure import,so our code should look like this:**

  `$cert = New-SelfSignedCertificate -Subject "BusinessCentralKeyVaultReader" -Provider "Microsoft Strong Cryptographic Provider" -NotAfter (Get-Date -Year 2025 -Month 12 -Day 31) -KeyUsageProperty All -KeySpec KeyExchange -KeyExportPolicy Exportable`
`$mypwd = ConvertTo-SecureString -String "[MySuperSecurePassword]" -Force -AsPlainText`
`Get-ChildItem -Path cert:\localMachine\my\41020F5580B840AF9A77364D3806B048103F60F4 | Export-PfxCertificate -FilePath C:\Users\[YourUserFolder]\Documents\BusinessCentralKeyVaultReader.pfx -Password $mypwd`
`Get-ChildItem -Path cert:\localMachine\my\41020F5580B840AF9A77364D3806B048103F60F4 | Export-Certificate -FilePath C:\Users\[YourUserFolder]\Documents\BusinessCentralKeyVaultReader.cer`

- Also, in the same document there's another sample showing how to import the certificate to the computer running our NST:

  `Import-Certificate -FilePath "C:\certificates\BusinessCentralKeyVaultReader.cer" -CertStoreLocation Cert:\LocalMachine\My`

  Now, if our NST instance is running inside the container, importing the certificate to **Cert:\LocalMachine\My** will cause an issue where users won't be able to log in to BC! This is probably caused by how the NST reads certificates, from the store. The solution is to import the certificate to different certificate store **(Cert:\LocalMachine\Root)**. Now, since we have exported our certificate by using .pfx file format, we need to import it using different PS cmdlet:

  `$mypwd = ConvertTo-SecureString -String "[MySuperSecurePassword]" -Force -AsPlainText`
  `Import-PfxCertificate -FilePath C:\run\BusinessCentralKeyVaultReader.pfx -CertStoreLocation Cert:\LocalMachine\Root -Password $mypwd`

  **Note that C:\Run\ is a folder INSIDE the container!**
  
- After that the certificate is created and imported, we need to set a few NST configuration parameters:

  `Set-NAVServerConfiguration -KeyName AzureKeyVaultClientCertificateThumbprint -KeyValue 41020F5580B840AF9A77364D3806B048103F60F4 -ServerInstance BC`
`Set-NAVServerConfiguration -KeyName AzureKeyVaultClientId -KeyValue b38b8bef-17d2-4368-84ce-f9880a45eed0 -ServerInstance BC`
`Set-NAVServerConfiguration -KeyName AzureKeyVaultClientCertificateStoreName -KeyValue Root -ServerInstance BC`

  **Note: AzureKeyVaultAppSecretsPublisherValidationEnabled is set by default on the NST (for BC OnPrem). In order to use Azure KeyVault with Publisher Validation, it is necessary to set -PublisherAzureActiveDirectoryTenantId to Azure AD tenant ID when publishing the app with Publish-NavApp cmdlet!!!**

- The last step is to restart the NST:
`Restart-NAVServerInstance -ServerInstance BC`

# AL project setup for Azure KeyVault

It is very easy and simple task to add support for Azure KeyVault to AL project. Everything is described in detail in Microsoft official documentation:

https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-app-key-vault

