Secrets in NaviPartner codebases can be split up into different groups and we handle each of them differently:

# 1. Internal (Not customer specific) secrets in AL code
These should be managed via our NPCore azure keyvault:
https://portal.azure.com/#@navipartner.dk/resource/subscriptions/5f16aa70-9e36-47ec-bfc3-29f0af339cb1/resourceGroups/NpCore-KeyVault/providers/Microsoft.KeyVault/vaults/NPCore/overview
If you are missing permission to add new secrets here, please contact hosting - it should be assigned via the NAV developer AD group.

As our NPCore apps are already hooked up to this keyvault, reading the secrets from AL code requires nothing more than invoking the keyvault codeunit with the name of your secret:
codeunit 3800 "App Key Vault Secret Provider"

Example here: https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-app-key-vault#add-code-to-retrieve-secrets-from-the-key-vault

Examples of usecases:
API key for calling an internal azure function that has core functionality, shared across all customers.
API key for calling an internal Azure API management wrapped service that phones home to the case system, shared across all customers.
API key for calling a third party service that we embed in our core functionality, shared across all customers. **However if the external service requires a customer specific API key those should not go in here.**
A fixed client secret which should be provided as part of an OAuth flow where the NPCore .app is the client.

# 2. Customer specific secrets in AL code
These should be managed via the AL feature IsolatedStorage:
https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-isolated-storage

Examples of usecases:
Customer specific API keys for calling our internal azure services.
Customer specific API keys for other services like magento webshop.
Customer specific API keys for third party services where a customer specific account has been created, for example a shipping label service.

Hint: Create a page action to prompt for an API key to allow a human to input it, then save it into IsolatedStorage. Or a variable page field where OnValidate moves it.

# 3. Internal secrets in non-AL code
These are handled according to the best practices of each environment. Worst case is hardcoding the secret.
Usually there are better options. To illustrate using azure functions as an example, for these you can create a "managed identity" for the function in our Azure AD which you can use to specify permissions it should have, such as reading from our keyvault.
Then you can read your secrets directly from the keyvault in your function.
https://docs.microsoft.com/en-us/azure/app-service/app-service-key-vault-references 
https://daniel-krzyczkowski.github.io/Integrate-Key-Vault-Secrets-With-Azure-Functions/

Most modern services have similar best practices. Make sure you search and read the docs.

------
It should be noted that we have a bunch of older code not following these practices.
For example, there are many customer extensions with hardcoded API keys or with API keys directly in table fields and the core is also not polished in all areas.
There are also plenty of azure functions where secrets are not handled via our vault. 
Try to leave code better than how you found it. There will be times where a manager won't be technical enough to understand why it matters. That means the buck stops with you.




