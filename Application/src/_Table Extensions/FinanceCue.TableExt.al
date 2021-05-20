tableextension 6151240 "NPR Finance Cue" extends "Finance Cue"
{
    fields
    {
        field(6151241; "NPR Purchase Order"; Integer)
        {
            CalcFormula = Count("Purchase Header" WHERE("Document Type" = CONST(Order)));
            FieldClass = FlowField;
        }
        field(6151242; "NPR Pending Inc. Documents"; Integer)
        {
            CalcFormula = Count("Incoming Document" WHERE("Document Type" = CONST(" "), "Document No." = CONST('')));
            FieldClass = FlowField;
            ObsoleteState = Removed;
            ObsoleteReason = 'Removing unnecesarry table extensions.';
        }
        field(6151243; "NPR Posted Purchase order"; Integer)
        {
            CalcFormula = Count("Purch. Inv. Header");
            FieldClass = FlowField;
            ObsoleteState = Removed;
            ObsoleteReason = 'Removing unnecesarry table extensions.';
        }
        field(6151244; "NPR Purchase Quote"; Integer)
        {
            CalcFormula = Count("Purchase Header" WHERE("Document Type" = CONST(Quote)));
            FieldClass = FlowField;
        }
    }
}