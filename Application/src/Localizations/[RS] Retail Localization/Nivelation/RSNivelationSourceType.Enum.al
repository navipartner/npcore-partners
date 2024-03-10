enum 6014639 "NPR RS Nivelation Source Type"
{
#if not BC17
    Access = Internal;
#endif
    Extensible = false;

    value(0; "Posted Sales Invoice")
    {
        Caption = 'Posted Sales Invoice';
    }
    value(1; "Posted Sales Credit Memo")
    {
        Caption = 'Posted Sales Credit Memo';
    }
    value(2; "POS Entry")
    {
        Caption = 'POS Entry';
    }
    value(3; "Sales Price List")
    {
        Caption = 'Sales Price List';
    }
}