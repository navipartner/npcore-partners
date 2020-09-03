codeunit 6014580 "NPR Object Output Mgt."
{
    // NPR4.15/MMV/20151002 CASE 223893 Added method for slave output path for usage in Master/Slave output for example through a webserver.
    // NPR5.00/TSA/20151127 CASE 220508 Added hosting type "Web Client" for proxy printing
    // NPR5.22/MMV/20160317 CASE 228382 Added functions to get object output type.
    // NPR5.23/MMV /20160530 CASE 241549 Removed deprecated printer selection code.
    // NPR5.26/MMV /20160831 CASE 241549 Check CLIENTTYPE first when resolving printer name.
    // NPR5.29/MMV /20161208 CASE 260621 Fixed filter ordering when finding correct output line.
    // NPR5.30/TJ  /20170303 CASE 267710 Removing "redirected" from printer name to obtain local printer name
    // NPR5.32/MMV /20170324 CASE 241995 Retail Print 2.0
    // NPR5.31/TJ  /20170314 CASE 269104 Fail safe to return PrinterName if no printer found
    // NPR5.31/JLK /20170313 CASE 268274 Removed unused caption (t001)
    // NPR5.44/MMV /20180706 CASE 315362 Cleanup and refactoring.
    // NPR5.44/MMV /20180706 CASE 321816 Auto detect windows client environment instead of relying on setup.
    // NPR5.48/MMV /20181128 CASE 327107 Added event for overruling object output
    // NPR5.53/THRO/20200106 CASE 383562 Added PrintNode Raw ouput


    trigger OnRun()
    begin
    end;

    var
        ErrNoOutputFound: Label 'No output found for\Object: %1 %2\Template: %3';
        Error_UnsupportedOutput: Label 'Output Type %1 is not supported for %2';

    procedure GetCodeunitOutputPath(ObjectID: Integer) Path: Text[250]
    var
        ObjectOutputSelection: Record "NPR Object Output Selection";
    begin
        Path := GetOutputPath(ObjectOutputSelection."Object Type"::Codeunit, ObjectID, '');
    end;

    procedure GetCodeunitOutputPath2(ObjectID: Integer; PrintCode: Code[20]) Path: Text[250]
    var
        ObjectOutputSelection: Record "NPR Object Output Selection";
    begin
        Path := GetOutputPath(ObjectOutputSelection."Object Type"::Codeunit, ObjectID, PrintCode);
    end;

    procedure GetReportOutputPath(ObjectID: Integer) Path: Text[250]
    var
        ObjectOutputSelection: Record "NPR Object Output Selection";
    begin
        Path := GetOutputPath(ObjectOutputSelection."Object Type"::Report, ObjectID, '');
    end;

    procedure GetXMLOutputPath(ObjectID: Integer) Path: Text[250]
    var
        ObjectOutputSelection: Record "NPR Object Output Selection";
    begin
        Path := GetOutputPath(ObjectOutputSelection."Object Type"::XMLPort, ObjectID, '');
    end;

    procedure GetOutputPath(ObjectType: Integer; ObjectID: Integer; PrintCode: Code[20]) Path: Text[250]
    var
        ObjectOutputSelection: Record "NPR Object Output Selection";
    begin
        if TryGetOutputRec(ObjectType, ObjectID, PrintCode, UserId, ObjectOutputSelection) then
            Path := ObjectOutputSelection."Output Path"
        else begin
            ObjectOutputSelection."Object Type" := ObjectType;
            Error(ErrNoOutputFound, Format(ObjectOutputSelection."Object Type"), ObjectID, PrintCode);
        end;
    end;

    procedure GetCodeunitOutputType(ObjectID: Integer): Integer
    var
        ObjectOutputSelection: Record "NPR Object Output Selection";
    begin
        exit(GetOutputType(ObjectOutputSelection."Object Type"::Codeunit, ObjectID, ''));
    end;

    procedure GetCodeunitOutputType2(ObjectID: Integer; PrintCode: Code[20]): Integer
    var
        ObjectOutputSelection: Record "NPR Object Output Selection";
    begin
        exit(GetOutputType(ObjectOutputSelection."Object Type"::Codeunit, ObjectID, PrintCode));
    end;

    procedure GetReportOutputType(ObjectID: Integer): Integer
    var
        ObjectOutputSelection: Record "NPR Object Output Selection";
    begin
        exit(GetOutputType(ObjectOutputSelection."Object Type"::Report, ObjectID, ''));
    end;

    procedure GetXMLOutputType(ObjectID: Integer): Integer
    var
        ObjectOutputSelection: Record "NPR Object Output Selection";
    begin
        exit(GetOutputType(ObjectOutputSelection."Object Type"::XMLPort, ObjectID, ''));
    end;

    procedure GetOutputType(ObjectType: Integer; ObjectID: Integer; PrintCode: Code[20]): Integer
    var
        ObjectOutputSelection: Record "NPR Object Output Selection";
    begin
        if TryGetOutputRec(ObjectType, ObjectID, PrintCode, UserId, ObjectOutputSelection) then
            exit(ObjectOutputSelection."Output Type")
        else begin
            ObjectOutputSelection."Object Type" := ObjectType;
            Error(ErrNoOutputFound, Format(ObjectOutputSelection."Object Type"), ObjectID, PrintCode);
        end;
    end;

    procedure TryGetOutputRec(ObjectType: Integer; ObjectID: Integer; PrintCode: Code[20]; User: Text; var ObjectOutputSelection: Record "NPR Object Output Selection"): Boolean
    begin
        with ObjectOutputSelection do begin
            if Get(User, ObjectType, ObjectID, PrintCode) then
                exit(true);

            if ObjectID <> 0 then
                if Get(User, ObjectType, 0, PrintCode) then
                    exit(true);

            if StrLen(PrintCode) > 0 then
                if Get(User, ObjectType, ObjectID, '') then
                    exit(true);

            if not ((ObjectID = 0) and (StrLen(PrintCode) = 0)) then
                if Get(User, ObjectType, 0, '') then
                    exit(true);

            if StrLen(User) = 0 then
                exit(false)
            else
                exit(TryGetOutputRec(ObjectType, ObjectID, PrintCode, '', ObjectOutputSelection));
        end;
    end;

    local procedure TryGetPrintOutput(TemplateCode: Text; CodeunitId: Integer; ReportId: Integer; var ObjectOutputSelection: Record "NPR Object Output Selection"): Boolean
    begin
        //-NPR5.44 [315362]
        case true of
            ReportId <> 0:
                if not TryGetOutputRec(ObjectOutputSelection."Object Type"::Report, ReportId, TemplateCode, UserId, ObjectOutputSelection) then
                    exit(false);

            CodeunitId <> 0,
          TemplateCode <> '':
                if not TryGetOutputRec(ObjectOutputSelection."Object Type"::Codeunit, CodeunitId, TemplateCode, UserId, ObjectOutputSelection) then
                    exit(false);
            else
                exit(false);
        end;

        exit(true);
        //+NPR5.44 [315362]
    end;

    local procedure FindLocalPrinterName(PrinterName: Text): Text
    var
        RedirectedText: Text;
    begin
        RedirectedText := ' (redirected';
        if StrPos(PrinterName, RedirectedText) > 0 then
            exit(CopyStr(PrinterName, 1, StrPos(PrinterName, RedirectedText) - 1));
        exit(PrinterName);
    end;

    local procedure "// Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014547, 'OnSendPrintJob', '', false, false)]
    local procedure OnSendMatrixPrint(TemplateCode: Text; CodeunitId: Integer; ReportId: Integer; var Printer: Codeunit "NPR RP Matrix Printer Interf."; NoOfPrints: Integer)
    var
        ObjectOutput: Record "NPR Object Output Selection";
        PrintBytes: Text;
        TargetEncoding: Text;
        Supported: Boolean;
        HTTPEndpoint: Text;
        PrintMethodMgt: Codeunit "NPR Print Method Mgt.";
        i: Integer;
        Skip: Boolean;
    begin
        //-NPR5.44 [315362]
        if NoOfPrints < 1 then
            exit;
        if not TryGetPrintOutput(TemplateCode, CodeunitId, ReportId, ObjectOutput) then
            exit;

        //-NPR5.48 [327107]
        OnBeforeSendMatrixPrint(TemplateCode, CodeunitId, ReportId, Printer, NoOfPrints, Skip);
        if Skip then
            exit;
        //+NPR5.48 [327107]

        case ObjectOutput."Output Type" of
            ObjectOutput."Output Type"::"Printer Name":
                begin
                    Printer.OnGetPrintBytes(PrintBytes);
                    Printer.OnGetTargetEncoding(TargetEncoding);
                    for i := 1 to NoOfPrints do
                        PrintMethodMgt.PrintBytesLocal(ObjectOutput."Output Path", PrintBytes, TargetEncoding);
                end;

            ObjectOutput."Output Type"::"Epson Web":
                begin
                    Printer.OnGetPrintBytes(PrintBytes);
                    Printer.OnGetTargetEncoding(TargetEncoding);
                    for i := 1 to NoOfPrints do
                        PrintMethodMgt.PrintViaEpsonWebService(ObjectOutput."Output Path", '', PrintBytes, TargetEncoding);
                end;

            ObjectOutput."Output Type"::HTTP:
                begin
                    Printer.OnPrepareJobForHTTP(TargetEncoding, HTTPEndpoint, Supported);
                    if not Supported then
                        Error(Error_UnsupportedOutput, Format(ObjectOutput."Output Type"::HTTP), TemplateCode);
                    Printer.OnGetPrintBytes(PrintBytes);
                    for i := 1 to NoOfPrints do
                        PrintMethodMgt.PrintBytesHTTP(ObjectOutput."Output Path", HTTPEndpoint, PrintBytes, TargetEncoding);
                end;

            ObjectOutput."Output Type"::Bluetooth:
                begin
                    Printer.OnPrepareJobForBluetooth(TargetEncoding, Supported);
                    if not Supported then
                        Error(Error_UnsupportedOutput, Format(ObjectOutput."Output Type"::Bluetooth), TemplateCode);
                    Printer.OnGetPrintBytes(PrintBytes);
                    for i := 1 to NoOfPrints do
                        PrintMethodMgt.PrintBytesBluetooth(ObjectOutput."Output Path", PrintBytes, TargetEncoding);
                end;
            //-NPR5.53 [383562]
            ObjectOutput."Output Type"::"PrintNode Raw":
                begin
                    Printer.OnGetPrintBytes(PrintBytes);
                    Printer.OnGetTargetEncoding(TargetEncoding);
                    for i := 1 to NoOfPrints do
                        PrintMethodMgt.PrintViaPrintNodeRaw(ObjectOutput."Output Path", PrintBytes, TargetEncoding);
                end;
        //+NPR5.53 [383562]
        end;
        //+NPR5.44 [315362]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014549, 'OnSendPrintJob', '', false, false)]
    local procedure OnSendLinePrint(TemplateCode: Text; CodeunitId: Integer; ReportId: Integer; var Printer: Codeunit "NPR RP Line Printer Interf."; NoOfPrints: Integer)
    var
        ObjectOutput: Record "NPR Object Output Selection";
        PrintBytes: Text;
        TargetEncoding: Text;
        Supported: Boolean;
        HTTPEndpoint: Text;
        PrintMethodMgt: Codeunit "NPR Print Method Mgt.";
        i: Integer;
        Skip: Boolean;
    begin
        //-NPR5.44 [315362]
        if NoOfPrints < 1 then
            exit;
        if not TryGetPrintOutput(TemplateCode, CodeunitId, ReportId, ObjectOutput) then
            exit;

        //-NPR5.48 [327107]
        OnBeforeSendLinePrint(TemplateCode, CodeunitId, ReportId, Printer, NoOfPrints, Skip);
        if Skip then
            exit;
        //+NPR5.48 [327107]

        case ObjectOutput."Output Type" of
            ObjectOutput."Output Type"::"Printer Name":
                begin
                    Printer.OnGetPrintBytes(PrintBytes);
                    Printer.OnGetTargetEncoding(TargetEncoding);
                    for i := 1 to NoOfPrints do
                        PrintMethodMgt.PrintBytesLocal(ObjectOutput."Output Path", PrintBytes, TargetEncoding);
                end;

            ObjectOutput."Output Type"::"Epson Web":
                begin
                    Printer.OnGetPrintBytes(PrintBytes);
                    Printer.OnGetTargetEncoding(TargetEncoding);
                    for i := 1 to NoOfPrints do
                        PrintMethodMgt.PrintViaEpsonWebService(ObjectOutput."Output Path", '', PrintBytes, TargetEncoding);
                end;

            ObjectOutput."Output Type"::HTTP:
                begin
                    Printer.OnPrepareJobForHTTP(TargetEncoding, HTTPEndpoint, Supported);
                    if not Supported then
                        Error(Error_UnsupportedOutput, Format(ObjectOutput."Output Type"::HTTP), TemplateCode);
                    Printer.OnGetPrintBytes(PrintBytes);
                    for i := 1 to NoOfPrints do
                        PrintMethodMgt.PrintBytesHTTP(ObjectOutput."Output Path", HTTPEndpoint, PrintBytes, TargetEncoding);
                end;

            ObjectOutput."Output Type"::Bluetooth:
                begin
                    Printer.OnPrepareJobForBluetooth(TargetEncoding, Supported);
                    if not Supported then
                        Error(Error_UnsupportedOutput, Format(ObjectOutput."Output Type"::Bluetooth), TemplateCode);
                    Printer.OnGetPrintBytes(PrintBytes);
                    for i := 1 to NoOfPrints do
                        PrintMethodMgt.PrintBytesBluetooth(ObjectOutput."Output Path", PrintBytes, TargetEncoding);
                end;
            //-NPR5.53 [383562]
            ObjectOutput."Output Type"::"PrintNode Raw":
                begin
                    Printer.OnGetPrintBytes(PrintBytes);
                    Printer.OnGetTargetEncoding(TargetEncoding);
                    for i := 1 to NoOfPrints do
                        PrintMethodMgt.PrintViaPrintNodeRaw(ObjectOutput."Output Path", PrintBytes, TargetEncoding);
                end;
        //+NPR5.53 [383562]
        end;
        //+NPR5.44 [315362]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014547, 'OnGetDeviceType', '', false, false)]
    local procedure OnGetMatrixDeviceType(TemplateCode: Text; CodeunitId: Integer; ReportId: Integer; var DeviceType: Text)
    var
        ObjectOutput: Record "NPR Object Output Selection";
    begin
        //-NPR5.44 [315362]
        if not TryGetPrintOutput(TemplateCode, CodeunitId, ReportId, ObjectOutput) then
            exit;
        if ObjectOutput."Output Type" in [ObjectOutput."Output Type"::"Printer Name", ObjectOutput."Output Type"::Bluetooth] then
            DeviceType := ObjectOutput."Output Path";
        //+NPR5.44 [315362]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014549, 'OnGetDeviceType', '', false, false)]
    local procedure OnGetLineDeviceType(TemplateCode: Text; CodeunitId: Integer; ReportId: Integer; var DeviceType: Text)
    var
        ObjectOutput: Record "NPR Object Output Selection";
    begin
        //-NPR5.44 [315362]
        if not TryGetPrintOutput(TemplateCode, CodeunitId, ReportId, ObjectOutput) then
            exit;
        if ObjectOutput."Output Type" in [ObjectOutput."Output Type"::"Printer Name", ObjectOutput."Output Type"::Bluetooth] then
            DeviceType := ObjectOutput."Output Path";
        //+NPR5.44 [315362]
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSendMatrixPrint(TemplateCode: Text; CodeunitId: Integer; ReportId: Integer; var Printer: Codeunit "NPR RP Matrix Printer Interf."; NoOfPrints: Integer; var Skip: Boolean)
    begin
        //-+NPR5.48 [327107]
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSendLinePrint(TemplateCode: Text; CodeunitId: Integer; ReportId: Integer; var Printer: Codeunit "NPR RP Line Printer Interf."; NoOfPrints: Integer; var Skip: Boolean)
    begin
        //-+NPR5.48 [327107]
    end;
}

