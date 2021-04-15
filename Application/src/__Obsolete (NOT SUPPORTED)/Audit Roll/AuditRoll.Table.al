table 6014407 "NPR Audit Roll"
{
    Caption = 'Audit Roll';
    DataClassification = CustomerContent;
    PasteIsValid = false;
    ObsoleteState = Removed;
    ObsoleteReason = 'Replaced by POS entry';

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
            TableRelation = IF (Type = CONST("G/L")) "G/L Account"."No."
            ELSE
            IF (Type = CONST(Payment)) "NPR POS Payment Method".Code
            ELSE
            IF (Type = CONST(Customer)) Customer."No."
            ELSE
            IF (Type = CONST(Item)) Item."No." WHERE(Blocked = CONST(false));
            ValidateTableRelation = false;
        }
        field(7; Lokationskode; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location;
        }
        field(8; "Posting Group"; Code[20])
        {
            Caption = 'Posting Group';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = IF (Type = CONST(Item)) "Inventory Posting Group";
        }
        field(9; "Qty. Discount Code"; Code[20])
        {
            Caption = 'Qty. Discount Code';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(11; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = CustomerContent;
            TableRelation = IF (Type = CONST(Item),
                                "No." = FILTER(<> '')) "Item Unit of Measure".Code WHERE("Item No." = FIELD("No."))
            ELSE
            "Unit of Measure";
        }
        field(12; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(13; "Invoice (Qty)"; Decimal)
        {
            Caption = 'Invoice (Qty)';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(14; "To Ship (Qty)"; Decimal)
        {
            Caption = 'To Ship (Qty)';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(15; "Unit Price"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            Caption = 'Unit Price';
            DataClassification = CustomerContent;
        }
        field(16; "Unit Cost (LCY)"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Cost (LCY)';
            DataClassification = CustomerContent;
        }
        field(17; "VAT %"; Decimal)
        {
            Caption = 'VAT %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(18; "Qty. Discount %"; Decimal)
        {
            Caption = 'Qty. Discount %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            MaxValue = 100;
            MinValue = 0;
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
        field(32; "Allow Invoice Discount"; Boolean)
        {
            Caption = 'Allow Invoice Discount';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(40; "Department Code"; Code[10])
        {
            Caption = 'Department Code DONT USE';
            DataClassification = CustomerContent;
            Description = 'Not used. use "Shortcut Dimension 1 Code" instead';
        }
        field(41; "Price Group Code"; Code[10])
        {
            Caption = 'Price Group Code';
            DataClassification = CustomerContent;
            TableRelation = "Customer Price Group";
        }
        field(42; "Allow Quantity Discount"; Boolean)
        {
            Caption = 'Allow Quantity Discount';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(43; "Serial No."; Code[50])
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
        field(45; "Sales Order Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Sales Order Amount';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(46; "Invoice to Customer No."; Code[20])
        {
            Caption = 'Invoice to Customer No.';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = Customer;
        }
        field(47; "Invoice Discount Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Invoice Discount Amount';
            DataClassification = CustomerContent;
        }
        field(48; "Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Business Posting Group";
        }
        field(49; "Gen. Prod. Posting Group"; Code[20])
        {
            Caption = 'Gen. Prod. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Product Posting Group";
        }
        field(50; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Business Posting Group";
        }
        field(51; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Product Posting Group";
        }
        field(52; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = Currency;
        }
        field(53; "Claim (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Claim (LCY)';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(54; "VAT Base Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'VAT Base Amount';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(55; Cost; Decimal)
        {
            Caption = 'Cost';
            DataClassification = CustomerContent;
        }
        field(58; "Period Discount code"; Code[20])
        {
            Caption = 'Period Discount code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Period Discount".Code;
        }
        field(59; "Gift voucher ref."; Code[20])
        {
            Caption = 'Gift voucher ref.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Gift voucher table won''t be used anymore.';
            ObsoleteTag = 'NPR Gift Voucher';
        }
        field(60; "Credit voucher ref."; Code[20])
        {
            Caption = 'Credit voucher ref.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Credit Voucher table won''t be used anymore.';
            ObsoleteTag = 'NPR Credit Voucher';
        }
        field(61; "Salgspris inkl. moms"; Boolean)
        {
            Caption = 'Unit Price incl. VAT';
            DataClassification = CustomerContent;
        }
        field(62; "Fremmed nummer"; Code[20])
        {
            Caption = 'Fremmed nummer';
            DataClassification = CustomerContent;
        }
        field(63; "Clearing Date"; Date)
        {
            Caption = 'Clearing Date';
            DataClassification = CustomerContent;
        }
        field(70; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(71; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(72; "Offline - Gift voucher ref."; Code[20])
        {
            Caption = 'Offline - Gift voucher ref.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Gift voucher table won''t be used anymore.';
            ObsoleteTag = 'NPR Gift Voucher';
        }
        field(73; "Offline - Credit voucher ref."; Code[20])
        {
            Caption = 'Offline - Credit voucher ref.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Credit voucher table won''t be used anymore.';
            ObsoleteTag = 'NPR Credit Voucher';
        }
        field(75; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            DataClassification = CustomerContent;
            TableRelation = Bin;
        }
        field(80; "Special price"; Decimal)
        {
            Caption = 'Special price';
            DataClassification = CustomerContent;
        }
        field(85; "Tax Area Code"; Code[20])
        {
            Caption = 'Tax Area Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.31';
            TableRelation = "Tax Area";
        }
        field(86; "Tax Liable"; Boolean)
        {
            Caption = 'Tax Liable';
            DataClassification = CustomerContent;
            Description = 'NPR5.31';
        }
        field(87; "Tax Group Code"; Code[20])
        {
            Caption = 'Tax Group Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.31';
            TableRelation = "Tax Group";
        }
        field(88; "Use Tax"; Boolean)
        {
            Caption = 'Use Tax';
            DataClassification = CustomerContent;
            Description = 'NPR5.31';
        }
        field(90; "Return Reason Code"; Code[10])
        {
            Caption = 'Return Reason Code';
            DataClassification = CustomerContent;
            TableRelation = "Return Reason";
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
        field(102; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
            TableRelation = IF (Type = CONST(Item)) "Item Variant".Code WHERE("Item No." = FIELD("No."));
        }
        field(105; "Allocated No."; Code[10])
        {
            Caption = 'Allocated No.';
            DataClassification = CustomerContent;
        }
        field(106; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(107; "Document Type"; Option)
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Invoice,Order,Credit Memo,Return Order';
            OptionMembers = Invoice,"Order","Credit Memo","Return Order";
        }
        field(108; "Wish List"; Code[10])
        {
            Caption = 'Wish List';
            DataClassification = CustomerContent;
            Description = 'NPR5.38';
        }
        field(109; "Wish List Line No."; Integer)
        {
            Caption = 'Wish List Line No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.38';
        }
        field(110; "Retail Document Type"; Option)
        {
            Caption = 'Retail Document Type';
            DataClassification = CustomerContent;
            NotBlank = true;
            OptionCaption = ' ,Selection,Retail Order,Wish,Customization,Delivery,Rental contract,Purchase contract,Qoute';
            OptionMembers = " ","Selection Contract","Retail Order",Wish,Customization,Delivery,"Rental contract","Purchase contract",Quote;
        }
        field(111; "Retail Document No."; Code[20])
        {
            Caption = 'Retail Document No.';
            DataClassification = CustomerContent;
        }
        field(140; "Sales Document Type"; Enum "Sales Document Type")
        {
            Caption = 'Sales Document Type';
            DataClassification = CustomerContent;
        }
        field(141; "Sales Document No."; Code[20])
        {
            Caption = 'Sales Document No.';
            DataClassification = CustomerContent;
        }
        field(142; "Sales Document Line No."; Integer)
        {
            Caption = 'Sales Document Line No.';
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
            Description = 'NPR5.31';
        }
        field(161; "Orig. POS Sale ID"; Integer)
        {
            Caption = 'Orig. POS Sale ID';
            DataClassification = CustomerContent;
            Description = 'NPR5.31';
        }
        field(162; "Orig. POS Line No."; Integer)
        {
            Caption = 'Orig. POS Line No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.31';
        }
        field(200; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser";
        }
        field(201; "Reversed by Salesperson Code"; Code[20])
        {
            Caption = 'Reversed by Salesperson Code';
            DataClassification = CustomerContent;
            Description = 'Udfyldes med sælgerkoden der tilbagef¢rer bon''en';
            TableRelation = "Salesperson/Purchaser";
        }
        field(202; "Reverseing Sales Ticket No."; Code[20])
        {
            Caption = 'Reverseing Sales Ticket No.';
            DataClassification = CustomerContent;
            Description = 'Peger på det bonnummer som den aktuelle bon tilbagef¢rer';
        }
        field(203; "Reversed by Sales Ticket No."; Code[20])
        {
            Caption = 'Reversed by Sales Ticket No.';
            DataClassification = CustomerContent;
            Description = 'Peger på det bonnummer som tilbagef¢rte aktuel bonnummer';
        }
        field(300; "Cancelled No. Of Items"; Decimal)
        {
            Caption = 'Cancelled No. Of Items';
            DataClassification = CustomerContent;
        }
        field(301; "Cancelled Amount On Ticket"; Decimal)
        {
            Caption = 'Cancelled Amount On Ticket';
            DataClassification = CustomerContent;
        }
        field(400; "Discount Type"; Option)
        {
            Caption = 'Discount Type';
            DataClassification = CustomerContent;
            Description = 'NPR5.30';
            OptionCaption = ' ,Period,Mixed,Multiple Unit,Salesperson Discount,Inventory,,Rounding,Combination,Customer';
            OptionMembers = " ",Campaign,Mix,Quantity,Manual,"BOM List",,Rounding,Combination,Customer;
        }
        field(401; "Discount Code"; Code[30])
        {
            Caption = 'Discount Code';
            DataClassification = CustomerContent;
        }
        field(405; "Discount Authorised by"; Code[20])
        {
            Caption = 'Discount Authorised by';
            DataClassification = CustomerContent;
            Description = 'NPR5.39';
            TableRelation = "Salesperson/Purchaser";
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
        field(505; "Credit Card Tax Free"; Boolean)
        {
            Caption = 'Credit Card Tax Free';
            DataClassification = CustomerContent;
        }
        field(550; "Drawer Opened"; Boolean)
        {
            Caption = 'Drawer Opened';
            DataClassification = CustomerContent;
            Description = 'NPR4.001.000, for indication of opening on drawer.';
        }
        field(600; "Total Qty"; Decimal)
        {
            Caption = 'Total Qty';
            DataClassification = CustomerContent;
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
        field(1500; "Tax Free Refund"; Decimal)
        {
            Caption = 'Tax Free Refund';
            DataClassification = CustomerContent;
            Description = 'Amount refunded by Tax Free. Sag 66308';
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
        field(2004; EuroDifference; Decimal)
        {
            Caption = 'EuroDifference';
            DataClassification = CustomerContent;
        }
        field(2005; "Change Register"; Decimal)
        {
            Caption = 'Change Register';
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
        field(5004; "Serial No. not Created"; Code[50])
        {
            Caption = 'Serial No. not Created';
            DataClassification = CustomerContent;
        }
        field(5006; "Cash Customer No."; Code[30])
        {
            Caption = 'Cash Customer No.';
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
            OptionMembers = "Ord.",Cash;
        }
        field(5022; Reference; Text[50])
        {
            Caption = 'Reference';
            DataClassification = CustomerContent;
        }
        field(5023; Accessory; Boolean)
        {
            Caption = 'Accessory';
            DataClassification = CustomerContent;
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
        field(6001; "Buffer Document Type"; Enum "Gen. Journal Document Type")
        {
            Caption = 'Buffer Document Type';
            DataClassification = CustomerContent;
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
            TableRelation = "Reason Code";
        }
        field(6005; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
            DataClassification = CustomerContent;
            Description = 'NPR5.23';
        }
        field(6006; "Touch Screen sale"; Boolean)
        {
            Caption = 'Touch Screen sale';
            DataClassification = CustomerContent;
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
        field(6010; "Order No. from Web"; Code[20])
        {
            Caption = 'Order No. from Web';
            DataClassification = CustomerContent;
        }
        field(6011; "Order Line No. from Web"; Integer)
        {
            BlankZero = true;
            Caption = 'Order Line No. from Web';
            DataClassification = CustomerContent;
        }
        field(6015; Offline; Boolean)
        {
            Caption = 'Offline';
            DataClassification = CustomerContent;
        }
        field(6020; Internal; Boolean)
        {
            Caption = 'Internal';
            DataClassification = CustomerContent;
            InitValue = false;
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
        field(6040; "Copy No."; Integer)
        {
            Caption = 'Copy No.';
            DataClassification = CustomerContent;
            InitValue = -1;
        }
        field(6045; "Item Group"; Code[10])
        {
            Caption = 'Item Group';
            DataClassification = CustomerContent;
        }
        field(6050; Kundenavn; Text[50])
        {
            Caption = 'Customer Name';
            DataClassification = CustomerContent;
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
        field(6065; "Lock Code"; Code[10])
        {
            Caption = 'Lock Code';
            DataClassification = CustomerContent;
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
            DataClassification = CustomerContent;
        }
        field(10001; "Balance Sundries"; Code[200])
        {
            Caption = 'Balance Sundries';
            DataClassification = CustomerContent;
        }
        field(10002; "Balance Printed"; Integer)
        {
            Caption = 'Balance Printed';
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
        field(10005; "Balanced on Sales Ticket No."; Code[20])
        {
            Caption = 'Balanced on Sales Ticket No.';
            DataClassification = CustomerContent;
            Description = 'Bruges ifm. samling af flere kasser.';
        }
        field(10006; "On Register No."; Code[10])
        {
            Caption = 'On Register No.';
            DataClassification = CustomerContent;
        }
        field(10007; "Balance amount euro"; Code[200])
        {
            Caption = 'Balance amount euro';
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
        field(6014511; "Label No."; Code[8])
        {
            Caption = 'Label Number';
            DataClassification = CustomerContent;
            Description = 'NPR4.004.004 - Benyttes i forbindelse med Smart Safety forsikring';
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
            ObsoleteState = Removed;
            ObsoleteReason = 'Gift voucher table won''t be used anymore.';
            ObsoleteTag = 'NPR Gift Voucher';
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
            Enabled = false;
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
            Enabled = false;
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
            Enabled = false;
        }
        key(Key26; "Sale Date", "Sales Ticket No.", "Sale Type", "Line No.")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(Brick; "Sales Ticket No.", Description, "No.", "Sale Date", "Starting Time", "Register No.")
        {
        }
    }
}