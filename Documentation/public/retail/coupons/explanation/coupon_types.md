# Coupon types

Coupon type card gives possibility to create set up for coupons. Coupon type card has four sections: **General**, **Issue coupon**, **Validate coupon** and **Apply discount**.

In **General** section needs to be defined:         
- **Code** - Unique code for coupon.
- **Description** - short description of coupon.
- **Discount type** - Choose between **Discount amount** or **Discount %**
- **Discount Amount** - amount that will be on coupon.
- **Discount %** - % of discount that customer gets with coupon.
- **Max. discount Amount** - Max. amount on which discount will be calculated
- **POS store Group** - Group of stores in which coupon can be used. If it is blank, coupon can be used in all stores.
- **Coupon Qty. (Open)** - Number of open coupons
- **Arch. Coupon Qty.** - Number of archived coupons.
- **Enabled** - If coupon type is in use this field needs to be checked.

![General](../images/General%20coupon.png)

For example, coupon from above picture will give discount amount of 65 to customer and it can be used in all stores.

In **Issue coupon** section it must be defined how coupon will be issued:
- **Issue Coupon Module** - **DEFAULT** - coupon is issued manually from Business central or from POS (after button is created), **ON-SALE** - coupon is created during sale in POS, **MEMBER-LOYALTY** - coupon is created when memeber have enough points for coupon.
- **Match POS Store Group** - If there is case that coupon created ON-SALE in one store can be used just in that store, we need to assign **POS Store group** in section **general** and to check this field. In this way, coupons ON-SALE will be issued only in stores from POS Store Group assigned.
- **Reference No. Pattern** - Pattern used to create the coupon external number, which later will be scanned.
- **Customer No.** - for easier tracking of coupons for customer.
- **Print template code** - Template which will be printed for coupon.
- **Print on issue** - If this field is checked, coupon will be printed.

![issue](../images/Issue%20coupon.png)

In section **Validate Coupon** it is defined what must be validated in moment of redeeming coupon:
- **Validate Coupon Module** - **DEFAULT** - store, date, and reference number, **ITEM_LIST** - store, date, reference number and items set in Setup > Setup Validate coupon, **TIME** - store, date, reference number and time set in Setup > Setup Validate coupon.
- **Starting date** - Date from which coupon is valid.
- **Ending date** - Date until coupon is valid.
- **Starting date formula** - Setting formula from when coupon is valid.
- **Ending date Forumla** - Setting formula until when coupon is valid.

![validate](../images/Validate%20coupon.png)

In section **Apply discount** it is defined how discount will be applied.
- **Apply Discount Module** - **DEFAULT** - Will give discount according to the settings on the coupon; **ITEM_LIST** – Will give discount according to the settings set on the Item list; **EXTRA_ITEM** – Will give discount to the specific item selected to discount (Setup > Setup Apply Discount) , will also add the item to POS when coupon is scanned.
- **Max User per Sale** - Number of uses per sale.
- **Multi-Use Coupon** - If it is allowed to use coupon more than once this field must be checked.
- **Multi-Use Qty.** - How many times is allowed to use coupon.

![apply](../images/Apply%20discount.png)