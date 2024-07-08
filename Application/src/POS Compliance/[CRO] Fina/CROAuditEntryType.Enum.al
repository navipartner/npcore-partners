enum 6014586 "NPR CRO Audit Entry Type"
{
#if not BC17
    Access = Internal;
#endif
    Extensible = false;

    value(0; "POS Entry")
    {
        Caption = 'POS Entry';
    }
    value(1; "Sales Invoice")
    {
        Caption = 'Sales Invoice';
    }
    value(2; "Sales Credit Memo")
    {
        Caption = 'Sales Credit Memo';
    }
}