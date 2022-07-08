# Perform stock count (Business Central)

Stock counting is performed by comparing the physical inventory from warehouses and the calculated inventory in Business Central, and settling the differences between the two across journals, ledgers, and accounts. 

To perform the stock count, follow the provided steps:

1. Click the ![Lightbulb that opens the Tell Me feature](../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **Physical Inventory Journals** and choose the related link.
2. To prepare the list of items which will be counted, click **Prepare**, and then **Calculate Inventory**.      
   The **Calculate Inventory** popup window is displayed. Here, you can add information such as posting date, document number, and apply the filters for item groups. 
3. Apply the filter to determine according to which criteria the item group will be selected in the **Filter totals by** section (for example, according to the warehouse location).
   The list of physical inventory journal entries corresponding to the filter criteria is displayed.   
   The **Qty. (Calculated)** field contains the stock level recorded in Business Central, while the **Qty. (Phys. Inventory)** field contains the actual physical quantity of items in the warehouse, as determined by the physical count.

> [!Note]
> If there are discrepancies between the values in the **Qty. (Calculated)** and the **Qty. (Phys. Inventory)** fields, it's recommended to perform another physical stock count. 

4. Navigate to **Actions**, and then select **Print**.    
  Once the document is printed, the warehouse employees can scan the items with their mobile devices and record the physical inventory values in the **Qty. (Phys. Inventory)** column.
5. Once the physical inventory is performed, you can add the new values to the **Qty. (Phys. Inventory)** column in Business Central's **Physical Inventory Journals** administrative section. 


## Perform planned stock count (mobile device)

There are two types of stock counts - planned and unplanned. In the planned stock count, you have a predefined list of filtered items that need to be counted. After the warehouse employees scan the items, they can be updated in Business Central and finally the revised stock count list can be posted. The unplanned stock count implies that the need for checking the stock count arises on the spot, as opposed to having an item list ready.

To perform the planned stock count on the mobile device, follow the provided steps:

1. Open the **NP WMS** app on the mobile device, and log in.
2. From the **Main Menu**, navigate to the **Stock Take Menu**.
3. To performed a planned count, click **Planned Count**, and select the warehouse location on which you wish to perform the stock take from the list.    
   The list of the physical inventory corresponding to the filtered list form the Business Central's **Physical Inventory Journals** is displayed.
4. Perform the item scan. As you do so, the **Quantity** column is going to be populated accordingly.