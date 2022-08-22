# Create a new sales order (WMS)

Sales orders are orders which contain important information about shipments, such as customer information, shipped item specifications, and pricing details. From the **Sales Orders** administrative section, you can perform multiple actions, such as creating, editing, posting, and invoicing sales orders.

While this article focuses on the manual creation process of a sales order, it can also be created [automatically](../explanation/auto_web_sales_order.md) (by being imported from the Web store).

> [!Note]
> The sales order creation flow is dependent on how the **Warehouse** section has been set up in the **Location Card** of the locations included in the sales order. 

1. Click the ![Lightbulb that opens the Tell Me feature](../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **Sales Orders**, and choose the related link.      
   The list of all the sales orders in the environment which have not yet been posted is displayed.
2. Click **New**.      
   The **Sales Order** card is displayed.     
   The **No.**, **Posting Date**, and **Order Date** fields are automatically populated, as soon as you click anywhere on the window.      
   The **Status** field indicates whether the sales order can be modified (if it's **Open**) or not (**Released**).
3. Populate the **Customer Name** with the name of an existing customer.     
   Other fields are automatically populated with the standard information about the selected customer as a result. 
4. In the **Due Date** field, provide the date on which the shipment is going to be delivered to the customer, as well as the **Requested Delivery Date** on which the customer wants it to be delivered at the latest. 
5. In the **Lines** section, you can list the shipment components, and add accompanying information. Start by setting the **Type**.     
   - **G/L Account** - used if freight/insurance charges (or other additional charges) need to be applied to the sales order.
   - **Item** - used when an inventory item is sold; when the sales order with this line type is posted, the results will be reflected in the inventory level.
   - **Resource** -  used if you are selling man hours/machine hours linked to a resource on BC.
   - **Fixed Asset** - used then the sales order should include some fixed assets already registered in Business Central.
   - **Charge (Item)** - used for additional cost paid on the sales of the item (e.g insurance, freight) if these aren't included in the selling price of the item. The Charge(Item) cost is then added to the initial cost of the item.
6. Use the dropdown in the **No.** field to find the entry you wish to include in the line.     
   Depending on the previous selections, some fields will be populated. For example, if an **Item** entry type is selected, the information from the selected item's **Item Card** will be applied in the relevant fields. 
7. Make sure that the **Location Code** corresponds to the correct location. 
8. Provide the **Quantity** of the line entry, making sure to stay within the limits of the available quantity in the selected location.     
   The **Line Amount** field is updated to show the value in the unit price multiplied by the quantity.     
   The VAT-related fields below will be populated according to the input on the lines.
9. Add the percentage if you wish to grant a discount on the product to the customer in the **Line Discount %** field.      
    The value in the **Line Amount** field is updated as a result. 
10. If you only wish to ship a part of the order quantity, enter that quantity in the **Qty. to Ship** field.      
    The value is automatically copied to the **Qty. to Invoice** field.  
11.  In the **Invoicing Details**, provide the payment codes, and other necessary information for this sales order.
12. In the **Shipping and Billing** section, provide the information about the ship-to target, if it's different from the contents of the **General** section.
13. When you're done configuring the sales order, click **Release** (and then **Release** again, once the option is displayed) to change its status accordingly.       
    In this way, you're confirming that the order is ready to be shipped.

    > [!Note]
    > If you need to make any additional changes, you need to click **Release** in the ribbon, followed by **Reopen** when the option is displayed.

14. When you're ready to ship the order, click **Posting** in the ribbon, followed by **Post** once the option is displayed.
15. Choose whether the order should be shipped, invoiced or both, in the popup window. 
    The order is posted as a result, and moved to the **Posted Sales Invoices** administrative section.
    You can now print, email or attach the posted invoice as a PDF file. 

    > [!Note]
    > In the **Customer Card** you can set up the preferred method of sending documents in the **Document Sending Profile** field. Once set up, that customer will always automatically receive sales orders and other documents via that method.


### Related links

- [Create inventory pick](create_inventory_pick_sales_order.md)