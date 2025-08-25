#if not BC17
enum 6059903 "NPR Spfy Order Line Price Type"
{
    Access = Internal;
    Extensible = false;

    value(0; "Actual Price")
    {
        Caption = 'Actual Price';
    }
    value(1; "Compare-at-Price")
    {
        Caption = 'Compare at Price';
    }
}
#endif