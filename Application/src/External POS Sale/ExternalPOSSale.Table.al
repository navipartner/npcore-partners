table 6014606 "NPR External POS Sale"
{
    Caption = 'External POS Sale';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }

        field(10; "Register No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit";
        }
        field(20; "Sales Ticket No."; Code[20])
        {
            Caption = 'Sales Ticket No.';
            DataClassification = CustomerContent;
        }

        field(30; "POS Store Code"; Code[10])
        {
            Caption = 'POS Store Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.30';
            TableRelation = "NPR POS Store";
            trigger OnValidate()
            begin
                CreateDim(
                  DATABASE::"NPR POS Unit", "Register No.",
                  DATABASE::"NPR POS Store", "POS Store Code",
                  DATABASE::Job, "Event No.",
                  DATABASE::Customer, "Customer No.",
                  DATABASE::"Salesperson/Purchaser", "Salesperson Code");
            end;
        }

        field(40; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser".Code;
            trigger OnValidate()
            begin
                CreateDim(
                  DATABASE::"NPR POS Unit", "Register No.",
                  DATABASE::"NPR POS Store", "POS Store Code",
                  DATABASE::Job, "Event No.",
                  DATABASE::Customer, "Customer No.",
                  DATABASE::"Salesperson/Purchaser", "Salesperson Code");
            end;
        }

        field(50; "Date"; Date)
        {
            Caption = 'Date';
            DataClassification = CustomerContent;
        }

        field(60; "Start Time"; Time)
        {
            Caption = 'Start Time';
            DataClassification = CustomerContent;
        }

        field(65; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
        }

        field(70; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                SaleLinePOS: Record "NPR External POS Sale Line";
                Item: Record Item;
                POSPostingProfile: Record "NPR POS Posting Profile";
                Cust: Record Customer;
                xSaleLinePOS: Record "NPR External POS Sale Line";
                FoundPostingProfile: Boolean;
            begin
                GetPOSUnit();
                "POS Store Code" := POSUnit."POS Store Code";
                GetPOSStore();

                FoundPostingProfile := POSStore.GetProfile(POSPostingProfile);
                "Gen. Bus. Posting Group" := POSPostingProfile."Gen. Bus. Posting Group";
                "Tax Area Code" := POSPostingProfile."Tax Area Code";
                "Tax Liable" := POSPostingProfile."Tax Liable";
                "VAT Bus. Posting Group" := POSPostingProfile."VAT Bus. Posting Group";

                IF "Customer No." <> '' then begin
                    Cust.Get("Customer No.");
                    if not FoundPostingProfile then begin
                        "Gen. Bus. Posting Group" := Cust."Gen. Bus. Posting Group";
                        "Tax Area Code" := Cust."Tax Area Code";
                        "Tax Liable" := Cust."Tax Liable";
                        "VAT Bus. Posting Group" := Cust."VAT Bus. Posting Group";
                    end else begin
                        if POSPostingProfile."Default POS Posting Setup" = POSPostingProfile."Default POS Posting Setup"::Customer then begin
                            "Gen. Bus. Posting Group" := Cust."Gen. Bus. Posting Group";
                            "Tax Area Code" := Cust."Tax Area Code";
                            "Tax Liable" := Cust."Tax Liable";
                            "VAT Bus. Posting Group" := Cust."VAT Bus. Posting Group";
                        end else begin
                            "Gen. Bus. Posting Group" := POSPostingProfile."Gen. Bus. Posting Group";
                            "Tax Area Code" := POSPostingProfile."Tax Area Code";
                            "Tax Liable" := POSPostingProfile."Tax Liable";
                            "VAT Bus. Posting Group" := POSPostingProfile."VAT Bus. Posting Group";
                        end;
                    end;

                    SaleLinePOS.Reset();
                    SaleLinePOS.SetRange("Register No.", "Register No.");
                    SaleLinePOS.SetRange("Sales Ticket No.", "Sales Ticket No.");
                    SaleLinePOS.SetRange("Sale Type", SaleLinePOS."Sale Type"::Sale);
                    SaleLinePOS.SetRange(Type, SaleLinePOS.Type::Item);
                    SaleLinePOS.SetRange(Date, Date);
                    if SaleLinePOS.FindSet(true, false) then begin
                        repeat
                            xSaleLinePOS := SaleLinePOS;
                            Item.Get(SaleLinePOS."No.");
                            SaleLinePOS."Gen. Bus. Posting Group" := "Gen. Bus. Posting Group";
                            SaleLinePOS."VAT Bus. Posting Group" := "VAT Bus. Posting Group";
                            SaleLinePOS."Tax Area Code" := "Tax Area Code";
                            SaleLinePOS."Tax Liable" := "Tax Liable";
                            SaleLinePOS.Modify();
                        until SaleLinePOS.Next() = 0;
                    end;
                end;

                CreateDim(
                  DATABASE::Customer, "Customer No.",
                  DATABASE::"NPR POS Unit", "Register No.",
                  DATABASE::"NPR POS Store", "POS Store Code",
                  DATABASE::Job, "Event No.",
                  DATABASE::"Salesperson/Purchaser", "Salesperson Code");
            end;
        }

        field(81; "Country Code"; Code[10])
        {
            Caption = 'Country Code';
            DataClassification = CustomerContent;
            TableRelation = "Country/Region";
        }

        field(85; "Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            DataClassification = CustomerContent;
            Description = 'NPR5.31';
            TableRelation = "Gen. Business Posting Group";
        }
        field(90; Reference; Text[35])
        {
            Caption = 'Reference';
            DataClassification = CustomerContent;
        }

        field(95; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                LookUpShortcutDimCode(1, "Shortcut Dimension 1 Code");
                Validate("Shortcut Dimension 1 Code", "Shortcut Dimension 1 Code");
            end;

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
            end;
        }
        field(96; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                LookUpShortcutDimCode(2, "Shortcut Dimension 2 Code");
                Validate("Shortcut Dimension 2 Code", "Shortcut Dimension 2 Code");
            end;

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
            end;
        }

        field(128; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
            DataClassification = CustomerContent;
        }

        field(141; "Tax Area Code"; Code[20])
        {
            Caption = 'Tax Area Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.31';
            TableRelation = "Tax Area";
        }
        field(142; "Tax Liable"; Boolean)
        {
            Caption = 'Tax Liable';
            DataClassification = CustomerContent;
            Description = 'NPR5.31';
        }
        field(143; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            DataClassification = CustomerContent;
            Description = 'NPR5.31';
            TableRelation = "VAT Business Posting Group";
        }

        field(120; "Prices Including VAT"; Boolean)
        {
            Caption = 'Prices Including VAT';
            DataClassification = CustomerContent;
        }

        field(145; "Event No."; Code[20])
        {
            Caption = 'Event No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.53 [376035]';
            TableRelation = Job WHERE("NPR Event" = CONST(true));

            trigger OnValidate()
            begin
                CreateDim(
                  DATABASE::Job, "Event No.",
                  DATABASE::"NPR POS Unit", "Register No.",
                  DATABASE::"NPR POS Store", "POS Store Code",
                  DATABASE::Customer, "Customer No.",
                  DATABASE::"Salesperson/Purchaser", "Salesperson Code");
            end;
        }

        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                ShowDocDim();
            end;
        }

        field(210; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
            Editable = false;
        }

        field(1550; "Converted To POS Entry"; Boolean)
        {
            Caption = 'Converted To POS Entry';
            DataClassification = SystemMetadata;
        }

        field(1551; "Has Conversion Error"; Boolean)
        {
            Caption = 'Has Conversion Error';
            DataClassification = SystemMetadata;
            trigger OnValidate()
            begin
                IF Not "Has Conversion Error" then
                    Rec."Last Conversion Error Message" := '';
            end;
        }

        field(1552; "Last Conversion Error Message"; Text[250])
        {
            Caption = 'Has Conversion Error';
            DataClassification = SystemMetadata;
        }

        field(1560; "POS Entry System Id"; Guid)
        {
            Caption = 'POS Entry System Id';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }

        key(Key2; "Register No.", "Sales Ticket No.")
        {
        }

        key(Key3; "Converted To POS Entry", "Has Conversion Error", "POS Store Code")
        {
        }
    }


    local procedure GetPOSUnit()
    begin
        if POSUnit."No." <> "Register No." then
            POSUnit.Get("Register No.");
    end;

    local procedure GetPOSStore()
    begin
        if "POS Store Code" = '' then begin
            if POSStore.Code <> POSUnit."POS Store Code" then
                POSStore.get(POSUnit."POS Store Code")
        end else begin
            if POSStore.Code <> "POS Store Code" then
                POSStore.Get("POS Store Code");
        end;
    end;

    procedure CreateDim(Type1: Integer; No1: Code[20]; Type2: Integer; No2: Code[20]; Type3: Integer; No3: Code[20]; Type4: Integer; No4: Code[20]; Type5: Integer; No5: Code[20])
    var
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
        OldDimSetID: Integer;
    begin
        TableID[1] := Type1;
        No[1] := No1;
        TableID[2] := Type2;
        No[2] := No2;
        TableID[3] := Type3;
        No[3] := No3;
        TableID[4] := Type4;
        No[4] := No4;
        TableID[5] := Type5;
        No[5] := No5;
        Rec."Shortcut Dimension 1 Code" := '';
        Rec."Shortcut Dimension 2 Code" := '';
        OldDimSetID := Rec."Dimension Set ID";
        Rec."Dimension Set ID" :=
          DimMgt.GetDefaultDimID(TableID, No, GetPOSSourceCode(), Rec."Shortcut Dimension 1 Code", Rec."Shortcut Dimension 2 Code", 0, 0);

        if (OldDimSetID <> "Dimension Set ID") then begin
            if SalesLinesExist() then
                UpdateAllLineDim("Dimension Set ID", OldDimSetID);
        end;
    end;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    var
        OldDimSetID: Integer;
    begin
        OldDimSetID := Rec."Dimension Set ID";
        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, Rec."Dimension Set ID");
        if Rec."Sales Ticket No." <> '' then
            Rec.Modify();

        if OldDimSetID <> Rec."Dimension Set ID" then begin
            Rec.Modify();
            if SalesLinesExist() then
                UpdateAllLineDim("Dimension Set ID", OldDimSetID);
        end;
    end;

    procedure ShowDocDim()
    var
        OldDimSetID: Integer;
        DimSetIdLbl: Label '%1 %2', Locked = true;
    begin
        OldDimSetID := "Dimension Set ID";
        "Dimension Set ID" :=
          DimMgt.EditDimensionSet(
            "Dimension Set ID", StrSubstNo(DimSetIdLbl, "Register No.", "Sales Ticket No."),
            "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
        if OldDimSetID <> "Dimension Set ID" then begin
            Rec.Modify();
            if SalesLinesExist() then
                UpdateAllLineDim("Dimension Set ID", OldDimSetID);
        end;
    end;

    procedure UpdateAllLineDim(NewParentDimSetID: Integer; OldParentDimSetID: Integer)
    var
        ExtSaleLinePOS: Record "NPR External POS Sale Line";
        NewDimSetID: Integer;
    begin
        // Update all lines with changed dimensions.
        if NewParentDimSetID = OldParentDimSetID then
            exit;

        ExtSaleLinePOS.SetRange("External POS Sale Entry No.", Rec."Entry No.");
        ExtSaleLinePOS.LockTable();
        if ExtSaleLinePOS.FindSet() then
            repeat
                NewDimSetID := DimMgt.GetDeltaDimSetID(ExtSaleLinePOS."Dimension Set ID", NewParentDimSetID, OldParentDimSetID);
                if ExtSaleLinePOS."Dimension Set ID" <> NewDimSetID then begin
                    ExtSaleLinePOS."Dimension Set ID" := NewDimSetID;
                    DimMgt.UpdateGlobalDimFromDimSetID(
                      ExtSaleLinePOS."Dimension Set ID", ExtSaleLinePOS."Shortcut Dimension 1 Code", ExtSaleLinePOS."Shortcut Dimension 2 Code");
                    ExtSaleLinePOS.Modify();
                end;
            until ExtSaleLinePOS.Next() = 0;
    end;

    procedure GetPOSSourceCode() SourceCode: Code[10]
    var
        NPRPOSUnit: Record "NPR Pos Unit";
        NPRPOSStore: Record "NPR POS Store";
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        SourceCode := '';

        if NPRPOSUnit.Get(Rec."Register No.") then begin
            NPRPOSStore.Get(NPRPOSUnit."POS Store Code");
            if NPRPOSStore.GetProfile(POSPostingProfile) then begin
                SourceCode := POSPostingProfile."Source Code";
            end;
        end;
    end;

    procedure LookUpShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        NPRDimMgt.LookupDimValueCode(FieldNumber, ShortcutDimCode);
    end;

    procedure SalesLinesExist(): Boolean
    var
        ExtSaleLinePOS: Record "NPR External POS Sale Line";
    begin
        ExtSaleLinePOS.SetRange("External POS Sale Entry No.", Rec."Entry No.");
        exit(ExtSaleLinePOS.FindFirst());
    end;

    trigger OnInsert()
    begin
        GetPOSUnit();
        GetPOSStore();
        "POS Store Code" := POSStore.Code;
        "Location Code" := POSStore."Location Code";
        "User ID" := UserId;
    end;

    var
        POSUnit: Record "NPR POS Unit";
        POSStore: Record "NPR POS Store";
        DimMgt: Codeunit DimensionManagement;
        NPRDimMgt: Codeunit "NPR Dimension Mgt.";

}