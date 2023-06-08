# Set up sales price 

You can define prices for specific items in the **Sales Price List** in which Microsoft has combined the Price functions with the Discount function. Let’s start with an example of Price, hence in the price list, the price is different from the Unit Price.

To access the Sales Price List, there are a few ways to do it: 

1. Click the ![Lightbulb that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **Sales Price List**, and choose the related link. 
2. From **Item Card** access the **Sales Price** via **Special Sales Prices & Discount** in the ribbon.      
   On an item level, you will get a line or a list if that item is already in a Sales Price of some sort. Otherwise, you will need to create a new list by selecting the **Sales Price List**.
3. Click **Sales Prices & Discount** in the **Item Card** to access the **Sales Price** card.      
   Populate the following fields:

| Field Name      | Description |
| ----------- | ----------- |
| **Code**  | Provide a code that is used for the price identification. | 
| **Wholesales** | Provide a description for the sales price scheme. |
| **Assign-to Type** | Assign the pricing to a group or a specific person. You can choose between **All Customers**, a specific **Customer**, **Customer Price Group**, a sales **Campaign**, a specific **Contact**. |
| **Assign-to No.** | Specify the entity to which the prices are assigned. The options depend on the selection in the **Assign-to Type** field. If you choose an entity, the price list will be used only for that entity. |
| **VAT Bus. Posting Gr. (Price)** | Specifies the default VAT business posting group code. |
| **Price Includes VAT** | Specifies the if prices used in this scheme include VAT. |
| **View Columns for** | Specify what kind of columns you will have in the detail section. |
| **Status** | Specifies whether the price list is in **Draft** (can be edited), **Inactive** (cannot be edited or used), or **Active** status (used for price calculations). |
| **Currency Code** | Specifies the currency code of the price list. |
| **Starting/Ending Dates** | Specifies the period during which the price list is active. |
| **Line Defaults** | If flagged, all of the following actions are allowed in the detail lines. **Allow Updating Defaults** - Specifies whether users can change the values in the fields on the price list lines that contain default values from the header. This does not affect the ability to allow line or invoice discounts; **Allow Invoice Disc.** - Specifies whether invoice discount is allowed. You can change this value on the lines; **Allow Line Disc.** - Specifies whether line discounts are allowed. You can change this value on the lines. |

4. Define the details of the scheme in the **Lines** section.       
   
   ![sales_price_list_1](../images/sales_price_list_1.PNG)

### Example

In the provided screenshot all customers that benefit from a Customer Price Group = WHOLESALE, will pay for the item 70004 at a beneficial price of 1,200.00 per unit instead of the normal unit price of 1,500.00 within the period starting from 1st March and ending 31st May 23, inclusively. 

## Next steps

### Apply item discount

Item discount is applied in much the same way as described in the main procedure above, the only difference being that instead of defining unit prices, you can define the discount.

In the following example, you're assigning a discount percentage that all customers will benefit from. If 5 x items with Item Discount Group = A are sold, the customer will benefit from 15% discount on the 5 items. 

You can also set a “Wild Card” whereby you include all Items in the scheme. In the last line, the Product Type = Item & The Product No = BLANK. This is a function in Business Central that permits you to give a 3 % on all items to all customers.

![sales_price_2](../images/sales_price_2.PNG)

### Combine sales price with item discount

In this example, you can see that different sales price, item discounts or even a combination of both can be set in the system in one price list. 
Both pricing and discount setup can be performed in one page instead of having to navigate to each Item card to set up pricing and apply discounts individually. 

![sales_price_3](../images/sales_price_3.PNG)