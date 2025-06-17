codeunit 6248233 "NPR Ext. POS Sale Processing"
{
    Access = Internal;


    internal procedure TryAutoFillExternalPOSSale(var ExternalPOSSale: Record "NPR External POS Sale")
    var
        UserSetup: Record "User Setup";
        POSUnit: Record "NPR POS Unit";
        POSStore: Record "NPR POS Store";
        POSPostingProfile: Record "NPR POS Posting Profile";
        MissingUserSetupLbl: Label 'The field "salespersonCode" is empty. Please include the Salesperson code';
    begin
        if (ExternalPOSSale."Salesperson Code" = '') then
            Error(MissingUserSetupLbl);
        if ExternalPOSSale."Register No." = '' then begin
            UserSetup.Get(UserId());
            ExternalPOSSale."Register No." := UserSetup."NPR POS Unit No.";
        end;
        ExternalPOSSale.TestField("Register No.");

        IF ExternalPOSSale.Date = 0D then
            ExternalPOSSale.Date := System.Today();

        IF ExternalPOSSale."Start Time" = 0T then
            ExternalPOSSale."Start Time" := System.Time();

        if ExternalPOSSale."POS Store Code" = '' then begin
            if (POSUnit.Get(ExternalPOSSale."Register No.")) then begin
                ExternalPOSSale."POS Store Code" := POSUnit."POS Store Code";
            end;
        end;

        if (POSStore.Get(ExternalPOSSale."POS Store Code")) then begin
            ExternalPOSSale."Country Code" := POSStore."Country/Region Code";
            ExternalPOSSale."Location Code" := POSStore."Location Code";
            if (POSPostingProfile.Get(POSStore."POS Posting Profile")) then begin
                ExternalPOSSale."Tax Liable" := POSPostingProfile."Tax Liable";
                ExternalPOSSale."Tax Area Code" := POSPostingProfile."Tax Area Code";
                ExternalPOSSale."Gen. Bus. Posting Group" := POSPostingProfile."Gen. Bus. Posting Group";
                ExternalPOSSale."VAT Bus. Posting Group" := POSPostingProfile."VAT Bus. Posting Group";
            end;
        end;
        ExternalPOSSale.Modify();
    end;

    internal procedure TryAutoFillExternalPOSSaleLine(var ExternalPOSSaleLine: Record "NPR External POS Sale Line"; ExternalPOSSale: Record "NPR External POS Sale")
    var
        LineNoInt: Integer;
        LastExtPOSSalesLine: Record "NPR External POS Sale Line";
        POSUnit: Record "NPR POS Unit";
        Currency: Record Currency;
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSStore: Record "NPR POS Store";
        UOMMgt: Codeunit "Unit of Measure Management";
    begin
        ExternalPOSSale.Get(ExternalPOSSaleLine."External POS Sale Entry No.");
        if IsNullGuid(ExternalPOSSaleLine.SystemId) then
            ExternalPOSSaleLine.SystemId := CreateGuid();
        if ((ExternalPOSSaleLine."Register No." = '') and (ExternalPOSSale."Register No." <> '')) then begin
            ExternalPOSSaleLine."Register No." := ExternalPOSSale."Register No."
        end;

        IF ExternalPOSSaleLine."Line No." = 0 then begin
            LineNoInt += 10000;
            LastExtPOSSalesLine.SetRange("External POS Sale Entry No.", ExternalPOSSaleLine."External POS Sale Entry No.");
            IF LastExtPOSSalesLine.FindLast() then
                LineNoInt := LastExtPOSSalesLine."Line No." + 10000;

            ExternalPOSSaleLine."Line No." := LineNoInt;
        end;

        ExternalPOSSaleLine."Price Includes VAT" := ExternalPOSSale."Prices Including VAT";

        if (ExternalPOSSaleLine."Sales Ticket No." = '') then
            ExternalPOSSaleLine."Sales Ticket No." := ExternalPOSSale."Sales Ticket No.";

        case ExternalPOSSaleLine."Line Type" of
            Enum::"NPR POS Sale Line Type"::Item:
                begin
                    if ((ExternalPOSSaleLine."No." = '') and (ExternalPOSSaleLine."Barcode Reference" <> '')) then begin
                        TryFindItemFromBarcode(ExternalPOSSaleLine);
                    end;
                    ExternalPOSSaleLine."Gen. Bus. Posting Group" := ExternalPOSSale."Gen. Bus. Posting Group";
                    if (Item.Get(ExternalPOSSaleLine."No.")) then begin

                        ExternalPOSSaleLine."Gen. Prod. Posting Group" := Item."Gen. Prod. Posting Group";
                        ExternalPOSSaleLine."VAT Bus. Posting Group" := Item."VAT Bus. Posting Gr. (Price)";
                        ExternalPOSSaleLine."VAT Prod. Posting Group" := Item."VAT Prod. Posting Group";
                        VATPostingSetup.Get(ExternalPOSSaleLine."VAT Bus. Posting Group", ExternalPOSSaleLine."VAT Prod. Posting Group");
                        ExternalPOSSaleLine."VAT %" := VATPostingSetup."VAT %";
                        ExternalPOSSaleLine."VAT Identifier" := VATPostingSetup."VAT Identifier";
                        ExternalPOSSaleLine."VAT Calculation Type" := VATPostingSetup."VAT Calculation Type";
                        ExternalPOSSaleLine."Qty. per Unit of Measure" := UOMMgt.GetQtyPerUnitOfMeasure(Item, ExternalPOSSaleLine."Unit of Measure Code");
                        ExternalPOSSaleLine."Quantity (Base)" := Round(ExternalPOSSaleLine.Quantity * ExternalPOSSaleLine."Qty. per Unit of Measure", 0.00001);
                    end;

                    // try calculate discounts if not provided via api call
                    IF (ExternalPOSSaleLine."Discount %" <> 0) AND (ExternalPOSSaleLine."Discount Amount" = 0) then begin
                        ExternalPOSSaleLine.GetCurrency(Currency);
                        ExternalPOSSaleLine."Discount Amount" := Round((ExternalPOSSaleLine.Quantity * ExternalPOSSaleLine."Unit Price") * (ExternalPOSSaleLine."Discount %" / 100), Currency."Amount Rounding Precision");
                    end;
                    IF (ExternalPOSSaleLine."Discount Amount" <> 0) AND (ExternalPOSSaleLine."Discount %" = 0) then begin
                        ExternalPOSSaleLine.GetCurrency(Currency);
                        ExternalPOSSaleLine."Discount %" := Round(ExternalPOSSaleLine."Discount Amount" / (ExternalPOSSaleLine.Quantity * ExternalPOSSaleLine."Unit Price") * 100, Currency."Amount Rounding Precision");
                    end;
                    if (ExternalPOSSaleLine."Location Code" = '') then
                        ExternalPOSSaleLine."Location Code" := ExternalPOSSale."Location Code";
                    if (ExternalPOSSaleLine."VAT Bus. Posting Group" = '') then
                        ExternalPOSSaleLine."VAT Bus. Posting Group" := ExternalPOSSale."VAT Bus. Posting Group";
                    ExternalPOSSaleLine.UpdateVAT();
                end;
            Enum::"NPR POS Sale Line Type"::"POS Payment":
                begin
                    if ((ExternalPOSSaleLine."Amount Including VAT" = 0) and (ExternalPOSSaleLine.Amount <> 0)) then
                        ExternalPOSSaleLine."Amount Including VAT" := ExternalPOSSaleLine.Amount;
                    if ((ExternalPOSSaleLine."Amount Including VAT" <> 0) and (ExternalPOSSaleLine.Amount = 0)) then
                        ExternalPOSSaleLine.Amount := ExternalPOSSaleLine."Amount Including VAT";
                    if (ExternalPOSSaleLine.Quantity = 0) then
                        ExternalPOSSaleLine.Quantity := 1;
                end;
            Enum::"NPR POS Sale Line Type"::Rounding:
                begin
                    ExternalPOSSaleLine.Amount := ExternalPOSSaleLine."Amount Including VAT";
                    //Is always *-1 of Amount Incl VAT in POS.
                    ExternalPOSSaleLine."Unit Price" := ExternalPOSSaleLine."Amount Including VAT" * -1;
                    if (ExternalPOSSaleLine."No." = '') then
                        if (POSUnit.Get(ExternalPOSSale."Register No.")) then
                            if (POSStore.Get(POSUnit."POS Store Code")) then
                                if (POSPostingProfile.Get(POSStore."POS Posting Profile")) then begin
                                    ExternalPOSSaleLine."No." := POSPostingProfile."POS Sales Rounding Account";
                                end


                end;
        end;
        ExternalPOSSaleLine.Modify();
    end;

    [TryFunction]
    internal procedure ValidateExternalPOSData(var ExternalPOSSale: Record "NPR External POS Sale")
    var
        RecordAlreadyConvertedErr: Label 'This record was already converted into a POS Entry.';
    begin
        //Validate Header
        IF ExternalPOSSale."Converted To POS Entry" then
            Error(RecordAlreadyConvertedErr);
        //Validate Lines
        ValidateSaleLinesData(ExternalPOSSale);
        ValidateBalance(ExternalPOSSale);
    end;

    local procedure ValidateSaleLinesData(ExternalPOSSale: Record "NPR External POS Sale")
    var
        ExternalPOSSaleLine: Record "NPR External POS Sale Line";
        NoNumberSpecifiedinSaleLineErrLbl: Label 'There was no ''No.'' specified for one or more sale lines, sale is not valid!';
#IF NOT (BC17 or BC18 or BC19 or BC20)
        InventorySetup: Record "Inventory Setup";
        Item: Record Item;
        ItemVariantMandatoryErrLbl: Label 'Item Variant is mandatory for Item in Line No. %1.', Comment = '%1 = Line No.';
#ENDIF
    begin
        ExternalPOSSaleLine.SetRange("External POS Sale Entry No.", ExternalPOSSale."Entry No.");
        ExternalPOSSaleLine.SetRange("No.", '');
        if (not ExternalPOSSaleLine.IsEmpty()) then
            Error(NoNumberSpecifiedinSaleLineErrLbl);

        // Variant Mandatory if exist
#IF NOT (BC17 or BC18 or BC19 or BC20)
        if InventorySetup.Get() then begin
            if InventorySetup."Variant Mandatory if Exists" then begin
                ExternalPOSSaleLine.Reset();
                ExternalPOSSaleLine.SetRange("External POS Sale Entry No.", ExternalPOSSale."Entry No.");
                ExternalPOSSaleLine.SetRange("Line Type", ExternalPOSSaleLine."Line Type"::Item);
                ExternalPOSSaleLine.SetRange("Variant Code", '');
                if ExternalPOSSaleLine.FindSet() then
                    repeat
                        if Item.Get(ExternalPOSSaleLine."No.") then begin
                            Item.CalcFields("NPR Has Variants");
                            if Item."NPR Has Variants" then
                                Error(ItemVariantMandatoryErrLbl, ExternalPOSSaleLine."Line No.");
                        end;
                    until ExternalPOSSaleLine.Next() = 0;
            end;
        end;
#ENDIF
    end;

    local procedure ValidateBalance(ExternalPOSSale: Record "NPR External POS Sale")
    var
        ExternalPOSSaleLine: Record "NPR External POS Sale Line";
        SaleAmount: Decimal;
        PaidAmount: Decimal;
        RoundingAmount: Decimal;
        SaleBalanceNotValidErrLbl: Label 'The end balance was not correct, can''t convert to POS Entry';
    begin
        ExternalPOSSaleLine.SetRange("External POS Sale Entry No.", ExternalPOSSale."Entry No.");
        ExternalPOSSaleLine.FindSet();
        repeat
            case ExternalPOSSaleLine."Line Type" of
                Enum::"NPR POS Sale Line Type"::"BOM List",
                Enum::"NPR POS Sale Line Type"::"Customer Deposit",
                Enum::"NPR POS Sale Line Type"::"GL Payment",
                Enum::"NPR POS Sale Line Type"::"Issue Voucher",
                Enum::"NPR POS Sale Line Type"::Item,
                Enum::"NPR POS Sale Line Type"::"Item Category":
                    begin
                        SaleAmount += ExternalPOSSaleLine."Amount Including VAT";
                    end;
                Enum::"NPR POS Sale Line Type"::"POS Payment":
                    begin
                        PaidAmount += ExternalPOSSaleLine."Amount Including VAT";
                    end;
                Enum::"NPR POS Sale Line Type"::Rounding:
                    begin
                        RoundingAmount += ExternalPOSSaleLine."Amount Including VAT";
                    end;
            end;
        until ExternalPOSSaleLine.Next() = 0;
        if (SaleAmount - PaidAmount + RoundingAmount <> 0) then
            Error(SaleBalanceNotValidErrLbl);
    end;

    local procedure TryFindItemFromBarcode(var ExternalPOSSaleLine: Record "NPR External POS Sale Line")
    var
        ItemReference: Record "Item Reference";
        BarcodeLookupMgt: Codeunit "NPR Barcode Lookup Mgt.";
        ItemNo: Code[20];
        ItemVariantCode: Code[10];
        ResolvingTable: Integer;
    begin
        if (BarcodeLookupMgt.TranslateBarcodeToItemVariant(ExternalPOSSaleLine."Barcode Reference", ItemNo, ItemVariantCode, ResolvingTable, False)) then begin
            ExternalPOSSaleLine.Validate("No.", ItemNo);
            if ItemVariantCode <> '' then
                ExternalPOSSaleLine.Validate("Variant Code", ItemVariantCode);
        end;

        // Validate and set proper UoM
        ItemReference.Reset();
        ItemReference.SetCurrentKey("Reference Type", "Reference No.", "Item No.");
        ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::"Bar Code");
        ItemReference.SetRange("Reference No.", ExternalPOSSaleLine."Barcode Reference");
        ItemReference.SetRange("Item No.", ExternalPOSSaleLine."No.");
        if ItemReference.FindFirst() then
            if ItemReference."Unit of Measure" <> ExternalPOSSaleLine."Unit of Measure Code" then
                ExternalPOSSaleLine.Validate("Unit of Measure Code", ItemReference."Unit of Measure");
    end;

    procedure AddConversionError(var ExternalPOSSale: Record "NPR External POS Sale"; ErrorTxt: Text)
    begin
        ExternalPOSSale."Has Conversion Error" := true;
        ExternalPOSSale."Last Conversion Error Message" := CopyStr(ErrorTxt, 1, MaxStrLen(ExternalPOSSale."Last Conversion Error Message"));
        ExternalPOSSale.Modify();
    end;
}