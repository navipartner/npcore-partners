table 6014424 "NPR Audit Roll Posting"
{
    Caption = 'Audit Roll Posting';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Register No."; Code[10])
        {
            Caption = 'Cash Register No.';
            NotBlank = true;
            TableRelation = "NPR Register";
            DataClassification = CustomerContent;

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
            DataClassification = CustomerContent;
        }
        field(3; "Sale Type"; Option)
        {
            Caption = 'Sale Type';
            OptionCaption = 'Sale,Payment,Debit Sale,Gift Voucher,Credit Voucher,Deposit,Out payment,Comment,Open/Close';
            OptionMembers = Sale,Payment,"Debit Sale","Gift Voucher","Credit Voucher",Deposit,"Out payment",Comment,"Open/Close";
            DataClassification = CustomerContent;
        }
        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(5; Type; Option)
        {
            Caption = 'Type';
            InitValue = Item;
            OptionCaption = 'G/L,Item,Payment,Open/Close,Customer,Debit Sale,Cancelled,Comment';
            OptionMembers = "G/L",Item,Payment,"Open/Close",Customer,"Debit Sale",Cancelled,Comment;
            DataClassification = CustomerContent;
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
            DataClassification = CustomerContent;
        }
        field(7; Lokationskode; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
            DataClassification = CustomerContent;
        }
        field(8; "Posting Group"; Code[10])
        {
            Caption = 'Posting Group';
            Editable = false;
            TableRelation = IF (Type = CONST(Item)) "Inventory Posting Group";
            DataClassification = CustomerContent;
        }
        field(9; "Qty. Discount Code"; Code[20])
        {
            Caption = 'Qty. Discount Code';
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
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
        }
        field(13; "Invoice (Qty)"; Decimal)
        {
            Caption = 'Invoice (Qty)';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
        }
        field(14; "To Ship (Qty)"; Decimal)
        {
            Caption = 'To Ship (Qty)';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
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
            DecimalPlaces = 0 : 5;
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(18; "Qty. Discount %"; Decimal)
        {
            Caption = 'Qty. Discount %';
            DecimalPlaces = 0 : 5;
            MaxValue = 100;
            MinValue = 0;
            DataClassification = CustomerContent;
        }
        field(19; "Line Discount %"; Decimal)
        {
            BlankZero = true;
            Caption = 'Line Discount %';
            DecimalPlaces = 0 : 5;
            MaxValue = 100;
            MinValue = 0;
            DataClassification = CustomerContent;
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
            DataClassification = CustomerContent;

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
            DataClassification = CustomerContent;
        }
        field(32; "Allow Invoice Discount"; Boolean)
        {
            Caption = 'Allow Invoice Discount';
            InitValue = true;
            DataClassification = CustomerContent;
        }
        field(40; "Department Code"; Code[10])
        {
            Caption = 'Department Code DONT USE';
            Description = 'Not used. use "Shortcut Dimension 1 Code" instead';
            DataClassification = CustomerContent;
        }
        field(41; "Price Group Code"; Code[10])
        {
            Caption = 'Price Group Code';
            TableRelation = "Customer Price Group";
            DataClassification = CustomerContent;
        }
        field(42; "Allow Quantity Discount"; Boolean)
        {
            Caption = 'Allow Quantity Discount';
            InitValue = true;
            DataClassification = CustomerContent;
        }
        field(43; "Serial No."; Code[20])
        {
            Caption = 'Serial No.';
            DataClassification = CustomerContent;
        }
        field(44; "Customer/Item Discount %"; Decimal)
        {
            Caption = 'Customer/Item Discount %';
            DecimalPlaces = 0 : 5;
            MaxValue = 100;
            MinValue = 0;
            DataClassification = CustomerContent;
        }
        field(45; "Sales Order Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Sales Order Amount';
            Editable = false;
            DataClassification = CustomerContent;

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
            DataClassification = CustomerContent;
        }
        field(47; "Invoice Discount Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Invoice Discount Amount';
            DataClassification = CustomerContent;
        }
        field(48; "Gen. Bus. Posting Group"; Code[10])
        {
            Caption = 'Gen. Bus. Posting Group';
            TableRelation = "Gen. Business Posting Group";
            DataClassification = CustomerContent;
        }
        field(49; "Gen. Prod. Posting Group"; Code[10])
        {
            Caption = 'Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group";
            DataClassification = CustomerContent;
        }
        field(50; "VAT Bus. Posting Group"; Code[10])
        {
            Caption = 'VAT Bus. Posting Group';
            TableRelation = "VAT Business Posting Group";
            DataClassification = CustomerContent;
        }
        field(51; "VAT Prod. Posting Group"; Code[10])
        {
            Caption = 'VAT Prod. Posting Group';
            TableRelation = "VAT Product Posting Group";
            DataClassification = CustomerContent;
        }
        field(52; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            Editable = false;
            TableRelation = Currency;
            DataClassification = CustomerContent;
        }
        field(53; "Claim (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Claim (LCY)';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(54; "VAT Base Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'VAT Base Amount';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(55; Cost; Decimal)
        {
            Caption = 'Cost';
            DataClassification = CustomerContent;
        }
        field(58; "Period Discount code"; Code[20])
        {
            Caption = 'Period Discount code';
            TableRelation = "NPR Period Discount".Code;
            DataClassification = CustomerContent;
        }
        field(59; "Gift voucher ref."; Code[20])
        {
            Caption = 'Gift Voucher Reference No.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Gift voucher table won''t be used anymore.';
            ObsoleteTag = 'NPR Gift Voucher';
        }
        field(60; "Credit voucher ref."; Code[20])
        {
            Caption = 'Credit Voucher Reference No.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Credit voucher table won''t be used anymore.';
            ObsoleteTag = 'NPR Credit Voucher';
        }
        field(61; "Salgspris inkl. moms"; Boolean)
        {
            Caption = 'Unit Price incl. VAT';
            DataClassification = CustomerContent;
        }
        field(62; "Fremmed nummer"; Code[20])
        {
            Caption = 'Unknown Number';
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
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
            DataClassification = CustomerContent;
        }
        field(71; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
            DataClassification = CustomerContent;
        }
        field(72; "Offline - Gift voucher ref."; Code[20])
        {
            Caption = 'Offline - Gift Voucher Reference';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Gift voucher table won''t be used anymore.';
            ObsoleteTag = 'NPR Gift Voucher';
        }
        field(73; "Offline - Credit voucher ref."; Code[20])
        {
            Caption = 'Offline - Gift Voucher Reference';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Credit voucher table won''t be used anymore.';
            ObsoleteTag = 'NPR Credit Voucher';
        }
        field(75; "Bin Code"; Code[10])
        {
            Caption = 'Bin Code';
            TableRelation = Bin;
            DataClassification = CustomerContent;
        }
        field(80; "Special price"; Decimal)
        {
            Caption = 'Special price';
            DataClassification = CustomerContent;
        }
        field(90; "Return Reason Code"; Code[10])
        {
            Caption = 'Return Reason Code';
            TableRelation = "Return Reason";
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
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(101; "System-Created Entry"; Boolean)
        {
            Caption = 'System-Created Entry';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(102; "Variant Code"; Code[20])
        {
            Caption = 'Variant Code';
            TableRelation = IF (Type = CONST(Item)) "Item Variant".Code WHERE("Item No." = FIELD("No."));
            DataClassification = CustomerContent;
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
            OptionCaption = 'Invoice,Order,Credit Memo,Return Order';
            OptionMembers = Invoice,"Order","Credit Memo","Return Order";
            DataClassification = CustomerContent;
        }
        field(108; List; Code[10])
        {
            Caption = 'List';
            DataClassification = CustomerContent;
        }
        field(109; "Listno."; Integer)
        {
            Caption = 'List No.';
            DataClassification = CustomerContent;
        }
        field(110; "Retail Document Type"; Option)
        {
            Caption = 'Document Type';
            NotBlank = true;
            OptionCaption = ' ,Selection,Retail Order,Wish,Customization,Delivery,Rental contract,Purchase contract,Qoute';
            OptionMembers = " ","Selection Contract","Retail Order",Wish,Customization,Delivery,"Rental contract","Purchase contract",Quote;
            DataClassification = CustomerContent;
        }
        field(111; "Retail Document No."; Code[20])
        {
            Caption = 'No.';
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
        field(200; "Salesperson Code"; Code[10])
        {
            Caption = 'Salesperson Code';
            TableRelation = "Salesperson/Purchaser";
            DataClassification = CustomerContent;
        }
        field(201; "Reversed by Salesperson Code"; Code[10])
        {
            Caption = 'Reversed by Salesperson Code';
            Description = 'Udfyldes med sælgerkoden der tilbagef¢rer bon''en';
            TableRelation = "Salesperson/Purchaser";
            DataClassification = CustomerContent;
        }
        field(202; "Reverseing Sales Ticket No."; Code[20])
        {
            Caption = 'Reverseing Sales Ticket No.';
            Description = 'Peger på det bonnummer som den aktuelle bon tilbagef¢rer';
            DataClassification = CustomerContent;
        }
        field(203; "Reversed by Sales Ticket No."; Code[20])
        {
            Caption = 'Reversed by Sales Ticket No.';
            Description = 'Peger på det bonnummer som tilbagef¢rte aktuel bonnummer';
            DataClassification = CustomerContent;
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
            OptionCaption = ' ,Period,Mixed,Multiple Unit,Salesperson Discount,Inventory,Photo Work,Rounding,Combination,Customer';
            OptionMembers = " ",Campaign,Mix,Quantity,Manual,"BOM List","Photo work",Rounding,Combination,Customer;
            DataClassification = CustomerContent;
        }
        field(401; "Discount Code"; Code[30])
        {
            Caption = 'Discount Code';
            DataClassification = CustomerContent;
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
            Description = 'NPR4.001.000, for indication of opening on drawer.';
            DataClassification = CustomerContent;
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
            OptionCaption = ' ,Negative Sales Ticket,Change,Outpayment,Return Item,Sales in Negative Receipt';
            OptionMembers = " ","Negative receipt","Change money",Outpayment,"Return items","Sales in negative receipt";
            DataClassification = CustomerContent;
        }
        field(1500; "Tax Free Refund"; Decimal)
        {
            Caption = 'Tax Free Refund';
            Description = 'Amount refunded by Tax Free. Sag 66308';
            DataClassification = CustomerContent;
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
            OptionCaption = 'Ord.,Cash';
            OptionMembers = "Ord.",Cash;
            DataClassification = CustomerContent;
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
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(6000; "N3 Debit Sale Conversion"; Boolean)
        {
            Caption = 'N3 Debit Sale Conversion';
            DataClassification = CustomerContent;
        }
        field(6001; "Buffer Document Type"; Enum "Gen. Journal Document Type")
        {
            Caption = 'Buffer Document Type';
            Description = 'NP-retail 1.8';
            DataClassification = CustomerContent;
        }
        field(6002; "Buffer ID"; Code[20])
        {
            Caption = 'Buffer ID';
            Description = 'NP-retail 1.8';
            DataClassification = CustomerContent;
        }
        field(6003; "Buffer Invoice No."; Code[20])
        {
            Caption = 'Buffer Invoice No.';
            Description = 'NP-retail 1.8';
            DataClassification = CustomerContent;
        }
        field(6004; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
            DataClassification = CustomerContent;
        }
        field(6005; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
            Description = 'NPR5.23';
            DataClassification = CustomerContent;
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
            Description = 'Hack til hurtigt count vha. sum index fields.';
            InitValue = 1;
            DataClassification = CustomerContent;
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
            InitValue = false;
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
            InitValue = false;
            DataClassification = CustomerContent;
        }
        field(6040; "Copy No."; Integer)
        {
            Caption = 'Copy No.';
            InitValue = -1;
            DataClassification = CustomerContent;
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
            Description = 'Bruges ifm. replikering til at afg¢ren om det felt er udlæst eller ej';
            DataClassification = CustomerContent;
        }
        field(6060; "Offline receipt no."; Code[20])
        {
            Caption = 'Offline receipt no.';
            DataClassification = CustomerContent;
        }
        field(6065; "Lock Code"; Code[10])
        {
            Caption = 'Lock Code';
            Description = 'NPR4.002.002';
            DataClassification = CustomerContent;
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
            Description = 'Bruges ifm. samling af flere kasser.';
            DataClassification = CustomerContent;
        }
        field(10006; "On Register No."; Code[10])
        {
            Caption = 'On Cash Register No.';
            DataClassification = CustomerContent;
        }
        field(10007; "Balance amount euro"; Code[200])
        {
            Caption = 'Balance amount euro';
            DataClassification = CustomerContent;
        }
        field(10008; Photobag; Code[20])
        {
            Caption = 'Photobag';
            DataClassification = CustomerContent;
        }
        field(10013; "Invoiz Guid"; Text[150])
        {
            Caption = 'Invoiz Guid';
            DataClassification = CustomerContent;
        }
        field(6014511; "Label No."; Code[8])
        {
            Caption = 'Label Number';
            Description = 'NPR4.004.004 - Benyttes i forbindelse med Smart Safety forsikring';
            DataClassification = CustomerContent;
        }
        field(6014539; "CleanCash Reciept No."; Code[10])
        {
            Caption = 'CleanCash Reciept No.';
            Description = 'CleanCash';
            DataClassification = CustomerContent;
        }
        field(6014540; "CleanCash Serial No."; Text[30])
        {
            Caption = 'CleanCash Serial No.';
            Description = 'CleanCash';
            DataClassification = CustomerContent;
        }
        field(6014541; "CleanCash Control Code"; Text[100])
        {
            Caption = 'CleanCash Control Code';
            Description = 'CleanCash';
            DataClassification = CustomerContent;
        }
        field(6014542; "CleanCash Copy Serial No."; Text[30])
        {
            Caption = 'CleanCash Copy Serial No.';
            Description = 'CleanCash';
            DataClassification = CustomerContent;
        }
        field(6014543; "CleanCash Copy Control Code"; Text[100])
        {
            Caption = 'CleanCash Copy Control Code';
            Description = 'CleanCash';
            DataClassification = CustomerContent;
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
        exit(DoTransferFromRev(Revisionsrulle, RevPost, Dlg, true));
    end;

    procedure TransferFromRevItemLedger(var Revisionsrulle: Record "NPR Audit Roll"; var RevPost: Record "NPR Audit Roll Posting" temporary; var Dlg: Dialog): Integer
    var
        Total: Integer;
        nCount: Integer;
    begin
        exit(DoTransferFromRevItemLedger(Revisionsrulle, RevPost, Dlg, true));
    end;

    procedure TransferFromTemp(var Target: Record "NPR Audit Roll Posting" temporary; var Source: Record "NPR Audit Roll Posting" temporary)
    begin
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
        DoUpdateChanges(Dlg, true);
    end;

    procedure CopyAllFilters(var RevRulle: Record "NPR Audit Roll")
    begin
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
        exit(DoTransferFromRev(Revisionsrulle, RevPost, Dlg, false));
    end;

    procedure TransferFromRevSilentItemLedg(var Revisionsrulle: Record "NPR Audit Roll"; var RevPost: Record "NPR Audit Roll Posting" temporary): Integer
    var
        Dlg: Dialog;
    begin
        exit(DoTransferFromRevItemLedger(Revisionsrulle, RevPost, Dlg, false));
    end;

    procedure UpdateChangesSilent()
    var
        Revisionsrulle: Record "NPR Audit Roll";
        Dlg: Dialog;
    begin
        DoUpdateChanges(Dlg, false);
    end;

    procedure DoTransferFromRev(var Revisionsrulle: Record "NPR Audit Roll"; var RevPost: Record "NPR Audit Roll Posting" temporary; var Dlg: Dialog; UpdateDialog: Boolean): Integer
    var
        Total: Integer;
        nCount: Integer;
    begin
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
    end;

    procedure DoTransferFromRevItemLedger(var Revisionsrulle: Record "NPR Audit Roll"; var RevPost: Record "NPR Audit Roll Posting" temporary; var Dlg: Dialog; UpdateDialog: Boolean): Integer
    var
        Total: Integer;
        nCount: Integer;
    begin
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
    end;

    procedure DoUpdateChanges(var Dlg: Dialog; UpdateDialog: Boolean)
    var
        Revisionsrulle: Record "NPR Audit Roll";
        Total: Integer;
        nCount: Integer;
    begin
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
    end;
}

