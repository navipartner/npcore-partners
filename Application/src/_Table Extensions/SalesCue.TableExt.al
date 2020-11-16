tableextension 6151252 "NPR Sales Cue" extends "Sales Cue"
{
    fields
    {
        field(6151241; "NPR Date Filter"; Date)
        {
            FieldClass = FlowFilter;
            Editable = false;
        }
        field(6151242; "NPR Date Filter Lst Year"; Date)
        {
            FieldClass = FlowFilter;
            Editable = false;
        }
        field(6151243; "NPR Sales This Month"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Sum ("Value Entry"."Sales Amount (Actual)" WHERE("Item Ledger Entry Type" = FILTER(Sale), "Posting Date" = FIELD("NPR Date Filter")));
        }
        field(6151244; "NPR Sales This Month Lst Year"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Sum ("Value Entry"."Sales Amount (Actual)" WHERE("Item Ledger Entry Type" = FILTER(Sale), "Posting Date" = FIELD("NPR Date Filter Lst Year")));
        }
    }
}
