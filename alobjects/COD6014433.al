codeunit 6014433 "Customer Discount Management"
{
    // NPR5.29/TJ/20161223 CASE 249720 Replaced calling of standard codeunit 7000 Sales Price Calc. Mgt. with our own codeunit 6014453 POS Sales Price Calc. Mgt.
    // NPR5.31/MHA /20170210  CASE 262904 Applied Event triggered Discount Calculation: OnInitDiscountPriority(),OnApplyDiscount(),IsSubscribedDiscount(),DiscSourceTableId(),DiscCalcCodeunitId()
    // NPR5.38/MHA /20171204  CASE 298276 Removed Discount Cache
    // NPR5.40/MMV /20180213  CASE 294655 Performance optimization
    // NPR5.44/MMV /20180627  CASE 312154 Fixed incorrect cross line discount handling when different types collided.
    // NPR5.48/MMV /20181214 CASE 340109 Set discount modified flag on lines being considered so auto disable works.


    trigger OnRun()
    begin
    end;

    procedure ApplyCustomerDiscount(SalePOS: Record "Sale POS";var TempSaleLinePOS: Record "Sale Line POS" temporary;Rec: Record "Sale Line POS";RecalculateAllLines: Boolean)
    var
        Customer: Record Customer;
        TempSaleLinePOS2: Record "Sale Line POS" temporary;
    begin
        if Customer.Get(SalePOS."Customer No.") and not Customer."Allow Line Disc." then
          exit;

        //-NPR5.44 [312154]
        // IF NOT TempSaleLinePOS.GET(Rec."Register No.", Rec."Sales Ticket No.", Rec.Date, Rec."Sale Type", Rec."Line No.") THEN
        //  EXIT;
        // IF NOT TempSaleLinePOS."Allow Line Discount" THEN
        //  EXIT;
        //
        // IF TempSaleLinePOS."Discount Type" = TempSaleLinePOS."Discount Type"::" " THEN BEGIN
        //  ApplyCustomerDiscountOnLine(SalePOS, TempSaleLinePOS);
        //  TempSaleLinePOS.MODIFY;
        // END;
        //
        // IF TempSaleLinePOS."Discount Type" = TempSaleLinePOS."Discount Type"::Campaign THEN BEGIN
        //  TempSaleLinePOS2.COPY(TempSaleLinePOS, TRUE);
        //  ApplyCustomerDiscountOnLine(SalePOS, TempSaleLinePOS2);
        //  IF TempSaleLinePOS2."Discount %" <= TempSaleLinePOS."Discount %" THEN
        //    EXIT;
        //  TempSaleLinePOS2.MODIFY;
        // END;

        Clear(TempSaleLinePOS);
        if RecalculateAllLines then begin
          TempSaleLinePOS.SetRange("Register No.", Rec."Register No.");
          TempSaleLinePOS.SetRange("Sales Ticket No.", Rec."Sales Ticket No.");
          TempSaleLinePOS.SetRange(Date, Rec.Date);
          TempSaleLinePOS.SetRange("Sale Type", Rec."Sale Type");
          TempSaleLinePOS.SetFilter("Discount Type", '=%1|=%2', TempSaleLinePOS."Discount Type"::" ", TempSaleLinePOS."Discount Type"::Campaign);
          if TempSaleLinePOS.FindSet then
            repeat
              ApplyDiscountOnLine(SalePOS, TempSaleLinePOS);
            until TempSaleLinePOS.Next = 0;
        end else
          if TempSaleLinePOS.Get(Rec."Register No.", Rec."Sales Ticket No.", Rec.Date, Rec."Sale Type", Rec."Line No.") then
            ApplyDiscountOnLine(SalePOS, TempSaleLinePOS);
        //+NPR5.44 [312154]
    end;

    local procedure ApplyDiscountOnLine(SalePOS: Record "Sale POS";var TempSaleLinePOS: Record "Sale Line POS" temporary)
    var
        TempSaleLinePOS2: Record "Sale Line POS" temporary;
    begin
        //-NPR5.44 [312154]
        //-NPR5.48 [340109]
        TempSaleLinePOS."Discount Calculated" := true;
        TempSaleLinePOS.Modify;
        //+NPR5.48 [340109]

        if not TempSaleLinePOS."Allow Line Discount" then
          exit;

        if TempSaleLinePOS."Discount Type" = TempSaleLinePOS."Discount Type"::" " then begin
          ApplyCustomerDiscountOnLine(SalePOS, TempSaleLinePOS);
          TempSaleLinePOS.Modify;
        end;

        if TempSaleLinePOS."Discount Type" = TempSaleLinePOS."Discount Type"::Campaign then begin
          TempSaleLinePOS2.Copy(TempSaleLinePOS, true);
          ApplyCustomerDiscountOnLine(SalePOS, TempSaleLinePOS2);
          if TempSaleLinePOS2."Discount %" <= TempSaleLinePOS."Discount %" then
            exit;
          TempSaleLinePOS2.Modify;
        end;
        //+NPR5.44 [312154]
    end;

    local procedure ApplyCustomerDiscountOnLine(SalePOS: Record "Sale POS";var TempSaleLinePOS: Record "Sale Line POS" temporary)
    var
        POSSalesPriceCalcMgt: Codeunit "POS Sales Price Calc. Mgt.";
    begin
        //-NPR5.40 [294655]
        POSSalesPriceCalcMgt.FindSalesLineLineDisc(SalePOS,TempSaleLinePOS);
        if TempSaleLinePOS."Discount %" > 0 then begin
          TempSaleLinePOS."Discount Type" := TempSaleLinePOS."Discount Type"::Customer;
          TempSaleLinePOS."FP Anvendt" := false;
          TempSaleLinePOS."MR Anvendt antal" := 0;
          TempSaleLinePOS."Discount Calculated" := true;
          TempSaleLinePOS.Modify;
        end;
        //+NPR5.40 [294655]
    end;

    local procedure "--- Subscription"()
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
        DiscountPriority.Priority := 2;
        DiscountPriority.Disabled := false;
        DiscountPriority."Discount Calc. Codeunit ID" := DiscCalcCodeunitId();
        DiscountPriority.Insert(true);
        //+NPR5.31 [262904]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014455, 'ApplyDiscount', '', true, true)]
    local procedure OnApplyDiscount(DiscountPriority: Record "Discount Priority";SalePOS: Record "Sale POS";var TempSaleLinePOS: Record "Sale Line POS" temporary;Rec: Record "Sale Line POS";xRec: Record "Sale Line POS";LineOperation: Option Insert,Modify,Delete;RecalculateAllLines: Boolean)
    begin
        if not IsSubscribedDiscount(DiscountPriority) then
          exit;

        //-NPR5.44 [312154]
        //ApplyCustomerDiscount(SalePOS,TempSaleLinePOS,Rec);
        ApplyCustomerDiscount(SalePOS,TempSaleLinePOS,Rec,RecalculateAllLines);
        //+NPR5.44 [312154]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014455, 'OnFindActiveSaleLineDiscounts', '', false, false)]
    local procedure OnFindActiveSaleLineDiscounts(var tmpDiscountPriority: Record "Discount Priority" temporary;Rec: Record "Sale Line POS";xRec: Record "Sale Line POS";LineOperation: Option Insert,Modify,Delete)
    var
        IsActive: Boolean;
        DiscountPriority: Record "Discount Priority";
        POSSalesPriceCalcMgt: Codeunit "POS Sales Price Calc. Mgt.";
        SalePOS: Record "Sale POS";
    begin
        //-NPR5.40 [294655]
        if not DiscountPriority.Get(DiscSourceTableId()) then
          exit;
        if not IsSubscribedDiscount(DiscountPriority) then
          exit;
        if not IsValidLineOperation(Rec, xRec, LineOperation) then
          exit;

        SalePOS.Get(Rec."Register No.", Rec."Sales Ticket No.");
        if POSSalesPriceCalcMgt.SalesLineLineDiscExists(SalePOS, Rec, false) then begin
          tmpDiscountPriority.Init;
          tmpDiscountPriority := DiscountPriority;
          tmpDiscountPriority.Insert;
        end;
        //+NPR5.40 [294655]
    end;

    local procedure IsValidLineOperation(Rec: Record "Sale Line POS";xRec: Record "Sale Line POS";LineOperation: Option Insert,Modify,Delete): Boolean
    begin
        //-NPR5.40 [294655]
        if LineOperation = LineOperation::Delete then
          exit(false);

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
        exit(DATABASE::"Sales Line Discount");
        //+NPR5.31 [262904]
    end;

    local procedure DiscCalcCodeunitId(): Integer
    begin
        //-NPR5.31 [262904]
        exit(CODEUNIT::"Customer Discount Management");
        //+NPR5.31 [262904]
    end;

    local procedure DiscountLineActiveNow(var SalesLineDiscount: Record "Sales Line Discount"): Boolean
    var
        CurrDate: Date;
        CurrTime: Time;
    begin
        //-NPR5.31 [262904]
        if SalesLineDiscount.IsTemporary then
          exit(false);

        CurrDate := Today;
        CurrTime := Time;
        if SalesLineDiscount."Starting Date" > CurrDate then
          exit(false);
        if (SalesLineDiscount."Ending Date" >  0D) and (SalesLineDiscount."Ending Date" < CurrDate) then
          exit(false);

        exit(true);
        //+NPR5.31 [262904]
    end;
}

