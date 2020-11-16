codeunit 6151305 "NPR NpEc S.Order Imp. Delete"
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

    local procedure ImportSalesOrder(XmlElement: DotNet NPRNetXmlElement)
    var
        SalesHeader: Record "Sales Header";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        NpEcSalesDocImportMgt: Codeunit "NPR NpEc Sales Doc. Imp. Mgt.";
    begin
        if IsNull(XmlElement) then
            exit;
        if not NpEcSalesDocImportMgt.FindOrder(XmlElement, SalesHeader) then
            exit;

        SalesHeader.SetHideValidationDialog(true);
        SalesHeader.Delete(true);
    end;
}

