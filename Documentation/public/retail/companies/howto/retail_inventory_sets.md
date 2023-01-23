# Set up retail inventory sets

In some cases, multiple companies are set up in a single database. Such companies often trade in the same fields, and commonly have similar items available in their item lists. With this module, if there's shortage of an item in one of the companies, you can check the inventory status in other companies which belong to the same database without having to switch the company first. If a requested item is available elsewhere, a salesperson can direct the customer to the other shop.

To set up retail inventory sets and start using them, follow the provided steps:

1. Click the ![Lightbulb that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **Retail Inventory Sets**, and choose the related link.           
2. Click **New** in the ribbon.     
   The **Retail Inventory Set Card** is displayed.
3. Populate the following fields:    

   | Field Name      | Description |
   | ----------- | ----------- |
   | **Company Name** | Select the company whose inventory you wish to check. |
   | **Location Filter** | Enter the code of the company's location. |
   | **Enabled** | If enabled, the setup line will be in use. If not, the line will not be active. |
   | **API URL** | This value will be populated automatically. | 
   | **Auth. Type** | Choose whether you wish to perform authentication with username and password, tokens, or in a custom way. |
   | **API Username** | Provide the username for webservice authentication if basic authentication is performed. |
   | **API Password** | Provide the password for webservice authentication if basic authentication is performed. |
   | **Processing Function** | Drill down on this field, and select the **ProcessInventorySetEntry** function. |
   | **Processing Codeunit Name** | This field will be populated automatically.  |

4. To test if the setup was successful, use the **Test Retail Inventory** action in the ribbon.     
   The **Item List** is opened.
5. Select the item you want to look up in another company from the **Item List**, then click **OK**.     
   If the setup was successful, a new page with inventory on locations enabled in the setup is displayed.   

   ![retail_inventory_sets](../images/retail_inventory_sets.png)

## Next steps

### Check inventory from a different company

1. Navigate to the **Item List**, and search for the item you wish to check the status of. 
2. Select the item, and click **Retail Inventory Set** found in the **Related** options in the ribbon.     
   A new page is displayed.
3. Select the inventory set you wish to use for fetching inventory data, and click **OK**.     
      A page with the requested inventory data is displayed. 

   ![retail_inventory_sets2](../images/retail_inventory_sets2.png)