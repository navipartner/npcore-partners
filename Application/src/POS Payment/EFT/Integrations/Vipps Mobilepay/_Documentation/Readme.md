# Developer Info for MobilePay Vipps Integration.
This document contains info relevant for developers working on this integrations.
See this link for [Getting Started](https://developer.vippsmobilepay.com/docs/getting-started/).

## Info
MSN aka Merchant Serial Number corresponds to a Sales Unit, (not a POS unit), another way of looking at a Sales Unit is a Store specific setup. There is no definition for a POS Unit in Vipps Mobilepay.

## Migration From Mobilepay to Vipps
To migrate Mobilepay we need to:
Identify ALL MobilepayV10 Integrations used in the EFT Setup.
For each MobilepayV10 we need to find:
Pos Unit
Payment Type POS
Integration Payment Setup
- Environment --> Env
- Merchant VAT Number --> Buisness ID
- Log Level --> LogLevel
Integration Pos Setup
- Store ID --> MSN
- Mercahnt POS ID --> POS Unit No.
- Mobilepay POS ID --> ...
- Beacon ID --> Mercahnt QR Id



## Flows:
### Online Payment
Not Relevant

### In-Store Payment
Scanner 


## Notes
APIs: ePayment, Checkout, Recurring & Login.
Server ednpoint Test: https://apitest.vipps.no
Server ednpoint Prod: https://api.vipps.no
Merchant API Keys: They are specific for singular sales unit. So multiple set of API keys are needed for more POS Units.
Partner API Keys: These keys work for all Sales units that are linked to the partner portal. Works like Merchant API Keys, but needs to specify Merchant-Serial-Number (MSN).
Parther Key Types:
- Partner Keys: Manage Sales units, Act on behalf of merchants. Uses normal endpoint for accessToken: POST:/accesstoken/get
- Management Keys: Manage Sales units. Uses specific endpoint for access token: POST/miami/v1/token
- Accounting Keys: Report API. Uses specific endpoint for access token: POST/miami/v1/token

Http Headers:
Authorization: Used for API Requests. Bearer Tokens.
client_id: Needed for AccessToken
client_secret: Needed for AccessToken.
Ocp-Apim-Subscription-Key: Needed for alle requests.
Merchant-Serial-Number: Needed for partner key requests. Optional/recommended in normal Merchant mode.
Vipps-System-Name: Meta data, mostly used to differantiate between apps/solutions.
Vipps-System-Version: Meta data, mostly used to differantiate between apps/solutions.
Vipps-System-Plugin-Name: Meta data, mostly used to differantiate between apps/solutions.
Vipps-System-Plugin-Version: Meta data, mostly used to differantiate between apps/solutions.



//Auth = Approved money to take from Customer
//Cancelled = Removed money from payment before Capture.
//Captured = Transfered money to Merchant
//Refunded = Transfered money back to Customer Finiancial result:
// Captured - Refunded = Result.
//fx 100 Captured and 25 Refunded =  75 Paid.
//fx 100 Captured and 100 Refunded = 0 Paid.
