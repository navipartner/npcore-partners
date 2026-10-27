#if not BC17
enum 6059811 "NPR Spfy WH Subscr. Status"
{
    Access = Internal;
    Extensible = false;

    value(0; "Not Checked")
    {
        Caption = 'Not Checked';
    }
    value(1; OK)
    {
        Caption = 'OK';
    }
    value(2; "Missing in Shopify")
    {
        Caption = 'Missing in Shopify';
    }
    value(3; "Address Mismatch")
    {
        Caption = 'Address Mismatch';
    }
    value(4; "Delivers Elsewhere")
    {
        Caption = 'Delivers Elsewhere';
    }
    value(5; "Not Registered")
    {
        Caption = 'Not Registered in This Company';
    }
}
#endif
