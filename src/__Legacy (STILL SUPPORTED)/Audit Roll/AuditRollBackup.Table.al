table 6014538 "NPR Audit Roll Backup"
{
    // NPR5.01/RMT/20160217 CASE 234145 Change field "Register No." property "SQL Data Type" from Variant to <Undefined>
    //                                  Change field "Sales Ticket No." property "SQL Data Type" from Variant to <Undefined>
    //                                  NOTE: requires data upgrade
    // NPR5.23/MHA/20160530 CASE 242929 Field 6005 "Description 2" length increased from 30 to 50
    // NPR5.27/LS  /20161020 CASE 252997 Changed LookupPageID and DrillDownPageID to "Audit Roll Backup List" from "Audit Roll"
    // NPR5.30/TJ  /20170215 CASE 265504 Changed ENU captions on fields with word Register in their name
    // NPR5.38/TJ  /20171218  CASE 225415 Renumbered fields from range 50xxx to range 60144xx
    // NPR5.39/TJ  /20180206  CASE 302634 Changed OptionString property of field 3 "Sale Type" to english version
    // NPR5.43/JDH /20180620 CASE 317453 Removed non existing table relation from Field 40 (ref to old Department table 11)

    Caption = 'Audit Roll Backup';
    DrillDownPageID = "NPR Audit Roll Backup List";
    LookupPageID = "NPR Audit Roll Backup List";
    PasteIsValid = false;

    fields
    {
        field(1; "Register No."; Code[10])
        {
            Caption = 'Cash Register No.';
            NotBlank = true;
            TableRelation = "NPR Register";

            trigger OnValidate()
            var
                Rapportvalg: Record "NPR Report Selection Retail";
            begin
            end;
        }
        field(2; "Sales Ticket No."; Code[20])
        {
            Caption = 'Sales Ticket No.';
            Editable = false;
            NotBlank = true;
        }
        field(3; "Sale Type"; Option)
        {
            Caption = 'Sale Type';
            OptionCaption = 'Sale,Payment,Debit Sale,Gift Voucher,Credit Voucher,Deposit,Out payment,Comment,,Open/Close';
            OptionMembers = Sale,Payment,"Debit Sale","Gift Voucher","Credit Voucher",Deposit,"Out payment",Comment,,"Open/Close";
        }
        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(5; Type; Option)
        {
            Caption = 'Type';
            InitValue = Item;
            OptionCaption = 'G/L,Item,Payment,Open/Close,Customer,Debit Sale,Cancelled,Comment';
            OptionMembers = "G/L",Item,Payment,"Open/Close",Customer,"Debit Sale",Cancelled,Comment;
        }
        field(6; "No."; Code[20])
        {
            Caption = 'No.';
            TableRelation = IF (Type = CONST("G/L")) "G/L Account"."No."
            ELSE
            IF (Type = CONST(Payment)) "NPR Payment Type POS"."No."
            ELSE
            IF (Type = CONST(Customer)) Customer."No."
            ELSE
            IF (Type = CONST(Item)) Item."No." WHERE(Blocked = CONST(false));
            ValidateTableRelation = false;
        }
        field(7; Lokationskode; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
        }
        field(8; "Posting Group"; Code[10])
        {
            Caption = 'Posting Group';
            Editable = false;
            TableRelation = IF (Type = CONST(Item)) "Inventory Posting Group";
        }
        field(9; "Qty. Discount Code"; Code[20])
        {
            Caption = 'Qty. Discount Code';
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
        }
        field(11; Unit; Text[10])
        {
            Caption = 'Unit';
        }
        field(12; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(13; "Invoice (Qty)"; Decimal)
        {
            Caption = 'Invoice (Qty)';
            DecimalPlaces = 0 : 5;
        }
        field(14; "To Ship (Qty)"; Decimal)
        {
            Caption = 'To Ship (Qty)';
            DecimalPlaces = 0 : 5;
        }
        field(15; "Unit Price"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            Caption = 'Unit Price';
        }
        field(16; "Unit Cost (LCY)"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Cost (LCY)';
        }
        field(17; "VAT %"; Decimal)
        {
            Caption = 'VAT %';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(18; "Qty. Discount %"; Decimal)
        {
            Caption = 'Qty. Discount %';
            DecimalPlaces = 0 : 5;
            MaxValue = 100;
            MinValue = 0;
        }
        field(19; "Line Discount %"; Decimal)
        {
            BlankZero = true;
            Caption = 'Line Discount %';
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
        }
        field(25; "Sale Date"; Date)
        {
            Caption = 'Sale Date';
        }
        field(26; "Posted Doc. No."; Code[20])
        {
            Caption = 'Posted Doc. No.';
        }
        field(30; Amount; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Amount';

            trigger OnLookup()
            var
                Revisionsrulle: Record "NPR Audit Roll";
            begin
            end;
        }
        field(31; "Amount Including VAT"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Amount Including VAT';
            DecimalPlaces = 2 : 2;
        }
        field(32; "Allow Invoice Discount"; Boolean)
        {
            Caption = 'Allow Invoice Discount';
            InitValue = true;
        }
        field(40; "Department Code"; Code[10])
        {
            Caption = 'Department Code DONT USE';
            Description = 'Not used. use "Shortcut Dimension 1 Code" instead';
        }
        field(41; "Price Group Code"; Code[10])
        {
            Caption = 'Price Group Code';
            TableRelation = "Customer Price Group";
        }
        field(42; "Allow Quantity Discount"; Boolean)
        {
            Caption = 'Allow Quantity Discount';
            InitValue = true;
        }
        field(43; "Serial No."; Code[20])
        {
            Caption = 'Serial No.';
        }
        field(44; "Customer/Item Discount %"; Decimal)
        {
            Caption = 'Customer/Item Discount %';
            DecimalPlaces = 0 : 5;
            MaxValue = 100;
            MinValue = 0;
        }
        field(45; "Sales Order Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Sales Order Amount';
            Editable = false;

            trigger OnValidate()
            var
                Valuta2: Record Currency;
            begin
            end;
        }
        field(46; "Invoice to Customer No."; Code[20])
        {
            Caption = 'Invoice to Customer No.';
            Editable = false;
            TableRelation = Customer;
        }
        field(47; "Invoice Discount Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Invoice Discount Amount';
        }
        field(48; "Gen. Bus. Posting Group"; Code[10])
        {
            Caption = 'Gen. Bus. Posting Group';
            TableRelation = "Gen. Business Posting Group";
        }
        field(49; "Gen. Prod. Posting Group"; Code[10])
        {
            Caption = 'Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group";
        }
        field(50; "VAT Bus. Posting Group"; Code[10])
        {
            Caption = 'VAT Bus. Posting Group';
            TableRelation = "VAT Business Posting Group";
        }
        field(51; "VAT Prod. Posting Group"; Code[10])
        {
            Caption = 'VAT Prod. Posting Group';
            TableRelation = "VAT Product Posting Group";
        }
        field(52; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            Editable = false;
            TableRelation = Currency;
        }
        field(53; "Claim (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Claim (LCY)';
            Editable = false;
        }
        field(54; "VAT Base Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'VAT Base Amount';
            Editable = false;
        }
        field(55; Cost; Decimal)
        {
            Caption = 'Cost';
        }
        field(58; "Period Discount code"; Code[20])
        {
            Caption = 'Period Discount code';
            TableRelation = "NPR Period Discount".Code;
        }
        field(59; "Gift voucher ref."; Code[20])
        {
            Caption = 'Gift Voucher Reference';
        }
        field(60; "Credit voucher ref."; Code[20])
        {
            Caption = 'Credit Voucher Reference';
        }
        field(61; "Salgspris inkl. moms"; Boolean)
        {
            Caption = 'Unit Price incl. VAT';
        }
        field(62; "Fremmed nummer"; Code[20])
        {
            Caption = 'Unknown Number';
        }
        field(63; "Clearing Date"; Date)
        {
            Caption = 'Clearing Date';
        }
        field(70; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(71; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(72; "Offline - Gift voucher ref."; Code[20])
        {
            Caption = 'Offline - Gift Voucher Reference';
        }
        field(73; "Offline - Credit voucher ref."; Code[20])
        {
            Caption = 'Offline - Gift Voucher Reference';
        }
        field(80; "Special price"; Decimal)
        {
            Caption = 'Special price';
        }
        field(90; "Return Reason Code"; Code[10])
        {
            Caption = 'Return Reason Code';
            TableRelation = "Return Reason";
        }
        field(95; "Clustered Key"; Integer)
        {
            AutoIncrement = true;
            Caption = 'Clustered Key';
        }
        field(100; "Unit Cost"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            Caption = 'Unit Cost';
            Editable = false;
        }
        field(101; "System-Created Entry"; Boolean)
        {
            Caption = 'System-Created Entry';
            Editable = false;
        }
        field(102; "Variant Code"; Code[20])
        {
            Caption = 'Variant Code';
            TableRelation = IF (Type = CONST(Item)) "Item Variant".Code WHERE("Item No." = FIELD("No."));
        }
        field(105; "Allocated No."; Code[10])
        {
            Caption = 'Allocated No.';
        }
        field(106; "Document No."; Code[10])
        {
            Caption = 'Document No.';
        }
        field(107; "Document Type"; Option)
        {
            Caption = 'Document Type';
            OptionCaption = 'Invoice,Order,Credit Memo,Return Order';
            OptionMembers = Faktura,Ordre,Kreditnota,Returordre;
        }
        field(108; List; Code[10])
        {
            Caption = 'List';
        }
        field(109; "Listno."; Integer)
        {
            Caption = 'List No.';
        }
        field(110; "Retail Document Type"; Option)
        {
            Caption = 'Document Type';
            NotBlank = true;
            OptionCaption = ' ,Selection,Retail Order,Wish,Customization,Delivery,Rental contract,Purchase contract,Qoute';
            OptionMembers = " ","Selection Contract","Retail Order",Wish,Customization,Delivery,"Rental contract","Purchase contract",Quote;
        }
        field(111; "Retail Document No."; Code[20])
        {
            Caption = 'No.';
        }
        field(200; "Salesperson Code"; Code[10])
        {
            Caption = 'Salesperson Code';
            TableRelation = "Salesperson/Purchaser";
        }
        field(201; "Reversed by Salesperson Code"; Code[10])
        {
            Caption = 'Reversed by Salesperson Code';
            Description = 'Udfyldes med sælgerkoden der tilbagef¢rer bon''en';
            TableRelation = "Salesperson/Purchaser";
        }
        field(202; "Reverseing Sales Ticket No."; Code[20])
        {
            Caption = 'Reverseing Sales Ticket No.';
            Description = 'Peger på det bonnummer som den aktuelle bon tilbagef¢rer';
        }
        field(203; "Reversed by Sales Ticket No."; Code[20])
        {
            Caption = 'Reversed by Sales Ticket No.';
            Description = 'Peger på det bonnummer som tilbagef¢rte aktuel bonnummer';
        }
        field(400; "Discount Type"; Option)
        {
            Caption = 'Discount Type';
            OptionCaption = ' ,Period,Mixed,Multiple Unit,Salesperson Discount,Inventory,Photo Work,Rounding,Combination,Customer';
            OptionMembers = " ",Campaign,Mix,Quantity,Manual,"BOM List","Photo work",Rounding,Combination,Customer;
        }
        field(401; "Discount Code"; Code[30])
        {
            Caption = 'Discount Code';
        }
        field(500; "Cash Terminal Approved"; Boolean)
        {
            Caption = 'Cash Terminal Approved';
        }
        field(550; "Drawer Opened"; Boolean)
        {
            Caption = 'Drawer Opened';
            Description = 'NPR4.001.000, for indication of opening on drawer.';
        }
        field(600; "Total Qty"; Decimal)
        {
            Caption = 'Total Qty';
        }
        field(1000; "Starting Time"; Time)
        {
            Caption = 'Starting Time';
        }
        field(1001; "Closing Time"; Time)
        {
            Caption = 'Closing Time';
        }
        field(1002; "Receipt Type"; Option)
        {
            Caption = 'Ticket Type';
            OptionCaption = ' ,Negativ Sales Ticket,Change,Outpayment,Change Item,Sales in negative receipt';
            OptionMembers = " ","Negative receipt","Change money",Outpayment,"Return items","Sales in negative receipt";
        }
        field(2000; "Closing Cash"; Decimal)
        {
            Caption = 'Closing Cash';
        }
        field(2001; "Opening Cash"; Decimal)
        {
            Caption = 'Opening Cash';
        }
        field(2002; "Transferred to Balance Account"; Decimal)
        {
            Caption = 'Transferred to Balance Account';
        }
        field(2003; Difference; Decimal)
        {
            Caption = 'Difference';
        }
        field(2004; EuroDifference; Decimal)
        {
            Caption = 'EuroDifference';
        }
        field(2005; "Change Register"; Decimal)
        {
            Caption = 'Change Cash Register';
        }
        field(3000; Posted; Boolean)
        {
            Caption = 'Posted';
        }
        field(3001; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(3002; "Internal Posting No."; Integer)
        {
            Caption = 'Internal Posting No.';
        }
        field(5002; Color; Code[20])
        {
            Caption = 'Color';
        }
        field(5003; Size; Code[20])
        {
            Caption = 'Size';
        }
        field(5004; "Serial No. not Created"; Code[30])
        {
            Caption = 'Serial No. not Created';
        }
        field(5006; "Cash Customer No."; Code[30])
        {
            Caption = 'Cash Customer No.';
        }
        field(5020; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
        }
        field(5021; "Customer Type"; Option)
        {
            Caption = 'Customer Type';
            OptionCaption = 'Ord.,Cash';
            OptionMembers = Alm,Kontant;
        }
        field(5022; Reference; Text[50])
        {
            Caption = 'Reference';
        }
        field(5023; Accessory; Boolean)
        {
            Caption = 'Accessory';
        }
        field(5024; "Payment Type No."; Code[10])
        {
            Caption = 'Payment Type No.';
            NotBlank = true;
        }
        field(6000; "N3 Debit Sale Conversion"; Boolean)
        {
            Caption = 'N3 Debit Sale Conversion';
        }
        field(6001; "Buffer Document Type"; Option)
        {
            Caption = 'Buffer Document Type';
            Description = 'NP-retail 1.8';
            OptionCaption = ' ,Payment,Invoice,Credit Note,Interest Note,Reminder';
            OptionMembers = " ",Betaling,Faktura,Kreditnota,Rentenota,Rykker;
        }
        field(6002; "Buffer ID"; Code[20])
        {
            Caption = 'Buffer ID';
            Description = 'NP-retail 1.8';
        }
        field(6003; "Buffer Invoice No."; Code[20])
        {
            Caption = 'Buffer Invoice No.';
            Description = 'NP-retail 1.8';
        }
        field(6004; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        field(6005; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
            Description = 'NPR5.23';
        }
        field(6006; "Touch Screen sale"; Boolean)
        {
            Caption = 'Touch Screen Sale';
        }
        field(6007; "Money bag no."; Code[20])
        {
            Caption = 'Money bag no.';
        }
        field(6008; "External Document No."; Code[20])
        {
            Caption = 'External Document No.';
        }
        field(6009; LineCounter; Decimal)
        {
            Caption = 'Line Counter';
            Description = 'Hack til hurtigt count vha. sum index fields.';
            InitValue = 1;
        }
        field(6015; Offline; Boolean)
        {
            Caption = 'Offline';
        }
        field(6020; Internal; Boolean)
        {
            Caption = 'Internal';
            InitValue = false;
        }
        field(6025; "Customer Post Code"; Code[20])
        {
            Caption = 'Customer Post Code';
        }
        field(6030; "Currency Amount"; Decimal)
        {
            Caption = 'Currency Amount';
        }
        field(6035; "Item Entry Posted"; Boolean)
        {
            Caption = 'Item Entry Posted';
            InitValue = false;
        }
        field(6040; "Copy No."; Integer)
        {
            Caption = 'Copy No.';
            InitValue = -1;
        }
        field(6045; "Item Group"; Code[10])
        {
            Caption = 'Item Group';
        }
        field(6050; Kundenavn; Text[50])
        {
            Caption = 'Customer Name';
        }
        field(6055; Send; Date)
        {
            Caption = 'Send';
            Description = 'Bruges ifm. replikering til at afg¢ren om det felt er udlæst eller ej';
        }
        field(6060; "Offline receipt no."; Code[20])
        {
            Caption = 'Offline receipt no.';
        }
        field(6070; "Sale Date filter"; Date)
        {
            Caption = 'Sale Date filter';
            FieldClass = FlowFilter;
        }
        field(10000; "Balance Amount"; Code[200])
        {
            Caption = 'Balance Amount';
        }
        field(10001; "Balance Sundries"; Code[200])
        {
            Caption = 'Balance Sundries';
        }
        field(10002; "Balance Printed"; Integer)
        {
            Caption = 'Balance Printed';
        }
        field(10003; Balancing; Boolean)
        {
            Caption = 'Balancing';
        }
        field(10004; Vendor; Code[20])
        {
            Caption = 'Vendor';
        }
        field(10005; "Balanced on Sales Ticket No."; Code[20])
        {
            Caption = 'Balanced on Sales Ticket No.';
            Description = 'Bruges ifm. samling af flere kasser.';
        }
        field(10006; "On Register No."; Code[10])
        {
            Caption = 'On Cash Register No.';
        }
        field(10007; "Balance amount euro"; Code[200])
        {
            Caption = 'Balance amount euro';
        }
        field(10008; Photobag; Code[20])
        {
            Caption = 'Photobag';
        }
        field(10013; "Invoiz Guid"; Text[150])
        {
            Caption = 'Invoiz Guid';
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
            SumIndexFields = "Amount Including VAT", "Currency Amount", "Line Discount Amount", Cost, Amount, "Unit Cost";
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
        }
        key(Key7; "Sale Type", Type, "No.", Posted)
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount Including VAT";
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
        }
        key(Key18; "Salesperson Code", "Register No.", "Sale Date")
        {
            SumIndexFields = Amount;
        }
        key(Key19; "Sale Type", Type, "Item Entry Posted")
        {
        }
        key(Key20; "Sale Date", "Invoiz Guid")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    var
        KasseLoc: Record "NPR Register";
        InsertAllowed: Boolean;
    begin
    end;
}

