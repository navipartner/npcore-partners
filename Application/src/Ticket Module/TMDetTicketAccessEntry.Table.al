table 6060123 "NPR TM Det. Ticket AccessEntry"
{
    Access = Internal;
    Caption = 'Det. Ticket Access Entry';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR TM Det. Ticket AccessEntry";
    LookupPageId = "NPR TM Det. Ticket AccessEntry";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(3; "Ticket No."; Code[20])
        {
            Caption = 'Ticket No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR TM Ticket";
        }
        field(4; "Ticket Access Entry No."; Integer)
        {
            Caption = 'Ticket Access Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR TM Ticket Access Entry";
        }
        field(10; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Initial Entry,Reservation,Admitted,Departed,Consumed,Canceled,Payment,PrePaid,PostPaid,Canceled Reservation';
            OptionMembers = INITIAL_ENTRY,RESERVATION,ADMITTED,DEPARTED,CONSUMED,CANCELED_ADMISSION,PAYMENT,PREPAID,POSTPAID,CANCELED_RESERVATION;
        }
        field(11; "External Adm. Sch. Entry No."; Integer)
        {
            Caption = 'External Adm. Sch. Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR TM Admis. Schedule Entry"."External Schedule Entry No.";
            ValidateTableRelation = false;
        }
        field(12; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
        }
        field(13; "Closed By Entry No."; Integer)
        {
            Caption = 'Closed By Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR TM Det. Ticket AccessEntry";
        }
        field(14; Open; Boolean)
        {
            Caption = 'Open';
            DataClassification = CustomerContent;
        }
        field(15; "Sales Channel No."; Code[20])
        {
            Caption = 'Sales Channel No.';
            DataClassification = CustomerContent;
        }
        field(16; "Scanner Station ID"; Text[30])
        {
            Caption = 'Scanner Station ID';
            DataClassification = CustomerContent;
        }
        field(20; "Created Datetime"; DateTime)
        {
            Caption = 'Created Datetime';
            DataClassification = CustomerContent;
        }
        field(21; "User ID"; Code[40])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "External Adm. Sch. Entry No.", Type, Open, "Posting Date")
        {
            SumIndexFields = Quantity;
        }
        key(Key3; "Ticket No.", Type, Open, "Posting Date")
        {
        }
        key(Key4; "Ticket Access Entry No.", Type, Open, "Posting Date")
        {
        }
        key(Key5; Type, Open, "Posting Date")
        {
        }
        key(Key6; Type, "Created Datetime")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        Rec."Created Datetime" := CurrentDateTime();
        Rec."User ID" := CopyStr(UserId(), 1, MaxStrLen(Rec."User ID"));
    end;

    trigger OnModify()
    begin
        Rec."Created Datetime" := CurrentDateTime();
        Rec."User ID" := CopyStr(UserId(), 1, MaxStrLen(Rec."User ID"));
    end;

    trigger OnRename()
    begin
        Error('');
    end;
}

