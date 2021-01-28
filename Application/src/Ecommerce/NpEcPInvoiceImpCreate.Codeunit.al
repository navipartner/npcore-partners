codeunit 6151327 "NPR NpEc P.Invoice Imp. Create"
{
    TableNo = "NPR Nc Import Entry";

    trigger OnRun()
    var
        Document: XmlDocument;
    begin
        if Load(Rec, Document) then
            ImportPurchInvoices(Document);
    end;

    local procedure ImportPurchInvoices(Document: XmlDocument)
    var
        Element: XmlElement;
        NodeList: XmlNodeList;
        Node: XmlNode;
    begin
        if not Document.GetRoot(Element) then
            exit;

        if not Element.SelectNodes('//purchase_invoice', NodeList) then
            exit;

        foreach Node in NodeList do begin
            Element := Node.AsXmlElement();
            ImportPurchInvoice(Element);
        end;
    end;

    local procedure ImportPurchInvoice(Element: XmlElement): Boolean
    var
        PurchHeader: Record "Purchase Header";
        NpEcPurchDocImportMgt: Codeunit "NPR NpEc Purch.Doc.Import Mgt.";
    begin

        if NpEcPurchDocImportMgt.InvoiceExists(Element) then
            exit(false);

        NpEcPurchDocImportMgt.InsertInvoiceHeader(Element, PurchHeader);
        NpEcPurchDocImportMgt.InsertInvoiceLines(Element, PurchHeader);
        NpEcPurchDocImportMgt.InsertNote(Element, PurchHeader);

        exit(true);
    end;

    local procedure Load(var Rec: Record "NPR Nc Import Entry"; var Document: XmlDocument): Boolean
    var
        XmlDomMgt: Codeunit "XML DOM Management";
        InStr: InStream;
        DocumentSource: Text;
    begin
        Rec.CalcFields("Document Source");
        if not Rec."Document Source".HasValue() then
            exit(false);
        Rec."Document Source".CreateInStream(InStr);
        XmlDocument.ReadFrom(InStr, Document);
        Document.WriteTo(DocumentSource);
        DocumentSource := XmlDomMgt.RemoveNamespaces(DocumentSource);
        XmlDocument.ReadFrom(DocumentSource, Document);
        exit(true);
    end;
}

