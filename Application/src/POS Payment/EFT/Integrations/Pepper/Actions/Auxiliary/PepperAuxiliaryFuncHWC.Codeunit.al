codeunit 6184488 "NPR Pepper Auxiliary Func HWC"
{
    Access = Internal;

    var
        _InitializedRequest: Boolean;
        _InitializedResponse: Boolean;
        NOT_INITIALIZED: Label 'Please invoke initialize protocol function before setting parameters.';
        _LastResultCode: Integer;
        _AuxOperation: JsonObject;
        _Envelope: JsonObject;

    procedure InitializeProtocol()
    var
        PepperTerminalCaptions: Codeunit "NPR Pepper Terminal Captions";
        PepperLabels: JsonObject;
    begin

        ClearAll();
        _Envelope.ReadFrom('{}');
        _Envelope.Add('WorkflowName', Format(Enum::"NPR POS Workflow"::EFT_PEPPER_AUX));
        _Envelope.Add('HwcName', 'EFTPepper');

        PepperTerminalCaptions.GetLabels(PepperLabels);

        _Envelope.Add('Type', 'AuxiliaryOperation');
        _Envelope.Add('Captions', PepperLabels);

        _LastResultCode := -999998;
        _InitializedRequest := true;
    end;

    procedure SetTimeout(TimeoutMilliSeconds: Integer)
    begin

        if not _InitializedRequest then
            InitializeProtocol();

        if (TimeoutMilliSeconds = 0) then
            TimeoutMilliSeconds := 15000;

        _Envelope.Add('Timeout', TimeoutMilliSeconds);
    end;

    procedure SetHwcVerboseLogLevel()
    begin
        _Envelope.Add('LogLevel', 'Verbose');
    end;

    procedure SetReceiptEncoding(PepperEncodingName: Code[20])
    begin

        if not _InitializedRequest then
            InitializeProtocol();

        // Default value is UTF-8
        if (PepperEncodingName <> '') then
            _Envelope.Add('PepperReceiptEncoding', PepperEncodingName);
    end;

    procedure AssembleHwcRequest(): JsonObject
    begin
        _Envelope.Add('AuxiliaryRequest', _AuxOperation);
        exit(_Envelope)
    end;

    local procedure SetUtilityOpCode(WaitForReceipt: Boolean; OpCodeMnemonic: Text; XmlParameter: Text)
    begin
        _AuxOperation.ReadFrom('{}');
        _AuxOperation.Add('Operation', OpCodeMnemonic); // Actual value is known by HWC
        _AuxOperation.Add('XmlAdditionalParameters', XmlParameter);
        _AuxOperation.Add('WaitForReceipt', WaitForReceipt);
    end;

    procedure SetReprintLastTicket(WaitForReceipt: Boolean)
    begin
        if (not _InitializedRequest) then
            Error(NOT_INITIALIZED);

        SetUtilityOpCode(WaitForReceipt, 'TicketReprint', '');
    end;

    procedure SetGetSummaryReport(WaitForReceipt: Boolean)
    begin
        if (not _InitializedRequest) then
            Error(NOT_INITIALIZED);

        SetUtilityOpCode(WaitForReceipt, 'SummaryReport', '');
    end;

    procedure SetGetDiagnostics(WaitForReceipt: Boolean)
    begin
        if (not _InitializedRequest) then
            Error(NOT_INITIALIZED);

        SetUtilityOpCode(WaitForReceipt, 'Diagnostics', '');
    end;

    procedure SetGetSystemInfoTicket(WaitForReceipt: Boolean)
    begin
        if (not _InitializedRequest) then
            Error(NOT_INITIALIZED);

        SetUtilityOpCode(WaitForReceipt, 'SystemInfo', '');
    end;

    procedure SetAbort()
    begin
        if (not _InitializedRequest) then
            Error(NOT_INITIALIZED);

        SetUtilityOpCode(false, 'Abort', '');
    end;

    procedure SetPanSuppressionOn()
    begin
        if (not _InitializedRequest) then
            Error(NOT_INITIALIZED);

        SetUtilityOpCode(false, 'PanSuppressionOn', '');
    end;

    procedure SetPanSuppressionOff()
    begin
        if (not _InitializedRequest) then
            Error(NOT_INITIALIZED);

        SetUtilityOpCode(false, 'PanSuppressionOff', '');
    end;

    procedure SetDisplayShowText(DisplayText: Text)
    begin
        if (not _InitializedRequest) then
            Error(NOT_INITIALIZED);

        SetUtilityOpCode(false, 'f', DisplayText);
    end;

    procedure SetTinaActivation(TinaParams: Text)
    begin
        if (not _InitializedRequest) then
            Error(NOT_INITIALIZED);

        if (TinaParams = '') then
            TinaParams := '<xml><EnableTinaCompatibilityFlag>false</EnableTinaCompatibilityFlag><TinaModeValue>activate</TinaModeValue></xml>';

        SetUtilityOpCode(false, 'TinaActivation', TinaParams);
    end;

    procedure SetTinaDeactivation(TinaParams: Text)
    begin
        if (not _InitializedRequest) then
            Error(NOT_INITIALIZED);

        if (TinaParams = '') then
            TinaParams := '<xml><EnableTinaCompatibilityFlag>false</EnableTinaCompatibilityFlag><TinaModeValue>deactivate</TinaModeValue></xml>';

        SetUtilityOpCode(false, 'TinaActivation', TinaParams);
    end;

    procedure SetTinaQuery(TinaParams: Text)
    begin
        if (not _InitializedRequest) then
            Error(NOT_INITIALIZED);

        if (TinaParams = '') then
            TinaParams := '<xml><EnableTinaCompatibilityFlag>false</EnableTinaCompatibilityFlag><TinaModeValue>query</TinaModeValue></xml>';

        SetUtilityOpCode(false, 'TinaQuery', TinaParams);
    end;

    procedure SetShowCustomMenu()
    begin
        if (not _InitializedRequest) then
            Error(NOT_INITIALIZED);

        SetUtilityOpCode(false, 'CustomMenu', '');
    end;

    procedure SetTransactionEntryNo(EntryNo: Integer)
    begin

        if (not _InitializedRequest) then
            InitializeProtocol();

        _Envelope.Add('EntryNo', EntryNo);
    end;

    #region Response
    procedure SetResponse(HwcResponse: JsonObject)
    begin

        // Lets blow up on invalid response
        _LastResultCode := AsInteger(HwcResponse, 'ResultCode');
        _AuxOperation := AsObject(HwcResponse, 'AuxiliaryResponse');

        _InitializedResponse := true;
    end;

    procedure GetResultCode() ResultCode: Integer
    begin

        if (not _InitializedResponse) then
            exit(-999999);

        exit(_LastResultCode);
    end;

    procedure GetClientReceipt(): Text
    begin

        if (not _InitializedResponse) then
            exit('');

        exit(AsText(_AuxOperation, 'ReceiptOne', 0));
    end;

    procedure GetMerchantReceipt(): Text
    begin

        if (not _InitializedResponse) then
            exit('');

        exit(AsText(_AuxOperation, 'ReceiptTwo', 0));
    end;

    procedure GetXmlResponse(): Text
    begin

        if (not _InitializedResponse) then
            exit('');

        exit(AsText(_AuxOperation, 'XmlAdditionalParameters', 0));
    end;

    #endregion

    #region jsonHelpers
    local procedure AsObject(JObject: JsonObject; KeyName: Text): JsonObject
    var
        JToken: JsonToken;
    begin
        JObject.Get(KeyName, JToken);
        exit(JToken.AsObject());
    end;

    local procedure AsInteger(JObject: JsonObject; KeyName: Text): Integer
    var
        JToken: JsonToken;
    begin
        JObject.Get(KeyName, JToken);
        exit(JToken.AsValue().AsInteger());
    end;

    local procedure AsText(JObject: JsonObject; KeyName: Text; MaxLength: Integer): Text
    var
        JToken: JsonToken;
        Result: Text;
        OverflowError: Label 'The key "%1" has a max length of %2, but the value "%3" is %4.';
    begin
        JObject.Get(KeyName, JToken);
        Result := JToken.AsValue().AsText();
        if ((MaxLength > 0) and (StrLen(Result) > MaxLength)) then
            Error(OverflowError, KeyName, MaxLength, Result, StrLen(Result));

        exit(Result);
    end;
    #endregion
}