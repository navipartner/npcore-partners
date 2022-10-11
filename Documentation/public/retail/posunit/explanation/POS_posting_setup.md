# POS Posting Setup

**POS Posting Setup** allows users to set up accounts on which payments from sales transactions will be posted.

![POS_posting_setup](../images/POS%20posting%20setup.PNG)

For every existing **POS Payment Method** there needs to be a set up account on which postings will be created after the POS entry is posted.   

Depending on your business needs, accounts can be the same for all stores or each store can have its own account for postings.  

If all stores have the same account for posting payments, it is enough to assign the **Account No.** to the **POS Payment Method Code**. 

**Example**: In the provided image, all postings for payments made with the **PBB-EDBT** POS payment method will be posted to the *Account No. 33314*.    

However, if there's a need for payments to be posted on different accounts depending on the store, the account number should be assigned to the **POS Payment Method Code** and the **POS Store Code**. 

**Example**: In the provided image, all postings for payments made with the POS Payment Method **CASH** will be posted to the *Account No. 37007*, except for those payments made in the **GARDENS** store. For this store, every payment made with the POS Payment Method **CASH** will be posted to the *Account No. 33314*.

Additionally, it is possible to set up different accounts for different POS payment bins. In that case, it is necessary to also set up the **POS Payment Bin Code**, except in the case of **POS Payment Method Code** and **POS Store Code**. 

**Example**: If there is a need to have multiple bins for **CASH** in one store, every bin can have its own G/L account for posting.

In the **POS Posting Setup** section for every **Payment Method Code**, which is used for payments in POS units, you need to set up the **Difference Account No.**, which is used if there are differences between the counted amount and the system amount in the end-of-day process.

### Related links

- [Create a POS payment method](../howto/POS_payment_methods.md)
- [Create a POS store](../howto/Create_new_POS_store.md)