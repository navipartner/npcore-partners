codeunit 6151327 "NpEc P.Invoice Import (Create)"
{
    // NPR5.53/MHA /20191205  CASE 380837 Object created - NaviPartner General E-Commerce

    TableNo = "Nc Import Entry";

    trigger OnRun()
    var
        XmlDoc: DotNet npNetXmlDocument;
    begin
        if LoadXmlDoc(XmlDoc) then
          ImportPurchInvoices(XmlDoc);
    end;

    local procedure ImportPurchInvoices(XmlDoc: DotNet npNetXmlDocument)
    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        XmlElement: DotNet npNetXmlElement;
        XmlNodeList: DotNet npNetXmlNodeList;
        i: Integer;
    begin
        if IsNull(XmlDoc) then
          exit;
        XmlElement := XmlDoc.DocumentElement;
        if IsNull(XmlElement) then
          exit;
        if not NpXmlDomMgt.FindNodes(XmlElement,'purchase_invoice',XmlNodeList) then
          exit;
        for i := 0 to XmlNodeList.Count - 1 do begin
          XmlElement := XmlNodeList.ItemOf(i);
          ImportPurchInvoice(XmlElement);
        end;
    end;

    local procedure ImportPurchInvoice(XmlElement: DotNet npNetXmlElement) Imported: Boolean
    var
        PurchHeader: Record "Purchase Header";
        NpEcPurchDocImportMgt: Codeunit "NpEc Purch. Doc. Import Mgt.";
    begin
        if IsNull(XmlElement) then
          exit(false);
        if NpEcPurchDocImportMgt.InvoiceExists(XmlElement) then
          exit(false);

        NpEcPurchDocImportMgt.InsertInvoiceHeader(XmlElement,PurchHeader);
        NpEcPurchDocImportMgt.InsertInvoiceLines(XmlElement,PurchHeader);
        NpEcPurchDocImportMgt.InsertNote(XmlElement,PurchHeader);

        exit(true);
    end;
}

