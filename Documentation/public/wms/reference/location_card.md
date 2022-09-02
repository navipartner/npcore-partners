# Location card (reference guide)

The **Location Card** administrative section contains the following fields and options in the **General** section:

| Field Name      | Description |
| ----------- | ----------- |
|  **Code**   | Specifies the location code for the warehouse, or the distribution center, in which items are handled and stored before being sold.   |
|  **Name**  | Specifies the name/address of the location.   |
|  **Use As In-Transit**  |   Specifies whether the location will be used as a temporary storage for the items.   |

The following fields and options are available in the **Address & Contact** section:

| Field Name      | Description |
| ----------- | ----------- |
|  **Address**   |  Specifies the address of the location.   |
|  **Address 2**  |  Specifies the address line 2, or any additional information of the location.  |
|  **Post Code**  |   Specifies the postal code of the location.   |
|  **City**   |   Specifies the name of the city in which the location is situated.  |
|  **Country/Region Code**  |   Specifies the code of the country/region in which the location's city is.  |
|  **Contact**  |   Specifies the name of the person who should be contacted in relation to the location.   |
|  **Phone No.**   |  Specifies the contact phone number.   |
|  **Email**  |  Specifies the email address associated with the location.   |
|  **Home Page**  |  Specifies the URL to the location's website homepage.    |

The following fields and options are available in the **Warehouse** section:


| Field Name      | Description |
| ----------- | ----------- |
|  **Require Receive**   |  Specifies if a receipt document is required when receiving items in the location.  |
|  **Require Shipment**  |  Specifies if a shipment document is required when shipping items.  |
|  **Require Put-away**  |  Specifies if the put-away document is required when storing items in the location.    |
|  **Use Put-away Worksheet**   |   Specifies if put-away worksheets need to be created for posted warehouse receipts.   |
|  **Require Pick**  |   Specifies if a pick document is required when selecting items to be shipped.  |
|  **Bin Mandatory**  |   Specifies if the location requires a bin code to be provided on all item transactions.   |
|  **Directed Put-away and Pick**   |  Specifies if the location requires advanced warehouse functionality, such as calculated bin suggestion.  |
|  **Default Bin Selection**  |  Specifies the method used to select the default bin if the **Bin Mandatory** toggle switch is enabled. The following options are available: **Fixed** - an item is fixed to the bin, and will always be stored in that bin if there's enough space; **Last-Used Bin** - the bin that was used in the previous storing process will be automatically selected.   |
|  **Outbound Whse. Handling Time**  |  Specifies if a date formula for the time it takes to get items ready to ship from this location.     |
|  **Inbound Whse. Handling Time**   |  Specifies the time it takes to make items a part of available inventory after the items have been posted as received.  |
|  **Base Calendar Code**  |  Specifies a customizable calendar that contains the location's working days and holidays.   |
|  **Customized Calendar**  |   Specifies if the location has a customized calendar with working days that are different from those defined by the company's base calendar.   |
|  **Use Cross-Docking**  |   Specifies if the location supports movement of items directly from the receiving dock to the shipping dock.  |
|  **Cross-Dock Due Date Calc.**  |   Specifies the cross-dock due date calculation.    |

The following fields and options are available in the **Bins** section:

| Field Name      | Description |
| ----------- | ----------- |
|  **Receipt Bin Code**   |  Specifies the code of the default receipt bin.   |
|  **Shipment Bin Code**  |  Specifies the code of the default shipment bin.  |
|  **Open Shop Floor Bin Code**  |   Specifies the code of the bin that functions as the default open shop floor bin; this code is used for internal handlings related to the production order.   |
|  **To-Production Bin Code**   |  Specifies the code of the bin used for moving into the production order when it's necessary to perform a production pick.   |
|  **From-Production Bin Code**  |   Specifies the code of the bin used to store the items when the output from the production order is posted, and when items are moved away from the production order.  |
|  **Adjustment Bin Code**  |   Specifies the virtual bin in which the observed discrepancies in inventory quantities are recorded.   |
|  **Cross-Dock Bin Code**  |   Specifies the bin code that is used by default for the receipt of items to be cross-docked.   |
|  **To-Assembly Bin Code**   |  Specifies the bin in the assembly area in which components are placed by default before they can be consumed in the assembly.  |
|  **From-Assembly Bin Code**  |  Specifies the bin in the assembly area where the completed assembly items are posted to when they are assembled to stock.  |
|  **Asm.-to-Order Shpt. Bin Code**  |  Specifies the bin in which the completed assembly items are posted when they are assembled to a linked sales order.    |

The following fields and options are available in the **Bin Policies** section:

| Field Name      | Description |
| ----------- | ----------- |
|  **Special Equipment**   |  Specifies the default location in which the special equipment designated for warehouse activities is stored  |
|  **Bin Capacity Policy**  |  Specifies how the bins are filled automatically, according to their capacity.  |
|  **Allow Breakbulk**  |   Specifies whether another order can be filled with items stored in alternate units of measure, if an item measured in the requested unit of measure hasn't been found.   |
|  **Put-away Template Code**   |   Specifies the code of the put-away template used at this location.  |
|  **Always Create Put-away Line**  |   Specifies whether a put-away line is created even if the appropriate zone and bin can't be located.  |
|  **Always Create Pick Line**  |   Specifies whether a pick line is created even if the appropriate zone and bin can't be located.   |
|  **Pick According to FEFO**   |  Specifies whether the First Expired First Out (FEFO) method is used to determine which items to pick, according to the expiration dates.  |
