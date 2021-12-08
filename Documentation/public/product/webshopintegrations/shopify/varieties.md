# Varieties

Varieties/variants assist users in creating different characteristics associated with an item. These variants can be copied and shown in Shopify as product variant options. 

> [!Note]
> The system sends the first three varieties to Shopify (the fourth variety isn't included in the synchronization).

There are several conditions which determine whether a variety is included in the synchronization:
- The variety value needs to be specified on the item variant record.
- The **Use in Variant Description** toggle switch needs to be active in the **Variety** administrative section.
- If the **Use Description Field** toggle switch is active in the **Variety** administrative section, the **Description** field needs to be specified on the **Variety Value** administrative section, since the variant description will be generated from it.  

When calculating the variety description string, which is sent to Shopify, the **Pre tag in Variant Description** field is used in the **Variety** administrative section.

### Related links
- [Shopify SKU](./shopifysku.md)
- [Synchronize Items List](./syncitemslist.md)
- [Set up Shopify integration](./setupshopifyintegration.md)