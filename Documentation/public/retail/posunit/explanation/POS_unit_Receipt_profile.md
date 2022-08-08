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

### Related links

- [Balance the POS (Z-report)](../howto/balance_the_pos.md)
- [POS Display Profile](POS_Display_profile.md)
- [POS Input Box Profile](POS_input_box_profile.md)
- [POS End-of-Day Profile](../reference/POS_End_of_Day_Profile.md)
- [POS View Profile](../reference/POS_view_profile.md)
- [POS Audit Profile](../reference/POS_audit_profile.md)
- [Set up the POS Global Sales Profile](../howto/POS_Global.md)
- [Set up POS Posting Profile](../howto/POS_Pos_Prof.md)
- [Set up POS Pricing Profile](../howto/POS_Pricing_profile.md)