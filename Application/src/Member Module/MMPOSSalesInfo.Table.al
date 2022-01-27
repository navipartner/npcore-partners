table 6060147 "NPR MM POS Sales Info"
{
    Access = Internal;

    Caption = 'MM POS Sales Info';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Association Type"; Option)
        {
            Caption = 'Association Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Header,Line';
            OptionMembers = HEADER,LINE;
        }
        field(2; "Receipt No."; Code[20])
        {
            Caption = 'Receipt No.';
            DataClassification = CustomerContent;
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(10; "Membership Entry No."; Integer)
        {
            Caption = 'Membership Entry No.';
            DataClassification = CustomerContent;
        }
        field(15; "Member Entry No."; Integer)
        {
            Caption = 'Member Entry No.';
            DataClassification = CustomerContent;
        }
        field(20; "Member Card Entry No."; Integer)
        {
            Caption = 'Member Card Entry No.';
            DataClassification = CustomerContent;
        }
        field(30; "Scanned Card Data"; Text[200])
        {
            Caption = 'Scanned Card Data';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Association Type", "Receipt No.", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}

