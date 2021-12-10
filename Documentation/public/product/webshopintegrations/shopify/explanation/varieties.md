# Varieties

Varieties/variants assist users in creating different characteristics associated with an item. Item varieties can be copied and shown in Shopify as product variant options. 

## Variety mapping

There are two things to take into account when mapping varieties to Shopify options:

- Shopify supports only three variant options (as opposed to Business Central, which supports four). If the **Item Card** has all four varieties defined in Business Central, only 1, 2, and 3 are sent to Shopify, while the fourth variety isn't included in the synchronization.
- Shopify has a stricter policy on how variant options can be defined. It's not possible to define an option until all the options preceding it have already been defined. For example, the second option can't be defined before the first one, and the third option can't be defined before the second one. In Business Central, you can define varieties arbitrarily: there's no need to define the first variety for an item before defining the second one, and so on.

The system applies dynamic mapping when identifying which Business Central variety number will be mapped to which variant option number in Shopify: the lowest specified variety on the **Item Card** in Business Central becomes option1 in Shopify, while the following variety number becomes option2, and so on. For example, if the **Item Card** has varieties 2 and 4 in Business Central, the variety 2 becomes option1, and the variety 4 becomes option2 in Shopify.

## Conditions for synchronization

There are several conditions which determine whether a variety is included in the synchronization:
- The variety value needs to be specified on the item variant record.
- The **Use in Variant Description** toggle switch needs to be active in the **Variety** administrative section.
- If the **Use Description Field** toggle switch is active in the **Variety** administrative section, the **Description** field needs to be specified on the **Variety Value** administrative section, since the variant description will be generated from it.  

When calculating the variety description string, which is sent to Shopify, the **Pre tag in Variant Description** field is used in the **Variety** administrative section.

### Related links
- [Shopify SKU](./shopifysku.md)
- [Synchronize Items List](../howto/syncitemslist.md)
- [Set up Shopify integration](../howto/setupshopifyintegration.md)