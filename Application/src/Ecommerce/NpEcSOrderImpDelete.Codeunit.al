﻿codeunit 6151305 "NPR NpEc S.Order Imp. Delete" implements "NPR Nc Import List IProcess"
{
    Access = Internal;
    TableNo = "NPR Nc Import Entry";

    trigger OnRun()
    begin
    end;

    internal procedure RunProcessImportEntry(ImportEntry: Record "NPR Nc Import Entry")
    var
        Document: XmlDocument;
    begin
        if Load(ImportEntry, Document) then
            ImportSalesOrders(Document);
    end;

    local procedure ImportSalesOrders(Document: XmlDocument)
    var
        Element: XmlElement;
        NodeList: XmlNodeList;
        Node: XmlNode;
    begin
        if not Document.GetRoot(Element) then
            exit;
        if not Element.SelectNodes('//sales_order', NodeList) then
            exit;

        foreach Node in NodeList do begin
            Element := Node.AsXmlElement();
            ImportSalesOrder(Element);
        end;
    end;

    local procedure ImportSalesOrder(Element: XmlElement)
    var
        SalesHeader: Record "Sales Header";
        NpEcSalesDocImportMgt: Codeunit "NPR NpEc Sales Doc. Imp. Mgt.";
    begin
        if not NpEcSalesDocImportMgt.FindOrder(Element, SalesHeader) then
            exit;

        SalesHeader.SetHideValidationDialog(true);
        SalesHeader.Delete(true);
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

