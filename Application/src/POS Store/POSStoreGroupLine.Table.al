table 6014686 "NPR POS Store Group Line"
{
    Access = Internal;
    Caption = 'POS Store Group Lines';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR POS Store List";
    LookupPageID = "NPR POS Store List";


    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'No.';
            TableRelation = "NPR POS Store Group";
        }
        field(2; "POS Store"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'POS Store';
            TableRelation = "NPR POS Store";
            NotBlank = true;
        }
        field(10; Name; Text[50])
        {
            Caption = 'Name';
            CalcFormula = lookup("NPR POS Store".Name where("Code" = field("POS Store")));
            FieldClass = FlowField;
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "No.", "POS Store")
        {
            Clustered = true;
        }
    }
}