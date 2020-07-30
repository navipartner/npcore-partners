tableextension 6151245 "NP Retail Activities Cue" extends "Activities Cue"
{
    fields
    {
        field(6151241; "Sales This Month  Last Year"; Integer)
        {
            AutoFormatExpression = GetAmountFormat();
            AutoFormatType = 10;
            Caption = 'Quantity Sold';
        }
        field(6151242; "Sales This Month Last Year"; Decimal)
        {
            AutoFormatExpression = GetAmountFormat();
            DecimalPlaces = 0 : 0;
            AutoFormatType = 10;
            Caption = 'Sales Amount';
        }
        field(6151243; "NP Sales This Month"; Integer)
        {
            AutoFormatExpression = GetAmountFormat();
            //DecimalPlaces = 0 : 0;
            AutoFormatType = 10;
            Caption = 'Qty Sales This Month';
        }
        field(6151244; "NP Sales This Month Last Year"; Decimal)
        {
            AutoFormatExpression = GetAmountFormat();
            DecimalPlaces = 0 : 0;
            AutoFormatType = 10;
            Caption = 'Sales This Month Last Year';
        }
        field(6151245; "NP Sales This Month ILE"; Decimal)
        {
            AutoFormatExpression = GetAmountFormat();
            DecimalPlaces = 0 : 0;
            AutoFormatType = 10;
            Caption = 'Sales This Month';
        }
    }
}