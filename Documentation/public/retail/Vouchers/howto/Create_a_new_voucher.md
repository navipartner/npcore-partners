# Create a new voucher

After the [voucher type](../explanation/Voucher_types.md) is created, the voucher needs to be sold.

1. Buttons for issuing vouchers should be created in the POS, so that the voucher can be sold. The button must have **Action – ISSUE_VOUCHER** set. 
   The parameters set on this button determine which voucher will be created with which amount, and how much the customer will pay for it.

![parameters](../images/parameters.png)

- **Amount** - when button is used, if amount is entered, voucher will be created with this value.
- **ContactInfo** - If the voucher needs to contain contact information select True. In this way, at the time of creating voucher in the POS a window will appear in which contact information can be entered.
- **DiscountAmount** - Amount entered means that customer will pay voucher less then it is worth for this discount amount.
- **DiscountType** - Amount, Percent, None.
- **Quantity** - when button is used, if quantity is entered, it will be created this number of vouchers.
- **ScanReferenceNos** - False.
- **VoucherTypeCode** - Choose which voucher type will be created when button is used.

> [!Note]
> If information about the voucher type, quantity, amount, discount isn't entered in parameters, when choosing button with the **Issue voucher** action, a window displays prompting you to provide this information.

2. After the button has been created, select that button and the line with a voucher will be added in the sales lines.

![saleslines](../images/Sale%20line.png)

3. Go to payment and end sale.   
   After the sale is finalized, you will see a new voucher created in the **Retail vouchers** list.

![Vouchers](../images/List_vouchers.png)

## Related links:

- [Voucher types](../explanation/Voucher_types.md)
- [Coupons](../../coupons/intro.md)