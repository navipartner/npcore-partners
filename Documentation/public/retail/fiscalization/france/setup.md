# Setup
This article details how to configure NP Retail for compliance in France in relation to NF 525 legislation.

## BC Permissions
Anything that must not be modifiable from a POS user can be locked down via Business Central Permission Sets.
You must lock down access to all setup mentioned in this article.
Especially the "FR Compliance Setup" and "POS Audit Profile" config must as minimum be locked down as it controls some fundamental setup for NF 525 compliance.

## BC Change Log
Anything that must be tracked for changes can be configured via Business Central Change Log.
You should configure it for all setup mentioned in this article.

## POS Audit Profile
Each **POS Unit** is connected to an **POS Audit Profile**.
For NF 525 compliance, create one audit profile and use it for all POS Units.  
On the profile you must set "Audit Log Enabled" and select NF_525 as the "Audit Handler".  
This will automatically block opening of the POS on that POS Unit if any other setup is obviously non-compliant. 

## Certificate generation and upload.
Reach out to NaviPartner for a self-signed certificate that is specific to your customer with the proper algorithm. 
On the "FR Compliance Setup" page, a password protected export of the certificate must be uploaded with correct password inserted in field "Signing Certificate Password".

## Number Series
On the "FR Compliance Setup" page you can setup POS unit specific number series under action "Unit No. Series Setup". 

## POS Store and Company Information
The "Company Information" in standard BC contains the core company base info, such as the intra-comm. VAT ID and APE.  

The "POS Store" in NPRetail contains other all the retail specific base info such as store name, address, city and Siret number. 

## JET Initialization
On the "FR Compliance Setup" page you can initialize the JET for a new POS unit by clicking action "Initialize JET".

## Partner Modifications
On the "FR Compliance Setup" page you can log a partner modification to the system by clicking 
action "Log Partner Modification".

## Period Lengths
On the "FR Compliance Setup" page you must setup the following period calcformulas to comply with NF525:
- "Yearly Workshift Duration": 1Y
- "Monthly Workshift Duration": 1M

## Item VAT filter
To make sure that the grand total events only count items, vouchers, services etc. that include VAT, you must setup a "VAT Identifier" filter on the "FR Compliance Setup" page that matches all non-zero VAT identifiers.

## Archive to Azure Blob Storage
To enable automatic archiving, we use the standard Business Central module known as "Job Queue". 
The following object must be configured to run nightly:
```
codeunit 6184851 "NPR FR Audit Arch. Workshifts"
```
Also, on the "FR Compliance Setup" page you must setup the following API keys for auto archiving to work:
- "Auto Archive URL" - Reach out to NaviPartner for correct URL to use.
- "Auto Archive API Key" - Reach out to NaviPartner for correct API key to use.
- "Auto Archive SAS" - Reach out to NaviPartner for correct SAS to use.

## Print Template
On the "Print Template List" page you can use action "Deploy Package" to download NaviPartners default templates. Two of these must be configured for french compliance:
- EPSON_RECEIPT_2_FR, as the sales receipt print.
- EPSON_END_OF_DAY_Z_FR, as the end-of-day/balancing print.

## POS Footer
The footer in all active sales and payment screens will show the software name, version and certification number.  