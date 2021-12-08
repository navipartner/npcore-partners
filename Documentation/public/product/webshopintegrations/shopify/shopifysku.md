# Shopify SKU (Stock Keeping Unit)

Whenever an item or an item variant update request is sent to Shopify, the **Shopify Product ID** and the **Shopify Variant ID** are automatically included in the request (or **Shopify Inventory Item ID**, if this is an inventory or unit cost update request).

If there aren't any values for the fields in Business Central, the system will initially attempt to get the IDs from Shopify by providing the Shopify SKU number. For the integration to work properly, the SKU fields in Shopify need to contain the following information:

- Items without variants - the SKU needs to be equal to the Business Central item number.
- Items with variants - each variant SKU needs to be equal to the Business Central item number and Business Central variant code, separated by an underscore (for example: 8000_1)

### Related links
- [Set up inventory update sending (Location links)](./inventoryupdates.md)
- [Varieties](./varieties.md)
- [Set up Shopify integration](./setupshopifyintegration.md)