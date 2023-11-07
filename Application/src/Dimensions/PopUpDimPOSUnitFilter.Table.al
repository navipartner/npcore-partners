table 6150694 "NPR Pop Up Dim POS Unit Filter"
{
    Access = Internal;
    DataClassification = CustomerContent;
    Caption = 'Pop Up Dim POS Unit Filter';

    fields
    {
        field(1; "POS Unit"; Code[10])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit"."No.";
        }

        field(2; "POS Unit Name"; Text[50])
        {
            Caption = 'POS Unit Name';
            FieldClass = FlowField;
            CalcFormula = lookup("NPR POS Unit".Name where("No." = field("POS Unit")));
            Editable = false;
        }

        field(3; Enable; Boolean)
        {
            Caption = 'Enable Dimension Popup';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "POS Unit")
        {
            Clustered = true;
        }
    }
}