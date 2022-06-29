# POS Audit Profile

**POS Audit Profile** is used so different number series and different rules for printing can be assigned to different POS units.

![POSAuditProfile](../images/POS%20audit%20profile.PNG)

The following options can be set up in the **General** section:


| Field Name      | Description |
| ----------- | ----------- |
| **Code**       | The unique code for the POS Audit Profile.     |
| **Description**   | The short description of profile.        |
| **Sales ticket No. Series**  | The number series used for creating the document number. |
| **Sale Fiscal No. Series** | The number series used for creating the fiscal number. |
| **Credit Sale Fiscal No. Series** | The items will be searched by their cross reference numbers. |
| **Balancing Fiscal No. Series** | The number series used for creating the fiscal number for balancing. |
| **Fill Sales Fiscal No. On** | You can choose between **All Sale** and **Successful Sale**. |
| **Audit Log Enabled** | Used in certain countries for creating additional logs, usually for VAT. |
| **Audit Handler** | If **Audit Log Enabled** is checked use this field to choose which log will be created. |
| **Allow Zero Amount Sale** | Allow the sale to be finalized with the amount zero. |
| **Print Receipt On Cancel Sale** | Allow receipts to be printed even when the sale is canceled. |
| **Allow Printing Receipt Copy** | Set up whether a copy is printed or not. Available options are: **Always**, **Once**, **Never**. |
| **Require Item Return Reason** | If this field is checked in the moment of returning goods in the POS, the cashier will be asked to enter the reason code for the return of the goods. |

### Related links

- [POS Display Profile](POS_Display_profile.md)
- [POS End-of-Day Profile](POS_End_of_Day_Profile.md)
- [POS Input Box Profile](POS_input_box_profile.md)
- [POS Unit Receipt Profile](POS_unit_Receipt_profile.md)
- [POS View Profile](POS_view_profile.md)
- [Set up the POS Global Sales Profile](../howto/POS_Global.md)
- [Set up POS Posting Profile](../howto/POS_Pos_Prof.md)
- [Set up POS Pricing Profile](../howto/POS_Pricing_profile.md)