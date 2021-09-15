codeunit 6150803 "NPR POSAction: Zoom"
{
    var
        ActionDescription: Label 'Zoom a sales line.';

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
            ActionCode(),
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        ZoomLine(POSSession);
        Handled := true;
    end;

    local procedure ZoomLine(POSSession: Codeunit "NPR POS Session")
    var
        Line: Record "NPR POS Sale Line";
        SaleLine: Codeunit "NPR POS Sale Line";
        CurrentView: Codeunit "NPR POS View";
    begin

        POSSession.GetCurrentView(CurrentView);
        if (CurrentView.Type() <> CurrentView.Type() ::Sale) then
            exit;

        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(Line);
        if (Line."Line No." > 0) then begin
            PAGE.RunModal(PAGE::"NPR TouchScreen: SalesLineZoom", Line);
            POSSession.RequestRefreshData();
        end;
    end;

    local procedure ActionCode(): Code[20]
    begin
        exit('ZOOM');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.0');
    end;
}
