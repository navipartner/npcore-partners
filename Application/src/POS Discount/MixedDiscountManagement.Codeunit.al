codeunit 6014416 "NPR Mixed Discount Management"
{
    var
        TempCustDiscGroup: Record "Customer Discount Group" temporary;
        GLSetup: Record "General Ledger Setup";

    procedure ApplyMixDiscounts(SalePOS: Record "NPR POS Sale"; var TempSaleLinePOS: Record "NPR POS Sale Line" temporary; TriggerRec: Record "NPR POS Sale Line"; RecalculateAllLines: Boolean): Boolean
    begin
        Exit(ApplyMixDiscounts(SalePOS, TempSaleLinePOS, TriggerRec, RecalculateAllLines, false));
    end;

    procedure ApplyMixDiscounts(SalePOS: Record "NPR POS Sale"; var TempSaleLinePOS: Record "NPR POS Sale Line" temporary; TriggerRec: Record "NPR POS Sale Line"; RecalculateAllLines: Boolean; CalculateOnly: Boolean): Boolean
    var
        TempMixedDiscount: Record "NPR Mixed Discount" temporary;
        TempMixedDiscountLine: Record "NPR Mixed Discount Line" temporary;
    begin
        GLSetup.Get();
        GLSetup.TestField("Amount Rounding Precision");

        FindPotentiallyImpactedMixesAndLines(TempSaleLinePOS, TriggerRec, TempMixedDiscount, RecalculateAllLines);

        if not FindMatchingMixedDiscounts(SalePOS, TempMixedDiscount, TempMixedDiscountLine, TempSaleLinePOS) then begin
            Clear(TempSaleLinePOS);
            exit;
        end;

        TempMixedDiscount.Reset();
        TempMixedDiscount.SetRange("Mix Type", TempMixedDiscount."Mix Type"::Standard, TempMixedDiscount."Mix Type"::Combination);
        if TempMixedDiscount.IsEmpty then begin
            Clear(TempSaleLinePOS);
            exit;
        end;

        FindBestMixMatch(TempMixedDiscount, TempMixedDiscountLine, TempSaleLinePOS);

        TempMixedDiscount.SetCurrentKey("Actual Discount Amount", "Actual Item Qty.");
        TempMixedDiscount.SetRange("Mix Type", TempMixedDiscount."Mix Type"::Standard, TempMixedDiscount."Mix Type"::Combination);
        TempMixedDiscount.Ascending(false);
        TempMixedDiscount.FindSet();

        repeat
            ApplyMixDiscount(TempMixedDiscount, TempMixedDiscountLine, TempSaleLinePOS, CalculateOnly);
        until (TempMixedDiscount.Next() = 0);

        Clear(TempSaleLinePOS);
    end;

    procedure FindPotentiallyImpactedMixesAndLines(var TempSaleLinePOS: Record "NPR POS Sale Line" temporary; Rec: Record "NPR POS Sale Line"; var tmpImpactedMixHeaders: Record "NPR Mixed Discount" temporary; RecalculateAllLines: Boolean)
    var
        MixedDiscountLine: Record "NPR Mixed Discount Line";
        TempImpactedItems: Record "Item Variant" temporary;
        TempImpactedItemGroups: Record "Item Discount Group" temporary;
        TempImpactedItemDiscGroups: Record "Item Discount Group" temporary;
    begin
        // This function narrows the scope based on static parameters (=those assumed to not change inside an ongoing POS sale ie. "Item Group" for an item line)
        // For parameters like time and customer no., these are kept in scope here to allow them to go from enabled -> disabled (because they'll trigger "Discount Modified" := TRUE here),
        // but will be filtered out later in FindMatchingMixDiscounts()

        TempSaleLinePOS.SetRange("Discount Type", TempSaleLinePOS."Discount Type"::" ");
        TempSaleLinePOS.SetRange("Allow Line Discount", true);
        if not TempSaleLinePOS.FindSet() then
            exit;

        if RecalculateAllLines then begin
            repeat
                FindMixGroupingImpact(MixedDiscountLine."Disc. Grouping Type"::Item, TempSaleLinePOS."No.", TempSaleLinePOS."Variant Code", tmpImpactedMixHeaders, TempImpactedItems, TempImpactedItemGroups, TempImpactedItemDiscGroups);
                FindMixGroupingImpact(MixedDiscountLine."Disc. Grouping Type"::"Item Disc. Group", TempSaleLinePOS."Item Disc. Group", '', tmpImpactedMixHeaders, TempImpactedItems, TempImpactedItemGroups, TempImpactedItemDiscGroups);
                FindMixGroupingImpact(MixedDiscountLine."Disc. Grouping Type"::"Item Group", TempSaleLinePOS."Item Category Code", '', tmpImpactedMixHeaders, TempImpactedItems, TempImpactedItemGroups, TempImpactedItemDiscGroups);
            until TempSaleLinePOS.Next() = 0;
        end else begin
            if not Rec."Allow Line Discount" then
                exit;
            FindMixGroupingImpact(MixedDiscountLine."Disc. Grouping Type"::Item, Rec."No.", Rec."Variant Code", tmpImpactedMixHeaders, TempImpactedItems, TempImpactedItemGroups, TempImpactedItemDiscGroups);
            FindMixGroupingImpact(MixedDiscountLine."Disc. Grouping Type"::"Item Disc. Group", Rec."Item Disc. Group", '', tmpImpactedMixHeaders, TempImpactedItems, TempImpactedItemGroups, TempImpactedItemDiscGroups);
            FindMixGroupingImpact(MixedDiscountLine."Disc. Grouping Type"::"Item Group", Rec."Item Category Code", '', tmpImpactedMixHeaders, TempImpactedItems, TempImpactedItemGroups, TempImpactedItemDiscGroups);
        end;

        TempSaleLinePOS.FindSet();
        repeat
            if HasImpact(TempImpactedItems, TempImpactedItemGroups, TempImpactedItemDiscGroups, TempSaleLinePOS) then begin
                TempSaleLinePOS."Discount Calculated" := true;
                TempSaleLinePOS.Modify();
                TempSaleLinePOS.Mark(true);
            end;
        until TempSaleLinePOS.Next() = 0;
        TempSaleLinePOS.MarkedOnly(true);
    end;

    local procedure FindMixGroupingImpact(GroupingType: Enum "NPR Disc. Grouping Type"; No: Code[20]; VariantCode: Code[10]; var tmpImpactedMixHeaders: Record "NPR Mixed Discount" temporary; var tmpImpactedItems: Record "Item Variant" temporary; var tmpImpactedItemGroups: Record "Item Discount Group" temporary; var tmpImpactedItemDiscGroups: Record "Item Discount Group" temporary)
    var
        MixedDiscountLine: Record "NPR Mixed Discount Line";
    begin
        MixedDiscountLine.SetCurrentKey("Disc. Grouping Type", "No.", "Variant Code", "Starting Date", "Ending Date", "Starting Time", "Ending Time", Status);
        MixedDiscountLine.SetRange("Disc. Grouping Type", GroupingType);
        MixedDiscountLine.SetRange("No.", No);
        MixedDiscountLine.SetFilter("Variant Code", '%1|%2', VariantCode, '');
        MixedDiscountLine.SetFilter("Starting Date", '<=%1|=%2', Today, 0D);
        MixedDiscountLine.SetFilter("Ending Date", '>=%1|=%2', Today, 0D);
        MixedDiscountLine.SetRange(Status, MixedDiscountLine.Status::Active);

        if MixedDiscountLine.FindSet() then
            repeat
                FindMixHeaderImpact(MixedDiscountLine.Code, tmpImpactedMixHeaders, tmpImpactedItems, tmpImpactedItemGroups, tmpImpactedItemDiscGroups);
            until MixedDiscountLine.Next() = 0;
    end;

    local procedure FindMixHeaderImpact(MixDiscountCode: Code[20]; var tmpImpactedMixHeaders: Record "NPR Mixed Discount" temporary; var tmpImpactedItems: Record "Item Variant" temporary; var tmpImpactedItemGroups: Record "Item Discount Group" temporary; var tmpImpactedItemDiscGroups: Record "Item Discount Group" temporary)
    var
        MixedDiscount: Record "NPR Mixed Discount";
        MixedDiscountLine: Record "NPR Mixed Discount Line";
    begin
        if tmpImpactedMixHeaders.Get(MixDiscountCode) then
            exit;
        if not MixedDiscount.Get(MixDiscountCode) then
            exit;
        if MixedDiscount.Status <> MixedDiscount.Status::Active then
            exit;
        if MixedDiscount."Starting date" > Today then
            exit;
        if MixedDiscount."Ending date" < Today then
            exit;

        tmpImpactedMixHeaders := MixedDiscount;
        tmpImpactedMixHeaders.Insert();

        FindMixLineImpact(MixDiscountCode, tmpImpactedMixHeaders, tmpImpactedItems, tmpImpactedItemGroups, tmpImpactedItemDiscGroups);
        FindMixGroupingImpact(MixedDiscountLine."Disc. Grouping Type"::"Mix Discount", MixDiscountCode, '', tmpImpactedMixHeaders, tmpImpactedItems, tmpImpactedItemGroups, tmpImpactedItemDiscGroups);
    end;

    local procedure FindMixLineImpact(MixDiscountCode: Code[20]; var tmpImpactedMixHeaders: Record "NPR Mixed Discount" temporary; var tmpImpactedItems: Record "Item Variant" temporary; var tmpImpactedItemGroups: Record "Item Discount Group" temporary; var tmpImpactedItemDiscGroups: Record "Item Discount Group" temporary)
    var
        MixedDiscountLine: Record "NPR Mixed Discount Line";
    begin
        MixedDiscountLine.SetRange(Code, MixDiscountCode);
        if not MixedDiscountLine.FindSet() then
            exit;

        repeat
            case MixedDiscountLine."Disc. Grouping Type" of
                MixedDiscountLine."Disc. Grouping Type"::Item:
                    if not tmpImpactedItems.Get(MixedDiscountLine."No.", MixedDiscountLine."Variant Code") then begin
                        tmpImpactedItems."Item No." := MixedDiscountLine."No.";
                        tmpImpactedItems.Code := MixedDiscountLine."Variant Code";
                        tmpImpactedItems.Insert();
                        FindMixGroupingImpact(MixedDiscountLine."Disc. Grouping Type", MixedDiscountLine."No.", MixedDiscountLine."Variant Code", tmpImpactedMixHeaders, tmpImpactedItems, tmpImpactedItemGroups, tmpImpactedItemDiscGroups);
                    end;
                MixedDiscountLine."Disc. Grouping Type"::"Item Disc. Group":
                    if not tmpImpactedItemDiscGroups.Get(MixedDiscountLine."No.") then begin
                        tmpImpactedItemDiscGroups.Code := MixedDiscountLine."No.";
                        tmpImpactedItemDiscGroups.Insert();
                        FindMixGroupingImpact(MixedDiscountLine."Disc. Grouping Type", MixedDiscountLine."No.", MixedDiscountLine."Variant Code", tmpImpactedMixHeaders, tmpImpactedItems, tmpImpactedItemGroups, tmpImpactedItemDiscGroups);
                    end;
                MixedDiscountLine."Disc. Grouping Type"::"Item Group":
                    if not tmpImpactedItemGroups.Get(MixedDiscountLine."No.") then begin
                        tmpImpactedItemGroups.Code := MixedDiscountLine."No.";
                        tmpImpactedItemGroups.Insert();
                        FindMixGroupingImpact(MixedDiscountLine."Disc. Grouping Type", MixedDiscountLine."No.", MixedDiscountLine."Variant Code", tmpImpactedMixHeaders, tmpImpactedItems, tmpImpactedItemGroups, tmpImpactedItemDiscGroups);
                    end;
                MixedDiscountLine."Disc. Grouping Type"::"Mix Discount":
                    FindMixHeaderImpact(MixedDiscountLine."No.", tmpImpactedMixHeaders, tmpImpactedItems, tmpImpactedItemGroups, tmpImpactedItemDiscGroups);
            end;
        until MixedDiscountLine.Next() = 0;
    end;

    local procedure HasImpact(var tmpImpactedItems: Record "Item Variant" temporary; var tmpImpactedItemGroups: Record "Item Discount Group" temporary; var tmpImpactedItemDiscGroups: Record "Item Discount Group" temporary; var TempSaleLinePOS: Record "NPR POS Sale Line" temporary): Boolean
    begin
        if tmpImpactedItems.Get(TempSaleLinePOS."No.", TempSaleLinePOS."Variant Code") then
            exit(true);

        if tmpImpactedItems.Get(TempSaleLinePOS."No.", '') then
            exit(true);

        if tmpImpactedItemGroups.Get(TempSaleLinePOS."Item Category Code") then
            exit(true);

        exit(tmpImpactedItemDiscGroups.Get(TempSaleLinePOS."Item Disc. Group"));
    end;

    procedure CalcLineDiscAmount(var TempMixedDiscount: Record "NPR Mixed Discount" temporary; var TempMixedDiscountLine: Record "NPR Mixed Discount Line" temporary; BatchQty: Decimal; TotalQty: Decimal; TotalVATAmount: Decimal; TotalAmount: Decimal; var TempSaleLinePOSApply: Record "NPR POS Sale Line" temporary; InvQtyDict: Dictionary of [Guid, Decimal]) LineDiscAmount: Decimal
    var
        TotalAmountAfterDisc: Decimal;
        AvgDiscPct: Decimal;
        UnitPrice: Decimal;
    begin
        if TotalAmount <= 0 then
            exit(0);

        case TempMixedDiscount."Discount Type" of
            TempMixedDiscount."Discount Type"::"Total Amount per Min. Qty.":
                begin
                    TotalAmountAfterDisc := BatchQty * TempMixedDiscount."Total Amount";
                    AvgDiscPct := 1 - (TotalAmountAfterDisc / TotalAmount);
                    LineDiscAmount := TempSaleLinePOSApply."Unit Price" * TempSaleLinePOSApply."MR Anvendt antal" * AvgDiscPct;
                    if AmountExclVat(TempMixedDiscount) then begin
                        AvgDiscPct := 1 - (TotalAmountAfterDisc / (TotalAmount - TotalVATAmount));
                        UnitPrice := TempSaleLinePOSApply."Unit Price" / (1 + TempSaleLinePOSApply."VAT %" / 100);
                        LineDiscAmount := UnitPrice * TempSaleLinePOSApply."MR Anvendt antal" * AvgDiscPct;
                    end;
                end;
            TempMixedDiscount."Discount Type"::"Total Discount %":
                begin
                    AvgDiscPct := TempMixedDiscount."Total Discount %" / 100;
                    LineDiscAmount := TempSaleLinePOSApply."Unit Price" * TempSaleLinePOSApply."MR Anvendt antal" * AvgDiscPct;
                end;
            TempMixedDiscount."Discount Type"::"Total Discount Amt. per Min. Qty.":
                begin
                    TotalAmountAfterDisc := TotalAmount - BatchQty * TempMixedDiscount."Total Discount Amount";
                    AvgDiscPct := 1 - (TotalAmountAfterDisc / TotalAmount);
                    LineDiscAmount := TempSaleLinePOSApply."Unit Price" * TempSaleLinePOSApply."MR Anvendt antal" * AvgDiscPct;
                end;
            TempMixedDiscount."Discount Type"::"Priority Discount per Min. Qty":
                begin
                    AvgDiscPct := TempMixedDiscount."Item Discount %" / 100;
                    LineDiscAmount := TempSaleLinePOSApply."Unit Price" * InvQtyDict.Get(TempSaleLinePOSApply.SystemId) * AvgDiscPct;
                end;
        end;
        if TempMixedDiscount.Lot then begin
            TempMixedDiscountLine.Get(TempSaleLinePOSApply."Discount Code", TempSaleLinePOSApply."Sales Document Type", TempSaleLinePOSApply."Sales Document No.", TempSaleLinePOSApply."Variant Code");
            if TempMixedDiscountLine.Quantity = 0 then
                exit(0);
        end;

        LineDiscAmount := Round(LineDiscAmount, GLSetup."Amount Rounding Precision");
        exit(LineDiscAmount);
    end;

    procedure CalcTotalDiscAmount(var TempMixedDiscount: Record "NPR Mixed Discount" temporary; BatchQty: Decimal; TotalVATAmount: Decimal; TotalAmount: Decimal; var TempPriorityBuffer: Record "NPR Mixed Disc. Prio. Buffer" temporary) TotalDiscAmount: Decimal
    var
        TotalAmountAfterDisc: Decimal;
        AvgDiscPct: Decimal;
        ItemDiscQty: Decimal;
        DiscQty: Decimal;
        TotalDiscQty: Decimal;
    begin
        if TotalAmount <= 0 then
            exit(0);

        case TempMixedDiscount."Discount Type" of
            TempMixedDiscount."Discount Type"::"Total Amount per Min. Qty.":
                begin
                    TotalAmountAfterDisc := BatchQty * TempMixedDiscount."Total Amount";
                    TotalDiscAmount := TotalAmount - TotalAmountAfterDisc;
                    if AmountExclVat(TempMixedDiscount) then
                        TotalDiscAmount -= TotalVATAmount;
                end;
            TempMixedDiscount."Discount Type"::"Total Discount %":
                begin
                    AvgDiscPct := TempMixedDiscount."Total Discount %" / 100;
                    TotalDiscAmount := TotalAmount * AvgDiscPct;
                end;
            TempMixedDiscount."Discount Type"::"Total Discount Amt. per Min. Qty.":
                begin
                    TotalDiscAmount := BatchQty * TempMixedDiscount."Total Discount Amount";
                end;
            TempMixedDiscount."Discount Type"::"Priority Discount per Min. Qty":
                begin
                    if TempPriorityBuffer.IsEmpty then
                        exit(0);

                    ItemDiscQty := TempMixedDiscount."Item Discount Qty." * BatchQty;
                    TempPriorityBuffer.FindSet();
                    repeat
                        DiscQty := TempPriorityBuffer.Quantity;
                        if DiscQty > ItemDiscQty - TotalDiscQty then
                            DiscQty := ItemDiscQty - TotalDiscQty;
                        TotalDiscQty += DiscQty;
                        TotalDiscAmount += DiscQty * TempPriorityBuffer."Unit Price" * (TempMixedDiscount."Item Discount %" / 100);
                    until (TempPriorityBuffer.Next() = 0) or (TotalDiscQty >= ItemDiscQty);
                end;
        end;

        TotalDiscAmount := Round(TotalDiscAmount, GLSetup."Amount Rounding Precision");
        exit(TotalDiscAmount);
    end;

    procedure CalcExpectedDiscAmount(MixedDiscount: Record "NPR Mixed Discount"; MaxDisc: Boolean) ExpectedDiscAmount: Decimal
    var
        TempPriorityBuffer: Record "NPR Mixed Disc. Prio. Buffer" temporary;
        TotalAmount: Decimal;
    begin
        TotalAmount := CalcExpectedAmountPerBatch(MixedDiscount, MaxDisc, TempPriorityBuffer);
        ExpectedDiscAmount := CalcTotalDiscAmount(MixedDiscount, 1, 0, TotalAmount, TempPriorityBuffer);
        exit(ExpectedDiscAmount);
    end;

    procedure CalcExpectedAmountPerBatch(MixedDiscount: Record "NPR Mixed Discount"; MaxAmount: Boolean; var TempPriorityBuffer: Record "NPR Mixed Disc. Prio. Buffer" temporary) TotalAmount: Decimal
    var
        MixedDiscountPart: Record "NPR Mixed Discount";
        MixedDiscountLine: Record "NPR Mixed Discount Line";
    begin
        if MixedDiscount."Mix Type" = MixedDiscount."Mix Type"::Combination then begin
            MixedDiscountLine.SetRange(Code, MixedDiscount.Code);
            MixedDiscountLine.SetRange("Disc. Grouping Type", MixedDiscountLine."Disc. Grouping Type"::"Mix Discount");
            if MixedDiscountLine.IsEmpty then
                exit(0);

            MixedDiscountLine.FindSet();
            repeat
                if MixedDiscountPart.Get(MixedDiscountLine."No.") then
                    TotalAmount += CalcExpectedAmountPerBatch(MixedDiscountPart, MaxAmount, TempPriorityBuffer);
            until MixedDiscountLine.Next() = 0;
            exit(TotalAmount);
        end;

        MixedDiscountLine.SetRange(Code, MixedDiscount.Code);
        MixedDiscountLine.SetFilter("Unit price", '>%1', 0);
        MixedDiscountLine.SetRange("Disc. Grouping Type", MixedDiscountLine."Disc. Grouping Type"::Item, MixedDiscountLine."Disc. Grouping Type"::"Item Disc. Group");
        if not MixedDiscountLine.FindFirst() then
            exit(0);

        if MixedDiscount.Lot then begin
            repeat
                MixedDiscountLine.CalcFields("Unit price");
                TotalAmount += MixedDiscountLine."Unit price" * MixedDiscountLine.Quantity;

                TransferMixedDiscountLine2PriorityBuffer(MixedDiscountLine, TempPriorityBuffer);
            until MixedDiscountLine.Next() = 0;

            exit(TotalAmount);
        end;

        repeat
            MixedDiscountLine.CalcFields("Unit price");
            if MaxAmount then
                MixedDiscountLine.SetFilter("Unit price", '>%1', MixedDiscountLine."Unit price")
            else
                MixedDiscountLine.SetFilter("Unit price", '<%1', MixedDiscountLine."Unit price");
        until not MixedDiscountLine.FindFirst();

        MixedDiscountLine.CalcFields("Unit price");
        TotalAmount := MixedDiscountLine."Unit price" * MixedDiscount."Min. Quantity";

        MixedDiscountLine.Quantity := MixedDiscount."Min. Quantity";
        TransferMixedDiscountLine2PriorityBuffer(MixedDiscountLine, TempPriorityBuffer);

        exit(TotalAmount);
    end;

    local procedure TransferSaleLinePOS2PriorityBuffer(var TempSaleLinePOS: Record "NPR POS Sale Line" temporary; var TempMixedDiscount: Record "NPR Mixed Discount" temporary; var TempMixedDiscountLine: Record "NPR Mixed Discount Line" temporary; var TempPriorityBuffer: Record "NPR Mixed Disc. Prio. Buffer" temporary): Boolean
    var
        Priority: Decimal;
    begin
        if TempSaleLinePOS.IsEmpty then
            exit(false);

        TempPriorityBuffer.DeleteAll();

        TempSaleLinePOS.FindSet();
        repeat
            Priority := FindPriority(TempMixedDiscount, TempMixedDiscountLine, TempSaleLinePOS);
            if TempPriorityBuffer.Get(Priority, TempSaleLinePOS."Unit Price", TempSaleLinePOS."No.", TempSaleLinePOS."Variant Code") then begin
                TempPriorityBuffer.Quantity += TempSaleLinePOS.Quantity;
                TempPriorityBuffer.Modify();
            end else begin
                TempPriorityBuffer.Init();
                TempPriorityBuffer.Priority := Priority;
                TempPriorityBuffer."Unit Price" := TempSaleLinePOS."Unit Price";
                TempPriorityBuffer."Item No." := TempSaleLinePOS."No.";
                TempPriorityBuffer."Variant Code" := TempSaleLinePOS."Variant Code";
                TempPriorityBuffer.Quantity := TempSaleLinePOS.Quantity;
                TempPriorityBuffer.Insert();
            end;
        until TempSaleLinePOS.Next() = 0;

        exit(true);
    end;

    local procedure TransferMixedDiscountLine2PriorityBuffer(var TempMixedDiscountLine: Record "NPR Mixed Discount Line" temporary; var TempPriorityBuffer: Record "NPR Mixed Disc. Prio. Buffer" temporary)
    begin
        if TempMixedDiscountLine."Disc. Grouping Type" <> TempMixedDiscountLine."Disc. Grouping Type"::Item then
            exit;

        if TempPriorityBuffer.Get(TempMixedDiscountLine.Priority, TempMixedDiscountLine."Unit price", TempMixedDiscountLine."No.", TempMixedDiscountLine."Variant Code") then begin
            TempPriorityBuffer.Quantity += TempMixedDiscountLine.Quantity;
            TempPriorityBuffer.Modify();
            exit;
        end;

        TempPriorityBuffer.Init();
        TempPriorityBuffer.Priority := TempMixedDiscountLine.Priority;
        TempPriorityBuffer."Unit Price" := TempMixedDiscountLine."Unit price";
        TempPriorityBuffer."Item No." := TempMixedDiscountLine."No.";
        TempPriorityBuffer."Variant Code" := TempMixedDiscountLine."Variant Code";
        TempPriorityBuffer.Quantity := TempMixedDiscountLine.Quantity;
        TempPriorityBuffer.Insert();
    end;

    local procedure TransferHighestPriorityBuffer(var TempMixedDiscount: Record "NPR Mixed Discount" temporary; BatchQty: Decimal; var TempPriorityBuffer: Record "NPR Mixed Disc. Prio. Buffer" temporary; var TempPriorityBufferHigh: Record "NPR Mixed Disc. Prio. Buffer" temporary)
    var
        DiscQty: Decimal;
        TotalDiscQty: Decimal;
    begin
        TempPriorityBufferHigh.DeleteAll();
        if TempMixedDiscount."Discount Type" <> TempMixedDiscount."Discount Type"::"Priority Discount per Min. Qty" then
            exit;
        if TempPriorityBuffer.IsEmpty then
            exit;

        TotalDiscQty := TempMixedDiscount."Item Discount Qty." * BatchQty;
        TempPriorityBuffer.FindSet();
        repeat
            TempPriorityBufferHigh.Init();
            TempPriorityBufferHigh := TempPriorityBuffer;
            if TempPriorityBufferHigh.Quantity + DiscQty > TotalDiscQty then
                TempPriorityBufferHigh.Quantity := TotalDiscQty - DiscQty;
            TempPriorityBufferHigh.Insert();

            DiscQty += TempPriorityBufferHigh.Quantity;
        until (TempPriorityBuffer.Next() = 0) or (DiscQty >= TotalDiscQty);
    end;

    procedure CalcLineMultiLevelDiscAmount(MixedDiscount: Record "NPR Mixed Discount"; MixedDiscountLevel: Record "NPR Mixed Discount Level"; SaleLinePOSApply: Record "NPR POS Sale Line"; QtyToApply: Decimal; RemainderAmt: Decimal): Decimal
    var
        LineDiscountAmount: Decimal;
    begin
        if MixedDiscount."Discount Type" <> MixedDiscount."Discount Type"::"Multiple Discount Levels" then
            exit(0);

        case true of
            MixedDiscountLevel."Discount Amount" > 0:
                begin
                    LineDiscountAmount := MixedDiscountLevel."Discount Amount" / MixedDiscountLevel.Quantity * QtyToApply;
                    if AmountExclVat(MixedDiscount) then
                        LineDiscountAmount := LineDiscountAmount * (1 + SaleLinePOSApply."VAT %" / 100);
                    if LineDiscountAmount <> 0 then
                        LineDiscountAmount := LineDiscountAmount + RemainderAmt;
                end;

            MixedDiscountLevel."Discount %" > 0:
                begin
                    LineDiscountAmount := SaleLinePOSApply."Unit Price" * QtyToApply * MixedDiscountLevel."Discount %" / 100;
                end;
        end;

        if LineDiscountAmount > SaleLinePOSApply."Amount Including VAT" then
            LineDiscountAmount := SaleLinePOSApply."Amount Including VAT";

        exit(LineDiscountAmount);
    end;

    procedure GetMixDiscountLevels(MixedDiscount: Record "NPR Mixed Discount"; MaxQty: Decimal; var MixedDiscountLevelTmp: Record "NPR Mixed Discount Level")
    var
        MixedDiscountLevel: Record "NPR Mixed Discount Level";
        QtyFactor: Integer;
    begin
        if not MixedDiscountLevelTmp.IsTemporary then
            exit;
        MixedDiscountLevelTmp.DeleteAll();

        MixedDiscountLevel.SetRange("Mixed Discount Code", MixedDiscount.Code);
        MixedDiscountLevel.SetRange("Multiple Of", false);
        if MixedDiscountLevel.FindSet() then
            repeat
                CopyMixDiscountLevel(MixedDiscountLevel, MixedDiscountLevelTmp, 1);
            until MixedDiscountLevel.Next() = 0;

        MixedDiscountLevel.SetRange("Multiple Of", true);
        MixedDiscountLevel.Ascending(false);
        if MixedDiscountLevel.FindSet() then
            repeat
                QtyFactor := 1;
                while MixedDiscountLevel.Quantity * QtyFactor <= MaxQty do begin
                    CopyMixDiscountLevel(MixedDiscountLevel, MixedDiscountLevelTmp, QtyFactor);
                    QtyFactor += 1;
                end;
            until MixedDiscountLevel.Next() = 0;
    end;

    local procedure CopyMixDiscountLevel(FromMixDiscountLevel: Record "NPR Mixed Discount Level"; var ToMixDiscountLevel: Record "NPR Mixed Discount Level"; QtyFactor: Integer)
    begin
        ToMixDiscountLevel := FromMixDiscountLevel;
        ToMixDiscountLevel.Quantity := ToMixDiscountLevel.Quantity * QtyFactor;
        if ToMixDiscountLevel.Find() or (ToMixDiscountLevel.Quantity <= 0) then
            exit;
        if ToMixDiscountLevel."Discount Amount" <> 0 then
            ToMixDiscountLevel."Discount Amount" := ToMixDiscountLevel."Discount Amount" * QtyFactor;
        ToMixDiscountLevel.Insert();
    end;

    local procedure FindApplicableMixDiscountLevel(var MixDiscountLevel: Record "NPR Mixed Discount Level"; QtyToApply: Decimal): Boolean
    begin
        if not MixDiscountLevel.IsTemporary then
            exit(false);

        MixDiscountLevel.SetFilter(Quantity, '>%1', QtyToApply);
        MixDiscountLevel.DeleteAll();
        MixDiscountLevel.SetRange(Quantity);
        exit(MixDiscountLevel.FindLast());
    end;

    local procedure AdjustBatchQty(var BatchQty: Decimal; var TempMixedDiscount: Record "NPR Mixed Discount" temporary; var TempMixedDiscountLine: Record "NPR Mixed Discount Line" temporary; var TempSaleLinePOSApply: Record "NPR POS Sale Line" temporary; var InvQtyDict: Dictionary of [Guid, Decimal])
    var
        TempSaleLinePOSApplyCopy: Record "NPR POS Sale Line" temporary;
        TempSaleLinePOSApplyNew: Record "NPR POS Sale Line" temporary;
        QtyToApply: Decimal;
    begin
        TempSaleLinePOSApply.Reset();
        if BatchQty < 1 then begin
            TempSaleLinePOSApply.DeleteAll();
            exit;
        end;
        if (TempMixedDiscount."Discount Type" = TempMixedDiscount."Discount Type"::"Priority Discount per Min. Qty") then
            BatchQty := Round(BatchQty, 1, '<');

        TempSaleLinePOSApplyCopy.Copy(TempSaleLinePOSApply, true);
        Clear(TempMixedDiscountLine);
        TempMixedDiscountLine.SetCurrentKey(Priority);
        if TempMixedDiscountLine.IsEmpty then
            exit;

        if not TempMixedDiscount.Lot then
            QtyToApply := Round(TempMixedDiscount.CalcMinQty() * BatchQty, 0.00001);

        TempMixedDiscountLine.FindSet();
        repeat
            FilterSaleLinePOS(TempMixedDiscountLine, TempSaleLinePOSApplyCopy);
            TempSaleLinePOSApplyCopy.SetRange("Discount Type");
            TempSaleLinePOSApplyCopy.SetRange("Discount Code");
            if TempMixedDiscount.Lot then
                QtyToApply := Round(TempMixedDiscountLine.Quantity * BatchQty, 0.00001);
            AdjustBatchQtyItems(QtyToApply, TempSaleLinePOSApplyCopy, TempSaleLinePOSApplyNew, InvQtyDict);
        until TempMixedDiscountLine.Next() = 0;
        TempSaleLinePOSApply.Copy(TempSaleLinePOSApplyNew, true);
    end;

    local procedure AdjustBatchQtyItems(var QtyToApply: Decimal; var TempSaleLinePOSApplyCopy: Record "NPR POS Sale Line" temporary; var TempSaleLinePOSApplyNew: Record "NPR POS Sale Line" temporary; var InvQtyDict: Dictionary of [Guid, Decimal])
    begin
        if TempSaleLinePOSApplyCopy.IsEmpty then
            exit;

        TempSaleLinePOSApplyCopy.FindSet();
        repeat
            if QtyToApply > 0 then begin
                TempSaleLinePOSApplyNew.Init();
                TempSaleLinePOSApplyNew := TempSaleLinePOSApplyCopy;

                if QtyToApply < TempSaleLinePOSApplyNew."MR Anvendt antal" then
                    TempSaleLinePOSApplyNew."MR Anvendt antal" := QtyToApply;
                if QtyToApply > TempSaleLinePOSApplyNew."MR Anvendt antal" then begin
                    TempSaleLinePOSApplyNew."MR Anvendt antal" := TempSaleLinePOSApplyNew.Quantity;
                    if TempSaleLinePOSApplyNew.Quantity > QtyToApply then
                        TempSaleLinePOSApplyNew."MR Anvendt antal" -= TempSaleLinePOSApplyNew.Quantity - QtyToApply;
                end;
                TempSaleLinePOSApplyNew."Amount Including VAT" := TempSaleLinePOSApplyNew."Unit Price" * TempSaleLinePOSApplyNew."MR Anvendt antal";
                TempSaleLinePOSApplyNew.Insert();

                InvQtyDict.Set(TempSaleLinePOSApplyNew.SystemId, TempSaleLinePOSApplyNew."MR Anvendt antal");

                QtyToApply -= TempSaleLinePOSApplyCopy."MR Anvendt antal";
            end;
            TempSaleLinePOSApplyCopy.Delete();
        until TempSaleLinePOSApplyCopy.Next() = 0;
    end;

    local procedure AdjustDiscQty(BatchQty: Decimal; var TempMixedDiscount: Record "NPR Mixed Discount" temporary; var TempMixedDiscountLine: Record "NPR Mixed Discount Line" temporary; var TempSaleLinePOSApply: Record "NPR POS Sale Line" temporary; var InvQtyDict: Dictionary of [Guid, Decimal])
    var
        TempPriorityBuffer: Record "NPR Mixed Disc. Prio. Buffer" temporary;
        TempPriorityBufferHigh: Record "NPR Mixed Disc. Prio. Buffer" temporary;
    begin
        if TempMixedDiscount."Discount Type" <> TempMixedDiscount."Discount Type"::"Priority Discount per Min. Qty" then
            exit;

        Clear(TempSaleLinePOSApply);
        if TempSaleLinePOSApply.IsEmpty then
            exit;

        TransferSaleLinePOS2PriorityBuffer(TempSaleLinePOSApply, TempMixedDiscount, TempMixedDiscountLine, TempPriorityBuffer);
        TransferHighestPriorityBuffer(TempMixedDiscount, BatchQty, TempPriorityBuffer, TempPriorityBufferHigh);
        Clear(TempPriorityBufferHigh);

        TempSaleLinePOSApply.FindSet();
        repeat
            AdjustDiscQtyItems(TempMixedDiscount, TempMixedDiscountLine, TempPriorityBufferHigh, TempSaleLinePOSApply, InvQtyDict);
        until TempSaleLinePOSApply.Next() = 0;
    end;

    local procedure AdjustDiscQtyItems(var TempMixedDiscount: Record "NPR Mixed Discount" temporary; var TempMixedDiscountLine: Record "NPR Mixed Discount Line" temporary; var TempPriorityBufferHigh: Record "NPR Mixed Disc. Prio. Buffer" temporary; var TempSaleLinePOSApply: Record "NPR POS Sale Line" temporary; var InvQtyDict: Dictionary of [Guid, Decimal])
    var
        DiscQty: Decimal;
        Priority: Decimal;
    begin
        Priority := FindPriority(TempMixedDiscount, TempMixedDiscountLine, TempSaleLinePOSApply);
        if (not TempPriorityBufferHigh.Get(Priority, TempSaleLinePOSApply."Unit Price", TempSaleLinePOSApply."No.", TempSaleLinePOSApply."Variant Code")) or (TempPriorityBufferHigh.Quantity <= 0) then begin
            InvQtyDict.Set(TempSaleLinePOSApply.SystemId, 0);
            exit;
        end;

        DiscQty := TempPriorityBufferHigh.Quantity;
        if DiscQty > TempSaleLinePOSApply."MR Anvendt antal" then
            DiscQty := TempSaleLinePOSApply."MR Anvendt antal";

        TempPriorityBufferHigh.Quantity -= DiscQty;
        if TempPriorityBufferHigh.Quantity > 0 then
            TempPriorityBufferHigh.Modify()
        else
            TempPriorityBufferHigh.Delete();

        InvQtyDict.Set(TempSaleLinePOSApply.SystemId, DiscQty);
    end;

#pragma warning disable AA0137
    local procedure ApplyMixDiscount(var TempMixedDiscount: Record "NPR Mixed Discount" temporary; var TempMixedDiscountLine: Record "NPR Mixed Discount Line" temporary; var TempSaleLinePOS: Record "NPR POS Sale Line" temporary) TotalDiscAmount: Decimal
    begin
        exit(ApplyMixDiscount(TempMixedDiscount, TempMixedDiscountLine, TempSaleLinePOS, false));
    end;
#pragma warning restore

    local procedure ApplyMixDiscount(var TempMixedDiscount: Record "NPR Mixed Discount" temporary; var TempMixedDiscountLine: Record "NPR Mixed Discount Line" temporary; var TempSaleLinePOS: Record "NPR POS Sale Line" temporary; CalculateOnly: Boolean) TotalDiscAmount: Decimal
    var
        TempSaleLinePOSApply: Record "NPR POS Sale Line" temporary;
        InvQtyDict: Dictionary of [Guid, Decimal];
        BatchQty: Decimal;
        LastLineNo: Integer;
    begin
        TempSaleLinePOSApply.DeleteAll();
        BatchQty := FindLinesToApply(TempMixedDiscount, TempMixedDiscountLine, TempSaleLinePOS, TempSaleLinePOSApply, InvQtyDict);
        if BatchQty < 1 then
            exit(0);

        AdjustBatchQty(BatchQty, TempMixedDiscount, TempMixedDiscountLine, TempSaleLinePOSApply, InvQtyDict);
        AdjustDiscQty(BatchQty, TempMixedDiscount, TempMixedDiscountLine, TempSaleLinePOSApply, InvQtyDict);
        Clear(TempSaleLinePOS);
        if TempSaleLinePOS.FindLast() then
            LastLineNo := TempSaleLinePOS."Line No.";
        if TempMixedDiscount."Discount Type" = TempMixedDiscount."Discount Type"::"Multiple Discount Levels" then
            TotalDiscAmount := ApplylMultiLevelMixDiscountOnLines(TempSaleLinePOSApply, TempMixedDiscount, TempMixedDiscountLine, LastLineNo, InvQtyDict)
        else
            TotalDiscAmount := ApplyMixDiscountOnLines(BatchQty, TempMixedDiscount, TempMixedDiscountLine, TempSaleLinePOSApply, InvQtyDict);
        if (not CalculateOnly) then
            TransferAppliedDiscountToSale(TempSaleLinePOSApply, TempSaleLinePOS, LastLineNo, InvQtyDict);

        exit(TotalDiscAmount);
    end;

    local procedure ApplyMixDiscountOnLines(BatchQty: Decimal; var TempMixedDiscount: Record "NPR Mixed Discount" temporary; var TempMixedDiscountLine: Record "NPR Mixed Discount Line" temporary; var TempSaleLinePOSApply: Record "NPR POS Sale Line" temporary; InvQtyDict: Dictionary of [Guid, Decimal]) TotalDiscAmount: Decimal
    var
        TempPriorityBuffer: Record "NPR Mixed Disc. Prio. Buffer" temporary;
        AppliedDiscAmount: Decimal;
        LineDiscAmount: Decimal;
        TotalQty: Decimal;
        TotalAmount: Decimal;
        TotalVATAmount: Decimal;
    begin
        TempSaleLinePOSApply.CalcSums("MR Anvendt antal", "Amount Including VAT", "VAT Base Amount");

        TotalVATAmount := TempSaleLinePOSApply."VAT Base Amount";
        TotalQty := TempSaleLinePOSApply."MR Anvendt antal";
        TotalAmount := TempSaleLinePOSApply."Amount Including VAT";
        if TotalAmount = 0 then
            exit(0);

        TempSaleLinePOSApply.FindSet();
        repeat
            TempSaleLinePOSApply."Discount Type" := TempSaleLinePOSApply."Discount Type"::Mix;
            TempSaleLinePOSApply."Discount Code" := TempMixedDiscount.Code;
            TempSaleLinePOSApply."Custom Disc Blocked" := TempMixedDiscount."Block Custom Discount";
            LineDiscAmount := CalcLineDiscAmount(TempMixedDiscount, TempMixedDiscountLine, BatchQty, TotalQty, TotalVATAmount, TotalAmount, TempSaleLinePOSApply, InvQtyDict);
            if AmountExclVat(TempMixedDiscount) then
                TempSaleLinePOSApply."Discount Amount" := LineDiscAmount * (1 + TempSaleLinePOSApply."VAT %" / 100)
            else
                TempSaleLinePOSApply."Discount Amount" := LineDiscAmount;
            TempSaleLinePOSApply.Modify();
            AppliedDiscAmount += LineDiscAmount;
        until TempSaleLinePOSApply.Next() = 0;

        TransferSaleLinePOS2PriorityBuffer(TempSaleLinePOSApply, TempMixedDiscount, TempMixedDiscountLine, TempPriorityBuffer);
        TotalDiscAmount := CalcTotalDiscAmount(TempMixedDiscount, BatchQty, TotalVATAmount, TotalAmount, TempPriorityBuffer);
        if AppliedDiscAmount <> TotalDiscAmount then begin
            if AmountExclVat(TempMixedDiscount) then
                TempSaleLinePOSApply."Discount Amount" += (TotalDiscAmount - AppliedDiscAmount) * (1 + TempSaleLinePOSApply."VAT %" / 100)
            else
                TempSaleLinePOSApply."Discount Amount" += TotalDiscAmount - AppliedDiscAmount;
            TempSaleLinePOSApply.Modify();
        end;

        exit(TotalDiscAmount);
    end;

    local procedure ApplylMultiLevelMixDiscountOnLines(var SaleLinePOSApply: Record "NPR POS Sale Line"; MixedDiscount: Record "NPR Mixed Discount"; var MixedDiscountLine: Record "NPR Mixed Discount Line"; var LastLineNo: Integer; var InvQtyDict: Dictionary of [Guid, Decimal]): Decimal
    var
        TempMixedDiscountLevel: Record "NPR Mixed Discount Level" temporary;
        TempPriorityBuffer: Record "NPR Mixed Disc. Prio. Buffer" temporary;
        SaleLinePOSApply2: Record "NPR POS Sale Line";
        CurrentQtyToApply: Decimal;
        LineDiscountAmt: Decimal;
        RemainderAmt: Decimal;
        TotalAppliedDiscountAmt: Decimal;
        TotalQtyToApply: Decimal;
        InsertReminderLine: Boolean;
        NothingLeftToApply: Boolean;
    begin
        if MixedDiscount."Discount Type" <> MixedDiscount."Discount Type"::"Multiple Discount Levels" then
            exit(0);
        if SaleLinePOSApply.IsEmpty then
            exit(0);
        SaleLinePOSApply.CalcSums("MR Anvendt antal");
        TotalQtyToApply := SaleLinePOSApply."MR Anvendt antal";

        GetMixDiscountLevels(MixedDiscount, TotalQtyToApply, TempMixedDiscountLevel);
        if TempMixedDiscountLevel.IsEmpty then
            exit(0);

        TransferSaleLinePOS2PriorityBuffer(SaleLinePOSApply, MixedDiscount, MixedDiscountLine, TempPriorityBuffer);
        if TempPriorityBuffer.IsEmpty then
            exit(0);

        while not NothingLeftToApply do begin
            if CurrentQtyToApply = 0 then begin
                if FindApplicableMixDiscountLevel(TempMixedDiscountLevel, TotalQtyToApply) then begin
                    CurrentQtyToApply := TempMixedDiscountLevel.Quantity;
                    TotalQtyToApply := TotalQtyToApply - CurrentQtyToApply;
                    RemainderAmt := 0;
                end else
                    NothingLeftToApply := true;
            end;

            if CurrentQtyToApply > 0 then begin
                TempPriorityBuffer.FindSet();
                repeat
                    SaleLinePOSApply.SetRange(Type, SaleLinePOSApply.Type::Item);
                    SaleLinePOSApply.SetRange("No.", TempPriorityBuffer."Item No.");
                    SaleLinePOSApply.SetRange("Variant Code", TempPriorityBuffer."Variant Code");
                    SaleLinePOSApply.SetRange("Unit Price", TempPriorityBuffer."Unit Price");
                    SaleLinePOSApply.SetRange("Discount Type", SaleLinePOSApply."Discount Type"::Mix);
                    SaleLinePOSApply.SetRange("Discount Code", MixedDiscount.Code);
                    SaleLinePOSApply.SetFilter(Quantity, '>%1', 0);
                    if SaleLinePOSApply.FindSet() then
                        repeat
                            if SaleLinePOSApply."Discount Amount" = 0 then begin
                                if CurrentQtyToApply >= SaleLinePOSApply."MR Anvendt antal" then
                                    CurrentQtyToApply := CurrentQtyToApply - SaleLinePOSApply."MR Anvendt antal"
                                else begin
                                    SaleLinePOSApply2 := SaleLinePOSApply;
                                    SaleLinePOSApply."MR Anvendt antal" := CurrentQtyToApply;
                                    SaleLinePOSApply.Quantity := CurrentQtyToApply;
                                    SaleLinePOSApply2."MR Anvendt antal" := SaleLinePOSApply2."MR Anvendt antal" - SaleLinePOSApply."MR Anvendt antal";
                                    SaleLinePOSApply2.Quantity := SaleLinePOSApply2.Quantity - SaleLinePOSApply.Quantity;
                                    CurrentQtyToApply := 0;
                                    InsertReminderLine := true;
                                end;

                                SaleLinePOSApply."Discount Type" := SaleLinePOSApply."Discount Type"::Mix;
                                SaleLinePOSApply."Discount Code" := MixedDiscount.Code;
                                SaleLinePOSApply."Custom Disc Blocked" := MixedDiscount."Block Custom Discount";
                                LineDiscountAmt :=
                                  CalcLineMultiLevelDiscAmount(MixedDiscount, TempMixedDiscountLevel, SaleLinePOSApply, SaleLinePOSApply."MR Anvendt antal", RemainderAmt);
                                SaleLinePOSApply."Discount Amount" := Round(LineDiscountAmt, 0.01);
                                SaleLinePOSApply.Modify();

                                InvQtyDict.Set(SaleLinePOSApply.SystemId, SaleLinePOSApply."MR Anvendt antal");

                                TotalAppliedDiscountAmt += SaleLinePOSApply."Discount Amount";
                                RemainderAmt := LineDiscountAmt - SaleLinePOSApply."Discount Amount";

                                if InsertReminderLine then begin
                                    InsertNewSaleLine(
                                      SaleLinePOSApply, SaleLinePOSApply2, SaleLinePOSApply2.Quantity, SaleLinePOSApply2."Discount Type"::Mix, SaleLinePOSApply2."Discount Code", LastLineNo);

                                    SaleLinePOSApply."MR Anvendt antal" := SaleLinePOSApply2."MR Anvendt antal";
                                    InvQtyDict.Set(SaleLinePOSApply.SystemId, 0);

                                    if not SaleLinePOSApply."Price Includes VAT" and
                                        (SaleLinePOSApply.Amount <> 0) and
                                        (SaleLinePOSApply.Amount <> SaleLinePOSApply."Amount Including VAT")
                                    then
                                        SaleLinePOSApply."Unit Price" :=
                                          SaleLinePOSApply."Unit Price" / SaleLinePOSApply.Amount * SaleLinePOSApply."Amount Including VAT";
                                    SaleLinePOSApply."Amount Including VAT" := SaleLinePOSApply."MR Anvendt antal" * SaleLinePOSApply."Unit Price";
                                    SaleLinePOSApply."VAT Base Amount" := SaleLinePOSApply."Amount Including VAT" - SaleLinePOSApply."Amount Including VAT" / (1 + SaleLinePOSApply."VAT %" / 100);
                                    SaleLinePOSApply.Amount := SaleLinePOSApply."Amount Including VAT" - SaleLinePOSApply."VAT Base Amount";
                                    SaleLinePOSApply.Modify();

                                    InsertReminderLine := false;
                                end;
                            end;

                            if CurrentQtyToApply = 0 then
                                TempMixedDiscountLevel.Delete();
                        until (SaleLinePOSApply.Next() = 0) or (CurrentQtyToApply = 0);
                until (TempPriorityBuffer.Next() = 0) or (CurrentQtyToApply = 0);
            end;

            if not NothingLeftToApply then
                NothingLeftToApply := TotalQtyToApply = 0;
        end;

        SaleLinePOSApply.Reset();
        exit(TotalAppliedDiscountAmt);
    end;

    local procedure FilterSaleLinePOS(var TempMixedDiscountLine: Record "NPR Mixed Discount Line" temporary; var TempSaleLinePOS: Record "NPR POS Sale Line" temporary): Boolean
    begin
        TempSaleLinePOS.SetRange("No.");
        TempSaleLinePOS.SetRange("Variant Code");
        TempSaleLinePOS.SetRange("Item Category Code");
        TempSaleLinePOS.SetRange("Item Disc. Group");
        case TempMixedDiscountLine."Disc. Grouping Type" of
            TempMixedDiscountLine."Disc. Grouping Type"::Item:
                begin
                    TempSaleLinePOS.SetRange("No.", TempMixedDiscountLine."No.");
                    if TempMixedDiscountLine."Variant Code" <> '' then
                        TempSaleLinePOS.SetFilter("Variant Code", TempMixedDiscountLine."Variant Code");
                end;
            TempMixedDiscountLine."Disc. Grouping Type"::"Item Group":
                TempSaleLinePOS.SetRange("Item Category Code", TempMixedDiscountLine."No.");
            TempMixedDiscountLine."Disc. Grouping Type"::"Item Disc. Group":
                TempSaleLinePOS.SetRange("Item Disc. Group", TempMixedDiscountLine."No.");
            else
                exit(false);
        end;
        TempSaleLinePOS.SetRange(Type, TempSaleLinePOS.Type::Item);
        TempSaleLinePOS.SetRange("Discount Type", TempSaleLinePOS."Discount Type"::" ");
        TempSaleLinePOS.SetFilter("Discount Code", '=%1', '');
        TempSaleLinePOS.SetFilter(Quantity, '>%1', 0);
        exit(not TempSaleLinePOS.IsEmpty());
    end;

    local procedure FindLinesToApply(var TempMixedDiscount: Record "NPR Mixed Discount" temporary; var TempMixedDiscountLine: Record "NPR Mixed Discount Line" temporary; var TempSaleLinePOS: Record "NPR POS Sale Line" temporary; var TempSaleLinePOSApply: Record "NPR POS Sale Line" temporary; var InvQtyDict: Dictionary of [Guid, Decimal]) BatchQty: Decimal
    begin
        case TempMixedDiscount."Mix Type" of
            TempMixedDiscount."Mix Type"::Standard, TempMixedDiscount."Mix Type"::"Combination Part":
                begin
                    if TempMixedDiscount.Lot then
                        BatchQty := FindLinesToApplyLot(TempMixedDiscount, TempMixedDiscountLine, TempSaleLinePOS, TempSaleLinePOSApply, InvQtyDict)
                    else
                        BatchQty := FindLinesToApplyTotalQty(TempMixedDiscount, TempMixedDiscountLine, TempSaleLinePOS, TempSaleLinePOSApply, InvQtyDict);
                    exit(BatchQty);
                end;
            TempMixedDiscount."Mix Type"::Combination:
                begin
                    BatchQty := FindLinesToApplyCombination(TempMixedDiscount, TempMixedDiscountLine, TempSaleLinePOS, TempSaleLinePOSApply, InvQtyDict);
                    exit(BatchQty);
                end;
        end;

        exit(0);
    end;

    local procedure FindLinesToApplyCombination(var TempMixedDiscount: Record "NPR Mixed Discount" temporary; var TempMixedDiscountLine: Record "NPR Mixed Discount Line" temporary; var TempSaleLinePOS: Record "NPR POS Sale Line" temporary; var TempSaleLinePOSApply: Record "NPR POS Sale Line" temporary; var InvQtyDict: Dictionary of [Guid, Decimal]) BatchQty: Decimal
    var
        TempMixedDiscountLine2: Record "NPR Mixed Discount Line" temporary;
        TempMixedDiscount2: Record "NPR Mixed Discount" temporary;
        MinQty: Decimal;
    begin
        if TempMixedDiscount."Mix Type" <> TempMixedDiscount."Mix Type"::Combination then
            exit(0);

        TempMixedDiscount2.Copy(TempMixedDiscount, true);
        TempMixedDiscountLine2.Copy(TempMixedDiscountLine, true);
        TempMixedDiscountLine2.SetRange(Code, TempMixedDiscount.Code);
        TempMixedDiscountLine2.SetRange("Disc. Grouping Type", TempMixedDiscountLine."Disc. Grouping Type"::"Mix Discount");
        if TempMixedDiscountLine2.IsEmpty then
            exit(0);

        BatchQty := -1;
        TempMixedDiscountLine2.FindSet();
        repeat
            TempMixedDiscount2.Get(TempMixedDiscountLine2."No.");
            FindLinesToApply(TempMixedDiscount2, TempMixedDiscountLine, TempSaleLinePOS, TempSaleLinePOSApply, InvQtyDict);
        until TempMixedDiscountLine2.Next() = 0;

        MinQty := TempMixedDiscount.CalcMinQty();
        if MinQty <= 0 then
            exit(0);

        TempSaleLinePOSApply.CalcSums("MR Anvendt antal");
        BatchQty := TempSaleLinePOSApply."MR Anvendt antal" / MinQty;

        exit(BatchQty);
    end;

    local procedure FindLinesToApplyLot(var TempMixedDiscount: Record "NPR Mixed Discount" temporary; var TempMixedDiscountLine: Record "NPR Mixed Discount Line" temporary; var TempSaleLinePOS: Record "NPR POS Sale Line" temporary; var TempSaleLinePOSApply: Record "NPR POS Sale Line" temporary; var InvQtyDisc: Dictionary of [Guid, Decimal]) BatchQty: Decimal
    var
        AppliedQty: Decimal;
        LastBatchQty: Decimal;
    begin
        if not (TempMixedDiscount."Mix Type" in [TempMixedDiscount."Mix Type"::Standard, TempMixedDiscount."Mix Type"::"Combination Part"]) then
            exit(0);
        if not TempMixedDiscount.Lot then
            exit(0);

        TempMixedDiscountLine.SetCurrentKey(Priority);
        TempMixedDiscountLine.SetRange(Code, TempMixedDiscount.Code);
        TempMixedDiscountLine.SetRange("Disc. Grouping Type", TempMixedDiscountLine."Disc. Grouping Type"::Item, TempMixedDiscountLine."Disc. Grouping Type"::"Item Disc. Group");
        if TempMixedDiscountLine.IsEmpty then
            exit(0);

        BatchQty := -1;
        TempMixedDiscountLine.FindSet();
        repeat
            if TempMixedDiscountLine.Quantity <= 0 then
                exit(0);

            AppliedQty := TransferLinesToApply(TempMixedDiscountLine, 0, TempSaleLinePOS, TempSaleLinePOSApply, InvQtyDisc);

            LastBatchQty := AppliedQty div TempMixedDiscountLine.Quantity;
            if (LastBatchQty < BatchQty) or (BatchQty = -1) then
                BatchQty := LastBatchQty;
        until TempMixedDiscountLine.Next() = 0;

        exit(BatchQty);
    end;

    local procedure FindLinesToApplyTotalQty(var TempMixedDiscount: Record "NPR Mixed Discount" temporary; var TempMixedDiscountLine: Record "NPR Mixed Discount Line" temporary; var TempSaleLinePOS: Record "NPR POS Sale Line" temporary; var TempSaleLinePOSApply: Record "NPR POS Sale Line" temporary; var InvQtyDict: Dictionary of [Guid, Decimal]) BatchQty: Decimal
    var
        AppliedQty: Decimal;
        MaxQtyToApply: Decimal;
    begin
        if not TempSaleLinePOSApply.IsTemporary then
            exit(0);
        if not (TempMixedDiscount."Mix Type" in [TempMixedDiscount."Mix Type"::Standard, TempMixedDiscount."Mix Type"::"Combination Part"]) then
            exit(0);
        if TempMixedDiscount.Lot then
            exit(0);
        if TempMixedDiscount."Min. Quantity" <= 0 then
            exit(0);

        TempMixedDiscountLine.SetCurrentKey(Priority);
        TempMixedDiscountLine.SetRange(Code, TempMixedDiscount.Code);
        TempMixedDiscountLine.SetRange("Disc. Grouping Type", TempMixedDiscountLine."Disc. Grouping Type"::Item, TempMixedDiscountLine."Disc. Grouping Type"::"Item Disc. Group");
        if TempMixedDiscountLine.IsEmpty then
            exit(0);

        MaxQtyToApply := TempMixedDiscount."Max. Quantity";
        TempMixedDiscountLine.FindSet();
        repeat
            AppliedQty += TransferLinesToApply(TempMixedDiscountLine, MaxQtyToApply, TempSaleLinePOS, TempSaleLinePOSApply, InvQtyDict);
            if TempMixedDiscount."Max. Quantity" > 0 then begin
                MaxQtyToApply := TempMixedDiscount."Max. Quantity" - AppliedQty;
                if MaxQtyToApply <= 0 then
                    TempMixedDiscountLine.FindLast();
            end;
        until TempMixedDiscountLine.Next() = 0;

        BatchQty := AppliedQty / TempMixedDiscount."Min. Quantity";
        exit(BatchQty);
    end;

    local procedure FindPriority(var TempMixedDiscount: Record "NPR Mixed Discount" temporary; var TempMixedDiscountLine: Record "NPR Mixed Discount Line" temporary; var TempSaleLinePOS: Record "NPR POS Sale Line" temporary) HighestPriority: Decimal
    begin
        HighestPriority := 1000000000;

        if TempMixedDiscountLine.Get(TempMixedDiscount.Code, TempMixedDiscountLine."Disc. Grouping Type"::Item, TempSaleLinePOS."No.", TempSaleLinePOS."Variant Code") then
            HighestPriority := TempMixedDiscountLine.Priority;

        if TempMixedDiscountLine.Get(TempMixedDiscount.Code, TempMixedDiscountLine."Disc. Grouping Type"::Item, TempSaleLinePOS."No.", '') and (HighestPriority > TempMixedDiscountLine.Priority) then
            HighestPriority := TempMixedDiscountLine.Priority;

        if TempMixedDiscountLine.Get(TempMixedDiscount.Code, TempMixedDiscountLine."Disc. Grouping Type"::"Item Group", TempSaleLinePOS."Item Category Code", '') and (HighestPriority > TempMixedDiscountLine.Priority) then
            HighestPriority := TempMixedDiscountLine.Priority;

        if TempMixedDiscountLine.Get(TempMixedDiscount.Code, TempMixedDiscountLine."Disc. Grouping Type"::"Item Disc. Group", TempSaleLinePOS."Item Disc. Group", '') and (HighestPriority > TempMixedDiscountLine.Priority) then
            HighestPriority := TempMixedDiscountLine.Priority;

        exit(HighestPriority);
    end;

    local procedure TransferLinesToApply(var TempMixedDiscountLine: Record "NPR Mixed Discount Line" temporary; MaxQtyToApply: Decimal; var TempSaleLinePOS: Record "NPR POS Sale Line" temporary; var TempSaleLinePOSApply: Record "NPR POS Sale Line" temporary; var InvQtyDisc: Dictionary of [Guid, Decimal]) AppliedQty: Decimal
    begin
        if not FilterSaleLinePOS(TempMixedDiscountLine, TempSaleLinePOS) then
            exit(0);

        TempSaleLinePOS.FindSet();
        repeat
            if not TempSaleLinePOSApply.Get(TempSaleLinePOS."Register No.", TempSaleLinePOS."Sales Ticket No.", TempSaleLinePOS.Date, TempSaleLinePOS."Sale Type", TempSaleLinePOS."Line No.") then begin

                TempSaleLinePOSApply.Init();
                TempSaleLinePOSApply := TempSaleLinePOS;

                TempSaleLinePOSApply."Discount Type" := TempSaleLinePOSApply."Discount Type"::Mix;
                TempSaleLinePOSApply."Discount Code" := TempMixedDiscountLine.Code;
                TempSaleLinePOSApply."Sales Document Type" := TempMixedDiscountLine."Disc. Grouping Type";
                TempSaleLinePOSApply."Sales Document No." := TempMixedDiscountLine."No.";
                TempSaleLinePOSApply."Variant Code" := TempMixedDiscountLine."Variant Code";

                TempSaleLinePOSApply."Quantity (Base)" := TempMixedDiscountLine.Quantity;
                TempSaleLinePOSApply.Insert();

                TempSaleLinePOSApply."MR Anvendt antal" := TempSaleLinePOSApply.Quantity;
                if (MaxQtyToApply > 0) and (AppliedQty + TempSaleLinePOSApply."MR Anvendt antal" >= MaxQtyToApply) then begin
                    TempSaleLinePOSApply."MR Anvendt antal" := MaxQtyToApply - AppliedQty;
                    TempSaleLinePOS.FindLast();
                end;
                TempSaleLinePOSApply."Amount Including VAT" := TempSaleLinePOSApply."MR Anvendt antal" * TempSaleLinePOSApply."Unit Price";
                TempSaleLinePOSApply."VAT Base Amount" := TempSaleLinePOSApply."Amount Including VAT" - TempSaleLinePOSApply."Amount Including VAT" / (1 + TempSaleLinePOSApply."VAT %" / 100);
                TempSaleLinePOSApply.Amount := TempSaleLinePOSApply."Amount Including VAT" - TempSaleLinePOSApply."VAT Base Amount";
                TempSaleLinePOSApply.Modify();

                InvQtyDisc.Add(TempSaleLinePOSApply.SystemId, TempSaleLinePOSApply."MR Anvendt antal");
                AppliedQty += TempSaleLinePOSApply."MR Anvendt antal";
            end;
        until TempSaleLinePOS.Next() = 0;

        exit(AppliedQty);
    end;

    local procedure TransferAppliedDiscountToSale(var TempSaleLinePOSApply: Record "NPR POS Sale Line" temporary; var TempSaleLinePOS: Record "NPR POS Sale Line" temporary; LastLineNo: Integer; InvQtyDict: Dictionary of [Guid, Decimal])
    var
        RemainingQty: Decimal;
        NonDiscQty: Decimal;
        InvQty: Decimal;
    begin
        if TempSaleLinePOSApply.IsEmpty then
            exit;

        TempSaleLinePOSApply.FindSet();
        repeat
            if not TempSaleLinePOS.Get(TempSaleLinePOSApply."Register No.", TempSaleLinePOSApply."Sales Ticket No.", TempSaleLinePOSApply.Date, TempSaleLinePOSApply."Sale Type", TempSaleLinePOSApply."Line No.")
            then begin
                TempSaleLinePOS := TempSaleLinePOSApply;
                TempSaleLinePOS.Insert();
            end;
            TempSaleLinePOSApply."Discount Amount" := TempSaleLinePOSApply."Discount Amount";
            RemainingQty := TempSaleLinePOSApply.Quantity - TempSaleLinePOSApply."MR Anvendt antal";  //need this for "Multiple Discount Levels" type of discounts
            TempSaleLinePOS.Validate(Quantity, TempSaleLinePOSApply."MR Anvendt antal");
            NonDiscQty := 0;
            InvQty := InvQtyDict.Get(TempSaleLinePOSApply.SystemId);
            if InvQty > 0 then begin
                NonDiscQty := TempSaleLinePOSApply."MR Anvendt antal" - InvQty;
                if TempSaleLinePOS.Quantity <> InvQty then
                    TempSaleLinePOS.Validate(Quantity, InvQty);
            end;
            TempSaleLinePOS."Discount Type" := TempSaleLinePOSApply."Discount Type";
            TempSaleLinePOS."Discount Code" := TempSaleLinePOSApply."Discount Code";
            TempSaleLinePOS."Discount %" := 0;
            TempSaleLinePOS."Discount Amount" := TempSaleLinePOSApply."Discount Amount";
            TempSaleLinePOS."Custom Disc Blocked" := TempSaleLinePOSApply."Custom Disc Blocked";
            TempSaleLinePOS.Modify();

            InsertNewSaleLine(TempSaleLinePOS, TempSaleLinePOSApply, NonDiscQty, TempSaleLinePOSApply."Discount Type", TempSaleLinePOSApply."Discount Code", LastLineNo);
            InsertNewSaleLine(TempSaleLinePOS, TempSaleLinePOSApply, RemainingQty, TempSaleLinePOS."Discount Type"::" ", '', LastLineNo);
        until TempSaleLinePOSApply.Next() = 0;
    end;

    local procedure InsertNewSaleLine(var SaleLinePOS: Record "NPR POS Sale Line"; FromSaleLinePOS: Record "NPR POS Sale Line"; Qty: Decimal; DiscountType: Integer; DiscountCode: Code[20]; var LastLineNo: Integer)
    var
        SaleLinePOS2: Record "NPR POS Sale Line";
    begin
        if Qty <= 0 then
            exit;

        SaleLinePOS2 := SaleLinePOS;

        SaleLinePOS.Init();
        SaleLinePOS := FromSaleLinePOS;
        SaleLinePOS."Sales Document Type" := SaleLinePOS2."Sales Document Type";
        SaleLinePOS."Sales Document No." := SaleLinePOS2."Sales Document No.";
        if SaleLinePOS.IsTemporary() then
            SaleLinePOS."Variant Code" := SaleLinePOS2."Variant Code";
        SaleLinePOS."Line No." := LastLineNo + 10000;
        SaleLinePOS.Insert();
        SaleLinePOS."Discount Type" := DiscountType;
        SaleLinePOS."Discount Code" := DiscountCode;
        SaleLinePOS."Discount %" := 0;
        SaleLinePOS."Discount Amount" := 0;
        SaleLinePOS."Custom Disc Blocked" := false;
        SaleLinePOS.Validate(Quantity, Qty);
        SaleLinePOS.Modify();

        LastLineNo := SaleLinePOS."Line No.";
    end;

    local procedure AmountExclVat(TempMixedDiscount: Record "NPR Mixed Discount" temporary): Boolean
    begin
        if not TempMixedDiscount."Total Amount Excl. VAT" then
            exit(false);

        exit(
          TempMixedDiscount."Discount Type" in
            [TempMixedDiscount."Discount Type"::"Total Amount per Min. Qty.",
             TempMixedDiscount."Discount Type"::"Multiple Discount Levels"]);
    end;

    procedure FindMatchingMixedDiscounts(SalePOS: Record "NPR POS Sale"; var TempMixedDiscount: Record "NPR Mixed Discount" temporary; var TempMixedDiscountLine: Record "NPR Mixed Discount Line" temporary; var TempSaleLinePOS: Record "NPR POS Sale Line" temporary): Boolean
    begin
        MatchMixedDiscounts(SalePOS, TempMixedDiscount, TempMixedDiscountLine, TempSaleLinePOS);
        MatchMixedDiscountCominations(SalePOS, TempMixedDiscount, TempMixedDiscountLine, TempSaleLinePOS);
        TempMixedDiscount.Reset();
        exit(not TempMixedDiscount.IsEmpty());
    end;

    procedure MatchMixedDiscounts(SalePOS: Record "NPR POS Sale"; var TempMixedDiscount: Record "NPR Mixed Discount" temporary; var TempMixedDiscountLine: Record "NPR Mixed Discount Line" temporary; var TempSaleLinePOS: Record "NPR POS Sale Line" temporary)
    begin
        TempMixedDiscount.Reset();
        TempMixedDiscount.SetFilter("Mix Type", '%1|%2', TempMixedDiscount."Mix Type"::Standard, TempMixedDiscount."Mix Type"::"Combination Part");
        if TempMixedDiscount.IsEmpty then
            exit;

        TempMixedDiscount.FindSet();
        repeat
            if not MatchMixedDiscount(SalePOS, TempMixedDiscount, TempMixedDiscountLine, TempSaleLinePOS) then begin
                TempMixedDiscountLine.Reset();
                TempMixedDiscountLine.SetRange(Code, TempMixedDiscount.Code);
                TempMixedDiscountLine.DeleteAll();

                TempMixedDiscount.Delete();
            end;
        until TempMixedDiscount.Next() = 0;
    end;

    local procedure MatchMixedDiscount(SalePOS: Record "NPR POS Sale"; var TempMixedDiscount: Record "NPR Mixed Discount" temporary; var TempMixedDiscountLine: Record "NPR Mixed Discount Line" temporary; var TempSaleLinePOS: Record "NPR POS Sale Line" temporary): Boolean
    var
        MixedDiscountLine: Record "NPR Mixed Discount Line";
        TempSaleLinePOS2: Record "NPR POS Sale Line" temporary;
        TotalQuantity: Decimal;
    begin
        if not DiscountActive(SalePOS, TempMixedDiscount) then
            exit(false);

        if (TempMixedDiscount."Min. Quantity" <= 0) and not TempMixedDiscount.Lot then
            exit(false);

        MixedDiscountLine.SetRange(Code, TempMixedDiscount.Code);
        MixedDiscountLine.SetRange("Disc. Grouping Type", MixedDiscountLine."Disc. Grouping Type"::Item, MixedDiscountLine."Disc. Grouping Type"::"Item Disc. Group");
        if MixedDiscountLine.IsEmpty then
            exit(false);

        TotalQuantity := 0;
        MixedDiscountLine.FindSet();
        repeat
            TempSaleLinePOS2.Copy(TempSaleLinePOS, true);
            TempSaleLinePOS2.SetRange(Type, TempSaleLinePOS2.Type::Item);
            case MixedDiscountLine."Disc. Grouping Type" of
                MixedDiscountLine."Disc. Grouping Type"::Item:
                    begin
                        TempSaleLinePOS2.SetRange("No.", MixedDiscountLine."No.");
                        if MixedDiscountLine."Variant Code" <> '' then
                            TempSaleLinePOS2.SetRange("Variant Code", MixedDiscountLine."Variant Code");
                    end;
                MixedDiscountLine."Disc. Grouping Type"::"Item Group":
                    TempSaleLinePOS2.SetRange("Item Category Code", MixedDiscountLine."No.");
                MixedDiscountLine."Disc. Grouping Type"::"Item Disc. Group":
                    TempSaleLinePOS2.SetRange("Item Disc. Group", MixedDiscountLine."No.")
            end;

            TempSaleLinePOS2.CalcSums(Quantity);
            TotalQuantity += TempSaleLinePOS2.Quantity;
            if TempMixedDiscount.Lot and (TotalQuantity < MixedDiscountLine.Quantity) then
                exit(false);

            TempMixedDiscountLine.Init();
            TempMixedDiscountLine := MixedDiscountLine;
            TempMixedDiscountLine.Insert();
        until MixedDiscountLine.Next() = 0;

        if TempMixedDiscount.Lot then
            exit(true);

        exit(TotalQuantity >= TempMixedDiscount."Min. Quantity");
    end;

    procedure MatchMixedDiscountCominations(SalePOS: Record "NPR POS Sale"; var TempMixedDiscount: Record "NPR Mixed Discount" temporary; var TempMixedDiscountLine: Record "NPR Mixed Discount Line" temporary; var TempSaleLinePOS: Record "NPR POS Sale Line" temporary): Boolean
    begin
        TempMixedDiscount.Reset();
        TempMixedDiscount.SetRange("Mix Type", TempMixedDiscount."Mix Type"::Combination);
        if TempMixedDiscount.IsEmpty then
            exit;

        TempMixedDiscount.FindSet();
        repeat
            if not MatchMixedDiscountComination(SalePOS, TempMixedDiscount, TempMixedDiscountLine, TempSaleLinePOS) then begin
                TempMixedDiscountLine.SetRange(Code, TempMixedDiscount.Code);
                TempMixedDiscountLine.DeleteAll();
                TempMixedDiscount.Delete();
            end;
        until TempMixedDiscount.Next() = 0;
    end;

    procedure MatchMixedDiscountComination(SalePOS: Record "NPR POS Sale"; var TempMixedDiscount: Record "NPR Mixed Discount" temporary; var TempMixedDiscountLine: Record "NPR Mixed Discount Line" temporary; var TempSaleLinePOS: Record "NPR POS Sale Line" temporary): Boolean
    var
        MixedDiscountLine: Record "NPR Mixed Discount Line";
        TempMixedDiscountPart: Record "NPR Mixed Discount" temporary;
    begin
        TempMixedDiscountPart.Copy(TempMixedDiscount, true);

        if not DiscountActive(SalePOS, TempMixedDiscount) then
            exit(false);

        MixedDiscountLine.SetRange(Code, TempMixedDiscount.Code);
        MixedDiscountLine.SetRange("Disc. Grouping Type", MixedDiscountLine."Disc. Grouping Type"::"Mix Discount");
        if MixedDiscountLine.IsEmpty then
            exit(false);

        MixedDiscountLine.FindSet();
        repeat
            if not TempMixedDiscountPart.Get(MixedDiscountLine."No.") then
                exit(false);

            TempMixedDiscountLine.Init();
            TempMixedDiscountLine := MixedDiscountLine;
            TempMixedDiscountLine.Insert();
        until MixedDiscountLine.Next() = 0;
        exit(true);
    end;

    local procedure DiscountActive(SalePOS: Record "NPR POS Sale"; var MixedDiscount: Record "NPR Mixed Discount"): Boolean
    var
        MixedDiscount2: Record "NPR Mixed Discount";
        MixedDiscountLine2: Record "NPR Mixed Discount Line";
    begin
        case MixedDiscount."Mix Type" of
            MixedDiscount."Mix Type"::Standard, MixedDiscount."Mix Type"::Combination:
                begin
                    if not IsActiveNow(MixedDiscount) then
                        exit(false);

                    if MixedDiscount."Customer Disc. Group Filter" <> '' then begin
                        GenerateTmpCustDiscGroupList();
                        TempCustDiscGroup.SetFilter(Code, MixedDiscount."Customer Disc. Group Filter");
                        TempCustDiscGroup.Code := SalePOS."Customer Disc. Group";
                        if not TempCustDiscGroup.Find() then
                            exit(false);
                    end;

                    exit(true);
                end;
            MixedDiscount."Mix Type"::"Combination Part":
                begin
                    MixedDiscountLine2.SetRange("Disc. Grouping Type", MixedDiscountLine2."Disc. Grouping Type"::"Mix Discount");
                    MixedDiscountLine2.SetFilter("No.", MixedDiscount.Code);
                    MixedDiscountLine2.SetRange(Status, MixedDiscountLine2.Status::Active);
                    if MixedDiscountLine2.IsEmpty then
                        exit(false);
                    MixedDiscountLine2.FindSet();
                    repeat
                        if MixedDiscount2.Get(MixedDiscountLine2.Code) and (MixedDiscount2."Mix Type" = MixedDiscount2."Mix Type"::Combination) then
                            if DiscountActive(SalePOS, MixedDiscount2) then
                                exit(true);
                    until MixedDiscountLine2.Next() = 0;
                end;
        end;

        exit(false)
    end;

    local procedure CalcTotalAppliedMixDisc(var TempMixedDiscount: Record "NPR Mixed Discount" temporary; var TempMixedDiscountLine: Record "NPR Mixed Discount Line" temporary; var TempSaleLinePOS: Record "NPR POS Sale Line" temporary) DiscAmount: Decimal
    var
        TempMixedDiscountCopy: Record "NPR Mixed Discount" temporary;
        MixCode: Code[20];
    begin
        if TempMixedDiscount.IsEmpty then
            exit(0);

        MixCode := TempMixedDiscount.Code;

        TempMixedDiscountCopy.Copy(TempMixedDiscount, true);
        DiscAmount := ApplyMixDiscount(TempMixedDiscountCopy, TempMixedDiscountLine, TempSaleLinePOS);

        TempMixedDiscountCopy.SetCurrentKey("Actual Discount Amount", "Actual Item Qty.");
        TempMixedDiscount.SetRange("Mix Type", TempMixedDiscount."Mix Type"::Standard, TempMixedDiscount."Mix Type"::Combination);
        TempMixedDiscountCopy.SetFilter(Code, '<>%1', MixCode);
        TempMixedDiscountCopy.Ascending(false);
        if TempMixedDiscountCopy.IsEmpty then
            exit(DiscAmount);

        TempMixedDiscountCopy.FindSet();
        repeat
            DiscAmount += ApplyMixDiscount(TempMixedDiscountCopy, TempMixedDiscountLine, TempSaleLinePOS);
        until TempMixedDiscountCopy.Next() = 0;

        exit(DiscAmount);
    end;

    local procedure CopyMixedDiscount(var TempMixedDiscount: Record "NPR Mixed Discount" temporary; var TempMixedDiscountCopy: Record "NPR Mixed Discount" temporary)
    begin
        if not TempMixedDiscountCopy.IsTemporary then
            exit;
        Clear(TempMixedDiscountCopy);
        TempMixedDiscountCopy.DeleteAll();

        if TempMixedDiscount.IsEmpty then
            exit;

        TempMixedDiscount.FindSet();
        repeat
            TempMixedDiscountCopy.Init();
            TempMixedDiscountCopy := TempMixedDiscount;
            TempMixedDiscountCopy.Insert();
        until TempMixedDiscount.Next() = 0;
    end;

    local procedure CopySaleLinePOS(var TempSaleLinePOS: Record "NPR POS Sale Line" temporary; var TempSaleLinePOSCopy: Record "NPR POS Sale Line" temporary)
    begin
        if not TempSaleLinePOSCopy.IsTemporary then
            exit;
        Clear(TempSaleLinePOSCopy);
        TempSaleLinePOSCopy.DeleteAll();

        if TempSaleLinePOS.IsEmpty then
            exit;

        TempSaleLinePOS.FindSet();
        repeat
            TempSaleLinePOSCopy.Init();
            TempSaleLinePOSCopy := TempSaleLinePOS;
            TempSaleLinePOSCopy.Insert();
        until TempSaleLinePOS.Next() = 0;
    end;

    local procedure FindBestMixMatch(var TempMixedDiscount: Record "NPR Mixed Discount" temporary; var TempMixedDiscountLine: Record "NPR Mixed Discount Line" temporary; var TempSaleLinePOS: Record "NPR POS Sale Line" temporary)
    var
        TempMixedDiscountCopy: Record "NPR Mixed Discount" temporary;
        TempSaleLinePOSCopy: Record "NPR POS Sale Line" temporary;
        DiscAmount: Decimal;
    begin
        Clear(TempMixedDiscount);
        TempMixedDiscount.SetRange("Mix Type", TempMixedDiscount."Mix Type"::Standard, TempMixedDiscount."Mix Type"::Combination);
        if TempMixedDiscount.Count() <= 1 then
            exit;

        TempMixedDiscount.FindSet();
        repeat
            CopySaleLinePOS(TempSaleLinePOS, TempSaleLinePOSCopy);
            DiscAmount := ApplyMixDiscount(TempMixedDiscount, TempMixedDiscountLine, TempSaleLinePOSCopy);
            TempSaleLinePOSCopy.SetRange("Discount Type", TempSaleLinePOSCopy."Discount Type"::Mix);
            TempSaleLinePOSCopy.SetRange("Discount Code", TempMixedDiscount.Code);
            TempSaleLinePOSCopy.CalcSums(Quantity);
            TempMixedDiscount."Actual Discount Amount" := DiscAmount;
            TempMixedDiscount."Actual Item Qty." := TempSaleLinePOSCopy.Quantity;
            TempMixedDiscount.Modify();
        until TempMixedDiscount.Next() = 0;

        Clear(TempMixedDiscount);
        CopyMixedDiscount(TempMixedDiscount, TempMixedDiscountCopy);

        TempMixedDiscountCopy.SetCurrentKey("Actual Discount Amount", "Actual Item Qty.");
        TempMixedDiscountCopy.Ascending(false);
        TempMixedDiscountCopy.SetRange("Mix Type", TempMixedDiscountCopy."Mix Type"::Standard, TempMixedDiscountCopy."Mix Type"::Combination);
        TempMixedDiscountCopy.FindSet();
        repeat
            CopySaleLinePOS(TempSaleLinePOS, TempSaleLinePOSCopy);
            DiscAmount := CalcTotalAppliedMixDisc(TempMixedDiscountCopy, TempMixedDiscountLine, TempSaleLinePOSCopy);
            TempSaleLinePOSCopy.SetRange("Discount Type", TempSaleLinePOSCopy."Discount Type"::Mix);
            TempSaleLinePOSCopy.SetRange("Discount Code", TempMixedDiscountCopy.Code);
            TempSaleLinePOSCopy.CalcSums(Quantity);

            TempMixedDiscount.Get(TempMixedDiscountCopy.Code);
            TempMixedDiscount."Actual Discount Amount" := DiscAmount;
            TempMixedDiscount."Actual Item Qty." := TempSaleLinePOSCopy.Quantity;
            TempMixedDiscount.Modify();
        until TempMixedDiscountCopy.Next() = 0;
    end;

    procedure GetOrInit(var DiscountPriority: Record "NPR Discount Priority")
    begin
        if DiscountPriority.Get(DiscSourceTableId()) then
            exit;

        DiscountPriority.Init();
        DiscountPriority."Table ID" := DiscSourceTableId();
        DiscountPriority.Priority := 1;
        DiscountPriority.Disabled := false;
        DiscountPriority."Discount Calc. Codeunit ID" := DiscCalcCodeunitId();
        DiscountPriority."Cross Line Calculation" := true;
        DiscountPriority.Insert(true);
    end;

    procedure GetNoSeries(): Code[20]
    var
        DiscountPriority: Record "NPR Discount Priority";
        NoSeriesCodeTok: Label 'MIX-DISC', Locked = true;
        NoSeriesDescriptionTok: Label 'Mixed Discount No. Series';
    begin
        GetOrInit(DiscountPriority);
        if DiscountPriority."Discount No. Series" = '' then // if not initialized via upgrade codeunit
            DiscountPriority.CreateNoSeries(NoSeriesCodeTok, NoSeriesDescriptionTok, false);

        exit(DiscountPriority."Discount No. Series");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sales Disc. Calc. Mgt.", 'InitDiscountPriority', '', true, true)]
    local procedure OnInitDiscountPriority(var DiscountPriority: Record "NPR Discount Priority")
    begin
        GetOrInit(DiscountPriority);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sales Disc. Calc. Mgt.", 'ApplyDiscount', '', true, true)]
    local procedure OnApplyDiscount(DiscountPriority: Record "NPR Discount Priority"; SalePOS: Record "NPR POS Sale"; var TempSaleLinePOS: Record "NPR POS Sale Line" temporary; Rec: Record "NPR POS Sale Line"; xRec: Record "NPR POS Sale Line"; LineOperation: Option Insert,Modify,Delete; RecalculateAllLines: Boolean)
    begin
        if not IsSubscribedDiscount(DiscountPriority) then
            exit;

        ApplyMixDiscounts(SalePOS, TempSaleLinePOS, Rec, RecalculateAllLines);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sales Disc. Calc. Mgt.", 'OnFindActiveSaleLineDiscounts', '', false, false)]
    local procedure OnFindActiveSaleLineDiscounts(var tmpDiscountPriority: Record "NPR Discount Priority" temporary; Rec: Record "NPR POS Sale Line"; xRec: Record "NPR POS Sale Line"; LineOperation: Option Insert,Modify,Delete)
    var
        MixedDiscountLine: Record "NPR Mixed Discount Line";
        IsActive: Boolean;
        DiscountPriority: Record "NPR Discount Priority";
    begin
        if not DiscountPriority.Get(DiscSourceTableId()) then
            exit;
        if not IsSubscribedDiscount(DiscountPriority) then
            exit;
        if not IsValidLineOperation() then
            exit;

        MixedDiscountLine.SetCurrentKey("Disc. Grouping Type", "No.", "Variant Code", "Starting Date", "Ending Date", "Starting Time", "Ending Time", Status);
        MixedDiscountLine.SetRange(Status, MixedDiscountLine.Status::Active);
        MixedDiscountLine.SetFilter("Starting Date", '<=%1|=%2', Today, 0D);
        MixedDiscountLine.SetFilter("Ending Date", '>=%1|=%2', Today, 0D);
        MixedDiscountLine.SetRange("Disc. Grouping Type", MixedDiscountLine."Disc. Grouping Type"::Item);
        MixedDiscountLine.SetRange("No.", Rec."No.");
        MixedDiscountLine.SetFilter("Variant Code", '%1|%2', '', Rec."Variant Code");
        IsActive := not MixedDiscountLine.IsEmpty();

        if not IsActive then begin
            MixedDiscountLine.SetRange("Variant Code");
            MixedDiscountLine.SetRange("Disc. Grouping Type", MixedDiscountLine."Disc. Grouping Type"::"Item Disc. Group");
            MixedDiscountLine.SetRange("No.", Rec."Item Disc. Group");
            IsActive := not MixedDiscountLine.IsEmpty();
        end;

        if not IsActive then begin
            MixedDiscountLine.SetRange("Disc. Grouping Type", MixedDiscountLine."Disc. Grouping Type"::"Item Group");
            MixedDiscountLine.SetRange("No.", Rec."Item Category Code");
            IsActive := not MixedDiscountLine.IsEmpty();
        end;

        if IsActive then begin
            tmpDiscountPriority.Init();
            tmpDiscountPriority := DiscountPriority;
            tmpDiscountPriority.Insert();
        end;
    end;

    local procedure IsValidLineOperation(): Boolean
    begin
        exit(true);
    end;

    local procedure IsSubscribedDiscount(DiscountPriority: Record "NPR Discount Priority"): Boolean
    begin
        if DiscountPriority.Disabled then
            exit(false);
        if DiscountPriority."Table ID" <> DiscSourceTableId() then
            exit(false);
        if (DiscountPriority."Discount Calc. Codeunit ID" <> 0) and (DiscountPriority."Discount Calc. Codeunit ID" <> DiscCalcCodeunitId()) then
            exit(false);

        exit(true);
    end;

    local procedure DiscSourceTableId(): Integer
    begin
        exit(DATABASE::"NPR Mixed Discount");
    end;

    local procedure DiscCalcCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR Mixed Discount Management");
    end;

    local procedure IsActiveNow(var MixedDiscount: Record "NPR Mixed Discount"): Boolean
    var
        MixedDiscountLine: Record "NPR Mixed Discount Line";
        CurrDate: Date;
        CurrTime: Time;
    begin
        if MixedDiscount."Mix Type" = MixedDiscount."Mix Type"::"Combination Part" then begin
            MixedDiscountLine.SetRange("Disc. Grouping Type", MixedDiscountLine."Disc. Grouping Type"::"Mix Discount");
            MixedDiscountLine.SetRange("No.", MixedDiscount.Code);
            MixedDiscountLine.SetRange(Status, MixedDiscountLine.Status::Active);
            if MixedDiscountLine.IsEmpty then
                exit(false);

            MixedDiscountLine.FindSet();
            repeat
                if not IsActiveLineNow(MixedDiscountLine) then
                    exit(true);
            until MixedDiscountLine.Next() = 0;
            exit(false);
        end;

        if MixedDiscount.Status <> MixedDiscount.Status::Active then
            exit(false);
        if MixedDiscount."Starting date" = 0D then
            exit(false);
        if MixedDiscount."Ending date" = 0D then
            exit(false);

        CurrDate := Today();
        CurrTime := Time;
        if MixedDiscount."Starting date" > CurrDate then
            exit(false);
        if MixedDiscount."Ending date" < CurrDate then
            exit(false);
        if (MixedDiscount."Starting date" = CurrDate) and (MixedDiscount."Starting time" > CurrTime) then
            exit(false);
        if (MixedDiscount."Ending date" = CurrDate) and (MixedDiscount."Ending time" < CurrTime) and (MixedDiscount."Ending time" <> 0T) then
            exit(false);
        if not HasActiveTimeInterval(MixedDiscount) then
            exit(false);

        exit(true);
    end;

    local procedure IsActiveLineNow(var MixedDiscountLine: Record "NPR Mixed Discount Line"): Boolean
    var
        MixedDiscount: Record "NPR Mixed Discount";
    begin
        if MixedDiscountLine.IsTemporary then
            exit(false);

        if not MixedDiscount.Get(MixedDiscountLine.Code) then
            exit(false);

        exit(IsActiveNow(MixedDiscount));
    end;

    local procedure HasActiveTimeInterval(MixedDiscount: Record "NPR Mixed Discount"): Boolean
    var
        MixedDiscountTimeInterval: Record "NPR Mixed Disc. Time Interv.";
        CheckTime: Time;
        CheckDate: Date;
    begin
        MixedDiscountTimeInterval.SetRange("Mix Code", MixedDiscount.Code);
        if MixedDiscountTimeInterval.IsEmpty then
            exit(true);

        CheckTime := Time;
        CheckDate := Today();
        MixedDiscountTimeInterval.FindSet();
        repeat
            if IsActiveTimeInterval(MixedDiscountTimeInterval, CheckTime, CheckDate) then
                exit(true);
        until MixedDiscountTimeInterval.Next() = 0;

        exit(false);
    end;

    local procedure IsActiveTimeInterval(MixedDiscountTimeInterval: Record "NPR Mixed Disc. Time Interv."; CheckTime: Time; CheckDate: Date): Boolean
    begin
        if not IsActiveDay(MixedDiscountTimeInterval, CheckDate) then
            exit(false);

        if (MixedDiscountTimeInterval."Start Time" = 0T) and (MixedDiscountTimeInterval."End Time" = 0T) then
            exit(true);

        if (MixedDiscountTimeInterval."Start Time" <= MixedDiscountTimeInterval."End Time") or (MixedDiscountTimeInterval."End Time" = 0T) then begin
            if CheckTime < MixedDiscountTimeInterval."Start Time" then
                exit(false);
            if MixedDiscountTimeInterval."End Time" = 0T then
                exit(true);
            exit(CheckTime <= MixedDiscountTimeInterval."End Time");
        end;

        exit((CheckTime >= MixedDiscountTimeInterval."Start Time") or (CheckTime <= MixedDiscountTimeInterval."End Time"));
    end;

    local procedure IsActiveDay(MixedDiscountTimeInterval: Record "NPR Mixed Disc. Time Interv."; CheckDate: Date): Boolean
    begin
        if MixedDiscountTimeInterval."Period Type" = MixedDiscountTimeInterval."Period Type"::"Every Day" then
            exit(true);

        case Date2DWY(CheckDate, 1) of
            1:
                exit(MixedDiscountTimeInterval.Monday);
            2:
                exit(MixedDiscountTimeInterval.Tuesday);
            3:
                exit(MixedDiscountTimeInterval.Wednesday);
            4:
                exit(MixedDiscountTimeInterval.Thursday);
            5:
                exit(MixedDiscountTimeInterval.Friday);
            6:
                exit(MixedDiscountTimeInterval.Saturday);
            7:
                exit(MixedDiscountTimeInterval.Sunday);
        end;
    end;

    local procedure GenerateTmpCustDiscGroupList()
    var
        CustDiscGroup: Record "Customer Discount Group";
    begin
        TempCustDiscGroup.Reset();
        if not TempCustDiscGroup.IsEmpty then
            exit;

        if CustDiscGroup.FindSet() then
            repeat
                TempCustDiscGroup := CustDiscGroup;
                TempCustDiscGroup.Insert();
            until CustDiscGroup.Next() = 0;

        TempCustDiscGroup.Init();
        TempCustDiscGroup.Code := '';
        if not TempCustDiscGroup.Find() then
            TempCustDiscGroup.Insert();
    end;
}