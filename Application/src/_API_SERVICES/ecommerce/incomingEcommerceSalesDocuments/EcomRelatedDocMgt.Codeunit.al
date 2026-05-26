#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6151062 "NPR Ecom Related Doc Mgt"
{
    Access = Internal;

    internal procedure AddSalesHeader(var TempRelatedDocument: Record "NPR Ecom Related Document" temporary; SalesHeader: Record "Sales Header")
    var
        SalesOrderLbl: Label 'Sales Order';
        SalesReturnOrderLbl: Label 'Sales Return Order';
    begin
        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Order:
                AddRelatedDocument(TempRelatedDocument, SalesHeader.RecordId(), SalesOrderLbl, SalesHeader."No.");
            SalesHeader."Document Type"::"Return Order":
                AddRelatedDocument(TempRelatedDocument, SalesHeader.RecordId(), SalesReturnOrderLbl, SalesHeader."No.");
        end;
    end;

    internal procedure AddSalesInvoiceHeader(var TempRelatedDocument: Record "NPR Ecom Related Document" temporary; SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        PostedSalesInvoiceLbl: Label 'Posted Sales Invoice';
    begin
        AddRelatedDocument(TempRelatedDocument, SalesInvoiceHeader.RecordId(), PostedSalesInvoiceLbl, SalesInvoiceHeader."No.");
    end;

    internal procedure AddSalesCrMemoHeader(var TempRelatedDocument: Record "NPR Ecom Related Document" temporary; SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        PostedSalesCrMemoLbl: Label 'Posted Sales Credit Memo';
    begin
        AddRelatedDocument(TempRelatedDocument, SalesCrMemoHeader.RecordId(), PostedSalesCrMemoLbl, SalesCrMemoHeader."No.");
    end;

    internal procedure OpenRelatedDocument(RelatedDocument: Record "NPR Ecom Related Document" temporary)
    var
        PageManagement: Codeunit "Page Management";
        RecRef: RecordRef;
    begin
        if not RecRef.Get(RelatedDocument."Source Record Id") then
            exit;

        PageManagement.PageRun(RecRef);
    end;

    local procedure AddRelatedDocument(var TempRelatedDocument: Record "NPR Ecom Related Document" temporary; SourceRecordId: RecordId; DocumentType: Text; DocumentNo: Code[20])
    begin
        if RelatedDocumentExists(TempRelatedDocument, SourceRecordId) then
            exit;

        TempRelatedDocument.Init();
        TempRelatedDocument."Source Record Id" := SourceRecordId;
        TempRelatedDocument."Document Type" := CopyStr(DocumentType, 1, MaxStrLen(TempRelatedDocument."Document Type"));
        TempRelatedDocument."Document No." := DocumentNo;
        TempRelatedDocument.Insert();
    end;

    local procedure RelatedDocumentExists(var TempRelatedDocument: Record "NPR Ecom Related Document" temporary; SourceRecordId: RecordId): Boolean
    begin
        TempRelatedDocument.Reset();
        TempRelatedDocument.SetRange("Source Record Id", SourceRecordId);
        exit(not TempRelatedDocument.IsEmpty());
    end;

    internal procedure OpenRelatedSalesDocumentsFromEcomDoc(EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        TempRelatedDocument: Record "NPR Ecom Related Document" temporary;
        NoRelatedDocumentsErrorLbl: Label 'No related documents found for %1.', Comment = '%1 - external no. of ecom sales header';
    begin
        CollectRelatedSalesHeaders(TempRelatedDocument, EcomSalesHeader.SystemId);
        CollectRelatedSalesInvoiceHeaders(TempRelatedDocument, EcomSalesHeader.SystemId);
        CollectRelatedSalesCrMemoHeaders(TempRelatedDocument, EcomSalesHeader.SystemId);

        TempRelatedDocument.Reset();
        if TempRelatedDocument.IsEmpty() then
            Error(NoRelatedDocumentsErrorLbl, Format(EcomSalesHeader.RecordId));

        Page.RunModal(Page::"NPR Ecom Related Documents", TempRelatedDocument);
    end;

    local procedure CollectRelatedSalesHeaders(var TempRelatedDocument: Record "NPR Ecom Related Document" temporary; EcomSalesHeaderSystemId: Guid)
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.SetLoadFields("Document Type", "No.");
        SalesHeader.SetRange("NPR Inc Ecom Sale Id", EcomSalesHeaderSystemId);

        if SalesHeader.FindSet() then
            repeat
                AddSalesHeader(TempRelatedDocument, SalesHeader);
            until SalesHeader.Next() = 0;
    end;

    local procedure CollectRelatedSalesInvoiceHeaders(var TempRelatedDocument: Record "NPR Ecom Related Document" temporary; EcomSalesHeaderSystemId: Guid)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        SalesInvoiceHeader.SetLoadFields("No.");
        SalesInvoiceHeader.SetRange("NPR Inc Ecom Sale Id", EcomSalesHeaderSystemId);

        if SalesInvoiceHeader.FindSet() then
            repeat
                AddSalesInvoiceHeader(TempRelatedDocument, SalesInvoiceHeader);
            until SalesInvoiceHeader.Next() = 0;
    end;

    local procedure CollectRelatedSalesCrMemoHeaders(var TempRelatedDocument: Record "NPR Ecom Related Document" temporary; EcomSalesHeaderSystemId: Guid)
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        SalesCrMemoHeader.SetLoadFields("No.");
        SalesCrMemoHeader.SetRange("NPR Inc Ecom Sale Id", EcomSalesHeaderSystemId);

        if SalesCrMemoHeader.FindSet() then
            repeat
                AddSalesCrMemoHeader(TempRelatedDocument, SalesCrMemoHeader);
            until SalesCrMemoHeader.Next() = 0;
    end;
}
#endif