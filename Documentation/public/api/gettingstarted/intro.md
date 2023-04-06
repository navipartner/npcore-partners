# Webservice API 

Both SOAP and REST API can used for managing our solutions. Refer to the relevant guides to learn more.

## REST API

The newest versions of Business Central use the OData v4 standard to provide REST webservice APIs.  
The base application in the ERP system comes with a sizeable set of APIs, and NPRetail adds many additional APIs on top, intended for NaviPartner's modules.

### Microsoft Docs

Read the Microsoft documentation for an introduction to Business Central APIs, authorization options and tips & tricks:

- [Getting started developing connect apps for Dynamics 365 Business Central](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-develop-connect-apps)
- [Tips for working with the APIs](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-connect-apps-tips)
- [Using filters with API calls](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-connect-apps-filtering)
 
### Microsoft API

Refer to the [technical reference](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/api-reference/v2.0/) of the base ERP APIs developed by Microsoft.  


### NPRetail API

NaviPartner APIs are grouped into various domains/modules. An OpenAPI API sandbox is maintained for each, and you can either explore them directly from your browser or import them into your favorite software that supports [OpenAPI 3](https://openapi.tools/).

## SOAP API

NaviPartner uses SOAP API for retrieving tickets and ticket-related data in the Entertainment solution. Other entities in the Entertainment module can also be managed via SOAP API, and will be further explained in the coming period.

- [Ticket services](../../entertainment/ticket/files/ticket_services_wsdl.xml)