codeunit 6014646 "NPR BTF XML Response" implements "NPR BTF IFormatResponse"
{
    procedure FormatInternalError(ErrorCode: Text; ErrorDescription: Text; var Result: Codeunit "Temp Blob")
    var
        Document: XmlDocument;
        Node: XmlNode;
        ChildNode: XmlNode;
        Xml: Text;
        InStr: InStream;
        OutStr: OutStream;
    begin
        Document := XmlDocument.Create();
        Document.SetDeclaration(XmlDeclaration.Create('1.0', 'UTF-8', 'yes'));
        Node := XmlElement.Create('root').AsXmlNode();
        Document.Add(Node);

        ChildNode := XmlElement.Create('error', '', ErrorCode).AsXmlNode();
        Node.AsXmlElement.Add(ChildNode);

        ChildNode := XmlElement.Create('error_description', '', ErrorDescription).AsXmlNode();
        Node.AsXmlElement.Add(ChildNode);

        Document.WriteTo(Xml);

        Result.CreateOutStream(OutStr);
        OutStr.WriteText(Xml);
    end;

    procedure FoundErrorInResponse(Response: Codeunit "Temp Blob"): Boolean;
    var
        Document: XmlDocument;
        Node: XmlNode;
        InStr: InStream;
    begin
        Response.CreateInStream(InStr);
        if not XmlDocument.ReadFrom(InStr, Document) then
            exit(true);
        if (Document.SelectSingleNode('.//error', Node)) or (Document.SelectSingleNode('.//Error', Node)) then
            exit(true);
        if Document.SelectSingleNode('.//exceptionMessage', Node) then
            exit(true);
    end;

    procedure GetErrorDescription(Response: Codeunit "Temp Blob"): Text
    var
        Document: XmlDocument;
        Node: XmlNode;
        InStr: InStream;
    begin
        Response.CreateInStream(InStr);
        if not XmlDocument.ReadFrom(InStr, Document) then
            exit;
        if Document.SelectSingleNode('.//error_description', Node) then
            exit(Node.AsXmlElement().InnerText());
        if (not Document.SelectSingleNode('.//error', Node)) and (not Document.SelectSingleNode('.//Error', Node)) then
            exit;
        if Node.AsXmlElement().SelectSingleNode('.//message', Node) then
            exit(Node.AsXmlElement().InnerText());
        if Node.AsXmlElement().SelectSingleNode('.//Message', Node) then
            exit(Node.AsXmlElement().InnerText());
    end;


    [NonDebuggable]
    procedure GetToken(Response: Codeunit "Temp Blob"): Text
    var
        Document: XmlDocument;
        Element: XmlElement;
        Node: XmlNode;
        InStr: InStream;
    begin
        Response.CreateInStream(InStr);
        if not XmlDocument.ReadFrom(InStr, Document) then
            exit;
        if not Document.GetRoot(Element) then
            exit;
        if not Element.SelectSingleNode('.//access_token', Node) then
            exit;
        exit(Node.AsXmlElement().InnerText());
    end;

    procedure FoundToken(Response: Codeunit "Temp Blob"): Boolean
    var
        Document: XmlDocument;
        Element: XmlElement;
        Node: XmlNode;
        InStr: InStream;
    begin
        Response.CreateInStream(InStr);
        if not XmlDocument.ReadFrom(InStr, Document) then
            exit;
        if not Document.GetRoot(Element) then
            exit;
        exit(Element.SelectSingleNode('.//access_token', Node));
    end;

    procedure GetFileExtension(): Text
    begin
        exit('xml');
    end;

    procedure GetResourcesUri(Content: Codeunit "Temp Blob"; var ResourcesUri: List of [Text]): Boolean
    var
        Document: XmlDocument;
        Element: XmlElement;
        NodeList: XmlNodeList;
        Node: XmlNode;
        InStr: InStream;
    begin
        clear(ResourcesUri);
        Content.CreateInStream(InStr);
        if not XmlDocument.ReadFrom(InStr, Document) then
            exit;
        if not Document.GetRoot(Element) then
            exit;
        if not Element.SelectNodes('.//resourceUri', NodeList) then
            exit;
        foreach Node in NodeList do begin
            ResourcesUri.Add(Node.AsXmlElement().InnerText());
        end;
        exit(ResourcesUri.Count() <> 0);
    end;

    procedure GetDocument(Content: Codeunit "Temp Blob"; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"): Boolean
    var
        Document: XmlDocument;
        Node: XmlNode;
        Node2: XmlNode;
        NodeList: XmlNodeList;
        Element: XmlElement;
        InStr: InStream;
        XPath: Text;
        DocumentType: Text;
        LineParameter: Text;
    begin
        SalesHeader.DeleteAll();
        SalesLine.DeleteAll();

        Content.CreateInStream(InStr);
        if not XmlDocument.ReadFrom(InStr, Document) then
            exit;
        DocumentType := 'b24Order';
        XPath := '/order/documentReference[@documentType==''' + DocumentType + ''']/@id';
        Document.SelectSingleNode(XPath, Node);
        SalesHeader."No." := Node.AsXmlAttribute().Value();

        DocumentType := 'b24Order';
        XPath := '/order/documentReference[@documentType==''' + DocumentType + ''']/@date';
        Document.SelectSingleNode(XPath, Node);
        evaluate(SalesHeader."Posting Date", Node.AsXmlAttribute().Value());

        DocumentType := 'BuyerOrder';
        XPath := '/order/documentReference[@documentType==''' + DocumentType + ''']/@id';
        Document.SelectSingleNode(XPath, Node);
        SalesHeader."External Document No." := Node.AsXmlAttribute().Value();

        XPath := '/order/buyer/@gln';
        Document.SelectSingleNode(XPath, Node);
        SalesHeader."Sell-to Customer No." := Node.AsXmlAttribute().Value();

        XPath := '/order/item';
        Document.SelectNodes(XPath, NodeList);
        foreach Node in NodeList do begin
            Element := Node.AsXmlElement();

            SalesLine."Document No." := SalesHeader."No.";
            SalesLine."Line No." += 10000;
            SalesLine.Init();
            SalesLine.Type := SalesLine.Type::Item;

            Element.SelectSingleNode('/@id', Node2);
            SalesLine."No." := Node2.AsXmlAttribute().Value();

            Element.SelectSingleNode('/@quantity', Node2);
            evaluate(SalesLine.Quantity, Node2.AsXmlAttribute().Value(), 9);

            Element.SelectSingleNode('/@deliveryDate', Node2);
            evaluate(SalesLine."Shipment Date", Node2.AsXmlAttribute().Value(), 9);

            LineParameter := 'unitOfMeasure';
            XPath := './property[@name=''' + LineParameter + ''']';
            Element.SelectSingleNode(XPath, Node2);
            SalesLine."Unit of Measure Code" := Node2.AsXmlElement().InnerText();

            LineParameter := 'Supplier';
            XPath := './itemReference[@registry=''' + LineParameter + ''']';
            Element.SelectSingleNode(XPath, Node2);
            SalesLine."Item Reference No." := Node2.AsXmlElement().InnerText();

            LineParameter := 'netPrice';
            XPath := './price[@type=''' + LineParameter + ''']/@value';
            Element.SelectSingleNode(XPath, Node2);

            evaluate(SalesLine."Unit Price", Node2.AsXmlAttribute().Value(), 9);

            SalesLine.Insert();
        end;
    end;
}