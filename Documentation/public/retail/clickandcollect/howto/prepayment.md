# Perform prepayment on POS (Click & Collect)

To set up the prepayment flow of 100% on ordering for the Click & Collect module, follow the provided steps:

1. Create a Click & Collect order on the POS.     

   ![click_collect_prepayment_1](../images/click_collect_prepayment_1.png)

      As the result, the following things occur: 
      - an entry is created in **Send to Stores Order**
      - a sales order is created in **Sales Orders**
      - a prepayment invoice is created in **Posted Sales Invoices**
      - two entries are created in **POS Entry List** (one for the sales order, and the other one for the payment of the prepayment invoice associated with the sales order)
      - two entries are created in the **Customer Ledger Entries** for the customer (one for the prepayment invoice, and the other one for the payment of the prepayment invoice).

2. Navigate to **Send to Store Orders**, and select the entry that is created. 
3. Click **Send Order** in the ribbon, followed by **Send the Order to Collect in Store**.
4. Confirm the Click & Collect order on the POS or from the **Collect in Store Orders** ribbon in Business Central. 

   ![click_collect_prepayment_2](../images/click_collect_prepayment_2.png)   

   An entry is created in the **Collect in Store Orders** for the collecting store.

5. Deliver the Click & Collect order on the POS.    
   When you use the button to pick up the order, a window for scanning or inserting a reference number for the order is displayed.
6. Provide the order reference number.      
   The original sales order is opened, and the salesperson can see the details of items to deliver.     
   On the POS, there are two lines - one with the **Collect Order No.**, and the other with the **Remaining Amount for Order**. In the case of the 100% prepayment, the remaining amount should equal to zero. 
7. Continue to the payment screen, and complete the zero payment in cash to finalize the sale.     
   The original sales order is posted into a posted invoice on the **Customer Ledger Entries**, and the items are shipped. 

   > [!Note]
   > If initially a part of the payment was done as prepayment, then the difference to be paid will be displayed on the POS, and the customer needs to settle the payment. The order is then converted into a posted invoice for that customer. 
