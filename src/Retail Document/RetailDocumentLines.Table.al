table 6014426 "NPR Retail Document Lines"
{
    // //-NPR3.0k ved Nikolai Pedersen
    //   tilf¢jet vat %
    // //-NPR3.0l ved Nikolai Pedersen
    //   tilf¢jet bel¢b incl. moms
    // //-NPR3.0m ved Nikolai Pedersen
    //   varenummer -> onvalidate udregner nu moms efter varen og hovedet
    // //-NPR3.0n ved Nikolai Pedersen
    //    Overf¢rFraEkspLinie-> moms udregnes efter ekspeditionen og hovedet
    // //-NPR3.0p ved Simon Sch¢bel
    //   Tilf¢jet feltet"date of rental"
    // 
    // NPR4.001.003, 11-06-09, MH, Tilf¢jet feltet "Lock Code" (sag 65422).
    // NPR4.001.004, 08-07-09, MH, Tilf¢jet overf¢rsel af feltet "Lock Code" i forbindelse med Sale2RetailDocument (sag 65422).
    // NPR5.23/JDH /20160513 CASE 240916 Removed old VariaX Solution
    // NPR5.29/TJ/20161223 CASE 249720 Replaced calling of standard codeunit 7000 Sales Price Calc. Mgt. with our own codeunit 6014453 POS Sales Price Calc. Mgt.
    // NPR5.32/JLK /20170428  CASE 272861  Removed Validate because trigger is calling for Item Unit Price instead of Sales Line POS price
    //                                     Issue rising when changing a Unit Price on POS
    // NPR5.35/TJ  /20170809  CASE 286283 Renamed variables/functions into english and into proper naming terminology
    // NPR5.38/TJ  /20171218  CASE 225415 Renumbered fields from range 50xxx to range below 50000
    // NPR5.38/JDH /20180116 CASE 302570 Translated option string on field 22 (Sales Type), as well as changed ENU caption to the same as in the POS Sales line
    // NPR5.45/MHA /20180803 CASE 323705 Changed FindItemSalesPrice() to use Retail Price function
    // NPR5.48/TS  /20181128 CASE 337806 UnitOfMeasure changed from  text to code
    // NPR5.51/MHA /20190722 CASE 358985 Added hook OnGetVATPostingSetup() and removed redundant VAT calculation

    Caption = 'Retail Document Line';
    LookupPageID = "NPR Retail Document Lines";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Document Type"; Option)
        {
            Caption = 'Document Type';
            OptionCaption = ' ,Selection,Retail Order,Wish,Customization,Delivery,Rental contract,Purchase contract,Qoute';
            OptionMembers = " ","Selection Contract","Retail Order",Wish,Customization,Delivery,"Rental contract","Purchase contract",Quote;
            DataClassification = CustomerContent;
        }
        field(2; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;
            DataClassification = CustomerContent;
        }
        field(3; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            TableRelation = "NPR Retail Document Header"."No." WHERE("Document Type" = FIELD("Document Type"));
            DataClassification = CustomerContent;
        }
        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(5; "No."; Code[20])
        {
            Caption = 'No.';
            TableRelation = IF (Type = CONST(" ")) "Standard Text"
            ELSE
            IF (Type = CONST("G/L Account")) "G/L Account"
            ELSE
            IF (Type = CONST(Item)) Item
            ELSE
            IF (Type = CONST(Resource)) Resource
            ELSE
            IF (Type = CONST("Fixed Asset")) "Fixed Asset"
            ELSE
            IF (Type = CONST("Charge (Item)")) "Item Charge"
            ELSE
            IF (Type = CONST("Catalouge items")) "Nonstock Item";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                NumberLogic: Codeunit "NPR Number Logic";
            begin
                case Type of
                    Type::Item:
                        begin
                            NumberLogic.ForRetailDocumentLine("No.", Rec);
                            Item.Get("No.");
                            if xRec."No." <> "No." then
                                "Variant Code" := '';
                            //-NPR5.51 [358985]
                            "VAT Bus. Posting Group" := Item."VAT Bus. Posting Gr. (Price)";
                            Validate("VAT Prod. Posting Group", Item."VAT Prod. Posting Group");
                            //+NPR5.51 [358985]

                            //-NPR5.45 [323705]
                            RetailDocumentHeaderGlobal.Get("Document Type", "Document No.");
                            //+NPR5.45 [323705]

                            Item.Get("No.");
                            if (Item."Price Includes VAT" = RetailDocumentHeaderGlobal."Prices Including VAT") then begin
                                /* Item VAT = Header VAT */
                                "Unit price" := Item."Unit Price";
                                "Price including VAT" := RetailDocumentHeaderGlobal."Prices Including VAT";
                            end else
                                if (Item."Price Includes VAT" and not RetailDocumentHeaderGlobal."Prices Including VAT") then begin
                                    /* Item incl. VAT + Header excl. VAT => remove VAT */
                                    "Unit price" := Item."Unit Price" / (1 + ("Vat %" / 100));
                                    "Price including VAT" := false;
                                end else begin
                                    /* add VAT */
                                    "Unit price" := Item."Unit Price" * (1 + ("Vat %" / 100));
                                    "Price including VAT" := true;
                                end;

                            if Quantity = 0 then
                                Quantity := 1;

                            CalculateAmount;

                            "Package quantity" := Item."Units per Parcel";
                            Description := Item.Description;
                        end;
                    Type::" ":
                        begin
                            StdTxt.Get("No.");
                            Description := StdTxt.Description;
                        end;
                    Type::"G/L Account":
                        begin
                            GLAcc.Get("No.");
                            GLAcc.CheckGLAcc;
                            Description := GLAcc.Name;
                        end;
                    Type::Resource:
                        begin
                            Res.Get("No.");
                            Res.TestField(Blocked, false);
                            Res.TestField("Gen. Prod. Posting Group");
                            Description := Res.Name;
                        end;
                    Type::"Fixed Asset":
                        begin
                            FA.Get("No.");
                            FA.TestField(Inactive, false);
                            FA.TestField(Blocked, false);
                            Description := FA.Description;
                        end;
                    Type::"Charge (Item)":
                        begin
                            ItemCharge.Get("No.");
                            Description := ItemCharge.Description;
                        end;
                end;

            end;
        }
        field(6; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(7; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField("Quantity in order", 0);

                if Quantity = 0 then
                    Open := false
                else
                    Open := true;

                Validate("Qty. to Ship", Quantity);

                CalculateAmount;
            end;
        }
        field(8; "Unit price"; Decimal)
        {
            CaptionClass = GetCaptionClass(FieldNo("Unit price"));
            Caption = 'Unit Price';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Validate("Line discount %");
            end;
        }
        field(9; Amount; Decimal)
        {
            Caption = 'Amount';
            FieldClass = Normal;
            DataClassification = CustomerContent;
        }
        field(10; "Line discount %"; Decimal)
        {
            Caption = 'Line Discount %';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "Line discount amount" :=
                  Round(
                    Round(Quantity * "Unit price", Currency."Amount Rounding Precision") *
                    "Line discount %" / 100, Currency."Amount Rounding Precision");

                CalculateAmount;
            end;
        }
        field(11; "Line discount amount"; Decimal)
        {
            Caption = 'Line Discount Amount';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin

                "Line discount %" :=
                  Round("Line discount amount" / (Quantity * "Unit price") * 100, Currency."Amount Rounding Precision");

                CalculateAmount;
            end;
        }
        field(12; "Unit Cost (LCY)"; Decimal)
        {
            Caption = 'Unit Cost (LCY)';
            DataClassification = CustomerContent;
        }
        field(13; "Salesperson Code"; Code[10])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
        }
        field(14; "Quantity in order"; Decimal)
        {
            Caption = 'Quantity in order';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Quantity < "Quantity in order" then
                    Error(Text1060001);

                if Modify then;

                RetailDocumentHeaderGlobal.Get("Document Type", "Document No.");
                RetailDocumentHeaderGlobal.Validate(Outstanding);
                RetailDocumentHeaderGlobal.Validate("Show List");
                RetailDocumentHeaderGlobal.Modify;
            end;
        }
        field(15; "Quantity received"; Decimal)
        {
            Caption = 'Quantity received';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Quantity < "Quantity received" then
                    Error(Text1060002);

                "Received (LCY)" := "Quantity received" * "Unit price";
                HjemOverUd := "Quantity received" > "Quantity Shipped";

                if Modify then;

                RetailDocumentHeaderGlobal.Get("Document Type", "Document No.");
                RetailDocumentHeaderGlobal.Validate(Outstanding);
                RetailDocumentHeaderGlobal.Validate("Show List");
                RetailDocumentHeaderGlobal."Letter Printed" := 0D;
                RetailDocumentHeaderGlobal.Validate(Status, 2);
                RetailDocumentHeaderGlobal.Modify;
            end;
        }
        field(16; "Quantity Shipped"; Decimal)
        {
            Caption = 'Quantity Shipped';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Quantity < "Quantity Shipped" then
                    Error(Text1060003);

                HjemOverUd := "Quantity received" > "Quantity Shipped";

                Validate("Outstanding quantity", Quantity - "Quantity Shipped");
                Validate("Qty. to Ship", "Outstanding quantity");
            end;
        }
        field(17; "Received (LCY)"; Decimal)
        {
            Caption = 'Received (LCY)';
            DataClassification = CustomerContent;
        }
        field(18; "Outstanding quantity"; Decimal)
        {
            Caption = 'Outstanding quantity';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Outstanding quantity" = 0 then
                    Open := false
                else
                    Open := true;

                if Modify then;

                RetailDocumentHeaderGlobal.Get("Document Type", "Document No.");
                RetailDocumentHeaderGlobal.Validate(Outstanding);
                RetailDocumentHeaderGlobal.Validate("Show List");
                RetailDocumentHeaderGlobal.Modify;
            end;
        }
        field(19; "Unit of measure"; Code[10])
        {
            Caption = 'Unit of measure';
            Description = 'NPR5.48';
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("No."));
            DataClassification = CustomerContent;
        }
        field(20; "Std. quantity"; Decimal)
        {
            Caption = 'Std. quantity';
            DataClassification = CustomerContent;
        }
        field(21; Open; Boolean)
        {
            Caption = 'Open';
            DataClassification = CustomerContent;
        }
        field(22; "Sales Type"; Option)
        {
            Caption = 'Sales Type';
            OptionCaption = 'Sale,Payment,Debit Sale,Gift Voucher,Credit Voucher,Deposit,Out payment,Comment,Cancelled,Open/Close';
            OptionMembers = Sale,Payment,"Debit Sale","Gift Voucher","Credit Voucher",Deposit,"Out payment",Comment,Cancelled,"Open/Close";
            DataClassification = CustomerContent;
        }
        field(23; Type; Option)
        {
            Caption = 'Type';
            InitValue = Item;
            OptionCaption = ' ,G/L Account,Item,Resource,Fixed Asset,Charge (Item),Catalouge items';
            OptionMembers = " ","G/L Account",Item,Resource,"Fixed Asset","Charge (Item)","Catalouge items";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Type = Type::" " then
                    "Sales Type" := "Sales Type"::Comment;

                if Type = Type::Item then
                    "Sales Type" := "Sales Type"::Sale;
            end;
        }
        field(24; "Received last"; Date)
        {
            Caption = 'Received last';
            DataClassification = CustomerContent;
        }
        field(25; "Letter printed"; Boolean)
        {
            Caption = 'Letter printed';
            DataClassification = CustomerContent;
        }
        field(26; Color; Code[20])
        {
            Caption = 'Color';
            DataClassification = CustomerContent;
        }
        field(27; Size; Code[20])
        {
            Caption = 'Size';
            DataClassification = CustomerContent;
        }
        field(28; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("No."));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CalculateAmount;
            end;
        }
        field(31; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            TableRelation = Vendor."No.";
            DataClassification = CustomerContent;
        }
        field(32; "Serial No."; Code[20])
        {
            Caption = 'Serial No.';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                ItemLedgerEntry: Record "Item Ledger Entry";
            begin
                ItemLedgerEntry.SetRange("Item No.", "No.");

                if PAGE.RunModal(PAGE::"NPR Serial Numbers Lookup", ItemLedgerEntry) = ACTION::LookupOK then
                    "Serial No." := ItemLedgerEntry."Serial No.";
            end;
        }
        field(34; "Price including VAT"; Boolean)
        {
            Caption = 'Price Includes VAT';
            DataClassification = CustomerContent;
        }
        field(35; "Amount Including VAT"; Decimal)
        {
            Caption = 'Amount Including VAT';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Price including VAT" then
                    Validate("Line discount amount", Quantity * "Unit price" - "Amount Including VAT")
                else
                    Validate("Line discount amount", Quantity * "Unit price" - "Amount Including VAT" / (1 + "Vat %" / 100));
            end;
        }
        field(36; "Rental Amount incl. VAT"; Decimal)
        {
            Caption = 'Rental Amount incl. VAT';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "Total Rental Amount incl. VAT" := "Rental Amount incl. VAT" * Quantity;

                RetailDocumentHeaderGlobal.SetRange(RetailDocumentHeaderGlobal."Document Type", "Document Type");
                RetailDocumentHeaderGlobal.SetRange(RetailDocumentHeaderGlobal."No.", "Document No.");
                RetailDocumentHeaderGlobal.CalcAnualRent();
            end;
        }
        field(37; "Total Rental Amount incl. VAT"; Decimal)
        {
            Caption = 'Total Rental Amount incl. VAT';
            FieldClass = Normal;
            DataClassification = CustomerContent;
        }
        field(38; Accessory; Boolean)
        {
            Caption = 'Accessory';
            DataClassification = CustomerContent;
        }
        field(39; "VAT Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'VAT Amount';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(40; "Return Reason Code"; Code[10])
        {
            Caption = 'Return Reason Code';
            TableRelation = "Return Reason";
            DataClassification = CustomerContent;
        }
        field(41; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
            DataClassification = CustomerContent;
        }
        field(42; "Qty. to Ship"; Decimal)
        {
            Caption = 'Qty. to Ship';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
        }
        field(43; "Delivery Item"; Boolean)
        {
            Caption = 'Delivery Item';
            DataClassification = CustomerContent;
        }
        field(44; "Deposit item"; Boolean)
        {
            Caption = 'Deposit item';
            DataClassification = CustomerContent;
        }
        field(45; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
            DataClassification = CustomerContent;
        }
        field(46; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
            DataClassification = CustomerContent;
        }
        field(47; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
            DataClassification = CustomerContent;
        }
        field(77; "VAT Calculation Type"; Enum "Tax Calculation Type")
        {
            Caption = 'VAT Calculation Type';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(89; "VAT Bus. Posting Group"; Code[10])
        {
            Caption = 'VAT Bus. Posting Group';
            TableRelation = "VAT Business Posting Group";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Validate("VAT Prod. Posting Group");
            end;
        }
        field(90; "VAT Prod. Posting Group"; Code[10])
        {
            Caption = 'VAT Prod. Posting Group';
            TableRelation = "VAT Product Posting Group";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                POSTaxCalculation: Codeunit "NPR POS Tax Calculation";
                Handled: Boolean;
            begin
                //TestStatusOpen;
                VATPostingSetup.Get("VAT Bus. Posting Group", "VAT Prod. Posting Group");
                //-NPR5.51 [358985]
                POSTaxCalculation.OnGetVATPostingSetup(VATPostingSetup, Handled);
                //+NPR5.51 [358985]
                "VAT Difference" := 0;
                "Vat %" := VATPostingSetup."VAT %";
                "VAT Calculation Type" := VATPostingSetup."VAT Calculation Type";
                "VAT Identifier" := VATPostingSetup."VAT Identifier";
                case "VAT Calculation Type" of
                    "VAT Calculation Type"::"Reverse Charge VAT",
                  "VAT Calculation Type"::"Sales Tax":
                        "Vat %" := 0;
                    "VAT Calculation Type"::"Full VAT":
                        begin
                            TestField(Type, Type::"G/L Account");
                            VATPostingSetup.TestField("Sales VAT Account");
                            TestField("No.", VATPostingSetup."Sales VAT Account");
                        end;
                end;
                if RetailDocumentHeaderGlobal."Prices Including VAT" and (Type in [Type::Item, Type::Resource]) then
                    "Unit price" :=
                      Round(
                        "Unit price" * (100 + "Vat %") / (100 + xRec."Vat %"),
                        Currency."Unit-Amount Rounding Precision");
            end;
        }
        field(91; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            Editable = false;
            TableRelation = Currency;
            DataClassification = CustomerContent;
        }
        field(99; "VAT Base Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'VAT Base Amount';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(100; "Printing filter"; Integer)
        {
            Caption = 'Printing filter';
            FieldClass = FlowFilter;
        }
        field(104; "VAT Difference"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'VAT Difference';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(106; "VAT Identifier"; Code[10])
        {
            Caption = 'VAT Identifier';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(110; "Lock Code"; Code[10])
        {
            Caption = 'Lock Code';
            Description = 'NPR4.001.003';
            DataClassification = CustomerContent;
        }
        field(200; "Package quantity"; Decimal)
        {
            Caption = 'Package quantity';
            DataClassification = CustomerContent;
        }
        field(201; "Belongs to Item"; Code[20])
        {
            Caption = 'Belongs to Item';
            DataClassification = CustomerContent;
        }
        field(202; "Serial No. not Created"; Code[30])
        {
            Caption = 'Serial No. not Created';
            DataClassification = CustomerContent;
        }
        field(1000; HjemOverUd; Boolean)
        {
            Caption = 'Home Preceeds out';
            DataClassification = CustomerContent;
        }
        field(1001; "Vat %"; Decimal)
        {
            Caption = 'Vat %';
            DataClassification = CustomerContent;
        }
        field(1002; "Date of rental"; Date)
        {
            Caption = 'Date of rental';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Document Type", "Document No.", "Line No.")
        {
            SumIndexFields = Amount, Quantity, "Quantity in order", "Quantity received", "Quantity Shipped", "Rental Amount incl. VAT", "Amount Including VAT", "Total Rental Amount incl. VAT", "VAT Amount", "VAT Base Amount";
        }
        key(Key2; "No.")
        {
            SumIndexFields = "Outstanding quantity";
        }
        key(Key3; "Document Type", "No.", Open)
        {
        }
        key(Key4; "Document Type", "Document No.", "Outstanding quantity")
        {
        }
        key(Key5; "Document Type", "Document No.", "Quantity in order", "Quantity received", HjemOverUd)
        {
        }
        key(Key6; "Document Type", "No.")
        {
        }
        key(Key7; "Document Type", Description)
        {
        }
        key(Key8; Type)
        {
        }
        key(Key9; "Document Type", "Document No.", Type, "Deposit item", "Delivery Item")
        {
            MaintainSIFTIndex = false;
            SumIndexFields = "Amount Including VAT";
        }
        key(Key10; "Vendor No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        if "No." = '' then begin
            Type := Type::" ";
            "Sales Type" := "Sales Type"::Comment;
        end;
    end;

    trigger OnModify()
    begin
        if "No." = '' then begin
            Type := Type::" ";
            "Sales Type" := "Sales Type"::Comment;
        end;
    end;

    var
        Item: Record Item;
        Text1060001: Label 'You cannot order more than %1 units.';
        Text1060002: Label 'You cannot receive more than %1 units.';
        Text1060003: Label 'You cannot ship more than %1 units.';
        RetailDocumentHeaderGlobal: Record "NPR Retail Document Header";
        Currency: Record Currency;
        StdTxt: Record "Standard Text";
        GLAcc: Record "G/L Account";
        Res: Record Resource;
        FA: Record "Fixed Asset";
        ItemCharge: Record "Item Charge";
        VATPostingSetup: Record "VAT Posting Setup";

    procedure TransferFromSaleLinePOS(var SaleLinePOS: Record "NPR Sale Line POS")
    begin
        //TransferFromSaleLinePOS

        /* Find Rental Header */
        //-NPR5.45 [323705]
        RetailDocumentHeaderGlobal.Get("Document Type", "Document No.");
        //+NPR5.45 [323705]

        /* Insert item */
        Validate("Sales Type", SaleLinePOS."Sale Type");
        case SaleLinePOS.Type of
            SaleLinePOS.Type::"G/L Entry":
                Validate(Type, Type::"G/L Account");
            SaleLinePOS.Type::Item,
          SaleLinePOS.Type::"Item Group":
                Validate(Type, Type::Item);
            SaleLinePOS.Type::Comment:
                Validate(Type, Type::" ");
        end;

        /* Amount incl. VAT */
        /* Logic: Get from header */
        Validate("Vat %", SaleLinePOS."VAT %");
        "Price including VAT" := RetailDocumentHeaderGlobal."Prices Including VAT";

        Validate("No.", SaleLinePOS."No.");

        //-NPR3.0p
        "Date of rental" := Today;
        //+NPR3.0p

        Description := SaleLinePOS.Description;
        Validate(Quantity, SaleLinePOS.Quantity);
        Validate("Qty. to Ship", SaleLinePOS.Quantity);

        /* Prices */
        Validate("Unit of measure", SaleLinePOS."Unit of Measure Code");

        if "Price including VAT" = SaleLinePOS."Price Includes VAT" then
            //-NPR5.32
            //VALIDATE( "Unit price", EkspLinie."Unit Price" )
            "Unit price" := SaleLinePOS."Unit Price"
        //+NPR5.32
        else
            if ("Price including VAT" and not SaleLinePOS."Price Includes VAT") then
                //-NPR5.32
                "Unit price" := SaleLinePOS."Unit Price" * (1 + "Vat %" / 100)
            //+NPR5.32
            else
                //-NPR5.32
                "Unit price" := SaleLinePOS."Unit Price" / (1 + "Vat %" / 100);
        //+NPR5.32

        //-NPR5.32
        "Line discount %" := SaleLinePOS."Discount %";
        "Line discount amount" := SaleLinePOS."Discount Amount";
        Amount := SaleLinePOS.Amount;
        "Amount Including VAT" := SaleLinePOS."Amount Including VAT";
        //+NPR5.32

        /* Insert variance */
        Color := SaleLinePOS.Color;
        Size := SaleLinePOS.Size;
        "Variant Code" := SaleLinePOS."Variant Code";
        Accessory := SaleLinePOS.Accessory;
        "Return Reason Code" := SaleLinePOS."Return Reason Code";
        "Reason Code" := SaleLinePOS."Reason Code";

        "Lock Code" := SaleLinePOS."Lock Code";

        if SaleLinePOS."Serial No." <> '' then
            Validate("Serial No.", SaleLinePOS."Serial No.");

        if SaleLinePOS."Serial No. not Created" <> '' then
            Validate("Serial No. not Created", SaleLinePOS."Serial No. not Created");

    end;

    procedure FindItemSalesPrice()
    var
        Customer: Record Customer;
        TempSalePOS: Record "NPR Sale POS" temporary;
        TempSaleLinePOS: Record "NPR Sale Line POS" temporary;
        RetailDocumentHeader: Record "NPR Retail Document Header";
        POSSalesPriceCalcMgt: Codeunit "NPR POS Sales Price Calc. Mgt.";
    begin
        if Type <> Type::Item then
            exit;

        RetailDocumentHeader.Get("Document Type", "Document No.");
        //-NPR5.45 [323705]
        TempSaleLinePOS.Type := TempSaleLinePOS.Type::Item;
        TempSaleLinePOS."No." := "No.";
        TempSaleLinePOS."Variant Code" := "Variant Code";
        TempSaleLinePOS."Unit of Measure Code" := "Unit of measure";
        TempSaleLinePOS."Price Includes VAT" := RetailDocumentHeader."Prices Including VAT";

        POSSalesPriceCalcMgt.InitTempPOSItemSale(TempSaleLinePOS, TempSalePOS);
        if (RetailDocumentHeader."Customer Type" = RetailDocumentHeader."Customer Type"::Alm) and Customer.Get(RetailDocumentHeader."Customer No.") then
            TempSalePOS."Customer Price Group" := Customer."Customer Price Group";
        POSSalesPriceCalcMgt.FindItemPrice(TempSalePOS, TempSaleLinePOS);
        "Unit price" := TempSaleLinePOS."Unit Price";
        //+NPR5.45 [323705]
    end;

    procedure CalculateAmount()
    begin
        //calculate

        FindItemSalesPrice;

        Amount := Quantity * "Unit price" - "Line discount amount";

        if "Price including VAT" then begin
            "VAT Amount" := Amount / ("Vat %" / 100 + 1) * "Vat %" / 100;
            "Amount Including VAT" := Amount;
        end else begin
            "VAT Amount" := Amount * "Vat %" / 100;
            "Amount Including VAT" := Amount + "VAT Amount";
        end;

        "VAT Base Amount" := Amount;
    end;

    local procedure GetCaptionClass(FieldNumber: Integer): Text[80]
    begin
        //GetCaptionClass

        if not RetailDocumentHeaderGlobal.Get("Document Type", "Document No.") then begin
            RetailDocumentHeaderGlobal."No." := '';
            RetailDocumentHeaderGlobal.Init;
        end;
        if RetailDocumentHeaderGlobal."Prices Including VAT" then
            exit('2,1,' + GetFieldCaption(FieldNumber))
        else
            exit('2,0,' + GetFieldCaption(FieldNumber));
    end;

    local procedure GetFieldCaption(FieldNumber: Integer): Text[100]
    var
        "Field": Record "Field";
    begin
        //GetFieldCaption

        Field.Get(DATABASE::"NPR Retail Document Lines", FieldNumber);
        exit(Field."Field Caption");
    end;
}

