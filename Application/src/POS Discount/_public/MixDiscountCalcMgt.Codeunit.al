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

    [Obsolete('Use CalculateMixedDiscountLine(RetailJournalLine: Record "NPR Retail Journal Line"; var POSSaleLineTemp: Record "NPR POS Sale Line" temporary; CalculationDate: Date) MixedDiscountExists: Boolean')]
    procedure CalculateMixedDiscountLine(ItemNo: Code[20]; VariantCode: Code[20]; var POSSaleLineTemp: Record "NPR POS Sale Line" temporary) MixedDiscountExists: Boolean

    var
        MixedDiscountMgt: Codeunit "NPR Mixed Discount Management";
        TempPOSSale: Record "NPR POS Sale" temporary;
        Item: Record Item;
        TempMixedDiscount: Record "NPR Mixed Discount" temporary;
        MixedDiscountLevel: Record "NPR Mixed Discount Level";
        LastLineNo: Integer;
    begin
        if not Item.Get(ItemNo) then
            exit(false);
        TempPOSSale."Register No." := GetCalculationTempPosSalesLineId();
        TempPOSSale."Sales Ticket No." := GetCalculationTempPosSalesLineId();
        TempPOSSale.Date := WorkDate();
        TempPOSSale."Start Time" := Time;
        TempPOSSale.Insert();

        POSSaleLineTemp.Reset();
        if POSSaleLineTemp.FindLast() then
            LastLineNo := POSSaleLineTemp."Line No.";
        POSSaleLineTemp.Init();
        POSSaleLineTemp."Register No." := GetCalculationTempPosSalesLineId();
        POSSaleLineTemp."Sales Ticket No." := GetCalculationTempPosSalesLineId();
        POSSaleLineTemp."Line No." := LastLineNo + 1;
        POSSaleLineTemp.Validate(Type, POSSaleLineTemp.Type::Item);
        POSSaleLineTemp."No." := ItemNo;
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
        POSSaleLineTemp."Variant Code" := VariantCode;
        POSSaleLineTemp."Item Disc. Group" := Item."Item Disc. Group";
        POSSaleLineTemp."Item Category Code" := Item."Item Category Code";
        POSSaleLineTemp.Date := WorkDate();
        POSSaleLineTemp."Manual Item Sales Price" := true;
        POSSaleLineTemp."Unit Price" := Item."Unit Price";

        POSSaleLineTemp.Insert();

        MixedDiscountMgt.FindPotentiallyImpactedMixesAndLines(POSSaleLineTemp, POSSaleLineTemp, TempMixedDiscount, true);

        TempMixedDiscount.SetRange("Discount Type", TempMixedDiscount."Discount Type"::"Multiple Discount Levels");
        if TempMixedDiscount.FindSet() then
            repeat
                MixedDiscountLevel.SetRange("Mixed Discount Code", TempMixedDiscount.Code);
                MixedDiscountLevel.Ascending(false);
                if MixedDiscountLevel.FindFirst() then begin
                    TempMixedDiscount."Min. Quantity" := MixedDiscountLevel.Quantity;
                    TempMixedDiscount.Modify();
                end;
            until TempMixedDiscount.Next() = 0;

        TempMixedDiscount.SetRange("Discount Type");
        TempMixedDiscount.SetCurrentKey("Min. Quantity");
        TempMixedDiscount.Ascending(false);
        if TempMixedDiscount.FindFirst() then begin
            POSSaleLineTemp."Price Includes VAT" := true;
            POSSaleLineTemp.Validate(Quantity, TempMixedDiscount."Min. Quantity");
            POSSaleLineTemp."MR Anvendt antal" := POSSaleLineTemp.Quantity;
            POSSaleLineTemp."Amount Including VAT" := POSSaleLineTemp.Amount;
            POSSaleLineTemp.Modify();
            MixedDiscountMgt.ApplyMixDiscounts(TempPOSSale, POSSaleLineTemp, POSSaleLineTemp, true, true, WorkDate());
            exit(true);
        end;
    end;

    [Obsolete('Use CalculateMixedDiscountLine(RetailJournalLine: Record "NPR Retail Journal Line"; var POSSaleLineTemp: Record "NPR POS Sale Line" temporary; CalculationDate: Date) MixedDiscountExists: Boolean')]
    procedure CalculateMixedDiscountLine(ItemNo: Code[20]; VariantCode: Code[20]; var POSSaleLineTemp: Record "NPR POS Sale Line" temporary; CalculationDate: Date) MixedDiscountExists: Boolean
    var
        MixedDiscountMgt: Codeunit "NPR Mixed Discount Management";
        TempPOSSale: Record "NPR POS Sale" temporary;
        Item: Record Item;
        TempMixedDiscount: Record "NPR Mixed Discount" temporary;
        MixedDiscountLevel: Record "NPR Mixed Discount Level";
        LastLineNo: Integer;
    begin
        if not Item.Get(ItemNo) then
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
        POSSaleLineTemp.Validate(Type, POSSaleLineTemp.Type::Item);
        POSSaleLineTemp."No." := ItemNo;
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
        POSSaleLineTemp."Variant Code" := VariantCode;
        POSSaleLineTemp."Item Disc. Group" := Item."Item Disc. Group";
        POSSaleLineTemp."Item Category Code" := Item."Item Category Code";
        POSSaleLineTemp.Date := CalculationDate;
        POSSaleLineTemp."Manual Item Sales Price" := true;
        POSSaleLineTemp."Unit Price" := Item."Unit Price";

        POSSaleLineTemp.Insert();

        MixedDiscountMgt.FindPotentiallyImpactedMixesAndLines(POSSaleLineTemp, POSSaleLineTemp, TempMixedDiscount, true, CalculationDate);

        TempMixedDiscount.SetRange("Discount Type", TempMixedDiscount."Discount Type"::"Multiple Discount Levels");
        if TempMixedDiscount.FindSet() then
            repeat
                MixedDiscountLevel.SetRange("Mixed Discount Code", TempMixedDiscount.Code);
                MixedDiscountLevel.Ascending(false);
                if MixedDiscountLevel.FindFirst() then begin
                    TempMixedDiscount."Min. Quantity" := MixedDiscountLevel.Quantity;
                    TempMixedDiscount.Modify();
                end;
            until TempMixedDiscount.Next() = 0;

        TempMixedDiscount.SetRange("Discount Type");
        TempMixedDiscount.SetCurrentKey("Min. Quantity");
        TempMixedDiscount.Ascending(false);
        if TempMixedDiscount.FindFirst() then begin
            POSSaleLineTemp."Price Includes VAT" := true;
            POSSaleLineTemp.Validate(Quantity, TempMixedDiscount."Min. Quantity");
            POSSaleLineTemp."MR Anvendt antal" := POSSaleLineTemp.Quantity;
            POSSaleLineTemp."Amount Including VAT" := POSSaleLineTemp.Amount;
            POSSaleLineTemp.Modify();
            MixedDiscountMgt.ApplyMixDiscounts(TempPOSSale, POSSaleLineTemp, POSSaleLineTemp, true, true, CalculationDate);
            exit(true);
        end;
    end;

    procedure CalculateMixedDiscountLine(RetailJournalLine: Record "NPR Retail Journal Line"; var POSSaleLineTemp: Record "NPR POS Sale Line" temporary; CalculationDate: Date) MixedDiscountExists: Boolean
    var
        MixedDiscountMgt: Codeunit "NPR Mixed Discount Management";
        TempPOSSale: Record "NPR POS Sale" temporary;
        Item: Record Item;
        MixedDiscount: Record "NPR Mixed Discount";
        MinQty: Decimal;
        LastLineNo: Integer;
    begin
        if not MixedDiscount.get(RetailJournalLine."Discount Code") then
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
        POSSaleLineTemp.Validate(Type, POSSaleLineTemp.Type::Item);
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

        MixedDiscountMgt.ApplyMixDiscounts(TempPOSSale, POSSaleLineTemp, POSSaleLineTemp, true, true, CalculationDate);

        exit(true);
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
}