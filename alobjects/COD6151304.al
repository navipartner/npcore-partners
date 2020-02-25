codeunit 6151304 "NpEc S.Order Import (Post)"
{
    // NPR5.53/MHA /20191205  CASE 380837 Object created - NaviPartner General E-Commerce

    TableNo = "Nc Import Entry";

    trigger OnRun()
    var
        XmlDoc: DotNet npNetXmlDocument;
    begin
        if LoadXmlDoc(XmlDoc) then
          ImportSalesOrders(XmlDoc);
    end;

    local procedure ImportSalesOrders(XmlDoc: DotNet npNetXmlDocument)
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
        if not NpXmlDomMgt.FindNodes(XmlElement,'sales_order',XmlNodeList) then
          exit;
        for i := 0 to XmlNodeList.Count - 1 do begin
          XmlElement := XmlNodeList.ItemOf(i);
          ImportSalesOrder(XmlElement);
        end;
    end;

    local procedure ImportSalesOrder(XmlElement: DotNet npNetXmlElement)
    var
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        NpEcSalesDocImportMgt: Codeunit "NpEc Sales Doc. Import Mgt.";
    begin
        if IsNull(XmlElement) then
          exit;

        if NpEcSalesDocImportMgt.FindPostedInvoice(XmlElement,SalesInvHeader) then
          exit;

        if NpEcSalesDocImportMgt.FindOrder(XmlElement,SalesHeader) then begin
          SalesHeader.SetHideValidationDialog(not GuiAllowed);
          if SalesHeader.Status <> SalesHeader.Status::Open then
            ReleaseSalesDoc.PerformManualReopen(SalesHeader);

          NpEcSalesDocImportMgt.DeleteSalesLines(SalesHeader);
          NpEcSalesDocImportMgt.DeletePaymentLines(SalesHeader);
          NpEcSalesDocImportMgt.DeleteNotes(SalesHeader);

          NpEcSalesDocImportMgt.UpdateOrderHeader(XmlElement,SalesHeader);
        end else
          NpEcSalesDocImportMgt.InsertOrderHeader(XmlElement,SalesHeader);

        NpEcSalesDocImportMgt.InsertOrderLines(XmlElement,SalesHeader);
        NpEcSalesDocImportMgt.InsertPaymentLines(XmlElement,SalesHeader);
        NpEcSalesDocImportMgt.InsertNote(XmlElement,SalesHeader);

        Commit;
        PostSalesOrder(SalesHeader);

        Commit;
        SendSalesInvoice(SalesHeader);
    end;

    local procedure PostSalesOrder(var SalesHeader: Record "Sales Header")
    begin
        SalesHeader.Ship := true;
        SalesHeader.Invoice := true;
        CODEUNIT.Run(CODEUNIT::"Sales-Post",SalesHeader);
    end;

    local procedure SendSalesInvoice(SalesHeader: Record "Sales Header")
    var
        SalesInvHeader: Record "Sales Invoice Header";
        EmailDocMgt: Codeunit "E-mail Document Management";
    begin
        case SalesHeader."Document Processing" of
          SalesHeader."Document Processing"::Email,SalesHeader."Document Processing"::PrintAndEmail:
            begin
              SalesInvHeader.Get(SalesHeader."Last Posting No.");
              SalesInvHeader.SetRecFilter;
              EmailDocMgt.SendReport(SalesInvHeader,true);
            end;
        end;
    end;
}

