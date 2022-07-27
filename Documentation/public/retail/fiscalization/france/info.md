This article provides a technical overview of NP Retail and french NF 525 compliance.

## Certification Details
NP Retail is audited by InfoCert and our certification details are:
- Category: B
- Number: 0274

## Platform
The platform that NP Retail is running inside is the ERP system known as Microsoft Business Central.  
Microsoft manages the french ERP compliance, documented by them here: 
https://docs.microsoft.com/en-us/dynamics365/business-central/localfunctionality/france/france-local-functionality

NP Retail compliance is only focused on the point of sale requirements, known as NF 525.  
NOTE: If you are using a trial from AppSource, the solution is not compliant with NF 525 unless configured as per the setup article and with automatic archive storage configured. Reach out to your partner to make sure your solution is compliant.

## Versioning Logic
The NP Retail application has 4 version numbers, of which 2 have functional meaning:

BCMinimumVersion.NPRMajorVersion.NPRMinorVersion.BuildRevision

The NPRMajorVersion is increased every time we release all features/fixes prepared since last major, usually on a monthly basis. 
The NPRMinorVersion is increased ad-hoc, for hotfixes in between major versions.

The NF 525 compliance is tied to the NPRMajorVersion number.

## Software Deployment
The NP Retail releases are deployed via Microsoft AppSource.  
This is documented by them here: https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/administration/tenant-admin-center-manage-apps 

When a customer or a partner installs NP Retail via Microsofts AppSource, Microsoft is performing both the notarization and validation of NaviPartners submitted releases, guaranteeing that customers are only able to install our releases, not counterfeits.
All of our release binaries submitted to Microsoft are also code-signed first with a certificate purchased from https://trustzone.com/, as per the steps detailed here: 
https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-sign-extension 

## Automated Testing
As development is done using continuous integration principles, we have a range of code tests that are executed automatically on our pull requests, meaning for every change of the NP Retail source code. 
We have a number of test scenarios written explicitly to maintain NF 525 compliance. These are called:

- PurchaseSignature
- ReprintSignature
- VoidSignature
- DailyZReportSignature
- MonthlyPeriodSignature
- YearlyPeriodSignature
- MonthlyPeriodArchiveSignature
- LoginSetupValidation
- LoginSignature
- CancelSaleSignature
- VoucherAndItemPurchaseSignature
- BrokenTicketSignatureChain
- PartnerModificationSignature
- ArchiveSchemaTest
- JETInitSignatureTest

## Quality Assurance

Quality of the NP Retail is assured by a combination of:
- Functional code tests for invidiual business logic procedures, examples specific to french compliance seen above, executing on every developer change.
- Performance code tests for specific use-cases, executed periodically.
- Using latest changes internally as quickly as possible. Every consultant, support employee, manager and developer ordering new test environments for any purposes will receive the latest state of the master branch, containing unreleased changes.
- Manually testing ad-hoc on a feature-by-feature basis.
- Staged deployment - we do not deploy to all customers at once. We have a management tool that controls who gets what and when.


## Signed data
In NPRetail the following events are signed:
- Tickets, both sales and returns.
- Duplicates (Ticket re-prints).
- Various technical events (Called JET).
- Archive Creation.
- Grand Total events, tracked for 4 individual lengths of period: Each individual sale, a daily shift for each POS unit, a monthly period for each POS unit, a yearly period for each POS unit.
 
See below sections for breakdown of data in these events.



### JET Events
List of supported JET events in NP Retail:
| Code | Event | Data in "Additional Info" |
|-----|-----|-----|
| 20 | Monthly Archive Attempt | Sequence number of the balancing POS Entry |
| 30 | Yearly Archive Attempt | Sequence number of the balancing POS Entry |
| 40 | Log out | Salesperson code |
| 50 | Daily/Monthly closing | Sequence number of the balancing POS Entry |
| 60 | Year closing | Sequence number of the balancing POS Entry |
| 80 | Log in | Salesperson code | Salesperson code | 
| 90 | Signature Chain Verification Failure | Blank |
| 170 | Drawer Count | Sequence number of the balancing POS Entry |
| 190 | Item RMA (Note: One event per line in refund sale) | Blank |
| 240 | Partner Modification | A description of the modification made |
| 260 | JET Initialization | Blank |
| 320 | Cancel Sale | Salesperson code |
| 910 | Non item amount | Blank |

List of data included in a signed JET event, in order, separated by comma:
- Sequential Number
- The JET Event Code (see above list)
- Empty String
- Date and time
- Salesperson Code
- POS Unit Number
- A true false (Y/N) value indicating if this event is the first in the entire sequence for this register and event type.
- The previous signature for this register and event type. (Blank if first)


Note: 
All JET events have "External ID" in the "POS Audit Log" set to the JET sequence number.

### GRANDTOTAL Events
A grand total event is created for 4 different "periods":
- Per individual sales ticket.
- Per daily closing
- Per monthly closing
- Per yearly closing

The amounts will be totalled, corresponding to the period of the GRANDTOTAL.

List of data included in a signed GRANDTOTAL event, in order of separation:
- A breakdown of all sales tax amounts per VAT rate, including returns.
- The total sales amount incl. VAT and including returns. For sales ticket grand totals, this only counts items, not VAT free vouchers etc.
- A cumulative perpetual sum of all sales and returns in this period and all prior periods on the same POS unit.
- Date and time.
- Sequential number (Note: this is unique for each of the 4 different periods mentioned above).
- A true false (Y/N) value indicating if this event is the first in the entire sequence for this register and event type.
- The previous signature for this register and event type. (Blank if first)

Note: 
The "Additional Info" field in the "POS Audit Log" consists of three values that are tracked for GRAND TOTAL events, separated by pipe character. The definition of these three fields are:  

- SaleTotalInclTax: The total sales amount incl. VAT and including returns. 
- PerpetualAbsoluteAmount: A cumulative perpetual sum of all sales and returns, **in absolute value** in this period and all prior periods on the same POS unit.
- PerpetualAmount: A cumulative perpetual sum of all sales and returns in this period and all prior periods on the same POS unit.

The "External ID" field in the "POS Audit Log" consists of one value:  
The sequence number of the grand total, with 4 different sequences depending on the type of grand total: Ticket, Daily, Monthly, Yearly.

### DUPLICATE Events
A duplicate is a receipt copy/reprint. 

List of data included in a signed DUPLICATE event, in order of separation:
- Sequential number of the duplicate event for the individual POS unit.
- The type of the original sale. Always "TICKET" as NPRetail does not support other sale types.
- The duplicate/reprint number. E.g. 2 for the 2nd reprint of the same receipt.
- Salesperson Code
- Date and time
- The sequential number of the reprinted sales ticket.
- A true false (Y/N) value indicating if this event is the first in the entire sequence for this register and event type.
- The previous signature for this register and event type. (Blank if first)


Note: 
The "Additional Info" field consists of one value: This is the reprint number.

### TICKET Events
A TICKET event is a POS sale. Return sales are included, but carry a negative amount.

List of data included in a signed TICKET event, in order of separation:
- A breakdown of all tax amounts per VAT rate.
- A total of all sales & return amounts incl. VAT
- Date and time
- Sequential number of the sale/return for the specific POS Unit.
- A description of the ticket - will indicate of it was a cancellation of prior ticket (full return) or a new sale.
- A true false (Y/N) value indicating if this event is the first in the entire sequence for this register and event type.
- The previous signature for this register and event type. (Blank if first)


### ARCHIVE Events
The archive event is created when an archive of a monthly period is created.


List of data included in a signed ARCHIVE event, in order of separation:
- A breakdown of all tax amounts per VAT rate in the archived period.
- A total amount of all item sales and returns in the archived period.
- Date and time
- POS Unit Number
- Description of the event, always "Archive".
- A true false (Y/N) value indicating if this event is the first in the entire sequence for this register and event type.
- The previous signature for this register and event type. (Blank if first)

### Algorithms used to sign
The NF 525 data is signed via the RSA algorithm with 2048 bits and hashed via the SHA256 algorithm. 
The certificates used are self-signed and issued per customer by NaviPartner.

### Overview of all events
You can see all the event data in the system by navigating from the "POS Entry List" to "POS Audit Log".
Notice the column "External Type" is extra important as it carries types like "GRANDTOTAL", "JET", "DUPLICATE", "TICKET". 
Filtering to a specific POS unit and a specific type will show you one chain of signed events.

## Electronic Validation of data stored in the system
On the page "POS Audit Log" there is an action "Validate Log" that will re-calculate all the events within the current page filter and check if the signature chain is still valid or broken.  
If broken, it will point to the specific entry where the chain has been broken.


## Printing
NPRetail comes with pre-defined print templates that must be configured for NF 525 compliance. 
Requirements for the print-out include version numbers, reprint number, specific sequential numbers, specific VAT breakdown in columns and more.

See setup article for more details on configuring the correct templates.