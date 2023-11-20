enum 6014566 "NPR RS Nivelation Type"
{
#if not BC17
    Access = Internal;
#endif
    Extensible = false;

    value(0; "Price Change")
    {
        Caption = 'Price Change';
    }
    value(1; "Promotions & Discounts")
    {
        Caption = 'Promotions & Discounts';
    }
}