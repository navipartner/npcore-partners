tableextension 6151240 "NP Retail Finance Cue" extends "Finance Cue"
{
    fields
    {
        field(6151241; "NP Purchase Order"; Integer)
        {
            CalcFormula = Count ("Purchase Header" WHERE("Document Type" = CONST(Order)));
            FieldClass = FlowField;
        }
        field(6151242; "Pending Inc. Documents"; Integer)
        {
            CalcFormula = Count ("Incoming Document" WHERE("Document Type" = CONST(" "), "Document No." = CONST('')));
            FieldClass = FlowField;
        }

        field(6151243; "Posted Purchase order"; Integer)
        {
            CalcFormula = Count ("Purch. Inv. Header");
            FieldClass = FlowField;
        }

    }
}
