table 6014612 "NPR Retail Campaign Items"
{
    Caption = 'Period Discount Items';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Retail Campaign Code"; Code[20])
        {
            Caption = 'Retail Campaign Code';
            DataClassification = CustomerContent;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(5; "Disc. Type"; Option)
        {
            Caption = 'Disc. Type';
            OptionCaption = 'Periodic,Mix';
            OptionMembers = Periodic,Mix;
            DataClassification = CustomerContent;
        }
        field(6; "Disc. Code"; Code[20])
        {
            Caption = 'Disc. Code';
            DataClassification = CustomerContent;
        }
        field(12; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            NotBlank = true;
            TableRelation = Item."No.";
            DataClassification = CustomerContent;
        }
        field(13; Description; Text[50])
        {
            CalcFormula = Lookup(Item.Description WHERE("No." = FIELD("Item No.")));
            Caption = 'Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14; "Unit Price"; Decimal)
        {
            CalcFormula = Lookup(Item."Unit Price" WHERE("No." = FIELD("Item No.")));
            Caption = 'Unit Price';
            Editable = false;
            FieldClass = FlowField;
            MaxValue = 9999999;
            MinValue = 0;
        }
        field(15; "Campaign Unit Price"; Decimal)
        {
            Caption = 'Period Price';
            MaxValue = 9999999;
            MinValue = 0;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin

                if (("Unit Price" > 0) and ("Campaign Unit Price" > 0)) then begin
                    "Discount Amount" := Round("Unit Price" - "Campaign Unit Price");
                    "Discount %" := Round(("Unit Price" - "Campaign Unit Price") / "Unit Price" * 100);
                end;
            end;
        }
        field(16; Status; Option)
        {
            Caption = 'Status';
            Editable = false;
            FieldClass = Normal;
            OptionCaption = 'Await,Active,Balanced';
            OptionMembers = Await,Active,Balanced;
            DataClassification = CustomerContent;
        }
        field(17; "Starting Date"; Date)
        {
            Caption = 'Starting Date';
            Editable = false;
            FieldClass = Normal;
            DataClassification = CustomerContent;
        }
        field(18; "Ending Date"; Date)
        {
            Caption = 'Closing Date';
            Editable = false;
            FieldClass = Normal;
            DataClassification = CustomerContent;
        }
        field(43; "Units per Parcel"; Decimal)
        {
            Caption = 'Units per Parcel';
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.41';
            MinValue = 0;
            DataClassification = CustomerContent;
        }
        field(110; "Discount %"; Decimal)
        {
            Caption = 'Discount %';
            MaxValue = 100;
            MinValue = 0;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if (("Unit Price" > 0) and ("Campaign Unit Price" > 0)) then begin
                    "Discount Amount" := Round("Unit Price" - "Campaign Unit Price");
                end;
            end;
        }
        field(111; "Discount Amount"; Decimal)
        {
            Caption = 'Discount Amount';
            MaxValue = 9999999;
            MinValue = 0;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if (("Unit Price" > 0) and ("Campaign Unit Price" > 0)) then begin
                    "Discount %" := Round(("Unit Price" - "Campaign Unit Price") / "Unit Price" * 100);
                end;
            end;
        }
        field(112; "Unit Price Incl. VAT"; Boolean)
        {
            CalcFormula = Lookup(Item."Price Includes VAT" WHERE("No." = FIELD("Item No.")));
            Caption = 'Price Includes VAT';
            Editable = false;
            FieldClass = FlowField;
        }
        field(113; "Campaign Unit Cost"; Decimal)
        {
            Caption = 'Period Cost';
            DataClassification = CustomerContent;
        }
        field(114; Profit; Decimal)
        {
            Caption = 'Revenue %';
            DataClassification = CustomerContent;
        }
        field(120; Comment; Boolean)
        {
            Caption = 'Comment';
            Editable = false;
            FieldClass = Normal;
            DataClassification = CustomerContent;
        }
        field(121; "Unit Cost"; Decimal)
        {
            Caption = 'Period purchase price';
            DataClassification = CustomerContent;
        }
        field(122; "Unit Purchase Price"; Decimal)
        {
            Caption = 'Unit Purchase Price';
            DataClassification = CustomerContent;
        }
        field(124; "Distribution Item"; Boolean)
        {
            Caption = 'Distributionitem';
            DataClassification = CustomerContent;
        }
        field(125; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            TableRelation = Vendor."No.";
            DataClassification = CustomerContent;
        }
        field(126; "Vendor Item No."; Code[20])
        {
            Caption = 'Vendor Item No.';
            DataClassification = CustomerContent;
        }
        field(127; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
            DataClassification = CustomerContent;
        }
        field(128; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
            DataClassification = CustomerContent;
        }
        field(130; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(131; "Global Dimension 1 Filter"; Code[20])
        {
            Caption = 'Global Dimension 1 Filter';
            FieldClass = FlowFilter;
        }
        field(132; "Global Dimension 2 Filter"; Code[20])
        {
            Caption = 'Global Dimension 2 Filter';
            FieldClass = FlowFilter;
        }
        field(133; "Location Filter"; Code[10])
        {
            Caption = 'Location Filter';
            FieldClass = FlowFilter;
        }
        field(135; "Starting Time"; Time)
        {
            Caption = 'Starting Time';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(136; "Ending Time"; Time)
        {
            Caption = 'Closing Time';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(1101; Inventory; Decimal)
        {
            CalcFormula = Sum("Item Ledger Entry".Quantity WHERE("Item No." = FIELD("Item No."),
                                                                  "Posting Date" = FIELD("Date Filter"),
                                                                  "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                  "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                  "Location Code" = FIELD("Location Filter")));
            Caption = 'Inventory Quantity';
            FieldClass = FlowField;
        }
        field(1102; "Quantity On Purchase Order"; Decimal)
        {
            CalcFormula = Sum("Purchase Line"."Outstanding Qty. (Base)" WHERE("Document Type" = CONST(Order),
                                                                               Type = CONST(Item),
                                                                               "No." = FIELD("Item No."),
                                                                               "Order Date" = FIELD("Date Filter"),
                                                                               "Shortcut Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                               "Shortcut Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                               "Location Code" = FIELD("Location Filter")));
            Caption = 'Quantity in Purchase Order';
            FieldClass = FlowField;
        }
        field(1200; "Quantity Sold"; Decimal)
        {
            Caption = 'Sold Quantity';
            FieldClass = Normal;
            DataClassification = CustomerContent;
        }
        field(1201; Turnover; Decimal)
        {
            Caption = 'Turnover';
            FieldClass = Normal;
            DataClassification = CustomerContent;
        }
        field(1202; "Internet Special Id"; Integer)
        {
            AutoIncrement = true;
            Caption = 'Internet Special ID';
            DataClassification = CustomerContent;
        }
        field(1203; "Campaign Profit"; Decimal)
        {
            Caption = 'Campaign Profit';
            DataClassification = CustomerContent;
        }
        field(1210; "Cross-Reference No."; Code[20])
        {
            Caption = 'Cross-Reference No.';
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
            end;
        }
        field(2310; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
            InitValue = 1;
            MinValue = 0;
            DataClassification = CustomerContent;
        }
        field(2313; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
            DataClassification = CustomerContent;
        }
        field(2321; "Disc. Grouping Type"; Enum "NPR Disc. Grouping Type")
        {
            Caption = 'Disc. Grouping Type';
            DataClassification = CustomerContent;
        }
        field(2330; Priority; Integer)
        {
            Caption = 'Priority';
            DataClassification = CustomerContent;
        }
        field(4200; "Item Group"; Boolean)
        {
            Caption = 'Item Group';
            DataClassification = CustomerContent;
        }
        field(5215; "Page no. in advert"; Integer)
        {
            Caption = 'Page no. in advert';
            DataClassification = CustomerContent;
        }
        field(5217; "Priority 2"; Code[10])
        {
            Caption = 'Priority 2';
            DataClassification = CustomerContent;
        }
        field(5220; Photo; Boolean)
        {
            Caption = 'Photo';
            DataClassification = CustomerContent;
        }
        field(5500; "Comment 2"; Text[50])
        {
            Caption = 'Comments';
            DataClassification = CustomerContent;
        }
        field(7017; "Mix Discount Type"; Option)
        {
            Caption = 'Discount Type';
            OptionCaption = ',Total Amount per Min. Qty.,Total Discount %,Total Discount Amt. per Min. Qty.,Priority Discount per Min. Qty,Multiple Discount Levels';
            OptionMembers = ,"Total Amount per Min. Qty.","Total Discount %","Total Discount Amt. per Min. Qty.","Priority Discount per Min. Qty","Multiple Discount Levels";
            DataClassification = CustomerContent;
        }
        field(7018; "Total Discount %"; Decimal)
        {
            Caption = 'Total Discount %';
            DataClassification = CustomerContent;
        }
        field(7020; "Max. Quantity"; Decimal)
        {
            BlankZero = true;
            Caption = 'Max. Quantity';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
        }
        field(7025; "Total Discount Amount"; Decimal)
        {
            Caption = 'Total Discount Amount';
            DataClassification = CustomerContent;
        }
        field(7030; "Item Discount Qty."; Decimal)
        {
            Caption = 'Item Discount Quantity';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
        }
        field(7035; "Item Discount %"; Decimal)
        {
            Caption = 'Item Discount %';
            DataClassification = CustomerContent;
        }
        field(7100; "Mix Type"; Option)
        {
            Caption = 'Mix Type';
            OptionCaption = ',Standard,Combination,Combination Part';
            OptionMembers = ,Standard,Combination,"Combination Part";
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Retail Campaign Code", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
    end;

    trigger OnInsert()
    begin
    end;

    trigger OnRename()
    begin
    end;


    procedure CreateDiscountItems(RetailCampaignHeader: Record "NPR Retail Campaign Header")
    var
        Item: Record Item;
        RetailCampaignLine: Record "NPR Retail Campaign Line";
        PeriodDiscount: Record "NPR Period Discount";
        PeriodDiscountLine: Record "NPR Period Discount Line";
        MixedDiscount: Record "NPR Mixed Discount";
        MixedDiscountLine: Record "NPR Mixed Discount Line";
        RetailComment: Record "NPR Retail Comment";
        LineNo: Integer;
        PurchPriceCalcMgt: Codeunit "Purch. Price Calc. Mgt.";
        RequisitionLine: Record "Requisition Line";
    begin
        DeleteAll;
        LineNo := 0;
        RetailCampaignLine.SetRange("Campaign Code", RetailCampaignHeader.Code);
        if RetailCampaignLine.FindSet() then begin
            repeat
                case RetailCampaignLine.Type of
                    RetailCampaignLine.Type::"Period Discount":
                        begin
                            PeriodDiscountLine.SetRange(Code, RetailCampaignLine.Code);
                            if PeriodDiscountLine.FindSet() then begin
                                PeriodDiscount.Get(PeriodDiscountLine.Code);
                                repeat
                                    Clear(Rec);
                                    "Retail Campaign Code" := RetailCampaignHeader.Code;
                                    LineNo += 10000;
                                    "Line No." := LineNo;
                                    "Disc. Type" := "Disc. Type"::Periodic;
                                    "Item No." := PeriodDiscountLine."Item No.";
                                    "Disc. Code" := PeriodDiscountLine.Code;
                                    "Starting Date" := PeriodDiscount."Starting Date";
                                    "Ending Date" := PeriodDiscount."Ending Date";
                                    Status := PeriodDiscount.Status;
                                    "Discount %" := PeriodDiscountLine."Discount %";
                                    "Discount Amount" := PeriodDiscountLine."Discount Amount";
                                    "Campaign Unit Cost" := PeriodDiscountLine."Campaign Unit Cost";
                                    "Unit Cost" := PeriodDiscountLine."Unit Cost Purchase";
                                    "Vendor No." := PeriodDiscountLine."Vendor No.";
                                    "Vendor Item No." := PeriodDiscountLine."Vendor Item No.";
                                    "Variant Code" := PeriodDiscountLine."Variant Code";
                                    "Starting Time" := PeriodDiscountLine."Starting Time";
                                    "Ending Time" := PeriodDiscountLine."Ending Time";
                                    if Item.Get("Item No.") then begin
                                        "Unit Cost" := Item."Unit Cost";
                                        "Vendor Item No." := Item."Vendor Item No.";
                                        "Vendor No." := Item."Vendor No.";
                                        "Units per Parcel" := Item."Units per Parcel";

                                        if not Item.Blocked then begin
                                            Clear(RequisitionLine);
                                            RequisitionLine.Init();
                                            RequisitionLine.Validate(Type, RequisitionLine.Type::Item);
                                            RequisitionLine.Validate("No.", Item."No.");
                                            RequisitionLine.Validate("Unit of Measure Code", Item."Base Unit of Measure");
                                            RequisitionLine.Validate("Order Date", Today);
                                            RequisitionLine.Validate("Vendor No.", Item."Vendor No.");
                                            PurchPriceCalcMgt.FindReqLinePrice(RequisitionLine, 0);
                                            "Unit Purchase Price" := RequisitionLine."Direct Unit Cost";
                                        end;

                                        if "Unit Purchase Price" = 0 then
                                            "Unit Purchase Price" := Item."Last Direct Cost";
                                    end;

                                    "Priority 2" := PeriodDiscountLine.Priority;
                                    "Unit Price" := PeriodDiscountLine."Unit Price";
                                    "Campaign Unit Price" := PeriodDiscountLine."Campaign Unit Price";
                                    RetailComment.SetRange("Table ID", 6014414);
                                    RetailComment.SetRange("No.", PeriodDiscountLine.Code);
                                    RetailComment.SetRange("No. 2", PeriodDiscountLine."Item No.");
                                    if RetailComment.FindFirst() then
                                        "Comment 2" := CopyStr(RetailComment.Comment, 1, 50);
                                    CalcProfit;
                                    "Quantity Sold" := GetQuantitySold;
                                    if Insert then;
                                until PeriodDiscountLine.Next() = 0;
                            end;
                        end;
                    RetailCampaignLine.Type::"Mixed Discount":
                        begin
                            MixedDiscountLine.SetRange(Code, RetailCampaignLine.Code);
                            MixedDiscountLine.SetRange("Disc. Grouping Type", MixedDiscountLine."Disc. Grouping Type"::Item);
                            if MixedDiscountLine.FindSet() then begin
                                repeat
                                    Clear(Rec);
                                    MixedDiscount.Get(MixedDiscountLine.Code);
                                    "Retail Campaign Code" := RetailCampaignHeader.Code;
                                    LineNo += 10000;
                                    "Line No." := LineNo;
                                    "Disc. Type" := "Disc. Type"::Mix;
                                    "Item No." := MixedDiscountLine."No.";
                                    "Disc. Code" := MixedDiscountLine.Code;
                                    "Starting Date" := MixedDiscount."Starting date";
                                    "Ending Date" := MixedDiscount."Ending date";
                                    Status := MixedDiscount.Status;
                                    "Discount %" := 0;
                                    "Campaign Unit Cost" := 0;
                                    "Variant Code" := MixedDiscountLine."Variant Code";
                                    "Starting Time" := 0T;
                                    "Ending Time" := 0T;
                                    "Unit Price" := MixedDiscountLine."Unit price";
                                    "Unit Cost" := MixedDiscountLine."Unit cost";
                                    if Item.Get("Item No.") then begin
                                        "Unit Cost" := Item."Unit Cost";
                                        "Vendor Item No." := Item."Vendor Item No.";
                                        "Vendor No." := Item."Vendor No.";
                                        "Units per Parcel" := Item."Units per Parcel";
                                        if not Item.Blocked then begin
                                            Clear(RequisitionLine);
                                            RequisitionLine.Init();
                                            RequisitionLine.Validate(Type, RequisitionLine.Type::Item);
                                            RequisitionLine.Validate("No.", Item."No.");
                                            RequisitionLine.Validate("Unit of Measure Code", Item."Base Unit of Measure");
                                            RequisitionLine.Validate("Order Date", Today);
                                            RequisitionLine.Validate("Vendor No.", Item."Vendor No.");
                                            PurchPriceCalcMgt.FindReqLinePrice(RequisitionLine, 0);
                                            "Unit Purchase Price" := RequisitionLine."Direct Unit Cost";
                                        end;
                                        if "Unit Purchase Price" = 0 then
                                            "Unit Purchase Price" := Item."Last Direct Cost";
                                    end;

                                    "Page no. in advert" := 0;
                                    "Priority 2" := '';
                                    Photo := false;
                                    "Mix Discount Type" := MixedDiscount."Discount Type".AsInteger() + 1;
                                    "Total Discount %" := MixedDiscount."Total Discount %";
                                    "Max. Quantity" := MixedDiscount."Max. Quantity";
                                    "Total Discount Amount" := MixedDiscount."Total Discount Amount";
                                    "Item Discount Qty." := MixedDiscount."Item Discount Qty.";
                                    "Item Discount %" := MixedDiscount."Item Discount %";
                                    "Mix Type" := MixedDiscount."Mix Type" + 1;
                                    "Quantity Sold" := GetQuantitySold;
                                    if Insert then;
                                until MixedDiscountLine.Next() = 0;
                            end;
                        end;
                end;
            until RetailCampaignLine.Next() = 0;
        end;
    end;

    local procedure CalcProfit()
    var
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        Handled: Boolean;
        VATPct: Decimal;
    begin
        if Item.Get("Item No.") then begin
            VATPct := 0;
            if VATPostingSetup.Get(Item."VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group") then begin
                POSSaleTaxCalc.OnGetVATPostingSetup(VATPostingSetup, Handled);
                VATPct := VATPostingSetup."VAT %";
            end;

            if ((VATPct > 0) and (Item."Price Includes VAT")) then begin
                if (("Campaign Unit Price" > 0) and ("Campaign Unit Cost" > 0)) then begin
                    Profit := Round(((("Campaign Unit Price" / (1 + VATPct / 100)) / "Campaign Unit Cost") * 100) - 100, 0.001);
                    "Campaign Profit" := Round(("Campaign Unit Price" / (1 + VATPct / 100)) - "Campaign Unit Cost", 0.001);
                end else
                    if (("Campaign Unit Price" > 0) and ("Unit Cost" > 0)) then begin
                        Profit := Round(((("Campaign Unit Price" / (1 + VATPct / 100)) / "Unit Cost") * 100) - 100, 0.001);
                        "Campaign Profit" := Round(("Campaign Unit Price" / (1 + VATPct / 100)) - "Unit Cost", 0.001);
                    end else
                        if (("Unit Price" > 0) and ("Unit Cost" > 0)) then begin
                            "Campaign Profit" := Round(((("Unit Price" / (1 + VATPct / 100)) / "Unit Cost") * 100) - 100, 0.001);
                            Profit := Round(("Unit Price" / (1 + VATPct / 100)) - "Unit Cost", 0.001);
                        end else begin
                            "Campaign Profit" := 0;
                            Profit := 0;
                        end;
            end else begin
                if (("Campaign Unit Price" > 0) and ("Campaign Unit Cost" > 0)) then begin
                    Profit := Round((("Campaign Unit Price" / "Campaign Unit Cost") * 100) - 100, 0.001);
                    "Campaign Profit" := Round("Campaign Unit Price" - "Campaign Unit Cost", 0.001);
                end else
                    if (("Campaign Unit Price" > 0) and ("Unit Cost" > 0)) then begin
                        Profit := Round((("Unit Cost" / "Campaign Unit Price") * 100) - 100, 0.001);
                        "Campaign Profit" := Round("Campaign Unit Price" - "Unit Cost", 0.001);
                    end else
                        if (("Unit Price" > 0) and ("Unit Cost" > 0)) then begin
                            "Campaign Profit" := Round((("Unit Price" / "Unit Cost") * 100) - 100, 0.001);
                            Profit := Round("Unit Price" - "Unit Cost", 0.001);
                        end else begin
                            "Campaign Profit" := 0;
                            Profit := 0;
                        end;
            end;
        end;
    end;

    local procedure GetQuantitySold() QuantitySold: Decimal
    var
        AuxItemLedgerEntry: Record "NPR Aux. Item Ledger Entry";
    begin
        AuxItemLedgerEntry.SetRange("Item No.", "Item No.");
        AuxItemLedgerEntry.SetFilter("Document Date", '%1..%2', "Starting Date", "Ending Date");
        AuxItemLedgerEntry.SetFilter(Quantity, '<0');
        case "Disc. Type" of
            "Disc. Type"::Periodic:
                AuxItemLedgerEntry.SetRange("Discount Type", AuxItemLedgerEntry."Discount Type"::Period);
            "Disc. Type"::Mix:
                AuxItemLedgerEntry.SetRange("Discount Type", AuxItemLedgerEntry."Discount Type"::Mixed);
            else
                exit;
        end;
        AuxItemLedgerEntry.SetRange("Discount Code", "Disc. Code");
        AuxItemLedgerEntry.SetRange("Variant Code", "Variant Code");

        AuxItemLedgerEntry.CalcSums(Quantity);

        QuantitySold := -AuxItemLedgerEntry.Quantity;
    end;
}

