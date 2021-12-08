# Sending inventory to Shopify

The administrative section **Shopify Inventory Levels** stores the pre-calculated available inventory levels before sending them to Shopify.

The Shopify inventory levels are updated on each item-related transaction posting (when an item ledger entry is created), and each time a sales order line is created, updated, or deleted.

The inventory levels are calculated per a Shopify location ID. That means that, if the same Shopify location ID is assigned to multiple Business Central locations, the system sums up the data from all of those Business Central locations to calculate the inventory level tied to the specific Shopify location ID.

How is Shopify inventory calculated?

|                     |                         |                       |
|---------------------|-------------------------|-----------------------|
| Available inventory | Quantity on sales order | Safety stock quantity |

The safety stock quantity can be set in the **Shopify Safety Stock Quantity** field of the **Item Card** of any item. It helps limit stock shortages due to unforeseen events. If you wish to set a different level of Shopify safety stock quantity for each item variant, it's necessary to create stockkeeping units in Business Central (you can do so in the **Create Stockkeeping Units** administrative section).

> [!Note]
> If there's at least one stockkeeping unit for an item in Business Central, the value of the Shopify safety stock quantity specifies on the **Item Card** is disregarded.

The inventory level synchronization triggering process is very similar to the process of [item list synchronization in Business Central](./syncitemslist.md) - it involves the **Item Ledger Entries** table, the **Sales Line** data log subscribers, as well as processing of the **Task List** entries.

### Related links
- [Set up Shopify integration](./setupshopifyintegration.md)