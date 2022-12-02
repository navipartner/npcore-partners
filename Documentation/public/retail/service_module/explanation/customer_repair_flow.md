# Customer repair flow

There are various levels of setup that need to be performed in order to make the Service Module fully operational. Given the number of functions associated with the module, it's necessary to understand the process so that the module can be set up correctly. 

1. A customer walks into the shop with an item that should be repaired. 
2. A customer repair card is created in Business Central for this transaction. The following information is recorded in regards to the customer:
   - If they are a new customer, a **Customer Card** is created.
   - Details about the customer are recorded in the **General** section. 
   - Details about the item for repair are recorded in the **Registration** section. 
   - Details about the complaint are recorded in the **Defect** section.
   - A note with all the necessary information recorded is printed and given to the customer to acknowledge the item has been admitted to the shop to undergo the necessary repairs.
   - The repair status is set to its initial stage as **To be sent**.
   - Some shops place the item in a designated repair bag/box, and stick a barcode reference on it. The barcode corresponds to the value of the **Customer Repair Card No.**.
3. The decision on whether the item will be repaired in-house or by a third-party specialist is reached. 
   - If the repair is done in-house:
     - The **In-house Repairer** checkbox is ticket in the **General** section. 
     - The estimate for the repair cost and price is calculated, and the **Unit Cost** and **VAT** fields are updated. 
     - The **Repair Offer** document is sent to the customer to get their approval, and proceed with the repair. 
     - The status of the repair is set to **Awaits Approval**.   
   - If the repair is done at an external repairer: 
     - The information about the repairer is recorded in the **Repairer** segment of the **General** section. 
     - The **Delivery Note** document is printed, and sent together with the item for repair to the repairer's shop. 
     - The repair status is changed to **At Vendor**.
     - An estimate of the repair cost is obtained from the repairer, and the price is calculated based on the cost charged by the repairer. Both the **Unit Cost** and **Price Including VAT** fields are updated. 
     - The **Repair Offer** document is sent to the customer to get their approval to proceed with the repair. 

    > [!Note]
    > The repair offer can be sent via an email. 

4. The customer decides whether they want to proceed with the repair or not. 
   - If the repair is approved: 
     - The status is changed to **Approved**.
     - The repair process starts either in-house or at the repairer's shop. 
   - If the repair isn't approved:
     - The status is changed from **Awaits Claiming** to **Return No Repair**, and then finally to **Claimed**.
5. When the repair is in progress:
   - The section on the **Repair Description** is updated. 
   - The details of the repair are filled in the **Repair Description** section, which includes:
     - Test description, that should be kept internal
     - Additional expenses
     - Spare parts 
     - Description in which it's stated that the invoice should be printed
     - The option to select which expense we want to charge to the client in addition to the fixed price that was initially agreed on
     - The option to input the charges including the labor cost

6. When the repair is completed:
   - The section on **Repair Description** is updated if this hasn't yet been done in the previous stages. 
   - The customer is notified that the repair is ready to be collected. 
   - A document **Repair Done** is sent to the customer to notify them to pick up the repair. 
   - The status is changed to **Awaits Claiming**.     

   > [!Note]
   > An email stating that the repair has been completed can be sent to the customer.

7. Repair finalization
   - Once the repair has been completed, the **Repair Card** can be finalized using the **Finalize Repair** shortcut. 
   - If the repair is guaranteed, a **Repair Guarantee** document is printed to be delivered with the repaired item. 
8. Invoicing 
   - An invoice can be printed and posted at any time after the repair has been finalized.
   - An invoice can be sent via email to the customer for payment and collection. 
9. Payment collection
    The payment is received when the customer comes to pick up the item. The collection is done via POS as a payment to the debtor against the invoice for the repair. 

### Related links

- [Set up service module for repairs](../howto/set_up_customer_repair.md)