# Inventory and warehouse picks

Inventory and warehouse picks entail the processes of picking items before they are shipped.

> [!Note]
> To perform inventory and warehouse picks, you first need to have warehouse and CS users specified in the environment.

## Inventory pick

Inventory picks are used in regards to locations which require pick processing, but not shipment processing. In the **Inventory Pick** page you can post the information necessary for performing picks and shipment. This information is placed in relevant outbound source documents, such as transfer orders, purchase return orders, and production orders.

Inventory pick is used for specifying the instructions that need to be followed to pick up items for shipment or from assembly.

Inventory picks can be created and posted directly from a sales order, and each sales order can be associated with only one inventory pick. Until you release the sales order, you can change options such as quantity and the bin codes manually. 

In general, inventory picks can be [created](../howto/create_inventory_pick.md) by releasing the source document, thus requesting an inventory pick.

## Warehouse pick

Warehouse pick is always created in relation to warehouse shipments, either directly from the shipment, or from the journal. You can have multiple source documents for one warehouse pick, so it's possible to have one or more warehouse shipments going into one warehouse pick. 

If the location is set up require warehouse pick processing and warehouse shipment processing, you can use the warehouse pick documents to create and process pick information before you post the warehouse shipment. 

> [!Note]
>If your company deals with multiple orders and shipments, warehouse pick is a better option than inventory pick, since it's more stable from a technical standpoint.

### Related links

- [Inventory adjustments](inventory_adjustments.md)
- [Warehouse and inventory putaway](warehouse_putaway.md)
- [Create inventory picks](../howto/create_inventory_pick.md)