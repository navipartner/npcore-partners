﻿table 6150622 "NPR POS Entry Sales Line"
{
    Caption = 'POS Entry Sales Line';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR POS Entry Sales Line List";
    LookupPageID = "NPR POS Entry Sales Line List";

    fields
    {
        field(1; "POS Entry No."; Integer)
        {
            Caption = 'POS Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Entry";
        }
        field(3; "POS Store Code"; Code[10])
        {
            Caption = 'POS Store Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Store";
        }
        field(4; "POS Unit No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit";
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
            TableRelation = "NPR POS Period Register";
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
        }
        field(12; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location;
        }
        field(13; "Posting Group"; Code[20])
        {
            Caption = 'Posting Group';
            DataClassification = CustomerContent;
            TableRelation = IF (Type = CONST(Item)) "Inventory Posting Group"
            ELSE
            IF (Type = CONST(Customer)) "Customer Posting Group";
        }
        field(14; Description; Text[100])
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
        field(43; "Salesperson Code"; Code[20])
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
        field(74; "Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Business Posting Group";
        }
        field(75; "Gen. Prod. Posting Group"; Code[20])
        {
            Caption = 'Gen. Prod. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Product Posting Group";
        }
        field(77; "VAT Calculation Type"; Enum "Tax Calculation Type")
        {
            Caption = 'VAT Calculation Type';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(84; "Gen. Posting Type"; Enum "General Posting Type")
        {
            Caption = 'Gen. Posting Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Gen. Posting Type" = "Gen. Posting Type"::Settlement then
                    FieldError("Gen. Posting Type");
            end;
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
        field(87; "Tax Group Code"; Code[20])
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
        field(89; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Business Posting Group";
        }
        field(90; "VAT Prod. Posting Group"; Code[20])
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
        field(106; "VAT Identifier"; Code[20])
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
        field(143; "Applies-to Doc. Type"; Enum "Gen. Journal Document Type")
        {
            Caption = 'Applies-to Doc. Type';
            DataClassification = CustomerContent;
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
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Use systemID instead';
        }
        field(161; "Orig. POS Line No."; Integer)
        {
            Caption = 'Orig. POS Line No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.32';
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Replaced by SystemID';
        }
        field(170; "Retail ID"; Guid)
        {
            Caption = 'Retail ID';
            DataClassification = CustomerContent;
            Description = 'NPR5.50';
            ObsoleteState = Pending;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Replaced by SystemID';
        }
        field(180; Indentation; Integer)
        {
            Caption = 'Indentation';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(200; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            DataClassification = CustomerContent;
            TableRelation = Bin.Code WHERE("Location Code" = FIELD("Location Code"),
                                            "Item Filter" = FIELD("No."),
                                            "Variant Filter" = FIELD("Variant Code"));
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
        field(202; "Cross-Reference No."; Code[50])
        {
            AccessByPermission = TableData "Item Reference" = R;
            Caption = 'Reference No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.32.10';
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
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used';
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
        field(405; "Discount Authorised by"; Code[50])
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
                ShowDimensions();
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
            CalcFormula = Lookup("NPR POS Entry"."Entry Date" WHERE("Entry No." = FIELD("POS Entry No.")));
            Caption = 'Entry Date';
            Description = 'NPR5.53';
            Editable = false;
            FieldClass = FlowField;
        }
        field(610; "Starting Time"; Time)
        {
            CalcFormula = Lookup("NPR POS Entry"."Starting Time" WHERE("Entry No." = FIELD("POS Entry No.")));
            Caption = 'Starting Time';
            Description = 'NPR5.53';
            Editable = false;
            FieldClass = FlowField;
        }
        field(620; "Ending Time"; Time)
        {
            CalcFormula = Lookup("NPR POS Entry"."Ending Time" WHERE("Entry No." = FIELD("POS Entry No.")));
            Caption = 'Ending Time';
            Description = 'NPR5.53';
            Editable = false;
            FieldClass = FlowField;
        }
        field(630; "Voucher Category"; Enum "NPR Voucher Category")
        {
            Caption = 'Voucher Category';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(700; "NPRE Seating Code"; Code[20])
        {
            Caption = 'Seating Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.53';
            TableRelation = "NPR NPRE Seating";
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
        field(5700; "Responsibility Center"; Code[10])
        {
            Caption = 'Responsibility Center';
            DataClassification = CustomerContent;
            TableRelation = "Responsibility Center";
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
        field(6015; "Retail Serial No."; Code[50])
        {
            Caption = 'Retail Serial No.';
            DataClassification = CustomerContent;
        }
        field(6039; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
            DataClassification = CustomerContent;
        }
        field(6500; "Serial No."; Code[50])
        {
            Caption = 'Serial No.';
            DataClassification = CustomerContent;
        }
        field(6501; "Lot No."; Code[50])
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
        field(6610; "POS Sale Line Created At"; DateTime)
        {
            Caption = 'POS Sale Line Created At';
            DataClassification = CustomerContent;
        }
        field(7000; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            DataClassification = CustomerContent;
            TableRelation = Vendor;
        }
        field(7001; "Copy Description"; Boolean)
        {
            Caption = 'Copy Description from POS Entry to Cust. Ledger Entry';
            DataClassification = CustomerContent;
        }
        field(10014; "Orig.POS Entry S.Line SystemId"; Guid)
        {
            Caption = 'Original POS Entry Sale Line SystemId';
            DataClassification = CustomerContent;
        }

        field(9000; "Total Discount Code"; Code[20])
        {
            Caption = 'Total Discount Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Total Discount Header";
        }
        field(9010; "Total Discount Step"; Decimal)
        {
            Caption = 'Total Discount Step';
            DataClassification = CustomerContent;

        }
        field(9020; "Line Total Disc Amt Excl Tax"; Decimal)
        {
            Caption = 'Line Total Discount Amount Excluding Tax';
            DataClassification = CustomerContent;
        }
        field(9030; "Line Total Disc Amt Incl Tax"; Decimal)
        {
            Caption = 'Line Total Discount Amount Including Tax';
            DataClassification = CustomerContent;
        }

        field(9040; "Benefit Item"; Boolean)
        {
            Caption = 'Benefit Item';
            DataClassification = CustomerContent;
        }

        field(9050; "Benefit List Code"; Code[20])
        {
            Caption = 'Benefit List Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Item Benefit List Header".Code;

        }
        field(9060; "Return Sale Sales Ticket No."; Code[20])
        {
            Caption = 'Return Sale Sales Ticket No.';
            DataClassification = CustomerContent;
        }
        field(9070; "Shipment Fee"; Boolean)
        {
            Caption = 'Shipment Fee';
            DataClassification = CustomerContent;
        }
        field(9080; "Deferral Code"; Code[10])
        {
            Caption = 'Deferral Code';
            TableRelation = "Deferral Template"."Deferral Code";
            DataClassification = CustomerContent;
        }
        field(9090; "Deferral Line No."; Integer)
        {
            Caption = 'Deferral Line No.';
            DataClassification = CustomerContent;
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
        key(Key3; Type, "No.", "Document No.")
        {
        }
        key(Key4; "Serial No.")
        {
            ObsoleteState = Removed;
            ObsoleteTag = '2023-08-28';
            ObsoleteReason = 'Replaced by Key7: "Item Entry No.", "Serial No."';
            Enabled = false;
#if not (BC17 or BC18)
            IncludedFields = "Item Entry No.";
#endif
        }
        key(Key5; "Item Entry No.")
        {
            ObsoleteState = Removed;
            ObsoleteTag = '2023-08-28';
            ObsoleteReason = 'Replaced by Key7: "Item Entry No.", "Serial No."';
            Enabled = false;
#if not (BC17 or BC18)
            IncludedFields = "Serial No.";
#endif
        }
        key(Key6; Type, "Salesperson Code", "Discount Type")
        {
        }
        key(Key7; "Item Entry No.", "Serial No.")
        {
        }
    }

    fieldgroups
    {
    }

    internal procedure ShowDimensions()
    var
        DimMgt: Codeunit DimensionManagement;
        POSEntry: Record "NPR POS Entry";
        DimSetIdLbl: Label '%1 %2 %3', Locked = true;
    begin
        POSEntry.Get("POS Entry No.");
        if ((POSEntry."Post Entry Status" = POSEntry."Post Entry Status"::Posted) and (POSEntry."Post Item Entry Status" = POSEntry."Post Item Entry Status"::Posted)) then begin
            DimMgt.ShowDimensionSet("Dimension Set ID", StrSubstNo(DimSetIdLbl, TableCaption, "POS Entry No.", "Line No."));
        end else begin
            "Dimension Set ID" :=
              DimMgt.EditDimensionSet(
                "Dimension Set ID", StrSubstNo(DimSetIdLbl, TableCaption, "POS Entry No.", "Line No."), "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
            Modify();
        end;
    end;

    procedure IsInventoriableItem(): Boolean
    var
        Item: Record Item;
    begin
        if (Type <> Type::Item) or ("No." = '') then
            exit(false);
        GetItem(Item);
        exit(Item.IsInventoriableType());
    end;

    procedure GetItem(var Item: Record Item)
    begin
        TestField("No.");
        Item.Get("No.");
    end;

    internal procedure ShowDeferrals()
    var
        DeferralUtilities: Codeunit "Deferral Utilities";
    begin
        DeferralUtilities.OpenLineScheduleView("Deferral Code", Enum::"Deferral Document Type"::"G/L".AsInteger(), '', '', Database::"NPR POS Entry Sales Line", Format("POS Entry No."), "Line No.");
    end;
}
