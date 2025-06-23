codeunit 6184480 "NPR Pepper Install HWC"
{
    Access = Internal;
    ObsoleteState = Pending;
    ObsoleteTag = '2025-06-13';
    ObsoleteReason = 'No longer supported';

    var
        _PepperVersion: Record "NPR Pepper Version";
        _Envelope: JsonObject;
        _PepperInstall: JsonObject;
        _InitializedRequest: Boolean;
        _InitializedResponse: Boolean;
        _LastResultCode: Integer;

    procedure InitializeProtocol()
    var
        PepperTerminalCaptions: Codeunit "NPR Pepper Terminal Captions";
        PepperLabels: JsonObject;
    begin

        ClearAll();

        ClearAll();
        _Envelope.ReadFrom('{}');
        _Envelope.Add('WorkflowName', Format(Enum::"NPR POS Workflow"::EFT_PEPPER_INSTALL));
        _Envelope.Add('HwcName', 'EFTPepper');

        PepperTerminalCaptions.GetLabels(PepperLabels);

        _Envelope.Add('Type', 'InstallPepper');
        _Envelope.Add('Captions', PepperLabels);

        _InitializedRequest := true;

    end;

    procedure AssembleHwcRequest(Operation: Text): JsonObject
    begin
        _PepperInstall.Add('Operation', Operation);
        _Envelope.Add('InstallRequest', _PepperInstall);

        exit(_Envelope);
    end;

    procedure SetTimeout(TimeoutMilliSeconds: Integer)
    begin

        if not _InitializedRequest then
            InitializeProtocol();

        if (TimeoutMilliSeconds = 0) then
            TimeoutMilliSeconds := 15000;

        _Envelope.Add('Timeout', TimeoutMilliSeconds);
    end;

    procedure SetTransactionEntryNo(EntryNo: Integer)
    begin

        if not _InitializedRequest then
            InitializeProtocol();

        _Envelope.Add('EntryNo', EntryNo);
    end;

    procedure SetHwcVerboseLogLevel()
    begin
        _Envelope.Add('LogLevel', 'Verbose');
    end;

    procedure SetPepperVersionToInstall(VersionCode: Code[10])
    var
        NO_PEPPER_BLOB: Label 'No blob to install for pepper version %1.';
    begin

        _PepperVersion.Get(VersionCode);
        _PepperVersion.TestField("Install Directory");

        _PepperVersion.CalcFields("Install Zip File");
        if (not _PepperVersion."Install Zip File".HasValue()) then
            Error(NO_PEPPER_BLOB, VersionCode);

        _PepperInstall.Add('UploadPepperVersion', VersionCode);
        _PepperInstall.Add('DllPath', _PepperVersion."Install Directory");

    end;

    procedure DownloadFileToClient(TargetFileName: Text)
    var
        FileStream: InStream;
        B64: Codeunit "Base64 Convert";
        Request: Codeunit "NPR Front-End: HWC";
        FileRequest: JsonObject;
        FrontEnd: Codeunit "NPR POS Front End Management";
        POSSession: Codeunit "NPR POS Session";
    begin
        _PepperInstall.Add('SourceFile', TargetFileName);

        _PepperVersion.CalcFields("Install Zip File");
        _PepperVersion."Install Zip File".CreateInStream(FileStream);

        Request.SetHandler('File');
        FileRequest.Add('path', TargetFileName);
        FileRequest.Add('operation', 'writeText');
        FileRequest.Add('contents', B64.ToBase64(FileStream));
        Request.SetRequest(FileRequest);

        POSSession.GetFrontEnd(FrontEnd);
        FrontEnd.InvokeFrontEndMethod2(Request);
    end;

    procedure SetResponse(HwcResponse: JsonObject)
    var
        JToken: JsonToken;
    begin

        // Lets blow up on invalid response
        HwcResponse.Get('ResultCode', JToken);
        _LastResultCode := JToken.AsValue().AsInteger();

        HwcResponse.Get('InstallResponse', JToken);
        _PepperInstall := JToken.AsObject();

        _InitializedResponse := true;
    end;

    procedure GetInstalledVersion(): Text
    begin

        if (not _InitializedResponse) then
            exit('');

        exit(AsText(_PepperInstall, 'NewVersion'));
    end;

    procedure GetPreviousVersion(): Text
    begin

        if (not _InitializedResponse) then
            exit('');

        exit(AsText(_PepperInstall, 'OldVersion'));
    end;

    procedure GetExceptionText(): Text
    begin

        if (not _InitializedResponse) then
            exit('');

        exit(AsText(_PepperInstall, 'ExceptionText'));
    end;

    procedure GetResultCode() ResultCode: Integer
    begin

        if (not _InitializedResponse) then
            exit(-999999);

        exit(_LastResultCode);
    end;

    local procedure AsText(JObject: JsonObject; KeyName: Text): Text
    var
        JToken: JsonToken;
    begin
        JObject.Get(KeyName, JToken);
        exit(JToken.AsValue().AsText());
    end;

}