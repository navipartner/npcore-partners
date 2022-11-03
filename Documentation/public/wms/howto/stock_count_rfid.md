# Perform shop and stock count in NP RFID

Radio Frequency Identification (RFID) is a system that transmits identity in the form of a unique serial number of a product wirelessly. It is used to identify objects, collect data about them, and enter those data directly into computer systems with little or no human intervention. While barcodes are cheaper and well-established globally, the RFID scanning is quicker since it can scan multiple items simultaneously. 

The NP RFID app is used for optimizing the inventory management across different locations. From the app, you can perform counting of the stock and shop inventory, configure and track shipping, and perform tag handling. This article focuses on the shop and stock count, along with the refill functionality. 

> [!Note]
> The NP RFID app is Android-exclusive.

## Prerequisites for using the NP RFID features

- Download and install the [WMS extension for Business Central](Install-NP-WMS.md), and perform the necessary authentication with [the QR code scan](create-qr-codes.md).
- Download and install the [NP RFID app](../howto/install-mobile-apps.md)

## Counting

Counting is the most commonly used feature in the mobile app. Follow the provided steps to go through the entire counting procedure:

1. Press **COUNT** in the NP RFID welcome screen to open the counting interface. 
2. Locate the shop/warehouse you want to perform the counting in by pressing **FIND**.      
   This store corresponds to the **Location** entity in Business Central. 
3. Press **NEW** to start creating an inventory calculation.          
   You can also schedule when an inventory calculation should be performed from the back end.
4. Move on to either **SHOP** or **STOCK** counting.

### Shop counting procedure

1. Press **SHOP**.
   You will see the predicted number of items that should be found in the shop during the counting, as well as the inventory sorted according to the item category.     
   ![NP RFID SHOP](../images/NP_RFID_SHOP.PNG)
2. Press **START** to initiate the counting.   
   You can see how many tags have been counted so far, as well as the progress of the entire counting process in the upper part of the screen. The percentage bar indicates to which degree the predicted and the actual inventory match. 
   - The dark-blue numbers represent the inventory predicted in Business Central.
   - The green numbers represent the counted inventory.
   - The red numbers represent discrepancies between the predicted and the counted inventories. 

    > [!Note]
    > By clicking on the item, you can see which specific item is missing, and see the picture of the missing item.

3. You can then either **RESET** the counting process, or **SAVE** it. 
   After you're done with the counting in the shop, you can move on to the **STOCK** counting.

> [!Note]
> It is possible to find unexpected item tags during the counting. You can import these items into Business Central after the counting is completed. 

### Stock counting procedure

1. Press **STOCK**.
   You will see the predicted number of items that should be found in the shop stock room, as well as the inventory sorted according to type of items it consists of. If some of the items missing from the shop need to be restocked, and these items can be found in the stock room, then it's possible to transfer them via the **REFILL** functionality. 
2. Press **START** to initiate the counting.   
   You can see how many tags have been counted so far, as well as the progress of the entire counting process in the upper part of the screen. The percentage bar indicates to which degree the predicted and the actual inventory match. 
   - The dark-blue numbers represent the inventory predicted in Business Central.
   - The green numbers represent the counted inventory.
   - The red numbers represent discrepancies between the predicted and the counted inventories. 

    > [!Note]
    > By clicking on the item, you can see which specific item is missing, and see the picture of the missing item.

3. You can then either **RESET** the counting process, or **SAVE** it. 
   After you're done with the counting in the stock room, and there are items that you wish to transfer to shops, you can move on to the **REFILL** section.
   If there are no items that you can refill the shop inventory with, skip the **REFILL**, and **CLOSE** the counting. 

### Refill procedure

1. Press **REFILL**. 
   You will see the suggested list of items that can be restocked in the shops. 

   ![NP RFID REFILL](../images/NP_RFID_REFILL.PNG)

2. Select the items you wish to refill the shop stock with by enabling the toggle switches next to respective items. 
3. Press **SAVE**.
4. Move on to the **CLOSE** section to review the refill items. 
5. Press **SAVE** again.    
   Once the counting is approved, the process is completed. 

> [!Note]
> You can also access the **Deviation Journals** from the button in the upper-right corner of the **COUNTING** page to see the history of all performed countings, so you can compare them if needed. You can also see this data in the **CS Stock Takes List** in Business Central. 


> [!Video https://share.synthesia.io/e40343b3-3ccd-489e-812e-c2ae88422ff4]


> [!Video https://share.synthesia.io/3ddb5ff5-5fe0-4b83-adab-0862d81076f7]

### Related links

- [Install WMS and RFID apps on mobile devices](install-mobile-apps.md)
- [Create a CS RFID tag model](create_rfid_tag_model.md)