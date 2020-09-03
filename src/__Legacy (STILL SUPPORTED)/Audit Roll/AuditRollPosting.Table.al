table 6014424 "NPR Audit Roll Posting"
{
    // NPR4.01/JDH/20150310  CASE 201022 Removed reference to assortments
    // NPR4.14/RMT/20150715  CASE 216519 Added fields - used for registering prepayment
    //                                   140 "Sales Document Type"
    //                                   141 "Sales Document No."
    //                                   142 "Sales Document Line No."
    //                                   143 "Sales Document Prepayment"
    //                                   144 "Sales Doc. Prepayment %"
    // NPR5.01/RMT/20160217  CASE 234145 Change field "Register No." property "SQL Data Type" from Variant to <Undefined>
    //                                   Change field "Sales Ticket No." property "SQL Data Type" from Variant to <Undefined>
    //                                   NOTE: requires data upgrade
    // NPR5.22/BHR/20150317 CASE 234744 Change size of field 106(Document No) from 10 to 20
    // NPR5.22/JC/20160421  CASE 239058 Added new key  'Sale Type,Type,Gen. Bus. Posting Group,Gen. Prod. Posting Group,Shortcut Dimension 1 Code,Shortcut Dimension 2 Code,Dimension Set ID,VAT Bus. Posting Group,VAT Prod. Posting Group'
    // NPR5.23/THRO/20160511 CASE 240004 TransferFromRevSilent returns no of records transferred
    //                                   TransferFromRevSilentItemLedg returns no of records transferred
    //                                   Cleanup so we don't have same functionality in 2 functions
    // NPR5.23/MHA/20160530 CASE 242929 Field 6005 "Description 2" length increased from 30 to 50
    // NPR5.30/TJ  /20170215 CASE 265504 Changed ENU captions on fields with word Register in their name
    // NPR5.36/TJ  /20170920 CASE 286283 Renamed all the danish OptionString properties to english
    // NPR5.38/TJ  /20171218 CASE 225415 Renumbered fields from range 50xxx to range below 50000
    // NPR5.43/JDH /20180620 CASE 317453 Removed non existing table relation from Field 40 (ref to old Department table 11)

    Caption = 'Audit Roll Posting';

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
            OptionCaption = 'Sale,Payment,Debit Sale,Gift Voucher,Credit Voucher,Deposit,Out payment,Comment,Open/Close';
            OptionMembers = Sale,Payment,"Debit Sale","Gift Voucher","Credit Voucher",Deposit,"Out payment",Comment,"Open/Close";
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
        field(10; Description; Text[80])
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

            trigger OnValidate()
            begin
                exit;
            end;
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
            Caption = 'Gift Voucher Reference No.';
        }
        field(60; "Credit voucher ref."; Code[20])
        {
            Caption = 'Credit Voucher Reference No.';
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
        field(75; "Bin Code"; Code[10])
        {
            Caption = 'Bin Code';
            TableRelation = Bin;
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
        field(106; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(107; "Document Type"; Option)
        {
            Caption = 'Document Type';
            OptionCaption = 'Invoice,Order,Credit Memo,Return Order';
            OptionMembers = Invoice,"Order","Credit Memo","Return Order";
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
        field(140; "Sales Document Type"; Integer)
        {
            Caption = 'Sales Document Type';
        }
        field(141; "Sales Document No."; Code[20])
        {
            Caption = 'Sales Document No.';
        }
        field(142; "Sales Document Line No."; Integer)
        {
            Caption = 'Sales Document Line No.';
        }
        field(143; "Sales Document Prepayment"; Boolean)
        {
            Caption = 'Sales Document Prepayment';
        }
        field(144; "Sales Doc. Prepayment %"; Decimal)
        {
            Caption = 'Sales Doc. Prepayment %';
        }
        field(145; "Sales Document Invoice"; Boolean)
        {
            Caption = 'Sales Document Invoice';
        }
        field(146; "Sales Document Ship"; Boolean)
        {
            Caption = 'Sales Document Ship';
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
        field(300; "Cancelled No. Of Items"; Decimal)
        {
            Caption = 'Cancelled No. Of Items';
        }
        field(301; "Cancelled Amount On Ticket"; Decimal)
        {
            Caption = 'Cancelled Amount On Ticket';
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
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
        }
        field(500; "Cash Terminal Approved"; Boolean)
        {
            Caption = 'Cash Terminal Approved';
        }
        field(505; "Credit Card Tax Free"; Boolean)
        {
            Caption = 'Credit Card Tax Free';
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
            OptionCaption = ' ,Negative Sales Ticket,Change,Outpayment,Return Item,Sales in Negative Receipt';
            OptionMembers = " ","Negative receipt","Change money",Outpayment,"Return items","Sales in negative receipt";
        }
        field(1500; "Tax Free Refund"; Decimal)
        {
            Caption = 'Tax Free Refund';
            Description = 'Amount refunded by Tax Free. Sag 66308';
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
            OptionMembers = "Ord.",Cash;
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
            OptionMembers = " ",Payment,Invoice,"Credit Note","Interest Note",Reminder;
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
            Caption = 'Touch Screen sale';
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
            Caption = 'LineCounter';
            Description = 'Hack til hurtigt count vha. sum index fields.';
            InitValue = 1;
        }
        field(6010; "Order No. from Web"; Code[20])
        {
            Caption = 'Order No. from Web';
        }
        field(6011; "Order Line No. from Web"; Integer)
        {
            BlankZero = true;
            Caption = 'Order Line No. from Web';
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
        field(6065; "Lock Code"; Code[10])
        {
            Caption = 'Lock Code';
            Description = 'NPR4.002.002';
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
        field(6014511; "Label No."; Code[8])
        {
            Caption = 'Label Number';
            Description = 'NPR4.004.004 - Benyttes i forbindelse med Smart Safety forsikring';
        }
        field(6014539; "CleanCash Reciept No."; Code[10])
        {
            Caption = 'CleanCash Reciept No.';
            Description = 'CleanCash';
        }
        field(6014540; "CleanCash Serial No."; Text[30])
        {
            Caption = 'CleanCash Serial No.';
            Description = 'CleanCash';
        }
        field(6014541; "CleanCash Control Code"; Text[100])
        {
            Caption = 'CleanCash Control Code';
            Description = 'CleanCash';
        }
        field(6014542; "CleanCash Copy Serial No."; Text[30])
        {
            Caption = 'CleanCash Copy Serial No.';
            Description = 'CleanCash';
        }
        field(6014543; "CleanCash Copy Control Code"; Text[100])
        {
            Caption = 'CleanCash Copy Control Code';
            Description = 'CleanCash';
        }
    }

    keys
    {
        key(Key1; "Register No.", "Sales Ticket No.", "Sale Type", "Line No.", "No.", "Sale Date")
        {
        }
        key(Key2; "Sale Date", "Sales Ticket No.", "Line No.")
        {
            MaintainSIFTIndex = false;
            SumIndexFields = "Amount Including VAT";
        }
        key(Key3; "Gen. Bus. Posting Group", "Gen. Prod. Posting Group", "Sale Type", Type)
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount Including VAT", "Line Discount Amount";
        }
        key(Key4; "Register No.", Posted, "Sale Date", Type)
        {
            Enabled = false;
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
        }
        key(Key5; "Register No.", "Closing Time", "Sale Type", Description, Type, "Sales Ticket No.", "Sale Date")
        {
            Enabled = false;
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount Including VAT", "Line Discount Amount";
        }
        key(Key6; "Sale Type", Type, "No.", "Posting Date", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", "Dimension Set ID")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount Including VAT";
        }
        key(Key7; Posted)
        {
            Enabled = false;
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
        }
        key(Key8; "Register No.", "Sale Date", "Sale Type", Type, Posted, "Item Entry Posted", Quantity)
        {
            Enabled = false;
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount Including VAT", Amount, "Unit Cost", "Line Discount Amount", Cost;
        }
        key(Key9; "Sale Type", Type, "Gen. Bus. Posting Group", "Gen. Prod. Posting Group", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", "Dimension Set ID")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount Including VAT", "Line Discount Amount";
        }
        key(Key10; "Sale Date", "Sale Type", Type)
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
        }
        key(Key11; Type, Balancing)
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
        }
        key(Key12; "Sale Type", Type, "Customer Type", "Customer No.")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
        }
        key(Key13; "Sale Type", Type, "Item Entry Posted")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
        }
        key(Key14; "Sales Ticket No.", "Sale Type", Type, "Customer Type", "Customer No.")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount Including VAT", Amount, "Unit Cost", "Line Discount Amount", Cost;
        }
        key(Key15; "Sale Type", Type, "Gen. Bus. Posting Group", "Gen. Prod. Posting Group", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", "Dimension Set ID", "VAT Bus. Posting Group", "VAT Prod. Posting Group")
        {
            SumIndexFields = "Amount Including VAT", "Line Discount Amount";
        }
    }

    fieldgroups
    {
    }

    procedure TransferFromRev(var Revisionsrulle: Record "NPR Audit Roll"; var RevPost: Record "NPR Audit Roll Posting" temporary; var Dlg: Dialog): Integer
    var
        Total: Integer;
        nCount: Integer;
    begin
        //TransferFromRev()
        //-NPR5.23
        exit(DoTransferFromRev(Revisionsrulle, RevPost, Dlg, true));
        //+NPR5.23

        //-NPR5.23
        // Revisionsrulle.SETCURRENTKEY( "Register No.", Posted, "Sale Date" );
        // Revisionsrulle.SETRANGE( Posted, FALSE );
        //
        // { Ohm - checking
        // form6014432.setExtFilters(TRUE);
        // form6014432.SETTABLEVIEW(Revisionsrulle);
        // form6014432.RUNMODAL;
        // }
        //
        // RevPost.SETFILTER( "Register No.", Revisionsrulle.GETFILTER( "Register No." ));
        // RevPost.SETFILTER( "Sales Ticket No.", Revisionsrulle.GETFILTER( "Sales Ticket No." ));
        // RevPost.SETFILTER( "Sale Type", Revisionsrulle.GETFILTER( "Sale Type" ));
        // RevPost.SETFILTER( "Line No.", Revisionsrulle.GETFILTER( "Line No." ));
        // RevPost.SETFILTER( "No.", Revisionsrulle.GETFILTER( "No." ));
        // RevPost.SETFILTER( "Sale Date", Revisionsrulle.GETFILTER( "Sale Date" ));
        // RevPost.SETFILTER( Type, Revisionsrulle.GETFILTER( Type ));
        // RevPost.SETFILTER( Lokationskode, Revisionsrulle.GETFILTER( Lokationskode ));
        // RevPost.SETFILTER( "Shortcut Dimension 1 Code", Revisionsrulle.GETFILTER( "Shortcut Dimension 1 Code" ));
        // RevPost.SETFILTER( "Shortcut Dimension 2 Code", Revisionsrulle.GETFILTER( "Shortcut Dimension 2 Code" ));
        // Total := Revisionsrulle.COUNT;
        // IF Revisionsrulle.FIND('-') THEN REPEAT
        //  nCount += 1;
        //  Revisionsrulle.Description := COPYSTR(Revisionsrulle.Description,1,50);
        //  RevPost.TRANSFERFIELDS( Revisionsrulle );
        //  RevPost.INSERT;
        //  Dlg.UPDATE( 100, ROUND( nCount / Total * 10000, 1 ));
        // UNTIL Revisionsrulle.NEXT = 0;
        // Revisionsrulle.SETRANGE( Posted );
        // Dlg.UPDATE( 100, 10000 );
        // EXIT(nCount);
        //+NPR5.23
    end;

    procedure TransferFromRevItemLedger(var Revisionsrulle: Record "NPR Audit Roll"; var RevPost: Record "NPR Audit Roll Posting" temporary; var Dlg: Dialog): Integer
    var
        Total: Integer;
        nCount: Integer;
    begin
        //TransferFromRevItemLedger()
        //-NPR5.23
        exit(DoTransferFromRevItemLedger(Revisionsrulle, RevPost, Dlg, true));
        //+NPR5.23

        //-NPR5.23
        // Revisionsrulle.SETCURRENTKEY( "Sale Type", Type, "Item Entry Posted" );
        // //Revisionsrulle.SETRANGE("Sale Type", Revisionsrulle."Sale Type"::Salg);
        // //Revisionsrulle.SETFILTER(Type, '<>%1&<>%2', Revisionsrulle.Type::Cancelled, Revisionsrulle.Type::"Open/Close");
        // Revisionsrulle.SETFILTER(Type, '=%1', Revisionsrulle.Type::Item);
        // Revisionsrulle.SETRANGE( "Item Entry Posted", FALSE );
        //
        // RevPost.SETFILTER( "Register No.", Revisionsrulle.GETFILTER( "Register No." ));
        // RevPost.SETFILTER( "Sales Ticket No.", Revisionsrulle.GETFILTER( "Sales Ticket No." ));
        // RevPost.SETFILTER( "Sale Type", Revisionsrulle.GETFILTER( "Sale Type" ));
        // RevPost.SETFILTER( "Line No.", Revisionsrulle.GETFILTER( "Line No." ));
        // RevPost.SETFILTER( "No.", Revisionsrulle.GETFILTER( "No." ));
        // RevPost.SETFILTER( "Sale Date", Revisionsrulle.GETFILTER( "Sale Date" ));
        // RevPost.SETFILTER( Type, Revisionsrulle.GETFILTER( Type ));
        // RevPost.SETFILTER( Lokationskode, Revisionsrulle.GETFILTER( Lokationskode ));
        // RevPost.SETFILTER( "Shortcut Dimension 1 Code", Revisionsrulle.GETFILTER( "Shortcut Dimension 1 Code" ));
        // RevPost.SETFILTER( "Shortcut Dimension 2 Code", Revisionsrulle.GETFILTER( "Shortcut Dimension 2 Code" ));
        // Total := Revisionsrulle.COUNT;
        // IF Revisionsrulle.FIND('-') THEN REPEAT
        //  nCount += 1;
        //  Revisionsrulle.Description := COPYSTR(Revisionsrulle.Description,1,50);
        //  RevPost.TRANSFERFIELDS( Revisionsrulle );
        //  RevPost.INSERT;
        //  Dlg.UPDATE( 100, ROUND( nCount / Total * 10000, 1 ));
        // UNTIL Revisionsrulle.NEXT = 0;
        // Revisionsrulle.SETRANGE( Posted );
        // Dlg.UPDATE( 100, 10000 );
        // EXIT(nCount);
        //+NPR5.23
    end;

    procedure TransferFromTemp(var Target: Record "NPR Audit Roll Posting" temporary; var Source: Record "NPR Audit Roll Posting" temporary)
    begin
        //TransferFromTemp()
        Target.SetFilter("Register No.", Source.GetFilter("Register No."));
        Target.SetFilter("Sales Ticket No.", Source.GetFilter("Sales Ticket No."));
        Target.SetFilter("Sale Type", Source.GetFilter("Sale Type"));
        Target.SetFilter("Line No.", Source.GetFilter("Line No."));
        Target.SetFilter("No.", Source.GetFilter("No."));
        Target.SetFilter("Sale Date", Source.GetFilter("Sale Date"));
        Target.SetFilter(Type, Source.GetFilter(Type));
        Target.SetFilter(Lokationskode, Source.GetFilter(Lokationskode));
        Target.SetFilter("Shortcut Dimension 1 Code", Source.GetFilter("Shortcut Dimension 1 Code"));
        Target.SetFilter("Shortcut Dimension 2 Code", Source.GetFilter("Shortcut Dimension 2 Code"));

        if Source.Find('-') then
            repeat
                Target.TransferFields(Source);
                Target.Insert;
            until Source.Next = 0;
    end;

    procedure UpdateChanges(var Dlg: Dialog)
    var
        Revisionsrulle: Record "NPR Audit Roll";
        Total: Integer;
        nCount: Integer;
    begin
        //UpdateChanges()
        //-NPR5.23
        DoUpdateChanges(Dlg, true);
        //+NPR5.23

        //-NPR5.23
        // Total := COUNT;
        // IF FIND('-') THEN REPEAT
        //  nCount += 1;
        //  Dlg.UPDATE( 103, ROUND( nCount / Total * 10000, 1 ));
        //  Revisionsrulle.GET( "Register No.", "Sales Ticket No.", "Sale Type", "Line No.", "No.", "Sale Date" );
        //  Revisionsrulle.TRANSFERFIELDS( Rec );
        //  Revisionsrulle.MODIFY;
        // UNTIL NEXT = 0;
        // Dlg.UPDATE( 103, 10000 );
        //+NPR5.23
    end;

    procedure CopyAllFilters(var RevRulle: Record "NPR Audit Roll")
    begin
        //CopyAllFilters

        RevRulle.SetFilter("Register No.", GetFilter("Register No."));
        RevRulle.SetFilter("Sales Ticket No.", GetFilter("Sales Ticket No."));
        RevRulle.SetFilter("Sale Date", GetFilter("Sale Date"));
        RevRulle.SetFilter("Line No.", GetFilter("Line No."));
        RevRulle.SetFilter("Gen. Bus. Posting Group", GetFilter("Gen. Bus. Posting Group"));
        RevRulle.SetFilter("Gen. Prod. Posting Group", GetFilter("Gen. Prod. Posting Group"));
        RevRulle.SetFilter("Shortcut Dimension 1 Code", GetFilter("Shortcut Dimension 1 Code"));
        RevRulle.SetFilter("Shortcut Dimension 2 Code", GetFilter("Shortcut Dimension 2 Code"));
        RevRulle.SetFilter("Sale Type", GetFilter("Sale Type"));
        RevRulle.SetFilter(Type, GetFilter(Type));
        RevRulle.SetFilter("No.", GetFilter("No."));
        RevRulle.SetFilter(Balancing, GetFilter(Balancing));
        RevRulle.SetFilter("Customer Type", GetFilter("Customer Type"));
        RevRulle.SetFilter("Customer No.", GetFilter("Customer No."));
        RevRulle.SetFilter("Item Entry Posted", GetFilter("Item Entry Posted"));
    end;

    procedure TransferFromRevSilent(var Revisionsrulle: Record "NPR Audit Roll"; var RevPost: Record "NPR Audit Roll Posting" temporary): Integer
    var
        Dlg: Dialog;
    begin
        //TransferFromRevSilent()
        //-NPR5.23
        exit(DoTransferFromRev(Revisionsrulle, RevPost, Dlg, false));
        //+NPR5.23

        //-NPR5.23
        // Revisionsrulle.SETCURRENTKEY( "Register No.", Posted, "Sale Date" );
        // Revisionsrulle.SETRANGE( Posted, FALSE );
        // RevPost.SETFILTER( "Register No.", Revisionsrulle.GETFILTER( "Register No." ));
        // RevPost.SETFILTER( "Sales Ticket No.", Revisionsrulle.GETFILTER( "Sales Ticket No." ));
        // RevPost.SETFILTER( "Sale Type", Revisionsrulle.GETFILTER( "Sale Type" ));
        // RevPost.SETFILTER( "Line No.", Revisionsrulle.GETFILTER( "Line No." ));
        // RevPost.SETFILTER( "No.", Revisionsrulle.GETFILTER( "No." ));
        // RevPost.SETFILTER( "Sale Date", Revisionsrulle.GETFILTER( "Sale Date" ));
        // RevPost.SETFILTER( Type, Revisionsrulle.GETFILTER( Type ));
        // RevPost.SETFILTER( Lokationskode, Revisionsrulle.GETFILTER( Lokationskode ));
        // RevPost.SETFILTER( "Shortcut Dimension 1 Code", Revisionsrulle.GETFILTER( "Shortcut Dimension 1 Code" ));
        // RevPost.SETFILTER( "Shortcut Dimension 2 Code", Revisionsrulle.GETFILTER( "Shortcut Dimension 2 Code" ));
        // IF Revisionsrulle.FIND('-') THEN REPEAT
        //  Revisionsrulle.Description := COPYSTR(Revisionsrulle.Description,1,50);
        //  RevPost.TRANSFERFIELDS( Revisionsrulle );
        //  RevPost.INSERT;
        // UNTIL Revisionsrulle.NEXT = 0;
        // Revisionsrulle.SETRANGE( Posted );
        //+NPR5.23
    end;

    procedure TransferFromRevSilentItemLedg(var Revisionsrulle: Record "NPR Audit Roll"; var RevPost: Record "NPR Audit Roll Posting" temporary): Integer
    var
        Dlg: Dialog;
    begin
        //TransferFromRevSilent()
        //-NPR5.23
        exit(DoTransferFromRevItemLedger(Revisionsrulle, RevPost, Dlg, false));
        //+NPR5.23

        //-NPR5.23
        // Revisionsrulle.SETCURRENTKEY( "Sale Type", Type, "Item Entry Posted" );
        // //Revisionsrulle.SETRANGE("Sale Type", Revisionsrulle."Sale Type"::Salg);
        // //Revisionsrulle.SETFILTER(Type, '<>%1&<>%2', Revisionsrulle.Type::Cancelled, Revisionsrulle.Type::"Open/Close");
        // Revisionsrulle.SETFILTER(Type, '=%1', Revisionsrulle.Type::Item);
        // Revisionsrulle.SETRANGE( "Item Entry Posted", FALSE );
        //
        // RevPost.SETFILTER( "Register No.", Revisionsrulle.GETFILTER( "Register No." ));
        // RevPost.SETFILTER( "Sales Ticket No.", Revisionsrulle.GETFILTER( "Sales Ticket No." ));
        // RevPost.SETFILTER( "Sale Type", Revisionsrulle.GETFILTER( "Sale Type" ));
        // RevPost.SETFILTER( "Line No.", Revisionsrulle.GETFILTER( "Line No." ));
        // RevPost.SETFILTER( "No.", Revisionsrulle.GETFILTER( "No." ));
        // RevPost.SETFILTER( "Sale Date", Revisionsrulle.GETFILTER( "Sale Date" ));
        // RevPost.SETFILTER( Type, Revisionsrulle.GETFILTER( Type ));
        // RevPost.SETFILTER( Lokationskode, Revisionsrulle.GETFILTER( Lokationskode ));
        // RevPost.SETFILTER( "Shortcut Dimension 1 Code", Revisionsrulle.GETFILTER( "Shortcut Dimension 1 Code" ));
        // RevPost.SETFILTER( "Shortcut Dimension 2 Code", Revisionsrulle.GETFILTER( "Shortcut Dimension 2 Code" ));
        // IF Revisionsrulle.FIND('-') THEN REPEAT
        //  Revisionsrulle.Description := COPYSTR(Revisionsrulle.Description,1,50);
        //  RevPost.TRANSFERFIELDS( Revisionsrulle );
        //  RevPost.INSERT;
        // UNTIL Revisionsrulle.NEXT = 0;
        // Revisionsrulle.SETRANGE( Posted );
        //+NPR5.23
    end;

    procedure UpdateChangesSilent()
    var
        Revisionsrulle: Record "NPR Audit Roll";
        Dlg: Dialog;
    begin
        //UpdateChanges()
        //-NPR5.23
        DoUpdateChanges(Dlg, false);
        //+NPR5.23

        //-NPR5.23
        // IF FIND('-') THEN REPEAT
        //  Revisionsrulle.GET( "Register No.", "Sales Ticket No.", "Sale Type", "Line No.", "No.", "Sale Date" );
        //  Revisionsrulle.TRANSFERFIELDS( Rec );
        //  Revisionsrulle.MODIFY;
        // UNTIL NEXT = 0;
        //+NPR5.23
    end;

    procedure DoTransferFromRev(var Revisionsrulle: Record "NPR Audit Roll"; var RevPost: Record "NPR Audit Roll Posting" temporary; var Dlg: Dialog; UpdateDialog: Boolean): Integer
    var
        Total: Integer;
        nCount: Integer;
    begin
        //-NPR5.23
        Revisionsrulle.SetCurrentKey("Register No.", Posted, "Sale Date");
        Revisionsrulle.SetRange(Posted, false);

        RevPost.SetFilter("Register No.", Revisionsrulle.GetFilter("Register No."));
        RevPost.SetFilter("Sales Ticket No.", Revisionsrulle.GetFilter("Sales Ticket No."));
        RevPost.SetFilter("Sale Type", Revisionsrulle.GetFilter("Sale Type"));
        RevPost.SetFilter("Line No.", Revisionsrulle.GetFilter("Line No."));
        RevPost.SetFilter("No.", Revisionsrulle.GetFilter("No."));
        RevPost.SetFilter("Sale Date", Revisionsrulle.GetFilter("Sale Date"));
        RevPost.SetFilter(Type, Revisionsrulle.GetFilter(Type));
        RevPost.SetFilter(Lokationskode, Revisionsrulle.GetFilter(Lokationskode));
        RevPost.SetFilter("Shortcut Dimension 1 Code", Revisionsrulle.GetFilter("Shortcut Dimension 1 Code"));
        RevPost.SetFilter("Shortcut Dimension 2 Code", Revisionsrulle.GetFilter("Shortcut Dimension 2 Code"));
        if UpdateDialog then
            Total := Revisionsrulle.Count;
        if Revisionsrulle.Find('-') then
            repeat
                nCount += 1;
                Revisionsrulle.Description := CopyStr(Revisionsrulle.Description, 1, 50);
                RevPost.TransferFields(Revisionsrulle);
                RevPost.Insert;
                if UpdateDialog then
                    Dlg.Update(100, Round(nCount / Total * 10000, 1));
            until Revisionsrulle.Next = 0;
        Revisionsrulle.SetRange(Posted);
        if UpdateDialog then
            Dlg.Update(100, 10000);
        exit(nCount);
        //+NPR5.23
    end;

    procedure DoTransferFromRevItemLedger(var Revisionsrulle: Record "NPR Audit Roll"; var RevPost: Record "NPR Audit Roll Posting" temporary; var Dlg: Dialog; UpdateDialog: Boolean): Integer
    var
        Total: Integer;
        nCount: Integer;
    begin
        //-NPR5.23
        Revisionsrulle.SetCurrentKey("Sale Type", Type, "Item Entry Posted");
        Revisionsrulle.SetFilter(Type, '=%1', Revisionsrulle.Type::Item);
        Revisionsrulle.SetRange("Item Entry Posted", false);

        RevPost.SetFilter("Register No.", Revisionsrulle.GetFilter("Register No."));
        RevPost.SetFilter("Sales Ticket No.", Revisionsrulle.GetFilter("Sales Ticket No."));
        RevPost.SetFilter("Sale Type", Revisionsrulle.GetFilter("Sale Type"));
        RevPost.SetFilter("Line No.", Revisionsrulle.GetFilter("Line No."));
        RevPost.SetFilter("No.", Revisionsrulle.GetFilter("No."));
        RevPost.SetFilter("Sale Date", Revisionsrulle.GetFilter("Sale Date"));
        RevPost.SetFilter(Type, Revisionsrulle.GetFilter(Type));
        RevPost.SetFilter(Lokationskode, Revisionsrulle.GetFilter(Lokationskode));
        RevPost.SetFilter("Shortcut Dimension 1 Code", Revisionsrulle.GetFilter("Shortcut Dimension 1 Code"));
        RevPost.SetFilter("Shortcut Dimension 2 Code", Revisionsrulle.GetFilter("Shortcut Dimension 2 Code"));
        if UpdateDialog then
            Total := Revisionsrulle.Count;
        if Revisionsrulle.Find('-') then
            repeat
                nCount += 1;
                Revisionsrulle.Description := CopyStr(Revisionsrulle.Description, 1, 50);
                RevPost.TransferFields(Revisionsrulle);
                RevPost.Insert;
                if UpdateDialog then
                    Dlg.Update(100, Round(nCount / Total * 10000, 1));
            until Revisionsrulle.Next = 0;
        Revisionsrulle.SetRange(Posted);
        if UpdateDialog then
            Dlg.Update(100, 10000);
        exit(nCount);
        //+NPR5.23
    end;

    procedure DoUpdateChanges(var Dlg: Dialog; UpdateDialog: Boolean)
    var
        Revisionsrulle: Record "NPR Audit Roll";
        Total: Integer;
        nCount: Integer;
    begin
        //-NPR5.23
        if UpdateDialog then
            Total := Count;
        if Find('-') then
            repeat
                if UpdateDialog then begin
                    nCount += 1;
                    Dlg.Update(103, Round(nCount / Total * 10000, 1));
                end;
                Revisionsrulle.Get("Register No.", "Sales Ticket No.", "Sale Type", "Line No.", "No.", "Sale Date");
                Revisionsrulle.TransferFields(Rec);
                Revisionsrulle.Modify;
            until Next = 0;
        if UpdateDialog then
            Dlg.Update(103, 10000);
        //+NPR5.23
    end;
}

