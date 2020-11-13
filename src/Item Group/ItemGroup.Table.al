table 6014410 "NPR Item Group"
{
    Caption = 'Item Group';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Item Group Tree";
    LookupPageID = "NPR Item Group Tree";

    fields
    {
        field(1; "No."; Code[10])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Item: Record Item;
            begin
                if (UpperCase("Search Description") = UpperCase(xRec.Description)) or ("Search Description" = '') then
                    "Search Description" := UpperCase(Description);

                if Description <> xRec.Description then begin
                    if Item.Get("No.") then
                        if Item."NPR Group sale" then begin
                            Item.Description := Description;
                            Item."Search Description" := UpperCase("Search Description");
                            Item.Modify(true);
                        end;
                end;
            end;
        }
        field(3; "Search Description"; Text[50])
        {
            Caption = 'Search Description';
            DataClassification = CustomerContent;
        }
        field(4; "Parent Item Group No."; Code[10])
        {
            Caption = 'Parent Item Group No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR Item Group"."No.";
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                if "Parent Item Group No." = "No." then Error(Text1060004);

                if (xRec."Parent Item Group No." <> '') then begin
                    if Confirm(Text1060011, true) then
                        CopyParentItemGroupSetup(Rec);
                end else
                    CopyParentItemGroupSetup(Rec);

                if "Parent Item Group No." = '' then begin
                    Level := 0;
                end;

                UpdateSortKey(Rec);
            end;
        }
        field(5; "Belongs In Main Item Group"; Code[10])
        {
            Caption = 'Belongs in Main Item Group';
            DataClassification = CustomerContent;
            TableRelation = "NPR Item Group"."No.";
            ValidateTableRelation = false;
        }
        field(7; "Sorting-Key"; Text[250])
        {
            Caption = 'Sorting Key';
            DataClassification = CustomerContent;
        }
        field(8; Blocked; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                ItemGroup: Record "NPR Item Group";
            begin
                CheckItemGroup(FieldNo(Blocked));

                ItemGroup.Reset;
                ItemGroup.SetRange("Parent Item Group No.", "No.");
                if ItemGroup.IsEmpty then
                    exit;
                if not Confirm(Text1060012, true, FieldCaption(Blocked), Blocked) then
                    exit;

                BlockSubLevels("No.", Blocked);
            end;
        }
        field(9; "Created Date"; Date)
        {
            Caption = 'Created Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(10; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(11; Type; Enum "Item Type")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Type = Type::"Non-Inventory" then
                    FieldError(Type);
            end;
        }
        field(12; "VAT Prod. Posting Group"; Code[10])
        {
            Caption = 'VAT Prod. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Product Posting Group";
        }
        field(14; "VAT Bus. Posting Group"; Code[10])
        {
            Caption = 'VAT Bus. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Business Posting Group";
        }
        field(15; "Gen. Bus. Posting Group"; Code[10])
        {
            Caption = 'Gen. Bus. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Business Posting Group";

            trigger OnValidate()
            var
                GenBusinessPostingGroup: Record "Gen. Business Posting Group";
            begin
                if "Gen. Bus. Posting Group" <> '' then begin
                    GenBusinessPostingGroup.Get("Gen. Bus. Posting Group");
                    Validate("VAT Bus. Posting Group", GenBusinessPostingGroup."Def. VAT Bus. Posting Group");
                end else
                    "VAT Bus. Posting Group" := '';

                CheckItemGroup(FieldNo("Gen. Bus. Posting Group"));
            end;
        }
        field(16; "Gen. Prod. Posting Group"; Code[10])
        {
            Caption = 'Gen. Prod. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Product Posting Group";

            trigger OnValidate()
            var
                GenProductPostingGroup: Record "Gen. Product Posting Group";
            begin
                if "Gen. Prod. Posting Group" <> '' then begin
                    GenProductPostingGroup.Get("Gen. Prod. Posting Group");
                    Validate("VAT Prod. Posting Group", GenProductPostingGroup."Def. VAT Prod. Posting Group");
                end else
                    "VAT Prod. Posting Group" := '';

                CheckItemGroup(FieldNo("Gen. Prod. Posting Group"));
            end;
        }
        field(17; "Inventory Posting Group"; Code[10])
        {
            Caption = 'Inventory Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "Inventory Posting Group";

            trigger OnValidate()
            begin
                CheckItemGroup(FieldNo("Inventory Posting Group"));
            end;
        }
        field(50; Level; Integer)
        {
            Caption = 'Level';
            DataClassification = CustomerContent;
        }
        field(52; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(54; "Main Item Group"; Boolean)
        {
            Caption = 'Main Item Group';
            DataClassification = CustomerContent;
            Editable = true;
        }
        field(55; "Sales (Qty.)"; Decimal)
        {
            CalcFormula = - Sum("Item Ledger Entry".Quantity WHERE("Entry Type" = CONST(Sale),
                                                                   "NPR Item Group No." = FIELD("No."),
                                                                   "NPR Vendor No." = FIELD("Vendor Filter"),
                                                                   "Posting Date" = FIELD("Date Filter"),
                                                                   "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                   "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter")));
            Caption = 'Sales (Qty.)';
            FieldClass = FlowField;
        }
        field(56; "Sales (LCY)"; Decimal)
        {
            CalcFormula = Sum("Value Entry"."Sales Amount (Actual)" WHERE("Item Ledger Entry Type" = CONST(Sale),
                                                                           "NPR Item Group No." = FIELD("No."),
                                                                           "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                           "Posting Date" = FIELD("Date Filter"),
                                                                           "NPR Vendor No." = FIELD("Vendor Filter"),
                                                                           "Salespers./Purch. Code" = FIELD("Salesperson Filter"),
                                                                           "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter")));
            Caption = 'Sales (LCY)';
            FieldClass = FlowField;
        }
        field(57; "Global Dimension 1 Filter"; Code[20])
        {
            CaptionClass = '1,3,1';
            Caption = 'Global Dimension 1 Filter';
            Description = 'NPR5.48';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(58; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(59; "Vendor Filter"; Code[20])
        {
            Caption = 'Vendor Filter';
            FieldClass = FlowFilter;
            TableRelation = Vendor;
        }
        field(60; "Consumption (Amount)"; Decimal)
        {
            CalcFormula = - Sum("Value Entry"."Cost Amount (Actual)" WHERE("Item Ledger Entry Type" = CONST(Sale),
                                                                           "NPR Item Group No." = FIELD("No."),
                                                                           "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                           "Posting Date" = FIELD("Date Filter"),
                                                                           "NPR Vendor No." = FIELD("Vendor Filter"),
                                                                           "Salespers./Purch. Code" = FIELD("Salesperson Filter"),
                                                                           "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter")));
            Caption = 'Consumption (Amount)';
            FieldClass = FlowField;
        }
        field(61; "Salesperson Filter"; Code[10])
        {
            Caption = 'Salesperson Filter';
            FieldClass = FlowFilter;
            TableRelation = "Salesperson/Purchaser";
        }
        field(62; "Item Discount Group"; Code[20])
        {
            Caption = 'Item Discount Group';
            DataClassification = CustomerContent;
            Description = 'NPR5.48';
            TableRelation = "Item Discount Group".Code;

            trigger OnValidate()
            var
                VareLoc: Record Item;
                OldGroup: Text[30];
            begin
                VareLoc.SetRange("NPR Item Group", "No.");
                if VareLoc.Find('-') then begin
                    VareLoc.SetFilter("Item Disc. Group", '<> %1', xRec."Item Discount Group");
                    if VareLoc.Find('-') then begin
                        OldGroup := xRec."Item Discount Group";
                        if OldGroup = '' then
                            OldGroup := '<BLANK>';
                        if Confirm(
                          StrSubstNo(Text1060010,
                            TableCaption,
                            "No.",
                            OldGroup,
                            VareLoc.FieldCaption("Item Disc. Group"),
                            "Item Discount Group"
                            )) then begin
                            VareLoc.SetRange("Item Disc. Group");
                            VareLoc.ModifyAll("Item Disc. Group", "Item Discount Group");
                        end else begin
                            VareLoc.SetRange("Item Disc. Group", xRec."Item Discount Group");
                            VareLoc.ModifyAll("Item Disc. Group", "Item Discount Group");
                        end;
                    end else begin
                        VareLoc.ModifyAll("Item Disc. Group", "Item Discount Group");
                    end;
                end;
            end;
        }
        field(63; "Warranty File"; Option)
        {
            Caption = 'Warranty File';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Move to Warranty File';
            OptionMembers = " ","Flyt til garanti kar.";
        }
        field(64; "No. Series"; Code[10])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(65; "Costing Method"; Enum "Costing Method")
        {
            Caption = 'Costing Method';
            DataClassification = CustomerContent;
            InitValue = FIFO;
        }
        field(66; Movement; Decimal)
        {
            CalcFormula = Sum("Item Ledger Entry".Quantity WHERE("NPR Item Group No." = FIELD("No."),
                                                                  "NPR Vendor No." = FIELD("Vendor Filter"),
                                                                  "Posting Date" = FIELD("Date Filter"),
                                                                  "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                  "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter")));
            Caption = 'Movement';
            FieldClass = FlowField;
        }
        field(67; "Purchases (Qty.)"; Decimal)
        {
            CalcFormula = Sum("Item Ledger Entry".Quantity WHERE("Entry Type" = CONST(Purchase),
                                                                  "NPR Item Group No." = FIELD("No."),
                                                                  "NPR Vendor No." = FIELD("Vendor Filter"),
                                                                  "Posting Date" = FIELD("Date Filter"),
                                                                  "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                  "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter")));
            Caption = 'Purchases (Qty.)';
            FieldClass = FlowField;
        }
        field(68; "Purchases (LCY)"; Decimal)
        {
            CalcFormula = Sum("Value Entry"."Cost Amount (Actual)" WHERE("Item Ledger Entry Type" = CONST(Purchase),
                                                                          "NPR Item Group No." = FIELD("No."),
                                                                          "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                          "Posting Date" = FIELD("Date Filter"),
                                                                          "NPR Vendor No." = FIELD("Vendor Filter"),
                                                                          "Salespers./Purch. Code" = FIELD("Salesperson Filter"),
                                                                          "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter")));
            Caption = 'Purchases (LCY)';
            FieldClass = FlowField;
        }
        field(70; "Base Unit of Measure"; Code[10])
        {
            Caption = 'Base Unit of Measure';
            DataClassification = CustomerContent;
            TableRelation = "Unit of Measure";
        }
        field(71; "Sales Unit of Measure"; Code[10])
        {
            Caption = 'Sales Unit of Measure';
            DataClassification = CustomerContent;
            TableRelation = "Unit of Measure";
        }
        field(72; "Purch. Unit of Measure"; Code[10])
        {
            Caption = 'Purch. Unit of Measure';
            DataClassification = CustomerContent;
            TableRelation = "Unit of Measure";
        }
        field(73; "Insurance Category"; Code[50])
        {
            Caption = 'Insurance Category';
            DataClassification = CustomerContent;
            TableRelation = "NPR Insurance Category";
        }
        field(74; Warranty; Boolean)
        {
            Caption = 'Warranty';
            DataClassification = CustomerContent;
        }
        field(80; "Config. Template Header"; Code[10])
        {
            Caption = 'Config. Template Header';
            DataClassification = CustomerContent;
            Description = 'NPR5.30';
            TableRelation = "Config. Template Header";
        }
        field(85; Picture; BLOB)
        {
            Caption = 'Picture';
            DataClassification = CustomerContent;
            SubType = Bitmap;
        }
        field(86; "Picture Extention"; Text[3])
        {
            Caption = 'Picture Extention';
            DataClassification = CustomerContent;
        }
        field(90; "Inventory Value"; Decimal)
        {
            CalcFormula = Sum("Value Entry"."Cost Amount (Actual)" WHERE("NPR Item Group No." = FIELD("No."),
                                                                          "NPR Vendor No." = FIELD("Vendor Filter"),
                                                                          "Posting Date" = FIELD("Date Filter"),
                                                                          "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                          "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter")));
            Caption = 'Inventory Value';
            Description = 'Lagerværdi';
            FieldClass = FlowField;
        }
        field(98; "Tax Group Code"; Code[10])
        {
            Caption = 'Tax Group Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.38';
            TableRelation = "Tax Group";
        }
        field(310; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.48';
            TableRelation = Location;
        }
        field(316; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Global Dimension 1 Code");
            end;
        }
        field(317; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Global Dimension 2 Code");
            end;
        }
        field(318; "Global Dimension 2 Filter"; Code[20])
        {
            CaptionClass = '1,3,2';
            Caption = 'Global Dimension 2 Filter';
            Description = 'NPR5.48';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(320; "Primary Key Length"; Integer)
        {
            Caption = 'Primary Key Length';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "Primary Key Length" := StrLen("No.");
            end;
        }
        field(321; "Tarif No."; Code[20])
        {
            Caption = 'Tarif No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.48';
            TableRelation = "Tariff Number";
        }
        field(500; "Used Goods Group"; Boolean)
        {
            Caption = 'Used Goods Group';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                ItemGroup: Record "NPR Item Group";
            begin
                if not "Main Item Group" then begin
                    ItemGroup.SetRange("No.", "Parent Item Group No.");
                    if ItemGroup.FindFirst then
                        if (ItemGroup."Used Goods Group") and ("Used Goods Group") then
                            Error(Text1060008, "No.");
                end;

                SetUsedOnSubLevels("No.", "Used Goods Group");
            end;
        }
        field(600; "Mixed Discount Line Exists"; Boolean)
        {
            CalcFormula = Exist("NPR Mixed Discount Line" WHERE("No." = FIELD("No."),
                                                             "Disc. Grouping Type" = CONST("Item Group")));
            Caption = 'Mixed Discount Line Exists';
            FieldClass = FlowField;
        }
        field(5440; "Reordering Policy"; Option)
        {
            Caption = 'Reordering Policy';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Fixed Reorder Qty.,Maximum Qty.,Order,Lot-for-Lot';
            OptionMembers = " ","Fixed Reorder Qty.","Maximum Qty.","Order","Lot-for-Lot";
        }
        field(6014607; "Size Dimension"; Code[20])
        {
            Caption = 'Size Dimension';
            DataClassification = CustomerContent;
        }
        field(6014608; "Color Dimension"; Code[20])
        {
            Caption = 'Color Dimension';
            DataClassification = CustomerContent;
        }
        field(6059982; "Variety Group"; Code[20])
        {
            Caption = 'Variety Group';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
            TableRelation = "NPR Variety Group";
        }
        field(6060001; "Webshop Picture"; Text[200])
        {
            Caption = 'Webshop Picture';
            DataClassification = CustomerContent;
        }
        field(6060002; Internet; Boolean)
        {
            Caption = 'Internet';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
        key(Key2; "Entry No.", "Primary Key Length")
        {
        }
        key(Key3; "Parent Item Group No.")
        {
        }
        key(Key4; "Main Item Group")
        {
        }
        key(Key5; "Sorting-Key")
        {
        }
        key(Key6; Description)
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "No.", Description, Blocked)
        {
        }
    }

    trigger OnDelete()
    var
        ItemGroup: Record "NPR Item Group";
        ItemGroup2: Record "NPR Item Group";
    begin
        ItemGroup.SetRange("Parent Item Group No.", "No.");
        if not ItemGroup.IsEmpty then begin
            if not Confirm(Text001, false, "No.") then
                Error(Text1060002);

            if ItemGroup.FindSet(false, false) then
                repeat
                    ItemGroup2.Get(ItemGroup."No.");
                    ItemGroup2."Parent Item Group No." := '';
                    ItemGroup2.Modify;
                until ItemGroup.Next = 0;
        end;
    end;

    trigger OnInsert()
    var
        ItemGroup: Record "NPR Item Group";
    begin
        "Created Date" := Today;
        "Primary Key Length" := StrLen("No.");

        if "Parent Item Group No." <> '' then begin
            if ItemGroup.Get("Parent Item Group No.") then begin
                Level := ItemGroup.Level + 1;
                "Sorting-Key" := ItemGroup."Sorting-Key" + '/' + "No.";
                "Belongs In Main Item Group" := ItemGroup."Belongs In Main Item Group";
                "Main Item Group" := false;
            end;
        end else
            "Sorting-Key" := "No.";

        CopyParentItemGroupSetup(Rec);

        CreateNoSeries;

        RecRef.GetTable(Rec);
        CompanySyncMgt.OnInsert(RecRef);

        DimMgt.UpdateDefaultDim(
          DATABASE::"NPR Item Group", "No.",
          "Global Dimension 1 Code", "Global Dimension 2 Code");
    end;

    trigger OnModify()
    begin
        "Last Date Modified" := Today;
        "Primary Key Length" := StrLen("No.");

        RecRef.GetTable(Rec);
        CompanySyncMgt.OnModify(RecRef);
    end;

    trigger OnRename()
    var
        ItemGroup: Record "NPR Item Group";
    begin
        ItemGroup.SetRange("Parent Item Group No.", xRec."No.");
        if ItemGroup.FindSet then
            repeat
                ItemGroup."Parent Item Group No." := "No.";
                ItemGroup.Modify;
            until ItemGroup.Next = 0;

        SoNoSeries;
    end;

    var
        Text1060002: Label 'Deletion cancelled!';
        Text1060004: Label 'The item group cannot be subgroup to itself!';
        Text1060008: Label 'The main groups to item group %1 must be activated to used goods groups!';
        RetailSetup: Record "NPR Retail Setup";
        CompanySyncMgt: Codeunit "NPR CompanySyncManagement";
        DimMgt: Codeunit DimensionManagement;
        Text1060010: Label 'Items have been found belonging to %1 %2, but not having %3 in %4.\Edit these to %4 %5';
        Text1060011: Label 'You are about to move the relation to another item group, do you with to inherit the attributes?';
        Text1060012: Label 'Do you wish to set %1 to %2  on Item groups below this level?';
        RecRef: RecordRef;
        Text001: Label 'There is other Item groups that has a reference to Item Group %1.\Do you wish to delete it anyway?';

    procedure BlockSubLevels(ItemGroupCode: Code[10]; BlockValue: Boolean)
    var
        ItemGroup: Record "NPR Item Group";
    begin
        ItemGroup.SetRange("Parent Item Group No.", ItemGroupCode);
        if ItemGroup.Find('-') then
            repeat
                if ItemGroup."Belongs In Main Item Group" = ItemGroup."No." then ItemGroup.Next;
                ItemGroup.Blocked := BlockValue;
                ItemGroup.Modify;
                BlockSubLevels(ItemGroup."No.", BlockValue);
            until ItemGroup.Next = 0;
    end;

    procedure DeleteSubLevels(ItemGroupCode: Code[10])
    var
        ItemGroup: Record "NPR Item Group";
    begin
        ItemGroup.SetRange("Parent Item Group No.", ItemGroupCode);
        if ItemGroup.FindSet then
            repeat
                if ItemGroup."Belongs In Main Item Group" = ItemGroup."No." then ItemGroup.Next;
                DeleteSubLevels(ItemGroup."No.");
                ItemGroup.Delete(true);
            until ItemGroup.Next = 0;
    end;

    procedure SetUsedOnSubLevels(ItemGroupcode: Code[10]; UsedValue: Boolean)
    var
        ItemGroup: Record "NPR Item Group";
    begin
        ItemGroup.SetRange("Belongs In Main Item Group", ItemGroupcode);
        if ItemGroup.FindSet then
            repeat
                if ItemGroup."Belongs In Main Item Group" = ItemGroup."No." then ItemGroup.Next;
                ItemGroup."Used Goods Group" := UsedValue;
                ItemGroup.Modify;
                BlockSubLevels(ItemGroup."No.", UsedValue);
            until ItemGroup.Next = 0;
    end;

    procedure CreateNoSeries()
    var
        ErrLength: Label 'No. Series is too long. Reduce the length on itemgroup or pre-itemgroup in setup';
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        Text0001: Label 'NoSeries for itemgroup';
    begin
        //OpretNrSerie
        RetailSetup.Get;
        if RetailSetup."Itemgroup Pre No. Serie" = '' then
            exit;

        "No. Series" := RetailSetup."Itemgroup Pre No. Serie" + "No.";

        if StrLen(RetailSetup."Itemgroup Pre No. Serie" + "No.") > 10 then
            Error(ErrLength);

        NoSeries.Init;
        NoSeries.Code := "No. Series";
        NoSeries.Description := Text0001 + "No.";
        NoSeries."Default Nos." := true;
        NoSeries."Manual Nos." := true;
        NoSeries."Date Order" := false;
        NoSeries.Insert(true);
        NoSeriesLine.Init;
        NoSeriesLine."Series Code" := NoSeries.Code;
        NoSeriesLine."Line No." := 10000;
        NoSeriesLine."Starting Date" := CalcDate('<-1D>', Today);
        NoSeriesLine."Starting No." := "No." + RetailSetup."Itemgroup No. Serie StartNo.";
        NoSeriesLine."Ending No." := "No." + RetailSetup."Itemgroup No. Serie EndNo.";
        NoSeriesLine."Warning No." := RetailSetup."Itemgroup No. Serie Warning";
        NoSeriesLine."Increment-by No." := 1;
        NoSeriesLine."Last No. Used" := NoSeriesLine."Starting No.";
        NoSeriesLine.Open := true;
        NoSeriesLine.Insert;
    end;

    procedure SoNoSeries()
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        if RetailSetup."Itemgroup Pre No. Serie" = '' then
            exit;

        if "No. Series" = xRec."No. Series" then
            exit;

        NoSeries.Get(xRec."No. Series");
        NoSeries.Rename("No. Series");
        NoSeries.Validate(Description, 'Nummerserie til varegruppe ' + "No.");
        NoSeries.Modify;
        NoSeriesLine.Get("No. Series", 10000);
        NoSeriesLine."Starting No." := "No." + '00000';
        NoSeriesLine."Ending No." := "No." + '99999';
        NoSeriesLine."Warning No." := "No." + '99000';
        NoSeriesLine.Modify;

        "No. Series" := RetailSetup."Itemgroup Pre No. Serie" + "No.";
    end;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateDimValueCode(FieldNumber, ShortcutDimCode);
        DimMgt.SaveDefaultDim(DATABASE::Customer, "No.", FieldNumber, ShortcutDimCode);
        Modify;
    end;

    procedure CopyParentItemGroupSetup(var ItemGroup: Record "NPR Item Group")
    var
        ItemGroupParent: Record "NPR Item Group";
    begin
        with ItemGroup do begin
            if (ItemGroupParent.Get("Parent Item Group No.")) then begin
                Level := ItemGroupParent.Level + 1;
                "VAT Prod. Posting Group" := ItemGroupParent."VAT Prod. Posting Group";
                "VAT Bus. Posting Group" := ItemGroupParent."VAT Bus. Posting Group";
                "Gen. Prod. Posting Group" := ItemGroupParent."Gen. Prod. Posting Group";
                "Gen. Bus. Posting Group" := ItemGroupParent."Gen. Bus. Posting Group";
                "Inventory Posting Group" := ItemGroupParent."Inventory Posting Group";
                "Base Unit of Measure" := ItemGroupParent."Base Unit of Measure";
                "Sales Unit of Measure" := ItemGroupParent."Sales Unit of Measure";
                "Purch. Unit of Measure" := ItemGroupParent."Purch. Unit of Measure";
                "No. Series" := ItemGroupParent."No. Series";
                "Location Code" := ItemGroupParent."Location Code";
                "Global Dimension 1 Code" := ItemGroupParent."Global Dimension 1 Code";
                "Global Dimension 2 Code" := ItemGroupParent."Global Dimension 2 Code";
                "Item Discount Group" := ItemGroupParent."Item Discount Group";
                "Size Dimension" := ItemGroupParent."Size Dimension";
                "Color Dimension" := ItemGroupParent."Color Dimension";
                "Tax Group Code" := ItemGroupParent."Tax Group Code";
                Type := ItemGroupParent.Type;
            end;
        end;
    end;

    procedure UpdateSortKey(var ItemGroup: Record "NPR Item Group"): Text[250]
    var
        ItemGroup2: Record "NPR Item Group";
    begin
        //Update Me
        ItemGroup."Main Item Group" := (ItemGroup."Parent Item Group No." = '');
        if ItemGroup."Main Item Group" then begin
            ItemGroup.Level := 0;
            ItemGroup."Sorting-Key" := ItemGroup."No.";
            ItemGroup."Belongs In Main Item Group" := ItemGroup."No.";
            ItemGroup."Main Item Group" := true;
        end else begin
            ItemGroup2.Get(ItemGroup."Parent Item Group No.");
            ItemGroup.Level := ItemGroup2.Level + 1;
            ItemGroup."Sorting-Key" := ItemGroup2."Sorting-Key" + '/' + ItemGroup."No.";
            ItemGroup."Belongs In Main Item Group" := ItemGroup2."Belongs In Main Item Group";
            ItemGroup."Main Item Group" := false;
        end;
        ItemGroup.Modify;

        //Update Children
        ItemGroup2.SetCurrentKey("Parent Item Group No.");
        ItemGroup2.SetRange("Parent Item Group No.", ItemGroup."No.");
        if ItemGroup2.FindSet then
            repeat
                UpdateSortKey(ItemGroup2);
            until ItemGroup2.Next = 0;
    end;

    local procedure CheckItemGroup(CalledFromFieldNo: Integer)
    var
        ItemGroup2: Record "NPR Item Group";
    begin
        if CalledFromFieldNo = FieldNo(Blocked) then begin
            if not Blocked then begin
                TestField("Gen. Prod. Posting Group");
                TestField("Gen. Bus. Posting Group");
                ItemGroup2.Get("Parent Item Group No.");
            end;
        end else
            if ("Gen. Prod. Posting Group" = '') or
               ("Gen. Bus. Posting Group" = '') or
               (not ItemGroup2.Get("Parent Item Group No."))
            then
                Blocked := true;
    end;
}