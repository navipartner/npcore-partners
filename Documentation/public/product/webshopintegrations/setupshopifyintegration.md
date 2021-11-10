# Set up Shopify integration in NaviPartner

NaviPartner out-of-the-box Shopify integration functionality supports the following Shopify integration areas:

- Sending item information to Shopify (new and updated items and variants);

- Sending available inventory to Shopify (quantity available for sale);

- Getting sales orders from Shopify. We support 2 types of integration here:
    -	Order processing is done on the Shopify side: we import new orders from Shopify and automatically post them once we receive updated information from Shopify about completed orders (or delete them, if the order was cancelled in Shopify);
    -	Order processing is done in Business Central: in this case we import new orders from Shopify, and users will need to process them in Business Central. Once a sales order is processed and posted in the Business Central we send “fulfilment” and “payment capture” requests to Shopify.

## Prerequisites

- Install the NP Retail application. The application's version needs to be 1700.9.50.10000 and higher.   
  The extension is dependent on it, so it needs to exist in the tenant database prior to the installation of Shopify integration extension.
- Install the Shopify extension in the customer tenant database.       

> [!Note]
> A private application needs to be registered on the Shopify environment that Business Central should be connected to. Other than that, nothing needs to be developed on their side for the integration setup to be successful. We are using the existing Shopify capabilities (web services) to send data and get data from Shopify. All data transfers are initiated from the Business Central side.

## Procedure

To set up the Shopify integration:

1. From the **Role Center**, search **Shopify Integration Setup** and click on it once it's displayed in the results.      
   A window which contains general integration settings. You can choose which integration areas to enable, and specify the connection parameters.      

> [!Note]
> Whenever you change one of the values in this page, you'll need to sign into the Business Central again before the changes are applied.

2. Search for **Locations** and click **New**.
   At least one location needs to be set up in your Business Central company.          

 > [!Note]
 > You can link as many Business Central locations to a single Shopify location as you wish, but it's impossible to link multiple Shopify locations to a single location in Business Central.


3. In the **Shopify Location ID** field, use the assist-edit button to specify a value.      
   If you've already set up the connection parameters on the **Shopify Integration Setup** page, you will see a list of available Shopify locations to select from.     
4. (Optional) If sales order integration area is applicable, a separate e-commerce store needs to be created in Business Central for each value sent from Shopify as a JSON key **Source Name** of the Shopify order JSON file.
5. Specify the following information on the **E-commerce Store Card** for each store:     
   - **Code** - the value of the **Source Name** JSON key.
   - **Name** 
   - **Salesperson/Purchaser Code**
   - **Location Code**
   - **Customer No.**, **Customer Mapping**, **Customer Config. Template**, **Allow Create Customers**
6. Set up the shipment method mapping for each value sent from Shopify as a value from the JSON key **Code** in the **shipping_lines** array of the Shopify order JSON file.       
7. For each **External Shipment Method Code**, specify the following information:  
   - **External Shipment Method Code**
   - **Shipment Method Code**
   - **Shipping Agent Code**, **Shipping Agent Service Code**
   - **Location Code**
   - **Shipment Fee No.**
8. Set up a payment method mapping in Business Central for each value sent from Shopify as a JSON key **gateway** of the Shopify JSON order file.
9. Fill in the following columns in each payment method mapping line:   
   - **External Payment Method Code**
   - **External Payment Type**
   - **Payment Method Code**
10. Set up the location mapping.      
    The location mapping is used for identifying where the Business Central location code items are shipped from, as well as the shipping agent and its service code.     
    
    > [!Note] 
    > The location mapping setup is taken into account only if the system isn't able to identify the parameters (location code, shipping agent code) on the previous step during the shipment method evaluation.

11. For each location mapping line, you need to provide the following information:   
    - **Store Code**
    - **Country/Region Code**
    - **From Post Code**
    - **To Post Code**
    - **Location Code**
    - **Shipping Agent Code**, **Shipping Agent Service Code**            

    > [!Note]
    > If it's impossible to identify a Business Central location in the mapping setup, the default location should be used. The default location can be specified in the **Store Card** (the **Location Code** field).

   ## Next steps

   ## Automatically generated setups
   
   The following setups are generated automatically by the system when they are required

   ## Data log subscribers

   Data log subscribers are needed for the system to keep track of changes done to the data. Those are created automatically once that integration area has been enabled.

   The following data log subscribers are required:

| Table ID    | Table Name              | Direct Data Processing Codeunit           | Itegration Area                       |
| :---        |    :----:               |                                      ---: |                                  ---: |
| 27          | Item                    | 70010442 NP-Spfy Item Mgt.                | Item List Integration                 |
| 32          | Item Ledger Entry       | 70010446 NP-Spfy Inventory Level Mgt.     | Available Inventory Updates           |
| 37          | Sales Line              | 70010446 NP-Spfy Inventory Level Mgt.     | Available Inventory Updates           |
| 5401        | Item Variant            | 70010442 NP-Spfy Item Mgt.                | Item List Integration                 |
| 5717        | Item Reference          | 70010442 NP-Spfy Item Mgt.                | Item List Integration                 |
| 70010435    | Shopify Inventory Level | 70010442 NP-Spfy Item Mgt.                | Available Inventory Updates           |

> [!Note]
> All data log subscribers should have **Delayed Data Processing (sec)** set to **1** and the **Direct Data Processing** should be set to **Yes**, except for testing environments, as it may cause incorrect inventory levels to be sent to Shopify.


   ## Job queue entries

The job queue entries are needed to automate the periodic data exchange between Business Central and Shopify.

They involve:
 - Processing of both Business Central task list and import list entries. 
 - Running specific Shopify-related tasks, like getting Shopify orders. 

The job queue entries are created automatically by the system once the respective integration areas are enabled, or a data sending task is scheduled. 

  ## Import Types

Import types are needed to process data received from external sources, like Shopify.

The following import types are needed for the integration (all of them are related to the **Sales Order** integration area)

| Code                   | Description             | Import List Update Handler      | Import Codeunit ID     |  Lookup Codeunit ID       |
| :---                   |    :----:               |                            ---: |                   ---: |                      ---: |
| SHOPIFY_CREATE_ORDER   | Create Shopify Order    | Default                         | 70010435               | 70010436                  |
| SHOPIFY_DELETE_ORDER   | Delete Shopify Order    | Default                         | 70010437               | 70010436                  |
| SHOPIFY_POST_ORDER     | Post Shopify Order      | Default                         | 70010438               | 70010436                  |


> [!Note]
> All the import types are checked and created automatically by the system, when new import list entries are added.

## Synchronize the Items List

The system can send to Shopify information about new and updated items and item variants.

### Prerequisites
To include an item into the synchronization scope:  

- Enable the **Item List Integration** area of the **Integration Area** section.

1. Set the field's **Shopify Item** value to true on the **Item Card**. You need to do this on all items that you wish to synchronize.      

> [!Note]
> The blocked items and item variants are not sent to Shopify.

2. 