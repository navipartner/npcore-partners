table 6060110 "TM Ticket Notification Entry"
{
    // TM1.38/TSA/20181025  CASE 332109 Transport TM1.38 - 25 October 2018
    // TM1.39/TSA /20190109 CASE 310057 Added field "Notification Group Id" and "Admission Code"

    Caption = 'TM Ticket Notification Entry';

    fields
    {
        field(1;"Entry No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(10;"Notification Group Id";Integer)
        {
            Caption = 'Notification Group Id';
        }
        field(20;"Date To Notify";Date)
        {
            Caption = 'Date To Notify';
        }
        field(30;"Notification Send Status";Option)
        {
            Caption = 'Notification Send Status';
            OptionCaption = 'Pending,Sent,Canceled,Failed,Not Sent';
            OptionMembers = PENDING,SENT,CANCELED,FAILED,NOT_SENT;
        }
        field(31;"Notification Sent At";DateTime)
        {
            Caption = 'Notification Sent At';
        }
        field(32;"Notification Sent By User";Text[30])
        {
            Caption = 'Notification Sent By User';
        }
        field(35;"Notification Trigger";Option)
        {
            Caption = 'Notification Trigger';
            OptionCaption = 'Not Applicable,eTicket Update,eTicket Create';
            OptionMembers = NA,ETICKET_UPDATE,ETICKET_CREATE;
        }
        field(40;"Ticket Type Code";Code[20])
        {
            Caption = 'Ticket Type Code';
        }
        field(50;"Ticket Token";Text[100])
        {
            Caption = 'Ticket Token';
        }
        field(60;"Ticket No.";Code[20])
        {
            Caption = 'Ticket No.';
        }
        field(65;"Ticket List Price";Decimal)
        {
            Caption = 'Ticket List Price';
        }
        field(70;"Admission Code";Code[20])
        {
            Caption = 'Admission Code';
            TableRelation = "TM Admission";
        }
        field(80;"Notification Method";Option)
        {
            Caption = 'Notification Method';
            OptionCaption = ' ,E-Mail,SMS';
            OptionMembers = NA,EMAIL,SMS;
        }
        field(81;"Notification Address";Text[80])
        {
            Caption = 'Notification Address';
        }
        field(90;"Relevant Date";Date)
        {
            Caption = 'Relevant Date';
            Description = 'Local time';
        }
        field(91;"Relevant Time";Time)
        {
            Caption = 'Relevant Time';
            Description = 'Local time';
        }
        field(92;"Relevant Datetime";DateTime)
        {
            Caption = 'Relevant Datetime';
            Description = 'UTC';
        }
        field(95;"Expire Date";Date)
        {
            Caption = 'Expire Date';
            Description = 'Local time';
        }
        field(96;"Expire Time";Time)
        {
            Caption = 'Expire Time';
            Description = 'Local time';
        }
        field(97;"Expire Datetime";DateTime)
        {
            Caption = 'Expire Datetime';
            Description = 'UTC';
        }
        field(98;Voided;Boolean)
        {
            Caption = 'Voided';
        }
        field(100;"External Ticket No.";Code[30])
        {
            Caption = 'External Ticket No.';
        }
        field(105;"Ticket No. for Printing";Text[50])
        {
            Caption = 'Ticket No. for Printing';
        }
        field(150;Section;Text[30])
        {
            Caption = 'Section';
        }
        field(151;Row;Text[30])
        {
            Caption = 'Row';
        }
        field(152;Seat;Text[30])
        {
            Caption = 'Seat';
        }
        field(160;"Ticket Holder E-Mail";Text[80])
        {
            Caption = 'Ticket Holder E-Mail';
        }
        field(165;"Ticket Holder Name";Text[80])
        {
            Caption = 'Ticket Holder Name';
        }
        field(170;"Ticket BOM Adm. Description";Text[80])
        {
            Caption = 'Ticket Item Description';
        }
        field(171;"Adm. Event Description";Text[80])
        {
            Caption = 'Adm. Event Description';
        }
        field(172;"Adm. Location Description";Text[80])
        {
            Caption = 'Adm. Location Description';
        }
        field(173;"Ticket BOM Description";Text[80])
        {
            Caption = 'Ticket BOM Description';
        }
        field(175;"Event Start Date";Date)
        {
            Caption = 'Event Start Date';
        }
        field(176;"Event Start Time";Time)
        {
            Caption = 'Event Start Time';
        }
        field(180;"Quantity To Admit";Integer)
        {
            Caption = 'Quantity To Admit';
        }
        field(200;"Failed With Message";Text[250])
        {
            Caption = 'Failed With Message';
        }
        field(405;"eTicket Type Code";Text[30])
        {
            Caption = 'eTicket Type Code';
        }
        field(410;"eTicket Pass Id";Text[100])
        {
            Caption = 'Wallet Pass Id';
        }
        field(420;"eTicket Pass Default URL";Text[200])
        {
            Caption = 'Wallet Pass Default URL';
        }
        field(421;"eTicket Pass Andriod URL";Text[200])
        {
            Caption = 'Wallet Pass Andriod URL';
        }
        field(422;"eTicket Pass Landing URL";Text[200])
        {
            Caption = 'Wallet Pass Combine URL';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
        key(Key2;"Ticket No.","Notification Send Status")
        {
        }
        key(Key3;"eTicket Pass Id")
        {
        }
    }

    fieldgroups
    {
    }
}

