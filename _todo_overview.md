| Type     | Number  | Name                             | Comments                                                                                      | Responsible                               |
| -------- | ------- | -------------------------------- | --------------------------------------------------------------------------------------------- | ----------------------------------------- |
| codeunit | 6014407 | "Retail Sales Doc. Mgt."         | CreatePrepaymentLineLegacy function                                                           | Suggested : TSA                           |
| codeunit | 6014417 | "Call Terminal Integration"      | Dankort Stargate v1 proxy used; Pepper stuff uses Marshaller                                  | Suggested: MMV (Dankort) and TSA (Pepper) |
| codeunit | 6014435 | "Retail Form Code"               | Credit voucher and gift voucher lookup functionality                                          | Suggested: MMV                            |
| codeunit | 6014480 | "Retail Document Handling"       | Sale2RetailDocument function uses Marshaller                                                  | Suggested: TSA                            |
| codeunit | 6014498 | "Exchange Label Management"      | Uses Marshaller                                                                               | Suggested: MMV                            |
| codeunit | 6014505 | "Touch Screen - Functions"       | Several places in code use Marshaller                                                         | Suggested: MMV or TSA                     |
| codeunit | 6014556 | "File Print Proxy Protocol"      | Old Stargate v1 Proxy codeunit, possibly not even needed anymore. Should be investigated.     | MMV                                       |
| codeunit | 6014582 | "Print Method Mgt."              | References codeunit 6014556 that requires investigation.                                      | MMV                                       |
| codeunit | 6014663 | "Check POS Balancing"            | Subscribes to events from old Standard balancing functionality. Investigation needed.         | TSA                                       |
| codeunit | 6059956 | "MCS Webcam API"                 | References old Stargate v1 Proxy codeunits, should be investigated or removed                 | TSA or CLVA                               |
| codeunit | 6059967 | "MPOS Admission API"             | References a removed event publisher that's not used in Transcendence, investigation required | CLVA                                      |
| codeunit | 6060135 | "MM Member POS UI"               | Uses Marshaller                                                                               | TSA                                       |
| codeunit | 6150640 | "POS Info Management"            | Uses Marshaller                                                                               | Suggested: TSA                            |
| codeunit | 6150660 | "NPRE Waiter Pad POS Management" | Uses Marshaller                                                                               | Suggested: MMV or TSA                     |
| codeunit | 6150788 | "POS Action - Print Exch Label"  | Uses DotNet version of JSON, needs refactoring to AL Json* types                              | MMV                                       |
| codeunit | 6184480 | "Pepper Library"                 | A lot of obsolete Stargate v1 Proxy references, needs investigation, refactoring, or removal  | Suggested: TSA                            |
| codeunit | 6184481 | "Pepper Begin Workshift"         | "Remnant" of Stargate v1 Proxy Dialog removal/refactoring - requires investigation            | TSA                                       |
| codeunit | 6184482 | "Pepper Trx Transaction"         | "Remnant" of Stargate v1 Proxy Dialog removal/refactoring - requires investigation            | TSA                                       |
| codeunit | 6184483 | "Pepper End Workshift"           | "Remnant" of Stargate v1 Proxy Dialog removal/refactoring - requires investigation            | TSA                                       |
| codeunit | 6184484 | "Pepper Aux Functions"           | "Remnant" of Stargate v1 Proxy Dialog removal/refactoring - requires investigation            | TSA                                       |
| codeunit | 6184486 | "Pepper File Mgmt. Functions"    | "Remnant" of Stargate v1 Proxy Dialog removal/refactoring - requires investigation            | TSA                                       |
| codeunit | 6184496 | "Pepper Event Subscribers"       | Subscribes to an event from old Standard balancing functionality. Investigation needed.       | Suggested: MMV or TSA                     |
| codeunit | 6184501 | "CleanCash Communication"        | References old Stargate v1 Proxy codeunit, should be investigated, refactored, or removed     | JHL (?)                                   |
| codeunit | 6184503 | "CleanCash Proxy"                | "Remnant" of Stargate v1 Proxy Dialog removal/refactoring - requires investigation            | JHL (?)                                   |
| page     | 6014524 | "Touch Screen - CRM Contacts"    | Old Standard page, still in use by some Transcendence code, uses Marshaller                   | Suggested: TSA                            |
| page     | 6014526 | "Touch Screen - Customers"       | Old Standard page, still in use by some Transcendence code, uses Marshaller                   | Suggested: TSA                            |
| page     | 6014529 | "Touch Screen - Balancing Line"  | Old Standard page, still in use by some Transcendence code, uses Marshaller                   | Suggested: TSA                            |
