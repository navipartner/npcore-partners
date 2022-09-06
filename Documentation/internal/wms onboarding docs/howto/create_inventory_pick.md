# Create an inventory pick based on the source document 

You can create a new inventory pick based on the source document that is in the **Released** status if there's sufficient inventory to fulfil the demand. To do this, follow the provided steps:

1. Click the ![Lightbulb that opens the Tell Me feature](../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **Inventory Picks** and choose the related link. 
2. Click **New**.
3. Enter the **Location Code**.
4. Select the type of the source document that will provide the necessary shipping information.   
   It is also possible to use the **Get Source Document** action from the ribbon, and select the document from the list of prepared documents.      

   <img src="../images/get_source_document.png" width="550">    

5. Click **OK**.
   The pick lines are now added to the document.

## Next steps

### Delete inventory pick lines

After posting, you can delete inventory pick lines which correspond to items in the inventory that aren't available. However, bear in mind that this action isn't possible if serial numbers are specifies on the source document. If this is the case, the item tracking specification will be deleted if an inventory pick line for the serial number is deleted. 

If serial numbers associated with certain inventory pick lines aren't available, they shouldn't be deleted. Rather, the **Qty. to Handle** field value should be set to 0, the picks should be posted, and then the inventory pick document can be deleted. If you do this, the inventory pick lines for those serial numbers can be recreated from the sales order later on. 

