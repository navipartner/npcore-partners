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
> A private application needs to be registered on Shopify, but other than that, nothing needs to be developed on their side for the integration setup to be successful. We are using the existing Shopify capabilities (web services) to send data and get data from Shopify. All data transfers are initiated from the Business Central side.

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


3. In the **Shopify Location ID** field, use the **assist edit** button to specify a value.      
   If you've already set up the connection parameters on the **Shopify Integration Setup** page, you will see a list of available Shopify locations to select from.