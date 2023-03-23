# RFID administrative sections in Business Central

The RFID administrative sections are used to help you perform various jobs related to counting, shipping, receiving, and tagging items. The following sections are available: 

## Counting schedule

The **Counting Schedule** administrative section is used for scheduling counting jobs in shops and stockrooms. You simply need to specify the **Location Code** of the store, and the days on which the count will be performed. The **Earliest Start Date/Time** field is automatically generated according to the specified location's working hours and the selected days for the count.  

> [!Note]
> It's recommended to schedule each count if there is a large number of items that need to be scanned, as a physical journal entry needs to be created each time the counting is done. Therefore, if physical inventory journal entries are created for counting on a scheduled basis, the time required for counting will be reduced. 


## Antenna

The **Antenna** section is used for setting up the process of importing RFID documents from software other than Business Central, and for storing these imported documents. If an external scanner is used for the RFID scan, any related data can be uploaded and stored in Business Central. 


## Joined Tags

The **Joined Tags** administrative section is used for storing the RFID tags joined in the [NP RFID](np_rfid.md) app. 

## EPC Data List

The **EPC** (Electronic Product Code) **Data List** administrative section is used for storing the keys which are created by combining reference item numbers and reference item variant codes to produce unique IDs for every physical object in the stock.

## Countings

A line is created in the **Countings** administrative section when you initiate the [stock count](../howto/perform_stock_count.md).

When you open the line, you can see stockroom, sales floor, what has been refilled or if it has been posted or not. 

### Related links

- [Set up RFID functionalities in Business Central](../howto/rfid_setup.md)
- [NP RFID app features](np_rfid.md)
