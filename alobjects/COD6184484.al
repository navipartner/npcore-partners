
// TODO: CTRLUPGRADE - this codeunit is remnants of the old Proxy Manager stargate v1 protocol codeunit - INVESTIGATE

codeunit 6184484 "Pepper Aux Functions"
{
    // NPR5.25/TSA/20160513  CASE 239285 Version up to 5.0.398.2
    // NPR5.26/TSA/20160809 CASE 248452 Assembly Version Up - JBAXI Support, General Improvements

    SingleInstance = true;

    var
        InitializedRequest: Boolean;
        AuxRequest: DotNet npNetAuxRequest;
        AuxResponse: DotNet npNetAuxResponse;
        AuxResult: DotNet npNetAuxResult;
        AuxParam: DotNet npNetAuxParam;
        PepperOpCodes: DotNet npNetPepperOpCodes;
        LastRestCode: Integer;
        NOT_INITIALIZED: Label 'Please invoke initialprotocol function before setting paramaters.';
        Labels: DotNet npNetProcessLabels;
        PepperTerminalCaptions: Codeunit "Pepper Terminal Captions";

    procedure InitializeProtocol()
    begin

        ClearAll();

        PepperOpCodes := PepperOpCodes.PepperOpCodes();

        AuxRequest := AuxRequest.AuxRequest();
        AuxResponse := AuxResponse.AuxResponse();

        PepperTerminalCaptions.GetLabels(Labels);
        AuxRequest.ProcessLabels := Labels;

        LastRestCode := -999998;
        InitializedRequest := true;
    end;

    procedure SetReceiptEncoding(PepperEncodingName: Code[20]; NavisionEncodingName: Code[20])
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

    local procedure SetUtilityOpCode(WaitForReceipt: Boolean; OpCode: Byte; XmlParameter: Text)
    begin
        AuxParam := AuxParam.AuxParam();
        AuxParam.OpCode := OpCode;
        AuxParam.XmlAdditionalParameters := XmlParameter;
        AuxRequest.AuxParam := AuxParam;

        AuxRequest.WaitForReceipt := WaitForReceipt;
    end;

    procedure SetReprintLastTicket(WaitForReceipt: Boolean)
    begin
        if (not InitializedRequest) then
            Error(NOT_INITIALIZED);

        SetUtilityOpCode(WaitForReceipt, PepperOpCodes.TICKETREPRINT, '');
    end;

    procedure SetGetSummaryReport(WaitForReceipt: Boolean)
    begin
        if (not InitializedRequest) then
            Error(NOT_INITIALIZED);

        SetUtilityOpCode(WaitForReceipt, PepperOpCodes.SUMMARYREPORT, '');
    end;

    procedure SetGetDiagnostics(WaitForReceipt: Boolean)
    begin
        if (not InitializedRequest) then
            Error(NOT_INITIALIZED);

        SetUtilityOpCode(WaitForReceipt, PepperOpCodes.DIAGNOSTICS, '');
    end;

    procedure SetGetSystemInfoTicket(WaitForReceipt: Boolean)
    begin
        if (not InitializedRequest) then
            Error(NOT_INITIALIZED);

        SetUtilityOpCode(WaitForReceipt, PepperOpCodes.SYSTEMINFO, '');
    end;

    procedure SetAbort()
    begin
        if (not InitializedRequest) then
            Error(NOT_INITIALIZED);

        SetUtilityOpCode(false, PepperOpCodes.ABORT, '');
    end;

    procedure SetPanSuppressionOn()
    begin
        if (not InitializedRequest) then
            Error(NOT_INITIALIZED);

        SetUtilityOpCode(false, PepperOpCodes.PANSUPPRESSIONON, '');
    end;

    procedure SetPanSuppressionOff()
    begin
        if (not InitializedRequest) then
            Error(NOT_INITIALIZED);

        SetUtilityOpCode(false, PepperOpCodes.PANSUPPRESSIONOFF, '');
    end;

    procedure SetDisplayShowText(DisplayText: Text)
    begin
        if (not InitializedRequest) then
            Error(NOT_INITIALIZED);

        SetUtilityOpCode(false, 'f', DisplayText);
    end;

    procedure SetTinaActivation(TinaParams: Text)
    begin
        if (not InitializedRequest) then
            Error(NOT_INITIALIZED);

        if (TinaParams = '') then
            TinaParams := '<xml><EnableTinaCompatibilityFlag>false</EnableTinaCompatibilityFlag><TinaModeValue>activate</TinaModeValue></xml>';

        SetUtilityOpCode(false, PepperOpCodes.TINAACTIVATION, TinaParams);
    end;

    procedure SetTinaDeactivation(TinaParams: Text)
    begin
        if (not InitializedRequest) then
            Error(NOT_INITIALIZED);

        if (TinaParams = '') then
            TinaParams := '<xml><EnableTinaCompatibilityFlag>false</EnableTinaCompatibilityFlag><TinaModeValue>deactivate</TinaModeValue></xml>';

        SetUtilityOpCode(false, PepperOpCodes.TINAACTIVATION, TinaParams);
    end;

    procedure SetTinaQuery(TinaParams: Text)
    begin
        if (not InitializedRequest) then
            Error(NOT_INITIALIZED);

        if (TinaParams = '') then
            TinaParams := '<xml><EnableTinaCompatibilityFlag>false</EnableTinaCompatibilityFlag><TinaModeValue>query</TinaModeValue></xml>';

        SetUtilityOpCode(false, PepperOpCodes.TINAQUERY, TinaParams);
    end;

    procedure SetShowCustomMenu()
    begin
        if (not InitializedRequest) then
            Error(NOT_INITIALIZED);

        SetUtilityOpCode(false, PepperOpCodes.CUSTOMMENU, '');
    end;

    local procedure "---Pepper_Get"()
    begin
    end;

    procedure GetResultCode() ResultCode: Integer
    begin

        if (not InitializedRequest) then
            exit(-999999);

        exit(AuxResult.ResultCode);
    end;

    procedure GetClientReceipt(): Text
    begin

        if (not InitializedRequest) then
            exit('');

        exit(AuxResponse.ReceiptOne);
    end;

    procedure GetMerchantReceipt(): Text
    begin

        if (not InitializedRequest) then
            exit('');

        exit(AuxResponse.ReceiptTwo);
    end;

    procedure GetXmlResponse(): Text
    begin

        if (not InitializedRequest) then
            exit('');

        exit(AuxResult.XmlAdditionalParameters);
    end;
}
