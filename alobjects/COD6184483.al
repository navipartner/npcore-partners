codeunit 6184483 "Pepper End Workshift"
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
        EndWorkShiftRequest: DotNet EndWorkshiftRequest;
        EndWorkShiftResponse: DotNet EndWorkshiftResponse;
        EndOfDayPa: Integer;
        LastRestCode: Integer;
        Labels: DotNet ProcessLabels;
        PepperTerminalCaptions: Codeunit "Pepper Terminal Captions";

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
             ProtocolManagerId, EndWorkShiftRequest));
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

        EndWorkShiftRequest := EndWorkShiftRequest.EndWorkshiftRequest ();
        EndWorkShiftResponse := EndWorkShiftResponse.EndWorkshiftResponse ();

        PepperTerminalCaptions.GetLabels (Labels);
        EndWorkShiftRequest.ProcessLabels := Labels;
        //-NPR5.22
        //SetOptions (TRUE, TRUE);
        SetOptions (true, true, true);
        //+NPR5.22

        LastRestCode := -999998;
        InitializedRequest := true;
    end;

    procedure SetReceiptEncoding(PepperEncodingName: Code[20];NavisionEncodingName: Code[20])
    begin

        if not InitializedRequest then
          InitializeProtocol();

        // Default value is UTF-8
        if (PepperEncodingName <> '') then
          EndWorkShiftRequest.PepperReceiptEncoding := PepperEncodingName;

        // Default value is ISO-8859-1
        if (NavisionEncodingName <> '') then
          EndWorkShiftRequest.NavisionReceiptEncoding := NavisionEncodingName;
    end;

    procedure SetOptions(WithEndOfDayReport: Boolean;WithFinalizeLibrary: Boolean;RequireReceipt: Boolean)
    begin

        EndWorkShiftRequest.WithEndOfDayHandling := WithEndOfDayReport;
        EndWorkShiftRequest.WithFinalizeLibrary := WithFinalizeLibrary;
        //-NPR5.22
        EndWorkShiftRequest.RequireReceipt := RequireReceipt;
        //+NPR5.22
    end;

    procedure SetTimout(TimeoutMillies: Integer)
    begin

        if not InitializedRequest then
          InitializeProtocol();

        if (TimeoutMillies = 0) then
          TimeoutMillies := 15000;

        EndWorkShiftRequest.TimeoutMillies := TimeoutMillies;
    end;

    local procedure "---Pepper_Get"()
    begin
    end;

    procedure GetResultCode() ResultCode: Integer
    begin

        if (not InitializedRequest) then
          exit (-999999);

        //-NPR5.22
        if (LastRestCode = -10) and (not EndWorkShiftRequest.RequireReceipt) then
            LastRestCode := 10;
        //+NPR5.22

        exit (LastRestCode);
    end;

    procedure GetCloseReceipt() CloseReceipt: Text
    begin

        if (not InitializedRequest) then
          exit ('');

        exit (EndWorkShiftResponse.CloseReceipt ());
    end;

    procedure GetEndOfDayReceipt() EndOfDayReceipt: Text
    begin

        if (not InitializedRequest) then
          exit ('');

        exit (EndWorkShiftResponse.EndOfDayReceipt ());
    end;

    local procedure "----"()
    begin
    end;

    [EventSubscriber(ObjectType::Page, 6014657, 'ProtocolEvent', '', false, false)]
    local procedure ProtocolEvent(ProtocolCodeunitID: Integer;EventName: Text;Data: Text;ResponseRequired: Boolean;var ReturnData: Text)
    begin

        if (ProtocolCodeunitID <> CODEUNIT::"Pepper End Workshift") then
          exit;

        case EventName of
          'CloseForm':
            CloseForm(Data);
        end;
    end;

    local procedure CloseForm(Data: Text)
    begin

        EndWorkShiftResponse := EndWorkShiftResponse.Deserialize (Data);
        LastRestCode := EndWorkShiftResponse.LastResultCode();

        CloseProtocol ();
    end;
}

