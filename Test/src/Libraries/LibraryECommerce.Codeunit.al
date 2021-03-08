codeunit 85010 "NPR Library - E-Commerce"
{

    var
        CreateSalesOrderDescLbl: Label 'Create Sales Order';
        CreatePurchOrderDescLbl: Label 'Create Purchase Order';
        PostSalesOrderDescLbl: Label 'Post Sales Order';
        DeleteSalesOrderDescLbl: Label 'Delete Sales Order';

    procedure CreateEcStore(StoreCode: Code[20])
    var
        EcStore: Record "NPR NpEc Store";
        Salesperson: Record "Salesperson/Purchaser";
        LibrarySales: Codeunit "Library - Sales";
    begin
        EcStore.Code := StoreCode;
        EcStore.Init();
        LibrarySales.CreateSalesperson(Salesperson);
        EcStore."Salesperson/Purchaser Code" := Salesperson.Code;
        EcStore."Global Dimension 1 Code" := '';
        EcStore."Global Dimension 2 Code" := '';
        EcStore."Location Code" := CreateLocationWithCode();
        EcStore."Customer Mapping" := EcStore."Customer Mapping"::"E-mail";
        EcStore."Customer Config. Template Code" := '';
        EcStore."Allow Create Customers" := false;
        EcStore."Update Customers from S. Order" := false;
        EcStore.Insert();
    end;

    procedure CreateCustomer(EMailAddress: Text; PhoneNo: Text)
    var
        Customer: Record Customer;
        LibrarySales: Codeunit "Library - Sales";
    begin
        LibrarySales.CreateCustomer(Customer);
        Customer."E-Mail" := EMailAddress;
        Customer."Phone No." := PhoneNo;
        Customer.Name := '';
        Customer.Address := '';
        Customer."Post Code" := '';
        Customer.City := '';
        Customer.Modify();
    end;

    procedure CreateVendor(EMailAddress: Text; PhoneNo: Text; var VendorNo: Code[20])
    var
        Vendor: Record Vendor;
        LibraryPurchase: Codeunit "Library - Purchase";
    begin
        LibraryPurchase.CreateVendor(Vendor);
        Vendor."E-Mail" := EMailAddress;
        Vendor."Phone No." := PhoneNo;
        Vendor.Name := '';
        Vendor.Address := '';
        Vendor."Post Code" := '';
        Vendor.City := '';
        Vendor.Modify();
        VendorNo := Vendor."No.";
    end;

    procedure CreateEcCustomerMapping(StoreCode: Code[20]; PostCode: Code[20])
    var
        EcCustomerMapping: Record "NPR NpEc Customer Mapping";
    begin
        EcCustomerMapping."Store Code" := StoreCode;
        EcCustomerMapping."Post Code" := PostCode;
        EcCustomerMapping.Init();
        EcCustomerMapping."Config. Template Code" := '';
        EcCustomerMapping.Insert();
    end;

    procedure CreateMagentoPaymentMapping(PaymentCode: Code[50]; PaymentType: Text[50])
    var
        LibraryMagento: Codeunit "NPR Library - Magento";
    begin
        LibraryMagento.CreatePaymentMapping(PaymentCode, PaymentType);
    end;

    procedure CreateMagentoShipmentMapping(ExternalShipmentMethodCode: Text[50])
    var
        ShipmentMapping: Record "NPR Magento Shipment Mapping";
        VATPostSetup: Record "VAT Posting Setup";
        LibraryMagento: Codeunit "NPR Library - Magento";
        LibraryERM: Codeunit "Library - ERM";
        GLAccountNo: Code[20];
    begin
        LibraryMagento.CreateShipmentMapping(ExternalShipmentMethodCode, ShipmentMapping);
        ShipmentMapping."Shipment Fee Type" := ShipmentMapping."Shipment Fee Type"::"G/L Account";
        LibraryERM.FindVATPostingSetup(VATPostSetup, "Tax Calculation Type"::"Normal VAT");
        GLAccountNo := LibraryERM.CreateGLAccountWithVATPostingSetup(VATPostSetup, "General Posting Type"::Sale);
        ShipmentMapping."Shipment Fee No." := GLAccountNo;
        ShipmentMapping.Modify();
    end;

    local procedure CreateLocationWithCode(): Code[10]
    var
        Location: Record Location;
        LibraryUtility: Codeunit "Library - Utility";
    begin
        Location.Code := LibraryUtility.GenerateRandomCode(Location.FieldNo(Code), Database::Location);
        Location.Init();
        Location.Name := CopyStr(Location.Code, 1, MaxStrLen(Location.Name));
        Location.Insert();
        exit(Location.Code);
    end;

    procedure CreateItem(var ItemNo: Code[20])
    var
        Item: Record Item;
        LibraryInventory: Codeunit "Library - Inventory";
    begin
        if (ItemNo <> '') then
            exit;
        LibraryInventory.CreateItem(Item);
        ItemNo := Item."No.";
    end;

    procedure IncreaseItemInventoryOnLocation(ItemNo: Code[20]; Qty: Decimal; LocationCode: Code[10])
    var
        ItemJournalLine: Record "Item Journal Line";
        ItemJournalTemplate: Record "Item Journal Template";
        ItemJournalBatch: Record "Item Journal Batch";
        Location: Record Location;
        LibraryInventory: Codeunit "Library - Inventory";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
    begin
        Location.Code := LocationCode;
        Location.Find();
        LibraryInventory.UpdateInventoryPostingSetup(Location);
        LibraryInventory.CreateItemJournalTemplate(ItemJournalTemplate);
        LibraryInventory.CreateItemJournalBatch(ItemJournalBatch, ItemJournalTemplate.Name);
        LibraryInventory.CreateItemJournalLine(
                                ItemJournalLine, ItemJournalTemplate.Name, ItemJournalBatch.Name,
                                "Item Ledger Entry Type"::"Positive Adjmt.", ItemNo, Qty);
        ItemJournalLine.Validate("Location Code", LocationCode);
        ItemJnlPostLine.RunWithCheck(ItemJournalLine);
    end;

    procedure CreateGLAccount(var GLAccountNo: Code[20])
    var
        VATPostSetup: Record "VAT Posting Setup";
        LibraryERM: Codeunit "Library - ERM";
    begin
        if (GLAccountNo <> '') then
            exit;
        LibraryERM.FindVATPostingSetup(VATPostSetup, "Tax Calculation Type"::"Normal VAT");
        GLAccountNo := LibraryERM.CreateGLAccountWithVATPostingSetup(VATPostSetup, "General Posting Type"::Sale);
    end;

    procedure GetSalesOrderNo(var SalesOrderNo: Code[20])
    var
        SalesHeader: Record "Sales Header";
        LibraryUtility: Codeunit "Library - Utility";
    begin
        if SalesOrderNo <> '' then
            exit;
        SalesOrderNo := LibraryUtility.GenerateRandomCode20(SalesHeader.FieldNo("No."), Database::"Sales Header");
    end;

    procedure GetPurchInvNo(var PurchInvNo: Code[20])
    var
        PurchaseHeader: Record "Purchase Header";
        LibraryUtility: Codeunit "Library - Utility";
    begin
        if PurchInvNo <> '' then
            exit;
        PurchInvNo := LibraryUtility.GenerateRandomCode20(PurchaseHeader.FieldNo("No."), Database::"Purchase Header");
    end;

    procedure GetVendorInvoiceNo(var VendorInvoiceNo: Code[35])
    var
        PurchaseHeader: Record "Purchase Header";
        LibraryRandom: Codeunit "Library - Random";
    begin
        if VendorInvoiceNo <> '' then
            exit;
        VendorInvoiceNo := LibraryRandom.RandText(MaxStrLen(PurchaseHeader."Vendor Invoice No."));
    end;

    procedure GetEcStoreCode(var StoreCode: Code[20])
    var
        EcStore: Record "NPR NpEc Store";
        LibraryUtility: Codeunit "Library - Utility";
    begin
        if StoreCode <> '' then
            exit;
        StoreCode := LibraryUtility.GenerateRandomCode20(EcStore.FieldNo(Code), Database::"NPR NpEc Store");
    end;

    procedure GetCustomerEMailAddress(var EMail: Text[45])
    var
        Customer: Record Customer;
        LibraryUtility: Codeunit "Library - Utility";
    begin
        if EMail <> '' then
            exit;
        EMail := LibraryUtility.GenerateRandomEmail();
    end;

    procedure GetPostCodeAndCity(var NewPostCode: Code[20]; var NewCity: Text[30])
    var
        PostCode: Record "Post Code";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";
    begin
        if (NewPostCode <> '') and (NewCity <> '') then
            exit;
        if NewPostCode = '' then
            NewPostCode := LibraryUtility.GenerateRandomCode20(PostCode.FieldNo(Code), Database::"Post Code");
        if NewCity = '' then
            NewCity := LibraryRandom.RandText(MaxStrLen(PostCode.City));
    end;

    procedure GetMagentoPaymentCode(var NewPaymentCode: Code[50])
    var
        PaymentMapping: Record "NPR Magento Payment Mapping";
        LibraryRandom: Codeunit "Library - Random";
    begin
        if (NewPaymentCode <> '') then
            exit;
        if NewPaymentCode = '' then
            NewPaymentCode := LibraryRandom.RandText(MaxStrLen(PaymentMapping."External Payment Method Code"));
    end;

    procedure GetMagentoPaymentTransactionId(var TransactionId: Code[50])
    var
        PaymentLine: Record "NPR Magento Payment Line";
        LibraryRandom: Codeunit "Library - Random";
    begin
        if (TransactionId <> '') then
            exit;
        TransactionId := LibraryRandom.RandText(MaxStrLen(PaymentLine."No."));
    end;

    procedure GetMagentoShipmentMethodCode(var ExternalShipmentMethodCode: Text[50])
    var
        ShipmentMapping: Record "NPR Magento Shipment Mapping";
        LibraryRandom: Codeunit "Library - Random";
    begin
        if (ExternalShipmentMethodCode <> '') then
            exit;
        ExternalShipmentMethodCode := LibraryRandom.RandText(MaxStrLen(ShipmentMapping."External Shipment Method Code"));
    end;

    procedure GetItemQuantitiesAndPrices(var Qty: Decimal; var Qty2: Decimal; var UnitPrice: Decimal; var UnitPrice2: Decimal)
    var
        LibraryRandom: Codeunit "Library - Random";
    begin
        if (Qty <> 0) and (Qty2 <> 0) and (UnitPrice <> 0) and (UnitPrice2 <> 0) then
            exit;
        if Qty = 0 then
            Qty := LibraryRandom.RandDec(4, 4);
        if Qty2 = 0 then
            Qty2 := LibraryRandom.RandDec(10, 4);
        if UnitPrice = 0 then
            UnitPrice := LibraryRandom.RandDec(10, 4);
        if UnitPrice2 = 0 then
            UnitPrice2 := LibraryRandom.RandDec(10, 4);
    end;

    procedure GetPaymentAmounts(var Amt: Decimal; var Amt2: Decimal)
    var
        LibraryRandom: Codeunit "Library - Random";
    begin
        if (Amt <> 0) and (Amt2 <> 0) then
            exit;
        if Amt = 0 then
            Amt := LibraryRandom.RandDec(4, 4);
        if Amt2 = 0 then
            Amt2 := LibraryRandom.RandDec(10, 4);
    end;

    procedure GetGlAccUnitPrices(var UnitPrice: Decimal; var UnitPrice2: Decimal)
    var
        LibraryRandom: Codeunit "Library - Random";
    begin
        if (UnitPrice <> 0) and (UnitPrice2 <> 0) then
            exit;
        if UnitPrice = 0 then
            UnitPrice := LibraryRandom.RandDec(10, 4);
        if UnitPrice2 = 0 then
            UnitPrice2 := LibraryRandom.RandDec(10, 4);
    end;

    procedure GetLineDesc(var Desc: Text; SalesLineType: Enum "Sales Line Type")
    var
        SalesLine: Record "Sales Line";
        LibraryRandom: Codeunit "Library - Random";
        SalesLineTypeTxt: Text;
    begin
        if (Desc <> '') then
            exit;
        SalesLineTypeTxt := Format(SalesLineType);
        Desc := SalesLineTypeTxt + LibraryRandom.RandText(MaxStrLen(SalesLine.Description) - StrLen(SalesLineTypeTxt));
    end;

    procedure InitImportTypeDeleteSalesOrder(var ImportType: Record "NPR Nc Import Type")
    var
        EcWebService: codeunit "NPR NpEc Webservice";
    begin
        EcWebService.InitImportType('DeleteSalesOrder', 'DELETE_SALES_ORDER', DeleteSalesOrderDescLbl, CODEUNIT::"NPR NpEc S.Order Imp. Delete", CODEUNIT::"NPR NpEc S.Order Lookup", ImportType);

    end;

    procedure InitImportTypeCreateSalesOrder(var ImportType: Record "NPR Nc Import Type")
    var
        EcWebService: codeunit "NPR NpEc Webservice";
    begin
        EcWebService.InitImportType('CreateSalesOrder', 'CREATE_SALES_ORDER', CreateSalesOrderDescLbl, CODEUNIT::"NPR NpEc S.Order Import Create", CODEUNIT::"NPR NpEc S.Order Lookup", ImportType);
    end;

    procedure InitImportTypePostSalesOrder(var ImportType: Record "NPR Nc Import Type")
    var
        EcWebService: codeunit "NPR NpEc Webservice";
    begin
        EcWebService.InitImportType('PostSalesOrder', 'POST_SALES_ORDER', PostSalesOrderDescLbl, CODEUNIT::"NPR NpEc S.Order Import (Post)", CODEUNIT::"NPR NpEc S.Order Lookup", ImportType);
    end;

    procedure InitImportTypeCreatePurchInv(var ImportType: Record "NPR Nc Import Type")
    var
        EcWebService: codeunit "NPR NpEc Webservice";
    begin
        EcWebService.InitImportType('CreatePurchaseInvoice', 'CREATE_PURCH_ORDER', CreatePurchOrderDescLbl, CODEUNIT::"NPR NpEc P.Invoice Imp. Create", CODEUNIT::"NPR NpEc P.Invoice Look.", ImportType);
    end;

    procedure InsertImportEntry(ImportType: Record "NPR Nc Import Type"; var ImportEntry: Record "NPR Nc Import Entry")
    var
        EcWebService: codeunit "NPR NpEc Webservice";
    begin
        EcWebService.InsertImportEntry(ImportType, ImportEntry);
    end;
}