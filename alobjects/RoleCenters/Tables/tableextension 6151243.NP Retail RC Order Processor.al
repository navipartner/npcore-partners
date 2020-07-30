tableextension 6151243 "NP Retail RC Order Processor" extends "Headline RC Order Processor"
{
    fields
    {
        field(6151241; "Biggest Sales Today"; Decimal)
        {
            CalcFormula = Max ("POS Entry"."Item Sales (LCY)");
            Caption = 'Not Enabled';
            FieldClass = FlowField;
        }
    }

}