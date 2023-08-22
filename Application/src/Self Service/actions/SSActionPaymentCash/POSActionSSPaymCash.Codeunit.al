codeunit 6151334 "NPR POS Action SS Paym. Cash"
{
    Access = Internal;
    procedure EndSale(POSSession: Codeunit "NPR POS Session"; POSPaymentMethod: Record "NPR POS Payment Method"): Boolean
    var
        POSSetup: Codeunit "NPR POS Setup";
        ReturnPOSPaymentMethod: Record "NPR POS Payment Method";
        POSSale: Codeunit "NPR POS Sale";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        POSLine: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
    begin
        POSSession.GetSetup(POSSetup);
        POSSession.GetSale(POSSale);
        ReturnPOSPaymentMethod.Get(POSPaymentMethod."Return Payment Method Code");
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetPaymentLine(POSPaymentLine);
        Clear(POSLine);
        POSLine."Register No." := POSSetup.GetPOSUnitNo();
        POSLine."No." := POSPaymentMethod.Code;
        POSLine."Register No." := SalePOS."Register No.";
        POSLine."Sales Ticket No." := SalePOS."Sales Ticket No.";
        IF CaptureCashPayment(GetAmountSuggestion(POSSession, POSPaymentMethod), POSPaymentLine, POSLine, POSPaymentMethod) THEN
            POSSale.TryEndDirectSaleWithBalancing(POSSession, POSPaymentMethod, ReturnPOSPaymentMethod);
    end;

    procedure EnsureSaleIsNotEmpty(POSSession: Codeunit "NPR POS Session")
    var
        POSAuditProfile: Record "NPR POS Audit Profile";
        POSUnit: Record "NPR POS Unit";
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        Setup: Codeunit "NPR POS Setup";
        NO_SALES_LINES: Label 'There are no sales lines in the POS. You must add at least one sales line before handling payment.';
    begin
        POSSession.GetSetup(Setup);
        Setup.GetPOSUnit(POSUnit);
        PosUnit.GetProfile(POSAuditProfile);
        if not POSAuditProfile."Allow Zero Amount Sales" then begin
            POSSession.GetSale(POSSale);
            POSSale.GetCurrentSale(SalePOS);
            SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
            SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
            SaleLinePOS.SetFilter("Line Type", '<>%1', SaleLinePOS."Line Type"::Comment);
            if SaleLinePOS.IsEmpty() then
                Error(NO_SALES_LINES);
        end;
    end;

    local procedure GetAmountSuggestion(POSSession: Codeunit "NPR POS Session"; POSPaymentMethod: Record "NPR POS Payment Method"): Decimal
    var
        POSPaymentLine: Codeunit "NPR POS Payment Line";
    begin
        POSSession.GetPaymentLine(POSPaymentLine);
        exit(POSPaymentLine.CalculateRemainingPaymentSuggestionInCurrentSale(POSPaymentMethod));
    end;

    local procedure CaptureCashPayment(AmountToCaptureLCY: Decimal; POSPaymentLine: Codeunit "NPR POS Payment Line"; var POSLine: Record "NPR POS Sale Line"; POSPaymentMethod: Record "NPR POS Payment Method"): Boolean
    var
        AmountToCapture: Decimal;
        DefaultAmountToCapture: Decimal;
    begin
        AmountToCapture := AmountToCaptureLCY;
        DefaultAmountToCapture := AmountToCapture;

        if AmountToCaptureLCY = 0 then
            exit(true);

        POSPaymentLine.ValidateAmountBeforePayment(POSPaymentMethod, AmountToCaptureLCY, DefaultAmountToCapture);

        if (POSPaymentMethod."Fixed Rate" <> 0) then begin
            POSLine."Amount Including VAT" := 0;
            POSPaymentLine.InsertPaymentLine(POSLine, AmountToCapture);
        end else begin
            POSLine."Amount Including VAT" := AmountToCaptureLCY;
            POSPaymentLine.InsertPaymentLine(POSLine, 0);
        end;
        exit(true);
    end;

}

