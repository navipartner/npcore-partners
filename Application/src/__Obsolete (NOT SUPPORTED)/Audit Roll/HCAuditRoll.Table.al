﻿table 6150901 "NPR HC Audit Roll"
{
    Access = Internal;
    Caption = 'HC Audit Roll';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteTag = '2023-06-28';
    ObsoleteReason = 'Not used anymore';
    PasteIsValid = false;

    fields
    {
        field(1; "Register No."; Code[10])
        {
            Caption = 'Cash Register No.';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; "Sales Ticket No."; Code[20])
        {
            Caption = 'Sales Ticket No.';
            DataClassification = CustomerContent;
            Editable = false;
            NotBlank = true;
        }
        field(3; "Sale Type"; Option)
        {
            Caption = 'Sale Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Sale,Payment,Debit Sale,Gift Voucher,Credit Voucher,Deposit,Out payment,Comment,,Open/Close';
            OptionMembers = Sale,Payment,"Debit Sale","Gift Voucher","Credit Voucher",Deposit,"Out payment",Comment,,"Open/Close";
        }
        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(5; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            InitValue = Item;
            OptionCaption = 'G/L,Item,Payment,Open/Close,Customer,Debit Sale,Cancelled,Comment';
            OptionMembers = "G/L",Item,Payment,"Open/Close",Customer,"Debit Sale",Cancelled,Comment;
        }
        field(6; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(7; Lokationskode; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[80])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(11; Unit; Text[10])
        {
            Caption = 'Unit';
            DataClassification = CustomerContent;
        }
        field(12; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(17; "VAT %"; Decimal)
        {
            Caption = 'VAT %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(19; "Line Discount %"; Decimal)
        {
            BlankZero = true;
            Caption = 'Line Discount %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            MaxValue = 100;
            MinValue = 0;
        }
        field(20; "Line Discount Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            BlankZero = true;
            Caption = 'Line Discount Amount';
            DataClassification = CustomerContent;
        }
        field(25; "Sale Date"; Date)
        {
            Caption = 'Sale Date';
            DataClassification = CustomerContent;
        }
        field(26; "Posted Doc. No."; Code[20])
        {
            Caption = 'Posted Doc. No.';
            DataClassification = CustomerContent;
        }
        field(30; Amount; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Amount';
            DataClassification = CustomerContent;
        }
        field(31; "Amount Including VAT"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Amount Including VAT';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 2;
        }
        field(40; "Department Code"; Code[10])
        {
            Caption = 'Department Code DONT USE';
            DataClassification = CustomerContent;
            Description = 'Not used. use "Shortcut Dimension 1 Code" instead';
        }
        field(43; "Serial No."; Code[20])
        {
            Caption = 'Serial No.';
            DataClassification = CustomerContent;
        }
        field(44; "Customer/Item Discount %"; Decimal)
        {
            Caption = 'Customer/Item Discount %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            MaxValue = 100;
            MinValue = 0;
        }
        field(48; "Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            DataClassification = CustomerContent;
        }
        field(49; "Gen. Prod. Posting Group"; Code[20])
        {
            Caption = 'Gen. Prod. Posting Group';
            DataClassification = CustomerContent;
        }
        field(50; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            DataClassification = CustomerContent;
        }
        field(51; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            DataClassification = CustomerContent;
        }
        field(52; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(55; Cost; Decimal)
        {
            Caption = 'Cost';
            DataClassification = CustomerContent;
        }
        field(59; "Gift voucher ref."; Code[20])
        {
            Caption = 'Gift voucher ref.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Gift voucher won''t be used anymore';
        }
        field(60; "Credit voucher ref."; Code[20])
        {
            Caption = 'Credit voucher ref.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Credit voucher won''t be used anymore';
        }
        field(70; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            DataClassification = CustomerContent;
        }
        field(71; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            DataClassification = CustomerContent;
        }
        field(75; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            DataClassification = CustomerContent;
        }
        field(85; "Tax Area Code"; Code[20])
        {
            Caption = 'Tax Area Code';
            DataClassification = CustomerContent;
            Description = '248534';
        }
        field(86; "Tax Liable"; Boolean)
        {
            Caption = 'Tax Liable';
            DataClassification = CustomerContent;
            Description = '248534';
        }
        field(87; "Tax Group Code"; Code[20])
        {
            Caption = 'Tax Group Code';
            DataClassification = CustomerContent;
            Description = '248534';
        }
        field(88; "Use Tax"; Boolean)
        {
            Caption = 'Use Tax';
            DataClassification = CustomerContent;
            Description = '248534';
        }
        field(90; "Return Reason Code"; Code[10])
        {
            Caption = 'Return Reason Code';
            DataClassification = CustomerContent;
        }
        field(95; "Clustered Key"; Integer)
        {
            AutoIncrement = true;
            Caption = 'Clustered Key';
            DataClassification = CustomerContent;
        }
        field(100; "Unit Cost"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            Caption = 'Unit Cost';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(101; "System-Created Entry"; Boolean)
        {
            Caption = 'System-Created Entry';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(102; "Variant Code"; Code[20])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
        }
        field(105; "Allocated No."; Code[10])
        {
            Caption = 'Allocated No.';
            DataClassification = CustomerContent;
        }
        field(107; "Document Type"; Option)
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Invoice,Order,Credit Memo,Return Order';
            OptionMembers = Faktura,Ordre,Kreditnota,Returordre;
        }
        field(110; "Retail Document Type"; Option)
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
            NotBlank = true;
            OptionCaption = ' ,Selection,Retail Order,Wish,Customization,Delivery,Rental contract,Purchase contract,Qoute';
            OptionMembers = " ","Selection Contract","Retail Order",Wish,Customization,Delivery,"Rental contract","Purchase contract",Quote;
        }
        field(111; "Retail Document No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(140; "Sales Document Type"; Integer)
        {
            Caption = 'Sales Document Type';
            DataClassification = CustomerContent;
        }
        field(141; "Sales Document No."; Code[20])
        {
            Caption = 'Sales Document No.';
            DataClassification = CustomerContent;
        }
        field(143; "Sales Document Prepayment"; Boolean)
        {
            Caption = 'Sales Document Prepayment';
            DataClassification = CustomerContent;
        }
        field(144; "Sales Doc. Prepayment %"; Decimal)
        {
            Caption = 'Sales Doc. Prepayment %';
            DataClassification = CustomerContent;
        }
        field(145; "Sales Document Invoice"; Boolean)
        {
            Caption = 'Sales Document Invoice';
            DataClassification = CustomerContent;
        }
        field(146; "Sales Document Ship"; Boolean)
        {
            Caption = 'Sales Document Ship';
            DataClassification = CustomerContent;
        }
        field(160; "POS Sale ID"; Integer)
        {
            Caption = 'POS Sale ID';
            DataClassification = CustomerContent;
            Description = '262628';
        }
        field(200; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
        }
        field(400; "Discount Type"; Option)
        {
            Caption = 'Discount Type';
            DataClassification = CustomerContent;
            Description = '264918';
            OptionCaption = ' ,Period,Mixed,Multiple Unit,Salesperson Discount,Inventory,,Rounding,Combination,Customer';
            OptionMembers = " ",Campaign,Mix,Quantity,Manual,"BOM List",,Rounding,Combination,Customer;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            DataClassification = CustomerContent;
        }
        field(500; "Cash Terminal Approved"; Boolean)
        {
            Caption = 'Cash Terminal Approved';
            DataClassification = CustomerContent;
        }
        field(550; "Drawer Opened"; Boolean)
        {
            Caption = 'Drawer Opened';
            DataClassification = CustomerContent;
            Description = 'NPR4.001.000, for indication of opening on drawer.';
        }
        field(1000; "Starting Time"; Time)
        {
            Caption = 'Starting Time';
            DataClassification = CustomerContent;
        }
        field(1001; "Closing Time"; Time)
        {
            Caption = 'Closing Time';
            DataClassification = CustomerContent;
        }
        field(1002; "Receipt Type"; Option)
        {
            Caption = 'Ticket Type';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Negative Sales Ticket,Change,Outpayment,Return Item,Sales in Negative Receipt';
            OptionMembers = " ","Negative receipt","Change money",Outpayment,"Return items","Sales in negative receipt";
        }
        field(2000; "Closing Cash"; Decimal)
        {
            Caption = 'Closing Cash';
            DataClassification = CustomerContent;
        }
        field(2001; "Opening Cash"; Decimal)
        {
            Caption = 'Opening Cash';
            DataClassification = CustomerContent;
        }
        field(2002; "Transferred to Balance Account"; Decimal)
        {
            Caption = 'Transferred to Balance Account';
            DataClassification = CustomerContent;
        }
        field(2003; Difference; Decimal)
        {
            Caption = 'Difference';
            DataClassification = CustomerContent;
        }
        field(2005; "Change Register"; Decimal)
        {
            Caption = 'Change Cash Register';
            DataClassification = CustomerContent;
        }
        field(3000; Posted; Boolean)
        {
            Caption = 'Posted';
            DataClassification = CustomerContent;
        }
        field(3001; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(3002; "Internal Posting No."; Integer)
        {
            Caption = 'Internal Posting No.';
            DataClassification = CustomerContent;
        }
        field(5002; Color; Code[20])
        {
            Caption = 'Color';
            DataClassification = CustomerContent;
        }
        field(5003; Size; Code[20])
        {
            Caption = 'Size';
            DataClassification = CustomerContent;
        }
        field(5004; "Serial No. not Created"; Code[30])
        {
            Caption = 'Serial No. not Created';
            DataClassification = CustomerContent;
        }
        field(5020; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
        }
        field(5021; "Customer Type"; Option)
        {
            Caption = 'Customer Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Ord.,Cash';
            OptionMembers = Alm,Kontant;
        }
        field(5022; Reference; Text[50])
        {
            Caption = 'Reference';
            DataClassification = CustomerContent;
            Description = 'NPR5.48';
        }
        field(5024; "Payment Type No."; Code[10])
        {
            Caption = 'Payment Type No.';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(6000; "N3 Debit Sale Conversion"; Boolean)
        {
            Caption = 'N3 Debit Sale Conversion';
            DataClassification = CustomerContent;
        }
        field(6001; "Buffer Document Type"; Option)
        {
            Caption = 'Buffer Document Type';
            DataClassification = CustomerContent;
            Description = 'NP-retail 1.8';
            OptionCaption = ' ,Payment,Invoice,Credit Note,Interest Note,Reminder';
            OptionMembers = " ",Betaling,Faktura,Kreditnota,Rentenota,Rykker;
        }
        field(6002; "Buffer ID"; Code[20])
        {
            Caption = 'Buffer ID';
            DataClassification = CustomerContent;
            Description = 'NP-retail 1.8';
        }
        field(6003; "Buffer Invoice No."; Code[20])
        {
            Caption = 'Buffer Invoice No.';
            DataClassification = CustomerContent;
            Description = 'NP-retail 1.8';
        }
        field(6004; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            DataClassification = CustomerContent;
        }
        field(6005; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
            DataClassification = CustomerContent;
            Description = 'NPR5.23';
        }
        field(6007; "Money bag no."; Code[20])
        {
            Caption = 'Money bag no.';
            DataClassification = CustomerContent;
        }
        field(6008; "External Document No."; Code[20])
        {
            Caption = 'External Document No.';
            DataClassification = CustomerContent;
        }
        field(6009; LineCounter; Decimal)
        {
            Caption = 'LineCounter';
            DataClassification = CustomerContent;
            Description = 'Hack til hurtigt count vha. sum index fields.';
            InitValue = 1;
        }
        field(6015; Offline; Boolean)
        {
            Caption = 'Offline';
            DataClassification = CustomerContent;
        }
        field(6025; "Customer Post Code"; Code[20])
        {
            Caption = 'Customer Post Code';
            DataClassification = CustomerContent;
        }
        field(6030; "Currency Amount"; Decimal)
        {
            Caption = 'Currency Amount';
            DataClassification = CustomerContent;
        }
        field(6035; "Item Entry Posted"; Boolean)
        {
            Caption = 'Item Entry Posted';
            DataClassification = CustomerContent;
            InitValue = false;
        }
        field(6055; Send; Date)
        {
            Caption = 'Send';
            DataClassification = CustomerContent;
            Description = 'Bruges ifm. replikering til at afg¢ren om det felt er udlæst eller ej';
        }
        field(6060; "Offline receipt no."; Code[20])
        {
            Caption = 'Offline receipt no.';
            DataClassification = CustomerContent;
        }
        field(10003; Balancing; Boolean)
        {
            Caption = 'Balancing';
            DataClassification = CustomerContent;
        }
        field(10004; Vendor; Code[20])
        {
            Caption = 'Vendor';
            DataClassification = CustomerContent;
        }
        field(10013; "Invoiz Guid"; Text[150])
        {
            Caption = 'Invoiz Guid';
            DataClassification = CustomerContent;
        }
        field(10020; "No. Printed"; Integer)
        {
            Caption = 'No. Printed';
            DataClassification = CustomerContent;
            InitValue = 0;
        }
    }

    keys
    {
        key(Key1; "Register No.", "Sales Ticket No.", "Sale Type", "Line No.", "No.", "Sale Date")
        {
            SumIndexFields = "Amount Including VAT";
        }
        key(Key2; "Clustered Key")
        {
        }
        key(Key3; "Register No.", "Sales Ticket No.", "Sale Type", Type, "No.")
        {
            MaintainSQLIndex = false;
            SumIndexFields = "Amount Including VAT", "Currency Amount", "Line Discount Amount", Cost, Amount, "Unit Cost", Quantity;
        }
        key(Key4; "Register No.", "Sale Type", Type, "No.", "Sale Date", "Discount Type", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount Including VAT", Amount, Cost, "Line Discount Amount";
        }
        key(Key5; "Register No.", "Sales Ticket No.", "Sale Type", Type)
        {
            Enabled = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount Including VAT", "Line Discount Amount", Cost, Amount, "Unit Cost";
        }
        key(Key6; "Register No.", Posted, "Sale Date", Type, "Credit voucher ref.")
        {
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Gift voucher won''t be used anymore';
        }
        key(Key7; "Sale Type", Type, "No.", Posted)
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount Including VAT", "Currency Amount";
        }
        key(Key8; "Register No.", "Sales Ticket No.", "Sale Date", "Sale Type", Type, "No.")
        {
            MaintainSQLIndex = false;
            SumIndexFields = "Amount Including VAT", Cost, "Line Discount Amount", Amount;
        }
        key(Key9; Posted, "Serial No.")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = Quantity;
        }
        key(Key10; "Register No.", "Sales Ticket No.", Type, "Closing Time", Description, "Sale Date", "Salesperson Code")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = true;
            SumIndexFields = "Amount Including VAT", "Line Discount Amount";
        }
        key(Key11; Send, Type, "Sale Type")
        {
            Enabled = false;
            MaintainSQLIndex = false;
        }
        key(Key12; Offline, "Offline receipt no.", Posted, "Sale Type")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
        }
        key(Key13; "Sales Ticket No.", Type)
        {
        }
        key(Key14; "Sale Date", "Sale Type", Type, "Gift voucher ref.", "Register No.", "Closing Time", "Salesperson Code", "Receipt Type", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount Including VAT", Quantity, "Line Discount Amount", Amount, Cost;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Gift voucher won''t be used anymore';
        }
        key(Key15; "Register No.", "Sale Date", "Sale Type", Type, Quantity, "Receipt Type", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount Including VAT", Amount, Cost;
        }
        key(Key16; "Sale Type", Type, "Starting Time", "Closing Time", "Sale Date", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", Lokationskode)
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount Including VAT", Quantity, LineCounter;
        }
        key(Key17; "Retail Document Type", "Retail Document No.")
        {
            MaintainSQLIndex = false;
        }
        key(Key18; "Salesperson Code", "Register No.", "Sale Date")
        {
            SumIndexFields = Amount;
        }
        key(Key19; "Sale Type", Type, "Item Entry Posted")
        {
            MaintainSQLIndex = false;
        }
        key(Key20; "Sale Date", "Invoiz Guid")
        {
            MaintainSQLIndex = false;
        }
        key(Key21; "Customer No.")
        {
        }
        key(Key22; "Register No.", "Sales Ticket No.", "Line No.")
        {
            SumIndexFields = "Amount Including VAT", Amount, Cost;
        }
        key(Key23; "Register No.", "Sales Ticket No.", "Sale Type", "Cash Terminal Approved")
        {
            SumIndexFields = "Amount Including VAT";
        }
        key(Key24; "Sales Ticket No.", "Line No.")
        {
        }
        key(Key25; "Sale Date", "Sales Ticket No.", "Line No.")
        {
        }
    }
}

