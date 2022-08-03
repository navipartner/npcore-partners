# POS Payment Methods

POS payment methods are methods used in POS for creating payment lines (like cash, credit cards, etc.). Every POS payment method that is created can be set up in buttons and used for creating payments in sales.

To create new POS payment method:
1. Click the ![Lightbulb that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button and enter **POS Payment Method**. 
2. Create **New**.
3. Insert unique **Code** for payment method and **Description**.
4. Chose **Processing Type** for payment method. Options are: **Cash**, **Voucher**, **Check**, **EFT** (used for credit cards), **Foreign Voucher**, **Payout**.
5. Chose **Return Payment Method Code**. This field definse which payment method will be used for creating charge in sales transactions.
6. **Block POS Payment** allows you to block payment method so it can be used in POS.
7. If drawer needs to open when payment method is used, check field **Open drawer**.

![POS_payment_method_general](../images/General%20Payment%20methods.PNG)

8. For every payment method needs to be set up if that method will be counted in End of day process. This is set in field **Include in Counting**. Options are: **Yes**, **Yes - blind** (difference between Yes and Yes - blind is that in first case while counting you will have shown column with system amount and in second case there will not be shown this column), **Virtual**, **No**. Practice is that instead of **No** is used **Virtual** so system will create virtual counting. If **Virtual** is chosen, in field **Bin for Virutal Counting** should be selected bin that wil be used for this counting.
9. If this payment method is using different currency then local, in field **Currency Code** is should be assigned currency and in field **Fixed Rate** rate for the currency.
10. If there is need to posted entries be compressed then field **Post Condensed** should be checked.
11. **Zero as Default** should be checked if users want that zero be the amount that will popup when they chose this payment method.
12. If user wants that sale ends after payment is done with this payment method, **Auto End Sale** should be checked.
13. If there is need to be created some limit on Minimum Amount on web orders so this payment method can be used, field **No Min Amount on Web orders** should be used.

![other_payment](../images/Other%20-%20payment.PNG)

14. In payment methods also needs to be set up Rounding. There is **Rounding Precision**, **Rounding Type** and **Rounding Gains/Losses Accounts** which has to be set up.

![rounding](../images/Rounding%20payment.PNG)

15. If refund is allowed, **Allow Refund** should be checked.
16. **Min Amount** and **Max Amount** can be used if payment method has a limit for minimal and maximal amount.

![options](../images/options%20payment.PNG)