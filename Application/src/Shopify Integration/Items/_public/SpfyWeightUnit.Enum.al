#if not BC17
enum 6014576 "NPR Spfy Weight Unit"
{
    Caption = 'Shopify Weight Unit';
    Access = Public;
    Extensible = false;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; GRAMS)
    {
        Caption = 'g (grams)';
    }
    value(2; KILOGRAMS)
    {
        Caption = 'kg (kilograms)';
    }
    value(3; OUNCES)
    {
        Caption = 'oz (ounces)';
    }
    value(4; POUNDS)
    {
        Caption = 'lb (pounds)';
    }
}
#endif
