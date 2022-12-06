# Receive items at a warehouse location

Item reception is recorded in four different ways, depending on the current warehouse setup.

- The most straightforward creation method entails creating the receipt directly from the order (purchase, sales return, and transfer order).
- You can also create inventory receipts from inventory put-away documents. The benefit of this approach is that the users who receive the items don't have to do any additional work on orders as well.
- If the warehouse is set up for receipt processing, you need to retrieve the lines of the released source document that has triggered the lines' receipt. 
- You can combine the put-away and warehouse receipt approaches to create a more complex process that has its own set of benefits. 

> [!Important]
> The [**Location Card**](../reference/location_card.md) of the locations included in the received orders is used for setting up how receipts are processed. You can configure the processing behavior via the **Require Receive** and **Require Put-away** fields. 

> [!Note]
> If there are bins in the warehouse setup, it's possible to receive items with the default bin, or select another bin to which items will be put away. After that, it's necessary to provide the item quantities received, and post the receipt to complete the process.

## Receive items directly from the order

This is the most direct method of receiving inventory in Business Central. You simply need to provide the quantity that is to be received and post it. These orders can be easily tracked via their order number. 

1. Click the ![Lightbulb that opens the Tell Me feature](../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **Transfer Orders**/**Sales Return Orders**/**Purchase Orders**, and choose the related link.      
2. Create a new order.     
   The most important field you need to populate is **Qty, to Receive**.
3. When done, post the order.
4. In the popup window, select either **Receive** or **Receive and Invoice** (depending on the order in question).      
   The **Qty. Received** is updated as the result. 

## Receive items from inventory put-away

Inventory put-aways can be used for receiving inventory from all types of orders. With this method, users who perform the receiving don't have to do any work on the orders themselves.

1. You can either create a put-away from the orders, through the [**Create Inventory Pick/Put-away** job](create_inventory_pick_action.md), or by creating a new inventory put-away from the **Inventory Put-aways** administrative section. The recommended method is to create inventory put-away upon receiving the inventory.
   Whichever method you select, be sure to populate the **Qty. to Handle** field to be able to complete the put-away.
2. Once the inventory put-away is created, you can post it and select either **Receive** or **Receive and Invoice** in the popup window. 


## Receive items with a warehouse receipt

Unlike put-aways, warehouse receipts can contain lines from multiple orders, which is useful if inventory is received from multiple orders simultaneously, and they need to be processed at once. 

1. Click the ![Lightbulb that opens the Tell Me feature](../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **Warehouse Receipts**, and choose the related link.      
2. Click **New**. 
3. Populate the necessary fields in the **General** tab.    
   - Make sure that the selected location has the **Require Receive** toggle switch enabled in its **Location Card** if you wish to use it in the warehouse receipt.     
   - The **Zone Code** and the **Bin Code** fields are automatically populated if the default zone and receipt bin are defined for the selected location.
4. Click the **Get Source Documents...** action in the ribbon.

    ![warehouse receipt get source document](../images/get_source_document.PNG)

5. Pick the released source document lines that define which items should be received, then click **OK**.       
   The source document lines are displayed in the **Lines** section.
6. Provide the adequate **Bin Code** per each line if bins are mandatory in the selected warehouse location, and if the **Bin Code** field in the **General** tab was populated.
7. Post the warehouse receipt via the **Posting** action in the ribbon.     
   You can choose whether you wish to only post the receipt, post and print it, or post and print with the put-away function.

## Receiving items from the warehouse receipt, and using warehouse put-aways

This approach to receipting presents a combination of the two aforementioned methods. Receipts are created in much the same way as in the [Receive items with a warehouse receipt](../howto/receive_items.md#receive-items-with-a-warehouse-receipt) procedure, and after being posted, the warehouse put-away is used to move the inventory to the appropriate bins. This method should be used if you can benefit from splitting the receipting procedure into two segments (receiving items into the receiving area, followed by relocation of those items from the receiving area to their destination in the warehouse).

> [!Note] 
> It is possible to have warehouse put-aways created automatically when the warehouse receipt is posted. This is defined on the **Location Card** of the locations involved in the process.
