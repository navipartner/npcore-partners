codeunit 6151303 "NPR NpEc S.Order Import Create"
{
    // NPR5.53/MHA /20191205  CASE 380837 Object created - NaviPartner General E-Commerce

    TableNo = "NPR Nc Import Entry";

    trigger OnRun()
    var
        XmlDoc: DotNet "NPRNetXmlDocument";
    begin
        if LoadXmlDoc(XmlDoc) then
            ImportSalesOrders(XmlDoc);
    end;

    local procedure ImportSalesOrders(XmlDoc: DotNet "NPRNetXmlDocument")
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
        if not NpXmlDomMgt.FindNodes(XmlElement, 'sales_order', XmlNodeList) then
            exit;
        for i := 0 to XmlNodeList.Count - 1 do begin
            XmlElement := XmlNodeList.ItemOf(i);
            ImportSalesOrder(XmlElement);
        end;
    end;

    local procedure ImportSalesOrder(XmlElement: DotNet NPRNetXmlElement) Imported: Boolean
    var
        MagentoSetup: Record "NPR Magento Setup";
        SalesHeader: Record "Sales Header";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        NpEcSalesDocImportMgt: Codeunit "NPR NpEc Sales Doc. Imp. Mgt.";
    begin
        if IsNull(XmlElement) then
            exit(false);
        if NpEcSalesDocImportMgt.OrderExists(XmlElement) then
            exit(false);

        NpEcSalesDocImportMgt.InsertOrderHeader(XmlElement, SalesHeader);
        NpEcSalesDocImportMgt.InsertOrderLines(XmlElement, SalesHeader);
        NpEcSalesDocImportMgt.InsertPaymentLines(XmlElement, SalesHeader);
        NpEcSalesDocImportMgt.InsertNote(XmlElement, SalesHeader);

        exit(true);
    end;
}

