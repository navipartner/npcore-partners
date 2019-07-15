codeunit 6059946 "CashKeeper Proxy"
{
    // NPR5.29\CLVA\20161108 CASE NPR5.29 Object Created

    SingleInstance = true;
    TableNo = TempBlob;

    trigger OnRun()
    begin
        ProcessSignal(Rec);
    end;

    var
        POSDeviceProxyManager: Codeunit "POS Device Proxy Manager";
        ProtocolStage: Integer;
        ExpectedResponseType: DotNet npNetType;
        ExpectedResponseId: Guid;
        QueuedRequests: DotNet npNetStack;
        QueuedResponseTypes: DotNet npNetStack;
        ProtocolManagerId: Guid;
        CashKeeperTransaction: Record "CashKeeper Transaction";

    local procedure "--- Protocol functions"()
    begin
    end;

    procedure InitializeProtocol()
    begin
        ClearAll();
    end;

    local procedure ProcessSignal(var TempBlob: Record TempBlob)
    var
        Signal: DotNet npNetSignal;
        StartSignal: DotNet npNetStartSession;
        Response: DotNet npNetMessageResponse;
        ProtocolManagerId: Guid;
        QueryCloseSignal: DotNet npNetQueryClosePage;
    begin
        POSDeviceProxyManager.DeserializeObject(Signal, TempBlob);
        case true of
            Signal.TypeName = Format(GetDotNetType(StartSignal)):
                begin
                    QueuedRequests := QueuedRequests.Stack();
                    QueuedResponseTypes := QueuedResponseTypes.Stack();

                    POSDeviceProxyManager.DeserializeSignal(StartSignal, Signal);
                    Start(StartSignal.ProtocolManagerId);
                end;
            Signal.TypeName = Format(GetDotNetType(Response)):
                begin
                    POSDeviceProxyManager.DeserializeSignal(Response, Signal);
                    MessageResponse(Response.Envelope);
                end;
            Signal.TypeName = Format(GetDotNetType(QueryCloseSignal)):
                if QueryClosePage() then
                    POSDeviceProxyManager.AbortByUserRequest(ProtocolManagerId);
        end;
    end;

    local procedure Start(ProtocolManagerIdIn: Guid)
    var
        CashKeeperRequest: DotNet npNetCashKeeperRequest;
        VoidResponse: DotNet npNetVoidResponse;
        State: DotNet npNetState1;
        StateEnum: DotNet npNetState_Action;
        CashKeeperSetup: Record "CashKeeper Setup";
    begin
        ProtocolManagerId := ProtocolManagerIdIn;

        CashKeeperSetup.Get(CashKeeperTransaction."Register No.");

        State := State.State();
        case CashKeeperTransaction.Action of
            CashKeeperTransaction.Action::Capture:
                State.ActionType := StateEnum.Capture;
            CashKeeperTransaction.Action::Pay:
                State.ActionType := StateEnum.Pay;
            CashKeeperTransaction.Action::Setup:
                State.ActionType := StateEnum.Setup;
        end;
        State.Amount := CashKeeperTransaction.Amount;
        State.ValueInCents := CashKeeperTransaction."Value In Cents";
        State.PaidInValue := CashKeeperTransaction."Paid In Value";
        State.PaidOutValue := CashKeeperTransaction."Paid Out Value";
        if not CashKeeperSetup."Debug Mode" then begin
            CashKeeperSetup.TestField("CashKeeper IP");
            State.IP := CashKeeperSetup."CashKeeper IP";
        end else
            State.IP := 'localhost';

        CashKeeperRequest := CashKeeperRequest.CashKeeperRequest();
        CashKeeperRequest.State := State;

        AwaitResponse(
          GetDotNetType(VoidResponse),
          POSDeviceProxyManager.SendMessage(
            ProtocolManagerId, CashKeeperRequest));
    end;

    local procedure MessageResponse(Envelope: DotNet npNetResponseEnvelope)
    var
        CashKeeperResponse: DotNet npNetCashKeeperResponse;
    begin
        if Envelope.ResponseTypeName <> Format(ExpectedResponseType) then
            Error('Unknown response type: %1 (expected %2)', Envelope.ResponseTypeName, Format(ExpectedResponseType));
    end;

    local procedure QueryClosePage(): Boolean
    begin
        exit(true);
    end;

    local procedure CloseProtocol()
    begin
        POSDeviceProxyManager.ProtocolClose(ProtocolManagerId);
    end;

    local procedure AwaitResponse(Type: DotNet npNetType; Id: Guid)
    begin
        ExpectedResponseType := Type;
        ExpectedResponseId := Id;
    end;

    local procedure "--- Protocol Events"()
    begin
    end;

    local procedure CloseForm(Data: Text)
    var
        State: DotNet npNetState1;
        Txt001: Label 'CashKeeper error: %1 - %2';
        Txt002: Label 'Payment was cancelled';
    begin
        State := State.Deserialize(Data);

        CashKeeperTransaction."Paid In Value" := State.PaidInValue;
        CashKeeperTransaction."Paid Out Value" := State.PaidOutValue;

        if State.RunWithSucces then
            CashKeeperTransaction.Status := CashKeeperTransaction.Status::Ok
        else
            if State.CancelledByUser then
                CashKeeperTransaction.Status := CashKeeperTransaction.Status::Cancelled
            else
                if not State.RunWithSucces and not State.CancelledByUser then
                    CashKeeperTransaction.Status := CashKeeperTransaction.Status::Error;

        CashKeeperTransaction."CK Error Code" := State.ErrorCode;
        CashKeeperTransaction."CK Error Description" := State.ErrorText;

        //DEBUG: MESSAGE('Close Form');

        CloseProtocol();

        Commit;

        // IF (CashKeeperTransaction.Status = CashKeeperTransaction.Status::Error) THEN
        //  ERROR(Txt001, CashKeeperTransaction."CK Error Code", CashKeeperTransaction."CK Error Description");
        //
        // IF (CashKeeperTransaction.Status = CashKeeperTransaction.Status::Cancelled) THEN
        //  ERROR(Txt002);
    end;

    local procedure "--- Protocol Event Handling"()
    begin
    end;

    local procedure SerializeJson("Object": Variant): Text
    var
        JsonConvert: DotNet JsonConvert;
    begin
        exit(JsonConvert.SerializeObject(Object));
    end;

    [EventSubscriber(ObjectType::Page, 6014657, 'ProtocolEvent', '', false, false)]
    local procedure ProtocolEvent(ProtocolCodeunitID: Integer; EventName: Text; Data: Text; ResponseRequired: Boolean; var ReturnData: Text)
    begin
        //DEBUG: MESSAGE('Action 1: ' + FORMAT(CashKeeperTransaction.Action) + ' ' + FORMAT(ProtocolCodeunitID));
        if (ProtocolCodeunitID <> CODEUNIT::"CashKeeper Proxy") then
            exit;

        //DEBUG: MESSAGE('Action 2: ' + EventName);
        case EventName of
            'CloseForm':
                CloseForm(Data);
        end;
    end;

    local procedure "-- Set Functions"()
    begin
    end;

    procedure SetState(var CashKeeperTransactionIn: Record "CashKeeper Transaction")
    begin
        CashKeeperTransaction := CashKeeperTransactionIn;
    end;

    local procedure "-- Get Functions"()
    begin
    end;

    procedure GetStatus(): Integer
    begin
        exit(CashKeeperTransaction.Status);
    end;

    procedure GetState(var CashKeeperTransactionOut: Record "CashKeeper Transaction")
    begin
        CashKeeperTransactionOut := CashKeeperTransaction;
    end;
}

