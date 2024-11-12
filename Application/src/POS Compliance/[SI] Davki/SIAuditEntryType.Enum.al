enum 6014533 "NPR SI Audit Entry Type"
{
#if not BC17
    Access = Internal;
#endif
    Extensible = false;

    value(0; "POS Entry")
    {
        Caption = 'POS Entry';
    }
    value(1; "Sales Invoice Header")
    {
        Caption = 'Sales Invoice Header';
    }
    value(2; "Sales Cr. Memo Header")
    {
        Caption = 'Sales Cr. Memo Header';
    }
}