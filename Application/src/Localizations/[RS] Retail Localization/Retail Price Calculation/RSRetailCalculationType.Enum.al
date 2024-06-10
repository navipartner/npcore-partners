enum 6014691 "NPR RS Retail Calculation Type"
{
#if not BC17
    Access = Internal;
#endif
    Extensible = false;

    value(0; "Margin")
    {
        Caption = 'Margin';
    }
    value(1; "VAT")
    {
        Caption = 'VAT';
    }
    value(2; "Margin with VAT")
    {
        Caption = 'Margin with VAT';
    }
    value(3; "Standard Correction")
    {
        Caption = 'Standard Correction';
    }
    value(4; "Counter Std Correction")
    {
        Caption = 'Counter Std Correction';
    }
    value(5; "COGS Correction")
    {
        Caption = 'COGS Correction';
    }
    value(6; "Counter COGS Correction")
    {
        Caption = 'Counter COGS Correction';
    }
    value(7; "Item Charge Margin with VAT")
    {
        Caption = 'Item Charge Margin with VAT';
    }
    value(8; "Item Charge Margin")
    {
        Caption = 'Item Charge Margin';
    }
    value(9; "Transit Adjustment")
    {
        Caption = 'Transit Adjustment';
    }
}