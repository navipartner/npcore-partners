table 6184513 "NPR EFT Transaction Log"
{
    // NPR5.53/MMV /20191120 CASE 377533 Created object

    Caption = 'EFT Transaction Logs';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Transaction Entry No."; Integer)
        {
            Caption = 'Transaction Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR EFT Transaction Request"."Entry No.";
        }
        field(2; "Log Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Log Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; Log; BLOB)
        {
            Caption = 'Log';
            DataClassification = CustomerContent;
        }
        field(20; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(30; "Logged At"; DateTime)
        {
            Caption = 'Logged At';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Transaction Entry No.", "Log Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

