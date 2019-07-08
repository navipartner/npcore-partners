codeunit 6184493 "Pepper End Workshift TSD"
{
    // NPR5.30/TSA/20170123  CASE 263458 Refactored for Transcendence


    trigger OnRun()
    begin
    end;

    var
        InitializedRequest: Boolean;
        InitializedResponse: Boolean;
        EndWorkShiftRequest: DotNet EndWorkshiftRequest0;
        EndWorkShiftResponse: DotNet EndWorkshiftResponse0;
        EndOfDayPa: Integer;
        LastRestCode: Integer;
        Labels: DotNet ProcessLabels0;
        PepperTerminalCaptions: Codeunit "Pepper Terminal Captions TSD";

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

        if (not InitializedResponse) then
          exit (-999999);

        //-NPR5.22
        if (LastRestCode = -10) and (not EndWorkShiftResponse.RequireReceipt) then
            LastRestCode := 10;
        //+NPR5.22

        exit (LastRestCode);
    end;

    procedure GetCloseReceipt() CloseReceipt: Text
    begin

        if (not InitializedResponse) then
          exit ('');

        exit (EndWorkShiftResponse.CloseReceipt ());
    end;

    procedure GetEndOfDayReceipt() EndOfDayReceipt: Text
    begin

        if (not InitializedResponse) then
          exit ('');

        exit (EndWorkShiftResponse.EndOfDayReceipt ());
    end;

    local procedure "--Stargate2"()
    begin
    end;

    procedure SetTransactionEntryNo(EntryNo: Integer)
    begin

        if not InitializedRequest then
          InitializeProtocol();

        EndWorkShiftRequest.RequestEntryNo := EntryNo;
    end;

    procedure InvokeEndWorkshiftRequest(var FrontEnd: Codeunit "POS Front End Management";var POSSession: Codeunit "POS Session")
    begin

        FrontEnd.InvokeDevice (EndWorkShiftRequest, 'Pepper_EftEnd', 'EftEndWorkshift');
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150716, 'OnDeviceResponse', '', false, false)]
    local procedure OnDeviceResponse(ActionName: Text;Step: Text;Envelope: DotNet ResponseEnvelope0;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    begin

        if (ActionName <> 'Pepper_EftEnd') then
          exit;

        // Pepper has a VOID response. Actual Return Data is on the CloseForm Event
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150716, 'OnAppGatewayProtocol', '', false, false)]
    local procedure OnDeviceEvent(ActionName: Text;EventName: Text;Data: Text;ResponseRequired: Boolean;var ReturnData: Text;var Handled: Boolean)
    var
        PaymentRequest: Integer;
        EFTTransactionRequest: Record "EFT Transaction Request";
    begin

        if (ActionName <> 'Pepper_EftEnd') then
          exit;

        Handled := true;

        case EventName of
          'CloseForm':
            begin
              EndWorkShiftResponse := EndWorkShiftResponse.Deserialize (Data);
              LastRestCode := EndWorkShiftResponse.LastResultCode();
              InitializedResponse := true;

              EFTTransactionRequest.Get (EndWorkShiftResponse.RequestEntryNo);
              OnEndWorkshiftResponse (EFTTransactionRequest."Entry No.");
            end;
        end;
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnEndWorkshiftResponse(EFTPaymentRequestID: Integer)
    begin
    end;
}

