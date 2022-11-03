# HC payment types (reference guide)

If you navigate to the **HC Payment Types** administrative sections, the following options will be available to fill in:

| Field Name      | Description |
| ----------- | ----------- |
| **No.**  | Specifies the ID of the payment type. |
| **Description**  | Specifies additional information about the payment type, such as its name. |
| **Account Type** | Enable the interface between the payment type and the account types, and set how it will be treated in the accounts. The payment the accounts in the following ways: **G/L Account** - all transactions using this account type will be posted directly to a G/L account; **Customer** - all transactions using this account type will be posted to the sub-ledger **Customer**, and transferred to the G/L account with the **Customer Posting Group**; **Bank** - all transactions using this account type will be posted to the sub-ledger **Bank**, and then ultimately be transferred to the G/L account associated with the **Bank Posting Group**. | 
| **G/L Account**/ **Customer**/ **Bank** | Depending on your selection in the previous field, the code used for identifying one of the listed entities will need to be provided. |
| **Sale Line Text** | Specifies the description of the text that will be displayed on the sale line in the POS. |
| **Search Description** | Specifies the search description of the payment type. |
| **Prefix** | The **Payment Card** is directed to the correct payment type. For example, if we put 4 in a prefix on the payment type, and the card begins in 4 is in the terminal, then the payment will be directed to the payment type VISA. You don't choose the card type, but just T for the terminal. It goes for payment types with a V in the Cash terminal. |
| **Processing Type** | You can select the predefined codes that do posting with specific processes. It determines which code to call when doing payment on the POS. The following options are available: **Cash**, **Terminal**, **Card**, **Manual Card**, **Other Credit Cards**, **Credit Voucher**, **Cash Terminal**, **Foreign Currency**, **Foreign Credit Voucher**, **Foreign Gift Voucher**, **Debit Sale**, **Invoice**, **Finance Agreement** and **Payout**. |
| **Payment Method Code** | Determines which payment method is used, and to which G/L account it is associated. |
| **Posting** | The following options are available: **Condensed** - all transactions line for this particular payment type are posted in a consolidated entry; **Single entry** - all transactions line for this particular payment type are posted in an individual line entry. | 
| **Immediate Posting** | The immediate posting determines whether a transaction in the audit roll with that particular payment should be posted or not in the G/L at the time the transaction is concluded. It can be set to: **Never**, **Always**, **Negative** or **Positive**. |
| **Day Clearing Account** | This temporary account holds the receipt until it's transferred to the actual account. | 
| **Common Company Clearing** | This temporary account holds the receipt until it's transferred to the actual account. | 
| **Auto End Sale** | If this checkbox is ticked, the payment type is used in a sale. It automatically ends the sale, and closes the payment window to redirect the salesperson to the login window. |
| **Forced Amount** | If active, the customer has to type in the amount manually; there's no suggested amount in the payment pop-up in the POS. |
| **Hidden** | Hide the payment type from the list. | 
| **Match Sales Amount** | This setting is used in the interfaces of the credit card. The payment is matched to the sales amount. | 