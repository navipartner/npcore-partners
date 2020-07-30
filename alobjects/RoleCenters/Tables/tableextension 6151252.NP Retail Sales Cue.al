tableextension 6151252 "NP Retail Sales Cue" extends "Sales Cue"
{
    fields
    {
        field(6151241; "NPRC Date Filter"; Date)
        {
            FieldClass = FlowFilter;
            Editable = false;
        }
        field(6151242; "NPRC Date Filter Lst Year"; Date)
        {
            FieldClass = FlowFilter;
            Editable = false;
        }
        field(6151243; "NPRC Sales This Month"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Sum ("Value Entry"."Sales Amount (Actual)" WHERE("Item Ledger Entry Type" = FILTER(Sale), "Posting Date" = FIELD("NPRC Date Filter")));
        }
        field(6151244; "NPRC Sales This Month Lst Year"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Sum ("Value Entry"."Sales Amount (Actual)" WHERE("Item Ledger Entry Type" = FILTER(Sale), "Posting Date" = FIELD("NPRC Date Filter Lst Year")));
        }
    }
}
