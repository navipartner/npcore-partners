table 6014683 "NPR POS Unit Group Line"
{
    Access = Internal;
    Caption = 'POS Unit Group Lines';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR POS Unit List";
    LookupPageID = "NPR POS Unit List";


    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'No.';
            TableRelation = "NPR POS Unit Group";
        }
        field(2; "POS Unit"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'POS Unit';
            TableRelation = "NPR POS Unit";
            NotBlank = true;
        }
        field(10; Name; Text[50])
        {
            Caption = 'Name';
            CalcFormula = lookup("NPR POS Unit".Name where("No." = field("POS Unit")));
            FieldClass = FlowField;
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "No.", "POS Unit")
        {
            Clustered = true;
        }
    }
}