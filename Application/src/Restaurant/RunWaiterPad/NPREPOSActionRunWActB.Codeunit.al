codeunit 6151335 "NPR NPRE POSAction: Run WAct-B"
{
    Access = Internal;

    var
        _WPadAction: Option "Print Pre-Receipt","Send Kitchen Order","Request Next Serving","Request Specific Serving","Merge Waiter Pad","Close w/out Saving";

    internal procedure RunWaiterPadAction(WPadAction: Option; WPadLinesToSend: Option "New/Updated",All; ServingStepToRequest: Code[10]; ClearSaleOnFinish: Boolean; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; var NewWaiterPadNo: Code[20]; var ResultMessageText: Text; var CleanupMessageText: Text) ConfirmSaleCleanup: Boolean
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPad2: Record "NPR NPRE Waiter Pad";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        PartlyPaid: Boolean;
        PartlyPaidErr: Label 'This sales has been partly paid. You must first void the payment.';
        WPadNotSelectedErr: Label 'Please select a waiter pad first.';
        ConfirmDeletionQst: Label 'All changes not saved to waiter pad will be lost. Are you sure you want to continue?';
    begin
        Sale.GetCurrentSale(SalePOS);
        if WPadAction <> _WPadAction::"Close w/out Saving" then begin
            if SalePOS."NPRE Pre-Set Waiter Pad No." = '' then
                Error(WPadNotSelectedErr);
            WaiterPad.Get(SalePOS."NPRE Pre-Set Waiter Pad No.");
            WaiterPadPOSMgt.MoveSaleFromPOSToWaiterPad(SalePOS, WaiterPad, false);
            Commit();

            Clear(WaiterPad2);
            if WPadAction = _WPadAction::"Merge Waiter Pad" then begin
                if not WaiterPadPOSMgt.SelectWaiterPadToMergeTo(WaiterPad, WaiterPad2) then
                    Error('');
                SaleLine.DeleteWPadSupportedLinesOnly();
            end;
            WaiterPadPOSMgt.RunWaiterPadAction(WPadAction, WPadLinesToSend = WPadLinesToSend::All, ServingStepToRequest, WaiterPad, WaiterPad2, ResultMessageText);
            IF WPadAction = _WPadAction::"Merge Waiter Pad" then
                NewWaiterPadNo := WaiterPad2."No.";
        end;

        if (WPadAction = _WPadAction::"Close w/out Saving") or ClearSaleOnFinish then begin
            SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
            SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
            SaleLinePOS.SetRange("Line Type", SaleLinePOS."Line Type"::"POS Payment");
            SaleLinePOS.SetFilter("Amount Including VAT", '<> %1', 0);
            PartlyPaid := not SaleLinePOS.IsEmpty();
            if PartlyPaid and (WPadAction = _WPadAction::"Close w/out Saving") then
                Error(PartlyPaidErr)
        end;

        if (WPadAction <> _WPadAction::"Merge Waiter Pad") or ClearSaleOnFinish then begin
            if WPadAction = _WPadAction::"Close w/out Saving" then begin
                CleanupMessageText := ConfirmDeletionQst;
                ConfirmSaleCleanup := true;
            end else
                if WaiterPadPOSMgt.UnsupportedSaleLinesExist(SalePOS) then begin
                    CleanupMessageText := WaiterPadPOSMgt.UnableToCleanupSaleMsgText(not PartlyPaid);
                    ConfirmSaleCleanup := not PartlyPaid;
                end;
        end;
    end;

    internal procedure CleanupSale(WPadAction: Option; NewWaiterPadNo: Code[20]; ClearSaleOnFinish: Boolean; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line")
    var
        SalePOS: Record "NPR POS Sale";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        POSSession: Codeunit "NPR POS Session";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        if not (ClearSaleOnFinish or (WPadAction in [_WPadAction::"Merge Waiter Pad", _WPadAction::"Close w/out Saving"])) then
            exit;

        if (WPadAction <> _WPadAction::"Merge Waiter Pad") or ClearSaleOnFinish then
            SaleLine.DeleteAll();

        Sale.GetCurrentSale(SalePOS);
        SalePOS.Find();
        WaiterPadPOSMgt.ClearSaleHdrNPREPresetFields(SalePOS, false);
        Sale.Refresh(SalePOS);
        Sale.Modify(true, false);

        if (WPadAction = _WPadAction::"Merge Waiter Pad") and not ClearSaleOnFinish then begin
            WaiterPad."No." := NewWaiterPadNo;
            WaiterPad.Find();
            WaiterPadPOSMgt.GetSaleFromWaiterPadToPOS(WaiterPad, POSSession);
        end;
    end;
}