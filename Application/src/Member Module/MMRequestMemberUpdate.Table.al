table 6014608 "NPR MM Request Member Update"
{
    Access = Internal;
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
            AutoIncrement = true;
        }

        field(10; "Member Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Member Entry No.';
        }

        field(11; "Member No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Member No.';
        }

        field(15; Handled; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Handled';
        }

        field(20; "Field No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Field No.';
        }

        field(21; Caption; Text[80])
        {
            DataClassification = CustomerContent;
            Caption = 'Caption';
        }

        field(30; "Current Value"; Text[200])
        {
            DataClassification = CustomerContent;
            Caption = 'Current Value';
        }

        field(31; "New Value"; Text[200])
        {
            DataClassification = CustomerContent;
            Caption = 'New Value';
        }

        field(40; "Request Datetime"; Datetime)
        {
            DataClassification = CustomerContent;
            Caption = 'Request Datetime';
        }

        field(41; "Response Datetime"; Datetime)
        {
            DataClassification = CustomerContent;
            Caption = 'Response Datetime';
        }

        field(50; "Remote Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Remote Entry No.';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(MemberEntryNo; "Member Entry No.")
        {
            Unique = false;
        }

    }


}
