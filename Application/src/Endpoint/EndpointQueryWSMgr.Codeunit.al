codeunit 6014673 "NPR Endpoint Query WS Mgr"
{
    TableNo = "NPR Nc Import Entry";

    trigger OnRun()
    var
        Document: XmlDocument;
        FunctionName: Text[100];
    begin

        if Load(Rec, Document) then begin
            FunctionName := GetWebserviceFunction(Rec."Import Type");
            case FunctionName of
                'Createendpointquery':
                    CreateEndpointQueries(Document);
                else
                    Error(MissingCaseErr, Rec."Import Type", FunctionName);
            end;

        end;
    end;

    var
        MissingCaseErr: Label 'No handler for %1 [%2].', Comment = '%1="NPR Nc Import Entry"."Import Type",%2="NPR Nc Import Entry"."Webservice Function"';

    local procedure CreateEndpointQueries(Document: XmlDocument)
    var
        Element: XmlElement;
        Node: XmlNode;
        NodeList: XmlNodeList;
        Declaration: XmlDeclaration;
        XPathExcludeNamespacePattern: Text;
    begin
        if not Document.GetRoot(Element) then
            exit;
        if not Document.GetDeclaration(Declaration) then
            XPathExcludeNamespacePattern := '//*[local-name()=''%1'']'
        else
            case Declaration.Version() of
                '1.0':
                    XPathExcludeNamespacePattern := '//*[local-name()=''%1'']';
                '2.0':
                    XPathExcludeNamespacePattern := '//*:%1';
            end;

        if not Element.SelectNodes(StrSubstNo(XPathExcludeNamespacePattern, 'Createendpointquery'), NodeList) then
            exit;
        if not Element.SelectNodes(StrSubstNo(XPathExcludeNamespacePattern, 'endpointqueryimport'), NodeList) then
            exit;
        if not Element.SelectNodes(StrSubstNo(XPathExcludeNamespacePattern, 'insertendpointquery'), NodeList) then
            exit;

        NodeList.Get(0, Node);
        Element := Node.AsXmlElement();

        if not Element.SelectNodes(StrSubstNo(XPathExcludeNamespacePattern, 'endpointquery'), NodeList) then
            exit;

        foreach Node in NodeList do begin
            Element := Node.AsXmlElement();
            CreateEndpointQuery(Element, XPathExcludeNamespacePattern);
        end;
    end;

    local procedure CreateEndpointQuery(Element: XmlElement; XPathExcludeNamespacePattern: Text)
    var
        EndpointQuery: Record "NPR Endpoint Query";
        Element2: XmlElement;
        Node: XmlNode;
        NodeList: XmlNodeList;
    begin
        ReadEndpointQuery(Element, EndpointQuery, XPathExcludeNamespacePattern);
        if not Element.SelectNodes(StrSubstNo(XPathExcludeNamespacePattern, 'endpointqueryfilter'), NodeList) then
            foreach Node in NodeList do begin
                Element := Node.AsXmlElement();
                CreateEndpointQueryFilter(Element2, EndpointQuery, XPathExcludeNamespacePattern);
            end;
        EndpointQuery.ProcessQuery();
    end;

    local procedure CreateEndpointQueryFilter(Element: XmlElement; EndpointQuery: Record "NPR Endpoint Query"; XPathExcludeNamespacePattern: Text)
    var
        EndpointQueryFilter: Record "NPR Endpoint Query Filter";
    begin
        ReadEndpointQueryFilter(Element, EndpointQueryFilter, EndpointQuery, XPathExcludeNamespacePattern);
    end;

    local procedure ReadEndpointQuery(Element: XmlElement; var EndpointQuery: Record "NPR Endpoint Query"; XPathExcludeNamespacePattern: Text)
    var
        Node: XmlNode;
        TableNoAsString: Text;
        NewAndModifiedRecs: Text;
    begin
        Clear(EndpointQuery);
        EndpointQuery.Init();

        EndpointQuery."Creation Date" := CurrentDateTime();

        if Element.SelectSingleNode(StrSubstNo(XPathExcludeNamespacePattern, 'no'), Node) then
            Evaluate(EndpointQuery."External No.", CopyStr(Node.AsXmlElement().InnerText(), 1, Maxstrlen(format(EndpointQuery."External No."))), 9);

        if Element.SelectSingleNode(StrSubstNo(XPathExcludeNamespacePattern, 'name'), Node) then
            EndpointQuery.Name := CopyStr(Node.AsXmlElement().InnerText(), MaxStrLen(EndpointQuery.Name));

        if Element.SelectSingleNode(StrSubstNo(XPathExcludeNamespacePattern, 'tableno'), Node) then begin
            TableNoAsString := Node.AsXmlElement().InnerText();
            if TableNoAsString <> '' then
                Evaluate(EndpointQuery."Table No.", TableNoAsString, 9);
        end;

        if Element.SelectSingleNode(StrSubstNo(XPathExcludeNamespacePattern, 'senderdatabasename'), Node) then
            EndpointQuery."Database Name" := CopyStr(Node.AsXmlElement().InnerText(), MaxStrLen(EndpointQuery."Database Name"));

        if Element.SelectSingleNode(StrSubstNo(XPathExcludeNamespacePattern, 'sendercompany'), Node) then
            EndpointQuery."Company Name" := CopyStr(Node.AsXmlElement().InnerText(), MaxStrLen(EndpointQuery."Company Name"));

        if Element.SelectSingleNode(StrSubstNo(XPathExcludeNamespacePattern, 'senderuserid'), Node) then
            EndpointQuery."User ID" := CopyStr(Node.AsXmlElement().InnerText(), MaxStrLen(EndpointQuery."User Id"));

        if Element.SelectSingleNode(StrSubstNo(XPathExcludeNamespacePattern, 'OnlyNewandmodified'), Node) then begin
            NewAndModifiedRecs := Node.AsXmlElement().InnerText();
            if NewAndModifiedRecs = 'true' then
                EndpointQuery."Only New and Modified Records" := true;
        end;

        EndpointQuery.Insert(true);
    end;

    local procedure ReadEndpointQueryFilter(Element: XmlElement; var EndpointQueryFilter: Record "NPR Endpoint Query Filter"; EndpointQuery: Record "NPR Endpoint Query"; XPathExcludeNamespacePattern: Text)
    var
        Node: XmlNode;
    begin
        EndpointQueryFilter."Endpoint Query No." := EndpointQuery."No.";
        if Element.SelectSingleNode(StrSubstNo(XPathExcludeNamespacePattern, 'tableno'), Node) then
            Evaluate(EndpointQueryFilter."Table No.", Node.AsXmlElement().InnerText(), 9);

        if Element.SelectSingleNode(StrSubstNo(XPathExcludeNamespacePattern, 'fieldno'), Node) then
            Evaluate(EndpointQueryFilter."Field No.", Node.AsXmlElement().InnerText(), 9);

        EndpointQueryFilter.Init();
        if Element.SelectSingleNode(StrSubstNo(XPathExcludeNamespacePattern, 'filtertext'), Node) then
            EndpointQueryFilter."Filter Text" := Node.AsXmlElement().InnerText();
        EndpointQueryFilter.Insert(true);
    end;

    local procedure GetWebserviceFunction(ImportTypeCode: Code[20]): Text
    var
        ImportType: Record "NPR Nc Import Type";
    begin
        ImportType.Code := ImportTypeCode;
        if ImportType.Find() then
            exit(ImportType."Webservice Function");
    end;

    procedure Load(var Rec: Record "NPR Nc Import Entry"; var Document: XmlDocument): Boolean
    var
        InStr: InStream;
    begin
        Rec.CalcFields("Document Source");
        if not Rec."Document Source".HasValue() then
            exit(false);

        Rec."Document Source".CreateInStream(InStr);
        exit(XmlDocument.ReadFrom(InStr, Document));
    end;
}

