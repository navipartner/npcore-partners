# Inventory adjustments

Inventory adjustments refer to all modifications of the stock level, which occur for various reasons. These can be results of sales, purchases, or positive and negative adjustments.

Some companies tend to make minor inventory adjustments throughout the fiscal year, while others make them as a regular part of their business process.

To post adjustments to the item stock, you can use the [Item Journals](../howto/post_inventory_adjustment_item_journal.md), to perform item counting, you can use the [Physical Inventory Journals](../howto/perform_stock_count.md), and to change information attached to the items, use the [Item Reclassification Journal](../howto/reclassify_items.md).

## Adjustment types
  
- Positive adjustments refer to scenarios in which excess stock needs to be recorded and sold.     

![positive adjustment](../images/item_journal_positive_adjustment.PNG)

- Negative adjustments refer to scenarios in which items are broken or otherwise deemed out of commission. Bear in mind that the value of the **Cost Amount (Actual)** on the posted negative adjustment may depend on the FIFO cost of the item batch.

> [!Note]
> When recording a positive or negative adjustment, the **Unit Amount**, **Amount**, **Discount Amount**, and the **Unit Cost** will be populated automatically. 

- Purchases are for posting positive inventory adjustments that work as purchase order transactions. Both purchases and positive adjustments indicate raise in the stock level, but this raise is recorded either in the purchase account or adjustment account respectively in the **General Posting Setup**. 

![item journal purchase](../images/item_journal_purchase.PNG)

- Sales are for posting negative inventory adjustments that work as sales order transactions. As soon as you provide the number of the item you wish to sell, as well as the item quantity, the unit price of that item will be displayed in the **Unit Amount** field, and the full price for that quantity in the **Amount** field. The **Unit Cost** field will contain the amount at which the item was previously procured. 

![bc sale item journal](../images/bc_sale_item_journal.PNG)

### Related links

- [Inventory and warehouse putaway](warehouse_putaway.md)
- [Inventory and warehouse pick](inventory_warehouse_pick.md)
- [Perform stock count (Physical Inventory Journal and mobile apps)](../howto/perform_stock_count.md)