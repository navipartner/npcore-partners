table 6151293 "NPR External POS Sale Buf"
{
    Access = Public;
    DataClassification = CustomerContent;
    TableType = Temporary;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(10; "Register No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit";
        }
        field(20; "Sales Ticket No."; Code[20])
        {
            Caption = 'Sales Ticket No.';
            DataClassification = CustomerContent;
        }

        field(30; "POS Store Code"; Code[10])
        {
            Caption = 'POS Store Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.30';
            TableRelation = "NPR POS Store";
        }

        field(40; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser".Code;
        }

        field(50; "Date"; Date)
        {
            Caption = 'Date';
            DataClassification = CustomerContent;
        }

        field(60; "Start Time"; Time)
        {
            Caption = 'Start Time';
            DataClassification = CustomerContent;
        }

        field(65; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
        }

        field(70; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";
        }

        field(81; "Country Code"; Code[10])
        {
            Caption = 'Country Code';
            DataClassification = CustomerContent;
            TableRelation = "Country/Region";
        }

        field(85; "Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            DataClassification = CustomerContent;
            Description = 'NPR5.31';
            TableRelation = "Gen. Business Posting Group";
        }
        field(90; Reference; Text[35])
        {
            Caption = 'Reference';
            DataClassification = CustomerContent;
        }

        field(95; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            DataClassification = CustomerContent;
        }
        field(96; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            DataClassification = CustomerContent;
        }
        field(110; "Header Type"; Enum "NPR POS Sale Type")
        {
            Caption = 'Sale Type';
            DataClassification = CustomerContent;
        }
        field(128; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
            DataClassification = CustomerContent;
        }

        field(141; "Tax Area Code"; Code[20])
        {
            Caption = 'Tax Area Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.31';
            TableRelation = "Tax Area";
        }
        field(142; "Tax Liable"; Boolean)
        {
            Caption = 'Tax Liable';
            DataClassification = CustomerContent;
            Description = 'NPR5.31';
        }
        field(143; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            DataClassification = CustomerContent;
            Description = 'NPR5.31';
            TableRelation = "VAT Business Posting Group";
        }

        field(120; "Prices Including VAT"; Boolean)
        {
            Caption = 'Prices Including VAT';
            DataClassification = CustomerContent;
        }

        field(145; "Event No."; Code[20])
        {
            Caption = 'Event No.';
            DataClassification = CustomerContent;
            TableRelation = Job where("NPR Event" = const(true));
        }
        field(210; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(300; "External Pos Id"; Text[50])
        {
            Caption = 'External Pos Id';
            DataClassification = CustomerContent;
        }
        field(301; "Email Template"; Code[20])
        {
            Caption = 'Email Template';
            DataClassification = CustomerContent;
            TableRelation = "NPR E-mail Template Header";
        }
        field(302; "SMS Template"; Code[20])
        {
            Caption = 'SMS Template';
            DataClassification = CustomerContent;
            TableRelation = "NPR SMS Template Header";
        }
        field(303; "External Pos Sale Id"; Text[50])
        {
            Caption = 'External Pos Sale Id';
            DataClassification = CustomerContent;
        }

        field(304; "Send Receipt: Email"; Boolean)
        {
            Caption = 'Send Receipt: Email';
            DataClassification = CustomerContent;
        }
        field(305; "Send Receipt: SMS"; Boolean)
        {
            Caption = 'Send Receipt: SMS';
            DataClassification = CustomerContent;
        }
        field(306; "Phone Number"; Text[30])
        {
            Caption = 'Phone Number';
            DataClassification = CustomerContent;
        }
        field(307; "E-mail"; Text[250])
        {
            Caption = 'E-mail';
            DataClassification = CustomerContent;
        }
        field(308; "SMS Receipt Log"; Integer)
        {
            Caption = 'SMS Receipt Log';
            DataClassification = CustomerContent;
            TableRelation = "NPR SMS Log";
        }
        field(309; "Email Receipt Sent"; Boolean)
        {
            Caption = 'E-mail Receipt Sent';
            DataClassification = CustomerContent;
        }
        field(310; "SMS Receipt Sent"; Boolean)
        {
            Caption = 'SMS Receipt Sent';
            DataClassification = CustomerContent;
        }

        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Dimension Set Entry";
        }
        field(1550; "Converted To POS Entry"; Boolean)
        {
            Caption = 'Converted To POS Entry';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(1551; "Has Conversion Error"; Boolean)
        {
            Caption = 'Has Conversion Error';
            DataClassification = SystemMetadata;
        }

        field(1552; "Last Conversion Error Message"; Text[250])
        {
            Caption = 'Last Conversion Error Message';
            DataClassification = SystemMetadata;
        }
        field(1560; "POS Entry System Id"; Guid)
        {
            Caption = 'POS Entry System Id';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(1561; "POS Entry No."; Integer)
        {
            Caption = 'POS Entry No.';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "NPR POS Entry";
        }
        field(6010; "Sales Channel"; Code[20])
        {
            Caption = 'Sales Channel';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Loyalty Sales Channel".Code;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }

        key(Key2; "Register No.", "Sales Ticket No.")
        {
        }

        key(Key3; "Converted To POS Entry", "Has Conversion Error", "POS Store Code")
        {
        }
        key(Key4; "Send Receipt: SMS", "SMS Receipt Sent")
        {

        }
        key(Key5; "Send Receipt: Email", "Email Receipt Sent")
        {

        }
        key(Key6; "POS Entry No.")
        {

        }

    }
}
