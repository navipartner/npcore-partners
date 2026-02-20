codeunit 85237 "NPR NPLoyaltyDiscountTests"
{
#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
    Subtype = Test;

    var
        Customer: Record Customer;
        Membership: Record "NPR MM Membership";
        TmpTransactionAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary;
        _VoucherTypePartial: Record "NPR NpRv Voucher Type";
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Initialized: Boolean;
        GatewayCode, CountryCode : Code[10];
        ItemNo, ItemNo2, ExternalNo, PostCode, GLAccountNo : Code[20];
        MagentoPaymentCode, MagentoPaymentType : Code[50];
        TransactionId: Code[40];
        ItemDesc, ItemDesc2, City, GLAccName : Text;
        Qty, Qty2, UnitPrice, UnitPrice2, PymAmount1, PymAmount2 : Decimal;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure NegativeSalesLineCreatedandPointsPaymentLine()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        PaymentLineIsPointsPayment: Boolean;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Assert: Codeunit "Assert";
        LibraryRandom: Codeunit "Library - Random";
        NegativeSalesLineFound: Boolean;
    begin
        //[Scenario] Sales Order created from Incoming Ecommerce Order should have negative sales line and payment line should be flagged as points payment
        Initialize();
        //[GIVEN] Ecom Document No
        ExternalNo := LibraryRandom.RandText(20);

        //[WHEN] Create Ecom Document
        CreateEcomDocRestAPIandProcess(SalesHeader);

        //[THEN] Verify Sales Line and Payment Line created correctly
        NegativeSalesLineFound := FindNegativeSalesLine(SalesHeader, SalesLine);
        Assert.AreEqual(true, NegativeSalesLineFound, 'Negative line should have been created');
        PaymentLineIsPointsPayment := PaymentLineIsFlaggedAsPointsPayment(SalesHeader, PaymentLine);
        Assert.AreEqual(true, PaymentLineIsPointsPayment, 'Payment Line shoudld be flagged as points payment.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PostSalesOrderNoPointsPaymentLine()
    var
        SalesHeader: Record "Sales Header";
        Assert: Codeunit "Assert";
        LibrarySales: Codeunit "Library - Sales";
        SalesPost: Codeunit "Sales-Post";
        Success: Boolean;
    begin
        //[Scenario] Post Sales Order with no points payment line
        Initialize();
        //[GIVEN] Create a sales order without points payment
        LibrarySales.CreateSalesOrderForCustomerNo(SalesHeader, Membership."Customer No.");
        Commit();

        //[WHEN] Sales Order is posted
        SalesHeader.Ship := true;
        SalesHeader.Invoice := true;
        Success := SalesPost.Run(SalesHeader);

        //[THEN] Posting of sales order should be successful
        Assert.AreEqual(true, Success, 'Posting of sales order should have been successful');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CapturePointsPayment()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Assert: Codeunit "Assert";
        LibrarySales: Codeunit "Library - Sales";
        _LibPaymentGateway: Codeunit "NPR Library - Payment Gateway";
        NPLoyaltyDiscountMgt: Codeunit "NPR NP Loyalty Discount Mgt";
        SalesPost: Codeunit "Sales-Post";
        PointsPaymentLineCaptured: Boolean;
        Success: Boolean;
        Authorizationcode: Text[40];
    begin
        //[Scenario] Test Capture on posting of sales order(Sales Order has only stock Item)
        Initialize();

        //[GIVEN] Sales Order is created with points payment line
        LibrarySales.CreateSalesOrderForCustomerNo(SalesHeader, Membership."Customer No.");
        SalesHeader.CalcFields("Amount Including VAT");
        Authorizationcode := ReservePoints(SalesHeader."Amount Including VAT");
        _LibPaymentGateway.CreatePointsPaymentLine(Database::"Sales Header", SalesHeader."Document Type"::Order, SalesHeader."No.", GatewayCode, GLAccountNo, SalesHeader."Amount Including VAT", PaymentLine, Authorizationcode);
        NPLoyaltyDiscountMgt.CreateDiscountSalesLine(PaymentLine, SalesHeader);
        UpdateVATPostingSetup(SalesHeader);
        Commit();

        //[WHEN] Sales Order is posted
        SalesHeader.Ship := true;
        SalesHeader.Invoice := true;
        Success := SalesPost.Run(SalesHeader);
        Assert.AreEqual(true, Success, 'Posting should have been successful');

        SalesInvoiceHeader.SetRange("Order No.", SalesHeader."No.");
        if not SalesInvoiceHeader.FindFirst() then
            Error('Posted Sales Invoice not found');

        //[THEN] Payment Line should be captured
        PaymentLine.SetRange("Document Table No.", Database::"Sales Invoice Header");
        PaymentLine.SetRange("Document Type", PaymentLine."Document Type"::Quote);
        PaymentLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        PaymentLine.SetRange("Points Payment", true);
        PaymentLine.SetFilter("Date Captured", '<>%1', 0D);
        PointsPaymentLineCaptured := PaymentLine.FindFirst();

        Assert.AreEqual(true, PointsPaymentLineCaptured, 'Points Payment should have been captured');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RefundPointsPayment()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesHeader: Record "Sales Header";
        Assert: Codeunit "Assert";
        LibrarySales: Codeunit "Library - Sales";
        _LibPaymentGateway: Codeunit "NPR Library - Payment Gateway";
        NPLoyaltyDiscountMgt: Codeunit "NPR NP Loyalty Discount Mgt";
        SalesPost: Codeunit "Sales-Post";
        PointsPaymentLineCaptured: Boolean;
        Success: Boolean;
        Authorizationcode: Text[40];

    begin
        //[Scenario] Test Refund on posting of sales return order
        Initialize();

        //[GIVEN] Sales Return Order is created with points payment line
        LibrarySales.CreateSalesReturnOrderForCustomerNo(SalesHeader, Membership."Customer No.");
        SalesHeader.CalcFields("Amount Including VAT");
        Authorizationcode := DepositPoints(SalesHeader."Amount Including VAT");
        _LibPaymentGateway.CreatePointsPaymentLine(Database::"Sales Header", SalesHeader."Document Type"::"Return Order", SalesHeader."No.", GatewayCode, GLAccountNo, SalesHeader."Amount Including VAT", PaymentLine, Authorizationcode);
        NPLoyaltyDiscountMgt.CreateDiscountSalesLine(PaymentLine, SalesHeader);
        UpdateVATPostingSetup(SalesHeader);
        Commit();

        //[WHEN] Sales Return Order is posted
        SalesHeader.Receive := true;
        SalesHeader.Invoice := true;
        Success := SalesPost.Run(SalesHeader);
        Assert.AreEqual(true, Success, 'Posting should have been successful');

        SalesCrMemoHeader.SetRange("Return Order No.", SalesHeader."No.");
        if not SalesCrMemoHeader.FindFirst() then
            Error('Posted Sales Cr. Memo not found');

        //[THEN] Payment Line should be captured
        PaymentLine.SetRange("Document Table No.", Database::"Sales Cr.Memo Header");
        PaymentLine.SetRange("Document Type", PaymentLine."Document Type"::Quote);
        PaymentLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        PaymentLine.SetRange("Points Payment", true);
        PaymentLine.SetFilter("Date Refunded", '<>%1', 0D);
        PointsPaymentLineCaptured := PaymentLine.FindFirst();

        Assert.AreEqual(true, PointsPaymentLineCaptured, 'Points Payment should have been captured');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CancelPointsPayment()
    var
        LoyaltyLedgerEntry: Record "NPR MM Loy. LedgerEntry (Srvr)";
        SalesHeader: Record "Sales Header";
        Assert: Codeunit "Assert";
        LibraryRandom: Codeunit "Library - Random";
        PointsPaymentIsCancelled: Boolean;
        Success: Boolean;
    begin
        //[Scenario] Test Cancel points reservation on deleting sales order
        Initialize();

        //[GIVEN] Create Ecom Document with Point Reservation
        ExternalNo := LibraryRandom.RandText(20);
        TransactionId := ReservePoints(100);
        CreateEcomDocRestAPIandProcess(SalesHeader);
        //[WHEN] Sales Header is deleted
        Success := SalesHeader.Delete(true);

        //[THEN] Points Payment should be cancelled
        LoyaltyLedgerEntry.SetRange("Inc Ecom Sale Id", SalesHeader."NPR Inc Ecom Sale Id");
        LoyaltyLedgerEntry.SetRange("Entry Type", LoyaltyLedgerEntry."Entry Type"::CANCEL_RESERVE);
        PointsPaymentIsCancelled := LoyaltyLedgerEntry.FindFirst();
        Assert.AreEqual(true, PointsPaymentIsCancelled, 'Cancel should have been successful');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateEcomDocWithDigitalItemOnlyAndProcessWithFastLineCapture()
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        PaymentLine: Record "NPR Magento Payment Line";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Assert: Codeunit "Assert";
        LibraryRandom: Codeunit "Library - Random";
        InitialBalance: Decimal;
        FinalBalance: Decimal;
        ExpectedBalance: Decimal;
        VoucherAmount: Decimal;
        PaymentAmount: Decimal;
        ReserveAmount: Decimal;
        VoucherReferenceNo: Code[50];
    begin
        //[Scenario] Test Ecom document with voucher line processed with fast line capture
        //Payment Line is captured, Sales Order is posted automatically, and membership points are correct

        Initialize();
        VoucherAmount := 100;
        PaymentAmount := 100;
        ReserveAmount := 200;

        //[GIVEN] Get initial membership balance
        Membership.Find();
        Membership.SetAutoCalcFields("Remaining Points");
        InitialBalance := Membership."Remaining Points";

        //[GIVEN] Create points reservation of 200
        TransactionId := ReservePoints(ReserveAmount);

        //[GIVEN] Generate a random voucher reference number for the test
        VoucherReferenceNo := CopyStr(LibraryRandom.RandText(50), 1, 50);

        //[GIVEN] Random external number for the ecom document
        ExternalNo := LibraryRandom.RandText(20);

        //[WHEN] Create Ecom document with voucher line (line amount 100, payment line 100)
        CreateEcomDocWithVoucher(EcomSalesHeader, VoucherReferenceNo, VoucherAmount, PaymentAmount);

        //[THEN] Verify Sales Order was created and posted automatically
        SalesInvoiceHeader.SetRange("External Document No.", ExternalNo);
        if not SalesInvoiceHeader.FindFirst() then
            Assert.IsTrue(SalesInvoiceHeader.Get(SalesHeader."Last Posting No."), 'Sales Invoice Header should exist');

        //[THEN] Verify Payment Line was captured
        PaymentLine.Reset();
        PaymentLine.SetRange("Document Table No.", Database::"Sales Invoice Header");
        PaymentLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        PaymentLine.SetRange("Payment Gateway Code", GatewayCode);
        Assert.IsTrue(PaymentLine.FindFirst(), 'Payment Line should exist on posted Sales Invoice');
        Assert.AreNotEqual(0D, PaymentLine."Date Captured", 'Payment Line should have been captured');
        Assert.AreEqual(PaymentAmount, PaymentLine.Amount, 'Payment Line amount should match expected amount');

        //[THEN] Verify remaining points on membership is correct
        Membership.Find();
        Membership.CalcFields("Remaining Points", "Redeemed Points (Withdrawl)");
        FinalBalance := Membership."Remaining Points";
        ExpectedBalance := InitialBalance - ReserveAmount;

        Assert.AreEqual(ExpectedBalance, FinalBalance,
            StrSubstNo('Remaining points should be %1. Initial: %2, Reserved: %3, Payment: %4, Final: %5',
                ExpectedBalance, InitialBalance, ReserveAmount, PaymentAmount, FinalBalance));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateEcomDocWithDigitalItemStockItemPointsPayment()
    var
        LoyaltyLedgerEntry: Record "NPR MM Loy. LedgerEntry (Srvr)";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PaymentLine: Record "NPR Magento Payment Line";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Assert: Codeunit "Assert";
        LibraryRandom: Codeunit "Library - Random";
        SalesPost: Codeunit "Sales-Post";
        FinalBalance: Decimal;
        VoucherAmount: Decimal;
        ItemAmount: Decimal;
        PaymentAmount: Decimal;
        ReserveAmount: Decimal;
        VoucherReferenceNo: Code[50];
        Success: Boolean;
        ErrorText: Text;
    begin
        //[Scenario] Test Ecom document with voucher and item lines processed with fast line capture
        //Payment Line is captured, digital item (voucher) is processed, sales order is NOT posted automatically
        //Modify Quantity to Ship and post sales order manually
        //Check remaining points balance on membership

        Initialize();
        VoucherAmount := 30;
        ItemAmount := 90;
        PaymentAmount := 120;
        ReserveAmount := 240;

        //[GIVEN] Get initial membership balance
        Membership.Find();
        Membership.SetAutoCalcFields("Remaining Points");

        //[GIVEN] Create points reservation of 240
        TransactionId := ReservePoints(ReserveAmount);

        //[GIVEN] Generate a random voucher reference number for the test
        VoucherReferenceNo := CopyStr(LibraryRandom.RandText(50), 1, 50);

        //[GIVEN] Random external number for the ecom document
        ExternalNo := LibraryRandom.RandText(20);

        //[WHEN] Create Ecom document with voucher line (30), item line (90), and payment line (120)
        CreateEcomDocWithVoucherAndItem(EcomSalesHeader, VoucherReferenceNo, VoucherAmount, ItemAmount, PaymentAmount);

        //[WHEN] Process ecom document using fast line capture (without automatic posting)
        ProcessEcomDocWithFastLineCaptureNoPost(EcomSalesHeader, SalesHeader, Success, ErrorText);

        //[THEN] Verify processing was successful
        Assert.AreEqual(true, Success, StrSubstNo('Fast line capture should have been successful. Error: %1', ErrorText));

        //[THEN] Verify Sales Order was created but NOT posted automatically
        //Assert.AreEqual('', SalesHeader."Last Posting No.", 'Sales Order should NOT have been posted automatically');

        //[THEN] Verify Payment Line was captured
        PaymentLine.Reset();
        PaymentLine.SetRange("Document Table No.", Database::"Sales Header");
        PaymentLine.SetRange("Document Type", PaymentLine."Document Type"::Order);
        PaymentLine.SetRange("Document No.", SalesHeader."No.");
        PaymentLine.SetRange("Payment Gateway Code", GatewayCode);
        Assert.IsTrue(PaymentLine.FindFirst(), 'Payment Line should exist on Sales Order');
        Assert.AreNotEqual(0D, PaymentLine."Date Captured", 'Payment Line should have been captured');
        Assert.AreEqual(PaymentAmount, PaymentLine.Amount, 'Payment Line amount should match expected amount');

        //[THEN] Verify voucher was processed by checking Ecom Sales Line
        VerifyVoucherProcessed(EcomSalesHeader, VoucherReferenceNo);

        //[WHEN] Modify Quantity to Ship on Sales Order Line
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        if SalesLine.FindFirst() then begin
            SalesLine.Validate("Qty. to Ship", SalesLine.Quantity);
            SalesLine.Modify(true);
        end;

        //[WHEN] Post sales order
        Commit();
        SalesHeader.Find();
        SalesHeader.Ship := true;
        SalesHeader.Invoice := true;
        Success := SalesPost.Run(SalesHeader);
        Assert.AreEqual(true, Success, 'Posting of sales order should have been successful');

        //[THEN] Verify sales order was posted
        Assert.AreNotEqual('', SalesHeader."Last Posting No.", 'Sales Order should have been posted');

        //[THEN] Verify remaining points on membership is correct
        Membership.Find();
        Membership.CalcFields("Remaining Points");

        LoyaltyLedgerEntry.SetRange("Inc Ecom Sale Id", EcomSalesHeader.SystemId);
        LoyaltyLedgerEntry.SetRange("Entry Type", LoyaltyLedgerEntry."Entry Type"::RECEIPT);
        if LoyaltyLedgerEntry.FindFirst() then
            FinalBalance := LoyaltyLedgerEntry.Balance;

        Assert.AreEqual(Membership."Remaining Points", FinalBalance,
            StrSubstNo('Remaining points should be %1.',
                Membership."Remaining Points"));
    end;

    local procedure CreateEcomDocRestAPIandProcess(var SalesHeader: Record "Sales Header")
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";

        Headers: Dictionary of [Text, Text];
        QueryParameters: Dictionary of [Text, Text];
        GuidValue: Guid;
        Body: JsonObject;
        Response: JsonObject;
        ResponseBody: JsonObject;
        GuidToken: JsonToken;
        ErrorResponse: Text;
    begin
        LibraryNPRetailAPI.CreateAPIPermission(UserSecurityId(), CompanyName(), 'NPR API Ecom');
        Body := BuildEcomDocJsonObject('order');
        Headers.Add('x-api-version', Format(Today, 0, 9));
        Response := LibraryNPRetailAPI.CallApi('POST', 'ecommerce/documents', Body, QueryParameters, Headers);
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        if not LibraryNPRetailAPI.IsSuccessStatusCode(Response) then begin
            ResponseBody.WriteTo(ErrorResponse);
            Error('POST create edoc api call failed. Response: %1', ErrorResponse);
        end;

        if ResponseBody.SelectToken('id', GuidToken) then begin
            GuidValue := GuidToken.AsValue().AsText();
            if not EcomSalesHeader.GetBySystemId(GuidValue) then
                Error('Ecom document not found');
        end else
            Error('id missing from response');

        if not SalesHeader.Get(SalesHeader."Document Type"::Order, EcomSalesHeader."Created Doc No.") then
            error('sales header not created');
    end;

    local procedure FindNegativeSalesLine(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"): Boolean
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::"G/L Account");
        SalesLine.SetRange("NPR Loyalty Discount", true);
        SalesLine.SetFilter("Line Amount", '<%1', 0);
        exit(SalesLine.FindFirst());
    end;

    local procedure PaymentLineIsFlaggedAsPointsPayment(SalesHeader: Record "Sales Header"; var PaymentLine: Record "NPR Magento Payment Line"): Boolean
    begin
        PaymentLine.SetRange(PaymentLine."Document Table No.", Database::"Sales Header");
        PaymentLine.SetRange(PaymentLine."Document Type", PaymentLine."Document Type"::Order);
        PaymentLine.SetRange(PaymentLine."Document No.", SalesHeader."No.");
        PaymentLine.SetRange("Payment Gateway Code", GatewayCode);
        PaymentLine.SetRange("Points Payment", true);
        exit(PaymentLine.FindFirst());
    end;

    procedure Initialize()
    begin
        if not Initialized then begin
            PrepareDataForJson();
            CreateSetupData();
            Initialized := true;
        end;
    end;

    local procedure CreateSetupData()
    var
        LibraryLoyalty: Codeunit "NPR Library MemberLoyalty";
        LibraryMagento: Codeunit "NPR Library - Magento";
        LibrayPaymentGateway: Codeunit "NPR Library - Payment Gateway";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LoyaltySetup: Record "NPR MM Loyalty Setup";
        MagentoPaymentMapping: Record "NPR Magento Payment Mapping";
        MembershipSalesItem: Record "NPR MM Members. Sales Setup";
        MembershipSetup: Record "NPR MM Membership Setup";
        TmpRegisterSaleLines: Record "NPR MM Reg. Sales Buffer" temporary;
        TmpRegisterPaymentLines: Record "NPR MM Reg. Sales Buffer" temporary;
        ItemNo: Code[20];
        PaymentMethod: Record "Payment Method";
    begin
        LibraryPOSMasterData.CreatePartialVoucherType(_VoucherTypePartial, false);
        ItemNo := LibraryLoyalty.CreateScenario_Loyalty100(TmpTransactionAuthorization, TmpRegisterSaleLines, TmpRegisterPaymentLines);
        MembershipSalesItem.Get(MembershipSalesItem.Type::ITEM, ItemNo);
        MembershipSetup.Get(MembershipSalesItem."Membership Code");
        LoyaltySetup.Get(MembershipSetup."Loyalty Code");

        CreateMembership(ItemNo);
        AssignInitialPointstoMembership();
        UpdateCustomerDetails();

        GatewayCode := LibrayPaymentGateway.CreatePaymentGateway(Enum::"NPR PG Integrations"::NPLoyalty_Discount);
        LibraryMagento.CreatePaymentMappingBalAccount(MagentoPaymentCode, MagentoPaymentType);
        if MagentoPaymentMapping.Get(MagentoPaymentCode, MagentoPaymentType) then begin
            MagentoPaymentMapping."Payment Gateway Code" := GatewayCode;
            MagentoPaymentMapping.Modify();

            if PaymentMethod.Get(MagentoPaymentMapping."Payment Method Code") then begin
                PaymentMethod.Validate("Bal. Account No.", GLAccountNo);
                PaymentMethod.Modify();
            end;
        end;
    end;

    local procedure CreateMembership(ItemNo: Code[20])
    var
        MemberApiLibrary: Codeunit "NPR Library - Member XML API";
        MemberLibrary: Codeunit "NPR Library - Member Module";
        ResponseMessage: Text;
        MembershipEntryNo: Integer;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MemberEntryNo: Integer;
    begin
        if (not MemberApiLibrary.CreateMembership(ItemNo, MembershipEntryNo, ResponseMessage)) then
            Error(ResponseMessage);

        Membership.Reset();
        Membership.Get(MembershipEntryNo);
        Membership.SetRecFilter();
        Membership.SetAutoCalcFields("Awarded Points (Sale)", "Awarded Points (Refund)", "Remaining Points", "Redeemed Points (Deposit)", "Redeemed Points (Withdrawl)", "Expired Points");
        MemberLibrary.SetRandomMemberInfoData(MemberInfoCapture);
        if (not MemberApiLibrary.AddMembershipMember(Membership, MemberInfoCapture, MemberEntryNo, ResponseMessage)) then
            Error(ResponseMessage);
    end;

    local procedure UpdateCustomerDetails()
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        Customer.Get(Membership."Customer No.");
        Customer.Name := LibraryUtility.GenerateRandomText(100);
        Customer.Address := LibraryUtility.GenerateRandomText(100);
        Customer."Post Code" := PostCode;
        Customer.City := City;
        Customer."E-Mail" := LibraryUtility.GenerateRandomEmail();
        Customer."Country/Region Code" := CountryCode;
        Customer."Currency Code" := '';
        Customer."Prices Including VAT" := true;
        Customer.Modify();
    end;

    local procedure UpdateVATPostingSetup(SalesHeader: Record "Sales Header")
    var
        GLAccount: Record "G/L Account";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        GLAccount.Get(GLAccountNo);
        if VATPostingSetup.Get(SalesHeader."VAT Bus. Posting Group", GLAccount."VAT Prod. Posting Group") then begin
            VATPostingSetup.Blocked := false;
            VATPostingSetup.Modify();
        end;
    end;

    local procedure ReservePoints(Amount: Decimal) AuthorizationCode: Text[40];
    var
        QueryParameters: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        Response: JsonObject;
        Body: JsonObject;
        AuthorizationCodeToken: JsonToken;
        ResponseText: Text;
    begin
        LibraryNPRetailAPI.CreateAPIPermission(UserSecurityId(), CompanyName(), 'NPR API Membership');
        Body := AuthorizationToJObject(TmpTransactionAuthorization, CreateGuid());
        Body.Add('pointsToReserve', Amount);
        Body.Add('type', 'WITHDRAW');
        Body.Add('reason', 'test_capture');
        Headers.Add('x-api-version', Format(Today, 0, 9));
        Response := LibraryNPRetailAPI.CallApi('POST', StrSubstNo('membership/%1/points/reserve', Format(Membership.SystemId, 0, 4)), Body, QueryParameters, Headers);
        Body := LibraryNPRetailAPI.GetResponseBody(Response);
        if not LibraryNPRetailAPI.IsSuccessStatusCode(Response) then begin
            Body.WriteTo(ResponseText);
            Error('Reserve points failed. Response: %1', ResponseText);
        end;

        if Body.SelectToken('authorizationCode', AuthorizationCodeToken) then
            AuthorizationCode := AuthorizationCodeToken.AsValue().AsText()
        else
            Error('authorizationCode missing from response');
    end;

    local procedure DepositPoints(Amount: Decimal) AuthorizationCode: Text[40];
    var
        QueryParameters: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        Response: JsonObject;
        Body: JsonObject;
        AuthorizationCodeToken: JsonToken;
        ResponseText: Text;
    begin
        LibraryNPRetailAPI.CreateAPIPermission(UserSecurityId(), CompanyName(), 'NPR API Membership');
        Body := AuthorizationToJObject(TmpTransactionAuthorization, CreateGuid());
        Body.Add('pointsToReserve', Amount);
        Body.Add('type', 'DEPOSIT');
        Body.Add('reason', 'test_capture');
        Headers.Add('x-api-version', Format(Today, 0, 9));
        Response := LibraryNPRetailAPI.CallApi('POST', StrSubstNo('membership/%1/points/reserve', Format(Membership.SystemId, 0, 4)), Body, QueryParameters, Headers);
        Body := LibraryNPRetailAPI.GetResponseBody(Response);
        if not LibraryNPRetailAPI.IsSuccessStatusCode(Response) then begin
            Body.WriteTo(ResponseText);
            Error('Reserve points failed. Response: %1', ResponseText);
        end;

        if Body.SelectToken('authorizationCode', AuthorizationCodeToken) then
            AuthorizationCode := AuthorizationCodeToken.AsValue().AsText()
        else
            Error('authorizationCode missing from response');
    end;

    local procedure AssignInitialPointstoMembership()
    var
        PointsEntry: Record "NPR MM Members. Points Entry";
    begin
        PointsEntry.Init();
        PointsEntry."Entry No." := 0;
        PointsEntry."Entry Type" := PointsEntry."Entry Type"::SYNCHRONIZATION;
        PointsEntry."Membership Entry No." := Membership."Entry No.";
        PointsEntry.Points := 10000;
        PointsEntry."Awarded Points" := PointsEntry.Points;
        PointsEntry.Insert(false);
    end;

    local procedure PrepareDataForJson()
    var
        LibraryECommerce: Codeunit "NPR Library - E-Commerce";
    begin
        GetCountryCode(CountryCode);
        LibraryECommerce.GetPostCodeAndCity(PostCode, City);
        LibraryECommerce.GetMagentoPaymentCode(MagentoPaymentCode);
        LibraryECommerce.GetMagentoPaymentType(MagentoPaymentType);
        LibraryECommerce.GetMagentoPointsPaymentId(TransactionId);
        LibraryECommerce.CreateItem(ItemNo);
        LibraryECommerce.CreateItem(ItemNo2);
        LibraryECommerce.CreateGLAccount(GLAccountNo);
        LibraryECommerce.GetItemQuantitiesAndPrices(Qty, Qty2, UnitPrice, UnitPrice2);
        LibraryECommerce.GetLineDesc(ItemDesc, "Sales Line Type"::Item);
        LibraryECommerce.GetLineDesc(ItemDesc2, "Sales Line Type"::Item);
        LibraryECommerce.GetLineDesc(GLAccName, "Sales Line Type"::"G/L Account");
        LibraryECommerce.GetPaymentAmounts(PymAmount1, PymAmount2);
    end;

    local procedure GetCountryCode(var NewCountryCode: Code[10])
    var
        LibraryERM: Codeunit "Library - ERM";
    begin
        if NewCountryCode <> '' then
            exit;
        NewCountryCode := LibraryERM.CreateCountryRegion();
    end;

    local procedure BuildEcomDocJsonObject(DocType: Text[11]): JsonObject
    var
        IncSalesDocumentJsonObject: Codeunit "NPR Json Builder";
        PaymentLineJsonObject: Codeunit "NPR Json Builder";
        SalesLineJsonObject: Codeunit "NPR Json Builder";
    begin
        IncSalesDocumentJsonObject.StartObject('salesDocument')
                                 .AddProperty('externalNo', ExternalNo)
                                 .AddProperty('id', Format(CreateGuid(), 0, 4).ToLower())
                                 .AddProperty('documentType', DocType)
                                 .AddProperty('currencyCode', '')
                                 .AddProperty('currencyExchangeRate', 1)
                                 .AddProperty('externalDocumentNo', '')
                                 .AddProperty('yourReference', '')
                                 .AddProperty('pricesExcludingVat', false)
                                 .StartObject('sellToCustomer')
                                    .AddProperty('no', Customer."No.")
                                    .AddProperty('name', Customer.Name)
                                    .AddProperty('address', Customer.Address)
                                    .AddProperty('postCode', Customer."Post Code")
                                    .AddProperty('city', Customer.City)
                                    .AddProperty('countryCode', Customer."Country/Region Code")
                                    .AddProperty('email', Customer."E-Mail")
                                .EndObject();

        IncSalesDocumentJsonObject.StartArray('payments');
        PaymentLineJsonObject := CreateAddPaymentDocumentDetailsJsonObject(IncSalesDocumentJsonObject);
        IncSalesDocumentJsonObject.AddObject(PaymentLineJsonObject);
        IncSalesDocumentJsonObject.EndArray();

        IncSalesDocumentJsonObject.StartArray('salesDocumentLines');
        SalesLineJsonObject := CreateAddSalesLineDetailsJsonObject(IncSalesDocumentJsonObject);
        IncSalesDocumentJsonObject.AddObject(SalesLineJsonObject);
        IncSalesDocumentJsonObject.EndArray();

        IncSalesDocumentJsonObject.EndObject();
        exit(IncSalesDocumentJsonObject.Build());
    end;

    local procedure CreateAddPaymentDocumentDetailsJsonObject(var PaymentDocumentDetailsJsonObject: Codeunit "NPR Json Builder"): Codeunit "NPR Json Builder"
    begin
        PaymentDocumentDetailsJsonObject.StartObject()
                                        .AddProperty('paymentMethodType', 'paymentGateway')
                                        .AddProperty('externalPaymentMethodCode', MagentoPaymentCode)
                                        .AddProperty('externalPaymentType', MagentoPaymentType)
                                        .AddProperty('paymentReference', TransactionId)
                                        .AddProperty('paymentAmount', Format(PymAmount1, 0, 9));
        PaymentDocumentDetailsJsonObject.EndObject();
    end;

    local procedure CreateAddSalesLineDetailsJsonObject(var SalesLineDetailsJsonObject: Codeunit "NPR Json Builder"): Codeunit "NPR Json Builder"
    begin
        SalesLineDetailsJsonObject.StartObject()
                                  .AddProperty('type', 'item')
                                  .AddProperty('no', ItemNo)
                                  .AddProperty('variantCode', '')
                                  .AddProperty('barcodeNo', '')
                                  .AddProperty('description', ItemDesc)
                                  .AddProperty('unitPrice', Format(UnitPrice, 0, 9))
                                  .AddProperty('quantity', Format(Qty, 0, 9))
                                  .AddProperty('unitOfMeasure', Format('', 0, 9))
                                  .AddProperty('vatPercent', Format(25, 0, 9))
                                  .AddProperty('lineAmount', Format(UnitPrice * Qty, 0, 9));
        SalesLineDetailsJsonObject.EndObject();
    end;

    local procedure AuthorizationToJObject(TempAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary; TransactionId: Guid): JsonObject
    var
        Body: JsonObject;
    begin
        Body.Add('requestId', TransactionId);
        Body.Add('externalReferenceNo', TempAuthorization."Reference Number");
        Body.Add('externalSystemIdentifier', TempAuthorization."POS Store Code");
        Body.Add('externalSystemUserIdentifier', TempAuthorization."POS Unit Code");
        Body.Add('externalBusinessUnitIdentifier', TempAuthorization."Company Name");
        exit(Body);
    end;

    local procedure CreateEcomDocWithVoucher(var EcomSalesHeader: Record "NPR Ecom Sales Header"; VoucherReferenceNo: Code[50]; VoucherAmount: Decimal; PaymentAmount: Decimal)
    var
        Headers: Dictionary of [Text, Text];
        QueryParameters: Dictionary of [Text, Text];
        Body: JsonObject;
        Response: JsonObject;
        ResponseBody: JsonObject;
        GuidToken: JsonToken;
        GuidValue: Guid;
        ErrorResponse: Text;
    begin
        LibraryNPRetailAPI.CreateAPIPermission(UserSecurityId(), CompanyName(), 'NPR API Ecom');

        // Build the Ecom document JSON with voucher line
        Body := BuildEcomDocWithVoucherJson('order', VoucherReferenceNo, VoucherAmount, PaymentAmount);

        // Call the API to create the Ecom document
        Headers.Add('x-api-version', Format(Today, 0, 9));
        Response := LibraryNPRetailAPI.CallApi('POST', 'ecommerce/documents', Body, QueryParameters, Headers);
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);

        if not LibraryNPRetailAPI.IsSuccessStatusCode(Response) then begin
            ResponseBody.WriteTo(ErrorResponse);
            Error('POST create ecom document API call failed. Response: %1', ErrorResponse);
        end;

        // Get the created Ecom document
        if ResponseBody.SelectToken('id', GuidToken) then begin
            GuidValue := GuidToken.AsValue().AsText();
            if not EcomSalesHeader.GetBySystemId(GuidValue) then
                Error('Ecom document not found');
        end else
            Error('id missing from response');
    end;

    local procedure BuildEcomDocWithVoucherJson(DocType: Text[11]; VoucherReferenceNo: Code[50]; VoucherAmount: Decimal; PaymentAmount: Decimal): JsonObject
    var
        IncSalesDocumentJsonObject: Codeunit "NPR Json Builder";
        PaymentLineJsonObject: Codeunit "NPR Json Builder";
        VoucherLineJsonObject: Codeunit "NPR Json Builder";
    begin
        // Build the main sales document JSON
        IncSalesDocumentJsonObject.StartObject('salesDocument')
                                 .AddProperty('externalNo', ExternalNo)
                                 .AddProperty('id', Format(CreateGuid(), 0, 4).ToLower())
                                 .AddProperty('documentType', DocType)
                                 .AddProperty('currencyCode', '')
                                 .AddProperty('currencyExchangeRate', 1)
                                 .AddProperty('externalDocumentNo', '')
                                 .AddProperty('yourReference', '')
                                 .AddProperty('pricesExcludingVat', false)
                                 .StartObject('sellToCustomer')
                                    .AddProperty('no', Customer."No.")
                                    .AddProperty('name', Customer.Name)
                                    .AddProperty('address', Customer.Address)
                                    .AddProperty('postCode', Customer."Post Code")
                                    .AddProperty('city', Customer.City)
                                    .AddProperty('countryCode', Customer."Country/Region Code")
                                    .AddProperty('email', Customer."E-Mail")
                                .EndObject();

        // Add payments array (points payment)
        IncSalesDocumentJsonObject.StartArray('payments');
        PaymentLineJsonObject := CreatePaymentLineJson(IncSalesDocumentJsonObject, PaymentAmount);
        IncSalesDocumentJsonObject.AddObject(PaymentLineJsonObject);
        IncSalesDocumentJsonObject.EndArray();

        // Add sales document lines array with voucher line
        IncSalesDocumentJsonObject.StartArray('salesDocumentLines');
        VoucherLineJsonObject := CreateVoucherLineJson(IncSalesDocumentJsonObject, VoucherReferenceNo, VoucherAmount);
        IncSalesDocumentJsonObject.AddObject(VoucherLineJsonObject);
        IncSalesDocumentJsonObject.EndArray();

        IncSalesDocumentJsonObject.EndObject();
        exit(IncSalesDocumentJsonObject.Build());
    end;

    local procedure CreatePaymentLineJson(var PaymentDocumentDetailsJsonObject: Codeunit "NPR Json Builder"; PaymentAmount: Decimal): Codeunit "NPR Json Builder"
    begin
        PaymentDocumentDetailsJsonObject.StartObject()
                                        .AddProperty('paymentMethodType', 'paymentGateway')
                                        .AddProperty('externalPaymentMethodCode', MagentoPaymentCode)
                                        .AddProperty('externalPaymentType', MagentoPaymentType)
                                        .AddProperty('paymentReference', TransactionId)
                                        .AddProperty('paymentAmount', Format(PaymentAmount, 0, 9));
        PaymentDocumentDetailsJsonObject.EndObject();
    end;

    local procedure CreateVoucherLineJson(var SalesLineDetailsJsonObject: Codeunit "NPR Json Builder"; VoucherReferenceNo: Code[50]; VoucherAmount: Decimal): Codeunit "NPR Json Builder"
    begin
        SalesLineDetailsJsonObject.StartObject()
                                  .AddProperty('type', 'voucher')
                                  .AddProperty('no', VoucherReferenceNo)
                                  .AddProperty('variantCode', '')
                                  .AddProperty('description', 'Voucher Payment')
                                  .AddProperty('voucherType', 'PARTIAL')
                                  .AddProperty('unitPrice', Format(VoucherAmount, 0, 9))
                                  .AddProperty('quantity', Format(1, 0, 9))
                                  .AddProperty('unitOfMeasure', '')
                                  .AddProperty('vatPercent', Format(25, 0, 9))
                                  .AddProperty('lineAmount', Format(VoucherAmount, 0, 9));
        SalesLineDetailsJsonObject.EndObject();
    end;

    local procedure CreateEcomDocWithVoucherAndItem(var EcomSalesHeader: Record "NPR Ecom Sales Header"; VoucherReferenceNo: Code[50]; VoucherAmount: Decimal; ItemAmount: Decimal; PaymentAmount: Decimal)
    var
        Headers: Dictionary of [Text, Text];
        QueryParameters: Dictionary of [Text, Text];
        Body: JsonObject;
        Response: JsonObject;
        ResponseBody: JsonObject;
        GuidToken: JsonToken;
        GuidValue: Guid;
        ErrorResponse: Text;
    begin
        LibraryNPRetailAPI.CreateAPIPermission(UserSecurityId(), CompanyName(), 'NPR API Ecom');

        // Build the Ecom document JSON with voucher and item lines
        Body := BuildEcomDocWithVoucherAndItemJson('order', VoucherReferenceNo, VoucherAmount, ItemAmount, PaymentAmount);

        // Call the API to create the Ecom document
        Headers.Add('x-api-version', Format(Today, 0, 9));
        Response := LibraryNPRetailAPI.CallApi('POST', 'ecommerce/documents', Body, QueryParameters, Headers);
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);

        if not LibraryNPRetailAPI.IsSuccessStatusCode(Response) then begin
            ResponseBody.WriteTo(ErrorResponse);
            Error('POST create ecom document API call failed. Response: %1', ErrorResponse);
        end;

        // Get the created Ecom document
        if ResponseBody.SelectToken('id', GuidToken) then begin
            GuidValue := GuidToken.AsValue().AsText();
            if not EcomSalesHeader.GetBySystemId(GuidValue) then
                Error('Ecom document not found');
        end else
            Error('id missing from response');
    end;

    local procedure BuildEcomDocWithVoucherAndItemJson(DocType: Text[11]; VoucherReferenceNo: Code[50]; VoucherAmount: Decimal; ItemAmount: Decimal; PaymentAmount: Decimal): JsonObject
    var
        IncSalesDocumentJsonObject: Codeunit "NPR Json Builder";
        PaymentLineJsonObject: Codeunit "NPR Json Builder";
        VoucherLineJsonObject: Codeunit "NPR Json Builder";
        ItemLineJsonObject: Codeunit "NPR Json Builder";
    begin
        // Build the main sales document JSON
        IncSalesDocumentJsonObject.StartObject('salesDocument')
                                 .AddProperty('externalNo', ExternalNo)
                                 .AddProperty('id', Format(CreateGuid(), 0, 4).ToLower())
                                 .AddProperty('documentType', DocType)
                                 .AddProperty('currencyCode', '')
                                 .AddProperty('currencyExchangeRate', 1)
                                 .AddProperty('externalDocumentNo', '')
                                 .AddProperty('yourReference', '')
                                 .AddProperty('pricesExcludingVat', false)
                                 .StartObject('sellToCustomer')
                                    .AddProperty('no', Customer."No.")
                                    .AddProperty('name', Customer.Name)
                                    .AddProperty('address', Customer.Address)
                                    .AddProperty('postCode', Customer."Post Code")
                                    .AddProperty('city', Customer.City)
                                    .AddProperty('countryCode', Customer."Country/Region Code")
                                    .AddProperty('email', Customer."E-Mail")
                                .EndObject();

        // Add payments array (points payment)
        IncSalesDocumentJsonObject.StartArray('payments');
        PaymentLineJsonObject := CreatePaymentLineJson(IncSalesDocumentJsonObject, PaymentAmount);
        IncSalesDocumentJsonObject.AddObject(PaymentLineJsonObject);
        IncSalesDocumentJsonObject.EndArray();

        // Add sales document lines array with voucher and item lines
        IncSalesDocumentJsonObject.StartArray('salesDocumentLines');
        // Add voucher line
        VoucherLineJsonObject := CreateVoucherLineJson(IncSalesDocumentJsonObject, VoucherReferenceNo, VoucherAmount);
        IncSalesDocumentJsonObject.AddObject(VoucherLineJsonObject);
        // Add item line
        ItemLineJsonObject := CreateItemLineJson(IncSalesDocumentJsonObject, ItemAmount);
        IncSalesDocumentJsonObject.AddObject(ItemLineJsonObject);
        IncSalesDocumentJsonObject.EndArray();

        IncSalesDocumentJsonObject.EndObject();
        exit(IncSalesDocumentJsonObject.Build());
    end;

    local procedure CreateItemLineJson(var SalesLineDetailsJsonObject: Codeunit "NPR Json Builder"; ItemAmount: Decimal): Codeunit "NPR Json Builder"
    begin
        SalesLineDetailsJsonObject.StartObject()
                                  .AddProperty('type', 'item')
                                  .AddProperty('no', ItemNo)
                                  .AddProperty('variantCode', '')
                                  .AddProperty('barcodeNo', '')
                                  .AddProperty('description', ItemDesc)
                                  .AddProperty('unitPrice', Format(ItemAmount, 0, 9))
                                  .AddProperty('quantity', Format(1, 0, 9))
                                  .AddProperty('unitOfMeasure', '')
                                  .AddProperty('vatPercent', Format(25, 0, 9))
                                  .AddProperty('lineAmount', Format(ItemAmount, 0, 9));
        SalesLineDetailsJsonObject.EndObject();
    end;

    local procedure ProcessEcomDocWithFastLineCaptureNoPost(var EcomSalesHeader: Record "NPR Ecom Sales Header"; var SalesHeader: Record "Sales Header"; var Success: Boolean; var ErrorText: Text)
    var
        EcomCaptureImpl: Codeunit "NPR EcomCaptureImpl";
        VATPostingSetup: Record "VAT Posting Setup";
        SalesLine: Record "Sales Line";
    begin
        // Refresh the ecom header to get the latest data
        EcomSalesHeader.Find();

        // Get the created sales header
        if not SalesHeader.Get(SalesHeader."Document Type"::Order, EcomSalesHeader."Created Doc No.") then begin
            Success := false;
            ErrorText := 'Sales header was not created from Ecom document';
            exit;
        end;

        // Process fast line capture using NPR EcomCaptureImpl (this captures payment and processes digital items)
        // Skip if already created - the API pre-processes capture before creating the Sales Header
        if EcomSalesHeader."Creation Status" <> EcomSalesHeader."Creation Status"::Created then begin
            Commit();
            EcomCaptureImpl.Process(EcomSalesHeader, Success, ErrorText);

            if not Success then
                exit;
        end else
            Success := true;

        // Update VAT Posting Setup to ensure it's not blocked (for later posting)
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindSet() then
            repeat
                if SalesLine.Type = SalesLine.Type::"G/L Account" then begin
                    if VATPostingSetup.Get(SalesHeader."VAT Bus. Posting Group", SalesLine."VAT Prod. Posting Group") then begin
                        VATPostingSetup.Blocked := false;
                        VATPostingSetup.Modify();
                    end;
                end;
            until SalesLine.Next() = 0;

        Commit();
    end;

    local procedure VerifyVoucherProcessed(var EcomSalesHeader: Record "NPR Ecom Sales Header"; VoucherReferenceNo: Code[50])
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
        Assert: Codeunit "Assert";
    begin
        // // Find the voucher line in Ecom Sales Lines
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.SetRange(Type, EcomSalesLine.Type::Voucher);
        if EcomSalesLine.FindFirst() then
            // Check if the virtual item has been processed using field 23
            Assert.AreEqual(EcomSalesLine."Virtual Item Process Status"::Processed, EcomSalesLine."Virtual Item Process Status", 'Virtual Item Process Status should be Processed');
    end;
#endif
}