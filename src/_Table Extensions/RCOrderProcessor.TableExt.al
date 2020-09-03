tableextension 6151243 "NPR RC Order Processor" extends "Headline RC Order Processor"
{
    fields
    {
        field(6151241; "NPR Biggest Sales Today"; Decimal)
        {
            CalcFormula = Max ("NPR POS Entry"."Item Sales (LCY)");
            Caption = 'Not Enabled';
            FieldClass = FlowField;
        }
    }

}