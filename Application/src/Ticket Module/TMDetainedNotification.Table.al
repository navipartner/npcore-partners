table 6014631 "NPR TM Detained Notification"
{
    Access = Internal;
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(10; "Notification Profile Code"; Code[10])
        {
            Caption = 'Notification Profile Code';
            DataClassification = CustomerContent;
        }
        field(15; "Notification Trigger Type"; Enum "NPR TM Not. Trigger Type")
        {
            Caption = 'Ticket Trigger Type';
            DataClassification = CustomerContent;
        }
        field(20; "Notification Address"; Text[100])
        {
            Caption = 'Notification Address';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(50; "Detain Until"; DateTime)
        {
            Caption = 'Detain Until';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Primary; "Entry No.")
        {
            Clustered = true;
        }
        key(Sec2; "Notification Address", "Notification Trigger Type", "Notification Profile Code")
        {
            Unique = true;
        }
    }

}
