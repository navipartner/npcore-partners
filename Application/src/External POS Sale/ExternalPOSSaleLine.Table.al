table 6014605 "NPR External POS Sale Line"
{
    Access = Internal;
    Caption = 'External POS Sale Line';
    DataClassification = CustomerContent;
    fields
    {
        field(1; "External POS Sale Entry No."; Integer)
        {
            Caption = 'External POS Sale Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR External POS Sale";
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
            Editable = false;
        }
        field(30; "Sale Type"; Option)
        {
            Caption = 'Sale Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Sale,Payment,Debit Sale,Gift Voucher,Credit Voucher,Deposit,Out payment,Comment,Cancelled,Open/Close';
            OptionMembers = Sale,Payment,"Debit Sale","Gift Voucher","Credit Voucher",Deposit,"Out payment",Comment,Cancelled,"Open/Close";
        }
        field(40; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(50; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            Description = 'NPR5.30';
            InitValue = Item;
            OptionCaption = 'G/L,Item,Item Group,Repair,,Payment,Open/Close,Inventory,Customer,Comment';
            OptionMembers = "G/L Entry",Item,"Item Group",Repair,,Payment,"Open/Close","BOM List",Customer,Comment;
        }
        field(60; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            TableRelation = IF (Type = CONST("G/L Entry")) "G/L Account"."No."
            ELSE
            IF (Type = CONST("Item Group")) "Item Category".Code
            ELSE
            IF (Type = CONST(Payment)) "NPR POS Payment Method".Code WHERE("Block POS Payment" = const(false))
            ELSE
            IF (Type = CONST(Customer)) Customer."No."
            ELSE
            IF (Type = CONST(Item)) Item."No.";
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                InitFromSalePOS();

                POSUnitGlobal.Get(Rec."Register No.");

                if (Type = Type::Item) and ("No." = '*') then begin
                    Type := Type::Comment;
                    "Sale Type" := "Sale Type"::Comment;
                end;

                case Type of
                    Type::"G/L Entry":
                        begin
                            InitFromGLAccount();
                            UpdateVATSetup();
                        end;
                    Type::Item, Type::"BOM List":
                        begin
                            InitFromItem();
                            UpdateVATSetup();
                            CalculateCostPrice();
                            Validate(Quantity);
                        end;
                    Type::"Item Group":
                        begin
                            InitFromItemCategory();
                            UpdateVATSetup();
                        end;
                    Type::Payment:
                        begin
                            InitFromPaymentTypePOS();
                        end;
                    Type::Customer:
                        begin
                            InitFromCustomer();
                        end;
                    else
                        exit;
                end;

                CreateDim(
                  NPRDimMgt.TypeToTableNPR(Type), "No.",
                   0, '',
                   0, '',
                   0, '');
            end;
        }

        field(43; "Serial No."; Code[50])
        {
            Caption = 'Serial No.';
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                SerialNoLookup();
            end;

            trigger OnValidate()
            begin
                SerialNoValidate();
                Validate("Unit Cost (LCY)", GetUnitCostLCY());
            end;
        }
        field(75; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location;
        }
        field(80; "Posting Group"; Code[20])
        {
            Caption = 'Posting Group';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = IF (Type = CONST(Item)) "Inventory Posting Group";
        }

        field(100; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }

        field(101; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
            DataClassification = CustomerContent;
            Description = 'NPR5.23';
        }

        field(102; "Custom Descr"; Boolean)
        {
            Caption = 'Customer Description';
            DataClassification = CustomerContent;
        }

        field(110; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = CustomerContent;
            TableRelation = IF (Type = CONST(Item),
                                "No." = FILTER(<> '')) "Item Unit of Measure".Code WHERE("Item No." = FIELD("No."))
            ELSE
            "Unit of Measure";

            trigger OnValidate()
            var
                UOMMgt: Codeunit "Unit of Measure Management";
            begin
                case Type of
                    Type::"G/L Entry":
                        begin
                            "Qty. per Unit of Measure" := 1;
                        end;
                    else begin
                            GetItem();
                            "Qty. per Unit of Measure" := UOMMgt.GetQtyPerUnitOfMeasure(Item, "Unit of Measure Code");
                            "Quantity (Base)" := CalcBaseQty(Quantity);
                        end;
                end;
            end;

        }
        field(120; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            MaxValue = 99.999;

            trigger OnValidate()
            var
                Err001: Label 'Quantity at %2 %1 can only be 1 or -1';
                Err003: Label 'A quantity must be specified on the line';
            begin
                if ("Serial No." <> '') and
                  ("Sale Type" = "Sale Type"::Sale) and
                    (Abs(Quantity) <> 1) then
                    Error(Err001,
                      "Serial No.", FieldName("Serial No."));

                if ("Serial No." <> '') then
                    Validate("Serial No.", "Serial No.");

                case Type of
                    Type::"G/L Entry":
                        begin
                            if Quantity = 0 then
                                Error(Err003);
                        end;
                    Type::Item:
                        begin
                            GetItem();
                            "Quantity (Base)" := CalcBaseQty(Quantity);

                            CalculateCostPrice();
                            UpdateAmounts(Rec);
                        end;
                end;
                UpdateCost();
            end;
        }

        field(57; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DataClassification = CustomerContent;
        }

        field(130; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Editable = false;
            InitValue = 1;
        }

        field(150; "Unit Price"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            Caption = 'Unit Price';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 2;
            Editable = true;
            MaxValue = 9999999;
        }
        field(155; "Price Includes VAT"; Boolean)
        {
            Caption = 'Price Includes VAT';
            DataClassification = CustomerContent;
        }

        field(170; "VAT %"; Decimal)
        {
            Caption = 'VAT %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }

        field(54; "VAT Base Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'VAT Base Amount';
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(180; "Discount Type"; Option)
        {
            Caption = 'Discount Type';
            DataClassification = CustomerContent;
            Description = 'NPR5.30';
            OptionCaption = ' ,Period,Mixed,Multiple Unit,Salesperson Discount,Inventory,,Rounding,Combination,Customer';
            OptionMembers = " ",Campaign,Mix,Quantity,Manual,"BOM List",,Rounding,Combination,Customer;
        }

        field(190; "Discount %"; Decimal)
        {
            Caption = 'Discount %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 1;
            MaxValue = 100;
            MinValue = 0;
        }
        field(200; "Discount Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Discount';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(250; "Date"; Date)
        {
            Caption = 'Date';
            DataClassification = CustomerContent;
        }
        field(300; Amount; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Amount';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 2;
            MaxValue = 1000000;

            trigger OnValidate()
            begin
                IF Type IN [Type::Item, Type::"Item Group", Type::"G/L Entry"] then
                    Rec."VAT Base Amount" := Rec.Amount;

                Rec."Line Amount" := Rec.Amount;
            end;
        }

        field(301; "Line Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Line Amount';
            DataClassification = CustomerContent;
        }
        field(310; "Amount Including VAT"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Amount Including VAT';
            DataClassification = CustomerContent;
            MaxValue = 99999999;
        }

        field(320; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = Currency;
        }

        field(330; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
            TableRelation = IF (Type = CONST(Item)) "Item Variant".Code WHERE("Item No." = FIELD("No."));
        }

        field(350; "Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Business Posting Group";
        }
        field(360; "Gen. Prod. Posting Group"; Code[20])
        {
            Caption = 'Gen. Prod. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Product Posting Group";
        }

        field(84; "Gen. Posting Type"; Enum "General Posting Type")
        {
            Caption = 'Gen. Posting Type';
            DataClassification = CustomerContent;
            Description = 'NPR5.31';

            trigger OnValidate()
            begin
                if "Gen. Posting Type" = "Gen. Posting Type"::Settlement then
                    FieldError("Gen. Posting Type");
                if "Gen. Posting Type" <> "Gen. Posting Type"::" " then
                    TestField(Type, Type::"G/L Entry");
            end;
        }

        field(370; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Business Posting Group";
        }
        field(380; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Product Posting Group";
        }

        field(381; "VAT Identifier"; Code[20])
        {
            Caption = 'VAT Identifier';
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(382; "VAT Calculation Type"; Enum "Tax Calculation Type")
        {
            Caption = 'VAT Calculation Type';
            DataClassification = CustomerContent;
        }

        field(385; "Tax Area Code"; Code[20])
        {
            Caption = 'Tax Area Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.31';
            TableRelation = "Tax Area";
        }

        field(390; "Tax Liable"; Boolean)
        {
            Caption = 'Tax Liable';
            DataClassification = CustomerContent;
            Description = 'NPR5.31';
        }
        field(400; "Tax Group Code"; Code[20])
        {
            Caption = 'Tax Group Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.31';
            TableRelation = "Tax Group";
        }
        field(410; "Use Tax"; Boolean)
        {
            Caption = 'Use Tax';
            DataClassification = CustomerContent;
            Description = 'NPR5.31';
        }

        field(440; "Return Sale Sales Ticket No."; Code[20])
        {
            Caption = 'Return Sale Sales Ticket No.';
            DataClassification = CustomerContent;
        }

        field(450; "Return Reason Code"; Code[10])
        {
            Caption = 'Return Reason Code';
            DataClassification = CustomerContent;
            TableRelation = "Return Reason";

            trigger OnValidate()
            var
                ReturnReason: Record "Return Reason";
            begin
                if "Return Reason Code" <> '' then begin
                    ReturnReason.Get("Return Reason Code");
                    if (ReturnReason."Default Location Code" <> '') and ("Location Code" <> ReturnReason."Default Location Code") then
                        Validate("Location Code", ReturnReason."Default Location Code");
                end else begin
                    GetPOSHeader();
                    if "Location Code" <> ExtSalePOS."Location Code" then
                        Validate("Location Code", ExtSalePOS."Location Code");
                    CalculateCostPrice();
                end;
            end;
        }
        field(460; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            DataClassification = CustomerContent;
            TableRelation = "Reason Code";
        }

        field(470; "Unit Cost"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            Caption = 'Unit Cost';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 2;
            Editable = false;

            trigger OnValidate()
            begin
                if "Unit Cost" <> 0 then begin
                    "Custom Cost" := true;
                    "Unit Cost (LCY)" := "Unit Cost";
                    UpdateCost();
                end else begin
                    "Custom Cost" := false;
                    Validate("No.");
                end;
            end;
        }

        field(475; "Unit Cost (LCY)"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Cost (LCY)';
            DataClassification = CustomerContent;
            Description = 'NPR5.45';

            trigger OnValidate()
            begin
                "Unit Cost" := "Unit Cost (LCY)";
                UpdateCost();
            end;
        }
        field(490; Cost; Decimal)
        {
            Caption = 'Cost';
            DataClassification = CustomerContent;
        }

        field(495; "Custom Cost"; Boolean)
        {
            Caption = 'Custom Cost';
            DataClassification = CustomerContent;
        }

        field(6050; "Item Category Code"; Code[20])
        {
            Caption = 'Item Category Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.00 [250375]';

            trigger OnValidate()
            begin
                CreateDim(
                   NPRDimMgt.TypeToTableNPR(Type), "No.",
                   0, '',
                   0, '',
                   0, '');
            end;
        }

        field(6060; "Magento Brand"; Code[20])
        {
            Caption = 'Magento Brand';
            DataClassification = CustomerContent;
            TableRelation = "NPR Magento Brand";
        }

        field(70; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                LookupShortcutDimCode(1, "Shortcut Dimension 1 Code");
                Validate("Shortcut Dimension 1 Code", "Shortcut Dimension 1 Code");
            end;

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
            end;
        }
        field(71; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                LookupShortcutDimCode(2, "Shortcut Dimension 2 Code");
                Validate("Shortcut Dimension 2 Code", "Shortcut Dimension 2 Code");
            end;

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
            end;
        }

        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            DataClassification = CustomerContent;
        }
        field(6005; "Currency Amount"; Decimal)
        {
            Caption = 'Currency Amount';
            DataClassification = CustomerContent;
        }

        field(6006; Accessory; Boolean)
        {
            Caption = 'Accessory';
            DataClassification = CustomerContent;
            InitValue = false;
        }
        field(6007; "Main Item No."; Code[21])
        {
            Caption = 'Main Item No.';
            DataClassification = CustomerContent;
        }

        field(6008; "Combination Item"; Boolean)
        {
            Caption = 'Combination Item';
            DataClassification = CustomerContent;
        }
        field(6009; "Combination No."; Code[20])
        {
            Caption = 'Combination No.';
            DataClassification = CustomerContent;
        }

        field(6100; "Main Line No."; Integer)
        {
            Caption = 'Main Line No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.40';
        }
    }

    keys
    {
        key(Key1; "External POS Sale Entry No.", "Line No.")
        {
        }

        key(Key2; "Register No.", "Sales Ticket No.", "Line No.")
        {

        }
    }

    fieldgroups
    {
    }

    var
        Item: Record Item;

        ExtSalePOS: Record "NPR External POS Sale";
        Currency: Record Currency;

        POSUnitGlobal: Record "NPR POS Unit";
        DimMgt: Codeunit DimensionManagement;

        NPRDimMgt: Codeunit "NPR Dimension Mgt.";

        TotalItemLedgerEntryQuantity: Decimal;
        TotalAuditRollQuantity: Decimal;

        Text002: Label '%1 %2 is used more than once. Adjust the inventory first, and then continue the transaction';

        Text004: Label '%1 %2 is already used.';

    local procedure InitFromGLAccount()
    var
        GLAccount: Record "G/L Account";
    begin
        if "No." = '' then
            exit;

        GLAccount.Get("No.");
        GLAccount.CheckGLAcc();
        Description := GLAccount.Name;
        "Gen. Posting Type" := GLAccount."Gen. Posting Type";
        "Gen. Prod. Posting Group" := GLAccount."Gen. Prod. Posting Group";
        "VAT Prod. Posting Group" := GLAccount."VAT Prod. Posting Group";
        "Tax Group Code" := GLAccount."Tax Group Code";
    end;

    local procedure InitFromItem()
    begin
        if "No." = '' then
            exit;

        TestItem();
        GetItem();
        "Gen. Prod. Posting Group" := Item."Gen. Prod. Posting Group";
        "VAT Prod. Posting Group" := Item."VAT Prod. Posting Group";
        "Item Category Code" := Item."Item Category Code";
        "Tax Group Code" := Item."Tax Group Code";
        "Posting Group" := Item."Inventory Posting Group";
        if "Unit of Measure Code" = '' then
            "Unit of Measure Code" := Item."Base Unit of Measure";

        "Magento Brand" := Item."NPR Magento Brand";

        if NOT Rec."Custom Descr" then begin
            if (Rec.Description = '') or (Rec.Description = ' ') then
                Rec.Description := CopyStr(Item.Description, 1, 30);

            Rec."Description 2" := CopyStr(Item."Description 2", 1, 30);
        end;
    end;

    local procedure InitFromItemCategory()
    var
        ItemCategory: Record "Item Category";
    begin
        if "No." = '' then
            exit;

        ItemCategory.Get("No.");
        GetItem();
        Item.TestField("NPR Group sale");
        "Gen. Prod. Posting Group" := Item."Gen. Prod. Posting Group";
        "VAT Prod. Posting Group" := Item."VAT Prod. Posting Group";
        "Tax Group Code" := Item."Tax Group Code";
        Description := CopyStr(ItemCategory.Description, 1, MaxStrLen(Description));
    end;

    local procedure InitFromPaymentTypePOS()
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
    begin
        if "No." = '' then
            exit;

        POSPaymentMethod.Get("No.");
        TestPaymentMethod(POSPaymentMethod);
        Description := POSPaymentMethod.Description;
    end;

    local procedure InitFromCustomer()
    var
        Customer: Record Customer;
        GLSetup: Record "General Ledger Setup";
    begin
        if "No." = '' then
            exit;

        Customer.Get("No.");
        Customer.TestField("Customer Posting Group");
        if Customer."Currency Code" <> '' then begin
            GLSetup.Get();
            Customer.TestField("Currency Code", GLSetup."LCY Code");
        end;

        Description := CopyStr(Customer.Name, 1, MaxStrLen(Description));
        Validate("Currency Code", Customer."Currency Code");
    end;

    procedure UpdateVATSetup()
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        if (Type = Type::"G/L Entry") then begin
            case "Gen. Posting Type" of
                "Gen. Posting Type"::" ":
                    begin
                        "VAT Calculation Type" := "VAT Calculation Type"::"Normal VAT";
                        "VAT %" := 0;
                        "Gen. Bus. Posting Group" := '';
                        "Gen. Prod. Posting Group" := '';
                        "VAT Bus. Posting Group" := '';
                        "VAT Prod. Posting Group" := '';
                    end;
                else begin
                        VATPostingSetup.Get("VAT Bus. Posting Group", "VAT Prod. Posting Group");
                        "VAT Identifier" := VATPostingSetup."VAT Identifier";
                        "VAT Calculation Type" := VATPostingSetup."VAT Calculation Type";
                    end;
            end;
        end else begin
            VATPostingSetup.Get("VAT Bus. Posting Group", "VAT Prod. Posting Group");
            "VAT Identifier" := VATPostingSetup."VAT Identifier";
            "VAT Calculation Type" := VATPostingSetup."VAT Calculation Type";
        end;
    end;

    procedure CalculateCostPrice()
    var
        VATPercent: Decimal;
    begin
        GetItem();

        if (Item."NPR Group sale") and (Item."Profit %" <> 0) then
            Validate("Unit Cost (LCY)", ((1 - Item."Profit %" / 100) * "Unit Price" / (1 + VATPercent / 100)) * "Qty. per Unit of Measure")
        else
            Validate("Unit Cost (LCY)", Item."Unit Cost" * "Qty. per Unit of Measure");
    end;

    local procedure UpdateCost()
    begin
        Cost := "Unit Cost (LCY)" * Quantity;
    end;

    local procedure TestItem()
    var
        ItemVariant: Record "Item Variant";
    begin
        if "No." = '' then
            exit;

        Item.Get("No.");
        Item.TestField(Blocked, false);
        Item.TestField("Gen. Prod. Posting Group");
        if Item.Type <> Item.Type::Service then
            Item.TestField("Inventory Posting Group");
        if Item."Price Includes VAT" then
            Item.TestField(Item."VAT Bus. Posting Gr. (Price)");
        if "Variant Code" <> '' then begin
            ItemVariant.Get(Item."No.", "Variant Code");
            ItemVariant.TestField("NPR Blocked", false);
        end;
    end;

    local procedure TestPaymentMethod(POSPaymentMethod: Record "NPR POS Payment Method")
    begin
        POSPaymentMethod.TestField("Block POS Payment", false);
    end;

    local procedure GetItem()
    begin
        TestField("No.");
        if "No." <> Item."No." then
            Item.Get("No.");
    end;

    local procedure CalcBaseQty(Qty: Decimal): Decimal
    begin
        TestField("Qty. per Unit of Measure");
        exit(Round(Qty * "Qty. per Unit of Measure", 0.00001));
    end;

    procedure SerialNoLookup()
    var
        xSaleLinePOS2: Record "NPR External POS Sale Line";
    begin
        xSaleLinePOS2 := Rec;
        if not SerialNoLookup2() then
            exit;
        if "Variant Code" <> xSaleLinePOS2."Variant Code" then
            Validate("Variant Code");
        Validate("Serial No.");
    end;

    procedure SerialNoLookup2(): Boolean
    var
        TempItemLedgerEntry: Record "Item Ledger Entry" temporary;
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        TestField("Sale Type", "Sale Type"::Sale);
        TestField(Type, Type::Item);

        GetItem();
        Item.TestField("Costing Method", Item."Costing Method"::Specific);
        ItemLedgerEntry.SetCurrentKey(Open, Positive, "Item No.", "Serial No.");
        ItemLedgerEntry.SetRange(Open, true);
        ItemLedgerEntry.SetRange(Positive, true);
        ItemLedgerEntry.SetRange("Item No.", "No.");
        ItemLedgerEntry.SetFilter("Serial No.", '<> %1', '');
        ItemLedgerEntry.SetRange("Location Code", "Location Code");
        if "Variant Code" <> '' then
            ItemLedgerEntry.SetRange("Variant Code", "Variant Code");
        ItemLedgerEntry.SetRange("Global Dimension 1 Code", "Shortcut Dimension 1 Code");
        if ItemLedgerEntry.Find('-') then
            repeat
                ItemLedgerEntry.SetRange("Serial No.", ItemLedgerEntry."Serial No.");
                ItemLedgerEntry.FindLast();
                TempItemLedgerEntry := ItemLedgerEntry;
                TempItemLedgerEntry.Insert();
                ItemLedgerEntry.SetRange("Serial No.");
            until ItemLedgerEntry.Next() = 0;

        TempItemLedgerEntry.SetFilter("Expiration Date", '<>%1', 0D);
        if not TempItemLedgerEntry.IsEmpty then
            TempItemLedgerEntry.SetCurrentKey("Expiration Date");
        TempItemLedgerEntry.SetRange("Expiration Date");
        if "Serial No." <> '' then
            TempItemLedgerEntry.SetRange("Serial No.", "Serial No.");
        if TempItemLedgerEntry.FindFirst() then;
        TempItemLedgerEntry.SetRange("Serial No.");
        if PAGE.RunModal(PAGE::"NPR Item - Series Number", TempItemLedgerEntry) <> ACTION::LookupOK then
            exit(false);

        "Serial No." := TempItemLedgerEntry."Serial No.";

        TempItemLedgerEntry.CalcFields("Cost Amount (Actual)");
        "Variant Code" := TempItemLedgerEntry."Variant Code";
        "Unit Cost (LCY)" := TempItemLedgerEntry."Cost Amount (Actual)";
        "Unit Cost" := "Unit Cost (LCY)";
        "Custom Cost" := true;

        exit(true);
    end;

    local procedure GetPOSHeader()
    var
        ExtSalePOS2: Record "NPR External POS Sale";
    begin
        if ExtSalePOS2.Get(Rec."External POS Sale Entry No.") then
            ExtSalePOS := ExtSalePOS2;
        Currency.InitRoundingPrecision();
    end;

    local procedure InitFromSalePOS()
    begin
        GetPOSHeader();
        "Register No." := ExtSalePOS."Register No.";
        "Sales Ticket No." := ExtSalePOS."Sales Ticket No.";
        Rec.Date := ExtSalePOS.Date;
        "Location Code" := ExtSalePOS."Location Code";
        "Gen. Bus. Posting Group" := ExtSalePOS."Gen. Bus. Posting Group";
        "VAT Bus. Posting Group" := ExtSalePOS."VAT Bus. Posting Group";
        "Tax Area Code" := ExtSalePOS."Tax Area Code";
        "Tax Liable" := ExtSalePOS."Tax Liable";
    end;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, Rec."Dimension Set ID");
    end;

    procedure LookupShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.LookupDimValueCode(FieldNumber, ShortcutDimCode);
        ValidateShortcutDimCode(FieldNumber, ShortcutDimCode);
    end;

    procedure UpdateAmounts(var ExtSaleLinePOS: Record "NPR External POS Sale Line")
    begin
        ExtSaleLinePOS."Discount %" := Abs(ExtSaleLinePOS."Discount %");
    end;

    procedure GetUnitCostLCY(): Decimal
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ItemTrackingCode: Record "Item Tracking Code";
        TxtNoSerial: Label 'No open Item Ledger Entry has been found with the Serial No. %2';
    begin
        if "Custom Cost" then
            exit("Unit Cost");

        if ("Serial No." <> '') and (Quantity > 0) then begin
            GetItem();
            Item.TestField("Item Tracking Code");
            ItemTrackingCode.Get(Item."Item Tracking Code");
            if ItemTrackingCode."SN Specific Tracking" then begin
                ItemLedgerEntry.SetCurrentKey(Open, Positive, "Item No.", "Serial No.");
                ItemLedgerEntry.SetRange(Open, true);
                ItemLedgerEntry.SetRange(Positive, true);
                ItemLedgerEntry.SetRange("Item No.", "No.");
                ItemLedgerEntry.SetRange("Serial No.", "Serial No.");
                if not ItemLedgerEntry.FindFirst() then begin
                    Message(TxtNoSerial, "Serial No.");
                    exit(0);
                end;
                ItemLedgerEntry.CalcFields("Cost Amount (Actual)");
                exit(ItemLedgerEntry."Cost Amount (Actual)");
            end;
        end;
    end;

    procedure SerialNoValidate()
    var
        SaleLinePOS2: Record "NPR POS Sale Line";
        NPRSalePOS: Record "NPR POS Sale";
        ItemTrackingCode: Record "Item Tracking Code";
        Positive: Boolean;
        Txt004: Label '%2 %1 has already sold!';
        Txt005: Label '%2 %1 is already in stock!';
        TotalNonAppliedQuantity: Decimal;
    begin
        if "Serial No." = '' then
            exit;

        TotalAuditRollQuantity := 0;
        TotalItemLedgerEntryQuantity := 0;
        TestField("Sale Type", "Sale Type"::Sale);
        TestField(Quantity);

        GetItem();
        Item.TestField("Item Tracking Code");
        ItemTrackingCode.Get(Item."Item Tracking Code");

        SaleLinePOS2.SetCurrentKey("Serial No.");
        SaleLinePOS2.SetRange("Serial No.", "Serial No.");
        if SaleLinePOS2.FindSet() then
            repeat
                NPRSalePOS.Get(SaleLinePOS2."Register No.", SaleLinePOS2."Sales Ticket No.");
                if (SaleLinePOS2."Sales Ticket No." <> "Sales Ticket No.") or (SaleLinePOS2."Line No." <> "Line No.") then
                    Error(Text004, FieldName("Serial No."), "Serial No.");
            until SaleLinePOS2.Next() = 0;

        if Quantity <> Abs(1) then
            Quantity := 1 * (Quantity / Abs(Quantity));
        Positive := (Quantity >= 0);

        if ItemTrackingCode."SN Specific Tracking" then begin
            CheckSerialNoApplication("No.", "Serial No.");
            CheckSerialNoAuditRoll("No.", "Serial No.", Positive);
            if Positive then begin
                TotalNonAppliedQuantity := TotalItemLedgerEntryQuantity - TotalAuditRollQuantity - Quantity;
                if (TotalNonAppliedQuantity < 0) then begin
                    Message(Txt004, "Serial No.", FieldName("Serial No."));
                    "Serial No." := '';
                end;
            end else begin
                TotalNonAppliedQuantity := TotalItemLedgerEntryQuantity - TotalAuditRollQuantity - Quantity;
                if TotalNonAppliedQuantity > 1 then begin
                    Message(Txt005, "Serial No.", FieldName("Serial No."));
                    "Serial No." := '';
                end;
            end;
        end;
    end;

    procedure CheckSerialNoApplication(ItemNo: Code[20]; SerialNo: Code[50])
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ItemLedgerEntry.SetCurrentKey(Open, Positive, "Item No.", "Serial No.");
        ItemLedgerEntry.SetRange("Item No.", ItemNo);
        ItemLedgerEntry.SetRange(Open, true);
        ItemLedgerEntry.SetRange(Positive, true);
        ItemLedgerEntry.SetRange("Serial No.", SerialNo);
        if ItemLedgerEntry.FindFirst() then begin
            ItemLedgerEntry.CalcSums(Quantity);
            TotalItemLedgerEntryQuantity := ItemLedgerEntry.Quantity;
            if ItemLedgerEntry.Count() > 1 then
                Error(Text002, FieldName("Serial No."), "Serial No.");
        end;
    end;

    procedure CheckSerialNoAuditRoll(ItemNo: Code[20]; SerialNo: Code[50]; Positive: Boolean)
    var
        Err001: Label '%2 %1 is already in stock but has not been posted yet';
        Err002: Label '%2 %1 has already been sold to a customer but is not yet posted';
        POSSalesLine: Record "NPR POS Entry Sales Line";
    begin
        POSSalesLine.SetRange("Item Entry No.", 0);
        POSSalesLine.SetRange("Serial No.", "Serial No.");
        if POSSalesLine.FindFirst() then
            POSSalesLine.CalcSums(Quantity);
        TotalAuditRollQuantity := POSSalesLine.Quantity;

        if Positive then begin
            if POSSalesLine.Quantity = -1 then
                Error(Err001, "Serial No.", FieldName("Serial No."));
        end else begin
            if POSSalesLine.Quantity = 1 then
                Error(Err002, "Serial No.", FieldName("Serial No."));
        end;
    end;

    procedure CreateDim(Type1: Integer; No1: Code[20]; Type2: Integer; No2: Code[20]; Type3: Integer; No3: Code[20]; Type4: Integer; No4: Code[20])
    var
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
    begin
        GetPOSHeader();

        TableID[1] := Type1;
        No[1] := No1;
        TableID[2] := Type2;
        No[2] := No2;
        TableID[3] := Type3;
        No[3] := No3;
        TableID[3] := Type3;
        No[3] := No3;
        TableID[4] := Type4;
        No[4] := No4;

        Rec."Shortcut Dimension 1 Code" := '';
        Rec."Shortcut Dimension 2 Code" := '';

        "Dimension Set ID" :=
          DimMgt.GetDefaultDimID(
            TableID, No, ExtSalePOS.GetPOSSourceCode(),
            Rec."Shortcut Dimension 1 Code", Rec."Shortcut Dimension 2 Code",
            ExtSalePOS."Dimension Set ID", DATABASE::Customer);
        DimMgt.UpdateGlobalDimFromDimSetID(Rec."Dimension Set ID", Rec."Shortcut Dimension 1 Code", Rec."Shortcut Dimension 2 Code");
    end;

    procedure GetCurrency(var CurrencyOut: Record Currency)
    begin
        CurrencyOut := Currency;
    end;
}
