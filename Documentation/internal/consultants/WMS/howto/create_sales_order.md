# Create a new sales order (WMS)

Sales orders are forms which populated in such a way that they contain all necessary information to request a sale of specific items. Companies typically use them to track orders and resupply their stock. They contain important information about shipments, such as customer information, shipped item specifications, and pricing details. 

It is recommended to use sales orders when partially shipping or invoicing an order, since sales invoices are a better choice for sales fully shipped and invoiced in a single instance. You can check whether the order is completely shipped (and invoiced) in the **Completely Shipped** column.

From the **Sales Orders** administrative section, you can perform multiple actions, like creating, editing, posting, and invoicing sales orders.

While this article focuses on the manual creation process of a sales order, it can also be created [automatically](../explanation/auto_web_sales_order.md) (by being imported from the Web store).

## Prerequisites

- Make sure you've set up customers and locations prior to creating new sales orders, as you will be required to reference both during the sales order creation.

## Procedure

1. Click the ![Lightbulb that opens the Tell Me feature](../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **Sales Orders**, and choose the related link.      
2. Click **New**.      
   The **Sales Order** card is displayed.     
3. Populate the **Customer Name** with the name of an existing customer.     
   Other fields are automatically populated with the standard information about the selected customer as a result. However, you can edit them if needed.      
   If you've defined any special prices or discount in the **Customer Card** of the selected customer, they will be automatically applied.
4. In the **Due Date** field, provide the date on which the shipment is going to be delivered to the customer, as well as the **Requested Delivery Date** on which the customer wants it to be delivered at the latest.     
   The default **Due Date** can alternatively be set up per a customer in their **Customer Card** prior to the sales order creation.
5. In the **Lines** section, you can list the shipment components, and add accompanying information. Start by setting the **Type** of the posted entity.     

   | Field Name      | Description |
   | ----------- | ----------- |
   |  **G/L Account**   | Used if freight/insurance charges (or other additional charges) need to be applied to the sales order.  |
   |  **Item**  | Used when an inventory item is sold; when the sales order with this line type is posted, the results will be reflected in the inventory level.   |
   |  **Resource**  |  Used if you are selling man hours/machine hours linked to a resource on BC.    |
   |  **Fixed Asset**  |  Used then the sales order should include some fixed assets already registered in Business Central.  |
   |  **Charge (Item)** | Used for additional cost paid on the sales of the item (e.g insurance, freight) if these aren't included in the selling price of the item. The **Charge (Item)** cost is then added to the initial cost of the item.   |

6. Find the number of the entity in the **No.** dropdown per each line.     
   Depending on the previous selections, some fields will be populated. For example, if an **Item** entry type is selected, the information from the selected item's **Item Card** will be applied in the relevant fields per a current line. 
7. Make sure that the **Location Code** corresponds to the correct location, and provide the **Quantity** of the line entry, making sure not to exceed the limit of available quantity in the selected location.    
   The **Line Amount** field is updated to show the value in the unit price multiplied by the quantity.     
   The VAT-related fields below will be populated according to the provided input.
8. In the **Line Discount %** field, add the percentage of the discount if you wish to grant a discount to the customer.       
   The value in the **Line Amount** field is updated as a result. 
9. Provide the order quantity you wish to be shipped in the **Qty. to Ship** field.      
   The value is automatically copied to the **Qty. to Invoice** field.  
10. (Optional) Provide the amount to be deducted from the **Total Incl. Tax** in the **Invoice Discount Amount Excl. VAT** field.

> [!Note]
> If you wish to calculate the invoice discount, you can do so via the **Calculate Invoice Discount** option in the ribbon (**Actions** > **Functions** > **Calculate Invoice Discount**).

11. In the **Invoicing Details**, provide the payment codes, and other necessary information for this sales order.
12. In the **Shipping and Billing** section, provide the information about the ship-to target, if it's different from the contents of the **General** section.
13. When you're done configuring the sales order, click **Release** (and then **Release** again, once the option is displayed) to change its status accordingly.       
    This action confirms that the order is ready to be shipped.

    > [!Note]
    > If you need to make any additional changes, you need to click **Release** in the ribbon, followed by **Reopen** when the option is displayed.

14. When you're ready to ship the order, click the **Post and Send** action in the ribbon.
15. Choose whether the order should be shipped, invoiced or both, in the popup window. 
    The order is posted as a result, and moved to the **Posted Sales Invoices** administrative section. The shipment and the invoice are created.
    You can now print, email or attach the posted invoice as a PDF file. 

    > [!Note]
    > In the **Customer Card** you can set up the preferred method of sending documents in the **Document Sending Profile** field. Once set up, that customer will always automatically receive sales orders and other documents via that method.


### Related links

- [Create inventory pick](create_inventory_pick_sales_order.md)
- [Create sales invoice](create_sales_invoice.md)