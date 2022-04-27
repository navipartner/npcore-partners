# Retail vouchers

A retail voucher is a document that customers can use to purchase goods or services. As such, it can take the form of a paper, electronic voucher, token, and so on. It is widely used in the Retail & Service industries. The most common example are gift and credit voucher, but there are also meal, travel, and labor voucher types, among many others. 

In NP Retail, there is the **Retail Vouchers Module** administrative section, which can be used for defining different types of retail vouchers with their own conditions.

The retail vouchers combine two different code units that are made to issue, validate or redeem in a certain way.

## Voucher module types

The following default vouchers currently exist in the system:

- **Send Voucher** - used to define the logic for issuing the voucher (by default set to **printed**).
- **Validate Voucher** - used for checking the validity of the voucher within a valid date period defined; if the **Valid Period** is left blank, the validity duration will be indefinite.
- **Apply Discount** - used for giving the discount according to the settings on the voucher.
- **Apply Payment - default** - the redeemed voucher will be fully applied when used.

> [!Note]
> If the sale value is lower than the voucher value, a voucher is automatically issued to breach the difference.

- **Apply Payment - partial** - the redeemed voucher can be applied in part until the outstanding amount is fully cleared.
