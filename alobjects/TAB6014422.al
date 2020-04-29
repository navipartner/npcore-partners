table 6014422 "Retail Journal Line"
{
    // //NPR 280509
    // Nye felter mht sag  Sag 70113
    // 60     Discount Type       Option
    // 61     Discount code       Code        30
    // 
    // // NPR 190609 Sag 68963
    // Ny felter tilf�jet
    // 50020     StartDate
    // 50021     CustomerPriceGroupcode
    // 
    // NPR4.10 20130304 LJJ: Field Field 50022 - "Customer No." - added.
    // VRT1.01/MMV/20150513 CASE 213635 Added Variety Fields for grouping
    // NPR4.10 20130531 LJ: Job 157162 Validated "Variant Code" on "Item No. - OnValidate()"
    // NPR4.13/MMV/20150710 CASE 206009 Refactored "Item No." and "Variant Code" OnValidate triggers.
    // NPR4.18/MMV/20151123 CASE 227849 Added more barcode fallbacks to "Item No." OnValidate trigger.
    // NPR4.18/MMV/20151228 CASE 225584 Removed unused fields 6014401 & 6014402
    // NPR4.18/MMV/20160126 CASE 232859 Expanded F 42 from Code[30] to Code[50] to match table 23
    // NPR5.23/JDH /20160513 CASE 240916 Removed old VariaX Solution
    // NPR5.23/MMV /20160610 CASE 242522 Updated barcode lookups.
    // NPR5.29/TJ  /20161223 CASE 249720 Replaced calling of standard codeunit 7000 Sales Price Calc. Mgt. with our own codeunit 6014453 POS Sales Price Calc. Mgt.
    // NPR5.30/MMV /20170124 CASE 262533 Skip auto Line No. when temp rec.
    // NPR5.30/TJ  /20170215 CASE 265504 Changed ENU captions on fields with word Register in their name
    // NPR5.31/JLK /20170331 CASE 268274 Changed ENU Caption
    // NPR5.36/MMV /20170919 CASE 290792 Deleted legacy field 26 "Barcode ok".
    // NPR5.37/MMV /20171012 CASE 289725 Always fill description 2.
    // NPR5.38/TJ  /20171218 CASE 225415 Renumbered fields from range 50xxx to range below 50000
    // NPR5.41/JC  /20180403 CASE 309131 Add filter on Inventory based on location on line. Updated Field 50 Location code20 o code10 & parameters in Field Inventory
    // NPR5.45/MHA /20180803 CASE 323705 Changed FindItemSalesPrice() to use Retail Price function
    // NPR5.45/BHR /20180829 CASE 326412 added field Vat% and Unit Price InclVat
    // NPR5.46/JDH /20180925 CASE 294354 Cleanup of old code. Restructured Price calculation. Created new functions for easier line creation
    // NPR5.47/BHR /20181018 CASE 331700 Add the field 85 "Unit List price"
    // NPR5.47/JDH /20180925 CASE 294354 Restructured Price calculation. Created new functions for easier line creation
    // NPR5.48/MMV /20181204 CASE 327107 Added field 90
    // NPR5.49/BHR /20190220 CASE 344000 Added fields 36,37,38,76,77,78
    // NPR5.49/TJ  /20190307 CASE 347533 New field 100
    // NPR5.50/ALST/20190408 CASE 350435 modified logic to allow for multiple line inserts on items from the same batch
    // NPR5.51/MHA /20190822 CASE 365886 Discount Pct. is set to 0 when Unit Price is 0 in CalcDiscountPrice()

    Caption = 'Retail Journal Line';

    fields
    {
        field(1;"No.";Code[40])
        {
            Caption = 'No.';
            TableRelation = "Retail Journal Header"."No.";
        }
        field(2;"Item No.";Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                Item: Record Item;
                Vendor: Record Vendor;
                BarcodeLibrary: Codeunit "Barcode Library";
                ItemCrossReference: Record "Item Cross Reference";
                BarcodeValue: Text;
                ResolvingTable: Integer;
            begin
                //-NPR5.46 [294354]
                // IF BarcodeLibrary.TranslateBarcodeToItemVariant("Item No.",ItemNo,VariantCode,ResolvingTable,TRUE) THEN BEGIN
                //  "Item No." := ItemNo;
                //  VALIDATE("Variant Code", VariantCode);
                // END;
                //
                // Item.GET("Item No.");
                // VALIDATE( Description, Item.Description );
                // VALIDATE( "Vendor No.", Item."Vendor No." );
                // VALIDATE( "Vendor Item No.", Item."Vendor Item No." );
                // VALIDATE( "Unit cost", Item."Last Direct Cost" );
                // VALIDATE( "Unit price", Item."Unit Price" );
                // "Item group"               := Item."Item Group";
                // "Cannot edit unit price"   := Item."Cannot edit unit price";
                //
                // IF Quantity = 0 THEN
                //  VALIDATE( Quantity, 1 );
                //
                // IF Item."Sales Unit of Measure" <> '' THEN
                //  VALIDATE( "Sales Unit of measure", Item."Sales Unit of Measure" );
                //
                // IF "Variant Code" = '' THEN BEGIN
                //  IF BarcodeLibrary.GetItemVariantBarcode(BarcodeValue, "Item No.", "Variant Code", ResolvingTable, FALSE) THEN
                //    VALIDATE(Barcode, BarcodeValue);
                //  //-NPR5.37 [289725]
                //  VALIDATE("Description 2", Item."Description 2");
                //  //+NPR5.37 [289725]
                // END;
                //
                // VALIDATE( "Cannot edit unit price", Item."Cannot edit unit price" );
                // VALIDATE("New Item No.", "Item No.");
                //
                // IF Vendor.GET(Item."Vendor No.") THEN BEGIN
                //  VALIDATE("Vendor Name", Vendor.Name);
                //  VALIDATE("Vendor Search Description", Vendor."Search Name");
                // END;

                // FindItemSalesPrice;
                if "Item No." = '' then begin
                  Init;
                  exit;
                end;

                if Item.Get("Item No.") then begin
                  Validate("Vendor No.", Item."Vendor No.");
                  Description              := Item.Description;
                  "Description 2"          := Item."Description 2";
                  "Vendor Item No."        := Item."Vendor Item No.";
                  "Last Direct Cost"       := Item."Last Direct Cost";
                  "Unit Price"             := Item."Unit Price";
                  "Item group"             := Item."Item Group";
                  "Cannot edit unit price" := Item."Cannot edit unit price";
                  "New Item No."           := "Item No.";
                  if Item."Sales Unit of Measure" <> '' then
                    "Sales Unit of measure" := Item."Sales Unit of Measure";
                  //-NPR5.47 [331700]
                  "Unit List Price"         := Item. "Unit List Price";
                  //+NPR5.47 [331700]

                  UpdateBarcode;
                end else begin
                  //To support old code, we still support Barcodes in this field.
                  Validate(Barcode, "Item No.");
                  exit;
                end;

                "Quantity to Print" := 1;
                Validate("Quantity for Discount Calc", 1);
                //+NPR5.46 [294354]
            end;
        }
        field(3;"Quantity to Print";Decimal)
        {
            Caption = 'Quantity to Print';
        }
        field(4;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(5;"Vendor No.";Code[20])
        {
            Caption = 'Vendor No.';
            TableRelation = Vendor;

            trigger OnValidate()
            var
                Vendor: Record Vendor;
            begin
                //-NPR5.46 [294354]
                if not Vendor.Get("Vendor No.") then
                  Vendor.Init;

                "Vendor Name" := Vendor.Name;
                "Vendor Search Description" := Vendor."Search Name";
                //+NPR5.46 [294354]
            end;
        }
        field(6;"Vendor Item No.";Code[20])
        {
            Caption = 'Vendor Item No.';
        }
        field(7;"Discount Price Incl. Vat";Decimal)
        {
            Caption = 'Discount Price Incl. Vat';

            trigger OnValidate()
            begin
                Currency.InitRoundingPrecision;
                "Discount Price Excl. VAT" :=
                  Round(
                    "Discount Price Incl. Vat" /
                    (1 + "VAT %" / 100),
                    Currency."Amount Rounding Precision");

                CalcDiscountPrice(FieldNo("Discount Price Incl. Vat"));
                calcProfit;
            end;
        }
        field(8;"Last Direct Cost";Decimal)
        {
            Caption = 'Last Direct Cost';

            trigger OnValidate()
            begin
                calcProfit;
            end;
        }
        field(9;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(10;"Sales Unit of measure";Code[10])
        {
            Caption = 'Sales Unit of measure';
        }
        field(11;Barcode;Code[50])
        {
            Caption = 'Barcode';

            trigger OnValidate()
            var
                BarcodeLibrary: Codeunit "Barcode Library";
                ItemNo: Code[20];
                VariantCode: Code[10];
                ResolvingTable: Integer;
            begin
                //-NPR5.46 [294354]
                if BarcodeLibrary.TranslateBarcodeToItemVariant(Barcode,ItemNo,VariantCode,ResolvingTable,true) then begin
                  Validate("Item No.", ItemNo);
                  Validate("Variant Code", VariantCode);
                end;
                //+NPR5.46 [294354]
            end;
        }
        field(13;"Mixed Discount";Code[20])
        {
            Caption = 'Mixed Discount';
        }
        field(14;"Period Discount";Code[20])
        {
            Caption = 'Campaign/period discount';
        }
        field(17;"Variant Code";Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE ("Item No."=FIELD("Item No."));

            trigger OnValidate()
            var
                ItemVariant: Record "Item Variant";
            begin
                if "Variant Code" = '' then
                  exit;

                if ItemVariant.Get("Item No.","Variant Code") then
                  "Description 2" := ItemVariant.Description;

                //-NPR5.46 [294354]
                //IF BarcodeLibrary.GetItemVariantBarcode(BarcodeValue, "Item No.", "Variant Code", ResolvingTable, FALSE) THEN
                //  VALIDATE(Barcode, BarcodeValue);
                UpdateBarcode;
                //+NPR5.46 [294354]

                FindItemSalesPrice;
            end;
        }
        field(18;"Description 2";Text[50])
        {
            Caption = 'Description 2';
        }
        field(19;"Item group";Code[10])
        {
            Caption = 'Item group';
            NotBlank = true;
        }
        field(20;Assortment;Code[20])
        {
            Caption = 'Assortment';
            NotBlank = true;
        }
        field(21;"New Item No.";Code[20])
        {
            Caption = 'New Item No.';
        }
        field(22;"New Item";Boolean)
        {
            Caption = 'New Item';
        }
        field(23;"Purch. Unit of measure";Code[10])
        {
            Caption = 'Purch. Unit of measure';
        }
        field(24;"Base Unit of measure";Code[10])
        {
            Caption = 'Base Unit of measure';
        }
        field(25;Inventory;Decimal)
        {
            CalcFormula = Sum("Item Ledger Entry".Quantity WHERE ("Item No."=FIELD("Item No."),
                                                                  "Global Dimension 1 Code"=FIELD("Shortcut Dimension 1 Code"),
                                                                  "Global Dimension 2 Code"=FIELD("Shortcut Dimension 2 Code"),
                                                                  "Location Code"=FIELD("Location Code"),
                                                                  "Variant Code"=FIELD("Variant Code")));
            Caption = 'Inventory';
            DecimalPlaces = 0:5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(27;"Cannot edit unit price";Boolean)
        {
            Caption = 'Can''t edit unit price';
            FieldClass = Normal;
        }
        field(28;"Profit % (new)";Decimal)
        {
            Caption = 'Profit % (new)';
        }
        field(29;"Unit Price";Decimal)
        {
            Caption = 'Unit Price';

            trigger OnValidate()
            begin
                //-NPR5.46 [294354]
                CalcDiscountPrice(FieldNo("Unit Price"));
                //+NPR5.46 [294354]
            end;
        }
        field(30;"Discount Unit Price";Decimal)
        {
            Caption = 'Discount Unit Price';
        }
        field(31;"Serial No.";Code[20])
        {
            Caption = 'Serial No.';

            trigger OnLookup()
            var
                "Item Ledger Entry": Record "Item Ledger Entry";
            begin
                "Item Ledger Entry".SetRange("Item No.","Item No.");
                if PAGE.RunModal(PAGE::"Serial Numbers Lookup","Item Ledger Entry") = ACTION::LookupOK then
                  "Serial No." := "Item Ledger Entry"."Serial No.";
            end;
        }
        field(36;"Net Change";Decimal)
        {
            CalcFormula = Sum("Item Ledger Entry".Quantity WHERE ("Item No."=FIELD("Item No."),
                                                                  "Global Dimension 1 Code"=FIELD("Shortcut Dimension 1 Code"),
                                                                  "Global Dimension 2 Code"=FIELD("Shortcut Dimension 2 Code"),
                                                                  "Location Code"=FIELD("Location Code"),
                                                                  "Posting Date"=FIELD("Calculation Date"),
                                                                  "Variant Code"=FIELD("Variant Code")));
            Caption = 'Net Change';
            DecimalPlaces = 0:5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(37;"Purchases (Qty.)";Decimal)
        {
            CalcFormula = Sum("Item Ledger Entry"."Invoiced Quantity" WHERE ("Entry Type"=CONST(Purchase),
                                                                             "Item No."=FIELD("Item No."),
                                                                             "Global Dimension 1 Code"=FIELD("Shortcut Dimension 1 Code"),
                                                                             "Global Dimension 2 Code"=FIELD("Shortcut Dimension 2 Code"),
                                                                             "Location Code"=FIELD("Location Code"),
                                                                             "Variant Code"=FIELD("Variant Code"),
                                                                             "Posting Date"=FIELD("Calculation Date")));
            Caption = 'Purchases (Qty.)';
            DecimalPlaces = 0:5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(38;"Sales (Qty.)";Decimal)
        {
            CalcFormula = -Sum("Value Entry"."Invoiced Quantity" WHERE ("Item Ledger Entry Type"=CONST(Sale),
                                                                        "Item No."=FIELD("Item No."),
                                                                        "Global Dimension 1 Code"=FIELD("Shortcut Dimension 1 Code"),
                                                                        "Global Dimension 2 Code"=FIELD("Shortcut Dimension 1 Code"),
                                                                        "Location Code"=FIELD("Location Code"),
                                                                        "Variant Code"=FIELD("Variant Code"),
                                                                        "Posting Date"=FIELD("Calculation Date")));
            Caption = 'Sales (Qty.)';
            DecimalPlaces = 0:5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(41;"Vendor Name";Text[60])
        {
            Caption = 'Vendor Name';
        }
        field(42;"Vendor Search Description";Code[50])
        {
            Caption = 'Vendor Search Description';
        }
        field(47;"Register No.";Code[20])
        {
            Caption = 'Cash Register No.';
            TableRelation = Register;
        }
        field(50;"Location Filter";Code[10])
        {
            Caption = 'Location Code';
            FieldClass = FlowFilter;
            TableRelation = Location;
        }
        field(60;"Discount Type";Option)
        {
            Caption = 'Discount Type';
            Description = 'Sag 70113';
            OptionCaption = ' ,Period,Mixed,Multiple Unit,Salesperson Discount,Inventory,Photo Work,Rounding,Combination,Customer';
            OptionMembers = " ",Campaign,Mix,Quantity,Manual,"BOM List","Photo work",Rounding,Combination,Customer;
        }
        field(61;"Discount Code";Code[20])
        {
            Caption = 'Discount Code';
            Description = 'Sag 70113';
            TableRelation = IF ("Discount Type"=CONST(Mix)) "Mixed Discount"
                            ELSE IF ("Discount Type"=CONST(Quantity)) "Quantity Discount Header";
        }
        field(62;"Discount Pct.";Decimal)
        {
            Caption = 'Discount %';

            trigger OnValidate()
            begin
                //-NPR5.46 [294354]
                CalcDiscountPrice(FieldNo("Discount Pct."));
                //+NPR5.46 [294354]
            end;
        }
        field(63;"Quantity for Discount Calc";Decimal)
        {
            Caption = 'Quantity for Discount Calculation';

            trigger OnValidate()
            begin
                //-NPR5.46 [294354]
                FindItemSalesPrice;
                //+NPR5.46 [294354]
            end;
        }
        field(65;"Calculation Date";Date)
        {
            Caption = 'Calculation Date';
        }
        field(70;"Customer Price Group";Code[10])
        {
            Caption = 'Customer Price Group';
            TableRelation = "Customer Price Group";
        }
        field(72;"Customer Disc. Group";Code[20])
        {
            Caption = 'Customer Disc. Group';
            Description = 'NPR5.31';
            TableRelation = "Customer Discount Group";
        }
        field(75;"Customer No.";Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;

            trigger OnValidate()
            var
                Customer: Record Customer;
                AltNo: Record "Alternative No.";
            begin
                if "Customer No." <> xRec."Customer No." then
                  if "Customer No." <> '' then begin
                    Customer.Get("Customer No.");

                    Clear(AltNo);
                    AltNo.SetCurrentKey(Type, Code, "Alt. No.");
                    AltNo.SetRange(Type, AltNo.Type::Customer);
                    AltNo.SetRange(Code, Customer."No.");
                    if AltNo.FindFirst then
                      Barcode := AltNo."Alt. No.";

                    Description := Customer.Name;
                  end;
            end;
        }
        field(76;"Shortcut Dimension 1 Code";Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(1));
        }
        field(77;"Shortcut Dimension 2 Code";Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(2));
        }
        field(78;"Location Code";Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;

            trigger OnValidate()
            var
                RetailJournalLine: Record "Retail Journal Line";
            begin
                //-NPR5.46 [294354]
                //-NPR5.41 [309131]
                // RetailJournalLine.SETRANGE("No.", Rec."No.");
                // RetailJournalLine.MODIFYALL("Location Filter", Rec."Location Code", TRUE);
                //+NPR5.41
                //+NPR5.46 [294354]
            end;
        }
        field(80;"Discount Price Excl. VAT";Decimal)
        {
            Caption = 'Discount Price Excl. VAT';

            trigger OnValidate()
            begin
                //-NPR5.46 [294354]
                Currency.InitRoundingPrecision;
                Validate("Discount Price Incl. Vat",
                  Round(
                    "Discount Price Excl. VAT" *
                    (1 + ("VAT %" / 100)),
                    Currency."Amount Rounding Precision"));
                //+NPR5.46 [294354]
            end;
        }
        field(81;"VAT %";Decimal)
        {
            Caption = 'VAT %';
        }
        field(85;"Unit List Price";Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit List Price';
            MinValue = 0;
        }
        field(90;"RFID Tag Value";Text[30])
        {
            Caption = 'RFID Tag Value';
        }
        field(100;"Exchange Label";Code[13])
        {
            Caption = 'Exchange Label';
            Description = 'NPR5.49';

            trigger OnValidate()
            var
                ExchangeLabel: Record "Exchange Label";
                RetailJournalLine: Record "Retail Journal Line";
                RetailJournalLine2: Record "Retail Journal Line";
                MultipleLines: Boolean;
            begin
                //-NPR5.49 [347533]
                // //-NPR5.50 [350435]
                // IF ExchangeLabel.FINDFIRST THEN BEGIN
                //  VALIDATE("Item No.",ExchangeLabel."Item No.");
                //  VALIDATE("Variant Code",ExchangeLabel."Variant Code");
                // END;
                // //+NPR5.49 [347533]
                ExchangeLabel.SetRange(Barcode,"Exchange Label");
                ExchangeLabel.FindFirst;

                if ExchangeLabel."Packaged Batch" then begin
                  ExchangeLabel.SetRange(Barcode);
                  ExchangeLabel.SetRange("Packaged Batch",true);
                  ExchangeLabel.SetRange("Batch No.", ExchangeLabel."Batch No.");
                  ExchangeLabel.SetRange("Register No.", ExchangeLabel."Register No.");
                  ExchangeLabel.SetRange("Sales Ticket No.", ExchangeLabel."Sales Ticket No.");
                  ExchangeLabel.FindSet;
                end;

                repeat
                  if not MultipleLines then
                    RetailJournalLine := Rec
                  else begin
                    RetailJournalLine.SelectRetailJournal("No.");
                    RetailJournalLine.InitLine;
                  end;

                  RetailJournalLine."Exchange Label" := ExchangeLabel.Barcode;
                  RetailJournalLine.Validate("Item No.",ExchangeLabel."Item No.");
                  RetailJournalLine.Validate("Variant Code",ExchangeLabel."Variant Code");
                  RetailJournalLine."Quantity to Print" := ExchangeLabel.Quantity;

                  if MultipleLines then
                    RetailJournalLine.Insert(true)
                  else
                    Rec := RetailJournalLine;

                  MultipleLines := true;
                until (ExchangeLabel.Next = 0) or (not ExchangeLabel."Packaged Batch");
                //+NPR5.50 [350435]
            end;
        }
        field(6059970;"Is Master";Boolean)
        {
            Caption = 'Is Master';
            Description = 'VRT';
        }
        field(6059971;"Master Line No.";Integer)
        {
            Caption = 'Master Line No.';
            Description = 'VRT';
        }
    }

    keys
    {
        key(Key1;"No.","Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        //-NPR5.46 [294354]
        // IF NOT ISTEMPORARY THEN BEGIN
        //  RetailJnlLine.SETRANGE("No.", "No.");
        //  IF RetailJnlLine.ISEMPTY THEN
        //    "Line No." := 10000;
        // END;
        //
        //+NPR5.46 [294354]
        "Register No." := RetailFormCode.FetchRegisterNumber;
    end;

    var
        RetailFormCode: Codeunit "Retail Form Code";
        Utility: Codeunit Utility;
        RetailJournalHeader: Record "Retail Journal Header";
        LineNo: Integer;
        ShowDialog: Boolean;
        TotalRecNo: Integer;
        RecNo: Integer;
        Dia: Dialog;
        Text001: Label 'Creating lines @1@@@@@@@';
        Text002: Label '%1 line(s) transferred to %2';
        Currency: Record Currency;
        ExchangeLabel: Record "Exchange Label";

    procedure FindItemSalesPrice()
    var
        TempSalePOS: Record "Sale POS" temporary;
        TempSaleLinePOS: Record "Sale Line POS" temporary;
        POSSalesPriceCalcMgt: Codeunit "POS Sales Price Calc. Mgt.";
        Item: Record Item;
        POSSalesDiscountCalcMgt: Codeunit "POS Sales Discount Calc. Mgt.";
        TMPDiscountPriority: Record "Discount Priority" temporary;
        TempSaleLinePOS2: Record "Sale Line POS" temporary;
        Register: Record Register;
    begin
        //-NPR5.45 [323705]
        //POSSalesPriceCalcMgt.GetItemSalesPrice(TempSalesPrice,'',"Item No.","Variant Code",'',
        //                                     RetailDocumentHeader."Prices Including VAT",Customer);
        //
        //"Unit price" := TempSalesPrice."Unit Price";
        TempSaleLinePOS.Type := TempSaleLinePOS.Type::Item;
        TempSaleLinePOS."No." := "Item No.";
        TempSaleLinePOS."Variant Code" := "Variant Code";

        POSSalesPriceCalcMgt.InitTempPOSItemSale(TempSaleLinePOS,TempSalePOS);
        //-NPR5.47 [323705]
        if "Register No." <> '' then
          TempSalePOS."Register No." := "Register No."
        else
          TempSalePOS."Register No." := RetailFormCode.FetchRegisterNumber;

        if not Register.Get(TempSalePOS."Register No.") then
          Register.Init;

        if "Customer Price Group" <> '' then
          TempSalePOS."Customer Price Group" := "Customer Price Group"
        else
          TempSalePOS."Customer Price Group" := Register."Customer Price Group";

        if "Customer Disc. Group" <> '' then
          TempSalePOS."Customer Disc. Group" := "Customer Disc. Group"
        else
          TempSalePOS."Customer Disc. Group" := Register."Customer Disc. Group";
        if "Calculation Date" <> 0D then
          TempSalePOS.Date := "Calculation Date";
        //+NPR5.47 [323705]

        TempSalePOS."Prices Including VAT" := true;
        //-NPR5.46 [294354]
        Item.Get("Item No.");
        //TempSalePOS."Customer Price Group" := "Customer Price Group";
        //TempSalePOS."Customer Disc. Group" := "Customer Disc. Group";
        //TempSalePOS.Date := "Calculation Date";

        //TempSaleLinePOS."Customer Price Group" := "Customer Price Group";
        TempSaleLinePOS."Customer Price Group" := TempSalePOS."Customer Price Group";

        TempSaleLinePOS."Item Disc. Group" := Item."Item Disc. Group";
        TempSaleLinePOS.Silent := true;
        TempSaleLinePOS.Date := "Calculation Date";
        TempSaleLinePOS.Validate(Quantity, "Quantity for Discount Calc");
        //+NPR5.46 [294354]
        //-NPR5.47 [323705]
        TempSaleLinePOS."Register No." := "Register No.";
        //+NPR5.47 [323705]

        POSSalesPriceCalcMgt.FindItemPrice(TempSalePOS,TempSaleLinePOS);
        POSSalesDiscountCalcMgt.InitDiscountPriority(TMPDiscountPriority);
        //POSSalesDiscountCalcMgt.OnFindActiveSaleLineDiscounts(TMPDiscountPriority,TempSaleLinePOS,TempSaleLinePOS,0);
        TempSaleLinePOS2 := TempSaleLinePOS;
        TempSaleLinePOS2.Insert;
        TMPDiscountPriority.SetCurrentKey(Priority);
        if TMPDiscountPriority.FindSet then repeat
          POSSalesDiscountCalcMgt.ApplyDiscount(TMPDiscountPriority,TempSalePOS,TempSaleLinePOS2,TempSaleLinePOS,TempSaleLinePOS,0,true);
          TempSaleLinePOS2.UpdateAmounts(TempSaleLinePOS2);
        until (TMPDiscountPriority.Next = 0) or (TempSaleLinePOS2."Discount Type" <> TempSaleLinePOS2."Discount Type"::" ");
        "Discount Price Incl. Vat" := TempSaleLinePOS2."Amount Including VAT";
        //+NPR5.45 [323705]
        //-NPR5.45 [326412]
        "VAT %":= TempSaleLinePOS2."VAT %";
        "Discount Price Excl. VAT" := TempSaleLinePOS2.Amount;
        //+NPR5.45 [326412]
        //-NPR5.46 [294354]
        "Unit Price" := TempSaleLinePOS2."Unit Price";
        "Discount Type" := TempSaleLinePOS2."Discount Type";
        "Discount Code" := TempSaleLinePOS2."Discount Code";
        "Discount Pct." := TempSaleLinePOS2."Discount %";
        //+NPR5.46 [294354]
    end;

    procedure calcProfit()
    var
        tItem: Record Item temporary;
        Item1: Record Item;
        d: Dialog;
    begin
        if ("Discount Price Incl. Vat" = 0) then
          exit;

        if Item1.Get("Item No.") then begin
          if Item1."Unit Cost" = 0 then begin
            Item1."Unit Cost" := "Last Direct Cost";
            Item1.Validate("Unit Price", "Discount Price Incl. Vat");
            "Profit % (new)" := Item1."Profit %";
          end else begin
            Item1.Validate("Unit Price", "Discount Price Incl. Vat");
            "Profit % (new)" := Item1."Profit %";
          end;
        end else begin
          if "Item No." <> '' then begin
            tItem.Init;
            tItem."No." := "Item No.";
            tItem.Validate("Item Group", "Item group");
            tItem."Unit Cost" := "Last Direct Cost";
            tItem.Validate("Unit Price", "Discount Price Incl. Vat");
            "Profit % (new)" := tItem."Profit %";
          end;
        end;
        //-NPR5.46 [294354]
        // //-NPR5.45 [326412]
        // "Discount Price Excl. VAT" := "Discount Price Incl. Vat" *((100-"VAT %")/100);
        // //+NPR5.45 [326412]
        //+NPR5.46 [294354]
    end;

    procedure SelectRetailJournal(var RetailJournalCode: Code[40]) JournalSelected: Boolean
    var
        RetailJnlLine: Record "Retail Journal Line";
    begin
        //-NPR5.46 [294354]
        if not RetailJournalHeader.Get(RetailJournalCode) then begin
          RetailJournalHeader.Init;
          RetailJournalHeader."No." := RetailJournalCode;
          RetailJournalHeader."Register No." := RetailFormCode.FetchRegisterNumber;
        end;
        RetailJournalHeader.TestField("No.");

        RetailJnlLine.SetRange("No.", RetailJournalHeader."No.");
        if RetailJnlLine.FindLast then
          LineNo := RetailJnlLine."Line No." + 10000
        else
          LineNo := 10000;
        exit(true);
        //+NPR5.46 [294354]
    end;

    procedure UseGUI(TotalNoOfLines: Integer)
    begin
        //-NPR5.46 [294354]
        if not GuiAllowed then
          exit;

        if TotalNoOfLines < 1 then
          exit;

        ShowDialog := true;
        TotalRecNo := TotalNoOfLines;

        Dia.Open(Text001);
        //+NPR5.46 [294354]
    end;

    procedure InitLine()
    var
        RetailJnlLine: Record "Retail Journal Line";
    begin
        //-NPR5.46 [294354]
        RetailJournalHeader.TestField("No.");

        RecNo += 1;
        if ShowDialog then
          Dia.Update(1, Round(RecNo / TotalRecNo * 10000,1));

        Init;
        "No." := RetailJournalHeader."No.";
        "Line No." := LineNo;
        LineNo += 10000;
        "Calculation Date" := RetailJournalHeader."Date of creation";
        "Customer Price Group" := RetailJournalHeader."Customer Price Group";
        "Customer Disc. Group" := RetailJournalHeader."Customer Disc. Group";

        if RetailJournalHeader."Register No." = '' then
          "Register No." := RetailFormCode.FetchRegisterNumber
        else
          "Register No." := RetailJournalHeader."Register No.";
        //+NPR5.46 [294354]
    end;

    procedure SetItem(ItemNo: Code[20];VariantCode: Code[10];Barcode: Code[20])
    begin
        //-NPR5.46 [294354]
        if Barcode <> '' then
          Validate(Barcode, Barcode)
        else begin
          "Variant Code" := VariantCode;
          Validate("Item No.", ItemNo);
        end;
        //+NPR5.46 [294354]
    end;

    procedure SetDiscountType(DiscountType: Option " ",Campaign,Mix,Quantity,Manual,"BOM List","Photo work",Rounding,Combination,Customer;DiscountCode: Code[20];DiscountPrice: Decimal;DiscountQuantity: Decimal;PriceInclVAT: Boolean)
    begin
        //+NPR5.46 [294354]
        "Discount Type" := DiscountType;
        "Discount Code" := DiscountCode;
        "Quantity for Discount Calc" := DiscountQuantity;
        if PriceInclVAT then
          Validate("Discount Price Incl. Vat", DiscountPrice)
        else
          Validate("Discount Price Excl. VAT", DiscountPrice);
        //+NPR5.46 [294354]
    end;

    procedure CloseGUI()
    begin
        //-NPR5.46 [294354]
        if not ShowDialog then
          exit;

        Dia.Close;
        ShowDialog := false;
        //+NPR5.46 [294354]
    end;

    local procedure CalcDiscountPrice(CalledFromFieldNo: Integer)
    begin
        //-NPR5.46 [294354]
        Currency.InitRoundingPrecision;
        case CalledFromFieldNo of
          FieldNo("Discount Pct."):
            begin
              Validate("Discount Price Incl. Vat",
                Round(
                  "Unit Price" * "Quantity for Discount Calc" * (1 - "Discount Pct." / 100),
                    Currency."Amount Rounding Precision"));
            end;
          FieldNo("Unit Price"),FieldNo("Discount Price Incl. Vat"):
            begin
              //-NPR5.51 [365886]
              if ("Quantity for Discount Calc" = 0) or ("Unit Price" = 0) then begin
                "Discount Pct." := 0;
                exit;
              end;
              //+NPR5.51 [365886]
              "Discount Pct." := (1 - ( "Discount Price Incl. Vat" / "Quantity for Discount Calc" / "Unit Price")) * 100;
            end;
        end;
        //+NPR5.46 [294354]
    end;

    procedure SetupNewLine(var LastRetailJnlLine: Record "Retail Journal Line")
    var
        RetailJnlHeader: Record "Retail Journal Header";
        i: Integer;
    begin
        //-NPR5.47 [294354]
        //-NPR5.46 [294354]
        //IF LastRetailJnlLine."No." <> '' THEN BEGIN
        //  "Calculation Date" := LastRetailJnlLine."Calculation Date";
        //  "Customer Price Group" := LastRetailJnlLine."Customer Price Group";
        //  "Customer Disc. Group" := LastRetailJnlLine."Customer Disc. Group";
        //  "Register No." := LastRetailJnlLine."Register No.";
        //END ELSE BEGIN
          LastRetailJnlLine.FilterGroup(4);
          if not RetailJnlHeader.Get(LastRetailJnlLine.GetFilter("No.")) then begin
            RetailJnlHeader.Init;
            RetailJnlHeader."Date of creation" := Today;
          end;
          LastRetailJnlLine.FilterGroup(0);
          if RetailJnlHeader."Register No." = '' then
            "Register No." := RetailFormCode.FetchRegisterNumber
          else
            "Register No." := RetailJnlHeader."Register No.";

          "Calculation Date" := RetailJnlHeader."Date of creation";
          "Customer Price Group" := RetailJnlHeader."Customer Price Group";
          "Customer Disc. Group" := RetailJnlHeader."Customer Disc. Group";

        //END;
        //+NPR5.46 [294354]
        //+NPR5.47 [294354]
    end;

    local procedure UpdateBarcode()
    var
        BarcodeLibrary: Codeunit "Barcode Library";
        BarcodeValue: Text;
        ResolvingTable: Integer;
        TmpItemNo: Code[20];
        TmpVarCode: Code[10];
    begin
        //-NPR5.46 [294354]
        if (Barcode = '') then begin
          if BarcodeLibrary.GetItemVariantBarcode(BarcodeValue, "Item No.", "Variant Code", ResolvingTable, false) then
            Barcode := BarcodeValue;
        end else begin
          BarcodeLibrary.TranslateBarcodeToItemVariant(Barcode, TmpItemNo, TmpVarCode, ResolvingTable, true);
          if (TmpItemNo <> "Item No.") or (TmpVarCode <> "Variant Code") then
              if BarcodeLibrary.GetItemVariantBarcode(BarcodeValue, "Item No.", "Variant Code", ResolvingTable, false) then
                Barcode := BarcodeValue;
        end;
        //+NPR5.46 [294354]
    end;
}

