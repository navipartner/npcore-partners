enum 6059793 "NPR RS Retail Calc. Doc. Type"
{
#if not BC17
    Access = Internal;
#endif
    Extensible = false;

    value(0; " ")
    {
        Caption = '';
    }
    value(1; "POS Entry")
    {
        Caption = 'POS Entry';
    }
    value(2; "Purcahse Invoice")
    {
        Caption = 'Purcahse Invoice';
    }
    value(3; "Sales Invoice")
    {
        Caption = 'Sales Invoice';
    }
    value(4; "Sales Credit Memo")
    {
        Caption = 'Sales Credit Memo';
    }
    value(5; "Transfer Shipment")
    {
        Caption = 'Transfer Shipment';
    }
    value(6; "Transfer Receipt")
    {
        Caption = 'Transfer Receipt';
    }
}