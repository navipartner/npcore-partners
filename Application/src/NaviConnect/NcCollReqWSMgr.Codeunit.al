codeunit 6151533 "NPR Nc Coll. Req. WS Mgr"
{
    // NC2.01/BR  /20160912  CASE 250447 NaviConnect: Object created
    // NC2.08/BR  /20171123  CASE 297355 Deleted unused variables

    TableNo = "NPR Nc Import Entry";

    trigger OnRun()
    var
        XmlDoc: DotNet "NPRNetXmlDocument";
        FunctionName: Text[100];
    begin

        if LoadXmlDoc(XmlDoc) then begin
            FunctionName := GetWebserviceFunction("Import Type");
            case FunctionName of
                'Createcollectorrequest':
                    CreateCollectorRequests(XmlDoc, "Entry No.", "Document ID");
                else
                    Error(MISSING_CASE, "Import Type", FunctionName);
            end;

        end;
    end;

    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        Initialized: Boolean;
        MISSING_CASE: Label 'No handler for %1 [%2].';

    local procedure CreateCollectorRequests(XmlDoc: DotNet "NPRNetXmlDocument"; RequestEntryNo: Integer; DocumentID: Text[100])
    var
        XmlElement: DotNet NPRNetXmlElement;
        XmlNodeList: DotNet NPRNetXmlNodeList;
        i: Integer;
        Token: Text[50];
    begin
        if IsNull(XmlDoc) then
            exit;
        XmlElement := XmlDoc.DocumentElement;
        if IsNull(XmlElement) then
            exit;

        if not NpXmlDomMgt.FindNodes(XmlElement, 'Createcollectorrequest', XmlNodeList) then
            exit;

        if not NpXmlDomMgt.FindNodes(XmlElement, 'Collectorrequestimport', XmlNodeList) then
            exit;

        if not NpXmlDomMgt.FindNodes(XmlElement, 'insertcollectorrequest', XmlNodeList) then
            exit;

        XmlElement := XmlNodeList.ItemOf(0);

        SetImportParameters(XmlElement, Token);

        if not NpXmlDomMgt.FindNodes(XmlElement, 'collectorrequest', XmlNodeList) then
            exit;

        for i := 0 to XmlNodeList.Count() - 1 do begin
            XmlElement := XmlNodeList.ItemOf(i);
            CreateCollectorRequest(XmlElement, Token, DocumentID);
        end;

        Commit();
    end;

    local procedure CreateCollectorRequest(XmlElement: DotNet NPRNetXmlElement; Token: Text[100]; DocumentID: Text[100]): Boolean
    var
        XmlNodeList: DotNet NPRNetXmlNodeList;
        NcCollectorRequest: Record "NPR Nc Collector Request";
        i: Integer;
    begin

        if IsNull(XmlElement) then
            exit(false);

        NcCollectorRequest.Init();

        ReadCollectorRequest(XmlElement, Token, NcCollectorRequest);
        if NpXmlDomMgt.FindNodes(XmlElement, 'collectorrequestfilter', XmlNodeList) then
            for i := 0 to XmlNodeList.Count() - 1 do begin
                XmlElement := XmlNodeList.ItemOf(i);
                CreateCollectorRequestFilter(XmlElement, Token, DocumentID, NcCollectorRequest);
            end;
        //NcCollectorRequest.ProcessQuery;
        InsertCollectorRequests(NcCollectorRequest);


        exit(true);
    end;

    local procedure CreateCollectorRequestFilter(XmlElement: DotNet NPRNetXmlElement; Token: Text[100]; DocumentID: Text[100]; var NcCollectorRequest: Record "NPR Nc Collector Request"): Boolean
    var
        NcCollectorRequestFilter: Record "NPR Nc Collector Req. Filter";
    begin

        if IsNull(XmlElement) then
            exit(false);

        NcCollectorRequestFilter.Init();

        ReadCollectorRequestFilter(XmlElement, Token, NcCollectorRequestFilter, NcCollectorRequest);
        InsertCollectorRequestFilters(NcCollectorRequestFilter);

        exit(true);
    end;

    local procedure "---Database"()
    begin
    end;

    local procedure InsertCollectorRequests(var NcCollectorRequest: Record "NPR Nc Collector Request"): Boolean
    begin

        NcCollectorRequest.Init();
    end;

    local procedure ReadCollectorRequest(XmlElement: DotNet NPRNetXmlElement; Token: Text[100]; var NcCollectorRequest: Record "NPR Nc Collector Request")
    begin

        Initialize;

        Clear(NcCollectorRequest);
        NcCollectorRequest.Init();
        NcCollectorRequest."Creation Date" := CurrentDateTime();
        if NpXmlDomMgt.GetXmlText(XmlElement, 'no', MaxStrLen(NcCollectorRequest.Name), false) <> '' then
            Evaluate(NcCollectorRequest."External No.", NpXmlDomMgt.GetXmlText(XmlElement, 'no', MaxStrLen(NcCollectorRequest.Name), false), 9);
        NcCollectorRequest.Name := NpXmlDomMgt.GetXmlText(XmlElement, 'name', MaxStrLen(NcCollectorRequest.Name), false);
        if NpXmlDomMgt.GetXmlText(XmlElement, 'tableno', MaxStrLen(NcCollectorRequest.Name), false) <> '' then
            Evaluate(NcCollectorRequest."Table No.", NpXmlDomMgt.GetXmlText(XmlElement, 'tableno', MaxStrLen(NcCollectorRequest.Name), false), 9);
        NcCollectorRequest."Database Name" := NpXmlDomMgt.GetXmlText(XmlElement, 'senderdatabasename', MaxStrLen(NcCollectorRequest."Database Name"), false);
        NcCollectorRequest."Company Name" := NpXmlDomMgt.GetXmlText(XmlElement, 'sendercompany', MaxStrLen(NcCollectorRequest."Company Name"), false);
        NcCollectorRequest."User ID" := NpXmlDomMgt.GetXmlText(XmlElement, 'senderuserid', MaxStrLen(NcCollectorRequest."Company Name"), false);
        if NpXmlDomMgt.GetXmlText(XmlElement, 'OnlyNewandmodified', 0, false) = 'true' then
            NcCollectorRequest."Only New and Modified Records" := true;
        NcCollectorRequest.Insert(true);
    end;

    local procedure InsertCollectorRequestFilters(var NcCollectorRequestFilter: Record "NPR Nc Collector Req. Filter"): Boolean
    begin

        NcCollectorRequestFilter.Init();
    end;

    local procedure ReadCollectorRequestFilter(XmlElement: DotNet NPRNetXmlElement; Token: Text[100]; var NcCollectorRequestFilter: Record "NPR Nc Collector Req. Filter"; var NcCollectorRequest: Record "NPR Nc Collector Request")
    begin

        Initialize;

        Clear(NcCollectorRequestFilter);
        NcCollectorRequestFilter.Init();
        NcCollectorRequestFilter."Nc Collector Request No." := NcCollectorRequest."No.";
        Evaluate(NcCollectorRequestFilter."Table No.", NpXmlDomMgt.GetXmlText(XmlElement, 'tableno', 0, false), 9);
        Evaluate(NcCollectorRequestFilter."Field No.", NpXmlDomMgt.GetXmlText(XmlElement, 'fieldno', 0, false), 9);
        NcCollectorRequestFilter."Filter Text" := NpXmlDomMgt.GetXmlText(XmlElement, 'filtertext', MaxStrLen(NcCollectorRequestFilter."Filter Text"), false);
        NcCollectorRequestFilter.Insert(true);
    end;

    local procedure SetImportParameters(XmlElement: DotNet NPRNetXmlElement; Token: Text[100])
    begin
    end;

    local procedure FindCollectorRequest(VendorNo: Code[20]; VendorVATRegNo: Text; ItemNo: Code[20]; var ItemWorksheetTemplateCode: Code[20]; var ItemWorksheetCode: Code[20]; var ItemWorksheetLineNo: Integer)
    begin
    end;

    local procedure "--Utils"()
    begin
    end;

    procedure Initialize()
    begin

        if not Initialized then begin
            Initialized := true;
        end;
    end;

    local procedure GetWebserviceFunction(ImportTypeCode: Code[20]): Text[100]
    var
        ImportType: Record "NPR Nc Import Type";
    begin

        Clear(ImportType);
        ImportType.SetFilter(Code, '=%1', ImportTypeCode);
        if (ImportType.FindFirst()) then;

        exit(ImportType."Webservice Function");
    end;

    local procedure FindWorksheetVendorNio(VendorNo: Code[20])
    begin
    end;
}

