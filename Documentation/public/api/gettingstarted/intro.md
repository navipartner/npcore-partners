# Webservice API 

Both SOAP and REST API can used for managing our solutions. Refer to the provided guides to learn more.

## REST API

NPRetail is running on top of the Business Central platform which is developed and maintained by Microsoft.  
The newest versions of Business Central use the OData v4 standard to provide REST webservice APIs.  
The base application in the ERP system comes with a big set of APIs and NPRetail adds many additional APIs on top for NaviPartners modules.

### Microsoft Docs

Read the Microsoft documentation for an introduction to Business Central APIs, authorization options and tips & tricks:
https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-develop-connect-apps  
https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-connect-apps-tips  
https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-connect-apps-filtering

### Microsoft API

Refer to the [technical reference](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/api-reference/v2.0/) of the base ERP APIs developed by Microsoft.  


### NPRetail API

Our APIs are grouped into various domains/modules. Use the navigation menu to explore each of them.  
We maintain an OpenAPI API sandbox for each, which can either be explored directly in your browser or imported into your favorite software that supports OpenAPI 3:  
https://openapi.tools/

## SOAP API

NaviPartner uses SOAP API for retrieving tickets and ticket-related data in the Entertainment solution. Other entities in the Entertainment module can also be managed via SOAP API, and will be further explained in the coming period.

- [Ticket services](../../entertainment/ticket/files/ticket_services_wsdl.xml)