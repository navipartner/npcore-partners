# Mix Discounts

Mix discounts is type of discounts where customers must buy more different item if they want to get discount. Discount is triggered when a certain combination of items is selected in POS transaction. 

To set up mix discounts, follow the provided steps:
1. Click the ![Lightbulb that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **Mix discount** and choose the related link. Mix discount list will be opened.
2. To create a new mix discount, chose **New** from Action ribon and Mix discount card will open.
3. Insert the necessary information in the **General** tab:

![mix_discoutns_general](../images/Mix%20discount%20general.PNG)
- **Code** - The unique code for a mix discount.
- **Description** - The short description of a mix discount.
- **Mix Type** - Type of mix discout that should be created. Options: **Standard** - the items which are going to receive the discount are added in the Mixed Discounte Lines; **Combination** - combination of mixed discounts where in mixed discount lines should be created part cards. Part cards contain items which need to be setup for discount.
- **Lot** - When the Lot field is not checked, the sales ticket can contain any combination of item provided the Min. Quantity is respected to benefit from the discount scheme. When the Lot field is checked, the specific combination of item and item quantity needs to be respected to benefit from the discount scheme.
- **Min. Quantity** - Minimum of items from mix discount lines customer has to purchase so it can benefit from mix discount.
- **Max Quantity** - The maximum quanitity that customer can purchase under the specific mix discount.
- **Status** - After all the necessary data for mix discount is inserted, the status of the mix discount needs to be changed to **Active**. If there is need to disable the mix discount, the status has to be changed to **Closed**
- **Discount type** - Options: **Total Amount per Min. Qty.**, **Total Discount %**, **Total Discount Amt. per Min. Qty.**, **Priority Discount per Min. Qty.** and **Multiple Discount Levels**. These different types will be explaned later.
- **Min. Discount Amount** - The Minimum Discount Amount which will be calculated and given to the customer upon buying the minimum quantity allowed.
- **Max. Discount Amount** - The Maximum Discount Amount which will be calculated and given to the customer upon buying the maximum quantity allowed.
- **Block Custom Discount** - If enabled, the custom discounts will be blocked for items from mix discount lines.
- **Total Amount Excl. VAT** - If not enabled, amount from mix discounts are taken without VAT.

4. Insert the necessary information in the **Conditions** tab:

![mix_discount_conditions](../images/Mix%20discount%20conditions.PNG)
- **Start date** - The date on which the mix discount will become active. 
- **End date** - The date until which the mix discount will be active.
- **Customer Disc. Group Filter** - If mix discount is active only for certain customers, you should select their customer discount group in this field.

5. Insert the necessary information in the **Active Time Intervals** tab:

![mix_discount_active_time](../images/Mix%20discount%20active%20time.PNG)

- **Start time** - The time of day from which mix discount will become active.
- **End time** - The time of day until which mix discount will be active.
- **Period Type** - The period in a week during which the period discount is active. You can choose between: **Every day** (mix discount is active every day); **Weekly** (it will be possible to chose a day of the week when mix discount will be active).

6. Insert the necessary information in the **Mix Discount Lines**:

![mix_discount_lines](../images/Mix%20discount%20lines.PNG)

- **Disc. Grouping Type** - Options available: **Item** - then in field **No.** you have to chose item No. you wish to give discount to, **Item Group** - if you wish to give discount to all the items from a specific item group, then you select this option, **Item discount group** - you can assign specific Item Disc. Group on which you wish to overwrite the discount.
- **No.** - The field be populated with information depending on what is selected as Dis. Grouping Type.
**Variant Code** - Enter the Variant Code of the item is there is any specific Variant on which you want the discount to apply. If you leave this value blank, then all the variants will be affected.
- **Description** - Description of item, item group, item discount group.
- **Description 2** - Description of variant.
- **Unit Cost** - If item is inserted the unit cost will be taken from item card.
- **Unit price** - If item is inserted the unit price will be taken from item card.
- **Priority** - Priority which you wish to assign to a Mixed discount line. For example if we have two lines with priorities 1 and 2, Min and Max quantity are 2 and we bought 4 items (two from first and two from second line), only item with priority 1 will get discount.
- **Quantity** - When Lot is activated, this field will be enabled and will appear. The user enters the quantity of the item the customer MUST buy to generate a lot.

### Discount types

There are five discount types that can be chosen on Mixed discount card.

1. **Total amount per Min. Qty.** - is used to define total amount that will be paid for minimum quatity.

![Total_amount_per_min_qty](../images/Total%20amount%20per%20min%20qty.PNG)

In above example, if customer gets 5 items total amount that will pay for those is 1.500. If customer buys 6 items it will pay (1500/5)*6=1800. Difference between the unit price and total amount will be applied as a discount to the items.

2. **Total Discount %** - is used to define discount percentage that will be used to calculate discount if customer bought minimum quatity. When this type is selected field **Total discount %** will appear. 

![total_discount_percentage](../images/Total%20discount.PNG)

In above example, if customer gets 5 items it will get 10% discount on all items which are in mix discount lines. This discount will apply to an unlimited quantity of item. Difference between the unit price and total amount will be applied as a discount to the items.

3. **Total Discount Amt. per Min Qty.** - is used to define total discount amount that will be assigned to sale if customer purchase minimum quatity.

![total_amount_discount](../images/Total%20amount%20discount.PNG)

In above example, if customer gets 5 items total discount amount wil be 100.  If customer buys 6 items it will get discount (100/5)*6=120. The Discount % will be automatically calculated.

4. **Priority Discount per Min. Qty.** - When this discount type is selected, the field "Item Discount Quantity" will appear.

![priority_discount](../images/Priority%20discount.PNG)

In above example, if customer gets 5 items it will get 10% discount on two items.  This discount will apply to every set of 5 items until a maximum quantity is reached.

5. **Multiple discount Levels** - this type of discount is used if there is need to set up different discount percentages for different quantities.

![multiple_discount_levels](../images/multiple%20discount%20levels.PNG)

When this type of discount is chosen, new tab **Mix discount levels** will appear where user can set up discount percentages for different quantities..

![mix_discount_level](../images/mix%20discount%20levels.PNG)

In above example, if customer buys 5 items it will get 5% discount on items from mix discount lines, but if buys 15 items, it will get 10% discount.

### Combination Mix Type

If in **Mix type** on **General** tab is chosen **Combination** then in Mix discount lines we have mix discount lines Actions **New part** and **Part card**.

![part_new](../images/Part%20new.PNG)

When a user select **New Part** system will open a new window to prompt the user to create a combination part to use in the mixed discount. After entering the details for the combination part, the card will be automatically associated with the Mixed Discount card. When a combination part card has been created, it can be accessed again when a user select the combination part on the Mix Discount Lines and select the **Part Card**. This will open the combination part card so that it can be either reviewed or edited.

In Mix discount lines for this type of mix information you can see are:

- **Part code** - The reference to the combination part card already created in the system. You can either select from the list or create a new one using the "New Part" function.
- **Description** - The description from the combination part card.
- **Min Qty.** - The Min. Qty. from the combination part card which will trigger the discount.
- **Min expected amount** - This is calculated as the minimum amount which will be expected as discount based on the minimum quantity configured on the combination part card.
- **Max. Expected Amount** - This is calculated as the maximum amount which will be expected as discount based on the maximum quantity configured on the combination part card.

Combination Part card contains fields where you need to setup items and quantites similar to Standard mix discount.
![part_card](../images/Part%20card.PNG)