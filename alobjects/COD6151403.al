codeunit 6151403 "Magento Webservice"
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
    // MAG2.20/TSA /20190404 CASE 351060 Added GetItemImage()
    // MAG2.20/TSA /20190408 CASE 345376 Refactored the document.setfilters functions, added documentnumber, and shipment
    // MAG2.20/TSA /20190408 CASE 345376 Added GetShipments()
    // MAG2.20/TSA /20190408 CASE 345376 Added Actions for Get<DocumentType> that take customer number, document number as argument
    // MAG2.20/TSA /20190408 CASE 345376 Added Actions for List<DocumentType>s that take customer as argument, but suppress the lines
    // MAG2.20/TSA /20190409 CASE 351590 Added Customer Statement as PDF
    // MAG2.20/TSA /20190424 CASE 345376 Added Shipment Statement as PDF


    trigger OnRun()
    begin
    end;

    var
        Error001: Label 'Wrong key';
        Error002: Label 'Magento Integration has already been setup to %1';

    [Scope('Personalization')]
    procedure GeneratePdfCreditMemo(DocumentNo: Code[20];CustomerNo: Code[20]) PdfCrMemo: Text
    var
        ReportSelections: Record "Report Selections";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        Filename: Text;
    begin
        ReportSelections.SetRange(Usage,ReportSelections.Usage::"S.Cr.Memo");
        ReportSelections.SetFilter("Report ID",'<>%1',0);
        ReportSelections.FindFirst;

        SalesCrMemoHeader.Get(DocumentNo);
        SalesCrMemoHeader.TestField("Bill-to Customer No.",CustomerNo);
        SalesCrMemoHeader.SetRecFilter;

        Filename := TemporaryPath + 'CrMemo-' + DocumentNo + '.pdf';
        REPORT.SaveAsPdf(ReportSelections."Report ID",Filename,SalesCrMemoHeader);

        PdfCrMemo := GetBase64(Filename);
        if Erase(Filename) then;

        exit(PdfCrMemo);
    end;

    [Scope('Personalization')]
    procedure GeneratePdfOrder(DocumentNo: Code[20];CustomerNo: Code[20]) PdfSalesOrder: Text
    var
        SalesHeader: Record "Sales Header";
        ReportSelections: Record "Report Selections";
        Filename: Text;
    begin
        //-MAG2.07 [290144]
        ReportSelections.SetRange(Usage,ReportSelections.Usage::"S.Order");
        ReportSelections.SetFilter("Report ID",'<>%1',0);
        ReportSelections.FindFirst;

        SalesHeader.Get(SalesHeader."Document Type"::Order,DocumentNo);
        SalesHeader.TestField("Bill-to Customer No.",CustomerNo);
        SalesHeader.SetRecFilter;

        Filename := TemporaryPath + 'order-' + DocumentNo + '.pdf';
        REPORT.SaveAsPdf(ReportSelections."Report ID",Filename,SalesHeader);

        PdfSalesOrder := GetBase64(Filename);
        if Erase(Filename) then;

        exit(PdfSalesOrder);
        //+MAG2.07 [290144]
    end;

    [Scope('Personalization')]
    procedure GeneratePdfInvoice(DocumentNo: Code[20];CustomerNo: Code[20]) PdfSalesInvoice: Text
    var
        SalesInvHeader: Record "Sales Invoice Header";
        ReportSelections: Record "Report Selections";
        Filename: Text;
    begin
        ReportSelections.SetRange(Usage,ReportSelections.Usage::"S.Invoice");
        ReportSelections.SetFilter("Report ID",'<>%1',0);
        ReportSelections.FindFirst;

        SalesInvHeader.Get(DocumentNo);
        SalesInvHeader.TestField("Bill-to Customer No.",CustomerNo);
        SalesInvHeader.SetRecFilter;

        Filename := TemporaryPath + 'invoice-' + DocumentNo + '.pdf';
        REPORT.SaveAsPdf(ReportSelections."Report ID",Filename,SalesInvHeader);

        PdfSalesInvoice := GetBase64(Filename);
        if Erase(Filename) then;

        exit(PdfSalesInvoice);
    end;

    [Scope('Personalization')]
    procedure GeneratePdfCustomerStatement(CustomerNo: Code[20];FromDate: Date;UntilDate: Date) PdfCustomerStatement: Text
    var
        ReportSelections: Record "Report Selections";
        Filename: Text;
        Customer: Record Customer;
        CustomerStatement: Report Statement;
        AgingPeriodLength: DateFormula;
        DateChoice: Option "Due Date","Posting Date";
    begin

        //-MAG2.20 [351590]
        ReportSelections.SetRange (Usage,ReportSelections.Usage::"C.Statement");
        ReportSelections.SetFilter ("Report ID",'<>%1',0);
        ReportSelections.FindFirst ();

        Customer.Get (CustomerNo);
        Customer.SetRecFilter ();

        Filename := TemporaryPath + 'customerstatement-' + CustomerNo + '.pdf';

        if (ReportSelections."Report ID" = 116) then begin
          // Standard statement
          CustomerStatement.SetTableView (Customer);
          CustomerStatement.SetSettings (true, true, true, true, true, true, AgingPeriodLength, DateChoice::"Due Date", false, FromDate, UntilDate);
          CustomerStatement.SaveAsPdf (Filename);

        end else begin
          REPORT.SaveAsPdf (ReportSelections."Report ID", Filename, Customer);

        end;

        PdfCustomerStatement := GetBase64(Filename);
        if Erase(Filename) then;

        exit(PdfCustomerStatement);
        //+MAG2.20 [351590]
    end;

    [Scope('Personalization')]
    procedure GeneratePdfShipment(DocumentNo: Code[20];CustomerNo: Code[20]) PdfShipment: Text
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        ReportSelections: Record "Report Selections";
        Filename: Text;
    begin

        //-MAG2.20 [345376]
        ReportSelections.SetRange (Usage,ReportSelections.Usage::"S.Shipment");
        ReportSelections.SetFilter ("Report ID",'<>%1',0);
        ReportSelections.FindFirst ();

        SalesShipmentHeader.Get (DocumentNo);
        SalesShipmentHeader.TestField ("Bill-to Customer No.", CustomerNo);
        SalesShipmentHeader.SetRecFilter;

        Filename := TemporaryPath + 'shipment-' + DocumentNo + '.pdf';
        REPORT.SaveAsPdf (ReportSelections."Report ID",Filename, SalesShipmentHeader);

        PdfShipment := GetBase64(Filename);
        if Erase(Filename) then;

        exit(PdfShipment);
        //+MAG2.20 [345376]
    end;

    [Scope('Personalization')]
    procedure GetInvoices(CustomerNo: Code[20];StartDate: Date;EndDate: Date;var documents: XMLport "Magento Document Export")
    begin
        //-MAG2.03
        //documents.SetFilters(CustomerNo,StartDate,EndDate,TRUE,FALSE);

        //-MAG2.20 [345376]
        //documents.SetFilters(CustomerNo,StartDate,EndDate,TRUE,FALSE,FALSE);
        documents.SetFilters (CustomerNo, '', StartDate, EndDate, false, true, false, false, false);
        //+MAG2.20 [345376]

        //+MAG2.03
    end;

    [Scope('Personalization')]
    procedure GetCrMemos(CustomerNo: Code[20];StartDate: Date;EndDate: Date;var documents: XMLport "Magento Document Export")
    var
        XmlDoc: DotNet npNetXmlDocument;
        XmlDocElement: DotNet npNetXmlElement;
        XmlElement: DotNet npNetXmlElement;
        XmlElement2: DotNet npNetXmlElement;
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        StartDate2: Date;
        EndDate2: Date;
    begin
        //-MAG2.03
        //documents.SetFilters(CustomerNo,StartDate,EndDate,FALSE,TRUE);

        //-MAG2.20 [345376]
        //documents.SetFilters(CustomerNo,StartDate,EndDate,FALSE,TRUE,FALSE);
        documents.SetFilters (CustomerNo, '', StartDate, EndDate, false, false, true, false, false);
        //+MAG2.20 [345376]

        //-MAG2.03
    end;

    [Scope('Personalization')]
    procedure GetOrders(CustomerNo: Code[20];StartDate: Date;EndDate: Date;var documents: XMLport "Magento Document Export")
    begin
        //-MAG2.03

        //-MAG2.20 [345376]
        //documents.SetFilters(CustomerNo,StartDate,EndDate,FALSE,FALSE,TRUE);
        documents.SetFilters (CustomerNo, '', StartDate, EndDate, false, false, false, true, false);
        //+MAG2.20 [345376]

        //+MAG2.03
    end;

    [Scope('Personalization')]
    procedure GetShipments(CustomerNo: Code[20];StartDate: Date;EndDate: Date;var documents: XMLport "Magento Document Export")
    begin

        //-MAG2.20 [345376]
        documents.SetFilters (CustomerNo, '', StartDate, EndDate, false, false, false, false, true);
        //+MAG2.20 [345376]
    end;

    [Scope('Personalization')]
    procedure ListInvoices(CustomerNo: Code[20];StartDate: Date;EndDate: Date;var documents: XMLport "Magento Document Export")
    begin

        //-MAG2.20 [345376]
        documents.SetFilters (CustomerNo, '', StartDate, EndDate, true, true, false, false, false);
        //+MAG2.20 [345376]

        //+MAG2.03
    end;

    [Scope('Personalization')]
    procedure ListCrMemos(CustomerNo: Code[20];StartDate: Date;EndDate: Date;var documents: XMLport "Magento Document Export")
    var
        XmlDoc: DotNet npNetXmlDocument;
        XmlDocElement: DotNet npNetXmlElement;
        XmlElement: DotNet npNetXmlElement;
        XmlElement2: DotNet npNetXmlElement;
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        StartDate2: Date;
        EndDate2: Date;
    begin

        //-MAG2.20 [345376]
        documents.SetFilters (CustomerNo, '', StartDate, EndDate, true, false, true, false, false);
        //+MAG2.20 [345376]
    end;

    [Scope('Personalization')]
    procedure ListOrders(CustomerNo: Code[20];StartDate: Date;EndDate: Date;var documents: XMLport "Magento Document Export")
    begin

        //-MAG2.20 [345376]
        documents.SetFilters (CustomerNo, '', StartDate, EndDate, true, false, false, true, false);
        //+MAG2.20 [345376]
    end;

    [Scope('Personalization')]
    procedure ListShipments(CustomerNo: Code[20];StartDate: Date;EndDate: Date;var documents: XMLport "Magento Document Export")
    begin

        //-MAG2.20 [345376]
        documents.SetFilters (CustomerNo, '', StartDate, EndDate, true, false, false, false, true);
        //+MAG2.20 [345376]
    end;

    [Scope('Personalization')]
    procedure GetInvoice(CustomerNo: Code[20];DocumentNumber: Code[20];var documents: XMLport "Magento Document Export")
    begin

        //-MAG2.20 [345376]
        documents.SetFilters (CustomerNo, DocumentNumber, 0D, DMY2Date (31, 12, 9999), false, true, false, false, false);
        //+MAG2.20 [345376]
    end;

    [Scope('Personalization')]
    procedure GetCrMemo(CustomerNo: Code[20];DocumentNumber: Code[20];var documents: XMLport "Magento Document Export")
    var
        XmlDoc: DotNet npNetXmlDocument;
        XmlDocElement: DotNet npNetXmlElement;
        XmlElement: DotNet npNetXmlElement;
        XmlElement2: DotNet npNetXmlElement;
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        StartDate2: Date;
        EndDate2: Date;
    begin

        //-MAG2.20 [345376]
        documents.SetFilters (CustomerNo, DocumentNumber, 0D, DMY2Date (31, 12, 9999), false, false, true, false, false);
        //+MAG2.20 [345376]
    end;

    [Scope('Personalization')]
    procedure GetOrder(CustomerNo: Code[20];DocumentNumber: Code[20];var documents: XMLport "Magento Document Export")
    begin

        //-MAG2.20 [345376]
        documents.SetFilters (CustomerNo, DocumentNumber, 0D, DMY2Date (31, 12, 9999), false, false, false, true, false);
        //+MAG2.20 [345376]
    end;

    [Scope('Personalization')]
    procedure GetShipment(CustomerNo: Code[20];DocumentNumber: Code[20];var documents: XMLport "Magento Document Export")
    begin

        //-MAG2.20 [345376]
        documents.SetFilters (CustomerNo, DocumentNumber, 0D, DMY2Date (31, 12, 9999), false, false, false, false, true);
        //+MAG2.20 [345376]
    end;

    [Scope('Personalization')]
    procedure GetItemInventory(itemFilter: Text;variantFilter: Text;locationFilter: Text;var items: XMLport "Magento Avail. InventoryExport")
    begin
        Clear(items);
        items.SetFilters(itemFilter,variantFilter,locationFilter);
    end;

    [Scope('Personalization')]
    procedure GetItemInventorySet(var retail_inventory_api: XMLport "Magento Inventory Set Api")
    begin
        //-MAG2.17 [322939]
        retail_inventory_api.Import;
        //+MAG2.17 [322939]
    end;

    [Scope('Personalization')]
    procedure GetCustomerNo(OrderNo: Code[20]) CustomerNo: Text
    var
        SalesHeader: Record "Sales Header";
    begin
        //-MAG2.03
        SalesHeader.SetRange("Document Type",SalesHeader."Document Type"::Order);
        SalesHeader.SetFilter("External Order No.",OrderNo);
        if SalesHeader.FindFirst then
          CustomerNo :=  SalesHeader."Sell-to Customer No.";
        exit(CustomerNo);
        //+MAG2.03
    end;

    [Scope('Personalization')]
    procedure GetItemImage(ItemNo: Code[20];VariantCode: Code[10];ImageType: Option ANY,BASE,SMALL,THUMBNAIL;var ImageName: Text[250];var ImageDescription: Text[250];var ImageBase64: Text): Boolean
    var
        Item: Record Item;
        MagentoPictureLink: Record "Magento Picture Link";
        MagentoPicture: Record "Magento Picture";
        BinaryReader: DotNet npNetBinaryReader;
        MemoryStream: DotNet npNetMemoryStream;
        Convert: DotNet npNetConvert;
        InStr: InStream;
    begin

        //-MAG2.20 [351060]
        MagentoPictureLink.SetCurrentKey ("Item No.","Line No."); // No key on sorting
        MagentoPictureLink.SetFilter ("Item No.", '=%1', ItemNo);
        MagentoPictureLink.SetFilter ("Variant Value Code", '=%1', VariantCode);
        case (ImageType) of
          ImageType::BASE      : MagentoPictureLink.SetFilter ("Base Image", '=%1', true);
          ImageType::SMALL     : MagentoPictureLink.SetFilter ("Small Image", '=%1', true);
          ImageType::THUMBNAIL : MagentoPictureLink.SetFilter (Thumbnail, '=%1', true);
        end;
        if (not MagentoPictureLink.FindFirst ()) then
          exit (false);

        MagentoPicture.SetFilter (Type, '=%1', MagentoPicture.Type::Item);
        MagentoPicture.SetFilter (Name, '=%1', MagentoPictureLink."Picture Name");
        if (not MagentoPicture.FindFirst ()) then
          exit (false);

        if (not MagentoPicture.Picture.HasValue ()) then
          exit (false);

        MagentoPicture.CalcFields (Picture);
        MagentoPicture.Picture.CreateInStream (InStr);

        //Note: This will only work for on-prem
        MemoryStream := InStr;
        BinaryReader := BinaryReader.BinaryReader (InStr);
        ImageBase64 := Convert.ToBase64String (BinaryReader.ReadBytes (MemoryStream.Length));
        MemoryStream.Dispose ();
        Clear (MemoryStream);

        ImageName := MagentoPicture.Name;
        ImageDescription := MagentoPictureLink."Short Text";
        exit (true);
        //+MAG2.20 [351060]
    end;

    [Scope('Personalization')]
    procedure ImportSalesOrders(var sales_orders: XMLport "Magento Sales Order Import")
    var
        ImportEntry: Record "Nc Import Entry";
        NaviConnectSalesOrderMgt: Codeunit "Magento Sales Order Mgt.";
        NaviConnectSyncMgt: Codeunit "Nc Sync. Mgt.";
        OutStr: OutStream;
    begin
        sales_orders.Import;
        InsertImportEntry('ImportSalesOrders',ImportEntry);
        ImportEntry."Document Name" := 'Magento Order-' + sales_orders.GetWebsiteCode() + '-' + sales_orders.GetOrderNo() + '.xml';
        ImportEntry."Document Source".CreateOutStream(OutStr);
        sales_orders.SetDestination(OutStr);
        sales_orders.Export;
        ImportEntry.Modify(true);
        Commit;

        NaviConnectSyncMgt.ProcessImportEntry(ImportEntry);
    end;

    [Scope('Personalization')]
    procedure ImportSalesReturnOrders(var sales_return_orders: XMLport "Magento Return Order Import")
    var
        ImportEntry: Record "Nc Import Entry";
        NcSyncMgt: Codeunit "Nc Sync. Mgt.";
        OutStr: OutStream;
    begin
        //-MAG2.12 [309647]
        sales_return_orders.Import;
        InsertImportEntry('ImportSalesReturnOrders',ImportEntry);
        ImportEntry."Document Name" := 'Magento Return Order-' + sales_return_orders.GetReturnOrderNo() + '.xml';
        ImportEntry."Document Source".CreateOutStream(OutStr);
        sales_return_orders.SetDestination(OutStr);
        sales_return_orders.Export;
        ImportEntry.Modify(true);
        Commit;

        NcSyncMgt.ProcessImportEntry(ImportEntry);
        //+MAG2.12 [309647]
    end;

    local procedure InsertImportEntry(WebserviceFunction: Text;var ImportEntry: Record "Nc Import Entry")
    var
        NaviConnectSetupMgt: Codeunit "Nc Setup Mgt.";
    begin
        ImportEntry.Init;
        ImportEntry."Entry No." := 0;
        ImportEntry."Import Type" := NaviConnectSetupMgt.GetImportTypeCode(CODEUNIT::"Magento Webservice",WebserviceFunction);
        ImportEntry.Date := CurrentDateTime;
        ImportEntry."Document Name" := ImportEntry."Import Type" + '-' + Format(ImportEntry.Date,0,9) + '.xml';
        ImportEntry.Imported := false;
        ImportEntry."Runtime Error" := true;
        ImportEntry.Insert(true);
    end;

    [Scope('Personalization')]
    procedure InitSetup(MagentoUrl: Text;Hash: Text): Text
    var
        MagentoSetup: Record "Magento Setup";
        NpXmlSetup: Record "NpXml Setup";
        MagentoNpXmlSetupMgt: Codeunit "Magento NpXml Setup Mgt.";
        MagentoSetupMgt: Codeunit "Magento Setup Mgt.";
        MagentoMgt: Codeunit "Magento Mgt.";
        NaviConnectSetupMgt: Codeunit "Nc Setup Mgt.";
        FormsAuthentication: DotNet npNetFormsAuthentication;
    begin
        if LowerCase(Hash) <> LowerCase(FormsAuthentication.HashPasswordForStoringInConfigFile(MagentoUrl + 'D3W7k5pd7Pn64ctn25ng91ZkSvyDnjo2','MD5')) then
          Error(Error001);

        if not MagentoSetup.Get then
          MagentoSetup.Insert;
        if (MagentoSetup."Magento Url" <> '') and (MagentoSetup."Magento Url" <> MagentoUrl) then
          Error(Error002,MagentoSetup."Magento Url");

        //-MAG2.00
        // NpXmlSetupMgt.SetupNpXml();
        // NpXmlSetupMgt.SetApiUrl(MagentoUrl + 'api/rest/naviconnect/');
        // NpXmlSetupMgt.EnableNpXml();
        MagentoSetup."Api Username Type" := MagentoSetup."Api Username Type"::Automatic;
        //+MAG2.00

        MagentoSetup.Validate("Magento Url",MagentoUrl);
        MagentoSetup."Variant System" := MagentoSetup."Variant System"::"1";
        MagentoSetup."Magento Enabled" := true;
        MagentoSetup."Brands Enabled" := true;
        MagentoSetup."Attributes Enabled" := true;
        MagentoSetup."Product Relations Enabled" := true;
        MagentoSetup."Special Prices Enabled" := true;
        //-MAG2.00
        //MagentoSetup.MODIFY;
        MagentoSetup.Modify(true);
        //+MAG2.00

        NaviConnectSetupMgt.InitNaviConnectSetup();

        //-MAG2.00
        // NaviConnectSetupMgt.SetupWebservices();
        // COMMIT;
        // NaviConnectSetupMgt.SetupClientAddIns();
        // COMMIT;
        // NaviConnectSetupMgt.SetupImportTypes();
        MagentoSetupMgt.SetupClientAddIns();
        Commit;
        MagentoSetupMgt.SetupImportTypes();
        //+MAG2.00
        Commit;
        NaviConnectSetupMgt.SetupTaskQueue();
        Commit;

        //-MAG2.08 [292926]
        //MagentoSetupMgt.SetupNpXmlTemplates();
        MagentoSetupMgt.TriggerSetupNpXmlTemplates();
        //+MAG2.08 [292926]
        Commit;
        //-MAG2.07 [286943]
        // MagentoSetupMgt.SetupVATBusinessPostingGroups();
        // MagentoSetupMgt.SetupVATProductPostingGroups();
        // COMMIT;
        // MagentoSetupMgt.SetupMagentoCredentials();
        // MagentoSetupMgt.SetupMagentoWebsites();
        // MagentoSetupMgt.SetupMagentoTaxClasses();
        // MagentoSetupMgt.SetupMagentoCustomerGroups();
        // MagentoSetupMgt.SetupNaviConnectPaymentMethods();
        // MagentoSetupMgt.SetupNaviConnectShipmentMethods();
        //-MAG2.08 [292926]
        //MagentoSetupMgt.TriggerSetupVATBusinessPostingGroups();
        //MagentoSetupMgt.TriggerSetupVATProductPostingGroups();
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

    local procedure "--- Aux"()
    begin
    end;

    local procedure GetBase64(Filename: Text) Value: Text
    var
        TempBlob: Record TempBlob temporary;
        BinaryReader: DotNet npNetBinaryReader;
        MemoryStream: DotNet npNetMemoryStream;
        Convert: DotNet npNetConvert;
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

