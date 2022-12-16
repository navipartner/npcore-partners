codeunit 6060019 "NPR OIOUBL Update Document"
{
    Access = Internal;

    Permissions = tabledata "Sales Invoice Header" = rm,
                  tabledata "Sales Cr.Memo Header" = rm,
                  tabledata "Service Invoice Header" = rm,
                  tabledata "Service Cr.Memo Header" = rm;

    procedure SalesInvoiceSetOIOUBLFieldsFromCustomer(SalesInvoiceHeader: Record "Sales Invoice Header")

    var
        UpdateDocument: Page "NPR OIOUBL Update Document";
        RecRef: RecordRef;
        OIOUBLGLN: Code[13];
    begin
        UpdateDocument.GetDocument(SalesInvoiceHeader."Bill-to Customer No.", true);
        if UpdateDocument.RunModal() = Action::Yes then begin
            UpdateDocument.SetDocument(SalesInvoiceHeader."VAT Registration No.", OIOUBLGLN, SalesInvoiceHeader."Payment Terms Code", SalesInvoiceHeader."Sell-to Contact");
            RecRef.GetTable(SalesInvoiceHeader);
            RecRef.Field(13630).Value := OIOUBLGLN;
            RecRef.SetTable(SalesInvoiceHeader);
            SalesInvoiceHeader.Modify(true);
        end;
    end;

    procedure SalesCrMemoSetOIOUBLFieldsFromCustomer(var SalesCrMemoHeader: Record "Sales Cr.Memo Header")

    var
        UpdateDocument: Page "NPR OIOUBL Update Document";
        RecRef: RecordRef;
        OIOUBLGLN: Code[13];
        PaymentTermsCode: Code[10];
    begin
        UpdateDocument.GetDocument(SalesCrMemoHeader."Bill-to Customer No.", false);
        if UpdateDocument.RunModal() = Action::Yes then begin
            UpdateDocument.SetDocument(SalesCrMemoHeader."VAT Registration No.", OIOUBLGLN, PaymentTermsCode, SalesCrMemoHeader."Sell-to Contact");
            RecRef.GetTable(SalesCrMemoHeader);
            RecRef.Field(13630).Value := OIOUBLGLN;
            RecRef.SetTable(SalesCrMemoHeader);
            SalesCrMemoHeader.Modify(true);
        end;
    end;

    procedure ServiceInvoiceSetOIOUBLFieldsFromCustomer(ServiceInvoiceHeader: Record "Service Invoice Header")

    var
        UpdateDocument: Page "NPR OIOUBL Update Document";
        RecRef: RecordRef;
        OIOUBLGLN: Code[13];

    begin
        UpdateDocument.GetDocument(ServiceInvoiceHeader."Bill-to Customer No.", true);
        if UpdateDocument.RunModal() = Action::Yes then begin
            UpdateDocument.SetDocument(ServiceInvoiceHeader."VAT Registration No.", OIOUBLGLN, ServiceInvoiceHeader."Payment Terms Code", ServiceInvoiceHeader."Contact Name");
            RecRef.GetTable(ServiceInvoiceHeader);
            RecRef.Field(13630).Value := OIOUBLGLN;
            RecRef.SetTable(ServiceInvoiceHeader);
            ServiceInvoiceHeader.Modify(true);
        end;
    end;

    procedure ServiceCrMemoSetOIOUBLFieldsFromCustomer(ServiceCrMemoHeader: Record "Service Cr.Memo Header")

    var
        UpdatePage: Page "NPR OIOUBL Update Document";
        RecRef: RecordRef;
        OIOUBLGLN: Code[13];
        PaymentTermsCode: Code[10];

    begin
        UpdatePage.GetDocument(ServiceCrMemoHeader."Bill-to Customer No.", false);
        if UpdatePage.RunModal() = Action::Yes then begin
            UpdatePage.SetDocument(ServiceCrMemoHeader."VAT Registration No.", OIOUBLGLN, PaymentTermsCode, ServiceCrMemoHeader."Contact Name");
            RecRef.GetTable(ServiceCrMemoHeader);
            RecRef.Field(13630).Value := OIOUBLGLN;
            RecRef.SetTable(ServiceCrMemoHeader);
            ServiceCrMemoHeader.Modify(true);
        end;
    end;
}
