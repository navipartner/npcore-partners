# Capture Service Setup (CS Setup)

Before you start using NP WMS, you need to configure the rules which define how it will work. This is done in the **CS Setup** administrative section.

The CS setup consists of the following sections:

## General Setup 

This section contains general settings for the Capture Service.

| Field Name      | Description |
| ----------- | ----------- |
| **Enable Capture Service**       | Make sure this toggle switch is active if you wish to enable usage of handheld devices for scanning the warehouse components.  |
| **Log Communication**   | Use this option if you wish to record communication between Business Central and the WMS mobile app. Its main purpose is for troubleshooting and debugging scripts, as well as for tracking transactions handled by the NP WMS module.      |
| **Warehouse Type**  | Specifies the type of warehouse that you can apply to your environment. You can choose between the **Basic**, **Advanced** or **Advanced (Bins)**. |
| **Zero Def. Qty. to Handle** | Apply this option if you wish to set 0 as the default quantity in **Quantity to Handle** in your warehouse documents.  |
| **Sum Qty. to Handle** | Apply this option to sum the quantity of all scanned items of the same type. If disabled, each scanned item will be displayed in a distinct row in the NP WMS app. |
| **Autofill Qty. to Handle** | Enable users to automatically add the item quantity every time an item is scanned. If the toggle is disabled, users will be prompted to manually add quantity after each scan. | 
| **Lock Documents** | Specifies the type of locking that is applied to the warehouse documents when handled from the NP WMS mobile app. Locking prevents other users from accessing the same documents on the mobile device. You can choose between **No Lock**, **Lock & Assign** (automatically assigns the document to the current user) or **Lock & Assign/Unassign** (automatically assigns the document to the current user, and unassigns it from the previous user). |
| **Notify Ready for Posting** | If active, a notification will be displayed when a warehouse document is ready to be posted. |
| **Device Admin Password** | The device admin password for the RFID app can be set in this field. | 
| **Maximum No. of App. Users** | Specifies the maximum number of CS users that can use the NP WMS app during the current subscription period. |
| **Maximum No. of App. Users in Next Period** | Specifies the new maximum number of CS users that can use the NP WMS app applicable as of the next subscription period. Once the next subscription period has started, the maximum number of app users will be updated based on its value, and then the value will be cleared. |
| **No. of App. Users in Current Period** | Specifies the number of CS users that have already used the NP WMS app during the current subscription period. |


## Stock Take 

This section contains settings for the Stock Take module if you're using in on a mobile device.

| Field Name      | Description |
| ----------- | ----------- |
| **Filter Worksheets by Location**     | If active, users will only have access to the worksheets they were assigned in **Warehouse Employees**. |
| **Error on Invalid Barcode**   | If active, an error will be reported each time an invalid barcode is detected.  |
| **Aggregate Stock-Take Summarize**  | If active, the sum of stock take item lines will be summed up, and a summary provided. |
| **Create Worksheet after Transaction** | If active, a new blank worksheet will be automatically created once the previous one has been posted.  |


## RFID

This section contains settings related to the radio-frequency identification.

| Field Name      | Description |
| ----------- | ----------- |
| **Stock-Take Template**     | Specifies the selected stock-take template that will be used for RFID scanning. |
| **Counting Method**   | Specifies the preferred counting method. The available options are **Shop And Stock** and **Shop**. |
| **Disable Counting Authenticate**  | If active, the counting authentication will be disabled. |


## Ship & Receive

This section contains the settings related to posting of warehouse documents.

| Field Name      | Description |
| ----------- | ----------- |
| **Import Tags to Shipping Documents**  | If active, the RFID tags will be imported to shipping documents. |
| **Use Whse. Receipt** | If active, the warehouse receipt will be used for receipting. |

## Price Calculation 

This section contains the settings related to price calculation of items.

| Field Name      | Description |
| ----------- | ----------- |
| **Price Calc. Customer No.**  | Specifies the customer number that will be used when performing price calculation on mobile devices once the item has been scanned. |

## Searching

This section contains the settings related to grouping of search results.

| Field Name      | Description |
| ----------- | ----------- |
| **Max Records in Search Result**  | Specifies maximum number of records that will be returned to your mobile device when performing the search. |


## Worksheets 

This section contains the settings related to the common templates used in regards to the stock count.

## Physical Inventory Counting 

This section contains the settings related to the templates used in regards to the physical inventory count.

  
## Job Queue 

This section contains the settings related to the job queue processing.

| Field Name      | Description |
| ----------- | ----------- |
| **Post with Job Queue**     | If enabled, all Business Central postings triggered from the NP WMS app will be scheduled in the **Job Queue** for processing. |
| **Job Queue Category Code**   | Provide the code of the job queue category that the posting jobs belong to.|
| **Notify on Success**  | If active, a notification will be displayed after each successful posting. |
| **Run in User Session** | If active, the job queue will be run during the user session. |

## Azure Printing 

This section contains the settings related to printing. If you wish to be able to print from the envoy device, you can configure the Azure functionalities in this section. All WMS documents that you wish to print can be sent to the blob storage, from which they will be printed on a specific printer inside the warehouse.

| Field Name      | Description |
| ----------- | ----------- |
| **Azure Print Container**     | Specifies the container used for printing the shipping document. |
| **Azure Print Tested**   | Specifies whether the container has been tested.  |

From the **CS Setup** you can also set up [CS users](../howto/set-up-cs-users.md), devices, and [mobile app UI](../howto/set-up-cs-uis.md).

> [!Note]
> You can also access one of the [logs](../explanation/cs_logs.md) in **CS Setup** if you encounter unforeseen issues in the environment. 

## Video walkthrough

> [!Video https://www.youtube.com/embed/6EXqbu1jeTI]

### Related links

- [Create QR codes](../howto/create-qr-codes.md)
- [Set up CS](../howto/set-up-cssetup.md)
- [Set up CS Users](../howto/set-up-cs-users.md)
- [Create QR codes](../howto/create-qr-codes.md)