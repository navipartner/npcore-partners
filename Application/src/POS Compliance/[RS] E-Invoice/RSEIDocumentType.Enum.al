enum 6014653 "NPR RS EI Document Type"
{
#if not BC17
    Access = Internal;
#endif
    Extensible = false;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; "Sales Invoice")
    {
        Caption = 'Sales Invoice';
    }
    value(2; "Sales Cr. Memo")
    {
        Caption = 'Sales Cr. Memo';
    }
    value(3; "Purchase Invoice")
    {
        Caption = 'Purchase Invoice';
    }
    value(4; "Purchase Order")
    {
        Caption = 'Purchase Order';
    }
    value(5; "Purchase Cr. Memo")
    {
        Caption = 'Purchase Cr. Memo';
    }
}