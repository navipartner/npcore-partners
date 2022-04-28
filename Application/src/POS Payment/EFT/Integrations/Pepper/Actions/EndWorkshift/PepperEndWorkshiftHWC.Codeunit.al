codeunit 6184486 "NPR Pepper End Workshift HWC"
{
    Access = Internal;

    var
        _LastResultCode: Integer;
        _Envelope: JsonObject;
        _EndWorkshift: JsonObject;
        _InitializedRequest: Boolean;
        _InitializedResponse: Boolean;

    procedure InitializeProtocol()
    var
        PepperTerminalCaptions: Codeunit "NPR Pepper Terminal Captions";
        PepperLabels: JsonObject;
    begin

        ClearAll();
        _Envelope.ReadFrom('{}');
        _Envelope.Add('WorkflowName', Format(Enum::"NPR POS Workflow"::EFT_PEPPER_CLOSE));
        _Envelope.Add('HwcName', 'EFTPepper');

        PepperTerminalCaptions.GetLabels(PepperLabels);

        _Envelope.Add('Type', 'EndWorkshift');
        _Envelope.Add('Captions', PepperLabels);

        _LastResultCode := -999998;
        _InitializedRequest := true;
    end;

    procedure AssembleHwcRequest(): JsonObject
    begin
        _Envelope.Add('EndWorkshiftRequest', _EndWorkshift);
        exit(_Envelope)
    end;

    procedure SetHwcVerboseLogLevel()
    begin
        _Envelope.Add('LogLevel', 'Verbose');
    end;

    procedure SetTimeout(TimeoutMilliSeconds: Integer)
    begin

        if not _InitializedRequest then
            InitializeProtocol();

        if (TimeoutMilliSeconds = 0) then
            TimeoutMilliSeconds := 15000;

        _Envelope.Add('Timeout', TimeoutMilliSeconds);
    end;

    procedure SetReceiptEncoding(PepperEncodingName: Code[20])
    begin

        if not _InitializedRequest then
            InitializeProtocol();

        // Default value is UTF-8
        if (PepperEncodingName <> '') then
            _Envelope.Add('PepperReceiptEncoding', PepperEncodingName);
    end;


    procedure SetOptions(WithEndOfDayReport: Boolean; WithFinalizeLibrary: Boolean)
    begin
        _EndWorkshift.Add('WithEndOfDayHandling', WithEndOfDayReport);
        _EndWorkshift.Add('WithFinalizeLibrary', WithFinalizeLibrary);
    end;

    procedure SetResponse(HwcResponse: JsonObject)
    var
        JToken: JsonToken;
    begin

        // Lets blow up on invalid response
        HwcResponse.Get('ResultCode', JToken);
        _LastResultCode := JToken.AsValue().AsInteger();

        HwcResponse.Get('EndWorkshiftResponse', JToken);
        _EndWorkshift := JToken.AsObject();

        _InitializedResponse := true;
    end;

    procedure GetResultCode() ResultCode: Integer
    begin

        if (not _InitializedResponse) then
            exit(-999999);

        exit(_LastResultCode);
    end;

    procedure GetCloseReceipt() CloseReceipt: Text
    var
        JToken: JsonToken;
    begin
        if (not _InitializedResponse) then
            exit('');

        _EndWorkshift.Get('CloseReceipt', JToken);
        exit(JToken.AsValue().AsText());
    end;

    procedure GetEndOfDayReceipt() EndOfDayReceipt: Text
    var
        JToken: JsonToken;
    begin
        if (not _InitializedResponse) then
            exit('');

        _EndWorkshift.Get('EndOfDayReceipt', JToken);
        exit(JToken.AsValue().AsText());
    end;

    procedure SetTransactionEntryNo(EntryNo: Integer)
    begin

        if not _InitializedRequest then
            InitializeProtocol();

        _Envelope.Add('EntryNo', EntryNo);
    end;

}