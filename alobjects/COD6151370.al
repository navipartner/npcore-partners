codeunit 6151370 "CS Management"
{
    // NPR5.41/CLVA/20180313 CASE 306407 Object created - NP Capture Service
    // NPR5.43/NPKNAV/20180629  CASE 304872 Transport NPR5.43 - 29 June 2018

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        InboundDocument: DotNet npNetXmlDocument;
        OutboundDocument: DotNet npNetXmlDocument;

    procedure SendXMLReply(xmlout: DotNet npNetXmlDocument)
    begin
        OutboundDocument := xmlout;
    end;

    procedure SendError(ErrorString: Text[250])
    var
        XMLDOMMgt: Codeunit "XML DOM Management";
        RootNode: DotNet npNetXmlNode;
        Child: DotNet npNetXmlNode;
        ReturnedNode: DotNet npNetXmlNode;
    begin
        OutboundDocument := InboundDocument;

        // Error text
        Clear(XMLDOMMgt);
        RootNode := OutboundDocument.DocumentElement;

        if XMLDOMMgt.FindNode(RootNode,'Header',ReturnedNode) then begin
          if XMLDOMMgt.FindNode(RootNode,'Header/Input',Child) then
            ReturnedNode.RemoveChild(Child);
          if XMLDOMMgt.FindNode(RootNode,'Header/Comment',Child) then
            ReturnedNode.RemoveChild(Child);
          XMLDOMMgt.AddElement(ReturnedNode,'Comment',ErrorString,'',ReturnedNode);
        end;

        Clear(RootNode);
        Clear(Child);
    end;

    procedure ProcessDocument(Document: DotNet npNetXmlDocument)
    var
        CSUIManagement: Codeunit "CS UI Management";
    begin
        InboundDocument := Document;
        CSUIManagement.ReceiveXML(InboundDocument);
    end;

    procedure GetOutboundDocument(var Document: DotNet npNetXmlDocument)
    begin
        Document := OutboundDocument;
    end;
}

