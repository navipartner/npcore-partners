codeunit 6059880 "NPR POS Action: Change View-B"
{
    Access = Internal;

    procedure ChangeView(ViewType: Option Login,Sale,Payment,Balance,Locked; ViewCode: Code[10])
    var
        POSDefaultUserView: Record "NPR POS Default User View";
        POSUnit: Record "NPR POS Unit";
        POSSetup: Codeunit "NPR POS Setup";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        CurrentView: Codeunit "NPR POS View";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSTryCancelSale: Codeunit "NPR POS Resume Sale Mgt.";
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        POSTestItemInventory: Codeunit "NPR POS Test Item Inventory";
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
        CancelSaleLbl: Label 'There is an active sale. If you continue the sale will be automatically cancelled. Are you sure you want to continue?';
    begin
        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);
        POSDefaultUserView.SetDefault(ViewType, POSUnit."No.", ViewCode);

        POSSession.GetCurrentView(CurrentView);

        case ViewType of
            ViewType::Login:
                begin

                    if (CurrentView.GetType() = CurrentView.GetType() ::Sale) or (CurrentView.GetType() = CurrentView.GetType() ::Payment) then begin
                        POSSession.GetSaleLine(POSSaleLine);

                        // if there are lines to delete
                        if (POSSaleLine.RefreshCurrent()) then
                            if not Confirm(CancelSaleLbl, true) then
                                Error('');

                        POSSession.GetSale(POSSale);
                        POSSale.GetCurrentSale(SalePOS);
                        if CheckIfPOSSaleEmpty(SalePOS."Register No.", SalePOS."Sales Ticket No.") then
                            SalePOS."Empty Sale On Login/Logout" := true;
                        POSTryCancelSale.DoCancelSale(SalePOS, POSSession);
                    end;

                    POSCreateEntry.InsertUnitLogoutEntry(POSUnit."No.", POSSetup.Salesperson());
                    POSSession.StartPOSSession();

                end;
            ViewType::Sale:
                POSSession.ChangeViewSale();
            ViewType::Payment:
                begin
                    if FeatureFlagsManagement.IsEnabled('removeviewswitchscenarios') then begin
                        POSSession.GetSale(POSSale);
                        POSSale.GetCurrentSale(SalePOS);
                        POSTestItemInventory.Run(SalePOS);
                    end;
                    POSSession.ChangeViewPayment();
                end;
            ViewType::Balance:
                POSSession.ChangeViewBalancing();
            ViewType::Locked:
                begin
                    POSCreateEntry.InsertUnitLockEntry(POSUnit."No.", POSSetup.Salesperson());
                    POSSession.ChangeViewLocked();
                end;
        end;
    end;

    local procedure CheckIfPOSSaleEmpty(RegisterNo: Code[10]; SalesTicketNo: Code[20]): Boolean
    var
        POSSaleLine: Record "NPR POS Sale Line";
    begin
        POSSaleLine.SetRange("Register No.", RegisterNo);
        POSSaleLine.SetRange("Sales Ticket No.", SalesTicketNo);
        if POSSaleLine.IsEmpty() then
            exit(true);
    end;
}