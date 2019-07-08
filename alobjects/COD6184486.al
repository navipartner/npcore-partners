codeunit 6184486 "Pepper File Mgmt. Functions"
{
    // NPR5.25/TSA/20160513  CASE 239285 Version up to 5.0.398.2
    // NPR5.26/TSA/20160809 CASE 248452 Assembly Version Up - JBAXI Support, General Improvements

    SingleInstance = true;
    TableNo = TempBlob;

    trigger OnRun()
    begin

        ProcessSignal(Rec);
    end;

    var
        POSDeviceProxyManager: Codeunit "POS Device Proxy Manager";
        ExpectedResponseType: DotNet Type;
        ExpectedResponseId: Guid;
        ProtocolManagerId: Guid;
        ProtocolStage: Integer;
        QueuedRequests: DotNet Stack;
        QueuedResponseTypes: DotNet Stack;
        "--RequestSpecific": Integer;
        InitializedRequest: Boolean;
        FileMgtRequest: DotNet FileManagementRequest;
        FileMgtResponse: DotNet FileManagementResponse;
        NOT_INITIALIZED: Label 'Please invoke initialprotocol function before setting paramaters.';
        Labels: DotNet ProcessLabels;
        PepperTerminalCaptions: Codeunit "Pepper Terminal Captions";
        PepperVersion: Record "Pepper Version";
        LastRestultCode: Integer;
        "--": Integer;
        ChunkInStr: InStream;
        ChunkBinaryReader: DotNet BinaryReader;
        ChunkMemoryStream: DotNet MemoryStream;
        NO_PEPPER_BLOB: Label 'No blob to install for pepper version %1.';

    local procedure "---Protocol functions"()
    begin
    end;

    local procedure ProcessSignal(var TempBlob: Record TempBlob)
    var
        Signal: DotNet Signal;
        StartSignal: DotNet StartSession;
        QueryCloseSignal: DotNet QueryClosePage;
        Response: DotNet MessageResponse;
    begin

        POSDeviceProxyManager.DeserializeObject(Signal,TempBlob);
        case true of
          Signal.TypeName = Format(GetDotNetType(StartSignal)):
            begin
              QueuedRequests := QueuedRequests.Stack();
              QueuedResponseTypes := QueuedResponseTypes.Stack();

              POSDeviceProxyManager.DeserializeSignal(StartSignal,Signal);
              Start(StartSignal.ProtocolManagerId);
            end;
          Signal.TypeName = Format(GetDotNetType(Response)):
            begin
              POSDeviceProxyManager.DeserializeSignal(Response,Signal);
              MessageResponse(Response.Envelope);
            end;
          Signal.TypeName = Format(GetDotNetType(QueryCloseSignal)):
            if QueryClosePage() then
              POSDeviceProxyManager.AbortByUserRequest(ProtocolManagerId);
        end;
    end;

    local procedure Start(ProtocolManagerIdIn: Guid)
    var
        WebClientDependency: Record "Web Client Dependency";
        VoidResponse: DotNet VoidResponse;
    begin

        ProtocolManagerId := ProtocolManagerIdIn;

         AwaitResponse(
           GetDotNetType(VoidResponse),
           POSDeviceProxyManager.SendMessage(
             ProtocolManagerId, FileMgtRequest));
    end;

    local procedure MessageResponse(Envelope: DotNet ResponseEnvelope)
    begin

        if Envelope.ResponseTypeName <> Format(ExpectedResponseType) then
          Error('Unknown response type: %1 (expected %2)',Envelope.ResponseTypeName,Format(ExpectedResponseType));
    end;

    local procedure QueryClosePage(): Boolean
    begin

        exit(true);
    end;

    local procedure CloseProtocol()
    begin

        Clear(ChunkMemoryStream);
        POSDeviceProxyManager.ProtocolClose(ProtocolManagerId);
    end;

    local procedure AwaitResponse(Type: DotNet Type;Id: Guid)
    begin

        ExpectedResponseType := Type;
        ExpectedResponseId := Id;
    end;

    local procedure "---Pepper_Set"()
    begin
    end;

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

        if (not InitializedRequest) then
          exit ('');

        exit (FileMgtResponse.NewVersion);
    end;

    procedure GetPreviousVersion(): Text
    begin

        if (not InitializedRequest) then
          exit ('');

        exit (FileMgtResponse.OldVersion);
    end;

    procedure GetExceptionText(): Text
    begin

        if (not InitializedRequest) then
          exit ('');

        exit (FileMgtResponse.ExceptionText);
    end;

    procedure GetResultCode() ResultCode: Integer
    begin

        if (not InitializedRequest) then
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
        //FileMgtResponse := FileMgtResponse.Deserialize (Data);

        PepperVersion.CalcFields ("Install Zip File");
        if (PepperVersion."Install Zip File".HasValue ()) then begin
          PepperVersion."Install Zip File".CreateInStream (ChunkInStr);
          ChunkMemoryStream := ChunkInStr;
          ChunkBinaryReader := ChunkBinaryReader.BinaryReader(ChunkInStr);
          B64FileChunk := Convert.ToBase64String(ChunkBinaryReader.ReadBytes(60000));
          //B64FileChunk := Convert.ToBase64String(ChunkBinaryReader.ReadBytes(ChunkMemoryStream.Length));
        end else begin
          B64FileChunk := '';
        end;
    end;

    local procedure GetNextChunk(Data: Text;var B64FileChunk: Text)
    var
        Convert: DotNet Convert;
    begin
        //FileMgtResponse := FileMgtResponse.Deserialize (Data);

        PepperVersion.CalcFields ("Install Zip File");
        if (PepperVersion."Install Zip File".HasValue ()) then begin
          B64FileChunk  := Convert.ToBase64String(ChunkBinaryReader.ReadBytes (60000));
          //B64FileChunk  := '';
        end else begin
          B64FileChunk := '';
        end;
    end;

    [EventSubscriber(ObjectType::Page, 6014657, 'ProtocolEvent', '', false, false)]
    local procedure ProtocolEvent(ProtocolCodeunitID: Integer;EventName: Text;Data: Text;ResponseRequired: Boolean;var ReturnData: Text)
    begin
        if (ProtocolCodeunitID <> CODEUNIT::"Pepper File Mgmt. Functions") then
          exit;

        case EventName of
          'CloseForm':
            CloseForm (Data);
          'GetFirstChunk':
            GetFirstChunk (Data, ReturnData);
          'GetNextChunk':
            GetNextChunk (Data, ReturnData);
        end;
    end;

    local procedure SerializeJson("Object": Variant): Text
    var
        JsonConvert: DotNet JsonConvert;
    begin
        exit(JsonConvert.SerializeObject(Object));
    end;

    local procedure CloseForm(Data: Text)
    begin

        FileMgtResponse := FileMgtResponse.Deserialize (Data);
        LastRestultCode := FileMgtResponse.LastResultCode();

        //IF (CONFIRM ('%1 (%2 -> %3)\\%4', TRUE, LastRestultCode, FileMgtResponse.OldVersion, FileMgtResponse.NewVersion, FileMgtResponse.ExceptionText)) THEN ;
        CloseProtocol ();
    end;
}

