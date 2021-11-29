table 6060110 "NPR TM Ticket Notif. Entry"
{
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
        field(21; "Time To Notify"; Time)
        {
            Caption = 'Time To Notify';
            DataClassification = CustomerContent;
        }
        field(30; "Notification Send Status"; Enum "NPR TM Not. Send Status")
        {
            Caption = 'Notification Send Status';
            DataClassification = CustomerContent;
        }
        field(31; "Notification Sent At"; DateTime)
        {
            Caption = 'Notification Sent At';
            DataClassification = CustomerContent;
        }
        field(32; "Notification Sent By User"; Text[30])
        {
            Caption = 'Notification Sent By User';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(35; "Notification Trigger"; Enum "NPR TM Not. Trigger")
        {
            Caption = 'Notification Trigger';
            DataClassification = CustomerContent;
        }
        field(40; "Ticket Type Code"; Code[20])
        {
            Caption = 'Ticket Type Code';
            DataClassification = CustomerContent;
        }
        field(45; "Template Code"; Code[10])
        {
            Caption = 'Template Code';
            DataClassification = CustomerContent;
        }

        field(47; "Notification Process Method"; Enum "NPR TM Not. Process Method")
        {
            Caption = 'Notification Process Method';
            DataClassification = CustomerContent;
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
        field(53; "Ticket External Item No."; Code[50])
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
        field(75; "Detention Time Seconds"; Integer)
        {
            Caption = 'Detention Time Seconds';
            DataClassification = CustomerContent;
        }
        field(76; "Notification Profile Code"; Code[10])
        {
            Caption = 'Notification Profile Code';
            DataClassification = CustomerContent;
        }
        field(80; "Notification Method"; Enum "NPR TM Not. Method")
        {
            Caption = 'Notification Method';
            DataClassification = CustomerContent;
        }
        field(81; "Notification Address"; Text[100])
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
        field(120; "Extra Text"; Text[200])
        {
            Caption = 'Extra Text';
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
        field(160; "Ticket Holder E-Mail"; Text[100])
        {
            Caption = 'Ticket Holder E-Mail';
            DataClassification = CustomerContent;
        }
        field(165; "Ticket Holder Name"; Text[100])
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
        field(173; "Ticket BOM Description"; Text[100])
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
        field(210; "Ticket Trigger Type"; Enum "NPR TM Not. Trigger Type")
        {
            Caption = 'Ticket Trigger Type';
            DataClassification = CustomerContent;
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
        key(Key5; SystemModifiedAt)
        {
        }
    }

    fieldgroups
    {
    }
}