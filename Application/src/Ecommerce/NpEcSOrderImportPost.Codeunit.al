codeunit 6151304 "NPR NpEc S.Order Import (Post)"
{
    TableNo = "NPR Nc Import Entry";

    trigger OnRun()
    var
        Document: XmlDocument;
    begin
        if Load(Rec, Document) then
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
        SalesInvHeader: Record "Sales Invoice Header";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        NpEcSalesDocImportMgt: Codeunit "NPR NpEc Sales Doc. Imp. Mgt.";
    begin
        if NpEcSalesDocImportMgt.FindPostedInvoice(Element, SalesInvHeader) then
            exit;

        if NpEcSalesDocImportMgt.FindOrder(Element, SalesHeader) then begin
            SalesHeader.SetHideValidationDialog(not GuiAllowed);
            if SalesHeader.Status <> SalesHeader.Status::Open then
                ReleaseSalesDoc.PerformManualReopen(SalesHeader);

            NpEcSalesDocImportMgt.DeleteSalesLines(SalesHeader);
            NpEcSalesDocImportMgt.DeletePaymentLines(SalesHeader);
            NpEcSalesDocImportMgt.DeleteNotes(SalesHeader);

            NpEcSalesDocImportMgt.UpdateOrderHeader(Element, SalesHeader);
        end else
            NpEcSalesDocImportMgt.InsertOrderHeader(Element, SalesHeader);

        NpEcSalesDocImportMgt.InsertOrderLines(Element, SalesHeader);
        NpEcSalesDocImportMgt.InsertPaymentLines(Element, SalesHeader);
        NpEcSalesDocImportMgt.InsertNote(Element, SalesHeader);

        Commit();
        PostSalesOrder(SalesHeader);

        Commit();
        SendSalesInvoice(SalesHeader);
    end;

    local procedure PostSalesOrder(var SalesHeader: Record "Sales Header")
    begin
        SalesHeader.Ship := true;
        SalesHeader.Invoice := true;
        CODEUNIT.Run(CODEUNIT::"Sales-Post", SalesHeader);
    end;

    local procedure SendSalesInvoice(SalesHeader: Record "Sales Header")
    var
        SalesInvHeader: Record "Sales Invoice Header";
        DocSendProfile: Record "Document Sending Profile";
        CustomerVar: Record Customer;
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        DocSendProfile.GetDefaultForCustomer(SalesHeader."Bill-to Customer No.", DocSendProfile);
        if DocSendProfile."E-Mail" <> DocSendProfile."E-Mail"::No then begin
            SalesInvHeader.Get(SalesHeader."Last Posting No.");
            SalesInvHeader.SetRecFilter;
            EmailDocMgt.SendReport(SalesInvHeader, true);
        end;
    end;

    local procedure Load(Rec: Record "NPR Nc Import Entry"; var Document: XmlDocument): Boolean
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

