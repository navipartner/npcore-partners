codeunit 6151327 "NPR NpEc P.Invoice Imp. Create"
{
    // NPR5.53/MHA /20191205  CASE 380837 Object created - NaviPartner General E-Commerce

    TableNo = "NPR Nc Import Entry";

    trigger OnRun()
    var
        XmlDoc: DotNet "NPRNetXmlDocument";
    begin
        if LoadXmlDoc(XmlDoc) then
            ImportPurchInvoices(XmlDoc);
    end;

    local procedure ImportPurchInvoices(XmlDoc: DotNet "NPRNetXmlDocument")
    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        XmlElement: DotNet NPRNetXmlElement;
        XmlNodeList: DotNet NPRNetXmlNodeList;
        i: Integer;
    begin
        if IsNull(XmlDoc) then
            exit;
        XmlElement := XmlDoc.DocumentElement;
        if IsNull(XmlElement) then
            exit;
        if not NpXmlDomMgt.FindNodes(XmlElement, 'purchase_invoice', XmlNodeList) then
            exit;
        for i := 0 to XmlNodeList.Count - 1 do begin
            XmlElement := XmlNodeList.ItemOf(i);
            ImportPurchInvoice(XmlElement);
        end;
    end;

    local procedure ImportPurchInvoice(XmlElement: DotNet NPRNetXmlElement) Imported: Boolean
    var
        PurchHeader: Record "Purchase Header";
        NpEcPurchDocImportMgt: Codeunit "NPR NpEc Purch.Doc.Import Mgt.";
    begin
        if IsNull(XmlElement) then
            exit(false);
        if NpEcPurchDocImportMgt.InvoiceExists(XmlElement) then
            exit(false);

        NpEcPurchDocImportMgt.InsertInvoiceHeader(XmlElement, PurchHeader);
        NpEcPurchDocImportMgt.InsertInvoiceLines(XmlElement, PurchHeader);
        NpEcPurchDocImportMgt.InsertNote(XmlElement, PurchHeader);

        exit(true);
    end;
}

