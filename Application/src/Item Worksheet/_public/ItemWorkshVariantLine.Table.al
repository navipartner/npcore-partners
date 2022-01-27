table 6060043 "NPR Item Worksh. Variant Line"
{
    Caption = 'Item Worksheet Variant Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Worksheet Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR Item Worksh. Template";
        }
        field(2; "Worksheet Name"; Code[10])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR Item Worksheet".Name WHERE("Item Template Name" = FIELD("Worksheet Template Name"));
        }
        field(3; "Worksheet Line No."; Integer)
        {
            Caption = 'Worksheet Line No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR Item Worksheet Line"."Line No." WHERE("Worksheet Template Name" = FIELD("Worksheet Template Name"),
                                                                    "Worksheet Name" = FIELD("Worksheet Name"));
        }
        field(6; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(7; Level; Integer)
        {
            Caption = 'Level';
            DataClassification = CustomerContent;
        }
        field(8; "Action"; Option)
        {
            Caption = 'Action';
            DataClassification = CustomerContent;
            InitValue = Undefined;
            OptionCaption = 'Skip,CreateNew,Update,Undefined';
            OptionMembers = Skip,CreateNew,Update,Undefined;

            trigger OnValidate()
            begin
                if "Heading Text" <> '' then begin
                    //Propagate to lower lines
                    SetPropagationFilter();
                    if ItemWorksheetVariantLine2.FindSet() then
                        repeat
                            ItemWorksheetVariantLine2.Validate(Action, Action);
                            ItemWorksheetVariantLine2.Modify();
                        until ItemWorksheetVariantLine2.Next() = 0;
                    UpdateAllRemarks();
                end else begin
                    case Action of
                        Action::CreateNew:
                            if "Existing Variant Code" <> '' then begin
                                "Internal Bar Code" := '';
                                "Vendors Bar Code" := '';
                                "Existing Variant Code" := '';
                            end;
                        Action::Update:
                            begin
                                if "Existing Item No." <> '' then
                                    Validate("Existing Variant Code", GetExistingVariantCode());
                                TestField("Existing Variant Code");
                            end;
                    end;
                    if Action <> Action::Skip then begin
                        Validate("Variety 1 Value");
                        Validate("Variety 2 Value");
                        Validate("Variety 3 Value");
                        Validate("Variety 4 Value");
                    end;
                end;
            end;
        }
        field(9; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
        }
        field(15; "Existing Item No."; Code[20])
        {
            Caption = 'Existing Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;

            trigger OnValidate()
            begin
                Validate("Existing Variant Code", GetExistingVariantCode());
            end;
        }
        field(16; "Existing Variant Code"; Code[10])
        {
            Caption = 'Existing Variant Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Existing Item No."));

            trigger OnValidate()
            begin
                if "Existing Variant Code" <> xRec."Existing Variant Code" then begin
                    if ItemVariant.Get("Existing Item No.", "Existing Variant Code") then begin
                        CalcFields("Existing Variant Blocked");
                        Blocked := "Existing Variant Blocked";
                        Description := ItemVariant.Description;
                        GetLine();
                        "Sales Price" := GetExistingVariantPrice();
                        if "Sales Price" = ItemWorksheetLine."Sales Price" then
                            "Sales Price" := 0;
                        "Direct Unit Cost" := GetExistingVariantCost();
                        if "Direct Unit Cost" = ItemWorksheetLine."Direct Unit Cost" then
                            "Direct Unit Cost" := 0;
                    end;
                end;
            end;
        }
        field(21; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                UpdateExistingItemAndVaraint();
            end;
        }
        field(22; "Internal Bar Code"; Text[30])
        {
            Caption = 'Internal Bar Code';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Heading Text" <> '' then begin
                    //Propagate to lower lines
                    SetPropagationFilter();
                    if ItemWorksheetVariantLine2.FindSet() then
                        repeat
                            ItemWorksheetVariantLine2.Validate("Internal Bar Code", "Internal Bar Code");
                            ItemWorksheetVariantLine2.Modify();
                        until ItemWorksheetVariantLine2.Next() = 0;
                    UpdateAllRemarks();
                end else begin
                    UpdateExistingItemAndVaraint();
                end;
            end;
        }
        field(23; "Sales Price"; Decimal)
        {
            Caption = 'Sales Price';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Heading Text" <> '' then begin
                    //Propagate to lower lines
                    SetPropagationFilter();
                    if ItemWorksheetVariantLine2.FindSet() then
                        repeat
                            ItemWorksheetVariantLine2.Validate("Sales Price", "Sales Price");
                            ItemWorksheetVariantLine2.Modify();
                        until ItemWorksheetVariantLine2.Next() = 0;
                    UpdateAllRemarks();
                end else begin
                    UpdateExistingItemAndVaraint();
                end;
            end;
        }
        field(24; "Direct Unit Cost"; Decimal)
        {
            Caption = 'Direct Unit Cost';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Heading Text" <> '' then begin
                    //Propagate to lower lines
                    SetPropagationFilter();
                    if ItemWorksheetVariantLine2.FindSet() then
                        repeat
                            ItemWorksheetVariantLine2.Validate("Direct Unit Cost", "Direct Unit Cost");
                            ItemWorksheetVariantLine2.Modify();
                        until ItemWorksheetVariantLine2.Next() = 0;
                    UpdateAllRemarks();
                end else begin
                    UpdateExistingItemAndVaraint();
                end;
            end;
        }
        field(35; "Vendors Bar Code"; Code[20])
        {
            Caption = 'Vendors Bar Code';
            DataClassification = CustomerContent;
        }
        field(160; "Heading Text"; Text[50])
        {
            Caption = 'Heading Text';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(170; "Existing Variant Blocked"; Boolean)
        {
            CalcFormula = Lookup("Item Variant"."NPR Blocked" WHERE("Item No." = FIELD("Existing Item No."),
                                                               Code = FIELD("Existing Variant Code")));
            Caption = 'Existing Variant Blocked';
            Editable = false;
            FieldClass = FlowField;
        }
        field(180; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(190; Blocked; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Heading Text" <> '' then begin
                    //Propagate to lower lines
                    SetPropagationFilter();
                    if ItemWorksheetVariantLine2.FindSet() then
                        repeat
                            ItemWorksheetVariantLine2.Blocked := Blocked;
                            ItemWorksheetVariantLine2.Modify();
                        until ItemWorksheetVariantLine2.Next() = 0;
                    UpdateAllRemarks();
                end else begin
                    UpdateExistingItemAndVaraint();
                end;
            end;
        }
        field(260; "Recommended Retail Price"; Decimal)
        {
            Caption = 'Recommended Retail Price';
            DataClassification = CustomerContent;
        }
        field(6059980; "Variety 1"; Code[10])
        {
            CalcFormula = Lookup("NPR Item Worksheet Line"."Variety 1" WHERE("Worksheet Template Name" = FIELD("Worksheet Template Name"),
                                                                          "Worksheet Name" = FIELD("Worksheet Name"),
                                                                          "Line No." = FIELD("Worksheet Line No.")));
            Caption = 'Variety 1';
            Description = 'VRT1.00';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6059981; "Variety 1 Table"; Code[40])
        {
            CalcFormula = Lookup("NPR Item Worksheet Line"."Variety 1 Table (New)" WHERE("Worksheet Template Name" = FIELD("Worksheet Template Name"),
                                                                                      "Worksheet Name" = FIELD("Worksheet Name"),
                                                                                      "Line No." = FIELD("Worksheet Line No.")));
            Caption = 'Variety 1 Table';
            Description = 'VRT1.00';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6059982; "Variety 1 Value"; Code[50])
        {
            Caption = 'Variety 1 Value';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
            Editable = true;
            TableRelation = "NPR Item Worksh. Variety Value".Value WHERE("Worksheet Template Name" = FIELD("Worksheet Template Name"),
                                                                        "Worksheet Name" = FIELD("Worksheet Name"),
                                                                        "Worksheet Line No." = FIELD("Worksheet Line No."));
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                if "Heading Text" <> '' then begin
                    //Propagate to lower lines
                    SetPropagationFilter();
                    ItemWorksheetVariantLine2.SetCurrentKey("Worksheet Template Name", "Worksheet Name", "Worksheet Line No.", "Line No.");
                    ItemWorksheetVariantLine2.SetRange("Variety 1 Value", xRec."Variety 1 Value");
                    if ItemWorksheetVariantLine2.FindSet() then
                        repeat
                            ItemWorksheetVariantLine2.Validate("Variety 1 Value", "Variety 1 Value");
                            ItemWorksheetVariantLine2.Modify();
                        until ItemWorksheetVariantLine2.Next() = 0;
                    UpdateAllRemarks();
                end else begin
                    if "Variety 1 Value" <> '' then begin
                        CalcFields("Variety 1 Table", "Variety 1");
                        ValidateVarietyValue(1, "Variety 1", "Variety 1 Table", "Variety 1 Value", xRec."Variety 1 Value");
                    end;
                end;
            end;
        }
        field(6059983; "Variety 2"; Code[10])
        {
            CalcFormula = Lookup("NPR Item Worksheet Line"."Variety 2" WHERE("Worksheet Template Name" = FIELD("Worksheet Template Name"),
                                                                          "Worksheet Name" = FIELD("Worksheet Name"),
                                                                          "Line No." = FIELD("Worksheet Line No.")));
            Caption = 'Variety 2';
            Description = 'VRT1.00';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6059984; "Variety 2 Table"; Code[40])
        {
            CalcFormula = Lookup("NPR Item Worksheet Line"."Variety 2 Table (New)" WHERE("Worksheet Template Name" = FIELD("Worksheet Template Name"),
                                                                                      "Worksheet Name" = FIELD("Worksheet Name"),
                                                                                      "Line No." = FIELD("Worksheet Line No.")));
            Caption = 'Variety 2 Table';
            Description = 'VRT1.00';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6059985; "Variety 2 Value"; Code[50])
        {
            Caption = 'Variety 2 Value';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
            Editable = true;
            TableRelation = "NPR Item Worksh. Variety Value".Value WHERE("Worksheet Template Name" = FIELD("Worksheet Template Name"),
                                                                        "Worksheet Name" = FIELD("Worksheet Name"),
                                                                        "Worksheet Line No." = FIELD("Worksheet Line No."));
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                if "Variety 2 Value" <> '' then begin
                    CalcFields("Variety 2 Table", "Variety 2");
                    ValidateVarietyValue(2, "Variety 2", "Variety 2 Table", "Variety 2 Value", xRec."Variety 2 Value");
                end;
            end;
        }
        field(6059986; "Variety 3"; Code[10])
        {
            CalcFormula = Lookup("NPR Item Worksheet Line"."Variety 3" WHERE("Worksheet Template Name" = FIELD("Worksheet Template Name"),
                                                                          "Worksheet Name" = FIELD("Worksheet Name"),
                                                                          "Line No." = FIELD("Worksheet Line No.")));
            Caption = 'Variety 3';
            Description = 'VRT1.00';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6059987; "Variety 3 Table"; Code[40])
        {
            CalcFormula = Lookup("NPR Item Worksheet Line"."Variety 3 Table (New)" WHERE("Worksheet Template Name" = FIELD("Worksheet Template Name"),
                                                                                      "Worksheet Name" = FIELD("Worksheet Name"),
                                                                                      "Line No." = FIELD("Worksheet Line No.")));
            Caption = 'Variety 3 Table';
            Description = 'VRT1.00';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6059988; "Variety 3 Value"; Code[50])
        {
            Caption = 'Variety 3 Value';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
            Editable = true;

            trigger OnLookup()
            var
                VarValue: Code[50];
            begin
                CalcFields("Variety 3", "Variety 3 Table");
                VarValue := "Variety 3 Value";
                if VarValue <> "Variety 3 Value" then
                    Validate("Variety 3 Value", VarValue);
            end;

            trigger OnValidate()
            begin
                if "Variety 3 Value" <> '' then begin
                    CalcFields("Variety 3 Table", "Variety 3");
                    ValidateVarietyValue(3, "Variety 3", "Variety 3 Table", "Variety 3 Value", xRec."Variety 3 Value");
                end;
            end;
        }
        field(6059989; "Variety 4"; Code[10])
        {
            CalcFormula = Lookup("NPR Item Worksheet Line"."Variety 4" WHERE("Worksheet Template Name" = FIELD("Worksheet Template Name"),
                                                                          "Worksheet Name" = FIELD("Worksheet Name"),
                                                                          "Line No." = FIELD("Worksheet Line No.")));
            Caption = 'Variety 4';
            Description = 'VRT1.00';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6059990; "Variety 4 Table"; Code[40])
        {
            CalcFormula = Lookup("NPR Item Worksheet Line"."Variety 4 Table (New)" WHERE("Worksheet Template Name" = FIELD("Worksheet Template Name"),
                                                                                      "Worksheet Name" = FIELD("Worksheet Name"),
                                                                                      "Line No." = FIELD("Worksheet Line No.")));
            Caption = 'Variety 4 Table';
            Description = 'VRT1.00';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6059991; "Variety 4 Value"; Code[50])
        {
            Caption = 'Variety 4 Value';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
            Editable = true;

            trigger OnLookup()
            var
                VarValue: Code[50];
            begin
                CalcFields("Variety 4", "Variety 4 Table");
                VarValue := "Variety 4 Value";
                if VarValue <> "Variety 4 Value" then
                    Validate("Variety 4 Value", VarValue);
            end;

            trigger OnValidate()
            begin
                if "Variety 4 Value" <> '' then begin
                    CalcFields("Variety 4 Table", "Variety 4");
                    ValidateVarietyValue(4, "Variety 3", "Variety 4 Table", "Variety 4 Value", xRec."Variety 4 Value");
                end;
            end;
        }
    }

    keys
    {
        key(Key1; "Worksheet Template Name", "Worksheet Name", "Worksheet Line No.", "Line No.")
        {
        }
        key(Key2; "Worksheet Template Name", "Worksheet Name", "Worksheet Line No.", "Variety 1 Value", "Variety 2 Value", "Variety 3 Value", "Variety 4 Value")
        {
        }
    }

    trigger OnDelete()
    var
        ItemWorksheetFieldChange: Record "NPR Item Worksh. Field Change";
    begin
        if "Variant Code" <> '' then begin
            //the variant is created. test if
        end;

        ItemWorksheetFieldChange.SetRange("Worksheet Template Name", "Worksheet Template Name");
        ItemWorksheetFieldChange.SetRange("Worksheet Name", "Worksheet Name");
        ItemWorksheetFieldChange.SetRange("Worksheet Line No.", "Worksheet Line No.");
        ItemWorksheetFieldChange.SetRange("Worksheet Variant Line No.", "Line No.");
        ItemWorksheetFieldChange.DeleteAll();
    end;

    trigger OnInsert()
    begin
        UpdateLevel();
    end;

    trigger OnModify()
    begin
        UpdateLevel();
    end;

    var
        Currency: Record Currency;
        ItemVariant: Record "Item Variant";
        ItemWorksheetTemplate: Record "NPR Item Worksh. Template";
        ItemWorksheetVariantLine2: Record "NPR Item Worksh. Variant Line";
        ItemWorksheet: Record "NPR Item Worksheet";
        ItemWorksheetLine: Record "NPR Item Worksheet Line";
        DimMgt: Codeunit DimensionManagement;
        ItemNumberManagement: Codeunit "NPR Item Number Mgt.";
        UpdateFromWorksheetLine: Boolean;
        RemoveMappingQst: Label 'Value >%1< is mapped to value >%2< already. Would you like to remove this mapping?', Comment = '%1 = New Variety Value; %2 = Variety Value';
        AddedVarietyLbl: Label 'Variety %1 Value %2 will be added to table copy.', Comment = '%1 = Variety Type; %2 = Variety Value';
        AddedVarietyUnlockedTableLbl: Label 'Variety %1 Value %2 will be added to unlocked table.', Comment = '%1 = Variety Type; %2 = Variety Value';
        ApplyMappingQst: Label 'Would you like to apply the new mapping to all other lines in this Item Worksheet?';
        ChangeVarietyInstanceQst: Label 'Would you like to change all instances of this Variety Value to this value in this line?';
        MapValueVarietyQst: Label 'Would you like to map the value >%1< to >%2< for all variety %3 table %4?', Comment = '%1 = Old Variety Value; %2 = Variety Value, %3 = Variety Type; %4 = Variety Table';
        StatusCommentText: Text;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateDimValueCode(FieldNumber, ShortcutDimCode);
    end;

    procedure GetBatch()
    begin
        if (ItemWorksheet."Item Template Name" <> "Worksheet Template Name") or
           (ItemWorksheet.Name <> "Worksheet Name") then begin
            ItemWorksheet.Get("Worksheet Template Name", "Worksheet Name");

            if ItemWorksheet."Currency Code" = '' then
                Currency.InitRoundingPrecision()
            else begin
                Currency.Get(ItemWorksheet."Currency Code");
                Currency.TestField("Amount Rounding Precision");
            end;
        end;
    end;

    procedure GetLine()
    begin
        if "Worksheet Line No." = 0 then
            ItemWorksheetLine.Init()
        else
            if ("Worksheet Template Name" <> ItemWorksheetLine."Worksheet Template Name") or
               ("Worksheet Name" <> ItemWorksheetLine."Worksheet Name") or
               ("Worksheet Line No." <> ItemWorksheetLine."Line No.") then
                ItemWorksheetLine.Get("Worksheet Template Name", "Worksheet Name", "Worksheet Line No.");
    end;

    procedure SetLine(ItemWorksheetLineParm: Record "NPR Item Worksheet Line")
    begin
        ItemWorksheetLine := ItemWorksheetLineParm;
    end;

    procedure CheckIfDeleteIsOK(): Boolean
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        PurchLine: Record "Purchase Line";
    begin
        //Variant is not created yet. Delete is ok
        if "Variant Code" = '' then
            exit(true);

        if "Item No." = '' then
            exit(true);

        //Check if variant is used

        ItemLedgEntry.SetCurrentKey("Item No.", Open, "Variant Code");
        ItemLedgEntry.SetRange("Item No.", "Item No.");
        ItemLedgEntry.SetRange("Variant Code", "Variant Code");
        if not ItemLedgEntry.IsEmpty then
            exit(false);

        PurchLine.SetCurrentKey(Type, "No.", "Variant Code");
        PurchLine.SetRange(Type, PurchLine.Type::Item);
        PurchLine.SetRange("No.", "Item No.");
        PurchLine.SetRange("Variant Code", "Variant Code");
        if not PurchLine.IsEmpty then
            exit(false);
        //variant is created, but not used yet
        exit(true);
    end;

    procedure GetUnitCost(): Decimal
    begin
        if "Direct Unit Cost" <> 0 then
            exit("Direct Unit Cost");

        GetLine();
        exit(ItemWorksheetLine."Direct Unit Cost");
    end;

    procedure GetUnitPrice(): Decimal
    begin
        if "Sales Price" <> 0 then
            exit("Sales Price");

        GetLine();
        exit(ItemWorksheetLine."Sales Price");
    end;

    local procedure GetExistingVariantPrice(): Decimal
    var
        PriceListLine: Record "Price List Line";
    begin
        PriceListLine.SetRange("Source Type", PriceListLine."Source Type"::"All Customers");
        PriceListLine.SetRange("Asset Type", PriceListLine."Asset Type"::Item);
        PriceListLine.SetRange("Asset No.", "Existing Item No.");
        PriceListLine.SetRange("Variant Code", "Existing Variant Code");
        PriceListLine.SetRange("Price Type", PriceListLine."Price Type"::Sale);
        PriceListLine.SetRange("Amount Type", PriceListLine."Amount Type"::Price);
        if PriceListLine.FindFirst() then
            exit(PriceListLine."Unit Price")
        else
            exit(0);
    end;

    local procedure GetExistingVariantCost(): Decimal
    var
        PriceListLine: Record "Price List Line";
    begin
        PriceListLine.SetRange("Source Type", PriceListLine."Source Type"::Vendor);
        PriceListLine.SetRange("Source No.", ItemWorksheetLine."Vendor No.");
        PriceListLine.SetRange("Asset Type", PriceListLine."Asset Type"::Item);
        PriceListLine.SetRange("Asset No.", "Existing Item No.");
        PriceListLine.SetRange("Variant Code", "Existing Variant Code");
        PriceListLine.SetRange("Price Type", PriceListLine."Price Type"::Purchase);
        PriceListLine.SetRange("Amount Type", PriceListLine."Amount Type"::Price);
        if PriceListLine.FindFirst() then
            exit(PriceListLine."Unit Price")
        else
            exit(0);
    end;

    procedure UpdateExistingItemAndVaraint()
    begin
        //TO BE IMPLEMENTED
    end;

    local procedure ValidateVarietyValue(VrtNo: Integer; VrtType: Code[10]; VrtTable: Code[40]; VrtValue: Code[50]; OldVrtValue: Code[50])
    var
        ItemWorksheetVariantLine: Record "NPR Item Worksh. Variant Line";
        ItemWorksheetVarValue: Record "NPR Item Worksh. Variety Value";
        VarietyValue: Record "NPR Variety Value";
        NewVarExists: Boolean;
        I: Integer;
        AddCommentText: Text;
    begin
        GetLine();
        ApplyVarietyMapping();
        if Action <> Action::Skip then begin
            if (VrtTable <> '') and (VrtValue <> '') then begin
                NewVarExists := ItemWorksheetVarValue.Get("Worksheet Template Name", "Worksheet Name", "Worksheet Line No.", VrtType, VrtTable, VrtValue);
                if ItemWorksheetVarValue.Get("Worksheet Template Name", "Worksheet Name", "Worksheet Line No.", VrtType, VrtTable, OldVrtValue) then begin
                    if (VrtValue <> OldVrtValue) then begin
                        if Confirm(ChangeVarietyInstanceQst) then begin
                            ItemWorksheetVariantLine.SetRange("Worksheet Template Name", ItemWorksheetVarValue."Worksheet Template Name");
                            ItemWorksheetVariantLine.SetRange("Worksheet Name", ItemWorksheetVarValue."Worksheet Name");
                            ItemWorksheetVariantLine.SetRange("Worksheet Line No.", ItemWorksheetVarValue."Worksheet Line No.");
                            I := 0;
                            repeat
                                I := I + 1;
                                case I of
                                    1:
                                        begin
                                            ItemWorksheetVariantLine.SetRange(ItemWorksheetVariantLine."Variety 1", ItemWorksheetVarValue.Type);
                                            ItemWorksheetVariantLine.SetRange(ItemWorksheetVariantLine."Variety 1 Table", ItemWorksheetVarValue.Table);
                                            ItemWorksheetVariantLine.SetRange(ItemWorksheetVariantLine."Variety 1 Value", OldVrtValue);
                                        end;
                                    2:
                                        begin
                                            ItemWorksheetVariantLine.SetRange(ItemWorksheetVariantLine."Variety 2", ItemWorksheetVarValue.Type);
                                            ItemWorksheetVariantLine.SetRange(ItemWorksheetVariantLine."Variety 2 Table", ItemWorksheetVarValue.Table);
                                            ItemWorksheetVariantLine.SetRange(ItemWorksheetVariantLine."Variety 2 Value", OldVrtValue);
                                        end;
                                    3:
                                        begin
                                            ItemWorksheetVariantLine.SetRange(ItemWorksheetVariantLine."Variety 3", ItemWorksheetVarValue.Type);
                                            ItemWorksheetVariantLine.SetRange(ItemWorksheetVariantLine."Variety 3 Table", ItemWorksheetVarValue.Table);
                                            ItemWorksheetVariantLine.SetRange(ItemWorksheetVariantLine."Variety 3 Value", OldVrtValue);
                                        end;
                                    4:
                                        begin
                                            ItemWorksheetVariantLine.SetRange(ItemWorksheetVariantLine."Variety 4", ItemWorksheetVarValue.Type);
                                            ItemWorksheetVariantLine.SetRange(ItemWorksheetVariantLine."Variety 4 Table", ItemWorksheetVarValue.Table);
                                            ItemWorksheetVariantLine.SetRange(ItemWorksheetVariantLine."Variety 4 Value", OldVrtValue);
                                        end;
                                end;
                                if ItemWorksheetVariantLine.FindFirst() then
                                    repeat
                                        case I of
                                            1:
                                                ItemWorksheetVariantLine."Variety 1 Value" := VrtValue;
                                            2:
                                                ItemWorksheetVariantLine."Variety 2 Value" := VrtValue;
                                            3:
                                                ItemWorksheetVariantLine."Variety 3 Value" := VrtValue;
                                            4:
                                                ItemWorksheetVariantLine."Variety 4 Value" := VrtValue;
                                        end;
                                        ItemWorksheetVariantLine.Modify();
                                    until ItemWorksheetVariantLine.Next() = 0;
                            until I = 4;
                            if NewVarExists then
                                ItemWorksheetVarValue.Delete()
                            else
                                ItemWorksheetVarValue.Rename("Worksheet Template Name", "Worksheet Name", "Worksheet Line No.", VrtType, VrtTable, VrtValue);
                        end;
                    end;
                end;
                if (ItemWorksheetLine."Vendor No." <> '') and (OldVrtValue <> '') and (OldVrtValue <> VrtValue) then begin
                    if Confirm(StrSubstNo(MapValueVarietyQst, OldVrtValue, VrtValue, VrtType, VrtTable)) then begin
                        CreateVarietyMapping(VrtType, VrtTable, '', '', ItemWorksheetLine."Vendor No.", OldVrtValue, VrtValue);
                        if Confirm(ApplyMappingQst) then begin
                            ItemWorksheetVariantLine.Reset();
                            ItemWorksheetVariantLine.SetRange("Worksheet Template Name", "Worksheet Template Name");
                            ItemWorksheetVariantLine.SetRange("Worksheet Name", "Worksheet Name");
                            ItemWorksheetVariantLine.SetFilter("Worksheet Line No.", '<>%1', ItemWorksheetVarValue."Worksheet Line No.");
                            if ItemWorksheetVariantLine.FindSet() then
                                repeat
                                    if ItemWorksheetVariantLine.ApplyVarietyMapping() then
                                        ItemWorksheetVariantLine.Modify(true);
                                until ItemWorksheetVariantLine.Next() = 0;
                        end;
                    end;
                end else begin
                    if not NewVarExists then begin
                        //Insert in the new value in Worksheet Value table
                        ItemWorksheetVarValue.Init();
                        ItemWorksheetVarValue.Validate("Worksheet Template Name", ItemWorksheetLine."Worksheet Template Name");
                        ItemWorksheetVarValue.Validate("Worksheet Name", ItemWorksheetLine."Worksheet Name");
                        ItemWorksheetVarValue.Validate("Worksheet Line No.", ItemWorksheetLine."Line No.");
                        ItemWorksheetVarValue.Validate(Type, VrtType);
                        ItemWorksheetVarValue.Validate(Table, VrtTable);
                        ItemWorksheetVarValue.Validate(Value, VrtValue);
                        ItemWorksheetVarValue.Insert(true);
                    end;
                    if not VarietyValue.Get(VrtType, VrtTable, VrtValue) and (StrLen(ItemWorksheetLine."Status Comment") < 247) then begin
                        if ItemWorksheetLine.IsCopyVariety(VrtNo) then
                            AddCommentText := StrSubstNo(AddedVarietyLbl, VrtType, VrtValue)
                        else
                            AddCommentText := StrSubstNo(AddedVarietyUnlockedTableLbl, VrtType, VrtValue);
                        if UpdateFromWorksheetLine then begin
                            if StatusCommentText = '' then
                                StatusCommentText := ItemWorksheetLine."Status Comment";
                            if StatusCommentText <> '' then
                                StatusCommentText := StatusCommentText + ' - ';
                            StatusCommentText := StatusCommentText + AddCommentText;
                        end else begin
                            if ItemWorksheetLine."Status Comment" <> '' then
                                ItemWorksheetLine."Status Comment" := CopyStr(ItemWorksheetLine."Status Comment" + ' - ', 1, MaxStrLen(ItemWorksheetLine."Status Comment"));
                            ItemWorksheetLine."Status Comment" := CopyStr(ItemWorksheetLine."Status Comment" + AddCommentText, 1, MaxStrLen(ItemWorksheetLine."Status Comment"));
                            ItemWorksheetLine.Modify(true);
                        end;
                    end;
                end;
                if GetExistingVariantCode() <> "Variant Code" then
                    Validate("Existing Variant Code", GetExistingVariantCode());
            end;
        end;
    end;

    local procedure UpdateLevel()
    begin
        Level := CalcLevel();
    end;

    procedure CalcLevel(): Integer
    begin
        ItemWorksheet.Get("Worksheet Template Name", "Worksheet Name");
        case ItemWorksheet."Show Variety Level" of
            ItemWorksheet."Show Variety Level"::"Variety 1":
                if "Variety 4 Value" <> '' then
                    exit(3)
                else
                    if "Variety 3 Value" <> '' then
                        exit(2)
                    else
                        if "Variety 2 Value" <> '' then
                            exit(1)
                        else
                            exit(0);
            ItemWorksheet."Show Variety Level"::"Variety 1+2":
                if "Variety 4 Value" <> '' then
                    exit(2)
                else
                    if "Variety 3 Value" <> '' then
                        exit(1)
                    else
                        exit(0);
            ItemWorksheet."Show Variety Level"::"Variety 1+2+3":
                if "Variety 4 Value" <> '' then
                    exit(1)
                else
                    exit(0);
            ItemWorksheet."Show Variety Level"::"Variety 1+2+3+4":
                exit(0);
        end;
    end;

    local procedure UpdateAllRemarks()
    begin
        GetLine();
        ItemWorksheetLine.UpdateVarietyHeadingText();
    end;

    procedure GetExistingVariantCode(): Code[20]
    var
        ItemVar: Record "Item Variant";
    begin
        if StrLen("Variety 2 Value") > 20 then
            exit('');
        if "Existing Item No." <> '' then begin
            ItemVar.Reset();
            ItemVar.SetRange("Item No.", "Existing Item No.");
            ItemVar.SetRange("NPR Variety 1 Value", "Variety 1 Value");
            ItemVar.SetRange("NPR Variety 2 Value", "Variety 2 Value");
            ItemVar.SetRange("NPR Variety 3 Value", "Variety 3 Value");
            ItemVar.SetRange("NPR Variety 4 Value", "Variety 4 Value");
            ItemVar.SetRange("NPR Blocked", false);
            if ItemVar.FindFirst() then begin
                exit(ItemVar.Code);
            end else begin
                ItemVar.SetRange("NPR Blocked", true);
                if ItemVar.FindFirst() then
                    exit(ItemVar.Code);
            end;
        end;
    end;

    procedure UpdateBarcode()
    begin
        ItemWorksheetTemplate.Get("Worksheet Template Name");
        if "Internal Bar Code" <> '' then
            case ItemWorksheetTemplate."Create Internal Barcodes" of
                ItemWorksheetTemplate."Create Internal Barcodes"::"As Cross Reference":
                    begin
                        ItemNumberManagement.UpdateBarcode("Item No.", "Variant Code", "Internal Bar Code", 1);
                    end;
            end;
        if "Vendors Bar Code" <> '' then
            case ItemWorksheetTemplate."Create Vendor  Barcodes" of
                ItemWorksheetTemplate."Create Vendor  Barcodes"::"As Cross Reference":
                    begin
                        ItemNumberManagement.UpdateBarcode("Item No.", "Variant Code", "Vendors Bar Code", 1);
                    end;
            end;
    end;

    procedure FillDescription()
    var
        VarietyCloneData: Codeunit "NPR Variety Clone Data";
        TempDesc: Text[250];
    begin
        CalcFields("Variety 1", "Variety 1 Table", "Variety 2", "Variety 2 Table",
          "Variety 3", "Variety 3 Table", "Variety 4", "Variety 4 Table");
        VarietyCloneData.GetVarietyDesc("Variety 1", "Variety 1 Table", "Variety 1 Value", TempDesc);
        VarietyCloneData.GetVarietyDesc("Variety 2", "Variety 2 Table", "Variety 2 Value", TempDesc);
        VarietyCloneData.GetVarietyDesc("Variety 3", "Variety 3 Table", "Variety 3 Value", TempDesc);
        VarietyCloneData.GetVarietyDesc("Variety 4", "Variety 4 Table", "Variety 4 Value", TempDesc);
        if "Existing Variant Code" = '' then
            Description := CopyStr(TempDesc, 1, MaxStrLen(Description));
    end;

    local procedure SetPropagationFilter()
    begin
        ItemWorksheetVariantLine2.Reset();
        ItemWorksheetVariantLine2.SetRange("Worksheet Template Name", "Worksheet Template Name");
        ItemWorksheetVariantLine2.SetRange("Worksheet Name", "Worksheet Name");
        ItemWorksheetVariantLine2.SetRange("Worksheet Line No.", "Worksheet Line No.");
        ItemWorksheetVariantLine2.SetFilter("Line No.", '<>%1', "Line No.");
        ItemWorksheetVariantLine2.SetFilter("Heading Text", '%1', '');
        if "Variety 4 Value" <> '' then
            ItemWorksheetVariantLine2.SetRange("Variety 4 Value", "Variety 4 Value");
        if "Variety 3 Value" <> '' then
            ItemWorksheetVariantLine2.SetRange("Variety 3 Value", "Variety 3 Value");
        if "Variety 2 Value" <> '' then
            ItemWorksheetVariantLine2.SetRange("Variety 2 Value", "Variety 2 Value");
        ItemWorksheetVariantLine2.SetRange("Variety 1 Value", "Variety 1 Value");
    end;

    local procedure CreateVarietyMapping(VrtType: Code[10]; VrtTable: Code[40]; WorksheetTemplate: Code[10]; WorksheetName: Code[10]; VendorNo: Code[20]; OldVrtValue: Code[50]; NewValue: Code[50])
    var
        ItemWorksheetVarietyMapping: Record "NPR Item Worksh. Vrty Mapping";
    begin
        if (VrtType = '') or (VrtTable = '') then
            exit;

        ItemWorksheetVarietyMapping.SetRange(Variety, VrtType);
        ItemWorksheetVarietyMapping.SetRange("Variety Table", VrtTable);
        ItemWorksheetVarietyMapping.SetRange("Worksheet Template Name", WorksheetTemplate);
        ItemWorksheetVarietyMapping.SetRange("Worksheet Name", WorksheetName);
        ItemWorksheetVarietyMapping.SetRange("Vendor No.", VendorNo);
        ItemWorksheetVarietyMapping.SetRange("Vendor Variety Value", NewValue);
        //Check whether the New value is mapped iteself
        if ItemWorksheetVarietyMapping.FindFirst() then
            if Confirm(StrSubstNo(RemoveMappingQst, NewValue, ItemWorksheetVarietyMapping."Variety Value")) then
                ItemWorksheetVarietyMapping.Delete(true)
            else
                exit;

        //Update or New insert Mapping
        ItemWorksheetVarietyMapping.SetRange("Vendor Variety Value", OldVrtValue);
        if not ItemWorksheetVarietyMapping.FindFirst() then begin
            ItemWorksheetVarietyMapping.Init();
            ItemWorksheetVarietyMapping.Validate(Variety, VrtType);
            ItemWorksheetVarietyMapping.Validate("Variety Table", VrtTable);
            ItemWorksheetVarietyMapping.Validate("Worksheet Template Name", WorksheetTemplate);
            ItemWorksheetVarietyMapping.Validate("Worksheet Name", WorksheetName);
            ItemWorksheetVarietyMapping.Validate("Vendor No.", VendorNo);
            ItemWorksheetVarietyMapping.Validate("Vendor Variety Value", OldVrtValue);
            ItemWorksheetVarietyMapping.Insert(true);
        end;
        ItemWorksheetVarietyMapping.Validate("Variety Value", NewValue);
        ItemWorksheetVarietyMapping.Modify(true);

        //Update any mapping that results in the Old value
        ItemWorksheetVarietyMapping.SetRange("Vendor Variety Value");
        ItemWorksheetVarietyMapping.SetRange("Variety Value", OldVrtValue);
        if ItemWorksheetVarietyMapping.FindSet() then
            repeat
                ItemWorksheetVarietyMapping."Variety Value" := NewValue;
                ItemWorksheetVarietyMapping.Modify();
            until ItemWorksheetVarietyMapping.Next() = 0;
    end;

    procedure ApplyVarietyMapping() VariantModified: Boolean
    var
        ItemWorksheetVarietyMapping: Record "NPR Item Worksh. Vrty Mapping";
        I: Integer;
    begin
        GetLine();
        ItemWorksheetVarietyMapping.Reset();
        ItemWorksheetVarietyMapping.SetFilter("Worksheet Template Name", '%1|%2', ItemWorksheetLine."Worksheet Template Name", '');
        ItemWorksheetVarietyMapping.SetFilter("Worksheet Name", '%1|%2', ItemWorksheetLine."Worksheet Name", '');
        ItemWorksheetVarietyMapping.SetFilter("Vendor No.", '%1|%2', ItemWorksheetLine."Vendor No.", '');
        I := 0;
        repeat
            I := I + 1;
            case I of
                1:
                    if "Variety 1 Value" <> '' then begin
                        ItemWorksheetVarietyMapping.SetRange(Variety, ItemWorksheetLine."Variety 1");
                        ItemWorksheetVarietyMapping.SetFilter("Variety Table", '%1|%2', ItemWorksheetLine."Variety 1 Table (New)", '');
                        ItemWorksheetVarietyMapping.SetRange("Vendor Variety Value", "Variety 1 Value");

                        SetExtraVarityFilter(ItemWorksheetLine, ItemWorksheetVarietyMapping);

                        if ItemWorksheetVarietyMapping.FindFirst() then begin
                            "Variety 1 Value" := ItemWorksheetVarietyMapping."Variety Value";
                            VariantModified := true;
                        end;
                    end;
                2:
                    if "Variety 2 Value" <> '' then begin
                        ItemWorksheetVarietyMapping.SetRange(Variety, ItemWorksheetLine."Variety 2");
                        ItemWorksheetVarietyMapping.SetFilter("Variety Table", '%1|%2', ItemWorksheetLine."Variety 2 Table (New)", '');
                        ItemWorksheetVarietyMapping.SetRange("Vendor Variety Value", "Variety 2 Value");

                        SetExtraVarityFilter(ItemWorksheetLine, ItemWorksheetVarietyMapping);

                        if ItemWorksheetVarietyMapping.FindFirst() then begin
                            "Variety 2 Value" := ItemWorksheetVarietyMapping."Variety Value";
                            VariantModified := true;
                        end;
                    end;
                3:
                    if "Variety 3 Value" <> '' then begin
                        ItemWorksheetVarietyMapping.SetRange(Variety, ItemWorksheetLine."Variety 3");
                        ItemWorksheetVarietyMapping.SetFilter("Variety Table", '%1|%2', ItemWorksheetLine."Variety 3 Table (New)", '');
                        ItemWorksheetVarietyMapping.SetRange("Vendor Variety Value", "Variety 3 Value");
                        SetExtraVarityFilter(ItemWorksheetLine, ItemWorksheetVarietyMapping);

                        if ItemWorksheetVarietyMapping.FindFirst() then begin
                            "Variety 3 Value" := ItemWorksheetVarietyMapping."Variety Value";
                            VariantModified := true;
                        end;
                    end;
                4:
                    if "Variety 4 Value" <> '' then begin
                        ItemWorksheetVarietyMapping.SetRange(Variety, ItemWorksheetLine."Variety 4");
                        ItemWorksheetVarietyMapping.SetFilter("Variety Table", '%1|%2', ItemWorksheetLine."Variety 4 Table (New)", '');
                        ItemWorksheetVarietyMapping.SetRange("Vendor Variety Value", "Variety 4 Value");
                        SetExtraVarityFilter(ItemWorksheetLine, ItemWorksheetVarietyMapping);

                        if ItemWorksheetVarietyMapping.FindFirst() then begin
                            "Variety 4 Value" := ItemWorksheetVarietyMapping."Variety Value";
                            VariantModified := true;
                        end;
                    end;
            end;
        until (I = 4);
    end;

    procedure SetUpdateFromWorksheetLine(VarUpdateFromWorksheetLine: Boolean)
    begin
        UpdateFromWorksheetLine := VarUpdateFromWorksheetLine;
    end;

    procedure GetStatusCommentText(): Text
    begin
        exit(StatusCommentText);
    end;

    local procedure SetExtraVarityFilter(var ItemWorksheetLine: Record "NPR Item Worksheet Line"; var ItemWorksheetVarietyMapping: Record "NPR Item Worksh. Vrty Mapping")
    var
        ItemWorksheetVarietyMapping2: Record "NPR Item Worksh. Vrty Mapping";
        RecRef: RecordRef;
        FldRef: FieldRef;
    begin
        ItemWorksheetVarietyMapping2.CopyFilters(ItemWorksheetVarietyMapping);
        ItemWorksheetVarietyMapping2.SetFilter("Item Wksh. Maping Field", '>%1', 0);
        if ItemWorksheetVarietyMapping2.FindSet() then begin
            repeat
                RecRef.GetTable(ItemWorksheetLine);
                FldRef := RecRef.Field(1);
                FldRef.SetFilter('%1', ItemWorksheetLine."Worksheet Template Name");
                FldRef := RecRef.Field(2);
                FldRef.SetFilter('%1', ItemWorksheetLine."Worksheet Name");
                FldRef := RecRef.Field(3);
                FldRef.SetFilter('%1', ItemWorksheetLine."Line No.");
                FldRef := RecRef.Field(ItemWorksheetVarietyMapping2."Item Wksh. Maping Field");
                FldRef.SetFilter('%1', ItemWorksheetVarietyMapping2."Item Wksh. Maping Field Value");
                if RecRef.FindFirst() then begin
                    ItemWorksheetVarietyMapping.SetRange("Item Wksh. Maping Field", ItemWorksheetVarietyMapping2."Item Wksh. Maping Field");
                    ItemWorksheetVarietyMapping.SetRange("Item Wksh. Maping Field Value", ItemWorksheetVarietyMapping2."Item Wksh. Maping Field Value");
                end;
            until ItemWorksheetVarietyMapping2.Next() = 0;
        end;
    end;
}

