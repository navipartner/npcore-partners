table 6060000 "NPR RS Nivelation Lines"
{
    DataClassification = CustomerContent;
    Caption = 'Nivelation Document Subform';
    Access = Internal;

    fields
    {
        field(1; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR RS Nivelation Header"."No.";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(3; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
            trigger OnValidate()
            begin
                SetItemFields();
            end;
        }
        field(4; "Item Description"; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(5; "Variant Code"; Code[20])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Variant".Code where("Item No." = field("Item No."));
            trigger OnValidate()
            begin
                Validate("Item No.");
            end;
        }
        field(6; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location;
            trigger OnValidate()
            begin
                SetOldPriceFromPriceList();
                CalcDifference();
                SetQuantityFromLedger();
            end;
        }
        field(7; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            trigger OnValidate()
            begin
                CalcDifference();
            end;
        }
        field(8; "UOM Code"; Code[20])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = CustomerContent;
        }
        field(9; "Old Price"; Decimal)
        {
            Caption = 'Old Price';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                CalcDifference();
            end;
        }
        field(10; "New Price"; Decimal)
        {
            Caption = 'New Price';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                CalcDifference();
            end;
        }
        field(11; "Price Difference"; Decimal)
        {
            Caption = 'Price Difference';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(12; "Old Value"; Decimal)
        {
            Caption = 'Old Value';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(13; "New Value"; Decimal)
        {
            Caption = 'New Value';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(14; "VAT %"; Decimal)
        {
            Caption = 'VAT %';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(15; "Calculated VAT"; Decimal)
        {
            Caption = 'Calculated VAT';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(16; "Value Difference"; Decimal)
        {
            Caption = 'Value Difference';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(17; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                SetQuantityFromLedger();
            end;
        }
        field(18; "VAT Bus. Posting Gr. (Price)"; Code[20])
        {
            Caption = 'VAT Bus. Posting Gr. (Price)';
            DataClassification = CustomerContent;
        }
        field(19; "Price Valid Date"; Date)
        {
            Caption = 'Price Valid Date';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Document No.", "Line No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        GetDataFromNivelationHeader();
    end;

    local procedure SetItemFields()
    var
        Item: Record Item;
    begin
        if not Item.Get("Item No.") then
            exit;
        "Item Description" := Item.Description;
        "UOM Code" := Item."Base Unit of Measure";
        SetVATPercentage(Item);

        if "Location Code" = '' then
            exit;

        SetOldPriceFromPriceList();
        SetQuantityFromLedger();
    end;

    internal procedure GetDataFromNivelationHeader()
    var
        NivelationHeader: Record "NPR RS Nivelation Header";
    begin
        NivelationHeader.SetRange("No.", "Document No.");
        if not NivelationHeader.FindFirst() then
            exit;
        if NivelationHeader.Type in ["NPR RS Nivelation Type"::"Promotions & Discounts"] then
            exit;
        if NivelationHeader."Location Code" <> '' then
            "Location Code" := NivelationHeader."Location Code";
        if NivelationHeader."Posting Date" <> 0D then
            "Posting Date" := NivelationHeader."Posting Date";
        if NivelationHeader."Price Valid Date" <> 0D then
            "Price Valid Date" := NivelationHeader."Price Valid Date";
    end;

    local procedure SetOldPriceFromPriceList()
    var
        NivelationHeader: Record "NPR RS Nivelation Header";
        PriceListLine: Record "Price List Line";
        EndingDateFilter: Label '>=%1|''''', Comment = '%1 = Ending Date', Locked = true;
        StartingDateFilter: Label '<=%1', Comment = '%1 = Starting Date', Locked = true;
    begin
        NivelationHeader.SetRange("No.", "Document No.");
        if not NivelationHeader.FindFirst() then
            exit;
        if NivelationHeader.Type in ["NPR RS Nivelation Type"::"Promotions & Discounts"] then
            exit;
        PriceListLine.SetRange("Price List Code", NivelationHeader."Price List Code");
        PriceListLine.SetRange("Asset No.", "Item No.");
        PriceListLine.SetFilter("Starting Date", StrSubstNo(StartingDateFilter, "Price Valid Date"));
        PriceListLine.SetFilter("Ending Date", StrSubstNo(EndingDateFilter, "Price Valid Date"));
        if not PriceListLine.FindFirst() then
            Validate("Old Price", 0)
        else
            Validate("Old Price", PriceListLine."Unit Price");
    end;

    local procedure SetQuantityFromLedger()
    var
        NivelationHeader: Record "NPR RS Nivelation Header";
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        NivelationHeader.SetRange("No.", "Document No.");
        if not NivelationHeader.FindFirst() then
            exit;
        if NivelationHeader.Type in ["NPR RS Nivelation Type"::"Promotions & Discounts"] then
            exit;
        ItemLedgerEntry.SetCurrentKey("Item No.", "Posting Date");
        ItemLedgerEntry.SetLoadFields("Item No.", "Posting Date", "Location Code", Quantity);
        ItemLedgerEntry.SetRange("Location Code", NivelationHeader."Location Code");
        ItemLedgerEntry.SetRange("Item No.", "Item No.");
        ItemLedgerEntry.SetFilter("Posting Date", '..%1', CalcDate('<-1D>', "Posting Date"));
        ItemLedgerEntry.CalcSums(Quantity);
        Validate(Quantity, ItemLedgerEntry.Quantity);
    end;

    local procedure SetVATPercentage(var Item: Record Item)
    var
        NivelationHeader: Record "NPR RS Nivelation Header";
        VATSetup: Record "VAT Posting Setup";
        PriceListHeader: Record "Price List Header";
        VATSetupNotFoundErr: Label '%1 for %2 - %3, %4 - %5 has not been found.', Comment = '%1 = VAT Setup Table Caption, %2 = VAT Bus. Posting Gr (Price) Field Caption, %3 = VAT Bus. Posting Gr. (Price), %4 = VAT Prod. Posting Group Field Caption, %5 = VAT Prod. Posting Group';
    begin
        NivelationHeader.SetRange("No.", "Document No.");
        if not NivelationHeader.FindFirst() then
            exit;
        case NivelationHeader.Type of
            "NPR RS Nivelation Type"::"Price Change":
                begin
                    if not PriceListHeader.Get(NivelationHeader."Price List Code") then
                        exit;
                    if not VATSetup.Get(PriceListHeader."VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group") then
                        Error(VATSetupNotFoundErr, VATSetup.TableCaption(), PriceListHeader.FieldCaption("VAT Bus. Posting Gr. (Price)"), PriceListHeader."VAT Bus. Posting Gr. (Price)", Item.FieldCaption("VAT Prod. Posting Group"), Item."VAT Prod. Posting Group");
                end;
            "NPR RS Nivelation Type"::"Promotions & Discounts":
                if not VATSetup.Get("VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group") then
                    Error(VATSetupNotFoundErr, VATSetup.TableCaption(), FieldCaption("VAT Bus. Posting Gr. (Price)"), "VAT Bus. Posting Gr. (Price)", Item.FieldCaption("VAT Prod. Posting Group"), Item."VAT Prod. Posting Group");
        end;
        "VAT %" := VATSetup."VAT %";
    end;

    local procedure CalcDifference()
    begin
        ResetValues();
        if (Quantity = 0) then
            exit;
        "Old Value" := "Old Price" * Quantity;
        "New Value" := "New Price" * Quantity;
        "Price Difference" := "New Price" - "Old Price";
        "Value Difference" := "Price Difference" * Quantity;
        "Calculated VAT" := "Value Difference" * ((100 * "VAT %") / (100 + "VAT %") / 100);
    end;

    local procedure ResetValues()
    begin
        Clear("New Value");
        Clear("Old Value");
        Clear("Price Difference");
        Clear("Value Difference");
        Clear("Calculated VAT");
    end;

    procedure GetInitialLine(): Integer
    var
        FindRecordManagement: Codeunit "Find Record Management";
    begin
        exit(FindRecordManagement.GetLastEntryIntFieldValue(Rec, FieldNo("Line No.")))
    end;
}