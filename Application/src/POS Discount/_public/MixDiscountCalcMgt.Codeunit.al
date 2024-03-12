codeunit 6014681 "NPR Mix Discount Calc. Mgt."
{
    var
        CalculationTempPosSalesLineId: label '!CALCDISC!', MaxLength = 10, Locked = true, Comment = 'DO NOT TRANSLATE!';

    /// <summary>
    /// Calculates mixed discount based on maximum quantity in Mixed Discount/Mixed Discount Lines
    /// For Reporting purposes (Shelf labels)
    /// </summary>
    /// <param name="ItemNo"></param> Item No to be used for calculation
    /// <param name="VariantCode"></param> Variant Code to be used for calculation
    /// <param name="POSSaleLineTemp"></param> Temporary NPR POS Sale Line record used to return calculated values
    /// <returns></returns>
    [Obsolete('Use CalculateMixedDiscountLine(RetailJournalLine: Record "NPR Retail Journal Line"; var POSSaleLineTemp: Record "NPR POS Sale Line" temporary; CalculationDate: Date) MixedDiscountExists: Boolean', 'NPR23.0')]
    procedure CalculateMixedDiscountLine(ItemNo: Code[20]; VariantCode: Code[20]; var POSSaleLineTemp: Record "NPR POS Sale Line" temporary; CalculationDate: Date) MixedDiscountExists: Boolean
    begin

    end;

    procedure CalculateMixedDiscountLine(RetailJournalLine: Record "NPR Retail Journal Line"; var POSSaleLineTemp: Record "NPR POS Sale Line" temporary; CalculationDate: Date; FindBestMixedDiscount: Boolean) MixedDiscountExists: Boolean
    var
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
        MixedDiscountMgt: Codeunit "NPR Mixed Discount Management";
        TempPOSSale: Record "NPR POS Sale" temporary;
        Item: Record Item;
        MixedDiscount: Record "NPR Mixed Discount";
        TempMixedDiscount: Record "NPR Mixed Discount" temporary;
        TempMixedDiscountLine: Record "NPR Mixed Discount Line" temporary;
        TempImpactedSaleLinePOS: Record "NPR POS Sale Line" temporary;
        TempDiscountCalcBuffer: Record "NPR Discount Calc. Buffer" temporary;
        MinQty: Decimal;
        LastLineNo: Integer;
    begin
        if not (MixedDiscount.get(RetailJournalLine."Discount Code") or FindBestMixedDiscount) then
            exit(false);

        if not Item.Get(RetailJournalLine."Item No.") then
            exit(false);

        TempPOSSale."Register No." := GetCalculationTempPosSalesLineId();
        TempPOSSale."Sales Ticket No." := GetCalculationTempPosSalesLineId();
        TempPOSSale.Date := CalculationDate;
        TempPOSSale."Start Time" := Time;
        TempPOSSale.Insert();

        POSSaleLineTemp.Reset();
        if POSSaleLineTemp.FindLast() then
            LastLineNo := POSSaleLineTemp."Line No.";
        POSSaleLineTemp.Init();
        POSSaleLineTemp."Register No." := GetCalculationTempPosSalesLineId();
        POSSaleLineTemp."Sales Ticket No." := GetCalculationTempPosSalesLineId();
        POSSaleLineTemp."Line No." := LastLineNo + 1;
        POSSaleLineTemp.Validate("Line Type", POSSaleLineTemp."Line Type"::Item);
        POSSaleLineTemp."No." := RetailJournalLine."Item No.";
        POSSaleLineTemp."Gen. Prod. Posting Group" := Item."Gen. Prod. Posting Group";
        POSSaleLineTemp."VAT Prod. Posting Group" := Item."VAT Prod. Posting Group";
        POSSaleLineTemp."Item Category Code" := Item."Item Category Code";
        POSSaleLineTemp."Tax Group Code" := Item."Tax Group Code";
        POSSaleLineTemp."Posting Group" := Item."Inventory Posting Group";
        POSSaleLineTemp."Item Disc. Group" := Item."Item Disc. Group";
        POSSaleLineTemp."Custom Disc Blocked" := Item."NPR Custom Discount Blocked";
        if POSSaleLineTemp."Unit of Measure Code" = '' then
            POSSaleLineTemp."Unit of Measure Code" := Item."Base Unit of Measure";

        POSSaleLineTemp.UpdateVATSetup();
        POSSaleLineTemp.CalculateCostPrice();
        POSSaleLineTemp."Variant Code" := RetailJournalLine."Variant Code";
        POSSaleLineTemp."Item Disc. Group" := Item."Item Disc. Group";
        POSSaleLineTemp."Item Category Code" := Item."Item Category Code";
        POSSaleLineTemp.Date := CalculationDate;
        POSSaleLineTemp."Manual Item Sales Price" := true;
        POSSaleLineTemp."Unit Price" := Item."Unit Price";

        if MixedDiscount."Discount Type" = MixedDiscount."Discount Type"::"Multiple Discount Levels" then
            MinQty := CalculateMinimumMultipleLevelQuantity(MixedDiscount.Code)
        else
            MinQty := MixedDiscount."Min. Quantity";

        POSSaleLineTemp."Price Includes VAT" := true;
        POSSaleLineTemp.Validate(Quantity, MinQty);
        POSSaleLineTemp."MR Anvendt antal" := POSSaleLineTemp.Quantity;
        POSSaleLineTemp."Amount Including VAT" := POSSaleLineTemp.Amount;
        POSSaleLineTemp.Insert();

        if FindBestMixedDiscount then begin
            if FeatureFlagsManagement.IsEnabled('newMixDiscountCalculation_v2') then
                MixedDiscountMgt.FindImpactedMixedDiscoutnsAndLines(TempPOSSale, POSSaleLineTemp, POSSaleLineTemp, TempMixedDiscount, TempMixedDiscountLine, TempImpactedSaleLinePOS, TempDiscountCalcBuffer, true, CalculationDate)
            else
                MixedDiscountMgt.FindPotentiallyImpactedMixesAndLines(POSSaleLineTemp, POSSaleLineTemp, TempMixedDiscount, true, CalculationDate);

            if (TempMixedDiscount.Count = 0) then
                exit(false);
            TempMixedDiscount.SetRange("Discount Type", TempMixedDiscount."Discount Type"::"Multiple Discount Levels");
            if TempMixedDiscount.FindSet() then
                repeat
                    TempMixedDiscount."Min. Quantity" := CalculateMinimumMultipleLevelQuantity(TempMixedDiscount.Code);
                    TempMixedDiscount.Modify();
                until TempMixedDiscount.Next() = 0;

            TempMixedDiscount.SetRange("Discount Type");
            TempMixedDiscount.SetCurrentKey("Min. Quantity");
            TempMixedDiscount.Ascending(false);
            if TempMixedDiscount.FindFirst() then begin
                POSSaleLineTemp.Validate(Quantity, TempMixedDiscount."Min. Quantity");
                POSSaleLineTemp.Modify();
            end;
        end;

        if FeatureFlagsManagement.IsEnabled('newMixDiscountCalculation_v2') then
            MixedDiscountMgt.ApplyMixedDiscounts(TempPOSSale, POSSaleLineTemp, POSSaleLineTemp, true, true, CalculationDate)
        else
            MixedDiscountMgt.ApplyMixDiscounts(TempPOSSale, POSSaleLineTemp, POSSaleLineTemp, true, true, CalculationDate);

        exit(true);
    end;

    procedure CalculateMixedDiscountLine(RetailJournalLine: Record "NPR Retail Journal Line"; var POSSaleLineTemp: Record "NPR POS Sale Line" temporary; CalculationDate: Date) MixedDiscountExists: Boolean
    begin
        CalculateMixedDiscountLine(RetailJournalLine, POSSaleLineTemp, CalculationDate, false);
    end;

    local procedure CalculateMinimumMultipleLevelQuantity(MixDiscountCode: Code[20]): Decimal
    var
        MixedDiscountLevel: Record "NPR Mixed Discount Level";
    begin
        MixedDiscountLevel.SetRange("Mixed Discount Code", MixdiscountCode);
        MixedDiscountLevel.Ascending(false);
        if MixedDiscountLevel.FindFirst() then
            Exit(MixedDiscountLevel.Quantity);
    end;

    procedure GetCalculationTempPosSalesLineId(): Code[10]
    begin
        Exit(CalculationTempPosSalesLineId);
    end;

    procedure MixDiscountExistWithDateFilters(_Code: Code[20]; _Date: Date): Boolean
    var
        MixedDiscount: Record "NPR Mixed Discount";
    begin
        exit(MixedDiscount.Get(_Code) and ((MixedDiscount."Starting date" <= _Date) and (MixedDiscount."Ending date" >= _Date)));
    end;
}
