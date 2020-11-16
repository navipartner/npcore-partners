table 6060110 "NPR TM Ticket Notif. Entry"
{
    // TM1.38/TSA/20181025  CASE 332109 Transport TM1.38 - 25 October 2018
    // TM1.39/TSA /20190109 CASE 310057 Added field "Notification Group Id" and "Admission Code"
    // TM1.45/TSA /20191107 CASE 374620 Added Notification Trigger::Stakeholder, "Admission Schedule Entry No.", "Det. Ticket Access Entry No.", "Ticket Trigger Type"
    // TM1.45/TSA /20191204 CASE 380754 Added "Notification Trigger"::Waiting List and "Ticket Trigger Type"::Added to WL and "Ticket Trigger Type"::Notified by WL and Waiting List Reference Code
    // TM90.1.46/TSA /20200127 CASE 387138 Added Published Ticket URL and options to "Notification Trigger", "Ticket Trigger Type"
    // TM90.1.46/TSA /20200127 CASE 387138 extended "Waiting List Reference Code" to code 20

    Caption = 'Ticket Notification Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; "Notification Group Id"; Integer)
        {
            Caption = 'Notification Group Id';
            DataClassification = CustomerContent;
        }
        field(20; "Date To Notify"; Date)
        {
            Caption = 'Date To Notify';
            DataClassification = CustomerContent;
        }
        field(30; "Notification Send Status"; Option)
        {
            Caption = 'Notification Send Status';
            DataClassification = CustomerContent;
            OptionCaption = 'Pending,Sent,Canceled,Failed,Not Sent';
            OptionMembers = PENDING,SENT,CANCELED,FAILED,NOT_SENT;
        }
        field(31; "Notification Sent At"; DateTime)
        {
            Caption = 'Notification Sent At';
            DataClassification = CustomerContent;
        }
        field(32; "Notification Sent By User"; Text[30])
        {
            Caption = 'Notification Sent By User';
            DataClassification = CustomerContent;
        }
        field(35; "Notification Trigger"; Option)
        {
            Caption = 'Notification Trigger';
            DataClassification = CustomerContent;
            OptionCaption = 'Not Applicable,eTicket Update,eTicket Create,Stakeholder,Waiting List,TicketServer';
            OptionMembers = NA,ETICKET_UPDATE,ETICKET_CREATE,STAKEHOLDER,WAITINGLIST,TICKETSERVER;
        }
        field(40; "Ticket Type Code"; Code[20])
        {
            Caption = 'Ticket Type Code';
            DataClassification = CustomerContent;
        }
        field(47; "Notification Process Method"; Option)
        {
            Caption = 'Notification Process Method';
            DataClassification = CustomerContent;
            OptionCaption = 'Manual,Inline,Batch';
            OptionMembers = MANUAL,INLINE,BATCH;
        }
        field(50; "Ticket Token"; Text[100])
        {
            Caption = 'Ticket Token';
            DataClassification = CustomerContent;
        }
        field(51; "Ticket Item No."; Code[20])
        {
            Caption = 'Ticket Item No.';
            DataClassification = CustomerContent;
        }
        field(52; "Ticket Variant Code"; Code[10])
        {
            Caption = 'Ticket Variant Code';
            DataClassification = CustomerContent;
        }
        field(53; "Ticket External Item No."; Code[20])
        {
            Caption = 'Ticket External Item No.';
            DataClassification = CustomerContent;
        }
        field(60; "Ticket No."; Code[20])
        {
            Caption = 'Ticket No.';
            DataClassification = CustomerContent;
        }
        field(65; "Ticket List Price"; Decimal)
        {
            Caption = 'Ticket List Price';
            DataClassification = CustomerContent;
        }
        field(67; "External Order No."; Code[20])
        {
            Caption = 'External Order No.';
            DataClassification = CustomerContent;
        }
        field(70; "Admission Code"; Code[20])
        {
            Caption = 'Admission Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR TM Admission";
        }
        field(80; "Notification Method"; Option)
        {
            Caption = 'Notification Method';
            DataClassification = CustomerContent;
            OptionCaption = ' ,E-Mail,SMS';
            OptionMembers = NA,EMAIL,SMS;
        }
        field(81; "Notification Address"; Text[80])
        {
            Caption = 'Notification Address';
            DataClassification = CustomerContent;
        }
        field(85; "Authorization Code"; Code[10])
        {
            Caption = 'Authorization Code';
            DataClassification = CustomerContent;
        }
        field(90; "Relevant Date"; Date)
        {
            Caption = 'Relevant Date';
            DataClassification = CustomerContent;
            Description = 'Local time';
        }
        field(91; "Relevant Time"; Time)
        {
            Caption = 'Relevant Time';
            DataClassification = CustomerContent;
            Description = 'Local time';
        }
        field(92; "Relevant Datetime"; DateTime)
        {
            Caption = 'Relevant Datetime';
            DataClassification = CustomerContent;
            Description = 'UTC';
        }
        field(95; "Expire Date"; Date)
        {
            Caption = 'Expire Date';
            DataClassification = CustomerContent;
            Description = 'Local time';
        }
        field(96; "Expire Time"; Time)
        {
            Caption = 'Expire Time';
            DataClassification = CustomerContent;
            Description = 'Local time';
        }
        field(97; "Expire Datetime"; DateTime)
        {
            Caption = 'Expire Datetime';
            DataClassification = CustomerContent;
            Description = 'UTC';
        }
        field(98; Voided; Boolean)
        {
            Caption = 'Voided';
            DataClassification = CustomerContent;
        }
        field(100; "External Ticket No."; Code[30])
        {
            Caption = 'External Ticket No.';
            DataClassification = CustomerContent;
        }
        field(105; "Ticket No. for Printing"; Text[50])
        {
            Caption = 'Ticket No. for Printing';
            DataClassification = CustomerContent;
        }
        field(110; "Admission Schedule Entry No."; Integer)
        {
            Caption = 'Admission Schedule Entry No.';
            DataClassification = CustomerContent;
        }
        field(115; "Det. Ticket Access Entry No."; Integer)
        {
            Caption = 'Det. Ticket Access Entry No.';
            DataClassification = CustomerContent;
        }
        field(150; Section; Text[30])
        {
            Caption = 'Section';
            DataClassification = CustomerContent;
        }
        field(151; Row; Text[30])
        {
            Caption = 'Row';
            DataClassification = CustomerContent;
        }
        field(152; Seat; Text[30])
        {
            Caption = 'Seat';
            DataClassification = CustomerContent;
        }
        field(160; "Ticket Holder E-Mail"; Text[80])
        {
            Caption = 'Ticket Holder E-Mail';
            DataClassification = CustomerContent;
        }
        field(165; "Ticket Holder Name"; Text[80])
        {
            Caption = 'Ticket Holder Name';
            DataClassification = CustomerContent;
        }
        field(170; "Ticket BOM Adm. Description"; Text[80])
        {
            Caption = 'Ticket Item Description';
            DataClassification = CustomerContent;
        }
        field(171; "Adm. Event Description"; Text[80])
        {
            Caption = 'Adm. Event Description';
            DataClassification = CustomerContent;
        }
        field(172; "Adm. Location Description"; Text[80])
        {
            Caption = 'Adm. Location Description';
            DataClassification = CustomerContent;
        }
        field(173; "Ticket BOM Description"; Text[80])
        {
            Caption = 'Ticket BOM Description';
            DataClassification = CustomerContent;
        }
        field(175; "Event Start Date"; Date)
        {
            Caption = 'Event Start Date';
            DataClassification = CustomerContent;
        }
        field(176; "Event Start Time"; Time)
        {
            Caption = 'Event Start Time';
            DataClassification = CustomerContent;
        }
        field(180; "Quantity To Admit"; Integer)
        {
            Caption = 'Quantity To Admit';
            DataClassification = CustomerContent;
        }
        field(190; "Waiting List Reference Code"; Code[20])
        {
            Caption = 'Waiting List Reference Code';
            DataClassification = CustomerContent;
        }
        field(200; "Failed With Message"; Text[250])
        {
            Caption = 'Failed With Message';
            DataClassification = CustomerContent;
        }
        field(210; "Ticket Trigger Type"; Option)
        {
            Caption = 'Ticket Trigger Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Reservation,Cancelation,Admitted,Departed,Added to Waiting List,Waitinglist Notification,Sales,Not Applicable,SellOut,Capacity to Waiting List';
            OptionMembers = RESERVE,CANCEL_RESERVE,ADMIT,DEPART,ADDED_TO_WL,NOTIFIED_BY_WL,SALES,NA,SELLOUT,CAPACITY_TO_WL;
        }
        field(405; "eTicket Type Code"; Text[30])
        {
            Caption = 'eTicket Type Code';
            DataClassification = CustomerContent;
        }
        field(410; "eTicket Pass Id"; Text[100])
        {
            Caption = 'Wallet Pass Id';
            DataClassification = CustomerContent;
        }
        field(420; "eTicket Pass Default URL"; Text[200])
        {
            Caption = 'Wallet Pass Default URL';
            DataClassification = CustomerContent;
        }
        field(421; "eTicket Pass Andriod URL"; Text[200])
        {
            Caption = 'Wallet Pass Andriod URL';
            DataClassification = CustomerContent;
        }
        field(422; "eTicket Pass Landing URL"; Text[200])
        {
            Caption = 'Wallet Pass Combine URL';
            DataClassification = CustomerContent;
        }
        field(430; "Published Ticket URL"; Text[200])
        {
            Caption = 'Published Ticket URL';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Ticket No.", "Notification Send Status")
        {
        }
        key(Key3; "eTicket Pass Id")
        {
        }
        key(Key4; "Ticket Token")
        {
        }
    }

    fieldgroups
    {
    }
}

