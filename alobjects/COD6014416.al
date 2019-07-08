codeunit 6014416 "Mixed Discount Management"
{
    // NPR4.00/JDH/20150122  CASE 204962 fix for line discount rounding when having a MIX discount type "Total".
    //                                  The Problem: 3 pcs for 10 Euro
    //                                  each line will then get the line amount 3.33 Euro, due to line rounding. (Total 9.99)
    //                                  the fix will make an accumulated sum with no rounding as the lines are updated with the Mix offer.
    //                                  when the no rounded and the rounded line amount "suddently" have a difference, the fix is activated
    //                                  it will then adjust the current line with the line difference (1 cent).
    //                                  thereby the lines will be 3.33, 3.33 and 3.34, giving a total of 10.00
    // VRT1.00/JDH /20150305  CASE 201022 Not possible to give negative discount (increasing the price)
    // NPR5.31/MHA /20170109  CASE 262903 Added Discount Type: Discount Amount and added Auxiliary functions to prevent code duplication: ApplyRoundingDiffDiscount(),CalcAmtInclVat(),CalcDiscPct()
    // NPR5.31/MHA /20170109  CASE 262903 Extended with Mix Type: Combination
    // NPR5.31/MHA /20170117  CASE 263093 Filter Dimension Filter replaced with "Customer Disc. Group Filter" in ActiveDiscount()
    // NPR5.31/MHA /20170120  CASE 262964 Added Discount Type: Lowest Unit Price Items per Min. Qty
    // NPR5.38/MHA /20171204  CASE 298276 Removed Discount Cache
    // NPR5.38/MHA /20171220  CASE 300637 Unit Price should be transfered directly on Sale Line POS
    // NPR5.40/MMV /20180213  CASE 294655 Performance optimization
    // NPR5.40/MHA /20180320  CASE 306304 Added "Total Amount Excl. VAT"
    // NPR5.43/MHA /20180518  CASE 308776 Items may only be included in 1 Mixed Discount
    // NPR5.43/JDH /20180703  CASE 321284 Changed the way a few fields was copyed, to avoid copying temporary values to the permanent record
    // NPR5.44/MMV /20180627  CASE 312154 Fixed incorrect cross line discount handling when different types collided.
    // NPR5.45/MHA /20180802  CASE 323716 Replaced Time filter with DiscountLineActive() in FindMixImpact() and completely removed from OnFindActiveSaleLineDiscounts()
    // NPR5.45/MHA /20180820  CASE 323568 Added Active Time Intervals functionality
    // NPR5.45/MMV /20180828  CASE 326466 Separated the scope of PotentialMixes function and MatchingMixes function.
    //                                    Fixed wrong variable being used in [312154] change.
    // NPR5.45/MMV /20180904  CASE 327304 Handle variant code wildcard correctly.
    // NPR5.45/MMV /20180905  CASE 327277 Fixed combination mixes in the initial scoping.
    // NPR5.46/MMV /20181009  CASE 331487 Fixed incorrect unit price assignment when applying mix to lines.


    trigger OnRun()
    begin
    end;

    var
        GLSetup: Record "General Ledger Setup";

    procedure ApplyMixDiscounts(SalePOS: Record "Sale POS";var TempSaleLinePOS: Record "Sale Line POS" temporary;TriggerRec: Record "Sale Line POS";RecalculateAllLines: Boolean): Boolean
    var
        TempMixedDiscount: Record "Mixed Discount" temporary;
        TempMixedDiscountLine: Record "Mixed Discount Line" temporary;
        DiscAmount: Decimal;
    begin
        GLSetup.Get;
        GLSetup.TestField("Amount Rounding Precision");

        //-NPR5.44 [312154]
        //FindPotentiallyImpactedMixesAndLines(TempSaleLinePOS, TriggerRec, TempMixedDiscount);
        FindPotentiallyImpactedMixesAndLines(TempSaleLinePOS, TriggerRec, TempMixedDiscount, RecalculateAllLines);
        //+NPR5.44 [312154]

        if not FindMatchingMixedDiscounts(TempMixedDiscount,TempMixedDiscountLine,TempSaleLinePOS) then begin
          Clear(TempSaleLinePOS);
          exit;
        end;
        //+NPR5.40 [294655]

        TempMixedDiscount.Reset;
        TempMixedDiscount.SetRange("Mix Type",TempMixedDiscount."Mix Type"::Standard,TempMixedDiscount."Mix Type"::Combination);
        //-NPR5.40 [294655]
        // IF TempMixedDiscount.ISEMPTY THEN
        //  EXIT;
        if TempMixedDiscount.IsEmpty then begin
          Clear(TempSaleLinePOS);
          exit;
        end;

        //+NPR5.40 [294655]

        FindBestMixMatch(TempMixedDiscount,TempMixedDiscountLine,TempSaleLinePOS);

        TempMixedDiscount.SetCurrentKey("Actual Discount Amount","Actual Item Qty.");
        TempMixedDiscount.SetRange("Mix Type",TempMixedDiscount."Mix Type"::Standard,TempMixedDiscount."Mix Type"::Combination);
        TempMixedDiscount.Ascending(false);
        TempMixedDiscount.FindSet;
        repeat
          ApplyMixDiscount(TempMixedDiscount,TempMixedDiscountLine,TempSaleLinePOS);
        until (TempMixedDiscount.Next = 0);

        //-NPR5.40 [294655]
        Clear(TempSaleLinePOS);
        //+NPR5.40 [294655]
    end;

    local procedure "--- Impact"()
    begin
    end;

    local procedure FindPotentiallyImpactedMixesAndLines(var TempSaleLinePOS: Record "Sale Line POS" temporary;Rec: Record "Sale Line POS";var tmpImpactedMixHeaders: Record "Mixed Discount" temporary;RecalculateAllLines: Boolean)
    var
        SalePOS: Record "Sale POS";
        MixedDiscountLine: Record "Mixed Discount Line";
        tmpImpactedItems: Record "Item Variant" temporary;
        tmpImpactedItemGroups: Record "Item Discount Group" temporary;
        tmpImpactedItemDiscGroups: Record "Item Discount Group" temporary;
    begin
        // This function narrows the scope based on static parameters (=those assumed to not change inside an ongoing POS sale ie. "Item Group" for an item line)
        // For parameters like time and customer no., these are kept in scope here to allow them to go from enabled -> disabled (because they'll trigger "Discount Modified" := TRUE here),
        // but will be filtered out later in FindMatchingMixDiscounts()

        //-NPR5.40 [294655]
        TempSaleLinePOS.SetRange("Discount Type", TempSaleLinePOS."Discount Type"::" ");
        if not TempSaleLinePOS.FindSet then
          exit;

        //-NPR5.45 [323716]
        if not SalePOS.Get(TempSaleLinePOS."Register No.",TempSaleLinePOS."Sales Ticket No.") then
          exit;
        //+NPR5.45 [323716]
        //-NPR5.44 [312154]
        if RecalculateAllLines then begin
          repeat
            //-NPR5.45 [326466]
            //FindMixImpact(MixedDiscountLine."Disc. Grouping Type"::Item, Rec."No.", TempSaleLinePOS."Variant Code", tmpImpactedMixHeaders, tmpImpactedItems, tmpImpactedItemGroups, tmpImpactedItemDiscGroups);
            FindMixGroupingImpact(MixedDiscountLine."Disc. Grouping Type"::Item, TempSaleLinePOS."No.", TempSaleLinePOS."Variant Code", tmpImpactedMixHeaders, tmpImpactedItems, tmpImpactedItemGroups, tmpImpactedItemDiscGroups);
            //+NPR5.45 [326466]
            FindMixGroupingImpact(MixedDiscountLine."Disc. Grouping Type"::"Item Disc. Group", TempSaleLinePOS."Item Disc. Group", '', tmpImpactedMixHeaders, tmpImpactedItems, tmpImpactedItemGroups, tmpImpactedItemDiscGroups);
            FindMixGroupingImpact(MixedDiscountLine."Disc. Grouping Type"::"Item Group", TempSaleLinePOS."Item Group", '', tmpImpactedMixHeaders, tmpImpactedItems, tmpImpactedItemGroups, tmpImpactedItemDiscGroups);
          until TempSaleLinePOS.Next = 0;
        end else begin
        //+NPR5.44 [312154]
          FindMixGroupingImpact(MixedDiscountLine."Disc. Grouping Type"::Item, Rec."No.", Rec."Variant Code", tmpImpactedMixHeaders, tmpImpactedItems, tmpImpactedItemGroups, tmpImpactedItemDiscGroups);
          FindMixGroupingImpact(MixedDiscountLine."Disc. Grouping Type"::"Item Disc. Group", Rec."Item Disc. Group", '', tmpImpactedMixHeaders, tmpImpactedItems, tmpImpactedItemGroups, tmpImpactedItemDiscGroups);
          FindMixGroupingImpact(MixedDiscountLine."Disc. Grouping Type"::"Item Group", Rec."Item Group", '', tmpImpactedMixHeaders, tmpImpactedItems, tmpImpactedItemGroups, tmpImpactedItemDiscGroups);
        //-NPR5.44 [312154]
        end;

        TempSaleLinePOS.FindSet;
        //+NPR5.44 [312154]
        repeat
          if HasImpact(tmpImpactedItems,tmpImpactedItemGroups,tmpImpactedItemDiscGroups,TempSaleLinePOS) then begin
            TempSaleLinePOS."Discount Calculated" := true;
            TempSaleLinePOS.Modify;
            TempSaleLinePOS.Mark(true);
          end;
        until TempSaleLinePOS.Next = 0;
        TempSaleLinePOS.MarkedOnly(true);
        //+NPR5.40 [294655]
    end;

    local procedure FindMixGroupingImpact(GroupingType: Option Item,"Item Group","Item Disc. Group","Mix Discount";No: Code[20];VariantCode: Code[10];var tmpImpactedMixHeaders: Record "Mixed Discount" temporary;var tmpImpactedItems: Record "Item Variant" temporary;var tmpImpactedItemGroups: Record "Item Discount Group" temporary;var tmpImpactedItemDiscGroups: Record "Item Discount Group" temporary)
    var
        MixedDiscountLine: Record "Mixed Discount Line";
        MixedDiscountHeader: Record "Mixed Discount";
    begin
        //-NPR5.40 [294655]
        MixedDiscountLine.SetCurrentKey("Disc. Grouping Type","No.","Variant Code","Starting Date","Ending Date","Starting Time","Ending Time",Status);
        MixedDiscountLine.SetRange("Disc. Grouping Type", GroupingType);
        MixedDiscountLine.SetRange("No.", No);
        MixedDiscountLine.SetFilter("Variant Code", '%1|%2', VariantCode, '');
        MixedDiscountLine.SetFilter("Starting Date",'<=%1|=%2',Today,0D);
        //-NPR5.45 [323716]
        // MixedDiscountLine.SETFILTER("Starting Time",'<=%1|=%2',TIME,0T);
        // MixedDiscountLine.SETFILTER("Ending Date", '>=%1|=%2',TODAY,0D);
        // MixedDiscountLine.SETFILTER("Starting Time",'>=%1|=%2',TIME,0T);
        MixedDiscountLine.SetFilter("Ending Date", '>=%1|=%2',Today,0D);
        //+NPR5.45 [323716]
        MixedDiscountLine.SetRange(Status,MixedDiscountLine.Status::Active);

        if MixedDiscountLine.FindSet then
          repeat
            //-NPR5.45 [327277]
        //    IF NOT tmpImpactedMixHeaders.GET(MixedDiscountLine.Code) THEN BEGIN
        //      MixedDiscountHeader.GET(MixedDiscountLine.Code);
        //      tmpImpactedMixHeaders := MixedDiscountHeader;
        //      tmpImpactedMixHeaders.INSERT;
        //      //-NPR5.45 [323716]
        //      //FindMixLineImpact(MixedDiscountLine.Code, tmpImpactedMixHeaders, tmpImpactedItems, tmpImpactedItemGroups, tmpImpactedItemDiscGroups);
        //      FindMixLineImpact(SalePOS, MixedDiscountLine.Code, tmpImpactedMixHeaders, tmpImpactedItems, tmpImpactedItemGroups, tmpImpactedItemDiscGroups);
        //      //+NPR5.45 [323716]
        //    END;
            FindMixHeaderImpact(MixedDiscountLine.Code, tmpImpactedMixHeaders, tmpImpactedItems, tmpImpactedItemGroups, tmpImpactedItemDiscGroups);
            //+NPR5.45 [327277]
          until MixedDiscountLine.Next = 0;
        //+NPR5.40 [294655]
    end;

    local procedure FindMixHeaderImpact(MixDiscountCode: Code[20];var tmpImpactedMixHeaders: Record "Mixed Discount" temporary;var tmpImpactedItems: Record "Item Variant" temporary;var tmpImpactedItemGroups: Record "Item Discount Group" temporary;var tmpImpactedItemDiscGroups: Record "Item Discount Group" temporary)
    var
        MixedDiscount: Record "Mixed Discount";
        MixedDiscountLine: Record "Mixed Discount Line";
    begin
        //-NPR5.45 [327277]
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
        tmpImpactedMixHeaders.Insert;

        FindMixLineImpact(MixDiscountCode, tmpImpactedMixHeaders, tmpImpactedItems, tmpImpactedItemGroups, tmpImpactedItemDiscGroups);
        FindMixGroupingImpact(MixedDiscountLine."Disc. Grouping Type"::"Mix Discount", MixDiscountCode, '', tmpImpactedMixHeaders, tmpImpactedItems, tmpImpactedItemGroups, tmpImpactedItemDiscGroups);
        //+NPR5.45 [327277]
    end;

    local procedure FindMixLineImpact(MixDiscountCode: Code[20];var tmpImpactedMixHeaders: Record "Mixed Discount" temporary;var tmpImpactedItems: Record "Item Variant" temporary;var tmpImpactedItemGroups: Record "Item Discount Group" temporary;var tmpImpactedItemDiscGroups: Record "Item Discount Group" temporary)
    var
        MixedDiscountLine: Record "Mixed Discount Line";
        MixedDiscountHeader: Record "Mixed Discount";
    begin
        //-NPR5.40 [294655]
        MixedDiscountLine.SetRange(Code, MixDiscountCode);
        if not MixedDiscountLine.FindSet then
          exit;

        repeat
          case MixedDiscountLine."Disc. Grouping Type" of
            MixedDiscountLine."Disc. Grouping Type"::Item :
              if not tmpImpactedItems.Get(MixedDiscountLine."No.", MixedDiscountLine."Variant Code") then begin
                tmpImpactedItems."Item No." := MixedDiscountLine."No.";
                tmpImpactedItems.Code := MixedDiscountLine."Variant Code";
                tmpImpactedItems.Insert;
                //-NPR5.45 [327277]
                FindMixGroupingImpact(MixedDiscountLine."Disc. Grouping Type", MixedDiscountLine."No.", MixedDiscountLine."Variant Code", tmpImpactedMixHeaders, tmpImpactedItems, tmpImpactedItemGroups, tmpImpactedItemDiscGroups);
                //Check := TRUE;
                //+NPR5.45 [327277]
              end;
            MixedDiscountLine."Disc. Grouping Type"::"Item Disc. Group" :
              if not tmpImpactedItemDiscGroups.Get(MixedDiscountLine."No.") then begin
                tmpImpactedItemDiscGroups.Code := MixedDiscountLine."No.";
                tmpImpactedItemDiscGroups.Insert;
                //-NPR5.45 [327277]
                FindMixGroupingImpact(MixedDiscountLine."Disc. Grouping Type", MixedDiscountLine."No.", MixedDiscountLine."Variant Code", tmpImpactedMixHeaders, tmpImpactedItems, tmpImpactedItemGroups, tmpImpactedItemDiscGroups);
                //Check := TRUE;
                //+NPR5.45 [327277]
              end;
            MixedDiscountLine."Disc. Grouping Type"::"Item Group" :
              if not tmpImpactedItemGroups.Get(MixedDiscountLine."No.") then begin
                tmpImpactedItemGroups.Code := MixedDiscountLine."No.";
                tmpImpactedItemGroups.Insert;
                //-NPR5.45 [327277]
                FindMixGroupingImpact(MixedDiscountLine."Disc. Grouping Type", MixedDiscountLine."No.", MixedDiscountLine."Variant Code", tmpImpactedMixHeaders, tmpImpactedItems, tmpImpactedItemGroups, tmpImpactedItemDiscGroups);
                //Check := TRUE;
                //+NPR5.45 [327277]
              end;
            MixedDiscountLine."Disc. Grouping Type"::"Mix Discount" :
              //-NPR5.45 [327277]
              FindMixHeaderImpact(MixedDiscountLine."No.", tmpImpactedMixHeaders, tmpImpactedItems, tmpImpactedItemGroups, tmpImpactedItemDiscGroups);
        //      IF NOT tmpImpactedMixHeaders.GET(MixedDiscountLine."No.") THEN BEGIN
        //        MixedDiscountHeader.GET(MixedDiscountLine."No.");
        //        tmpImpactedMixHeaders := MixedDiscountHeader;
        //        tmpImpactedMixHeaders.INSERT;
        //        //-NPR5.45 [323716]
        //        //FindMixLineImpact(MixedDiscountLine."No.", tmpImpactedMixHeaders, tmpImpactedItems, tmpImpactedItemGroups, tmpImpactedItemDiscGroups);
        //        FindMixLineImpact(SalePOS,MixedDiscountLine."No.", tmpImpactedMixHeaders, tmpImpactedItems, tmpImpactedItemGroups, tmpImpactedItemDiscGroups);
        //        //+NPR5.45 [323716]
        //      END;
              //+NPR5.45 [327277]
          end;
        //-NPR5.45 [327277]
        //  IF Check THEN
        //    //-NPR5.45 [323716]
        //    //FindMixImpact(MixedDiscountLine."Disc. Grouping Type", MixedDiscountLine."No.", MixedDiscountLine."Variant Code", tmpImpactedMixHeaders, tmpImpactedItems, tmpImpactedItemGroups, tmpImpactedItemDiscGroups);
        //    FindMixImpact(SalePOS,MixedDiscountLine."Disc. Grouping Type", MixedDiscountLine."No.", MixedDiscountLine."Variant Code", tmpImpactedMixHeaders, tmpImpactedItems, tmpImpactedItemGroups, tmpImpactedItemDiscGroups);
        //    //+NPR5.45 [323716]
        //+NPR5.45 [327277]
        until MixedDiscountLine.Next = 0;
        //+NPR5.40 [294655]
    end;

    local procedure HasImpact(var tmpImpactedItems: Record "Item Variant" temporary;var tmpImpactedItemGroups: Record "Item Discount Group" temporary;var tmpImpactedItemDiscGroups: Record "Item Discount Group" temporary;var TempSaleLinePOS: Record "Sale Line POS" temporary): Boolean
    begin
        //-NPR5.40 [294655]
        if tmpImpactedItems.Get(TempSaleLinePOS."No.", TempSaleLinePOS."Variant Code") then
          exit(true);

        //-NPR5.45 [327304]
        if tmpImpactedItems.Get(TempSaleLinePOS."No.", '') then
          exit(true);
        //+NPR5.45 [327304]

        if tmpImpactedItemGroups.Get(TempSaleLinePOS."Item Group") then
          exit(true);

        exit(tmpImpactedItemDiscGroups.Get(TempSaleLinePOS."Item Disc. Group"));
        //+NPR5.40 [294655]
    end;

    local procedure "--- Calc Discount"()
    begin
    end;

    procedure CalcLineDiscAmount(var TempMixedDiscount: Record "Mixed Discount" temporary;var TempMixedDiscountLine: Record "Mixed Discount Line" temporary;BatchQty: Decimal;TotalQty: Decimal;TotalVATAmount: Decimal;TotalAmount: Decimal;var TempSaleLinePOSApply: Record "Sale Line POS" temporary) LineDiscAmount: Decimal
    var
        TotalAmountAfterDisc: Decimal;
        AvgDiscPct: Decimal;
        DiscQty: Decimal;
        RemainingQty: Decimal;
        UnitPrice: Decimal;
    begin
        //-NPR5.31 [262904]
        if TotalAmount <= 0 then
          exit(0);

        case TempMixedDiscount."Discount Type" of
          TempMixedDiscount."Discount Type"::"Total Amount per Min. Qty.":
            begin
              TotalAmountAfterDisc := BatchQty * TempMixedDiscount."Total Amount";
              AvgDiscPct := 1 - (TotalAmountAfterDisc / TotalAmount);
              LineDiscAmount := TempSaleLinePOSApply."Unit Price" * TempSaleLinePOSApply."MR Anvendt antal" * AvgDiscPct;
              //-NPR5.40 [306304]
              if AmountExclVat(TempMixedDiscount) then begin
                AvgDiscPct := 1 - (TotalAmountAfterDisc / (TotalAmount - TotalVATAmount));
                UnitPrice := TempSaleLinePOSApply."Unit Price" / (1 + TempSaleLinePOSApply."VAT %" / 100);
                LineDiscAmount := UnitPrice * TempSaleLinePOSApply."MR Anvendt antal" * AvgDiscPct;
              end;
              //+NPR5.40 [306304]
            end;
          TempMixedDiscount."Discount Type"::"Total Discount %":
            begin
              AvgDiscPct := TempMixedDiscount."Total Discount %" / 100;
              LineDiscAmount := TempSaleLinePOSApply."Unit Price" * TempSaleLinePOSApply."MR Anvendt antal" * AvgDiscPct;
            end;
          //-NPR5.31 [262903]
          TempMixedDiscount."Discount Type"::"Total Discount Amt. per Min. Qty.":
            begin
              TotalAmountAfterDisc := TotalAmount - BatchQty * TempMixedDiscount."Total Discount Amount";
              AvgDiscPct := 1 - (TotalAmountAfterDisc / TotalAmount);
              LineDiscAmount := TempSaleLinePOSApply."Unit Price" * TempSaleLinePOSApply."MR Anvendt antal" * AvgDiscPct;
            end;
          //+NPR5.31 [262903]
          //-NPR5.31 [262964]
          TempMixedDiscount."Discount Type"::"Priority Discount per Min. Qty":
            begin
              AvgDiscPct := TempMixedDiscount."Item Discount %" / 100;
              LineDiscAmount := TempSaleLinePOSApply."Unit Price" * TempSaleLinePOSApply."Invoice (Qty)" * AvgDiscPct;
            end;
          //+NPR5.31 [262964]
        end;
        if TempMixedDiscount.Lot then begin
          TempMixedDiscountLine.Get(TempSaleLinePOSApply."Discount Code",TempSaleLinePOSApply."Sales Document Type",TempSaleLinePOSApply."Sales Document No.",TempSaleLinePOSApply."Retail Document No.");
          if TempMixedDiscountLine.Quantity = 0 then
            exit(0);
          //LineDiscAmount := LineDiscAmount * (TempSaleLinePOSApply."MR Anvendt antal" / TempMixedDiscountLine.Quantity);
        end;

        LineDiscAmount := Round(LineDiscAmount,GLSetup."Amount Rounding Precision");
        exit(LineDiscAmount);
        //+NPR5.31 [262904]
    end;

    procedure CalcTotalDiscAmount(var TempMixedDiscount: Record "Mixed Discount" temporary;BatchQty: Decimal;TotalVATAmount: Decimal;TotalAmount: Decimal;var TempPriorityBuffer: Record "Mixed Discount Priority Buffer" temporary) TotalDiscAmount: Decimal
    var
        TotalAmountAfterDisc: Decimal;
        AvgDiscPct: Decimal;
        ItemDiscQty: Decimal;
        DiscQty: Decimal;
        TotalDiscQty: Decimal;
    begin
        //-NPR5.31 [262904]
        if TotalAmount <= 0 then
          exit(0);

        case TempMixedDiscount."Discount Type" of
          TempMixedDiscount."Discount Type"::"Total Amount per Min. Qty.":
            begin
              TotalAmountAfterDisc := BatchQty * TempMixedDiscount."Total Amount";
              TotalDiscAmount := TotalAmount - TotalAmountAfterDisc;
              //-NPR5.40 [306304]
              if AmountExclVat(TempMixedDiscount)then
                TotalDiscAmount -= TotalVATAmount;
              //+NPR5.40 [306304]
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
              TempPriorityBuffer.FindSet;
              repeat
                DiscQty := TempPriorityBuffer.Quantity;
                if DiscQty > ItemDiscQty - TotalDiscQty then
                  DiscQty := ItemDiscQty - TotalDiscQty;
                TotalDiscQty += DiscQty;
                TotalDiscAmount += DiscQty * TempPriorityBuffer."Unit Price" * (TempMixedDiscount."Item Discount %" / 100);
              until (TempPriorityBuffer.Next = 0) or (TotalDiscQty >= ItemDiscQty);
            end;
        end;

        TotalDiscAmount:= Round(TotalDiscAmount,GLSetup."Amount Rounding Precision");
        exit(TotalDiscAmount);
        //+NPR5.31 [262904]
    end;

    procedure CalcExpectedDiscAmount(MixedDiscount: Record "Mixed Discount";MaxDisc: Boolean) ExpectedDiscAmount: Decimal
    var
        TempPriorityBuffer: Record "Mixed Discount Priority Buffer" temporary;
        TotalAmount: Decimal;
    begin
        //-NPR5.31 [262904]
        TotalAmount := CalcExpectedAmountPerBatch(MixedDiscount,MaxDisc,TempPriorityBuffer);
        //-NPR5.40 [306304]
        //ExpectedDiscAmount := CalcTotalDiscAmount(MixedDiscount,1,TotalAmount,TempPriorityBuffer);
        ExpectedDiscAmount := CalcTotalDiscAmount(MixedDiscount,1,0,TotalAmount,TempPriorityBuffer);
        //+NPR5.40 [306304]
        exit(ExpectedDiscAmount);
        //+NPR5.31 [262904]
    end;

    procedure CalcExpectedAmountPerBatch(MixedDiscount: Record "Mixed Discount";MaxAmount: Boolean;var TempPriorityBuffer: Record "Mixed Discount Priority Buffer" temporary) TotalAmount: Decimal
    var
        MixedDiscountPart: Record "Mixed Discount";
        MixedDiscountLine: Record "Mixed Discount Line";
    begin
        //-NPR5.31 [262904]
        if MixedDiscount."Mix Type" = MixedDiscount."Mix Type"::Combination then begin
          MixedDiscountLine.SetRange(Code,MixedDiscount.Code);
          MixedDiscountLine.SetRange("Disc. Grouping Type",MixedDiscountLine."Disc. Grouping Type"::"Mix Discount");
          if MixedDiscountLine.IsEmpty then
            exit(0);

          MixedDiscountLine.FindSet;
          repeat
            if MixedDiscountPart.Get(MixedDiscountLine."No.") then
              TotalAmount += CalcExpectedAmountPerBatch(MixedDiscountPart,MaxAmount,TempPriorityBuffer);
          until MixedDiscountLine.Next = 0;
          exit(TotalAmount);
        end;

        MixedDiscountLine.SetRange(Code,MixedDiscount.Code);
        MixedDiscountLine.SetFilter("Unit price",'>%1',0);
        MixedDiscountLine.SetRange("Disc. Grouping Type",MixedDiscountLine."Disc. Grouping Type"::Item,MixedDiscountLine."Disc. Grouping Type"::"Item Disc. Group");
        if not MixedDiscountLine.FindFirst then
          exit(0);

        if MixedDiscount.Lot then begin
          repeat
            MixedDiscountLine.CalcFields("Unit price");
            TotalAmount += MixedDiscountLine."Unit price" * MixedDiscountLine.Quantity;

            TransferMixedDiscountLine2PriorityBuffer(MixedDiscountLine,TempPriorityBuffer);
          until MixedDiscountLine.Next = 0;

          exit(TotalAmount);
        end;

        repeat
          MixedDiscountLine.CalcFields("Unit price");
          if MaxAmount then
            MixedDiscountLine.SetFilter("Unit price",'>%1',MixedDiscountLine."Unit price")
          else
            MixedDiscountLine.SetFilter("Unit price",'<%1',MixedDiscountLine."Unit price");
        until not MixedDiscountLine.FindFirst;

        MixedDiscountLine.CalcFields("Unit price");
        TotalAmount := MixedDiscountLine."Unit price" * MixedDiscount."Min. Quantity";

        MixedDiscountLine.Quantity := MixedDiscount."Min. Quantity";
        TransferMixedDiscountLine2PriorityBuffer(MixedDiscountLine,TempPriorityBuffer);

        exit(TotalAmount);
        //+NPR5.31 [262904]
    end;

    local procedure TransferSaleLinePOS2PriorityBuffer(var TempSaleLinePOS: Record "Sale Line POS" temporary;var TempMixedDiscount: Record "Mixed Discount" temporary;var TempMixedDiscountLine: Record "Mixed Discount Line" temporary;var TempPriorityBuffer: Record "Mixed Discount Priority Buffer" temporary): Boolean
    var
        Priority: Decimal;
        Qty: Decimal;
    begin
        //-NPR5.31 [262904]
        //-NPR5.40 [294655]
        //TempSaleLinePOS.SETRANGE(Type,TempSaleLinePOS.Type::Item);
        //+NPR5.40 [294655]
        if TempSaleLinePOS.IsEmpty then
          exit(false);

        TempPriorityBuffer.DeleteAll;

        TempSaleLinePOS.FindSet;
        repeat
          Priority := FindPriority(TempMixedDiscount,TempMixedDiscountLine,TempSaleLinePOS);
          if TempPriorityBuffer.Get(Priority,TempSaleLinePOS."Unit Price",TempSaleLinePOS."No.",TempSaleLinePOS."Variant Code") then begin
            TempPriorityBuffer.Quantity += TempSaleLinePOS.Quantity;
            TempPriorityBuffer.Modify;
          end else begin
            TempPriorityBuffer.Init;
            TempPriorityBuffer.Priority := Priority;
            TempPriorityBuffer."Unit Price" := TempSaleLinePOS."Unit Price";
            TempPriorityBuffer."Item No." := TempSaleLinePOS."No.";
            TempPriorityBuffer."Variant Code" := TempSaleLinePOS."Variant Code";
            TempPriorityBuffer.Quantity := TempSaleLinePOS.Quantity;
            TempPriorityBuffer.Insert;
          end;
        until TempSaleLinePOS.Next = 0;

        exit(true);
        //+NPR5.31 [262904]
    end;

    local procedure TransferMixedDiscountLine2PriorityBuffer(var TempMixedDiscountLine: Record "Mixed Discount Line" temporary;var TempPriorityBuffer: Record "Mixed Discount Priority Buffer" temporary)
    var
        Qty: Decimal;
    begin
        //-NPR5.31 [262904]
        if TempMixedDiscountLine."Disc. Grouping Type" <> TempMixedDiscountLine."Disc. Grouping Type"::Item then
          exit;

        if TempPriorityBuffer.Get(TempMixedDiscountLine.Priority,TempMixedDiscountLine."Unit price",TempMixedDiscountLine."No.",TempMixedDiscountLine."Variant Code") then begin
          TempPriorityBuffer.Quantity += TempMixedDiscountLine.Quantity;
          TempPriorityBuffer.Modify;
          exit;
        end;

        TempPriorityBuffer.Init;
        TempPriorityBuffer.Priority := TempMixedDiscountLine.Priority;
        TempPriorityBuffer."Unit Price" := TempMixedDiscountLine."Unit price";
        TempPriorityBuffer."Item No." := TempMixedDiscountLine."No.";
        TempPriorityBuffer."Variant Code" := TempMixedDiscountLine."Variant Code";
        TempPriorityBuffer.Quantity := TempMixedDiscountLine.Quantity;
        TempPriorityBuffer.Insert;
        //+NPR5.31 [262904]
    end;

    local procedure TransferHighestPriorityBuffer(var TempMixedDiscount: Record "Mixed Discount" temporary;BatchQty: Decimal;var TempPriorityBuffer: Record "Mixed Discount Priority Buffer" temporary;var TempPriorityBufferHigh: Record "Mixed Discount Priority Buffer" temporary)
    var
        DiscQty: Decimal;
        TotalDiscQty: Decimal;
    begin
        //-NPR5.31 [262964]
        TempPriorityBufferHigh.DeleteAll;
        if TempMixedDiscount."Discount Type" <> TempMixedDiscount."Discount Type"::"Priority Discount per Min. Qty" then
          exit;
        if TempPriorityBuffer.IsEmpty then
          exit;

        TotalDiscQty := TempMixedDiscount."Item Discount Qty." * BatchQty;
        TempPriorityBuffer.FindSet;
        repeat
          TempPriorityBufferHigh.Init;
          TempPriorityBufferHigh := TempPriorityBuffer;
          if TempPriorityBufferHigh.Quantity + DiscQty > TotalDiscQty then
            TempPriorityBufferHigh.Quantity := TotalDiscQty - DiscQty;
          TempPriorityBufferHigh.Insert;

          DiscQty += TempPriorityBufferHigh.Quantity;
        until (TempPriorityBuffer.Next = 0) or (DiscQty >= TotalDiscQty);
        //+NPR5.31 [262964]
    end;

    local procedure "--- Apply"()
    begin
    end;

    local procedure AdjustBatchQty(var BatchQty: Decimal;var TempMixedDiscount: Record "Mixed Discount" temporary;var TempMixedDiscountLine: Record "Mixed Discount Line" temporary;var TempSaleLinePOSApply: Record "Sale Line POS" temporary)
    var
        TempSaleLinePOSApplyCopy: Record "Sale Line POS" temporary;
        TempSaleLinePOSApplyNew: Record "Sale Line POS" temporary;
        QtyToApply: Decimal;
    begin
        //-NPR5.31 [262904]
        TempSaleLinePOSApply.Reset;
        if BatchQty < 1 then begin
          TempSaleLinePOSApply.DeleteAll;
          exit;
        end;
        if (TempMixedDiscount."Discount Type" = TempMixedDiscount."Discount Type"::"Priority Discount per Min. Qty") then
          BatchQty := Round(BatchQty,1,'<');

        TempSaleLinePOSApplyCopy.Copy(TempSaleLinePOSApply,true);
        Clear(TempMixedDiscountLine);
        TempMixedDiscountLine.SetCurrentKey(Priority);
        if TempMixedDiscountLine.IsEmpty then
          exit;

        if not TempMixedDiscount.Lot then
          QtyToApply := Round(TempMixedDiscount.CalcMinQty() * BatchQty,0.00001);

        TempMixedDiscountLine.FindSet;
        repeat
          FilterSaleLinePOS(TempMixedDiscountLine,TempSaleLinePOSApplyCopy);
          TempSaleLinePOSApplyCopy.SetRange("Discount Type");
          TempSaleLinePOSApplyCopy.SetRange("Discount Code");
          if TempMixedDiscount.Lot then
            QtyToApply := Round(TempMixedDiscountLine.Quantity * BatchQty,0.00001);
          AdjustBatchQtyItems(BatchQty,QtyToApply,TempMixedDiscountLine,TempSaleLinePOSApplyCopy,TempSaleLinePOSApplyNew);
        until TempMixedDiscountLine.Next = 0;
        TempSaleLinePOSApply.Copy(TempSaleLinePOSApplyNew,true);
        //+NPR5.31 [262904]
    end;

    local procedure AdjustBatchQtyItems(BatchQty: Decimal;var QtyToApply: Decimal;var TempMixedDiscountLine: Record "Mixed Discount Line" temporary;var TempSaleLinePOSApplyCopy: Record "Sale Line POS" temporary;var TempSaleLinePOSApplyNew: Record "Sale Line POS" temporary)
    var
        AppliedQty: Decimal;
    begin
        //-NPR5.31 [262904]
        if TempSaleLinePOSApplyCopy.IsEmpty then
          exit;

        TempSaleLinePOSApplyCopy.FindSet;
        repeat
          if QtyToApply > 0 then begin
            TempSaleLinePOSApplyNew.Init;
            TempSaleLinePOSApplyNew := TempSaleLinePOSApplyCopy;

            if QtyToApply < TempSaleLinePOSApplyNew."MR Anvendt antal" then
              TempSaleLinePOSApplyNew."MR Anvendt antal" := QtyToApply;
            if QtyToApply > TempSaleLinePOSApplyNew."MR Anvendt antal" then begin
              TempSaleLinePOSApplyNew."MR Anvendt antal" := TempSaleLinePOSApplyNew.Quantity;
              if TempSaleLinePOSApplyNew.Quantity > QtyToApply then
                TempSaleLinePOSApplyNew."MR Anvendt antal" -= TempSaleLinePOSApplyNew.Quantity - QtyToApply;
            end;
            //-NPR5.31 [262964]
            TempSaleLinePOSApplyNew."Invoice (Qty)" := TempSaleLinePOSApplyNew."MR Anvendt antal";
            //+NPR5.31 [262964]
            TempSaleLinePOSApplyNew."Amount Including VAT" := TempSaleLinePOSApplyNew."Unit Price" * TempSaleLinePOSApplyNew."MR Anvendt antal";
            TempSaleLinePOSApplyNew.Insert;

            QtyToApply -= TempSaleLinePOSApplyCopy."MR Anvendt antal";
          end;
          TempSaleLinePOSApplyCopy.Delete;
        until TempSaleLinePOSApplyCopy.Next = 0;
        //+NPR5.31 [262904]
    end;

    local procedure AdjustDiscQty(BatchQty: Decimal;var TempMixedDiscount: Record "Mixed Discount" temporary;var TempMixedDiscountLine: Record "Mixed Discount Line" temporary;var TempSaleLinePOSApply: Record "Sale Line POS" temporary)
    var
        TempSaleLinePOSApplyCopy: Record "Sale Line POS" temporary;
        TempSaleLinePOSApplyNew: Record "Sale Line POS" temporary;
        TempPriorityBuffer: Record "Mixed Discount Priority Buffer" temporary;
        TempPriorityBufferHigh: Record "Mixed Discount Priority Buffer" temporary;
    begin
        //-NPR5.31 [262964]
        if TempMixedDiscount."Discount Type" <> TempMixedDiscount."Discount Type"::"Priority Discount per Min. Qty" then
          exit;

        Clear(TempSaleLinePOSApply);
        if TempSaleLinePOSApply.IsEmpty then
          exit;

        TransferSaleLinePOS2PriorityBuffer(TempSaleLinePOSApply,TempMixedDiscount,TempMixedDiscountLine,TempPriorityBuffer);
        TransferHighestPriorityBuffer(TempMixedDiscount,BatchQty,TempPriorityBuffer,TempPriorityBufferHigh);
        Clear(TempPriorityBufferHigh);

        TempSaleLinePOSApply.FindSet;
        repeat
          AdjustDiscQtyItems(BatchQty,TempMixedDiscount,TempMixedDiscountLine,TempPriorityBufferHigh,TempSaleLinePOSApply);
        until TempSaleLinePOSApply.Next = 0;
        //+NPR5.31 [262964]
    end;

    local procedure AdjustDiscQtyItems(BatchQty: Decimal;var TempMixedDiscount: Record "Mixed Discount" temporary;var TempMixedDiscountLine: Record "Mixed Discount Line" temporary;var TempPriorityBufferHigh: Record "Mixed Discount Priority Buffer" temporary;var TempSaleLinePOSApply: Record "Sale Line POS" temporary)
    var
        DiscQty: Decimal;
        RemainingQty: Decimal;
        Priority: Decimal;
    begin
        //-NPR5.31 [262964]
        Priority := FindPriority(TempMixedDiscount,TempMixedDiscountLine,TempSaleLinePOSApply);
        if (not TempPriorityBufferHigh.Get(Priority,TempSaleLinePOSApply."Unit Price",TempSaleLinePOSApply."No.",TempSaleLinePOSApply."Variant Code")) or (TempPriorityBufferHigh.Quantity <= 0) then begin
          TempSaleLinePOSApply."Invoice (Qty)" := 0;
          TempSaleLinePOSApply.Modify;
          exit;
        end;

        DiscQty := TempPriorityBufferHigh.Quantity;
        if DiscQty > TempSaleLinePOSApply."MR Anvendt antal" then
          DiscQty := TempSaleLinePOSApply."MR Anvendt antal";

        TempPriorityBufferHigh.Quantity -= DiscQty;
        if TempPriorityBufferHigh.Quantity > 0 then
          TempPriorityBufferHigh.Modify
        else
          TempPriorityBufferHigh.Delete;

        TempSaleLinePOSApply."Invoice (Qty)" := DiscQty;
        TempSaleLinePOSApply.Modify;
        //+NPR5.31 [262964]
    end;

    local procedure ApplyMixDiscount(var TempMixedDiscount: Record "Mixed Discount" temporary;var TempMixedDiscountLine: Record "Mixed Discount Line" temporary;var TempSaleLinePOS: Record "Sale Line POS" temporary) TotalDiscAmount: Decimal
    var
        TempSaleLinePOSApply: Record "Sale Line POS" temporary;
        TotalAmount: Decimal;
        BatchQty: Decimal;
    begin
        //-NPR5.31 [262904]
        TempSaleLinePOSApply.DeleteAll;
        BatchQty := FindLinesToApply(TempMixedDiscount,TempMixedDiscountLine,TempSaleLinePOS,TempSaleLinePOSApply);
        if BatchQty < 1 then
          exit(0);

        AdjustBatchQty(BatchQty,TempMixedDiscount,TempMixedDiscountLine,TempSaleLinePOSApply);
        //-NPR5.31 [262964]
        AdjustDiscQty(BatchQty,TempMixedDiscount,TempMixedDiscountLine,TempSaleLinePOSApply);
        //+NPR5.31 [262964]
        TotalDiscAmount := ApplyMixDiscountOnLines(BatchQty,TempMixedDiscount,TempMixedDiscountLine,TempSaleLinePOSApply);
        TransferAppliedDiscountToSale(TempSaleLinePOSApply,TempSaleLinePOS);

        exit(TotalDiscAmount);
        //+NPR5.31 [262904]
    end;

    local procedure ApplyMixDiscountOnLines(BatchQty: Decimal;var TempMixedDiscount: Record "Mixed Discount" temporary;var TempMixedDiscountLine: Record "Mixed Discount Line" temporary;var TempSaleLinePOSApply: Record "Sale Line POS" temporary) TotalDiscAmount: Decimal
    var
        Item: Record Item;
        TempPriorityBuffer: Record "Mixed Discount Priority Buffer" temporary;
        AppliedDiscAmount: Decimal;
        DiscPct: Decimal;
        LineDiscAmount: Decimal;
        RemainingQty: Decimal;
        TotalQty: Decimal;
        TotalAmount: Decimal;
        TotalVATAmount: Decimal;
    begin
        //-NPR5.31 [262904]
        //-NPR5.40 [306304]
        //TempSaleLinePOSApply.CALCSUMS("MR Anvendt antal","Amount Including VAT");
        TempSaleLinePOSApply.CalcSums("MR Anvendt antal","Amount Including VAT","VAT Base Amount");

        TotalVATAmount := TempSaleLinePOSApply."VAT Base Amount";
        //+NPR5.40 [306304]
        TotalQty := TempSaleLinePOSApply."MR Anvendt antal";
        TotalAmount := TempSaleLinePOSApply."Amount Including VAT";
        if TotalAmount = 0 then
          exit(0);

        //-NPR5.40 [294655]
        // TempSaleLinePOSApply.MODIFYALL("Discount Type",TempSaleLinePOSApply."Discount Type"::Mix);
        // TempSaleLinePOSApply.MODIFYALL("Discount Code",TempMixedDiscount.Code);
        // TempSaleLinePOSApply.MODIFYALL("Custom Disc Blocked",TempMixedDiscount."Block Custom Discount");
        //+NPR5.40 [294655]
        TempSaleLinePOSApply.FindSet;
        repeat
          //-NPR5.40 [294655]
          TempSaleLinePOSApply."Discount Type" := TempSaleLinePOSApply."Discount Type"::Mix;
          TempSaleLinePOSApply."Discount Code" := TempMixedDiscount.Code;
          TempSaleLinePOSApply."Custom Disc Blocked" := TempMixedDiscount."Block Custom Discount";
          //+NPR5.40 [294655]
          //-NPR5.40 [306304]
          //LineDiscAmount := CalcLineDiscAmount(TempMixedDiscount,TempMixedDiscountLine,BatchQty,TotalQty,TotalAmount,TempSaleLinePOSApply);
          //TempSaleLinePOSApply."Discount Amount" := LineDiscAmount;
          LineDiscAmount := CalcLineDiscAmount(TempMixedDiscount,TempMixedDiscountLine,BatchQty,TotalQty,TotalVATAmount,TotalAmount,TempSaleLinePOSApply);
          if AmountExclVat(TempMixedDiscount) then
            TempSaleLinePOSApply."Discount Amount" := LineDiscAmount * (1 + TempSaleLinePOSApply."VAT %" / 100)
          else
            TempSaleLinePOSApply."Discount Amount" := LineDiscAmount;
          //+NPR5.40 [306304]
          TempSaleLinePOSApply.Modify;
          AppliedDiscAmount += LineDiscAmount;
        until TempSaleLinePOSApply.Next = 0;

        TransferSaleLinePOS2PriorityBuffer(TempSaleLinePOSApply,TempMixedDiscount,TempMixedDiscountLine,TempPriorityBuffer);
        //-NPR5.40 [306304]
        //TotalDiscAmount := CalcTotalDiscAmount(TempMixedDiscount,BatchQty,TotalAmount,TempPriorityBuffer);
        TotalDiscAmount := CalcTotalDiscAmount(TempMixedDiscount,BatchQty,TotalVATAmount,TotalAmount,TempPriorityBuffer);
        //+NPR5.40 [306304]
        if AppliedDiscAmount <> TotalDiscAmount then begin
          //-NPR5.40 [306304]
          //TempSaleLinePOSApply."Discount Amount" += TotalDiscAmount - AppliedDiscAmount;
          if AmountExclVat(TempMixedDiscount) then
            TempSaleLinePOSApply."Discount Amount" += (TotalDiscAmount - AppliedDiscAmount) * (1 + TempSaleLinePOSApply."VAT %" / 100)
          else
            TempSaleLinePOSApply."Discount Amount" += TotalDiscAmount - AppliedDiscAmount;
          //+NPR5.40 [306304]
          TempSaleLinePOSApply.Modify;
        end;

        exit(TotalDiscAmount);
        //+NPR5.31 [262904]
    end;

    local procedure FilterSaleLinePOS(var TempMixedDiscountLine: Record "Mixed Discount Line" temporary;var TempSaleLinePOS: Record "Sale Line POS" temporary): Boolean
    begin
        //-NPR5.31 [262904]
        //-NPR5.40 [294655]
        //CLEAR(TempSaleLinePOS);
        TempSaleLinePOS.SetRange("No.");
        TempSaleLinePOS.SetRange("Variant Code");
        TempSaleLinePOS.SetRange("Item Group");
        TempSaleLinePOS.SetRange("Item Disc. Group");
        //+NPR5.40 [294655]
        case TempMixedDiscountLine."Disc. Grouping Type" of
          TempMixedDiscountLine."Disc. Grouping Type"::Item:
            begin
              TempSaleLinePOS.SetRange("No.",TempMixedDiscountLine."No.");
              //-NPR5.45 [327304]
              if TempMixedDiscountLine."Variant Code" <> '' then
              //+NPR5.45 [327304]
                TempSaleLinePOS.SetFilter("Variant Code",TempMixedDiscountLine."Variant Code");
            end;
          TempMixedDiscountLine."Disc. Grouping Type"::"Item Group":
            TempSaleLinePOS.SetRange("Item Group",TempMixedDiscountLine."No.");
          TempMixedDiscountLine."Disc. Grouping Type"::"Item Disc. Group":
            TempSaleLinePOS.SetRange("Item Disc. Group",TempMixedDiscountLine."No.");
          else
            exit(false);
        end;
        //-NPR5.40 [294655]
        // TempSaleLinePOS.SETRANGE(Type,TempSaleLinePOS.Type::Item);
        // TempSaleLinePOS.SETRANGE("Discount Type",TempSaleLinePOS."Discount Type"::" ");
        // TempSaleLinePOS.SETFILTER("Discount Code",'=%1','');
        // TempSaleLinePOS.SETFILTER(Quantity,'>%1',0);
        //+NPR5.40 [294655]
        //-NPR5.43 [308776]
        TempSaleLinePOS.SetRange(Type,TempSaleLinePOS.Type::Item);
        TempSaleLinePOS.SetRange("Discount Type",TempSaleLinePOS."Discount Type"::" ");
        TempSaleLinePOS.SetFilter("Discount Code",'=%1','');
        TempSaleLinePOS.SetFilter(Quantity,'>%1',0);
        //+NPR5.43 [308776]
        exit(not TempSaleLinePOS.IsEmpty);
        //+NPR5.31 [262904]
    end;

    local procedure FindLinesToApply(var TempMixedDiscount: Record "Mixed Discount" temporary;var TempMixedDiscountLine: Record "Mixed Discount Line" temporary;var TempSaleLinePOS: Record "Sale Line POS" temporary;var TempSaleLinePOSApply: Record "Sale Line POS" temporary) BatchQty: Decimal
    var
        TempMixedDiscount2: Record "Mixed Discount";
        AppliedQty: Decimal;
        LastBatchQty: Decimal;
        MaxQtyToApply: Decimal;
    begin
        //-NPR5.31 [262904]
        case TempMixedDiscount."Mix Type" of
          TempMixedDiscount."Mix Type"::Standard,TempMixedDiscount."Mix Type"::"Combination Part":
            begin
              if TempMixedDiscount.Lot then
                BatchQty := FindLinesToApplyLot(TempMixedDiscount,TempMixedDiscountLine,TempSaleLinePOS,TempSaleLinePOSApply)
              else
                BatchQty := FindLinesToApplyTotalQty(TempMixedDiscount,TempMixedDiscountLine,TempSaleLinePOS,TempSaleLinePOSApply);
              exit(BatchQty);
            end;
          TempMixedDiscount."Mix Type"::Combination:
            begin
              BatchQty := FindLinesToApplyCombination(TempMixedDiscount,TempMixedDiscountLine,TempSaleLinePOS,TempSaleLinePOSApply);
              exit(BatchQty);
            end;
        end;

        exit(0);
        //+NPR5.31 [262904]
    end;

    local procedure FindLinesToApplyCombination(var TempMixedDiscount: Record "Mixed Discount" temporary;var TempMixedDiscountLine: Record "Mixed Discount Line" temporary;var TempSaleLinePOS: Record "Sale Line POS" temporary;var TempSaleLinePOSApply: Record "Sale Line POS" temporary) BatchQty: Decimal
    var
        TempMixedDiscountLine2: Record "Mixed Discount Line" temporary;
        TempMixedDiscount2: Record "Mixed Discount" temporary;
        AppliedQty: Decimal;
        LastBatchQty: Decimal;
        MaxQtyToApply: Decimal;
        MinQty: Decimal;
    begin
        //-NPR5.31 [262904]
        if TempMixedDiscount."Mix Type" <> TempMixedDiscount."Mix Type"::Combination then
          exit(0);

        TempMixedDiscount2.Copy(TempMixedDiscount,true);
        TempMixedDiscountLine2.Copy(TempMixedDiscountLine,true);
        TempMixedDiscountLine2.SetRange(Code,TempMixedDiscount.Code);
        TempMixedDiscountLine2.SetRange("Disc. Grouping Type",TempMixedDiscountLine."Disc. Grouping Type"::"Mix Discount");
        if TempMixedDiscountLine2.IsEmpty then
          exit(0);

        BatchQty := -1;
        TempMixedDiscountLine2.FindSet;
        repeat
          TempMixedDiscount2.Get(TempMixedDiscountLine2."No.");
          FindLinesToApply(TempMixedDiscount2,TempMixedDiscountLine,TempSaleLinePOS,TempSaleLinePOSApply);
        until TempMixedDiscountLine2.Next = 0;

        MinQty := TempMixedDiscount.CalcMinQty();
        if MinQty <= 0 then
          exit(0);

        TempSaleLinePOSApply.CalcSums("MR Anvendt antal");
        BatchQty := TempSaleLinePOSApply."MR Anvendt antal" / MinQty;

        exit(BatchQty);
        //+NPR5.31 [262904]
    end;

    local procedure FindLinesToApplyLot(var TempMixedDiscount: Record "Mixed Discount" temporary;var TempMixedDiscountLine: Record "Mixed Discount Line" temporary;var TempSaleLinePOS: Record "Sale Line POS" temporary;var TempSaleLinePOSApply: Record "Sale Line POS" temporary) BatchQty: Decimal
    var
        TempMixedDiscount2: Record "Mixed Discount";
        AppliedQty: Decimal;
        LastBatchQty: Decimal;
        MaxQtyToApply: Decimal;
    begin
        //-NPR5.31 [262904]
        if not (TempMixedDiscount."Mix Type" in [TempMixedDiscount."Mix Type"::Standard,TempMixedDiscount."Mix Type"::"Combination Part"]) then
          exit(0);
        if not TempMixedDiscount.Lot then
          exit(0);

        TempMixedDiscountLine.SetCurrentKey(Priority);
        TempMixedDiscountLine.SetRange(Code,TempMixedDiscount.Code);
        TempMixedDiscountLine.SetRange("Disc. Grouping Type",TempMixedDiscountLine."Disc. Grouping Type"::Item,TempMixedDiscountLine."Disc. Grouping Type"::"Item Disc. Group");
        if TempMixedDiscountLine.IsEmpty then
          exit(0);

        BatchQty := -1;
        TempMixedDiscountLine.FindSet;
        repeat
          if TempMixedDiscountLine.Quantity <= 0 then
            exit(0);

          AppliedQty := TransferLinesToApply(TempMixedDiscount,TempMixedDiscountLine,0,TempSaleLinePOS,TempSaleLinePOSApply);

          LastBatchQty := AppliedQty div TempMixedDiscountLine.Quantity;
          if (LastBatchQty < BatchQty) or (BatchQty = -1) then
            BatchQty := LastBatchQty;
        until TempMixedDiscountLine.Next = 0;

        exit(BatchQty);
        //+NPR5.31 [262904]
    end;

    local procedure FindLinesToApplyTotalQty(var TempMixedDiscount: Record "Mixed Discount" temporary;var TempMixedDiscountLine: Record "Mixed Discount Line" temporary;var TempSaleLinePOS: Record "Sale Line POS" temporary;var TempSaleLinePOSApply: Record "Sale Line POS" temporary) BatchQty: Decimal
    var
        TempMixedDiscount2: Record "Mixed Discount";
        AppliedQty: Decimal;
        LastBatchQty: Decimal;
        MaxQtyToApply: Decimal;
    begin
        //-NPR5.31 [262904]
        if not TempSaleLinePOSApply.IsTemporary then
          exit(0);
        if not (TempMixedDiscount."Mix Type" in [TempMixedDiscount."Mix Type"::Standard,TempMixedDiscount."Mix Type"::"Combination Part"]) then
          exit(0);
        if TempMixedDiscount.Lot then
          exit(0);
        if TempMixedDiscount."Min. Quantity" <= 0 then
          exit(0);

        TempMixedDiscountLine.SetCurrentKey(Priority);
        TempMixedDiscountLine.SetRange(Code,TempMixedDiscount.Code);
        TempMixedDiscountLine.SetRange("Disc. Grouping Type",TempMixedDiscountLine."Disc. Grouping Type"::Item,TempMixedDiscountLine."Disc. Grouping Type"::"Item Disc. Group");
        if TempMixedDiscountLine.IsEmpty then
          exit(0);

        MaxQtyToApply := TempMixedDiscount."Max. Quantity";
        TempMixedDiscountLine.FindSet;
        repeat
          AppliedQty += TransferLinesToApply(TempMixedDiscount,TempMixedDiscountLine,MaxQtyToApply,TempSaleLinePOS,TempSaleLinePOSApply);
          if TempMixedDiscount."Max. Quantity" > 0 then begin
            MaxQtyToApply := TempMixedDiscount."Max. Quantity" - AppliedQty;
            if MaxQtyToApply <= 0 then
              TempMixedDiscountLine.FindLast;
          end;
        until TempMixedDiscountLine.Next = 0;

        BatchQty := AppliedQty / TempMixedDiscount."Min. Quantity";
        exit(BatchQty);
        //+NPR5.31 [262904]
    end;

    local procedure FindPriority(var TempMixedDiscount: Record "Mixed Discount" temporary;var TempMixedDiscountLine: Record "Mixed Discount Line" temporary;var TempSaleLinePOS: Record "Sale Line POS" temporary) HighestPriority: Decimal
    begin
        //-NPR5.31 [262964]
        HighestPriority := 1000000000;

        if TempMixedDiscountLine.Get(TempMixedDiscount.Code,TempMixedDiscountLine."Disc. Grouping Type"::Item,TempSaleLinePOS."No.",TempSaleLinePOS."Variant Code") then
          HighestPriority := TempMixedDiscountLine.Priority;

        if TempMixedDiscountLine.Get(TempMixedDiscount.Code,TempMixedDiscountLine."Disc. Grouping Type"::Item,TempSaleLinePOS."No.",'') and (HighestPriority > TempMixedDiscountLine.Priority) then
          HighestPriority := TempMixedDiscountLine.Priority;

        if TempMixedDiscountLine.Get(TempMixedDiscount.Code,TempMixedDiscountLine."Disc. Grouping Type"::"Item Group",TempSaleLinePOS."Item Group",'') and (HighestPriority > TempMixedDiscountLine.Priority) then
          HighestPriority := TempMixedDiscountLine.Priority;

        if TempMixedDiscountLine.Get(TempMixedDiscount.Code,TempMixedDiscountLine."Disc. Grouping Type"::"Item Group",TempSaleLinePOS."Item Disc. Group",'') and (HighestPriority > TempMixedDiscountLine.Priority) then
          HighestPriority := TempMixedDiscountLine.Priority;

        exit(HighestPriority);
        //+NPR5.31 [262964]
    end;

    local procedure TransferLinesToApply(var TempMixedDiscount: Record "Mixed Discount" temporary;var TempMixedDiscountLine: Record "Mixed Discount Line" temporary;MaxQtyToApply: Decimal;var TempSaleLinePOS: Record "Sale Line POS" temporary;var TempSaleLinePOSApply: Record "Sale Line POS" temporary) AppliedQty: Decimal
    begin
        //-NPR5.31 [262904]
        if not FilterSaleLinePOS(TempMixedDiscountLine,TempSaleLinePOS) then
          exit(0);

        TempSaleLinePOS.FindSet;
        repeat
          if not TempSaleLinePOSApply.Get(TempSaleLinePOS."Register No.",TempSaleLinePOS."Sales Ticket No.",TempSaleLinePOS.Date,TempSaleLinePOS."Sale Type",TempSaleLinePOS."Line No.") then begin

            TempSaleLinePOSApply.Init;
            TempSaleLinePOSApply := TempSaleLinePOS;

            TempSaleLinePOSApply."Discount Type" := TempSaleLinePOSApply."Discount Type"::Mix;
            TempSaleLinePOSApply."Discount Code" := TempMixedDiscountLine.Code;
            TempSaleLinePOSApply."Sales Document Type" := TempMixedDiscountLine."Disc. Grouping Type";
            TempSaleLinePOSApply."Sales Document No." := TempMixedDiscountLine."No.";
            TempSaleLinePOSApply."Retail Document No." := TempMixedDiscountLine."Variant Code";

            TempSaleLinePOSApply."Quantity (Base)" := TempMixedDiscountLine.Quantity;
            TempSaleLinePOSApply.Insert;

            TempSaleLinePOSApply."MR Anvendt antal" := TempSaleLinePOSApply.Quantity;
            if (MaxQtyToApply > 0) and (AppliedQty + TempSaleLinePOSApply."MR Anvendt antal" >= MaxQtyToApply) then begin
              TempSaleLinePOSApply."MR Anvendt antal" := MaxQtyToApply - AppliedQty;
              TempSaleLinePOS.FindLast;
            end;
            //-NPR5.31 [262964]
            TempSaleLinePOSApply."Invoice (Qty)" := TempSaleLinePOSApply."MR Anvendt antal";
            //+NPR5.31 [262964]
            //-NPR5.38 [300637]
            //TempSaleLinePOSApply."Unit Price" := TempSaleLinePOSApply.GetLineUnitPriceInclVat();
        //-NPR5.46 [331487]
        //    TempSaleLinePOSApply."Unit Price" := TempSaleLinePOS."Unit Price";
        //+NPR5.46 [331487]
            //+NPR5.38 [300637]
            TempSaleLinePOSApply."Amount Including VAT" := TempSaleLinePOSApply."MR Anvendt antal" * TempSaleLinePOSApply."Unit Price";
            //-NPR5.40 [306304]
            TempSaleLinePOSApply."VAT Base Amount" := TempSaleLinePOSApply."Amount Including VAT" - TempSaleLinePOSApply."Amount Including VAT" / (1 + TempSaleLinePOSApply."VAT %" / 100);
            TempSaleLinePOSApply.Amount := TempSaleLinePOSApply."Amount Including VAT" - TempSaleLinePOSApply."VAT Base Amount";
            //+NPR5.40 [306304]
            TempSaleLinePOSApply.Modify;

            AppliedQty += TempSaleLinePOSApply."MR Anvendt antal";
          end;
        until TempSaleLinePOS.Next = 0;

        exit(AppliedQty);
        //+NPR5.31 [262904]
    end;

    local procedure TransferAppliedDiscountToSale(var TempSaleLinePOSApply: Record "Sale Line POS" temporary;var TempSaleLinePOS: Record "Sale Line POS" temporary)
    var
        SaleLinePOS: Record "Sale Line POS";
        TempSaleLinePOS2: Record "Sale Line POS" temporary;
        RemainingQty: Decimal;
        NonDiscQty: Decimal;
        LineNo: Integer;
    begin
        //-NPR5.31 [262904]
        if TempSaleLinePOSApply.IsEmpty then
          exit;

        Clear(TempSaleLinePOS);
        if TempSaleLinePOS.FindLast then;
        LineNo := TempSaleLinePOS."Line No.";

        TempSaleLinePOSApply.FindSet;
        repeat
          //-NPR5.40 [294655]
          //Item.GET(TempSaleLinePOSApply."No.");
          //+NPR5.40 [294655]

          TempSaleLinePOS.Get(TempSaleLinePOSApply."Register No.",TempSaleLinePOSApply."Sales Ticket No.",TempSaleLinePOSApply.Date,TempSaleLinePOSApply."Sale Type",TempSaleLinePOSApply."Line No.");
          RemainingQty := TempSaleLinePOS.Quantity - TempSaleLinePOSApply."MR Anvendt antal";
          TempSaleLinePOS.Validate(Quantity,TempSaleLinePOSApply."MR Anvendt antal");
          //-NPR5.31 [262964]
          NonDiscQty := 0;
          if TempSaleLinePOSApply."Invoice (Qty)" > 0 then begin
            NonDiscQty := TempSaleLinePOSApply."MR Anvendt antal" - TempSaleLinePOSApply."Invoice (Qty)";
            TempSaleLinePOS.Validate(Quantity,TempSaleLinePOSApply."Invoice (Qty)");
          end;
          //+NPR5.31 [262964]
          TempSaleLinePOS."Discount Type" := TempSaleLinePOSApply."Discount Type";
          TempSaleLinePOS."Discount Code" := TempSaleLinePOSApply."Discount Code";
          TempSaleLinePOS."Discount %" := 0;
          TempSaleLinePOS."Discount Amount" := TempSaleLinePOSApply."Discount Amount";
          TempSaleLinePOS."Custom Disc Blocked" := TempSaleLinePOSApply."Custom Disc Blocked";
          //-NPR5.40 [294655]
          //TempSaleLinePOS.GetAmount(TempSaleLinePOS,Item,TempSaleLinePOSApply."Unit Price");
          //+NPR5.40 [294655]
          TempSaleLinePOS.Modify;

          //-NPR5.31 [262964]
          if NonDiscQty > 0 then begin
            LineNo += 10000;

            //-NPR5.43 [321284]
            TempSaleLinePOS2 := TempSaleLinePOS;
            //+NPR5.43 [321284]
            TempSaleLinePOS.Init;
            TempSaleLinePOS := TempSaleLinePOSApply;
            //-NPR5.43 [321284]
            TempSaleLinePOS."Sales Document Type" := TempSaleLinePOS2."Sales Document Type";
            TempSaleLinePOS."Sales Document No." := TempSaleLinePOS2."Sales Document No.";
            TempSaleLinePOS."Retail Document No." := TempSaleLinePOS2."Retail Document No.";
            //+NPR5.43 [321284]
            TempSaleLinePOS."Line No." := LineNo;
            TempSaleLinePOS.Validate(Quantity,NonDiscQty);
            TempSaleLinePOS."Discount Type" := TempSaleLinePOSApply."Discount Type";
            TempSaleLinePOS."Discount Code" := TempSaleLinePOSApply."Discount Code";
            TempSaleLinePOS."Discount %" := 0;
            TempSaleLinePOS."Discount Amount" := 0;
            TempSaleLinePOS."Custom Disc Blocked" := false;
            //-NPR5.40 [294655]
            //TempSaleLinePOS.GetAmount(TempSaleLinePOS,Item,TempSaleLinePOSApply."Unit Price");
            //+NPR5.40 [294655]
            TempSaleLinePOS.Insert;
          end;
          //+NPR5.31 [262964]
          if RemainingQty > 0 then begin
            LineNo += 10000;

            //-NPR5.43 [321284]
            TempSaleLinePOS2 := TempSaleLinePOS;
            //+NPR5.43 [321284]
            TempSaleLinePOS.Init;
            TempSaleLinePOS := TempSaleLinePOSApply;
            //-NPR5.43 [321284]
            TempSaleLinePOS."Sales Document Type" := TempSaleLinePOS2."Sales Document Type";
            TempSaleLinePOS."Sales Document No." := TempSaleLinePOS2."Sales Document No.";
            TempSaleLinePOS."Retail Document No." := TempSaleLinePOS2."Retail Document No.";
            //+NPR5.43 [321284]
            TempSaleLinePOS."Line No." := LineNo;
            TempSaleLinePOS.Validate(Quantity,RemainingQty);
            TempSaleLinePOS."Discount Type" := TempSaleLinePOS."Discount Type"::" ";
            TempSaleLinePOS."Discount Code" := '';
            TempSaleLinePOS."Discount %" := 0;
            TempSaleLinePOS."Discount Amount" := 0;
            TempSaleLinePOS."Custom Disc Blocked" := false;
            //-NPR5.40 [294655]
            //TempSaleLinePOS.GetAmount(TempSaleLinePOS,Item,TempSaleLinePOSApply."Unit Price");
            //+NPR5.40 [294655]
            TempSaleLinePOS.Insert;
          end;
        until TempSaleLinePOSApply.Next = 0;
        //+NPR5.31 [262904]
    end;

    local procedure AmountExclVat(TempMixedDiscount: Record "Mixed Discount" temporary): Boolean
    begin
        //-NPR5.40 [306304]
        if not TempMixedDiscount."Total Amount Excl. VAT" then
          exit(false);

        exit(TempMixedDiscount."Discount Type" = TempMixedDiscount."Discount Type"::"Total Amount per Min. Qty.");
        //+NPR5.40 [306304]
    end;

    local procedure "--- Mix Match"()
    begin
    end;

    procedure FindMatchingMixedDiscounts(var TempMixedDiscount: Record "Mixed Discount" temporary;var TempMixedDiscountLine: Record "Mixed Discount Line" temporary;var TempSaleLinePOS: Record "Sale Line POS" temporary): Boolean
    begin
        //-NPR5.40 [294655]
        //IF NOT FindPotentialMixedDiscounts(SalePOS,TempSaleLinePOS,TRUE,TempMixedDiscount) THEN
        //  EXIT(FALSE);
        //+NPR5.40 [294655]

        MatchMixedDiscounts(TempMixedDiscount,TempMixedDiscountLine,TempSaleLinePOS);
        MatchMixedDiscountCominations(TempMixedDiscount,TempMixedDiscountLine,TempSaleLinePOS);
        TempMixedDiscount.Reset;
        exit(not TempMixedDiscount.IsEmpty);
    end;

    procedure MatchMixedDiscounts(var TempMixedDiscount: Record "Mixed Discount" temporary;var TempMixedDiscountLine: Record "Mixed Discount Line" temporary;var TempSaleLinePOS: Record "Sale Line POS" temporary)
    begin
        //-NPR5.31 [262904]
        TempMixedDiscount.Reset;
        TempMixedDiscount.SetFilter("Mix Type",'%1|%2',TempMixedDiscount."Mix Type"::Standard,TempMixedDiscount."Mix Type"::"Combination Part");
        if TempMixedDiscount.IsEmpty then
          exit;

        TempMixedDiscount.FindSet;
        repeat
          if not MatchMixedDiscount(TempMixedDiscount,TempMixedDiscountLine,TempSaleLinePOS) then begin
            TempMixedDiscountLine.Reset;
            TempMixedDiscountLine.SetRange(Code,TempMixedDiscount.Code);
            TempMixedDiscountLine.DeleteAll;

            TempMixedDiscount.Delete;
          end;
        until TempMixedDiscount.Next = 0;
        //+NPR5.31 [262904]
    end;

    local procedure MatchMixedDiscount(var TempMixedDiscount: Record "Mixed Discount" temporary;var TempMixedDiscountLine: Record "Mixed Discount Line" temporary;var TempSaleLinePOS: Record "Sale Line POS" temporary): Boolean
    var
        MixedDiscountLine: Record "Mixed Discount Line";
        TempSaleLinePOS2: Record "Sale Line POS" temporary;
        TotalQuantity: Decimal;
        SalePOS: Record "Sale POS";
    begin
        //-NPR5.45 [326466]
        if not SalePOS.Get(TempSaleLinePOS."Register No.",TempSaleLinePOS."Sales Ticket No.") then
          exit(false);
        if not DiscountActive(SalePOS, TempMixedDiscount) then
          exit(false);
        //+NPR5.45 [326466]

        //-NPR5.31 [262904]
        if (TempMixedDiscount."Min. Quantity" <= 0) and not TempMixedDiscount.Lot then
          exit(false);

        MixedDiscountLine.SetRange(Code,TempMixedDiscount.Code);
        MixedDiscountLine.SetRange("Disc. Grouping Type",MixedDiscountLine."Disc. Grouping Type"::Item,MixedDiscountLine."Disc. Grouping Type"::"Item Disc. Group");
        if MixedDiscountLine.IsEmpty then
          exit(false);

        TotalQuantity := 0;
        MixedDiscountLine.FindSet;
        repeat
          TempSaleLinePOS2.Copy(TempSaleLinePOS,true);
          TempSaleLinePOS2.SetRange(Type,TempSaleLinePOS2.Type::Item);
          case MixedDiscountLine."Disc. Grouping Type" of
            MixedDiscountLine."Disc. Grouping Type"::Item:
              begin
                TempSaleLinePOS2.SetRange("No.",MixedDiscountLine."No.");
                //-NPR5.45 [327304]
                if MixedDiscountLine."Variant Code" <> '' then
                  TempSaleLinePOS2.SetRange("Variant Code", MixedDiscountLine."Variant Code");
                //+NPR5.45 [327304]
              end;
            MixedDiscountLine."Disc. Grouping Type"::"Item Group":
              TempSaleLinePOS2.SetRange("Item Group",MixedDiscountLine."No.");
            MixedDiscountLine."Disc. Grouping Type"::"Item Disc. Group":
              TempSaleLinePOS2.SetRange("Item Disc. Group",MixedDiscountLine."No.")
          end;

          TempSaleLinePOS2.CalcSums(Quantity);
          TotalQuantity += TempSaleLinePOS2.Quantity;
          if TempMixedDiscount.Lot and (TotalQuantity < MixedDiscountLine.Quantity) then
            exit(false);

          TempMixedDiscountLine.Init;
          TempMixedDiscountLine := MixedDiscountLine;
          TempMixedDiscountLine.Insert;
        until MixedDiscountLine.Next = 0;

        if TempMixedDiscount.Lot then
          exit(true);

        exit(TotalQuantity >= TempMixedDiscount."Min. Quantity");
        //+NPR5.31 [262904]
    end;

    procedure MatchMixedDiscountCominations(var TempMixedDiscount: Record "Mixed Discount" temporary;var TempMixedDiscountLine: Record "Mixed Discount Line" temporary;var TempSaleLinePOS: Record "Sale Line POS" temporary): Boolean
    begin
        //-NPR5.31 [262904]
        TempMixedDiscount.Reset;
        TempMixedDiscount.SetRange("Mix Type",TempMixedDiscount."Mix Type"::Combination);
        if TempMixedDiscount.IsEmpty then
          exit;

        TempMixedDiscount.FindSet;
        repeat
          if not MatchMixedDiscountComination(TempMixedDiscount,TempMixedDiscountLine,TempSaleLinePOS) then begin
            TempMixedDiscountLine.SetRange(Code,TempMixedDiscount.Code);
            TempMixedDiscountLine.DeleteAll;
            TempMixedDiscount.Delete;
          end;
        until TempMixedDiscount.Next = 0;
        //+NPR5.31 [262904]
    end;

    procedure MatchMixedDiscountComination(var TempMixedDiscount: Record "Mixed Discount" temporary;var TempMixedDiscountLine: Record "Mixed Discount Line" temporary;var TempSaleLinePOS: Record "Sale Line POS" temporary): Boolean
    var
        MixedDiscount: Record "Mixed Discount";
        MixedDiscountLine: Record "Mixed Discount Line";
        TempMixedDiscountPart: Record "Mixed Discount" temporary;
        SalePOS: Record "Sale POS";
    begin
        //-NPR5.31 [262904]
        TempMixedDiscountPart.Copy(TempMixedDiscount,true);

        //-NPR5.45 [326466]
        if not SalePOS.Get(TempSaleLinePOS."Register No.",TempSaleLinePOS."Sales Ticket No.") then
          exit(false);
        if not DiscountActive(SalePOS, TempMixedDiscount) then
          exit(false);
        //+NPR5.45 [326466]

        MixedDiscountLine.SetRange(Code,TempMixedDiscount.Code);
        MixedDiscountLine.SetRange("Disc. Grouping Type",MixedDiscountLine."Disc. Grouping Type"::"Mix Discount");
        if MixedDiscountLine.IsEmpty then
          exit(false);

        MixedDiscountLine.FindSet;
        repeat
          if not TempMixedDiscountPart.Get(MixedDiscountLine."No.") then
            exit(false);

          TempMixedDiscountLine.Init;
          TempMixedDiscountLine := MixedDiscountLine;
          TempMixedDiscountLine.Insert;
        until MixedDiscountLine.Next = 0;
        exit(true);
        //+NPR5.31 [262904]
    end;

    local procedure DiscountActive(SalePOS: Record "Sale POS";var MixedDiscount: Record "Mixed Discount"): Boolean
    var
        SalePOS2: Record "Sale POS";
        MixedDiscount2: Record "Mixed Discount";
        MixedDiscountLine2: Record "Mixed Discount Line";
    begin
        //-NPR5.31 [262904]
        case MixedDiscount."Mix Type" of
          MixedDiscount."Mix Type"::Standard,MixedDiscount."Mix Type"::Combination:
            begin
              //-NPR5.45 [323716]
              //IF NOT DiscountActiveNow(MixedDiscount) THEN
              //  EXIT(FALSE);
              if not IsActiveNow(MixedDiscount) then
                exit(false);
              //+NPR5.45 [323716]

              if MixedDiscount."Customer Disc. Group Filter" <> '' then begin
                SalePOS2.Copy(SalePOS);
                SalePOS2.SetRecFilter;
                SalePOS2.SetFilter("Customer Disc. Group",MixedDiscount."Customer Disc. Group Filter");
                if not SalePOS2.FindFirst then
                  exit(false);
              end;

              exit(true);
            end;
          MixedDiscount."Mix Type"::"Combination Part":
            begin
              MixedDiscountLine2.SetRange("Disc. Grouping Type",MixedDiscountLine2."Disc. Grouping Type"::"Mix Discount");
              MixedDiscountLine2.SetFilter("No.",MixedDiscount.Code);
              MixedDiscountLine2.SetRange(Status,MixedDiscountLine2.Status::Active);
              if MixedDiscountLine2.IsEmpty then
                exit(false);
              MixedDiscountLine2.FindSet;
              repeat
                if MixedDiscount2.Get(MixedDiscountLine2.Code) and (MixedDiscount2."Mix Type" = MixedDiscount2."Mix Type"::Combination) then
                  if DiscountActive(SalePOS,MixedDiscount2) then
                    exit(true);
              until MixedDiscountLine2.Next = 0;
            end;
        end;

        exit(false)
        //+NPR5.31 [262904]
    end;

    local procedure DiscountLineActive(SalePOS: Record "Sale POS";MixedDiscountLine: Record "Mixed Discount Line"): Boolean
    var
        MixedDiscount: Record "Mixed Discount";
    begin
        //-NPR5.31 [262904]
        if not MixedDiscount.Get(MixedDiscountLine.Code) then
          exit(false);

        exit(DiscountActive(SalePOS,MixedDiscount));
        //+NPR5.31 [262904]
    end;

    local procedure "--- Best Mix Match"()
    begin
    end;

    local procedure CalcTotalAppliedMixDisc(var TempMixedDiscount: Record "Mixed Discount" temporary;var TempMixedDiscountLine: Record "Mixed Discount Line" temporary;var TempSaleLinePOS: Record "Sale Line POS" temporary) DiscAmount: Decimal
    var
        TempMixedDiscountCopy: Record "Mixed Discount" temporary;
        MixCode: Code[20];
    begin
        //-NPR5.31 [262904]
        if TempMixedDiscount.IsEmpty then
          exit(0);

        MixCode := TempMixedDiscount.Code;

        //CopyMixedDiscount(TempMixedDiscount,TempMixedDiscountCopy);
        TempMixedDiscountCopy.Copy(TempMixedDiscount,true);
        DiscAmount := ApplyMixDiscount(TempMixedDiscountCopy,TempMixedDiscountLine,TempSaleLinePOS);

        TempMixedDiscountCopy.SetCurrentKey("Actual Discount Amount","Actual Item Qty.");
        TempMixedDiscount.SetRange("Mix Type",TempMixedDiscount."Mix Type"::Standard,TempMixedDiscount."Mix Type"::Combination);
        TempMixedDiscountCopy.SetFilter(Code,'<>%1',MixCode);
        TempMixedDiscountCopy.Ascending(false);
        if TempMixedDiscountCopy.IsEmpty then
          exit(DiscAmount);

        TempMixedDiscountCopy.FindSet;
        repeat
          DiscAmount += ApplyMixDiscount(TempMixedDiscountCopy,TempMixedDiscountLine,TempSaleLinePOS);
        until TempMixedDiscountCopy.Next = 0;

        exit(DiscAmount);
        //+NPR5.31 [262904]
    end;

    local procedure CopyMixedDiscount(var TempMixedDiscount: Record "Mixed Discount" temporary;var TempMixedDiscountCopy: Record "Mixed Discount" temporary)
    begin
        //-NPR5.31 [262904]
        if not TempMixedDiscountCopy.IsTemporary then
          exit;
        Clear(TempMixedDiscountCopy);
        TempMixedDiscountCopy.DeleteAll;

        if TempMixedDiscount.IsEmpty then
          exit;

        TempMixedDiscount.FindSet;
        repeat
          TempMixedDiscountCopy.Init;
          TempMixedDiscountCopy := TempMixedDiscount;
          TempMixedDiscountCopy.Insert;
        until TempMixedDiscount.Next = 0;
        //+NPR5.31 [262904]
    end;

    local procedure CopySaleLinePOS(var TempSaleLinePOS: Record "Sale Line POS" temporary;var TempSaleLinePOSCopy: Record "Sale Line POS" temporary)
    begin
        //-NPR5.31 [262904]
        if not TempSaleLinePOSCopy.IsTemporary then
          exit;
        Clear(TempSaleLinePOSCopy);
        TempSaleLinePOSCopy.DeleteAll;

        if TempSaleLinePOS.IsEmpty then
          exit;

        TempSaleLinePOS.FindSet;
        repeat
          TempSaleLinePOSCopy.Init;
          TempSaleLinePOSCopy := TempSaleLinePOS;
          TempSaleLinePOSCopy.Insert;
        until TempSaleLinePOS.Next = 0;
        //+NPR5.31 [262904]
    end;

    local procedure FindBestMixMatch(var TempMixedDiscount: Record "Mixed Discount" temporary;var TempMixedDiscountLine: Record "Mixed Discount Line" temporary;var TempSaleLinePOS: Record "Sale Line POS" temporary)
    var
        TempMixedDiscountCopy: Record "Mixed Discount" temporary;
        TempSaleLinePOSCopy: Record "Sale Line POS" temporary;
        DiscAmount: Decimal;
    begin
        //-NPR5.31 [262904]
        Clear(TempMixedDiscount);
        TempMixedDiscount.SetRange("Mix Type",TempMixedDiscount."Mix Type"::Standard,TempMixedDiscount."Mix Type"::Combination);
        if TempMixedDiscount.Count <=  1 then
          exit;

        TempMixedDiscount.FindSet;
        repeat
          CopySaleLinePOS(TempSaleLinePOS,TempSaleLinePOSCopy);
          DiscAmount := ApplyMixDiscount(TempMixedDiscount,TempMixedDiscountLine,TempSaleLinePOSCopy);
          TempSaleLinePOSCopy.SetRange("Discount Type",TempSaleLinePOSCopy."Discount Type"::Mix);
          TempSaleLinePOSCopy.SetRange("Discount Code",TempMixedDiscount.Code);
          TempSaleLinePOSCopy.CalcSums(Quantity);
          TempMixedDiscount."Actual Discount Amount" := DiscAmount;
          TempMixedDiscount."Actual Item Qty." := TempSaleLinePOSCopy.Quantity;
          TempMixedDiscount.Modify;
        until TempMixedDiscount.Next = 0;

        Clear(TempMixedDiscount);
        CopyMixedDiscount(TempMixedDiscount,TempMixedDiscountCopy);

        TempMixedDiscountCopy.SetCurrentKey("Actual Discount Amount","Actual Item Qty.");
        TempMixedDiscountCopy.Ascending(false);
        TempMixedDiscountCopy.SetRange("Mix Type",TempMixedDiscountCopy."Mix Type"::Standard,TempMixedDiscountCopy."Mix Type"::Combination);
        TempMixedDiscountCopy.FindSet;
        repeat
          CopySaleLinePOS(TempSaleLinePOS,TempSaleLinePOSCopy);
          DiscAmount := CalcTotalAppliedMixDisc(TempMixedDiscountCopy,TempMixedDiscountLine,TempSaleLinePOSCopy);
          TempSaleLinePOSCopy.SetRange("Discount Type",TempSaleLinePOSCopy."Discount Type"::Mix);
          TempSaleLinePOSCopy.SetRange("Discount Code",TempMixedDiscountCopy.Code);
          TempSaleLinePOSCopy.CalcSums(Quantity);

          TempMixedDiscount.Get(TempMixedDiscountCopy.Code);
          TempMixedDiscount."Actual Discount Amount" := DiscAmount;
          TempMixedDiscount."Actual Item Qty." := TempSaleLinePOSCopy.Quantity;
          TempMixedDiscount.Modify;
        until TempMixedDiscountCopy.Next = 0;
        //+NPR5.31 [262904]
    end;

    local procedure "--- Discount Interface"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014455, 'InitDiscountPriority', '', true, true)]
    local procedure OnInitDiscountPriority(var DiscountPriority: Record "Discount Priority")
    begin
        //-NPR5.31 [262904]
        if DiscountPriority.Get(DiscSourceTableId()) then
          exit;

        DiscountPriority.Init;
        DiscountPriority."Table ID" := DiscSourceTableId();
        DiscountPriority.Priority := 1;
        DiscountPriority.Disabled := false;
        DiscountPriority."Discount Calc. Codeunit ID" := DiscCalcCodeunitId();
        //-NPR5.44 [312154]
        DiscountPriority."Cross Line Calculation" := true;
        //+NPR5.44 [312154]
        DiscountPriority.Insert(true);
        //+NPR5.31 [262904]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014455, 'ApplyDiscount', '', true, true)]
    local procedure OnApplyDiscount(DiscountPriority: Record "Discount Priority";SalePOS: Record "Sale POS";var TempSaleLinePOS: Record "Sale Line POS" temporary;Rec: Record "Sale Line POS";xRec: Record "Sale Line POS";LineOperation: Option Insert,Modify,Delete;RecalculateAllLines: Boolean)
    begin
        if not IsSubscribedDiscount(DiscountPriority) then
          exit;

        //-NPR5.44 [312154]
        //ApplyMixDiscounts(SalePOS,TempSaleLinePOS, Rec);
        ApplyMixDiscounts(SalePOS,TempSaleLinePOS, Rec, RecalculateAllLines);
        //-NPR5.44 [312154]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014455, 'OnFindActiveSaleLineDiscounts', '', false, false)]
    local procedure OnFindActiveSaleLineDiscounts(var tmpDiscountPriority: Record "Discount Priority" temporary;Rec: Record "Sale Line POS";xRec: Record "Sale Line POS";LineOperation: Option Insert,Modify,Delete)
    var
        MixedDiscountLine: Record "Mixed Discount Line";
        IsActive: Boolean;
        DiscountPriority: Record "Discount Priority";
    begin
        //-NPR5.40 [294655]
        if not DiscountPriority.Get(DiscSourceTableId()) then
          exit;
        if not IsSubscribedDiscount(DiscountPriority) then
          exit;
        if not IsValidLineOperation(Rec, xRec, LineOperation) then
          exit;

        MixedDiscountLine.SetCurrentKey("Disc. Grouping Type","No.","Variant Code","Starting Date","Ending Date","Starting Time","Ending Time",Status);
        MixedDiscountLine.SetRange(Status,MixedDiscountLine.Status::Active);
        MixedDiscountLine.SetFilter("Starting Date",'<=%1|=%2',Today,0D);
        //-NPR5.45 [323716]
        // MixedDiscountLine.SETFILTER("Starting Time",'<=%1|=%2',TIME,0T);
        // MixedDiscountLine.SETFILTER("Ending Date", '>=%1|=%2',TODAY,0D);
        // MixedDiscountLine.SETFILTER("Starting Time",'>=%1|=%2',TIME,0T);
        MixedDiscountLine.SetFilter("Ending Date", '>=%1|=%2',Today,0D);
        //+NPR5.45 [323716]
        MixedDiscountLine.SetRange("Disc. Grouping Type", MixedDiscountLine."Disc. Grouping Type"::Item);
        MixedDiscountLine.SetRange("No.",Rec."No.");
        MixedDiscountLine.SetFilter("Variant Code",'%1|%2','',Rec."Variant Code");
        IsActive := not MixedDiscountLine.IsEmpty;

        if not IsActive then begin
          MixedDiscountLine.SetRange("Variant Code");
          MixedDiscountLine.SetRange("Disc. Grouping Type", MixedDiscountLine."Disc. Grouping Type"::"Item Disc. Group");
          MixedDiscountLine.SetRange("No.", Rec."Item Disc. Group");
          IsActive := not MixedDiscountLine.IsEmpty;
        end;

        if not IsActive then begin
          MixedDiscountLine.SetRange("Disc. Grouping Type", MixedDiscountLine."Disc. Grouping Type"::"Item Group");
          MixedDiscountLine.SetRange("No.", Rec."Item Group");
          IsActive := not MixedDiscountLine.IsEmpty;
        end;

        if IsActive then begin
          tmpDiscountPriority.Init;
          tmpDiscountPriority := DiscountPriority;
          tmpDiscountPriority.Insert;
        end;
        //+NPR5.40 [294655]
    end;

    local procedure IsValidLineOperation(Rec: Record "Sale Line POS";xRec: Record "Sale Line POS";LineOperation: Option Insert,Modify,Delete): Boolean
    begin
        //-NPR5.40 [294655]
        // IF LineOperation = LineOperation::Modify THEN
        //  IF (Rec.Type = Rec.Type::Item) AND (Rec.Type = xRec.Type) AND (Rec."No." = xRec."No.") THEN
        //    EXIT(Rec.Quantity <> xRec.Quantity);

        exit(true);
        //+NPR5.40 [294655]
    end;

    local procedure IsSubscribedDiscount(DiscountPriority: Record "Discount Priority"): Boolean
    begin
        //-NPR5.31 [262904]
        if DiscountPriority.Disabled then
          exit(false);
        if DiscountPriority."Table ID" <> DiscSourceTableId() then
          exit(false);
        if (DiscountPriority."Discount Calc. Codeunit ID" <> 0) and (DiscountPriority."Discount Calc. Codeunit ID" <> DiscCalcCodeunitId()) then
          exit(false);

        exit(true);
        //+NPR5.31 [262904]
    end;

    local procedure DiscSourceTableId(): Integer
    begin
        //-NPR5.31 [262904]
        exit(DATABASE::"Mixed Discount");
        //+NPR5.31 [262904]
    end;

    local procedure DiscCalcCodeunitId(): Integer
    begin
        //-NPR5.31 [262904]
        exit(CODEUNIT::"Mixed Discount Management");
        //+NPR5.31 [262904]
    end;

    local procedure IsActiveNow(var MixedDiscount: Record "Mixed Discount"): Boolean
    var
        MixedDiscountLine: Record "Mixed Discount Line";
        CurrDate: Date;
        CurrTime: Time;
    begin
        //-NPR5.31 [262904]
        //-NPR5.45 [326466]
        // IF MixedDiscount.ISTEMPORARY THEN
        //  EXIT(FALSE);
        //+NPR5.45 [326466]

        if MixedDiscount."Mix Type" = MixedDiscount."Mix Type"::"Combination Part" then begin
          MixedDiscountLine.SetRange("Disc. Grouping Type",MixedDiscountLine."Disc. Grouping Type"::"Mix Discount");
          MixedDiscountLine.SetRange("No.",MixedDiscount.Code);
          MixedDiscountLine.SetRange(Status,MixedDiscountLine.Status::Active);
          if MixedDiscountLine.IsEmpty then
            exit(false);

          MixedDiscountLine.FindSet;
          repeat
            //-NPR5.45 [323716]
            //IF DiscountLineActiveNow(MixedDiscountLine) THEN
            //  EXIT(TRUE);
            if not IsActiveLineNow(MixedDiscountLine) then
              exit(true);
            //+NPR5.45 [323716]
          until MixedDiscountLine.Next = 0;
          exit(false);
        end;

        if MixedDiscount.Status <> MixedDiscount.Status::Active then
          exit(false);
        if MixedDiscount."Starting date" = 0D then
          exit(false);
        if MixedDiscount."Ending date" = 0D then
          exit(false);

        CurrDate := Today;
        CurrTime := Time;
        if MixedDiscount."Starting date" > CurrDate then
          exit(false);
        if MixedDiscount."Ending date" < CurrDate then
          exit(false);
        if (MixedDiscount."Starting date" = CurrDate) and (MixedDiscount."Starting time" > CurrTime) then
          exit(false);
        //-NPR5.45 [323716]
        // IF (MixedDiscount."Ending date" = CurrDate) AND (MixedDiscount."Ending time" < CurrTime) THEN
        //  EXIT(FALSE);
        if (MixedDiscount."Ending date" = CurrDate) and (MixedDiscount."Ending time" < CurrTime) and (MixedDiscount."Ending time" <> 0T) then
          exit(false);
        //+NPR5.45 [323716]
        //-NPR5.45 [323568]
        if not HasActiveTimeInterval(MixedDiscount) then
          exit(false);
        //+NPR5.45 [323568]

        exit(true);
        //+NPR5.31 [262904]
    end;

    local procedure IsActiveLineNow(var MixedDiscountLine: Record "Mixed Discount Line"): Boolean
    var
        MixedDiscount: Record "Mixed Discount";
    begin
        //-NPR5.31 [262904]
        if MixedDiscountLine.IsTemporary then
          exit(false);

        if not MixedDiscount.Get(MixedDiscountLine.Code) then
          exit(false);

        //-NPR5.45 [323716]
        //EXIT(DiscountActiveNow(MixedDiscount));
        exit(IsActiveNow(MixedDiscount));
        //+NPR5.45 [323716]
        //+NPR5.31 [262904]
    end;

    local procedure HasActiveTimeInterval(MixedDiscount: Record "Mixed Discount"): Boolean
    var
        MixedDiscountTimeInterval: Record "Mixed Discount Time Interval";
        CheckTime: Time;
        CheckDate: Date;
    begin
        //-NPR5.45 [323568]
        MixedDiscountTimeInterval.SetRange("Mix Code",MixedDiscount.Code);
        if MixedDiscountTimeInterval.IsEmpty then
          exit(true);

        CheckTime := Time;
        CheckDate := Today;
        MixedDiscountTimeInterval.FindSet;
        repeat
          if IsActiveTimeInterval(MixedDiscountTimeInterval,CheckTime,CheckDate) then
            exit(true);
        until MixedDiscountTimeInterval.Next = 0;

        exit(false);
        //+NPR5.45 [323568]
    end;

    local procedure IsActiveTimeInterval(MixedDiscountTimeInterval: Record "Mixed Discount Time Interval";CheckTime: Time;CheckDate: Date): Boolean
    begin
        //-NPR5.45 [323568]
        if not IsActiveDay(MixedDiscountTimeInterval,CheckDate) then
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
        //+NPR5.45 [323568]
    end;

    local procedure IsActiveDay(MixedDiscountTimeInterval: Record "Mixed Discount Time Interval";CheckDate: Date): Boolean
    begin
        //-NPR5.45 [323568]
        if MixedDiscountTimeInterval."Period Type" = MixedDiscountTimeInterval."Period Type"::"Every Day" then
          exit(true);

        case Date2DWY(CheckDate,1) of
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
        //+NPR5.45 [323568]
    end;
}

