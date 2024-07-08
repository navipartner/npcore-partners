enum 6014511 "NPR POS Sale Line Type"
{
#IF NOT BC17
    Access = Internal;       
#ENDIF
    Extensible = true;
    value(0; Item)
    {
        Caption = 'Item';
    }
    value(1; "Item Category")
    {
        Caption = 'Item Category';
    }
    value(2; "POS Payment")
    {
        Caption = 'POS Payment';
    }
    value(3; "BOM List")
    {
        Caption = 'BOM List';
    }
    value(4; "Customer Deposit")
    {
        Caption = 'Customer Deposit';
    }
    value(5; Comment)
    {
        Caption = 'Comment';
    }
    value(6; Rounding)
    {
        Caption = 'Rounding';
    }
    value(7; "GL Payment")
    {
        Caption = 'G/L Payment';
    }
    value(8; "Issue Voucher")
    {
        Caption = 'Issue Voucher';
    }
}