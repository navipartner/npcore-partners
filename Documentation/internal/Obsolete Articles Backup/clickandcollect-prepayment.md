# Click & Collect order with prepayment pipeline example

In this example, the click & collect ordering method is performed, and the required prepayment that the customer needs to provide is 100%, or the full sales order amount. The background process performed automatically is detailed in the following steps:

1. An entry is created in the **Send to Store Orders** administrative section. 
2. A sales order is created in the **Sales Orders** administrative section.
3. A prepayment invoice is created in the **Posted Sales Invoices** administrative section.
4. Two entries are created in the **POS Entry List** administrative section.     
   One is for the sales order, and the other one is for the prepayment of the prepayment invoice associated with the sales order. 
5. Two entries are created in the **Customer Ledger Entries** archive section.     
   One entry is for the prepayment invoice, and the other one is for the prepayment of the prepayment invoice. 

# Perform the Click & Collect 

Required steps to be performed:

1. Open the NP Retail POS, enter the salesperson code, and then click **Create Click N Collect Order**.
2. Click the ![Lightbulb that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **Send to Store Orders** and choose the related link.
3. Click **Send the Order to Collect in Store**.     
   An entry is created in the **Collect in Store Orders** for the collecting store.   
   > [!Note]
   > The action for confirming the order in the collecting store can also be done from Business Central. 
4. Deliver the Click & Collect order on the POS.     
   When using the button to pick up the order, a window is opened to scan or insert the reference number for the order.     
   The original **Sales Order** is open and the salesperson can see the details of items to deliver.      
5. Two lines are displayed in the POS. One contains the collect order number, and the other one is for the remaining amount that should be paid (if any).       
   In case a 100% of prepayment amount is required, the remaining amount is 0.00. The salesperson needs to continue to the payment screen and do a zero payment value in cash to complete the sales. The system posts the original sales order into a posted invoice on the **Customer Ledger Entries**.     
   
   The original order is posted in the customer ledger account and items are shipped.

> [!Note]
> If a part of payment was initially done as prepayment, and then the difference that should be paid appears on the POS, and the customer needs to settle the payment. The order is converted into a posted invoice for the customer. 