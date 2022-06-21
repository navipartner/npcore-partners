# POS Unit Receipt Text Profile

The POS Unit Receipt Text Profile can be used for assigning additional text to the footer area of receipts. Every POS unit can have different text in the footer if they have different POS unit Receipt Text Profiles with different text in them.
The POS Unit Receipt Text Profile consists of two sections: **General** and **POS Sales Ticket Receipt Text**.

![POSreceipt](../images/POS%20receipt.PNG)

The following fields can be defined in the **General** section:

| Field Name      | Description |
| ----------- | ----------- |
| **Code**       | The unique code for a profile.     |
| **Description**   | The short description of a profile.        |
| **Break Line**  | The number of characters after which the line will break. |
| **Sales Ticket Receipt Text** | The text which will be displayed in the footer. |


The **POS Sales Ticket Receipt Text** section is used for entering text which will be shown in the receipt footer. If the text was already entered in the **Sales Ticket Receipt Text** field in the **General** section, it will automatically be shown in this section.