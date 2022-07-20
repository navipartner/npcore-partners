# Inventory costing methods

Inventory management is a very important function for all product-oriented businesses. The costing method you chose can greatly impact the businesses' logistics, profitability, and income, so it's recommended to research how each of these can be used to maximize your profits. If you order a different quantity of items in several occasions, their prices may differ. Different costing methods can cater to different business use cases in which you will be required to assign the unit cost differently. 

> [!Note]
> As soon as you choose the costing method you wish to use, it will be applied to items automatically, so there will be no need for you to calculate anything.

## FIFO

The FIFO (first in, first out) inventory costing method entails selling the products ordered in the first batch first before selling the others. In this way, the price at which the first batch of items was purchased is taken into account until the entirety of the oldest order batch has been emptied out. By employing this method businesses are at a smaller risk of losing money when products expire or become obsolete.

> [!Tip]
> The cost of the oldest inventory is multiplied by the number of inventory items sold. 


## LIFO

For the LIFO (last in, first out) inventory valuation method, the current prices are used to calculate the price of sold goods. It's best to apply this method for calculating prices of the non-perishable goods. Under LIFO, it's expected to sell the newest inventory first (the last purchased batch).

> [!Tip]
> The cost of the most recent inventory is multiplied by the amount of inventory sold.

## Standard

In the standard costing method, regardless of the item stock purchase cost and item quantity, the fixed standard cost will be used for all items. Due to the standard cost being fixed, the profit margin stays the same. 

> [!Tip]
> The **Standard Cost** is defined in the **Cost & Posting** section of the **Item Card**.

When an adjustment entry is added to the **Item Journal** for a transaction which includes a standard cost, an error will be displayed if the **Unit Amount** contains a value that doesn't correspond to what you've defined in the **Item Card** for the **Standard Cost** of the item.

## Average

By default, the average costing method determines the inventory item cost based on the total cost of purchased goods, divided by the total number of items purchased. It requires setting up the period over which the average item price will be calculated as well as the average cost calculation type in the **Inventory Setup**. 

The **Average Cost Calculation Type** specifies how costs are calculated. 

| Average Cost Calculation Type Option      | Description |
| ----------- | ----------- |
| **Item**       | One average cost per item in the company is calculated for all locations.    |
| **Item & Location & Variant**   | An average cost per item for each location and variant of an item in the company is calcualted. The average cost of this item depends on where it's stored, and which variant is selected.       |

The **Average Cost Period** field determines the period over which a single average cost is calculated according to the quantity and value of all ins. The available options are **Day**, **Week**, **Month**, and **Accounting Period**.

You can view the detailed **Average Cost Calculation Overview** by clicking the **Unit Cost** value in the **Item Card** of your choice.

> [!Important]
> If **FIFO** or **Average** costing methods are applied, the **Adjust Cost - Item Entries** report needs to be run. It is used for recalculating the unit cost after one of these costing methods are applied. To make sure all costs are up-to-date, it's recommended to schedule a recurring job which will adjust all modified cost each time it is automatically run. Jobs can be scheduled in the **Job Queue Entries** administrative section or from the **Automatic Cost Adjustment** field in **Inventory Setup**.

## Specific

To apply the specific costing method, you first need to specify the **Item Tracking Code** (related to the serial number tracking). In this costing method, the price will always be tied to a specific item serial number. In other words, each item that is costed with the **Specific** method may have its unique price determined by its unique ID. 

> [!Tip]
> The **Item Tracking Code** is defined in the **Item Tracking** section of the **Item Card**.

### Related links

- [Inventory and warehouse picks](inventory_warehouse_pick.md)
- [Inventory and warehouse putaways](warehouse_putaway.md)
- [Inventory adjustments](inventory_adjustments.md)