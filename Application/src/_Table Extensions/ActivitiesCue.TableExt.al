tableextension 6151245 "NPR Activities Cue" extends "Activities Cue"
{
    fields
    {
        field(6151241; "NPR Sales CM  Last Year"; Integer)
        {
            AutoFormatExpression = GetAmountFormat();
            AutoFormatType = 10;
            Caption = 'Quantity Sold';
            DataClassification = CustomerContent;

            ObsoleteState = Removed;
            ObsoleteReason = 'Not used';
        }
        field(6151242; "NPR Sales CM Last Year"; Decimal)
        {
            AutoFormatExpression = GetAmountFormat();
            DecimalPlaces = 0 : 0;
            AutoFormatType = 10;
            Caption = 'Sales Amount';
            DataClassification = CustomerContent;

            ObsoleteState = Removed;
            ObsoleteReason = 'Not used';
        }
        field(6151243; "NPR Sales This Month"; Integer)
        {
            AutoFormatExpression = GetAmountFormat();
            AutoFormatType = 10;
            Caption = 'Qty Sales This Month';
            DataClassification = CustomerContent;

            ObsoleteState = Removed;
            ObsoleteReason = 'Not used';
        }
        field(6151244; "NPR Sales This Month Last Year"; Decimal)
        {
            AutoFormatExpression = GetAmountFormat();
            DecimalPlaces = 0 : 0;
            AutoFormatType = 10;
            Caption = 'Sales This Month Last Year';
            DataClassification = CustomerContent;

            ObsoleteState = Removed;
            ObsoleteReason = 'Not used';
        }
        field(6151245; "NPR Sales This Month ILE"; Decimal)
        {
            AutoFormatExpression = GetAmountFormat();
            DecimalPlaces = 0 : 0;
            AutoFormatType = 10;
            Caption = 'Sales This Month';
            DataClassification = CustomerContent;

            ObsoleteState = Removed;
            ObsoleteReason = 'Not used';
        }
    }
}