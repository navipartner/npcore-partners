table 6014409 "NPR Gift Voucher"
{
    Caption = 'Gift Voucher';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(2; "Register No."; Code[10])
        {
            Caption = 'Cash Register No.';
            DataClassification = CustomerContent;
        }
        field(3; "Sales Ticket No."; Code[20])
        {
            Caption = 'Sales Ticket No.';
            DataClassification = CustomerContent;
        }
        field(4; "Issue Date"; Date)
        {
            Caption = 'Issue Date';
            DataClassification = CustomerContent;
        }
        field(5; "Salesperson Code"; Code[10])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
        }
        field(6; "Shortcut Dimension 1 Code"; Code[20])
        {
            Caption = 'Shortcut Dimension 1 Code';
            DataClassification = CustomerContent;
        }
        field(7; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
        }
        field(8; Status; Option)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            OptionCaption = 'Open,Cashed,Cancelled';
            OptionMembers = Open,Cashed,Cancelled;
        }
        field(9; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
        }
        field(10; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(11; Address; Text[100])
        {
            Caption = 'Address';
            DataClassification = CustomerContent;
        }
        field(12; "ZIP Code"; Code[20])
        {
            Caption = 'ZIP Code';
            DataClassification = CustomerContent;
        }
        field(13; City; Text[50])
        {
            Caption = 'City';
            DataClassification = CustomerContent;
        }
        field(22; "Cashed on Register No."; Code[10])
        {
            Caption = 'Cashed on Cash Register No.';
            DataClassification = CustomerContent;
        }
        field(23; "Cashed on Sales Ticket No."; Code[20])
        {
            Caption = 'Cashed on Sales Ticket No.';
            DataClassification = CustomerContent;
        }
        field(24; "Cashed Date"; Date)
        {
            Caption = 'Cashed Date';
            DataClassification = CustomerContent;
        }
        field(25; "Cashed Salesperson"; Code[10])
        {
            Caption = 'Cashed Salesperson';
            DataClassification = CustomerContent;
        }
        field(26; "Cashed in Global Dim 1 Code"; Code[20])
        {
            Caption = 'Cashed in Department Code';
            DataClassification = CustomerContent;
        }
        field(27; "Cashed in Location Code"; Code[10])
        {
            Caption = 'Cashed in Location Code';
            DataClassification = CustomerContent;
        }
        field(30; "Cashed External"; Boolean)
        {
            Caption = 'Cashed External';
            DataClassification = CustomerContent;
        }
        field(32; "No. Series"; Code[10])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
        }
        field(33; Blocked; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;
        }
        field(34; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
            DataClassification = CustomerContent;
        }
        field(35; Reference; Text[50])
        {
            Caption = 'Reference';
            DataClassification = CustomerContent;
        }
        field(36; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
        }
        field(37; Invoiced; Boolean)
        {
            Caption = 'Invoiced';
            DataClassification = CustomerContent;
        }
        field(38; "Invoiced by Document Type"; Option)
        {
            Caption = 'Invoiced by Document Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Offer,Order,Invoice,Creditnote,Requisition Worksheet';
            OptionMembers = Tilbud,Ordre,Faktura,Kreditnota,Rammeordre;
        }
        field(39; "Invoiced by Document No."; Code[20])
        {
            Caption = 'Invoiced by Document No.';
            DataClassification = CustomerContent;
        }
        field(40; "Cashed Externaly on Doc. No."; Code[20])
        {
            Caption = 'Cashed Externaly on Doc. No.';
            DataClassification = CustomerContent;
        }
        field(41; "Cashed Audit Roll Type"; Integer)
        {
            Caption = 'Cashed Audit Roll Type';
            DataClassification = CustomerContent;
        }
        field(42; "Cashed Audit Roll Line"; Integer)
        {
            Caption = 'Cashed Audit Roll Line';
            DataClassification = CustomerContent;
        }
        field(43; "Issuing Register No."; Code[10])
        {
            Caption = 'Issuing Cash Register No.';
            DataClassification = CustomerContent;
        }
        field(44; "Issuing Sales Ticket No."; Code[20])
        {
            Caption = 'Issuing Sales Ticket No.';
            DataClassification = CustomerContent;
        }
        field(45; "Issuing Audit Roll Type"; Integer)
        {
            Caption = 'Issuing Audit Roll Type';
            DataClassification = CustomerContent;
        }
        field(46; "Issuing Audit Roll Line"; Integer)
        {
            Caption = 'Issuing Audit Roll Line';
            DataClassification = CustomerContent;
        }
        field(47; "External Gift Voucher"; Boolean)
        {
            Caption = 'External Gift Voucher';
            DataClassification = CustomerContent;
        }
        field(48; "Man. Change of Status Date"; Date)
        {
            Caption = 'Man. Change of Status Date';
            DataClassification = CustomerContent;
        }
        field(49; "Status Changed Man. by"; Code[20])
        {
            Caption = 'Status Changed Man. by';
            DataClassification = CustomerContent;
        }
        field(50; "Customer Type"; Option)
        {
            Caption = 'Customer Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Ordinary,Cash';
            OptionMembers = Alm,Kontant;
        }
        field(51; "Cashed in Store"; Code[20])
        {
            Caption = 'Cashed in Store';
            DataClassification = CustomerContent;
        }
        field(53; "External No."; Code[20])
        {
            Caption = 'External No.';
            DataClassification = CustomerContent;
        }
        field(54; "Canceling Salesperson"; Code[20])
        {
            Caption = 'Canceling Salesperson';
            DataClassification = CustomerContent;
        }
        field(55; "Created in Company"; Code[30])
        {
            Caption = 'Created in Company';
            DataClassification = CustomerContent;
        }
        field(56; "Offline - No."; Code[20])
        {
            Caption = 'Offline - No.';
            DataClassification = CustomerContent;
        }
        field(57; "Primary Key Length"; Integer)
        {
            Caption = 'Primary Key Length';
            DataClassification = CustomerContent;
        }
        field(58; Offline; Boolean)
        {
            Caption = 'Offline';
            DataClassification = CustomerContent;
        }
        field(59; "Shortcut Dimension 2 Code"; Code[20])
        {
            Caption = 'Shortcut Dimension 2 Code';
            DataClassification = CustomerContent;
        }
        field(60; "Cashed in Global Dim 2 Code"; Code[20])
        {
            Caption = 'Cashed in Department Code';
            DataClassification = CustomerContent;
        }
        field(61; "Payment Type No."; Code[20])
        {
            Caption = 'Payment Type No.';
            DataClassification = CustomerContent;
        }
        field(62; "Exported date"; Date)
        {
            Caption = 'Exported the';
            DataClassification = CustomerContent;
        }
        field(63; "Secret Code"; Code[6])
        {
            Caption = 'Secret Code';
            DataClassification = CustomerContent;
        }
        field(70; "Cashed POS Entry No."; Integer)
        {
            Caption = 'Cashed POS Entry No.';
            DataClassification = CustomerContent;
        }
        field(71; "Cashed POS Payment Line No."; Integer)
        {
            Caption = 'Cashed POS Payment Line No.';
            DataClassification = CustomerContent;
        }
        field(72; "Cashed POS Unit No."; Code[10])
        {
            Caption = 'Cashed POS Unit No.';
            DataClassification = CustomerContent;
        }
        field(75; "Issuing POS Entry No"; Integer)
        {
            Caption = 'Issuing POS Entry No';
            DataClassification = CustomerContent;
        }
        field(76; "Issuing POS Sale Line No."; Integer)
        {
            Caption = 'Issuing POS Sale Line No.';
            DataClassification = CustomerContent;
        }
        field(77; "Issuing POS Unit No."; Code[10])
        {
            Caption = 'Issuing POS Unit No.';
            DataClassification = CustomerContent;
        }
        field(6014400; "No. Printed"; Integer)
        {
            Caption = 'No. Printed';
            DataClassification = CustomerContent;
        }
        field(6151400; "Voucher No."; Code[20])
        {
            Caption = 'Voucher No.';
            DataClassification = CustomerContent;
        }
        field(6151405; "External Gift Voucher No."; Code[10])
        {
            Caption = 'External Credit Voucher No.';
            DataClassification = CustomerContent;
        }
        field(6151410; "External Reference No."; Code[30])
        {
            Caption = 'External Reference No.';
            DataClassification = CustomerContent;
        }
        field(6151415; "Expire Date"; Date)
        {
            Caption = 'Expire Date';
            DataClassification = CustomerContent;
        }
        field(6151420; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
        }
        field(6151425; "Sales Order No."; Code[20])
        {
            Caption = 'Sales Order No.';
            DataClassification = CustomerContent;
        }
        field(6151430; "Gift Voucher Message"; BLOB)
        {
            Caption = 'Message';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
    }

    fieldgroups
    {
    }
}

