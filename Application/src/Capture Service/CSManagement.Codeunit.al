codeunit 6151370 "NPR CS Management"
{
    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        InboundDocument: XmlDocument;
        OutboundDocument: XmlDocument;

    [Obsolete('Use native Business Central objects instead of dotnet classes.', '')]
    procedure SendXMLReply(xmlout: DotNet "NPRNetXmlDocument")
    begin
        XmlDocument.ReadFrom(xmlout.OuterXml, OutboundDocument);
    end;

    procedure SendXMLReply(xmlout: XmlDocument)
    begin
        OutboundDocument := xmlout;
    end;

    procedure SendError(ErrorString: Text[250])
    var
        RootNode: XmlNode;
        RootElement: XmlElement;
        Child: XmlNode;
        ReturnedNode: XmlNode;
    begin
        OutboundDocument := InboundDocument;

        // Error text
        OutboundDocument.GetRoot(RootElement);

        if RootElement.SelectSingleNode('Header', ReturnedNode) then begin
            if RootElement.SelectSingleNode('Header/Input', Child) then
                Child.Remove();
            if RootElement.SelectSingleNode('Header/Comment', Child) then
                Child.Remove();
        end;
    end;

    [Obsolete('Use native Business Central objects instead of dotnet classes.', '')]
    procedure ProcessDocument(Document: DotNet "NPRNetXmlDocument")
    var
        CSUIManagement: Codeunit "NPR CS UI Management";
    begin
        XmlDocument.ReadFrom(Document.OuterXml, InboundDocument);
        CSUIManagement.ReceiveXML(InboundDocument);
    end;

    procedure ProcessDocument(Document: XmlDocument)
    var
        CSUIManagement: Codeunit "NPR CS UI Management";
    begin
        InboundDocument := Document;
        CSUIManagement.ReceiveXML(InboundDocument);
    end;

    [Obsolete('Use native Business Central objects instead of dotnet classes.', '')]
    procedure GetOutboundDocument(var Document: DotNet "NPRNetXmlDocument")
    var
        XmlText: Text;
    begin
        OutboundDocument.WriteTo(XmlText);
        Document := Document.XmlDocument();
        Document.LoadXml(XmlText);
    end;

    procedure GetOutboundDocument(var Document: XmlDocument)
    begin
        Document := OutboundDocument;
    end;
}

