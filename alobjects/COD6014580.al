codeunit 6014580 "Object Output Mgt."
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
        ObjectOutputSelection: Record "Object Output Selection";
    begin
        Path := GetOutputPath(ObjectOutputSelection."Object Type"::Codeunit, ObjectID,'');
    end;

    procedure GetCodeunitOutputPath2(ObjectID: Integer;PrintCode: Code[20]) Path: Text[250]
    var
        ObjectOutputSelection: Record "Object Output Selection";
    begin
        Path := GetOutputPath(ObjectOutputSelection."Object Type"::Codeunit, ObjectID, PrintCode);
    end;

    procedure GetReportOutputPath(ObjectID: Integer) Path: Text[250]
    var
        ObjectOutputSelection: Record "Object Output Selection";
    begin
        Path := GetOutputPath(ObjectOutputSelection."Object Type"::Report, ObjectID, '');
    end;

    procedure GetXMLOutputPath(ObjectID: Integer) Path: Text[250]
    var
        ObjectOutputSelection: Record "Object Output Selection";
    begin
        Path := GetOutputPath(ObjectOutputSelection."Object Type"::XMLPort, ObjectID, '');
    end;

    procedure GetOutputPath(ObjectType: Integer;ObjectID: Integer;PrintCode: Code[20]) Path: Text[250]
    var
        ObjectOutputSelection: Record "Object Output Selection";
    begin
        if TryGetOutputRec(ObjectType, ObjectID, PrintCode, UserId, ObjectOutputSelection) then
          Path := ObjectOutputSelection."Output Path"
        else begin
          ObjectOutputSelection."Object Type" := ObjectType;
          Error(ErrNoOutputFound, Format(ObjectOutputSelection."Object Type"), ObjectID, PrintCode);
        end;

        case ObjectOutputSelection."Output Type" of
          ObjectOutputSelection."Output Type"::"Printer Name":
            Path := ResolvePrinterName(Path);
          ObjectOutputSelection."Output Type"::File:;
        end;
    end;

    procedure GetCodeunitOutputType(ObjectID: Integer): Integer
    var
        ObjectOutputSelection: Record "Object Output Selection";
    begin
        exit(GetOutputType(ObjectOutputSelection."Object Type"::Codeunit, ObjectID,''));
    end;

    procedure GetCodeunitOutputType2(ObjectID: Integer;PrintCode: Code[20]): Integer
    var
        ObjectOutputSelection: Record "Object Output Selection";
    begin
        exit(GetOutputType(ObjectOutputSelection."Object Type"::Codeunit, ObjectID, PrintCode));
    end;

    procedure GetReportOutputType(ObjectID: Integer): Integer
    var
        ObjectOutputSelection: Record "Object Output Selection";
    begin
        exit(GetOutputType(ObjectOutputSelection."Object Type"::Report, ObjectID, ''));
    end;

    procedure GetXMLOutputType(ObjectID: Integer): Integer
    var
        ObjectOutputSelection: Record "Object Output Selection";
    begin
        exit(GetOutputType(ObjectOutputSelection."Object Type"::XMLPort, ObjectID, ''));
    end;

    procedure GetOutputType(ObjectType: Integer;ObjectID: Integer;PrintCode: Code[20]): Integer
    var
        ObjectOutputSelection: Record "Object Output Selection";
    begin
        if TryGetOutputRec(ObjectType, ObjectID, PrintCode, UserId, ObjectOutputSelection) then
          exit(ObjectOutputSelection."Output Type")
        else begin
          ObjectOutputSelection."Object Type" := ObjectType;
          Error(ErrNoOutputFound, Format(ObjectOutputSelection."Object Type"), ObjectID, PrintCode);
        end;
    end;

    procedure TryGetOutputRec(ObjectType: Integer;ObjectID: Integer;PrintCode: Code[20];User: Text;var ObjectOutputSelection: Record "Object Output Selection"): Boolean
    begin
        with ObjectOutputSelection do begin
          if Get (User, ObjectType, ObjectID, PrintCode) then
            exit (true);

          if ObjectID <> 0 then
            if Get (User, ObjectType, 0, PrintCode) then
              exit (true);

          if StrLen (PrintCode) > 0 then
            if Get (User, ObjectType, ObjectID, '') then
              exit (true);

          if not ((ObjectID = 0) and (StrLen (PrintCode) = 0)) then
            if Get (User, ObjectType, 0, '') then
              exit (true);

          if StrLen(User) = 0 then
            exit (false)
          else
            exit (TryGetOutputRec(ObjectType,ObjectID, PrintCode, '', ObjectOutputSelection));
        end;
    end;

    local procedure TryGetPrintOutput(TemplateCode: Text;CodeunitId: Integer;ReportId: Integer;var ObjectOutputSelection: Record "Object Output Selection"): Boolean
    begin
        //-NPR5.44 [315362]
        case true of
          ReportId <> 0 :
            if not TryGetOutputRec(ObjectOutputSelection."Object Type"::Report, ReportId, TemplateCode, UserId, ObjectOutputSelection) then
              exit(false);

          CodeunitId <> 0,
          TemplateCode <> '' :
            if not TryGetOutputRec(ObjectOutputSelection."Object Type"::Codeunit, CodeunitId, TemplateCode, UserId, ObjectOutputSelection) then
              exit(false);
          else
            exit(false);
        end;

        exit(true);
        //+NPR5.44 [315362]
    end;

    procedure ResolvePrinterName(PrinterName: Text[250]): Text[250]
    var
        Printer: Record Printer;
        TS1: Label '(from';
        TS2: Label ') in';
        ErrInvalidPrinter: Label '%1 is not a correct printerselection for this conectiontype';
        t002: Label 'Printerselection does not exist';
        t003: Label 'Printer %1 not found.';
        t004: Label 'Printer "%1" not found. Continue?';
        ErrIllegalUse: Label '%1 does not belong to your local PC (%2) and can therefore not be used.';
        Environment: Codeunit "NPR Environment Mgt.";
        SessionName: Text;
    begin
        if CurrentClientType <> CLIENTTYPE::Windows then
          exit(PrinterName);

        //-NPR5.44 [321816]
        SessionName := Environment.ClientEnvironment('SESSIONNAME');
        case true of
          CopyStr(SessionName,1,4) = 'RDP-' :
            begin
              PrinterName := FindLocalPrinterName(PrinterName);
              Printer.SetFilter(ID, '%1', PrinterName + ' (redirected *');
              if Printer.FindLast then
                exit(Printer.ID);
              exit(PrinterName);
            end;

          CopyStr(SessionName,1,3) = 'ICA' : exit(PrinterName); //TODO: Citrix printer name syntax
          else
            exit(PrinterName);
        end;

        // RetailSetup.GET;
        // CASE ConnectionProfileMgt.GetHostingType() OF
        //  { LOCAL CLIENT }
        //  RetailSetup."Hosting type"::Client : BEGIN
        //    TxtPrinter := '@' + PrinterName + '*';
        //    Printer.SETFILTER(Name, '%1', TxtPrinter);
        //    IF NOT Printer.FINDLAST THEN
        //      ERROR(t003, TxtPrinter)
        //    ELSE
        //      EXIT(Printer.ID);
        //  END;
        //
        //  { CITRIX }
        //  RetailSetup."Hosting type"::Citrix : BEGIN
        //    TxtPrinter := '';
        //    IF (COPYSTR(PrinterName, 1, 2) <> '\\') AND
        //        (COPYSTR(PrinterName, 1, 2) <> '//') AND
        //        (UPPERCASE(COPYSTR(PrinterName, 1, 6)) <> 'CLIENT') THEN
        //          TxtPrinter := 'Client' + '/' + Environment.ClientEnvironment('CLIENTNAME') + '#' + '/';
        //
        //    TxtPrinter := '*@'+ TxtPrinter + PrinterName + '*';
        //    Printer.SETFILTER(Name, '%1', TxtPrinter);
        //
        //    IF Printer.FINDLAST THEN
        //      EXIT(Printer.ID);
        //
        //    TxtPrinter := 'Client' + '\' + Environment.ClientEnvironment('CLIENTNAME') + '#' + '\';
        //    TxtPrinter := '*@'+ TxtPrinter + PrinterName + '*';
        //    Printer.SETFILTER(Name, '%1', TxtPrinter);
        //
        //    IF NOT Printer.FINDLAST THEN BEGIN
        //      Pos := STRPOS(PrinterName, ',');
        //      IF Pos <> 0 THEN
        //        TxtPrinter := '@' + DELSTR(PrinterName, Pos) + '*';
        //      Printer.SETFILTER(Name, '%1', TxtPrinter);
        //      IF NOT Printer.FINDLAST THEN BEGIN
        //        IF CONFIRM(t004, FALSE,TxtPrinter) THEN
        //          EXIT('')
        //        ELSE
        //          ERROR(t003, TxtPrinter);
        //      END;
        //    END ELSE
        //      EXIT(Printer.ID);
        //  END;
        //
        //  { TERMINAL SERVER }
        //  RetailSetup."Hosting type"::"Terminal Server" : BEGIN
        //    IF RetailSetup."Use I-Comm" THEN BEGIN
        //      "I-Comm".GET;
        //      IF (STRPOS(PrinterName, "I-Comm"."VirtualPDF Name") <> 0) THEN BEGIN
        //          Printer.GET(PrinterName);
        //          EXIT(Printer.ID);
        //        END;
        //    END;
        //
        //    IF STRPOS(PrinterName, '(from') = 0 THEN
        //      TxtPrinter := '*@'+ PrinterName + ' (from ' + Environment.ClientEnvironment('CLIENTNAME') + ')*'
        //    ELSE
        //      TxtPrinter := '*@'+ PrinterName + '*';
        //
        //    Printer.SETFILTER(Name, '%1', TxtPrinter);
        //    IF NOT Printer.FINDLAST THEN BEGIN
        //      TxtPrinter := '*@'+ PrinterName + ' on '+ '*@'+' (from ' + Environment.ClientEnvironment('CLIENTNAME') + ')*' ;
        //      Printer.SETFILTER(Name, '%1', TxtPrinter);
        //      IF NOT Printer.FINDFIRST THEN BEGIN
        //        TxtPrinter := '*@'+ PrinterName + '*';
        //        Printer.SETFILTER(Name, '%1', TxtPrinter);
        //        IF NOT Printer.FINDLAST THEN BEGIN
        //          Pos := STRPOS(PrinterName, ',');
        //          IF Pos > 0 THEN BEGIN
        //            TxtPrinter := '@' + DELSTR(PrinterName, Pos) + '*';
        //            Printer.SETFILTER(Name, '%1', TxtPrinter);
        //          END;
        //        END;
        //      END;
        //    END;
        //    IF (STRPOS( Printer.Name, '(from ' + Environment.ClientEnvironment('CLIENTNAME') ) = 0) AND
        //              (NOT RetailSetup."Don't force TS-Client printers") THEN
        //      MESSAGE(ErrIllegalUse,Printer.Name,Environment.ClientEnvironment('CLIENTNAME'));
        //    EXIT(Printer.ID);
        //  END;
        //
        //  { TERMINAL SERVER 2008 }
        //  RetailSetup."Hosting type"::"Terminal Server 2008" : BEGIN
        //    IF RetailSetup."Use I-Comm" THEN BEGIN
        //      "I-Comm".GET;
        //      IF (STRPOS(PrinterName, "I-Comm"."VirtualPDF Name") <> 0) THEN BEGIN
        //          Printer.GET(PrinterName);
        //          EXIT(Printer.ID);
        //        END;
        //    END;
        //
        //    PrinterName := FindLocalPrinterName(PrinterName);
        //    Printer.SETFILTER(Name, '%1', PrinterName + ' (redirected *');
        //    IF NOT Printer.FINDLAST THEN
        //      EXIT(PrinterName);
        //
        //    EXIT(Printer.ID);
        //  END;
        //
        //  ConnectionProfile."Hosting type"::WebClient :
        //    BEGIN
        //      EXIT (PrinterName);
        //    END;
        // END;
        //+NPR5.44 [321816]
    end;

    local procedure FindLocalPrinterName(PrinterName: Text): Text
    var
        RedirectedText: Text;
    begin
        RedirectedText := ' (redirected';
        if StrPos(PrinterName,RedirectedText) > 0 then
          exit(CopyStr(PrinterName,1,StrPos(PrinterName,RedirectedText) - 1));
        exit(PrinterName);
    end;

    local procedure "// Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014547, 'OnSendPrintJob', '', false, false)]
    local procedure OnSendMatrixPrint(TemplateCode: Text;CodeunitId: Integer;ReportId: Integer;var Printer: Codeunit "RP Matrix Printer Interface";NoOfPrints: Integer)
    var
        ObjectOutput: Record "Object Output Selection";
        PrintBytes: Text;
        TargetEncoding: Text;
        Supported: Boolean;
        HTTPEndpoint: Text;
        PrintMethodMgt: Codeunit "Print Method Mgt.";
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
          ObjectOutput."Output Type"::"Printer Name" :
            begin
              Printer.OnGetPrintBytes(PrintBytes);
              Printer.OnGetTargetEncoding(TargetEncoding);
              for i := 1 to NoOfPrints do
                PrintMethodMgt.PrintBytesLocal(ResolvePrinterName(ObjectOutput."Output Path"), PrintBytes, TargetEncoding);
            end;

          ObjectOutput."Output Type"::"Epson Web" :
            begin
              Printer.OnGetPrintBytes(PrintBytes);
              Printer.OnGetTargetEncoding(TargetEncoding);
              for i := 1 to NoOfPrints do
                PrintMethodMgt.PrintViaEpsonWebService(ObjectOutput."Output Path", '', PrintBytes, TargetEncoding);
            end;

          ObjectOutput."Output Type"::HTTP :
            begin
              Printer.OnPrepareJobForHTTP(TargetEncoding, HTTPEndpoint, Supported);
              if not Supported then
                Error(Error_UnsupportedOutput, Format(ObjectOutput."Output Type"::HTTP), TemplateCode);
              Printer.OnGetPrintBytes(PrintBytes);
              for i := 1 to NoOfPrints do
                PrintMethodMgt.PrintBytesHTTP(ObjectOutput."Output Path", HTTPEndpoint, PrintBytes, TargetEncoding);
            end;

          ObjectOutput."Output Type"::Bluetooth :
            begin
              Printer.OnPrepareJobForBluetooth(TargetEncoding, Supported);
              if not Supported then
                Error(Error_UnsupportedOutput, Format(ObjectOutput."Output Type"::Bluetooth), TemplateCode);
              Printer.OnGetPrintBytes(PrintBytes);
              for i := 1 to NoOfPrints do
                PrintMethodMgt.PrintBytesBluetooth(ObjectOutput."Output Path", PrintBytes, TargetEncoding);
            end;
          //-NPR5.53 [383562]
          ObjectOutput."Output Type"::"PrintNode Raw" :
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
    local procedure OnSendLinePrint(TemplateCode: Text;CodeunitId: Integer;ReportId: Integer;var Printer: Codeunit "RP Line Printer Interface";NoOfPrints: Integer)
    var
        ObjectOutput: Record "Object Output Selection";
        PrintBytes: Text;
        TargetEncoding: Text;
        Supported: Boolean;
        HTTPEndpoint: Text;
        PrintMethodMgt: Codeunit "Print Method Mgt.";
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
          ObjectOutput."Output Type"::"Printer Name" :
            begin
              Printer.OnGetPrintBytes(PrintBytes);
              Printer.OnGetTargetEncoding(TargetEncoding);
              for i := 1 to NoOfPrints do
                PrintMethodMgt.PrintBytesLocal(ResolvePrinterName(ObjectOutput."Output Path"), PrintBytes, TargetEncoding);
            end;

          ObjectOutput."Output Type"::"Epson Web" :
            begin
              Printer.OnGetPrintBytes(PrintBytes);
              Printer.OnGetTargetEncoding(TargetEncoding);
              for i := 1 to NoOfPrints do
                PrintMethodMgt.PrintViaEpsonWebService(ObjectOutput."Output Path", '', PrintBytes, TargetEncoding);
            end;

          ObjectOutput."Output Type"::HTTP :
            begin
              Printer.OnPrepareJobForHTTP(TargetEncoding, HTTPEndpoint, Supported);
              if not Supported then
                Error(Error_UnsupportedOutput, Format(ObjectOutput."Output Type"::HTTP), TemplateCode);
              Printer.OnGetPrintBytes(PrintBytes);
              for i := 1 to NoOfPrints do
                PrintMethodMgt.PrintBytesHTTP(ObjectOutput."Output Path", HTTPEndpoint, PrintBytes, TargetEncoding);
            end;

          ObjectOutput."Output Type"::Bluetooth :
            begin
              Printer.OnPrepareJobForBluetooth(TargetEncoding, Supported);
              if not Supported then
                Error(Error_UnsupportedOutput, Format(ObjectOutput."Output Type"::Bluetooth), TemplateCode);
              Printer.OnGetPrintBytes(PrintBytes);
              for i := 1 to NoOfPrints do
                PrintMethodMgt.PrintBytesBluetooth(ObjectOutput."Output Path", PrintBytes, TargetEncoding);
            end;
          //-NPR5.53 [383562]
          ObjectOutput."Output Type"::"PrintNode Raw" :
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
    local procedure OnGetMatrixDeviceType(TemplateCode: Text;CodeunitId: Integer;ReportId: Integer;var DeviceType: Text)
    var
        ObjectOutput: Record "Object Output Selection";
    begin
        //-NPR5.44 [315362]
        if not TryGetPrintOutput(TemplateCode, CodeunitId, ReportId, ObjectOutput) then
          exit;
        if ObjectOutput."Output Type" in [ObjectOutput."Output Type"::"Printer Name", ObjectOutput."Output Type"::Bluetooth] then
          DeviceType := ObjectOutput."Output Path";
        //+NPR5.44 [315362]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014549, 'OnGetDeviceType', '', false, false)]
    local procedure OnGetLineDeviceType(TemplateCode: Text;CodeunitId: Integer;ReportId: Integer;var DeviceType: Text)
    var
        ObjectOutput: Record "Object Output Selection";
    begin
        //-NPR5.44 [315362]
        if not TryGetPrintOutput(TemplateCode, CodeunitId, ReportId, ObjectOutput) then
          exit;
        if ObjectOutput."Output Type" in [ObjectOutput."Output Type"::"Printer Name", ObjectOutput."Output Type"::Bluetooth] then
          DeviceType := ObjectOutput."Output Path";
        //+NPR5.44 [315362]
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSendMatrixPrint(TemplateCode: Text;CodeunitId: Integer;ReportId: Integer;var Printer: Codeunit "RP Matrix Printer Interface";NoOfPrints: Integer;var Skip: Boolean)
    begin
        //-+NPR5.48 [327107]
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSendLinePrint(TemplateCode: Text;CodeunitId: Integer;ReportId: Integer;var Printer: Codeunit "RP Line Printer Interface";NoOfPrints: Integer;var Skip: Boolean)
    begin
        //-+NPR5.48 [327107]
    end;
}

