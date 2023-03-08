codeunit 6151221 "NPR PrintNode Mgt."
{
    Access = Internal;

    trigger OnRun()
    begin
    end;

    var
        NaviDocsHandlingProfileTxt: Label 'PrintNode printing';
        NoDefaultPrinterErr: Label 'No default Printer found.';
        RecordNotFoundErr: Label 'Document %1 not found.';
        NoOutputErr: Label 'No output from Report %1.';

    procedure LookupPrinter(var PrinterId: Text[250]): Boolean
    var
        PrinterName: Text;
    begin
        exit(LookupPrinterIdAndName(PrinterId, PrinterName));
    end;

    procedure LookupPrinterIdAndName(var PrinterID: Text[250]; var PrinterName: Text): Boolean
    var
        TempRetailList: Record "NPR Retail List" temporary;
        PrintNodeAPI: Codeunit "NPR PrintNode API Mgt.";
        RetailList: Page "NPR Retail List";
        JArray: JsonArray;
        JToken: JsonToken;
        Hostname: Text;
    begin
        ClearLastError();
        if not PrintNodeAPI.GetPrinters(JArray) then
            Error(GetLastErrorText);
        foreach JToken in JArray do begin
            TempRetailList.Number += 1;
            Hostname := GetString(JToken.AsObject(), 'computer.name', false);
            TempRetailList.Choice := CopyStr(GetString(JToken.AsObject(), 'name', false) + ' (' + Hostname + ')', 1, MaxStrLen(TempRetailList.Choice));
#pragma warning disable AA0139                    
            TempRetailList.Value := GetString(JToken.AsObject(), 'id', true);
#pragma warning restore                    
            TempRetailList.Insert();
        end;
        if TempRetailList.IsEmpty then
            exit(false);
        RetailList.SetRec(TempRetailList);
        RetailList.SetShowValue(true);
        RetailList.LookupMode(true);
        if RetailList.RunModal() <> Action::LookupOK then
            exit(false);
        RetailList.GetRecord(TempRetailList);
        PrinterID := TempRetailList.Value;
        PrinterName := TempRetailList.Choice;
        exit(true);
    end;



    procedure SetPrinterOptions(var PrintNodePrinter: Record "NPR PrintNode Printer")
    var
        PrintNodeAPI: Codeunit "NPR PrintNode API Mgt.";
        PrintNodeSettings: Page "NPR PrintNode Printer Settings";
        JArray: JsonArray;
        JToken: JsonToken;
        IStream: InStream;
        OStream: OutStream;
        SettingsJson: Text;
        PrinterNotFoundErr: label 'Printer %1 not found in PrintNode.';
    begin
        if PrintNodePrinter.Id = '' then
            exit;
        if not PrintNodeAPI.GetPrinterInfo(PrintNodePrinter.Id, JArray) then
            Error(PrinterNotFoundErr, PrintNodePrinter.Id);
        if not JArray.Get(0, JToken) then
            exit;
        if not SelectToken(JToken.AsObject(), JToken, 'capabilities', false) then
            exit;
        if PrintNodePrinter.Settings.HasValue() then begin
            PrintNodePrinter.CalcFields(Settings);
            PrintNodePrinter.Settings.CreateInStream(IStream, TextEncoding::UTF8);
            IStream.Read(SettingsJson);
            PrintNodeSettings.LoadExistingSettings(SettingsJson);
        end;
        PrintNodeSettings.LookupMode(true);
        JToken.WriteTo(SettingsJson);
        PrintNodeSettings.SetPrinterJson(SettingsJson);
        if PrintNodeSettings.RunModal() = Action::LookupOK then begin
            SettingsJson := PrintNodeSettings.GetSettings();
            if SettingsJson <> '' then begin
                PrintNodePrinter.Settings.CreateOutStream(OStream, TextEncoding::UTF8);
                OStream.Write(SettingsJson);
            end else
                clear(PrintNodePrinter.Settings);
            PrintNodePrinter.Modify(true);
        end;
    end;

    procedure GetPrinterOptions(PrinterId: Text; ObjectType: Option "Report","Codeunit"; ObjectId: Integer): Text
    var
        PrintNodePrinter: Record "NPR PrintNode Printer";
        IStream: InStream;
        SettingsJson: Text;
    begin
        PrintNodePrinter.SetAutoCalcFields(Settings);
        if not PrintNodePrinter.Get(PrinterId, ObjectType, ObjectId) then
            if not PrintNodePrinter.Get(PrinterId, ObjectType, 0) then
                exit('');
        if not PrintNodePrinter.Settings.HasValue() then
            exit('');
        PrintNodePrinter.Settings.CreateInStream(IStream, TextEncoding::UTF8);
        IStream.Read(SettingsJson);
        exit(SettingsJson);
    end;

    procedure ViewPrinterInfo(PrinterId: Text)
    var
        PrintNodeAPI: Codeunit "NPR PrintNode API Mgt.";
        TempBlob: Codeunit "Temp Blob";
        JArray: JsonArray;
        OStream: OutStream;
        IStream: InStream;
        Filename: Text;
        PrinterNotFoundErr: Label 'Printer %1 not found in PrintNode.';
    begin
        if PrinterId = '' then
            exit;
        if not PrintNodeAPI.GetPrinterInfo(PrinterId, JArray) then
            Error(PrinterNotFoundErr, PrinterId);
        TempBlob.CreateOutStream(OStream);
        if not JArray.WriteTo(OStream) then
            exit;
        TempBlob.CreateInStream(IStream);
        Filename := 'Config' + PrinterId + '.json';
        DownloadFromStream(Istream, 'Printer Config', '', 'JSON File (*.json)|*.json', Filename);
    end;

    local procedure SelectToken(JObject: JsonObject; var JToken: JsonToken; JPath: Text; WithError: Boolean): Boolean
    var
        JSonString: Text;
        KeyNotFoundTxt: Label 'Property "%1" does not exist in JSON object.\\%2.';
    begin
        if not JObject.SelectToken(JPath, JToken) then begin
            if WithError then begin
                JObject.WriteTo(JSonString);
                Error(KeyNotFoundTxt, JPath, JSonString);
            end;
            exit(false);
        end;
        exit(true);
    end;

    local procedure GetString(JObject: JsonObject; JPath: Text; WithError: Boolean): Text
    var
        JToken: JsonToken;
    begin
        if SelectToken(JObject, JToken, JPath, WithError) then
            exit(JToken.AsValue().AsText());
        exit('');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NaviDocs Management", 'OnAddHandlingProfilesToLibrary', '', true, true)]
    local procedure AddNaviDocsHandlingProfile()
    var
        NaviDocsManagement: Codeunit "NPR NaviDocs Management";
    begin
        NaviDocsManagement.AddHandlingProfileToLibrary(NaviDocsHandlingProfileCode(), NaviDocsHandlingProfileTxt, true, false, false, false);
    end;

    local procedure NaviDocsHandlingProfileCode(): Code[20]
    begin
        exit('PRINTNODE-PDF');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NaviDocs Management", 'OnManageDocument', '', true, true)]
    local procedure HandleNaviDocsDocument(var IsDocumentHandled: Boolean; ProfileCode: Code[20]; var NaviDocsEntry: Record "NPR NaviDocs Entry"; ReportID: Integer; var WithSuccess: Boolean; var ErrorMessage: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        PrintNodeAPIMgt: Codeunit "NPR PrintNode API Mgt.";
        RecRef: RecordRef;
        PrinterId: Code[20];
        OStream: OutStream;
    begin
        if IsDocumentHandled or (ProfileCode <> NaviDocsHandlingProfileCode()) then
            exit;

        PrinterId := NaviDocsEntry."Template Code";

        if PrinterId = '' then
            ErrorMessage := NoDefaultPrinterErr;

        if ErrorMessage = '' then
            if not RecRef.Get(NaviDocsEntry."Record ID") then
                ErrorMessage := StrSubstNo(RecordNotFoundErr, NaviDocsEntry."Record ID");

        if ErrorMessage = '' then begin
            RecRef.SetRecFilter();
            SetCustomReportLayout(RecRef, ReportID);
            TempBlob.CreateOutStream(OStream);
            if not Report.SaveAs(ReportID, '', REPORTFORMAT::Pdf, OStream, RecRef) then
                ErrorMessage := StrSubstNo(NoOutputErr, ReportID);
            ClearCustomReportLayout();
        end;

        if ErrorMessage = '' then begin
            PrintNodeAPIMgt.SendPDFStream(PrinterId, TempBlob, NaviDocsEntry."Document Description", '', '');
        end;

        IsDocumentHandled := true;
        WithSuccess := ErrorMessage = '';
    end;

    local procedure SetCustomReportLayout(RecRef: RecordRef; ReportID: Integer)
    var
        CustomReportSelection: Record "Custom Report Selection";
        ReportLayoutSelection: Record "Report Layout Selection";
        CustomReportLayout: Record "Custom Report Layout";
        EmailNaviDocsMgtWrapper: Codeunit "NPR E-mail NaviDocs Mgt.Wrap.";
        CustomReportLayoutVariant: Code[20];
    begin
        if RecRef.Number in [18, 36, 112, 114] then begin
            CustomReportSelection.SetRange("Source Type", DATABASE::Customer);
            if RecRef.Number = 18 then
                CustomReportSelection.SetRange("Source No.", Format(RecRef.Field(1).Value))
            else
                CustomReportSelection.SetRange("Source No.", Format(RecRef.Field(4).Value));
            CustomReportSelection.SetRange("Report ID", ReportID);
            if CustomReportSelection.FindFirst() then begin
                EmailNaviDocsMgtWrapper.GetCustomReportLayoutVariant(CustomReportSelection, CustomReportLayoutVariant);
                if CustomReportLayout.Get(CustomReportLayoutVariant) then
                    ReportLayoutSelection.SetTempLayoutSelected(CustomReportLayoutVariant);
            end;
        end;
    end;

    local procedure ClearCustomReportLayout()
    var
        ReportLayoutSelection: Record "Report Layout Selection";
        CustomReportSelection: Record "Custom Report Selection";
        EmailNaviDocsMgtWrapper: Codeunit "NPR E-mail NaviDocs Mgt.Wrap.";
        BlankVariant: Variant;
    begin
        EmailNaviDocsMgtWrapper.GetCustomReportLayoutVariant(CustomReportSelection, BlankVariant);
        ReportLayoutSelection.SetTempLayoutSelected(BlankVariant);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Object Output Selection", 'OnLookupOutputPath', '', false, false)]
    local procedure OnLookupObjectOutputPath(var ObjectOutputSelection: Record "NPR Object Output Selection")
    var
        ID: Text[250];
    begin
        if ObjectOutputSelection."Output Type" <> ObjectOutputSelection."Output Type"::"PrintNode Raw" then
            exit;

        if LookupPrinter(ID) then
            ObjectOutputSelection."Output Path" := ID;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"ReportManagement", 'OnAfterSetupPrinters', '', true, true)]
    local procedure SetupPrinters(var Printers: Dictionary of [Text[250], JsonObject]);
    var
        Payload: JsonObject;
        PrintNodePrinter: Record "NPR PrintNode Printer";
        PrintNodePrinterLbl: Label 'Print Node Printer: %1', Locked = true;
        BooleanString: Text;
        PrinterIdHashSet: Dictionary of [Text, Boolean];
    begin
        if PrintNodePrinter.FindSet() then
            repeat
                if not PrinterIdHashSet.ContainsKey(PrintNodePrinter.Id) then begin
                    if PrintNodePrinter."BC Paper Size" = PrintNodePrinter."BC Paper Size"::Custom then begin
                        if PrintNodePrinter."BC Landscape" then
                            BooleanString := 'true'
                        else
                            BooleanString := 'false';

                        Payload.ReadFrom(StrSubstNo('{"version":1,"description":"%1","papertrays":[{"papersourcekind":%2,"paperkind":%3,"units":"%4","height":%5,"width":%6,"landscape":%7}]}',
                                                    CopyStr(StrSubstNo(PrintNodePrinterLbl, PrintNodePrinter.Name), 1, 250), PrintNodePrinter."BC Paper Source".AsInteger(), PrintNodePrinter."BC Paper Size".AsInteger(), PrintNodePrinter."BC Paper Unit", PrintNodePrinter."BC Paper Height", PrintNodePrinter."BC Paper Width", BooleanString));
                    end else begin
                        Payload.ReadFrom(StrSubstNo('{"version":1,"description":"%1","papertrays":[{"papersourcekind":%2,"paperkind":%3}]}', CopyStr(StrSubstNo(PrintNodePrinterLbl, PrintNodePrinter.Name), 1, 250), PrintNodePrinter."BC Paper Source".AsInteger(), PrintNodePrinter."BC Paper Size".AsInteger()));
                    end;
                    Printers.Add('NPR_PRINTNODE_' + PrintNodePrinter.Id, Payload);
                    Clear(Payload);
                    PrinterIdHashSet.Add(PrintNodePrinter.Id, false);
                end;
            until PrintNodePrinter.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"ReportManagement", 'OnAfterDocumentPrintReady', '', true, true)]
    local procedure OnDocumentPrintReady(ObjectType: Option "Report","Page"; ObjectId: Integer; ObjectPayload: JsonObject; DocumentStream: InStream; var Success: Boolean);
    var
        PrintNodePrinter: Record "NPR PrintNode Printer";
        JToken: JsonToken;
        PrintMethodMgt: Codeunit "NPR Print Method Mgt.";
        PrinterName: Text;
    begin
        begin
            if Success then
                exit;
            if ObjectType <> ObjectType::Report then
                exit;
            if not ObjectPayload.Get('printername', JToken) then
                exit;
            PrinterName := JToken.AsValue().AsText();
            if not PrinterName.StartsWith('NPR_PRINTNODE_') then
                exit;
            PrintNodePrinter.SetRange(Id, PrinterName.Substring(15));
            if not PrintNodePrinter.FindFirst() then
                exit;
            if not ObjectPayload.Get('documenttype', JToken) then
                exit;
            if JToken.AsValue().AsText() <> 'application/pdf' then
                exit;

            PrintMethodMgt.PrintViaPrintNodePdf(PrintNodePrinter.Id, DocumentStream, StrSubstNo('NPRetail PrintNode Print - Report %1', ObjectId), 0, ObjectId);
            Success := true;
        end;
    end;
}


