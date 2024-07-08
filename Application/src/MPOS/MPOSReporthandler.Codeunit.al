codeunit 6059976 "NPR MPOS Report handler"
{
    Access = Internal;
    var
        CreatePDFFailedErr: Label 'Error creating PDF report';

    procedure ExecutionHandler(ReportId: Integer; RegisterId: Code[10])
    var
        POSUnit: Record "NPR POS Unit";
        RecVariant: Variant;
    begin
        if POSUnit.Get(RegisterId) then begin
            if POSUnit."POS Type" = POSUnit."POS Type"::MPOS then
                SendReportToLocalOS(ReportId, RecVariant)
            else
                REPORT.RunModal(ReportId);
        end else
            REPORT.RunModal(ReportId);
    end;

    procedure ExecutionHandlerWithVars(ReportId: Integer; RecVariant: Variant; ReqWindow: Boolean; SystemPrinter: Boolean)
    var
        POSUnit: Record "NPR POS Unit";
        RegisterId: Code[10];
        UserSetup: Record "User Setup";
    begin
        if UserSetup.Get(UserId) then
            RegisterId := UserSetup."NPR POS Unit No.";

        if POSUnit.Get(RegisterId) then begin
            if POSUnit."POS Type" = POSUnit."POS Type"::MPOS then
                SendReportToLocalOS(ReportId, RecVariant)
            else
                REPORT.RunModal(ReportId, ReqWindow, SystemPrinter, RecVariant);
        end else
            REPORT.RunModal(ReportId, ReqWindow, SystemPrinter, RecVariant);
    end;

    local procedure SendReportToLocalOS(ReportId: Integer; RecVariant: Variant): Boolean
    var
        ReportBlob: Codeunit "Temp Blob";
        AllObjWithCaption: Record AllObjWithCaption;
        RecRef: RecordRef;
        OutStr: OutStream;
        InStr: InStream;
        XmlParameters: Text;
        Filename: Text;
        Base64String: Text;
        JSON: Text;
        JSBridge: Page "NPR JS Bridge";
        Base64Convert: Codeunit "Base64 Convert";
        FileNameLbl: Label '%1 - %2.pdf', Locked = true;
    begin
        AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Report, ReportId);

        if RecVariant.IsRecord then begin
            RecRef.GetTable(RecVariant);
            XmlParameters := GetXmlParameters(RecRef);
        end;

        Filename := StrSubstNo(FileNameLbl, AllObjWithCaption."Object Caption", CurrentDateTime);
        XmlParameters := REPORT.RunRequestPage(ReportId, XmlParameters);
        if XmlParameters = '' then
            Error('');

        ReportBlob.CreateOutStream(OutStr);

        if RecVariant.IsRecord then
            REPORT.SaveAs(ReportId, XmlParameters, REPORTFORMAT::Pdf, OutStr, RecRef)
        else
            REPORT.SaveAs(ReportId, XmlParameters, REPORTFORMAT::Pdf, OutStr);

        ReportBlob.CreateInStream(InStr);
        Base64String := Base64Convert.ToBase64(InStr);

        JSON := BuildJSONParams(Filename, '', Base64String, '', CreatePDFFailedErr);

        JSBridge.SetParameters('CREATEPDF', JSON, '');
        JSBridge.RunModal();

        exit(true);
    end;

    local procedure GetXmlParameters(RecRef: RecordRef): Text
    var
        XmlDoc: XmlDocument;
        XmlText: Text;
        RootElement: XmlElement;
        DataItemsNode: XmlElement;
        DataItemNode: XmlElement;
    begin
        XmlDocument.ReadFrom('<?xml version="1.0" encoding="utf-8" standalone="yes"?><ReportParameters />', XmlDoc);
        XmlDoc.GetRoot(RootElement);
        DataItemsNode := XmlElement.Create('DataItems');
        RootElement.Add(DataItemsNode);

        DataItemNode := XmlElement.Create('DataItem', '', RecRef.GetView(false));
        DataItemNode.SetAttribute('name', RecRef.Caption);
        DataItemsNode.Add(DataItemNode);

        XmlDoc.WriteTo(XmlText);

        exit(XmlText);
    end;

    local procedure BuildJSONParams(BaseAddress: Text; Endpoint: Text; PrintJob: Text; RequestType: Text; ErrorCaption: Text) JSON: Text
    begin
        JSON := '{';
        JSON += '"RequestMethod": "CREATEPDF",';
        JSON += '"BaseAddress": "' + BaseAddress + '",';
        JSON += '"Endpoint": "' + Endpoint + '",';
        JSON += '"PrintJob": "' + PrintJob + '",';
        JSON += '"RequestType": "' + RequestType + '",';
        JSON += '"ErrorCaption": "' + ErrorCaption + '"';
        JSON += '}';
    end;
}

