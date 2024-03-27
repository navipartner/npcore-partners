#if not BC17
tableextension 6014523 "NPR Stockkeeping Unit" extends "Stockkeeping Unit"
{
    fields
    {
        field(6014440; "NPR Spfy Safety Stock Quantity"; Decimal)
        {
            Caption = 'Shopify Safety Stock Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
    }
}
#endif