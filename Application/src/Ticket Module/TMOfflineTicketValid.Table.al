table 6060109 "NPR TM Offline Ticket Valid."
{
    // TM1.22/NPKNAV/20170612  CASE 274464 Transport T0007 - 12 June 2017

    Caption = 'Offline Ticket Validation';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; "Ticket Reference Type"; Option)
        {
            Caption = 'Ticket Reference Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Ticket No.';
            OptionMembers = EXTERNALTICKETNO;
        }
        field(15; "Ticket Reference No."; Code[20])
        {
            Caption = 'Ticket Reference No.';
            DataClassification = CustomerContent;
        }
        field(20; "Member Reference Type"; Option)
        {
            Caption = 'Member Reference Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Member Card No.,Member No.';
            OptionMembers = MEMBERCARDNO,MEMBERNO;
        }
        field(25; "Member Reference No."; Code[20])
        {
            Caption = 'Member Reference No.';
            DataClassification = CustomerContent;
        }
        field(30; "Event Type"; Option)
        {
            Caption = 'Event Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Admit,Depart';
            OptionMembers = ADMIT,DEPART;
        }
        field(31; "Event Date"; Date)
        {
            Caption = 'Event Date';
            DataClassification = CustomerContent;
        }
        field(32; "Event Time"; Time)
        {
            Caption = 'Event Time';
            DataClassification = CustomerContent;
        }
        field(40; "Process Status"; Option)
        {
            Caption = 'Process Status';
            DataClassification = CustomerContent;
            OptionCaption = 'Unhandled,Valid,Invalid';
            OptionMembers = UNHANDLED,VALID,INVALID;
        }
        field(45; "Process Response Text"; Text[250])
        {
            Caption = 'Process Response Text';
            DataClassification = CustomerContent;
        }
        field(50; "Admission Code"; Code[20])
        {
            Caption = 'Admission Code';
            DataClassification = CustomerContent;
        }
        field(70; "Imported At"; DateTime)
        {
            Caption = 'Imported At';
            DataClassification = CustomerContent;
        }
        field(75; "Import Reference Name"; Text[100])
        {
            Caption = 'Import Reference Name';
            DataClassification = CustomerContent;
        }
        field(76; "Import Reference No."; Integer)
        {
            Caption = 'Import Reference No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Import Reference No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        if ("Process Status" = "Process Status"::VALID) then
            Error(DELETE_NOT_ALLOWED, FieldCaption("Process Status"), "Process Status", TableCaption, FieldCaption("Entry No."), "Entry No.");
    end;

    var
        DELETE_NOT_ALLOWED: Label '%1 must not be equal to ''%2'' in %3: %4=%5.';
}

