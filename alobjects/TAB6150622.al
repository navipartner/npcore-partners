table 6150622 "POS Sales Line"
{
    // NPR5.29/AP/20170126 CASE 262628 Recreated ENU-captions
    // NPR5.30/AP/20170209 CASE 261728 Renamed field "Store Code" -> "POS Store Code"
    // NPR5.32/AP/20170220 CASE 262628 Renamed field "Receipt No." -> "Document No."
    // NPR5.32.10/BR/20170609 CASE 279551 Added fields for Item Ledger Entry Posting
    // NPR5.36/BR/20170609 CASE 277101 Added fields for Item Ledger Entry Posting
    // NPR5.36/AP/20170717 CASE 262628 Added "POS Ledg. Register No."
    // NPR5.36/BR/20170810 CASE 277096 Filled LookupPageID and DrillDownPageID
    // NPR5.37/BR/20171016 CASE 293227 Added Functions CalculateDiscountPerc
    // NPR5.38/BR/20171108 CASE 294717 Added function ShowDimensions
    // NPR5.38/BR  /20180122 CASE 302693 Added Type Option "Payout"
    // NPR5.39/BR  /20180208 CASE 304739 Added Type Option "Rounding", adding to tablerelation of "No." field
    // NPR5.39/MHA /20180221 CASE 305139 Added field 405 "Discount Authorised by"
    // NPR5.42/TSA /20180511 CASE 314834 Dimensions are editable when entry is unposted
    // NPR5.48/TJ  /20181115 CASE 330832 Increased Length of field Item Category Code from 10 to 20
    // NPR5.48/JDH /20181203 CASE 335967 Field Line Amount added
    // NPR5.50/MHA /20190422 CASE 337539 Added field 170 "Retail ID"
    // NPR5.50/MMV /20190328 CASE 300557 Added field 143,144.
    //                                   Renamed blank Type option to comment.
    // NPR5.51/MHA /20190718 CASE 362329 Added field 500 "Exclude from Posting"
    // NPR5.52/TSA /20190925 CASE 369231 Added field "Retail Serial No." aka "Serial No. not Created"
    // NPR5.53/SARA/20191024 CASE 373672 Added Field 600..620
    // NPR5.53/ALPO/20200108 CASE 380918 Post Seating Code and Number of Guests to POS Entries (for further sales analysis breakedown)
    // NPR5.54/RA  /20200214 CASE 388514 Table relation to variant table was wrong, field 5402
    // NPR5.54/ALPO/20200324 CASE 397063 Global dimensions were not updated on assigned dimension change through ShowDimensions() function ("Dimensions" button)

    Caption = 'POS Sales Line';
    DataClassification = CustomerContent;
    DrillDownPageID = "POS Sales Line List";
    LookupPageID = "POS Sales Line List";

    fields
    {
        field(1; "POS Entry No."; Integer)
        {
            Caption = 'POS Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "POS Entry";
        }
        field(3; "POS Store Code"; Code[10])
        {
            Caption = 'POS Store Code';
            DataClassification = CustomerContent;
            TableRelation = "POS Store";
        }
        field(4; "POS Unit No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "POS Unit";
        }
        field(5; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(6; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(7; "POS Period Register No."; Integer)
        {
            Caption = 'POS Period Register No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.36';
            TableRelation = "POS Period Register";
        }
        field(10; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Comment,G/L Account,Item,Customer,Voucher,Payout,Rounding';
            OptionMembers = Comment,"G/L Account",Item,Customer,Voucher,Payout,Rounding;
        }
        field(11; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            TableRelation = IF (Type = CONST(Comment)) "Standard Text"
            ELSE
            IF (Type = CONST("G/L Account")) "G/L Account"
            ELSE
            IF (Type = CONST(Customer)) Customer
            ELSE
            IF (Type = CONST(Voucher)) "G/L Account"
            ELSE
            IF (Type = CONST(Payout)) "G/L Account"
            ELSE
            IF (Type = CONST(Item)) Item
            ELSE
            IF (Type = CONST(Rounding)) "G/L Account";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(12; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location;
        }
        field(13; "Posting Group"; Code[10])
        {
            Caption = 'Posting Group';
            DataClassification = CustomerContent;
            TableRelation = IF (Type = CONST(Item)) "Inventory Posting Group"
            ELSE
            IF (Type = CONST(Customer)) "Customer Posting Group";
        }
        field(14; Description; Text[80])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(15; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
        }
        field(20; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer;
        }
        field(22; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            DataClassification = CustomerContent;
        }
        field(23; "Unit Cost (LCY)"; Decimal)
        {
            Caption = 'Unit Cost (LCY)';
            DataClassification = CustomerContent;
        }
        field(25; "VAT %"; Decimal)
        {
            Caption = 'VAT %';
            DataClassification = CustomerContent;
        }
        field(26; "Line Discount %"; Decimal)
        {
            Caption = 'Line Discount %';
            DataClassification = CustomerContent;
        }
        field(27; "Line Discount Amount Excl. VAT"; Decimal)
        {
            Caption = 'Line Discount Amount Excl. VAT';
            DataClassification = CustomerContent;
        }
        field(28; "Line Discount Amount Incl. VAT"; Decimal)
        {
            Caption = 'Line Discount Amount';
            DataClassification = CustomerContent;
        }
        field(29; "Amount Excl. VAT"; Decimal)
        {
            Caption = 'Amount Excl. VAT';
            DataClassification = CustomerContent;
        }
        field(30; "Amount Incl. VAT"; Decimal)
        {
            Caption = 'Amount Incl. VAT';
            DataClassification = CustomerContent;
        }
        field(31; "Line Dsc. Amt. Excl. VAT (LCY)"; Decimal)
        {
            Caption = 'Line Dsc. Amt. Excl. VAT (LCY)';
            DataClassification = CustomerContent;
        }
        field(32; "Line Dsc. Amt. Incl. VAT (LCY)"; Decimal)
        {
            Caption = 'Line Dsc. Amt. Incl. VAT (LCY)';
            DataClassification = CustomerContent;
        }
        field(35; "Amount Excl. VAT (LCY)"; Decimal)
        {
            Caption = 'Amount Excl. VAT (LCY)';
            DataClassification = CustomerContent;
            Description = 'NPR5.36';
        }
        field(36; "Amount Incl. VAT (LCY)"; Decimal)
        {
            Caption = 'Amount Incl. VAT (LCY)';
            DataClassification = CustomerContent;
            Description = 'NPR5.36';
        }
        field(38; "Appl.-to Item Entry"; Integer)
        {
            Caption = 'Appl.-to Item Entry';
            DataClassification = CustomerContent;
        }
        field(39; "Item Entry No."; Integer)
        {
            Caption = 'Item Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "Item Ledger Entry";
        }
        field(40; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(41; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(43; "Salesperson Code"; Code[10])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser";
        }
        field(50; "Withhold Item"; Boolean)
        {
            Caption = 'Withhold Item';
            DataClassification = CustomerContent;
            Description = 'NPR5.36';
        }
        field(51; "Move to Location"; Code[10])
        {
            Caption = 'Move to Location';
            DataClassification = CustomerContent;
            Description = 'NPR5.36';
            TableRelation = Location;
        }
        field(70; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.36';
            TableRelation = Currency;
        }
        field(74; "Gen. Bus. Posting Group"; Code[10])
        {
            Caption = 'Gen. Bus. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Business Posting Group";
        }
        field(75; "Gen. Prod. Posting Group"; Code[10])
        {
            Caption = 'Gen. Prod. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Product Posting Group";
        }
        field(77; "VAT Calculation Type"; Option)
        {
            Caption = 'VAT Calculation Type';
            DataClassification = CustomerContent;
            Description = 'NPR5.36';
            Editable = false;
            OptionCaption = 'Normal VAT,Reverse Charge VAT,Full VAT,Sales Tax';
            OptionMembers = "Normal VAT","Reverse Charge VAT","Full VAT","Sales Tax";
        }
        field(84; "Gen. Posting Type"; Option)
        {
            Caption = 'Gen. Posting Type';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Purchase,Sale';
            OptionMembers = " ",Purchase,Sale;
        }
        field(85; "Tax Area Code"; Code[20])
        {
            Caption = 'Tax Area Code';
            DataClassification = CustomerContent;
            TableRelation = "Tax Area";
        }
        field(86; "Tax Liable"; Boolean)
        {
            Caption = 'Tax Liable';
            DataClassification = CustomerContent;
        }
        field(87; "Tax Group Code"; Code[10])
        {
            Caption = 'Tax Group Code';
            DataClassification = CustomerContent;
            TableRelation = "Tax Group";
        }
        field(88; "Use Tax"; Boolean)
        {
            Caption = 'Use Tax';
            DataClassification = CustomerContent;
        }
        field(89; "VAT Bus. Posting Group"; Code[10])
        {
            Caption = 'VAT Bus. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Business Posting Group";
        }
        field(90; "VAT Prod. Posting Group"; Code[10])
        {
            Caption = 'VAT Prod. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Product Posting Group";
        }
        field(99; "VAT Base Amount"; Decimal)
        {
            Caption = 'VAT Base Amount';
            DataClassification = CustomerContent;
        }
        field(100; "Unit Cost"; Decimal)
        {
            Caption = 'Unit Cost';
            DataClassification = CustomerContent;
        }
        field(103; "Line Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Line Amount';
            DataClassification = CustomerContent;
        }
        field(104; "VAT Difference"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'VAT Difference';
            DataClassification = CustomerContent;
            Description = 'NPR5.36';
            Editable = false;
        }
        field(106; "VAT Identifier"; Code[10])
        {
            Caption = 'VAT Identifier';
            DataClassification = CustomerContent;
            Description = 'NPR5.36';
            Editable = false;
        }
        field(140; "Sales Document Type"; Integer)
        {
            Caption = 'Sales Document Type';
            DataClassification = CustomerContent;
            Description = 'NPR5.36';
        }
        field(141; "Sales Document No."; Code[20])
        {
            Caption = 'Sales Document No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.36';
        }
        field(142; "Sales Document Line No."; Integer)
        {
            Caption = 'Sales Document Line No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.36';
        }
        field(143; "Applies-to Doc. Type"; Option)
        {
            Caption = 'Applies-to Doc. Type';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Payment,Invoice,Credit Memo,Finance Charge Memo,Reminder,Refund';
            OptionMembers = " ",Payment,Invoice,"Credit Memo","Finance Charge Memo",Reminder,Refund;
        }
        field(144; "Applies-to Doc. No."; Code[20])
        {
            Caption = 'Applies-to Doc. No.';
            DataClassification = CustomerContent;
        }
        field(160; "Orig. POS Sale ID"; Integer)
        {
            Caption = 'Orig. POS Sale ID';
            DataClassification = CustomerContent;
            Description = 'NPR5.32';
        }
        field(161; "Orig. POS Line No."; Integer)
        {
            Caption = 'Orig. POS Line No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.32';
        }
        field(170; "Retail ID"; Guid)
        {
            Caption = 'Retail ID';
            DataClassification = CustomerContent;
            Description = 'NPR5.50';
        }
        field(200; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.32.10';
            TableRelation = Bin.Code WHERE("Location Code" = FIELD("Location Code"));

            trigger OnLookup()
            var
                WMSManagement: Codeunit "WMS Management";
                BinCode: Code[20];
            begin
            end;

            trigger OnValidate()
            var
                WMSManagement: Codeunit "WMS Management";
            begin
            end;
        }
        field(201; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.32.10';
            Editable = false;
            InitValue = 1;
        }
        field(202; "Cross-Reference No."; Code[20])
        {
            AccessByPermission = TableData "Item Cross Reference" = R;
            Caption = 'Cross-Reference No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.32.10';

            trigger OnValidate()
            var
                ReturnedCrossRef: Record "Item Cross Reference";
            begin
            end;
        }
        field(203; "Originally Ordered No."; Code[20])
        {
            AccessByPermission = TableData "Item Substitution" = R;
            Caption = 'Originally Ordered No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.32.10';
            TableRelation = IF (Type = CONST(Item)) Item;
        }
        field(204; "Originally Ordered Var. Code"; Code[10])
        {
            AccessByPermission = TableData "Item Substitution" = R;
            Caption = 'Originally Ordered Var. Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.32.10';
            TableRelation = IF (Type = CONST(Item)) "Item Variant".Code WHERE("Item No." = FIELD("Originally Ordered No."));
        }
        field(205; "Out-of-Stock Substitution"; Boolean)
        {
            Caption = 'Out-of-Stock Substitution';
            DataClassification = CustomerContent;
            Description = 'NPR5.32.10';
            Editable = false;
        }
        field(206; "Purchasing Code"; Code[10])
        {
            AccessByPermission = TableData "Drop Shpt. Post. Buffer" = R;
            Caption = 'Purchasing Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.32.10';
            TableRelation = Purchasing;
        }
        field(207; "Product Group Code"; Code[10])
        {
            Caption = 'Product Group Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.32.10';
            TableRelation = "Product Group".Code WHERE("Item Category Code" = FIELD("Item Category Code"));
        }
        field(208; "Planned Delivery Date"; Date)
        {
            AccessByPermission = TableData "Order Promising Line" = R;
            Caption = 'Planned Delivery Date';
            DataClassification = CustomerContent;
            Description = 'NPR5.32.10';
        }
        field(210; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.36';
            TableRelation = "Reason Code";
        }
        field(400; "Discount Type"; Option)
        {
            Caption = 'Discount Type';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Campaign,Mix,Quantity,Manual,BOM List,Photo work,Rounding,Combination,Customer';
            OptionMembers = " ",Campaign,Mix,Quantity,Manual,"BOM List","Photo work",Rounding,Combination,Customer;
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
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                //-NPR5.38 [294747]
                ShowDimensions;
                //+NPR5.38 [294747]
            end;
        }
        field(500; "Exclude from Posting"; Boolean)
        {
            Caption = 'Exclude from Posting';
            DataClassification = CustomerContent;
            Description = 'NPR5.51';
        }
        field(600; "Entry Date"; Date)
        {
            CalcFormula = Lookup ("POS Entry"."Entry Date" WHERE("Entry No." = FIELD("POS Entry No.")));
            Caption = 'Entry Date';
            Description = 'NPR5.53';
            Editable = false;
            FieldClass = FlowField;
        }
        field(610; "Starting Time"; Time)
        {
            CalcFormula = Lookup ("POS Entry"."Starting Time" WHERE("Entry No." = FIELD("POS Entry No.")));
            Caption = 'Starting Time';
            Description = 'NPR5.53';
            Editable = false;
            FieldClass = FlowField;
        }
        field(620; "Ending Time"; Time)
        {
            CalcFormula = Lookup ("POS Entry"."Ending Time" WHERE("Entry No." = FIELD("POS Entry No.")));
            Caption = 'Ending Time';
            Description = 'NPR5.53';
            Editable = false;
            FieldClass = FlowField;
        }
        field(700; "NPRE Seating Code"; Code[10])
        {
            Caption = 'Seating Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.53';
            TableRelation = "NPRE Seating";
        }
        field(5402; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
            TableRelation = IF (Type = CONST(Item)) "Item Variant".Code WHERE("Item No." = FIELD("No."));
        }
        field(5407; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = CustomerContent;
            TableRelation = IF (Type = CONST(Item)) "Item Unit of Measure".Code WHERE("Item No." = FIELD("No."))
            ELSE
            "Unit of Measure";
        }
        field(5415; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DataClassification = CustomerContent;
        }
        field(5709; "Item Category Code"; Code[20])
        {
            Caption = 'Item Category Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Category";
        }
        field(5710; Nonstock; Boolean)
        {
            Caption = 'Nonstock';
            DataClassification = CustomerContent;
        }
        field(5909; "BOM Item No."; Code[20])
        {
            Caption = 'BOM Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
        }
        field(6015; "Retail Serial No."; Code[30])
        {
            Caption = 'Retail Serial No.';
            DataClassification = CustomerContent;
        }
        field(6500; "Serial No."; Code[20])
        {
            Caption = 'Serial No.';
            DataClassification = CustomerContent;
        }
        field(6501; "Lot No."; Code[20])
        {
            Caption = 'Lot No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.32.10';
        }
        field(6608; "Return Reason Code"; Code[10])
        {
            Caption = 'Return Reason Code';
            DataClassification = CustomerContent;
            TableRelation = "Return Reason";
        }
    }

    keys
    {
        key(Key1; "POS Entry No.", "Line No.")
        {
        }
        key(Key2; "Document No.", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    procedure ShowDimensions()
    var
        DimMgt: Codeunit DimensionManagement;
        POSEntry: Record "POS Entry";
    begin
        //-NPR5.42 [314834]

        //-NPR5.38 [294717]
        // DimMgt.ShowDimensionSet("Dimension Set ID",STRSUBSTNO('%1 %2 - %3',TABLECAPTION,"POS Entry No.","Line No."));
        //+NPR5.38 [294717]

        POSEntry.Get("POS Entry No.");
        if ((POSEntry."Post Entry Status" = POSEntry."Post Entry Status"::Posted) and (POSEntry."Post Item Entry Status" = POSEntry."Post Item Entry Status"::Posted)) then begin
            DimMgt.ShowDimensionSet("Dimension Set ID", StrSubstNo('%1 %2 %3', TableCaption, "POS Entry No.", "Line No."));
        end else begin
            //"Dimension Set ID" := DimMgt.EditDimensionSet ("Dimension Set ID",STRSUBSTNO('%1 %2 %3',TABLECAPTION,"POS Entry No.", "Line No."));  //NPR5.54 [397063]-revoked
            //-NPR5.54 [397063]
            "Dimension Set ID" :=
              DimMgt.EditDimensionSet(
                "Dimension Set ID", StrSubstNo('%1 %2 %3', TableCaption, "POS Entry No.", "Line No."), "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
            //+NPR5.54 [397063]
            Modify();
        end;
        //+NPR5.42 [314834]
    end;

    procedure UpdateLCYAmounts()
    var
        POSEntry: Record "POS Entry";
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get;
        POSEntry.Get("POS Entry No.");
        if POSEntry."Currency Factor" > 0 then
            POSEntry."Currency Factor" := 1;
        "Line Dsc. Amt. Excl. VAT (LCY)" := Round("Line Discount Amount Excl. VAT" / POSEntry."Currency Factor", GeneralLedgerSetup."Amount Rounding Precision");
        "Line Dsc. Amt. Incl. VAT (LCY)" := Round("Line Discount Amount Incl. VAT" / POSEntry."Currency Factor", GeneralLedgerSetup."Amount Rounding Precision");
        "Amount Excl. VAT (LCY)" := Round("Amount Excl. VAT" / POSEntry."Currency Factor", GeneralLedgerSetup."Amount Rounding Precision");
        "Amount Incl. VAT (LCY)" := Round("Amount Incl. VAT" / POSEntry."Currency Factor", GeneralLedgerSetup."Amount Rounding Precision");
    end;

    procedure CalculateDiscountPerc()
    begin
        //-NPR5.37 [293227]
        if "Amount Excl. VAT" <> 0 then
            "Line Discount %" := ("Line Discount Amount Excl. VAT" / "Amount Excl. VAT") * 100;
        //+NPR5.37 [293227]
    end;
}

