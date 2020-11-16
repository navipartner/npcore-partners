codeunit 6151403 "NPR Magento Webservice"
{
    // MAG1.01/MHA /20150201  CASE 204133 Object Created - All Magento Webservices are exposed in this codeunit
    //                                 - NaviConnect References/Functions may be removed if [NC] is not installed
    // MAG1.10/MHA /20150319  CASE 207206 Added function InitSetup() which initiates Magento Integration Setup
    // MAG1.12/MHA /20150409  CASE 211036 Added update of ImportEntry depending on if Import was performed without error
    // MAG1.16/TS  /20150423  CASE 212103 Replaced hardcoded import codeunit with NaviConnect Setup Import Codeunit
    // MAG1.17/MHA /20150622  CASE 215533 Renamed codeunit from Magento NaviConnect Webservice
    //                                 Added Magento- and NpXmlSetup
    //                                 Added logging of error during import
    // MAG1.21/TTH /20151118  CASE 227358 Replacing Type option field with "Import type".
    // MAG1.22/MHA /20151202  CASE 227358 Added ImportType."Webservice Function" and function InsertImportEntry() for extensibility
    // MAG1.22/TS  /20151209  CASE 228917 Updated "Document Name" in ImportEntry()
    // MAG1.22/MHA /20160421  CASE 236917 Added function GetItemInventory()
    // MAG1.22/MHA /20160427  CASE 240212 Replaced deprecated function SetupNaviConnect() with corresponding sub functions
    // MAG2.00/MHA /20160525  CASE 242557 Magento Integration
    // MAG2.03/TS  /20170124  CASE 256345 Extending codeunit for Magento 2.0
    // MAG2.07/MHA /20170830  CASE 286943 Updated Magento Setup functions to support Setup Event Subscriptions in InitSetup()
    // MAG2.07/MHA /20170828  CASE 290144 Added function GeneratePdfOrder()
    // MAG2.08/MHA /20171025  CASE 292926 NpXml Templates made extensible and extensibility removed from Vat Setup
    // MAG2.12/MHA /20180425  CASE 309647 Added function ImportReturnOrders()
    // MAG2.15/MHA /20180807  CASE 322939 Added function GetItemInventorySet()
    // MAG2.17/MHA /20181012  CASE 331949 Removed GetItemInventorySet() as it is not yet ready for release
    // MAG2.18/MHA /20181122  CASE 322939 Added function GetItemInventorySet()
    // MAG2.20/TSA /20190404  CASE 351060 Added GetItemImage()
    // MAG2.20/TSA /20190408  CASE 345376 Refactored the document.setfilters functions, added documentnumber, and shipment
    // MAG2.20/TSA /20190408  CASE 345376 Added GetShipments()
    // MAG2.20/TSA /20190408  CASE 345376 Added Actions for Get<DocumentType> that take customer number, document number as argument
    // MAG2.20/TSA /20190408  CASE 345376 Added Actions for List<DocumentType>s that take customer as argument, but suppress the lines
    // MAG2.20/TSA /20190409  CASE 351590 Added Customer Statement as PDF
    // MAG2.20/TSA /20190424  CASE 345376 Added Shipment Statement as PDF
    // MAG2.22/MHA /20190711  CASE 361706 Removed explicit set of Magento."Variant System" in InitSetup()
    // MAG14.00.2.22/ALST/20190714 CASE 361943 removed call to standard object customization in GeneratePdfCustomerStatement()
    // MAG2.25/TSA /20200218  CASE 388058 Added Quotes to magento service
    // MAG2.25/TSA /20200320  CASE 396445 Added service GetCustomerAndContactNo()
    // MAG2.26/MHA /20200527  CASE 406741 Added function GetStoreInventory()
    // MAG2.26/MHA /20200527  CASE 404580 Added functions UpdateCategories(), UpdateBrands()


    trigger OnRun()
    begin
    end;

    var
        Error001: Label 'Wrong key';
        Error002: Label 'Magento Integration has already been setup to %1';

    procedure GeneratePdfCreditMemo(DocumentNo: Code[20]; CustomerNo: Code[20]) PdfCrMemo: Text
    var
        ReportSelections: Record "Report Selections";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        Filename: Text;
    begin
        ReportSelections.SetRange(Usage, ReportSelections.Usage::"S.Cr.Memo");
        ReportSelections.SetFilter("Report ID", '<>%1', 0);
        ReportSelections.FindFirst;

        SalesCrMemoHeader.Get(DocumentNo);
        SalesCrMemoHeader.TestField("Bill-to Customer No.", CustomerNo);
        SalesCrMemoHeader.SetRecFilter;

        Filename := TemporaryPath + 'CrMemo-' + DocumentNo + '.pdf';
        REPORT.SaveAsPdf(ReportSelections."Report ID", Filename, SalesCrMemoHeader);

        PdfCrMemo := GetBase64(Filename);
        if Erase(Filename) then;

        exit(PdfCrMemo);
    end;

    procedure GeneratePdfOrder(DocumentNo: Code[20]; CustomerNo: Code[20]) PdfSalesOrder: Text
    var
        SalesHeader: Record "Sales Header";
        ReportSelections: Record "Report Selections";
        Filename: Text;
    begin
        //-MAG2.07 [290144]
        ReportSelections.SetRange(Usage, ReportSelections.Usage::"S.Order");
        ReportSelections.SetFilter("Report ID", '<>%1', 0);
        ReportSelections.FindFirst;

        SalesHeader.Get(SalesHeader."Document Type"::Order, DocumentNo);
        SalesHeader.TestField("Bill-to Customer No.", CustomerNo);
        SalesHeader.SetRecFilter;

        Filename := TemporaryPath + 'order-' + DocumentNo + '.pdf';
        REPORT.SaveAsPdf(ReportSelections."Report ID", Filename, SalesHeader);

        PdfSalesOrder := GetBase64(Filename);
        if Erase(Filename) then;

        exit(PdfSalesOrder);
        //+MAG2.07 [290144]
    end;

    procedure GeneratePdfInvoice(DocumentNo: Code[20]; CustomerNo: Code[20]) PdfSalesInvoice: Text
    var
        SalesInvHeader: Record "Sales Invoice Header";
        ReportSelections: Record "Report Selections";
        Filename: Text;
    begin
        ReportSelections.SetRange(Usage, ReportSelections.Usage::"S.Invoice");
        ReportSelections.SetFilter("Report ID", '<>%1', 0);
        ReportSelections.FindFirst;

        SalesInvHeader.Get(DocumentNo);
        SalesInvHeader.TestField("Bill-to Customer No.", CustomerNo);
        SalesInvHeader.SetRecFilter;

        Filename := TemporaryPath + 'invoice-' + DocumentNo + '.pdf';
        REPORT.SaveAsPdf(ReportSelections."Report ID", Filename, SalesInvHeader);

        PdfSalesInvoice := GetBase64(Filename);
        if Erase(Filename) then;

        exit(PdfSalesInvoice);
    end;

    procedure GeneratePdfCustomerStatement(CustomerNo: Code[20]; FromDate: Date; UntilDate: Date) PdfCustomerStatement: Text
    var
        ReportSelections: Record "Report Selections";
        Filename: Text;
        Customer: Record Customer;
    begin

        //-MAG2.20 [351590]
        ReportSelections.SetRange(Usage, ReportSelections.Usage::"C.Statement");
        ReportSelections.SetFilter("Report ID", '<>%1', 0);
        ReportSelections.FindFirst();

        Customer.Get(CustomerNo);
        Customer.SetRecFilter();

        Filename := TemporaryPath + 'customerstatement-' + CustomerNo + '.pdf';

        REPORT.SaveAsPdf(ReportSelections."Report ID", Filename, Customer);

        PdfCustomerStatement := GetBase64(Filename);
        if Erase(Filename) then;

        exit(PdfCustomerStatement);
        //+MAG2.20 [351590]
    end;

    procedure GeneratePdfShipment(DocumentNo: Code[20]; CustomerNo: Code[20]) PdfShipment: Text
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        ReportSelections: Record "Report Selections";
        Filename: Text;
    begin

        //-MAG2.20 [345376]
        ReportSelections.SetRange(Usage, ReportSelections.Usage::"S.Shipment");
        ReportSelections.SetFilter("Report ID", '<>%1', 0);
        ReportSelections.FindFirst();

        SalesShipmentHeader.Get(DocumentNo);
        SalesShipmentHeader.TestField("Bill-to Customer No.", CustomerNo);
        SalesShipmentHeader.SetRecFilter;

        Filename := TemporaryPath + 'shipment-' + DocumentNo + '.pdf';
        REPORT.SaveAsPdf(ReportSelections."Report ID", Filename, SalesShipmentHeader);

        PdfShipment := GetBase64(Filename);
        if Erase(Filename) then;

        exit(PdfShipment);
        //+MAG2.20 [345376]
    end;

    procedure GeneratePdfQuote(DocumentNo: Code[20]; CustomerNo: Code[20]) PdfQuote: Text
    var
        SalesHeader: Record "Sales Header";
        ReportSelections: Record "Report Selections";
        Filename: Text;
    begin

        //-MAG2.25 [388058]
        ReportSelections.SetRange(Usage, ReportSelections.Usage::"S.Quote");
        ReportSelections.SetFilter("Report ID", '<>%1', 0);
        ReportSelections.FindFirst();

        SalesHeader.Get(SalesHeader."Document Type"::Quote, DocumentNo);
        SalesHeader.TestField("Bill-to Customer No.", CustomerNo);
        SalesHeader.SetRecFilter;

        Filename := TemporaryPath + 'quote-' + DocumentNo + '.pdf';
        REPORT.SaveAsPdf(ReportSelections."Report ID", Filename, SalesHeader);

        PdfQuote := GetBase64(Filename);
        if (Erase(Filename)) then;

        exit(PdfQuote);
        //+MAG2.25 [388058]
    end;

    procedure GetInvoices(CustomerNo: Code[20]; StartDate: Date; EndDate: Date; var documents: XMLport "NPR Magento Document Export")
    begin
        //-MAG2.20 [345376]
        documents.SetFilters(CustomerNo, '', StartDate, EndDate, false, true, false, false, false);
        //+MAG2.20 [345376]
    end;

    procedure GetCrMemos(CustomerNo: Code[20]; StartDate: Date; EndDate: Date; var documents: XMLport "NPR Magento Document Export")
    var
        XmlDoc: DotNet "NPRNetXmlDocument";
        XmlDocElement: DotNet NPRNetXmlElement;
        XmlElement: DotNet NPRNetXmlElement;
        XmlElement2: DotNet NPRNetXmlElement;
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        StartDate2: Date;
        EndDate2: Date;
    begin
        //-MAG2.20 [345376]
        documents.SetFilters(CustomerNo, '', StartDate, EndDate, false, false, true, false, false);
        //+MAG2.20 [345376]
    end;

    procedure GetOrders(CustomerNo: Code[20]; StartDate: Date; EndDate: Date; var documents: XMLport "NPR Magento Document Export")
    begin
        //-MAG2.20 [345376]
        documents.SetFilters(CustomerNo, '', StartDate, EndDate, false, false, false, true, false);
        //+MAG2.20 [345376]
    end;

    procedure GetShipments(CustomerNo: Code[20]; StartDate: Date; EndDate: Date; var documents: XMLport "NPR Magento Document Export")
    begin

        //-MAG2.20 [345376]
        documents.SetFilters(CustomerNo, '', StartDate, EndDate, false, false, false, false, true);
        //+MAG2.20 [345376]
    end;

    procedure GetQuotes(CustomerNo: Code[20]; StartDate: Date; EndDate: Date; var documents: XMLport "NPR Magento Document Export")
    begin

        //-MAG2.25 [388058]
        documents.SetQuoteFilter(CustomerNo, '', StartDate, EndDate, false);
        //+MAG2.25 [388058]
    end;

    procedure ListInvoices(CustomerNo: Code[20]; StartDate: Date; EndDate: Date; var documents: XMLport "NPR Magento Document Export")
    begin

        //-MAG2.20 [345376]
        documents.SetFilters(CustomerNo, '', StartDate, EndDate, true, true, false, false, false);
        //+MAG2.20 [345376]
    end;

    procedure ListCrMemos(CustomerNo: Code[20]; StartDate: Date; EndDate: Date; var documents: XMLport "NPR Magento Document Export")
    var
        XmlDoc: DotNet "NPRNetXmlDocument";
        XmlDocElement: DotNet NPRNetXmlElement;
        XmlElement: DotNet NPRNetXmlElement;
        XmlElement2: DotNet NPRNetXmlElement;
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        StartDate2: Date;
        EndDate2: Date;
    begin

        //-MAG2.20 [345376]
        documents.SetFilters(CustomerNo, '', StartDate, EndDate, true, false, true, false, false);
        //+MAG2.20 [345376]
    end;

    procedure ListOrders(CustomerNo: Code[20]; StartDate: Date; EndDate: Date; var documents: XMLport "NPR Magento Document Export")
    begin

        //-MAG2.20 [345376]
        documents.SetFilters(CustomerNo, '', StartDate, EndDate, true, false, false, true, false);
        //+MAG2.20 [345376]
    end;

    procedure ListShipments(CustomerNo: Code[20]; StartDate: Date; EndDate: Date; var documents: XMLport "NPR Magento Document Export")
    begin

        //-MAG2.20 [345376]
        documents.SetFilters(CustomerNo, '', StartDate, EndDate, true, false, false, false, true);
        //+MAG2.20 [345376]
    end;

    procedure ListQuotes(CustomerNo: Code[20]; StartDate: Date; EndDate: Date; var documents: XMLport "NPR Magento Document Export")
    begin

        //-MAG2.25 [388058]
        documents.SetQuoteFilter(CustomerNo, '', StartDate, EndDate, true);
        //+MAG2.25 [388058]
    end;

    procedure GetInvoice(CustomerNo: Code[20]; DocumentNumber: Code[20]; var documents: XMLport "NPR Magento Document Export")
    begin

        //-MAG2.20 [345376]
        documents.SetFilters(CustomerNo, DocumentNumber, 0D, DMY2Date(31, 12, 9999), false, true, false, false, false);
        //+MAG2.20 [345376]
    end;

    procedure GetCrMemo(CustomerNo: Code[20]; DocumentNumber: Code[20]; var documents: XMLport "NPR Magento Document Export")
    var
        XmlDoc: DotNet "NPRNetXmlDocument";
        XmlDocElement: DotNet NPRNetXmlElement;
        XmlElement: DotNet NPRNetXmlElement;
        XmlElement2: DotNet NPRNetXmlElement;
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        StartDate2: Date;
        EndDate2: Date;
    begin

        //-MAG2.20 [345376]
        documents.SetFilters(CustomerNo, DocumentNumber, 0D, DMY2Date(31, 12, 9999), false, false, true, false, false);
        //+MAG2.20 [345376]
    end;

    procedure GetOrder(CustomerNo: Code[20]; DocumentNumber: Code[20]; var documents: XMLport "NPR Magento Document Export")
    begin

        //-MAG2.20 [345376]
        documents.SetFilters(CustomerNo, DocumentNumber, 0D, DMY2Date(31, 12, 9999), false, false, false, true, false);
        //+MAG2.20 [345376]
    end;

    procedure GetShipment(CustomerNo: Code[20]; DocumentNumber: Code[20]; var documents: XMLport "NPR Magento Document Export")
    begin

        //-MAG2.20 [345376]
        documents.SetFilters(CustomerNo, DocumentNumber, 0D, DMY2Date(31, 12, 9999), false, false, false, false, true);
        //+MAG2.20 [345376]
    end;

    procedure GetQuote(CustomerNo: Code[20]; DocumentNumber: Code[20]; var documents: XMLport "NPR Magento Document Export")
    begin

        //-MAG2.25 [388058]
        documents.SetQuoteFilter(CustomerNo, DocumentNumber, 0D, DMY2Date(31, 12, 9999), false);
        //+MAG2.25 [388058]
    end;

    procedure GetItemInventory(itemFilter: Text; variantFilter: Text; locationFilter: Text; var items: XMLport "NPR Magento Avail. Inv. Exp.")
    begin
        Clear(items);
        items.SetFilters(itemFilter, variantFilter, locationFilter);
    end;

    procedure GetItemInventorySet(var retail_inventory_api: XMLport "NPR Magento Inv. Set Api")
    begin
        //-MAG2.17 [322939]
        retail_inventory_api.Import;
        //+MAG2.17 [322939]
    end;

    procedure GetStoreInventory(var store_inventory: XMLport "NPR Magento Store Inv.")
    begin
        //-MAG2.26 [406741]
        store_inventory.Import;
        //+MAG2.26 [406741]
    end;

    procedure GetCustomerNo(OrderNo: Code[20]) CustomerNo: Text
    var
        SalesHeader: Record "Sales Header";
    begin
        //-MAG2.03
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetFilter("NPR External Order No.", OrderNo);
        if SalesHeader.FindFirst then
            CustomerNo := SalesHeader."Sell-to Customer No.";
        exit(CustomerNo);
        //+MAG2.03
    end;

    procedure GetCustomerAndContactNo(OrderNo: Code[20]; var CustomerNo: Code[20]; var ContactNo: Code[20]): Boolean
    var
        SalesHeader: Record "Sales Header";
    begin
        //-MAG2.25 [396445]
        if (OrderNo = '') then
            exit(false);

        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetFilter("NPR External Order No.", OrderNo);
        if (not SalesHeader.FindFirst()) then
            exit(false);

        CustomerNo := SalesHeader."Sell-to Customer No.";
        ContactNo := SalesHeader."Sell-to Contact No.";
        exit(true);
        //+MAG2.25 [396445]
    end;

    procedure GetItemImage(ItemNo: Code[20]; VariantCode: Code[10]; ImageType: Option ANY,BASE,SMALL,THUMBNAIL; var ImageName: Text[250]; var ImageDescription: Text[250]; var ImageBase64: Text): Boolean
    var
        Item: Record Item;
        MagentoPictureLink: Record "NPR Magento Picture Link";
        MagentoPicture: Record "NPR Magento Picture";
        BinaryReader: DotNet NPRNetBinaryReader;
        MemoryStream: DotNet NPRNetMemoryStream;
        Convert: DotNet NPRNetConvert;
        InStr: InStream;
    begin

        //-MAG2.20 [351060]
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

        if (not MagentoPicture.Picture.HasValue()) then
            exit(false);

        MagentoPicture.CalcFields(Picture);
        MagentoPicture.Picture.CreateInStream(InStr);

        //Note: This will only work for on-prem
        MemoryStream := InStr;
        BinaryReader := BinaryReader.BinaryReader(InStr);
        ImageBase64 := Convert.ToBase64String(BinaryReader.ReadBytes(MemoryStream.Length));
        MemoryStream.Dispose();
        Clear(MemoryStream);

        ImageName := MagentoPicture.Name;
        ImageDescription := MagentoPictureLink."Short Text";
        exit(true);
        //+MAG2.20 [351060]
    end;

    procedure ImportSalesOrders(var sales_orders: XMLport "NPR Magento Sales Order Import")
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSalesOrderMgt: Codeunit "NPR Magento Sales Order Mgt.";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
    begin
        sales_orders.Import;
        InsertImportEntry('ImportSalesOrders', ImportEntry);
        ImportEntry."Document Name" := 'Magento Order-' + sales_orders.GetWebsiteCode() + '-' + sales_orders.GetOrderNo() + '.xml';
        ImportEntry."Document Source".CreateOutStream(OutStr);
        sales_orders.SetDestination(OutStr);
        sales_orders.Export;
        ImportEntry.Modify(true);
        Commit;

        NaviConnectSyncMgt.ProcessImportEntry(ImportEntry);
    end;

    procedure ImportSalesReturnOrders(var sales_return_orders: XMLport "NPR Magento Ret. Order Import")
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NcSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
    begin
        //-MAG2.12 [309647]
        sales_return_orders.Import;
        InsertImportEntry('ImportSalesReturnOrders', ImportEntry);
        ImportEntry."Document Name" := 'Magento Return Order-' + sales_return_orders.GetReturnOrderNo() + '.xml';
        ImportEntry."Document Source".CreateOutStream(OutStr);
        sales_return_orders.SetDestination(OutStr);
        sales_return_orders.Export;
        ImportEntry.Modify(true);
        Commit;

        NcSyncMgt.ProcessImportEntry(ImportEntry);
        //+MAG2.12 [309647]
    end;

    local procedure InsertImportEntry(WebserviceFunction: Text; var ImportEntry: Record "NPR Nc Import Entry")
    var
        NaviConnectSetupMgt: Codeunit "NPR Nc Setup Mgt.";
    begin
        ImportEntry.Init;
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
        NpXmlSetup: Record "NPR NpXml Setup";
        MagentoNpXmlSetupMgt: Codeunit "NPR Magento NpXml Setup Mgt";
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
        MagentoMgt: Codeunit "NPR Magento Mgt.";
        NaviConnectSetupMgt: Codeunit "NPR Nc Setup Mgt.";
        FormsAuthentication: DotNet NPRNetFormsAuthentication;
    begin
        if LowerCase(Hash) <> LowerCase(FormsAuthentication.HashPasswordForStoringInConfigFile(MagentoUrl + 'D3W7k5pd7Pn64ctn25ng91ZkSvyDnjo2', 'MD5')) then
            Error(Error001);

        if not MagentoSetup.Get then
            MagentoSetup.Insert;
        if (MagentoSetup."Magento Url" <> '') and (MagentoSetup."Magento Url" <> MagentoUrl) then
            Error(Error002, MagentoSetup."Magento Url");

        //-MAG2.00
        MagentoSetup."Api Username Type" := MagentoSetup."Api Username Type"::Automatic;
        //+MAG2.00

        MagentoSetup.Validate("Magento Url", MagentoUrl);
        MagentoSetup."Magento Enabled" := true;
        MagentoSetup."Brands Enabled" := true;
        MagentoSetup."Attributes Enabled" := true;
        MagentoSetup."Product Relations Enabled" := true;
        MagentoSetup."Special Prices Enabled" := true;
        //-MAG2.00
        MagentoSetup.Modify(true);
        //+MAG2.00

        NaviConnectSetupMgt.InitNaviConnectSetup();

        //-MAG2.00
        MagentoSetupMgt.SetupClientAddIns();
        Commit;
        MagentoSetupMgt.SetupImportTypes();
        //+MAG2.00
        Commit;
        NaviConnectSetupMgt.SetupTaskQueue();
        Commit;

        //-MAG2.08 [292926]
        MagentoSetupMgt.TriggerSetupNpXmlTemplates();
        //+MAG2.08 [292926]
        Commit;
        //-MAG2.07 [286943]
        //-MAG2.08 [292926]
        MagentoSetupMgt.SetupVATBusinessPostingGroups();
        MagentoSetupMgt.SetupVATProductPostingGroups();
        //+MAG2.08 [292926]
        Commit;
        MagentoSetupMgt.TriggerSetupMagentoCredentials();
        MagentoSetupMgt.TriggerSetupMagentoWebsites();
        MagentoSetupMgt.TriggerSetupMagentoTaxClasses();
        MagentoSetupMgt.TriggerSetupMagentoCustomerGroups();
        MagentoSetupMgt.TriggerSetupPaymentMethodMapping();
        MagentoSetupMgt.TriggerSetupShipmentMethodMapping();
        //+MAG2.07 [286943]
    end;

    procedure UpdateCategories()
    var
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
    begin
        //-MAG2.26 [404580]
        MagentoSetupMgt.TriggerSetupCategories();
        //+MAG2.26 [404580]
    end;

    procedure UpdateBrands()
    var
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
    begin
        //-MAG2.26 [404580]
        MagentoSetupMgt.TriggerSetupBrands();
        //+MAG2.26 [404580]
    end;

    local procedure "--- Aux"()
    begin
    end;

    local procedure GetBase64(Filename: Text) Value: Text
    var
        TempBlob: Codeunit "Temp Blob";
        BinaryReader: DotNet NPRNetBinaryReader;
        MemoryStream: DotNet NPRNetMemoryStream;
        Convert: DotNet NPRNetConvert;
        FieldRef: FieldRef;
        InStr: InStream;
        f: File;
    begin
        Value := '';

        f.Open(Filename);
        f.CreateInStream(InStr);
        MemoryStream := InStr;
        BinaryReader := BinaryReader.BinaryReader(InStr);

        Value := Convert.ToBase64String(BinaryReader.ReadBytes(MemoryStream.Length));

        MemoryStream.Dispose;
        Clear(MemoryStream);
        f.Close;
        exit(Value);
    end;
}

