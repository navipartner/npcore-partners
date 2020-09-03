// TODO: CTRLUPGRADE - This codeunit is remnants of the old Proxy Manager Stargate v1 protocol codeunit - possibly obsolete and outdated - INVESTIGATE

codeunit 6184486 "NPR Pepper File Mgmt. Func."
{
    // NPR5.25/TSA/20160513  CASE 239285 Version up to 5.0.398.2
    // NPR5.26/TSA/20160809 CASE 248452 Assembly Version Up - JBAXI Support, General Improvements

    SingleInstance = true;

    var
        InitializedRequest: Boolean;
        FileMgtRequest: DotNet NPRNetFileManagementRequest;
        FileMgtResponse: DotNet NPRNetFileManagementResponse;
        Labels: DotNet NPRNetProcessLabels;
        PepperTerminalCaptions: Codeunit "NPR Pepper Terminal Captions";
        PepperVersion: Record "NPR Pepper Version";
        LastRestultCode: Integer;
        NO_PEPPER_BLOB: Label 'No blob to install for pepper version %1.';

    procedure InitializeProtocol()
    begin

        ClearAll();

        FileMgtRequest := FileMgtRequest.FileManagementRequest();
        FileMgtResponse := FileMgtResponse.FileManagementResponse();

        PepperTerminalCaptions.GetLabels(Labels);
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

        PepperVersion.Get(VersionCode);
        PepperVersion.TestField("Install Directory");

        PepperVersion.CalcFields("Install Zip File");
        if (not PepperVersion."Install Zip File".HasValue()) then
            Error(NO_PEPPER_BLOB, VersionCode);

        FileMgtRequest.UploadPepperVersion := VersionCode;
        FileMgtRequest.DllPath := PepperVersion."Install Directory";
    end;

    procedure GetInstalledVersion(): Text
    begin

        if (not InitializedRequest) then
            exit('');

        exit(FileMgtResponse.NewVersion);
    end;

    procedure GetPreviousVersion(): Text
    begin

        if (not InitializedRequest) then
            exit('');

        exit(FileMgtResponse.OldVersion);
    end;

    procedure GetExceptionText(): Text
    begin

        if (not InitializedRequest) then
            exit('');

        exit(FileMgtResponse.ExceptionText);
    end;

    procedure GetResultCode() ResultCode: Integer
    begin

        if (not InitializedRequest) then
            exit(-999999);

        exit(LastRestultCode);
    end;
}

