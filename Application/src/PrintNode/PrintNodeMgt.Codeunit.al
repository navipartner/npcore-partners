codeunit 6151221 "NPR PrintNode Mgt."
{

    trigger OnRun()
    begin
    end;

    var
        NaviDocsHandlingProfileTxt: Label 'PrintNode printing';
        NoDefaultPrinterErr: Label 'No default Printer found.';
        RecordNotFoundErr: Label 'Document %1 not found.';
        NoOutputErr: Label 'No output from Report %1.';

    procedure LookupPrinter(var PrinterId: Text): Boolean
    var
        PrinterName: Text;
    begin
        exit(LookupPrinterIdAndName(PrinterId, PrinterName));
    end;

    procedure LookupPrinterIdAndName(var PrinterID: Text; var PrinterName: Text): Boolean
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
            TempRetailList.Value := GetString(JToken.AsObject(), 'id', true);
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
                Error(StrSubstNo(KeyNotFoundTxt, JPath, JSonString));
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

    [EventSubscriber(ObjectType::Codeunit, 6059767, 'OnAddHandlingProfilesToLibrary', '', true, true)]
    local procedure AddNaviDocsHandlingProfile()
    var
        NaviDocsManagement: Codeunit "NPR NaviDocs Management";
    begin
        NaviDocsManagement.AddHandlingProfileToLibrary(NaviDocsHandlingProfileCode, NaviDocsHandlingProfileTxt, true, false, false, false);
    end;

    local procedure NaviDocsHandlingProfileCode(): Text
    begin
        exit('PRINTNODE-PDF');
    end;

    local procedure AddPrintNodeJobtoNaviDocs(RecordVariant: Variant; PrinterID: Text; ReportID: Integer; DelayUntil: DateTime)
    var
        NaviDocsManagement: Codeunit "NPR NaviDocs Management";
        DataTypeManagement: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        DataTypeManagement.GetRecordRef(RecordVariant, RecRef);
        NaviDocsManagement.AddDocumentEntryWithHandlingProfileExt(RecRef, NaviDocsHandlingProfileCode, ReportID, '', PrinterID, DelayUntil);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6059767, 'OnManageDocument', '', true, true)]
    local procedure HandleNaviDocsDocument(var IsDocumentHandled: Boolean; ProfileCode: Code[20]; var NaviDocsEntry: Record "NPR NaviDocs Entry"; ReportID: Integer; var WithSuccess: Boolean; var ErrorMessage: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        PrintNodeAPIMgt: Codeunit "NPR PrintNode API Mgt.";
        RecRef: RecordRef;
        PrinterId: Text;
        OStream: OutStream;
    begin
        if IsDocumentHandled or (ProfileCode <> NaviDocsHandlingProfileCode) then
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
            ClearCustomReportLayout;
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
        CustomReportLayoutVariant: Variant;
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
}

