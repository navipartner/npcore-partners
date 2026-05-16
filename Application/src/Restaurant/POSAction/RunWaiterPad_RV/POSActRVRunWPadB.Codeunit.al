codeunit 6151336 "NPR POSAct. RV Run W/PadB"
{
    Access = Internal;

    procedure RunWaiterPadAction(WPadAction: Option "Print Pre-Receipt","Send Kitchen Order","Request Next Serving","Request Specific Serving","Merge Waiter Pad","Open Waiter Pad"; WaiterPadNo: Code[20]; WPadLinesToSend: Option "New/Updated",All; ServingStepToRequest: Code[10]; var ResultMessageText: Text)
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        ConfirmMsg: Text;
        WPadIsOpenedInPOSSale: Label 'The waiter pad is opened in a POS sale at the moment and might have unsaved changes. Are you sure you want to continue on running the action?';
        WPadIsHeldInParkedSale: Label 'The waiter pad is held in a parked POS sale at the moment. Are you sure you want to continue on running the action?';
    begin
        WaiterPad."No." := WaiterPadNo;
        WaiterPad.Find();

        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPad."No.");
        WaiterPadLine.SetFilter("Sale Retail ID", '<>%1', WaiterPadPOSMgt.GetNullGuid());
        if WaiterPadLine.FindFirst() then begin
            if WaiterPadPOSMgt.IsParkedSale(WaiterPadLine."Sale Retail ID") then
                ConfirmMsg := WPadIsHeldInParkedSale
            else
                ConfirmMsg := WPadIsOpenedInPOSSale;
            if not Confirm(ConfirmMsg, false) then
                Error('');
        end;

        WaiterPadPOSMgt.RunWaiterPadAction(WPadAction, WPadLinesToSend = WPadLinesToSend::All, ServingStepToRequest, false, WaiterPad, ResultMessageText);
    end;
}