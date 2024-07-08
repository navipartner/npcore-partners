# Item Card (reference guide)

Item cards are used for providing relevant characteristics of items, such as their unit of measure, category, pricing, and so on.


The following fields and options exist in the **Item** section:

| Field Name      | Description |
| ----------- | ----------- |
|  **No.**   | Specifies the number which will be used for identifying the item.  |
|  **Description**  | Specifies the name/description of the item.    |
|  **Blocked**  |  If enabled, the item will not be posted in transactions.    |
|  **Type**  | Specifies what the item will be used for. The following options are available: **Inventory** - refers to physical items, such as chairs, and non-physical items, such as subscriptions; **Non-inventory** - refers to physical items that are consumed by a business internally, and that don't have to be tracked individually; **Service** - refers to billable services such as man hours.  |
|  **Base Unit of Measure** | Specifies in which units the items will be measured (e.g. pieces).   |
|  **Item Category Code**  |  Specifies the code of the category the item belongs to. All attributes assigned to items will also be included in the same category.  |

The following fields and options exist in the **Inventory** section if the item is of the **Inventory** type:

| Field Name      | Description |
| ----------- | ----------- |
|  **Shelf No.**   | Specifies the fixed location in which the item can be found in the warehouse. Normally used if you don't use BIN codes in your warehouse setup. |
|  **Inventory**  | Specifies how many units are currently located in the inventory.  |
|  **Qty. on Purch. Order**  |  Specifies how many units of the item are inbound on purchase orders.    |
|  **Qty. on Prod. Order**  | Specifies how many units of the item are allocated to production orders.   |
|  **Qty. on Component Lines** | Specifies how many item units are allocated as production order components.   |
|  **Qty. on Sales. Order**  |  Specifies how many item units are allocated to sales orders.  |
|  **Stockout Warning**   | Specifies whether a warning will be displayed  when you enter a quantity on the sales document that brings the inventory level down to zero. |
|  **Unit Volume**  | Specifies the volume of the item unit, if there is any.   |
|  **Over-Receipt Code**  |  Specifies the policy which will be applied to the item if more items than ordered are received.   |


The following fields and options exist in the **Costs & Posting** section: 

| Field Name      | Description |
| ----------- | ----------- |
|  **Costing Method**   | Specifies which costing method is used to calculate the item price. |
|  **Standard Cost**  | Specifies the unit cost that is used as an estimation to be adjusted with variants later. It is typically used in assembly and production where costs can vary.   |
|  **Unit Cost**  |  Specifies the cost of a single unit of the item or a resource on a line.    |
|  **Net Invoiced Qty.**  | Specifies how many units of the item in the inventory have been invoiced.  |
|  **Cost is Adjusted** | Specifies whether the item's unit cost has been adjusted, either automatically or manually.  |
|  **Purchase Prices & Discounts** |  Specifies if any purchase prices and line discounts have been applied to the item.  |
|  **Gen. Prod. Posting Group**   | Specifies the item's product type to link transactions made from this item with the appropriate General Ledger account according to the **General Posting Setup**.   |
|  **Tax Group Code**  | Specifies the tax group that is used for calculating and posting the sales tax.   |
|  **Inventory Posting Group**  |  Specifies the policy which will be used for the item if more items than ordered are received.   |
|  **Default Deferral Template** |  Specifies how revenue or expenses related to the item are deferred to other accounting periods by default.  |
|  **Tariff No.**   |  Specifies the code of the item's tariff number.  |

The following fields and options are available in the **Prices & Sales** section:

| Field Name      | Description |
| ----------- | ----------- |
|  **Unit Price**   | Specifies the price of one unit of an item or a resource. You can provide the price manually or have it entered according to the **Price/Profit Calculation** field on the relevant card. |
|  **Profit %**  | Specifies the profit margin that you want to sell the item at. You can enter a profit percentage manually or have it entered according to the **Price/Profit Calculation** field on the relevant card. |
|  **Sales Prices & Discounts**  |  Specifies sales prices and line discounts for the item.    |
|  **Sales Unit of Measure**  | Specifies the unit of measure code that is used when you sell the item.   |
|  **Sales Blocked** | If enabled, the item can't be entered on sales documents, except return orders, credit memos, and journals.   |
|  **VAT Bus. Posting Gr. (Price)**  |  Specifies the VAT business posting group for customers for whom you want the sales price including the VAT to apply.  |

The following fields and options are available in the **Replenishment** section:

| Field Name      | Description |
| ----------- | ----------- |
|  **Replenishment System**   | Specifies the type of supply order created by the planning system when the item needs to be replenished.  |
|  **Lead Time Calculation**  | Specifies the date formula for the amount of time it takes to replenish the item.    |
|  **Vendor No.**  |   Specifies the number used to identify the vendor.   |
|  **Vendor Item No.**  | Specifies the number that the vendor uses for this item.   |
|  **Purch. Unit of Measure** | Specifies whether the item's unit cost has been adjusted, either automatically or manually.  |
|  **Purchasing Blocked** |  Specifies if any purchase prices and line discounts have been applied to the item.  |
|  **Manufacturing Policy**   | Specifies whether additional orders for any related components are calculated or not.   |
|  **Routing No.**  | Specifies the number of the production routing that the item is used in.  |
|  **Production BOM No.**  |  Specifies the number of the production BOM that the item represents.  |
|  **Rounding Precision** |   Specifies how the calculated consumption quantities are rounded when entered on the consumption journal lines. |
|  **Flushing Method**   |  Specifies how the consumption of the item is calculated and handled in production processes. The following options are available: **Manual** - enter and post the consumption in the consumption journal manually; **Forward** - automatically posts consumption according to the production order component lines when the first operation starts; **Backward** - automatically calculates and posts consumption according to the production order component lines when the production order is finished; **Pick + Forward**/**Pick + Backward** - variations with warehousing. |
|  **Scrap %**   |  Specifies the percentage of the item that you expect to be scrapped in the production process. |
|  **Lot Size**  | Specifies the default number of units of the item that are processed in one production operation.   |
|  **Assembly Policy**  |  Specifies which default order flow is used to supply this assembly items.   |
|  **Assembly BOM** |  Specifies whether the item is an assembly BOM.  |

The following fields and options are available in the **Planning** section: 

| Field Name      | Description |
| ----------- | ----------- |
|  **Reordering Policy**   | Specifies the reordering policy in use. The following options are available: **Fixed Reorder Qty.** - The order quantity is equal to the reorder quantity (at a minimum), but can be increased if needed; **Maximum Qty.** - The order quantity is calculated to meet the maximum inventory; **Order** - The order quantity is calculated to meet each individual demand event, and the demand-supply set remains linked until execution; **Lot-for-Lot** - The quantity is calculated to meet the sum of the demand that comes due in the time bucket.|
|  **Order Tracking Policy**  |  Specifies if and how the order tracking entries are created and maintained between the supply, and its corresponding demand.  |
|  **Stockkeeping Unit Exists**  |   Specifies whether there's a stockkeeping unit tied to this item.   |
|  **Critical**  |  Specifies if the item is included in availability calculations to predict a shipment date for its parent item. |
|  **Safety Lead Time** |  Specifies a date formula to indicate a safety lead time that can be used as a buffer period for item production, and other delays. |
|  **Safety Stock Quantity** | Specifies the stock quantity that should always be in the inventory, to protect against supply-and-demand fluctuations during the replenishment lead time.   |
|  **Include Inventory**   |  If enabled, the inventory quantity is included in the projected available balance when the replenishment orders are calculated.  |
|  **Lot Accumulation Period**  |  Specifies a period in which multiple demands are accumulated into one supply order when you select the **Lot-for-Lot** option in **Reordering Policy**  |
|  **Rescheduling Period**  | Specifies a period within which any suggestion to change a supply date always consists of the **Reschedule** action, and never the **Cancel + New** action.  |
|  **Reorder Point** |  Specifies the minimum quantity of a single item that can be in stock. When it is reached, an action for replenishing that inventory stock is triggered. |
|  **Reorder Quantity**   |  Specifies a standard lot size quantity to be used for all order proposals.   |
|  **Maximum Inventory**  |  Specifies the maximum inventory level allowed.  |
|  **Minimum Order Quantity**  |  Specifies a minimum allowed quantity for an item order proposal.   |
|  **Maximum Order Quantity**   |  Specifies a maximum allowed quantity for an item order proposal.   |
|  **Order Multiple**  |  Specifies a parameter used by the planning system to modify the quantity of the planned supply orders.   |


The following fields and options are available in the **Item Tracking** section: 

| Field Name      | Description |
| ----------- | ----------- |
|  **Item Tracking Code**   |  Specifies how the serial or lot numbers assigned to an item are tracked in the supply chain.   |
|  **Serial Nos.**  |  Specifies a number series code to assign consecutive serial numbers to items produced.  |
|  **Lot Nos.**  |   Specifies the number series code that will be used when assigning lot numbers.  |
|  **Expiration Calculation**  |   Specifies the date formula which calculates the expiration date on the item tracking line. This field will be ignored if the involved item has **Required Expiration Date Entry** set to **Yes** on the **Item Tracking Code** page.   |


The following fields and options are available in the **Warehouse** section: 


| Field Name      | Description |
| ----------- | ----------- |
|  **Warehouse Class Code**   |  Specifies the warehouse class code that the item belongs to, to help control and track storage of different item classes (e.g. frozen goods).  |
|  **Put-away Template Code**  |  Specifies the code of the put-away template by which the program determines the most appropriate zone and bin for storage of the item after receipt.   |
|  **Put-away Unit of Measure Code**  |   Specifies the code of the item unit of measure in which the program will put the item away.   |
|  **Phys. Invt. Counting Period Code**  | Specifies the code of the counting period that indicates how often you want to count the item in a physical inventory.    |
|  **Last Phys. Invt. Date** |  Specifies the date on which you last posted the results of a physical inventory for the item to the Item Ledger.  |
|  **Last Counting Period Update** | Specifies the last date on which you calculated the counting period. It is updated when you use the **Calculate Counting Period** action.   |
|  **Next Counting Start Date**   |  Specifies the starting date of the next counting period.   |
|  **Next Counting End Date**  |  Specifies the end date of the next counting period.   |