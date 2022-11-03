# Perform stock count (Physical Inventory Journal and mobile apps)

It's necessary to periodically compare the actual stock quantity with the stock quantity recorded in the Business Central. Stock counting is performed by comparing the physical inventory from warehouses and the calculated inventory in Business Central, and settling the differences between the two using Inventory Journals. The first segment of the stock count procedure is performed in the Physical Inventory Journal in Business Central, and then taken up by the NP mobile apps.

NaviPartner provides two types of stock counts - planned and unplanned. In the planned stock count, you have a predefined list of items that need to be counted. The counting is performed using the NP mobile app for scanning the items, and then updating the counted quantities in Business Central. The counting sheet is then posted in Business Central.  After the warehouse employees scan the items, they can be updated in Business Central and finally the revised stock count list can be posted. The unplanned stock count implies that the need for checking the stock count arises on the spot, as opposed to having an item list ready.

## Perform planned stock count (Business Central)

To perform the stock count in Business Central, follow the provided steps:

1. Click the ![Lightbulb that opens the Tell Me feature](../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **Physical Inventory Journals** and choose the related link.
2. To prepare the list of items which will be counted, click **Prepare**, and then **Calculate Inventory**.      
   The **Calculate Inventory** popup window is displayed. Here, you can add information such as posting date, document number, and apply the filters for item groups. 
3. Apply the filter to determine according to which criteria the item group will be selected in the **Filter totals by** section (for example, according to the warehouse location).
   The list of physical inventory journal entries corresponding to the filter criteria is displayed.   
   The **Qty. (Calculated)** field contains the stock level recorded in Business Central, while the **Qty. (Phys. Inventory)** field contains the actual physical quantity of items in the warehouse, as determined by the physical count. Business Central will default the same value in both fields, as there will be no difference. 

4. Navigate to **Actions**, and then select **Print**.    
  Once the document is printed, the warehouse employees can scan the items with their mobile devices and record the physical inventory values in the **Qty. (Phys. Inventory)** column.
5. Once the physical inventory is performed, you can add the new values to the **Qty. (Phys. Inventory)** column in Business Central's **Physical Inventory Journals** administrative section. 

## Perform planned stock count (mobile device)

To perform the planned stock count on the mobile device, follow the provided steps:

1. Open the **NP WMS** app on the mobile device, and log in.
2. From the **Main Menu**, navigate to the **Stock Take Menu**.
3. To performed a planned count, click **Planned Count** (with bins, or without - depending on the use case), and select the warehouse location on which you wish to perform the stock take from the list.    
   The list of the physical inventory corresponding to the filtered list form the Business Central's **Physical Inventory Journals** is displayed.
4. Perform the item scan. As you do so, the **Qty. (Phys. Inventory)** column is going to be updated accordingly.

> [!Note]
> Unplanned count is performed similarly to the planned count on mobile devices. However, no Physical Inventory Journals will be created in Business Central. The quantity from the NP apps will be transferred to Business Central, and the difference between the scanned quantities will be posted as Inventory Adjustments. 


> [!Video https://share.synthesia.io/e40343b3-3ccd-489e-812e-c2ae88422ff4]


> [!Video https://share.synthesia.io/3ddb5ff5-5fe0-4b83-adab-0862d81076f7]

### Related links

- [Set up Capture Service (CS)](set-up-cssetup.md)
- [Inventory adjustments](../explanation/inventory_adjustments.md)
- [Post inventory adjustments with the Item Journal](https://docs.microsoft.com/en-us/dynamics365/business-central/inventory-how-count-adjust-reclassify)