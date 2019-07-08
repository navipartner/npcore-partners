codeunit 6184495 "Pepper FileMgmt. Functions TSD"
{
    // NPR5.30/TSA/20170123  CASE 263458 Refactored for Transcendence, intentionally SingleInstance to avoid seeking in BLOB when delivering the chunks

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        InitializedRequest: Boolean;
        InitializedResponse: Boolean;
        FileMgtRequest: DotNet FileManagementRequest0;
        FileMgtResponse: DotNet FileManagementResponse0;
        NOT_INITIALIZED: Label 'Please invoke initialprotocol function before setting paramaters.';
        Labels: DotNet ProcessLabels0;
        PepperTerminalCaptions: Codeunit "Pepper Terminal Captions TSD";
        PepperVersion: Record "Pepper Version";
        LastRestultCode: Integer;
        "--": Integer;
        ChunkInStr: InStream;
        ChunkBinaryReader: DotNet BinaryReader;
        ChunkMemoryStream: DotNet MemoryStream;
        NO_PEPPER_BLOB: Label 'No blob to install for pepper version %1.';

    procedure InitializeProtocol()
    begin

        ClearAll();

        FileMgtRequest := FileMgtRequest.FileManagementRequest();
        FileMgtResponse := FileMgtResponse.FileManagementResponse();

        PepperTerminalCaptions.GetLabels (Labels);
        FileMgtRequest.ProcessLabels := Labels;

        InitializedRequest := true;
    end;

    procedure SetTimout(TimeoutMillies: Integer)
    begin

        if not InitializedRequest then
          InitializeProtocol();

        if (TimeoutMillies = 0) then
          TimeoutMillies := 15000;

        FileMgtRequest.TimeoutMillies := TimeoutMillies;
    end;

    procedure SetPepperVersionToInstall(VersionCode: Code[10])
    begin

        PepperVersion.Get (VersionCode);
        PepperVersion.TestField ("Install Directory");

        PepperVersion.CalcFields ("Install Zip File");
        if (not PepperVersion."Install Zip File".HasValue()) then
          Error (NO_PEPPER_BLOB, VersionCode);

        FileMgtRequest.UploadPepperVersion := VersionCode;
        FileMgtRequest.DllPath := PepperVersion."Install Directory";
    end;

    procedure GetInstalledVersion(): Text
    begin

        if (not InitializedResponse) then
          exit ('');

        exit (FileMgtResponse.NewVersion);
    end;

    procedure GetPreviousVersion(): Text
    begin

        if (not InitializedResponse) then
          exit ('');

        exit (FileMgtResponse.OldVersion);
    end;

    procedure GetExceptionText(): Text
    begin

        if (not InitializedResponse) then
          exit ('');

        exit (FileMgtResponse.ExceptionText);
    end;

    procedure GetResultCode() ResultCode: Integer
    begin

        if (not InitializedResponse) then
          exit (-999999);

        exit (LastRestultCode);
    end;

    local procedure "----"()
    begin
    end;

    local procedure GetZipFileToInstall(Data: Text;var PepperB64File: Text)
    var
        JsonConvert: DotNet JsonConvert;
        InStr: InStream;
        BinaryReader: DotNet BinaryReader;
        MemoryStream: DotNet MemoryStream;
        Convert: DotNet Convert;
    begin
        FileMgtResponse := FileMgtResponse.Deserialize (Data);

        PepperVersion.CalcFields ("Install Zip File");
        if (PepperVersion."Install Zip File".HasValue ()) then begin
          PepperVersion."Install Zip File".CreateInStream (InStr);
          MemoryStream := InStr;
          BinaryReader := BinaryReader.BinaryReader(InStr);
          PepperB64File := Convert.ToBase64String(BinaryReader.ReadBytes(MemoryStream.Length));
          MemoryStream.Dispose;
          Clear(MemoryStream);
        end;
    end;

    local procedure GetFirstChunk(Data: Text;var B64FileChunk: Text)
    var
        Convert: DotNet Convert;
    begin

        PepperVersion.CalcFields ("Install Zip File");
        if (PepperVersion."Install Zip File".HasValue ()) then begin
          PepperVersion."Install Zip File".CreateInStream (ChunkInStr);
          ChunkMemoryStream := ChunkInStr;
          ChunkBinaryReader := ChunkBinaryReader.BinaryReader(ChunkInStr);
          B64FileChunk := Convert.ToBase64String(ChunkBinaryReader.ReadBytes(240000));

        end else begin
          B64FileChunk := '';
        end;
    end;

    local procedure GetNextChunk(Data: Text;var B64FileChunk: Text)
    var
        Convert: DotNet Convert;
    begin

        PepperVersion.CalcFields ("Install Zip File");
        if (PepperVersion."Install Zip File".HasValue ()) then begin
          B64FileChunk  := Convert.ToBase64String(ChunkBinaryReader.ReadBytes (240000));

        end else begin
          B64FileChunk := '';
        end;
    end;

    local procedure SerializeJson("Object": Variant): Text
    var
        JsonConvert: DotNet JsonConvert;
    begin
        exit(JsonConvert.SerializeObject(Object));
    end;

    local procedure "--Stargate2"()
    begin
    end;

    procedure SetTransactionEntryNo(EntryNo: Integer)
    begin

        if not InitializedRequest then
          InitializeProtocol();

        FileMgtRequest.RequestEntryNo := EntryNo;
    end;

    procedure InvokeFileMgtRequest(var FrontEnd: Codeunit "POS Front End Management";var POSSession: Codeunit "POS Session")
    begin

        FrontEnd.InvokeDevice (FileMgtRequest, 'Pepper_EftFileMgt', 'EftEndWorkshift');
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150716, 'OnDeviceResponse', '', false, false)]
    local procedure OnDeviceResponse(ActionName: Text;Step: Text;Envelope: DotNet ResponseEnvelope0;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    begin

        if (ActionName <> 'Pepper_EftFileMgt') then
          exit;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150716, 'OnAppGatewayProtocol', '', false, false)]
    local procedure OnDeviceEvent(ActionName: Text;EventName: Text;Data: Text;ResponseRequired: Boolean;var ReturnData: Text;var Handled: Boolean)
    var
        PaymentRequest: Integer;
        EFTTransactionRequest: Record "EFT Transaction Request";
    begin

        if (ActionName <> 'Pepper_EftFileMgt') then
          exit;

        Handled := true;

        case EventName of
          'CloseForm':
            begin
              FileMgtResponse := FileMgtResponse.Deserialize (Data);
              LastRestultCode := FileMgtResponse.LastResultCode();
              InitializedResponse := true;

              EFTTransactionRequest.Get (FileMgtResponse.RequestEntryNo);
              OnFileMgtResponse (EFTTransactionRequest."Entry No.");

            end;
          'GetFirstChunk': GetFirstChunk (Data, ReturnData);
          'GetNextChunk':  GetNextChunk (Data, ReturnData);

        end;
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnFileMgtResponse(EFTPaymentRequestID: Integer)
    begin
    end;
}

