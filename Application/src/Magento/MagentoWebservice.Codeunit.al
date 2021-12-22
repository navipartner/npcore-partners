codeunit 6151403 "NPR Magento Webservice"
{
    var
        Error001: Label 'Wrong key';
        Error002: Label 'Magento Integration has already been setup to %1';

    procedure GeneratePdfCreditMemo(DocumentNo: Code[20]; CustomerNo: Code[20]) PdfCrMemo: Text
    var
        ReportSelections: Record "Report Selections";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        RecRef: RecordRef;
    begin
        ReportSelections.SetRange(Usage, ReportSelections.Usage::"S.Cr.Memo");
        ReportSelections.SetFilter("Report ID", '<>%1', 0);
        ReportSelections.FindFirst();

        SalesCrMemoHeader.Get(DocumentNo);
        SalesCrMemoHeader.TestField("Bill-to Customer No.", CustomerNo);
        SalesCrMemoHeader.SetRecFilter();

        RecRef.GetTable(SalesCrMemoHeader);
        RecRef.SetRecFilter();
        PdfCrMemo := ReportToBase64(ReportSelections."Report ID", RecRef);

        exit(PdfCrMemo);
    end;

    procedure GeneratePdfOrder(DocumentNo: Code[20]; CustomerNo: Code[20]) PdfSalesOrder: Text
    var
        SalesHeader: Record "Sales Header";
        ReportSelections: Record "Report Selections";
        RecRef: RecordRef;
    begin
        ReportSelections.SetRange(Usage, ReportSelections.Usage::"S.Order");
        ReportSelections.SetFilter("Report ID", '<>%1', 0);
        ReportSelections.FindFirst();

        SalesHeader.Get(SalesHeader."Document Type"::Order, DocumentNo);
        SalesHeader.TestField("Bill-to Customer No.", CustomerNo);
        SalesHeader.SetRecFilter();

        RecRef.GetTable(SalesHeader);
        RecRef.SetRecFilter();
        PdfSalesOrder := ReportToBase64(ReportSelections."Report ID", RecRef);

        exit(PdfSalesOrder);
    end;

    procedure GeneratePdfInvoice(DocumentNo: Code[20]; CustomerNo: Code[20]) PdfSalesInvoice: Text
    var
        SalesInvHeader: Record "Sales Invoice Header";
        ReportSelections: Record "Report Selections";
        RecRef: RecordRef;
    begin
        ReportSelections.SetRange(Usage, ReportSelections.Usage::"S.Invoice");
        ReportSelections.SetFilter("Report ID", '<>%1', 0);
        ReportSelections.FindFirst();

        SalesInvHeader.Get(DocumentNo);
        SalesInvHeader.TestField("Bill-to Customer No.", CustomerNo);
        SalesInvHeader.SetRecFilter();

        RecRef.GetTable(SalesInvHeader);
        RecRef.SetRecFilter();
        PdfSalesInvoice := ReportToBase64(ReportSelections."Report ID", RecRef);

        exit(PdfSalesInvoice);
    end;

    procedure GeneratePdfCustomerStatement(CustomerNo: Code[20]; FromDate: Date; UntilDate: Date) PdfCustomerStatement: Text
    var
        ReportSelections: Record "Report Selections";
        Customer: Record Customer;
        RecRef: RecordRef;
    begin
        ReportSelections.SetRange(Usage, ReportSelections.Usage::"C.Statement");
        ReportSelections.SetFilter("Report ID", '<>%1', 0);
        ReportSelections.FindFirst();

        Customer.Get(CustomerNo);
        Customer.SetRecFilter();

        RecRef.GetTable(Customer);
        RecRef.SetRecFilter();
        PdfCustomerStatement := ReportToBase64(ReportSelections."Report ID", RecRef);

        exit(PdfCustomerStatement);
    end;

    procedure GeneratePdfShipment(DocumentNo: Code[20]; CustomerNo: Code[20]) PdfShipment: Text
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        ReportSelections: Record "Report Selections";
        RecRef: RecordRef;
    begin
        ReportSelections.SetRange(Usage, ReportSelections.Usage::"S.Shipment");
        ReportSelections.SetFilter("Report ID", '<>%1', 0);
        ReportSelections.FindFirst();

        SalesShipmentHeader.Get(DocumentNo);
        SalesShipmentHeader.TestField("Bill-to Customer No.", CustomerNo);
        SalesShipmentHeader.SetRecFilter();

        RecRef.GetTable(SalesShipmentHeader);
        RecRef.SetRecFilter();
        PdfShipment := ReportToBase64(ReportSelections."Report ID", RecRef);

        exit(PdfShipment);
    end;

    procedure GeneratePdfQuote(DocumentNo: Code[20]; CustomerNo: Code[20]) PdfQuote: Text
    var
        SalesHeader: Record "Sales Header";
        ReportSelections: Record "Report Selections";
        RecRef: RecordRef;
    begin
        ReportSelections.SetRange(Usage, ReportSelections.Usage::"S.Quote");
        ReportSelections.SetFilter("Report ID", '<>%1', 0);
        ReportSelections.FindFirst();

        SalesHeader.Get(SalesHeader."Document Type"::Quote, DocumentNo);
        SalesHeader.TestField("Bill-to Customer No.", CustomerNo);
        SalesHeader.SetRecFilter();

        RecRef.GetTable(SalesHeader);
        RecRef.SetRecFilter();
        PdfQuote := ReportToBase64(ReportSelections."Report ID", RecRef);

        exit(PdfQuote);
    end;

    procedure GetInvoices(CustomerNo: Code[20]; StartDate: Date; EndDate: Date; var documents: XMLport "NPR Magento Document Export")
    begin
        documents.SetFilters(CustomerNo, '', StartDate, EndDate, false, true, false, false, false);
    end;

    procedure GetCrMemos(CustomerNo: Code[20]; StartDate: Date; EndDate: Date; var documents: XMLport "NPR Magento Document Export")
    begin
        documents.SetFilters(CustomerNo, '', StartDate, EndDate, false, false, true, false, false);
    end;

    procedure GetOrders(CustomerNo: Code[20]; StartDate: Date; EndDate: Date; var documents: XMLport "NPR Magento Document Export")
    begin
        documents.SetFilters(CustomerNo, '', StartDate, EndDate, false, false, false, true, false);
    end;

    procedure GetShipments(CustomerNo: Code[20]; StartDate: Date; EndDate: Date; var documents: XMLport "NPR Magento Document Export")
    begin
        documents.SetFilters(CustomerNo, '', StartDate, EndDate, false, false, false, false, true);
    end;

    procedure GetQuotes(CustomerNo: Code[20]; StartDate: Date; EndDate: Date; var documents: XMLport "NPR Magento Document Export")
    begin
        documents.SetQuoteFilter(CustomerNo, '', StartDate, EndDate, false);
    end;

    procedure ListInvoices(CustomerNo: Code[20]; StartDate: Date; EndDate: Date; var documents: XMLport "NPR Magento Document Export")
    begin
        documents.SetFilters(CustomerNo, '', StartDate, EndDate, true, true, false, false, false);
    end;

    procedure ListCrMemos(CustomerNo: Code[20]; StartDate: Date; EndDate: Date; var documents: XMLport "NPR Magento Document Export")
    begin
        documents.SetFilters(CustomerNo, '', StartDate, EndDate, true, false, true, false, false);
    end;

    procedure ListOrders(CustomerNo: Code[20]; StartDate: Date; EndDate: Date; var documents: XMLport "NPR Magento Document Export")
    begin
        documents.SetFilters(CustomerNo, '', StartDate, EndDate, true, false, false, true, false);
    end;

    procedure ListShipments(CustomerNo: Code[20]; StartDate: Date; EndDate: Date; var documents: XMLport "NPR Magento Document Export")
    begin
        documents.SetFilters(CustomerNo, '', StartDate, EndDate, true, false, false, false, true);
    end;

    procedure ListQuotes(CustomerNo: Code[20]; StartDate: Date; EndDate: Date; var documents: XMLport "NPR Magento Document Export")
    begin
        documents.SetQuoteFilter(CustomerNo, '', StartDate, EndDate, true);
    end;

    procedure GetInvoice(CustomerNo: Code[20]; DocumentNumber: Code[20]; var documents: XMLport "NPR Magento Document Export")
    begin
        documents.SetFilters(CustomerNo, DocumentNumber, 0D, DMY2Date(31, 12, 9999), false, true, false, false, false);
    end;

    procedure GetCrMemo(CustomerNo: Code[20]; DocumentNumber: Code[20]; var documents: XMLport "NPR Magento Document Export")
    begin
        documents.SetFilters(CustomerNo, DocumentNumber, 0D, DMY2Date(31, 12, 9999), false, false, true, false, false);
    end;

    procedure GetOrder(CustomerNo: Code[20]; DocumentNumber: Code[20]; var documents: XMLport "NPR Magento Document Export")
    begin
        documents.SetFilters(CustomerNo, DocumentNumber, 0D, DMY2Date(31, 12, 9999), false, false, false, true, false);
    end;

    procedure GetShipment(CustomerNo: Code[20]; DocumentNumber: Code[20]; var documents: XMLport "NPR Magento Document Export")
    begin
        documents.SetFilters(CustomerNo, DocumentNumber, 0D, DMY2Date(31, 12, 9999), false, false, false, false, true);
    end;

    procedure GetQuote(CustomerNo: Code[20]; DocumentNumber: Code[20]; var documents: XMLport "NPR Magento Document Export")
    begin
        documents.SetQuoteFilter(CustomerNo, DocumentNumber, 0D, DMY2Date(31, 12, 9999), false);
    end;

    procedure GetItemInventory(itemFilter: Text; variantFilter: Text; locationFilter: Text; var items: XMLport "NPR Magento Avail. Inv. Exp.")
    begin
        Clear(items);
        items.SetFilters(itemFilter, variantFilter, locationFilter);
    end;

    procedure GetItemInventorySet(var retail_inventory_api: XMLport "NPR Magento Inv. Set Api")
    begin
        retail_inventory_api.Import();
    end;

    procedure GetStoreInventory(var store_inventory: XMLport "NPR Magento Store Inv.")
    begin
        store_inventory.Import();
    end;

    procedure GetCustomerNo(OrderNo: Code[20]) CustomerNo: Text
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetFilter("NPR External Order No.", OrderNo);
        if SalesHeader.FindFirst() then
            CustomerNo := SalesHeader."Sell-to Customer No.";
        exit(CustomerNo);
    end;

    procedure GetCustomerAndContactNo(OrderNo: Code[20]; var CustomerNo: Code[20]; var ContactNo: Code[20]): Boolean
    var
        SalesHeader: Record "Sales Header";
    begin
        if (OrderNo = '') then
            exit(false);

        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetFilter("NPR External Order No.", OrderNo);
        if (not SalesHeader.FindFirst()) then
            exit(false);

        CustomerNo := SalesHeader."Sell-to Customer No.";
        ContactNo := SalesHeader."Sell-to Contact No.";
        exit(true);
    end;

    procedure GetItemImage(ItemNo: Code[20]; VariantCode: Code[10]; ImageType: Option ANY,BASE,SMALL,THUMBNAIL; var ImageName: Text[250]; var ImageDescription: Text[250]; var ImageBase64: Text): Boolean
    var
        MagentoPictureLink: Record "NPR Magento Picture Link";
        MagentoPicture: Record "NPR Magento Picture";
        Base64: Codeunit "Base64 Convert";
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        OutStr: OutStream;
    begin
        MagentoPictureLink.SetCurrentKey("Item No.", "Line No."); // No key on sorting
        MagentoPictureLink.SetFilter("Item No.", '=%1', ItemNo);
        MagentoPictureLink.SetFilter("Variant Value Code", '=%1', VariantCode);
        case (ImageType) of
            ImageType::BASE:
                MagentoPictureLink.SetFilter("Base Image", '=%1', true);
            ImageType::SMALL:
                MagentoPictureLink.SetFilter("Small Image", '=%1', true);
            ImageType::THUMBNAIL:
                MagentoPictureLink.SetFilter(Thumbnail, '=%1', true);
        end;
        if (not MagentoPictureLink.FindFirst()) then
            exit(false);

        MagentoPicture.SetFilter(Type, '=%1', MagentoPicture.Type::Item);
        MagentoPicture.SetFilter(Name, '=%1', MagentoPictureLink."Picture Name");
        if (not MagentoPicture.FindFirst()) then
            exit(false);

        if (not MagentoPicture.Image.HasValue()) then
            exit(false);

        TempBlob.CreateOutStream(OutStr);
        MagentoPicture.Image.ExportStream(OutStr);
        TempBlob.CreateInStream(InStr);
        ImageBase64 := Base64.ToBase64(InStr);

        ImageName := MagentoPicture.Name;
        ImageDescription := MagentoPictureLink."Short Text";
        exit(true);
    end;

    procedure ImportSalesOrders(var sales_orders: XMLport "NPR Magento Sales Order Import")
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
    begin
        sales_orders.Import();
        InsertImportEntry('ImportSalesOrders', ImportEntry);
        ImportEntry."Document Name" := 'Magento Order-' + sales_orders.GetWebsiteCode() + '-' + sales_orders.GetOrderNo() + '.xml';
        ImportEntry."Document Source".CreateOutStream(OutStr);
        sales_orders.SetDestination(OutStr);
        sales_orders.Export();
        ImportEntry.Modify(true);
        Commit();

        NaviConnectSyncMgt.ProcessImportEntry(ImportEntry);
    end;

    procedure ImportSalesReturnOrders(var sales_return_orders: XMLport "NPR Magento Ret. Order Import")
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NcSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
    begin
        sales_return_orders.Import();
        InsertImportEntry('ImportSalesReturnOrders', ImportEntry);
        ImportEntry."Document Name" := 'Magento Return Order-' + sales_return_orders.GetReturnOrderNo() + '.xml';
        ImportEntry."Document Source".CreateOutStream(OutStr);
        sales_return_orders.SetDestination(OutStr);
        sales_return_orders.Export();
        ImportEntry.Modify(true);
        Commit();

        NcSyncMgt.ProcessImportEntry(ImportEntry);
    end;

    local procedure InsertImportEntry(WebserviceFunction: Text; var ImportEntry: Record "NPR Nc Import Entry")
    var
        NaviConnectSetupMgt: Codeunit "NPR Nc Setup Mgt.";
    begin
        ImportEntry.Init();
        ImportEntry."Entry No." := 0;
        ImportEntry."Import Type" := NaviConnectSetupMgt.GetImportTypeCode(CODEUNIT::"NPR Magento Webservice", WebserviceFunction);
        ImportEntry.Date := CurrentDateTime;
        ImportEntry."Document Name" := ImportEntry."Import Type" + '-' + Format(ImportEntry.Date, 0, 9) + '.xml';
        ImportEntry.Imported := false;
        ImportEntry."Runtime Error" := true;
        ImportEntry.Insert(true);
    end;

    procedure InitSetup(MagentoUrl: Text; Hash: Text): Text
    var
        MagentoSetup: Record "NPR Magento Setup";
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
        NaviConnectSetupMgt: Codeunit "NPR Nc Setup Mgt.";
        CryptographyManagement: Codeunit "Cryptography Management";
    begin
        if LowerCase(Hash) <> LowerCase(CryptographyManagement.GenerateHash(MagentoUrl + 'D3W7k5pd7Pn64ctn25ng91ZkSvyDnjo2', 0)) then
            Error(Error001);

        if not MagentoSetup.Get() then
            MagentoSetup.Insert();
        if (MagentoSetup."Magento Url" <> '') and (MagentoSetup."Magento Url" <> MagentoUrl) then
            Error(Error002, MagentoSetup."Magento Url");

        MagentoSetup.AuthType := MagentoSetup.AuthType::Basic;

        MagentoSetup.Validate("Magento Url", MagentoUrl);
        MagentoSetup."Magento Enabled" := true;
        MagentoSetup."Brands Enabled" := true;
        MagentoSetup."Attributes Enabled" := true;
        MagentoSetup."Product Relations Enabled" := true;
        MagentoSetup."Special Prices Enabled" := true;
        MagentoSetup.Modify(true);

        NaviConnectSetupMgt.InitNaviConnectSetup();

        MagentoSetupMgt.SetupImportTypes();
        Commit();
        NaviConnectSetupMgt.SetupTaskQueue();
        Commit();

        MagentoSetupMgt.TriggerSetupNpXmlTemplates();
        Commit();
        MagentoSetupMgt.SetupVATBusinessPostingGroups();
        MagentoSetupMgt.SetupVATProductPostingGroups();
        Commit();
        MagentoSetupMgt.TriggerSetupMagentoCredentials();
        MagentoSetupMgt.TriggerSetupMagentoWebsites();
        MagentoSetupMgt.TriggerSetupMagentoTaxClasses();
        MagentoSetupMgt.TriggerSetupMagentoCustomerGroups();
        MagentoSetupMgt.TriggerSetupPaymentMethodMapping();
        MagentoSetupMgt.TriggerSetupShipmentMethodMapping();
    end;

    procedure UpdateCategories()
    var
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
    begin
        MagentoSetupMgt.TriggerSetupCategories();
    end;

    procedure UpdateBrands()
    var
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
    begin
        MagentoSetupMgt.TriggerSetupBrands();
    end;

    local procedure ReportToBase64(ReportID: Integer; RecRef: RecordRef): Text
    var
        Base64Codeunit: Codeunit "Base64 Convert";
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        InStr: InStream;
    begin
        TempBlob.CreateOutStream(OutStr, TEXTENCODING::UTF8);
        Report.SaveAs(ReportID, '', ReportFormat::Pdf, OutStr, RecRef);
        TempBlob.CreateInStream(InStr, TEXTENCODING::UTF8);

        exit(Base64Codeunit.ToBase64(InStr));
    end;
}