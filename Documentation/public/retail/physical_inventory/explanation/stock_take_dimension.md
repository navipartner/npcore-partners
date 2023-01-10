# Stock-take by Dimension

Filtering items according to Dimensions is by default hidden, and can be made available on request. 

The Global Dimension Codes on the [stock-take worksheet](../howto/stock_take_worksheet.md) act as filters to the item table, and can narrow the scope to include only items with those Dimension codes as in-scope items. You can manually specify other Dimension codes and values for each line in the worksheet that will be used during [posting](../howto/transfer_post_worksheet.md). 

To make this process more convenient, the [configuration](../howto/configure_stock_take.md) can define both the Dimension values for filtering, and the Dimension values for posting. Those Dimension code values on the form itself (in the **Scope** tab) are transferred to the worksheet Dimension filters. The Dimension codes specified on the configuration lines, however, are applied to the item on the worksheet lines. The Dimension specified on the worksheet line will be carried over to the Item Inventory Journal. 

If the Dimension setup allows it, it will be possible to capture the cost of quantity adjustments on the Dimension code value other than the ones defined on the actual item. However, inventory can't be split on Dimension code values with this module. 

### Related links

- [Stocktaking and physical inventory](../intro.md)