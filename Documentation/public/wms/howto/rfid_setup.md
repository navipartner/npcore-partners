# Set up RFID functionalities in Business Central

RFID tags are unique scannable identifiers of items. They consist of printable chips that are generated on the basis of numerical data provided in the **RFID Setup** page. 

The NP RFID functionalities can be grouped into two segments:

- NP WMS extension installed in the Business Central database
- NP RFID apps installed on the scanner

To set up the RFID functionalities, follow the provided steps: 

1. Navigate to the **RFID Setup** administrative section.     
   This section is used for generating data that will be stored on the printable RFID chips. In NP WMS, this data is expressed in hexadecimal values.

   > [!Note]
   > RFID tags are unique for each item.

    | Field Name      | Description |
    | ----------- | ----------- |
    | **RFID Value No. Series** | The number series references the group of items the tag will be used to signify. Each number series has a fixed starting and ending number, so each item with this RFID tag will be assigned the first available number between those two fixed values.  |
    | **RFID Hex Value Length** | Specifies the overall length of the number used to generate the RFID tag.  |
    | **RFID Hex Value Prefix** | Specifies the number that will precede the rest of the number used to generate the RFID tag.  |

    After the following numbers are specified, they are used to build a visual representation of the RFID which can then be printed. 

2. Next up, you need to [set up **CS RFID Tag Models**](create_rfid_tag_model.md).    
   In this section you can specify the alphanumerical values used for distinguishing between items belonging to different stocks. All items that don't belong to product families and models specified in this section can still be scanned with the RFID scanner, but will not be recognized as parts of the relevant stock.

   > [!Note]
   > RFID is used in stores. Stores are divided into the shop floor and a small storage space at the back. The counting is performed in the display area first (shop floor), and then in the back. The sum of the two is considered to be the full stock, which is compared to what is recorded in Business Central. When comparison is finished, changes can be applied in Business Central. This concludes the daily RFID counting process.

3. Navigate to the **CS Location Users** administrative section to set up users who will be performing the counting.
4. Provide the **User ID**.    
   Each device is linked to a user, so the user ID is the same as the device ID. 
5. Specify which users are **Supervisors**.    
   Supervisors can apply the necessary adjustments after the counting is finished.
6. Connect the scanner to the Business Central user who is going to perform the counting.

## Next steps

- [Perform shop and stock count in NP RFID](stock_count_rfid.md)

### Related links

- [CS setup](../reference/cs-setup.md)
- [Install and set up NP WMS and NP RFID](install-mobile-apps.md)
- [Recommended WMS hardware](../reference/wms_hardware.md)