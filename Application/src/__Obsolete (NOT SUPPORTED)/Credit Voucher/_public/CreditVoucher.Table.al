table 6014408 "NPR Credit Voucher"
{
    Caption = 'Credit Voucher';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'This table won''t be used anymore.';
    ObsoleteTag = 'NPR Register';

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
        field(5; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
        }
        field(6; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
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
            Description = 'NPR5.38';
        }
        field(11; Address; Text[100])
        {
            Caption = 'Address';
            DataClassification = CustomerContent;
            Description = 'NPR5.38';
        }
        field(12; "Post Code"; Code[20])
        {
            Caption = 'Post Code';
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
        field(25; "Cashed Salesperson"; Code[20])
        {
            Caption = 'Cashed Salesperson';
            DataClassification = CustomerContent;
        }
        field(26; "Cashed in Global Dim 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
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
        field(32; Blocked; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;
        }
        field(33; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
            DataClassification = CustomerContent;
        }
        field(34; Reference; Text[50])
        {
            Caption = 'Reference';
            DataClassification = CustomerContent;
        }
        field(35; Nummerserie; Code[10])
        {
            Caption = 'Numberserie';
            DataClassification = CustomerContent;
        }
        field(36; "Customer No"; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
        }
        field(37; Invoiced; Boolean)
        {
            Caption = 'Invoiced';
            DataClassification = CustomerContent;
        }
        field(38; "Invoiced on enclosure"; Option)
        {
            Caption = 'Invoiced on enclosure';
            DataClassification = CustomerContent;
            OptionCaption = 'Offer,Order,Invoice,Creditnote,Requisition Worksheet';
            OptionMembers = Tilbud,Ordre,Faktura,Kreditnota,Rammeordre;
        }
        field(39; "Invoiced on enclosure no."; Code[20])
        {
            Caption = 'Invoiced on enclosure no.';
            DataClassification = CustomerContent;
        }
        field(40; "Checked external via enclosure"; Code[20])
        {
            Caption = 'Checked external via enclosure No';
            DataClassification = CustomerContent;
        }
        field(41; "Issued on Drawer No"; Code[10])
        {
            Caption = 'Issued on Drawer No';
            DataClassification = CustomerContent;
        }
        field(42; "Issued on Ticket No"; Code[20])
        {
            Caption = 'Issued on Ticket No';
            DataClassification = CustomerContent;
        }
        field(43; "Issued Audit Roll Type"; Integer)
        {
            Caption = 'Issued Audit Roll Type';
            DataClassification = CustomerContent;
        }
        field(44; "Issued Audit Roll Line"; Integer)
        {
            Caption = 'Issued Audit Roll Line';
            DataClassification = CustomerContent;
        }
        field(45; "Checked Audit"; Integer)
        {
            Caption = 'Checked Audit';
            DataClassification = CustomerContent;
        }
        field(46; "Check Audit Roll Line"; Integer)
        {
            Caption = 'Check Audit Roll Line';
            DataClassification = CustomerContent;
        }
        field(47; "External Credit Voucher"; Boolean)
        {
            Caption = 'External Gift Voucher';
            DataClassification = CustomerContent;
        }
        field(48; "Status manually changed on"; Date)
        {
            Caption = 'Status manually changed on';
            DataClassification = CustomerContent;
        }
        field(49; "Status manually changed by"; Code[20])
        {
            Caption = 'Status manually changed by';
            DataClassification = CustomerContent;
        }
        field(50; "Customer Type"; Option)
        {
            Caption = 'Customer Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Ordinary,Cash';
            OptionMembers = Alm,Kontant;
        }
        field(51; "Cashed in store"; Code[30])
        {
            Caption = 'Cashed in store';
            DataClassification = CustomerContent;
        }
        field(53; "External no"; Code[20])
        {
            Caption = 'Alien no';
            DataClassification = CustomerContent;
        }
        field(54; "Cancelled by salesperson"; Code[20])
        {
            Caption = 'Cancelled by salesperson';
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
        field(6151405; "External Credit Voucher No."; Code[10])
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

