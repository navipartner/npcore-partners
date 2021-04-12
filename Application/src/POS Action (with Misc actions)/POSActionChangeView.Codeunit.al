codeunit 6150724 "NPR POS Action - Change View"
{
    var
        ActionDescription: Label 'Changes the current view.';
        RemainingLines: Label 'All lines could not be automatically deleted before selecting Login View. You need to cancel sales manually.';

    local procedure ActionCode(): Text
    begin
        exit('CHANGE_VIEW');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.1');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
  ActionCode,
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

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
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
    begin
        JSON.InitializeJObjectParser(Context, FrontEnd);

        ViewType := JSON.GetIntegerParameterOrFail('ViewType', ActionCode());
        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);
        POSDefaultUserView.SetDefault(ViewType, POSUnit."No.", JSON.GetStringParameter('ViewCode'));

        POSSession.GetCurrentView(CurrentView);

        case ViewType of
            ViewType::Login:
                begin
                    POSCreateEntry.InsertUnitLogoutEntry(POSUnit."No.", POSSetup.Salesperson());

                    if (CurrentView.Type = CurrentView.Type::Sale) or (CurrentView.Type = CurrentView.Type::Payment) then begin
                        POSSession.GetSaleLine(POSSaleLine);

                        // if there are lines to delete
                        if (POSSaleLine.RefreshCurrent()) then
                            Error(RemainingLines)
                    end;

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
