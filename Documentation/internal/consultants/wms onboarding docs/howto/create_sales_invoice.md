# Create a sales invoice

Sales invoices are documents which contain information on products which are sold, as well as details related to payments and discounts, and delivery.

Unlike [sales orders](create_sales_order.md), sales invoices should be used to record sales fully shipped and invoiced in a single instance.

To create a sales invoice, follow the provided steps.

1. Click the ![Lightbulb that opens the Tell Me feature](../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **Sales Invoices**, and choose the related link.      
2. Click **New**.      
3. Populate the **Customer Name** with the name of an existing customer.     
   Other fields in the **General** section are automatically populated with the standard information about the selected customer as a result. However, you can edit them if needed.      
4. In the **Lines** section, you can list the shipment components, and add accompanying information. Start by setting the **Type** of the posted entity.     

   | Field Name      | Description |
   | ----------- | ----------- |
   |  **G/L Account**   | Used if freight/insurance charges (or other additional charges) need to be applied to the sales order.  |
   |  **Item**  | Used when an inventory item is sold; when the sales order with this line type is posted, the results will be reflected in the inventory level.   |
   |  **Resource**  |  Used if you are selling man hours/machine hours linked to a resource on BC.    |
   |  **Fixed Asset**  |  Used then the sales order should include some fixed assets already registered in Business Central.  |
   |  **Charge (Item)** | Used for additional cost paid on the sales of the item (e.g insurance, freight) if these aren't included in the selling price of the item. The **Charge (Item)** cost is then added to the initial cost of the item.   |

5. Find the number of the entity in the **No.** dropdown per each line.     
   Depending on the previous selections, some fields will be populated. For example, if an **Item** entry type is selected, the information from the selected item's **Item Card** will be applied in the relevant fields per a current line. 
6. Make sure that the **Location Code** corresponds to the correct location, and provide the **Quantity** of the line entry, making sure not to exceed the limit of available quantity in the selected location.    
7. (Optional) Provide the amount to be deducted from the **Total Incl. Tax** in the **Invoice Discount Amount Excl. VAT** field.
8. When you're done creating a sales invoice, you can post it by selecting the **Post and Send** action in the ribbon.

> [!Note]
> After being posted, sales invoices are moved from the **Sales Invoices** to the **Posted Sales Invoices** page. The **No.** of the sales invoice will be changed to a different one when posted, and that final **No** will be the one customers see in the final document.
