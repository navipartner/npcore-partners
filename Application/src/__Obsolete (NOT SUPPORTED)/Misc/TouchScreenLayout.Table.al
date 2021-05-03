table 6014442 "NPR Touch Screen - Layout"
{
    Caption = 'Touch Screen - Layout';
    ObsoleteState = Removed;
    ObsoleteReason = 'Not used';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; "Resolution Width"; Integer)
        {
            Caption = 'Resolution Width';
            DataClassification = CustomerContent;
        }
        field(21; "Resolution Height"; Integer)
        {
            Caption = 'Resolution Height';
            DataClassification = CustomerContent;
        }
        field(30; "Button Count Vertical"; Integer)
        {
            Caption = 'Button Count Vertical';
            DataClassification = CustomerContent;
        }
        field(31; "Button Count Horizontal"; Integer)
        {
            Caption = 'Button Count Horizontal';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }
}

