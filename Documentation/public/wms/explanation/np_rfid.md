# NP RFID app features

The NP RFID app consists of the following features and sections:

## Counting (COUNT)

The **Counting** section is used for recording shop and stock counts, as well as stock refills, if any are required. 

To learn more about the counting process, refer to the article on [performing the shop and stock count](../howto/stock_count_rfid.md).

## Shipping and Receiving (SHIP)

The **SHIP** section is used for recording the item shipping and receiving operations. Every time items are shipped or received, you can record the process with the app, and then scan the shipped/received items to check if everything is in order. 

A prerequisite for recording these processes is to create the accompanying documents in Business Central:

- [sales orders](https://learn.microsoft.com/en-us/dynamics365/business-central/sales-how-sell-products)
- [transfer orders](https://learn.microsoft.com/en-us/dynamics365/business-central/inventory-how-transfer-between-locations)
- direct transfer orders (reclassification journals)

After the necessary documents have been created, you can initiate the shipping/receiving process, count the items that are to be shipped, and finalize the process. 

 > [!Note]
 > The shipping/receiving contents are usually stored in boxes, and then in areas separate from the warehouse, so that no additional RFID tags are picked up during the scan.

When the process is finalized, you can see the results in the **RFID Documents** section in Business Central. A document is automatically generated when the counting is done, and it contains the total number of scanned RFID tags. 

## Tags (TAGS)

In the **TAGS** section, you can link an RFID tag from Business Central to a specific item, thus creating a unique code for it. You can also perform a scan to check how many available tags are valid, and if any need to be fixed. 

### Related links

- [Install WMS and RFID apps on mobile devices](../howto/install-mobile-apps.md)
- [Perform stock count (Physical Inventory Journal and mobile apps)](../howto/perform_stock_count.md)