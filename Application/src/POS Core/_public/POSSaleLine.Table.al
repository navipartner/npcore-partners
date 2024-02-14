table 6014406 "NPR POS Sale Line"
{
    Caption = 'POS Sale Line';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR POS Sale Lines Subpage";
    PasteIsValid = false;

    fields
    {
        field(1; "Register No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR POS Unit";
        }
        field(2; "Sales Ticket No."; Code[20])
        {
            Caption = 'Sales Ticket No.';
            DataClassification = CustomerContent;
            Editable = false;
            NotBlank = true;
        }
        field(3; "Sale Type"; Enum "NPR POS Line Sale Type")
        {
            Caption = 'Sale Type';
            DataClassification = CustomerContent;
            Description = 'This field has been "obsoleted" by removing all reference to it in Np Retail app. No need to assing it or filter on it';
        }
        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(5; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            Description = 'NPR5.30';
            InitValue = Item;
            OptionCaption = 'G/L,Item,Item Group,Repair,,Payment,Open/Close,Inventory,Customer,Comment';
            OptionMembers = "G/L Entry",Item,"Item Group",Repair,,Payment,"Open/Close","BOM List",Customer,Comment;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Use Line Type';
        }
        field(6; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            TableRelation = IF ("Line Type" = filter("GL Payment" | "Issue Voucher")) "G/L Account"."No."
            ELSE
            IF ("Line Type" = CONST("Item Category")) "Item Category".Code
            ELSE
            IF ("Line Type" = CONST("POS Payment")) "NPR POS Payment Method".Code WHERE("Block POS Payment" = const(false))
            ELSE
            IF ("Line Type" = CONST("Customer Deposit")) Customer."No."
            ELSE
            IF ("Line Type" = CONST(Item)) Item."No.";

            trigger OnValidate()
            var
                POSSaleTranslation: Codeunit "NPR POS Sale Translation";
            begin
                InitFromSalePOS();

                POSUnitGlobal.Get(Rec."Register No.");

                if ("Line Type" = "Line Type"::Item) and ("No." = '*') then begin
                    "Line Type" := "Line Type"::Comment;
                end;

                case "Line Type" of
                    "Line Type"::"GL Payment",
                    "Line Type"::Rounding,
                    "Line Type"::"Issue Voucher":
                        begin
                            InitFromGLAccount();
                            UpdateVATSetup();
                        end;
                    "Line Type"::Item, "Line Type"::"BOM List":
                        begin
                            InitFromItem();
                            UpdateVATSetup();
                            "Unit Price" := FindItemSalesPrice();
                            Validate(Quantity);
                            POSSaleTranslation.AssignTranslationOnPOSSaleLine(Rec, SalePOS);
                            if "No." <> xRec."No." then
                                GetDefaultBin();
                        end;
                    "Line Type"::"Item Category":
                        begin
                            InitFromItemCategory();
                            UpdateVATSetup();
                        end;
                    "Line Type"::"POS Payment":
                        begin
                            InitFromPaymentTypePOS();
                        end;
                    "Line Type"::"Customer Deposit":
                        begin
                            InitFromCustomer();
                        end;
                    else
                        exit;
                end;

                CreateDimFromDefaultDim(FieldNo("No."));
            end;
        }
        field(7; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location;

            trigger OnValidate()
            begin
                if "Location Code" <> xRec."Location Code" then
                    GetDefaultBin();

                CreateDimFromDefaultDim(Rec.FieldNo("Location Code"));
            end;
        }
        field(8; "Posting Group"; Code[20])
        {
            Caption = 'Posting Group';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = IF ("Line Type" = CONST(Item)) "Inventory Posting Group";
        }
        field(9; "Qty. Discount Code"; Code[20])
        {
            Caption = 'Qty. Discount Code';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(11; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = CustomerContent;
            TableRelation = IF ("Line Type" = CONST(Item),
                                "No." = FILTER(<> '')) "Item Unit of Measure".Code WHERE("Item No." = FIELD("No."))
            ELSE
            "Unit of Measure";

            trigger OnValidate()
            var
                UOMMgt: Codeunit "Unit of Measure Management";
                NPRPOSIUOMUtils: Codeunit "NPR POS IUOM Utils";
            begin
                case "Line Type" of
                    "Line Type"::"GL Payment", "Line Type"::"Issue VOucher", "Line Type"::Rounding, "Line Type"::"Issue Voucher", "Line Type"::"Customer Deposit":
                        begin
                            "Qty. per Unit of Measure" := 1;
                        end;
                    else begin
                        GetItem();
                        NPRPOSIUOMUtils.CheckIfUnitOfMeasureBlocked(Rec);
                        "Qty. per Unit of Measure" := UOMMgt.GetQtyPerUnitOfMeasure(_Item, "Unit of Measure Code");
                        "Quantity (Base)" := CalcBaseQty(Quantity);
                        "Unit Price" := FindItemSalesPrice();
                    end;
                end;
                UpdateAmounts(Rec);
            end;
        }
        field(12; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            MaxValue = 99.999;

            trigger OnValidate()
            var
                SaleLinePOS: Record "NPR POS Sale Line";
                Err001: Label 'Quantity at %2 %1 can only be 1 or -1';
                Err003: Label 'A quantity must be specified on the line';
                OldUnitPrice: Decimal;
            begin
                if ("Serial No." <> '') and
                    (Abs(Quantity) <> 1) then
                    Error(Err001,
                      "Serial No.", FieldName("Serial No."));

                if ("Serial No." <> '') then
                    Validate("Serial No.", "Serial No.");

                case "Line Type" of
                    "Line Type"::"POS Payment", "Line Type"::"GL Payment", "Line Type"::Rounding, "Line Type"::"Issue Voucher", "Line Type"::"Customer Deposit":
                        begin
                            if Quantity = 0 then
                                Error(Err003);
                            UpdateAmounts(Rec);
                        end;
                    "Line Type"::Item:
                        begin
                            GetItem();
                            "Quantity (Base)" := CalcBaseQty(Quantity);

                            UpdateDependingLinesQuantity();

                            if ("Discount Type" = "Discount Type"::Manual) and ("Discount %" <> 0) then
                                Validate("Discount %");

                            CalculateCostPrice();
                            UpdateAmounts(Rec);

                            if not _Item."NPR Group sale" then begin
                                OldUnitPrice := "Unit Price";
                                "Unit Price" := Rec.FindItemSalesPrice();
                                if OldUnitPrice <> "Unit Price" then
                                    UpdateAmounts(Rec);
                            end;
                        end;
                    "Line Type"::"Item Category":
                        begin
                            if Quantity = 0 then
                                Error(Err003);
                            if "Price Includes VAT" then
                                "Amount Including VAT" := Round("Unit Price" * Quantity, 0.01)
                            else
                                "Amount Including VAT" := Round("Unit Price" * Quantity * (1 + "VAT %" / 100), 0.01);
                        end;
                    "Line Type"::"BOM List":
                        begin
                            SaleLinePOS.SetRange("Register No.", "Register No.");
                            SaleLinePOS.SetRange("Sales Ticket No.", "Sales Ticket No.");
                            SaleLinePOS.SetRange(Date, Date);
                            SaleLinePOS.SetRange("Discount Code", "Discount Code");
                            SaleLinePOS.SetFilter("No.", '<>%1', "No.");
                            "Amount Including VAT" := 0;
                        end;
                end;
                UpdateCost();
            end;
        }
        field(13; "Invoice (Qty)"; Decimal)
        {
            Caption = 'Invoice (Qty)';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'No longer used except as dummy field.';
        }
        field(14; "To Ship (Qty)"; Decimal)
        {
            Caption = 'To Ship (Qty)';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(15; "Unit Price"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            Caption = 'Unit Price';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 2;
            Editable = true;
            MaxValue = 9999999;

            trigger OnValidate()
            var
                ErrItemBelow: Label 'Price cannot be negative.';
                Err001: Label 'A quantity must be specified on the line';
                Err003: Label 'The sales price cannot be changed for this item';
            begin
                POSUnitGlobal.Get("Register No.");
                case "Line Type" of
                    "Line Type"::"POS Payment", "Line Type"::"GL Payment", "Line Type"::Rounding, "Line Type"::"Issue Voucher":
                        begin
                            if Quantity <> 0 then begin
                                "Amount Including VAT" := "Unit Price" * Quantity;
                                Amount := "Amount Including VAT";
                            end;
                        end;
                    "Line Type"::Item:
                        begin
                            if "Unit Price" < 0 then
                                Error(ErrItemBelow);
                            GetItem();

                            "Eksp. Salgspris" := true;
                            GetAmount(Rec, _Item, "Unit Price");
                            if ("No." <> '') then begin
                                if (_Item."NPR Group sale") or (_Item."Unit Cost" = 0) then begin
                                    CalculateCostPrice();
                                end else
                                    if ("Serial No." <> '') and (Quantity > 0) then
                                        Error(Err003);
                            end;
                            "Custom Price" := true;
                        end;
                    "Line Type"::"Item Category":
                        begin
                            if Quantity = 0 then
                                Error(Err001);
                            if "Price Includes VAT" then
                                "Amount Including VAT" := Round("Unit Price" * Quantity, 0.01) - "Discount Amount"
                            else
                                "Amount Including VAT" := Round("Unit Price" * Quantity * (1 + "VAT %" / 100), 0.01);
                        end;
                    "Line Type"::"BOM List":
                        begin
                            "Unit Price" := xRec."Unit Price";
                            exit;
                        end;
                    "Line Type"::"Customer Deposit":
                        begin
                            if Quantity <> 0 then begin
                                "Amount Including VAT" := "Unit Price" * Quantity;
                                Amount := "Amount Including VAT";
                            end;
                        end;
                end;
            end;
        }
        field(16; "Unit Cost (LCY)"; Decimal)
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
        field(17; "VAT %"; Decimal)
        {
            Caption = 'VAT %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(18; "Qty. Discount %"; Decimal)
        {
            Caption = 'Qty. Discount %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            MaxValue = 100;
            MinValue = 0;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(19; "Discount %"; Decimal)
        {
            Caption = 'Discount %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 1;
            MaxValue = 100;
            MinValue = 0;

            trigger OnValidate()
            var
                POSUnit: Record "NPR POS Unit";
                ErrMin: Label 'Discount % cannot be negative.';
                ErrMax: Label 'Discount % cannot exeed 100.';
                POSSetup: Codeunit "NPR POS Setup";
                Trans0001: Label 'A deptorpayment cannot have discount';
                Trans0002: Label 'An itemgroup cannot have discount';
                Trans0003: Label 'Financial posts cannot be given a rebate';
            begin
                if "Discount %" < 0 then
                    Error(ErrMin);

                if "Discount %" > 100 then
                    Error(ErrMax);

                POSUnit.Get("Register No.");
                POSSetup.SetPOSUnit(POSUnit);

                case "Line Type" of
                    "Line Type"::"POS Payment", "Line Type"::"GL Payment", "Line Type"::Rounding:
                        begin
                            Error(Trans0003);
                        end;
                    "Line Type"::"Issue VOucher":
                        begin
                            "Discount Type" := "Discount Type"::" ";
                            "Discount Code" := '';
                            "Discount Amount" := Round("Unit Price" * "Discount %" / 100, POSSetup.AmountRoundingPrecision());
                            "Amount Including VAT" := "Unit Price" - "Discount Amount";
                        end;
                    "Line Type"::Item:
                        begin
                            RemoveBOMDiscount();
                            if "Discount %" > 0 then
                                "Discount Type" := "Discount Type"::Manual;
                            "Discount Code" := xRec."Discount Code";
                            "Amount Including VAT" := 0;
                            "Discount Amount" := 0;
                            if Modify() then;
                            GetItem();
                            GetAmount(Rec, _Item, Rec."Unit Price");
                        end;
                    "Line Type"::"Item Category":
                        Error(Trans0002);
                    "Line Type"::"BOM List":
                        begin
                            "Discount %" := xRec."Discount %";
                            exit;
                        end;
                    "Line Type"::"Customer Deposit":
                        Error(Trans0001);
                end;
            end;
        }
        field(20; "Discount Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Discount';
            DataClassification = CustomerContent;
            MinValue = 0;

            trigger OnValidate()
            begin
                case true of
                    ("Discount Amount" = 0) OR ("Unit Price" = 0) OR (Quantity = 0):
                        Validate("Discount %", 0);
                    "Price Includes VAT":
                        Validate("Discount %", "Discount Amount" / "Unit Price" / Quantity * 100);
                    else
                        Validate("Discount %", "Discount Amount" / "Unit Price" / Quantity / (100 + "VAT %") * 10000);
                end;
            end;
        }
        field(21; "Manual Item Sales Price"; Boolean)
        {
            Caption = 'Manual Item Sales Price';
            DataClassification = CustomerContent;
            Description = 'NPR5.48';
            InitValue = false;
        }
        field(25; "Date"; Date)
        {
            Caption = 'Date';
            DataClassification = CustomerContent;
        }
        field(26; "Line Type"; Enum "NPR POS Sale Line Type")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
        }
        field(30; Amount; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Amount';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 2;
            MaxValue = 1000000;

            trigger OnValidate()
            var
                Trans0001: Label 'The sign on quantity and amount must be the same';
            begin
                if Amount <> xRec.Amount then begin
                    case "Line Type" of
                        "Line Type"::Item:
                            begin
                                GetItem();
                                if Amount * xRec.Amount <> Abs(Amount) * Abs(xRec.Amount) then
                                    Error(Trans0001);

                                if not "Price Includes VAT" then
                                    "Discount %" := (1 - Amount / ("Unit Price" * Quantity)) * 100
                                else
                                    "Discount %" := (1 - Amount * ((100 + "VAT %") / 100) / ("Unit Price" * Quantity)) * 100;

                                "Discount Type" := "Discount Type"::Manual;
                                "Discount Code" := '';
                                "Discount Amount" := 0;
                                "Amount Including VAT" := 0;

                                if Modify() then;
                                GetAmount(Rec, _Item, Rec."Unit Price");
                            end;
                    end;
                end;
            end;
        }
        field(31; "Amount Including VAT"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Amount Including VAT';
            DataClassification = CustomerContent;
            MaxValue = 99999999;

            trigger OnValidate()
            begin
                if "Unit Price" <> 0 then begin
                    if "Price Includes VAT" then begin
                        Validate("Discount %", 100 - "Amount Including VAT" / ("Unit Price" * Quantity) * 100);
                    end else begin
                        Validate("Discount %", 100 - "Amount Including VAT" / ("Unit Price" * Quantity) / (100 + "VAT %") * 10000);
                    end;
                end;

            end;
        }
        field(32; "Allow Invoice Discount"; Boolean)
        {
            Caption = 'Allow Invoice Discount';
            DataClassification = CustomerContent;
            InitValue = true;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used in POS';
        }
        field(33; "Allow Line Discount"; Boolean)
        {
            Caption = 'Allow Line Discount';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(34; "Price Includes VAT"; Boolean)
        {
            Caption = 'Price Includes VAT';
            DataClassification = CustomerContent;
        }
        field(38; "Initial Group Sale Price"; Decimal)
        {
            Caption = 'Initial Group Sale Price';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin

                Validate("Unit of Measure Code");
            end;
        }
        field(41; "Customer Price Group"; Code[10])
        {
            Caption = 'Customer Price Group';
            DataClassification = CustomerContent;
            Description = 'NPR5.30';
            TableRelation = "Customer Price Group";

            trigger OnValidate()
            begin
                Validate("No.");
            end;
        }
        field(42; "Allow Quantity Discount"; Boolean)
        {
            Caption = 'Allow Quantity Discount';
            DataClassification = CustomerContent;
            InitValue = true;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
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
                Validate("Unit Cost (LCY)", GetUnitCostLCY(CurrFieldNo <> FieldNo("Serial No.")));
            end;
        }
        field(44; "Customer/Item Discount %"; Decimal)
        {
            Caption = 'Customer/Item Discount %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            MaxValue = 100;
            MinValue = 0;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(46; "Invoice to Customer No."; Code[20])
        {
            Caption = 'Invoice to Customer No.';
            DataClassification = CustomerContent;
            Editable = false;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(47; "Invoice Discount Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Invoice Discount Amount';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used in POS';
        }
        field(48; "Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Business Posting Group";
        }
        field(49; "Gen. Prod. Posting Group"; Code[20])
        {
            Caption = 'Gen. Prod. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Product Posting Group";
        }
        field(50; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Business Posting Group";
        }
        field(51; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Product Posting Group";
        }
        field(52; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = Currency;
        }
        field(53; "Claim (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Claim (LCY)';
            DataClassification = CustomerContent;
            Editable = false;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(54; "VAT Base Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'VAT Base Amount';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(55; Cost; Decimal)
        {
            Caption = 'Cost';
            DataClassification = CustomerContent;
        }
        field(56; Euro; Decimal)
        {
            Caption = 'Euro';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(57; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DataClassification = CustomerContent;
        }
        field(58; "Period Discount code"; Code[20])
        {
            Caption = 'Period Discount code';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(59; "Lookup On No."; Boolean)
        {
            Caption = 'Lookup On No.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
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
        field(75; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            DataClassification = CustomerContent;
            TableRelation = Bin.Code;
        }
        field(80; "Special price"; Decimal)
        {
            Caption = 'Special price';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
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
            end;
        }
        field(85; "Tax Area Code"; Code[20])
        {
            Caption = 'Tax Area Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.31';
            TableRelation = "Tax Area";
        }
        field(86; "Tax Liable"; Boolean)
        {
            Caption = 'Tax Liable';
            DataClassification = CustomerContent;
            Description = 'NPR5.31';
        }
        field(87; "Tax Group Code"; Code[20])
        {
            Caption = 'Tax Group Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.31';
            TableRelation = "Tax Group";
        }
        field(88; "Use Tax"; Boolean)
        {
            Caption = 'Use Tax';
            DataClassification = CustomerContent;
            Description = 'NPR5.31';
        }
        field(90; "Return Reason Code"; Code[10])
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
                    if ReturnReason."Inventory Value Zero" then
                        Validate("Unit Cost (LCY)", 0);
                end else begin
                    GetPOSHeader();
                    if "Location Code" <> SalePOS."Location Code" then
                        Validate("Location Code", SalePOS."Location Code");
                    CalculateCostPrice();
                end;
            end;
        }
        field(91; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            DataClassification = CustomerContent;
            TableRelation = "Reason Code";
        }
        field(100; "Unit Cost"; Decimal)
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
        field(101; "System-Created Entry"; Boolean)
        {
            Caption = 'System-Created Entry';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(102; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
            TableRelation = IF ("Line Type" = CONST(Item)) "Item Variant".Code WHERE("Item No." = FIELD("No."));

            trigger OnValidate()
            begin
                Validate("No.");
                if "Variant Code" <> xRec."Variant Code" then
                    GetDefaultBin();
            end;
        }
        field(103; "Line Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Line Amount';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField("Line Type");
                TestField(Quantity);
                TestField("Unit Price");
                GetPOSHeader();
                "Line Amount" := Round("Line Amount", Currency."Amount Rounding Precision");
            end;
        }
        field(106; "VAT Identifier"; Code[20])
        {
            Caption = 'VAT Identifier';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(117; "Retail Document Type"; Option)
        {
            Caption = 'Retail Document Type';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Selection,Retail Order,Wish,Customization,Delivery,Rental contract,Purchase contract,Qoute';
            OptionMembers = " ","Selection Contract","Retail Order",Wish,Customization,Delivery,"Rental contract","Purchase contract",Quote;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(118; "Retail Document No."; Code[20])
        {
            Caption = 'Retail Document No.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'No longer used except as dummy field.';
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
        field(144; "Sales Doc. Prepayment Value"; Decimal)
        {
            Caption = 'Sales Doc. Prepayment Value';
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
        field(147; "Sales Document Sync. Posting"; Boolean)
        {
            Caption = 'Sales Document Sync. Posting';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Use Enum POS Sales Document Post instead';
        }
        field(148; "Sales Document Print"; Boolean)
        {
            Caption = 'Sales Document Print';
            DataClassification = CustomerContent;
        }
        field(149; "Sales Document Receive"; Boolean)
        {
            Caption = 'Sales Document Receive';
            DataClassification = CustomerContent;
        }
        field(150; "Customer Location No."; Code[20])
        {
            Caption = 'Customer Location No.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(151; "Sales Document Prepay. Refund"; Boolean)
        {
            Caption = 'Sales Document Prepay. Refund';
            DataClassification = CustomerContent;
        }
        field(152; "Sales Document Delete"; Boolean)
        {
            Caption = 'Sales Document Delete';
            DataClassification = CustomerContent;
        }
        field(153; "Sales Doc. Prepay Is Percent"; Boolean)
        {
            Caption = 'Sales Doc. Prepay Is Percent';
            DataClassification = CustomerContent;
        }
        field(154; "Sales Document Pdf2Nav"; Boolean)
        {
            Caption = 'Sales Document Pdf2Nav';
            DataClassification = CustomerContent;
        }
        field(155; "Posted Sales Document Type"; Option)
        {
            Caption = 'Posted Sales Document Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Invoice,Credit Memo';
            OptionMembers = INVOICE,CREDIT_MEMO;
        }
        field(156; "Posted Sales Document No."; Code[20])
        {
            Caption = 'Posted Sales Document No.';
            DataClassification = CustomerContent;
            TableRelation = IF ("Posted Sales Document Type" = CONST(INVOICE)) "Sales Invoice Header"
            ELSE
            IF ("Posted Sales Document Type" = CONST(CREDIT_MEMO)) "Sales Cr.Memo Header";
        }
        field(157; "Delivered Sales Document Type"; Option)
        {
            Caption = 'Delivered Sales Document Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Shipment,Return Receipt';
            OptionMembers = SHIPMENT,RETURN_RECEIPT;
        }
        field(158; "Delivered Sales Document No."; Code[20])
        {
            Caption = 'Delivered Sales Document No.';
            DataClassification = CustomerContent;
            TableRelation = IF ("Delivered Sales Document Type" = CONST(SHIPMENT)) "Sales Shipment Header"
            ELSE
            IF ("Delivered Sales Document Type" = CONST(RETURN_RECEIPT)) "Return Receipt Header";
        }
        field(159; "Sales Document Send"; Boolean)
        {
            Caption = 'Sales Document Send';
            DataClassification = CustomerContent;
        }
        field(160; "Orig. POS Sale ID"; Integer)
        {
            Caption = 'Orig. POS Sale ID';
            DataClassification = CustomerContent;
            Description = 'NPR5.31';
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Use systemID instead';
        }
        field(161; "Orig. POS Line No."; Integer)
        {
            Caption = 'Orig. POS Line No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.31';
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Use systemID instead';
        }
        field(162; "Sales Document Post"; Enum "NPR POS Sales Document Post")
        {
            DataClassification = CustomerContent;
            Caption = 'Sales Document Post';
        }
        field(163; "Sales Posting Type"; Enum "NPR Post Sales Posting Type")
        {
            Caption = 'Sales Posting Type';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(170; "Retail ID"; Guid)
        {
            Caption = 'Retail ID';
            DataClassification = CustomerContent;
            Description = 'NPR5.50';
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Use systemID instead';
        }
        field(200; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Editable = false;
            InitValue = 1;
        }
        field(300; "Return Sale Register No."; Code[10])
        {
            Caption = 'Return Sale POS Unit No.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(301; "Return Sale Sales Ticket No."; Code[20])
        {
            Caption = 'Return Sale Sales Ticket No.';
            DataClassification = CustomerContent;
        }
        field(302; "Return Sales Sales Type"; Option)
        {
            Caption = 'Return Sales Sales Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Sale,Payment,Debit Sale,Gift Voucher,Credit Voucher,Payment1,Disbursement,Comment,,Open/Close';
            OptionMembers = Sale,Payment,"Debit Sale","Gift Voucher","Credit Voucher",Payment1,Disbursement,Comment,,"Open/Close";
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(303; "Return Sale Line No."; Integer)
        {
            Caption = 'Return Sale Line No.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(304; "Return Sale No."; Code[20])
        {
            Caption = 'Return Sale No.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(305; "Return Sales Sales Date"; Date)
        {
            Caption = 'Return Sales Sales Date';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(400; "Discount Type"; Option)
        {
            Caption = 'Discount Type';
            DataClassification = CustomerContent;
            Description = 'NPR5.30';
            OptionCaption = ' ,Period,Mixed,Multiple Unit,Salesperson Discount,Inventory,,Rounding,Combination,Customer';
            OptionMembers = " ",Campaign,Mix,Quantity,Manual,"BOM List",,Rounding,Combination,Customer;

            trigger OnValidate()
            begin
                "Discount %" := 0;
                "Discount Amount" := 0;
            end;
        }
        field(401; "Discount Code"; Code[20])
        {
            Caption = 'Discount Code';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CreateDimFromDefaultDim(FieldNo("Discount Code"));
            end;
        }
        field(402; "Discount Calculated"; Boolean)
        {
            Caption = 'Discount Calculated';
            DataClassification = CustomerContent;
            Description = 'NPR5.40';
        }
        field(405; "Discount Authorised by"; Code[50])
        {
            Caption = 'Discount Authorised by';
            DataClassification = CustomerContent;
            Description = 'NPR5.39';
            TableRelation = "Salesperson/Purchaser";
        }
        field(420; "Coupon Qty."; Integer)
        {
            CalcFormula = Count("NPR NpDc SaleLinePOS Coupon" WHERE("Register No." = FIELD("Register No."),
                                                                   "Sales Ticket No." = FIELD("Sales Ticket No."),
                                                                   "Sale Date" = FIELD(Date),
                                                                   "Sale Line No." = FIELD("Line No."),
                                                                   Type = CONST(Coupon)));
            Caption = 'Coupon Qty.';
            Description = 'NPR5.00 [250375]';
            Editable = false;
            FieldClass = FlowField;
        }
        field(425; "Coupon Discount Amount"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("NPR NpDc SaleLinePOS Coupon"."Discount Amount" WHERE("Register No." = FIELD("Register No."),
                                                                                   "Sales Ticket No." = FIELD("Sales Ticket No."),
                                                                                   "Sale Date" = FIELD(Date),
                                                                                   "Sale Line No." = FIELD("Line No."),
                                                                                   Type = CONST(Discount)));
            Caption = 'Coupon Discount Amount';
            Description = 'NPR5.00 [250375]';
            Editable = false;
            FieldClass = FlowField;
        }
        field(430; "Coupon Applied"; Boolean)
        {
            Caption = 'Coupon Applied';
            DataClassification = CustomerContent;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            DataClassification = CustomerContent;
        }
        field(490; "Imported from Invoice No."; Code[20])
        {
            Caption = 'Imported from Invoice No.';
            DataClassification = CustomerContent;
        }
        field(491; "Derived from Line"; Guid)
        {
            Caption = 'Derived from Line';
            DataClassification = SystemMetadata;
        }
        field(495; "Created At"; DateTime)
        {
            Caption = 'Created At';
            DataClassification = CustomerContent;
        }
        field(500; "EFT Approved"; Boolean)
        {
            Caption = 'Cash Terminal Approved';
            DataClassification = CustomerContent;
        }
        field(505; "Credit Card Tax Free"; Boolean)
        {
            Caption = 'Credit Card Tax Free';
            DataClassification = CustomerContent;
            Description = 'Only to be set if Cash Terminal Approved';
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';

        }
        field(550; "Drawer Opened"; Boolean)
        {
            Caption = 'Drawer Opened';
            DataClassification = CustomerContent;
            Description = 'NPR4.002.005, for indication of opening on drawer.';
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(600; "VAT Calculation Type"; Enum "Tax Calculation Type")
        {
            Caption = 'VAT Calculation Type';
            DataClassification = CustomerContent;
        }
        field(700; "NPRE Seating Code"; Code[20])
        {
            Caption = 'Seating Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.53';
            TableRelation = "NPR NPRE Seating";

            trigger OnValidate()
            begin
                CreateDimFromDefaultDim(FieldNo("NPRE Seating Code"));
            end;
        }
        field(801; "Insurance Category"; Code[50])
        {
            Caption = 'Insurance Category';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used anymore.';
        }
        field(5002; Color; Code[20])
        {
            Caption = 'Color';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(5003; Size; Code[20])
        {
            Caption = 'Size';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(5004; Clearing; Option)
        {
            Caption = 'Clearing';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Gift Voucher,Credit Voucher';
            OptionMembers = " ",Gavekort,Tilgodebevis;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(5008; "External Document No."; Code[20])
        {
            Caption = 'External Document No.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(5700; "Responsibility Center"; Code[10])
        {
            Caption = 'Responsibility Center';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Responsibility Center";

            trigger OnValidate()
            begin
                CreateDimFromDefaultDim(FieldNo("Responsibility Center"));
            end;
        }
        field(5999; "Buffer Ref. No."; Integer)
        {
            Caption = 'Buffer Ref. No.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(6000; "Buffer Document Type"; Enum "Gen. Journal Document Type")
        {
            Caption = 'Buffer Document Type';
            DataClassification = CustomerContent;
        }
        field(6001; "Buffer ID"; Code[50])
        {
            Caption = 'Buffer ID';
            DataClassification = CustomerContent;
        }
        field(6002; "Buffer Document No."; Code[20])
        {
            Caption = 'Buffer Document No.';
            DataClassification = CustomerContent;
        }
        field(6003; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            DataClassification = CustomerContent;
        }
        field(6004; Internal; Boolean)
        {
            Caption = 'Internal';
            DataClassification = CustomerContent;
            InitValue = false;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
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
        field(6010; "From Selection"; Boolean)
        {
            Caption = 'From Selection';
            DataClassification = CustomerContent;
            InitValue = false;
        }
        field(6011; "Item Group"; Code[10])
        {
            Caption = 'Item Group';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Item Category Used instead.';
        }
        field(6012; "MR Anvendt antal"; Decimal)
        {
            Caption = 'MR Used Amount';
            DataClassification = CustomerContent;
        }
        field(6013; "FP Anvendt"; Boolean)
        {
            Caption = 'FP Used';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(6014; "Eksp. Salgspris"; Boolean)
        {
            Caption = 'Sale POS Salesprice';
            DataClassification = CustomerContent;
            InitValue = false;
        }
        field(6015; "Serial No. not Created"; Code[50])
        {
            Caption = 'Serial No. not Created';
            DataClassification = CustomerContent;
        }
        field(6019; "Custom Price"; Boolean)
        {
            Caption = 'Custom Price';
            DataClassification = CustomerContent;
        }
        field(6020; NegPriceZero; Boolean)
        {
            Caption = 'NegPriceZero';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(6021; Reference; Text[50])
        {
            Caption = 'Reference';
            DataClassification = CustomerContent;
        }
        field(6022; "Rep. Nummer"; Code[10])
        {
            Caption = 'Rep. No.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(6023; "Gift Voucher Ref."; Code[20])
        {
            Caption = 'Gift Voucher Ref.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(6024; "Credit voucher ref."; Code[20])
        {
            Caption = 'Credit voucher ref.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(6025; "Custom Cost"; Boolean)
        {
            Caption = 'Custom Cost';
            DataClassification = CustomerContent;
        }
        field(6026; "Wish List"; Code[10])
        {
            Caption = 'Wish list';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(6027; "Wish List Line No."; Integer)
        {
            Caption = 'Wish List Line No.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(6028; "Item group accessory"; Boolean)
        {
            Caption = 'Itemgroup Accessories';
            DataClassification = CustomerContent;
        }
        field(6029; "Accessories Item Group No."; Code[20])
        {
            Caption = 'Accessories Itemgroup No.';
            DataClassification = CustomerContent;
        }
        field(6032; "Label Quantity"; Integer)
        {
            Caption = 'Label Quantity';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(6033; "Offline Sales Ticket No"; Code[20])
        {
            Caption = 'Emergency Ticket No.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(6034; "Custom Descr"; Boolean)
        {
            Caption = 'Customer Description';
            DataClassification = CustomerContent;
        }
        field(6036; "Foreign No."; Code[20])
        {
            Caption = 'Foreign No.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(6037; GiftCrtLine; Integer)
        {
            Caption = 'Gift Certificate Line';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(6038; "Label Date"; Date)
        {
            Caption = 'Label Date';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(6039; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
            DataClassification = CustomerContent;
            Description = 'NPR5.23';
        }
        field(6043; "Order No. from Web"; Code[20])
        {
            Caption = 'Order No. from Web';
            DataClassification = CustomerContent;
        }
        field(6044; "Order Line No. from Web"; Integer)
        {
            BlankZero = true;
            Caption = 'Order Line No. from Web';
            DataClassification = CustomerContent;
        }
        field(6050; "Item Category Code"; Code[20])
        {
            Caption = 'Item Category Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.00 [250375]';

            trigger OnValidate()
            begin
                CreateDimFromDefaultDim(FieldNo("No."));
            end;
        }
        field(6051; "Product Group Code"; Code[10])
        {
            Caption = 'Product Group Code';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(6055; "Lock Code"; Code[10])
        {
            Caption = 'Lock Code';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(6060; "Magento Brand"; Code[20])
        {
            Caption = 'Magento Brand';
            DataClassification = CustomerContent;
            TableRelation = "NPR Magento Brand";
        }
        field(6100; "Main Line No."; Integer)
        {
            Caption = 'Main Line No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.40';
        }
        field(6105; "Parent BOM Item No."; Code[20])
        {
            Caption = 'Parent BOM Item No.';
            DataClassification = CustomerContent;
        }
        field(6110; "Parent BOM Line No."; Integer)
        {
            Caption = 'Parent BOM Line No.';
            DataClassification = CustomerContent;
        }

        field(7014; "Item Disc. Group"; Code[20])
        {
            Caption = 'Item Disc. Group';
            DataClassification = CustomerContent;
            TableRelation = IF ("Line Type" = CONST(Item),
                                "No." = FILTER(<> '')) "Item Discount Group" WHERE(Code = FIELD("Item Disc. Group"));
            ValidateTableRelation = false;
        }
        field(22; "Copy Description"; Boolean)
        {
            Caption = 'Copy Description from POS Entry to Cust. Ledger Entry';
            DataClassification = CustomerContent;
        }
        field(10000; Silent; Boolean)
        {
            Caption = 'Silent';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(10001; Deleting; Boolean)
        {
            Caption = 'Deleting';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(10002; NoWarning; Boolean)
        {
            Caption = 'No Warning';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(10003; CondFirstRun; Boolean)
        {
            Caption = 'Conditioned First Run';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(10004; CurrencySilent; Boolean)
        {
            Caption = 'Currency (Silent)';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(10005; StyklisteSilent; Boolean)
        {
            Caption = 'Bill of materials (Silent)';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(10006; "Cust Forsikring"; Boolean)
        {
            Caption = 'Cust. Insurrance';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used anymore.';
        }
        field(10007; Forsikring; Boolean)
        {
            Caption = 'Insurrance';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(10008; TestOnServer; Boolean)
        {
            Caption = 'Test on Server';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(10009; "Customer No. Line"; Boolean)
        {
            Caption = 'Customer No. Line';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(10010; ForceApris; Boolean)
        {
            Caption = 'Force A-Price';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(10011; GuaranteePrinted; Boolean)
        {
            Caption = 'Guarantee Certificat Printed';
            DataClassification = CustomerContent;
            Description = 'Field set true, if guarantee certificate has been printed';
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(10012; "Custom Disc Blocked"; Boolean)
        {
            Caption = 'Custom Disc Blocked';
            DataClassification = CustomerContent;
        }
        field(10013; "Invoiz Guid"; Text[150])
        {
            Caption = 'Invoiz Guid';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(10014; "Orig.POS Entry S.Line SystemId"; Guid)
        {
            Caption = 'Original POS Entry Sale Line SystemId';
            DataClassification = CustomerContent;
        }
        field(10015; "Total Discount Code"; Code[20])
        {
            Caption = 'Total Discount Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Total Discount Header";
        }
        field(10016; "Total Discount Amount"; Decimal)
        {
            Caption = 'Total Discount Amount';
            DataClassification = CustomerContent;
        }
        field(10017; "Total Discount Step"; Decimal)
        {
            Caption = 'Total Discount Step';
            DataClassification = CustomerContent;

        }
        field(10018; "Benefit Item"; Boolean)
        {
            Caption = 'Benefit Item';
            DataClassification = CustomerContent;

        }
        field(10019; "Disc. Amt. Without Total Disc."; Decimal)
        {
            Caption = 'Disc. Amt. Without Total Disc.';
            DataClassification = CustomerContent;

        }

        field(10020; "Benefit List Code"; Code[20])
        {
            Caption = 'Benefit List Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Item Benefit List Header".Code;

        }
        field(6014511; "Label No."; Code[8])
        {
            Caption = 'Label Number';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not used';
        }
        field(6014512; "SQL Server Timestamp"; BigInteger)
        {
            Caption = 'Timestamp';
            DataClassification = CustomerContent;
            Editable = false;
            SQLTimestamp = true;
        }
        field(630; "Voucher Category"; Enum "NPR Voucher Category")
        {
            Caption = 'Voucher Category';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Register No.", "Sales Ticket No.", Date, "Sale Type", "Line No.")
        {
            MaintainSIFTIndex = false;
            SumIndexFields = "Amount Including VAT", Cost, "Discount Amount", Amount;
        }
        key(Key4; "Register No.", "Sales Ticket No.", "Line No.")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
        }
        key(Key5; "Discount Type")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount Including VAT", Amount;
        }
        key(Key6; "Register No.", "Sales Ticket No.", Date, "Sale Type", Type, "Discount Type", "Line No.")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount Including VAT";
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Sale Type field not used anymore. For usage of Sale Type refer to NPR POS Sale table';
        }
        key(Key7; "Serial No.")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
        }
        key(Key8; "Register No.", "Sales Ticket No.", "No.")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = Quantity;
        }
        key(Key10; "Register No.", "Sales Ticket No.", "Sale Type", Type, "No.", "Item Category Code", Quantity)
        {
            MaintainSIFTIndex = false;
            SumIndexFields = "Amount Including VAT", Amount, Quantity;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Sale Type field not used anymore. For usage of Sale Type refer to NPR POS Sale table';
        }
        key(Key11; "Register No.", "Sales Ticket No.", Date, "Sale Type", Type)
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount Including VAT";
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Sale Type field not used anymore. For usage of Sale Type refer to NPR POS Sale table';
        }
        key(Key12; "Register No.", "Sales Ticket No.", Date, "Line Type", "Discount Type", "Line No.")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount Including VAT";
        }
        key(Key13; "Register No.", "Sales Ticket No.", "Line Type", "No.", "Item Category Code", Quantity)
        {
            MaintainSIFTIndex = false;
            SumIndexFields = "Amount Including VAT", Amount, Quantity;
        }
        key(Key14; "Register No.", "Sales Ticket No.", Date, "Line Type")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount Including VAT";
        }
        key(Key15; "Register No.", "Sales Ticket No.", "Line Type", "Total Discount Code", "Benefit Item")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount Including VAT";
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        if "Created At" = 0DT then
            "Created At" := CurrentDateTime(); //Not the same as built-in SystemCreatedAt, as this timestamp stays intact across parking/loading and is kept on POS entry sales/payment lines.        
    end;

    trigger OnDelete()
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        ErrNoDeleteDep: Label 'Deposit line from a rental is not to be deleted.';
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        EFTInterface: Codeunit "NPR EFT Interface";
        IsAllowed, Handled : Boolean;
    begin
        if Rec."EFT Approved" then begin
            EFTInterface.AllowVoidEFTRequestOnPaymentLineDelete(Rec, IsAllowed, Handled);
            if not IsAllowed then
                Error(ERR_EFT_DELETE);
        end;

        if (("Line Type" = "Line Type"::"Customer Deposit") and ("From Selection")) then
            Error(ErrNoDeleteDep);

        if ("Line Type" = "Line Type"::Item) or ("Line Type" = "Line Type"::"BOM List") then begin
            case "Discount Type" of
                "Discount Type"::"BOM List":
                    begin
                        SaleLinePOS.Reset();
                        SaleLinePOS.SetRange("Register No.", "Register No.");
                        SaleLinePOS.SetRange("Sales Ticket No.", "Sales Ticket No.");
                        SaleLinePOS.SetRange(Date, Date);
                        SaleLinePOS.SetRange("Discount Code", "Discount Code");
                        if SaleLinePOS.FindSet() then
                            repeat
                                if SaleLinePOS."Line Type" = "Line Type"::"BOM List" then
                                    SaleLinePOS.Validate("No.");
                                if "Line No." <> SaleLinePOS."Line No." then
                                    SaleLinePOS.Delete();
                            until SaleLinePOS.Next() = 0;
                    end;
            end;
        end;

        TicketRequestManager.OnDeleteSaleLinePos(Rec);
    end;

    trigger OnRename()
    var
        ErrBlanc: Label 'Number in the expedition line must not be blank.';
    begin
        if (xRec."No." <> '') and ("No." = '') then
            Error(ErrBlanc);
    end;

    var
        _Item: Record Item;
        _Location: Record Location;
        POSUnitGlobal: Record "NPR POS Unit";
        SalePOS: Record "NPR POS Sale";
        Currency: Record Currency;
        DimMgt: Codeunit DimensionManagement;
        NPRDimMgt: Codeunit "NPR Dimension Mgt.";
        TotalItemLedgerEntryQuantity: Decimal;
        TotalAuditRollQuantity: Decimal;
        SkipCalcDiscount: Boolean;
        Text002: Label '%1 %2 is used more than once. Adjust the inventory first, and then continue the transaction';
        Text004: Label '%1 %2 is already used.';
        SkipDependantQuantityUpdate: Boolean;
        ERR_EFT_DELETE: Label 'Cannot delete externally approved electronic funds transfer. Please attempt refund or void of the original transaction instead.';

    local procedure GetPOSHeader()
    var
        SalePOS2: Record "NPR POS Sale";
    begin
        if SalePOS2.Get("Register No.", "Sales Ticket No.") then
            SalePOS := SalePOS2;
        Currency.InitRoundingPrecision();
    end;

    procedure SetPOSHeader(NewSalePOS: Record "NPR POS Sale")
    begin
        SalePOS := NewSalePOS;
        Currency.InitRoundingPrecision();
    end;

    procedure CalculateCostPrice()
    begin
        Validate("Unit Cost (LCY)", GetUnitCostLCY(true));
    end;

    procedure RemoveBOMDiscount()
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        if ("Discount Type" = "Discount Type"::"BOM List") then begin
            SaleLinePOS.SetRange("Register No.", "Register No.");
            SaleLinePOS.SetRange("Sales Ticket No.", "Sales Ticket No.");
            SaleLinePOS.SetRange(Date, Date);
            SaleLinePOS.SetRange("Discount Code", "Discount Code");
            SaleLinePOS.SetFilter("No.", '<>%1', "No.");
            if SaleLinePOS.FindSet(true) then
                repeat
                    if SaleLinePOS."Line Type" = "Line Type"::"BOM List" then
                        SaleLinePOS.Delete()
                    else begin
                        SaleLinePOS."Discount Type" := "Discount Type"::" ";
                        SaleLinePOS."Discount Code" := '';
                        SaleLinePOS."Discount %" := 0;
                        SaleLinePOS."Discount Amount" := 0;
                        SaleLinePOS."Amount Including VAT" := 0;
                        SaleLinePOS.Validate("No.");
                        SaleLinePOS.Modify();
                    end;
                until SaleLinePOS.Next() = 0;
        end;
    end;

    procedure FindItemSalesPrice(): Decimal
    var
        TempSaleLinePOS: Record "NPR POS Sale Line" temporary;
        POSSalesPriceCalcMgt: Codeunit "NPR POS Sales Price Calc. Mgt.";
    begin
        if "Manual Item Sales Price" then
            exit("Unit Price");
        GetPOSHeader();
        TempSaleLinePOS := Rec;
        TempSaleLinePOS."Currency Code" := '';
        POSSalesPriceCalcMgt.FindItemPrice(SalePOS, TempSaleLinePOS);
        "Allow Line Discount" := TempSaleLinePOS."Allow Line Discount";
        if not "Allow Line Discount" then begin
            "Discount %" := 0;
            "Discount Amount" := 0;
        end;
        exit(TempSaleLinePOS."Unit Price");
    end;

    procedure GetAmount(var SaleLinePOS: Record "NPR POS Sale Line"; var Item: Record Item; UnitPrice: Decimal)
    begin
        SaleLinePOS."Unit Price" := UnitPrice;
        UpdateAmounts(SaleLinePOS);
    end;

    [Obsolete('Use the version with 2 parameters instead.', 'NPR23.0')]
    procedure TransferToSalesLine(var SalesLine: Record "Sales Line"): Boolean
    begin
        exit(TransferToSalesLine(SalesLine, true));
    end;

    procedure TransferToSalesLine(var SalesLine: Record "Sales Line"; TransferPostingGroups: Boolean) SalesPriceRecalculated: Boolean
    var
        Txt001: Label 'Deposit';
    begin
        if ("No." = '*') or ("Line Type" = "Line Type"::Comment) then begin
            SalesLine."No." := '';
            SalesLine.Description := Description;
            SalesLine."Description 2" := "Description 2";
            exit;
        end;

        if ("Line Type" = "Line Type"::"Customer Deposit") then begin
            SalesLine."No." := '';
            SalesLine.Description := Txt001 + ' ' + Format(Abs("Amount Including VAT"));
            exit;
        end;

        SalesLine."Responsibility Center" := "Responsibility Center";
        SalesLine.Validate("No.", "No.");
        if TransferPostingGroups then begin
            if "Posting Group" <> '' then
                SalesLine."Posting Group" := "Posting Group";
            if "Gen. Bus. Posting Group" <> '' then
                SalesLine."Gen. Bus. Posting Group" := "Gen. Bus. Posting Group";
            if "Gen. Prod. Posting Group" <> '' then
                SalesLine."Gen. Prod. Posting Group" := "Gen. Prod. Posting Group";
            if ("VAT Bus. Posting Group" <> '') and (SalesLine."VAT Bus. Posting Group" <> "VAT Bus. Posting Group") then begin
                SalesLine."VAT Bus. Posting Group" := "VAT Bus. Posting Group";
                if ("VAT Prod. Posting Group" = '') or (SalesLine."VAT Prod. Posting Group" = "VAT Prod. Posting Group") then
                    SalesLine.Validate("VAT Prod. Posting Group");
            end;
            if ("VAT Prod. Posting Group" <> '') and (SalesLine."VAT Prod. Posting Group" <> "VAT Prod. Posting Group") then
                SalesLine.Validate("VAT Prod. Posting Group", "VAT Prod. Posting Group");
        end;

        SalesLine."Location Code" := "Location Code";
        SalesLine.Validate("Variant Code", "Variant Code");
        SalesLine.Validate("Unit of Measure Code", "Unit of Measure Code");
        SalesLine.Validate(Quantity, Quantity);
        SalesLine.Description := Description;
        SalesLine."Description 2" := "Description 2";

        SalesLine."Unit Price" := "Unit Price";
        SalesPriceRecalculated := SalesLine_AjdustPriceForVAT(Rec, SalesLine);
        SalesLine."Allow Line Disc." := "Allow Line Discount";
        SalesLine."Line Discount %" := "Discount %";
        if not SalesPriceRecalculated then begin
            SalesLine."Line Discount Amount" := "Discount Amount";
            SalesLine.Amount := Amount;
            SalesLine."Line Amount" := "Line Amount";
            SalesLine."Amount Including VAT" := "Amount Including VAT";
            SalesLine."VAT Base Amount" := "VAT Base Amount";
            SalesLine."VAT Calculation Type" := "VAT Calculation Type";
            SalesLine."VAT %" := "VAT %";
        end;
        SalesLine."Customer Price Group" := "Customer Price Group";
        SalesLine."Unit Cost" := "Unit Cost";
        SalesLine."Unit Cost (LCY)" := "Unit Cost (LCY)";
        SalesLine.Validate("Unit Price");
        SalesLine."NPR Discount Type" := "Discount Type";
        SalesLine."NPR Discount Code" := "Discount Code";

        OnAfterTransferToSalesLine(Rec, SalesLine);
    end;

    local procedure SalesLine_AjdustPriceForVAT(FromSaleLinePOS: Record "NPR POS Sale Line"; var SalesLine: Record "Sales Line"): Boolean
    var
        SalesHeader: Record "Sales Header";
        ToSaleLinePOS: Record "NPR POS Sale Line";
        POSSaleLine: Codeunit "NPR POS Sale Line";
    begin
        ToSaleLinePOS := FromSaleLinePOS;
        ToSaleLinePOS."VAT Bus. Posting Group" := SalesLine."VAT Bus. Posting Group";
        ToSaleLinePOS."VAT Prod. Posting Group" := SalesLine."VAT Prod. Posting Group";
        ToSaleLinePOS."VAT Calculation Type" := SalesLine."VAT Calculation Type";
        ToSaleLinePOS."VAT %" := SalesLine."VAT %";
        if SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.") then
            ToSaleLinePOS."Price Includes VAT" := SalesHeader."Prices Including VAT";

        exit(
            POSSaleLine.DoConvertPriceToVAT(
                FromSaleLinePOS."Price Includes VAT", FromSaleLinePOS."VAT Bus. Posting Group", FromSaleLinePOS."VAT Prod. Posting Group",
                ToSaleLinePOS, SalesLine."Unit Price"));
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
        if not ItemLedgerEntry.IsEmpty() then begin
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
        POSSale: Record "NPR POS Entry";
        ReservationEntry: Record "Reservation Entry";
    begin
        POSSalesLine.Reset();
        POSSalesLine.SetRange("Item Entry No.", 0);
        POSSalesLine.SetRange("Serial No.", SerialNo);
        POSSalesLine.SetLoadFields("POS Entry No.", "Item Entry No.", "Serial No.", Quantity);
        if POSSalesLine.FindSet(false) then
            repeat
                POSSale.SetLoadFields("Entry No.", "Sales Document Type", "Sales Document No.");
                POSSale.Get(POSSalesLine."POS Entry No.");
                if POSSale."Sales Document No." <> '' then begin
                    ReservationEntry.Reset();
                    ReservationEntry.SetCurrentKey("Serial No.", "Source ID", "Source Ref. No.", "Source Type", "Source Subtype", "Source Batch Name", "Source Prod. Order Line");
                    ReservationEntry.SetRange("Source Type", Database::"Sales Line");
                    ReservationEntry.SetRange("Source Subtype", POSSale."Sales Document Type");
                    ReservationEntry.SetRange("Source ID", POSSale."Sales Document No.");
                    ReservationEntry.SetRange("Reservation Status", ReservationEntry."Reservation Status"::Surplus);
                    ReservationEntry.SetRange("Serial No.", POSSalesLine."Serial No.");
                    if not ReservationEntry.IsEmpty then begin
                        ReservationEntry.CalcSums(Quantity);
                        TotalAuditRollQuantity += -ReservationEntry.Quantity;
                    end;
                end else
                    TotalAuditRollQuantity += POSSalesLine.Quantity;
            until POSSalesLine.Next() = 0;

        if Positive then begin
            if TotalAuditRollQuantity = -1 then
                Error(Err001, SerialNo, FieldName("Serial No."));
        end else begin
            if TotalAuditRollQuantity = 1 then
                Error(Err002, SerialNo, FieldName("Serial No."));
        end;
    end;

    [Obsolete('Pending removal, not used', 'NPR23.0')]
    procedure TransferToService()
    var
        ServiceItem: Record "Service Item";
    begin
        GetPOSHeader();
        ServiceItem.Init();
        ServiceItem.Insert(true);
        ServiceItem.Validate("Item No.", "No.");
        ServiceItem.Validate("Serial No.", "Serial No.");
        ServiceItem.Validate(Status, ServiceItem.Status::Installed);
        ServiceItem.Validate("Warranty Starting Date (Labor)", SalePOS.Date);
        ServiceItem.Validate("Warranty Ending Date (Labor)", CalcDate('<+1Y>', SalePOS.Date));
        ServiceItem.Validate("Customer No.", SalePOS."Customer No.");
        ServiceItem.Validate("Unit of Measure Code", "Unit of Measure Code");
        ServiceItem.Validate("Sales Date", SalePOS.Date);
        ServiceItem.Modify();
    end;

    procedure ExplodeBOM(ItemNo: Code[20]; StartLineNo: Integer; EndLineNo: Integer; var Level: Integer; UnitPrice: Decimal; "Sum": Decimal)
    var
        BOMComponent: Record "BOM Component";
        SaleLinePOS: Record "NPR POS Sale Line";
        Item2: Record Item;
        BOMComponentItem: Record Item;
        NPRPOSTrackingUtils: Codeunit "NPR POS Tracking Utils";
        TotalComponentQuantity: Decimal;
        LineQuantity: Decimal;
        FromLineNo: Integer;
        ToLineNo: Integer;
        i: Integer;
        UseSpecTracking: Boolean;
    begin
        if Sum = 0 then begin
            if Quantity = 0 then
                Quantity := 1;
            StartLineNo := Rec."Line No.";
            SaleLinePOS.Reset();
            SaleLinePOS.SetRange("Register No.", "Register No.");
            SaleLinePOS.SetRange("Sales Ticket No.", "Sales Ticket No.");
            SaleLinePOS.SetRange(Date, Date);
            SaleLinePOS.SetRange("Line No.", StartLineNo + 1, StartLineNo + 10000);
            if SaleLinePOS.FindFirst() then
                EndLineNo := SaleLinePOS."Line No."
            else
                EndLineNo := StartLineNo + 10000;

            if Item2.Get(ItemNo) then
                UnitPrice := Item2."Unit Price";
        end;

        BOMComponent.SetRange("Parent Item No.", ItemNo);
        if BOMComponent.FindSet() then begin
            Sum := 0;
            repeat
                if BOMComponent."Assembly BOM" then begin
                    ExplodeBOM(BOMComponent."No.", StartLineNo, EndLineNo, Level, UnitPrice, Sum);
                end else begin

                    if not BOMComponentItem.Get(BOMComponent."No.") then
                        Clear(BOMComponentItem);

                    TotalComponentQuantity := BOMComponent."Quantity per" * Rec.Quantity;

                    i := TotalComponentQuantity;
                    LineQuantity := BOMComponent."Quantity per" * Rec.Quantity;
                    if NPRPOSTrackingUtils.ItemRequiresSerialNumber(BOMComponentItem, UseSpecTracking) then begin
                        i := 0;
                        LineQuantity := 1;
                    end;

                    repeat
                        Level += 1;
                        i += 1;
                        SaleLinePOS.Init();
                        SaleLinePOS."Register No." := "Register No.";
                        SaleLinePOS."Sales Ticket No." := "Sales Ticket No.";
                        SaleLinePOS.Date := Rec.Date;
                        SaleLinePOS."Line No." := Round(EndLineNo - (EndLineNo - StartLineNo) / (2 * Level), 1);
                        if not SaleLinePOS.Insert(true) then
                            SaleLinePOS.Modify(true);
                        SaleLinePOS."No." := BOMComponent."No.";
                        SaleLinePOS.SetSkipUpdateDependantQuantity(true);
                        SaleLinePOS.Validate("No.");
                        SaleLinePOS.Quantity := LineQuantity;
                        SaleLinePOS.Validate(Quantity);
                        SaleLinePOS."Parent BOM Item No." := BOMComponent."Parent Item No.";
                        SaleLinePOS."Parent BOM Line No." := StartLineNo;
                        Sum += SaleLinePOS."Unit Price" * SaleLinePOS.Quantity;
                        SaleLinePOS.SetSkipUpdateDependantQuantity(false);
                        if not SaleLinePOS.Modify(true) then
                            SaleLinePOS.Insert(true);
                        if FromLineNo = 0 then
                            FromLineNo := SaleLinePOS."Line No.";

                        ToLineNo := SaleLinePOS."Line No.";

                    until (i >= TotalComponentQuantity)
                end;
            until BOMComponent.Next() = 0;

            if (UnitPrice <> 0) and (Sum <> 0) then begin
                SaleLinePOS.Reset();
                SaleLinePOS.SetRange("Register No.", "Register No.");
                SaleLinePOS.SetRange("Sales Ticket No.", "Sales Ticket No.");
                SaleLinePOS.SetRange("Line No.", FromLineNo, ToLineNo);
                if SaleLinePOS.FindSet(true) then
                    repeat
                        SaleLinePOS."Discount Code" := "Discount Code";
                        SaleLinePOS.Validate("Discount %", 100 - UnitPrice / Sum * 100);
                        SaleLinePOS.Modify(true);
                    until SaleLinePOS.Next() = 0;
                SaleLinePOS.ModifyAll("Discount Type", SaleLinePOS."Discount Type"::"BOM List");
            end;
        end;
    end;

    procedure GetSkipCalcDiscount(): Boolean
    begin
        exit(SkipCalcDiscount);
    end;

    procedure SetSkipCalcDiscount(NewSkipCalcDiscount: Boolean)
    begin
        SkipCalcDiscount := NewSkipCalcDiscount;
    end;

    [Obsolete('Replaced by CreateDim(DefaultDimSource: List of [Dictionary of [Integer, Code[20]]]). Use CreateDimFromDefaultDim(FieldNo: Integer) to update line dimensions from default dims.', 'NPR23.0')]
    procedure CreateDim(Type1: Integer; No1: Code[20]; Type2: Integer; No2: Code[20]; Type3: Integer; No3: Code[20]; Type4: Integer; No4: Code[20])
    var
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
#IF NOT (BC17 or BC18 or BC19)
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
        i: Integer;
#endif
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

        "Shortcut Dimension 1 Code" := '';
        "Shortcut Dimension 2 Code" := '';

#IF NOT (BC17 or BC18 or BC19)
        for i := 1 to ArrayLen(TableID) do
            if (TableID[i] <> 0) and (No[i] <> '') then
                DimMgt.AddDimSource(DefaultDimSource, TableID[i], No[i]);

        "Dimension Set ID" :=
                DimMgt.GetRecDefaultDimID(
                Rec, CurrFieldNo, DefaultDimSource, SalePOS.GetPOSSourceCode(),
                "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", SalePOS."Dimension Set ID", DATABASE::"NPR POS Store");
#else
        "Dimension Set ID" :=
            DimMgt.GetRecDefaultDimID(
                Rec, CurrFieldNo, TableID, No, SalePOS.GetPOSSourceCode(),
                "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", SalePOS."Dimension Set ID", DATABASE::"NPR POS Store");

#endif
        DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
    end;
#IF BC17 or BC18 or BC19

    internal procedure CreateDimFromDefaultDim(FieldNo: Integer)
    begin
        case FieldNo of
            FieldNo("No."):
                CreateDim(
                    NPRDimMgt.LineTypeToTableNPR("Line Type"), "No.",
                    NPRDimMgt.DiscountTypeToTableNPR("Discount Type"), "Discount Code",
                    Database::"NPR NPRE Seating", "NPRE Seating Code",
                    Database::"Responsibility Center", "Responsibility Center");
            FieldNo("Discount Code"):
                CreateDim(
                    NPRDimMgt.DiscountTypeToTableNPR("Discount Type"), "Discount Code",
                    NPRDimMgt.LineTypeToTableNPR("Line Type"), "No.",
                    Database::"NPR NPRE Seating", "NPRE Seating Code",
                    Database::"Responsibility Center", "Responsibility Center");
            FieldNo("Responsibility Center"):
                CreateDim(
                    Database::"Responsibility Center", "Responsibility Center",
                    NPRDimMgt.LineTypeToTableNPR("Line Type"), "No.",
                    NPRDimMgt.DiscountTypeToTableNPR("Discount Type"), "Discount Code",
                    Database::"NPR NPRE Seating", "NPRE Seating Code");
            FieldNo("NPRE Seating Code"):
                CreateDim(
                    Database::"NPR NPRE Seating", "NPRE Seating Code",
                    NPRDimMgt.LineTypeToTableNPR("Line Type"), "No.",
                    NPRDimMgt.DiscountTypeToTableNPR("Discount Type"), "Discount Code",
                    Database::"Responsibility Center", "Responsibility Center");
        end;
    end;
#ELSE

    local procedure CreateDim(DefaultDimSource: List of [Dictionary of [Integer, Code[20]]])
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCreateDim(IsHandled, Rec, CurrFieldNo, DefaultDimSource);
        if IsHandled then
            exit;

        "Shortcut Dimension 1 Code" := '';
        "Shortcut Dimension 2 Code" := '';
        "Dimension Set ID" :=
            DimMgt.GetRecDefaultDimID(
                Rec, CurrFieldNo, DefaultDimSource, SalePOS.GetPOSSourceCode(),
                "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", SalePOS."Dimension Set ID", DATABASE::"NPR POS Store");

        OnCreateDimOnBeforeUpdateGlobalDimFromDimSetID(Rec);
        DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");

        OnAfterCreateDim(Rec, CurrFieldNo, xRec);
    end;

    internal procedure CreateDimFromDefaultDim(FieldNo: Integer)
    var
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
    begin
        GetPOSHeader();
        InitDefaultDimensionSources(DefaultDimSource, FieldNo);
#ENDIF
#IF NOT (BC17 or BC18 or BC19 or BC20 or BC2100 or BC2101 or BC2102 or BC2103)
        if DimMgt.IsDefaultDimDefinedForTable(GetTableValuePair(FieldNo)) then  //First appears in BC21.4
#ENDIF
#IF NOT (BC17 or BC18 or BC19)
        CreateDim(DefaultDimSource);
        OnAfterCreateDimFromDefaultDim(Rec, xRec, SalePOS, CurrFieldNo, FieldNo);
    end;

    local procedure InitDefaultDimensionSources(var DefaultDimSource: List of [Dictionary of [Integer, Code[20]]]; FieldNo: Integer)
    begin
        DimMgt.AddDimSource(DefaultDimSource, NPRDimMgt.LineTypeToTableNPR("Line Type"), "No.", FieldNo = FieldNo("No."));
        DimMgt.AddDimSource(DefaultDimSource, NPRDimMgt.DiscountTypeToTableNPR("Discount Type"), "Discount Code", FieldNo = FieldNo("Discount Code"));
        DimMgt.AddDimSource(DefaultDimSource, Database::"Responsibility Center", "Responsibility Center", FieldNo = FieldNo("Responsibility Center"));
        DimMgt.AddDimSource(DefaultDimSource, Database::"NPR NPRE Seating", "NPRE Seating Code", FieldNo = FieldNo("NPRE Seating Code"));
        DimMgt.AddDimSource(DefaultDimSource, Database::Location, Rec."Location Code", FieldNo = Rec.FieldNo("Location Code"));

        OnAfterInitDefaultDimensionSources(Rec, DefaultDimSource, FieldNo);
    end;
#ENDIF
#IF NOT (BC17 or BC18 or BC19 or BC20 or BC2100 or BC2101 or BC2102 or BC2103)

    local procedure GetTableValuePair(FieldNo: Integer) TableValuePair: Dictionary of [Integer, Code[20]]
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeInitTableValuePair(TableValuePair, FieldNo, IsHandled);
        if IsHandled then
            exit;

        case FieldNo of
            FieldNo("No."):
                TableValuePair.Add(NPRDimMgt.LineTypeToTableNPR("Line Type"), "No.");
            FieldNo("Discount Code"):
                TableValuePair.Add(NPRDimMgt.DiscountTypeToTableNPR("Discount Type"), "Discount Code");
            FieldNo("Responsibility Center"):
                TableValuePair.Add(Database::"Responsibility Center", "Responsibility Center");
            FieldNo("NPRE Seating Code"):
                TableValuePair.Add(Database::"NPR NPRE Seating", "NPRE Seating Code");
            FieldNo("Location Code"):
                TableValuePair.Add(Database::Location, "Location Code");
        end;
        OnAfterInitTableValuePair(TableValuePair, FieldNo);
    end;
#ENDIF

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");
    end;

    procedure LookupShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.LookupDimValueCode(FieldNumber, ShortcutDimCode);
        ValidateShortcutDimCode(FieldNumber, ShortcutDimCode);
    end;

    procedure SetDimension(DimCode: Code[20]; DimValueCode: Code[20])
    var
        Dim: Record Dimension;
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
    begin
        if DimCode = '' then
            exit;
        Dim.Get(DimCode);

        DimMgt.GetDimensionSet(TempDimSetEntry, Rec."Dimension Set ID");
        if TempDimSetEntry.Get(TempDimSetEntry."Dimension Set ID", Dim.Code) then
            TempDimSetEntry.Delete();
        if DimValueCode <> '' then begin
            TempDimSetEntry."Dimension Code" := DimCode;
            TempDimSetEntry.Validate("Dimension Value Code", DimValueCode);
            if TempDimSetEntry.Insert() then;
        end;

        Rec."Dimension Set ID" := TempDimSetEntry.GetDimensionSetID(TempDimSetEntry);
        DimMgt.UpdateGlobalDimFromDimSetID(Rec."Dimension Set ID", Rec."Shortcut Dimension 1 Code", Rec."Shortcut Dimension 2 Code");
        Rec.Modify();
    end;

    procedure ShowDimensions() IsChanged: Boolean
    var
        OldDimSetID: Integer;
        DimSetIdLbl: Label '%1 %2 %3', Locked = true;
    begin
        OldDimSetID := "Dimension Set ID";
        "Dimension Set ID" :=
            DimMgt.EditDimensionSet("Dimension Set ID", StrSubstNo(DimSetIdLbl, "Register No.", "Sales Ticket No.", "Line No."));
        DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
        IsChanged := OldDimSetID <> "Dimension Set ID";
    end;

    procedure UpdateVATSetup()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        Handled: Boolean;
    begin
        case true of
            "Line Type" in ["Line Type"::Rounding, "Line Type"::"GL Payment", "Line Type"::"Issue Voucher"]:
                begin
                    if Rec."Gen. Posting Type" = Rec."Gen. Posting Type"::" " then begin
                        "VAT Calculation Type" := "VAT Calculation Type"::"Normal VAT";
                        "VAT %" := 0;
                        "Gen. Bus. Posting Group" := '';
                        "Gen. Prod. Posting Group" := '';
                        "VAT Bus. Posting Group" := '';
                        "VAT Prod. Posting Group" := '';
                    end else begin
                        VATPostingSetup.Get("VAT Bus. Posting Group", "VAT Prod. Posting Group");
                        POSSaleTaxCalc.OnGetVATPostingSetup(VATPostingSetup, Handled);
                        "VAT Identifier" := VATPostingSetup."VAT Identifier";
                        "VAT Calculation Type" := VATPostingSetup."VAT Calculation Type";

                        POSSaleTaxCalc.UpdateSourceTaxSetup(Rec, VATPostingSetup, SalePOS, 0);
                    end;
                end;
            "Line Type" in ["Line Type"::Item, "Line Type"::"Item Category", "Line Type"::"BOM List"]:
                begin
                    VATPostingSetup.Get("VAT Bus. Posting Group", "VAT Prod. Posting Group");
                    POSSaleTaxCalc.OnGetVATPostingSetup(VATPostingSetup, Handled);
                    "VAT Identifier" := VATPostingSetup."VAT Identifier";
                    "VAT Calculation Type" := VATPostingSetup."VAT Calculation Type";

                    POSSaleTaxCalc.UpdateSourceTaxSetup(Rec, VATPostingSetup, SalePOS, 0);
                end;
        end;
    end;

    procedure UpdateAmounts(var SaleLinePOS: Record "NPR POS Sale Line")
    begin
        SaleLinePOS.UpdateLineVatAmounts(SaleLinePOS);

        SaleLinePOS."Discount %" := Abs(SaleLinePOS."Discount %");

    end;

    procedure CalculateTax()
    var
        POSSaleTaxCalc: codeunit "NPR POS Sale Tax Calc.";
    begin
        POSSaleTaxCalc.CalculateTax(Rec, SalePOS, 0);
    end;

    procedure UpdateLineVatAmounts(var SaleLinePOS: Record "NPR POS Sale Line")
    begin
        SaleLinePOS.CalculateTax();
    end;

    local procedure InitFromSalePOS()
    begin
        GetPOSHeader();
        "Allow Line Discount" := SalePOS."Allow Line Discount";
        "Location Code" := SalePOS."Location Code";
        "Price Includes VAT" := SalePOS."Prices Including VAT";
        "Customer Price Group" := SalePOS."Customer Price Group";
        "Gen. Bus. Posting Group" := SalePOS."Gen. Bus. Posting Group";
        "VAT Bus. Posting Group" := SalePOS."VAT Bus. Posting Group";
        "Tax Area Code" := SalePOS."Tax Area Code";
        "Tax Liable" := SalePOS."Tax Liable";
        "NPRE Seating Code" := SalePOS."NPRE Pre-Set Seating Code";
        "Responsibility Center" := SalePOS."Responsibility Center";
        "Shortcut Dimension 1 Code" := SalePOS."Shortcut Dimension 1 Code";
        "Shortcut Dimension 2 Code" := SalePOS."Shortcut Dimension 2 Code";
        "Dimension Set ID" := SalePOS."Dimension Set ID";
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

    local procedure InitFromGLAccount()
    var
        GLAccount: Record "G/L Account";
    begin
        if "No." = '' then
            exit;

        GLAccount.Get("No.");
        GLAccount.CheckGLAcc();
        Description := GLAccount.Name;
        Validate("Gen. Posting Type", GLAccount."Gen. Posting Type");
        Validate("Gen. Bus. Posting Group", GLAccount."Gen. Bus. Posting Group");
        Validate("Gen. Prod. Posting Group", GLAccount."Gen. Prod. Posting Group");
        Validate("VAT Bus. Posting Group", GLAccount."VAT Bus. Posting Group");
        Validate("VAT Prod. Posting Group", GLAccount."VAT Prod. Posting Group");
        Validate("Tax Group Code", GLAccount."Tax Group Code");
    end;

    local procedure InitFromItem()
    begin
        if "No." = '' then
            exit;

        TestItem();
        GetItem();

        "Gen. Prod. Posting Group" := _Item."Gen. Prod. Posting Group";
        "VAT Prod. Posting Group" := _Item."VAT Prod. Posting Group";
        "Item Category Code" := _Item."Item Category Code";
        "Tax Group Code" := _Item."Tax Group Code";
        "Posting Group" := _Item."Inventory Posting Group";
        "Item Disc. Group" := _Item."Item Disc. Group";
        "Custom Disc Blocked" := _Item."NPR Custom Discount Blocked";
        if "Unit of Measure Code" = '' then
            "Unit of Measure Code" := _Item."Base Unit of Measure";
        "Vendor No." := _Item."Vendor No.";
        GetDescription();
        "Magento Brand" := _Item."NPR Magento Brand";
    end;

    local procedure InitFromItemCategory()
    var
        ItemCategory: Record "Item Category";
    begin
        if "No." = '' then
            exit;

        ItemCategory.Get("No.");
        GetItem();
        _Item.TestField("NPR Group sale");
        "Gen. Prod. Posting Group" := _Item."Gen. Prod. Posting Group";
        "VAT Prod. Posting Group" := _Item."VAT Prod. Posting Group";
        "Tax Group Code" := _Item."Tax Group Code";
        "Item Disc. Group" := _Item."Item Disc. Group";
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

    local procedure TestItem()
    var
        ItemVariant: Record "Item Variant";
        SalesBlockedErr: Label 'You cannot sell this item because the Sales Blocked check box is selected on the item card.';
    begin
        if "No." = '' then
            exit;

        _Item.Get("No.");
        _Item.TestField(Blocked, false);
        _Item.TestField("Gen. Prod. Posting Group");
        if _Item.Type = _Item.Type::Inventory then
            _Item.TestField("Inventory Posting Group");
        if _Item."Price Includes VAT" then
            _Item.TestField(_Item."VAT Bus. Posting Gr. (Price)");
        if "Variant Code" <> '' then begin
            ItemVariant.Get(_Item."No.", "Variant Code");
#IF (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
            ItemVariant.TestField("NPR Blocked", false);
#ELSE
            ItemVariant.TestField(Blocked, false);
#ENDIF
        end;
        if _Item."Sales Blocked" then
            Error(SalesBlockedErr);
    end;

    local procedure TestPaymentMethod(POSPaymentMethod: Record "NPR POS Payment Method")
    begin
        POSPaymentMethod.TestField("Block POS Payment", false);
    end;

    local procedure CalcBaseQty(Qty: Decimal): Decimal
    begin
        TestField("Qty. per Unit of Measure");
        exit(Round(Qty * "Qty. per Unit of Measure", 0.00001));
    end;

    local procedure GetItem()
    begin
        TestField("No.");
        if "No." <> _Item."No." then
            _Item.Get("No.");
    end;

    local procedure UpdateCost()
    begin
        Cost := "Unit Cost (LCY)" * Quantity;
    end;

    procedure GetUnitCostLCY(): Decimal
    begin
        exit(GetUnitCostLCY(false));
    end;

    local procedure GetUnitCostLCY(IsSilent: Boolean): Decimal
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ItemTrackingCode: Record "Item Tracking Code";
        ReturnReason: Record "Return Reason";
        VATPercent: Decimal;
        TxtNoSerial: Label 'No open Item Ledger Entry has been found with the Serial No. %2';
    begin
        if "Return Reason Code" <> '' then begin
            ReturnReason.Get("Return Reason Code");
            if ReturnReason."Inventory Value Zero" then
                exit(0);
        end;

        if "Custom Cost" then
            exit("Unit Cost");

        GetItem();
        if ("Serial No." <> '') and (Quantity > 0) then begin
            _Item.TestField("Item Tracking Code");
            ItemTrackingCode.Get(_Item."Item Tracking Code");
            if ItemTrackingCode."SN Specific Tracking" then begin
                ItemLedgerEntry.SetAutoCalcFields("Cost Amount (Actual)");
                ItemLedgerEntry.SetCurrentKey(Open, Positive, "Item No.", "Serial No.");
                ItemLedgerEntry.SetRange(Open, true);
                ItemLedgerEntry.SetRange(Positive, true);
                ItemLedgerEntry.SetRange("Item No.", "No.");
                ItemLedgerEntry.SetRange("Serial No.", "Serial No.");
                if not ItemLedgerEntry.FindFirst() then begin
                    if not IsSilent then
                        Message(TxtNoSerial, "Serial No.");
                    exit(0);
                end;
                exit(ItemLedgerEntry."Cost Amount (Actual)");
            end;
        end;

        if "Price Includes VAT" then
            VATPercent := "VAT %"
        else
            VATPercent := 0;
        if (_Item."NPR Group sale") and (_Item."Profit %" <> 0) then
            exit(((1 - _Item."Profit %" / 100) * "Unit Price" / (1 + VATPercent / 100)) * "Qty. per Unit of Measure")
        else
            exit(_Item."Unit Cost" * "Qty. per Unit of Measure");
    end;

    local procedure UpdateDependingLinesQuantity()
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        if SkipDependantQuantityUpdate then
            exit;

        if xRec.Quantity = 0 then
            exit;

        //TSD is numbering lines differently. Implmented "Main Line No." as reference
        // NOTE: TSD Allows auto split key on new lines
        SaleLinePOS.LockTable(true);
        SaleLinePOS.SetFilter("Register No.", '=%1', "Register No.");
        SaleLinePOS.SetFilter("Sales Ticket No.", '=%1', "Sales Ticket No.");
        SaleLinePOS.SetFilter("Main Line No.", '=%1', "Line No.");
        SaleLinePOS.SetFilter(Accessory, '=%1', true); // not really required, would also be one solution for combination items below
        SaleLinePOS.SetFilter("Main Item No.", '=%1', "No."); // not really required, would also be one solution for combination items below
        if (SaleLinePOS.FindSet(true)) then
            repeat
                SaleLinePOS.SetSkipUpdateDependantQuantity(true);
                SaleLinePOS.Validate(Quantity, SaleLinePOS.Quantity * Quantity / xRec.Quantity);
                SaleLinePOS.SetSkipUpdateDependantQuantity(false);
                SaleLinePOS.SetSkipCalcDiscount(true);
                SaleLinePOS.Modify();
            until SaleLinePOS.Next() = 0;
        SaleLinePOS.Reset();

        SaleLinePOS.SetFilter("Main Line No.", '=%1', 0); // STD will have "Main Line No." as 0 and this function should not interfer in TSD.

        SaleLinePOS.SetRange("Register No.", "Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", "Sales Ticket No.");
        SaleLinePOS.SetRange("Line No.", "Line No.", "Line No." + 9999);
        SaleLinePOS.SetRange(Accessory, true);
        SaleLinePOS.SetRange("Main Item No.", "No.");
        if SaleLinePOS.FindSet(true) then
            repeat
                SaleLinePOS.SetSkipUpdateDependantQuantity(true);
                SaleLinePOS.Validate(Quantity, SaleLinePOS.Quantity * Quantity / xRec.Quantity);
                SaleLinePOS.SetSkipUpdateDependantQuantity(false);
                SaleLinePOS.SetSkipCalcDiscount(true);
                SaleLinePOS.Modify();
            until SaleLinePOS.Next() = 0;
        SaleLinePOS.Reset();

        SaleLinePOS.SetRange("Register No.", "Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", "Sales Ticket No.");
        SaleLinePOS.SetRange(Date, Date);
        SaleLinePOS.SetRange("Line No.", "Line No.", "Line No." + 9999);
        SaleLinePOS.SetRange("Combination Item", true);
        SaleLinePOS.SetRange("Main Item No.", "No.");
        SaleLinePOS.SetRange("Combination No.", "Combination No.");
        if SaleLinePOS.FindSet(true) then
            repeat
                SaleLinePOS.SetSkipUpdateDependantQuantity(true);
                SaleLinePOS.Validate(Quantity, SaleLinePOS.Quantity * Quantity / xRec.Quantity);
                SaleLinePOS.SetSkipUpdateDependantQuantity(false);
                SaleLinePOS.SetSkipCalcDiscount(true);
                SaleLinePOS.Modify();
            until SaleLinePOS.Next() = 0;
    end;

    local procedure GetDescription()
    var
        NPRVarietySetup: Record "NPR Variety Setup";
        ItemVariant: Record "Item Variant";
        IsHandled: Boolean;
    begin
        OnBeforeGetDescription(Rec, IsHandled);
        if IsHandled then
            exit;
        if "Variant Code" <> '' then begin
            ItemVariant.Get(_Item."No.", "Variant Code");
            Description := CopyStr(ItemVariant.Description, 1, MaxStrLen(Rec.Description));
            "Description 2" := CopyStr(ItemVariant."Description 2", 1, MaxStrLen(Rec."Description 2"));
            if NPRVarietySetup.Get() then
                if NPRVarietySetup."Custom Descriptions" then begin
                    Description := CopyStr(_Item.Description, 1, MaxStrLen(Rec.Description));
                    "Description 2" := CopyStr(ItemVariant.Description, 1, MaxStrLen(Rec."Description 2"));
                end;
        end else begin
            Description := CopyStr(_Item.Description, 1, MaxStrLen(Rec.Description));
            "Description 2" := CopyStr(_Item."Description 2", 1, MaxStrLen(Rec."Description 2"));
        end;
    end;

    procedure SetSkipUpdateDependantQuantity(Skip: Boolean)
    begin
        SkipDependantQuantityUpdate := Skip;
    end;

    procedure SerialNoLookup()
    var
        xSaleLinePOS2: Record "NPR POS Sale Line";
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
        TestField("Line Type", "Line Type"::Item);

        GetItem();
        _Item.TestField("Costing Method", _Item."Costing Method"::Specific);
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

    procedure SerialNoValidate()
    var
        SaleLinePOS2: Record "NPR POS Sale Line";
        NPRSalePOS: Record "NPR POS Sale";
        ItemTrackingCode: Record "Item Tracking Code";
        Positive: Boolean;
        Txt004: Label '%2 %1 is not in the stock!';
        Txt005: Label '%2 %1 is already in stock!';
        TotalNonAppliedQuantity: Decimal;
    begin
        if "Serial No." = '' then
            exit;

        TotalAuditRollQuantity := 0;
        TotalItemLedgerEntryQuantity := 0;
        TestField(Quantity);

        GetItem();
        _Item.TestField("Item Tracking Code");
        ItemTrackingCode.Get(_Item."Item Tracking Code");

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
                if (TotalNonAppliedQuantity < 0) then
                    Error(Txt004, "Serial No.", FieldName("Serial No."));
            end else begin
                TotalNonAppliedQuantity := TotalItemLedgerEntryQuantity - TotalAuditRollQuantity - Quantity;
                if TotalNonAppliedQuantity > 1 then
                    Error(Txt005, "Serial No.", FieldName("Serial No."));
            end;
        end;
    end;

    procedure GetDefaultBin()
    var
        WMSManagement: Codeunit "WMS Management";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetDefaultBin(Rec, IsHandled);
        if IsHandled then
            exit;

        if not IsInventoriableItem() then
            exit;

        "Bin Code" := '';

        if ("Location Code" <> '') and ("No." <> '') then begin
            GetLocation("Location Code");
            if _Location."Bin Mandatory" and not _Location."Directed Put-away and Pick" then begin
                if IsAsmToOrderRequired() then
                    if GetATOBin(_Location, "Bin Code") then
                        exit;

                if not IsShipmentBinOverridesDefaultBin(_Location) then begin
                    WMSManagement.GetDefaultBin("No.", "Variant Code", "Location Code", "Bin Code");
                    HandleDedicatedBin(false);
                end;
            end;
        end;

        OnAfterGetDefaultBin(Rec);
    end;

    local procedure GetATOBin(Location: Record Location; var BinCode: Code[20]): Boolean
    var
        AsmHeader: Record "Assembly Header";
    begin
        if not Location."Require Shipment" then
            BinCode := Location."Asm.-to-Order Shpt. Bin Code";
        if BinCode <> '' then
            exit(true);

        if AsmHeader.GetFromAssemblyBin(Location, BinCode) then
            exit(true);

        exit(false);
    end;

    local procedure HandleDedicatedBin(IssueWarning: Boolean)
    var
        WhseIntegrationMgt: Codeunit "Whse. Integration Management";
    begin
        if Quantity <= 0 then
            exit;

        WhseIntegrationMgt.CheckIfBinDedicatedOnSrcDoc("Location Code", "Bin Code", IssueWarning);
    end;

    procedure IsInventoriableItem(): Boolean
    begin
        if ("Line Type" <> "Line Type"::Item) or ("No." = '') then
            exit(false);
        GetItem();
        exit(_Item.IsInventoriableType());
    end;

    local procedure GetLocation(LocationCode: Code[10])
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetLocation(Rec, xRec, _Location, LocationCode, IsHandled);
        If IsHandled then
            exit;

        if LocationCode = '' then
            Clear(_Location)
        else
            if _Location.Code <> LocationCode then
                _Location.Get(LocationCode);
    end;

    local procedure IsAsmToOrderRequired(): Boolean
    var
        POSPostItemEntries: Codeunit "NPR POS Post Item Entries";
        IsHandled: Boolean;
        Result: Boolean;
    begin
        OnBeforeIsAsmToOrderRequired(Rec, Result, IsHandled);
        if IsHandled then
            exit(Result);

        if ("Line Type" <> "Line Type"::Item) or ("No." = '') then
            exit(false);

        exit(POSPostItemEntries.IsAsmToOrderRequired("No.", "Variant Code", "Location Code"));
    end;

    local procedure IsShipmentBinOverridesDefaultBin(Location: Record Location): Boolean
    var
        Bin: Record Bin;
        ShipmentBinAvailable: Boolean;
    begin
        ShipmentBinAvailable := Bin.Get(Location.Code, Location."Shipment Bin Code");
        exit(Location."Require Shipment" and ShipmentBinAvailable);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetDescription(var POSSaleLine: Record "NPR POS Sale Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetDefaultBin(var POSSaleLine: Record "NPR POS Sale Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetDefaultBin(var POSSaleLine: Record "NPR POS Sale Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetLocation(var POSSaleLine: Record "NPR POS Sale Line"; xPOSSaleLine: Record "NPR POS Sale Line"; var Location: Record "Location"; LocationCode: Code[10]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeIsAsmToOrderRequired(POSSaleLine: Record "NPR POS Sale Line"; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;
#IF NOT (BC17 or BC18 or BC19)

    [IntegrationEvent(true, false)]
    local procedure OnBeforeCreateDim(var IsHandled: Boolean; var POSSaleLine: Record "NPR POS Sale Line"; FieldNo: Integer; DefaultDimSource: List of [Dictionary of [Integer, Code[20]]])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateDimOnBeforeUpdateGlobalDimFromDimSetID(var POSSaleLine: Record "NPR POS Sale Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateDim(var POSSaleLine: Record "NPR POS Sale Line"; CallingFieldNo: Integer; xPOSSaleLine: Record "NPR POS Sale Line");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateDimFromDefaultDim(var POSSaleLine: Record "NPR POS Sale Line"; xPOSSaleLine: Record "NPR POS Sale Line"; var POSSale: Record "NPR POS Sale"; CurrFieldNo: Integer; CallingFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitDefaultDimensionSources(var POSSaleLine: Record "NPR POS Sale Line"; var DefaultDimSource: List of [Dictionary of [Integer, Code[20]]]; FieldNo: Integer)
    begin
    end;
#ENDIF
#IF NOT (BC17 or BC18 or BC19 or BC20 or BC2100 or BC2101 or BC2102 or BC2103)

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitTableValuePair(var TableValuePair: Dictionary of [Integer, Code[20]]; FieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitTableValuePair(var TableValuePair: Dictionary of [Integer, Code[20]]; FieldNo: Integer)
    begin
    end;
#ENDIF

    [IntegrationEvent(false, false)]
    local procedure OnAfterTransferToSalesLine(NPRPOSSaleLine: Record "NPR POS Sale Line"; var SaleLine: Record "Sales Line")
    begin
    end;
}
