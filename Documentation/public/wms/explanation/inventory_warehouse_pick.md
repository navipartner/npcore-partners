# Inventory and warehouse picks

Inventory pick and warehouse pick represent outbound stock-related processes that are employed when the stock is sent away from the warehouse to the buyer.

The processes associated with outbound warehouse movements are: Sales Orders, Transfer Orders, and Purchase Returns.

## Inventory pick

Inventory pick is used for specifying the instructions that warehouse workers are going to follow to pick up items for shipment or from assembly which precedes shipment.

Inventory picks can be created and posted directly from a sales order, and each sales order can be associated with only one inventory pick. Until you release the sales order, you can change options such as quantity and the bin codes manually. 

## Warehouse pick

Warehouse pick is always created in relation to warehouse shipments, either directly from the shipment, or from the journal. You can have multiple source documents for one warehouse pick, so it's possible to have one or more warehouse shipments going into one warehouse pick. 

> [!Note]
>If your company deals with multiple orders and shipments, warehouse pick is a better option than inventory pick, since it's more stable from a technical standpoint.

### Related links

- [Inventory adjustments](inventory_adjustments.md)
- [Warehouse and inventory putaway](warehouse_putaway.md)