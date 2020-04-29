table 6014419 "Archive Sale Line POS"
{
    // The purpose of this table:
    //   All existing unfinished sale transactions have been moved here for possible future reference (6014418 - header, 6014419 - lines).
    //   The table may be deleted later, when it is no longer relevant.
    // 
    // NPR5.54/ALPO/20200203 CASE 364658 Resume POS Sale

    Caption = 'Archive Sale Line POS';
    DrillDownPageID = "Archive POS Sale Lines Subpage";
    LookupPageID = "Archive POS Sale Lines Subpage";
    PasteIsValid = false;

    fields
    {
        field(1;"Register No.";Code[10])
        {
            Caption = 'Cash Register No.';
            NotBlank = true;
            TableRelation = Register;
        }
        field(2;"Sales Ticket No.";Code[20])
        {
            Caption = 'Sales Ticket No.';
            Editable = false;
            NotBlank = true;
        }
        field(3;"Sale Type";Option)
        {
            Caption = 'Sale Type';
            OptionCaption = 'Sale,Payment,Debit Sale,Gift Voucher,Credit Voucher,Deposit,Out payment,Comment,Cancelled,Open/Close';
            OptionMembers = Sale,Payment,"Debit Sale","Gift Voucher","Credit Voucher",Deposit,"Out payment",Comment,Cancelled,"Open/Close";
        }
        field(4;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(5;Type;Option)
        {
            Caption = 'Type';
            InitValue = Item;
            OptionCaption = 'G/L,Item,Item Group,Repair,,Payment,Open/Close,Inventory,Customer,Comment';
            OptionMembers = "G/L Entry",Item,"Item Group",Repair,,Payment,"Open/Close","BOM List",Customer,Comment;
        }
        field(6;"No.";Code[20])
        {
            Caption = 'No.';
            TableRelation = IF (Type=CONST("G/L Entry")) "G/L Account"."No."
                            ELSE IF (Type=CONST("Item Group")) "Item Group"."No."
                            ELSE IF (Type=CONST(Repair)) "Customer Repair"."No."
                            ELSE IF (Type=CONST(Payment)) "Payment Type POS"."No." WHERE (Status=CONST(Active),
                                                                                          "Via Terminal"=CONST(false))
                                                                                          ELSE IF (Type=CONST(Customer)) Customer."No."
                                                                                          ELSE IF (Type=CONST(Item)) Item."No.";
            ValidateTableRelation = false;
        }
        field(7;"Location Code";Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
        }
        field(8;"Posting Group";Code[10])
        {
            Caption = 'Posting Group';
            Editable = false;
            TableRelation = IF (Type=CONST(Item)) "Inventory Posting Group";
        }
        field(9;"Qty. Discount Code";Code[20])
        {
            Caption = 'Qty. Discount Code';
        }
        field(10;Description;Text[80])
        {
            Caption = 'Description';
        }
        field(11;"Unit of Measure Code";Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = IF (Type=CONST(Item),
                                "No."=FILTER(<>'')) "Item Unit of Measure".Code WHERE ("Item No."=FIELD("No."))
                                ELSE "Unit of Measure";
        }
        field(12;Quantity;Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0:5;
            MaxValue = 99.999;
        }
        field(13;"Invoice (Qty)";Decimal)
        {
            Caption = 'Invoice (Qty)';
            DecimalPlaces = 0:5;
        }
        field(14;"To Ship (Qty)";Decimal)
        {
            Caption = 'To Ship (Qty)';
            DecimalPlaces = 0:5;
        }
        field(15;"Unit Price";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            Caption = 'Unit Price';
            DecimalPlaces = 2:2;
            Editable = true;
            MaxValue = 9.999.999;
        }
        field(16;"Unit Cost (LCY)";Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Cost (LCY)';
        }
        field(17;"VAT %";Decimal)
        {
            Caption = 'VAT %';
            DecimalPlaces = 0:5;
            Editable = false;
        }
        field(18;"Qty. Discount %";Decimal)
        {
            Caption = 'Qty. Discount %';
            DecimalPlaces = 0:5;
            MaxValue = 100;
            MinValue = 0;
        }
        field(19;"Discount %";Decimal)
        {
            Caption = 'Discount %';
            DecimalPlaces = 0:1;
            MaxValue = 100;
            MinValue = 0;
        }
        field(20;"Discount Amount";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Discount';
            MinValue = 0;
        }
        field(21;"Manual Item Sales Price";Boolean)
        {
            Caption = 'Manual Item Sales Price';
            InitValue = false;
        }
        field(25;Date;Date)
        {
            Caption = 'Date';
        }
        field(30;Amount;Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Amount';
            DecimalPlaces = 2:2;
            MaxValue = 1.000.000;
        }
        field(31;"Amount Including VAT";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Amount Including VAT';
            MaxValue = 99.999.999;
        }
        field(32;"Allow Invoice Discount";Boolean)
        {
            Caption = 'Allow Invoice Discount';
            InitValue = true;
        }
        field(33;"Allow Line Discount";Boolean)
        {
            Caption = 'Allow Line Discount';
            InitValue = true;
        }
        field(34;"Price Includes VAT";Boolean)
        {
            Caption = 'Price Includes VAT';
        }
        field(38;"Initial Group Sale Price";Decimal)
        {
            Caption = 'Initial Group Sale Price';
        }
        field(41;"Customer Price Group";Code[10])
        {
            Caption = 'Customer Price Group';
            TableRelation = "Customer Price Group";
        }
        field(42;"Allow Quantity Discount";Boolean)
        {
            Caption = 'Allow Quantity Discount';
            InitValue = true;
        }
        field(43;"Serial No.";Code[20])
        {
            Caption = 'Serial No.';
        }
        field(44;"Customer/Item Discount %";Decimal)
        {
            Caption = 'Customer/Item Discount %';
            DecimalPlaces = 0:5;
            MaxValue = 100;
            MinValue = 0;
        }
        field(45;"Sales Order Amount";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            CalcFormula = Sum("Sale Line POS"."Amount Including VAT");
            Caption = 'Sales Order Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(46;"Invoice to Customer No.";Code[20])
        {
            Caption = 'Invoice to Customer No.';
            Editable = false;
            TableRelation = Customer;
        }
        field(47;"Invoice Discount Amount";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Invoice Discount Amount';
        }
        field(48;"Gen. Bus. Posting Group";Code[10])
        {
            Caption = 'Gen. Bus. Posting Group';
            TableRelation = "Gen. Business Posting Group";
        }
        field(49;"Gen. Prod. Posting Group";Code[10])
        {
            Caption = 'Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group";
        }
        field(50;"VAT Bus. Posting Group";Code[10])
        {
            Caption = 'VAT Bus. Posting Group';
            TableRelation = "VAT Business Posting Group";
        }
        field(51;"VAT Prod. Posting Group";Code[10])
        {
            Caption = 'VAT Prod. Posting Group';
            TableRelation = "VAT Product Posting Group";
        }
        field(52;"Currency Code";Code[10])
        {
            Caption = 'Currency Code';
            Editable = false;
            TableRelation = Currency;
        }
        field(53;"Claim (LCY)";Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Claim (LCY)';
            Editable = false;
        }
        field(54;"VAT Base Amount";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'VAT Base Amount';
            Editable = false;
        }
        field(55;Cost;Decimal)
        {
            Caption = 'Cost';
        }
        field(56;Euro;Decimal)
        {
            Caption = 'Euro';
        }
        field(57;"Quantity (Base)";Decimal)
        {
            Caption = 'Quantity (Base)';
        }
        field(58;"Period Discount code";Code[20])
        {
            Caption = 'Period Discount code';
            TableRelation = "Period Discount".Code;
        }
        field(59;"Lookup On No.";Boolean)
        {
            Caption = 'Lookup On No.';
        }
        field(70;"Shortcut Dimension 1 Code";Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
        }
        field(71;"Shortcut Dimension 2 Code";Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
        }
        field(75;"Bin Code";Code[20])
        {
            Caption = 'Bin Code';
            TableRelation = Bin.Code;
        }
        field(80;"Special price";Decimal)
        {
            Caption = 'Special price';
        }
        field(84;"Gen. Posting Type";Option)
        {
            Caption = 'Gen. Posting Type';
            OptionCaption = ' ,Purchase,Sale';
            OptionMembers = " ",Purchase,Sale;
        }
        field(85;"Tax Area Code";Code[20])
        {
            Caption = 'Tax Area Code';
            TableRelation = "Tax Area";
        }
        field(86;"Tax Liable";Boolean)
        {
            Caption = 'Tax Liable';
        }
        field(87;"Tax Group Code";Code[10])
        {
            Caption = 'Tax Group Code';
            TableRelation = "Tax Group";
        }
        field(88;"Use Tax";Boolean)
        {
            Caption = 'Use Tax';
        }
        field(90;"Return Reason Code";Code[10])
        {
            Caption = 'Return Reason Code';
            TableRelation = "Return Reason";
        }
        field(91;"Reason Code";Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        field(100;"Unit Cost";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            Caption = 'Unit Cost';
            DecimalPlaces = 2:2;
            Editable = false;
        }
        field(101;"System-Created Entry";Boolean)
        {
            Caption = 'System-Created Entry';
            Editable = false;
        }
        field(102;"Variant Code";Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = IF (Type=CONST(Item)) "Item Variant".Code WHERE ("Item No."=FIELD("No."));
        }
        field(103;"Line Amount";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Line Amount';
        }
        field(106;"VAT Identifier";Code[10])
        {
            Caption = 'VAT Identifier';
            Editable = false;
        }
        field(117;"Retail Document Type";Option)
        {
            Caption = 'Retail Document Type';
            NotBlank = true;
            OptionCaption = ' ,Selection,Retail Order,Wish,Customization,Delivery,Rental contract,Purchase contract,Qoute';
            OptionMembers = " ","Selection Contract","Retail Order",Wish,Customization,Delivery,"Rental contract","Purchase contract",Quote;
        }
        field(118;"Retail Document No.";Code[20])
        {
            Caption = 'Retail Document No.';
        }
        field(140;"Sales Document Type";Integer)
        {
            Caption = 'Sales Document Type';
        }
        field(141;"Sales Document No.";Code[20])
        {
            Caption = 'Sales Document No.';
        }
        field(142;"Sales Document Line No.";Integer)
        {
            Caption = 'Sales Document Line No.';
        }
        field(143;"Sales Document Prepayment";Boolean)
        {
            Caption = 'Sales Document Prepayment';
        }
        field(144;"Sales Doc. Prepayment Value";Decimal)
        {
            Caption = 'Sales Doc. Prepayment Value';
        }
        field(145;"Sales Document Invoice";Boolean)
        {
            Caption = 'Sales Document Invoice';
        }
        field(146;"Sales Document Ship";Boolean)
        {
            Caption = 'Sales Document Ship';
        }
        field(147;"Sales Document Sync. Posting";Boolean)
        {
            Caption = 'Sales Document Sync. Posting';
        }
        field(148;"Sales Document Print";Boolean)
        {
            Caption = 'Sales Document Print';
        }
        field(149;"Sales Document Receive";Boolean)
        {
            Caption = 'Sales Document Receive';
        }
        field(150;"Customer Location No.";Code[20])
        {
            Caption = 'Customer Location No.';
        }
        field(151;"Sales Document Prepay. Refund";Boolean)
        {
            Caption = 'Sales Document Prepay. Refund';
        }
        field(152;"Sales Document Delete";Boolean)
        {
            Caption = 'Sales Document Delete';
        }
        field(153;"Sales Doc. Prepay Is Percent";Boolean)
        {
            Caption = 'Sales Doc. Prepay Is Percent';
        }
        field(154;"Sales Document Pdf2Nav";Boolean)
        {
            Caption = 'Sales Document Pdf2Nav';
        }
        field(155;"Posted Sales Document Type";Option)
        {
            Caption = 'Posted Sales Document Type';
            OptionCaption = 'Invoice,Credit Memo';
            OptionMembers = INVOICE,CREDIT_MEMO;
        }
        field(156;"Posted Sales Document No.";Code[20])
        {
            Caption = 'Posted Sales Document No.';
            TableRelation = IF ("Posted Sales Document Type"=CONST(INVOICE)) "Sales Invoice Header"
                            ELSE IF ("Posted Sales Document Type"=CONST(CREDIT_MEMO)) "Sales Cr.Memo Header";
        }
        field(157;"Delivered Sales Document Type";Option)
        {
            Caption = 'Delivered Sales Document Type';
            OptionCaption = 'Shipment,Return Receipt';
            OptionMembers = SHIPMENT,RETURN_RECEIPT;
        }
        field(158;"Delivered Sales Document No.";Code[20])
        {
            Caption = 'Delivered Sales Document No.';
            TableRelation = IF ("Delivered Sales Document Type"=CONST(SHIPMENT)) "Sales Shipment Header"
                            ELSE IF ("Delivered Sales Document Type"=CONST(RETURN_RECEIPT)) "Return Receipt Header";
        }
        field(159;"Sales Document Send";Boolean)
        {
            Caption = 'Sales Document Send';
        }
        field(160;"Orig. POS Sale ID";Integer)
        {
            Caption = 'Orig. POS Sale ID';
        }
        field(161;"Orig. POS Line No.";Integer)
        {
            Caption = 'Orig. POS Line No.';
        }
        field(170;"Retail ID";Guid)
        {
            Caption = 'Retail ID';
        }
        field(200;"Qty. per Unit of Measure";Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DecimalPlaces = 0:5;
            Editable = false;
            InitValue = 1;
        }
        field(300;"Return Sale Register No.";Code[10])
        {
            Caption = 'Return Sale Cash Register No.';
        }
        field(301;"Return Sale Sales Ticket No.";Code[20])
        {
            Caption = 'Return Sale Sales Ticket No.';
        }
        field(302;"Return Sales Sales Type";Option)
        {
            Caption = 'Return Sales Sales Type';
            OptionCaption = 'Sale,Payment,Debit Sale,Gift Voucher,Credit Voucher,Payment1,Disbursement,Comment,,Open/Close';
            OptionMembers = Sale,Payment,"Debit Sale","Gift Voucher","Credit Voucher",Payment1,Disbursement,Comment,,"Open/Close";
        }
        field(303;"Return Sale Line No.";Integer)
        {
            Caption = 'Return Sale Line No.';
        }
        field(304;"Return Sale No.";Code[20])
        {
            Caption = 'Return Sale No.';
        }
        field(305;"Return Sales Sales Date";Date)
        {
            Caption = 'Return Sales Sales Date';
        }
        field(400;"Discount Type";Option)
        {
            Caption = 'Discount Type';
            OptionCaption = ' ,Period,Mixed,Multiple Unit,Salesperson Discount,Inventory,,Rounding,Combination,Customer';
            OptionMembers = " ",Campaign,Mix,Quantity,Manual,"BOM List",,Rounding,Combination,Customer;
        }
        field(401;"Discount Code";Code[20])
        {
            Caption = 'Discount Code';
        }
        field(402;"Discount Calculated";Boolean)
        {
            Caption = 'Discount Calculated';
        }
        field(405;"Discount Authorised by";Code[20])
        {
            Caption = 'Discount Authorised by';
            TableRelation = "Salesperson/Purchaser";
        }
        field(420;"Coupon Qty.";Integer)
        {
            CalcFormula = Count("NpDc Sale Line POS Coupon" WHERE ("Register No."=FIELD("Register No."),
                                                                   "Sales Ticket No."=FIELD("Sales Ticket No."),
                                                                   "Sale Type"=FIELD("Sale Type"),
                                                                   "Sale Date"=FIELD(Date),
                                                                   "Sale Line No."=FIELD("Line No."),
                                                                   Type=CONST(Coupon)));
            Caption = 'Coupon Qty.';
            Editable = false;
            FieldClass = FlowField;
        }
        field(425;"Coupon Discount Amount";Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("NpDc Sale Line POS Coupon"."Discount Amount" WHERE ("Register No."=FIELD("Register No."),
                                                                                   "Sales Ticket No."=FIELD("Sales Ticket No."),
                                                                                   "Sale Type"=FIELD("Sale Type"),
                                                                                   "Sale Date"=FIELD(Date),
                                                                                   "Sale Line No."=FIELD("Line No."),
                                                                                   Type=CONST(Discount)));
            Caption = 'Coupon Discount Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(430;"Coupon Applied";Boolean)
        {
            Caption = 'Coupon Applied';
        }
        field(480;"Dimension Set ID";Integer)
        {
            Caption = 'Dimension Set ID';
        }
        field(500;"EFT Approved";Boolean)
        {
            Caption = 'Cash Terminal Approved';
        }
        field(505;"Credit Card Tax Free";Boolean)
        {
            Caption = 'Credit Card Tax Free';
        }
        field(550;"Drawer Opened";Boolean)
        {
            Caption = 'Drawer Opened';
        }
        field(600;"VAT Calculation Type";Option)
        {
            Caption = 'VAT Calculation Type';
            OptionCaption = 'Normal VAT,Reverse Charge VAT,Full VAT,Sales Tax';
            OptionMembers = "Normal VAT","Reverse Charge VAT","Full VAT","Sales Tax";
        }
        field(700;"NPRE Seating Code";Code[10])
        {
            Caption = 'Seating Code';
            TableRelation = "NPRE Seating";
        }
        field(801;"Insurance Category";Code[50])
        {
            Caption = 'Insurance Category';
            TableRelation = "Insurance Category";
        }
        field(5002;Color;Code[20])
        {
            Caption = 'Color';
        }
        field(5003;Size;Code[20])
        {
            Caption = 'Size';
        }
        field(5004;Clearing;Option)
        {
            Caption = 'Clearing';
            OptionCaption = ' ,Gift Voucher,Credit Voucher';
            OptionMembers = " ",Gavekort,Tilgodebevis;
        }
        field(5008;"External Document No.";Code[20])
        {
            Caption = 'External Document No.';
        }
        field(5999;"Buffer Ref. No.";Integer)
        {
            Caption = 'Buffer Ref. No.';
        }
        field(6000;"Buffer Document Type";Option)
        {
            Caption = 'Buffer Document Type';
            OptionCaption = ' ,Payment,Invoice,Credit Note,Interest Note,Reminder';
            OptionMembers = " ",Betaling,Faktura,Kreditnota,Rentenota,Rykker;
        }
        field(6001;"Buffer ID";Code[20])
        {
            Caption = 'Buffer ID';
        }
        field(6002;"Buffer Document No.";Code[20])
        {
            Caption = 'Buffer Document No.';
        }
        field(6003;"Vendor No.";Code[20])
        {
            Caption = 'Vendor No.';
        }
        field(6004;Internal;Boolean)
        {
            Caption = 'Internal';
            InitValue = false;
        }
        field(6005;"Currency Amount";Decimal)
        {
            Caption = 'Currency Amount';
        }
        field(6006;Accessory;Boolean)
        {
            Caption = 'Accessory';
            InitValue = false;
        }
        field(6007;"Main Item No.";Code[21])
        {
            Caption = 'Main Item No.';
        }
        field(6008;"Combination Item";Boolean)
        {
            Caption = 'Combination Item';
        }
        field(6009;"Combination No.";Code[20])
        {
            Caption = 'Combination No.';
        }
        field(6010;"From Selection";Boolean)
        {
            Caption = 'From Selection';
            InitValue = false;
        }
        field(6011;"Item Group";Code[10])
        {
            Caption = 'Item Group';
            TableRelation = "Item Group";
        }
        field(6012;"MR Anvendt antal";Decimal)
        {
            Caption = 'MR Used Amount';
        }
        field(6013;"FP Anvendt";Boolean)
        {
            Caption = 'FP Used';
            InitValue = true;
        }
        field(6014;"Eksp. Salgspris";Boolean)
        {
            Caption = 'Sale POS Salesprice';
            InitValue = false;
        }
        field(6015;"Serial No. not Created";Code[30])
        {
            Caption = 'Serial No. not Created';
        }
        field(6019;"Custom Price";Boolean)
        {
            Caption = 'Custom Price';
        }
        field(6020;NegPriceZero;Boolean)
        {
            Caption = 'NegPriceZero';
        }
        field(6021;Reference;Text[50])
        {
            Caption = 'Reference';
        }
        field(6022;"Rep. Nummer";Code[10])
        {
            Caption = 'Rep. No.';
        }
        field(6023;"Gift Voucher Ref.";Code[20])
        {
            Caption = 'Gift Voucher Ref.';
        }
        field(6024;"Credit voucher ref.";Code[20])
        {
            Caption = 'Credit voucher ref.';
        }
        field(6025;"Custom Cost";Boolean)
        {
            Caption = 'Custom Cost';
        }
        field(6026;"Wish List";Code[10])
        {
            Caption = 'Wish list';
        }
        field(6027;"Wish List Line No.";Integer)
        {
            Caption = 'Wish List Line No.';
        }
        field(6028;"Item group accessory";Boolean)
        {
            Caption = 'Itemgroup Accessories';
        }
        field(6029;"Accessories Item Group No.";Code[20])
        {
            Caption = 'Accessories Itemgroup No.';
        }
        field(6032;"Label Quantity";Integer)
        {
            Caption = 'Label Quantity';
        }
        field(6033;"Offline Sales Ticket No";Code[20])
        {
            Caption = 'Emergency Ticket No.';
        }
        field(6034;"Custom Descr";Boolean)
        {
            Caption = 'Customer Description';
        }
        field(6036;"Foreign No.";Code[20])
        {
            Caption = 'Foreign No.';
        }
        field(6037;GiftCrtLine;Integer)
        {
            Caption = 'Gift Certificate Line';
        }
        field(6038;"Label Date";Date)
        {
            Caption = 'Label Date';
        }
        field(6039;"Description 2";Text[50])
        {
            Caption = 'Description 2';
        }
        field(6043;"Order No. from Web";Code[20])
        {
            Caption = 'Order No. from Web';
        }
        field(6044;"Order Line No. from Web";Integer)
        {
            BlankZero = true;
            Caption = 'Order Line No. from Web';
        }
        field(6050;"Item Category Code";Code[10])
        {
            Caption = 'Item Category Code';
        }
        field(6051;"Product Group Code";Code[10])
        {
            Caption = 'Product Group Code';
        }
        field(6055;"Lock Code";Code[10])
        {
            Caption = 'Lock Code';
        }
        field(6100;"Main Line No.";Integer)
        {
            Caption = 'Main Line No.';
        }
        field(7014;"Item Disc. Group";Code[20])
        {
            Caption = 'Item Disc. Group';
            TableRelation = IF (Type=CONST(Item),
                                "No."=FILTER(<>'')) "Item Discount Group" WHERE (Code=FIELD("Item Disc. Group"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(10000;Silent;Boolean)
        {
            Caption = 'Silent';
        }
        field(10001;Deleting;Boolean)
        {
            Caption = 'Deleting';
        }
        field(10002;NoWarning;Boolean)
        {
            Caption = 'No Warning';
        }
        field(10003;CondFirstRun;Boolean)
        {
            Caption = 'Conditioned First Run';
            InitValue = true;
        }
        field(10004;CurrencySilent;Boolean)
        {
            Caption = 'Currency (Silent)';
        }
        field(10005;StyklisteSilent;Boolean)
        {
            Caption = 'Bill of materials (Silent)';
        }
        field(10006;"Cust Forsikring";Boolean)
        {
            Caption = 'Cust. Insurrance';
        }
        field(10007;Forsikring;Boolean)
        {
            Caption = 'Insurrance';
        }
        field(10008;TestOnServer;Boolean)
        {
            Caption = 'Test on Server';
        }
        field(10009;"Customer No. Line";Boolean)
        {
            Caption = 'Customer No. Line';
        }
        field(10010;ForceApris;Boolean)
        {
            Caption = 'Force A-Price';
        }
        field(10011;GuaranteePrinted;Boolean)
        {
            Caption = 'Guarantee Certificat Printed';
        }
        field(10012;"Custom Disc Blocked";Boolean)
        {
            Caption = 'Custom Disc Blocked';
        }
        field(10013;"Invoiz Guid";Text[150])
        {
            Caption = 'Invoiz Guid';
        }
        field(6014511;"Label No.";Code[8])
        {
            Caption = 'Label Number';
        }
        field(6014512;"SQL Server Timestamp";BigInteger)
        {
            Caption = 'Timestamp';
            Editable = false;
            SQLTimestamp = true;
        }
    }

    keys
    {
        key(Key1;"Register No.","Sales Ticket No.",Date,"Sale Type","Line No.")
        {
            MaintainSIFTIndex = false;
            SumIndexFields = "Amount Including VAT",Cost,"Discount Amount",Amount;
        }
        key(Key2;"Register No.","Sales Ticket No.","Sale Type","Line No.")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
        }
        key(Key3;"Register No.","Sales Ticket No.","Sale Type",Type,"No.","Item Group",Quantity)
        {
            MaintainSIFTIndex = false;
            SumIndexFields = "Amount Including VAT",Amount,Quantity;
        }
        key(Key4;"Register No.","Sales Ticket No.","Line No.")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
        }
        key(Key5;"Discount Type")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount Including VAT",Amount;
        }
        key(Key6;"Register No.","Sales Ticket No.",Date,"Sale Type",Type,"Discount Type","Line No.")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount Including VAT";
        }
        key(Key7;"Serial No.")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
        }
        key(Key8;"Register No.","Sales Ticket No.","No.")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = Quantity;
        }
        key(Key9;"Insurance Category","Register No.","Sales Ticket No.",Date,"Sale Type",Type)
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount Including VAT";
        }
    }

    fieldgroups
    {
    }
}

