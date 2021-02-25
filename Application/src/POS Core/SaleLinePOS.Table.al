table 6014406 "NPR Sale Line POS"
{
    Caption = 'Sale Line';
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
        field(3; "Sale Type"; Option)
        {
            Caption = 'Sale Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Sale,Payment,Debit Sale,Gift Voucher,Credit Voucher,Deposit,Out payment,Comment,Cancelled,Open/Close';
            OptionMembers = Sale,Payment,"Debit Sale","Gift Voucher","Credit Voucher",Deposit,"Out payment",Comment,Cancelled,"Open/Close";
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
        }
        field(6; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            TableRelation = IF (Type = CONST("G/L Entry")) "G/L Account"."No."
            ELSE
            IF (Type = CONST("Item Group")) "NPR Item Group"."No."
            ELSE
            IF (Type = CONST(Repair)) "NPR Customer Repair"."No."
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
                            "Unit Price" := FindItemSalesPrice();
                            Validate(Quantity);
                        end;
                    Type::"Item Group":
                        begin
                            InitFromItemGroup();
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
                  NPRDimMgt.DiscountTypeToTableNPR("Discount Type"), "Discount Code",
                  DATABASE::"NPR NPRE Seating", "NPRE Seating Code",
                  0, '');
            end;
        }
        field(7; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location;
        }
        field(8; "Posting Group"; Code[20])
        {
            Caption = 'Posting Group';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = IF (Type = CONST(Item)) "Inventory Posting Group";
        }
        field(9; "Qty. Discount Code"; Code[20])
        {
            Caption = 'Qty. Discount Code';
            DataClassification = CustomerContent;
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
            TableRelation = IF (Type = CONST(Item),
                                "No." = FILTER(<> '')) "Item Unit of Measure".Code WHERE("Item No." = FIELD("No."))
            ELSE
            "Unit of Measure";

            trigger OnValidate()
            var
                UOMMgt: Codeunit "Unit of Measure Management";
            begin
                GetItem;
                "Qty. per Unit of Measure" := UOMMgt.GetQtyPerUnitOfMeasure(Item, "Unit of Measure Code");
                "Quantity (Base)" := CalcBaseQty(Quantity);
                "Unit Price" := FindItemSalesPrice();
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
                SaleLinePOS: Record "NPR Sale Line POS";
                Txt001: Label 'Quantity can not be changes on a repair sale';
                Err001: Label 'Quantity at %2 %1 can only be 1 or -1';
                Err003: Label 'A quantity must be specified on the line';
                OldUnitPrice: Decimal;
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
                            if not Silent then begin
                                if Quantity = 0 then
                                    Error(Err003);
                            end;
                            UpdateAmounts(Rec);
                        end;
                    Type::Item:
                        begin
                            GetItem;
                            "Quantity (Base)" := CalcBaseQty(Quantity);

                            UpdateDependingLinesQuantity;

                            if ("Discount Type" = "Discount Type"::Manual) and ("Discount %" <> 0) then
                                Validate("Discount %");

                            CalculateCostPrice;
                            UpdateAmounts(Rec);

                            if not Item."NPR Group sale" then begin
                                OldUnitPrice := "Unit Price";
                                "Unit Price" := Rec.FindItemSalesPrice();
                                if OldUnitPrice <> "Unit Price" then
                                    UpdateAmounts(Rec);
                            end;
                        end;
                    Type::"Item Group":
                        begin
                            if Quantity = 0 then
                                Error(Err003);
                            if "Price Includes VAT" then
                                "Amount Including VAT" := Round("Unit Price" * Quantity, 0.01)
                            else
                                "Amount Including VAT" := Round("Unit Price" * Quantity * (1 + "VAT %" / 100), 0.01);
                        end;
                    Type::Repair:
                        begin
                            Error(Txt001);
                        end;
                    Type::"BOM List":
                        begin
                            SaleLinePOS.SetRange("Register No.", "Register No.");
                            SaleLinePOS.SetRange("Sales Ticket No.", "Sales Ticket No.");
                            SaleLinePOS.SetRange("Sale Type", "Sale Type");
                            SaleLinePOS.SetRange(Date, Date);
                            SaleLinePOS.SetRange("Discount Code", "Discount Code");
                            SaleLinePOS.SetFilter("No.", '<>%1', "No.");
                            "Amount Including VAT" := 0;
                        end;
                end;
                UpdateCost;
            end;
        }
        field(13; "Invoice (Qty)"; Decimal)
        {
            Caption = 'Invoice (Qty)';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(14; "To Ship (Qty)"; Decimal)
        {
            Caption = 'To Ship (Qty)';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
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
                RetailSetup: Record "NPR NP Retail Setup";
                ErrDisabled: Label 'Unit Cost is disabled';
                ErrDisNo: Label 'Unit Cost is disabled for Quantity > 0';
                ErrDisX: Label 'Unit Cost cannot be reduced';
                ErrItemBelow: Label 'Price cannot be negative.';
                Err001: Label 'A quantity must be specified on the line';
                Err002: Label 'The creditvoucher cannot be changed';
                Err003: Label 'The sales price cannot be changed for this item';
                TotalAmount: Decimal;
            begin
                RetailSetup.Get;
                POSUnitGlobal.Get("Register No.");
                case Type of
                    Type::"G/L Entry":
                        begin
                            if Quantity <> 0 then begin
                                "Amount Including VAT" := "Unit Price" * Quantity;
                                Amount := "Amount Including VAT";
                            end;
                        end;
                    Type::Item:
                        begin
                            if "Unit Price" < 0 then
                                Error(ErrItemBelow);
                            GetItem;

                            if not Item."NPR Group sale" then begin
                                case RetailSetup."Unit Cost Control" of
                                    RetailSetup."Unit Cost Control"::Enabled:
                                        begin
                                        end;
                                    RetailSetup."Unit Cost Control"::Disabled:
                                        begin
                                            if Quantity < 0 then
                                                Error(ErrDisabled);
                                        end;
                                    RetailSetup."Unit Cost Control"::"Disabled if Quantity > 0":
                                        begin
                                            if Quantity > 0 then
                                                Error(ErrDisNo);
                                        end;
                                    RetailSetup."Unit Cost Control"::"Disabled if xUnit Cost > Unit Cost":
                                        begin
                                            if xRec."Unit Price" > "Unit Price" then
                                                Error(ErrDisX);
                                        end;
                                    RetailSetup."Unit Cost Control"::"Disabled if Quantity > 0 and xUnit Cost > Unit Cost":
                                        begin
                                            if not ((Quantity < 0) or ("Unit Price" >= FindItemSalesPrice())) then
                                                Error(ErrDisX);
                                        end;
                                end;
                            end;

                            "Eksp. Salgspris" := true;
                            GetAmount(Rec, Item, "Unit Price");
                            if ("No." <> '') then begin
                                if (Item."NPR Group sale") or (Item."Unit Cost" = 0) then begin
                                    CalculateCostPrice();
                                end else
                                    if ("Serial No." <> '') and (Quantity > 0) then
                                        Error(Err003);
                            end;
                            "Custom Price" := true;
                        end;
                    Type::"Item Group":
                        begin
                            if Quantity = 0 then
                                Error(Err001);
                            if RetailSetup.Get then
                                if "Price Includes VAT" then
                                    "Amount Including VAT" := Round("Unit Price" * Quantity, 0.01) - "Discount Amount"
                                else
                                    "Amount Including VAT" := Round("Unit Price" * Quantity * (1 + "VAT %" / 100), 0.01);
                        end;
                    Type::"BOM List":
                        begin
                            "Unit Price" := xRec."Unit Price";
                            exit;
                        end;
                    Type::Customer:
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
                UpdateCost;
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
                SaleLinePOS: Record "NPR Sale Line POS";
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

                case Type of
                    Type::"G/L Entry":
                        begin
                            if not ("Sale Type" = "Sale Type"::Deposit) then
                                Error(Trans0003);
                            "Discount Type" := "Discount Type"::" ";
                            "Discount Code" := '';
                            "Discount Amount" := Round("Unit Price" * "Discount %" / 100, POSSetup.AmountRoundingPrecision);
                            "Amount Including VAT" := "Unit Price" - "Discount Amount";
                        end;
                    Type::Item:
                        begin
                            RemoveBOMDiscount;
                            if "Discount %" > 0 then
                                "Discount Type" := "Discount Type"::Manual;
                            "Discount Code" := xRec."Discount Code";
                            "Amount Including VAT" := 0;
                            "Discount Amount" := 0;
                            if Modify then;
                            GetItem();
                            GetAmount(Rec, Item, Rec."Unit Price");
                        end;
                    Type::"Item Group":
                        Error(Trans0002);
                    Type::"BOM List":
                        begin
                            "Discount %" := xRec."Discount %";
                            exit;
                        end;
                    Type::Customer:
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
                if "Price Includes VAT" then begin
                    Validate("Discount %", "Discount Amount" / "Unit Price" / Quantity * 100);
                end else begin
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
                    case Type of
                        Type::Item:
                            begin
                                GetItem;
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

                                if Modify then;
                                GetAmount(Rec, Item, Rec."Unit Price");
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
        }
        field(43; "Serial No."; Code[20])
        {
            Caption = 'Serial No.';
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                SerialNoLookup;
            end;

            trigger OnValidate()
            begin
                SerialNoValidate();
                Validate("Unit Cost (LCY)", GetUnitCostLCY);
            end;
        }
        field(44; "Customer/Item Discount %"; Decimal)
        {
            Caption = 'Customer/Item Discount %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            MaxValue = 100;
            MinValue = 0;
        }
        field(46; "Invoice to Customer No."; Code[20])
        {
            Caption = 'Invoice to Customer No.';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = Customer;
        }
        field(47; "Invoice Discount Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Invoice Discount Amount';
            DataClassification = CustomerContent;
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
            TableRelation = "NPR Period Discount".Code;

            trigger OnValidate()
            begin
                CreateDim(
                  NPRDimMgt.TypeToTableNPR(Type), "No.",
                  NPRDimMgt.DiscountTypeToTableNPR("Discount Type"), "Discount Code",
                  DATABASE::"NPR NPRE Seating", "NPRE Seating Code",
                  0, '');
            end;
        }
        field(59; "Lookup On No."; Boolean)
        {
            Caption = 'Lookup On No.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
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

            trigger OnValidate()
            var
                Customer: Record Customer;
            begin
                if "Special price" = 0 then begin
                    GetItem;
                    "Custom Price" := false;
                    "Eksp. Salgspris" := false;
                    GetAmount(Rec, Item, FindItemSalesPrice());
                end else begin
                    GetPOSHeader;
                    if Customer.Get(SalePOS."Customer No.") then begin
                        if Customer."NPR Type" = Customer."NPR Type"::Cash then begin
                            if Customer."Prices Including VAT" then
                                Validate("Unit Price", "Special price" * (1 + "VAT %" / 100))
                            else
                                Validate("Unit Price", "Special price");
                            if "Discount %" <> 0 then
                                Validate("Discount %", 0);
                        end;
                    end;
                end;
            end;
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
                    GetPOSHeader;
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
                    UpdateCost;
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
        }
        field(102; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
            TableRelation = IF (Type = CONST(Item)) "Item Variant".Code WHERE("Item No." = FIELD("No."));

            trigger OnValidate()
            begin
                Validate("No.");
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
                TestField(Type);
                TestField(Quantity);
                TestField("Unit Price");
                GetPOSHeader;
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
        }
        field(118; "Retail Document No."; Code[20])
        {
            Caption = 'Retail Document No.';
            DataClassification = CustomerContent;
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
        }
        field(161; "Orig. POS Line No."; Integer)
        {
            Caption = 'Orig. POS Line No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.31';
        }
        field(170; "Retail ID"; Guid)
        {
            Caption = 'Retail ID';
            DataClassification = CustomerContent;
            Description = 'NPR5.50';
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
        }
        field(303; "Return Sale Line No."; Integer)
        {
            Caption = 'Return Sale Line No.';
            DataClassification = CustomerContent;
        }
        field(304; "Return Sale No."; Code[20])
        {
            Caption = 'Return Sale No.';
            DataClassification = CustomerContent;
        }
        field(305; "Return Sales Sales Date"; Date)
        {
            Caption = 'Return Sales Sales Date';
            DataClassification = CustomerContent;
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
                CreateDim(
                    NPRDimMgt.TypeToTableNPR(Type), "No.",
                    NPRDimMgt.DiscountTypeToTableNPR("Discount Type"), "Discount Code",
                    DATABASE::"NPR NPRE Seating", "NPRE Seating Code",
                    0, '');
            end;
        }
        field(402; "Discount Calculated"; Boolean)
        {
            Caption = 'Discount Calculated';
            DataClassification = CustomerContent;
            Description = 'NPR5.40';
        }
        field(405; "Discount Authorised by"; Code[20])
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
                                                                   "Sale Type" = FIELD("Sale Type"),
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
                                                                                   "Sale Type" = FIELD("Sale Type"),
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

        }
        field(550; "Drawer Opened"; Boolean)
        {
            Caption = 'Drawer Opened';
            DataClassification = CustomerContent;
            Description = 'NPR4.002.005, for indication of opening on drawer.';
            ObsoleteState = Removed;
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
                CreateDim(
                  DATABASE::"NPR NPRE Seating", "NPRE Seating Code",
                  NPRDimMgt.TypeToTableNPR(Type), "No.",
                  NPRDimMgt.DiscountTypeToTableNPR("Discount Type"), "Discount Code",
                  0, '');
            end;
        }
        field(801; "Insurance Category"; Code[50])
        {
            Caption = 'Insurance Category';
            DataClassification = CustomerContent;
            TableRelation = "NPR Insurance Category";

            trigger OnValidate()
            begin
                if (xRec."Insurance Category" <> '') and ("Insurance Category" <> xRec."Insurance Category") then
                    "Cust Forsikring" := true;
            end;
        }
        field(5002; Color; Code[20])
        {
            Caption = 'Color';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
        }
        field(5003; Size; Code[20])
        {
            Caption = 'Size';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
        }
        field(5004; Clearing; Option)
        {
            Caption = 'Clearing';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Gift Voucher,Credit Voucher';
            OptionMembers = " ",Gavekort,Tilgodebevis;
        }
        field(5008; "External Document No."; Code[20])
        {
            Caption = 'External Document No.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
        }
        field(5999; "Buffer Ref. No."; Integer)
        {
            Caption = 'Buffer Ref. No.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
        }
        field(6000; "Buffer Document Type"; Enum "Gen. Journal Document Type")
        {
            Caption = 'Buffer Document Type';
            DataClassification = CustomerContent;
        }
        field(6001; "Buffer ID"; Code[20])
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
            TableRelation = "NPR Item Group";

            trigger OnValidate()
            begin
                CreateDim(
                  NPRDimMgt.TypeToTableNPR(Type), "No.",
                  NPRDimMgt.DiscountTypeToTableNPR("Discount Type"), "Discount Code",
                  DATABASE::"NPR NPRE Seating", "NPRE Seating Code",
                  0, '');
            end;
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
        }
        field(6023; "Gift Voucher Ref."; Code[20])
        {
            Caption = 'Gift Voucher Ref.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
        }
        field(6024; "Credit voucher ref."; Code[20])
        {
            Caption = 'Credit voucher ref.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
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
        }
        field(6027; "Wish List Line No."; Integer)
        {
            Caption = 'Wish List Line No.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
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
        }
        field(6033; "Offline Sales Ticket No"; Code[20])
        {
            Caption = 'Emergency Ticket No.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
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
        }
        field(6037; GiftCrtLine; Integer)
        {
            Caption = 'Gift Certificate Line';
            DataClassification = CustomerContent;
        }
        field(6038; "Label Date"; Date)
        {
            Caption = 'Label Date';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
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
        }
        field(6051; "Product Group Code"; Code[10])
        {
            Caption = 'Product Group Code';
            DataClassification = CustomerContent;
            ObsoleteState = No;
            //ObsoleteReason = 'Product Groups became first level children of Item Categories.';
            //ObsoleteTag = '15.0';
        }
        field(6055; "Lock Code"; Code[10])
        {
            Caption = 'Lock Code';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
        }
        field(6100; "Main Line No."; Integer)
        {
            Caption = 'Main Line No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.40';
        }
        field(7014; "Item Disc. Group"; Code[20])
        {
            Caption = 'Item Disc. Group';
            DataClassification = CustomerContent;
            TableRelation = IF (Type = CONST(Item),
                                "No." = FILTER(<> '')) "Item Discount Group" WHERE(Code = FIELD("Item Disc. Group"));
            ValidateTableRelation = false;
        }
        field(10000; Silent; Boolean)
        {
            Caption = 'Silent';
            DataClassification = CustomerContent;
        }
        field(10001; Deleting; Boolean)
        {
            Caption = 'Deleting';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
        }
        field(10002; NoWarning; Boolean)
        {
            Caption = 'No Warning';
            DataClassification = CustomerContent;
        }
        field(10003; CondFirstRun; Boolean)
        {
            Caption = 'Conditioned First Run';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
        }
        field(10004; CurrencySilent; Boolean)
        {
            Caption = 'Currency (Silent)';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
        }
        field(10005; StyklisteSilent; Boolean)
        {
            Caption = 'Bill of materials (Silent)';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
        }
        field(10006; "Cust Forsikring"; Boolean)
        {
            Caption = 'Cust. Insurrance';
            DataClassification = CustomerContent;
        }
        field(10007; Forsikring; Boolean)
        {
            Caption = 'Insurrance';
            DataClassification = CustomerContent;
        }
        field(10008; TestOnServer; Boolean)
        {
            Caption = 'Test on Server';
            DataClassification = CustomerContent;
        }
        field(10009; "Customer No. Line"; Boolean)
        {
            Caption = 'Customer No. Line';
            DataClassification = CustomerContent;
        }
        field(10010; ForceApris; Boolean)
        {
            Caption = 'Force A-Price';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
        }
        field(10011; GuaranteePrinted; Boolean)
        {
            Caption = 'Guarantee Certificat Printed';
            DataClassification = CustomerContent;
            Description = 'Field set true, if guarantee certificate has been printed';
            ObsoleteState = Removed;
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
        }
        field(6014511; "Label No."; Code[8])
        {
            Caption = 'Label Number';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
        }
        field(6014512; "SQL Server Timestamp"; BigInteger)
        {
            Caption = 'Timestamp';
            DataClassification = CustomerContent;
            Editable = false;
            SQLTimestamp = true;
        }
    }

    keys
    {
        key(Key1; "Register No.", "Sales Ticket No.", Date, "Sale Type", "Line No.")
        {
            MaintainSIFTIndex = false;
            SumIndexFields = "Amount Including VAT", Cost, "Discount Amount", Amount;
        }
        key(Key2; "Register No.", "Sales Ticket No.", "Sale Type", "Line No.")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
        }
        key(Key3; "Register No.", "Sales Ticket No.", "Sale Type", Type, "No.", "Item Group", Quantity)
        {
            MaintainSIFTIndex = false;
            SumIndexFields = "Amount Including VAT", Amount, Quantity;
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
        key(Key9; "Insurance Category", "Register No.", "Sales Ticket No.", Date, "Sale Type", Type)
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount Including VAT";
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        SaleLinePOS: Record "NPR Sale Line POS";
        POSPaymentMethod: Record "NPR POS Payment Method";
        ErrNoDeleteDep: Label 'Deposit line from a rental is not to be deleted.';
        ICommRec: Record "NPR I-Comm";
        Err001: Label '%1 is not legal tender';
        Err002: Label 'A financial account has not been selected for the purchase %1';
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
    begin
        if "EFT Approved" then
            Error(ERR_EFT_DELETE);

        if ((Type = Type::Customer) and ("Sale Type" = "Sale Type"::Deposit) and ("From Selection")) then
            Error(ErrNoDeleteDep);

        if (Type = Type::Item) or (Type = Type::"BOM List") then begin
            case "Discount Type" of
                "Discount Type"::"BOM List":
                    begin
                        SaleLinePOS.Reset;
                        SaleLinePOS.SetRange("Register No.", "Register No.");
                        SaleLinePOS.SetRange("Sales Ticket No.", "Sales Ticket No.");
                        SaleLinePOS.SetRange("Sale Type", "Sale Type");
                        SaleLinePOS.SetRange(Date, Date);
                        SaleLinePOS.SetRange("Discount Code", "Discount Code");
                        if SaleLinePOS.FindSet then
                            repeat
                                if SaleLinePOS.Type = Type::"BOM List" then
                                    SaleLinePOS.Validate("No.");
                                if "Line No." <> SaleLinePOS."Line No." then
                                    SaleLinePOS.Delete;
                            until SaleLinePOS.Next = 0;
                    end;
            end;
        end;

        if GiftCrtLine <> 0 then begin
            SaleLinePOS.Reset;
            SaleLinePOS.SetRange("Register No.", "Register No.");
            SaleLinePOS.SetRange("Sales Ticket No.", "Sales Ticket No.");
            SaleLinePOS.SetRange("Sale Type", SaleLinePOS."Sale Type"::"Out payment");
            SaleLinePOS.SetRange(Type, SaleLinePOS.Type::"G/L Entry");
            SaleLinePOS.SetRange("Line No.", GiftCrtLine);
            if SaleLinePOS.FindFirst then
                SaleLinePOS.Delete;
        end;

        TicketRequestManager.OnDeleteSaleLinePos(Rec);
    end;

    trigger OnInsert()
    begin
        if "Orig. POS Sale ID" = 0 then begin
            GetPOSHeader;

            "Orig. POS Sale ID" := SalePOS."POS Sale ID";
            "Orig. POS Line No." := "Line No.";
        end;

        if IsNullGuid("Retail ID") then begin
            "Retail ID" := CreateGuid();
        end;
    end;

    trigger OnRename()
    var
        ErrBlanc: Label 'Number in the expedition line must not be blank.';
    begin
        if (xRec."No." <> '') and ("No." = '') then
            Error(ErrBlanc);
    end;

    var
        Item: Record Item;
        POSUnitGlobal: Record "NPR POS Unit";
        CustomerGlobal: Record Customer;
        SalePOS: Record "NPR Sale POS";
        Currency: Record Currency;
        DimMgt: Codeunit DimensionManagement;
        NPRDimMgt: Codeunit "NPR Dimension Mgt.";
        TotalItemLedgerEntryQuantity: Decimal;
        TotalAuditRollQuantity: Decimal;
        SkipCalcDiscount: Boolean;
        ErrVATCalcNotSupportInPOS: Label '%1 %2 not supported in POS';
        Text000: Label 'Only one means of payment type allowed as payment choice on Invoice';
        Text001: Label 'Account is missing on Payment Type %1';
        Text002: Label '%1 %2 is used more than once.';
        Text003: Label 'Adjust the inventory first, and then continue the transaction';
        Text004: Label '%1 %2 is already used.';
        ERR_EFT_DELETE: Label 'Cannot delete externally approved electronic funds transfer. Please attempt refund or void of the original transaction instead.';

    local procedure GetPOSHeader()
    var
        SalePOS2: Record "NPR Sale POS";
    begin
        if SalePOS2.Get("Register No.", "Sales Ticket No.") then
            SalePOS := SalePOS2;
        Currency.InitRoundingPrecision;
    end;

    procedure SetPOSHeader(NewSalePOS: Record "NPR Sale POS")
    begin
        SalePOS := NewSalePOS;
        Currency.InitRoundingPrecision;
    end;

    procedure CalculateCostPrice()
    var
        VATPercent: Decimal;
    begin
        GetItem;

        if "Price Includes VAT" then
            VATPercent := "VAT %"
        else
            VATPercent := 0;

        if (Item."NPR Group sale") and (Item."Profit %" <> 0) then
            Validate("Unit Cost (LCY)", ((1 - Item."Profit %" / 100) * "Unit Price" / (1 + VATPercent / 100)) * "Qty. per Unit of Measure")
        else
            Validate("Unit Cost (LCY)", Item."Unit Cost" * "Qty. per Unit of Measure");
    end;

    procedure RemoveBOMDiscount()
    var
        SaleLinePOS: Record "NPR Sale Line POS";
    begin
        if ("Discount Type" = "Discount Type"::"BOM List") then begin
            SaleLinePOS.SetRange("Register No.", "Register No.");
            SaleLinePOS.SetRange("Sales Ticket No.", "Sales Ticket No.");
            SaleLinePOS.SetRange("Sale Type", "Sale Type");
            SaleLinePOS.SetRange(Date, Date);
            SaleLinePOS.SetRange("Discount Code", "Discount Code");
            SaleLinePOS.SetFilter("No.", '<>%1', "No.");
            if SaleLinePOS.FindSet(true, false) then
                repeat
                    if SaleLinePOS.Type = Type::"BOM List" then
                        SaleLinePOS.Delete
                    else begin
                        SaleLinePOS."Discount Type" := "Discount Type"::" ";
                        SaleLinePOS."Discount Code" := '';
                        SaleLinePOS."Discount %" := 0;
                        SaleLinePOS."Discount Amount" := 0;
                        SaleLinePOS."Amount Including VAT" := 0;
                        SaleLinePOS.Validate("No.");
                        SaleLinePOS.Modify;
                    end;
                until SaleLinePOS.Next = 0;
        end;
    end;

    procedure FindItemSalesPrice(): Decimal
    var
        TempSaleLinePOS: Record "NPR Sale Line POS" temporary;
        POSSalesPriceCalcMgt: Codeunit "NPR POS Sales Price Calc. Mgt.";
    begin
        if "Manual Item Sales Price" then
            exit("Unit Price");
        GetPOSHeader;
        TempSaleLinePOS := Rec;
        TempSaleLinePOS."Currency Code" := '';
        POSSalesPriceCalcMgt.FindItemPrice(SalePOS, TempSaleLinePOS);
        exit(TempSaleLinePOS."Unit Price");
    end;

    procedure GetAmount(var SaleLinePOS: Record "NPR Sale Line POS"; var Item: Record Item; UnitPrice: Decimal)
    begin
        SaleLinePOS."Unit Price" := UnitPrice;
        UpdateAmounts(SaleLinePOS);
    end;

    procedure TransferToSalesLine(var SalesLine: Record "Sales Line"): Boolean
    var
        Txt001: Label 'Deposit';
    begin
        if ("No." = '*') or (Type = Type::Comment) then begin
            SalesLine."No." := '';
            SalesLine.Description := Description;
            SalesLine."Description 2" := "Description 2";
            exit;
        end;

        if (Type = Type::Customer) and ("Sale Type" = "Sale Type"::Deposit) then begin
            SalesLine."No." := '';
            SalesLine.Description := Txt001 + ' ' + Format(Abs("Amount Including VAT"));
            exit;
        end;

        SalesLine.Validate("No.", "No.");
        SalesLine."Location Code" := "Location Code";
        SalesLine."Posting Group" := "Posting Group";
        SalesLine.Validate("Unit of Measure Code", "Unit of Measure Code");
        SalesLine.Validate(Quantity, Quantity);
        SalesLine.Description := Description;
        SalesLine."Unit Price" := "Unit Price";
        SalesLine."Line Discount %" := "Discount %";
        SalesLine."Line Discount Amount" := "Discount Amount";
        SalesLine.Amount := Amount;
        SalesLine."Amount Including VAT" := "Amount Including VAT";
        SalesLine."Allow Invoice Disc." := "Allow Invoice Discount";
        SalesLine."Customer Price Group" := "Customer Price Group";
        if CustomerGlobal."Bill-to Customer No." <> '' then
            SalesLine."Bill-to Customer No." := CustomerGlobal."Bill-to Customer No."
        else
            SalesLine."Bill-to Customer No." := SalesLine."Sell-to Customer No.";

        SalesLine."Inv. Discount Amount" := "Invoice Discount Amount";
        SalesLine."Currency Code" := "Currency Code";
        SalesLine."Outstanding Amount (LCY)" := "Claim (LCY)";
        SalesLine."VAT Base Amount" := "VAT Base Amount";
        SalesLine."NPR Special Price" := "Special price";
        SalesLine."Unit Cost" := "Unit Cost";
        SalesLine."NPR Discount Type" := "Discount Type";
        SalesLine."NPR Discount Code" := "Discount Code";
        SalesLine."VAT Calculation Type" := "VAT Calculation Type";
        SalesLine."NPR Internal" := Internal;
        SalesLine."NPR Serial No. not Created" := "Serial No. not Created";
        SalesLine."Unit Cost (LCY)" := "Unit Cost (LCY)";
        SalesLine.Validate("Variant Code", "Variant Code");
        SalesLine.Description := Description;
        SalesLine."Description 2" := "Description 2";
    end;

    procedure CheckSerialNoApplication(ItemNo: Code[20]; SerialNo: Code[20])
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ItemLedgerEntry.SetCurrentKey(Open, Positive, "Item No.", "Serial No.");
        ItemLedgerEntry.SetRange("Item No.", ItemNo);
        ItemLedgerEntry.SetRange(Open, true);
        ItemLedgerEntry.SetRange(Positive, true);
        ItemLedgerEntry.SetRange("Serial No.", SerialNo);
        if ItemLedgerEntry.FindFirst then begin
            ItemLedgerEntry.CalcSums(Quantity);
            TotalItemLedgerEntryQuantity := ItemLedgerEntry.Quantity;
            if ItemLedgerEntry.Count > 1 then
                Error(Text002 + Text003, FieldName("Serial No."), "Serial No.");
        end;
    end;

    procedure CheckSerialNoAuditRoll(ItemNo: Code[20]; SerialNo: Code[20]; Positive: Boolean)
    var
        AuditRoll: Record "NPR Audit Roll";
        Err001: Label '%2 %1 is already in stock but has not been posted yet';
        Err002: Label '%2 %1 has already been sold to a customer but is not yet posted';
    begin
        if Positive then begin
            AuditRoll.SetCurrentKey(Posted, "Serial No.");
            AuditRoll.SetRange(Posted, false);
            AuditRoll.SetRange("Serial No.", "Serial No.");
            if AuditRoll.FindFirst then
                AuditRoll.CalcSums(Quantity);
            TotalAuditRollQuantity := AuditRoll.Quantity;
            if AuditRoll.Quantity = -1 then
                Error(Err001, "Serial No.", FieldName("Serial No."));
        end else begin
            AuditRoll.SetCurrentKey(Posted, "Serial No.");
            AuditRoll.SetRange(Posted, false);
            AuditRoll.SetRange("Serial No.", "Serial No.");
            if AuditRoll.FindFirst then
                AuditRoll.CalcSums(Quantity);
            TotalAuditRollQuantity := AuditRoll.Quantity;
            if AuditRoll.Quantity = 1 then
                Error(Err002, "Serial No.", FieldName("Serial No."));
        end;
    end;

    procedure TransferToService()
    var
        ServiceItem: Record "Service Item";
    begin
        GetPOSHeader;
        ServiceItem.Init;
        ServiceItem.Insert(true);
        ServiceItem.Validate("Item No.", "No.");
        ServiceItem.Validate("Serial No.", "Serial No.");
        ServiceItem.Validate(Status, ServiceItem.Status::Installed);
        ServiceItem.Validate("Warranty Starting Date (Labor)", SalePOS.Date);
        ServiceItem.Validate("Warranty Ending Date (Labor)", CalcDate('<+1Y>', SalePOS.Date));
        ServiceItem.Validate("Customer No.", SalePOS."Customer No.");
        ServiceItem.Validate("Unit of Measure Code", "Unit of Measure Code");
        ServiceItem.Validate("Sales Date", SalePOS.Date);
        ServiceItem.Modify;
    end;

    procedure ExplodeBOM(ItemNo: Code[20]; StartLineNo: Integer; EndLineNo: Integer; var Level: Integer; UnitPrice: Decimal; "Sum": Decimal)
    var
        BOMComponent: Record "BOM Component";
        SaleLinePOS: Record "NPR Sale Line POS";
        Item2: Record Item;
        FromLineNo: Integer;
        ToLineNo: Integer;
    begin
        if Sum = 0 then begin
            if Quantity = 0 then
                Quantity := 1;
            StartLineNo := Rec."Line No.";
            SaleLinePOS.Reset;
            SaleLinePOS.SetRange("Register No.", "Register No.");
            SaleLinePOS.SetRange("Sales Ticket No.", "Sales Ticket No.");
            SaleLinePOS.SetFilter("Sale Type", '%1|%2|%3', "Sale Type"::Sale, "Sale Type"::Deposit, "Sale Type"::"Out payment");
            SaleLinePOS.SetRange(Date, Date);
            SaleLinePOS.SetRange("Line No.", StartLineNo + 1, StartLineNo + 10000);
            if SaleLinePOS.FindFirst then
                EndLineNo := SaleLinePOS."Line No."
            else
                EndLineNo := StartLineNo + 10000;

            if Item2.Get(ItemNo) then
                UnitPrice := Item2."Unit Price";
        end;

        BOMComponent.SetRange("Parent Item No.", ItemNo);
        if BOMComponent.FindSet then begin
            Sum := 0;
            repeat
                if BOMComponent."Assembly BOM" then begin
                    ExplodeBOM(BOMComponent."No.", StartLineNo, EndLineNo, Level, UnitPrice, Sum);
                end else begin
                    Level += 1;
                    SaleLinePOS.Init;
                    SaleLinePOS."Register No." := "Register No.";
                    SaleLinePOS."Sales Ticket No." := "Sales Ticket No.";
                    SaleLinePOS."Sale Type" := "Sale Type";
                    SaleLinePOS.Date := Rec.Date;
                    SaleLinePOS."Line No." := Round(EndLineNo - (EndLineNo - StartLineNo) / (2 * Level), 1);
                    if not SaleLinePOS.Insert(true) then
                        SaleLinePOS.Modify(true);
                    SaleLinePOS."No." := BOMComponent."No.";
                    SaleLinePOS.Silent := true;
                    SaleLinePOS.Validate("No.");
                    SaleLinePOS.Quantity := BOMComponent."Quantity per" * Rec.Quantity;
                    SaleLinePOS.Validate(Quantity);
                    Sum += SaleLinePOS."Unit Price" * SaleLinePOS.Quantity;
                    SaleLinePOS.Silent := false;
                    if not SaleLinePOS.Modify(true) then
                        SaleLinePOS.Insert(true);
                    if FromLineNo = 0 then
                        FromLineNo := SaleLinePOS."Line No.";

                    ToLineNo := SaleLinePOS."Line No.";
                end;
            until BOMComponent.Next = 0;

            if (UnitPrice <> 0) and (Sum <> 0) then begin
                SaleLinePOS.Reset;
                SaleLinePOS.SetRange("Register No.", "Register No.");
                SaleLinePOS.SetRange("Sales Ticket No.", "Sales Ticket No.");
                SaleLinePOS.SetRange("Line No.", FromLineNo, ToLineNo);
                if SaleLinePOS.FindSet(true, false) then
                    repeat
                        SaleLinePOS."Discount Code" := "Discount Code";
                        SaleLinePOS.Validate("Discount %", 100 - UnitPrice / Sum * 100);
                        SaleLinePOS.Modify(true);
                    until SaleLinePOS.Next = 0;
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

    procedure CreateDim(Type1: Integer; No1: Code[20]; Type2: Integer; No2: Code[20]; Type3: Integer; No3: Code[20]; Type4: Integer; No4: Code[20])
    var
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
    begin
        GetPOSHeader;

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

        "Dimension Set ID" :=
          DimMgt.GetDefaultDimID(
            TableID, No, SalePOS.GetPOSSourceCode(),
            "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code",
            SalePOS."Dimension Set ID", DATABASE::Customer);
        DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
    end;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");
    end;

    procedure LookupShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.LookupDimValueCode(FieldNumber, ShortcutDimCode);
        ValidateShortcutDimCode(FieldNumber, ShortcutDimCode);
    end;

    procedure UpdateVATSetup()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        POSTaxCalculation: Codeunit "NPR POS Tax Calculation";
        Handled: Boolean;
    begin
        if (Type = Type::"G/L Entry") and ("Gen. Posting Type" = "Gen. Posting Type"::" ") then begin
            "VAT %" := 0;
            "VAT Calculation Type" := "VAT Calculation Type"::"Normal VAT";
        end else begin
            VATPostingSetup.Get("VAT Bus. Posting Group", "VAT Prod. Posting Group");
            POSTaxCalculation.OnGetVATPostingSetup(VATPostingSetup, Handled);
            "VAT Identifier" := VATPostingSetup."VAT Identifier";
            "VAT Calculation Type" := VATPostingSetup."VAT Calculation Type";

            case "VAT Calculation Type" of
                "VAT Calculation Type"::"Normal VAT":
                    "VAT %" := VATPostingSetup."VAT %";
                "VAT Calculation Type"::"Sales Tax":
                    "VAT %" := 0;
                "VAT Calculation Type"::"Reverse Charge VAT":
                    if (Type = Type::"G/L Entry") and ("Gen. Posting Type" = "Gen. Posting Type"::Purchase) then
                        "VAT %" := VATPostingSetup."VAT %"
                    else
                        "VAT %" := 0;
                else
                    Error(ErrVATCalcNotSupportInPOS, FieldCaption("VAT Calculation Type"), "VAT Calculation Type");
            end;

        end;
    end;

    procedure UpdateAmounts(var SaleLinePOS: Record "NPR Sale Line POS")
    var
        SaleLinePOS2: Record "NPR Sale Line POS";
        TotalLineAmount: Decimal;
        TotalInvDiscAmount: Decimal;
        TotalAmount: Decimal;
        TotalAmountInclVAT: Decimal;
        TotalQuantityBase: Decimal;
    begin
        with SaleLinePOS do begin
            SaleLinePOS2.SetRange("Register No.", "Register No.");
            SaleLinePOS2.SetRange("Sales Ticket No.", "Sales Ticket No.");
            SaleLinePOS2.SetRange(Date, Date);
            SaleLinePOS2.SetRange("Sale Type", "Sale Type");
            SaleLinePOS2.SetFilter("Line No.", '<>%1', "Line No.");
            if (Quantity * "Unit Price") > 0 then
                SaleLinePOS2.SetFilter(Amount, '>%1', 0)
            else
                SaleLinePOS2.SetFilter(Amount, '<%1', 0);
            SaleLinePOS2.SetRange("VAT Identifier", "VAT Identifier");
            SaleLinePOS2.SetRange("Tax Group Code", "Tax Group Code");

            TotalLineAmount := 0;
            TotalInvDiscAmount := 0;
            TotalAmount := 0;
            TotalAmountInclVAT := 0;
            TotalQuantityBase := 0;

            if ("VAT Calculation Type" = "VAT Calculation Type"::"Sales Tax") or
               (("VAT Calculation Type" in
                 ["VAT Calculation Type"::"Normal VAT", "VAT Calculation Type"::"Reverse Charge VAT"]) and ("VAT %" <> 0))
            then
                if not SaleLinePOS2.IsEmpty then begin
                    SaleLinePOS2.CalcSums("Line Amount", "Invoice Discount Amount", Amount, "Amount Including VAT", "Quantity (Base)");
                    TotalLineAmount := SaleLinePOS2."Line Amount";
                    TotalInvDiscAmount := SaleLinePOS2."Invoice Discount Amount";
                    TotalAmount := SaleLinePOS2.Amount;
                    TotalAmountInclVAT := SaleLinePOS2."Amount Including VAT";
                    TotalQuantityBase := SaleLinePOS2."Quantity (Base)";
                end;

            UpdateLineVatAmounts(
                SaleLinePOS, TotalLineAmount, TotalInvDiscAmount, TotalAmount, TotalAmountInclVAT);

            "Discount %" := Abs("Discount %");
        end;
    end;

    procedure UpdateLineVatAmounts(var SaleLinePOS: Record "NPR Sale Line POS"; TotalLineAmount: Decimal; TotalInvDiscAmount: Decimal; TotalAmount: Decimal; TotalAmountInclVAT: Decimal)
    var
        SalesTaxCalculate: Codeunit "Sales Tax Calculate";
    begin
        if SaleLinePOS."Currency Code" <> '' then
            Currency.Get(SaleLinePOS."Currency Code")
        else
            Currency.InitRoundingPrecision();

        with SaleLinePOS do begin
            if "Price Includes VAT" then begin
                "Amount Including VAT" := Quantity * "Unit Price";
                if "Discount %" <> 0 then
                    "Discount Amount" := Round("Amount Including VAT" * "Discount %" / 100, Currency."Amount Rounding Precision")
                else
                    if "Discount Amount" <> 0 then begin
                        "Discount Amount" := Round("Discount Amount", Currency."Amount Rounding Precision");
                        "Discount %" := Round(100 - ("Amount Including VAT" - "Discount Amount") / "Amount Including VAT" * 100, 0.0001);
                    end;
                "Amount Including VAT" := Round("Amount Including VAT" - "Discount Amount", Currency."Amount Rounding Precision");
                "Line Amount" := Round(Quantity * "Unit Price" - "Discount Amount", Currency."Amount Rounding Precision");

                case "VAT Calculation Type" of
                    "VAT Calculation Type"::"Reverse Charge VAT",
                    "VAT Calculation Type"::"Normal VAT":
                        begin
                            Amount :=
                              Round(
                                (TotalLineAmount - TotalInvDiscAmount + "Line Amount" - "Invoice Discount Amount") / (1 + "VAT %" / 100),
                                Currency."Amount Rounding Precision") -
                              TotalAmount;
                            "Amount Including VAT" := Round("Amount Including VAT", Currency."Amount Rounding Precision");
                            if "Amount Including VAT" = 0 then
                                Amount := 0;
                            "VAT Base Amount" := Amount;
                        end;

                    "VAT Calculation Type"::"Sales Tax":
                        begin
                            TestField("Tax Area Code");
                            Amount := SalesTaxCalculate.ReverseCalculateTax(
                              "Tax Area Code", "Tax Group Code", "Tax Liable", Rec.Date,
                              "Amount Including VAT", "Quantity (Base)", 0);
                            if Amount <> 0 then
                                "VAT %" := Round(100 * ("Amount Including VAT" - Amount) / Amount, 0.00001)
                            else
                                "VAT %" := 0;
                            "Amount Including VAT" := Round("Amount Including VAT", Currency."Amount Rounding Precision");
                            Amount := Round(Amount, Currency."Amount Rounding Precision");
                            "VAT Base Amount" := Amount;
                        end;
                    else
                        Error(ErrVATCalcNotSupportInPOS, FieldCaption("VAT Calculation Type"), "VAT Calculation Type");
                end;
            end else begin
                Amount := Quantity * "Unit Price";
                if "Discount %" <> 0 then
                    "Discount Amount" := Round(Amount * "Discount %" / 100, Currency."Amount Rounding Precision")
                else
                    if "Discount Amount" <> 0 then begin
                        "Discount Amount" := Round("Discount Amount", Currency."Amount Rounding Precision");
                        "Discount %" := Round(100 - (Amount - "Discount Amount") / Amount * 100, 0.0001);
                    end;
                Amount := Round(Amount - "Discount Amount", Currency."Amount Rounding Precision");
                "Line Amount" := Round(Quantity * "Unit Price" - "Discount Amount", Currency."Amount Rounding Precision");

                case "VAT Calculation Type" of
                    "VAT Calculation Type"::"Reverse Charge VAT",
                    "VAT Calculation Type"::"Normal VAT":
                        begin
                            Amount := Round("Line Amount" - "Invoice Discount Amount", Currency."Amount Rounding Precision");
                            "VAT Base Amount" := Amount;
                            "Amount Including VAT" :=
                              TotalAmount + Amount +
                              Round(
                                (TotalAmount + Amount) * "VAT %" / 100,
                                Currency."Amount Rounding Precision", Currency.VATRoundingDirection) -
                              TotalAmountInclVAT;
                            if Amount = 0 then
                                "Amount Including VAT" := 0;
                        end;

                    "VAT Calculation Type"::"Sales Tax":
                        begin
                            Amount := Round(Amount, Currency."Amount Rounding Precision");
                            "VAT Base Amount" := Amount;
                            "Amount Including VAT" := Amount +
                              Round(
                                SalesTaxCalculate.CalculateTax("Tax Area Code", "Tax Group Code", "Tax Liable", Rec.Date, Amount, "Quantity (Base)", 0),
                                Currency."Amount Rounding Precision");
                            if "VAT Base Amount" <> 0 then
                                "VAT %" := Round(100 * ("Amount Including VAT" - "VAT Base Amount") / "VAT Base Amount", 0.00001)
                            else
                                "VAT %" := 0;
                        end;
                    else
                        Error(ErrVATCalcNotSupportInPOS, FieldCaption("VAT Calculation Type"), "VAT Calculation Type");
                end;
            end;
        end;
    end;

    local procedure InitFromSalePOS()
    begin
        GetPOSHeader;
        "Allow Line Discount" := SalePOS."Allow Line Discount";
        "Location Code" := SalePOS."Location Code";
        "Price Includes VAT" := SalePOS."Prices Including VAT";
        "Customer Price Group" := SalePOS."Customer Price Group";
        "Gen. Bus. Posting Group" := SalePOS."Gen. Bus. Posting Group";
        "VAT Bus. Posting Group" := SalePOS."VAT Bus. Posting Group";
        "Tax Area Code" := SalePOS."Tax Area Code";
        "Tax Liable" := SalePOS."Tax Liable";
        "NPRE Seating Code" := SalePOS."NPRE Pre-Set Seating Code";
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
            GLSetup.Get;
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
        GLAccount.CheckGLAcc;
        Description := GLAccount.Name;
        "Gen. Posting Type" := GLAccount."Gen. Posting Type";
        "Gen. Prod. Posting Group" := GLAccount."Gen. Prod. Posting Group";
        "VAT Prod. Posting Group" := GLAccount."VAT Prod. Posting Group";
        "Tax Group Code" := GLAccount."Tax Group Code";
    end;

    local procedure InitFromItem()
    var
        DescriptionControl: Codeunit "NPR Description Control";
    begin
        if "No." = '' then
            exit;

        TestItem();
        GetItem;
        "Gen. Prod. Posting Group" := Item."Gen. Prod. Posting Group";
        "VAT Prod. Posting Group" := Item."VAT Prod. Posting Group";
        "Item Category Code" := Item."Item Category Code";
        "Tax Group Code" := Item."Tax Group Code";
        "Posting Group" := Item."Inventory Posting Group";
        "Item Group" := Item."NPR Item Group";
        "Item Disc. Group" := Item."Item Disc. Group";
        "Vendor No." := Item."Vendor No.";
        "Custom Disc Blocked" := Item."NPR Custom Discount Blocked";
        if "Unit of Measure Code" = '' then
            "Unit of Measure Code" := Item."Base Unit of Measure";
        if not "Cust Forsikring" then
            "Insurance Category" := Item."NPR Insurrance category";

        DescriptionControl.GetDescriptionPOS(Rec, xRec, Item);
    end;

    local procedure InitFromItemGroup()
    var
        ItemGroup: Record "NPR Item Group";
    begin
        if "No." = '' then
            exit;

        ItemGroup.Get("No.");
        GetItem;
        Item.TestField("NPR Group sale");
        "Gen. Prod. Posting Group" := Item."Gen. Prod. Posting Group";
        "VAT Prod. Posting Group" := Item."VAT Prod. Posting Group";
        "Tax Group Code" := Item."Tax Group Code";
        "Item Disc. Group" := Item."Item Disc. Group";
        Description := CopyStr(ItemGroup.Description, 1, MaxStrLen(Description));
    end;

    local procedure InitFromPaymentTypePOS()
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        GLAccount: Record "G/L Account";
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
    begin
        if "No." = '' then
            exit;

        Item.Get("No.");
        Item.TestField(Blocked, false);
        Item.TestField("NPR Blocked on Pos", false);
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
    var
        POSUnit: Record "NPR POS Unit";
        SaleLinePOS: Record "NPR Sale Line POS";
    begin
        POSUnit.Get("Register No.");

        if POSPaymentMethod."Account No." = '' then
            Error(Text001, "No.");

        POSPaymentMethod.TestField("Block POS Payment", false);
        if POSPaymentMethod."Global Dimension 1 Code" <> '' then
            POSPaymentMethod.TestField("Global Dimension 1 Code", POSUnit."Global Dimension 1 Code");

        if POSPaymentMethod."Processing Type" <> POSPaymentMethod."Processing Type"::CUSTOMER then
            exit;
        GetPOSHeader;
        SalePOS.TestField("Customer No.");

        SaleLinePOS.SetRange("Register No.", "Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", "Sales Ticket No.");
        SaleLinePOS.SetRange(Type, Type::Payment);
        SaleLinePOS.SetFilter("Line No.", '<>%1', "Line No.");
        SaleLinePOS.SetFilter("No.", '<>%1', '');
        if SaleLinePOS.FindSet then
            repeat
                POSPaymentMethod.Get(SaleLinePOS."No.");
                if POSPaymentMethod."Processing Type" = POSPaymentMethod."Processing Type"::CUSTOMER then
                    Error(Text000);
            until SaleLinePOS.Next = 0;

    end;

    local procedure CalcBaseQty(Qty: Decimal): Decimal
    begin
        TestField("Qty. per Unit of Measure");
        exit(Round(Qty * "Qty. per Unit of Measure", 0.00001));
    end;

    local procedure GetItem()
    begin
        TestField("No.");
        if "No." <> Item."No." then
            Item.Get("No.");
    end;

    local procedure UpdateCost()
    begin
        Cost := "Unit Cost (LCY)" * Quantity;
    end;

    procedure GetUnitCostLCY(): Decimal
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        ItemTrackingCode: Record "Item Tracking Code";
        PriceMult: Decimal;
        TxtNoSerial: Label 'No open Item Ledger Entry has been found with the Serial No. %2';
    begin
        if "Custom Cost" then
            exit("Unit Cost");

        if ("Serial No." <> '') and (Quantity > 0) then begin
            GetItem;
            Item.TestField("Item Tracking Code");
            ItemTrackingCode.Get(Item."Item Tracking Code");
            if ItemTrackingCode."SN Specific Tracking" then begin
                ItemLedgerEntry.SetCurrentKey(Open, Positive, "Item No.", "Serial No.");
                ItemLedgerEntry.SetRange(Open, true);
                ItemLedgerEntry.SetRange(Positive, true);
                ItemLedgerEntry.SetRange("Item No.", "No.");
                ItemLedgerEntry.SetRange("Serial No.", "Serial No.");
                if not ItemLedgerEntry.FindFirst then begin
                    Message(TxtNoSerial, "Serial No.");
                    exit(0);
                end;
                ItemLedgerEntry.CalcFields("Cost Amount (Actual)");
                exit(ItemLedgerEntry."Cost Amount (Actual)");
            end;
        end;
    end;

    local procedure UpdateDependingLinesQuantity()
    var
        SaleLinePOS: Record "NPR Sale Line POS";
    begin
        if Silent then
            exit;

        if xRec.Quantity = 0 then
            exit;

        //TSD is numbering lines differently. Implmented "Main Line No." as reference
        // NOTE: TSD Allows auto split key on new lines
        SaleLinePOS.SetFilter("Register No.", '=%1', "Register No.");
        SaleLinePOS.SetFilter("Sales Ticket No.", '=%1', "Sales Ticket No.");
        SaleLinePOS.SetFilter("Sale Type", '=%1', "Sale Type"::Sale);
        SaleLinePOS.SetFilter("Main Line No.", '=%1', "Line No.");
        SaleLinePOS.SetFilter(Accessory, '=%1', true); // not really required, would also be one solution for combination items below
        SaleLinePOS.SetFilter("Main Item No.", '=%1', "No."); // not really required, would also be one solution for combination items below
        if (SaleLinePOS.FindSet(true, false)) then
            repeat
                SaleLinePOS.Silent := true;
                SaleLinePOS.Validate(Quantity, SaleLinePOS.Quantity * Quantity / xRec.Quantity);
                SaleLinePOS.Silent := false;
                SaleLinePOS.SetSkipCalcDiscount(true);
                SaleLinePOS.Modify;
            until SaleLinePOS.Next = 0;
        SaleLinePOS.Reset;

        SaleLinePOS.SetFilter("Main Line No.", '=%1', 0); // STD will have "Main Line No." as 0 and this function should not interfer in TSD.

        SaleLinePOS.SetRange("Register No.", "Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", "Sales Ticket No.");
        SaleLinePOS.SetRange("Sale Type", "Sale Type"::Sale);
        SaleLinePOS.SetRange("Line No.", "Line No.", "Line No." + 9999);
        SaleLinePOS.SetRange(Accessory, true);
        SaleLinePOS.SetRange("Main Item No.", "No.");
        if SaleLinePOS.FindSet(true, false) then
            repeat
                SaleLinePOS.Silent := true;
                SaleLinePOS.Validate(Quantity, SaleLinePOS.Quantity * Quantity / xRec.Quantity);
                SaleLinePOS.Silent := false;
                SaleLinePOS.SetSkipCalcDiscount(true);
                SaleLinePOS.Modify;
            until SaleLinePOS.Next = 0;
        SaleLinePOS.Reset;

        SaleLinePOS.SetRange("Register No.", "Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", "Sales Ticket No.");
        SaleLinePOS.SetRange(Date, Date);
        SaleLinePOS.SetRange("Sale Type", "Sale Type"::Sale);
        SaleLinePOS.SetRange("Line No.", "Line No.", "Line No." + 9999);
        SaleLinePOS.SetRange("Combination Item", true);
        SaleLinePOS.SetRange("Main Item No.", "No.");
        SaleLinePOS.SetRange("Combination No.", "Combination No.");
        if SaleLinePOS.FindSet(true, false) then
            repeat
                SaleLinePOS.Silent := true;
                SaleLinePOS.Validate(Quantity, SaleLinePOS.Quantity * Quantity / xRec.Quantity);
                SaleLinePOS.Silent := false;
                SaleLinePOS.SetSkipCalcDiscount(true);
                SaleLinePOS.Modify;
            until SaleLinePOS.Next = 0;
    end;

    procedure SerialNoLookup()
    var
        xSaleLinePOS2: Record "NPR Sale Line POS";
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
        RetailItemSetup: Record "NPR Retail Item Setup";
    begin
        RetailItemSetup.Get();
        TestField("Sale Type", "Sale Type"::Sale);
        TestField(Type, Type::Item);

        GetItem;
        Item.TestField("Costing Method", Item."Costing Method"::Specific);
        ItemLedgerEntry.SetCurrentKey(Open, Positive, "Item No.", "Serial No.");
        ItemLedgerEntry.SetRange(Open, true);
        ItemLedgerEntry.SetRange(Positive, true);
        ItemLedgerEntry.SetRange("Item No.", "No.");
        ItemLedgerEntry.SetFilter("Serial No.", '<> %1', '');
        ItemLedgerEntry.SetRange("Location Code", "Location Code");
        if "Variant Code" <> '' then
            ItemLedgerEntry.SetRange("Variant Code", "Variant Code");
        if not RetailItemSetup."Not use Dim filter SerialNo" then
            ItemLedgerEntry.SetRange("Global Dimension 1 Code", "Shortcut Dimension 1 Code");
        if ItemLedgerEntry.Find('-') then
            repeat
                ItemLedgerEntry.SetRange("Serial No.", ItemLedgerEntry."Serial No.");
                ItemLedgerEntry.FindLast;
                TempItemLedgerEntry := ItemLedgerEntry;
                TempItemLedgerEntry.Insert;
                ItemLedgerEntry.SetRange("Serial No.");
            until ItemLedgerEntry.Next = 0;

        TempItemLedgerEntry.SetFilter("Expiration Date", '<>%1', 0D);
        if not TempItemLedgerEntry.IsEmpty then
            TempItemLedgerEntry.SetCurrentKey("Expiration Date");
        TempItemLedgerEntry.SetRange("Expiration Date");
        if "Serial No." <> '' then
            TempItemLedgerEntry.SetRange("Serial No.", "Serial No.");
        if TempItemLedgerEntry.FindFirst then;
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
        SaleLinePOS2: Record "NPR Sale Line POS";
        SalePOS: Record "NPR Sale POS";
        ItemLedgerEntry: Record "Item Ledger Entry";
        ItemTrackingCode: Record "Item Tracking Code";
        Positive: Boolean;
        Txt001: Label 'Quantity in a serial number sale must be 1 or -1!';
        Txt002: Label '%2 %1 has already been used in another transaction! \';
        Txt003: Label 'try to check saved receipts';
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

        GetItem;
        Item.TestField("Item Tracking Code");
        ItemTrackingCode.Get(Item."Item Tracking Code");

        SaleLinePOS2.SetCurrentKey("Serial No.");
        SaleLinePOS2.SetRange("Serial No.", "Serial No.");
        if SaleLinePOS2.FindSet then
            repeat
                SalePOS.Get(SaleLinePOS2."Register No.", SaleLinePOS2."Sales Ticket No.");
                if not SalePOS."Saved Sale" then
                    if (SaleLinePOS2."Sales Ticket No." <> "Sales Ticket No.") or (SaleLinePOS2."Line No." <> "Line No.") then
                        Error(Text004, FieldName("Serial No."), "Serial No.");
            until SaleLinePOS2.Next = 0;

        if Quantity <> Abs(1) then
            Quantity := 1 * (Quantity / Abs(Quantity));
        Positive := (Quantity >= 0);

        if ItemTrackingCode."SN Specific Tracking" then begin
            CheckSerialNoApplication("No.", "Serial No.");
            CheckSerialNoAuditRoll("No.", "Serial No.", Positive);
            if not NoWarning then begin
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
    end;
}