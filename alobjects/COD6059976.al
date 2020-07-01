codeunit 6059976 "MPOS Report handler"
{
    // NPR5.33/NPKNAV/20170630  CASE 272155 Transport NPR5.33 - 30 June 2017
    // NPR5.34/CLVA/20170703 CASE 280444 Upgrading MPOS functionality to transcendence


    trigger OnRun()
    begin
    end;

    var
        Err_CreatePDFFailed: Label 'Error creating PDF report';

    procedure ExecutionHandler(ReportId: Integer; RegisterId: Code[10])
    var
        MPOSAppSetup: Record "MPOS App Setup";
        RecVariant: Variant;
    begin
        if MPOSAppSetup.Get(RegisterId) then begin
            if MPOSAppSetup.Enable then
                SendReportToLocalOS(ReportId, RecVariant)
            else
                REPORT.RunModal(ReportId);
        end else
            REPORT.RunModal(ReportId);
    end;

    procedure ExecutionHandlerWithVars(ReportId: Integer; RecVariant: Variant; ReqWindow: Boolean; SystemPrinter: Boolean)
    var
        MPOSAppSetup: Record "MPOS App Setup";
        RegisterId: Code[10];
        UserSetup: Record "User Setup";
    begin
        if UserSetup.Get(UserId) then
            RegisterId := UserSetup."Backoffice Register No.";

        if MPOSAppSetup.Get(RegisterId) then begin
            if MPOSAppSetup.Enable then
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
        MemStream: DotNet npNetMemoryStream;
        RecRef: RecordRef;
        OutStr: OutStream;
        InStr: InStream;
        Result: Text;
        XmlParameters: Text;
        Filename: Text;
        Bytes: DotNet npNetArray;
        Convert: DotNet npNetConvert;
        Base64String: Text;
        JSON: Text;
        JSBridge: Page "JS Bridge";
    begin
        AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Report, ReportId);

        if RecVariant.IsRecord then begin
            RecRef.GetTable(RecVariant);
            XmlParameters := GetXmlParameters(RecRef);
        end;

        Filename := StrSubstNo('%1 - %2.pdf', AllObjWithCaption."Object Caption", CurrentDateTime);
        XmlParameters := REPORT.RunRequestPage(ReportId, XmlParameters);
        if XmlParameters = '' then
            Error('');

        ReportBlob.CreateOutStream(OutStr);

        if RecVariant.IsRecord then
            REPORT.SaveAs(ReportId, XmlParameters, REPORTFORMAT::Pdf, OutStr, RecRef)
        else
            REPORT.SaveAs(ReportId, XmlParameters, REPORTFORMAT::Pdf, OutStr);

        ReportBlob.CreateInStream(InStr);
        MemStream := MemStream.MemoryStream();
        CopyStream(MemStream, InStr);

        Bytes := MemStream.GetBuffer();
        Base64String := Convert.ToBase64String(Bytes, 0, Bytes.Length);

        JSON := BuildJSONParams(Filename, '', Base64String, '', Err_CreatePDFFailed);

        JSBridge.SetParameters('CREATEPDF', JSON, '');
        JSBridge.RunModal;

        exit(true);
    end;

    local procedure GetXmlParameters(RecRef: RecordRef): Text
    var
        XMLDOMMgt: Codeunit "XML DOM Management";
        DataItemXmlNode: DotNet npNetXmlNode;
        DataItemsXmlNode: DotNet npNetXmlNode;
        XmlDoc: DotNet npNetXmlDocument;
        ReportParametersXmlNode: DotNet npNetXmlNode;
    begin
        XmlDoc := XmlDoc.XmlDocument;

        XMLDOMMgt.AddRootElement(XmlDoc, 'ReportParameters', ReportParametersXmlNode);
        XMLDOMMgt.AddDeclaration(XmlDoc, '1.0', 'utf-8', 'yes');

        XMLDOMMgt.AddElement(ReportParametersXmlNode, 'DataItems', '', '', DataItemsXmlNode);
        XMLDOMMgt.AddElement(DataItemsXmlNode, 'DataItem', RecRef.GetView(false), '', DataItemXmlNode);
        XMLDOMMgt.AddAttribute(DataItemXmlNode, 'name', RecRef.Caption);

        exit(XmlDoc.InnerXml);
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

