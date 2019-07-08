codeunit 6150803 "POS Action - Zoom"
{

    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'Zoom a sales line.';

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        with Sender do
          if DiscoverAction(
            ActionCode,
            ActionDescription,
            ActionVersion,
            Sender.Type::Generic,
            Sender."Subscriber Instances Allowed"::Multiple)
          then begin
            RegisterWorkflowStep ('', 'respond();');
            RegisterWorkflow(false);
            RegisterDataBinding();
          end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        Confirmed: Boolean;
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        ZoomLine (Context, POSSession, FrontEnd);
        Handled := true;
    end;

    local procedure ZoomLine(Context: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    var
        JSON: Codeunit "POS JSON Management";
        Line: Record "Sale Line POS";
        SaleLine: Codeunit "POS Sale Line";
        CurrentView: DotNet View0;
        ViewType: DotNet ViewType0;
    begin

        POSSession.GetCurrentView (CurrentView);
        if (not CurrentView.Type.Equals(ViewType.Sale)) then
          exit;

        POSSession.GetSaleLine (SaleLine);
        SaleLine.GetCurrentSaleLine (Line);
        if (Line."Line No." > 0) then begin
          PAGE.RunModal(PAGE::"Touch Screen - Sales Line Zoom", Line);
          POSSession.RequestRefreshData ();
        end;
    end;

    local procedure ActionCode(): Text
    begin
        exit ('ZOOM');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.0');
    end;
}

