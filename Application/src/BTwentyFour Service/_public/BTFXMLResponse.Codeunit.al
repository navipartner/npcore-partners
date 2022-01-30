codeunit 6014646 "NPR BTF XML Response" implements "NPR BTF IFormatResponse"
{
    var
        NoBodyReturnedLbl: Label 'No body returned';

    procedure FormatInternalError(ErrorCode: Text; ErrorDescription: Text; var Result: Codeunit "Temp Blob")
    var
        Document: XmlDocument;
        Node: XmlNode;
        ChildNode: XmlNode;
        Xml: Text;
        OutStr: OutStream;
    begin
        Document := XmlDocument.Create();
        Document.SetDeclaration(XmlDeclaration.Create('1.0', 'UTF-8', 'yes'));
        Node := XmlElement.Create('root').AsXmlNode();
        Document.Add(Node);

        ChildNode := XmlElement.Create('error', '', ErrorCode).AsXmlNode();
        Node.AsXmlElement().Add(ChildNode);

        ChildNode := XmlElement.Create('error_description', '', ErrorDescription).AsXmlNode();
        Node.AsXmlElement().Add(ChildNode);

        Document.WriteTo(Xml);

        Result.CreateOutStream(OutStr);
        OutStr.WriteText(Xml);
    end;

    procedure FoundErrorInResponse(Response: Codeunit "Temp Blob"; StatusCode: Integer): Boolean;
    var
        Document: XmlDocument;
        Node: XmlNode;
        InStr: InStream;
    begin
        if StatusCode = 200 then
            exit;
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
            exit(NoBodyReturnedLbl);
        if Document.SelectSingleNode('.//exceptionMessage', Node) then
            exit(Node.AsXmlElement().InnerText());
        if Document.SelectSingleNode('.//error_description', Node) then
            exit(Node.AsXmlElement().InnerText());
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

    procedure GetOrder(Content: Codeunit "Temp Blob"; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"): Boolean
    var
        Handled: Boolean;
    begin
        OnProcessOrder(Content, SalesHeader, SalesLine, Handled);
        exit(Handled);
    end;

    procedure GetInvoice(Content: Codeunit "Temp Blob"; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"): Boolean
    var
        Handled: Boolean;
    begin
        OnProcessInvoice(Content, SalesHeader, SalesLine, Handled);
        exit(Handled);
    end;

    procedure GetOrderResp(Content: Codeunit "Temp Blob"; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"): Boolean
    var
        Handled: Boolean;
    begin
        OnProcessOrderResp(Content, SalesHeader, SalesLine, Handled);
        exit(Handled);
    end;

    procedure GetPriceCat(Content: Codeunit "Temp Blob"; var ItemWrks: Record "NPR Item Worksheet"; var ItemWrksLine: Record "NPR Item Worksheet Line"): Boolean
    var
        Handled: Boolean;
    begin
        OnProcessPriceCatalogue(Content, ItemWrks, ItemWrksLine, Handled);
        exit(Handled);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnProcessOrder(Content: Codeunit "Temp Blob"; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnProcessInvoice(Content: Codeunit "Temp Blob"; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnProcessOrderResp(Content: Codeunit "Temp Blob"; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnProcessPriceCatalogue(Content: Codeunit "Temp Blob"; var ItemWrks: Record "NPR Item Worksheet"; var ItemWrksLine: Record "NPR Item Worksheet Line"; var Handled: Boolean)
    begin
    end;
}
