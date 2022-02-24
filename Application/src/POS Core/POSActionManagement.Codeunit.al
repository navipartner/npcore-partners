codeunit 6150719 "NPR POS Action Management"
{
    Access = Internal;
    EventSubscriberInstance = Manual;

    var
        ActionsDiscovered: Boolean;

    procedure LookupAction(var ActionCode: Code[20]): Boolean
    var
        POSAction: Record "NPR POS Action";
        POSActions: Page "NPR POS Actions";
    begin
        POSActions.LookupMode := true;
        POSActions.SetSkipDiscovery(ActionsDiscovered);
        POSActions.SetAction(ActionCode);
        ActionsDiscovered := true;
        if POSActions.RunModal() = ACTION::LookupOK then begin
            POSActions.GetRecord(POSAction);
            ActionCode := POSAction.Code;
            exit(true);
        end;
    end;

    procedure IsValidActionConfiguration(POSSession: Codeunit "NPR POS Session"; ActionObject: Interface "NPR IAction"; Source: Text; var ErrorText: Text; var Severity: Integer; RaiseEvent: Boolean) Result: Boolean
    var
        ActionMoniker: Text;
    begin
        Result := ActionObject.CheckConfiguration(POSSession, Source, ActionMoniker, ErrorText, Severity);

        if not Result then
            ReportError(ActionObject, Source, ActionMoniker, ErrorText, Severity, RaiseEvent);
    end;

    local procedure ReportError(ActionObject: Interface "NPR IAction"; Source: Text; "Action": Text; ErrorText: Text; Severity: Integer; RaiseEvent: Boolean)
    begin
        ActionObject.Content().Add('error', ErrorText);
        ActionObject.Content().Add('errorSeverity', Severity);
        if RaiseEvent then
            OnInvalidActionConfiguration(Source, Action, ErrorText);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInvalidActionConfiguration(Source: Text; "Action": Text; ErrorText: Text)
    begin
    end;
}
