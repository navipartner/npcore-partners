# OAuth Credentials for customer environments

When working with Business Central SaaS, web services use OAuth 2.0 as their
authentication mechanism.
The following guide applies to Service-to-Service (S2S) integrations, e.g. the
integration between Magento 2 and NP Retail.

## Service-to-Service credentials
S2S credentials are much like the username and password approach that many
NaviPartner colleagues have been used to for many years.

For S2S to work you need a **Client ID** (similar to a username) and a
**Client Secret** (similar to a password).

**IMPORTANT** Unlike how passwords used to work, client secrets do _expire_.
There is no option to make secrets with out an expiry.

## Who should create the credentials?
Follow these steps to determine who should receive the case for creating 
credentials:

1. In the case system go to **Database Overview** and find the tenant.
2. *If* **GDAP Level** is set to **Full Access**, send a case to Hosting
(Group 5) specifying what service you need OAuth credentials for.
3. *Else* the case should be sent to the customer, so they can create the credentials.

In both cases the two methods created below can be used and the links can
freely be shared with the customer.

**NOTE** A non-Hosting NaviPartner employee cannot create the credentials regardless of the circumstances.

## Creating credentials
OAuth credentials for BC SaaS are obtained through the associated Azure
Active Directory (AAD). This can either be done manually or through the
functionality in NP Retail.

In either case, it is required to have the **Global Administrator** in AAD.
All **Global Administrators** in an Azure AD tenant has access to Business Central
regardless of whether or not they have a license.

### Creating credentials manually
When you need to create the credentials manually through the Azure Portal
the user needs to follow the steps outlined in [this link](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/administration/automation-apis-using-s2s-authentication#task-1-register-an-azure-ad-application-for-authentication-to-business-central).
The output they should send to NaviPartner is the client ID and client secret.

The Business Central user or the consultant should then proceed with setting
up the access within Business Central. Follow the guide in [this link](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/administration/automation-apis-using-s2s-authentication#task-2-set-up-the-azure-ad-application-in-).

### Creating credentials programmatically
Within NP Retail, there is a functionality to create the Azure AD Application
using an action. For Magento you can follow [this guide](https://docs.navipartner.com/retail/webshopintegrations/magento/howto/create-azure-ad-app.html).

You still need to own the Global Administrator role, so the action
should be performed by Hosting or the customer's administrator.
The consultant should receive the client ID and client secret from the person
who performed the action.