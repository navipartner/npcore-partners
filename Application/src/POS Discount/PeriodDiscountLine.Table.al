table 6014414 "NPR Period Discount Line"
{
    Caption = 'Period Discount Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            Editable = false;
            NotBlank = true;
            TableRelation = "NPR Period Discount".Code;
            DataClassification = CustomerContent;
        }
        field(2; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            NotBlank = true;
            TableRelation = Item."No.";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CalcFields(Description, "Unit Price");

                Item.Get("Item No.");
                "Vendor No." := Item."Vendor No.";
                "Vendor Item No." := Item."Vendor Item No.";
            end;
        }
        field(3; Description; Text[100])
        {
            CalcFormula = Lookup(Item.Description WHERE("No." = FIELD("Item No.")));
            Caption = 'Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(4; "Unit Price"; Decimal)
        {
            CalcFormula = Lookup(Item."Unit Price" WHERE("No." = FIELD("Item No.")));
            Caption = 'Unit Price';
            Editable = false;
            FieldClass = FlowField;
            MaxValue = 9999999;
            MinValue = 0;

            trigger OnValidate()
            begin
                Validate("Campaign Unit Cost");
            end;
        }
        field(5; "Campaign Unit Price"; Decimal)
        {
            Caption = 'Period Price';
            MaxValue = 9999999;
            MinValue = 0;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CalcFields("Unit Price");
                if "Unit Price" <> 0 then begin
                    "Discount Amount" := Round("Unit Price" - "Campaign Unit Price");
                    "Discount %" := Round(("Unit Price" - "Campaign Unit Price") / "Unit Price" * 100);
                end;
                Validate("Campaign Unit Cost");
            end;
        }
        field(6; Status; Option)
        {
            Caption = 'Status';
            Description = 'NPR5.38';
            Editable = false;
            OptionCaption = 'Await,Active,Closed';
            OptionMembers = Await,Active,Closed;
            DataClassification = CustomerContent;
        }
        field(7; "Starting Date"; Date)
        {
            Caption = 'Starting Date';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(8; "Ending Date"; Date)
        {
            Caption = 'Closing Date';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(10; "Discount %"; Decimal)
        {
            Caption = 'Discount %';
            MaxValue = 100;
            MinValue = 0;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CalcFields("Unit Price");
                "Campaign Unit Price" := Round("Unit Price" * ((100 - "Discount %") / 100));
                if "Unit Price" < "Campaign Unit Price" then Error(Text1060003);
                "Discount Amount" := Round("Unit Price" - "Campaign Unit Price");
            end;
        }
        field(11; "Discount Amount"; Decimal)
        {
            Caption = 'Discount Amount';
            MaxValue = 9999999;
            MinValue = 0;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CalcFields("Unit Price");
                "Campaign Unit Price" := Round("Unit Price" - "Discount Amount");
                if "Unit Price" < "Campaign Unit Price" then Error(Text1060003);
                if "Unit Price" <> 0 then
                    "Discount %" := Round(("Unit Price" - "Campaign Unit Price") / "Unit Price" * 100);
            end;
        }
        field(12; "Unit Price Incl. VAT"; Boolean)
        {
            CalcFormula = Lookup(Item."Price Includes VAT" WHERE("No." = FIELD("Item No.")));
            Caption = 'Price Includes VAT';
            Editable = false;
            FieldClass = FlowField;
        }
        field(13; "Campaign Unit Cost"; Decimal)
        {
            Caption = 'Period Cost';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                ItemCategory: Record "Item Category";
                POSTaxCalculation: Codeunit "NPR POS Tax Calculation";
                Handled: Boolean;
                UnitCost: Decimal;
            begin

                if Item.Get("Item No.") then begin
                    ItemCategory.Get(Item."Item Category Code");
                    if Item."Price Includes VAT" then begin
                        if VATPostingSetup.Get(ItemCategory."NPR VAT Bus. Posting Group", ItemCategory."NPR VAT Prod. Posting Group") then begin
                            POSTaxCalculation.OnGetVATPostingSetup(VATPostingSetup, Handled);
                            VATPct := VATPostingSetup."VAT %";
                        end;
                    end else
                        VATPct := 0;

                    if "Campaign Unit Cost" <> 0 then
                        UnitCost := "Campaign Unit Cost" * (1 + (VATPct / 100))
                    else
                        UnitCost := Item."Unit Cost" * (1 + (VATPct / 100));
                    Profit := Round("Campaign Unit Price" - UnitCost, 0.001);
                    "Campaign Profit" := 0;
                    if ("Campaign Unit Price" <> 0) and (UnitCost <> 0) then begin
                        "Campaign Profit" := Round((1 - UnitCost / "Campaign Unit Price") * 100, 0.001);
                    end;
                end;
            end;
        }
        field(14; Profit; Decimal)
        {
            Caption = 'Revenue %';
            DataClassification = CustomerContent;
        }
        field(20; Comment; Boolean)
        {
            CalcFormula = Exist("NPR Retail Comment" WHERE("Table ID" = CONST(6014414),
                                                        "No." = FIELD(Code),
                                                        "No. 2" = FIELD("Item No.")));
            Caption = 'Comment';
            Editable = false;
            FieldClass = FlowField;
        }
        field(21; "Unit Cost Purchase"; Decimal)
        {
            Caption = 'Period purchase price';
            DataClassification = CustomerContent;
        }
        field(24; "Distribution Item"; Boolean)
        {
            Caption = 'Distributionitem';
            DataClassification = CustomerContent;
        }
        field(25; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            TableRelation = Vendor."No.";
            DataClassification = CustomerContent;
        }
        field(26; "Vendor Item No."; Code[20])
        {
            Caption = 'Vendor Item No.';
            DataClassification = CustomerContent;
        }
        field(27; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
            DataClassification = CustomerContent;
        }
        field(28; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
            DataClassification = CustomerContent;
        }
        field(30; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(31; "Global Dimension 1 Filter"; Code[20])
        {
            Caption = 'Global Dimension 1 Filter';
            FieldClass = FlowFilter;
        }
        field(32; "Global Dimension 2 Filter"; Code[20])
        {
            Caption = 'Global Dimension 2 Filter';
            FieldClass = FlowFilter;
        }
        field(33; "Location Filter"; Code[10])
        {
            Caption = 'Location Filter';
            FieldClass = FlowFilter;
        }
        field(35; "Starting Time"; Time)
        {
            Caption = 'Starting Date';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(36; "Ending Time"; Time)
        {
            Caption = 'Closing Date';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(101; Inventory; Decimal)
        {
            CalcFormula = Sum("Item Ledger Entry".Quantity WHERE("Item No." = FIELD("Item No."),
                                                                  "Posting Date" = FIELD("Date Filter"),
                                                                  "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                  "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                  "Location Code" = FIELD("Location Filter")));
            Caption = 'Inventory Quantity';
            Editable = false;
            FieldClass = FlowField;
        }
        field(102; "Quantity On Purchase Order"; Decimal)
        {
            CalcFormula = Sum("Purchase Line"."Outstanding Qty. (Base)" WHERE("Document Type" = CONST(Order),
                                                                               Type = CONST(Item),
                                                                               "No." = FIELD("Item No."),
                                                                               "Order Date" = FIELD("Date Filter"),
                                                                               "Shortcut Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                               "Shortcut Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                               "Location Code" = FIELD("Location Filter")));
            Caption = 'Quantity in Purchase Order';
            Editable = false;
            FieldClass = FlowField;
        }
        field(200; "Quantity Sold"; Decimal)
        {
            CalcFormula = - Sum("NPR Aux. Item Ledger Entry".Quantity
                                WHERE(
                                    "Item No." = FIELD("Item No."),
                                    "Discount Type" = CONST(Period),
                                    "Discount Code" = FIELD(Code),
                                    "Entry Type" = CONST(Sale),
                                    "Posting Date" = FIELD("Date Filter"),
                                    "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                    "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                    "Location Code" = FIELD("Location Filter")));
            Caption = 'Sold Quantity';
            Editable = false;
            FieldClass = FlowField;
        }
        field(201; Turnover; Decimal)
        {
            CalcFormula = Sum("NPR Aux. Value Entry"."Sales Amount (Actual)"
                            WHERE(
                                "Item No." = FIELD("Item No."),
                                "Discount Type" = CONST(Period),
                                "Discount Code" = FIELD(Code),
                                "Item Ledger Entry Type" = CONST(Sale),
                                "Posting Date" = FIELD("Date Filter"),
                                "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                "Location Code" = FIELD("Location Filter")));
            Caption = 'Turnover';
            Editable = false;
            FieldClass = FlowField;
        }
        field(202; "Internet Special Id"; Integer)
        {
            AutoIncrement = true;
            Caption = 'Internet Special ID';
            DataClassification = CustomerContent;
        }
        field(203; "Campaign Profit"; Decimal)
        {
            Caption = 'Campaign Profit';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                GLSetup: Record "General Ledger Setup";
                ItemCategory: Record "Item Category";
                POSTaxCalculation: Codeunit "NPR POS Tax Calculation";
                Handled: Boolean;
                UnitCost: Decimal;
            begin
                if ("Campaign Profit" < 100) and Item.Get("Item No.") then begin
                    GLSetup.Get();
                    ItemCategory.Get(Item."Item Category Code");
                    if Item."Price Includes VAT" then begin
                        if VATPostingSetup.Get(ItemCategory."NPR VAT Bus. Posting Group", ItemCategory."NPR VAT Prod. Posting Group") then begin
                            POSTaxCalculation.OnGetVATPostingSetup(VATPostingSetup, Handled);
                            VATPct := VATPostingSetup."VAT %";
                        end;
                    end else
                        VATPct := 0;

                    if "Campaign Unit Cost" <> 0 then
                        UnitCost := "Campaign Unit Cost"
                    else
                        UnitCost := Item."Unit Cost";
                    "Campaign Unit Price" := Round((UnitCost / (1 - "Campaign Profit" / 100)) * (1 + VATPct / 100),
                                                   GLSetup."Unit-Amount Rounding Precision");
                end;
            end;
        }
        field(210; "Cross-Reference No."; Code[50])
        {
            Caption = 'Reference No.';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                BarcodeLibrary: Codeunit "NPR Barcode Lookup Mgt.";
            begin
                BarcodeLibrary.CallItemRefNoLookupPeriodicDiscount(Rec);
            end;
        }
        field(215; "Page no. in advert"; Integer)
        {
            Caption = 'Page no. in advert';
            Description = 'NPR5.38';
            DataClassification = CustomerContent;
        }
        field(217; Priority; Code[10])
        {
            Caption = 'Priority';
            Description = 'NPR5.38';
            DataClassification = CustomerContent;
        }
        field(219; "Pagenumber in paper"; Text[30])
        {
            Caption = 'Pagenumber in paper';
            Description = 'NPR5.38';
            DataClassification = CustomerContent;
        }
        field(220; Photo; Boolean)
        {
            Caption = 'Photo';
            Description = 'NPR5.38';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code", "Item No.", "Variant Code")
        {
        }
        key(Key2; "Item No.")
        {
        }
        key(Key3; "Last Date Modified")
        {
        }
        key(Key4; "Item No.", "Variant Code", Status, "Starting Date", "Ending Date", "Starting Time", "Ending Time")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        RetailComment: Record "NPR Retail Comment";
    begin
        RetailComment.SetRange("Table ID", 6014414);
        RetailComment.SetRange("No.", Code);
        RetailComment.SetRange("No. 2", "Item No.");
        RetailComment.DeleteAll;
    end;

    trigger OnInsert()
    var
        QtyDiscLine: Record "NPR Quantity Discount Line";
    begin
        QtyDiscLine.SetRange("Item No.", "Item No.");
        if QtyDiscLine.Find('-') then
            Message(Text1060005);

        UpdatePeriodDiscount;

        UpdateLine();
    end;

    trigger OnModify()
    begin
        "Last Date Modified" := Today;

        UpdatePeriodDiscount;

        UpdateLine();
    end;

    trigger OnRename()
    var
        RetailComment: Record "NPR Retail Comment";
        RetailComment2: Record "NPR Retail Comment";
    begin
        UpdatePeriodDiscount;

        RetailComment.SetRange("Table ID", 6014414);
        RetailComment.SetRange("No.", xRec.Code);
        RetailComment.SetRange("No. 2", xRec."Item No.");
        if RetailComment.Find('-') then
            repeat
                RetailComment2.Copy(RetailComment);
                if Code <> xRec.Code then begin
                    RetailComment2.Validate("No.", Code);
                    if not RetailComment2.Insert(true) then
                        RetailComment2.Modify(true);
                end;
                if "Item No." <> xRec."Item No." then begin
                    RetailComment2.Validate("No. 2", "Item No.");
                    if not RetailComment2.Insert(true) then
                        RetailComment2.Modify(true);
                end;
            until RetailComment.Next = 0;
        RetailComment.DeleteAll;

        UpdateLine();
    end;

    var
        Text1060003: Label 'The special offer price exceeds the normal retail price!';
        Item: Record Item;
        Text1060005: Label 'This items includes multi unit prices, which will be controlled by period discounts';
        VATPostingSetup: Record "VAT Posting Setup";
        DG: Decimal;
        VATPct: Decimal;

    procedure UpdatePeriodDiscount()
    var
        PeriodDiscount: Record "NPR Period Discount";
    begin
        if PeriodDiscount.Get(Rec.Code) then begin
            PeriodDiscount."Last Date Modified" := Today;
            PeriodDiscount.Modify;
        end;
    end;

    procedure ShowComment()
    var
        RetailComment: Record "NPR Retail Comment";
    begin
        RetailComment.SetRange("Table ID", 6014414);
        if Code <> '' then
            if "Item No." <> '' then begin
                RetailComment.SetRange("No.", Code);
                RetailComment.SetRange("No. 2", "Item No.");
            end;
    end;

    local procedure UpdateLine()
    var
        PeriodDiscount: Record "NPR Period Discount";
    begin
        if PeriodDiscount.Get(Code) then begin
            "Starting Date" := PeriodDiscount."Starting Date";
            "Ending Date" := PeriodDiscount."Ending Date";
            "Starting Time" := PeriodDiscount."Starting Time";
            "Ending Time" := PeriodDiscount."Ending Time";
            Status := PeriodDiscount.Status;
        end;
    end;
}

