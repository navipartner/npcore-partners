table 6059786 "NPR TM Ticket Access Entry"
{
    Caption = 'Ticket Access Entry';
    LookupPageID = "NPR TM Ticket AccessEntry List";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "Ticket No."; Code[20])
        {
            Caption = 'Ticket No.';
            TableRelation = "NPR TM Ticket";
            DataClassification = CustomerContent;
        }
        field(3; "Ticket Type Code"; Code[10])
        {
            Caption = 'Ticket Type Code';
            TableRelation = "NPR TM Ticket Type";
            DataClassification = CustomerContent;
        }
        field(10; "Access Date"; Date)
        {
            Caption = 'Access Date';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(11; "Access Time"; Time)
        {
            Caption = 'Access Time';
            DataClassification = CustomerContent;
        }
        field(12; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;
            DataClassification = CustomerContent;
        }
        field(21; "Member Card Code"; Code[10])
        {
            Caption = 'Member Card Code';
            DataClassification = CustomerContent;
        }
        field(30; Status; Option)
        {
            Caption = 'Status';
            OptionCaption = 'Access,Blocked';
            OptionMembers = ACCESS,BLOCKED;
            DataClassification = CustomerContent;
        }
        field(31; Quantity; Decimal)
        {
            Caption = 'Qty.';
            Editable = false;
            InitValue = 1;
            DataClassification = CustomerContent;
        }
        field(40; "Admission Code"; Code[20])
        {
            Caption = 'Admission Code';
            Description = '#219658';
            TableRelation = "NPR TM Admission";
            DataClassification = CustomerContent;
        }
        field(50; DurationUntilDate; Date)
        {
            Caption = 'Duration Until Date';
            DataClassification = CustomerContent;
        }
        field(51; DurationUntilTime; Time)
        {
            Caption = 'Duration Until Time';
            DataClassification = CustomerContent;
        }

    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Ticket No.", "Admission Code")
        {
        }
    }

    fieldgroups
    {
    }
}

