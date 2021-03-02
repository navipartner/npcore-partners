codeunit 6150724 "NPR POS Action - Change View"
{
    var
        ActionDescription: Label 'Changes the current view.';
        ActionOptions: Label 'Login,Sale,Payment,Balance,Locked';
        POS_LOGOUT: Label 'User logged out from POS %1.';
        ConfirmPrompt: Label 'Are you sure you want to cancel this sales? All lines will be deleted.';
        RemovePayment: Label 'All payment lines must be removed before selecting Login View.';
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
        with Sender do
            if DiscoverAction(
              ActionCode,
              ActionDescription,
              ActionVersion,
              Type::Generic,
              "Subscriber Instances Allowed"::Single)
            then begin
                RegisterWorkflow(false);

                RegisterOptionParameter('ViewType', 'Login,Sale,Payment,Balance,Locked', '');
                RegisterTextParameter('ViewCode', '');
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        ControlId: Text;
        Value: Text;
        DoNotClearTextBox: Boolean;
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        ChangeView(Context, POSSession, FrontEnd);

        Handled := true;
    end;

    local procedure ChangeView(Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        Item: Record Item;
        POSAction: Record "NPR POS Action";
        POSDefaultUserView: Record "NPR POS Default User View";
        POSUnit: Record "NPR POS Unit";
        POSSetup: Codeunit "NPR POS Setup";
        JSON: Codeunit "NPR POS JSON Management";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        ViewType: Option Login,Sale,Payment,Balance,Locked;
        CurrentView: Codeunit "NPR POS View";
        POSActionCancelSale: Codeunit "NPR POSAction: Cancel Sale";
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
