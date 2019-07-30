// TODO: CTRLUPGRADE - this codeunit is remnants of the old Proxy Manager stargate v1 stuff - possibly outdated and obsolete - INVESTIGATE

codeunit 6184483 "Pepper End Workshift"
{
    // NPR5.25/TSA/20160513  CASE 239285 Version up to 5.0.398.2
    // NPR5.26/TSA/20160809 CASE 248452 Assembly Version Up - JBAXI Support, General Improvements

    SingleInstance = true;

    var
        InitializedRequest: Boolean;
        EndWorkShiftRequest: DotNet npNetEndWorkshiftRequest;
        EndWorkShiftResponse: DotNet npNetEndWorkshiftResponse;
        EndOfDayPa: Integer;
        LastRestCode: Integer;
        Labels: DotNet npNetProcessLabels;
        PepperTerminalCaptions: Codeunit "Pepper Terminal Captions";

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
}

