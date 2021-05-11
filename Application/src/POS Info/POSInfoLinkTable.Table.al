table 6150642 "NPR POS Info Link Table"
{
    Caption = 'POS Info Link Table';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            DataClassification = CustomerContent;
        }
        field(2; "Primary Key"; Text[250])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(3; "POS Info Code"; Code[20])
        {
            Caption = 'POS Info Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Info";
        }
        field(10; "When to Use"; Option)
        {
            Caption = 'When to Use';
            DataClassification = CustomerContent;
            OptionCaption = 'Always,Negative,Positive';
            OptionMembers = Always,Negative,Positive;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used';
        }
        field(20; "POS Info Description"; Text[50])
        {
            Caption = 'POS Info Description';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("NPR POS Info".Description where(Code = field("POS Info Code")));
        }
    }

    keys
    {
        key(Key1; "Table ID", "Primary Key", "POS Info Code")
        {
        }
    }
}
