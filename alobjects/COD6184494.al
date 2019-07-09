codeunit 6184494 "Pepper Aux Functions TSD"
{
    // NPR5.30/TSA/20170123  CASE 263458 Refactored for Transcendence


    trigger OnRun()
    begin
    end;

    var
        InitializedRequest: Boolean;
        AuxRequest: DotNet npNetAuxRequest0;
        AuxResponse: DotNet npNetAuxResponse0;
        AuxResult: DotNet npNetAuxResult0;
        AuxParam: DotNet npNetAuxParam0;
        PepperOpCodes: DotNet npNetPepperOpCodes0;
        LastRestCode: Integer;
        NOT_INITIALIZED: Label 'Please invoke initialprotocol function before setting paramaters.';
        Labels: DotNet npNetProcessLabels0;
        PepperTerminalCaptions: Codeunit "Pepper Terminal Captions TSD";

    local procedure "---Pepper_Set"()
    begin
    end;

    procedure InitializeProtocol()
    begin

        ClearAll();

        PepperOpCodes := PepperOpCodes.PepperOpCodes();

        AuxRequest := AuxRequest.AuxRequest ();
        AuxResponse := AuxResponse.AuxResponse ();

        PepperTerminalCaptions.GetLabels (Labels);
        AuxRequest.ProcessLabels := Labels;

        LastRestCode := -999998;
        InitializedRequest := true;
    end;

    procedure SetReceiptEncoding(PepperEncodingName: Code[20];NavisionEncodingName: Code[20])
    begin

        if not InitializedRequest then
          InitializeProtocol();

        // Default value is UTF-8
        if (PepperEncodingName <> '') then
          AuxRequest.PepperReceiptEncoding := PepperEncodingName;

        // Default value is ISO-8859-1
        if (NavisionEncodingName <> '') then
          AuxRequest.NavisionReceiptEncoding := NavisionEncodingName;
    end;

    procedure SetTimout(TimeoutMillies: Integer)
    begin

        if not InitializedRequest then
          InitializeProtocol();

        if (TimeoutMillies = 0) then
          TimeoutMillies := 15000;

        AuxRequest.TimeoutMillies := TimeoutMillies;
    end;

    local procedure SetUtilityOpCode(WaitForReceipt: Boolean;OpCode: Byte;XmlParameter: Text)
    begin
        AuxParam := AuxParam.AuxParam ();
        AuxParam.OpCode := OpCode;
        AuxParam.XmlAdditionalParameters := XmlParameter;
        AuxRequest.AuxParam := AuxParam;

        AuxRequest.WaitForReceipt := WaitForReceipt;
    end;

    procedure SetReprintLastTicket(WaitForReceipt: Boolean)
    begin
        if (not InitializedRequest) then
          Error (NOT_INITIALIZED);

        SetUtilityOpCode (WaitForReceipt, PepperOpCodes.TicketReprint, '');
    end;

    procedure SetGetSummaryReport(WaitForReceipt: Boolean)
    begin
        if (not InitializedRequest) then
          Error (NOT_INITIALIZED);

        SetUtilityOpCode (WaitForReceipt, PepperOpCodes.SummaryReport, '');
    end;

    procedure SetGetDiagnostics(WaitForReceipt: Boolean)
    begin
        if (not InitializedRequest) then
          Error (NOT_INITIALIZED);

        SetUtilityOpCode (WaitForReceipt, PepperOpCodes.Diagnostics, '');
    end;

    procedure SetGetSystemInfoTicket(WaitForReceipt: Boolean)
    begin
        if (not InitializedRequest) then
          Error (NOT_INITIALIZED);

        SetUtilityOpCode (WaitForReceipt, PepperOpCodes.SystemInfo, '');
    end;

    procedure SetAbort()
    begin
        if (not InitializedRequest) then
          Error (NOT_INITIALIZED);

        SetUtilityOpCode (false, PepperOpCodes.Abort, '');
    end;

    procedure SetPanSuppressionOn()
    begin
        if (not InitializedRequest) then
          Error (NOT_INITIALIZED);

        SetUtilityOpCode (false, PepperOpCodes.PanSuppressionOn, '');
    end;

    procedure SetPanSuppressionOff()
    begin
        if (not InitializedRequest) then
          Error (NOT_INITIALIZED);

        SetUtilityOpCode (false, PepperOpCodes.PanSuppressionOff, '');
    end;

    procedure SetDisplayShowText(DisplayText: Text)
    begin
        if (not InitializedRequest) then
          Error (NOT_INITIALIZED);

        SetUtilityOpCode (false, 'f', DisplayText);
    end;

    procedure SetTinaActivation(TinaParams: Text)
    begin
        if (not InitializedRequest) then
          Error (NOT_INITIALIZED);

        if (TinaParams = '') then
          TinaParams := '<xml><EnableTinaCompatibilityFlag>false</EnableTinaCompatibilityFlag><TinaModeValue>activate</TinaModeValue></xml>';

        SetUtilityOpCode (false, PepperOpCodes.TinaActivation, TinaParams);
    end;

    procedure SetTinaDeactivation(TinaParams: Text)
    begin
        if (not InitializedRequest) then
          Error (NOT_INITIALIZED);

        if (TinaParams = '') then
          TinaParams := '<xml><EnableTinaCompatibilityFlag>false</EnableTinaCompatibilityFlag><TinaModeValue>deactivate</TinaModeValue></xml>';

        SetUtilityOpCode (false, PepperOpCodes.TinaActivation, TinaParams);
    end;

    procedure SetTinaQuery(TinaParams: Text)
    begin
        if (not InitializedRequest) then
          Error (NOT_INITIALIZED);

        if (TinaParams = '') then
          TinaParams := '<xml><EnableTinaCompatibilityFlag>false</EnableTinaCompatibilityFlag><TinaModeValue>query</TinaModeValue></xml>';

        SetUtilityOpCode (false, PepperOpCodes.TinaQuery, TinaParams);
    end;

    procedure SetShowCustomMenu()
    begin
        if (not InitializedRequest) then
          Error (NOT_INITIALIZED);

        SetUtilityOpCode (false, PepperOpCodes.CustomMenu, '');
    end;

    local procedure "---Pepper_Get"()
    begin
    end;

    procedure GetResultCode() ResultCode: Integer
    begin

        if (not InitializedRequest) then
          exit (-999999);

        exit (AuxResult.ResultCode);
    end;

    procedure GetClientReceipt(): Text
    begin

        if (not InitializedRequest) then
          exit ('');

        exit (AuxResponse.ReceiptOne);
    end;

    procedure GetMerchantReceipt(): Text
    begin

        if (not InitializedRequest) then
          exit ('');

        exit (AuxResponse.ReceiptTwo);
    end;

    procedure GetXmlResponse(): Text
    begin

        if (not InitializedRequest) then
          exit ('');

        exit (AuxResult.XmlAdditionalParameters);
    end;

    local procedure "--Stargate2"()
    begin
    end;

    procedure SetTransactionEntryNo(EntryNo: Integer)
    begin

        if (not InitializedRequest) then
          Error (NOT_INITIALIZED);

        AuxRequest.RequestEntryNo := EntryNo;
    end;

    procedure InvokeAuxRequest(var FrontEnd: Codeunit "POS Front End Management";var POSSession: Codeunit "POS Session")
    begin

        FrontEnd.InvokeDevice (AuxRequest, 'Pepper_EftAux', 'EftEndWorkshift');
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150716, 'OnDeviceResponse', '', false, false)]
    local procedure OnDeviceResponse(ActionName: Text;Step: Text;Envelope: DotNet npNetResponseEnvelope0;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    begin

        if (ActionName <> 'Pepper_EftAux') then
          exit;

        // Pepper has a VOID response. Actual Return Data is on the CloseForm Event
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150716, 'OnAppGatewayProtocol', '', false, false)]
    local procedure OnDeviceEvent(ActionName: Text;EventName: Text;Data: Text;ResponseRequired: Boolean;var ReturnData: Text;var Handled: Boolean)
    var
        PaymentRequest: Integer;
        EFTTransactionRequest: Record "EFT Transaction Request";
    begin

        if (ActionName <> 'Pepper_EftAux') then
          exit;

        Handled := true;

        case EventName of
          'CloseForm':
            begin
              AuxResponse := AuxResponse.Deserialize (Data);
              AuxResult := AuxResponse.AuxResult;
              LastRestCode := AuxResult.ResultCode;
              InitializedRequest := true;

              EFTTransactionRequest.Get (AuxResponse.RequestEntryNo);
              OnAuxResponse (EFTTransactionRequest."Entry No.");
            end;
        end;
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnAuxResponse(EFTPaymentRequestID: Integer)
    begin
    end;
}

