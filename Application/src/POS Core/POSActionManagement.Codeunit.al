codeunit 6150719 "NPR POS Action Management"
{
    EventSubscriberInstance = Manual;

    var
        DiscoveryState: Record "Event Subscription" temporary;
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

    procedure IsValidActionConfiguration(POSSession: Codeunit "NPR POS Session"; ActionObject: Interface "NPR IAction"; Source: Text; var ErrorText: Text; RaiseEvent: Boolean) Result: Boolean
    var
        Severity: Integer;
        ActionMoniker: Text;
    begin
        Result := ActionObject.CheckConfiguration(POSSession, Source, ActionMoniker, ErrorText, Severity);

        if not Result then
            ReportError(ActionObject, Source, ActionMoniker, ErrorText, Severity, RaiseEvent);
    end;

    local procedure ReportError(ActionObject: Interface "NPR IAction"; Source: Text; "Action": Text; ErrorText: Text; Severity: Integer; RaiseEvent: Boolean)
    begin
        ActionObject.Content.Add('error', ErrorText);
        ActionObject.Content.Add('errorSeverity', Severity);
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
        InitializeDiscoveryState(DiscoveryState);
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnActionDiscovered', '', false, false)]
    local procedure OnActionDiscovered(var Rec: Record "NPR POS Action")
    var
        NewDiscoveryState: Record "Event Subscription" temporary;
    begin
        InitializeDiscoveryState(NewDiscoveryState);
        if NewDiscoveryState.FindSet() then
            repeat
                if DiscoveryState.Get(NewDiscoveryState."Subscriber Codeunit ID", NewDiscoveryState."Subscriber Function")
                  and (DiscoveryState."Number of Calls" <> NewDiscoveryState."Number of Calls") then begin
                    DiscoveryState."Number of Calls" := NewDiscoveryState."Number of Calls";
                    Rec."Codeunit ID" := NewDiscoveryState."Subscriber Codeunit ID";
                end;
            until NewDiscoveryState.Next() = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInvalidActionConfiguration(Source: Text; "Action": Text; ErrorText: Text)
    begin
    end;
}
