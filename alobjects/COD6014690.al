codeunit 6014690 "Stargate Dummy Request"
{
    // NPR5.23/MMV/20160526 CASE 241574 Created CU. A dummy stargate request only meant for manual triggering of assembly check & download phase.

    SingleInstance = true;
    TableNo = TempBlob;

    trigger OnRun()
    begin
        ProcessSignal(Rec);
    end;

    var
        POSDeviceProxyManager: Codeunit "POS Device Proxy Manager";
        ExpectedResponseType: DotNet npNetType;
        ExpectedResponseId: Guid;
        ProtocolManagerId: Guid;
        ProtocolStage: Integer;
        Proxy: Page "Proxy Dialog";
        SyncTxt: Label 'Stargate assemblies synced successfully';

    local procedure ProcessSignal(var TempBlob: Record TempBlob)
    var
        Signal: DotNet npNetSignal;
        StartSignal: DotNet npNetStartSession;
        Response: DotNet npNetMessageResponse;
    begin
        POSDeviceProxyManager.DeserializeObject(Signal,TempBlob);
        case true of
          Signal.TypeName = Format(GetDotNetType(StartSignal)):
            begin
              POSDeviceProxyManager.DeserializeSignal(StartSignal,Signal);
              Start(StartSignal.ProtocolManagerId);
            end;
          Signal.TypeName = Format(GetDotNetType(Response)):
            begin
              POSDeviceProxyManager.DeserializeSignal(Response,Signal);
              MessageResponse(Response.Envelope);
            end;
        end;
    end;

    local procedure Start(ProtocolManagerIdIn: Guid)
    begin
        ProtocolManagerId := ProtocolManagerIdIn;

        ProtocolStage1();
    end;

    local procedure MessageResponse(Envelope: DotNet npNetResponseEnvelope)
    begin
        if Envelope.MessageId <> ExpectedResponseId then
          Error('Unknown response: %1 (expected %2)',Envelope.MessageId,ExpectedResponseId);

        if Envelope.ResponseTypeName <> Format(ExpectedResponseType) then
          Error('Unknown response type: %1 (expected %2)',Envelope.ResponseTypeName,Format(ExpectedResponseType));

        case ProtocolStage of
          1: ProtocolStage1Close(Envelope);
        end;
    end;

    local procedure ProtocolStage1()
    var
        GetAssembliesRequest: DotNet npNetGetAssembliesRequest;
        GetAssembliesResponse: DotNet npNetGetAssembliesResponse;
    begin
        ProtocolStage := 1;

        GetAssembliesRequest := GetAssembliesRequest.GetAssembliesRequest();

        ExpectedResponseType := GetDotNetType(GetAssembliesResponse);
        ExpectedResponseId := POSDeviceProxyManager.SendMessage(ProtocolManagerId,GetAssembliesRequest);
    end;

    local procedure ProtocolStage1Close(Envelope: DotNet npNetEnvelope)
    var
        GetAssembliesResponse: DotNet npNetGetAssembliesResponse;
    begin
        POSDeviceProxyManager.DeserializeEnvelopeFromId(GetAssembliesResponse,Envelope,ProtocolManagerId);
        POSDeviceProxyManager.ProtocolClose(ProtocolManagerId);

        Message(SyncTxt);
    end;

    procedure RunRequest()
    begin
        Commit ();

        Clear (Proxy);
        Proxy.RunProtocolModal(6014690);
    end;
}

