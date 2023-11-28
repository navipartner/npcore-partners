codeunit 85063 "NPR RS Compliance Tests"
{
    Subtype = Test;

    var
        _Item: Record Item;
        _VoucherTypeDefault: Record "NPR NpRv Voucher Type";
        _POSPaymentMethod: Record "NPR POS Payment Method";
        _POSPostingProfile: Record "NPR POS Posting Profile";
        _POSUnit: Record "NPR POS Unit";
        _ReturnReason: Record "Return Reason";
        _Salesperson: Record "Salesperson/Purchaser";
        _Assert: Codeunit Assert;
        _POSSession: Codeunit "NPR POS Session";
        _Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('AllowedTaxRatesUpdateConfirmHandler,GeneralMessageHandler')]
    procedure NormalSalesFiscal()
    var
        RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info";
        LibraryRSFiscal: Codeunit "NPR Library RS Fiscal";
        EntryNumber: Integer;
    begin
        // [Scenario] Check that successful cash sales gets successful response from tax authority when RS audit handler is enabled on POS unit.
        // [Given] Enable Mock response instead of real http response
        BindSubscription(LibraryRSFiscal);

        // [Given] POS and RS audit setup
        InitializeData();

        // [When] Ending normal cash sale
        EntryNumber := DoItemSale();

        UnbindSubscription(LibraryRSFiscal);
        // [Then] For normal cash sale RS Audit Log is created and filled from Tax Authority
        RSPOSAuditLogAuxInfo.SetRange("Audit Entry Type", RSPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry");
        RSPOSAuditLogAuxInfo.SetRange("POS Entry No.", EntryNumber);
        RSPOSAuditLogAuxInfo.FindFirst();
        _Assert.IsTrue(RSPOSAuditLogAuxInfo.Signature <> '', 'Fiscal Bill must be signed from Tax Authority.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('AllowedTaxRatesUpdateConfirmHandler,GeneralMessageHandler')]
    procedure NormalSalesWithRefundFiscal()
    var
        POSEntry: Record "NPR POS Entry";
        RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info";
        LibraryRSFiscal: Codeunit "NPR Library RS Fiscal";
        EntryNumber: Integer;
        ReturnEntryNumber: Integer;
    begin
        // [Scenario] Check that successful cash sales refund gets successful response from tax authority when RS audit handler is enabled on POS unit.
        // [Given] Enable Mock response instead of real http response
        BindSubscription(LibraryRSFiscal);

        // [Given] POS and RS audit setup
        InitializeData();

        // [When] Ending and returning receipt
        EntryNumber := DoItemSale();
        POSEntry.Get(EntryNumber);
        ReturnEntryNumber := DoReturnSale(POSEntry."Document No.");

        UnbindSubscription(LibraryRSFiscal);
        // [Then] For normal cash sale RS Audit Log is created and filled from Tax Authority for both sales and refund
        RSPOSAuditLogAuxInfo.SetRange("Audit Entry Type", RSPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry");
        RSPOSAuditLogAuxInfo.SetRange("POS Entry No.", EntryNumber);
        RSPOSAuditLogAuxInfo.FindFirst();
        _Assert.IsTrue(RSPOSAuditLogAuxInfo.Signature <> '', 'Fiscal Bill must be signed from Tax Authority.');

        RSPOSAuditLogAuxInfo.SetRange("Audit Entry Type", RSPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry");
        RSPOSAuditLogAuxInfo.SetRange("POS Entry No.", ReturnEntryNumber);
        RSPOSAuditLogAuxInfo.FindFirst();
        _Assert.IsTrue(RSPOSAuditLogAuxInfo.Signature <> '', 'Fiscal Bill must be signed from Tax Authority.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('AllowedTaxRatesUpdateConfirmHandler,GeneralMessageHandler')]
    procedure NormalSalesDocumentProformaFiscal()
    var
        Customer: Record Customer;
        Location: Record Location;
        RSAuxSalesHeader: Record "NPR RS Aux Sales Header";
        RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        LibraryRandom: Codeunit "Library - Random";
        LibrarySales: Codeunit "Library - Sales";
        LibraryWarehouse: Codeunit "Library - Warehouse";
        LibraryRSFiscal: Codeunit "NPR Library RS Fiscal";
    begin
        // [Scenario] Check that successful Sales Order Release gets successful response from tax authority when RS audit handler is enabled on POS unit.
        // [Given] Enable Mock response instead of real http response
        BindSubscription(LibraryRSFiscal);

        // [Given] POS and RS audit setup
        InitializeData();

        // [Given] Enable RS Fiscal Application Area
        EnableRSApplicationArea();

        // [When] Ending and returning receipt
        LibrarySales.CreateCustomer(Customer);
        Customer."VAT Bus. Posting Group" := _POSPostingProfile."VAT Bus. Posting Group";
        Customer.Modify();
        LibraryWarehouse.CreateLocation(Location);
        Location."NPR Retail Location" := true;
        Location.Modify();
        LibrarySales.CreateSalesDocumentWithItem(SalesHeader, SalesLine, Enum::"Sales Document Type"::Order, Customer."No.", _Item."No.", LibraryRandom.RandIntInRange(1, 9), Location.Code, Today());
        SalesHeader."Salesperson Code" := _Salesperson.Code;
        SalesHeader.Modify();
        RSAuxSalesHeader.ReadRSAuxSalesHeaderFields(SalesHeader);
        RSAuxSalesHeader."NPR RS POS Unit" := _POSUnit."No.";
        RSAuxSalesHeader.SaveRSAuxSalesHeaderFields();
        LibrarySales.ReleaseSalesDocument(SalesHeader);

        UnbindSubscription(LibraryRSFiscal);
        // [Then] For normal cash sale RS Audit Log is created and filled from Tax Authority
        RSAuxSalesHeader.ReadRSAuxSalesHeaderFields(SalesHeader);
        RSPOSAuditLogAuxInfo.SetRange("Audit Entry Type", RSPOSAuditLogAuxInfo."Audit Entry Type"::"Sales Header");
        RSPOSAuditLogAuxInfo.SetRange("Audit Entry No.", RSAuxSalesHeader."NPR RS Audit Entry No.");
        RSPOSAuditLogAuxInfo.FindFirst();
        _Assert.IsTrue(RSPOSAuditLogAuxInfo."RS Transaction Type" = RSPOSAuditLogAuxInfo."RS Transaction Type"::SALE, 'RS Audit Transaction type must be by type SALE.');
        _Assert.IsTrue(RSPOSAuditLogAuxInfo."RS Invoice Type" = RSPOSAuditLogAuxInfo."RS Invoice Type"::PROFORMA, 'RS Audit Invoice type must be by type PROFORMA.');
        _Assert.IsTrue(RSPOSAuditLogAuxInfo.Signature <> '', 'Fiscal Bill must be signed from Tax Authority.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('AllowedTaxRatesUpdateConfirmHandler,GeneralMessageHandler')]
    procedure NormalSalesDocumentNormalSaleFiscal()
    var
        Customer: Record Customer;
        GLAccount: Record "G/L Account";
        InventoryPostingSetup: Record "Inventory Posting Setup";
        Location: Record Location;
        RSAuxSalesHeader: Record "NPR RS Aux Sales Header";
        RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        LibraryCostAccounting: Codeunit "Library - Cost Accounting";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryRandom: Codeunit "Library - Random";
        LibrarySales: Codeunit "Library - Sales";
        LibraryWarehouse: Codeunit "Library - Warehouse";
        LibraryRSFiscal: Codeunit "NPR Library RS Fiscal";
    begin
        // [Scenario] Check that successful post of Sales Order gets successful response from tax authority when RS audit handler is enabled on POS unit
        // [Given] Enable Mock response instead of real http response
        BindSubscription(LibraryRSFiscal);

        // [Given] POS and RS audit setup
        InitializeData();

        // [Given] Enable RS Fiscal Application Area
        EnableRSApplicationArea();

        // [When] Ending and returning receipt
        LibrarySales.CreateCustomer(Customer);
        Customer."VAT Bus. Posting Group" := _POSPostingProfile."VAT Bus. Posting Group";
        Customer.Modify();
        LibraryWarehouse.CreateLocation(Location);
        Location."NPR Retail Location" := true;
        Location.Modify();
        LibrarySales.CreateSalesDocumentWithItem(SalesHeader, SalesLine, Enum::"Sales Document Type"::Order, Customer."No.", _Item."No.", LibraryRandom.RandIntInRange(1, 9), Location.Code, Today());
        SalesHeader."Salesperson Code" := _Salesperson.Code;
        SalesHeader.Modify();
        RSAuxSalesHeader.ReadRSAuxSalesHeaderFields(SalesHeader);
        RSAuxSalesHeader."NPR RS POS Unit" := _POSUnit."No.";
        RSAuxSalesHeader.SaveRSAuxSalesHeaderFields();
        CreateAndInitCostAccountSetup();
        LibraryCostAccounting.CreateBalanceSheetGLAccount(GLAccount);
        LibraryInventory.CreateInventoryPostingSetup(InventoryPostingSetup, Location.Code, _Item."Inventory Posting Group");
        InventoryPostingSetup."Inventory Account" := GLAccount."No.";
        InventoryPostingSetup.Modify();
        LibrarySales.PostSalesDocument(SalesHeader, true, true);

        UnbindSubscription(LibraryRSFiscal);
        // [Then] For normal cash sale RS Audit Log is created and filled from Tax Authority
        RSPOSAuditLogAuxInfo.SetRange("Audit Entry Type", RSPOSAuditLogAuxInfo."Audit Entry Type"::"Sales Invoice Header");
        RSPOSAuditLogAuxInfo.SetRange("Source Document No.", SalesHeader."Last Posting No.");
        RSPOSAuditLogAuxInfo.FindLast();
        _Assert.IsTrue(RSPOSAuditLogAuxInfo."RS Transaction Type" = RSPOSAuditLogAuxInfo."RS Transaction Type"::SALE, 'RS Audit Transaction type must be by type SALE.');
        _Assert.IsTrue(RSPOSAuditLogAuxInfo."RS Invoice Type" = RSPOSAuditLogAuxInfo."RS Invoice Type"::NORMAL, 'RS Audit Invoice type must be by type NORMAL.');
        _Assert.IsTrue(RSPOSAuditLogAuxInfo.Signature <> '', 'Fiscal Bill must be signed from Tax Authority.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('AllowedTaxRatesUpdateConfirmHandler,GeneralMessageHandler')]
    procedure IssueDefaultVoucherFinishPOSTransactionFiscal()
    // [SCENARIO] Issue Voucher with amount and reference number
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        POSEntry: Record "NPR POS Entry";
        SalePOS: Record "NPR POS Sale";
        RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info";
        Assert: Codeunit Assert;
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryRSFiscal: Codeunit "NPR Library RS Fiscal";
        POSSale: Codeunit "NPR POS Sale";
        VoucherAmount: Decimal;
    begin
        // [Given] Enable Mock response instead of real http response
        BindSubscription(LibraryRSFiscal);

        // [Given] POS and RS audit setup
        InitializeData();

        VoucherAmount := GetRandomVoucherAmount();
        // [GIVEN] POS Transaction
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, _Salesperson, POSSale);
        POSSale.GetCurrentSale(SalePOS);
        // [WHEN] Create line with issue voucher, finish transaction
        CreateVoucherLine(_POSSession, _VoucherTypeDefault.Code, 1, VoucherAmount, '', 0);
        NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethod.Code, VoucherAmount, '');
        // [THEN] Retail Voucher should Exist with correct amount
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindFirst();
        NpRvVoucher.SetRange("Issue Register No.", SalePOS."Register No.");
        NpRvVoucher.SetRange("Issue Document Type", NpRvVoucher."Issue Document Type"::"Audit Roll");
        NpRvVoucher.SetRange("Issue Document No.", POSEntry."Document No.");
        NpRvVoucher.SetRange("Voucher Type", _VoucherTypeDefault.Code);
        Assert.IsTrue(NpRvVoucher.FindFirst(), 'Issued Voucher exists ');
        NpRvVoucher.CalcFields(Amount);
        Assert.AreEqual(VoucherAmount, NpRvVoucher.Amount, 'Issued Voucher Initial Amount not according to test scenario.');

        RSPOSAuditLogAuxInfo.SetRange("Audit Entry Type", RSPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry");
        RSPOSAuditLogAuxInfo.SetRange("POS Entry No.", POSEntry."Entry No.");
        RSPOSAuditLogAuxInfo.FindFirst();
        _Assert.IsTrue(RSPOSAuditLogAuxInfo.Signature <> '', 'Fiscal Bill must be signed from Tax Authority.');
        UnbindSubscription(LibraryRSFiscal);
    end;

    procedure CreateVoucherLine(POSSession: Codeunit "NPR POS Session"; VoucherTypeCode: Code[20]; Quantity: Decimal; VoucherAmount: Decimal; DiscountType: Text; DiscountAmount: Decimal)
    var
        GLAccount: Record "G/L Account";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        NpRvSalesLineReference: Record "NPR NpRv Sales Line Ref.";
        TempVoucher: Record "NPR NpRv Voucher" temporary;
        VoucherType: Record "NPR NpRv Voucher Type";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        QtyNotPositiveErr: Label 'You must specify a positive quantity.';
    begin
        VoucherType.Get(VoucherTypeCode);

        NpRvVoucherMgt.GenerateTempVoucher(VoucherType, TempVoucher);
        GLAccount.Get(TempVoucher."Account No.");
        GLAccount."VAT Bus. Posting Group" := _POSPostingProfile."VAT Bus. Posting Group";
        GLAccount."VAT Prod. Posting Group" := _Item."VAT Prod. Posting Group";
        GLAccount.Modify();

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetNewSaleLine(SaleLinePOS);
        SaleLinePOS.Validate("Line Type", SaleLinePOS."Line Type"::"Issue Voucher");
        SaleLinePOS.Validate("No.", VoucherType."Account No.");
        SaleLinePOS.Description := VoucherType.Description;
        SaleLinePOS.Quantity := Quantity;
        if SaleLinePOS.Quantity < 0 then
            Error(QtyNotPositiveErr);

        POSSaleLine.InsertLine(SaleLinePOS);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        SaleLinePOS."Unit Price" := VoucherAmount;

        case DiscountType of
            '0':
                SaleLinePOS."Discount Amount" := DiscountAmount;
            '1':
                SaleLinePOS."Discount %" := DiscountAmount;
        end;
        SaleLinePOS.UpdateAmounts(SaleLinePOS);
        if SaleLinePOS."Discount Amount" > 0 then
            SaleLinePOS."Discount Type" := SaleLinePOS."Discount Type"::Manual;
        SaleLinePOS.Description := TempVoucher.Description;
        SaleLinePOS.Modify(true);

        NpRvSalesLine.Init();
        NpRvSalesLine.Id := CreateGuid();
        NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::POS;
        NpRvSalesLine."Retail ID" := SaleLinePOS.SystemId;
        NpRvSalesLine."Register No." := SaleLinePOS."Register No.";
        NpRvSalesLine."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
        NpRvSalesLine."Sale Date" := SaleLinePOS.Date;
        NpRvSalesLine."Sale Line No." := SaleLinePOS."Line No.";
        NpRvSalesLine."Voucher No." := TempVoucher."No.";
        NpRvSalesLine."Reference No." := TempVoucher."Reference No.";
        NpRvSalesLine.Description := TempVoucher.Description;
        NpRvSalesLine.Type := NpRvSalesLine.Type::"New Voucher";
        NpRvSalesLine."Voucher Type" := VoucherType.Code;
        NpRvSalesLine.Description := VoucherType.Description;
        NpRvSalesLine."Starting Date" := CurrentDateTime;
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        NpRvSalesLine.Insert();

        NpRvVoucherMgt.SetSalesLineReferenceFilter(NpRvSalesLine, NpRvSalesLineReference);
        if NpRvSalesLineReference.IsEmpty then begin
            NpRvSalesLineReference.Init();
            NpRvSalesLineReference.Id := CreateGuid();
            NpRvSalesLineReference."Voucher No." := TempVoucher."No.";
            NpRvSalesLineReference."Reference No." := TempVoucher."Reference No.";
            NpRvSalesLineReference."Sales Line Id" := NpRvSalesLine.Id;
            NpRvSalesLineReference.Insert(true);
        end;
    end;

    local procedure GetRandomVoucherAmount(): Decimal
    var
        LibraryRandom: Codeunit "Library - Random";
    begin
        LibraryRandom.Init();
        //Avoid lower limit to be zero for those cases where discount amount is greater then zero
        exit(Round(LibraryRandom.RandDecInRange(100, 10000, LibraryRandom.RandIntInRange(0, 2)), _POSPaymentMethod."Rounding Precision"));
    end;

    local procedure GetRandomVoucherReferenceNo(): Text[50]
    var
        LibraryRandom: Codeunit "Library - Random";
    begin
        LibraryRandom.Init();
        exit(LibraryRandom.RandText(50));
    end;

    local procedure DoItemSale(): Integer
    var
        POSEntry: Record "NPR POS Entry";
        POSSaleRecord: Record "NPR POS Sale";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleWrapper: Codeunit "NPR POS Sale";
    begin
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, _Salesperson, POSSaleWrapper);
        POSSaleWrapper.GetCurrentSale(POSSaleRecord);
        NPRLibraryPOSMock.CreateItemLine(_POSSession, _Item."No.", 1);
        if not (NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethod.Code, _Item."Unit Price", '')) then
            Error('Sale did not end as expected');
        POSEntry.SetRange("Document No.", POSSaleRecord."Sales Ticket No.");
        POSEntry.FindFirst();
        _POSSession.ClearAll();
        Clear(_POSSession);
        exit(POSEntry."Entry No.");
    end;

    internal procedure InitializeData()
    var
        ObjectOutputSelection: Record "NPR Object Output Selection";
        POSAuditLog: Record "NPR POS Audit Log";
        POSAuditProfile: Record "NPR POS Audit Profile";
        POSEndOfDayProfile: Record "NPR POS End of Day Profile";
        POSSetup: Record "NPR POS Setup";
        POSStore: Record "NPR POS Store";
        ReportSelectionRetail: Record "NPR Report Selection Retail";
        TemplateHeader: Record "NPR RP Template Header";
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryERM: Codeunit "Library - ERM";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryRPTemplate: Codeunit "NPR Library - RP Template Data";
        LibraryRSFiscal: Codeunit "NPR Library RS Fiscal";
        RSTaxCommunicationMgt: Codeunit "NPR RS Tax Communication Mgt.";
    begin
        if _Initialized then begin
            //Refresh Allowed Tax Rates
            RSTaxCommunicationMgt.PullAndFillAllowedTaxRates();
            //Clean any previous mock session
            _POSSession.ClearAll();
            Clear(_POSSession);
        end else begin
            NPRLibraryPOSMasterData.CreatePOSSetup(POSSetup);
            NPRLibraryPOSMasterData.CreateDefaultVoucherType(_VoucherTypeDefault, false);
            NPRLibraryPOSMasterData.CreateDefaultPostingSetup(_POSPostingProfile);
            _POSPostingProfile."POS Period Register No. Series" := '';
            _POSPostingProfile.Modify();
            NPRLibraryPOSMasterData.CreatePOSStore(POSStore, _POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSUnit(_POSUnit, POSStore.Code, _POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSPaymentMethod(_POSPaymentMethod, _POSPaymentMethod."Processing Type"::CASH, '', false);
            NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(_Item, _POSUnit, POSStore);
            NPRLibraryPOSMasterData.CreateSalespersonForPOSUsage(_Salesperson);

            POSEndOfDayProfile.Code := 'EOD-TEST';
            POSEndOfDayProfile."Z-Report UI" := POSEndOfDayProfile."Z-Report UI"::BALANCING;
            POSEndOfDayProfile.Insert();

            _POSUnit."POS End of Day Profile" := POSEndOfDayProfile.Code;
            _POSUnit.Modify();

            LibraryERM.CreateReturnReasonCode(_ReturnReason);
            _Item."Unit Price" := 10;
            _Item.Modify();

            VATPostingSetup.SetRange("VAT Prod. Posting Group", _Item."VAT Prod. Posting Group");
            VATPostingSetup.SetRange("VAT Bus. Posting Group", _POSPostingProfile."VAT Bus. Posting Group");
            VATPostingSetup.SetFilter("VAT %", '<>%1', 0);
            VATPostingSetup.FindFirst();
            LibraryRSFiscal.CreateAuditProfileAndRSSetup(POSAuditProfile, VATPostingSetup, _POSUnit);

            ReportSelectionRetail.SetRange("Report Type", ReportSelectionRetail."Report Type"::"Sales Receipt (POS Entry)");
            ReportSelectionRetail.DeleteAll();
            ObjectOutputSelection.DeleteAll();

            LibraryRPTemplate.CreateDummySalesReceipt(TemplateHeader);
            LibraryRPTemplate.ConfigureReportSelection(ReportSelectionRetail."Report Type"::"Sales Receipt (POS Entry)", TemplateHeader);

            _Initialized := true;
        end;

        POSAuditLog.DeleteAll(true); //Clean in between tests
        Commit();
    end;

    local procedure DoReturnSale(ReceiptNumberToReturn: Code[20]): Integer
    var
        POSEntry: Record "NPR POS Entry";
        POSSaleRecord: Record "NPR POS Sale";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSActionRevDirSale: Codeunit "NPR POS Action: Rev.Dir.Sale B";
        POSSaleWrapper: Codeunit "NPR POS Sale";
        ChangeAmount: Decimal;
        PaidAmount: Decimal;
        RoundingAmount: Decimal;
        SalesAmount: Decimal;
    begin
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, _Salesperson, POSSaleWrapper);
        POSSaleWrapper.GetCurrentSale(POSSaleRecord);
        POSActionRevDirSale.ReverseSalesTicket(POSSaleRecord, ReceiptNumberToReturn, _ReturnReason.Code, true);
        POSSaleWrapper.GetTotals(SalesAmount, PaidAmount, ChangeAmount, RoundingAmount);
        if not (NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethod.Code, SalesAmount, '')) then
            Error('Sale did not end as expected');
        POSEntry.SetRange("Document No.", POSSaleRecord."Sales Ticket No.");
        POSEntry.FindFirst();
        _POSSession.ClearAll();
        Clear(_POSSession);
        exit(POSEntry."Entry No.");
    end;

    local procedure EnableRSApplicationArea()
    var
        ApplicationAreaSetup: Record "Application Area Setup";
    begin
        ApplicationAreaSetup.Init();
        ApplicationAreaSetup."Company Name" := CompanyName();
        ApplicationAreaSetup."NPR RS Fiscal" := true;
        if not ApplicationAreaSetup.Insert() then
            ApplicationAreaSetup.Modify();
    end;

    local procedure CreateAndInitCostAccountSetup()
    var
        CostAccountingSetup: Record "Cost Accounting Setup";
    begin
        if CostAccountingSetup.Get() then
            exit;
        CostAccountingSetup.Init();
        CostAccountingSetup.Insert();
    end;

    [ConfirmHandler]
    procedure AllowedTaxRatesUpdateConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        _Assert.ExpectedMessage('Allowed Tax Rates, VAT Posting Setup will be updated. Do you want to proceed?', Question);
        Reply := true;
    end;

    [MessageHandler]
    procedure GeneralMessageHandler(Msg: Text[1024])
    begin
        case true of
            Msg.Contains('Allowed Tax Rates have been updated'):
                exit;
            Msg.Contains('Proforma has been created and RS Audit Log created'):
                exit;
            else
                Error('Message "%1" is not expected.', Msg);
        end;
    end;
}