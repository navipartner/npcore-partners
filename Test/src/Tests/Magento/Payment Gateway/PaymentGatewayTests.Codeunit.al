codeunit 85123 "NPR Payment Gateway Tests"
{
    // [FEATURE] Payment Gateway integration module from NP Retail

    Subtype = Test;

    var
        _Assert: Codeunit Assert;
        _LibPaymentGateway: Codeunit "NPR Library - Payment Gateway";
        _LibSales: Codeunit "Library - Sales";
        _TestIntegration: Codeunit "NPR PG CI Test Integration";
        _PaymentEventType: Option " ",Capture,Refund,Cancel;

    #region Interface implementation
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PaymentLineIsCapturedUponPostingTest()
    var
        GatewayCode: Code[10];
        SalesHeader: Record "Sales Header";
        SalesPost: Codeunit "Sales-Post";
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        // [SCENARIO] When a sales header is posted the system should automatically try to capture the payment.

        Initialize();

        // [GIVEN] Given a payment gateway
        GatewayCode := _LibPaymentGateway.CreatePaymentGateway(Enum::"NPR PG Integrations"::"CI Test Integration");

        // [GIVEN] Given a Sales Header with a payment line
        _LibSales.CreateSalesOrder(SalesHeader);
        _LibPaymentGateway.CreatePaymentLineForSalesHeader(SalesHeader, GatewayCode, PaymentLine);

        Commit();

        // [WHEN] When the Sales Header is posted
        SalesHeader.Ship := true;
        SalesHeader.Invoice := true;
        SalesPost.Run(SalesHeader);

        // [THEN] Then an attempt was made to capture the payment
        _Assert.AreEqual(true, _TestIntegration.GetDidCapture(), 'Integration was not called to capture payment even though it should have been');
        _Assert.AreEqual(PaymentLine."No.", UpperCase(_TestIntegration.GetLastTransactionId()), 'Integration was called on a different transaction id than it was supposed to');

        // [THEN] One payment line for the sales inv header is found and is marked as captured today
        PaymentLine.Reset();
        PaymentLine.SetRange("Document Table No.", Database::"Sales Invoice Header");
        PaymentLine.SetRange("Document No.", SalesHeader."Last Posting No.");
        _Assert.AreEqual(true, PaymentLine.FindFirst(), 'Payment line for sales invoice header not found. One should have been created.');
        _Assert.AreEqual(1, PaymentLine.Count(), 'Expected only one payment line for the posted document');
        _Assert.AreEqual(PaymentLine."Date Captured", Today(), 'Payment should have been registered with today as capture date');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PaymentLineIsNotCapturedWhenDisabledTest()
    var
        SalesHeader: Record "Sales Header";
        SalesPost: Codeunit "Sales-Post";
        PaymentGateway: Record "NPR Magento Payment Gateway";
    begin
        // [SCENARIO] When a sales header is posted the system should automatically try to capture the payment.

        Initialize();

        // [GIVEN] Given a payment gateway where capture is disabled
        _LibPaymentGateway.CreatePaymentGateway(Enum::"NPR PG Integrations"::"CI Test Integration", PaymentGateway);
        PaymentGateway."Enable Capture" := false;
        PaymentGateway.Modify();

        // [GIVEN] Given a Sales Header with a payment line
        _LibSales.CreateSalesOrder(SalesHeader);
        _LibPaymentGateway.CreatePaymentLineForSalesHeader(SalesHeader, PaymentGateway.Code);

        Commit();

        // [WHEN] When the Sales Header is posted
        SalesHeader.Ship := true;
        SalesHeader.Invoice := true;
        SalesPost.Run(SalesHeader);

        // [THEN] Then an attempt was NOT made to capture the payment
        _Assert.AreEqual(false, _TestIntegration.GetDidCapture(), 'Integration was not called to capture payment even though it should have been');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PaymentLineIsRefundedUponPostingReverseSalesTest()
    var
        GatewayCode: Code[10];
        SalesHeader: Record "Sales Header";
        SalesPost: Codeunit "Sales-Post";
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        // [SCENARIO] When a reverse sales header with a payment line is posted it should automatically refund the payment.

        Initialize();

        // [GIVEN] Given a payment gateway
        GatewayCode := _LibPaymentGateway.CreatePaymentGateway(Enum::"NPR PG Integrations"::"CI Test Integration");

        // [GIVEN] Given a reserve sales header with a payment line
        _LibSales.CreateSalesCreditMemo(SalesHeader);
        _LibPaymentGateway.CreatePaymentLineForSalesHeader(SalesHeader, GatewayCode, PaymentLine);

        Commit();

        // [WHEN] When the sales header is posted
        SalesHeader.Receive := true;
        SalesHeader.Invoice := true;
        SalesPost.Run(SalesHeader);

        // [THEN] Then an attempt was made to refund the payment
        _Assert.AreEqual(true, _TestIntegration.GetDidRefund(), 'Integration was not called to refund payment');
        _Assert.AreEqual(PaymentLine."No.", UpperCase(_TestIntegration.GetLastTransactionId()), 'Integration was called on a different transaction id than it was supposed to');

        // [THEN] One payment line for the sales cr.memo header is found and is marked as refunded today
        PaymentLine.Reset();
        PaymentLine.SetRange("Document Table No.", Database::"Sales Cr.Memo Header");
        PaymentLine.SetRange("Document No.", SalesHeader."Last Posting No.");
        _Assert.AreEqual(true, PaymentLine.FindFirst(), 'Payment line for sales cr.memo header not found. One should have been created.');
        _Assert.AreEqual(1, PaymentLine.Count(), 'Expected only one payment line for the posted document');
        _Assert.AreEqual(PaymentLine."Date Refunded", Today(), 'Payment have been registered with today as refund date');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PaymentLineIsNotRefundedWhenDisabledTest()
    var
        SalesHeader: Record "Sales Header";
        SalesPost: Codeunit "Sales-Post";
        PaymentGateway: Record "NPR Magento Payment Gateway";
    begin
        // [SCENARIO] When a reverse sales header with a payment line is posted it should automatically refund the payment.

        Initialize();

        // [GIVEN] Given a payment gateway
        _LibPaymentGateway.CreatePaymentGateway(Enum::"NPR PG Integrations"::"CI Test Integration", PaymentGateway);
        PaymentGateway."Enable Refund" := false;
        PaymentGateway.Modify();

        // [GIVEN] Given a reserve sales header with a payment line
        _LibSales.CreateSalesCreditMemo(SalesHeader);
        _LibPaymentGateway.CreatePaymentLineForSalesHeader(SalesHeader, PaymentGateway.Code);

        Commit();

        // [WHEN] When the sales header is posted
        SalesHeader.Receive := true;
        SalesHeader.Invoice := true;
        SalesPost.Run(SalesHeader);

        // [THEN] Then an attempt was NOT made to refund the payment
        _Assert.AreEqual(false, _TestIntegration.GetDidRefund(), 'Integration was not called to refund payment');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PaymentLineIsCancelledWhenDeletedTest()
    var
        GatewayCode: Code[10];
        SalesHeader: Record "Sales Header";
        PaymentLine: Record "NPR Magento Payment Line";
        PaymentLineSystemId: Guid;
    begin
        // [SCENARIO] When a payment line is deleted it should be cancelled

        Initialize();

        // [GIVEN] Given a payment gateway
        GatewayCode := _LibPaymentGateway.CreatePaymentGateway(Enum::"NPR PG Integrations"::"CI Test Integration");

        // [GIVEN] Given a sales header
        _LibSales.CreateSalesOrder(SalesHeader);
        _LibPaymentGateway.CreatePaymentLineForSalesHeader(SalesHeader, GatewayCode, PaymentLine);

        // [WHEN] When the sales header is deleted
        PaymentLineSystemId := PaymentLine.SystemId;
        SalesHeader.Delete(true);

        // [THEN] Then an attempt was made to cancel the payment and the line is deleted
        _Assert.AreEqual(true, _TestIntegration.GetDidCancel(), 'Integration was not called to cancel payment');
        _Assert.AreEqual(PaymentLine."No.", UpperCase(_TestIntegration.GetLastTransactionId()), 'Integration was called on a different transaction id than it was supposed to');
        _Assert.AreEqual(false, PaymentLine.GetBySystemId(PaymentLineSystemId), 'Payment line should have been deleted but still exists');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PaymentLineIsNotCancelledDisabledTest()
    var
        DummySalesHeader: Record "Sales Header";
        PaymentGateway: Record "NPR Magento Payment Gateway";
        PaymentLine: Record "NPR Magento Payment Line";
        PaymentLineSystemId: Guid;
    begin
        // [SCENARIO] When a payment line is deleted it should be cancelled

        Initialize();

        // [GIVEN] Given a payment gateway
        _LibPaymentGateway.CreatePaymentGateway(Enum::"NPR PG Integrations"::"CI Test Integration", PaymentGateway);

        // [GIVEN] Given a sales header
        _LibSales.CreateSalesOrder(DummySalesHeader);
        _LibPaymentGateway.CreatePaymentLineForSalesHeader(DummySalesHeader, PaymentGateway.Code, PaymentLine);

        // [WHEN] When the payment line is deleted
        PaymentLineSystemId := PaymentLine.SystemId;
        PaymentLine.Delete(true);

        // [THEN] Then an attempt was made to cancel the payment
        _Assert.AreEqual(false, _TestIntegration.GetDidCancel(), 'Integration was not called to cancel payment');
        _Assert.AreEqual(false, PaymentLine.GetBySystemId(PaymentLineSystemId), 'Payment line should have been deleted but still exists');
    end;
    #endregion

    #region `Request` table tests
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PaymentRequestIsProperlyFilledFromPaymentLineAttachedToSalesHeaderTest()
    var
        SalesHeader: Record "Sales Header";
        PaymentLine: Record "NPR Magento Payment Line";
        TempRequest: Record "NPR PG Payment Request" temporary;
    begin
        // [GIVEN] Given a sales header and a payment line
        _LibSales.CreateSalesOrder(SalesHeader);
        _LibPaymentGateway.CreatePaymentLineForSalesHeader(SalesHeader, '', PaymentLine);

        // [WHEN] When Payment Line is converted to a Request
        PaymentLine.ToRequest(TempRequest);

        // [THEN] Then the fields on teh request is properly filled out
        _Assert.AreEqual(PaymentLine."No.", TempRequest."Transaction ID", 'Transaction ID on request and Payment Line does not match');
        _Assert.AreEqual(PaymentLine.Amount, TempRequest."Request Amount", 'Amounts do not match on Request and Payment Line');
        _Assert.AreEqual(PaymentLine."Payment Gateway Code", TempRequest."Payment Gateway Code", 'Payment Gateway Code do not match on Request and Payment Line');
        _Assert.AreEqual(PaymentLine."Document Table No.", TempRequest."Document Table No.", 'Document Table No.s do not match on Payment LIne and Request');
        _Assert.AreEqual(SalesHeader.SystemId, TempRequest."Document System Id", 'Document System Id on Request is not matching the on the Sales Header');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PaymentRequestIsProperlyFilledFromPaymentLineAttachedToSalesHeaderWhenSHIsDeletedTest()
    var
        SalesHeader: Record "Sales Header";
        PaymentLine: Record "NPR Magento Payment Line";
        TempRequest: Record "NPR PG Payment Request" temporary;
    begin
        // [GIVEN] Given a deleted sales header and a payment line
        _LibSales.CreateSalesOrder(SalesHeader);
        _LibPaymentGateway.CreatePaymentLineForSalesHeader(SalesHeader, '', PaymentLine);
        SalesHeader.Delete();

        // [WHEN] When Payment Line is converted to a Request
        PaymentLine.ToRequest(TempRequest);

        // [THEN] Then the fields on teh request is properly filled out
        _Assert.AreEqual(PaymentLine."No.", TempRequest."Transaction ID", 'Transaction ID on request and Payment Line does not match');
        _Assert.AreEqual(PaymentLine.Amount, TempRequest."Request Amount", 'Amounts do not match on Request and Payment Line');
        _Assert.AreEqual(PaymentLine."Payment Gateway Code", TempRequest."Payment Gateway Code", 'Payment Gateway Code do not match on Request and Payment Line');
        _Assert.AreEqual(PaymentLine."Document Table No.", TempRequest."Document Table No.", 'Document Table No.s do not match on Payment Line and Request');
        _Assert.AreEqual(true, IsNullGuid(TempRequest."Document System Id"), 'Document System Id should have been a null guid since sales header was deleted');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PaymentRequestIsProperlyFilledFromPaymentLineAttachedToSalesInvoiceHeaderTest()
    var
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
        SalesPost: Codeunit "Sales-Post";
        PaymentLine: Record "NPR Magento Payment Line";
        TempRequest: Record "NPR PG Payment Request" temporary;
    begin
        // [GIVEN] Given a posted invoice header and a payment line
        _LibSales.CreateSalesOrder(SalesHeader);
        _LibPaymentGateway.CreatePaymentLineForSalesHeader(SalesHeader, '');
        SalesHeader.Ship := true;
        SalesHeader.Invoice := true;
        SalesPost.Run(SalesHeader);

        SalesInvHeader.Get(SalesHeader."Last Posting No.");

        PaymentLine.SetRange("Document Table No.", Database::"Sales Invoice Header");
        PaymentLine.SetRange("Document No.", SalesHeader."Last Posting No.");
        _Assert.AreEqual(true, PaymentLine.FindFirst(), 'Payment Line could not be found for the created sales invoice header');

        // [WHEN] When Payment Line is converted to a Request
        PaymentLine.ToRequest(TempRequest);

        // [THEN] Then the fields on teh request is properly filled out
        _Assert.AreEqual(PaymentLine."No.", TempRequest."Transaction ID", 'Transaction ID on request and Payment Line does not match');
        _Assert.AreEqual(PaymentLine.Amount, TempRequest."Request Amount", 'Amounts do not match on Request and Payment Line');
        _Assert.AreEqual(PaymentLine."Payment Gateway Code", TempRequest."Payment Gateway Code", 'Payment Gateway Code do not match on Request and Payment Line');
        _Assert.AreEqual(PaymentLine."Document Table No.", TempRequest."Document Table No.", 'Document Table No.s do not match on Payment Line and Request');
        _Assert.AreEqual(SalesInvHeader.SystemId, TempRequest."Document System Id", 'Document System Id on Request is not matching the on the Sales Invoice Header');
    end;
    #endregion

    #region Error handling tests
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CodeunitRegistersErrorIfIntegrationFailsOnCapture()
    var
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
        SalesPost: Codeunit "Sales-Post";
        GatewayCode: Code[10];
        MagentoPmtMgt: Codeunit "NPR Magento Pmt. Mgt.";
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        // [SCENARIO] The code correctly registers the error when the integrations throws an error during capture
        Initialize();

        // [GIVEN] Given a sales invoice header with a payment line
        _LibSales.CreateSalesOrder(SalesHeader);
        SalesHeader.Ship := true;
        SalesHeader.Invoice := true;
        SalesPost.Run(SalesHeader);

        SalesInvHeader.Get(SalesHeader."Last Posting No.");
        GatewayCode := _LibPaymentGateway.CreatePaymentGateway(Enum::"NPR PG Integrations"::"CI Test Integration");
        _LibPaymentGateway.CreatePaymentLineForSalesInvoiceHeader(SalesInvHeader, GatewayCode, PaymentLine);

        Commit();

        // [WHEN] When the payment line is captured
        _TestIntegration.SetShouldError();
        MagentoPmtMgt.SetProcessingOptions(_PaymentEventType::Capture);

        // [THEN] Then the codeunit registers the error
        asserterror MagentoPmtMgt.Run(PaymentLine);
        _Assert.AreEqual(true, _TestIntegration.GetDidCapture(), 'Integration was not called to do capture. The error captured must have been unrelated.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CodeunitRegistersErrorIfIntegrationFailsOnRefund()
    var
        SalesHeader: Record "Sales Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesPost: Codeunit "Sales-Post";
        GatewayCode: Code[10];
        MagentoPmtMgt: Codeunit "NPR Magento Pmt. Mgt.";
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        // [SCENARIO] The code correctly registers the error when the integrations throws an error during refund
        Initialize();

        // [GIVEN] Given a sales cr. memo header with a payment line
        _LibSales.CreateSalesCreditMemo(SalesHeader);
        SalesHeader.Receive := true;
        SalesHeader.Invoice := true;
        SalesPost.Run(SalesHeader);

        SalesCrMemoHeader.Get(SalesHeader."Last Posting No.");
        GatewayCode := _LibPaymentGateway.CreatePaymentGateway(Enum::"NPR PG Integrations"::"CI Test Integration");
        _LibPaymentGateway.CreatePaymentLineForSalesCrMemoHeader(SalesCrMemoHeader, GatewayCode, PaymentLine);

        Commit();

        // [WHEN] When the payment line is captured
        _TestIntegration.SetShouldError();
        MagentoPmtMgt.SetProcessingOptions(_PaymentEventType::Refund);

        // [THEN] Then the codeunit registers the error
        asserterror MagentoPmtMgt.Run(PaymentLine);
        _Assert.AreEqual(true, _TestIntegration.GetDidRefund(), 'Integration was not called to do refund. The error captured must have been unrelated.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CodeunitRegistersErrorIfIntegrationFailsOnCancel()
    var
        SalesHeader: Record "Sales Header";
        GatewayCode: Code[10];
        MagentoPmtMgt: Codeunit "NPR Magento Pmt. Mgt.";
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        // [SCENARIO] The code correctly registers the error when the integrations throws an error during refund
        Initialize();

        // [GIVEN] Given a deleted sales header with a payment line
        GatewayCode := _LibPaymentGateway.CreatePaymentGateway(Enum::"NPR PG Integrations"::"CI Test Integration");
        _LibSales.CreateSalesOrder(SalesHeader);
        _LibPaymentGateway.CreatePaymentLineForSalesHeader(SalesHeader, GatewayCode, PaymentLine);
        SalesHeader.Delete(false); // no trigger so we can control when cancel action is run

        // [WHEN] When the payment line is captured
        _TestIntegration.SetShouldError();
        MagentoPmtMgt.SetProcessingOptions(_PaymentEventType::Cancel);

        Commit();

        asserterror MagentoPmtMgt.Run(PaymentLine);

        // [THEN] Then the codeunit registers the error
        _Assert.AreEqual(true, _TestIntegration.GetDidCancel(), 'Integration was not called to do cancel. The error captured must have been unrelated.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CommitIsNotAllowedDuringCaptureTest()
    var
        SalesHeader: Record "Sales Header";
        PaymentLine: Record "NPR Magento Payment Line";
        GatewayCode: Code[10];
        MagentoPmtMgt: Codeunit "NPR Magento Pmt. Mgt.";
    begin
        // [SCENARIO] The integration is badly written and tries to commit which we do not allow
        Initialize();

        // [GIVEN] Given a sales header with a payment line
        GatewayCode := _LibPaymentGateway.CreatePaymentGateway(Enum::"NPR PG Integrations"::"CI Test Integration");
        _LibSales.CreateSalesOrder(SalesHeader);
        _LibPaymentGateway.CreatePaymentLineForSalesHeader(SalesHeader, GatewayCode, PaymentLine);

        // [WHEN] When the payment line is captured
        _TestIntegration.SetShouldCommit();
        MagentoPmtMgt.SetProcessingOptions(_PaymentEventType::Capture);

        Commit();

        asserterror MagentoPmtMgt.Run(PaymentLine);

        // [THEN] Then the codeunit registers the error
        _Assert.AreEqual(true, _TestIntegration.GetDidCapture(), 'Integration was not called to capture. The error captured must have been unrelated');
        _Assert.AreEqual(
            true,
            LowerCase(GetLastErrorText()).Contains('commit'),
            'Last error text did not contain the word commit. The error must have been related to something else.'
        );
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CommitIsNotAllowedDuringRefundTest()
    var
        SalesHeader: Record "Sales Header";
        PaymentLine: Record "NPR Magento Payment Line";
        GatewayCode: Code[10];
        MagentoPmtMgt: Codeunit "NPR Magento Pmt. Mgt.";
    begin
        // [SCENARIO] The integration is badly written and tries to commit which we do not allow
        Initialize();

        // [GIVEN] Given a sales credit memo with a payment line
        GatewayCode := _LibPaymentGateway.CreatePaymentGateway(Enum::"NPR PG Integrations"::"CI Test Integration");
        _LibSales.CreateSalesCreditMemo(SalesHeader);
        _LibPaymentGateway.CreatePaymentLineForSalesHeader(SalesHeader, GatewayCode, PaymentLine);

        // [WHEN] When the payment line is refunded
        _TestIntegration.SetShouldCommit();
        MagentoPmtMgt.SetProcessingOptions(_PaymentEventType::Refund);

        Commit();

        asserterror MagentoPmtMgt.Run(PaymentLine);

        // [THEN] Then the codeunit registers the error
        _Assert.AreEqual(true, _TestIntegration.GetDidRefund(), 'Integration was not called to refund. The error captured must have been unrelated');
        _Assert.AreEqual(
            true,
            LowerCase(GetLastErrorText()).Contains('commit'),
            'Last error text did not contain the word commit. The error must have been related to something else.'
        );
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CommitIsNotAllowedDuringCancelTest()
    var
        SalesHeader: Record "Sales Header";
        PaymentLine: Record "NPR Magento Payment Line";
        GatewayCode: Code[10];
        MagentoPmtMgt: Codeunit "NPR Magento Pmt. Mgt.";
    begin
        // [SCENARIO] The integration is badly written and tries to commit which we do not allow
        Initialize();

        // [GIVEN] Given a sales header with a payment line
        GatewayCode := _LibPaymentGateway.CreatePaymentGateway(Enum::"NPR PG Integrations"::"CI Test Integration");
        _LibSales.CreateSalesOrder(SalesHeader);
        _LibPaymentGateway.CreatePaymentLineForSalesHeader(SalesHeader, GatewayCode, PaymentLine);

        // [WHEN] When the payment line is refunded
        _TestIntegration.SetShouldCommit();
        MagentoPmtMgt.SetProcessingOptions(_PaymentEventType::Cancel);

        Commit();

        asserterror MagentoPmtMgt.Run(PaymentLine);

        // [THEN] Then the codeunit registers the error
        _Assert.AreEqual(true, _TestIntegration.GetDidCancel(), 'Integration was not called to cancel. The error captured must have been unrelated');
        _Assert.AreEqual(
            true,
            LowerCase(GetLastErrorText()).Contains('commit'),
            'Last error text did not contain the word commit. The error must have been related to something else.'
        );
    end;
    #endregion

    #region Aux functionality
    local procedure Initialize()
    begin
        _TestIntegration.Reset();
    end;
    #endregion
}