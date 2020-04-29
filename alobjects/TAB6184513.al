table 6184513 "EFT Transaction Log"
{
    // NPR5.53/MMV /20191120 CASE 377533 Created object

    Caption = 'EFT Transaction Logs';

    fields
    {
        field(1;"Transaction Entry No.";Integer)
        {
            Caption = 'Transaction Entry No.';
            TableRelation = "EFT Transaction Request"."Entry No.";
        }
        field(2;"Log Entry No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Log Entry No.';
        }
        field(10;Log;BLOB)
        {
            Caption = 'Log';
        }
        field(20;Description;Text[250])
        {
            Caption = 'Description';
        }
        field(30;"Logged At";DateTime)
        {
            Caption = 'Logged At';
        }
    }

    keys
    {
        key(Key1;"Transaction Entry No.","Log Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

