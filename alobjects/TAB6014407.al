table 6014407 "Audit Roll"
{
    // //----MG 14/9-01 rettelse til udskrivrecords
    // 
    // //-0023 : Henrik, Bonudskrivning af forskellig rapport afh�ngig af kasse.
    // 
    // //-NPK3.0a Ved Nikolai Pedersen
    //   Tilf�jet funktionen Sletning der sletter frem til indtastede dato
    // 
    // //-NPR3.1r NE
    //   Incrementcount rettet.
    // 
    // // The Key
    //       "Sale Date,Sale Type,Type,Starting Time,Closing Time,Shortcut Dimension 1 Code,Shortcut Dimension 2 Code"
    // 
    //     Is only required if the time analysis module is active... otherwise it can be switched off
    // 
    // NPR4.002.002, 11-06-09, MH, Tilf�jet feltet "Lock Code" (sag 65422).
    // NPR4.004.003, 01-12-09, MH, Added function, SendLatestAsPDF - Sends the latest audit by email (Job 79125).
    // NPR4.004.004, 03-12-09, MH, Added "Label No." (job 59317).
    // PN1.04/MH/20140819  NAV-AddOn: PDF2NAV
    //   - Moved PDF functionality (NPR4.004.003) to Codeunit 6014464 "E-mail Document Management":
    //     A. SendAsPDF() --> SendReportAuditRoll()
    //     B. SendLatestAsPDF() --> SendReportLatestAuditRoll()
    // NPR4.01/JDH /20150310  CASE 201022 Removed reference to assortments
    // NPR4.04/JDH /20150427  CASE 212229 Removed references to old Variant solution "Color Size"
    // NPR4.10/MMV /20150611  CASE 215921 Added method GetNoOfSales from latest 6.2 release
    // NPR4.11/MMV /20150618  CASE 215957 Added new field 10020 to replace 50005. Updated function "IncrementCount" to new field.
    // NPR4.11/MMV /20150618  CASE 215921 Removed hardcoded filter on Type in NPR4.10 change - More use cases when you define filters before calling function.
    // NPR4.14/RMT /20150715  CASE 216519 Added fields - used for registering prepayment
    //                                    140 "Sales Document Type"
    //                                    141 "Sales Document No."
    //                                    142 "Sales Document Line No."
    //                                    143 "Sales Document Prepayment"
    //                                    144 "Sales Doc. Prepayment %"
    // NPR4.14/MMV /20150826  CASE 221045 Expanded field 106 from code10 to code20 to match size of all the sales doc. numbers.
    // NPR5.01/RMT /20160217  CASE 234145 Change field "Register No." property "SQL Data Type" from Variant to <Undefined>
    //                                    Change field "Sales Ticket No." property "SQL Data Type" from Variant to <Undefined>
    //                                    NOTE: requires data upgrade
    // NPR4.21/JHL /20160316  CASE 222417 Deleted old fields dealing with CleanCash
    // NPR4.21/BHR /20160318  CASE 229736 Code to flow "dimension set ID"
    // NPR5.23/JDH /20160523  CASE 242105 new key for sorting audit roll cronologically "Sale Date,Sales Ticket No.,Line No."
    // NPR5.23/MMV /20160527  CASE 242202 Removed deprecated discount code.
    //                                    Updated report selection reference.
    // NPR5.23/MHA /20160530  CASE 242929 Field 6005 "Description 2" length increased from 30 to 50
    // NPR5.27/JDH /20161018  CASE 255575 Removed unused functions
    // NPR5.30/MHA /20170201  CASE 264918 Np Photo Module removed
    // NPR5.30/TJ  /20170215  CASE 265504 Changed ENU captions on fields with word Register in their name
    // NPR5.31/AP  /20160915  CASE 248534 US Sales Tax
    //                                    Added the fields  85 "Tax Area Code", 86 "Tax Liable", 87 "Tax Group Code", 88 "Use Tax"
    // NPR5.31/MMV /20170321  CASE 269028 Re-added function IncrementPrintedCount
    // NPR5.31/AP  /20173103  CASE 262628 Added field 160 POS Sale ID. Surrogate key from POS Sale.
    //                                    Added field 161 Orig. POS Sale ID and 162 Orig POS Line No.
    // NPR5.31/JLK /20170420  CASE 272626 Changed ENU Caption on Sale Type
    // NPR5.35/TJ  /20170809  CASE 286283 Renamed variables/function into english and into proper naming terminology
    //                                    Removed unused variables
    // NPR5.36/TJ  /20170904  CASE 286283 Renamed all the danish OptionString properties to english
    // NPR5.38/BR  /20171207  CASE 299035 Added Key Sale Date,Sales Ticket No.,Sale Type,Line No., Disabled: Retail Document Type,Retail Document No., Sale Date,Invoiz Guid and Sale Date,Sales Ticket No.,Line No.
    // NPR5.38/TJ  /20171218  CASE 225415 Renumbered fields from range 50xxx to range below 50000
    // NPR5.38/MHA /20180105  CASE 301053 Renamed field 108 and 109 to reflect the field names from Sale Line POS
    // NPR5.39/MHA /20180214 CASE 305139 Added field 405 "Discount Authorised by"
    // NPR5.41/JDH /20180406 CASE 308194 Changed key "Sale Date","Sales Ticket No.","Sale Type","Line No." to "MaintainSQLIndex" = true, for better performance on page Audit Roll
    // NPR5.42/BHR /20180518 CASE 314987 Added functionality to Change dimension
    // NPR5.43/JDH /20180620 CASE 317453 Removed non existing table relation from Field 40 (ref to old Department table 11)
    // NPR5.43/JC  /20180625 CASE 320335 Transfer value of serial no. not created
    // NPR5.43/JDH /20180702 CASE 321012 Removed Color and size transfers - they are legacy
    // NPR5.45/TSA /20180809 CASE 310137 Changed captions on field 110 ("Document Type" -> "Retail Document Type") and 111 ("No." -> Retail Document No.") to become different from existing fields (6 and 107)
    // NPR5.45/THRO/20180815 CASE 321951 Added Fieldgroup Brick (Sales Ticket No.,Description,No.,Sale Date,Starting Time,Register No.)
    // NPR5.45/MHA /20180821 CASE 324395 SaleLinePOS."Unit Price (LCY)" Renamed to "Unit Cost (LCY)"
    // NPR5.48/JDH /20181113 CASE 334555 Changed Unit of measure code from Text to Code

    Caption = 'Audit Roll';
    DrillDownPageID = "Audit Roll";
    LookupPageID = "Audit Roll";
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
            OptionCaption = 'Sale,Payment,Debit Sale,Gift Voucher,Credit Voucher,Deposit,Out payment,Comment,,Open/Close';
            OptionMembers = Sale,Payment,"Debit Sale","Gift Voucher","Credit Voucher",Deposit,"Out payment",Comment,,"Open/Close";
        }
        field(4;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(5;Type;Option)
        {
            Caption = 'Type';
            InitValue = Item;
            OptionCaption = 'G/L,Item,Payment,Open/Close,Customer,Debit Sale,Cancelled,Comment';
            OptionMembers = "G/L",Item,Payment,"Open/Close",Customer,"Debit Sale",Cancelled,Comment;
        }
        field(6;"No.";Code[20])
        {
            Caption = 'No.';
            TableRelation = IF (Type=CONST("G/L")) "G/L Account"."No."
                            ELSE IF (Type=CONST(Payment)) "Payment Type POS"."No."
                            ELSE IF (Type=CONST(Customer)) Customer."No."
                            ELSE IF (Type=CONST(Item)) Item."No." WHERE (Blocked=CONST(false));
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                case Type of
                  Type::"G/L":
                    begin
                      TestField(Type,Type::"G/L");
                      //TESTFIELD("Sale Type","Sale Type"::Udbetaling);  //ohm - not applicable using gift vouchers
                      TestField(Posted,false);
                      if "No." <> '*' then begin
                        GLAccount.Get("No.");
                        GLAccount.TestField("Direct Posting",true);
                        GLAccount.TestField(Blocked,false);
                      end;
                    end;
                end;
            end;
        }
        field(7;Lokationskode;Code[10])
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
        field(19;"Line Discount %";Decimal)
        {
            BlankZero = true;
            Caption = 'Line Discount %';
            DecimalPlaces = 0:5;
            MaxValue = 100;
            MinValue = 0;
        }
        field(20;"Line Discount Amount";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            BlankZero = true;
            Caption = 'Line Discount Amount';
        }
        field(25;"Sale Date";Date)
        {
            Caption = 'Sale Date';
        }
        field(26;"Posted Doc. No.";Code[20])
        {
            Caption = 'Posted Doc. No.';
        }
        field(30;Amount;Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Amount';
        }
        field(31;"Amount Including VAT";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Amount Including VAT';
            DecimalPlaces = 2:2;
        }
        field(32;"Allow Invoice Discount";Boolean)
        {
            Caption = 'Allow Invoice Discount';
            InitValue = true;
        }
        field(40;"Department Code";Code[10])
        {
            Caption = 'Department Code DONT USE';
            Description = 'Not used. use "Shortcut Dimension 1 Code" instead';
        }
        field(41;"Price Group Code";Code[10])
        {
            Caption = 'Price Group Code';
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
            Caption = 'Sales Order Amount';
            Editable = false;
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
        field(58;"Period Discount code";Code[20])
        {
            Caption = 'Period Discount code';
            TableRelation = "Period Discount".Code;
        }
        field(59;"Gift voucher ref.";Code[20])
        {
            Caption = 'Gift voucher ref.';
        }
        field(60;"Credit voucher ref.";Code[20])
        {
            Caption = 'Credit voucher ref.';
        }
        field(61;"Salgspris inkl. moms";Boolean)
        {
            Caption = 'Unit Price incl. VAT';
        }
        field(62;"Fremmed nummer";Code[20])
        {
            Caption = 'Fremmed nummer';
        }
        field(63;"Clearing Date";Date)
        {
            Caption = 'Clearing Date';
        }
        field(70;"Shortcut Dimension 1 Code";Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(1));

            trigger OnLookup()
            begin
                LookUpShortcutDimCode(1,"Shortcut Dimension 1 Code");
                Validate("Shortcut Dimension 1 Code","Shortcut Dimension 1 Code");
            end;

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1,"Shortcut Dimension 1 Code");
                //-NPR5.42 [314987]
                //MODIFY;
                //-NPR5.42 [314987]
            end;
        }
        field(71;"Shortcut Dimension 2 Code";Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(2));

            trigger OnLookup()
            begin
                LookUpShortcutDimCode(2,"Shortcut Dimension 2 Code");
                Validate("Shortcut Dimension 2 Code","Shortcut Dimension 2 Code");
            end;

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2,"Shortcut Dimension 2 Code");
                //MODIFY;    //swteams an
            end;
        }
        field(72;"Offline - Gift voucher ref.";Code[20])
        {
            Caption = 'Offline - Gift voucher ref.';
        }
        field(73;"Offline - Credit voucher ref.";Code[20])
        {
            Caption = 'Offline - Credit voucher ref.';
        }
        field(75;"Bin Code";Code[10])
        {
            Caption = 'Bin Code';
            TableRelation = Bin;
        }
        field(80;"Special price";Decimal)
        {
            Caption = 'Special price';
        }
        field(85;"Tax Area Code";Code[20])
        {
            Caption = 'Tax Area Code';
            Description = 'NPR5.31';
            TableRelation = "Tax Area";
        }
        field(86;"Tax Liable";Boolean)
        {
            Caption = 'Tax Liable';
            Description = 'NPR5.31';
        }
        field(87;"Tax Group Code";Code[10])
        {
            Caption = 'Tax Group Code';
            Description = 'NPR5.31';
            TableRelation = "Tax Group";
        }
        field(88;"Use Tax";Boolean)
        {
            Caption = 'Use Tax';
            Description = 'NPR5.31';
        }
        field(90;"Return Reason Code";Code[10])
        {
            Caption = 'Return Reason Code';
            TableRelation = "Return Reason";
        }
        field(95;"Clustered Key";Integer)
        {
            AutoIncrement = true;
            Caption = 'Clustered Key';
        }
        field(100;"Unit Cost";Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            Caption = 'Unit Cost';
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
        field(105;"Allocated No.";Code[10])
        {
            Caption = 'Allocated No.';
        }
        field(106;"Document No.";Code[20])
        {
            Caption = 'Document No.';
        }
        field(107;"Document Type";Option)
        {
            Caption = 'Document Type';
            OptionCaption = 'Invoice,Order,Credit Memo,Return Order';
            OptionMembers = Invoice,"Order","Credit Memo","Return Order";
        }
        field(108;"Wish List";Code[10])
        {
            Caption = 'Wish List';
            Description = 'NPR5.38';
        }
        field(109;"Wish List Line No.";Integer)
        {
            Caption = 'Wish List Line No.';
            Description = 'NPR5.38';
        }
        field(110;"Retail Document Type";Option)
        {
            Caption = 'Retail Document Type';
            NotBlank = true;
            OptionCaption = ' ,Selection,Retail Order,Wish,Customization,Delivery,Rental contract,Purchase contract,Qoute';
            OptionMembers = " ","Selection Contract","Retail Order",Wish,Customization,Delivery,"Rental contract","Purchase contract",Quote;
        }
        field(111;"Retail Document No.";Code[20])
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
        field(144;"Sales Doc. Prepayment %";Decimal)
        {
            Caption = 'Sales Doc. Prepayment %';
        }
        field(145;"Sales Document Invoice";Boolean)
        {
            Caption = 'Sales Document Invoice';
        }
        field(146;"Sales Document Ship";Boolean)
        {
            Caption = 'Sales Document Ship';
        }
        field(160;"POS Sale ID";Integer)
        {
            Caption = 'POS Sale ID';
            Description = 'NPR5.31';
        }
        field(161;"Orig. POS Sale ID";Integer)
        {
            Caption = 'Orig. POS Sale ID';
            Description = 'NPR5.31';
        }
        field(162;"Orig. POS Line No.";Integer)
        {
            Caption = 'Orig. POS Line No.';
            Description = 'NPR5.31';
        }
        field(200;"Salesperson Code";Code[10])
        {
            Caption = 'Salesperson Code';
            TableRelation = "Salesperson/Purchaser";
        }
        field(201;"Reversed by Salesperson Code";Code[10])
        {
            Caption = 'Reversed by Salesperson Code';
            Description = 'Udfyldes med s�lgerkoden der tilbagef�rer bon''en';
            TableRelation = "Salesperson/Purchaser";
        }
        field(202;"Reverseing Sales Ticket No.";Code[20])
        {
            Caption = 'Reverseing Sales Ticket No.';
            Description = 'Peger p� det bonnummer som den aktuelle bon tilbagef�rer';
        }
        field(203;"Reversed by Sales Ticket No.";Code[20])
        {
            Caption = 'Reversed by Sales Ticket No.';
            Description = 'Peger p� det bonnummer som tilbagef�rte aktuel bonnummer';
        }
        field(300;"Cancelled No. Of Items";Decimal)
        {
            Caption = 'Cancelled No. Of Items';
        }
        field(301;"Cancelled Amount On Ticket";Decimal)
        {
            Caption = 'Cancelled Amount On Ticket';
        }
        field(400;"Discount Type";Option)
        {
            Caption = 'Discount Type';
            Description = 'NPR5.30';
            OptionCaption = ' ,Period,Mixed,Multiple Unit,Salesperson Discount,Inventory,,Rounding,Combination,Customer';
            OptionMembers = " ",Campaign,Mix,Quantity,Manual,"BOM List",,Rounding,Combination,Customer;
        }
        field(401;"Discount Code";Code[30])
        {
            Caption = 'Discount Code';
        }
        field(405;"Discount Authorised by";Code[20])
        {
            Caption = 'Discount Authorised by';
            Description = 'NPR5.39';
            TableRelation = "Salesperson/Purchaser";
        }
        field(480;"Dimension Set ID";Integer)
        {
            Caption = 'Dimension Set ID';
        }
        field(500;"Cash Terminal Approved";Boolean)
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
            Description = 'NPR4.001.000, for indication of opening on drawer.';
        }
        field(600;"Total Qty";Decimal)
        {
            Caption = 'Total Qty';
        }
        field(1000;"Starting Time";Time)
        {
            Caption = 'Starting Time';
        }
        field(1001;"Closing Time";Time)
        {
            Caption = 'Closing Time';
        }
        field(1002;"Receipt Type";Option)
        {
            Caption = 'Ticket Type';
            OptionCaption = ' ,Negative Sales Ticket,Change,Outpayment,Return Item,Sales in Negative Receipt';
            OptionMembers = " ","Negative receipt","Change money",Outpayment,"Return items","Sales in negative receipt";
        }
        field(1500;"Tax Free Refund";Decimal)
        {
            Caption = 'Tax Free Refund';
            Description = 'Amount refunded by Tax Free. Sag 66308';
        }
        field(2000;"Closing Cash";Decimal)
        {
            Caption = 'Closing Cash';
        }
        field(2001;"Opening Cash";Decimal)
        {
            Caption = 'Opening Cash';
        }
        field(2002;"Transferred to Balance Account";Decimal)
        {
            Caption = 'Transferred to Balance Account';
        }
        field(2003;Difference;Decimal)
        {
            Caption = 'Difference';
        }
        field(2004;EuroDifference;Decimal)
        {
            Caption = 'EuroDifference';
        }
        field(2005;"Change Register";Decimal)
        {
            Caption = 'Change Register';
        }
        field(3000;Posted;Boolean)
        {
            Caption = 'Posted';
        }
        field(3001;"Posting Date";Date)
        {
            Caption = 'Posting Date';
        }
        field(3002;"Internal Posting No.";Integer)
        {
            Caption = 'Internal Posting No.';
        }
        field(5002;Color;Code[20])
        {
            Caption = 'Color';
        }
        field(5003;Size;Code[20])
        {
            Caption = 'Size';
        }
        field(5004;"Serial No. not Created";Code[30])
        {
            Caption = 'Serial No. not Created';
        }
        field(5006;"Cash Customer No.";Code[30])
        {
            Caption = 'Cash Customer No.';
        }
        field(5020;"Customer No.";Code[20])
        {
            Caption = 'Customer No.';
        }
        field(5021;"Customer Type";Option)
        {
            Caption = 'Customer Type';
            OptionCaption = 'Ord.,Cash';
            OptionMembers = "Ord.",Cash;
        }
        field(5022;Reference;Text[50])
        {
            Caption = 'Reference';
        }
        field(5023;Accessory;Boolean)
        {
            Caption = 'Accessory';
        }
        field(5024;"Payment Type No.";Code[10])
        {
            Caption = 'Payment Type No.';
            NotBlank = true;
        }
        field(6000;"N3 Debit Sale Conversion";Boolean)
        {
            Caption = 'N3 Debit Sale Conversion';
        }
        field(6001;"Buffer Document Type";Option)
        {
            Caption = 'Buffer Document Type';
            Description = 'NP-retail 1.8';
            OptionCaption = ' ,Payment,Invoice,Credit Note,Interest Note,Reminder';
            OptionMembers = " ",Payment,Invoice,"Credit Note","Interest Note",Reminder;
        }
        field(6002;"Buffer ID";Code[20])
        {
            Caption = 'Buffer ID';
            Description = 'NP-retail 1.8';
        }
        field(6003;"Buffer Invoice No.";Code[20])
        {
            Caption = 'Buffer Invoice No.';
            Description = 'NP-retail 1.8';
        }
        field(6004;"Reason Code";Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        field(6005;"Description 2";Text[50])
        {
            Caption = 'Description 2';
            Description = 'NPR5.23';
        }
        field(6006;"Touch Screen sale";Boolean)
        {
            Caption = 'Touch Screen sale';
        }
        field(6007;"Money bag no.";Code[20])
        {
            Caption = 'Money bag no.';
        }
        field(6008;"External Document No.";Code[20])
        {
            Caption = 'External Document No.';
        }
        field(6009;LineCounter;Decimal)
        {
            Caption = 'LineCounter';
            Description = 'Hack til hurtigt count vha. sum index fields.';
            InitValue = 1;
        }
        field(6010;"Order No. from Web";Code[20])
        {
            Caption = 'Order No. from Web';
        }
        field(6011;"Order Line No. from Web";Integer)
        {
            BlankZero = true;
            Caption = 'Order Line No. from Web';
        }
        field(6015;Offline;Boolean)
        {
            Caption = 'Offline';
        }
        field(6020;Internal;Boolean)
        {
            Caption = 'Internal';
            InitValue = false;
        }
        field(6025;"Customer Post Code";Code[20])
        {
            Caption = 'Customer Post Code';
        }
        field(6030;"Currency Amount";Decimal)
        {
            Caption = 'Currency Amount';
        }
        field(6035;"Item Entry Posted";Boolean)
        {
            Caption = 'Item Entry Posted';
            InitValue = false;
        }
        field(6040;"Copy No.";Integer)
        {
            Caption = 'Copy No.';
            InitValue = -1;
        }
        field(6045;"Item Group";Code[10])
        {
            Caption = 'Item Group';
        }
        field(6050;Kundenavn;Text[50])
        {
            Caption = 'Customer Name';
        }
        field(6055;Send;Date)
        {
            Caption = 'Send';
            Description = 'Bruges ifm. replikering til at afg�ren om det felt er udl�st eller ej';
        }
        field(6060;"Offline receipt no.";Code[20])
        {
            Caption = 'Offline receipt no.';
        }
        field(6065;"Lock Code";Code[10])
        {
            Caption = 'Lock Code';
            Description = 'NPR4.002.002';
        }
        field(6070;"Sale Date filter";Date)
        {
            Caption = 'Sale Date filter';
            FieldClass = FlowFilter;
        }
        field(10000;"Balance Amount";Code[200])
        {
            Caption = 'Balance Amount';
        }
        field(10001;"Balance Sundries";Code[200])
        {
            Caption = 'Balance Sundries';
        }
        field(10002;"Balance Printed";Integer)
        {
            Caption = 'Balance Printed';
        }
        field(10003;Balancing;Boolean)
        {
            Caption = 'Balancing';
        }
        field(10004;Vendor;Code[20])
        {
            Caption = 'Vendor';
        }
        field(10005;"Balanced on Sales Ticket No.";Code[20])
        {
            Caption = 'Balanced on Sales Ticket No.';
            Description = 'Bruges ifm. samling af flere kasser.';
        }
        field(10006;"On Register No.";Code[10])
        {
            Caption = 'On Register No.';
        }
        field(10007;"Balance amount euro";Code[200])
        {
            Caption = 'Balance amount euro';
        }
        field(10013;"Invoiz Guid";Text[150])
        {
            Caption = 'Invoiz Guid';
        }
        field(10020;"No. Printed";Integer)
        {
            Caption = 'No. Printed';
            InitValue = 0;
        }
        field(6014511;"Label No.";Code[8])
        {
            Caption = 'Label Number';
            Description = 'NPR4.004.004 - Benyttes i forbindelse med Smart Safety forsikring';
        }
    }

    keys
    {
        key(Key1;"Register No.","Sales Ticket No.","Sale Type","Line No.","No.","Sale Date")
        {
            SumIndexFields = "Amount Including VAT";
        }
        key(Key2;"Clustered Key")
        {
        }
        key(Key3;"Register No.","Sales Ticket No.","Sale Type",Type,"No.")
        {
            MaintainSQLIndex = false;
            SumIndexFields = "Amount Including VAT","Currency Amount","Line Discount Amount",Cost,Amount,"Unit Cost",Quantity;
        }
        key(Key4;"Register No.","Sale Type",Type,"No.","Sale Date","Discount Type","Shortcut Dimension 1 Code","Shortcut Dimension 2 Code")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount Including VAT",Amount,Cost,"Line Discount Amount";
        }
        key(Key5;"Register No.","Sales Ticket No.","Sale Type",Type)
        {
            Enabled = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount Including VAT","Line Discount Amount",Cost,Amount,"Unit Cost";
        }
        key(Key6;"Register No.",Posted,"Sale Date",Type,"Credit voucher ref.")
        {
        }
        key(Key7;"Sale Type",Type,"No.",Posted)
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount Including VAT";
        }
        key(Key8;"Register No.","Sales Ticket No.","Sale Date","Sale Type",Type,"No.")
        {
            MaintainSQLIndex = false;
            SumIndexFields = "Amount Including VAT",Cost,"Line Discount Amount",Amount;
        }
        key(Key9;Posted,"Serial No.")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = Quantity;
        }
        key(Key10;"Register No.","Sales Ticket No.",Type,"Closing Time",Description,"Sale Date","Salesperson Code")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = true;
            SumIndexFields = "Amount Including VAT","Line Discount Amount";
        }
        key(Key11;Send,Type,"Sale Type")
        {
            Enabled = false;
            MaintainSQLIndex = false;
        }
        key(Key12;Offline,"Offline receipt no.",Posted,"Sale Type")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
        }
        key(Key13;"Sales Ticket No.",Type)
        {
        }
        key(Key14;"Sale Date","Sale Type",Type,"Gift voucher ref.","Register No.","Closing Time","Salesperson Code","Receipt Type","Shortcut Dimension 1 Code","Shortcut Dimension 2 Code")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount Including VAT",Quantity,"Line Discount Amount",Amount,Cost;
        }
        key(Key15;"Register No.","Sale Date","Sale Type",Type,Quantity,"Receipt Type","Shortcut Dimension 1 Code","Shortcut Dimension 2 Code")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount Including VAT",Amount,Cost;
        }
        key(Key16;"Sale Type",Type,"Starting Time","Closing Time","Sale Date","Shortcut Dimension 1 Code","Shortcut Dimension 2 Code",Lokationskode)
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount Including VAT",Quantity,LineCounter;
        }
        key(Key17;"Retail Document Type","Retail Document No.")
        {
            Enabled = false;
            MaintainSQLIndex = false;
        }
        key(Key18;"Salesperson Code","Register No.","Sale Date")
        {
            SumIndexFields = Amount;
        }
        key(Key19;"Sale Type",Type,"Item Entry Posted")
        {
            MaintainSQLIndex = false;
        }
        key(Key20;"Sale Date","Invoiz Guid")
        {
            Enabled = false;
            MaintainSQLIndex = false;
        }
        key(Key21;"Customer No.")
        {
        }
        key(Key22;"Register No.","Sales Ticket No.","Line No.")
        {
            SumIndexFields = "Amount Including VAT",Amount,Cost;
        }
        key(Key23;"Register No.","Sales Ticket No.","Sale Type","Cash Terminal Approved")
        {
            SumIndexFields = "Amount Including VAT";
        }
        key(Key24;"Sales Ticket No.","Line No.")
        {
        }
        key(Key25;"Sale Date","Sales Ticket No.","Line No.")
        {
            Enabled = false;
        }
        key(Key26;"Sale Date","Sales Ticket No.","Sale Type","Line No.")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(Brick;"Sales Ticket No.",Description,"No.","Sale Date","Starting Time","Register No.")
        {
        }
    }

    trigger OnDelete()
    begin
        RetailSetup.Get;
        if RetailSetup."Use Adv. dimensions" then
          NPRDimMgt.DeleteNPRDim(DATABASE::"Audit Roll","Register No.","Sales Ticket No.","Sale Date","Sale Type","Line No.","No.");
    end;

    trigger OnInsert()
    var
        Register2: Record Register;
        InsertAllowed: Boolean;
    begin
        //KasseLoc.LOCKTABLE; //ohm 18/8/06 - why?

        if Register2.Get("Register No.") then begin
          InsertAllowed := false;
          case Register2.Status of
            Register2.Status::" ":
              begin
                // Alt tilladt
                InsertAllowed := true;
              end;
            Register2.Status::Ekspedition:
              begin
                // Alt tilladt
                InsertAllowed := true;
              end;
            Register2.Status::Afsluttet:
              begin
                if Type = Type::"Open/Close" then
                  if not Balancing then
                    InsertAllowed := true;
                  if Balancing then
                    if Register2."Status Set By Sales Ticket" = "Sales Ticket No." then
                      InsertAllowed := true
                    else
                      Error(Text1060002,"Sales Ticket No.",Register2."Status Set By Sales Ticket",Register2.Status);

                if Type = Type::Cancelled then
                  InsertAllowed := true;
              end;
            Register2.Status::"Under afslutning":
              begin
                if Type = Type::"Open/Close" then
                  if Balancing then
                    if Register2."Status Set By Sales Ticket" = "Sales Ticket No." then
                      InsertAllowed := true
                    else
                      Error(Text1060002,"Sales Ticket No.",Register2."Status Set By Sales Ticket",Register2.Status);
                if Type = Type::Cancelled then
                  InsertAllowed := true;
              end;
          end;

          if not InsertAllowed then
            Error(
              StrSubstNo(
                Text1060001,
                Register2.FieldCaption("Register No."),
                Register2."Register No.",
                Register2.FieldCaption(Status),
                Register2.Status,
                TableCaption,
                FieldCaption(Type),
                Type));
        end;
        if "Offline receipt no." = '' then
          "Offline receipt no." := "Sales Ticket No.";
        RetailSetup.Get;
        if RetailSetup."Company - Function" = RetailSetup."Company - Function"::Offline then begin
          Offline := true;
          "Offline - Gift voucher ref."   := "Gift voucher ref.";
          "Offline - Credit voucher ref." := "Credit voucher ref.";
        end;
    end;

    var
        AuditRoll: Record "Audit Roll";
        RetailSetup: Record "Retail Setup";
        GLAccount: Record "G/L Account";
        DimMgt: Codeunit DimensionManagement;
        NPRDimMgt: Codeunit NPRDimensionManagement;
        HandleErrorUnderPrintReceipt: Boolean;
        Text1060001: Label '%1 %2 has %3 %4. It is not possible to insert %5 with %6 %7.';
        Text1060002: Label 'Error at insert into the audit roll. \Sales ticket no. %1 <> Sales Ticket No. of set register status %2. \Status = %3.';

    procedure PrintSalesReceipt(ViewDemand: Boolean): Boolean
    var
        StdCodeunitCode: Codeunit "Std. Codeunit Code";
    begin
        //PrintReceipt()

        StdCodeunitCode.OnRunSetShowDemand(ViewDemand);
        if HandleErrorUnderPrintReceipt then
          exit(StdCodeunitCode.Run(Rec))
        else
          StdCodeunitCode.Run(Rec);
    end;

    procedure PrintReceiptA4(ViewDemand: Boolean)
    var
        RetailReportSelectionMgt: Codeunit "Retail Report Selection Mgt.";
        RecRef: RecordRef;
        ReportSelectionRetail: Record "Report Selection Retail";
    begin
        //PrintReceiptA4
        //-NPR5.23 [242202]
        //RetailSetup.GET;
        //+NPR5.23 [242202]

        AuditRoll.Copy(Rec);

        //-NPR5.23 [242202]
        RecRef.GetTable(AuditRoll);
        RetailReportSelectionMgt.SetRegisterNo("Register No.");
        RetailReportSelectionMgt.SetRequestWindow(ViewDemand);
        RetailReportSelectionMgt.RunObjects(RecRef,ReportSelectionRetail."Report Type"::"Large Sales Receipt");

        // IF RetailSetup."Get Customername at Discount" AND Discount AND ( Revisionsrec.Kundenavn = '' ) THEN BEGIN
        //  szKundenavn := '';
        //  InputDialog.SetInput(1,szKundenavn,txtGetCust);
        //   IF InputDialog.RUNMODAL = ACTION::OK THEN BEGIN
        //     InputDialog.InputText(1, szKundenavn);
        //     Revisionsrec.MODIFYALL( Kundenavn, szKundenavn );
        //   END;
        // END;
        //
        // WITH Revisionsrec DO BEGIN
        //  Rapportvalg.SETRANGE("Report Type",Rapportvalg."Report Type"::"A4-Bon");
        //  Rapportvalg.SETFILTER("Report ID",'<>0');
        //  Rapportvalg.SETRANGE( "Register No.", "Register No." );
        //  IF NOT Rapportvalg.FIND('-') THEN
        //    Rapportvalg.SETRANGE( "Register No.", '' );
        //  Rapportvalg.FIND('-');
        //  REPEAT
        //    REPORT.RUN(Rapportvalg."Report ID",visanfordring,FALSE,Revisionsrec);
        //  UNTIL Rapportvalg.NEXT = 0;
        // END;
        //+NPR5.23 [242202]
    end;

    procedure LineIsGiftCert(): Boolean
    var
        Register2: Record Register;
        GiftVoucher2: Record "Gift Voucher";
    begin
        //LineIsGiftCert
        if Type = Type::"G/L" then
          if "Sale Type" = "Sale Type"::Deposit then
            if Register2.Get("Register No.") then
              if "No." = Register2."Gift Voucher Account" then
        //        IF "Rabat kode" <> '' THEN
        //          IF GavekortLok.GET("Rabat kode") THEN
                if "Gift voucher ref." <> '' then
                  if GiftVoucher2.Get("Gift voucher ref.") then
                    exit(true);
        exit(false);
    end;

    procedure LineIsGiftCertDisc(): Boolean
    var
        Register2: Record Register;
    begin
        //LineIsGiftCertDisc
        if Type = Type::"G/L" then
          if "Sale Type" = "Sale Type"::Deposit then
            if Register2.Get("Register No.") then
              if "No." = Register2."Gift Voucher Discount Account" then
                if "Discount Code" <> '' then
                  exit(true);
        exit(false);
    end;

    procedure ValidateShortcutDimCode(FieldNumber: Integer;var ShortcutDimCode: Code[20])
    begin
        RetailSetup.Get;
        if RetailSetup."Use Adv. dimensions" then begin
          if "Line No." <> 0 then
            NPRDimMgt.SaveNPRDim(
              DATABASE::"Audit Roll","Register No.","Sales Ticket No.","Sale Date",
              "Sale Type","Line No.","No.",FieldNumber,ShortcutDimCode)
          else
            NPRDimMgt.SaveTempDim(FieldNumber,ShortcutDimCode);
        end;
    end;

    procedure LookUpShortcutDimCode(FieldNumber: Integer;var ShortcutDimCode: Code[20])
    begin
        //RetailSetup.GET;
        //IF RetailSetup."Brug dimensionsstyring" THEN
          NPRDimMgt.LookupDimValueCode(FieldNumber,ShortcutDimCode);
    end;

    procedure ShowDimensions()
    begin
        DimMgt.ShowDimensionSet("Dimension Set ID",StrSubstNo('%1 %2',TableCaption,"No."));
    end;

    procedure ImmediatePost(AuditRoll: Record "Audit Roll"): Boolean
    var
        PaymentTypePOS: Record "Payment Type POS";
    begin
        //ImmediatePost()
        PaymentTypePOS.Reset;
        PaymentTypePOS.SetCurrentKey("Receipt - Post it Now");
        PaymentTypePOS.SetRange("Receipt - Post it Now",true);
        AuditRoll.SetCurrentKey("Register No.","Sales Ticket No.","Sale Date","Sale Type",Type,"No.");
        AuditRoll.SetRange("Register No.",AuditRoll."Register No.");
        AuditRoll.SetRange("Sales Ticket No.",AuditRoll."Sales Ticket No.");
        AuditRoll.SetRange(Type,AuditRoll.Type::Payment);
        AuditRoll.SetRange("Sale Type",AuditRoll."Sale Type"::Payment);
        if PaymentTypePOS.FindSet then
          repeat
            AuditRoll.SetRange("No.",PaymentTypePOS."No.");
            if AuditRoll.FindFirst then
              exit(true);
          until PaymentTypePOS.Next = 0;
        exit(false);
    end;

    procedure PrintReceiptErrorHandle(HandleError: Boolean)
    begin
        //PrintReceiptErrorHandle
        HandleErrorUnderPrintReceipt := HandleError;
    end;

    procedure LineIsReceivable(): Boolean
    var
        Register2: Record Register;
        CreditVoucher2: Record "Credit Voucher";
    begin
        //LineIsReceivable
        if Type = Type::"G/L" then
          if "Sale Type" = "Sale Type"::Deposit then
            if Register2.Get("Register No.") then
              if "No." = Register2."Credit Voucher Account" then
                if CreditVoucher2.Get("Credit voucher ref.") then
                    exit(true);
        exit(false);
    end;

    procedure GetNoOfSales(): Integer
    var
        AuditRoll2: Record "Audit Roll";
        NoOfSales: Integer;
        LastSalesTicketNo: Code[20];
    begin
        //-NPR4.10
        AuditRoll2.CopyFilters(Rec);

        //-NPR4.11
        //AuditRoll2.SETRANGE("Sale Type", AuditRoll2."Sale Type"::Salg);
        //+NPR4.11
        if AuditRoll2.FindSet then
          repeat
            if (AuditRoll2."Sales Ticket No." <> LastSalesTicketNo) then
              NoOfSales += 1;
            LastSalesTicketNo := AuditRoll2."Sales Ticket No.";
          until AuditRoll2.Next = 0;

        exit(NoOfSales);
        //+NPR4.10
    end;

    procedure TransferFromSaleLinePOS(var SaleLinePOS: Record "Sale Line POS";Time2: Time;Code2: Code[20];AuditDocType: Integer;AuditAdvanceNo: Code[20])
    begin
        //TransferFromSaleLinePOS()
        "No." := SaleLinePOS."No.";
        "Sale Date" := SaleLinePOS.Date;
        Type := Type::"Debit Sale";
        Lokationskode := SaleLinePOS."Location Code";
        "Bin Code" := SaleLinePOS."Bin Code";
        "Posting Group" := SaleLinePOS."Posting Group";
        "Qty. Discount Code" := SaleLinePOS."Qty. Discount Code";
        Description := SaleLinePOS.Description;
        "Unit of Measure Code" := SaleLinePOS."Unit of Measure Code";
        Quantity := SaleLinePOS.Quantity;
        "Invoice (Qty)" := SaleLinePOS."Invoice (Qty)";
        "To Ship (Qty)" := SaleLinePOS."To Ship (Qty)";
        "Unit Price" := SaleLinePOS."Unit Price";
        //-NPR5.45 [324395]
        //"Unit Cost (LCY)" := SaleLinePOS."Unit Price (LCY)";
        "Unit Cost (LCY)" := SaleLinePOS."Unit Cost (LCY)";
        //+NPR5.45 [324395]
        "VAT %" := SaleLinePOS."VAT %";
        "Qty. Discount %" := SaleLinePOS."Qty. Discount %";
        "Line Discount %" := SaleLinePOS."Discount %";
        "Line Discount Amount" := SaleLinePOS."Discount Amount";
        Amount := SaleLinePOS.Amount;
        "Amount Including VAT" := SaleLinePOS."Amount Including VAT";
        "Shortcut Dimension 1 Code" := SaleLinePOS."Shortcut Dimension 1 Code";
        "Shortcut Dimension 2 Code" := SaleLinePOS."Shortcut Dimension 2 Code";
        //-NPR4.21
        "Dimension Set ID":=SaleLinePOS."Dimension Set ID";
        //+NPR4.21

        "Price Group Code" := SaleLinePOS."Customer Price Group";
        "Serial No." := SaleLinePOS."Serial No.";
        "Customer/Item Discount %" := SaleLinePOS."Customer/Item Discount %";
        "Invoice to Customer No." := SaleLinePOS."Invoice to Customer No.";
        "Invoice Discount Amount" := SaleLinePOS."Invoice Discount Amount";
        "Gen. Bus. Posting Group" := SaleLinePOS."Gen. Bus. Posting Group";
        "Gen. Prod. Posting Group" := SaleLinePOS."Gen. Prod. Posting Group";
        "VAT Bus. Posting Group" := SaleLinePOS."VAT Bus. Posting Group";
        "VAT Prod. Posting Group" := SaleLinePOS."VAT Prod. Posting Group";
        "Currency Code" := SaleLinePOS."Currency Code";
        Cost := SaleLinePOS.Cost;
        "Unit Cost" := SaleLinePOS."Unit Cost";
        "Variant Code" := SaleLinePOS."Variant Code";
        "Salesperson Code" := "Salesperson Code";
        "Discount Type" := SaleLinePOS."Discount Type";
        "Discount Code" := SaleLinePOS."Discount Code";
        //-NPR5.39 [305139]
        "Discount Authorised by" := SaleLinePOS."Discount Authorised by";
        //+NPR5.39 [305139]
        //-NPR5.43 [321012]
        //Color := SaleLinePOS.Color;
        //Size := SaleLinePOS.Size;
        //+NPR5.43 [321012]
        "Customer No." := "Customer No.";
        "Customer Type" := "Customer Type";
        "Item Group" := SaleLinePOS."Item Group";
        "Starting Time" := Time2;
        "Closing Time" := Time;
        "Document No." := Code2;
        "Document Type" := AuditDocType;
        "Allocated No." := AuditAdvanceNo;
        "Credit voucher ref." := SaleLinePOS."Credit voucher ref.";
        "Gift voucher ref." := SaleLinePOS."Gift Voucher Ref.";
        "Variant Code" := SaleLinePOS."Variant Code";
        "Drawer Opened" := SaleLinePOS."Drawer Opened";

        "Order No. from Web" := SaleLinePOS."Order No. from Web";
        "Order Line No. from Web" := SaleLinePOS."Order Line No. from Web";

        if SaleLinePOS."Return Sale Sales Ticket No." <> '' then
          "Reverseing Sales Ticket No." := SaleLinePOS."Return Sale Sales Ticket No.";

        //-NPR5.43 [320335]
        "Serial No. not Created" := SaleLinePOS."Serial No. not Created";
        //+NPR5.43
    end;

    procedure IncrementPrintedCount()
    begin
        //-NPR5.31 [269028]
        if FindSet(true,false) then
          repeat
            "No. Printed" += 1;
            Modify;
          until Next = 0;
        //+NPR5.31 [269028]
    end;

    procedure SetDimensions()
    begin
        //-NPR5.42 [314987]
        "Dimension Set ID" :=
          DimMgt.EditDimensionSet("Dimension Set ID",StrSubstNo('%1 %2 %3',"Register No.","Sales Ticket No.","Line No."));

        DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID","Shortcut Dimension 1 Code","Shortcut Dimension 2 Code");
          Modify;
        if (xRec."Shortcut Dimension 1 Code" <> "Shortcut Dimension 1 Code") then
          Validate("Shortcut Dimension 1 Code");

        if (xRec."Shortcut Dimension 2 Code" <> "Shortcut Dimension 2 Code") then
            Validate("Shortcut Dimension 2 Code");
        //-NPR5.42 [314987]
    end;
}

