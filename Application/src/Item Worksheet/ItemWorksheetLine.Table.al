table 6060042 "NPR Item Worksheet Line"
{
    Caption = 'Item Worksheet Line';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Item Worksheet Page";
    LookupPageID = "NPR Item Worksheet Page";

    fields
    {
        field(1; "Worksheet Template Name"; Code[10])
        {
            Caption = 'Worksheet Template Name';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR Item Worksh. Template";
        }
        field(2; "Worksheet Name"; Code[10])
        {
            Caption = 'Worksheet Name';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR Item Worksheet".Name WHERE("Item Template Name" = FIELD("Worksheet Template Name"));
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(4; "Action"; Option)
        {
            Caption = 'Action';
            DataClassification = CustomerContent;
            OptionCaption = 'Skip,Create New,Update Only,Update and Create Variants';
            OptionMembers = Skip,CreateNew,UpdateOnly,UpdateAndCreateVariants;

            trigger OnValidate()
            var
                ItemWorksheetVariantLine: Record "NPR Item Worksh. Variant Line";
            begin
                case Action of
                    Action::UpdateOnly:
                        TestField("Existing Item No.");
                    Action::CreateNew:
                        begin
                            if "Existing Item No." <> '' then begin
                                "Internal Bar Code" := '';
                                "Vendors Bar Code" := '';
                                DeleteRelatedLines;
                            end;
                            if "Item No." = '' then
                                Validate("Item No.", GetNewItemNo);
                            if (CurrFieldNo <> 0) and (xRec.Action = xRec.Action::Skip) and GuiAllowed then begin
                                ItemWorksheetVariantLine.SetRange("Worksheet Template Name", "Worksheet Template Name");
                                ItemWorksheetVariantLine.SetRange("Worksheet Name", "Worksheet Name");
                                ItemWorksheetVariantLine.SetRange("Worksheet Line No.", "Line No.");
                                if not ItemWorksheetVariantLine.IsEmpty() then
                                    if Confirm(SetVariantsToCreateQst) then begin
                                        ItemWorksheetVariantLine.SetUpdateFromWorksheetLine(true);
                                        if ItemWorksheetVariantLine.FindSet() then
                                            repeat
                                                if ItemWorksheetVariantLine.Action <> ItemWorksheetVariantLine.Action::Undefined then begin
                                                    ItemWorksheetVariantLine.Validate(Action, ItemWorksheetVariantLine.Action::CreateNew);
                                                    ItemWorksheetVariantLine.Modify(true);
                                                end;
                                            until ItemWorksheetVariantLine.Next() = 0;
                                        "Status Comment" := CopyStr(ItemWorksheetVariantLine.GetStatusCommentText, 1, MaxStrLen("Status Comment"));
                                    end;
                            end;
                        end;
                end;
                UpdateVarietyHeadingText();
            end;
        }
        field(5; "Existing Item No."; Code[20])
        {
            Caption = 'Existing Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;

            trigger OnValidate()
            var
                AlternativeNo: Record "NPR Alternative No.";
                ItemWorksheetTemplate2: Record "NPR Item Worksh. Template";
            begin
                TestField("Line No.");
                if "Existing Item No." = '' then
                    exit;
                Item.Get("Existing Item No.");
                Description := Item.Description;
                "Base Unit of Measure" := Item."Base Unit of Measure";
                Validate("VAT Prod. Posting Group", Item."VAT Prod. Posting Group");
                "VAT Bus. Posting Gr. (Price)" := Item."VAT Bus. Posting Gr. (Price)";
                "Gen. Prod. Posting Group" := Item."Gen. Prod. Posting Group";
                "Inventory Posting Group" := Item."Inventory Posting Group";
                "Sales Unit of Measure" := Item."Sales Unit of Measure";
                "Purch. Unit of Measure" := Item."Purch. Unit of Measure";
                "Costing Method" := Item."Costing Method";
                if "No. Series" = '' then
                    "No. Series" := Item."No. Series";
                "Item Group" := Item."NPR Item Group";
                "Sales Price" := Item."Unit Price";
                "Direct Unit Cost" := Item."Last Direct Cost";
                "Tax Group Code" := Item."Tax Group Code";
                if "Vendor No." = '' then
                    "Vendor No." := Item."Vendor No.";
                if "Vendor Item No." = '' then
                    "Vendor Item No." := ItemNumberManagement.GetItemItemVendorNo(Item."No.", '', "Vendor No.");

                if ItemWorksheetTemplate2.Get("Worksheet Template Name") then;
                if ("Internal Bar Code" = '') and not ItemWorksheetTemplate2."Do not Apply Internal Barcode" then
                    "Internal Bar Code" := ItemNumberManagement.GetItemBarcode(Item."No.", '', '', "Vendor No.");

                if ItemWorksheetItemMgt.ItemVariantExists("Existing Item No.") then
                    "Use Variant" := true
                else
                    if ItemWorksheetItemMgt.ItemVarietyExists("Existing Item No.") then
                        "Use Variant" := true;

                "Variety Group" := Item."NPR Variety Group";
                "Cross Variety No." := Item."NPR Cross Variety No.";
                "Gross Weight" := Item."Gross Weight";
                "Net Weight" := Item."Net Weight";
                "Item Category Code" := Item."Item Category Code";
                "Profit %" := Item."Profit %";
                "Description 2" := Item."Description 2";
                if Item."NPR Magento Item" then
                    "Magento Item" := "Magento Item"::Yes
                else
                    "Magento Item" := "Magento Item"::No;

                CopyItemAttributes(Item."No.");

                "Variety 1" := Item."NPR Variety 1";
                if VRTTable.Get("Variety 1", Item."NPR Variety 1 Table") then
                    if VRTTable."Is Copy" and (Action = Action::CreateNew) then begin
                        Validate("Variety 1 Table (Base)", VRTTable."Copy from");
                        "Create Copy of Variety 1 Table" := true;
                    end else begin
                        Validate("Variety 1 Table (Base)", Item."NPR Variety 1 Table");
                        "Create Copy of Variety 1 Table" := false;
                    end;

                "Variety 2" := Item."NPR Variety 2";
                if VRTTable.Get("Variety 2", Item."NPR Variety 2 Table") then
                    if VRTTable."Is Copy" and (Action = Action::CreateNew) then begin
                        Validate("Variety 2 Table (Base)", VRTTable."Copy from");
                        "Create Copy of Variety 2 Table" := true;
                    end else begin
                        Validate("Variety 2 Table (Base)", Item."NPR Variety 2 Table");
                        "Create Copy of Variety 2 Table" := false;
                    end;

                "Variety 3" := Item."NPR Variety 3";
                if VRTTable.Get("Variety 3", Item."NPR Variety 3 Table") then
                    if VRTTable."Is Copy" and (Action = Action::CreateNew) then begin
                        Validate("Variety 3 Table (Base)", VRTTable."Copy from");
                        "Create Copy of Variety 3 Table" := true;
                    end else begin
                        Validate("Variety 3 Table (Base)", Item."NPR Variety 3 Table");
                        "Create Copy of Variety 3 Table" := false;
                    end;

                "Variety 4" := Item."NPR Variety 4";
                if VRTTable.Get("Variety 4", Item."NPR Variety 4 Table") then
                    if VRTTable."Is Copy" and (Action = Action::CreateNew) then begin
                        Validate("Variety 4 Table (Base)", VRTTable."Copy from");
                        "Create Copy of Variety 4 Table" := true;
                    end else begin
                        Validate("Variety 4 Table (Base)", Item."NPR Variety 4 Table");
                        "Create Copy of Variety 4 Table" := false;
                    end;

                FillVarietyTableNew();

                if Action = Action::CreateNew then
                    if "Existing Item No." <> '' then
                        if "Item No." = '' then
                            Validate("Item No.", GetNewItemNo);
                UpdateVarietyHeadingText();
                FillMappedFields();
            end;
        }
        field(6; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                if Item.Get("Item No.") then begin
                    Validate("Existing Item No.", "Item No.");
                    "Item No." := '';
                end else
                    "Existing Item No." := '';
                UpdateVarietyLines();
            end;
        }
        field(7; "Vendor Item No."; Text[20])
        {
            Caption = 'Vendor Item No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ItemWorksheetItemMgt.MatchItemNo(Rec);
                if ("Existing Item No." = '') then
                    Validate(Action);
            end;
        }
        field(8; "Internal Bar Code"; Code[20])
        {
            Caption = 'Internal Bar Code';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                AlternativeNo: Record "NPR Alternative No.";
            begin
                ItemWorksheetItemMgt.MatchItemNo(Rec);
            end;
        }
        field(9; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            DataClassification = CustomerContent;
            TableRelation = Vendor;
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(11; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(12; "No. 2"; Code[20])
        {
            Caption = 'No. 2';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(13; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'Inventory,Service,,,,,,,,Undefined';
            OptionMembers = Inventory,Service,,,,,,,,Undefined;
        }
        field(15; "Shelf No."; Code[10])
        {
            Caption = 'Shelf No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(16; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = Currency;
            ValidateTableRelation = false;
        }
        field(17; "Direct Unit Cost"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            Caption = 'Direct Unit Cost';
            CaptionClass = GetCaptionClass(FieldNo("Direct Unit Cost"));
            DataClassification = CustomerContent;
        }
        field(18; "Sales Price"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Price';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(20; "Use Variant"; Boolean)
        {
            Caption = 'Use Variant';
            DataClassification = CustomerContent;
        }
        field(22; "Base Unit of Measure"; Code[10])
        {
            Caption = 'Base Unit of Measure';
            DataClassification = CustomerContent;
            TableRelation = "Unit of Measure";
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                if "Sales Unit of Measure" = '' then
                    "Sales Unit of Measure" := "Base Unit of Measure";

                if "Purch. Unit of Measure" = '' then
                    "Purch. Unit of Measure" := "Base Unit of Measure";
            end;
        }
        field(23; "Inventory Posting Group"; Code[10])
        {
            Caption = 'Inventory Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "Inventory Posting Group";
            ValidateTableRelation = false;
        }
        field(24; "Costing Method"; Enum "Costing Method")
        {
            Caption = 'Costing Method';
            DataClassification = CustomerContent;
        }
        field(25; "Item Disc. Group"; Code[20])
        {
            Caption = 'Item Disc. Group';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            TableRelation = "Item Discount Group";
            ValidateTableRelation = false;
        }
        field(26; "Allow Invoice Disc."; Option)
        {
            Caption = 'Allow Invoice Disc.';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'No,Yes,Undefined';
            OptionMembers = No,Yes,Undefined;
        }
        field(27; "Statistics Group"; Integer)
        {
            Caption = 'Statistics Group';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(28; "Commission Group"; Integer)
        {
            Caption = 'Commission Group';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(29; "Price/Profit Calculation"; Option)
        {
            Caption = 'Price/Profit Calculation';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'Profit=Price-Cost,Price=Cost+Profit,No Relationship,,,,,,,Undefined';
            OptionMembers = "Profit=Price-Cost","Price=Cost+Profit","No Relationship",,,,,,,Undefined;
        }
        field(30; "Profit %"; Decimal)
        {
            Caption = 'Profit %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.25';
        }
        field(33; "Lead Time Calculation"; DateFormula)
        {
            AccessByPermission = TableData "Purch. Rcpt. Header" = R;
            Caption = 'Lead Time Calculation';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(34; "Reorder Point"; Decimal)
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            Caption = 'Reorder Point';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.25';
        }
        field(35; "Vendors Bar Code"; Code[20])
        {
            Caption = 'Vendors Bar Code';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ItemWorksheetItemMgt.MatchItemNo(Rec);
            end;
        }
        field(36; "Maximum Inventory"; Decimal)
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            Caption = 'Maximum Inventory';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.25';
        }
        field(37; "Reorder Quantity"; Decimal)
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            Caption = 'Reorder Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.25';
        }
        field(38; "Unit List Price"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit List Price';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            MinValue = 0;
        }
        field(39; "Duty Due %"; Decimal)
        {
            Caption = 'Duty Due %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.25';
            MaxValue = 100;
            MinValue = 0;
        }
        field(40; "Duty Code"; Code[10])
        {
            Caption = 'Duty Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(41; "Gross Weight"; Decimal)
        {
            Caption = 'Gross Weight';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(42; "Net Weight"; Decimal)
        {
            Caption = 'Net Weight';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(43; "Units per Parcel"; Decimal)
        {
            Caption = 'Units per Parcel';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.25';
            MinValue = 0;
        }
        field(44; "Unit Volume"; Decimal)
        {
            Caption = 'Unit Volume';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.25';
            MinValue = 0;
        }
        field(45; Durability; Code[10])
        {
            Caption = 'Durability';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(46; "Freight Type"; Code[10])
        {
            Caption = 'Freight Type';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(47; "Tariff No."; Code[20])
        {
            Caption = 'Tariff No.';
            DataClassification = CustomerContent;
            TableRelation = "Tariff Number";
            ValidateTableRelation = false;
        }
        field(48; "Duty Unit Conversion"; Decimal)
        {
            Caption = 'Duty Unit Conversion';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.25';
        }
        field(49; "Country/Region Purchased Code"; Code[10])
        {
            Caption = 'Country/Region Purchased Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            TableRelation = "Country/Region";
            ValidateTableRelation = false;
        }
        field(50; "Budget Quantity"; Decimal)
        {
            Caption = 'Budget Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.25';
        }
        field(51; "Budgeted Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Budgeted Amount';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(52; "Budget Profit"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Budget Profit';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(54; Blocked; Option)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'No,Yes,Undefined';
            OptionMembers = No,Yes,Undefined;
        }
        field(87; "Price Includes VAT"; Option)
        {
            Caption = 'Price Includes VAT';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'No,Yes,Undefined';
            OptionMembers = No,Yes,Undefined;
        }
        field(89; "VAT Bus. Posting Group"; Code[10])
        {
            Caption = 'VAT Bus. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Business Posting Group";
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                Validate("VAT Prod. Posting Group");
            end;
        }
        field(90; "VAT Bus. Posting Gr. (Price)"; Code[10])
        {
            Caption = 'VAT Bus. Posting Gr. (Price)';
            DataClassification = CustomerContent;
            TableRelation = "VAT Business Posting Group";
            ValidateTableRelation = false;
        }
        field(91; "Gen. Prod. Posting Group"; Code[10])
        {
            Caption = 'Gen. Prod. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Product Posting Group";
            ValidateTableRelation = false;
        }
        field(95; "Country/Region of Origin Code"; Code[10])
        {
            Caption = 'Country/Region of Origin Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            TableRelation = "Country/Region";
            ValidateTableRelation = false;
        }
        field(96; "Automatic Ext. Texts"; Option)
        {
            Caption = 'Automatic Ext. Texts';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'No,Yes,Undefined';
            OptionMembers = No,Yes,Undefined;
        }
        field(97; "No. Series"; Code[10])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
            ValidateTableRelation = false;
        }
        field(98; "Tax Group Code"; Code[10])
        {
            Caption = 'Tax Group Code';
            DataClassification = CustomerContent;
            TableRelation = "Tax Group";
            ValidateTableRelation = false;
        }
        field(99; "VAT Prod. Posting Group"; Code[10])
        {
            Caption = 'VAT Prod. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Product Posting Group";
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                VATPostingSetup: Record "VAT Posting Setup";
            begin
                if not VATPostingSetup.Get("VAT Bus. Posting Group", "VAT Prod. Posting Group") then
                    VATPostingSetup.Init();
            end;
        }
        field(100; Reserve; Option)
        {
            AccessByPermission = TableData "Purch. Rcpt. Header" = R;
            Caption = 'Reserve';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'Never,Optional,Always,,,,,,,Undefined';
            OptionMembers = Never,Optional,Always,,,,,,,Undefined;
        }
        field(105; "Global Dimension 1 Code"; Code[20])
        {
            Caption = 'Global Dimension 1 Code';
            CaptionClass = '1,1,1';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Global Dimension 1 Code");
            end;
        }
        field(106; "Global Dimension 2 Code"; Code[20])
        {
            Caption = 'Global Dimension 2 Code';
            CaptionClass = '1,1,2';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Global Dimension 2 Code");
            end;
        }
        field(120; "Stockout Warning"; Option)
        {
            Caption = 'Stockout Warning';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'Default,No,Yes,,,,,,,Undefined';
            OptionMembers = Default,No,Yes,,,,,,,Undefined;
        }
        field(121; "Prevent Negative Inventory"; Option)
        {
            Caption = 'Prevent Negative Inventory';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'Default,No,Yes,,,,,,,Undefined';
            OptionMembers = Default,No,Yes,,,,,,,Undefined;
        }
        field(150; Status; Option)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            OptionCaption = 'Unvalidated,Error,Warning,Validated,Processed';
            OptionMembers = Unvalidated,Error,Warning,Validated,Processed;
        }
        field(151; "Status Comment"; Text[250])
        {
            Caption = 'Status Comment';
            DataClassification = CustomerContent;
        }
        field(200; "Variety 1"; Code[10])
        {
            Caption = 'Variety 1';
            DataClassification = CustomerContent;
            Description = 'Variety';
            TableRelation = "NPR Variety";
            ValidateTableRelation = false;
        }
        field(201; "Variety 1 Table (Base)"; Code[40])
        {
            Caption = 'Variety 1 Table';
            DataClassification = CustomerContent;
            Description = 'Variety';
            TableRelation = "NPR Variety Table".Code WHERE(Type = FIELD("Variety 1"));
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                VrtTable: Record "NPR Variety Table";
            begin
                "Variety 1 Table (New)" := GetVariety1Table();
                if not VrtTable.Get("Variety 1", "Variety 1 Table (Base)") then
                    VrtTable.Init();
                "Variety 1 Lock Table" := VrtTable."Lock Table";
                CopyVrtValue("Variety 1", "Variety 1 Table (Base)");
            end;
        }
        field(202; "Create Copy of Variety 1 Table"; Boolean)
        {
            Caption = 'Create Copy of Variety 1 Table';
            DataClassification = CustomerContent;
            Description = 'Variety';

            trigger OnValidate()
            begin
                if not "Create Copy of Variety 1 Table" then
                    if IsLockedVariety(1) then
                        if IsAddedVarietyValue(1) then
                            Error(VarietyAddedErr, "Variety 1", "Variety 1 Table (New)");
            end;
        }
        field(203; "Variety 1 Table (New)"; Code[20])
        {
            Caption = 'Variety 1 Table (New)';
            DataClassification = CustomerContent;
            Description = 'Variety';
        }
        field(204; "Variety 1 Lock Table"; Boolean)
        {
            Caption = 'Variety 1 Lock Table';
            DataClassification = CustomerContent;
            Description = 'Variety';
        }
        field(210; "Variety 2"; Code[10])
        {
            Caption = 'Variety 2';
            DataClassification = CustomerContent;
            Description = 'Variety';
            TableRelation = "NPR Variety";
            ValidateTableRelation = false;
        }
        field(211; "Variety 2 Table (Base)"; Code[40])
        {
            Caption = 'Variety 2 Table';
            DataClassification = CustomerContent;
            Description = 'Variety';
            TableRelation = "NPR Variety Table".Code WHERE(Type = FIELD("Variety 2"));
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                VrtTable: Record "NPR Variety Table";
            begin
                "Variety 2 Table (New)" := GetVariety2Table();
                if not VrtTable.Get("Variety 2", "Variety 2 Table (Base)") then
                    VrtTable.Init();
                "Variety 2 Lock Table" := VrtTable."Lock Table";
                CopyVrtValue("Variety 2", "Variety 2 Table (Base)");
            end;
        }
        field(212; "Create Copy of Variety 2 Table"; Boolean)
        {
            Caption = 'Create Copy of Variety 2 Table';
            DataClassification = CustomerContent;
            Description = 'Variety';

            trigger OnValidate()
            begin
                if not "Create Copy of Variety 2 Table" then
                    if IsLockedVariety(2) then
                        if IsAddedVarietyValue(2) then
                            Error(VarietyAddedErr, "Variety 2", "Variety 2 Table (New)");
            end;
        }
        field(213; "Variety 2 Table (New)"; Code[20])
        {
            Caption = 'Variety 2 Table (New)';
            DataClassification = CustomerContent;
            Description = 'Variety';
        }
        field(214; "Variety 2 Lock Table"; Boolean)
        {
            Caption = 'Variety 2 Lock Table';
            DataClassification = CustomerContent;
            Description = 'Variety';
        }
        field(220; "Variety 3"; Code[10])
        {
            Caption = 'Variety 3';
            DataClassification = CustomerContent;
            Description = 'Variety';
            TableRelation = "NPR Variety";
            ValidateTableRelation = false;
        }
        field(221; "Variety 3 Table (Base)"; Code[40])
        {
            Caption = 'Variety 3 Table';
            DataClassification = CustomerContent;
            Description = 'Variety';
            TableRelation = "NPR Variety Table".Code WHERE(Type = FIELD("Variety 3"));
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                VrtTable: Record "NPR Variety Table";
            begin
                "Variety 3 Table (New)" := GetVariety3Table();
                if not VrtTable.Get("Variety 3", "Variety 3 Table (Base)") then
                    VrtTable.Init();
                "Variety 3 Lock Table" := VrtTable."Lock Table";
                CopyVrtValue("Variety 3", "Variety 3 Table (Base)");
            end;
        }
        field(222; "Create Copy of Variety 3 Table"; Boolean)
        {
            Caption = 'Create Copy of Variety 3 Table';
            DataClassification = CustomerContent;
            Description = 'Variety';

            trigger OnValidate()
            begin
                if not "Create Copy of Variety 3 Table" then
                    if IsLockedVariety(3) then
                        if IsAddedVarietyValue(3) then
                            Error(VarietyAddedErr, "Variety 3", "Variety 3 Table (New)");
            end;
        }
        field(223; "Variety 3 Table (New)"; Code[20])
        {
            Caption = 'Variety 3 Table (New)';
            DataClassification = CustomerContent;
            Description = 'Variety';
        }
        field(224; "Variety 3 Lock Table"; Boolean)
        {
            Caption = 'Variety 3 Lock Table';
            DataClassification = CustomerContent;
            Description = 'Variety';
        }
        field(230; "Variety 4"; Code[10])
        {
            Caption = 'Variety 4';
            DataClassification = CustomerContent;
            Description = 'Variety';
            TableRelation = "NPR Variety";
            ValidateTableRelation = false;
        }
        field(231; "Variety 4 Table (Base)"; Code[40])
        {
            Caption = 'Variety 4 Table';
            DataClassification = CustomerContent;
            Description = 'Variety';
            TableRelation = "NPR Variety Table".Code WHERE(Type = FIELD("Variety 4"));
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                VrtTable: Record "NPR Variety Table";
            begin
                "Variety 4 Table (New)" := GetVariety4Table();
                if not VrtTable.Get("Variety 4", "Variety 4 Table (Base)") then
                    VrtTable.Init();
                "Variety 4 Lock Table" := VrtTable."Lock Table";
                CopyVrtValue("Variety 4", "Variety 4 Table (Base)");
            end;
        }
        field(232; "Create Copy of Variety 4 Table"; Boolean)
        {
            Caption = 'Create Copy of Variety 4 Table';
            DataClassification = CustomerContent;
            Description = 'Variety';

            trigger OnValidate()
            begin
                if not "Create Copy of Variety 4 Table" then
                    if IsLockedVariety(4) then
                        if IsAddedVarietyValue(4) then
                            Error(VarietyAddedErr, "Variety 4", "Variety 4 Table (New)");
            end;
        }
        field(233; "Variety 4 Table (New)"; Code[20])
        {
            Caption = 'Variety 4 Table (New)';
            DataClassification = CustomerContent;
            Description = 'Variety';
        }
        field(234; "Variety 4 Lock Table"; Boolean)
        {
            Caption = 'Variety 4 Lock Table';
            DataClassification = CustomerContent;
            Description = 'Variety';
        }
        field(240; "Cross Variety No."; Option)
        {
            Caption = 'Cross Variety No.';
            DataClassification = CustomerContent;
            Description = 'Variety';
            OptionCaption = 'Variety 1,Variety 2,Variety 3,Variety 4';
            OptionMembers = Variety1,Variety2,Variety3,Variety4;
        }
        field(250; "Variety Group"; Code[20])
        {
            Caption = 'Variety Group';
            DataClassification = CustomerContent;
            Description = 'Variety';
            TableRelation = "NPR Variety Group";
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                VRTCheck: Codeunit "NPR Variety Check";
            begin
                if "Variety Group" <> xRec."Variety Group" then begin
                    //updateitem
                    if "Variety Group" = '' then
                        VRTGroup.Init
                    else
                        VRTGroup.Get("Variety Group");

                    if VRTGroup."Variety 1" <> '' then begin
                        Validate("Variety 1", VRTGroup."Variety 1");
                        Validate("Variety 1 Table (Base)", VRTGroup."Variety 1 Table");
                        Validate("Variety 1 Table (New)", VRTGroup."Variety 1 Table");
                        Validate("Create Copy of Variety 1 Table", VRTGroup."Create Copy of Variety 1 Table");
                    end else begin
                        "Variety 1" := '';
                        "Variety 1 Table (Base)" := '';
                        "Variety 1 Table (New)" := '';
                        "Create Copy of Variety 4 Table" := false;
                    end;

                    if VRTGroup."Variety 2" <> '' then begin
                        Validate("Variety 2", VRTGroup."Variety 2");
                        Validate("Variety 2 Table (Base)", VRTGroup."Variety 2 Table");
                        Validate("Variety 2 Table (New)", VRTGroup."Variety 2 Table");
                        Validate("Create Copy of Variety 2 Table", VRTGroup."Create Copy of Variety 2 Table");
                    end else begin
                        "Variety 2" := '';
                        "Variety 2 Table (Base)" := '';
                        "Variety 2 Table (New)" := '';
                        "Create Copy of Variety 2 Table" := false;
                    end;

                    if VRTGroup."Variety 3" <> '' then begin
                        Validate("Variety 3", VRTGroup."Variety 3");
                        Validate("Variety 3 Table (Base)", VRTGroup."Variety 3 Table");
                        Validate("Variety 3 Table (New)", VRTGroup."Variety 3 Table");
                        Validate("Create Copy of Variety 3 Table", VRTGroup."Create Copy of Variety 3 Table");
                    end else begin
                        "Variety 3" := '';
                        "Variety 3 Table (Base)" := '';
                        "Variety 3 Table (New)" := '';
                        "Create Copy of Variety 3 Table" := false;
                    end;

                    if VRTGroup."Variety 4" <> '' then begin
                        Validate("Variety 4", VRTGroup."Variety 4");
                        Validate("Variety 4 Table (Base)", VRTGroup."Variety 4 Table");
                        Validate("Variety 4 Table (New)", VRTGroup."Variety 4 Table");
                        Validate("Create Copy of Variety 4 Table", VRTGroup."Create Copy of Variety 4 Table");
                    end else begin
                        "Variety 4" := '';
                        "Variety 4 Table (Base)" := '';
                        "Variety 4 Table (New)" := '';
                        "Create Copy of Variety 4 Table" := false;
                    end;

                    Validate("Cross Variety No.", VRTGroup."Cross Variety No.");

                    if xRec."Variety Group" <> '' then begin
                        if HasVarietyLines() then
                            Error(VarietyErr, FieldCaption("Variety Group"));
                    end else begin
                        UpdateAddedVarietyValues();
                    end;
                end;
            end;
        }
        field(260; "Recommended Retail Price"; Decimal)
        {
            Caption = 'Recommended Retail Price';
            DataClassification = CustomerContent;
        }
        field(300; "Variant Code"; Code[20])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
        }
        field(400; "Sales Price Currency Code"; Code[10])
        {
            Caption = 'Sales Price Currency Code';
            DataClassification = CustomerContent;
            TableRelation = Currency;
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                if "Sales Price Currency Code" <> '' then begin
                    GLSetup.Get;
                    if "Sales Price Currency Code" = GLSetup."LCY Code" then
                        "Sales Price Currency Code" := '';
                end;
            end;
        }
        field(410; "Purchase Price Currency Code"; Code[10])
        {
            Caption = 'Purchase Price Currency Code';
            DataClassification = CustomerContent;
            TableRelation = Currency;
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                if "Purchase Price Currency Code" <> '' then begin
                    GLSetup.Get;
                    if "Purchase Price Currency Code" = GLSetup."LCY Code" then
                        "Purchase Price Currency Code" := '';
                end;
            end;
        }
        field(500; "Variety Lines to Skip"; Integer)
        {
            CalcFormula = Count("NPR Item Worksh. Variant Line" WHERE("Worksheet Template Name" = FIELD("Worksheet Template Name"),
                                                                     "Worksheet Name" = FIELD("Worksheet Name"),
                                                                     "Worksheet Line No." = FIELD("Line No."),
                                                                     Action = CONST(Skip)));
            Caption = 'Variety Lines to Skip';
            Editable = false;
            FieldClass = FlowField;
        }
        field(510; "Variety Lines to Update"; Integer)
        {
            CalcFormula = Count("NPR Item Worksh. Variant Line" WHERE("Worksheet Template Name" = FIELD("Worksheet Template Name"),
                                                                     "Worksheet Name" = FIELD("Worksheet Name"),
                                                                     "Worksheet Line No." = FIELD("Line No."),
                                                                     Action = CONST(Update)));
            Caption = 'Variety Lines to Update';
            Editable = false;
            FieldClass = FlowField;
        }
        field(520; "Variety Lines to Create"; Integer)
        {
            CalcFormula = Count("NPR Item Worksh. Variant Line" WHERE("Worksheet Template Name" = FIELD("Worksheet Template Name"),
                                                                     "Worksheet Name" = FIELD("Worksheet Name"),
                                                                     "Worksheet Line No." = FIELD("Line No."),
                                                                     Action = CONST(CreateNew)));
            Caption = 'Variety Lines to Create';
            Editable = false;
            FieldClass = FlowField;
        }
        field(600; "Created Date Time"; DateTime)
        {
            Caption = 'Created Date Time';
            DataClassification = CustomerContent;
        }
        field(610; "No. of Changes"; Integer)
        {
            CalcFormula = Count("NPR Item Worksh. Field Change" WHERE("Worksheet Template Name" = FIELD("Worksheet Template Name"),
                                                                     "Worksheet Name" = FIELD("Worksheet Name"),
                                                                     "Worksheet Line No." = FIELD("Line No."),
                                                                     Process = CONST(true)));
            Caption = 'No. of Changes';
            Description = 'NPR5.25';
            Editable = false;
            FieldClass = FlowField;
        }
        field(611; "No. of Warnings"; Integer)
        {
            CalcFormula = Count("NPR Item Worksh. Field Change" WHERE("Worksheet Template Name" = FIELD("Worksheet Template Name"),
                                                                     "Worksheet Name" = FIELD("Worksheet Name"),
                                                                     "Worksheet Line No." = FIELD("Line No."),
                                                                     Warning = CONST(true)));
            Caption = 'No. of Warnings';
            Description = 'NPR5.25';
            Editable = false;
            FieldClass = FlowField;
        }
        field(910; "Assembly Policy"; Option)
        {
            AccessByPermission = TableData "BOM Component" = R;
            Caption = 'Assembly Policy';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'Assemble-to-Stock,Assemble-to-Order,,,,,,,,Undefined';
            OptionMembers = "Assemble-to-Stock","Assemble-to-Order",,,,,,,,Undefined;
        }
        field(1217; GTIN; Code[14])
        {
            Caption = 'GTIN';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            Numeric = true;
        }
        field(5401; "Lot Size"; Decimal)
        {
            AccessByPermission = TableData "Production Order" = R;
            Caption = 'Lot Size';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.25';
            MinValue = 0;
        }
        field(5402; "Serial Nos."; Code[10])
        {
            Caption = 'Serial Nos.';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            TableRelation = "No. Series";
            ValidateTableRelation = false;
        }
        field(5407; "Scrap %"; Decimal)
        {
            AccessByPermission = TableData "Production Order" = R;
            Caption = 'Scrap %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
            Description = 'NPR5.25';
            MaxValue = 100;
            MinValue = 0;
        }
        field(5409; "Inventory Value Zero"; Option)
        {
            Caption = 'Inventory Value Zero';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'No,Yes,Undefined';
            OptionMembers = No,Yes,Undefined;
        }
        field(5410; "Discrete Order Quantity"; Integer)
        {
            Caption = 'Discrete Order Quantity';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            MinValue = 0;
        }
        field(5411; "Minimum Order Quantity"; Decimal)
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            Caption = 'Minimum Order Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.25';
            MinValue = 0;
        }
        field(5412; "Maximum Order Quantity"; Decimal)
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            Caption = 'Maximum Order Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.25';
            MinValue = 0;
        }
        field(5413; "Safety Stock Quantity"; Decimal)
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            Caption = 'Safety Stock Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.25';
            MinValue = 0;
        }
        field(5414; "Order Multiple"; Decimal)
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            Caption = 'Order Multiple';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.25';
            MinValue = 0;
        }
        field(5415; "Safety Lead Time"; DateFormula)
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            Caption = 'Safety Lead Time';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(5417; "Flushing Method"; Option)
        {
            AccessByPermission = TableData "Production Order" = R;
            Caption = 'Flushing Method';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'Manual,Forward,Backward,Pick + Forward,Pick + Backward,,,,,Undefined';
            OptionMembers = Manual,Forward,Backward,"Pick + Forward","Pick + Backward",,,,,Undefined;
        }
        field(5419; "Replenishment System"; Option)
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            Caption = 'Replenishment System';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'Purchase,Prod. Order,,Assembly,,,,,,Undefined';
            OptionMembers = Purchase,"Prod. Order",,Assembly,,,,,,Undefined;
        }
        field(5425; "Sales Unit of Measure"; Code[10])
        {
            Caption = 'Sales Unit of Measure';
            DataClassification = CustomerContent;
            TableRelation = "Unit of Measure";
            ValidateTableRelation = false;
        }
        field(5426; "Purch. Unit of Measure"; Code[10])
        {
            Caption = 'Purch. Unit of Measure';
            DataClassification = CustomerContent;
            TableRelation = "Unit of Measure";
        }
        field(5440; "Reordering Policy"; Option)
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            Caption = 'Reordering Policy';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = ' ,Fixed Reorder Qty.,Maximum Qty.,Order,Lot-for-Lot,,,,,Undefined';
            OptionMembers = " ","Fixed Reorder Qty.","Maximum Qty.","Order","Lot-for-Lot",,,,,Undefined;
        }
        field(5441; "Include Inventory"; Option)
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            Caption = 'Include Inventory';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'No,Yes,Undefined';
            OptionMembers = No,Yes,Undefined;
        }
        field(5442; "Manufacturing Policy"; Option)
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            Caption = 'Manufacturing Policy';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'Make-to-Stock,Make-to-Order,,,,,,,,Undefined';
            OptionMembers = "Make-to-Stock","Make-to-Order",,,,,,,,Undefined;
        }
        field(5443; "Rescheduling Period"; DateFormula)
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            Caption = 'Rescheduling Period';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(5444; "Lot Accumulation Period"; DateFormula)
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            Caption = 'Lot Accumulation Period';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(5445; "Dampener Period"; DateFormula)
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            Caption = 'Dampener Period';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(5446; "Dampener Quantity"; Decimal)
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            Caption = 'Dampener Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.25';
            MinValue = 0;
        }
        field(5447; "Overflow Level"; Decimal)
        {
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            Caption = 'Overflow Level';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.25';
            MinValue = 0;
        }
        field(5701; "Manufacturer Code"; Code[10])
        {
            Caption = 'Manufacturer Code';
            DataClassification = CustomerContent;
            TableRelation = Manufacturer;
            ValidateTableRelation = false;
        }
        field(5702; "Item Category Code"; Code[20])
        {
            Caption = 'Item Category Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Category";
            ValidateTableRelation = false;
        }
        field(5704; "Product Group Code"; Code[10])
        {
            Caption = 'Product Group Code';
            DataClassification = CustomerContent;
            ObsoleteState = No;
            //ObsoleteReason = 'Product Groups became first level children of Item Categories.';
            //ObsoleteTag = '15.0';
        }
        field(5900; "Service Item Group"; Code[10])
        {
            Caption = 'Service Item Group';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            TableRelation = "Service Item Group".Code;
            ValidateTableRelation = false;
        }
        field(6500; "Item Tracking Code"; Code[10])
        {
            Caption = 'Item Tracking Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            TableRelation = "Item Tracking Code";
            ValidateTableRelation = false;
        }
        field(6501; "Lot Nos."; Code[10])
        {
            Caption = 'Lot Nos.';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            TableRelation = "No. Series";
            ValidateTableRelation = false;
        }
        field(6502; "Expiration Calculation"; DateFormula)
        {
            Caption = 'Expiration Calculation';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(7301; "Special Equipment Code"; Code[10])
        {
            Caption = 'Special Equipment Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            TableRelation = "Special Equipment";
            ValidateTableRelation = false;
        }
        field(7302; "Put-away Template Code"; Code[10])
        {
            Caption = 'Put-away Template Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            TableRelation = "Put-away Template Header";
            ValidateTableRelation = false;
        }
        field(7307; "Put-away Unit of Measure Code"; Code[10])
        {
            AccessByPermission = TableData "Posted Invt. Put-away Header" = R;
            Caption = 'Put-away Unit of Measure Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(7380; "Phys Invt Counting Period Code"; Code[10])
        {
            Caption = 'Phys Invt Counting Period Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            TableRelation = "Phys. Invt. Counting Period";
            ValidateTableRelation = false;
        }
        field(7384; "Use Cross-Docking"; Option)
        {
            AccessByPermission = TableData "Bin Content" = R;
            Caption = 'Use Cross-Docking';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'No,Yes,Undefined';
            OptionMembers = No,Yes,Undefined;
        }
        field(8001; "Custom Text 1"; Text[50])
        {
            Caption = 'Custom Text 1';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(8002; "Custom Text 2"; Text[50])
        {
            Caption = 'Custom Text 2';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(8003; "Custom Text 3"; Text[50])
        {
            Caption = 'Custom Text 3';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(8004; "Custom Text 4"; Text[50])
        {
            Caption = 'Custom Text 4';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(8005; "Custom Text 5"; Text[50])
        {
            Caption = 'Custom Text 5';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(8011; "Custom Price 1"; Decimal)
        {
            Caption = 'Custom Price 1';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(8012; "Custom Price 2"; Decimal)
        {
            Caption = 'Custom Price 2';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(8013; "Custom Price 3"; Decimal)
        {
            Caption = 'Custom Price 3';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(8014; "Custom Price 4"; Decimal)
        {
            Caption = 'Custom Price 4';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(8015; "Custom Price 5"; Decimal)
        {
            Caption = 'Custom Price 5';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(8100; "Sales Price Start Date"; Date)
        {
            Caption = 'Sales Price Start Date';
            DataClassification = CustomerContent;
            Description = 'NPR5.38';
        }
        field(8101; "Purchase Price Start Date"; Date)
        {
            Caption = 'Purchase Price Start Date';
            DataClassification = CustomerContent;
            Description = 'NPR5.38';
        }
        field(6014400; "Item Group"; Code[10])
        {
            Caption = 'Item Group';
            DataClassification = CustomerContent;
            TableRelation = "NPR Item Group" WHERE(Blocked = CONST(false));
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                ItemGroup: Record "NPR Item Group";
            begin
                ItemWorksheetManagement.CheckItemGroupSetup("Item Group");

                if not ItemGroup.Get("Item Group") then
                    ItemGroup.Init();
                "VAT Prod. Posting Group" := ItemGroup."VAT Prod. Posting Group";
                "VAT Bus. Posting Gr. (Price)" := ItemGroup."VAT Bus. Posting Group";
                "Gen. Prod. Posting Group" := ItemGroup."Gen. Prod. Posting Group";
                "Inventory Posting Group" := ItemGroup."Inventory Posting Group";
                "Base Unit of Measure" := ItemGroup."Base Unit of Measure";
                "Sales Unit of Measure" := ItemGroup."Sales Unit of Measure";
                "Tax Group Code" := ItemGroup."Tax Group Code";

                "Purch. Unit of Measure" := ItemGroup."Purch. Unit of Measure";
                if Description = '' then
                    Description := ItemGroup.Description;
                "Costing Method" := ItemGroup."Costing Method";

                if ItemGroup."No. Series" <> '' then
                    "No. Series" := ItemGroup."No. Series";

                "Global Dimension 1 Code" := ItemGroup."Global Dimension 1 Code";
                "Global Dimension 2 Code" := ItemGroup."Global Dimension 2 Code";

                Validate("Variety Group", ItemGroup."Variety Group");
            end;
        }
        field(6014401; "Group sale"; Option)
        {
            Caption = 'Various item sales';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'No,Yes,Undefined';
            OptionMembers = No,Yes,Undefined;
        }
        field(6014408; Season; Code[3])
        {
            Caption = 'Season';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(6014410; "Label Barcode"; Code[20])
        {
            Caption = 'Label barcode';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(6014418; "Explode BOM auto"; Option)
        {
            Caption = 'Auto-explode BOM';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'No,Yes,Undefined';
            OptionMembers = No,Yes,Undefined;
        }
        field(6014419; "Guarantee voucher"; Option)
        {
            Caption = 'Guarantee voucher';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'No,Yes,Undefined';
            OptionMembers = No,Yes,Undefined;
        }
        field(6014424; "Cannot edit unit price"; Option)
        {
            Caption = 'Can''t edit unit price';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'No,Yes,Undefined';
            OptionMembers = No,Yes,Undefined;
        }
        field(6014500; "Second-hand number"; Code[20])
        {
            Caption = 'Second-hand number';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(6014502; Condition; Option)
        {
            Caption = 'Condition';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'New,Mint,Mint boxed,A,B,C,D,E,F,Undefined';
            OptionMembers = New,Mint,"Mint boxed",A,B,C,D,E,F,Undefined;
        }
        field(6014503; "Second-hand"; Option)
        {
            Caption = 'Second-hand';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'No,Yes,Undefined';
            OptionMembers = No,Yes,Undefined;
        }
        field(6014504; "Guarantee Index"; Option)
        {
            Caption = 'Guarantee Index';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = ' ,Move to Warrenty,,,,,,,,Undefined';
            OptionMembers = " ","Flyt til garanti kar.",,,,,,,,Undefined;
        }
        field(6014508; "Insurrance category"; Code[50])
        {
            Caption = 'Insurance Section';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            TableRelation = "NPR Insurance Category";
            ValidateTableRelation = false;
        }
        field(6014509; "Item Brand"; Code[10])
        {
            Caption = 'Item brand';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(6014511; "Type Retail"; Code[10])
        {
            Caption = 'Type Retail';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(6014512; "No Print on Reciept"; Option)
        {
            Caption = 'No Print on Reciept';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'No,Yes,Undefined';
            OptionMembers = No,Yes,Undefined;
        }
        field(6014513; "Print Tags"; Text[100])
        {
            Caption = 'Print Tags';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(6014607; "Change quantity by Photoorder"; Option)
        {
            Caption = 'Change quantity by Photoorder';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'No,Yes,Undefined';
            OptionMembers = No,Yes,Undefined;
        }
        field(6014625; "Std. Sales Qty."; Decimal)
        {
            Caption = 'Std. Sales Qty.';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(6014630; "Blocked on Pos"; Option)
        {
            Caption = 'Blocked on Pos';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'No,Yes,Undefined';
            OptionMembers = No,Yes,Undefined;
        }
        field(6059784; "Ticket Type"; Code[10])
        {
            Caption = 'Ticket Type';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            TableRelation = "NPR TM Ticket Type";
            ValidateTableRelation = false;
        }
        field(6151400; "Magento Item"; Option)
        {
            Caption = 'Magento Item';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            OptionCaption = 'No,Yes,Undefined';
            OptionMembers = No,Yes,Undefined;
        }
        field(6151405; "Magento Status"; Option)
        {
            BlankZero = true;
            Caption = 'Magento Status';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Active;
            OptionCaption = ',Active,Inactive';
            OptionMembers = ,Active,Inactive;
        }
        field(6151410; "Attribute Set ID"; Integer)
        {
            Caption = 'Attribute Set ID';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            TableRelation = "NPR Magento Attribute Set";
            ValidateTableRelation = false;
        }
        field(6151415; "Magento Description"; BLOB)
        {
            Caption = 'Magento Description';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(6151420; "Magento Name"; Text[250])
        {
            Caption = 'Magento Name';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(6151425; "Magento Short Description"; BLOB)
        {
            Caption = 'Magento Short Description';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(6151430; "Magento Brand"; Code[20])
        {
            Caption = 'Magento Brand';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            TableRelation = "NPR Magento Brand";
            ValidateTableRelation = false;
        }
        field(6151435; "Seo Link"; Text[250])
        {
            Caption = 'Seo Link';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(6151440; "Meta Title"; Text[70])
        {
            Caption = 'Meta Title';
            DataClassification = CustomerContent;
            Description = 'NPR5.25,NPR5.37';
        }
        field(6151445; "Meta Description"; Text[250])
        {
            Caption = 'Meta Description';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(6151450; "Product New From"; Date)
        {
            Caption = 'Product New From';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(6151455; "Product New To"; Date)
        {
            Caption = 'Product New To';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(6151460; "Special Price"; Decimal)
        {
            Caption = 'Special Price';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(6151465; "Special Price From"; Date)
        {
            Caption = 'Special Price From';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(6151470; "Special Price To"; Date)
        {
            Caption = 'Special Price To';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(6151475; "Featured From"; Date)
        {
            Caption = 'Featured From';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(6151480; "Featured To"; Date)
        {
            Caption = 'Featured To';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(6151485; Backorder; Option)
        {
            Caption = 'Backorder';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            OptionCaption = 'No,Yes,Undefined';
            OptionMembers = No,Yes,Undefined;
        }
        field(6151490; "Display Only"; Option)
        {
            Caption = 'Display Only';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            OptionCaption = 'No,Yes,Undefined';
            OptionMembers = No,Yes,Undefined;
        }
        field(99000750; "Routing No."; Code[20])
        {
            Caption = 'Routing No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            TableRelation = "Routing Header";
            ValidateTableRelation = false;
        }
        field(99000751; "Production BOM No."; Code[20])
        {
            Caption = 'Production BOM No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            TableRelation = "Production BOM Header";
            ValidateTableRelation = false;
        }
        field(99000757; "Overhead Rate"; Decimal)
        {
            AccessByPermission = TableData "Production Order" = R;
            AutoFormatType = 2;
            Caption = 'Overhead Rate';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
        field(99000773; "Order Tracking Policy"; Option)
        {
            Caption = 'Order Tracking Policy';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'None,Tracking Only,Tracking & Action Msg.,,,,,,,Undefined';
            OptionMembers = "None","Tracking Only","Tracking & Action Msg.",,,,,,,Undefined;
        }
        field(99000875; Critical; Option)
        {
            Caption = 'Critical';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
            InitValue = Undefined;
            OptionCaption = 'No,Yes,Undefined';
            OptionMembers = No,Yes,Undefined;
        }
        field(99008500; "Common Item No."; Code[20])
        {
            Caption = 'Common Item No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.25';
        }
    }

    keys
    {
        key(Key1; "Worksheet Template Name", "Worksheet Name", "Line No.")
        {
        }
        key(Key2; "No. Series")
        {
        }
    }


    trigger OnDelete()
    begin
        DeleteRelatedLines();
    end;

    trigger OnInsert()
    begin
        SetUseVariant();
    end;

    trigger OnModify()
    begin
        SetUseVariant();

        if "Item Group" = '' then begin
            GetWorksheet();
            if ItemWorksheet."Item Group" <> '' then
                Validate("Item Group", ItemWorksheet."Item Group");
        end;
    end;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateDimValueCode(FieldNumber, ShortcutDimCode);
    end;

    local procedure GetCaptionClass(FieldNumber: Integer): Text[80]
    var
        ItemWizBatch: Record "NPR Item Worksheet";
    begin
        if not ItemWorksheet.Get("Worksheet Template Name", "Worksheet Name") then begin
            ItemWorksheet.Init();
        end;
        if ItemWorksheet."Prices Including VAT" then
            exit('2,1,' + GetFieldCaption(FieldNumber))
        else
            exit('2,0,' + GetFieldCaption(FieldNumber));
    end;

    local procedure GetFieldCaption(FieldNumber: Integer): Text[100]
    var
        "Field": Record "Field";
    begin
        Field.Get(DATABASE::"NPR Item Worksheet Line", FieldNumber);
        exit(Field."Field Caption");
    end;

    procedure SetUpNewLine(LastItemWorksheetLine: Record "NPR Item Worksheet Line")
    begin
        ItemWorksheetTemplate.Get("Worksheet Template Name");
        ItemWorksheet.Get("Worksheet Template Name", "Worksheet Name");

        if "Sales Price Currency Code" = '' then
            "Sales Price Currency Code" := LastItemWorksheetLine."Sales Price Currency Code";
        if "Purchase Price Currency Code" = '' then
            "Purchase Price Currency Code" := LastItemWorksheetLine."Purchase Price Currency Code";
        "No. Series" := ItemWorksheet."No. Series";
        if "No. Series" = '' then
            "No. Series" := ItemWorksheetTemplate."No. Series";
        if "No. Series" = '' then
            "No. Series" := LastItemWorksheetLine."No. Series";

        if "Vendor No." = '' then
            "Vendor No." := LastItemWorksheetLine."Vendor No.";
        if "Vendor No." = '' then
            "Vendor No." := ItemWorksheet."Vendor No.";
        if Vendor.Get("Vendor No.") then begin
            "VAT Bus. Posting Group" := Vendor."VAT Bus. Posting Group";
            if "Vendor No." <> '' then
                "Vendor No." := Vendor."No.";
        end;
    end;

    procedure GetWorksheet()
    begin
        if (ItemWorksheet."Item Template Name" <> "Worksheet Template Name") or
           (ItemWorksheet.Name <> "Worksheet Name") then begin
            ItemWorksheet.Get("Worksheet Template Name", "Worksheet Name");

            if ItemWorksheet."Sales Price Currency Code" = '' then
                SalesCurrency.InitRoundingPrecision
            else begin
                SalesCurrency.Get(ItemWorksheet."Sales Price Currency Code");
                SalesCurrency.TestField("Amount Rounding Precision");
            end;
            if ItemWorksheet."Purchase Price Currency Code" = '' then
                PurchaseCurrency.InitRoundingPrecision
            else begin
                PurchaseCurrency.Get(ItemWorksheet."Purchase Price Currency Code");
                PurchaseCurrency.TestField("Amount Rounding Precision");
            end;
        end;
    end;

    procedure UpdateItemNo()
    var
        VarCode: Code[10];
        ItemNo: Code[20];
    begin
        if FindItemNo("Vendors Bar Code", "Internal Bar Code", "Vendor Item No.", "Vendor No.", ItemNo, VarCode) then begin
            Validate("Item No.", ItemNo);
        end else begin
            Validate("Item No.", '');
        end;
    end;

    procedure FindItemNo(ItemRefNo: Code[50]; AltNo: Code[50]; VendorsItemNo: Code[20]; OurVendorNo: Code[20]; var OurItemNo: Code[20]; var OurVariantCode: Code[20]) found: Boolean
    var
        ItemRef: Record "Item Reference";
        AlternativeNo: Record "NPR Alternative No.";
    begin
        if ItemRefNo <> '' then begin
            ItemRef.SetRange("Reference Type", ItemRef."Reference Type"::Vendor);
            if OurVendorNo <> '' then
                ItemRef.SetRange("Reference Type No.", OurVendorNo);
            ItemRef.SetRange("Reference No.", ItemRefNo);
            if ItemRef.FindFirst then begin
                OurItemNo := ItemRef."Item No.";
                OurVariantCode := ItemRef."Variant Code";
                exit(true);
            end;
        end;

        if AltNo <> '' then begin
            AlternativeNo.SetCurrentKey("Alt. No.", Type);
            AlternativeNo.SetRange("Alt. No.", AltNo);
            AlternativeNo.SetRange(Type, AlternativeNo.Type::Item);
            if AlternativeNo.FindFirst() then begin
                OurItemNo := AlternativeNo.Code;
                OurVariantCode := AlternativeNo."Variant Code";
                exit(true);
            end;
        end;

        if VendorsItemNo <> '' then begin
            Item.SetRange("Vendor Item No.", VendorsItemNo);
            if OurVendorNo <> '' then
                Item.SetRange("Vendor No.", OurVendorNo);
            if Item.FindFirst() then begin
                OurItemNo := Item."No.";
                OurVariantCode := '';
                exit(true);
            end;
        end;
    end;

    local procedure GetVariety1Table(): Code[20]
    begin
        if not "Create Copy of Variety 1 Table" then
            exit("Variety 1 Table (Base)");

        GetVRTGroup();

        VRTGroup.TestField("Copy Naming Variety 1");
        case VRTGroup."Copy Naming Variety 1" of
            VRTGroup."Copy Naming Variety 1"::TableCodeAndItemNo:
                begin
                    if "Item No." <> '' then
                        exit("Variety 1 Table (Base)" + '-' + "Item No.")
                    else
                        exit("Variety 1 Table (Base)" + '-' + NewItemNoLbl);
                end;
            VRTGroup."Copy Naming Variety 1"::TableCodeAndNoSeries:
                exit(VRTGroup."Variety 1 Table" + '-' + NewNosNoLbl);
        end;
        exit('');
    end;

    local procedure GetVariety2Table(): Code[20]
    begin
        if not VRTGroup."Create Copy of Variety 2 Table" then
            exit("Variety 2 Table (Base)");

        GetVRTGroup();

        VRTGroup.TestField("Copy Naming Variety 2");
        case VRTGroup."Copy Naming Variety 2" of
            VRTGroup."Copy Naming Variety 2"::TableCodeAndItemNo:
                begin
                    if "Item No." <> '' then
                        exit(VRTGroup."Variety 2 Table" + '-' + "Item No.")
                    else
                        exit(VRTGroup."Variety 2 Table" + '-' + NewItemNoLbl);
                end;
            VRTGroup."Copy Naming Variety 2"::TableCodeAndNoSeries:
                exit(VRTGroup."Variety 2 Table" + '-' + NewNosNoLbl);
        end;
        exit('');
    end;

    local procedure GetVariety3Table(): Code[20]
    begin
        if not VRTGroup."Create Copy of Variety 3 Table" then
            exit("Variety 3 Table (Base)");

        GetVRTGroup();

        VRTGroup.TestField("Copy Naming Variety 3");
        case VRTGroup."Copy Naming Variety 3" of
            VRTGroup."Copy Naming Variety 3"::TableCodeAndItemNo:
                begin
                    if "Item No." <> '' then
                        exit(VRTGroup."Variety 3 Table" + '-' + "Item No.")
                    else
                        exit(VRTGroup."Variety 3 Table" + '-' + NewItemNoLbl);
                end;
            VRTGroup."Copy Naming Variety 3"::TableCodeAndNoSeries:
                exit(VRTGroup."Variety 3 Table" + '-' + NewNosNoLbl);
        end;
        exit('');
    end;

    local procedure GetVariety4Table(): Code[20]
    begin
        if not VRTGroup."Create Copy of Variety 4 Table" then
            exit("Variety 4 Table (Base)");

        GetVRTGroup();

        VRTGroup.TestField("Copy Naming Variety 4");
        case VRTGroup."Copy Naming Variety 4" of
            VRTGroup."Copy Naming Variety 4"::TableCodeAndItemNo:
                begin
                    if "Item No." <> '' then
                        exit(VRTGroup."Variety 4 Table" + '-' + "Item No.")
                    else
                        exit(VRTGroup."Variety 4 Table" + '-' + NewItemNoLbl);
                end;
            VRTGroup."Copy Naming Variety 4"::TableCodeAndNoSeries:
                exit(VRTGroup."Variety 4 Table" + '-' + NewNosNoLbl);
        end;
        exit('');
    end;

    local procedure GetItem()
    begin
        if not Item.Get("Existing Item No.") then begin
            if Item."No." <> '' then
                Clear(Item);
            exit;
        end;

        if "Item No." <> Item."No." then
            Item.Get("Item No.");
    end;

    procedure GetNewItemNo(): Code[20]
    var
        InventorySetup: Record "Inventory Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        Prefix: Code[4];
    begin
        ItemWorksheetTemplate.Get("Worksheet Template Name");

        ItemWorksheet.Get("Worksheet Template Name", "Worksheet Name");
        if ItemWorksheet."No. Series" <> '' then
            "No. Series" := ItemWorksheet."No. Series"
        else
            if ItemWorksheetTemplate."No. Series" <> '' then
                "No. Series" := ItemWorksheetTemplate."No. Series";

        if "No. Series" = '' then
            Validate("No. Series", ItemWorksheetTemplate."No. Series");
        if "No. Series" = '' then begin
            InventorySetup.Get;
            Validate("No. Series", InventorySetup."Item Nos.");
        end;

        TestField("No. Series");
        case ItemWorksheetTemplate."Item No. Creation by" of
            ItemWorksheetTemplate."Item No. Creation by"::NoSeriesInWorksheet:
                begin
                    NoSeriesMgt.InitSeries("No. Series", "No. Series", 0D, "Item No.", "No. Series");
                    Prefix := ItemNoPrefix;
                    if StrLen(Prefix + "Item No.") < MaxStrLen("Item No.") then
                        exit(Prefix + "Item No.");
                    exit("Item No.");
                end;
            ItemWorksheetTemplate."Item No. Creation by"::NoSeriesOnProcessing:
                begin
                end;
            ItemWorksheetTemplate."Item No. Creation by"::VendorItemNo:
                begin
                    NoSeriesMgt.TestManual("No. Series");
                    if "Vendor Item No." = '' then
                        exit('');
                    Prefix := ItemNoPrefix;
                    if StrLen(Prefix + "Vendor Item No.") < MaxStrLen("Vendor Item No.") then
                        exit(Prefix + "Vendor Item No.");
                    exit("Vendor Item No.");
                end;
        end;
    end;

    local procedure GetVRTGroup()
    begin
        if "Variety Group" = VRTGroup.Code then
            exit;

        if not VRTGroup.Get("Variety Group") then
            VRTGroup.Init();
    end;

    local procedure CopyVrtValue(FromVrtType: Code[10]; FromVrtTable: Code[40])
    var
        ItemWorksheetVrtValue: Record "NPR Item Worksh. Variety Value";
        VrtValue: Record "NPR Variety Value";
    begin
        if FromVrtType <> '' then begin
            VrtValue.SetRange(Type, FromVrtType);
            VrtValue.SetRange(Table, FromVrtTable);

            if VrtValue.FindSet() then
                repeat
                    ItemWorksheetVrtValue."Worksheet Template Name" := "Worksheet Template Name";
                    ItemWorksheetVrtValue."Worksheet Name" := "Worksheet Name";
                    ItemWorksheetVrtValue."Worksheet Line No." := "Line No.";
                    ItemWorksheetVrtValue.Type := VrtValue.Type;
                    ItemWorksheetVrtValue.Table := VrtValue.Table;
                    ItemWorksheetVrtValue.Value := VrtValue.Value;
                    ItemWorksheetVrtValue."Sort Order" := VrtValue."Sort Order";
                    ItemWorksheetVrtValue.Description := VrtValue.Description;
                    if ItemWorksheetVrtValue.Insert then;
                until VrtValue.Next() = 0;
        end;
    end;

    procedure ConfirmRefreshVariants()
    begin
        if Confirm(RebuildQst) then
            RefreshVariants(3, true);
    end;

    procedure RefreshVariants(LinesType: Option "None",Variants,"Varieties Without Variants",All; IncludeHeaders: Boolean)
    var
        ItemWorksheetVar: Record "NPR Item Worksh. Variant Line";
        NewLevel: Integer;
    begin
        //Remove Lines
        ItemWorksheetVar.SetRange("Worksheet Template Name", "Worksheet Template Name");
        ItemWorksheetVar.SetRange("Worksheet Name", "Worksheet Name");
        ItemWorksheetVar.SetRange("Worksheet Line No.", "Line No.");
        if not IncludeHeaders then
            ItemWorksheetVar.SetFilter("Heading Text", '%1', '');
        case LinesType of
            LinesType::None:
                begin
                    if IncludeHeaders then
                        ItemWorksheetVar.SetFilter("Heading Text", '<>%1', '')
                    else
                        exit;
                end;
            LinesType::Variants:
                ItemWorksheetVar.SetFilter("Existing Variant Code", '<>%1', '');
            LinesType::"Varieties Without Variants":
                ItemWorksheetVar.SetFilter("Existing Variant Code", '%1', '');
        end;
        ItemWorksheetVar.DeleteAll();
        if IncludeHeaders then begin
            ItemWorksheetVar.Reset();
            ItemWorksheetVar.SetRange("Worksheet Template Name", "Worksheet Template Name");
            ItemWorksheetVar.SetRange("Worksheet Name", "Worksheet Name");
            ItemWorksheetVar.SetRange("Worksheet Line No.", "Line No.");
            ItemWorksheetVar.SetFilter("Heading Text", '<>%1', '');
            ItemWorksheetVar.DeleteAll();
        end;

        //Build Lines
        if "Variant Code" <> '' then
            CopyItemVariants(3)
        else
            CopyItemVarieties(LinesType, IncludeHeaders);
        if IncludeHeaders then
            UpdateVarietyHeadingText();
    end;

    local procedure CopyItemVariants(LinesType: Option Headers,Varieties,Both,Variant)
    var
        ItemVar: Record "Item Variant";
        ItemWorksheetVar: Record "NPR Item Worksh. Variant Line";
        LineNo: Integer;
    begin
        ItemVar.SetRange("Item No.", "Existing Item No.");
        if LinesType = LinesType::Variant then
            ItemVar.SetRange(Code, "Variant Code");
        if ItemVar.FindSet() then
            repeat
                LineNo += 10000;
                ItemWorksheetVar.Init();
                ItemWorksheetVar."Worksheet Template Name" := "Worksheet Template Name";
                ItemWorksheetVar."Worksheet Name" := "Worksheet Name";
                ItemWorksheetVar."Worksheet Line No." := "Line No.";
                ItemWorksheetVar."Line No." := LineNo;
                ItemWorksheetVar."Item No." := ItemVar."Item No.";
                ItemWorksheetVar."Existing Item No." := ItemVar."Item No.";
                ItemWorksheetVar."Existing Variant Code" := ItemVar.Code;
                ItemWorksheetVar."Variety 1 Value" := ItemVar."NPR Variety 1 Value";
                ItemWorksheetVar."Variety 2 Value" := ItemVar."NPR Variety 2 Value";
                ItemWorksheetVar."Variety 3 Value" := ItemVar."NPR Variety 3 Value";
                ItemWorksheetVar."Variety 4 Value" := ItemVar."NPR Variety 4 Value";
                case Action of
                    Action::Skip:
                        ItemWorksheetVar.Action := ItemWorksheetVar.Action::Skip;
                    Action::CreateNew:
                        ItemWorksheetVar.Action := ItemWorksheetVar.Action::Update;
                    Action::UpdateOnly:
                        ItemWorksheetVar.Action := ItemWorksheetVar.Action::Update;
                    Action::UpdateAndCreateVariants:
                        ItemWorksheetVar.Action := ItemWorksheetVar.Action::Update;
                end;
                ItemWorksheetVar.FillDescription();
                ItemWorksheetVar.Insert();
            until ItemVar.Next() = 0;
    end;

    local procedure CopyItemVarieties(LinesType: Option "None",Variants,"Varieties Without Variants",All; IncludeHeaders: Boolean)
    var
        ItemVar: Record "Item Variant";
        ItemWorksheetVariantLine: Record "NPR Item Worksh. Variant Line";
        ItemWorksheetVarietyValue1: Record "NPR Item Worksh. Variety Value";
        ItemWorksheetVarietyValue2: Record "NPR Item Worksh. Variety Value";
        ItemWorksheetVarietyValue3: Record "NPR Item Worksh. Variety Value";
        ItemWorksheetVarietyValue4: Record "NPR Item Worksh. Variety Value";
        TempItemWorksheetVarietyValue1: Record "NPR Item Worksh. Variety Value" temporary;
        TempItemWorksheetVarietyValue2: Record "NPR Item Worksh. Variety Value" temporary;
        TempItemWorksheetVarietyValue3: Record "NPR Item Worksh. Variety Value" temporary;
        TempItemWorksheetVarietyValue4: Record "NPR Item Worksh. Variety Value" temporary;
        UpdateLineNo: Boolean;
        ExistingVariantCode: Code[20];
        LineNo: Integer;
        NewLevel: Integer;
        VRT1Desc: Text[50];
        VRT2Desc: Text[50];
        VRT3Desc: Text[50];
        VRT4Desc: Text[50];
    begin
        InitItemWorksheetVarietyValue(ItemWorksheetVarietyValue1, "Variety 1", "Variety 1 Table (Base)");
        InitItemWorksheetVarietyValue(ItemWorksheetVarietyValue2, "Variety 2", "Variety 2 Table (Base)");
        InitItemWorksheetVarietyValue(ItemWorksheetVarietyValue3, "Variety 3", "Variety 3 Table (Base)");
        InitItemWorksheetVarietyValue(ItemWorksheetVarietyValue4, "Variety 4", "Variety 4 Table (Base)");

        ItemWorksheetVariantLine.SetRange("Worksheet Template Name", "Worksheet Template Name");
        ItemWorksheetVariantLine.SetRange("Worksheet Name", "Worksheet Name");
        ItemWorksheetVariantLine.SetRange("Worksheet Line No.", "Line No.");
        if ItemWorksheetVariantLine.FindLast() then
            LineNo := ItemWorksheetVariantLine."Line No."
        else
            LineNo := 0;

        GetTempVarietyLines(ItemWorksheetVarietyValue1, TempItemWorksheetVarietyValue1, 1, LinesType);
        GetTempVarietyLines(ItemWorksheetVarietyValue2, TempItemWorksheetVarietyValue2, 2, LinesType);
        GetTempVarietyLines(ItemWorksheetVarietyValue3, TempItemWorksheetVarietyValue3, 3, LinesType);
        GetTempVarietyLines(ItemWorksheetVarietyValue4, TempItemWorksheetVarietyValue4, 4, LinesType);

        if TempItemWorksheetVarietyValue1.FindFirst() then
            repeat
                if ("Variety 2 Table (New)" <> '') and IncludeHeaders then begin
                    //Insert Level 1 Header Line
                    LineNo := LineNo + 10000;
                    ItemWorksheetVariantLine.Init();
                    ItemWorksheetVariantLine."Worksheet Template Name" := Rec."Worksheet Template Name";
                    ItemWorksheetVariantLine."Worksheet Name" := Rec."Worksheet Name";
                    ItemWorksheetVariantLine."Worksheet Line No." := Rec."Line No.";
                    ItemWorksheetVariantLine."Line No." := LineNo;
                    ItemWorksheetVariantLine."Variety 1 Value" := TempItemWorksheetVarietyValue1.Value;
                    ItemWorksheetVariantLine."Variety 2 Value" := '';
                    ItemWorksheetVariantLine."Variety 3 Value" := '';
                    ItemWorksheetVariantLine."Variety 4 Value" := '';
                    ItemWorksheetVariantLine.Action := ItemWorksheetVariantLine.Action::Undefined;
                    ItemWorksheetVariantLine."Item No." := "Item No.";
                    ItemWorksheetVariantLine."Existing Item No." := "Existing Item No.";
                    ItemWorksheetVariantLine.Insert();
                end;

                if TempItemWorksheetVarietyValue2.FindFirst() then
                    repeat
                        if ("Variety 3 Table (New)" <> '') and IncludeHeaders then begin
                            //Insert Level 2 Header Line
                            LineNo := LineNo + 10000;
                            ItemWorksheetVariantLine.Init();
                            ItemWorksheetVariantLine."Worksheet Template Name" := Rec."Worksheet Template Name";
                            ItemWorksheetVariantLine."Worksheet Name" := Rec."Worksheet Name";
                            ItemWorksheetVariantLine."Worksheet Line No." := Rec."Line No.";
                            ItemWorksheetVariantLine."Line No." := LineNo;
                            ItemWorksheetVariantLine."Variety 1 Value" := TempItemWorksheetVarietyValue1.Value;
                            ItemWorksheetVariantLine."Variety 2 Value" := TempItemWorksheetVarietyValue2.Value;
                            ItemWorksheetVariantLine."Variety 3 Value" := '';
                            ItemWorksheetVariantLine."Variety 4 Value" := '';
                            ItemWorksheetVariantLine.Action := ItemWorksheetVariantLine.Action::Undefined;
                            ItemWorksheetVariantLine."Existing Item No." := "Existing Item No.";
                            ItemWorksheetVariantLine.Insert();
                        end;
                        if TempItemWorksheetVarietyValue3.FindFirst() then
                            repeat
                                if ("Variety 4 Table (New)" <> '') and IncludeHeaders then begin
                                    //Insert Level 3 Header Line
                                    LineNo := LineNo + 10000;
                                    ItemWorksheetVariantLine.Init();
                                    ItemWorksheetVariantLine."Worksheet Template Name" := Rec."Worksheet Template Name";
                                    ItemWorksheetVariantLine."Worksheet Name" := Rec."Worksheet Name";
                                    ItemWorksheetVariantLine."Worksheet Line No." := Rec."Line No.";
                                    ItemWorksheetVariantLine."Line No." := LineNo;
                                    ItemWorksheetVariantLine."Variety 1 Value" := TempItemWorksheetVarietyValue1.Value;
                                    ItemWorksheetVariantLine."Variety 2 Value" := TempItemWorksheetVarietyValue2.Value;
                                    ItemWorksheetVariantLine."Variety 3 Value" := TempItemWorksheetVarietyValue3.Value;
                                    ItemWorksheetVariantLine."Variety 4 Value" := '';
                                    ItemWorksheetVariantLine."Item No." := "Item No.";
                                    ItemWorksheetVariantLine.Action := ItemWorksheetVariantLine.Action::Undefined;
                                    ItemWorksheetVariantLine."Item No." := "Item No.";
                                    ItemWorksheetVariantLine."Existing Item No." := "Existing Item No.";
                                    ItemWorksheetVariantLine.Insert();
                                end;

                                if TempItemWorksheetVarietyValue4.FindFirst() then
                                    repeat
                                        if (((TempItemWorksheetVarietyValue4.Value <> '') or ("Variety 4 Table (Base)" = '')) and
                                            ((TempItemWorksheetVarietyValue3.Value <> '') or ("Variety 3 Table (Base)" = '')) and
                                            ((TempItemWorksheetVarietyValue2.Value <> '') or ("Variety 2 Table (Base)" = '')))
                                          then begin
                                            UpdateLineNo := true;
                                            if (LinesType <> LinesType::None) then begin
                                                ItemWorksheetVariantLine.Init();
                                                ItemWorksheetVariantLine."Worksheet Template Name" := Rec."Worksheet Template Name";
                                                ItemWorksheetVariantLine."Worksheet Name" := Rec."Worksheet Name";
                                                ItemWorksheetVariantLine."Worksheet Line No." := Rec."Line No.";
                                                ItemWorksheetVariantLine."Variety 1 Value" := TempItemWorksheetVarietyValue1.Value;
                                                ItemWorksheetVariantLine."Variety 2 Value" := TempItemWorksheetVarietyValue2.Value;
                                                ItemWorksheetVariantLine."Variety 3 Value" := TempItemWorksheetVarietyValue3.Value;
                                                ItemWorksheetVariantLine."Variety 4 Value" := TempItemWorksheetVarietyValue4.Value;
                                                ItemWorksheetVariantLine."Item No." := Rec."Item No.";
                                                ItemWorksheetVariantLine."Existing Item No." := Rec."Existing Item No.";

                                                ExistingVariantCode := ItemWorksheetVariantLine.GetExistingVariantCode;
                                                if ExistingVariantCode <> '' then
                                                    ItemWorksheetVariantLine.Validate("Existing Variant Code", ExistingVariantCode);

                                                if ((LinesType = LinesType::All) or
                                                    ((LinesType = LinesType::"Varieties Without Variants") and (ExistingVariantCode = '')) or
                                                    ((LinesType = LinesType::Variants) and (ExistingVariantCode <> ''))) then begin
                                                    LineNo := LineNo + 10000;
                                                    ItemWorksheetVariantLine."Line No." := LineNo;
                                                    case Action of
                                                        Action::Skip:
                                                            ItemWorksheetVariantLine.Action := ItemWorksheetVariantLine.Action::Skip;
                                                        Action::CreateNew:
                                                            if ItemWorksheetVariantLine."Existing Variant Code" <> '' then
                                                                ItemWorksheetVariantLine.Action := ItemWorksheetVariantLine.Action::Update
                                                            else
                                                                ItemWorksheetVariantLine.Action := ItemWorksheetVariantLine.Action::CreateNew;
                                                        Action::UpdateOnly:
                                                            if ItemWorksheetVariantLine."Existing Variant Code" <> '' then
                                                                ItemWorksheetVariantLine.Action := ItemWorksheetVariantLine.Action::Update
                                                            else
                                                                ItemWorksheetVariantLine.Action := ItemWorksheetVariantLine.Action::Skip;
                                                        Action::UpdateAndCreateVariants:
                                                            if ItemWorksheetVariantLine."Existing Variant Code" <> '' then
                                                                ItemWorksheetVariantLine.Action := ItemWorksheetVariantLine.Action::Update
                                                            else
                                                                ItemWorksheetVariantLine.Action := ItemWorksheetVariantLine.Action::CreateNew;
                                                    end;
                                                    ItemWorksheetVariantLine.FillDescription();
                                                    ItemWorksheetVariantLine.Insert(true);
                                                end;
                                            end;
                                        end;
                                    until TempItemWorksheetVarietyValue4.Next() = 0;
                            until TempItemWorksheetVarietyValue3.Next() = 0;
                    until TempItemWorksheetVarietyValue2.Next() = 0;
            until TempItemWorksheetVarietyValue1.Next() = 0;

        //Look for and update level numbering on existing line
        ItemWorksheetVariantLine.Reset();
        ItemWorksheetVariantLine.SetCurrentKey("Worksheet Template Name", "Worksheet Name", "Worksheet Line No.", "Variety 1 Value", "Variety 2 Value", "Variety 3 Value", "Variety 4 Value");
        ItemWorksheetVariantLine.SetRange("Worksheet Template Name", "Worksheet Template Name");
        ItemWorksheetVariantLine.SetRange("Worksheet Name", "Worksheet Name");
        ItemWorksheetVariantLine.SetRange("Worksheet Line No.", "Line No.");
        if ItemWorksheetVariantLine.FindSet() then
            repeat
                NewLevel := ItemWorksheetVariantLine.CalcLevel();
                if NewLevel <> ItemWorksheetVariantLine.Level then begin
                    ItemWorksheetVariantLine.Level := NewLevel;
                    ItemWorksheetVariantLine.Modify();
                end;
            until ItemWorksheetVariantLine.Next() = 0;
    end;

    local procedure CopyItemAttributes(ItemNo: Code[20])
    var
        AttributeID: Record "NPR Attribute ID";
        AttributeKey: Record "NPR Attribute Key";
        AttributeValueSet: Record "NPR Attribute Value Set";
        AttributeManagement: Codeunit "NPR Attribute Management";
        WorksheetReference: Integer;
    begin
        AttributeKey.SetCurrentKey("Table ID", "MDR Code PK");
        AttributeKey.SetFilter("Table ID", '=%1', DATABASE::Item);
        AttributeKey.SetFilter("MDR Code PK", '=%1', ItemNo);

        // Fill array
        if (AttributeKey.FindFirst()) then begin
            AttributeValueSet.Reset();
            AttributeValueSet.SetRange("Attribute Set ID", AttributeKey."Attribute Set ID");
            if AttributeValueSet.FindSet() then
                repeat
                    AttributeID.Reset();
                    AttributeID.SetRange("Attribute Code", AttributeValueSet."Attribute Code");
                    AttributeID.SetRange("Table ID", DATABASE::Item);
                    if AttributeID.FindFirst() then begin
                        AttributeID."Table ID" := DATABASE::"NPR Item Worksheet Line";
                        if AttributeID.Insert() then;
                    end;
                    AttributeManagement.SetWorksheetLineAttributeValue(DATABASE::"NPR Item Worksheet Line", AttributeID."Shortcut Attribute ID",
                        "Worksheet Template Name", "Worksheet Name", "Line No.", AttributeValueSet."Text Value");

                until AttributeValueSet.Next() = 0;
        end;
    end;

    local procedure InitItemWorksheetVarietyValue(var ItemWorksheetVarietyValue: Record "NPR Item Worksh. Variety Value"; LineType: Code[20]; LineTable: Code[20])
    begin
        with ItemWorksheetVarietyValue do begin
            SetCurrentKey("Worksheet Template Name", "Worksheet Name", "Worksheet Line No.", Type, Table, "Sort Order");
            SetRange("Worksheet Template Name", Rec."Worksheet Template Name");
            SetRange("Worksheet Name", Rec."Worksheet Name");
            SetRange("Worksheet Line No.", Rec."Line No.");
            SetRange(Type, LineType);
            SetRange(Table, LineTable);
            if IsEmpty then begin
                Init();
                "Worksheet Template Name" := Rec."Worksheet Template Name";
                "Worksheet Name" := Rec."Worksheet Name";
                "Worksheet Line No." := Rec."Line No.";
                Type := LineType;
                Table := LineTable;
                Value := '';
                Insert();
            end;
        end;
    end;

    local procedure VariantExists(ItemWorksheetVariantLine: Record "NPR Item Worksh. Variant Line"): Boolean
    var
        ItemWorksheetVariantLine2: Record "NPR Item Worksh. Variant Line";
    begin
        ItemWorksheetVariantLine2.Reset();
        ItemWorksheetVariantLine2.SetRange("Worksheet Template Name", ItemWorksheetVariantLine."Worksheet Template Name");
        ItemWorksheetVariantLine2.SetRange("Worksheet Name", ItemWorksheetVariantLine."Worksheet Name");
        ItemWorksheetVariantLine2.SetRange("Worksheet Line No.", ItemWorksheetVariantLine."Worksheet Line No.");
        ItemWorksheetVariantLine2.SetRange("Variety 1 Value", ItemWorksheetVariantLine."Variety 1 Value");
        ItemWorksheetVariantLine2.SetRange("Variety 2 Value", ItemWorksheetVariantLine."Variety 2 Value");
        ItemWorksheetVariantLine2.SetRange("Variety 3 Value", ItemWorksheetVariantLine."Variety 3 Value");
        ItemWorksheetVariantLine2.SetRange("Variety 4 Value", ItemWorksheetVariantLine."Variety 4 Value");
        exit(ItemWorksheetVariantLine2.FindFirst());
    end;

    procedure UpdateVarietyHeadingText()
    var
        ItemWorksheetVariantLine: Record "NPR Item Worksh. Variant Line";
        CreateCounter: array[4] of Integer;
        LineCounter: array[4] of Integer;
        UpdateCounter: array[4] of Integer;
        NewHeadingText: Text;
    begin
        Clear(LineCounter);
        Clear(CreateCounter);
        Clear(UpdateCounter);
        ItemWorksheetVariantLine.Reset();
        ItemWorksheetVariantLine.SetRange("Worksheet Template Name", "Worksheet Template Name");
        ItemWorksheetVariantLine.SetRange("Worksheet Name", "Worksheet Name");
        ItemWorksheetVariantLine.SetRange("Worksheet Line No.", "Line No.");
        ItemWorksheetVariantLine.SetCurrentKey("Worksheet Template Name", "Worksheet Name", "Worksheet Line No.", "Variety 1 Value", "Variety 2 Value", "Variety 3 Value", "Variety 4 Value");
        if ItemWorksheetVariantLine.FindLast() then
            repeat
                if ItemWorksheetVariantLine."Variety 4 Value" <> '' then begin
                    LineCounter[4] += 1;
                    LineCounter[3] += 1;
                    LineCounter[2] += 1;
                    LineCounter[1] += 1;
                    case ItemWorksheetVariantLine.Action of
                        ItemWorksheetVariantLine.Action::CreateNew:
                            begin
                                CreateCounter[4] += 1;
                                CreateCounter[3] += 1;
                                CreateCounter[2] += 1;
                                CreateCounter[1] += 1;
                            end;
                        ItemWorksheetVariantLine.Action::Update:
                            begin
                                UpdateCounter[4] += 1;
                                UpdateCounter[3] += 1;
                                UpdateCounter[2] += 1;
                                UpdateCounter[1] += 1;
                            end;
                    end;
                end else begin
                    if ItemWorksheetVariantLine."Variety 3 Value" <> '' then begin
                        if LineCounter[4] = 0 then begin
                            //Variety 3 is a lowest level line
                            if ItemWorksheetVariantLine.Action <> ItemWorksheetVariantLine.Action::Undefined then begin
                                LineCounter[3] += 1;
                                LineCounter[2] += 1;
                                LineCounter[1] += 1;
                                case ItemWorksheetVariantLine.Action of
                                    ItemWorksheetVariantLine.Action::CreateNew:
                                        begin
                                            CreateCounter[3] += 1;
                                            CreateCounter[2] += 1;
                                            CreateCounter[1] += 1;
                                        end;
                                    ItemWorksheetVariantLine.Action::Update:
                                        begin
                                            UpdateCounter[3] += 1;
                                            UpdateCounter[2] += 1;
                                            UpdateCounter[1] += 1;
                                        end;
                                end;
                            end;
                        end else begin
                            //Variety 3 is a header line
                            NewHeadingText := MakeLineHeadingText(LineCounter[4], CreateCounter[4], UpdateCounter[4]);
                            if NewHeadingText <> ItemWorksheetVariantLine."Heading Text" then begin
                                ItemWorksheetVariantLine."Heading Text" := NewHeadingText;
                                ItemWorksheetVariantLine.Modify();
                            end;
                            LineCounter[4] := 0;
                            CreateCounter[4] := 0;
                            UpdateCounter[4] := 0;
                        end;
                    end else begin
                        if ItemWorksheetVariantLine."Variety 2 Value" <> '' then begin
                            if LineCounter[3] = 0 then begin
                                //Variety 2 is a lowest level line
                                if ItemWorksheetVariantLine.Action <> ItemWorksheetVariantLine.Action::Undefined then begin
                                    LineCounter[2] += 1;
                                    LineCounter[1] += 1;
                                    case ItemWorksheetVariantLine.Action of
                                        ItemWorksheetVariantLine.Action::CreateNew:
                                            begin
                                                CreateCounter[2] += 1;
                                                CreateCounter[1] += 1;
                                            end;
                                        ItemWorksheetVariantLine.Action::Update:
                                            begin
                                                UpdateCounter[2] += 1;
                                                UpdateCounter[1] += 1;
                                            end;
                                    end;
                                end;
                            end else begin
                                //Variety 2 is a header line
                                NewHeadingText := MakeLineHeadingText(LineCounter[3], CreateCounter[3], UpdateCounter[3]);
                                if NewHeadingText <> ItemWorksheetVariantLine."Heading Text" then begin
                                    ItemWorksheetVariantLine."Heading Text" := NewHeadingText;
                                    ItemWorksheetVariantLine.Modify();
                                end;
                                LineCounter[3] := 0;
                                CreateCounter[3] := 0;
                                UpdateCounter[3] := 0;
                                LineCounter[4] := 0;
                                CreateCounter[4] := 0;
                                UpdateCounter[4] := 0;
                            end;
                        end else begin
                            if LineCounter[2] = 0 then begin
                                //Variety 1 is a lowest level line
                                if ItemWorksheetVariantLine.Action <> ItemWorksheetVariantLine.Action::Undefined then begin
                                    LineCounter[1] += 1;
                                    case ItemWorksheetVariantLine.Action of
                                        ItemWorksheetVariantLine.Action::CreateNew:
                                            CreateCounter[1] += 1;
                                        ItemWorksheetVariantLine.Action::Update:
                                            UpdateCounter[1] += 1;
                                    end;
                                end;
                            end else begin
                                //Variety 1 is a header line
                                NewHeadingText := MakeLineHeadingText(LineCounter[2], CreateCounter[2], UpdateCounter[2]);
                                if NewHeadingText <> ItemWorksheetVariantLine."Heading Text" then begin
                                    ItemWorksheetVariantLine."Heading Text" := NewHeadingText;
                                    ItemWorksheetVariantLine.Modify();
                                end;
                                LineCounter[2] := 0;
                                CreateCounter[2] := 0;
                                UpdateCounter[2] := 0;
                                LineCounter[3] := 0;
                                CreateCounter[3] := 0;
                                UpdateCounter[3] := 0;
                                LineCounter[4] := 0;
                                CreateCounter[4] := 0;
                                UpdateCounter[4] := 0;
                            end;
                        end;
                    end;
                end;
            until ItemWorksheetVariantLine.Next(-1) = 0;
        //Delete unwanted headers
        ItemWorksheetVariantLine.Reset();
        ItemWorksheetVariantLine.SetRange("Worksheet Template Name", "Worksheet Template Name");
        ItemWorksheetVariantLine.SetRange("Worksheet Name", "Worksheet Name");
        ItemWorksheetVariantLine.SetRange("Worksheet Line No.", "Line No.");
        ItemWorksheetVariantLine.SetRange(Action, ItemWorksheetVariantLine.Action::Undefined);
        ItemWorksheetVariantLine.SetFilter("Heading Text", '%1', '');
        ItemWorksheetVariantLine.DeleteAll(true);
    end;

    procedure UpdateVarietyLines()
    var
        ItemWorksheetVariantLine: Record "NPR Item Worksh. Variant Line";
    begin
        ItemWorksheetVariantLine.Reset();
        ItemWorksheetVariantLine.SetRange("Worksheet Template Name", "Worksheet Template Name");
        ItemWorksheetVariantLine.SetRange("Worksheet Name", "Worksheet Name");
        ItemWorksheetVariantLine.SetRange("Worksheet Line No.", "Line No.");
        if ItemWorksheetVariantLine.FindSet() then
            repeat
                ItemWorksheetVariantLine.Validate("Item No.", "Item No.");
                ItemWorksheetVariantLine.Validate("Existing Item No.", "Existing Item No.");
                ItemWorksheetVariantLine.Modify();
            until ItemWorksheetVariantLine.Next() = 0;
    end;

    local procedure MakeLineHeadingText(Varieties: Integer; CreateNew: Integer; UpdateExisting: Integer): Text[50]
    var
        VarsCreateUpdateLbl: Label '%1 varieties (%2 to be created, %3 to be updated)', Comment = '%1 = Varieties';
        VarsCreatesLbl: Label '%1 varieties (%2 variants to be created)', Comment = '%1 = Varieties; %2 = Number of variants to be created';
        VarsUpdatesLbl: Label '%1 varieties (%2 variants to be updated)', Comment = '%1 = Varieties; %2 = Number of variants to be updated';
        VarsCreateLbl: Label '%1 varieties (%2 variant to be created)', Comment = '%1 = Varieties; %2 = Number of variants to be created';
        VarsUpdateLbl: Label '%1 varieties (%2 variant to be updated)', Comment = '%1 = Varieties; %2 = Number of variant to be updated';
        VarsLbl: Label '%1 varieties (no actions to be taken)', Comment = '%1 = Varieties';
        VarUpdateLbl: Label '%1 variety (%2 variant to be updated)', Comment = '%1 = Variety; %2 = Number of variant to be updated';
        VarCreateLbl: Label '%1 variety (%2 variant to be created)', Comment = '%1 = Variety; %2 = Number of variant to be created';
        VarLbl: Label '%1 variety (no action to be taken)', Comment = '%1 = Variety';
    begin
        if (CreateNew = 0) and (UpdateExisting = 0) then
            if Varieties = 1 then
                exit(CopyStr(StrSubstNo(VarLbl, Varieties), 1, 50))
            else
                exit(CopyStr(StrSubstNo(VarsLbl, Varieties), 1, 50));
        if (CreateNew = 0) then
            if Varieties = 1 then
                exit(CopyStr(StrSubstNo(VarUpdateLbl, Varieties, UpdateExisting), 1, 50))
            else
                if UpdateExisting = 1 then
                    exit(CopyStr(StrSubstNo(VarsUpdateLbl, Varieties, UpdateExisting), 1, 50))
                else
                    exit(CopyStr(StrSubstNo(VarsUpdatesLbl, Varieties, UpdateExisting), 1, 50));
        if (UpdateExisting = 0) then
            if Varieties = 1 then
                exit(StrSubstNo(VarCreateLbl, Varieties, CreateNew))
            else
                if CreateNew = 1 then
                    exit(StrSubstNo(VarsCreateLbl, Varieties, CreateNew))
                else
                    exit(StrSubstNo(VarsCreatesLbl, Varieties, CreateNew));
        exit(CopyStr(StrSubstNo(VarsCreateUpdateLbl, Varieties, CreateNew, UpdateExisting), 1, 50));
    end;

    procedure IsCopyVariety(VrtValue: Integer): Boolean
    begin
        case VrtValue of
            1:
                exit("Create Copy of Variety 1 Table");
            2:
                exit("Create Copy of Variety 2 Table");
            3:
                exit("Create Copy of Variety 3 Table");
            4:
                exit("Create Copy of Variety 4 Table");
        end;
        exit(false);
    end;

    procedure IsLockedVariety(VrtValue: Integer): Boolean
    var
        VarietyTable: Record "NPR Variety Table";
    begin
        VarietyTable.Init();
        case VrtValue of
            1:
                VarietyTable.Get("Variety 1", "Variety 1 Table (New)");
            2:
                VarietyTable.Get("Variety 2", "Variety 2 Table (New)");
            3:
                VarietyTable.Get("Variety 3", "Variety 3 Table (New)");
            4:
                VarietyTable.Get("Variety 4", "Variety 4 Table (New)");
        end;
        exit(VarietyTable."Lock Table");
    end;

    procedure IsAddedVarietyValue(VrtValue: Integer): Boolean
    var
        WorksheetVarietyValue: Record "NPR Item Worksh. Variety Value";
        VarietyTable: Record "NPR Variety Table";
        VarietyValue: Record "NPR Variety Value";
    begin
        VarietyTable.Init();
        case VrtValue of
            1:
                VarietyTable.Get("Variety 1", "Variety 1 Table (New)");
            2:
                VarietyTable.Get("Variety 2", "Variety 2 Table (New)");
            3:
                VarietyTable.Get("Variety 3", "Variety 3 Table (New)");
            4:
                VarietyTable.Get("Variety 4", "Variety 4 Table (New)");
        end;
        WorksheetVarietyValue.SetRange("Worksheet Template Name", "Worksheet Template Name");
        WorksheetVarietyValue.SetRange("Worksheet Name", "Worksheet Name");
        WorksheetVarietyValue.SetRange("Worksheet Line No.", "Line No.");
        WorksheetVarietyValue.SetRange(Type, VarietyTable.Type);
        WorksheetVarietyValue.SetRange(Table, VarietyTable.Code);
        if WorksheetVarietyValue.FindSet() then
            repeat
                if not VarietyValue.Get(WorksheetVarietyValue.Type, WorksheetVarietyValue.Table, WorksheetVarietyValue.Value) then
                    exit(true);
            until WorksheetVarietyValue.Next() = 0;
        exit(false);
    end;

    local procedure UpdateAddedVarietyValues()
    var
        ItemWorksheetVar: Record "NPR Item Worksh. Variant Line";
        ItemWorksheetVarValue: Record "NPR Item Worksh. Variety Value";
        VarietyValue: Record "NPR Variety Value";
    begin
        ItemWorksheetVar.SetRange("Worksheet Template Name", "Worksheet Template Name");
        ItemWorksheetVar.SetRange("Worksheet Name", "Worksheet Name");
        ItemWorksheetVar.SetRange("Worksheet Line No.", "Line No.");
        if ItemWorksheetVar.FindSet() then
            repeat
                if ItemWorksheetVar."Heading Text" = '' then begin
                    if ItemWorksheetVar."Variety 1 Value" <> '' then begin
                        if not ItemWorksheetVarValue.Get("Worksheet Template Name", "Worksheet Name", "Line No.", "Variety 1", "Variety 1 Table (Base)", ItemWorksheetVar."Variety 1 Value") then begin
                            //Insert in the new value in Worksheet Value table
                            ItemWorksheetVarValue.Init();
                            ItemWorksheetVarValue.Validate("Worksheet Template Name", "Worksheet Template Name");
                            ItemWorksheetVarValue.Validate("Worksheet Name", "Worksheet Name");
                            ItemWorksheetVarValue.Validate("Worksheet Line No.", "Line No.");
                            ItemWorksheetVarValue.Validate(Type, "Variety 1");
                            ItemWorksheetVarValue.Validate(Table, "Variety 1 Table (Base)");
                            ItemWorksheetVarValue.Validate(Value, ItemWorksheetVar."Variety 1 Value");
                            ItemWorksheetVarValue.Insert(true);
                            if not VarietyValue.Get("Variety 1", "Variety 1 Table (Base)", ItemWorksheetVar."Variety 1 Value") and
                                (StrLen("Status Comment") < 247) then begin
                                if "Status Comment" <> '' then
                                    "Status Comment" := "Status Comment" + ' - ';
                                if IsCopyVariety(1) then
                                    "Status Comment" := CopyStr("Status Comment" + StrSubstNo(VarietyValueAddedToCopyLbl, "Variety 1", ItemWorksheetVar."Variety 1 Value"), 1, MaxStrLen("Status Comment"))
                                else
                                    "Status Comment" := CopyStr("Status Comment" + StrSubstNo(VarietyValueAddedToUnlockedTableLbl, "Variety 1", ItemWorksheetVar."Variety 1 Value"), 1, MaxStrLen("Status Comment"));
                            end;
                        end;
                    end;
                end;
            until ItemWorksheetVar.Next() = 0;
    end;

    local procedure HasVarietyLines(): Boolean
    var
        ItemWorksheetVar: Record "NPR Item Worksh. Variant Line";
    begin
        ItemWorksheetVar.SetRange("Worksheet Template Name", "Worksheet Template Name");
        ItemWorksheetVar.SetRange("Worksheet Name", "Worksheet Name");
        ItemWorksheetVar.SetRange("Worksheet Line No.", "Line No.");
        exit(ItemWorksheetVar.FindFirst());
    end;

    procedure EmptyLine(): Boolean
    begin
        exit("Worksheet Name" = '');
    end;

    procedure UpdateBarcode()
    begin
        ItemWorksheetTemplate.Get("Worksheet Template Name");
        if ("Internal Bar Code" <> '') and ("Variety 1" = '') then
            case ItemWorksheetTemplate."Create Internal Barcodes" of
                ItemWorksheetTemplate."Create Internal Barcodes"::"As Alt. No.":
                    ItemNumberManagement.UpdateBarcode("Item No.", "Variant Code", "Internal Bar Code", 0);
                ItemWorksheetTemplate."Create Internal Barcodes"::"As Cross Reference":
                    ItemNumberManagement.UpdateBarcode("Item No.", "Variant Code", "Internal Bar Code", 1);
            end;
        if ("Vendors Bar Code" <> '') and ("Variety 1" = '') then
            case ItemWorksheetTemplate."Create Vendor  Barcodes" of
                ItemWorksheetTemplate."Create Vendor  Barcodes"::"As Alt. No.":
                    ItemNumberManagement.UpdateBarcode("Item No.", "Variant Code", "Vendors Bar Code", 0);
                ItemWorksheetTemplate."Create Vendor  Barcodes"::"As Cross Reference":
                    ItemNumberManagement.UpdateBarcode("Item No.", "Variant Code", "Vendors Bar Code", 1);
            end;
    end;

    local procedure FillVarietyTableNew()
    begin
        if "Variety 1 Table (New)" = '' then
            "Variety 1 Table (New)" := "Variety 1 Table (Base)";
        if "Variety 2 Table (New)" = '' then
            "Variety 2 Table (New)" := "Variety 2 Table (Base)";
        if "Variety 3 Table (New)" = '' then
            "Variety 3 Table (New)" := "Variety 3 Table (Base)";
        if "Variety 4 Table (New)" = '' then
            "Variety 4 Table (New)" := "Variety 4 Table (Base)";
    end;

    local procedure DeleteRelatedLines()
    var
        NPRAttributeKey: Record "NPR Attribute Key";
        ItemWorksheetFieldChange: Record "NPR Item Worksh. Field Change";
        ItemWorksheetVar: Record "NPR Item Worksh. Variant Line";
        ItemWorksheetVrtValue: Record "NPR Item Worksh. Variety Value";
    begin
        ItemWorksheetVar.SetRange("Worksheet Template Name", "Worksheet Template Name");
        ItemWorksheetVar.SetRange("Worksheet Name", "Worksheet Name");
        ItemWorksheetVar.SetRange("Worksheet Line No.", "Line No.");
        ItemWorksheetVar.DeleteAll();

        ItemWorksheetVrtValue.SetRange("Worksheet Template Name", "Worksheet Template Name");
        ItemWorksheetVrtValue.SetRange("Worksheet Name", "Worksheet Name");
        ItemWorksheetVrtValue.SetRange("Worksheet Line No.", "Line No.");
        ItemWorksheetVrtValue.DeleteAll();

        NPRAttributeKey.SetCurrentKey("Table ID", "MDR Code PK", "MDR Line PK", "MDR Option PK");
        NPRAttributeKey.SetRange("Table ID", DATABASE::"NPR Item Worksheet Line");
        NPRAttributeKey.SetRange("MDR Code PK", "Worksheet Template Name");
        NPRAttributeKey.SetRange("MDR Code 2 PK", "Worksheet Name");
        NPRAttributeKey.SetRange("MDR Line PK", "Line No.");
        NPRAttributeKey.DeleteAll();

        ItemWorksheetFieldChange.SetRange("Worksheet Template Name", "Worksheet Template Name");
        ItemWorksheetFieldChange.SetRange("Worksheet Name", "Worksheet Name");
        ItemWorksheetFieldChange.SetRange("Worksheet Line No.", "Line No.");
        ItemWorksheetFieldChange.DeleteAll();
    end;

    local procedure SetUseVariant()
    begin
        if ("Variety 1" <> '') or
           ("Variety 2" <> '') or
           ("Variety 3" <> '') or
           ("Variety 4" <> '') then
            "Use Variant" := true;
    end;

    procedure UpdateSalesPriceWithRRP()
    var
        ItemWorksheetVar: Record "NPR Item Worksh. Variant Line";
    begin
        if "Recommended Retail Price" <> 0 then begin
            Validate("Sales Price", "Recommended Retail Price");
        end;
        ItemWorksheetVar.SetRange("Worksheet Template Name", "Worksheet Template Name");
        ItemWorksheetVar.SetRange("Worksheet Name", "Worksheet Name");
        ItemWorksheetVar.SetRange("Worksheet Line No.", "Line No.");
        if ItemWorksheetVar.FindFirst() then
            repeat
                if ItemWorksheetVar."Recommended Retail Price" <> 0 then begin
                    if "Recommended Retail Price" = ItemWorksheetVar."Recommended Retail Price" then begin
                        if ItemWorksheetVar."Sales Price" <> 0 then begin
                            ItemWorksheetVar."Sales Price" := 0;
                            ItemWorksheetVar.Modify();
                        end;
                    end else begin
                        ItemWorksheetVar."Sales Price" := ItemWorksheetVar."Recommended Retail Price";
                        ItemWorksheetVar.Modify();
                    end;
                end else
                    if ItemWorksheetVar."Sales Price" <> 0 then begin
                        ItemWorksheetVar."Sales Price" := 0;
                        ItemWorksheetVar.Modify();
                    end;
            until ItemWorksheetVar.Next() = 0;
    end;

    local procedure ItemNoPrefix(): Code[4]
    var
        Separator: Code[10];
    begin
        ItemWorksheetTemplate.Get("Worksheet Template Name");
        case ItemWorksheetTemplate."Item No. Prefix" of
            ItemWorksheetTemplate."Item No. Prefix"::None:
                exit('');
            ItemWorksheetTemplate."Item No. Prefix"::"From Template":
                begin
                    if ItemWorksheetTemplate."Prefix Code" = '' then
                        exit('');
                    exit(ItemWorksheetTemplate."Prefix Code" + Separator);
                end;
            ItemWorksheetTemplate."Item No. Prefix"::"From Worksheet":
                begin
                    ItemWorksheet.Get("Worksheet Template Name", "Worksheet Name");
                    if ItemWorksheet."Prefix Code" = '' then
                        exit('');
                    exit(ItemWorksheet."Prefix Code" + Separator);
                end;
            ItemWorksheetTemplate."Item No. Prefix"::"Vendor No.":
                begin
                    if "Vendor No." <> '' then
                        exit(CopyStr("Vendor No.", 1, 3) + Separator);
                    ItemWorksheet.Get("Worksheet Template Name", "Worksheet Name");
                    if ItemWorksheet."Vendor No." <> '' then
                        exit(CopyStr(ItemWorksheet."Vendor No.", 1, 3) + Separator);
                end;
        end;
    end;

    procedure DeleteDuplicate()
    var
        DuplicateItemWorksheetLine: Record "NPR Item Worksheet Line";
    begin
        if not ItemWorksheetTemplate.Get("Worksheet Template Name") then
            exit;
        if not ItemWorksheetTemplate."Delete Unvalidated Duplicates" then
            exit;
        DuplicateItemWorksheetLine.Reset();
        DuplicateItemWorksheetLine.SetRange("Worksheet Template Name", "Worksheet Template Name");
        DuplicateItemWorksheetLine.SetRange("Worksheet Name", "Worksheet Name");
        DuplicateItemWorksheetLine.SetFilter("Line No.", '<>%1', "Line No.");
        if "Item No." <> '' then begin
            DuplicateItemWorksheetLine.SetFilter("Item No.", "Item No.");
            if DuplicateItemWorksheetLine.FindLast() then
                if OldLineContainsSameVarieties(DuplicateItemWorksheetLine) then
                    DuplicateItemWorksheetLine.Delete(true);
            exit;
        end;
        if "Existing Item No." <> '' then begin
            DuplicateItemWorksheetLine.SetFilter("Existing Item No.", "Existing Item No.");
            if DuplicateItemWorksheetLine.FindLast() then
                if OldLineContainsSameVarieties(DuplicateItemWorksheetLine) then
                    DuplicateItemWorksheetLine.Delete(true);
            exit;
        end;
        if "Vendor Item No." <> '' then begin
            DuplicateItemWorksheetLine.SetFilter("Vendor Item No.", "Vendor Item No.");
            if DuplicateItemWorksheetLine.FindLast() then
                if OldLineContainsSameVarieties(DuplicateItemWorksheetLine) then
                    DuplicateItemWorksheetLine.Delete(true);
            exit;
        end;
        if "Vendors Bar Code" <> '' then begin
            DuplicateItemWorksheetLine.SetFilter("Vendors Bar Code", "Vendors Bar Code");
            if DuplicateItemWorksheetLine.FindLast() then
                if OldLineContainsSameVarieties(DuplicateItemWorksheetLine) then
                    DuplicateItemWorksheetLine.Delete(true);
            exit;
        end;
        if "Internal Bar Code" <> '' then begin
            DuplicateItemWorksheetLine.SetFilter("Internal Bar Code", "Internal Bar Code");
            if DuplicateItemWorksheetLine.FindLast() then
                if OldLineContainsSameVarieties(DuplicateItemWorksheetLine) then
                    DuplicateItemWorksheetLine.Delete(true);
            exit;
        end;
    end;

    local procedure FillMappedFields()
    var
        LocRecItem: Record Item;
        ItemWorksheetFieldSetup: Record "NPR Item Worksh. Field Setup";
        LocRecItemWorksheetLine: Record "NPR Item Worksheet Line";
    begin
        if "Existing Item No." = '' then
            exit;
        LocRecItem.Get("Existing Item No.");
        Modify();
        LocRecItemWorksheetLine := Rec;
        ValidateFields(LocRecItem, LocRecItemWorksheetLine);
        Rec := LocRecItemWorksheetLine;
    end;

    local procedure ValidateFields(var VarItem: Record Item; var VarItemWorksheetLine: Record "NPR Item Worksheet Line")
    var
        SourceFieldRec: Record "Field";
        TargetFieldRec: Record "Field";
        ItemWorksheetFieldChange: Record "NPR Item Worksh. Field Change";
        ItemWorksheetFieldSetup: Record "NPR Item Worksh. Field Setup";
        ItemRecRef: RecordRef;
        ItemWorksheetRecRef: RecordRef;
        ItemFldRef: FieldRef;
        ItemWorksheetFldRef: FieldRef;
        CountFields: Integer;
    begin
        VarItemWorksheetLine.Get("Worksheet Template Name", "Worksheet Name", "Line No.");
        ItemRecRef.Get(VarItem.RecordId);
        ItemWorksheetRecRef.Get(VarItemWorksheetLine.RecordId);
        CountFields := 0;
        ItemWorksheetFieldChange.Reset();
        ItemWorksheetFieldChange.SetRange("Worksheet Template Name", VarItemWorksheetLine."Worksheet Template Name");
        ItemWorksheetFieldChange.SetRange("Worksheet Name", VarItemWorksheetLine."Worksheet Name");
        ItemWorksheetFieldChange.SetRange("Worksheet Line No.", VarItemWorksheetLine."Line No.");
        ItemWorksheetFieldChange.DeleteAll();

        ItemWorksheetFieldSetup.Reset();
        ItemWorksheetFieldSetup.SetFilter("Worksheet Template Name", '=%1|=%2', VarItemWorksheetLine."Worksheet Template Name", '');
        ItemWorksheetFieldSetup.SetFilter("Worksheet Name", '=%1|=%2', VarItemWorksheetLine."Worksheet Name", '');
        ItemWorksheetFieldSetup.SetRange("Table No.", DATABASE::"NPR Item Worksheet Line");
        if ItemWorksheetFieldSetup.FindSet() then
            repeat
                //Find the setup on Template, Worksheet or General
                ItemWorksheetFieldSetup.SetRange("Field Number", ItemWorksheetFieldSetup."Field Number");
                ItemWorksheetFieldSetup.FindLast();
                ItemWorksheetFieldSetup.SetRange("Field Number");
                if (ItemWorksheetFieldSetup."Process Update" <> ItemWorksheetFieldSetup."Process Update"::Ignore) and
                   (ItemWorksheetFieldSetup."Process Update" <> ItemWorksheetFieldSetup."Process Update"::"Warn and Ignore") then begin

                    if TargetFieldRec.Get(ItemWorksheetFieldSetup."Table No.", ItemWorksheetFieldSetup."Field Number") then begin
                        ItemWorksheetFldRef := ItemWorksheetRecRef.Field(TargetFieldRec."No.");
                        SourceFieldRec.Init();
                        if not SourceFieldRec.Get(ItemWorksheetFieldSetup."Target Table No. Update", ItemWorksheetFieldSetup."Target Field Number Update") then
                            if not SourceFieldRec.Get(DATABASE::Item, ItemWorksheetFieldSetup."Target Field Number Update") then
                                SourceFieldRec.Init();
                        if SourceFieldRec."No." <> 0 then begin
                            ItemFldRef := ItemRecRef.Field(SourceFieldRec."No.");
                            ValidateFieldRef(ItemFldRef, ItemWorksheetFldRef, false);
                        end;
                    end;
                end;
            until ItemWorksheetFieldSetup.Next() = 0;
        ItemWorksheetRecRef.Modify();
        VarItemWorksheetLine.Get("Worksheet Template Name", "Worksheet Name", "Line No.");
    end;

    local procedure ValidateFieldRef(var SourceFldRef: FieldRef; var TargetFldRef: FieldRef; DoValidate: Boolean): Boolean
    var
        SourceFieldRec: Record "Field";
        TargetFieldRec: Record "Field";
        TmpDateFormula: DateFormula;
        SourceRecRef: RecordRef;
        TargetRecRef: RecordRef;
        TmpBool: Boolean;
        TmpDate: Date;
        TmpDateTime: DateTime;
        TmpDecimal: Decimal;
        TmpInteger: Integer;
        TmpTime: Time;
    begin
        if DoValidate then begin
            case UpperCase(Format(TargetFldRef.Type)) of
                'TEXT', 'CODE':
                    TargetFldRef.Validate(Format(SourceFldRef.Value));
                'INTEGER':
                    if Evaluate(TmpInteger, Format(SourceFldRef.Value)) then begin
                        TargetFldRef.Validate(TmpInteger);
                    end else
                        exit(false);
                'OPTION':
                    if UpperCase(Format(SourceFldRef.Type)) = 'BOOLEAN' then begin
                        if Evaluate(TmpBool, Format(SourceFldRef.Value, 0, 2)) then
                            TargetFldRef.Validate(TmpBool)
                        else
                            exit(false);
                    end else begin
                        if Evaluate(TmpInteger, Format(SourceFldRef.Value)) then begin
                            if TmpInteger <> 9 then
                                TargetFldRef.Validate(TmpInteger);
                        end else
                            exit(false);
                    end;
                'DECIMAL':
                    if Evaluate(TmpDecimal, Format(SourceFldRef.Value)) then begin
                        TargetFldRef.Validate(TmpDecimal);
                    end else
                        exit(false);
                'DATE':
                    if Evaluate(TmpDate, Format(SourceFldRef.Value)) then begin
                        TargetFldRef.Validate(TmpDate);
                    end else
                        exit(false);
                'TIME':
                    if Evaluate(TmpTime, Format(SourceFldRef.Value)) then begin
                        TargetFldRef.Validate(TmpTime);
                    end else
                        exit(false);
                'DATETIME':
                    if Evaluate(TmpDateTime, Format(SourceFldRef.Value)) then begin
                        TargetFldRef.Validate(TmpDateTime);
                    end else
                        exit(false);
                'BOOLEAN':
                    if Evaluate(TmpInteger, Format(SourceFldRef.Value)) then begin
                        case TmpInteger of
                            0:
                                begin
                                    TmpBool := false;
                                    TargetFldRef.Validate(TmpBool);
                                end;
                            1:
                                begin
                                    TmpBool := true;
                                    TargetFldRef.Validate(TmpBool);
                                end;
                        end;
                    end else begin
                        if Evaluate(TmpBool, Format(SourceFldRef.Value)) then
                            TargetFldRef.Validate(TmpBool);
                    end;
                'DATEFORMULA':
                    if Evaluate(TmpDateFormula, Format(SourceFldRef.Value)) then begin
                        TargetFldRef.Validate(TmpDateFormula);
                    end else
                        exit(false);
            end;
        end else begin
            SourceRecRef := SourceFldRef.Record;
            TargetRecRef := TargetFldRef.Record;
            if SourceFieldRec.Get(SourceRecRef.Number, SourceFldRef.Number) and TargetFieldRec.Get(TargetRecRef.Number, TargetFldRef.Number) then begin
                if SourceFieldRec.Type = TargetFieldRec.Type then begin
                    TargetFldRef.Value(SourceFldRef.Value);
                    if UpperCase(Format(SourceFldRef.Type)) = 'BOOLEAN' then begin
                        if Evaluate(TmpInteger, Format(SourceFldRef.Value, 0, 2)) then
                            TargetFldRef.Value(TmpInteger);
                    end;
                end;
            end;
        end;
        exit(true);
    end;

    local procedure ValidateFieldText(SourceText: Text; TargetFldRef: FieldRef): Boolean
    var
        TmpDateFormula: DateFormula;
        TmpBool: Boolean;
        TmpDate: Date;
        TmpDateTime: DateTime;
        TmpDecimal: Decimal;
        TmpInteger: Integer;
        TmpTime: Time;
    begin
        case UpperCase(Format(TargetFldRef.Type)) of
            'TEXT', 'CODE':
                TargetFldRef.Validate(Format(SourceText));
            'INTEGER':
                if Evaluate(TmpInteger, Format(SourceText)) then begin
                    TargetFldRef.Validate(TmpInteger);
                end else
                    exit(false);
            'OPTION':
                if Evaluate(TmpInteger, Format(SourceText)) then begin
                    if TmpInteger <> 9 then
                        TargetFldRef.Validate(TmpInteger);
                end else
                    exit(false);
            'DECIMAL':
                if Evaluate(TmpDecimal, Format(SourceText)) then begin
                    TargetFldRef.Validate(TmpDecimal);
                end else
                    exit(false);
            'DATE':
                if Evaluate(TmpDate, Format(SourceText)) then begin
                    TargetFldRef.Validate(TmpDate);
                end else
                    exit(false);
            'TIME':
                if Evaluate(TmpTime, Format(SourceText)) then begin
                    TargetFldRef.Validate(TmpTime);
                end else
                    exit(false);
            'DATETIME':
                if Evaluate(TmpDateTime, Format(SourceText)) then begin
                    TargetFldRef.Validate(TmpDateTime);
                end else
                    exit(false);
            'BOOLEAN':
                if Evaluate(TmpInteger, Format(SourceText)) then begin
                    case TmpInteger of
                        0:
                            begin
                                TmpBool := false;
                                TargetFldRef.Validate(TmpBool);
                            end;
                        1:
                            begin
                                TmpBool := true;
                                TargetFldRef.Validate(TmpBool);
                            end;
                    end;
                end else begin
                    if Evaluate(TmpBool, Format(SourceText)) then
                        TargetFldRef.Validate(TmpBool);
                end;
            'DATEFORMULA':
                if Evaluate(TmpDateFormula, Format(SourceText)) then begin
                    TargetFldRef.Validate(TmpDateFormula);
                end else
                    exit(false);
        end;
        exit(true);
    end;

    procedure CheckManualValidation()
    var
        ItemWorksheetFieldSetup: Record "NPR Item Worksh. Field Setup";
        RecRef: RecordRef;
        xRecRef: RecordRef;
        FldRef: FieldRef;
        xFldRef: FieldRef;
        FieldNumber: Integer;
        WarnChangeMsg: Label 'The value of field %1 was changed but this value will be ignored because of the Field Mapping.', Comment = '%1 = Field Name';
    begin
        if not GuiAllowed then
            exit;
        RecRef.GetTable(Rec);
        xRecRef.GetTable(xRec);
        FieldNumber := 0;
        repeat
            FieldNumber := FieldNumber + 1;
            FldRef := RecRef.FieldIndex(FieldNumber);
            xFldRef := xRecRef.FieldIndex(FieldNumber);
            if FldRef.Value <> xFldRef.Value then begin
                ItemWorksheetFieldSetup.Reset();
                ItemWorksheetFieldSetup.SetFilter("Worksheet Template Name", '=%1|=%2', "Worksheet Template Name", '');
                ItemWorksheetFieldSetup.SetFilter("Worksheet Name", '=%1|=%2', "Worksheet Name", '');
                ItemWorksheetFieldSetup.SetRange("Field Number", FldRef.Number);
                ItemWorksheetFieldSetup.SetRange("Table No.", DATABASE::"NPR Item Worksheet Line");
                if ItemWorksheetFieldSetup.FindLast() then begin
                    if ItemWorksheetFieldSetup."Process Update" in [ItemWorksheetFieldSetup."Process Update"::Ignore, ItemWorksheetFieldSetup."Process Update"::"Warn and Ignore"] then
                        Message(WarnChangeMsg, Format(FldRef.Name));
                end;
            end;
        until FieldNumber = RecRef.FieldCount;
    end;

    procedure CreateQueryItemInformation(OnlyNewAndUpdated: Boolean)
    var
        EndpointQuery: Record "NPR Endpoint Query";
        ItemWorksheetLine: Record "NPR Item Worksheet Line";
        EndpointManagement: Codeunit "NPR Endpoint Management";
        QueryName: Text;
    begin
        ItemWorksheetTemplate.Get("Worksheet Template Name");
        QueryName := ItemWorksheetTemplate."Item Info Query Name";
        case ItemWorksheetTemplate."Item Info Query Type" of
            ItemWorksheetTemplate."Item Info Query Type"::Item:
                begin
                    if QueryName = '' then
                        QueryName := Item.TableName;
                    case ItemWorksheetTemplate."Item Info Query By" of
                        ItemWorksheetTemplate."Item Info Query By"::"Vendor No. and Vendor Item No.":
                            begin
                                Item.SetRange("Vendor Item No.", "Vendor Item No.");
                                Item.SetRange("Vendor No.", "Vendor No.");
                            end;
                        ItemWorksheetTemplate."Item Info Query By"::"Vendor Item No. Only":
                            Item.SetRange("Vendor Item No.", "Vendor Item No.");
                    end;
                    EndpointManagement.CreateOutboundEndpointQuery(QueryName, Item, OnlyNewAndUpdated);
                end;
            ItemWorksheetTemplate."Item Info Query Type"::"Item Worksheet":
                begin
                    if QueryName = '' then
                        QueryName := ItemWorksheetLine.TableName();
                    case ItemWorksheetTemplate."Item Info Query By" of
                        ItemWorksheetTemplate."Item Info Query By"::"Vendor No. and Vendor Item No.":
                            begin
                                ItemWorksheetLine.SetRange("Vendor Item No.", "Vendor Item No.");
                                ItemWorksheetLine.SetRange("Vendor No.", "Vendor No.");
                            end;
                        ItemWorksheetTemplate."Item Info Query By"::"Vendor Item No. Only":
                            begin
                                ItemWorksheetLine.SetRange("Vendor Item No.", "Vendor Item No.");
                            end;
                    end;
                    EndpointManagement.CreateOutboundEndpointQuery(QueryName, ItemWorksheetLine, OnlyNewAndUpdated);
                end;
        end;
    end;

    procedure CleanupObsoleteLines()
    var
        ObsoleteWorksheetLine: Record "NPR Item Worksheet Line";
    begin
        if "Item No." = '' then
            exit;
        if "Line No." <= 0 then
            exit;
        if ("Worksheet Name" = '') or ("Worksheet Template Name" = '') then
            exit;
        ObsoleteWorksheetLine.SetRange("Worksheet Template Name", "Worksheet Template Name");
        ObsoleteWorksheetLine.SetRange("Worksheet Name", "Worksheet Name");
        ObsoleteWorksheetLine.SetRange("Line No.", 0, "Line No." - 1);
        ObsoleteWorksheetLine.SetRange("Item No.", "Item No.");
        if ObsoleteWorksheetLine.FindSet() then
            repeat
                if OldLineContainsSameVarieties(ObsoleteWorksheetLine) then
                    ObsoleteWorksheetLine.Delete(true);
            until ObsoleteWorksheetLine.Next() = 0;
    end;

    local procedure GetTempVarietyLines(var ItemWorksheetVarietyValue: Record "NPR Item Worksh. Variety Value"; var TempItemWorksheetVarietyValue: Record "NPR Item Worksh. Variety Value" temporary; ShortcutValue: Integer; LinesType: Option "None",Variants,"Varieties Without Variants",All)
    var
        ItemVariant: Record "Item Variant";
        ItemWorksheetVariantLine: Record "NPR Item Worksh. Variant Line";
        VarFound: Boolean;
    begin
        if ItemWorksheetVarietyValue.FindSet() then
            repeat
                VarFound := false;
                if ItemWorksheetVarietyValue.Value <> '' then begin
                    case LinesType of
                        LinesType::None:
                            begin
                                ItemWorksheetVariantLine.Reset();
                                ItemWorksheetVariantLine.SetRange("Worksheet Template Name", Rec."Worksheet Template Name");
                                ItemWorksheetVariantLine.SetRange("Worksheet Name", Rec."Worksheet Name");
                                ItemWorksheetVariantLine.SetRange("Worksheet Line No.", Rec."Line No.");
                                case ShortcutValue of
                                    1:
                                        ItemWorksheetVariantLine.SetFilter("Variety 1 Value", ItemWorksheetVarietyValue.Value);
                                    2:
                                        ItemWorksheetVariantLine.SetFilter("Variety 2 Value", ItemWorksheetVarietyValue.Value);
                                    3:
                                        ItemWorksheetVariantLine.SetFilter("Variety 3 Value", ItemWorksheetVarietyValue.Value);
                                    4:
                                        ItemWorksheetVariantLine.SetFilter("Variety 4 Value", ItemWorksheetVarietyValue.Value);
                                end;
                                if not ItemWorksheetVariantLine.IsEmpty then
                                    VarFound := true;
                            end;
                        LinesType::Variants:
                            begin
                                ItemVariant.Reset();
                                ItemVariant.SetRange("Item No.", Rec."Existing Item No.");
                                case ShortcutValue of
                                    1:
                                        ItemVariant.SetRange("NPR Variety 1 Value", ItemWorksheetVarietyValue.Value);
                                    2:
                                        ItemVariant.SetRange("NPR Variety 2 Value", ItemWorksheetVarietyValue.Value);
                                    3:
                                        ItemVariant.SetRange("NPR Variety 3 Value", ItemWorksheetVarietyValue.Value);
                                    4:
                                        ItemVariant.SetRange("NPR Variety 4 Value", ItemWorksheetVarietyValue.Value);
                                end;
                                if not ItemVariant.IsEmpty then
                                    VarFound := true;
                            end;
                        LinesType::"Varieties Without Variants":
                            begin
                                ItemVariant.Reset();
                                ItemVariant.SetRange("Item No.", Rec."Existing Item No.");
                                case ShortcutValue of
                                    1:
                                        ItemVariant.SetRange("NPR Variety 1 Value", ItemWorksheetVarietyValue.Value);
                                    2:
                                        ItemVariant.SetRange("NPR Variety 2 Value", ItemWorksheetVarietyValue.Value);
                                    3:
                                        ItemVariant.SetRange("NPR Variety 3 Value", ItemWorksheetVarietyValue.Value);
                                    4:
                                        ItemVariant.SetRange("NPR Variety 4 Value", ItemWorksheetVarietyValue.Value);
                                end;
                                if ItemVariant.IsEmpty then
                                    VarFound := true;
                            end;
                        LinesType::All:
                            VarFound := true;
                    end;
                end else
                    VarFound := true;
                if VarFound then begin
                    TempItemWorksheetVarietyValue.TransferFields(ItemWorksheetVarietyValue, true);
                    TempItemWorksheetVarietyValue.Insert;
                end;
            until ItemWorksheetVarietyValue.Next() = 0;
    end;

    local procedure OldLineContainsSameVarieties(WorksheetLineToCompare: Record "NPR Item Worksheet Line"): Boolean
    var
        ItemWorksheetVariantLine: Record "NPR Item Worksh. Variant Line";
        ItemWorksheetVariantLineToCompare: Record "NPR Item Worksh. Variant Line";
    begin
        ItemWorksheetVariantLineToCompare.SetRange("Worksheet Template Name", WorksheetLineToCompare."Worksheet Template Name");
        ItemWorksheetVariantLineToCompare.SetRange("Worksheet Name", WorksheetLineToCompare."Worksheet Name");
        ItemWorksheetVariantLineToCompare.SetRange("Worksheet Line No.", WorksheetLineToCompare."Line No.");
        if ItemWorksheetVariantLineToCompare.FindSet() then
            repeat
                ItemWorksheetVariantLine.SetRange("Worksheet Template Name", "Worksheet Template Name");
                ItemWorksheetVariantLine.SetRange("Worksheet Name", "Worksheet Name");
                ItemWorksheetVariantLine.SetRange("Worksheet Line No.", "Line No.");
                ItemWorksheetVariantLine.SetRange("Variety 1", ItemWorksheetVariantLineToCompare."Variety 1");
                ItemWorksheetVariantLine.SetRange("Variety 1 Table", ItemWorksheetVariantLineToCompare."Variety 1 Table");
                ItemWorksheetVariantLine.SetRange("Variety 1 Value", ItemWorksheetVariantLineToCompare."Variety 1 Value");
                ItemWorksheetVariantLine.SetRange("Variety 2", ItemWorksheetVariantLineToCompare."Variety 2");
                ItemWorksheetVariantLine.SetRange("Variety 2 Table", ItemWorksheetVariantLineToCompare."Variety 2 Table");
                ItemWorksheetVariantLine.SetRange("Variety 2 Value", ItemWorksheetVariantLineToCompare."Variety 2 Value");
                ItemWorksheetVariantLine.SetRange("Variety 3", ItemWorksheetVariantLineToCompare."Variety 3");
                ItemWorksheetVariantLine.SetRange("Variety 3 Table", ItemWorksheetVariantLineToCompare."Variety 3 Table");
                ItemWorksheetVariantLine.SetRange("Variety 3 Value", ItemWorksheetVariantLineToCompare."Variety 3 Value");
                ItemWorksheetVariantLine.SetRange("Variety 4", ItemWorksheetVariantLineToCompare."Variety 4");
                ItemWorksheetVariantLine.SetRange("Variety 4 Table", ItemWorksheetVariantLineToCompare."Variety 4 Table");
                ItemWorksheetVariantLine.SetRange("Variety 4 Value", ItemWorksheetVariantLineToCompare."Variety 4 Value");
                if ItemWorksheetVariantLine.IsEmpty then
                    exit(false);
            until ItemWorksheetVariantLineToCompare.Next() = 0;
        exit(true);
    end;

    var
        PurchaseCurrency: Record Currency;
        SalesCurrency: Record Currency;
        GLSetup: Record "General Ledger Setup";
        Item: Record Item;
        ItemWorksheetTemplate: Record "NPR Item Worksh. Template";
        ItemWorksheet: Record "NPR Item Worksheet";
        VRTGroup: Record "NPR Variety Group";
        VRTTable: Record "NPR Variety Table";
        Vendor: Record Vendor;
        DimMgt: Codeunit DimensionManagement;
        ItemNumberManagement: Codeunit "NPR Item Number Mgt.";
        ItemWorksheetItemMgt: Codeunit "NPR Item Worksheet Item Mgt.";
        ItemWorksheetManagement: Codeunit "NPR Item Worksheet Mgt.";
        NewItemNoLbl: Label '<NEWITEMNO>';
        NewNosNoLbl: Label '<NEWNOSNO>';
        VarietyErr: Label 'Delete all Item Worksheet Variety Lines belonging to this Item Worksheet Line before changing %1.', Comment = '%1 = Variety Group';
        SetVariantsToCreateQst: Label 'Do you want to set all Variants belonging to this line to Create New?';
        VarietyValueAddedToCopyLbl: Label 'Variety %1 Value %2 will be added to table copy.', Comment = '%1 = Variety 1, %2 = Variety Value';
        VarietyValueAddedToUnlockedTableLbl: Label 'Variety %1 Value %2 will be added to unlocked table.', Comment = '%1 = Variety 1, %2 = Variety Value';
        RebuildQst: Label 'Would you like to rebuild the Item Worksheet Variant Lines?';
        VarietyAddedErr: Label 'You must make a copy of variety %1 table %2 because values have been added for this item.', Comment = '%1 = Variety, %2 = Variety Table';


}