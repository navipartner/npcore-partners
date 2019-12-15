table 6060109 "TM Offline Ticket Validation"
{
    // TM1.22/NPKNAV/20170612  CASE 274464 Transport T0007 - 12 June 2017

    Caption = 'Offline Ticket Validation';

    fields
    {
        field(1;"Entry No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(10;"Ticket Reference Type";Option)
        {
            Caption = 'Ticket Reference Type';
            OptionCaption = 'Ticket No.';
            OptionMembers = EXTERNALTICKETNO;
        }
        field(15;"Ticket Reference No.";Code[20])
        {
            Caption = 'Ticket Reference No.';
        }
        field(20;"Member Reference Type";Option)
        {
            Caption = 'Member Reference Type';
            OptionCaption = 'Member Card No.,Member No.';
            OptionMembers = MEMBERCARDNO,MEMBERNO;
        }
        field(25;"Member Reference No.";Code[20])
        {
            Caption = 'Member Reference No.';
        }
        field(30;"Event Type";Option)
        {
            Caption = 'Event Type';
            OptionCaption = 'Admit,Depart';
            OptionMembers = ADMIT,DEPART;
        }
        field(31;"Event Date";Date)
        {
            Caption = 'Event Date';
        }
        field(32;"Event Time";Time)
        {
            Caption = 'Event Time';
        }
        field(40;"Process Status";Option)
        {
            Caption = 'Process Status';
            OptionCaption = 'Unhandled,Valid,Invalid';
            OptionMembers = UNHANDLED,VALID,INVALID;
        }
        field(45;"Process Response Text";Text[250])
        {
            Caption = 'Process Response Text';
        }
        field(50;"Admission Code";Code[20])
        {
            Caption = 'Admission Code';
        }
        field(70;"Imported At";DateTime)
        {
            Caption = 'Imported At';
        }
        field(75;"Import Reference Name";Text[80])
        {
            Caption = 'Import Reference Name';
        }
        field(76;"Import Reference No.";Integer)
        {
            Caption = 'Import Reference No.';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
        key(Key2;"Import Reference No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        if ("Process Status" = "Process Status"::VALID) then
          Error (DELETE_NOT_ALLOWED, FieldCaption ("Process Status"), "Process Status", TableCaption, FieldCaption ("Entry No."), "Entry No.");
    end;

    var
        DELETE_NOT_ALLOWED: Label '%1 must not be equal to ''%2'' in %3: %4=%5.';
}

