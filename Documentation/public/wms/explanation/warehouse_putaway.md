# Warehouse and inventory putaways

Inventory and warehouse putaways represent inbound stock-related processes used when the stock is increased, and needs to be allocated accordingly. All items received in the warehouse are either subjected to the inventory or warehouse putaway.

Purchase orders, sales return orders, and receipts of transfer orders can serve as source documents for both inventory and warehouse putaways. After the supply is received, and the necessary quality checks performed, you can start putting away the items into their designated spaces/bins (if bins are enabled in the location). 

## Warehouse putaway

Warehouse putaways entail all processes that occur after a supply of goods from a vendor is received, but before it is stored away in the warehouse. They are by default created from warehouse receipts. The flow typically goes as follows: items are received using warehouse receipts, and when warehouse receipts are posted, a putaway is automatically created. Warehouse putaways can have more than one source document and two lines per an item or a purchase line.

> [!Note]
> This putaway method is more stable, and it helps reduce the movement through the facility, reducing the average pick cost per order. 

## Inventory putaway

Inventory putaways are by default created from source documents (purchase orders, sales return orders or transfer orders) via the **Create Inventory Put-away/Pick** action.

Like the warehouse putaway, inventory putaway relates to processes of receiving and allocating the stock to the adequate storage spaces. There is a one-to-one relation between inventory putaways and the source documents related to them.
