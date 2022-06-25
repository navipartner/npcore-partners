# Mixed discount

A mixed discount is triggered when a certain combination of items is selected in the transaction. This may be a specific combination of items (in a line) or multiple series of assorted items. 

To set up mixed discount setup, navigate to the **Mixed Discount List**.

The following options are available in the **General** section:

| Field Name      | Description |
| ----------- | ----------- |
| **Code**       | The unique code for the mix discount scheme.  |
| **Description**   | The short description of the mix discount scheme.  |
| **Mix Type**  | Specifies the type of mixed discount you wish to create. You can choose between **Standard** (creates a **Standard Mixed Discount** card where the items which are going to receive the discount are added in the **Mixed Discount Lines** section) and **Combination** (the user needs to create **Part Cards** in the **Mixed Discount Lines**). |
| **Lot** | Enable the discount scheme only if the specific combination of item and item quantity is respected. If disabled, the sales ticket can contain any combination of items provided the **Min. Quantity** is respected, to benefit from the discount scheme. |
| **Min. Quantity** | Specifies the starting limit for which the customer will benefit from the discount scheme when purchasing that amount of products (If the minimum quantity is set to *2*, the minimum of two items from the **Mix Discount Lines** needs to be bought so that the discount scheme is applied.).  |
| **Max Quantity** | Specifies the limit in terms of quantity that a customer can purchase under the specific mix discount scheme (If the maximum quantity is set to *9* for an item, when the customer purchases ten of these items, the discount will be applied to nine of them, while one will be purchased at its full price.). |
| **Discount Type** | Specifies the applied discount type. |
| **Min. Discount Amount** | Specifies the minimum discount amount which will be calculated and offered to the customer when buying the minimum quantity allowed. |
| **Max. Discount Amount** | Specifies the maximum discount amount which will be offered to the customer when buying the maximum quantity allowed. |
| **Created Date** | Specifies the date on which the mix discount scheme was created. |
| **Last Date Modified** | Specifies the date on which the mix discount scheme was modified. |
| **Block Custom Discount** | Block the mix discount (the discounts from the setup will not be allocated anymore). |
| **Status** | Specifies whether the discount will be allocated to sales. |
| **Sold Qty.** | Specifies the quantity of items sold under this discount scheme. | 
| **Turnover** | Specifies the turnover generated from this discount scheme. |

The following options are available in the **Conditions** section: 

| Field Name      | Description |
| ----------- | ----------- |
| **Start Date**  | Specifies the date on which the discount takes effect. |
| **End Date**   | Specifies the date on which the discount expires. |
| **Start Time**  | Specifies the time at which the discount starts taking effect. |
| **End Time** | Specifies the time at which the discount expires. |
| **Customer Disc. Group Filter** | Specifies the link between the Customer Disc. Group and the Register. You should assign the Customer Disc. Group to the Register first, and then select the same Customer Disc. Group on the Mixed Discount. For example, when you assign the Customer Disc. Group *VIP* to the *Register 1*, and set up the Mixed Discount *MIX0020* with the same discount group, then all sales from *Register 1* will apply to the *MIX0020* scheme. |


## Discount types

The following discount types can be applied. 

- **Total Amount per Min. Qty.** 
  When this discount type is selected, the field **Total Amount** is displayed. The discount will be calculated according to the selected minimum quantity.

  *Example:*
  If you select *2* as the minimum quantity, and the total amount is *100,00*, the following rules apply:
    - The mixed discount will be triggered when a minimum quantity of 2 items from the Mix Discount lines are sold.
    - For each 2 items the total amount of the sales will be 100,00, meaning if 3 items are sold the total sales amount would be 150,00 ((100/2) x 3).
    - The difference between the unit price and the total amount will be applied as a discount to the items.


- **Total Discount %**

When this discount type is selected, the **Total Discount %** field is displayed. The total discount will be expressed in percentage. 

  *Example:*
  If you select *2* as the minimum quantity, and the **Total Discount %** to *10,00*
    - The mixed discount will be triggered when a minimum quantity of 2 items from the Mix Discount lines are sold.
    - All items from the **Mix Discount Lines** will benefit from a discount percentage of 10% if the Min. Quantity purchased is reached. This discount will apply to an unlimited quantity of an item.
    - The difference between the unit price and the total amount will be applied as a discount to the items.

- **Total Discount Amt. per Min. Qty.**

  When this discount type is selected, the field **Total Discount Amount** is displayed. The total discount will be calculated according to the selected minimum quantity.

  *Example:*
  If you select *3* as the **Min. Quantity**, *9* as the **Max. Quantity**, and *1* as the **Item Discount Quantity**:
    - The mixed discount will be triggered when a minimum quantity of 3 items from the Mix Discount lines are sold.
    - For every 3 items sold from the Mix Discount lines, 1 item from the 3 will benefit from the 10% discount. This discount will apply to every set of 3 items until a maximum quantity of 9 items is reached.


- **Priority Discount per Min. Qty.**

When this discount type is selected, the **Item Discount Quantity** field is displayed. 

  *Example:*
  If you select *3* as the **Min. Quantity**, *9* as the **Max. Quantity**, and *1* as the the **Item Discount Quantity**:
  - The mixed discount will be triggered when a minimum quantity of 3 items from the Mix Discount lines are sold.
  - For every 3 items sold from the Mix Discount lines, 1 item from the 3 will benefit from a 10% discount. This discount will be applied to every set of 3 items until a maximum quantity of 9 items is reached.

## Mix Discount Lines - Standard Mix Type

In this section, you can edit the following options:

| Field Name      | Description |
| ----------- | ----------- |
| **Disc. Grouping Type**       | Specifies according to which parameter the discounts are grouped. The available options are **Item** (when selected, you need to specify the item number you wish to give discount to), **Item Group** (choose this option if you wish to give discount to all the items from a specific item group), and **Item Disc. Group** (choose this option if you wish to assign the specific **Item Disc. Group** on which you wish to overwrite the discount).  |
| **No.**   | Depending on the selection in the **Disc. Grouping Type**, the following options are available: **Item** (when selected in **Disc. Grouping Type**, the item number needs to be specified here), **Item Group** (when **Item Group** is selected in **Disc. Grouping Type**, you need to specify the item group code that you wish to affect), **Item Disc. Group** (when **Item Disc. Group** is selected for the **Disc. Grouping Type**, you need to specify the item discount groups you wish to affect).  |
| **Variant Code**  | If there is a specific variant on which you want to apply the discount, populate this field. If you leave this field blank, all variants will be affected. |
| **Description** | Specifies the description of the item, item group or item discount group. This field is automatically populated when you select the **No.**. |
| **Description 2** | If a **Variant Code** is specified, the variant description will be displayed in the **Description 2** field. |
| **Unit Cost** | If the **Disc. Grouping Type** is **Item**, the **Unit Cost** found on the **Item Card** will be displayed here. If the **Disc. Grouping Type** is something other than an **Item**, then the unit cost will be defaulted to *0,00*.  |
| **Unit Price** | If the **Disc. Grouping Type** is **Item**, then the unit price found on the **Item Card** will be displayed here. If the **Disc. Grouping Type** is anything other than an **Item**, the unit price will be defaulted to *0,00*. |
| **Priority** | Specifies the priority assigned to a **Mixed Discount Line**. The lower the number, the higher the priority. |
| **Cross-Reference No.** | You can set the item using the **Item Cross Reference**. The item number will be set up with the corresponding value from the ICR setup.|
| **Price Includes VAT** | This field cannot be edited. It just shows the setting on the Item Card i.e. if the **Price Including VAT** has been selected on the **Item Card.** |
| **Quantity** | When **Lot** is activated, this field will be displayed. The user enters the item quantity the customer is required to buy in order for the lot to be generated. |


## Mix Discount Lines – Combination Mix Type

| Field Name      | Description |
| ----------- | ----------- |
| **Mix Discount Lines Actions**   | The available options are **New Part** (when selected, a new window which prompts users to create a combination part to use in the mixed discount is displayed. After entering the details for the combination part, the card is automatically associated with the **Mixed Discount** card.)   |
| **Part Code**   | You can either select the part code from the available options, or create a new one by using the **New** part option.  |
| **Description**  | Specifies the description of the combination part card.  |
| **Min. Qty.** | Specifies the **Min. Qty.** from the combination part card which will trigger the discount. |
| **Min. Expected Amount** | Specifies the value of the minimum amount expected as a discount based on the minimum quantity configured on the combination part card.  |
| **Max. Expected Amount** | Specifies the value of the maximum amount expected as a discount based on the maximum quantity configured on the combination part card. |

## Combination Part Card - General

| Field Name      | Description |
| ----------- | ----------- |
| **Code**   | Specifies the code of the combination part being created. This value is automatically generated, and should not be edited.  |
| **Description**   | Specifies the description of the combination part.  |
| **Lot**  | The two available options are **Unchecked** (the customer can buy any combination of the items specifies in the **Mix Discount Lines**) and **Checked** (the customer needs to buy the specific quantity of each item from the **Mix Discount Lines** to generate a lot.)  |
| **Min. Quantity** | Specifies the minimum amount on which the discount should be triggered. If you leave it at *0* the discount will be active for any item quantity. |
| **Max. Quantity** | Specifies the maximum amount on which the discount should be terminated. If it is left blank, there will be no limit on the item quantity to assign the discount.  |
| **Created Date** | Specifies the date on which the combination part card was created. This field is automatically generated. |
| **Last Date Modified** | Specifies the date of the previous instance when the combination card was modified. This field is automatically generated. |
| **Item Qty. per Lot** | When the lot is activated, the minimum and maximum quantities will be hidden, and this field will be displayed. It will contain the item quantity required for lot generation. This field is noneditable. |