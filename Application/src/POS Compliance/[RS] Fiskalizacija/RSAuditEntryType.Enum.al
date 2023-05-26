enum 6014517 "NPR RS Audit Entry Type"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; "POS Entry")
    {
        Caption = 'POS Entry';
    }
    value(1; "Sales Header")
    {
        Caption = 'Sales Header';
    }
    value(2; "Sales Invoice Header")
    {
        Caption = 'Sales Invoice Header';
    }
    value(3; "Sales Cr.Memo Header")
    {
        Caption = 'Sales Cr.Memo Header';
    }
}