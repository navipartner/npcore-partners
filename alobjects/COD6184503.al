codeunit 6184503 "CleanCash Proxy"
{
    // NPR5.26/JHL/20160705  CASE 242776 CU started to handle the communication with CleanCash through Stargate

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
        "--Response Variabel --": Integer;
        SerialNo: Text[100];
        ControlCode: Text[100];
        CCCommunicationResult: DotNet npNetCommunicationResult;
        CCCommunicationStatus: DotNet npNetCommunicationStatus;
        LastUnitStatusList: Text[250];
        NotSet: Boolean;
        LastExtendedError: Integer;
        "-- Input Variable --": Integer;
        OrganisationNumber: Text[10];
        PosID: Text[16];
        DateTime: Text[12];
        ReceiptNo: Text[30];
        ReceiptType: DotNet npNetCommunicationReceipt;
        ReceiptTotal: Text[30];
        NegativeTotal: Text[30];
        Vat: array [4] of Text[30];
        ConnectionString: Text[100];
        MultiOrganizationIDPerPOS: Boolean;
        ShowErrorMessage: Boolean;
        "---AUX--": Integer;
        EventResponse: Option NotSet,FailOpen,FailCheckStatusEX,FailRegisterPos,FailCheckStatus,FailStartReceipt," FailSendReceiptEX"," FailSendReceipt",ReceiptSend;

    procedure InitializeProtocol()
    begin
        ClearAll();
    end;

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
        if Envelope.MessageId <> ExpectedResponseId then begin
          Message('Unknown response: %1 (expected %2)',Envelope.MessageId,ExpectedResponseId);
          Error('');
        end;

        if Envelope.ResponseTypeName <> Format(ExpectedResponseType) then begin
          Message('Unknown response type: %1 (expected %2)',Envelope.ResponseTypeName,Format(ExpectedResponseType));
          Error('');
        end;

        //-EVENT

        case ProtocolStage of
          1: ProtocolStage1Response(Envelope);
        end;

        //+EVENT
    end;

    local procedure ProtocolStage1()
    var
        CleanCashRequest: DotNet npNetCleanCashRequest;
        CleanCashResponse: DotNet npNetCleanCashResponse;
        VoidResponse: DotNet npNetVoidResponse;
    begin
        ProtocolStage := 1;
        CleanCashRequest := CleanCashRequest.CleanCashRequest();

        CleanCashRequest.organisationNumber := OrganisationNumber;
        CleanCashRequest.posId := PosID;
        CleanCashRequest.dateTime := DateTime;
        CleanCashRequest.receiptNo := ReceiptNo;
        CleanCashRequest.receiptType := ReceiptType;
        CleanCashRequest.receiptTotal := ReceiptTotal;
        CleanCashRequest.negativeTotal := NegativeTotal;
        CleanCashRequest.vat1 := Vat[1];
        CleanCashRequest.vat2 := Vat[2];
        CleanCashRequest.vat3 := Vat[3];
        CleanCashRequest.vat4 := Vat[4];
        CleanCashRequest.connectionString := ConnectionString;

        ExpectedResponseType := GetDotNetType(CleanCashResponse);
        ExpectedResponseId := POSDeviceProxyManager.SendMessage(ProtocolManagerId,CleanCashRequest);
    end;

    local procedure ProtocolStage1Close(Envelope: DotNet npNetEnvelope)
    var
        CleanCashResponse: DotNet npNetCleanCashResponse;
    begin
        POSDeviceProxyManager.DeserializeEnvelopeFromId(CleanCashResponse,Envelope,ProtocolManagerId);
        POSDeviceProxyManager.ProtocolClose(ProtocolManagerId);
    end;

    local procedure ProtocolStage1Response(Envelope: DotNet npNetEnvelope)
    var
        CleanCashResponse: DotNet npNetCleanCashResponse;
        EventResponseEnum: DotNet npNetCleanCashRequest_ActionStatus;
        EventResponseInt: Integer;
    begin
        //CleanCashResponce = CleanCashResponce.CleanCashResponse

        POSDeviceProxyManager.DeserializeEnvelopeFromId(CleanCashResponse,Envelope,ProtocolManagerId);
        POSDeviceProxyManager.ProtocolClose(ProtocolManagerId);

        SerialNo := CleanCashResponse.SerialNo;
        ControlCode := CleanCashResponse.LastControlCode;
        CCCommunicationResult := CleanCashResponse.CCCommunicationResult;
        CCCommunicationStatus := CleanCashResponse.CCCommunicationStatus;
        LastUnitStatusList := CopyStr(CleanCashResponse.LastUnitStatusList,1,250);
        NotSet := CleanCashResponse.NotSet;
        EventResponseEnum := CleanCashResponse.LastAction;
        EventResponseInt := EventResponseEnum;
        EventResponse := EventResponseInt;
        //POSDeviceProxyManager.ProtocolClose(ProtocolManagerId);
    end;

    local procedure AwaitResponse(Type: DotNet npNetType;Id: Guid)
    begin
        ExpectedResponseType := Type;
        ExpectedResponseId := Id;
    end;

    local procedure CloseProtocol()
    begin
        POSDeviceProxyManager.ProtocolClose(ProtocolManagerId);
    end;

    procedure Init(pOrganisationNumber: Text[10];pPosId: Text[16];pDateTime: Text[12];pReceiptNo: Text[30];pReceiptType: DotNet npNetCommunicationReceipt;pReceiptTotal: Text[30];pNegativeTotal: Text[30];pVat: array [4] of Text[30];pConnectionString: Text[100];pMultiOrganizationIDPerPOS: Boolean;pShowErrorMessage: Boolean)
    begin
        OrganisationNumber := pOrganisationNumber;
        PosID := pPosId;
        DateTime := pDateTime;
        ReceiptNo := pReceiptNo;
        ReceiptType := pReceiptType;
        ReceiptTotal := pReceiptTotal;
        NegativeTotal := pNegativeTotal;
        Vat[1] := pVat[1];
        Vat[2] := pVat[2];
        Vat[3] := pVat[3];
        Vat[4] := pVat[4];
        ConnectionString := pConnectionString;
        MultiOrganizationIDPerPOS := pMultiOrganizationIDPerPOS;
        ShowErrorMessage := pShowErrorMessage;
    end;

    local procedure "-- GetFunction --"()
    begin
    end;

    procedure GetSerialNo(): Text[100]
    begin
        exit(SerialNo);
    end;

    procedure GetControlCode(): Text[100]
    begin
        exit(ControlCode);
    end;

    procedure GetCCCommunicationResult(var EnumCommResult: DotNet npNetCommunicationResult)
    var
        tempInt: Integer;
    begin
        EnumCommResult := CCCommunicationResult;
    end;

    procedure GetCCCommunicationStatus(var EnumCommStatus: DotNet npNetCommunicationStatus)
    begin
        EnumCommStatus := CCCommunicationStatus;
    end;

    procedure GetLastUnitStatusList(): Text[250]
    begin
        exit(CopyStr(LastUnitStatusList,1,250));
    end;

    procedure GetLastExtendedError(): Integer
    begin
        exit(LastExtendedError);
    end;

    procedure GetEventResponse(): Integer
    begin
        exit(EventResponse);
    end;

    procedure GetNotSet(): Boolean
    begin
        exit(NotSet);
    end;
}

