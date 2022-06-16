# POS Audit Profile

**POS Audit Profile** is used so different number series and different rules for printing can be assigned to different POS units.

![POSAuditProfile](../images/POS%20audit%20profile.PNG)

In **General** section there are next fields:

- **Code** - unique code for POS Audit Profile.
- **Description** - short description of profile.
- **Sales Ticket No. Series** - Number series used for creating document number
- **Sale Fiscal No. Series** - Number series used for creating fiscal number
- **Credit Sale Fiscal No. Series** - Number series used for creating fiscal number for credit sales.
- **Balancing Fiscal No. Series** - Number series used for creating fiscal number for balancing.
- **Fill Sale Fiscal No. On** - there is choice between **All Sale** and - **Successful Sale**.
- **Audit Log Enabled** - used in some countries for creating additional logs, usually for VAT.
- **Audit Handler** - if **Audit Log Enabled** is checked here it is choosen which log has to be made.
- **Allow Zero Amount Sale** - allows sale to be finished with amount zero.
- **Print Receipt On Cancel Sale** - allows printing receipt even when sale is canceled.
- **Allow Printing Receipt Copy** - setup for printing copy. Options: **Always**, **Once**, **Never**.
- **Require Item Return Reason** -If field is checked in moment of returning goods in POS cashier will be asked to enter reason code for return.