codeunit 6150719 "NPR POS Action Management"
{
    EventSubscriberInstance = Manual;

    var
        TempDiscoveryState: Record "Event Subscription" temporary;
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

    local procedure InitializeDiscoveryState(var State: Record "Event Subscription" temporary)
    var
        EventSubscriber: Record "Event Subscription";
    begin
        if not State.IsTemporary then
            Error('Function call on a non-temporary variable. This is a critical programming error.');

        State.DeleteAll();
        EventSubscriber.SetRange("Publisher Object Type", EventSubscriber."Publisher Object Type"::Table);
        EventSubscriber.SetRange("Publisher Object ID", 6150703);
        EventSubscriber.SetRange("Published Function", 'OnDiscoverActions');
        if EventSubscriber.FindSet() then
            repeat
                State := EventSubscriber;
                State.Insert();
            until EventSubscriber.Next() = 0;
    end;

    procedure InitializeActionDiscovery()
    begin
        InitializeDiscoveryState(TempDiscoveryState);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnActionDiscovered', '', false, false)]
    local procedure OnActionDiscovered(var Rec: Record "NPR POS Action")
    var
        TempNewDiscoveryState: Record "Event Subscription" temporary;
    begin
        InitializeDiscoveryState(TempNewDiscoveryState);
        if TempNewDiscoveryState.FindSet() then
            repeat
                if TempDiscoveryState.Get(TempNewDiscoveryState."Subscriber Codeunit ID", TempNewDiscoveryState."Subscriber Function") and
                   (TempDiscoveryState."Number of Calls" <> TempNewDiscoveryState."Number of Calls")
                then begin
                    TempDiscoveryState."Number of Calls" := TempNewDiscoveryState."Number of Calls";
                    TempDiscoveryState.Modify();
                    Rec."Codeunit ID" := TempNewDiscoveryState."Subscriber Codeunit ID";
                end;
            until TempNewDiscoveryState.Next() = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInvalidActionConfiguration(Source: Text; "Action": Text; ErrorText: Text)
    begin
    end;
}
