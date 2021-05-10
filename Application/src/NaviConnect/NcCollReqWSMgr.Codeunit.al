codeunit 6151533 "NPR Nc Coll. Req. WS Mgr"
{
    TableNo = "NPR Nc Import Entry";

    trigger OnRun()
    var
        XmlDoc: XmlDocument;
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

    local procedure CreateCollectorRequests(XmlDoc: XmlDocument; RequestEntryNo: Integer; DocumentID: Text[100])
    var
        Element: XmlElement;
        NodeList: XmlNodeList;
        Node: XmlNode;
        Token: Text[50];
    begin
        NodeList := XmlDoc.GetChildElements();
        if NodeList.Count = 0 then
            exit;

        XmlDoc.GetRoot(Element);
        if Element.IsEmpty then
            exit;

        if not NpXmlDomMgt.FindNodes(Element.AsXmlNode(), 'Createcollectorrequest', NodeList) then
            exit;

        if not NpXmlDomMgt.FindNodes(Element.AsXmlNode(), 'Collectorrequestimport', NodeList) then
            exit;

        if not NpXmlDomMgt.FindNodes(Element.AsXmlNode(), 'insertcollectorrequest', NodeList) then
            exit;

        NodeList.Get(0, Node);
        if not NpXmlDomMgt.FindNodes(Node, 'collectorrequest', NodeList) then
            exit;

        foreach Node in NodeList do
            CreateCollectorRequest(Node.AsXmlElement(), Token, DocumentID);

        Commit();
    end;

    local procedure CreateCollectorRequest(Element: XmlElement; Token: Text[100]; DocumentID: Text[100]): Boolean
    var
        NodeList: XmlNodeList;
        Node: XmlNode;
        NcCollectorRequest: Record "NPR Nc Collector Request";
    begin

        if Element.IsEmpty then
            exit(false);

        NcCollectorRequest.Init();

        ReadCollectorRequest(Element, Token, NcCollectorRequest);
        if NpXmlDomMgt.FindNodes(Element.AsXmlNode(), 'collectorrequestfilter', NodeList) then
            foreach Node in NodeList do
                CreateCollectorRequestFilter(Node.AsXmlElement(), Token, DocumentID, NcCollectorRequest);

        InsertCollectorRequests(NcCollectorRequest);

        exit(true);
    end;

    local procedure CreateCollectorRequestFilter(Element: XmlElement; Token: Text[100]; DocumentID: Text[100]; var NcCollectorRequest: Record "NPR Nc Collector Request"): Boolean
    var
        NcCollectorRequestFilter: Record "NPR Nc Collector Req. Filter";
    begin
        if Element.IsEmpty then
            exit(false);

        NcCollectorRequestFilter.Init();

        ReadCollectorRequestFilter(Element, Token, NcCollectorRequestFilter, NcCollectorRequest);
        InsertCollectorRequestFilters(NcCollectorRequestFilter);

        exit(true);
    end;

    local procedure InsertCollectorRequests(var NcCollectorRequest: Record "NPR Nc Collector Request"): Boolean
    begin
        NcCollectorRequest.Init();
    end;

    local procedure ReadCollectorRequest(Element: XmlElement; Token: Text[100]; var NcCollectorRequest: Record "NPR Nc Collector Request")
    begin
        Initialize();

        Clear(NcCollectorRequest);
        NcCollectorRequest.Init();
        NcCollectorRequest."Creation Date" := CurrentDateTime();
        if NpXmlDomMgt.GetXmlText(Element, 'no', MaxStrLen(NcCollectorRequest.Name), false) <> '' then
            Evaluate(NcCollectorRequest."External No.", NpXmlDomMgt.GetXmlText(Element, 'no', MaxStrLen(NcCollectorRequest.Name), false), 9);
        NcCollectorRequest.Name := NpXmlDomMgt.GetXmlText(Element, 'name', MaxStrLen(NcCollectorRequest.Name), false);
        if NpXmlDomMgt.GetXmlText(Element, 'tableno', MaxStrLen(NcCollectorRequest.Name), false) <> '' then
            Evaluate(NcCollectorRequest."Table No.", NpXmlDomMgt.GetXmlText(Element, 'tableno', MaxStrLen(NcCollectorRequest.Name), false), 9);
        NcCollectorRequest."Database Name" := NpXmlDomMgt.GetXmlText(Element, 'senderdatabasename', MaxStrLen(NcCollectorRequest."Database Name"), false);
        NcCollectorRequest."Company Name" := NpXmlDomMgt.GetXmlText(Element, 'sendercompany', MaxStrLen(NcCollectorRequest."Company Name"), false);
        NcCollectorRequest."User ID" := NpXmlDomMgt.GetXmlText(Element, 'senderuserid', MaxStrLen(NcCollectorRequest."Company Name"), false);
        if NpXmlDomMgt.GetXmlText(Element, 'OnlyNewandmodified', 0, false) = 'true' then
            NcCollectorRequest."Only New and Modified Records" := true;
        NcCollectorRequest.Insert(true);
    end;

    local procedure InsertCollectorRequestFilters(var NcCollectorRequestFilter: Record "NPR Nc Collector Req. Filter"): Boolean
    begin
        NcCollectorRequestFilter.Init();
    end;

    local procedure ReadCollectorRequestFilter(Element: XmlElement; Token: Text[100]; var NcCollectorRequestFilter: Record "NPR Nc Collector Req. Filter"; var NcCollectorRequest: Record "NPR Nc Collector Request")
    begin
        Initialize();

        Clear(NcCollectorRequestFilter);
        NcCollectorRequestFilter.Init();
        NcCollectorRequestFilter."Nc Collector Request No." := NcCollectorRequest."No.";
        Evaluate(NcCollectorRequestFilter."Table No.", NpXmlDomMgt.GetXmlText(Element, 'tableno', 0, false), 9);
        Evaluate(NcCollectorRequestFilter."Field No.", NpXmlDomMgt.GetXmlText(Element, 'fieldno', 0, false), 9);
        NcCollectorRequestFilter."Filter Text" := NpXmlDomMgt.GetXmlText(Element, 'filtertext', MaxStrLen(NcCollectorRequestFilter."Filter Text"), false);
        NcCollectorRequestFilter.Insert(true);
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
}

