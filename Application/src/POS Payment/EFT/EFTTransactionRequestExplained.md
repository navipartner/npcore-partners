# General Electronic Funds Transfer (EFT) Request
When making a new EFT Integration there are certain procedures and fields that require attention depending on which type of EFT request is being fired. This document serves as a general purpose guide to implement new EFT Integrations.

## Table of required fields
This section describes a table that contains the Name, type, and description of different EFT fields, what their purpose is and when they are needed in different transaction types.
The last 3 columns stand for Payment, Refund and Void.
The values of these are described as follows: 

**A**: Auto inserted,
**C**: If some condition requires it. This will be in the Description part.
**M**: Mandatory,
**O**: Optional.
**M/O**: If available.


| Name| Type | Description | P | R | V |
|-|-|-|-|-|-|
| Entry No. | Integer | Autoincrement Unique Number | A | A | A |
| Token | GUID | Unique Identifier |  |  |  |
| Integration Type | Code\[20\] | Mandatory Code specifying the EFT Integration | M | M | M |
| Started | DateTime | Transaction request created | A | A | A |
| Finished | DateTime | Transaction request finished | A | A | A |
| Integration Version Code | Code\[10\] | Short unique code identifying the integration. | M | M | M |
| Card Type | Text\[4\] | Short version of the card type, e.g. VISA or  MC for mastercard | M | M | O |
| Card Name | Text\[24\] | Name of the type of card e.g. VISA Electron | M | M | O |
| Card Number | Text\[30\] | the card PAN | O | O | O |
| Card Issuer ID | Text\[30\] | NETS specific ID | M/O | M/O |  |
| Card Application ID | Text\[30\] | A standardized code scheme identifying provider and card type. | M | M | O |
| Track Presence Input | Option | ??? | O | O | O |
| Card Information Input | Text\[40\] | ??? | O | O | O |
| Card Expiry Date | Text\[4\] | Expiry Date | O | O | O |
| Reference Number Input | Text\[50\]  | Our reference number/text for the EFT transaction | M | M | M |
| Reference Number Output | Text\[50\]  | The providers reference number for the EFT Transaction | M | M | M |
| Acquirer ID | Text\[50\] |  | O | O | O |
| Reconciliation ID | Text\[50\] | Identification for a grouping of transaction | O | O | O |
| Authorisation Number | Text\[50\]  | ??? | O | O | O |
| Hardware ID | Text\[200\] | The hardware ID of the terminal/device used. | M/O | M/O | M/O |
| Transaction Date | Date |  | A | A | A |
| Transaction Time | Time |  | A | A | A |
| Payment Instrument Type | Text\[30\] | ??? | O | O | O |
| Authentication Method | Option | How the transaction was authenticated by the customer. | O | O | O |
| Signature Type | Option | Where was the signature recorded | O | O | O |
| Financial Impact | Boolean | If the EFT transaction had fininacial impact.  e.g. a terminal AUX operation is an EFT request, but does not have financial impact. | A | A | A |
| Mode | Option | The mode of operation. Production is default, use other to specify test transactions. | M | M | M |
| Successful | Boolean | If the EFT Transaction request was successfull or failed. | M | M | M |
| Result Description | Text\[50\] | Short Result description e.g. APPROVED, DECLINED, CANCELLED, Card Rejected Etc. | M | M | M |
| Bookkeeping Period | Text\[4\] | ??? | O | O | O |
| Result Display Text | Text\[100\] | ??? | O | O | O |
| Amount Input | Decimal | The way we describe the amount, fx. for refunds we count this as a negative sum. | A | A | A |
| Amount Output | Decimal | The way the amount is used at the integration. fx Softpay uses positive values for Refund request. | M | M | M |
| Result Amount | Decimal | The final amount described in our way | M | M | M |
| Currency Code | Code\[10\] | Currency used. | M | M | M |
| Cashback Amount | Decimal | ??? | O | O | O |
| Fee Amount | Decimal | ??? | O | O | O |
| Fee Line ID | Guid | ??? | O | O | O |
| Tip Amount | Decimal| The tip entered on the terminal. | M | M | M |
| Tip Line ID | Guid | ??? | O | O | O |
| Receipt 1" | Blob | The cardholder/customer receipt. | M | M | M |
| Receipt 2 | Blob | The merchant receipt. | M/O | M/O | M/O |
| Logs | Blob | Logs describing events, errors, failures during the transaction. | O | O | O |
| Processing Type | Option | What type of EFT Request it is | A | A | A |
| Processed Entry No. | Integer | The entry no. beeing refered to by this eft request. e.g. the entry no. of the request that needs a lookup, or a void request. This is filled out automatically. |  |  | A/M |
| NST Error | Text\[250\] | Long error message | O | O | O |
| Client Error | Text\[250\] | Long error message | O | O | O |
| Force Closed | Boolean | ??? | O | O | O |
| Reversed | Boolean | Describes if the EFT request have been reversed (e.g. a void has been sent for this request and succeeded) |  | O | M/O |
| Reversed by Entry No. | Integer | The entry no. that reversed this eft request |  | O | M/O |
| External Result Known | Boolean | Specifies if we know the result of the request from the providers site. | M | M | M |
| Auto Voidable | Boolean | Describes if this request can be voided automatically, programatically??? | M | M |  |
| Manual Voidable | Boolean | Describes if this request can be voided manually, by calling the provider??? | M | M | O |
| Recoverable | Boolean | Describes if the result of the EFT transaction can be recovered. | M | M | M |
| Recovered | Boolean | Describes if the EFT request has been recovered  by another EFT Lookup request. | M/O | M/O | M/O |
| Recovered by Entry No. | Integer | The EFT Lookup Request that recovered the transaction | M/O | M/O | M/O |
| Auxiliary Operation ID | Integer | The Id of the integration specific operation. |  |  |  |
| Auxiliary Operation Desc. | Text\[50\] | Description of what the integration specific operation does. |  |  |  |
| External Transaction ID | Text\[50\] | The providers identification number/text of the transaction. | M | M | M/O |
| External Customer ID | Text\[50\] | ??? |  |  |  |
| External Customer ID Provider | Text\[50\] | ??? |  |  |  |
| External Payment Token | Text\[50\] | ??? |  |  |  |
| DCC Used | Boolean | specifies if Dynamic Currency Conversion were used | M/O | M/O |  |
| DCC Currency Code | Code\[10\] | The currency converted to. | M/O | M/O |  |
| DCC Amount | Decimal | The amount in the currency used | M/O | M/O |  |
| Result Processed | Boolean | ??? |  |  |  |
| - | - | - | - | - | - |
| Sales Ticket No. | Code\[20\] |  |  |  |  |
| Sales ID | Guid |  |  |  |  |
| Sales Line No. | Integer |  |  |  |  |
| Sales Line ID | Guid |  |  |  |  |
| POS Description | Text\[100\] |  |  |  |  |
| Register No. | Code\[10\] |  |  |  |  |
| POS Payment Type Code | Code\[10\] |  |  |  |  |
| Original POS Payment Type Code | Code\[10\] |  |  |  |  |
| Result Code | Integer |  |  |  |  |
| Offline mode |  |  |  |  |  |
| Client Assembly Version |  |  |  |  |  |
| No. of Reprints |  |  |  |  |  |
| Number of Attempts |  |  |  |  |  |
| Initiated from Entry No. |  |  |  |  |  |
| Self Service |  |  |  |  |  |
| Stored Value Account Type |  |  |  |  |  |
| Stored Value Provider |  |  |  |  |  |
| Stored Value ID |  |  |  |  |  |
| Internal Customer ID |  |  |  |  |  |
| Access Token |  |  |  |  |  |
| Matched in Reconciliation |  |  |  |  |  |
| FF Moved to POS Entry |  |  |  |  |  |
| User ID | Code\[50\] |  |  |  |  |