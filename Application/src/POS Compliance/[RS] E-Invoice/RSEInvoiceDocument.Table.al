table 6150804 "NPR RS E-Invoice Document"
{
    Caption = 'RS E-Invoice Document';
    Access = Internal;
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR RS E-Invoice Documents";
    LookupPageId = "NPR RS E-Invoice Documents";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "Request ID"; Guid)
        {
            Caption = 'Request ID';
            DataClassification = CustomerContent;
        }
        field(3; "Sales Invoice ID"; Integer)
        {
            Caption = 'Sales Invoice ID';
            DataClassification = CustomerContent;
        }
        field(4; "Purchase Invoice ID"; Integer)
        {
            Caption = 'Purchase Invoice ID';
            DataClassification = CustomerContent;
        }
        field(5; "Invoice Type Code"; Enum "NPR RS EI Invoice Type Code")
        {
            Caption = 'Inovice Type Code';
            DataClassification = CustomerContent;
        }
        field(6; Direction; Option)
        {
            Caption = 'Direction';
            OptionCaption = 'Incoming,Outgoing';
            OptionMembers = Incoming,Outgoing;
            DataClassification = CustomerContent;
        }
        field(7; "Document Type"; Enum "NPR RS EI Document Type")
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
        }
        field(8; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(9; "Invoice Document No."; Code[35])
        {
            Caption = 'Invoice Document No.';
            DataClassification = CustomerContent;
        }
        field(10; "Invoice Status"; Enum "NPR RS E-Invoice Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
        field(11; "Creation Date"; Date)
        {
            Caption = 'Creation Date';
            DataClassification = CustomerContent;
        }
        field(12; "Sending Date"; Date)
        {
            Caption = 'Sending Date';
            DataClassification = CustomerContent;
        }
        field(13; "Request Content"; Media)
        {
            Caption = 'Request Content';
            DataClassification = CustomerContent;
        }
        field(14; "Response Content"; Media)
        {
            Caption = 'Response Content';
            DataClassification = CustomerContent;
        }
        field(15; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
        }
        field(16; "Supplier No."; Code[20])
        {
            Caption = 'Supplier No.';
            DataClassification = CustomerContent;
        }
        field(17; "Supplier Name"; Text[100])
        {
            Caption = 'Supplier Name';
            DataClassification = CustomerContent;
        }
        field(18; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
        }
        field(19; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            DataClassification = CustomerContent;
        }
        field(20; Created; Boolean)
        {
            Caption = 'Created';
            DataClassification = CustomerContent;
        }
        field(21; Posted; Boolean)
        {
            Caption = 'Posted';
            DataClassification = CustomerContent;
        }
        field(22; "CIR Invoice"; Boolean)
        {
            Caption = 'CIR Invoice';
            DataClassification = CustomerContent;
        }
        field(23; Prepayment; Boolean)
        {
            Caption = 'Prepayment';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    var
        XPathExcludeNamespacePatternLbl: Label '//*[local-name()=''%1'']', Locked = true, Comment = '%1 = Element Name';

    internal procedure GetLastEntryNo(): Integer;
    var
        FindRecordManagement: Codeunit "Find Record Management";
    begin
        exit(FindRecordManagement.GetLastEntryIntFieldValue(Rec, FieldNo("Entry No.")))
    end;

    internal procedure SetRequestContent(RequestText: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        OutStream: OutStream;
    begin
        if "Request Content".HasValue() then
            RSEInvoiceMgt.ClearTenantMedia("Request Content".MediaId);

        TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(RequestText);
        TempBlob.CreateInStream(InStream, TextEncoding::UTF8);
        "Request Content".ImportStream(InStream, FieldCaption("Request Content"));
    end;

    internal procedure GetRequestContent() RequestText: Text;
    var
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        OutStream: OutStream;
        RequestTextLine: Text;
    begin
        TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        "Request Content".ExportStream(OutStream);
        TempBlob.CreateInStream(InStream, TextEncoding::UTF8);
        while not InStream.EOS do begin
            InStream.ReadText(RequestTextLine);
            RequestText += RequestTextLine;
        end;
    end;

    internal procedure SetResponseContent(ResponseText: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        OutStream: OutStream;
    begin
        if "Response Content".HasValue() then
            RSEInvoiceMgt.ClearTenantMedia("Response Content".MediaId);

        TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(ResponseText);
        TempBlob.CreateInStream(InStream, TextEncoding::UTF8);
        "Response Content".ImportStream(InStream, FieldCaption("Response Content"));
    end;

    internal procedure GetResponseContent() ResponseText: Text;
    var
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        OutStream: OutStream;
        ResponseTextLine: Text;
    begin
        TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        "Response Content".ExportStream(OutStream);
        TempBlob.CreateInStream(InStream, TextEncoding::UTF8);
        while not InStream.EOS do begin
            InStream.ReadText(ResponseTextLine);
            ResponseText += ResponseTextLine;
        end;
    end;

    internal procedure GetDocumentPdfBase64(var DocumentPdfBaseValue: Text): Boolean
    var
        Document: XmlDocument;
        DocumentHeaderNode: XmlNode;
        HelperDocHeaderNode: XmlNode;
        DocumentContent: Text;
    begin
        if Rec.Direction in [Rec.Direction::Outgoing] then
            DocumentContent := GetRequestContent()
        else
            DocumentContent := GetResponseContent();

        XmlDocument.ReadFrom(DocumentContent, Document);

        Document.GetChildElements().Get(1, DocumentHeaderNode);

        if DocumentHeaderNode.SelectSingleNode(StrSubstNo(XPathExcludeNamespacePatternLbl, 'DocumentPdf'), HelperDocHeaderNode) then begin
            DocumentPdfBaseValue := HelperDocHeaderNode.AsXmlElement().InnerText();
            exit(true);
        end;
        exit(false);
    end;

    internal procedure GetDocumentAttachmentsBase64(var AttachmentsText: List of [Text]): Boolean
    var
        Document: XmlDocument;
        InvoiceElement: XmlElement;
        DocumentBodyNode: XmlNode;
        AttachmentNodes: XmlNodeList;
        AttachmentNode: XmlNode;
        NamespaceManager: XmlNamespaceManager;
        DocumentContent: Text;
        AttachmentText: Text;
    begin
        if Rec.Direction in [Rec.Direction::Outgoing] then
            DocumentContent := GetRequestContent()
        else
            DocumentContent := GetResponseContent();

        XmlDocument.ReadFrom(DocumentContent, Document);
        NamespaceManager.NameTable(Document.NameTable());
        NamespaceManager.AddNamespace('cac', RSEInvoiceMgt.GetCacNamespace());
        NamespaceManager.AddNamespace('cec', RSEInvoiceMgt.GetCecNamespace());
        NamespaceManager.AddNamespace('cbc', RSEInvoiceMgt.GetCbcNamespace());

        Document.GetChildElements().Get(1, DocumentBodyNode);
        if not DocumentBodyNode.SelectSingleNode(StrSubstNo(XPathExcludeNamespacePatternLbl, 'Invoice'), DocumentBodyNode) then
            DocumentBodyNode.SelectSingleNode(StrSubstNo(XPathExcludeNamespacePatternLbl, 'CreditNote'), DocumentBodyNode);
        InvoiceElement := DocumentBodyNode.AsXmlElement();

        DocumentBodyNode.SelectNodes(StrSubstNo(XPathExcludeNamespacePatternLbl, 'AdditionalDocumentReference'), AttachmentNodes);

        foreach AttachmentNode in AttachmentNodes do begin
            RSEInvoiceMgt.GetTextValue(AttachmentText, AttachmentNode.AsXmlElement(), 'cac:Attachment/cbc:EmbeddedDocumentBinaryObject', NamespaceManager);
            AttachmentsText.Add(AttachmentText);
        end;

        exit(AttachmentsText.Count() > 0);
    end;

var
    RSEInvoiceMgt: Codeunit "NPR RS E-Invoice Mgt.";
#endif
}