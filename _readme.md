# Removed functionality notes

The following functionality was removed in the Control Add-in upgrade process:
* IFramework control add-in was not upgraded - it is an old "Standard" framework that's no longer in use
* All page objects that directly used IFramework control add-in have been deleted:
  * page 6014651 "Touch Screen - Sale (Web)"
  * page 6014652 "Touch Screen - Dialog (Web)"
  * page 6014653 "Touch Screen - Balancing (Web)"
  * page 6014654 "POS Web Font Preview"
  * page 6014657 "Proxy Dialog"

Also, the following objects were deleted
* page 6014656 "Proxy Assemblies"
* table 6014622 "Proxy Assembly"
* The POS Event Marshaller codeunit (6014623)
* The codeunit 6014624 "Touch Screen - Balancing Mgt."
* The codeunit 6014630 "Touch - Sale POS (Web)"
* The codeunit 6014691 "Trigger Stargate Assembly Sync"
* codeunit 6014557 "Raw Print Proxy Protocol"
* codeunit 6014552 "Touch - Sales Line POS"
* codeunit 6150812 "POS Action - Balance Reg V1"
* codeunit 6014530 "Credit Card Protocol C-sharp"
* codeunit 6014690 "Stargate Dummy Request"
* codeunit 6059947 "CashKeeper Capture" - referenced only removed object, while itself never referenced from anywhere
* codeunit 6059948 "CashKeeper PayOut" - referenced only removed object, while itself never referenced from anywhere
* codeunit 6059945 "CashKeeper API" - referenced only from removed objects (two objects above)
* codeunit 6059946 "CashKeeper Proxy" - obsolete proxy object
* codeunit 6059957 "MCS Webcam Proxy" - obsolete proxy object
* codeunit 6014625 "POS Device Proxy Manager"
* codeunit 6014621 "POS Web Utilities"
* codeunit 6014620 "POS Web UI Management"
* codeunit 6014633 "Touch - Static Subscribers"
* codeunit 6014622 "POS Web Session Management"
* codeunit 6014596 "Generic Page Web Serv. Client" - not used anywhere
* table 6014434 "Touch Screen - Menu Lines" - obsolete Standard setup table
* codeunit 6150822 "POS Action - Conv Touch2Trans"
* page 6014520 "Touch Screen - Setup"


# To-dos

There are a number of to-dos left in code. All of them are marked as `// TODO: CTRLUPGRADE` and have to be handled by somebody else. Those are mostly code blocks using some removed functionality, and should no longer be in use. However, since they may be in use, those code blocks are marked together with a comment about what needs to be done (in my opinion).

Somebody should investigate:
* codeunit 6059967 "MPOS Admission API" - an event subscriber subscribes to a removed event publisher
* codeunit 6014663 "Check POS Balancing" - two event subscribers subscribes to removed event publishers
* codeunit 6184496 "Pepper Event Subscribers" - an event subscriber subscribes to a removed event publisher
* codeunit 6014417 "Call Terminal Integration" - invokes old Stargate v1 protocols that were removed
* codeunit 6184480 "Pepper Library" - a lot of obsolete invocations, commented out with Error('CTRLUPGRADE')
* codeunit 6184481 "Pepper Begin Workshift" - possibly contains a lot of obsolete stuff
* codeunit 6184482 "Pepper Trx Transaction" - possibly obsolete
* codeunit 6184483 "Pepper End Workshift" - possibly obsolete
* codeunit 6184484 "Pepper Aux Functions" - possibly obsolete
* codeunit 6184486 "Pepper File Mgmt. Functions" - possibly obsolete
* codeunit 6184503 "CleanCash Proxy" - possibly obsolete
* codeunit 6014556 "File Print Proxy Protocol" - possibly obsolete

# POS Event Marshaller

A number of errors (and TODOs) are related to the POS Event Marshaller codeunit that was removed during the upgrade.

All functionality depending on POS Event Marshaller is old Standard code that must not be used in any Transcendence scenario. Therefore, all code that invokes it must be either removed or refactored.

Since Transcendence has been live for more than two years and Standard won't be upgraded to BC, it is assumed that any code that still uses Standard functionality is purely standard. An upgrade attempt must be made to remove all objects utilizing POS Event Marshaller and then cascade the removal of pieces of code that use them, to see if that way all old Standard code can be removed (or to pinpoint to Transcendence features that are still using them)