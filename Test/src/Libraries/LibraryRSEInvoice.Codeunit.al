codeunit 85200 "NPR Library RS E-Invoice"
{
    EventSubscriberInstance = Manual;

#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    var
        _PurchaseHeaderNo: Code[20];
        _LibrarySales: Codeunit "Library - Sales";
        _LibraryPurchase: Codeunit "Library - Purchase";
        _LibraryInventory: Codeunit "Library - Inventory";
        _LibraryERM: Codeunit "Library - ERM";
        _LibraryRandom: Codeunit "Library - Random";

    #region Library RS E-Invoice Setups

    internal procedure CreateRSEInvoiceSetup()
    var
        RSEInvoiceSetup: Record "NPR RS E-Invoice Setup";
        RSEICommunicationMgt: Codeunit "NPR RS EI Communication Mgt.";
        LibraryRSEInvoice: Codeunit "NPR Library RS E-Invoice";
    begin
        RSEInvoiceSetup.DeleteAll();
        RSEInvoiceSetup.Init();
        RSEInvoiceSetup."Enable RS E-Invoice" := true;
        RSEInvoiceSetup."API URL" := 'https://demoefaktura.mfin.gov.rs/';
        RSEInvoiceSetup."API Key" := CreateGuid();
        RSEInvoiceSetup."Default Unit Of Measure" := CreateUnitOfMeasure();
        RSEInvoiceSetup.Insert();

        EnableRSEIApplicationArea();

        CreateCompanyAuxInfo();

        BindSubscription(LibraryRSEInvoice);
        RSEICommunicationMgt.GetAllowedUOMs();
        RSEICommunicationMgt.GetTaxExemptionReasonList();
        UnbindSubscription(LibraryRSEInvoice);

        CreateUOMMapping(RSEInvoiceSetup."Default Unit Of Measure");
    end;

    local procedure EnableRSEIApplicationArea()
    var
        ApplicationAreaSetup: Record "Application Area Setup";
    begin
        ApplicationAreaSetup.Init();
        ApplicationAreaSetup."Company Name" := CompanyName();
        ApplicationAreaSetup."NPR RS Fiscal" := true;
        if not ApplicationAreaSetup.Insert() then
            ApplicationAreaSetup.Modify();
    end;

    local procedure CreateCompanyAuxInfo()
    var
        CompanyInfo: Record "Company Information";
    begin
        CompanyInfo."Registration No." := GetTestRegistrationNo();
        CompanyInfo."VAT Registration No." := GetTestVATRegistrationNo();
        CompanyInfo."Bank Account No." := GetTestBankAccountNo();
        CompanyInfo.Address := GetTestAddress();
        CompanyInfo.City := GetTestCity();
        CompanyInfo."Post Code" := GetTestPostCode();
        CompanyInfo."Country/Region Code" := GetTestCountryRegionCode();
        CompanyInfo.Modify();
    end;

    #endregion Library RS E-Invoice Setups

    #region Library RS E-Invoice Posting Setups

    internal procedure CreateVATPostingSetup(var VATPostingSetup: Record "VAT Posting Setup"; GeneralPostingSetup: Record "General Posting Setup")
    var
        RSEIVATPostSetupMap: Record "NPR RS EI VAT Post. Setup Map.";
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
        VATProductPostingGroup: Record "VAT Product Posting Group";
        GenPostingType: Enum "General Posting Type";
    begin
        _LibraryERM.CreateVATBusinessPostingGroup(VATBusinessPostingGroup);
        _LibraryERM.CreateVATProductPostingGroup(VATProductPostingGroup);
        _LibraryERM.CreateVATPostingSetup(VATPostingSetup, VATBusinessPostingGroup.Code, VATProductPostingGroup.Code);
        VATPostingSetup."VAT %" := 20;
        VATPostingSetup.Validate("Sales VAT Account", CreateGLAccount(GeneralPostingSetup, VATPostingSetup, GenPostingType::" "));
        VATPostingSetup.Modify();

        if not RSEIVATPostSetupMap.Get(VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group") then begin
            RSEIVATPostSetupMap.Init();
            RSEIVATPostSetupMap."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
            RSEIVATPostSetupMap."VAT Prod. Posting Group" := VATPostingSetup."VAT Prod. Posting Group";
            RSEIVATPostSetupMap."NPR RS EI Tax Category" := RSEIVATPostSetupMap."NPR RS EI Tax Category"::S;
            RSEIVATPostSetupMap.Insert();
        end;
    end;

    internal procedure CreateVATPostingSetup(var VATPostingSetup: Record "VAT Posting Setup"; VATBusinessPostingGroup: Code[20];
                                             VATProductPostingGroup: Code[20]; GeneralPostingSetup: Record "General Posting Setup")
    var
        RSEIVATPostSetupMap: Record "NPR RS EI VAT Post. Setup Map.";
        GenPostingType: Enum "General Posting Type";
    begin
        _LibraryERM.CreateVATPostingSetup(VATPostingSetup, VATBusinessPostingGroup, VATProductPostingGroup);
        VATPostingSetup."VAT %" := 20;
        VATPostingSetup.Validate("Sales VAT Account", CreateGLAccount(GeneralPostingSetup, VATPostingSetup, GenPostingType::" "));
        VATPostingSetup.Modify();

        if not RSEIVATPostSetupMap.Get(VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group") then begin
            RSEIVATPostSetupMap.Init();
            RSEIVATPostSetupMap."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
            RSEIVATPostSetupMap."VAT Prod. Posting Group" := VATPostingSetup."VAT Prod. Posting Group";
            RSEIVATPostSetupMap."NPR RS EI Tax Category" := RSEIVATPostSetupMap."NPR RS EI Tax Category"::S;
            RSEIVATPostSetupMap.Insert();
        end;
    end;

    internal procedure CreateGeneralPostingSetup(var GeneralPostingSetup: Record "General Posting Setup")
    var
        GenBusinessPostingGroup: Record "Gen. Business Posting Group";
        GenProductPostingGroup: Record "Gen. Product Posting Group";
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
        VATProductPostingGroup: Record "VAT Product Posting Group";
        VATPostingSetup: Record "VAT Posting Setup";
        GenPostingType: Enum "General Posting Type";
    begin
        _LibraryERM.CreateGenBusPostingGroup(GenBusinessPostingGroup);
        _LibraryERM.CreateGenProdPostingGroup(GenProductPostingGroup);
        _LibraryERM.CreateVATBusinessPostingGroup(VATBusinessPostingGroup);
        _LibraryERM.CreateVATProductPostingGroup(VATProductPostingGroup);
        _LibraryERM.CreateVATPostingSetup(VATPostingSetup, VATBusinessPostingGroup.Code, VATProductPostingGroup.Code);
        _LibraryERM.CreateGeneralPostingSetup(GeneralPostingSetup, GenBusinessPostingGroup.Code, GenProductPostingGroup.Code);
        GeneralPostingSetup.Validate("Sales Account", CreateGLAccount(GeneralPostingSetup, VATPostingSetup, GenPostingType::" "));
        GeneralPostingSetup.Validate("Purch. Account", CreateGLAccount(GeneralPostingSetup, VATPostingSetup, GenPostingType::" "));
        GeneralPostingSetup.Validate("COGS Account", CreateGLAccount(GeneralPostingSetup, VATPostingSetup, GenPostingType::" "));
        GeneralPostingSetup.Validate("Inventory Adjmt. Account", CreateGLAccount(GeneralPostingSetup, VATPostingSetup, GenPostingType::" "));
        GeneralPostingSetup.Validate("Direct Cost Applied Account", CreateGLAccount(GeneralPostingSetup, VATPostingSetup, GenPostingType::" "));
        GeneralPostingSetup.Validate("Purch. Line Disc. Account", CreateGLAccount(GeneralPostingSetup, VATPostingSetup, GenPostingType::" "));
        GeneralPostingSetup.Validate("Purch. Credit Memo Account", CreateGLAccount(GeneralPostingSetup, VATPostingSetup, GenPostingType::" "));
        GeneralPostingSetup.Validate("Sales Credit Memo Account", CreateGLAccount(GeneralPostingSetup, VATPostingSetup, GenPostingType::" "));
        GeneralPostingSetup.Validate("Sales Prepayments Account", CreateGLAccount(GeneralPostingSetup, VATPostingSetup, GenPostingType::" "));
        GeneralPostingSetup.Modify(true);
    end;

    #endregion Library RS E-Invoice Posting Setups

    #region Library RS E-Invoice Documents

    internal procedure CreateSalesHeaderWLines(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; DocumentType: Enum "Sales Document Type"; LineType: Enum "Sales Line Type";
                                            Customer: Record Customer; GeneralPostingSetup: Record "General Posting Setup"; VATPostingSetup: Record "VAT Posting Setup")
    var
        LineTypeNo: Code[20];
        GenPostingType: Enum "General Posting Type";
    begin
        CreateSalesHeaderForRSEInvoicing(SalesHeader, DocumentType, Customer, GeneralPostingSetup, VATPostingSetup);

        case LineType of
            LineType::Item:
                LineTypeNo := CreateItem(GeneralPostingSetup."Gen. Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
            LineType::"G/L Account":
                LineTypeNo := CreateGLAccount(GeneralPostingSetup, VATPostingSetup, GenPostingType::" ");
        end;
        _LibrarySales.CreateSalesLine(SalesLine, SalesHeader, LineType, LineTypeNo, _LibraryRandom.RandDec(10, 2));
    end;

    local procedure CreateSalesHeaderForRSEInvoicing(var SalesHeader: Record "Sales Header"; DocumentType: Enum "Sales Document Type"; Customer: Record Customer; GeneralPostingSetup: Record "General Posting Setup"; VATPostingSetup: Record "VAT Posting Setup"): Code[20]
    var
        PaymentMethod: Record "Payment Method";
    begin
        if DocumentType in [DocumentType::"Credit Memo"] then
            _LibrarySales.CreateSalesCreditMemo(SalesHeader)
        else
            _LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, Customer."No.");
        CreatePaymentMethod(PaymentMethod, GeneralPostingSetup, VATPostingSetup);
        SalesHeader."Payment Method Code" := PaymentMethod.Code;
        SalesHeader.Modify();
        CreateSalesHeaderAux(SalesHeader);
        exit(SalesHeader."No.");
    end;

    local procedure CreateSalesHeaderAux(SalesHeader: Record "Sales Header")
    var
        RSEIAuxSalesHeader: Record "NPR RS EI Aux Sales Header";
    begin
        RSEIAuxSalesHeader.ReadRSEIAuxSalesHeaderFields(SalesHeader);
        RSEIAuxSalesHeader."NPR RS EI Send To SEF" := true;
        RSEIAuxSalesHeader."NPR RS EI Tax Liability Method" := RSEIAuxSalesHeader."NPR RS EI Tax Liability Method"::"3";
        RSEIAuxSalesHeader.SaveRSEIAuxSalesHeaderFields();
    end;

    internal procedure CreateAndPostPrepaymentSalesHeader(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; Customer: Record Customer;
                                                        GenPostingSetup: Record "General Posting Setup"; VATPostingSetup: Record "VAT Posting Setup") PostedDocumentNo: Code[20]
    var
        VATPostingSetup2: Record "VAT Posting Setup";
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        GLAccount: Record "G/L Account";
        PrepmtNoSeries: Code[20];
        GenPostingType: Enum "General Posting Type";
    begin
        PrepmtNoSeries := CreateNumberSeries();
        SalesHeader."Prepayment No. Series" := PrepmtNoSeries;
        PrepmtNoSeries := CreateNumberSeries();
        SalesHeader."Prepmt. Cr. Memo No. Series" := PrepmtNoSeries;

        SalesLine.SetLoadFields("Gen. Bus. Posting Group", "Gen. Prod. Posting Group", "VAT Bus. Posting Group");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
        GLAccount.Get(GenPostingSetup."Sales Prepayments Account");
        CreateVATPostingSetup(VATPostingSetup2, SalesLine."VAT Bus. Posting Group", GLAccount."VAT Prod. Posting Group", GenPostingSetup);
        CreateRSVATPostingSetup(VATPostingSetup2, GenPostingSetup);

        CreateRSCustomerPostingGroup(Customer, GenPostingSetup, VATPostingSetup);

        CreateBankAccountLedgerEntry(BankAccountLedgerEntry, Customer);
        CreateRSSalesHeaderAuxData(SalesHeader, BankAccountLedgerEntry."Entry No.");

        PostedDocumentNo := _LibrarySales.PostSalesPrepaymentInvoice(SalesHeader);
    end;

    internal procedure CreateAndPostSalesCreditMemo(var SalesLine: Record "Sales Line"; GeneralPostingSetup: Record "General Posting Setup"; VATPostingSetup: Record "VAT Posting Setup"; DocumentNo: Code[20]): Code[20]
    var
        SalesHeader: Record "Sales Header";
        SalesLine2: Record "Sales Line";
        PaymentMethod: Record "Payment Method";
    begin
        SalesCreditMemoCopyDocument(SalesHeader, SalesLine."Sell-to Customer No.", DocumentNo);
        CreatePaymentMethod(PaymentMethod, GeneralPostingSetup, VATPostingSetup);
        SalesHeader."Payment Method Code" := PaymentMethod.Code;
        SalesHeader."Applies-to Doc. Type" := SalesHeader."Applies-to Doc. Type"::Invoice;
        SalesHeader."Applies-to Doc. No." := DocumentNo;
        SalesHeader.Modify();

        SalesLine2.Init();
        SalesLine2.Copy(SalesLine);

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if not SalesLine.IsEmpty() then
            SalesLine.DeleteAll();

        SalesLine2."Document Type" := SalesHeader."Document Type";
        SalesLine2."Document No." := SalesHeader."No.";
        SalesLine2.Validate(Quantity, -SalesLine.Quantity);
        SalesLine2."Qty. to Ship" := 0;
        SalesLine2.Validate("Unit Price", -SalesLine."Unit Price");
        SalesLine2.Insert();
        CreateSalesHeaderAux(SalesHeader);
        exit(_LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure SalesCreditMemoCopyDocument(var SalesHeader: Record "Sales Header"; CustomerNo: Code[20]; DocumentNo: Code[20])
    begin
        _LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::"Credit Memo", CustomerNo);
        _LibrarySales.CopySalesDocument(SalesHeader, "Sales Document Type From"::"Posted Invoice", DocumentNo, true, false);
    end;

    #endregion Library RS E-Invoice Documents

    #region Library RS E-Invoice Misc

    internal procedure CreateItem(GenProductPostingGroup: Code[20]; VATProdPostingGroup: Code[20]): Code[20]
    var
        Item: Record Item;
        UnitOfMeasureCode: Code[10];
    begin
        _LibraryInventory.CreateItem(Item);
        Item.Validate("Gen. Prod. Posting Group", GenProductPostingGroup);
        Item.Validate("VAT Prod. Posting Group", VATProdPostingGroup);
        Item.Validate("Unit Price", _LibraryRandom.RandDec(10, 2));
        UnitOfMeasureCode := CreateUnitOfMeasure();
        Item.Validate("Base Unit of Measure", UnitOfMeasureCode);
        CreateUOMMapping(UnitofMeasureCode);
        Item.Modify(true);

        exit(Item."No.");
    end;

    internal procedure CreateGLAccount(GenPostingSetup: Record "General Posting Setup"; VATPostingSetup: Record "VAT Posting Setup"; GeneralPostingType: Enum "General Posting Type"): Code[20]
    var
        GLAccount: Record "G/L Account";
    begin
        _LibraryERM.CreateGLAccount(GLAccount);
        GLAccount.Validate("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
        GLAccount.Validate("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        GLAccount.Validate("Gen. Bus. Posting Group", GenPostingSetup."Gen. Bus. Posting Group");
        GLAccount.Validate("Gen. Prod. Posting Group", GenPostingSetup."Gen. Prod. Posting Group");
        GLAccount.Validate("Gen. Posting Type", GeneralPostingType);
        GLAccount.Modify(true);

        exit(GLAccount."No.");
    end;

    local procedure CreateBankAccountLedgerEntry(var BankAccountLedgerEntry: Record "Bank Account Ledger Entry"; Customer: Record Customer)
    var
        LastEntryNo: Integer;
    begin
        if BankAccountLedgerEntry.FindLast() then
            LastEntryNo := BankAccountLedgerEntry."Entry No."
        else
            LastEntryNo := 0;

        BankAccountLedgerEntry.Reset();
        Clear(BankAccountLedgerEntry);

        BankAccountLedgerEntry.Init();
        BankAccountLedgerEntry."Entry No." := LastEntryNo + 1;
        BankAccountLedgerEntry."Bal. Account Type" := BankAccountLedgerEntry."Bal. Account Type"::Customer;
        BankAccountLedgerEntry."Bal. Account No." := Customer."No.";
        BankAccountLedgerEntry.Validate(Amount, 100);
        BankAccountLedgerEntry.Validate("Remaining Amount", 100);
        BankAccountLedgerEntry."Document No." := '123';
        BankAccountLedgerEntry.Insert();
    end;

    internal procedure CreatePurchaseLine(PurchaseHeader: Record "Purchase Header"; GenProductPostingGroup: Code[20]; VATProductPostingGroup: Code[20]; Amount: Decimal)
    var
        PurchaseLine: Record "Purchase Line";
        ItemNo: Code[20];
    begin
        ItemNo := CreateItem(GenProductPostingGroup, VATProductPostingGroup);
        _LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, ItemNo, _LibraryRandom.RandDec(2, 2));
        PurchaseLine.Validate("Amount Including VAT", Amount);
        PurchaseLine.Modify();
    end;

    internal procedure GetPurchaseHeaderNo(var PurchaseHeaderNo: Code[20])
    begin
        PurchaseHeaderNo := _PurchaseHeaderNo;
    end;

    internal procedure GetPurchHeaderAuxAmount(var LineAmount: Decimal; PurchaseHeader: Record "Purchase Header")
    var
        RSEIAuxPurchHeader: Record "NPR RS EI Aux Purch. Header";
    begin
        RSEIAuxPurchHeader.ReadRSEIAuxPurchHeaderFields(PurchaseHeader);
        LineAmount := RSEIAuxPurchHeader."NPR RS EI Total Amount";
    end;
    #endregion Library RS E-Invoice Misc

    #region Library RS E-Invoice Initial Data

    internal procedure CreateCustomer(var Customer: Record Customer; GenBusinessPostingGroup: Code[20]; VATBusinessPostingGroup: Code[20])
    var
        RSEIAuxCustomer: Record "NPR RS EI Aux Customer";
    begin
        _LibrarySales.CreateCustomer(Customer);

        Customer."Gen. Bus. Posting Group" := GenBusinessPostingGroup;
        Customer."VAT Bus. Posting Group" := VATBusinessPostingGroup;
        Customer."Registration Number" := GetTestRegistrationNo();
        Customer."VAT Registration No." := GetTestVATRegistrationNo();
        Customer.Address := GetTestAddress();
        Customer.City := GetTestCity();
        Customer."Post Code" := GetTestPostCode();
        Customer."Country/Region Code" := GetTestCountryRegionCode();
        Customer.Modify();

        RSEIAuxCustomer.ReadRSEIAuxCustomerFields(Customer);
        RSEIAuxCustomer."NPR RS E-Invoice Customer" := true;
        RSEIAuxCustomer.SaveRSEIAuxCustomerFields();
    end;

    internal procedure CreatePaymentMethod(var PaymentMethod: Record "Payment Method"; GeneralPostingSetup: Record "General Posting Setup"; VATPostingSetup: Record "VAT Posting Setup")
    var
        RSEIPaymentMethodMapp: Record "NPR RS EI Payment Method Mapp.";
        GenPostingType: Enum "General Posting Type";
    begin
        _LibraryInventory.CreatePaymentMethod(PaymentMethod);
        PaymentMethod."Bal. Account Type" := PaymentMethod."Bal. Account Type"::"G/L Account";
        PaymentMethod."Bal. Account No." := CreateGLAccount(GeneralPostingSetup, VATPostingSetup, GenPostingType::" ");
        PaymentMethod.Modify(true);
        RSEIPaymentMethodMapp.Init();
        RSEIPaymentMethodMapp."Payment Method Code" := PaymentMethod.Code;
        RSEIPaymentMethodMapp."RS EI Payment Means" := RSEIPaymentMethodMapp."RS EI Payment Means"::"30";
        RSEIPaymentMethodMapp.Insert();
    end;

    internal procedure CreateUnitOfMeasure() UnitOfMeasureCode: Code[10]
    var
        UnitofMeasure: Record "Unit of Measure";
    begin
        _LibraryInventory.CreateUnitOfMeasureCode(UnitofMeasure);
        exit(UnitofMeasure.Code)
    end;

    local procedure CreateUOMMapping(UnitOfMeasureCode: Code[10])
    var
        RSEIUOMMapping: Record "NPR RS EI UOM Mapping";
        RSEIAllowedUOM: Record "NPR RS EI Allowed UOM";
    begin
        RSEIAllowedUOM.Get('H87');
        if not RSEIUOMMapping.Get(UnitofMeasureCode) then begin
            RSEIUOMMapping.Init();
            RSEIUOMMapping."Unit of Measure" := UnitofMeasureCode;
            RSEIUOMMapping."RS EI UOM Code" := RSEIAllowedUOM.Code;
            RSEIUOMMapping."RS EI UOM Name" := RSEIAllowedUOM.Name;
            RSEIUOMMapping.Insert();
        end;
    end;

    internal procedure CreateNumberSeries(): Text
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        LibraryUtility: Codeunit "Library - Utility";
    begin
        LibraryUtility.CreateNoSeries(NoSeries, true, false, false);
        LibraryUtility.CreateNoSeriesLine(NoSeriesLine, NoSeries.Code, 'TEST_1', 'TEST_99999999');
        exit(NoSeries.Code);
    end;

    internal procedure CreateCustomerPrepmtGenJnlLine(var GenJournalLine: Record "Gen. Journal Line"; CustomerNo: Code[20]; Amount: Decimal)
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        BankAccount: Record "Bank Account";
    begin
        CreatePaymentsJournalBatch(GenJournalBatch);
        _LibraryERM.CreateGeneralJnlLine(GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalLine."Document Type"::Payment, GenJournalLine."Account Type"::Customer, CustomerNo, -Amount);
        _LibraryERM.CreateBankAccount(BankAccount);

        GenJournalLine.Validate("Bal. Account Type", GenJournalLine."Bal. Account Type"::"Bank Account");
        GenJournalLine.Validate("Bal. Account No.", BankAccount."No.");
        GenJournalLine.Validate(Prepayment, true);
        GenJournalLine.Modify(true);
    end;

    local procedure CreatePaymentsJournalBatch(var GenJournalBatch: Record "Gen. Journal Batch")
    var
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        GenJournalTemplate.SetRange(Recurring, false);
        GenJournalTemplate.SetRange(Type, GenJournalTemplate.Type::Payments);
        _LibraryERM.FindGenJournalTemplate(GenJournalTemplate);
        _LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        GenJournalBatch.Validate("Bal. Account No.", _LibraryERM.CreateGLAccountNo());
        GenJournalBatch.Modify(true);
    end;

    #endregion Library RS E-Invoice Initial Data

    #region Library RS E-Invoice Additional Setups

    internal procedure CreateRSLocalizationSetup()
    var
        RSLocalisationSetup: Record "NPR RS Localisation Setup";
    begin
        RSLocalisationSetup.DeleteAll();
        RSLocalisationSetup.Init();
        RSLocalisationSetup."Enable RS Local" := true;
        RSLocalisationSetup.Insert();
    end;

    internal procedure CreateRSVATPostingSetup(VATPostingSetup: Record "VAT Posting Setup"; GenPostingSetup: Record "General Posting Setup")
    var
        RSVATPostingSetup: Record "NPR RS VAT Posting Setup";
        GenPostingType: Enum "General Posting Type";
    begin
        if not RSVATPostingSetup.Get(VATPostingSetup.SystemId) then begin
            RSVATPostingSetup.Init();
            RSVATPostingSetup."Table SystemId" := VATPostingSetup.SystemId;
            RSVATPostingSetup.Validate("Sales Prep. VAT Account", CreateGLAccount(GenPostingSetup, VATPostingSetup, GenPostingType::" "));
            RSVATPostingSetup.Insert();
        end;
    end;

    local procedure CreateRSCustomerPostingGroup(Customer: Record Customer; GeneralPostingSetup: Record "General Posting Setup"; VATPostingSetup: Record "VAT Posting Setup")
    var
        GLAccount: Record "G/L Account";
        CustomerPostingGroup: Record "Customer Posting Group";
        RSCustomerPostingGroup: Record "NPR RS Customer Posting Group";
        GenPostingType: Enum "General Posting Type";
    begin
        CustomerPostingGroup.Get(Customer."Customer Posting Group");
        RSCustomerPostingGroup.Read(CustomerPostingGroup.SystemId);
        GLAccount.Get(CreateGLAccount(GeneralPostingSetup, VATPostingSetup, GenPostingType::" "));
        GLAccount."Account Category" := GLAccount."Account Category"::Assets;
        GLAccount.Modify(true);
        RSCustomerPostingGroup.Validate("Prepayment Account", GLAccount."No.");
        RSCustomerPostingGroup.Save();
    end;

    internal procedure CreateVendorPostingGroup(var VendorPostingGroup: Record "Vendor Posting Group")
    begin
        _LibraryPurchase.CreateVendorPostingGroup(VendorPostingGroup);
    end;

    local procedure CreateRSSalesHeaderAuxData(SalesHeader: Record "Sales Header"; BankAccountLedgEntryNo: Integer)
    var
        RSSalesHeader: Record "NPR RS Sales Header";
    begin
        RSSalesHeader.Read(SalesHeader.SystemId);
        RSSalesHeader.Validate("Applies-to Bank Entry", BankAccountLedgEntryNo);
        RSSalesHeader.Save();
    end;

    #endregion Library RS E-Invoice Additional Setups

    #region Library RS E-Invoice Asserts

    internal procedure VerifySalesDocumentIsSentToSEFAndCleanup(DocumentType: Enum "Sales Document Type"; DocumentNo: Code[20])
    var
        RSEInvoiceDocument: Record "NPR RS E-Invoice Document";
        Assert: Codeunit Assert;
    begin
        RSEInvoiceDocument.SetLoadFields("Document Type", "Sales Invoice ID");
        RSEInvoiceDocument.SetRange("Document No.", DocumentNo);
        RSEInvoiceDocument.FindLast();
        case DocumentType of
            DocumentType::Order, DocumentType::Invoice:
                Assert.IsTrue(RSEInvoiceDocument."Document Type" = RSEInvoiceDocument."Document Type"::"Sales Invoice", 'RS E-Invoice document type must be Sales Invoice');
            DocumentType::"Credit Memo":
                Assert.IsTrue(RSEInvoiceDocument."Document Type" = RSEInvoiceDocument."Document Type"::"Sales Cr. Memo", 'RS E-Invoice document type must be Sales Cr. Memo');
        end;
        Assert.IsTrue(Format(RSEInvoiceDocument."Sales Invoice ID") <> '', 'Sales Invoice ID must be received from SEF');

        RSEInvoiceDocument.Delete();
    end;

    internal procedure VerifyPurchaseDocumentIsSentToSEFAndCleanup(DocumentType: Enum "Purchase Document Type"; DocumentNo: Code[20]; CheckPosted: Boolean)
    var
        RSEInvoiceDocument: Record "NPR RS E-Invoice Document";
        Assert: Codeunit Assert;
    begin
        RSEInvoiceDocument.SetLoadFields("Document Type", Created, Posted);
        RSEInvoiceDocument.SetRange("Document No.", DocumentNo);
        RSEInvoiceDocument.FindLast();
        case DocumentType of
            DocumentType::Order:
                Assert.IsTrue(RSEInvoiceDocument."Document Type" = RSEInvoiceDocument."Document Type"::"Purchase Order", 'RS E-Invoice document type must be Purchase Order');
            DocumentType::Invoice:
                Assert.IsTrue(RSEInvoiceDocument."Document Type" = RSEInvoiceDocument."Document Type"::"Purchase Invoice", 'RS E-Invoice document type must be Purchase Invoice');
            DocumentType::"Credit Memo":
                Assert.IsTrue(RSEInvoiceDocument."Document Type" = RSEInvoiceDocument."Document Type"::"Purchase Cr. Memo", 'RS E-Invoice document type must be Purchase Cr. Memo');
        end;
        Assert.IsTrue(RSEInvoiceDocument.Created, 'RS E-Invoice Purchase Document was not Created');

        if CheckPosted then
            Assert.IsTrue(RSEInvoiceDocument.Posted, 'RS E-Invoice Purchase Document was not Posted');

        RSEInvoiceDocument.Delete();
    end;

    internal procedure VerifyPurchaseDocumentIsImported(DocumentType: Enum "NPR RS EI Document Type"; PurchaseInvoiceId: Integer)
    var
        RSEInvoiceDocument: Record "NPR RS E-Invoice Document";
        Assert: Codeunit Assert;
    begin
        RSEInvoiceDocument.SetRange("Document Type", DocumentType);
        RSEInvoiceDocument.SetRange("Purchase Invoice ID", PurchaseInvoiceId);
        RSEInvoiceDocument.FindLast();
        Assert.IsTrue(RSEInvoiceDocument.Created, 'RS E-Invoice Document successfully imported');
    end;

    #endregion Library RS E-Invoice Asserts

    #region Library RS E-Invoice - Helper Procedures

    local procedure GetTestVATRegistrationNo(): Text[20]
    begin
        exit('RS111911206');
    end;

    local procedure GetTestRegistrationNo(): Text[20]
    begin
        exit('21567850')
    end;

    local procedure GetTestAddress(): Text[100]
    begin
        exit('Test Address');
    end;

    local procedure GetTestCity(): Text[30]
    begin
        exit('Test City');
    end;

    local procedure GetTestPostCode(): Code[20]
    begin
        exit('34000');
    end;

    local procedure GetTestCountryRegionCode(): Code[10]
    begin
        exit('RS');
    end;

    local procedure GetTestBankAccountNo(): Text[30]
    begin
        exit('123123123123');
    end;

    #endregion Library RS E-Invoice - Helper Procedures

    #region Library RS E-Invoice - Event Subscribers

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RS EI Communication Mgt.", 'OnBeforeSendHttpRequestForGetAllowedUOM', '', false, false)]
    local procedure OnBeforeSendHttpRequestForGetAllowedUOM(sender: Codeunit "NPR RS EI Communication Mgt."; RequestMessage: HttpRequestMessage; var ResponseText: Text; var IsHandled: Boolean)
    begin
        ResponseText := '[' +
        '{' +
            '"Code": "H87",' +
            '"Symbol": null,' +
            '"NameEng": "pc",' +
            '"NameSrbLtn": "kom",' +
            '"NameSrbCyr": "kом",' +
            '"IsOnShortList": true' +
        '},' +
        '{' +
            '"Code": "KGM",' +
            '"Symbol": null,' +
            '"NameEng": "kg",' +
            '"NameSrbLtn": "kg",' +
            '"NameSrbCyr": "kг",' +
            '"IsOnShortList": true' +
        '},' +
        '{' +
            '"Code": "KMT",' +
            '"Symbol": null,' +
            '"NameEng": "km",' +
            '"NameSrbLtn": "km",' +
            '"NameSrbCyr": "kм",' +
            '"IsOnShortList": true' +
        '},' +
        '{' +
            '"Code": "GRM",' +
            '"Symbol": null,' +
            '"NameEng": "g",' +
            '"NameSrbLtn": "g",' +
            '"NameSrbCyr": "г",' +
            '"IsOnShortList": true' +
        '},' +
        '{' +
            '"Code": "MTR",' +
            '"Symbol": null,' +
            '"NameEng": "m",' +
            '"NameSrbLtn": "m",' +
            '"NameSrbCyr": "м",' +
            '"IsOnShortList": true' +
        '},' +
        '{' +
            '"Code": "LTR",' +
            '"Symbol": null,' +
            '"NameEng": "l",' +
            '"NameSrbLtn": "l",' +
            '"NameSrbCyr": "л",' +
            '"IsOnShortList": true' +
        '},' +
        '{' +
            '"Code": "TNE",' +
            '"Symbol": null,' +
            '"NameEng": "t",' +
            '"NameSrbLtn": "t",' +
            '"NameSrbCyr": "т",' +
            '"IsOnShortList": true' +
        '},' +
        '{' +
            '"Code": "MTK",' +
            '"Symbol": null,' +
            '"NameEng": "m2",' +
            '"NameSrbLtn": "m2",' +
            '"NameSrbCyr": "м2",' +
            '"IsOnShortList": true' +
        '},' +
        '{' +
            '"Code": "MTQ",' +
            '"Symbol": null,' +
            '"NameEng": "m3",' +
            '"NameSrbLtn": "m3",' +
            '"NameSrbCyr": "м3",' +
            '"IsOnShortList": true' +
        '},' +
        '{' +
            '"Code": "MIN",' +
            '"Symbol": null,' +
            '"NameEng": "min",' +
            '"NameSrbLtn": "min",' +
            '"NameSrbCyr": "мин",' +
            '"IsOnShortList": true' +
        '},' +
        '{' +
            '"Code": "HUR",' +
            '"Symbol": null,' +
            '"NameEng": "h",' +
            '"NameSrbLtn": "h",' +
            '"NameSrbCyr": "h",' +
            '"IsOnShortList": true' +
        '},' +
        '{' +
            '"Code": "DAY",' +
            '"Symbol": null,' +
            '"NameEng": "d",' +
            '"NameSrbLtn": "d",' +
            '"NameSrbCyr": "д",' +
            '"IsOnShortList": true' +
        '},' +
        '{' +
            '"Code": "MON",' +
            '"Symbol": null,' +
            '"NameEng": "M",' +
            '"NameSrbLtn": "M",' +
            '"NameSrbCyr": "М",' +
            '"IsOnShortList": true' +
        '},' +
        '{' +
            '"Code": "ANN",' +
            '"Symbol": null,' +
            '"NameEng": "y",' +
            '"NameSrbLtn": "god",' +
            '"NameSrbCyr": "гoд",' +
            '"IsOnShortList": true' +
        '},' +
        '{' +
            '"Code": "KWH",' +
            '"Symbol": null,' +
            '"NameEng": "kWh",' +
            '"NameSrbLtn": "kWh",' +
            '"NameSrbCyr": "kWh",' +
            '"IsOnShortList": true' +
        '}];';
        sender.FillAllowedUOMs(ResponseText);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RS EI Communication Mgt.", 'OnBeforeSendHttpRequestForGetTaxExemptionReasons', '', false, false)]
    local procedure OnBeforeSendHttpRequestForGetTaxExemptionReasons(sender: Codeunit "NPR RS EI Communication Mgt."; RequestMessage: HttpRequestMessage; var ResponseText: Text; var IsHandled: Boolean)
    begin
        ResponseText := '[' +
            '{' +
                '"ReasonId": 71,' +
                '"Key": "PDV-RS-6-1-1",' +
                '"Law": "Zakon o porezu na dodatu vrednost",' +
                '"Article": "6",' +
                '"Paragraph": "1",' +
                '"Point": "1",' +
                '"Subpoint": null,' +
                '"Text": "Smatra se da promet dobara i usluga nije izvršen kod prenosa celokupne ili dela imovine, sa ili bez naknade, ili kao ulog, ako je sticalac poreski obveznik ili tim prenosom postane poreski obveznik i ako produži da obavlja istu delatnost",' +
                '"FreeFormNote": null,' +
                '"ActiveFrom": "1900-01-01T00:00:00.0000000+00:00",' +
                '"ActiveTo": null,' +
                '"Category": "R"' +
            '},' +
            '{' +
                '"ReasonId": 72,' +
                '"Key": "PDV-RS-6a",' +
                '"Law": "Zakon o porezu na dodatu vrednost",' +
                '"Article": "6a",' +
                '"Paragraph": null,' +
                '"Point": null,' +
                '"Subpoint": null,' +
                '"Text": "Smatra se da, u smislu ovog zakona, promet dobara i usluga koji vrši davalac koncesije koncesionaru, odnosno koncesionar davaocu koncesije u okviru realizacije ugovora o javno-privatnom partnerstvu sa elementima koncesije, ' +
                'zaključenog u skladu sa zakonom kojim se uređuju javno-privatno partnerstvo i koncesije, nije izvršen, ako su davalac koncesije i koncesionar obveznici PDV koji bi, u slučaju kada bi se taj promet smatrao izvršenim, imali u potpunosti pravo na odbitak prethodnog poreza u skladu sa ovim zakonom",' +
                '"FreeFormNote": null,' +
                '"ActiveFrom": "1900-01-01T00:00:00.0000000+00:00",' +
                '"ActiveTo": null,' +
                '"Category": "R"' +
            '}]';
        sender.FillTaxExemptionReasonList(ResponseText);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RS EI Communication Mgt.", 'OnBeforeSendHttpRequestForSalesDocument', '', false, false)]
    local procedure OnBeforeSendHttpRequestForSalesDocument(sender: Codeunit "NPR RS EI Communication Mgt."; RequestMessage: HttpRequestMessage; var ResponseText: Text; var RSEInvoiceDocument: Record "NPR RS E-Invoice Document"; var IsHandled: Boolean)
    begin
        ResponseText :=
                '{' +
                '"InvoiceId":3267322,' +
                '"PurchaseInvoiceId":3267322,' +
                '"SalesInvoiceId":3357127' +
                '}';
        sender.ProcessSendSalesInvoiceDocumentResponse(RSEInvoiceDocument, ResponseText);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RS EI Communication Mgt.", 'OnBeforeSendHttpRequestForGetSalesDocumentStatus', '', false, false)]
    local procedure OnBeforeSendHttpRequestForGetSalesDocumentStatus(sender: Codeunit "NPR RS EI Communication Mgt."; var RSEInvoiceDocument: Record "NPR RS E-Invoice Document"; var ResponseText: Text; var IsHandled: Boolean)
    begin
        ResponseText :=
        '{' +
            '"InvoiceId": 12345678,' +
            '"GlobUniqId": "string",' +
            '"Comment": "string",' +
            '"CirStatus": "None",' +
            '"CirInvoiceId": "string",' +
            '"Version": 0,' +
            '"LastModifiedUtc": "2024-08-06T13:30:20.829Z",' +
            '"CirSettledAmount": 0,' +
            '"VatNumberFactoringCompany": "string",' +
            '"FactoringContractNumber": "string",' +
            '"CancelComment": "string",' +
            '"StornoComment": "string",' +
            '"Status": "Approved"' +
        '}';
        sender.ProcessGetSalesDocumentStatusResponse(RSEInvoiceDocument, ResponseText);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnValidateSellToCustomerNoOnAfterCalcShouldSkipConfirmSellToCustomerDialog', '', false, false)]
    local procedure OnValidateSellToCustomerNoOnAfterCalcShouldSkipConfirmSellToCustomerDialog(var SalesHeader: Record "Sales Header"; var ShouldSkipConfirmSellToCustomerDialog: Boolean; var ConfirmedShouldBeFalse: Boolean)
    begin
        ShouldSkipConfirmSellToCustomerDialog := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnValidateBillToCustomerNoOnAfterCheckBilltoCustomerNoChanged', '', false, false)]
    local procedure OnValidateBillToCustomerNoOnAfterCheckBilltoCustomerNoChanged(var SalesHeader: Record "Sales Header"; xSalesHeader: Record "Sales Header"; CurrFieldNo: Integer; var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RS EI Communication Mgt.", 'OnBeforeSendHttpRequestforGetPurchaseInvoice', '', false, false)]
    local procedure OnBeforeSendHttpRequestforGetPurchaseInvoice(sender: Codeunit "NPR RS EI Communication Mgt."; var TempRSEInvoiceDocument: Record "NPR RS E-Invoice Document"; var ResponseText: Text; var IsHandled: Boolean)
    var
        RSEIInPurchInvMgt: Codeunit "NPR RS EI In Purch. Inv. Mgt.";
    begin
        ResponseText :=
                '<env:DocumentEnvelope xmlns:env="urn:eFaktura:MinFinrs:envelop:schema">' +
                    '<env:DocumentHeader>' +
                        '<env:SalesInvoiceId>3276604</env:SalesInvoiceId>' +
                        '<env:PurchaseInvoiceId>3184198</env:PurchaseInvoiceId>' +
                        '<env:DocumentId>3e443d52-d880-4bfa-bc64-b4a9fee2b809</env:DocumentId>' +
                        '<env:CreationDate>2024-04-30</env:CreationDate>' +
                        '<env:SendingDate>2024-04-30</env:SendingDate>' +
                    '</env:DocumentHeader>' +
                    '<env:DocumentBody>' +
                        '<Invoice xmlns:cec="urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2" ' +
                            'xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2" ' +
                            'xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2" ' +
                            'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" ' +
                            'xmlns:xsd="http://www.w3.org/2001/XMLSchema" ' +
                            'xmlns:sbt="http://mfin.gov.rs/srbdt/srbdtext" ' +
                            'xmlns="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2">' +
                            '<cbc:CustomizationID>urn:cen.eu:en16931:2017#compliant#urn:mfin.gov.rs:srbdt:2022</cbc:CustomizationID>' +
                            '<cbc:ID>PR-0002</cbc:ID>' +
                            '<cbc:IssueDate>2024-04-30</cbc:IssueDate>' +
                            '<cbc:DueDate>2024-04-30</cbc:DueDate>' +
                            '<cbc:InvoiceTypeCode>380</cbc:InvoiceTypeCode>' +
                            '<cbc:DocumentCurrencyCode>RSD</cbc:DocumentCurrencyCode>' +
                            '<cac:InvoicePeriod>' +
                                '<cbc:DescriptionCode>3</cbc:DescriptionCode>' +
                            '</cac:InvoicePeriod>' +
                            '<cac:ContractDocumentReference>' +
                                '<cbc:ID>PR-0002</cbc:ID>' +
                            '</cac:ContractDocumentReference>' +
                            '<cac:AccountingSupplierParty>' +
                                '<cac:Party>' +
                                    '<cbc:EndpointID schemeID="9948">113454392</cbc:EndpointID>' +
                                    '<cac:PartyName>' +
                                        '<cbc:Name>BCILITY DOO</cbc:Name>' +
                                    '</cac:PartyName>' +
                                    '<cac:PostalAddress>' +
                                        '<cbc:StreetName>Kneza Milosa 22</cbc:StreetName>' +
                                        '<cbc:CityName>Čačak</cbc:CityName>' +
                                        '<cbc:PostalZone>32000</cbc:PostalZone>' +
                                        '<cac:Country>' +
                                            '<cbc:IdentificationCode>RS</cbc:IdentificationCode>' +
                                        '</cac:Country>' +
                                    '</cac:PostalAddress>' +
                                    '<cac:PartyTaxScheme>' +
                                        '<cbc:CompanyID>RS113454392</cbc:CompanyID>' +
                                        '<cac:TaxScheme>' +
                                            '<cbc:ID>VAT</cbc:ID>' +
                                        '</cac:TaxScheme>' +
                                    '</cac:PartyTaxScheme>' +
                                    '<cac:PartyLegalEntity>' +
                                        '<cbc:RegistrationName>BCILITY DOO</cbc:RegistrationName>' +
                                        '<cbc:CompanyID>21870005</cbc:CompanyID>' +
                                    '</cac:PartyLegalEntity>' +
                                '</cac:Party>' +
                            '</cac:AccountingSupplierParty>' +
                            '<cac:AccountingCustomerParty>' +
                                '<cac:Party>' +
                                    '<cbc:EndpointID schemeID="9948">113454392</cbc:EndpointID>' +
                                    '<cac:PartyName>' +
                                        '<cbc:Name>BCILITY DOO</cbc:Name>' +
                                    '</cac:PartyName>' +
                                    '<cac:PostalAddress>' +
                                        '<cbc:StreetName>Kneza Milosa 22</cbc:StreetName>' +
                                        '<cbc:CityName>Čačak</cbc:CityName>' +
                                        '<cbc:PostalZone>32000</cbc:PostalZone>' +
                                        '<cac:Country>' +
                                            '<cbc:IdentificationCode>RS</cbc:IdentificationCode>' +
                                        '</cac:Country>' +
                                    '</cac:PostalAddress>' +
                                    '<cac:PartyTaxScheme>' +
                                        '<cbc:CompanyID>RS113454392</cbc:CompanyID>' +
                                        '<cac:TaxScheme>' +
                                            '<cbc:ID>VAT</cbc:ID>' +
                                        '</cac:TaxScheme>' +
                                    '</cac:PartyTaxScheme>' +
                                    '<cac:PartyLegalEntity>' +
                                        '<cbc:RegistrationName>BCILITY DOO</cbc:RegistrationName>' +
                                        '<cbc:CompanyID>21870005</cbc:CompanyID>' +
                                    '</cac:PartyLegalEntity>' +
                                '</cac:Party>' +
                            '</cac:AccountingCustomerParty>' +
                            '<cac:Delivery>' +
                                '<cbc:ActualDeliveryDate>2024-04-29</cbc:ActualDeliveryDate>' +
                            '</cac:Delivery>' +
                            '<cac:PaymentMeans>' +
                                '<cbc:PaymentMeansCode>10</cbc:PaymentMeansCode>' +
                                '<cac:PayeeFinancialAccount>' +
                                    '<cbc:ID>265-3030310001535-53</cbc:ID>' +
                                '</cac:PayeeFinancialAccount>' +
                            '</cac:PaymentMeans>' +
                            '<cac:TaxTotal>' +
                                '<cbc:TaxAmount currencyID="RSD">100.00</cbc:TaxAmount>' +
                                '<cac:TaxSubtotal>' +
                                    '<cbc:TaxableAmount currencyID="RSD">500.00</cbc:TaxableAmount>' +
                                    '<cbc:TaxAmount currencyID="RSD">100.00</cbc:TaxAmount>' +
                                    '<cac:TaxCategory>' +
                                        '<cbc:ID>S</cbc:ID>' +
                                        '<cbc:Percent>20</cbc:Percent>' +
                                        '<cac:TaxScheme>' +
                                            '<cbc:ID>VAT</cbc:ID>' +
                                        '</cac:TaxScheme>' +
                                    '</cac:TaxCategory>' +
                                '</cac:TaxSubtotal>' +
                            '</cac:TaxTotal>' +
                            '<cac:LegalMonetaryTotal>' +
                                '<cbc:LineExtensionAmount currencyID="RSD">500.00</cbc:LineExtensionAmount>' +
                                '<cbc:TaxExclusiveAmount currencyID="RSD">500.00</cbc:TaxExclusiveAmount>' +
                                '<cbc:TaxInclusiveAmount currencyID="RSD">600.00</cbc:TaxInclusiveAmount>' +
                                '<cbc:AllowanceTotalAmount currencyID="RSD">0.00</cbc:AllowanceTotalAmount>' +
                                '<cbc:PrepaidAmount currencyID="RSD">0.00</cbc:PrepaidAmount>' +
                                '<cbc:PayableAmount currencyID="RSD">600.00</cbc:PayableAmount>' +
                            '</cac:LegalMonetaryTotal>' +
                            '<cac:InvoiceLine>' +
                                '<cbc:ID>10000</cbc:ID>' +
                                '<cbc:InvoicedQuantity unitCode="H87">1</cbc:InvoicedQuantity>' +
                                '<cbc:LineExtensionAmount currencyID="RSD">500</cbc:LineExtensionAmount>' +
                                '<cac:Item>' +
                                    '<cbc:Name>Redmi Note 12</cbc:Name>' +
                                    '<cac:SellersItemIdentification>' +
                                        '<cbc:ID>A1</cbc:ID>' +
                                    '</cac:SellersItemIdentification>' +
                                    '<cac:ClassifiedTaxCategory>' +
                                        '<cbc:ID>S</cbc:ID>' +
                                        '<cbc:Percent>20</cbc:Percent>' +
                                        '<cac:TaxScheme>' +
                                            '<cbc:ID>VAT</cbc:ID>' +
                                        '</cac:TaxScheme>' +
                                    '</cac:ClassifiedTaxCategory>' +
                                '</cac:Item>' +
                                '<cac:Price>' +
                                    '<cbc:PriceAmount currencyID="RSD">500</cbc:PriceAmount>' +
                                '</cac:Price>' +
                            '</cac:InvoiceLine>' +
                        '</Invoice>' +
                    '</env:DocumentBody>' +
             '</env:DocumentEnvelope>';
        IsHandled := true;
        RSEIInPurchInvMgt.ProcessGetPurchaseInvoiceDocumentResponse(TempRSEInvoiceDocument, ResponseText, 3184198);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RS EI Communication Mgt.", 'OnBeforeSendHttpRequestForGetPurchaseDocumentStatus', '', false, false)]
    local procedure OnBeforeSendHttpRequestForGetPurchaseDocumentStatus(sender: Codeunit "NPR RS EI Communication Mgt."; RequestMessage: HttpRequestMessage; var ResponseText: Text; var RSEInvoiceDocument: Record "NPR RS E-Invoice Document"; var IsHandled: Boolean)
    begin
        ResponseText := '{' +
                '"Status": "Approved",' +
                '"InvoiceId": 3370695,' +
                '"GlobUniqId": "a93c8523-ed00-4a1c-8c41-e5e5b96c8314",' +
                '"Comment": null,' +
                '"CirStatus": "None",' +
                '"CirInvoiceId": null,' +
                '"Version": 5,' +
                '"LastModifiedUtc": "2024-09-12T11:15:34.2771165+00:00",' +
                '"CirSettledAmount": 0,' +
                '"VatNumberFactoringCompany": null,' +
                '"FactoringContractNumber": null,' +
                '"CancelComment": "",' +
                '"StornoComment": ""' +
            '}';
        IsHandled := true;
        sender.ProcessGetPurchaseDocumentStatusResponse(RSEInvoiceDocument, ResponseText);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RS EI In Purch. Inv. Mgt.", 'OnAfterInsertPurchaseHeaderOnInsertPurchaseDocument', '', false, false)]
    local procedure OnAfterInsertPurchaseHeaderOnInsertPurchaseDocument(PurchaseHeader: Record "Purchase Header")
    begin
        _PurchaseHeaderNo := PurchaseHeader."No.";
    end;

    #endregion Library RS E-Invoice - Event Subscribers

#endif
}