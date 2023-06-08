# Pricing

Pricing is a process of adjusting the value that the shop receives in exchange for goods. There are several price types.

## Unit price

Unit Price is the price at which a single product quantity is sold. It is especially useful when items are purchased in bulks. For example, an item can be sold in kilograms. In Business Central, the simplest way to set an item’s sales price is on the **Item Card**. The unit price on the **Item Card** is the item’s price based on its unit of measure. The unit price is manually or automatically calculated based on the cost of the item and the desired markup or margin by setting the **Price/Profit Calculation** value.

## List price

The List Price is the value for which an article is sold in a retail store, through a catalogue or through a website. In Business Central, there's a **List Price** field in the **Item Card** but it isn't updated automatically or used by the system. It's a static field which gives you an idea of a recommended price.

## Unit price excl. VAT

Unit Price Excl. VAT is the Unit Price without VAT. If the Unit Price is stated and the flag inclusive of VAT is activated, the system will calculate the Unit Price with VAT and display it in that field for Unit Price Excl. VAT.

## Sales price list

You can create a selling price for a specific group of customers. Microsoft has combined different ways of affecting a price, like defining a specific price, discount or a combination of both for a group of customers. These configurations can be performed in the [**Sales Price List**](../howto/sales_price_setup.md) page.

> [!Note]
> In Business Central and NP Retail, the Sales Price takes priority on the Unit Price in the Item card. Whenever a sales order or a POS sale is done, the system will first check if an item has a Sales Price. If it does, that price will be applied, otherwise, the unit price will be applied.