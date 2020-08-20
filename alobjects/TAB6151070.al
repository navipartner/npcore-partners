table 6151070 "Customer GDPR Log Entries"
{
    // NPR5.52/ZESO/20190925 CASE 358656 Object Created
    // NPR5.55/ZESO/20200427 CASE 401981 Added field 10 Open Journal Entries/Statement

    Caption = 'Customer GDPR Log Entries';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No"; Integer)
        {
            Caption = 'Entry No';
            DataClassification = CustomerContent;
        }
        field(2; "Customer No"; Code[20])
        {
            Caption = 'Customer No';
            DataClassification = CustomerContent;
        }
        field(3; Status; Option)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            OptionCaption = 'Anonymised,Could Not be anonymised';
            OptionMembers = Anonymised,"Could Not be anonymised";
        }
        field(4; "Open Sales Documents"; Boolean)
        {
            Caption = 'Open Sales Documents';
            DataClassification = CustomerContent;
        }
        field(5; "Open Cust. Ledger Entry"; Boolean)
        {
            Caption = 'Open Cust. Ledger Entry';
            DataClassification = CustomerContent;
        }
        field(6; "Has transactions"; Boolean)
        {
            Caption = 'Has transactions';
            DataClassification = CustomerContent;
        }
        field(7; "Customer is a Member"; Boolean)
        {
            Caption = 'Customer is a Member';
            DataClassification = CustomerContent;
        }
        field(8; "Log Entry Date Time"; DateTime)
        {
            Caption = 'Log Entry Date Time';
            DataClassification = CustomerContent;
        }
        field(9; "Anonymized By"; Code[50])
        {
            Caption = 'Anonymized By';
            DataClassification = CustomerContent;
        }
        field(10; "Open Journal Entries/Statement"; Boolean)
        {
            Caption = 'Open Journal Entries/Statement';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No")
        {
        }
    }

    fieldgroups
    {
    }
}

