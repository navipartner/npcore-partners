# Item add-ons (reference guide)

In the **Item AddOns** administrative section, you can define how the associated action will behave in the POS. 

The following options and fields are available:


| Field Name      | Description |
| ----------- | ----------- |
| **No.** | Specifies the reference number for the item add-on. |
| **Enabled** | If enabled, the Item AddOns feature is activated in the POS. |
| **Description** | Specifies additional information about the item add-ons. This information can be in a form of a menu or an accessory attached to the main item. |
| **Comment POS Info Code** | This field is optional. If the business needs to add a comment when using the item add-ons, you can add a pop-up window in which users can add a comment. This comment will be added to **POS Info POS Entry** section which can be navigated to from the **Related** dropdown of the relevant **POS Entry Card**. |
| **Lines** | Lines are used for defining the items that will be added to the **POS Sales Line**. |
| **Type** | You can choose between **Quantity** (the selected item will be treated like a straight line item) and **Select** (you can define a list of options that a salesperson can choose from) |
| **Item No.** | You can define which items the item add-ons will consist of. |
| **Variant Code** | It's possible to use a specific variant for the listed item, if the code is provided in this field. |
| **Description** | Specifies the description that will be inserted in the **POS Sales Line**. |
| **Description 2** | Specifies additional description that will be inserted in the **POS Sales Line** | 
| **Quantity** | Specifies the item add-on quantity that is associated with the main item. For example, if you add **2**, when one main item is sold, two item addons will be added on the **POS Sales Line**. | 
| **Per Unit** | If activated, quantity needs to be set on the addons per unit of the main item. Following up on the previous example, if you add two main items, the quantity of addons will be automatically increased to **4**. |
| **Fixed Quantity** | If activated, the salesperson will not be able to change the quantity of the item addon manually. |
| **Mandatory** | If set as mandatory, it means that when the main item is added to the cart, the item addon is inserted automatically, and it can't be removed from the sales line. | 
| **Unit Price** | The item unit price will be set by default from the **Item Card**. The price can be modified if required. It is this unit price that can be inserted in the **POS Sales Line**. |
| **Use Unit Price** | The following options are available: **Always** - whatever price is on the Item AddOn line, the system will use it to override the price on the sales line; **Non-Zero** - the price which is higher than zero on the add-on line will override the price on the sales line. Hence, if the price is zero in the add-on line, it will not be copied. | 
| **Discount** | You can add a line discount on the item that forms the part of the menu. |
| **Comment Enabled** | You can control whether it's possible to insert comments on the POS info line or not. This control works on line level. |
| **Before Insert Setup** | You can define different workflows to be executed when selecting an item. For example, you can calculate a value based on a percentage of the unit price of the item defined as the main item for that item add-on. | 
| **Copy Serial No.** | If activated, the serial number of the main line is copied onto the item add-on lines. | 

### Related links

- [Item add-ons](../explanation/item_addons.md)
- [Set up item add-ons](../howto/item_addons_procedure.md)