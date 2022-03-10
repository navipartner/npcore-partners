codeunit 6150724 "NPR POS Action - Change View"
{
    Access = Internal;

    var
        ActionDescription: Label 'Changes the current view.';
        CancelSaleLbl: Label 'There is an active sale. If you continue the sale will be automatically cancelled. Are you sure you want to continue?';

    local procedure ActionCode(): Code[20]
    begin
        exit('CHANGE_VIEW');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.1');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
            ActionCode(),
            ActionDescription,
            ActionVersion(),
            Sender.Type::Generic,
            Sender."Subscriber Instances Allowed"::Single)
        then begin
            Sender.RegisterWorkflow(false);
            Sender.RegisterOptionParameter('ViewType', 'Login,Sale,Payment,Balance,Locked', '');
            Sender.RegisterTextParameter('ViewCode', '');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        ChangeView(Context, POSSession, FrontEnd);

        Handled := true;

    end;

    local procedure ChangeView(Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        POSDefaultUserView: Record "NPR POS Default User View";
        POSUnit: Record "NPR POS Unit";
        POSSetup: Codeunit "NPR POS Setup";
        JSON: Codeunit "NPR POS JSON Management";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        ViewType: Option Login,Sale,Payment,Balance,Locked;
        CurrentView: Codeunit "NPR POS View";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSTryCancelSale: Codeunit "NPR POS Resume Sale Mgt.";
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";

    begin
        JSON.InitializeJObjectParser(Context, FrontEnd);

        ViewType := JSON.GetIntegerParameterOrFail('ViewType', ActionCode());
        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);
        POSDefaultUserView.SetDefault(ViewType, POSUnit."No.", CopyStr(JSON.GetStringParameter('ViewCode'), 1, 10));

        POSSession.GetCurrentView(CurrentView);

        case ViewType of
            ViewType::Login:
                begin

                    if (CurrentView.Type() = CurrentView.Type() ::Sale) or (CurrentView.Type() = CurrentView.Type() ::Payment) then begin
                        POSSession.GetSaleLine(POSSaleLine);

                        // if there are lines to delete
                        if (POSSaleLine.RefreshCurrent()) then
                            if not Confirm(CancelSaleLbl, true) then
                                Error('');

                        POSSession.GetSale(POSSale);
                        POSSale.GetCurrentSale(SalePOS);
                        POSTryCancelSale.DoCancelSale(SalePOS, POSSession);
                    end;

                    POSCreateEntry.InsertUnitLogoutEntry(POSUnit."No.", POSSetup.Salesperson());
                    POSSession.StartPOSSession();

                end;
            ViewType::Sale:
                POSSession.ChangeViewSale();
            ViewType::Payment:
                POSSession.ChangeViewPayment();
            ViewType::Balance:
                POSSession.ChangeViewBalancing();
            ViewType::Locked:
                begin
                    POSCreateEntry.InsertUnitLockEntry(POSUnit."No.", POSSetup.Salesperson());
                    POSSession.ChangeViewLocked();
                end;
        end;
    end;
}
