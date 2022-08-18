# Create a new sales order (WMS)

Sales orders are orders which contain important information about shipments, such as customer information, shipped item specifications, and pricing details. From the **Sales Orders** administrative section, you can perform multiple actions, such as creating, editing, posting, and invoicing sales orders.

While this article focuses on the manual creation process of a sales order, it can also be created automatically (by being imported from the Web store).

The sales order creation flow is dependent on how the **Warehouse** section has been set up in the **Location Card** of the locations included in the sales order. 

1. Click the ![Lightbulb that opens the Tell Me feature](../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **Sales Orders**, and choose the related link.      
   The list of all the sales orders in the environment which have not yet been posted is displayed.
2. Click **New**.      
   The **Sales Order** card is displayed.     
   The **No.**, **Posting Date**, and **Order Date** fields are automatically populated, as soon as you click anywhere on the window. 
   The **Status** field indicates whether the sales order can be modified (if it's **Open**) or not (**Released**).
3. Populate the **Customer Name** with one of the available customers in the environment.     
   The **Contact** field is automatically populated as a result.
4. In the **Due Date** field, provide the date on which the shipment is going to be delivered to the customer, as well as the **Requested Delivery Date** on which the customer wants it to be delivered at the latest. 
5. In the **Lines** section, you can list the shipment components, and add accompanying information. Start by setting the **Type**.     
   - **G/L Account** - used if freight/insurance charges (or other additional charges) need to be applied to the sales order.
   - **Item** - used when an inventory item is sold; when the sales order with this line type is posted, the results will be reflected in the inventory level.
   - **Resource**
   - **Fixed Asset** - used then the sales order should include some fixed assets. 
   - **Charge (Item)**
6. Use the dropdown in the **No.** field to find the entry you wish to include in the line.     
   Depending on the previous selections, some fields will be populated. For example, if an **Item** entry type is selected, the information from the selected item's **Item Card** will be applied in the relevant fields. 
7. Make sure that the **Location Code** corresponds to the correct location. 
8. Provide the **Quantity** of the line entry, making sure to stay within the limits of the available quantity in the selected location. 
   The VAT-related fields below will be populated according to the input on the lines.
9. In the **Invoicing Details**, provide the payment codes, and other necessary information for this sales order.
10. In the **Shipping and Billing** section, provide the information about the ship-to target, if it's different from the contents of the **General** section.
11. When you're done configuring the sales order, click **Release** (and then **Release** again, once the option is displayed) to change its status accordingly.       
    In this way, you're confirming that the order is ready to be shipped.

    > [!Note]
    > If you need to make any additional changes, you need to click **Release** in the ribbon, followed by **Reopen** when the option is displayed.

12. When you're ready to ship the order, click **Posting** in the ribbon, followed by **Post** once the option is displayed.
13. Choose whether the order should be shipped, invoiced or both, in the popup window. 
    The order is posted as a result, and moved to the **Posted Sales Invoices** administrative section.
    You can now print, email or attach the posted invoice as a PDF file. 