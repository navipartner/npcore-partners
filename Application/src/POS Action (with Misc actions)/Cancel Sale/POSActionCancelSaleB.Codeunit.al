codeunit 6059872 "NPR POSAction: Cancel Sale B"
{
    Access = Internal;

    var
        AltSaleCancelDescription: Text;

    procedure CancelSale(POSSession: Codeunit "NPR POS Session"): Boolean
    var
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        Line: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadManagement: Codeunit "NPR NPRE Waiter Pad Mgt.";
        CANCEL_SALELbl: Label 'Sale was canceled %1';
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        if SalePOS."NPRE Pre-Set Waiter Pad No." <> '' then begin
            WaiterPad.Get(SalePOS."NPRE Pre-Set Waiter Pad No.");
            WaiterPadManagement.CloseWaiterPad(WaiterPad, true, "NPR NPRE W/Pad Closing Reason"::"Cancelled Sale");
        end;

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.DeleteAll();

        Line.Type := Line.Type::Comment;
        if AltSaleCancelDescription <> '' then begin
            Line.Description := CopyStr(AltSaleCancelDescription, 1, MaxStrLen(Line.Description));
            Line."Description 2" := CopyStr(AltSaleCancelDescription, MaxStrLen(Line.Description) + 1, MaxStrLen(Line."Description 2"));
        end else
            Line.Description := StrSubstNo(CANCEL_SALELbl, CurrentDateTime);
        Line."Sale Type" := Line."Sale Type"::Cancelled;
        POSSaleLine.InsertLine(Line);

        exit(POSSale.TryEndSale(POSSession, false));
    end;

    procedure CheckSaleBeforeCancel()
    var
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SaleAmount: Decimal;
        Subtotal: Decimal;
        POSSession: Codeunit "NPR POS Session";
        PartlyPaidErr: Label 'This sales can''t be deleted. It has been partly paid. You must first void the payment.';
    begin
        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.CalculateBalance(SaleAmount, PaidAmount, ReturnAmount, Subtotal);
        if (PaidAmount <> 0) then
            Error(PartlyPaidErr);
    end;

    procedure SetAlternativeDescription(NewAltSaleCancelDescription: Text)
    begin
        AltSaleCancelDescription := NewAltSaleCancelDescription;
    end;
}