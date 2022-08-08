# Create an inventory pick based on the source document 

After requesting an inventory pick, you can create a new inventory pick based on the released document. To do this, follow the provided steps:

1. Click the ![Lightbulb that opens the Tell Me feature](../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **Inventory Picks** and choose the related link. 
2. Click **New**.
3. Fill in the **No.** field with the number of the relevant entry/record. 
4. Select the type of the source document that will provide the necessary shipping information.   
   It is also possible to use the **Get Source Document** action from the ribbon, and select the document from the list of prepared documents.      

   <img src="../images/get_source_document.png" width="550">    

5. Click **OK**.
   An inventory pick is now created.

## Next steps

### Create multiple inventory picks simultaneously

It's possible to create a batch job for creating multiple inventory picks by following the provided steps:

1. Click the ![Lightbulb that opens the Tell Me feature](../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **Create Inventory Put-away/Pick/Movement** and choose the related link.
2. In the **Warehouse Request** section, filter the documents via the **Source Document** and **Source No.** fields.
3. In the **Options** section, enable the **Create Invt. Pick** toggle switch. 
4. Click **OK**.    
   You can also schedule a report for the inventory put-away/pick/movement creation by clicking **Schedule**, and adding the necessary data in the popup. 

### Delete inventory pick lines

After posting, you can delete inventory pick lines which correspond to items in the inventory that aren't available. However, bear in mind that this action isn't possible if serial numbers are specifies on the source document. If this is the case, the item tracking specification will be deleted if an inventory pick line for the serial number is deleted. 

If serial numbers associated with certain inventory pick lines aren't available, they shouldn't be deleted. Rather, the **Qty. to Handle** field value should be set to 0, the picks should be posted, and then the inventory pick document can be deleted. If you do this, the inventory pick lines for those serial numbers can be recreated from the sales order later on. 

### Related links

- [Inventory and warehouse picks](../explanation/inventory_warehouse_pick.md)