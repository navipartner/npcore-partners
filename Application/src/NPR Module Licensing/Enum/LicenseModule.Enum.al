enum 6059776 "NPR License Module"
{
    Access = Internal;
    Extensible = false;
    Caption = 'NPR License Module';

    // Values are Customer Portal SKUs. One "NPR License User" row per user per SKU.
    // Captions are product names and therefore locked (not translated).
    value(0; _)
    {
        Caption = '', Locked = true;
    }
    value(1; POS)
    {
        Caption = 'Retail POS', Locked = true;
    }
    value(2; KDS)
    {
        Caption = 'KDS', Locked = true;
    }
    value(3; Scanner)
    {
        Caption = 'Scanner', Locked = true;
    }
    value(4; RetailWithoutPOS)
    {
        Caption = 'Retail without POS', Locked = true;
    }
    value(5; AttractionPOS)
    {
        Caption = 'Attraction POS', Locked = true;
    }
    value(6; AttractionWithoutPOS)
    {
        Caption = 'Attraction without POS', Locked = true;
    }
}
