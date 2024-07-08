# Create a new transfer order

By creating transfer orders, you can move inventory items from one location/bin to another. During this process, the item quantity isn't changed, i.e. if there are 1000 items in location A, all 1000 will be transferred to the location B via a transfer order. 

To create a new transfer order, follow the provided steps: 

1. Click the ![Lightbulb that opens the Tell Me feature](../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **Transfer Orders**, and choose the related link.        
2. Click **New**.
3. Populate the necessary fields in the **General** section:
   
| Field Name      | Description |
| ----------- | ----------- |
|  **Transfer-from Code**   | Provide the original location from which the inventory items are shipped.  |
|  **Transfer-to Code**  | Provide the location to which the inventory items are transferred.    |
|  **Direct Transfer**  | If both locations are in the same building, or if in-transit location isn't necessary for any other reason, you can enable this toggle switch. If enabled, the items are directly transferred from one location to another.  |
|  **In-Transit Code**  |  If you wish to specify the in-transit location in which items are stored temporarily before arriving at the transit-to location, populate this field with that location's code (e.g. the code of a transportation vehicle which transfers items). |
| **Posting Date**  | Provide the date on which the transfer order is posted. |

4. In the **Lines** section, provide the item numbers, quantities, and other necessary item-related information.   
   If the quantity you provide is higher than the available item quantity in stock, you will not be able to post the transfer order.
5. In the **Shipment** section you can provide more specific information about the shipment, if needed.
6. In the **Transfer-from** and **Transfer-to** sections, you can edit the name of the respective locations between which the transfer occurs.
7. In the **Warehouse** section, you can specify the time it takes to make items a part of the available inventory after they have been received.
8. In the **Foreign Trade** section, you can provide additional information if the items are shipped to the foreign country. 
9. After you're finished with the creation of a transfer order, click **Posting** in the ribbon, followed by either **Post** or **Post and Print**.
10. Choose **Ship** in the pop-up window, and click **OK**.      
    After this, the items will enter the transit between the two locations. 
11. Click **Posting**, followed by **Post**/**Post and Print** in the ribbon, and then choose the **Receive** option in the pop-up window. Click **OK**.        
    You can see the posting results in the **Item Ledger Entries**.

> [!Note]
> It is also possible to use the [Item Reclassification Journal](reclassify_items.md) to transfer items between locations/bins, however the difference is that you can't manage warehouse activities with the Item Reclassification Journal, you can only state the current location, and the location to which items are transferred. The **Transfer Orders** administrative section offers more options. 

### Related links

- [Item Reclassification Journal](reclassify_items.md)