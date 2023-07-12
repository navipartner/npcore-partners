tableextension 6151252 "NPR Sales Cue" extends "Sales Cue"
{
    fields
    {
        field(6151241; "NPR Date Filter"; Date)
        {
            FieldClass = FlowFilter;
            Editable = false;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Removing unnecesarry table extensions.';
        }
        field(6151242; "NPR Date Filter Lst Year"; Date)
        {
            FieldClass = FlowFilter;
            Editable = false;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Removing unnecesarry table extensions.';
        }
        field(6151243; "NPR Sales This Month"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Sum("Value Entry"."Sales Amount (Actual)" WHERE("Item Ledger Entry Type" = FILTER(Sale)));
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Removing unnecesarry table extensions.';
        }
        field(6151244; "NPR Sales This Month Lst Year"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Sum("Value Entry"."Sales Amount (Actual)" WHERE("Item Ledger Entry Type" = FILTER(Sale)));
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Removing unnecesarry table extensions.';
        }
    }
}
