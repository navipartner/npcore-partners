codeunit 6014433 "NPR Customer Discount Mgt."
{
    trigger OnRun()
    begin
    end;

    procedure ApplyCustomerDiscount(SalePOS: Record "NPR POS Sale"; var TempSaleLinePOS: Record "NPR POS Sale Line" temporary; Rec: Record "NPR POS Sale Line"; RecalculateAllLines: Boolean)
    var
        Customer: Record Customer;
    begin
        if Customer.Get(SalePOS."Customer No.") and not Customer."Allow Line Disc." then
            exit;

        Clear(TempSaleLinePOS);
        if RecalculateAllLines then begin
            TempSaleLinePOS.SetRange("Register No.", Rec."Register No.");
            TempSaleLinePOS.SetRange("Sales Ticket No.", Rec."Sales Ticket No.");
            TempSaleLinePOS.SetRange(Date, Rec.Date);
            TempSaleLinePOS.SetRange("Sale Type", Rec."Sale Type");
            TempSaleLinePOS.SetFilter("Discount Type", '=%1|=%2', TempSaleLinePOS."Discount Type"::" ", TempSaleLinePOS."Discount Type"::Campaign);
            if TempSaleLinePOS.FindSet() then
                repeat
                    ApplyDiscountOnLine(SalePOS, TempSaleLinePOS);
                until TempSaleLinePOS.Next() = 0;
        end else
            if TempSaleLinePOS.Get(Rec."Register No.", Rec."Sales Ticket No.", Rec.Date, Rec."Sale Type", Rec."Line No.") then
                ApplyDiscountOnLine(SalePOS, TempSaleLinePOS);
    end;

    local procedure ApplyDiscountOnLine(SalePOS: Record "NPR POS Sale"; var TempSaleLinePOS: Record "NPR POS Sale Line" temporary)
    var
        TempSaleLinePOS2: Record "NPR POS Sale Line" temporary;
    begin
        if not TempSaleLinePOS."Allow Line Discount" then
            exit;

        TempSaleLinePOS."Discount Calculated" := true;
        TempSaleLinePOS.Modify();

        if TempSaleLinePOS."Discount Type" = TempSaleLinePOS."Discount Type"::" " then begin
            ApplyCustomerDiscountOnLine(SalePOS, TempSaleLinePOS);
            TempSaleLinePOS.Modify();
        end;

        if TempSaleLinePOS."Discount Type" = TempSaleLinePOS."Discount Type"::Campaign then begin
            TempSaleLinePOS2.Copy(TempSaleLinePOS, true);
            ApplyCustomerDiscountOnLine(SalePOS, TempSaleLinePOS2);
            if TempSaleLinePOS2."Discount %" <= TempSaleLinePOS."Discount %" then
                exit;
            TempSaleLinePOS2.Modify();
        end;
    end;

    local procedure ApplyCustomerDiscountOnLine(SalePOS: Record "NPR POS Sale"; var TempSaleLinePOS: Record "NPR POS Sale Line" temporary)
    var
        POSSalesPriceCalcMgt: Codeunit "NPR POS Sales Price Calc. Mgt.";
    begin
        POSSalesPriceCalcMgt.FindSalesLineLineDisc(SalePOS, TempSaleLinePOS);
        if TempSaleLinePOS."Discount %" > 0 then begin
            TempSaleLinePOS."Discount Type" := TempSaleLinePOS."Discount Type"::Customer;
            TempSaleLinePOS."FP Anvendt" := false;
            TempSaleLinePOS."MR Anvendt antal" := 0;
            TempSaleLinePOS."Discount Calculated" := true;
            TempSaleLinePOS.Modify();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sales Disc. Calc. Mgt.", 'InitDiscountPriority', '', true, true)]
    local procedure OnInitDiscountPriority(var DiscountPriority: Record "NPR Discount Priority")
    begin
        if DiscountPriority.Get(DiscSourceTableId()) then
            exit;

        DiscountPriority.Init();
        DiscountPriority."Table ID" := DiscSourceTableId();
        DiscountPriority.Priority := 2;
        DiscountPriority.Disabled := false;
        DiscountPriority."Discount Calc. Codeunit ID" := DiscCalcCodeunitId();
        DiscountPriority.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sales Disc. Calc. Mgt.", 'ApplyDiscount', '', true, true)]
    local procedure OnApplyDiscount(DiscountPriority: Record "NPR Discount Priority"; SalePOS: Record "NPR POS Sale"; var TempSaleLinePOS: Record "NPR POS Sale Line" temporary; Rec: Record "NPR POS Sale Line"; xRec: Record "NPR POS Sale Line"; LineOperation: Option Insert,Modify,Delete; RecalculateAllLines: Boolean)
    begin
        if not IsSubscribedDiscount(DiscountPriority) then
            exit;

        ApplyCustomerDiscount(SalePOS, TempSaleLinePOS, Rec, RecalculateAllLines);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sales Disc. Calc. Mgt.", 'OnFindActiveSaleLineDiscounts', '', false, false)]
    local procedure OnFindActiveSaleLineDiscounts(var tmpDiscountPriority: Record "NPR Discount Priority" temporary; SalePOS: Record "NPR POS Sale"; Rec: Record "NPR POS Sale Line"; xRec: Record "NPR POS Sale Line"; LineOperation: Option Insert,Modify,Delete)
    var
        DiscountPriority: Record "NPR Discount Priority";
        POSSalesPriceCalcMgt: Codeunit "NPR POS Sales Price Calc. Mgt.";
    begin
        if not DiscountPriority.Get(DiscSourceTableId()) then
            exit;
        if not IsSubscribedDiscount(DiscountPriority) then
            exit;
        if not IsValidLineOperation(LineOperation) then
            exit;

        if POSSalesPriceCalcMgt.SalesLineLineDiscExists(SalePOS, Rec, false) then begin
            tmpDiscountPriority.Init();
            tmpDiscountPriority := DiscountPriority;
            tmpDiscountPriority.Insert();
        end;
    end;

    local procedure IsValidLineOperation(LineOperation: Option Insert,Modify,Delete): Boolean
    begin
        if LineOperation = LineOperation::Delete then
            exit(false);

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
        exit(DATABASE::"Price List Line");
    end;

    local procedure DiscCalcCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR Customer Discount Mgt.");
    end;
}