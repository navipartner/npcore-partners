table 6060123 "TM Det. Ticket Access Entry"
{
    // NPR4.16/TSA/20150803 CASE219658 Ticket Initial Version
    // TM1.00/TSA/20151217  CASE 224225 NaviPartner Ticket Management
    // TM1.04/TSA20160115  CASE 231834 Changed quantity field to decimal to make flowfield sum work
    // TM1.07/TSA/20160125  CASE 232495 Added key Type,Created Datetime, for statistics
    // TM1.12/TSA/20160407  CASE 230600 Added DAN Captions
    // TM1.17/TSA /20161025  CASE 256152 Conform to OMA Guidelines
    // TM1.22/TSA/20170526  CASE 278142 Added options PREPAID,POSTPAID to option Type, extended Sales Channel to code 20 and renamed to Sales Channel No. Added Scanner Station ID
    // TM1.33/TSA/20180527 CASE 319454 Added Quantity on as sumindex field to enhance the schedule entry page flowfields

    Caption = 'Det. Ticket Access Entry';
    DrillDownPageID = "TM Det. Ticket Access Entry";
    LookupPageID = "TM Det. Ticket Access Entry";

    fields
    {
        field(1;"Entry No.";BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(2;"Posting Date";Date)
        {
            Caption = 'Posting Date';
        }
        field(3;"Ticket No.";Code[20])
        {
            Caption = 'Ticket No.';
            TableRelation = "TM Ticket";
        }
        field(4;"Ticket Access Entry No.";Integer)
        {
            Caption = 'Ticket Access Entry No.';
            TableRelation = "TM Ticket Access Entry";
        }
        field(10;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = 'Initial Entry,Reservation,Admitted,Departed,Consumed,Canceled,Payment,PrePaid,PostPaid';
            OptionMembers = INITIAL_ENTRY,RESERVATION,ADMITTED,DEPARTED,CONSUMED,CANCELED,PAYMENT,PREPAID,POSTPAID;
        }
        field(11;"External Adm. Sch. Entry No.";Integer)
        {
            Caption = 'External Adm. Sch. Entry No.';
            TableRelation = "TM Admission Schedule Entry"."External Schedule Entry No.";
            ValidateTableRelation = false;
        }
        field(12;Quantity;Decimal)
        {
            Caption = 'Quantity';
        }
        field(13;"Closed By Entry No.";BigInteger)
        {
            Caption = 'Closed By Entry No.';
            TableRelation = "TM Det. Ticket Access Entry";
        }
        field(14;Open;Boolean)
        {
            Caption = 'Open';
        }
        field(15;"Sales Channel No.";Code[20])
        {
            Caption = 'Sales Channel No.';
        }
        field(16;"Scanner Station ID";Text[30])
        {
            Caption = 'Scanner Station ID';
        }
        field(20;"Created Datetime";DateTime)
        {
            Caption = 'Created Datetime';
        }
        field(21;"User ID";Code[40])
        {
            Caption = 'User ID';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
        key(Key2;"External Adm. Sch. Entry No.",Type,Open,"Posting Date")
        {
            SumIndexFields = Quantity;
        }
        key(Key3;"Ticket No.",Type,Open,"Posting Date")
        {
        }
        key(Key4;"Ticket Access Entry No.",Type,Open,"Posting Date")
        {
        }
        key(Key5;Type,Open,"Posting Date")
        {
        }
        key(Key6;Type,"Created Datetime")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        "Created Datetime" := CurrentDateTime();
        "User ID" := UserId;
    end;

    trigger OnModify()
    begin
        "Created Datetime" := CurrentDateTime();
        "User ID" := UserId;
    end;

    trigger OnRename()
    begin
        Error ('');
    end;
}

