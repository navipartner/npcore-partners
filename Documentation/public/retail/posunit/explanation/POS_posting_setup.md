# POS Posting Setup

**POS Posting Setup** allows users to setup accounts on which will be posted payments from sales transactions.

![POS_posting_setup](../images/POS%20posting%20setup.PNG)

For every existing **POS payment method** which is used for payments in POS here must be setup account on which postings will be created after POS entry is posted.     
Depending on needs, accounts can be the same for all stores or every store can have its own accoutn for postings.                  
In case that all stores have the same account for posting payments, it is enough just to assign **Account no** to **POS payment method code**. As for example, in above picture all posting for payments made with POS Payment Method **PBB-EDBT** will be posted to Account No. 33314.    
But, if we have a case that there is need for payments to be posted on different accounts depending on store, in that case account no should be assined to **POS Payment Method Code** and **POS Store Code**. As for example, in above picture all postings for payments made with POS Payment Method **CASH** will be posted to account 37007, except for those payments made in store **GARDENS**. For this store, every payment made with POS Payment Method **CASH** will be posted to account no. 33314.

Also, it is possible to set up different accounts for different POS Payment Bins. In that case, except **POS payment method code** and **POS Store Code** it is necessary to set up also **POS Payment Bin Code**. So for example, if there is need to have more bins for **CASH** in one store, every bin can have own G/L account for posting.

In **POS Posting Setup** for every Payment Method Code, which is used for payments in POS units, must be set up **Difference Account No.** which is used in cases when there is some differences between counted amount and system amount in end of day process.