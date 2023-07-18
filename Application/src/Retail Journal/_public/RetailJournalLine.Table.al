﻿table 6014422 "NPR Retail Journal Line"
{
    Caption = 'Retail Journal Line';
    DataClassification = CustomerContent;
    fields
    {
        field(1; "No."; Code[40])
        {
            Caption = 'No.';
            TableRelation = "NPR Retail Journal Header"."No.";
            DataClassification = CustomerContent;
        }
        field(2; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
            ValidateTableRelation = false;
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Item: Record Item;
            begin

                if "Item No." = '' then begin
                    Init();
                    exit;
                end;

                if Item.Get("Item No.") then begin
                    Validate("Vendor No.", Item."Vendor No.");
                    Description := Item.Description;
                    "Description 2" := Item."Description 2";
                    "Vend Item No." := Item."Vendor Item No.";
                    "Last Direct Cost" := Item."Last Direct Cost";
                    "Item group" := Item."Item Category Code";
                    "New Item No." := "Item No.";
                    if Item."Sales Unit of Measure" <> '' then
                        "Sales Unit of measure" := Item."Sales Unit of Measure";
                    if Item."Base Unit of Measure" <> '' then
                        "Unit of Measure" := Item."Base Unit of Measure";
                    "Unit Price" := Item."Unit Price";
                    "Unit List Price" := Item."Unit List Price";

                    UpdateBarcode();
                end else begin
                    Validate(Barcode, "Item No.");
                    exit;
                end;

                "Quantity to Print" := 1;
                FindItemSalesPrice();
                Validate("Quantity for Discount Calc", 1);
                calcProfit();
            end;
        }
        field(3; "Quantity to Print"; Decimal)
        {
            Caption = 'Quantity to Print';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Error_BoundsCheck: Label 'Number of prints too high. Split into several requests';
            begin
                //Reports with a ton of barcodes fonts or images can bloat NST memory to double digit gigabyte size from 1 user session, eventually leading to a crashed NST for all sessions if max memory is hit. 
                //This guards against that when printing from RJL. Main purpose is to block accidental barcode scans as this is a very easy way to accidentally trigger huge prints.

                if "Quantity to Print" > 10000 then begin
                    Rec.FieldError("Quantity to Print", Error_BoundsCheck);
                end;
            end;
        }
        field(4; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(5; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            TableRelation = Vendor;
            ValidateTableRelation = false;
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Vendor: Record Vendor;
            begin
                if not Vendor.Get("Vendor No.") then
                    Vendor.Init();

                "Vend Name" := Vendor.Name;
                "Vend Search Description" := Vendor."Search Name";
            end;
        }
        field(6; "Vendor Item No."; Code[20])
        {
            Caption = 'Vendor Item No.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Removed because we need field length to increase, changed with Vend Item No. filed';
        }
        field(7; "Discount Price Incl. Vat"; Decimal)
        {
            Caption = 'Discount Price Incl. Vat';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Currency.InitRoundingPrecision();
                "Discount Price Excl. VAT" :=
                  Round(
                    "Discount Price Incl. Vat" /
                    (1 + "VAT %" / 100),
                    Currency."Amount Rounding Precision");

                CalcDiscountPrice(FieldNo("Discount Price Incl. Vat"));
                calcProfit();
            end;
        }
        field(8; "Last Direct Cost"; Decimal)
        {
            Caption = 'Last Direct Cost';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                calcProfit();
            end;
        }
        field(9; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(10; "Sales Unit of measure"; Code[10])
        {
            Caption = 'Sales Unit of measure';
            DataClassification = CustomerContent;
        }
        field(11; Barcode; Code[50])
        {
            Caption = 'Barcode';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                BarcodeLibrary: Codeunit "NPR Barcode Lookup Mgt.";
                ItemNo: Code[20];
                VariantCode: Code[10];
                ResolvingTable: Integer;
            begin
                if BarcodeLibrary.TranslateBarcodeToItemVariant(Barcode, ItemNo, VariantCode, ResolvingTable, true) then begin
                    Validate("Item No.", ItemNo);
                    Validate("Variant Code", VariantCode);
                end;
            end;
        }
        field(13; "Mixed Discount"; Code[20])
        {
            Caption = 'Mixed Discount';
            DataClassification = CustomerContent;
        }
        field(14; "Period Discount"; Code[20])
        {
            Caption = 'Campaign/period discount';
            DataClassification = CustomerContent;
        }
        field(15; "Vend Item No."; Code[50])
        {
            Caption = 'Vendor Item No.';
            DataClassification = CustomerContent;
        }
        field(17; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                ItemVariant: Record "Item Variant";
            begin
                if "Variant Code" = '' then
                    exit;

                if ItemVariant.Get("Item No.", "Variant Code") then
                    "Description 2" := CopyStr(ItemVariant.Description, 1, MaxStrLen("Description 2"));

                UpdateBarcode();

                FindItemSalesPrice();
            end;
        }
        field(18; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
            DataClassification = CustomerContent;
        }
        field(19; "Item group"; Code[20])
        {
            Caption = 'Item Category';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(20; Assortment; Code[20])
        {
            Caption = 'Assortment';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(21; "New Item No."; Code[20])
        {
            Caption = 'New Item No.';
            DataClassification = CustomerContent;
        }
        field(22; "New Item"; Boolean)
        {
            Caption = 'New Item';
            DataClassification = CustomerContent;
        }
        field(23; "Purch. Unit of measure"; Code[10])
        {
            Caption = 'Purch. Unit of measure';
            DataClassification = CustomerContent;
        }
        field(24; "Base Unit of measure"; Code[10])
        {
            Caption = 'Base Unit of measure';
            DataClassification = CustomerContent;
        }
        field(25; Inventory; Decimal)
        {
            CalcFormula = Sum("Item Ledger Entry".Quantity WHERE("Item No." = FIELD("Item No."),
                                                                  "Global Dimension 1 Code" = FIELD("Shortcut Dimension 1 Code"),
                                                                  "Global Dimension 2 Code" = FIELD("Shortcut Dimension 2 Code"),
                                                                  "Location Code" = FIELD("Location Code"),
                                                                  "Variant Code" = FIELD("Variant Code")));
            Caption = 'Inventory';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(27; "Cannot edit unit price"; Boolean)
        {
            Caption = 'Can''t edit unit price';
            FieldClass = Normal;
            DataClassification = CustomerContent;
        }
        field(28; "Profit % (new)"; Decimal)
        {
            Caption = 'Profit % (new)';
            DataClassification = CustomerContent;
        }
        field(29; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CalcDiscountPrice(FieldNo("Unit Price"));
            end;
        }
        field(30; "Discount Unit Price"; Decimal)
        {
            Caption = 'Discount Unit Price';
            DataClassification = CustomerContent;
        }
        field(31; "Serial No."; Code[50])
        {
            Caption = 'Serial No.';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                "Item Ledger Entry": Record "Item Ledger Entry";
            begin
                "Item Ledger Entry".SetRange("Item No.", "Item No.");
                if PAGE.RunModal(PAGE::"NPR Serial Numbers Lookup", "Item Ledger Entry") = ACTION::LookupOK then
                    "Serial No." := "Item Ledger Entry"."Serial No.";
            end;
        }
        field(36; "Net Change"; Decimal)
        {
            CalcFormula = Sum("Item Ledger Entry".Quantity WHERE("Item No." = FIELD("Item No."),
                                                                  "Global Dimension 1 Code" = FIELD("Shortcut Dimension 1 Code"),
                                                                  "Global Dimension 2 Code" = FIELD("Shortcut Dimension 2 Code"),
                                                                  "Location Code" = FIELD("Location Code"),
                                                                  "Posting Date" = FIELD("Calculation Date"),
                                                                  "Variant Code" = FIELD("Variant Code")));
            Caption = 'Net Change';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(37; "Purchases (Qty.)"; Decimal)
        {
            CalcFormula = Sum("Item Ledger Entry"."Invoiced Quantity" WHERE("Entry Type" = CONST(Purchase),
                                                                             "Item No." = FIELD("Item No."),
                                                                             "Global Dimension 1 Code" = FIELD("Shortcut Dimension 1 Code"),
                                                                             "Global Dimension 2 Code" = FIELD("Shortcut Dimension 2 Code"),
                                                                             "Location Code" = FIELD("Location Code"),
                                                                             "Variant Code" = FIELD("Variant Code"),
                                                                             "Posting Date" = FIELD("Calculation Date")));
            Caption = 'Purchases (Qty.)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(38; "Sales (Qty.)"; Decimal)
        {
            CalcFormula = - Sum("Value Entry"."Invoiced Quantity" WHERE("Item Ledger Entry Type" = CONST(Sale),
                                                                        "Item No." = FIELD("Item No."),
                                                                        "Global Dimension 1 Code" = FIELD("Shortcut Dimension 1 Code"),
                                                                        "Global Dimension 2 Code" = FIELD("Shortcut Dimension 1 Code"),
                                                                        "Location Code" = FIELD("Location Code"),
                                                                        "Variant Code" = FIELD("Variant Code"),
                                                                        "Posting Date" = FIELD("Calculation Date")));
            Caption = 'Sales (Qty.)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(41; "Vendor Name"; Text[60])
        {
            Caption = 'Vendor Name';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Removed because we need field length to increase, changed with Vend Name filed';
        }
        field(42; "Vendor Search Description"; Code[50])
        {
            Caption = 'Vendor Search Description';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Removed because we need field length to increase, changed with Vend Search Description filed';
        }
        field(43; "Vend Name"; Text[100])
        {
            Caption = 'Vendor Name';
            DataClassification = CustomerContent;
        }
        field(44; "Vend Search Description"; Code[100])
        {
            Caption = 'Vendor Search Description';
            DataClassification = CustomerContent;
        }
        field(47; "Register No."; Code[20])
        {
            Caption = 'POS Unit No.';
            TableRelation = "NPR POS Unit";
            DataClassification = CustomerContent;
        }
        field(48; "Unit of Measure"; Code[10])
        {
            Caption = 'Unit of measure';
            DataClassification = CustomerContent;
            TableRelation = "Item Unit of Measure".Code where("Item No." = field("Item No."));

            trigger OnValidate()
            var
                Item: Record Item;
                PriceListLineUOMMgt: Codeunit "NPR Price List Line UOM";
            begin
                Item.Get(Rec."Item No.");
                Rec."Last Direct Cost" := Item."Last Direct Cost" * PriceListLineUOMMgt.GetQtyPerUOMFromUOM(Rec."Item No.", Rec."Unit of Measure");
                FindItemSalesPrice();
                calcProfit();
            end;
        }
        field(50; "Location Filter"; Code[10])
        {
            Caption = 'Location Code';
            FieldClass = FlowFilter;
            TableRelation = Location;
        }
        field(60; "Discount Type"; Option)
        {
            Caption = 'Discount Type';
            Description = 'Sag 70113';
            OptionCaption = ' ,Period,Mixed,Multiple Unit,Salesperson Discount,Inventory,Photo Work,Rounding,Combination,Customer';
            OptionMembers = " ",Campaign,Mix,Quantity,Manual,"BOM List","Photo work",Rounding,Combination,Customer;
            DataClassification = CustomerContent;
        }
        field(61; "Discount Code"; Code[20])
        {
            Caption = 'Discount Code';
            Description = 'Sag 70113';
            TableRelation = IF ("Discount Type" = CONST(Mix)) "NPR Mixed Discount"
            ELSE
            IF ("Discount Type" = CONST(Quantity)) "NPR Quantity Discount Header";
            DataClassification = CustomerContent;
        }
        field(62; "Discount Pct."; Decimal)
        {
            Caption = 'Discount %';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CalcDiscountPrice(FieldNo("Discount Pct."));
            end;
        }
        field(63; "Quantity for Discount Calc"; Decimal)
        {
            Caption = 'Quantity for Discount Calculation';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                FindItemSalesPrice();
            end;
        }
        field(65; "Calculation Date"; Date)
        {
            Caption = 'Calculation Date';
            DataClassification = CustomerContent;
        }
        field(70; "Customer Price Group"; Code[10])
        {
            Caption = 'Customer Price Group';
            TableRelation = "Customer Price Group";
            DataClassification = CustomerContent;
        }
        field(72; "Customer Disc. Group"; Code[20])
        {
            Caption = 'Customer Disc. Group';
            Description = 'NPR5.31';
            TableRelation = "Customer Discount Group";
            DataClassification = CustomerContent;
        }
        field(75; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Customer: Record Customer;
            begin
                if "Customer No." <> xRec."Customer No." then
                    if "Customer No." <> '' then begin
                        Customer.Get("Customer No.");

                        Description := Customer.Name;
                    end;
            end;
        }
        field(76; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
            DataClassification = CustomerContent;
        }
        field(77; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
            DataClassification = CustomerContent;
        }
        field(78; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
            DataClassification = CustomerContent;
        }
        field(80; "Discount Price Excl. VAT"; Decimal)
        {
            Caption = 'Discount Price Excl. VAT';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Currency.InitRoundingPrecision();
                Validate("Discount Price Incl. Vat",
                  Round(
                    "Discount Price Excl. VAT" *
                    (1 + ("VAT %" / 100)),
                    Currency."Amount Rounding Precision"));
            end;
        }
        field(81; "VAT %"; Decimal)
        {
            Caption = 'VAT %';
            DataClassification = CustomerContent;
        }
        field(85; "Unit List Price"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit List Price';
            MinValue = 0;
            DataClassification = CustomerContent;
        }
        field(90; "RFID Tag Value"; Text[30])
        {
            Caption = 'RFID Tag Value';
            DataClassification = CustomerContent;
        }
        field(100; "Exchange Label"; Code[13])
        {
            Caption = 'Exchange Label';
            Description = 'NPR5.49';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                ExchangeLabel: Record "NPR Exchange Label";
                RetailJournalLine: Record "NPR Retail Journal Line";
                MultipleLines: Boolean;
            begin
                ExchangeLabel.SetRange(Barcode, "Exchange Label");
                ExchangeLabel.FindFirst();

                if ExchangeLabel."Packaged Batch" then begin
                    ExchangeLabel.SetRange(Barcode);
                    ExchangeLabel.SetRange("Packaged Batch", true);
                    ExchangeLabel.SetRange("Batch No.", ExchangeLabel."Batch No.");
                    ExchangeLabel.SetRange("Register No.", ExchangeLabel."Register No.");
                    ExchangeLabel.SetRange("Sales Ticket No.", ExchangeLabel."Sales Ticket No.");
                    ExchangeLabel.FindSet();
                end;

                repeat
                    if not MultipleLines then
                        RetailJournalLine := Rec
                    else begin
                        RetailJournalLine.SelectRetailJournal("No.");
                        RetailJournalLine.InitLine();
                    end;

                    RetailJournalLine."Exchange Label" := ExchangeLabel.Barcode;
                    RetailJournalLine.Validate("Item No.", ExchangeLabel."Item No.");
                    RetailJournalLine.Validate("Variant Code", ExchangeLabel."Variant Code");
                    RetailJournalLine.Validate("Quantity to Print", ExchangeLabel.Quantity);

                    if MultipleLines then
                        RetailJournalLine.Insert(true)
                    else
                        Rec := RetailJournalLine;

                    MultipleLines := true;
                until (ExchangeLabel.Next() = 0) or (not ExchangeLabel."Packaged Batch");
            end;
        }
        field(6059970; "Is Master"; Boolean)
        {
            Caption = 'Is Master';
            Description = 'VRT';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = '"NPR Master Line Map" used instead.';
        }
        field(6059971; "Master Line No."; Integer)
        {
            Caption = 'Master Line No.';
            Description = 'VRT';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = '"NPR Master Line Map" used instead.';
        }
    }

    keys
    {
        key(Key1; "No.", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        RetailJournalHeader: Record "NPR Retail Journal Header";
        LineNo: Integer;
        ShowDialog: Boolean;
        TotalRecNo: Integer;
        RecNo: Integer;
        Dia: Dialog;
        Text001: Label 'Creating lines @1@@@@@@@';
        Currency: Record Currency;

    internal procedure FindItemSalesPrice()
    var
        TempSalePOS: Record "NPR POS Sale" temporary;
        TempSaleLinePOS: Record "NPR POS Sale Line" temporary;
        POSSalesPriceCalcMgt: Codeunit "NPR POS Sales Price Calc. Mgt.";
        Item: Record Item;
        POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
        TempDiscountPriority: Record "NPR Discount Priority" temporary;
        TempSaleLinePOS2: Record "NPR POS Sale Line" temporary;
        POSUnit: Record "NPR POS Unit";
        PricingProfile: Codeunit "NPR POS Pricing Profile";
        PriceListLineUOMMgt: Codeunit "NPR Price List Line UOM";
    begin
        TempSaleLinePOS."Line Type" := TempSaleLinePOS."Line Type"::Item;
        TempSaleLinePOS."No." := "Item No.";
        TempSaleLinePOS."Variant Code" := "Variant Code";

        POSSalesPriceCalcMgt.InitTempPOSItemSale(TempSaleLinePOS, TempSalePOS);
        if "Register No." <> '' then
#pragma warning disable AA0139
            TempSalePOS."Register No." := "Register No.";
#pragma warning restore
        if not POSUnit.Get(TempSalePOS."Register No.") then
            POSUnit.Init();

        if "Customer Price Group" <> '' then
            TempSalePOS."Customer Price Group" := "Customer Price Group"
        else
            TempSalePOS."Customer Price Group" := PricingProfile.GetCustomerPriceGroupIfProfileExist(POSUnit."POS Pricing Profile");

        if "Customer Disc. Group" <> '' then
            TempSalePOS."Customer Disc. Group" := "Customer Disc. Group"
        else
            TempSalePOS."Customer Disc. Group" := PricingProfile.GetCustomerDiscountGroupIfProfileExist(POSUnit."POS Pricing Profile");

        if "Calculation Date" <> 0D then
            TempSalePOS.Date := "Calculation Date";

        TempSalePOS."Prices Including VAT" := true;
        Item.Get("Item No.");
        TempSaleLinePOS."Customer Price Group" := TempSalePOS."Customer Price Group";

        TempSaleLinePOS."Item Disc. Group" := Item."Item Disc. Group";
        TempSaleLinePOS.SetSkipUpdateDependantQuantity(true);
        TempSaleLinePOS.Date := "Calculation Date";
        TempSaleLinePOS.Validate(Quantity, "Quantity for Discount Calc");
#pragma warning disable AA0139        
        TempSaleLinePOS."Register No." := "Register No.";
#pragma warning restore
        TempSaleLinePOS."Unit of Measure Code" := "Unit of Measure";
        TempSaleLinePOS."Qty. per Unit of Measure" := PriceListLineUOMMgt.GetQtyPerUOMFromUOM("Item No.", "Unit of Measure");
        POSSalesPriceCalcMgt.FindItemPrice(TempSalePOS, TempSaleLinePOS);
        POSSalesDiscountCalcMgt.InitDiscountPriority(TempDiscountPriority);
        TempSaleLinePOS2 := TempSaleLinePOS;
        TempSaleLinePOS2.Insert();
        TempDiscountPriority.SetCurrentKey(Priority);
        if TempSaleLinePOS."Allow Line Discount" then
            if TempDiscountPriority.FindSet() then
                repeat
                    POSSalesDiscountCalcMgt.ApplyDiscount(TempDiscountPriority, TempSalePOS, TempSaleLinePOS2, TempSaleLinePOS, TempSaleLinePOS, 0, true);
                    TempSaleLinePOS2.UpdateAmounts(TempSaleLinePOS2);
                until (TempDiscountPriority.Next() = 0) or (TempSaleLinePOS2."Discount Type" <> TempSaleLinePOS2."Discount Type"::" ");
        "Discount Price Incl. Vat" := TempSaleLinePOS2."Amount Including VAT";
        "VAT %" := TempSaleLinePOS2."VAT %";
        "Discount Price Excl. VAT" := TempSaleLinePOS2.Amount;
        "Unit Price" := TempSaleLinePOS2."Unit Price";
        "Discount Type" := TempSaleLinePOS2."Discount Type";
        "Discount Code" := TempSaleLinePOS2."Discount Code";
        "Discount Pct." := TempSaleLinePOS2."Discount %";
    end;

    internal procedure calcProfit()
    var
        TempItem: Record Item temporary;
        Item1: Record Item;
    begin
        if ("Discount Price Incl. Vat" = 0) then
            exit;

        if Item1.Get("Item No.") then begin
            if Item1."Unit Cost" = 0 then begin
                Item1."Unit Cost" := "Last Direct Cost";
                Item1.Validate("Unit Price", "Discount Price Incl. Vat");
                "Profit % (new)" := Item1."Profit %";
            end else begin
                Item1."Unit Cost" := "Last Direct Cost";
                Item1.Validate("Unit Price", "Discount Price Incl. Vat");
                "Profit % (new)" := Item1."Profit %";
            end;
        end else begin
            if "Item No." <> '' then begin
                TempItem.Init();
                TempItem."No." := "Item No.";
                TempItem.Validate("Item Category Code", "Item group");
                TempItem."Unit Cost" := "Last Direct Cost";
                TempItem.Validate("Unit Price", "Discount Price Incl. Vat");
                "Profit % (new)" := TempItem."Profit %";
            end;
        end;
    end;

    internal procedure SelectRetailJournal(RetailJournalCode: Code[40]) JournalSelected: Boolean
    var
        RetailJnlLine: Record "NPR Retail Journal Line";
    begin
        if not RetailJournalHeader.Get(RetailJournalCode) then begin
            RetailJournalHeader.Init();
            RetailJournalHeader."No." := RetailJournalCode;
        end;
        RetailJournalHeader.TestField("No.");

        RetailJnlLine.SetRange("No.", RetailJournalHeader."No.");
        if RetailJnlLine.FindLast() then
            LineNo := RetailJnlLine."Line No." + 10000
        else
            LineNo := 10000;
        exit(true);
    end;

    internal procedure UseGUI(TotalNoOfLines: Integer)
    begin
        if not GuiAllowed then
            exit;

        if TotalNoOfLines < 1 then
            exit;

        ShowDialog := true;
        TotalRecNo := TotalNoOfLines;

        Dia.Open(Text001);
    end;

    internal procedure InitLine()
    begin
        RetailJournalHeader.TestField("No.");

        RecNo += 1;
        if ShowDialog then
            Dia.Update(1, Round(RecNo / TotalRecNo * 10000, 1));

        Init();
        "No." := RetailJournalHeader."No.";
        "Line No." := LineNo;
        LineNo += 10000;
        "Calculation Date" := RetailJournalHeader."Date of creation";
        "Customer Price Group" := RetailJournalHeader."Customer Price Group";
        "Customer Disc. Group" := RetailJournalHeader."Customer Disc. Group";

        "Register No." := RetailJournalHeader."Register No.";
    end;

    internal procedure SetItem(ItemNo: Code[20]; VariantCode: Code[10]; BarcodeValue: Code[50])
    begin
        if Barcode <> '' then
            Validate(Barcode, BarcodeValue)
        else begin
            "Variant Code" := VariantCode;
            Validate("Item No.", ItemNo);
        end;
    end;

    internal procedure SetDiscountType(DiscountType: Option " ",Campaign,Mix,Quantity,Manual,"BOM List","Photo work",Rounding,Combination,Customer; DiscountCode: Code[20]; DiscountPrice: Decimal; DiscountQuantity: Decimal; PriceInclVAT: Boolean)
    begin
        "Discount Type" := DiscountType;
        "Discount Code" := DiscountCode;
        "Quantity for Discount Calc" := DiscountQuantity;
        if PriceInclVAT then
            Validate("Discount Price Incl. Vat", DiscountPrice)
        else
            Validate("Discount Price Excl. VAT", DiscountPrice);
    end;

    internal procedure CloseGUI()
    begin
        if not ShowDialog then
            exit;

        Dia.Close();
        ShowDialog := false;
    end;

    local procedure CalcDiscountPrice(CalledFromFieldNo: Integer)
    begin
        Currency.InitRoundingPrecision();
        case CalledFromFieldNo of
            FieldNo("Discount Pct."):
                begin
                    Validate("Discount Price Incl. Vat",
                      Round(
                        "Unit Price" * "Quantity for Discount Calc" * (1 - "Discount Pct." / 100),
                          Currency."Amount Rounding Precision"));
                end;
            FieldNo("Unit Price"), FieldNo("Discount Price Incl. Vat"):
                begin
                    if ("Quantity for Discount Calc" = 0) or ("Unit Price" = 0) then begin
                        "Discount Pct." := 0;
                        exit;
                    end;
                    "Discount Pct." := (1 - ("Discount Price Incl. Vat" / "Quantity for Discount Calc" / "Unit Price")) * 100;
                end;
        end;
    end;

    procedure SetupNewLine(var LastRetailJnlLine: Record "NPR Retail Journal Line")
    var
        RetailJnlHeader: Record "NPR Retail Journal Header";
    begin
        LastRetailJnlLine.FilterGroup(4);
        if not RetailJnlHeader.Get(LastRetailJnlLine.GetFilter("No.")) then begin
            RetailJnlHeader.Init();
            RetailJnlHeader."Date of creation" := Today();
        end;
        LastRetailJnlLine.FilterGroup(0);
        "Register No." := RetailJnlHeader."Register No.";
        "Calculation Date" := RetailJnlHeader."Date of creation";
        "Customer Price Group" := RetailJnlHeader."Customer Price Group";
        "Customer Disc. Group" := RetailJnlHeader."Customer Disc. Group";
    end;

    local procedure UpdateBarcode()
    var
        BarcodeLibrary: Codeunit "NPR Barcode Lookup Mgt.";
        BarcodeValue: Text[50];
        ResolvingTable: Integer;
        TmpItemNo: Code[20];
        TmpVarCode: Code[10];
    begin
        if (Barcode = '') then begin
            if BarcodeLibrary.GetItemVariantBarcode(BarcodeValue, "Item No.", "Variant Code", ResolvingTable, false) then
                Barcode := BarcodeValue;
        end else begin
            BarcodeLibrary.TranslateBarcodeToItemVariant(Barcode, TmpItemNo, TmpVarCode, ResolvingTable, true);
            if (TmpItemNo <> "Item No.") or (TmpVarCode <> "Variant Code") then
                if BarcodeLibrary.GetItemVariantBarcode(BarcodeValue, "Item No.", "Variant Code", ResolvingTable, false) then
                    Barcode := BarcodeValue;
        end;
    end;
}
