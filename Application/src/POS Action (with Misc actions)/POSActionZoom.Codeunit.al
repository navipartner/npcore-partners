codeunit 6150803 "NPR POSAction: Zoom"
{
    var
        ActionDescription: Label 'Zoom a sales line.';

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
  ActionCode,
  ActionDescription,
  ActionVersion(),
  Sender.Type::Generic,
  Sender."Subscriber Instances Allowed"::Multiple)
then begin
            Sender.RegisterWorkflowStep('', 'respond();');
            Sender.RegisterWorkflow(false);
            Sender.RegisterDataBinding();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        ZoomLine(Context, POSSession, FrontEnd);
        Handled := true;
    end;

    local procedure ZoomLine(Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        JSON: Codeunit "NPR POS JSON Management";
        Line: Record "NPR POS Sale Line";
        SaleLine: Codeunit "NPR POS Sale Line";
        CurrentView: Codeunit "NPR POS View";
    begin

        POSSession.GetCurrentView(CurrentView);
        if (CurrentView.Type <> CurrentView.Type::Sale) then
            exit;

        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(Line);
        if (Line."Line No." > 0) then begin
            PAGE.RunModal(PAGE::"NPR TouchScreen: SalesLineZoom", Line);
            POSSession.RequestRefreshData();
        end;
    end;

    local procedure ActionCode(): Text
    begin
        exit('ZOOM');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.0');
    end;
}
