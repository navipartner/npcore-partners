#if not BC17
enum 6059887 "NPR Spfy Document Type"
{
    Access = Internal;
    Extensible = false;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; "Sales Order")
    {
        Caption = 'Sales Order';
    }
    value(2; "Sales Invoice")
    {
        Caption = 'Sales Invoice';
    }
    value(3; "Sales Return Order")
    {
        Caption = 'Sales Return Order';
    }
    value(4; "Sales Credit Memo")
    {
        Caption = 'Sales Credit Memo';
    }
    value(5; "Posted Sales Shipment")
    {
        Caption = 'Posted Sales Shipment';
    }
    value(6; "Posted Return Receipt")
    {
        Caption = 'Posted Return Receipt';
    }
    value(7; "Posted Sales Invoice")
    {
        Caption = 'Posted Sales Invoice';
    }
    value(8; "Posted Sales Credit Memo")
    {
        Caption = 'Posted Sales Credit Memo';
    }
#if not BC18 and not BC19 and not BC20 and not BC21 and not BC22
    value(9; "Incoming Ecommerce Order")
    {
        Caption = 'Incoming Ecommerce Order';
    }
    value(10; "Incoming Ecommerce Return Order")
    {
        Caption = 'Incoming Ecommerce Return Order';
    }
#endif
}
#endif