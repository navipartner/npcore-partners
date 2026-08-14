codeunit 85381 "NPR Ecom Async Creation Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit "Assert";
        _LibEcom: Codeunit "NPR Library Ecommerce";
        _LibPOSMasterData: Codeunit "NPR Library - POS Master Data";
        _LibTicket: Codeunit "NPR Library - Ticket Module";
        _TestIntegration: Codeunit "NPR PG CI Test Integration";

    [Test]
    procedure CreateLeavesDocumentPendingWithBucketId()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        SalesHeader: Record "Sales Header";
        HeaderDims: JsonArray;
        LineDims: JsonArray;
    begin
        Initialize();

        // [Scenario] Creation through the V2 API hands the conversion to the job queues instead of doing it
        // inline, so the request must leave a Pending document that the bucket-filtered job queue can pick up.
        // [Given] a plain item order for a fully configured customer - one the document WOULD convert for,
        // so that a still-Pending document means conversion was never attempted rather than that it failed
        // [When] the document is created through the API
        _LibEcom.InsertEcomDocumentWithDimensions(NextExternalNo(), 'order', _LibEcom.CreateItem(), _LibEcom.CreateCustomer(), HeaderDims, LineDims, EcomSalesHeader);

        // [Then] nothing was converted during the request
        _Assert.AreEqual(EcomSalesHeader."Creation Status"::Pending, EcomSalesHeader."Creation Status", 'Document should be left Pending for the job queue.');
        _Assert.AreEqual('', EcomSalesHeader."Created Doc No.", 'No sales document should be created during the API request.');
        SalesHeader.SetRange("NPR Inc Ecom Sale Id", EcomSalesHeader.SystemId);
        _Assert.RecordIsEmpty(SalesHeader);

        // [Then] and no conversion was even attempted - a swallowed inline failure would leave the document
        // Pending too, so the empty error message is what separates "not attempted" from "attempted and failed"
        _Assert.AreEqual('', EcomSalesHeader."Last Error Message", 'No conversion should have been attempted during the API request.');

        // [Then] and the document carries a bucket id, without which no bucket-filtered job queue would see it
        _Assert.AreNotEqual(0, EcomSalesHeader."Bucket Id", 'Document should be stamped with a bucket id.');
    end;

    [Test]
    procedure ConversionJobQueueSkipsDocumentWithUnprocessedVirtualItems()
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        SalesHeader: Record "Sales Header";
    begin
        Initialize();

        // [Scenario] The conversion job queue must ignore a virtual-item document until the FastLane job
        // queues have marked its assets Processed. That gate is what the async contract rests on - without
        // it a document would convert while its vouchers were still unissued.
        // [Given] an order created through the API carrying a voucher that has not been issued yet.
        // The voucher type must apply the PARTIAL payment module - the API rejects a voucher line whose
        // type applies a full-payment module (DEFAULT or LIMIT).
        _LibPOSMasterData.CreatePartialVoucherType(VoucherType, false);
        _LibEcom.InsertEcomDocumentWithVoucherLine(NextExternalNo(), VoucherType.Code, _LibEcom.CreateCustomer(), EcomSalesHeader);
        // Both halves matter. "Virtual Items Exist" is the one the scenario actually rests on - it is
        // what puts the document in the job queue's virtual-item filter block at all. The status check
        // alone would prove nothing: the enum defaults to Pending, so it holds for any fresh document,
        // including one where the voucher line was never recognised as a virtual item.
        _Assert.IsTrue(EcomSalesHeader."Virtual Items Exist", 'Precondition: the voucher line must be recognised as a virtual item.');
        _Assert.AreNotEqual(EcomSalesHeader."Virtual Items Process Status"::Processed, EcomSalesHeader."Virtual Items Process Status", 'Precondition: the voucher must still be unprocessed.');

        // [When] the conversion job queue runs on its own, with no FastLane job queue having run first
        _LibEcom.RunEcomJobQueueOnce(Codeunit::"NPR EcomSalesOrderProcJQ", EcomSalesHeader);

        // [Then] the document was not converted
        EcomSalesHeader.Get(EcomSalesHeader."Entry No.");
        _Assert.AreEqual(EcomSalesHeader."Creation Status"::Pending, EcomSalesHeader."Creation Status", 'Document should still be Pending.');
        SalesHeader.SetRange("NPR Inc Ecom Sale Id", EcomSalesHeader.SystemId);
        _Assert.RecordIsEmpty(SalesHeader);

        // [Then] and it was not even attempted. The job queue processes with SetUpdateRetryCount(true), so
        // a retry count still at zero is what distinguishes "filtered out" from "tried and failed" - which
        // would otherwise look identical, both leaving the document Pending.
        _Assert.AreEqual(0, EcomSalesHeader."Process Retry Count", 'The job queue should not have attempted a document with unprocessed virtual items.');
    end;

    [Test]
    procedure CreateResponseCarriesIdOfThePendingDocument()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Body: JsonObject;
        ResponseJson: JsonObject;
        Lines: JsonArray;
        Line: JsonObject;
        IdToken: JsonToken;
        ExternalNo: Code[20];
    begin
        Initialize();

        // [Scenario] The response can no longer describe a finished sale, so the document id it returns is
        // the caller's only handle for polling the asynchronous outcome. It has to be present and correct.
        // [Given] a plain item order
        ExternalNo := NextExternalNo();
        Body := _LibEcom.BuildEcomDocumentBody(ExternalNo, 'order', _LibEcom.CreateCustomer());
        Line.Add('type', 'item');
        Line.Add('no', _LibEcom.CreateItem());
        Line.Add('quantity', 1);
        Line.Add('unitPrice', 100);
        Line.Add('vatPercent', 0);
        Line.Add('lineAmount', 100);
        Lines.Add(Line);
        Body.Add('salesDocumentLines', Lines);

        // [When] the document is created through the API
        ResponseJson := _LibEcom.SubmitEcomDocumentBodyForResponse(Body, ExternalNo, EcomSalesHeader);

        // [Then] the response identifies the document that was stored. The id sits at the root of the
        // body: NPR Json Builder drops the property name of the object that becomes the root, so
        // StartObject('salesDocument') produces { "id": ... } rather than { "salesDocument": { "id": ... } }.
        _Assert.IsTrue(ResponseJson.SelectToken('id', IdToken), 'Response must carry the document id.');
        _Assert.AreEqual(Format(EcomSalesHeader.SystemId, 0, 4).ToLower(), IdToken.AsValue().AsText(), 'Response id must be the created document.');

        // [Then] and that document is still waiting for the job queue, which is what makes the id useful
        _Assert.AreEqual(EcomSalesHeader."Creation Status"::Pending, EcomSalesHeader."Creation Status", 'The returned id should refer to a document still awaiting conversion.');
    end;

    [Test]
    procedure FailedConversionInTheJobQueueConsumesARetry()
    var
        Item: Record Item;
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        HeaderDims: JsonArray;
        LineDims: JsonArray;
        ItemNo: Code[20];
    begin
        Initialize();

        // [Scenario] Conversion failures now reach the caller as job queue retries rather than as a failed
        // API request. The job queue processes with SetUpdateRetryCount(true) where the removed inline path
        // used false, so a failed attempt has to consume a retry instead of being silently free forever.
        // [Given] an order that will fail conversion, because its item is blocked after the document exists
        _LibEcom.SetMaxDocProcessRetryCount(3);
        ItemNo := _LibEcom.CreateItem();
        _LibEcom.InsertEcomDocumentWithDimensions(NextExternalNo(), 'order', ItemNo, _LibEcom.CreateCustomer(), HeaderDims, LineDims, EcomSalesHeader);
        Item.Get(ItemNo);
        Item.Blocked := true;
        Item.Modify();
        Commit();

        // [When] the conversion job queue runs
        _LibEcom.RunEcomJobQueueOnce(Codeunit::"NPR EcomSalesOrderProcJQ", EcomSalesHeader);

        // [Then] the attempt was counted against the retry budget and the reason recorded
        EcomSalesHeader.Get(EcomSalesHeader."Entry No.");
        _Assert.AreEqual(1, EcomSalesHeader."Process Retry Count", 'A failed conversion must consume a retry.');
        // Naming the blocked item, not merely "some error was recorded" - otherwise a regression that made every
        // conversion fail for an unrelated reason would still satisfy this test.
        _Assert.IsTrue(EcomSalesHeader."Last Error Message".Contains(ItemNo), 'The recorded failure should name the item this test blocked.');

        // [Then] and the document stays Pending while retries remain, rather than terminating on first failure
        _Assert.AreEqual(EcomSalesHeader."Creation Status"::Pending, EcomSalesHeader."Creation Status", 'Document should stay Pending while retries remain.');
    end;

    [Test]
    procedure CreateStampsOrderConfirmationNotificationWithTheDocumentBucketId()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        DigitalNotifEntry: Record "NPR Digital Notification Entry";
        HeaderDims: JsonArray;
        LineDims: JsonArray;
    begin
        Initialize();

        // [Scenario] The order-confirmation entry is written during the request, at which point the document
        // has no bucket yet, so AssignBucketId has to stamp the entry afterwards. If that sync broke the entry
        // would keep Bucket Id 0 and the bucket-filtered notification job queue would never send the mail.
        // [Given] ecommerce order confirmations are configured
        _LibEcom.EnableEcomOrderConfirmation(true);

        // [When] a document is created through the API
        _LibEcom.InsertEcomDocumentWithDimensions(NextExternalNo(), 'order', _LibEcom.CreateItem(), _LibEcom.CreateCustomer(), HeaderDims, LineDims, EcomSalesHeader);

        // [Then] an order-confirmation entry exists for the document
        DigitalNotifEntry.SetRange("Source Document Id", EcomSalesHeader.SystemId);
        DigitalNotifEntry.SetRange("Notification Type", DigitalNotifEntry."Notification Type"::"Order Confirmation");
        _Assert.IsTrue(DigitalNotifEntry.FindFirst(), 'An order confirmation notification entry should exist for the document.');

        // [Then] and it carries the document's bucket, which is what makes it visible to the job queue
        _Assert.AreNotEqual(0, EcomSalesHeader."Bucket Id", 'Precondition: the document must carry a bucket id.');
        _Assert.AreEqual(EcomSalesHeader."Bucket Id", DigitalNotifEntry."Bucket Id", 'Notification entry must be stamped with the document bucket id.');
    end;

    [Test]
    procedure CreateWritesNoOrderConfirmationWhenDisabled()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        DigitalNotifEntry: Record "NPR Digital Notification Entry";
        HeaderDims: JsonArray;
        LineDims: JsonArray;
    begin
        Initialize();

        // [Scenario] Order confirmation is opt-in. The create path runs it through Codeunit.Run and swallows
        // any failure, so an entry queued against a disabled setup would never surface at runtime.
        // [Given] order confirmations fully configured and then switched off. Enabling first is what makes this
        // test about the FLAG: Initialize() deletes the setup singleton, so without the enable step there would
        // be no template id either, and a document that wrote no notification would prove only that an
        // unconfigured feature stays off. The product requires both the flag and a template id, so arranging
        // the id and then clearing the flag is what pins the flag alone as sufficient to stop the write.
        _LibEcom.EnableEcomOrderConfirmation(true);
        _LibEcom.EnableEcomOrderConfirmation(false);

        // [When] a document is created through the API
        _LibEcom.InsertEcomDocumentWithDimensions(NextExternalNo(), 'order', _LibEcom.CreateItem(), _LibEcom.CreateCustomer(), HeaderDims, LineDims, EcomSalesHeader);

        // [Then] no order-confirmation entry was written
        DigitalNotifEntry.SetRange("Source Document Id", EcomSalesHeader.SystemId);
        DigitalNotifEntry.SetRange("Notification Type", DigitalNotifEntry."Notification Type"::"Order Confirmation");
        _Assert.RecordIsEmpty(DigitalNotifEntry);
    end;

    [Test]
    procedure VirtualItemOrderReachesCreatedThroughTheJobQueues()
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesVoucherLink: Record "NPR Ecom Sales Voucher Link";
        PaymentLine: Record "NPR Magento Payment Line";
        ExternalNo: Code[20];
        ExternalPaymentCode: Code[50];
    begin
        Initialize();

        // [Scenario] The positive half of the async contract. A virtual-item order the API leaves Pending must
        // actually reach Created once the FastLane job queues have run: the capture job queue settles the
        // payment through the gateway, which is what marks the voucher line captured; the voucher job queue
        // then issues the voucher; and only then may the conversion job queue take the document.
        // [Given] a voucher order paid through a payment gateway, as every live order is. The gateway is the
        // CI test integration rather than a mapping flagged "Captured Externally" - that flag would stamp the
        // payment line captured on insert and the capture leg under test here would never run at all.
        _LibEcom.EnableEcomOrderConfirmation(false);
        _LibEcom.SetMaxDocProcessRetryCount(3);
        _LibPOSMasterData.CreatePartialVoucherType(VoucherType, false);
        ExternalPaymentCode := _LibEcom.CreateGatewayCapturedPaymentMapping();
        ExternalNo := NextExternalNo();
        _LibEcom.InsertEcomDocumentWithVoucherLineAndPayment(ExternalNo, VoucherType.Code, _LibEcom.CreateCustomer(), ExternalPaymentCode, 100, EcomSalesHeader);
        _Assert.AreEqual(EcomSalesHeader."Creation Status"::Pending, EcomSalesHeader."Creation Status", 'Precondition: the API must leave the document Pending.');

        // [When] the FastLane job queues run in the order the scheduler would run them
        _LibEcom.RunEcomJobQueueOnce(Codeunit::"NPR EcomSaleCaptureJQ", EcomSalesHeader);
        _LibEcom.RunEcomJobQueueOnce(Codeunit::"NPR EcomCreateVoucherJQ", EcomSalesHeader);
        _LibEcom.RunEcomJobQueueOnce(Codeunit::"NPR EcomSalesOrderProcJQ", EcomSalesHeader);

        // [Then] the payment was captured by calling the gateway, not assumed captured. RunEcomJobQueueOnce
        // isolates the document in its own bucket, so the pass could only have captured this one - but the
        // mock's flags are session-global, so the direct evidence is the Date Captured stamp on this
        // document's own payment line: with a gateway-captured mapping nothing else sets it.
        _Assert.IsTrue(_TestIntegration.GetDidCapture(), 'The capture job queue should have called the payment gateway to capture the payment.');
        PaymentLine.SetRange("NPR Inc Ecom Sale Id", EcomSalesHeader.SystemId);
        _Assert.AreEqual(1, PaymentLine.Count(), 'Precondition: capture should have built exactly one payment line for the document.');
        PaymentLine.FindFirst();
        _Assert.AreNotEqual(0D, PaymentLine."Date Captured", 'This document''s payment line should be stamped captured by the gateway.');

        // [Then] the voucher was actually issued - status flags alone would not prove the asset exists
        EcomSalesHeader.Get(EcomSalesHeader."Entry No.");
        _Assert.AreEqual(EcomSalesHeader."Virtual Items Process Status"::Processed, EcomSalesHeader."Virtual Items Process Status", 'The voucher job queue should have processed the virtual item.');
        EcomSalesVoucherLink.SetRange("Source System Id", EcomSalesHeader.SystemId);
        _Assert.AreEqual(1, EcomSalesVoucherLink.Count(), 'Exactly one voucher should have been issued for the document.');

        // [Then] and the document converted
        _Assert.AreEqual(EcomSalesHeader."Creation Status"::Created, EcomSalesHeader."Creation Status", 'The conversion job queue should have created the sales document.');
        _Assert.AreNotEqual('', EcomSalesHeader."Created Doc No.", 'A sales document number should be stamped on the ecom document.');

        // [Then] exactly once. The count spans open AND posted documents because conversion posts a
        // virtual-item order on the spot (PostEcomSalesDoc runs when Virtual Items Exist), which removes the
        // Sales Header - so counting only open orders would report zero for a completely successful run.
        _Assert.AreEqual(1, _LibEcom.CountSalesDocumentsFor(EcomSalesHeader), 'Exactly one sales document should exist for the ecom document.');
    end;

    [Test]
    procedure DeclinedGatewayCaptureIssuesNoVoucherAndDoesNotConvert()
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesVoucherLink: Record "NPR Ecom Sales Voucher Link";
        PaymentLine: Record "NPR Magento Payment Line";
        DidCallGateway: Boolean;
        ExternalNo: Code[20];
        ExternalPaymentCode: Code[50];
        // The mock gateway's own error text. Asserting on it, rather than on "some error was recorded",
        // is what stops an unrelated capture failure from satisfying this test.
        MockCaptureDeclinedLbl: Label 'Failure during capture', Locked = true;
    begin
        Initialize();

        // [Scenario] Capture is the gate in front of every virtual item, and this is what it protects against:
        // when the gateway declines, no voucher may be issued and the order may not convert. Issuing the asset
        // anyway is the expensive failure - the customer holds a gift voucher that was never paid for.
        // [Given] the same voucher order as the successful case, but a gateway that refuses the capture
        _LibEcom.EnableEcomOrderConfirmation(false);
        _LibEcom.SetMaxDocProcessRetryCount(3);
        // Pinned above 1 so the first failure leaves the document retryable rather than terminally Error.
        // Both states keep the voucher job queue away, but retryable is what a declined card actually produces.
        _LibEcom.SetMaxCaptureRetryCount(3);
        _LibPOSMasterData.CreatePartialVoucherType(VoucherType, false);
        ExternalPaymentCode := _LibEcom.CreateGatewayCapturedPaymentMapping();
        ExternalNo := NextExternalNo();
        _LibEcom.InsertEcomDocumentWithVoucherLineAndPayment(ExternalNo, VoucherType.Code, _LibEcom.CreateCustomer(), ExternalPaymentCode, 100, EcomSalesHeader);

        // [When] the capture job queue runs and the gateway declines.
        // Arm the mock LAST, immediately before the pass that needs it, for the same reason it is disarmed
        // immediately after: its state is session state on a SingleInstance codeunit, which test isolation
        // never rolls back. Arming it before the arrangement above would leave it primed to decline for the
        // rest of the session if any of those setup calls threw, and recovery would depend on some later
        // method in this codeunit reaching Initialize() - which holds today only because this method is not
        // declared last.
        _TestIntegration.SetShouldError();
        _LibEcom.RunEcomJobQueueOnce(Codeunit::"NPR EcomSaleCaptureJQ", EcomSalesHeader);

        // Read the mock and disarm it immediately, before anything that can throw. Resetting only at the end of
        // the test would leave the singleton primed to decline for the rest of the session whenever an assertion
        // below fails first - which is exactly when the leak would be hardest to diagnose.
        DidCallGateway := _TestIntegration.GetDidCapture();
        _TestIntegration.Reset();

        // [When] and the two job queues that depend on a captured payment run afterwards
        _LibEcom.RunEcomJobQueueOnce(Codeunit::"NPR EcomCreateVoucherJQ", EcomSalesHeader);
        _LibEcom.RunEcomJobQueueOnce(Codeunit::"NPR EcomSalesOrderProcJQ", EcomSalesHeader);

        // [Then] the gateway was asked and refused, for THIS document's payment. The pass was isolated to this
        // document's own bucket, so it is the only one the gateway could have been called for; the uncaptured
        // payment line and the recorded refusal are the direct, document-scoped evidence of the decline.
        _Assert.IsTrue(DidCallGateway, 'The capture job queue must have called the gateway.');
        PaymentLine.SetRange("NPR Inc Ecom Sale Id", EcomSalesHeader.SystemId);
        _Assert.AreEqual(1, PaymentLine.Count(), 'Precondition: capture should have built exactly one payment line to attempt.');
        PaymentLine.FindFirst();
        _Assert.AreEqual(0D, PaymentLine."Date Captured", 'This document''s payment line must not be stamped captured after the gateway declined.');
        EcomSalesHeader.Get(EcomSalesHeader."Entry No.");
        _Assert.AreEqual(1, EcomSalesHeader."Capture Retry Count", 'A declined capture must consume exactly one capture retry.');
        _Assert.IsTrue(EcomSalesHeader."Last Capture Error Message".Contains(MockCaptureDeclinedLbl), 'The document must record the gateway''s own refusal, not merely some failure.');

        // [Then] no voucher was issued - the voucher job queue only takes documents whose Capture Processing
        // Status reached Partially Processed or Processed, and a refused capture reaches neither
        EcomSalesVoucherLink.SetRange("Source System Id", EcomSalesHeader.SystemId);
        _Assert.RecordIsEmpty(EcomSalesVoucherLink);
        _Assert.AreNotEqual(EcomSalesHeader."Virtual Items Process Status"::Processed, EcomSalesHeader."Virtual Items Process Status", 'A virtual item whose payment never captured must not be processed.');

        // [Then] and the order did not convert
        _Assert.AreEqual(EcomSalesHeader."Creation Status"::Pending, EcomSalesHeader."Creation Status", 'The document must stay Pending when its capture was declined.');
        _Assert.AreEqual(0, _LibEcom.CountSalesDocumentsFor(EcomSalesHeader), 'No sales document should exist for an order whose payment was never captured.');
    end;

    [Test]
    procedure UnscopedSweepProcessesEveryDocumentDespiteAFailure()
    var
        FirstFailing: Record "NPR Ecom Sales Header";
        SecondFailing: Record "NPR Ecom Sales Header";
        Converting: Record "NPR Ecom Sales Header";
    begin
        Initialize();

        // [Scenario] A scheduled entry sweeps 'bucket=1..100' - every eligible document - and wraps each one in
        // `if EcomSalesDocProcess.Run(...) then;` so a single bad document cannot stop the pass. Every other
        // test in this codeunit isolates its document in its own bucket, which is what makes them reliable but
        // also leaves the production parameter string and that multi-document contract unexercised. This test
        // covers both. It is the only unscoped test here, but it does not depend on running last: its two
        // retry assertions are independent of any document earlier methods left behind.
        //
        // TWO failing documents, not one, because the job queue sets no SetCurrentKey and so the order it
        // visits them in is the query optimizer's choice. With one failure and one success, a pass that gave up
        // at the failure would be indistinguishable from one that continued whenever the success happened to be
        // visited first. With two failures, a pass that gave up can only ever record a retry against one of
        // them, whichever order they come in.
        // [Given] two orders that will fail conversion, and one that will succeed
        _LibEcom.SetMaxDocProcessRetryCount(3);
        InsertOrderThatFailsConversion(FirstFailing);
        InsertOrderThatFailsConversion(SecondFailing);
        InsertOrderThatConverts(Converting);
        Commit();

        // [When] a single unscoped pass runs, exactly as a scheduled entry would
        _LibEcom.RunEcomJobQueueOnceUnscoped(Codeunit::"NPR EcomSalesOrderProcJQ");

        // [Then] BOTH failures were attempted - this pair is what catches a pass that stopped early
        FirstFailing.Get(FirstFailing."Entry No.");
        SecondFailing.Get(SecondFailing."Entry No.");
        _Assert.AreEqual(1, FirstFailing."Process Retry Count", 'The first failing document should have been attempted once.');
        _Assert.AreEqual(1, SecondFailing."Process Retry Count", 'The second failing document should have been attempted too - the pass must not stop at the first failure.');
        _Assert.AreNotEqual('', FirstFailing."Last Error Message", 'The first failure should be recorded on its document.');
        _Assert.AreNotEqual('', SecondFailing."Last Error Message", 'The second failure should be recorded on its document.');

        // [Then] and the healthy document converted in the same pass, so the sweep did real work rather than
        // merely failing everything it touched
        Converting.Get(Converting."Entry No.");
        _Assert.AreEqual(Converting."Creation Status"::Created, Converting."Creation Status", 'The healthy document should have converted in the same pass.');
        _Assert.AreNotEqual('', Converting."Created Doc No.", 'A sales document number should be stamped on the converted document.');
    end;

    [Test]
    procedure WalletOrderReachesCreatedThroughTheJobQueues()
    var
        Item: Record Item;
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        WalletAssetHeaderReference: Record "NPR WalletAssetHeaderReference";
        ExternalNo: Code[20];
        ExternalPaymentCode: Code[50];
        ItemNo: Code[20];
    begin
        Initialize();

        // [Scenario] A paid attraction-wallet order across the asynchronous chain. The wallet manager has direct
        // tests, but nothing crossed the glue: the API setting "Is Attraction Wallet" from the item, the header's
        // "Attraction Wallets Exist" stamping, the wallet job queue selecting the document, and conversion
        // waiting for the wallet.
        //
        // Be precise about WHICH gate makes conversion wait, because it is not the obvious one. On this job
        // queue path it is the header-level "Virtual Items Process Status", which CalculateVirtualItemsDocStatus
        // only reports Processed once the wallet is processed too. The wallet-specific line check inside
        // CheckIfDocumentCanBeProcessed is NOT what holds this document: that check sits after an early exit
        // taken when the document has no Ticket/Voucher/Membership/Coupon subtype line, and a standalone wallet
        // line has none - so for a wallet-only order it never runs. That is a real product gap, confirmed and
        // routed to separate work; it is reachable through the manual Process action, which this path does not
        // use. Do not read this test as cover for it.
        //
        // Deliberately a STANDALONE wallet item rather than a wallet bundle. CreateWalletsForTopLevelParentLine
        // exits silently - no status change, no error - unless every bundle component's virtual-item processing has
        // finished, so a bundle would additionally depend on running the component job queues first and in the
        // right order. A standalone item passes that check trivially, which keeps this test about the wallet
        // queue rather than about bundle sequencing.
        // [Given] the wallet feature enabled - without it CreateWallet returns entry no. 0 and the failure is
        // recorded on the line, leaving the header looking exactly as if the queue had never run - plus an item
        // flagged to create an attraction wallet, paid through the CI test gateway
        _LibEcom.EnableAttractionWallets(true);
        ItemNo := _LibEcom.CreateItem();
        Item.Get(ItemNo);
        Item."NPR CreateAttractionWallet" := true;
        Item.Modify();
        ExternalPaymentCode := _LibEcom.CreateGatewayCapturedPaymentMapping();
        ExternalNo := NextExternalNo();
        _LibEcom.InsertEcomDocumentWithItemLineAndPayment(ExternalNo, ItemNo, _LibEcom.CreateCustomer(), ExternalPaymentCode, 100, EcomSalesHeader);

        // [Then] the API recognised it as a wallet line. Note this is orthogonal to Subtype - a standalone wallet
        // item stays Subtype::Item and is identified by the flag alone.
        _Assert.IsTrue(EcomSalesHeader."Attraction Wallets Exist", 'Precondition: the API should have flagged the document as carrying an attraction wallet.');
        _Assert.AreEqual(EcomSalesHeader."Creation Status"::Pending, EcomSalesHeader."Creation Status", 'Precondition: the API must leave the document Pending.');

        // [When] capture settles
        _LibEcom.RunEcomJobQueueOnce(Codeunit::"NPR EcomSaleCaptureJQ", EcomSalesHeader);

        // [Then] the two preconditions the wallet job queue selects on, asserted here so a failure below is not
        // confused with the wallet queue itself misbehaving: the header's capture status must have progressed
        // past Pending, and the LINE must carry the wallet flag - CreateWallets filters parent lines on it, and
        // that is a different field from the header-level one asserted above.
        EcomSalesHeader.Get(EcomSalesHeader."Entry No.");
        // Assert the capture error is empty FIRST: CreateWallets requires Partially Processed or Processed, and a
        // capture that ended in Error would satisfy a mere "not Pending" check while still silently exiting the
        // wallet queue. Asserting the message is empty also prints the reason if there is one.
        _Assert.AreEqual('', EcomSalesHeader."Last Capture Error Message", 'Capture should not have recorded a failure.');
        _Assert.IsTrue(EcomSalesHeader."Capture Processing Status" in [EcomSalesHeader."Capture Processing Status"::"Partially Processed", EcomSalesHeader."Capture Processing Status"::Processed], 'Precondition: capture must have reached Partially Processed or Processed for the wallet job queue to select the document.');
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        _Assert.IsTrue(EcomSalesLine.FindFirst(), 'The document should have a line.');
        _Assert.IsTrue(EcomSalesLine."Is Attraction Wallet", 'Precondition: the line should be flagged as an attraction wallet.');

        // [When] the wallet job queue runs, then conversion
        _LibEcom.RunEcomJobQueueOnce(Codeunit::"NPR EcomProcessWalletsJQ", EcomSalesHeader);
        _LibEcom.RunEcomJobQueueOnce(Codeunit::"NPR EcomSalesOrderProcJQ", EcomSalesHeader);

        // [Then] the wallet job queue processed the document. The failure message is asserted FIRST and it is
        // deliberately the LINE's, not the header's: EcomCreateWalletMgt.HandleResponse records wallet failures on
        // the parent line ("Attr. Wallet Process ErrMsg"), and leaves the status Pending rather than Error until
        // the retry budget - which self-defaults to 3 - is exhausted. So a failed wallet run is indistinguishable
        // from an unattempted one at header level, and asserting the line message surfaces the reason.
        EcomSalesHeader.Get(EcomSalesHeader."Entry No.");
        EcomSalesLine.FindFirst();
        _Assert.AreEqual('', EcomSalesLine."Attr. Wallet Process ErrMsg", 'Wallet creation should not have recorded a failure on the line.');
        _Assert.AreEqual(EcomSalesHeader."Attr. Wallet Processing Status"::Processed, EcomSalesHeader."Attr. Wallet Processing Status", 'The wallet job queue should have processed the document.');

        // [Then] and a real wallet exists, reachable from the line it was created for
        EcomSalesLine.FindFirst();
        WalletAssetHeaderReference.SetRange(LinkToTableId, Database::"NPR Ecom Sales Line");
        WalletAssetHeaderReference.SetRange(LinkToSystemId, EcomSalesLine.SystemId);
        _Assert.AreEqual(1, WalletAssetHeaderReference.Count(), 'Exactly one wallet should have been created for the line.');

        // [Then] conversion was not attempted and failed - asserting the message is empty surfaces the reason
        // in the assertion output if it was
        _Assert.AreEqual('', EcomSalesHeader."Last Error Message", 'Conversion should not have recorded a failure.');

        // [Then] and the document converted, exactly once
        _Assert.AreEqual(EcomSalesHeader."Creation Status"::Created, EcomSalesHeader."Creation Status", 'The conversion job queue should have created the sales document.');
        _Assert.AreEqual(1, _LibEcom.CountSalesDocumentsFor(EcomSalesHeader), 'Exactly one sales document should exist for the wallet order.');
    end;

    [Test]
    procedure MembershipOrderReachesCreatedThroughTheJobQueues()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomSalesMembershipLink: Record "NPR Ecom Sales Membership Link";
        Membership: Record "NPR MM Membership";
        ExternalNo: Code[20];
        ExternalPaymentCode: Code[50];
        ItemNo: Code[20];
    begin
        Initialize();

        // [Scenario] A paid membership order across the whole asynchronous chain. The membership implementation
        // has extensive direct tests, but none of them crosses the glue this covers: the API classifying the item
        // as a membership line, "Memberships Exist" being stamped, the membership job queue selecting the
        // document, and the conversion gate. A regression in that glue would leave valid orders Pending while every existing
        // membership test stayed green.
        // [Given] an individual-membership item, paid through the CI test gateway. The member email is unique per
        // run so member matching never enters the picture.
        ItemNo := _LibEcom.CreateEcomMembershipItem();
        ExternalPaymentCode := _LibEcom.CreateGatewayCapturedPaymentMapping();
        ExternalNo := NextExternalNo();
        _LibEcom.InsertEcomDocumentWithMembershipLineAndPayment(ExternalNo, ItemNo, _LibEcom.CreateCustomer(), ExternalPaymentCode, 100, LowerCase(ExternalNo) + '@example.invalid', EcomSalesHeader);

        // [Then] the API classified it as a membership line
        _Assert.IsTrue(EcomSalesHeader."Memberships Exist", 'Precondition: the API should have classified the item as a membership line.');
        _Assert.AreEqual(EcomSalesHeader."Creation Status"::Pending, EcomSalesHeader."Creation Status", 'Precondition: the API must leave the document Pending.');

        // [When] the FastLane job queues run in scheduler order
        _LibEcom.RunEcomJobQueueOnce(Codeunit::"NPR EcomSaleCaptureJQ", EcomSalesHeader);
        _LibEcom.RunEcomJobQueueOnce(Codeunit::"NPR EcomCreateMembershipJQ", EcomSalesHeader);
        _LibEcom.RunEcomJobQueueOnce(Codeunit::"NPR EcomSalesOrderProcJQ", EcomSalesHeader);

        // [Then] the membership job queue processed the document
        EcomSalesHeader.Get(EcomSalesHeader."Entry No.");
        _Assert.AreEqual(EcomSalesHeader."Membership Processing Status"::Processed, EcomSalesHeader."Membership Processing Status", 'The membership job queue should have processed the document.');

        // [Then] and a real membership was created - the line carries its id, and the link resolves to an actual
        // membership record rather than just existing
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        _Assert.IsTrue(EcomSalesLine.FindFirst(), 'The document should have a line.');
        _Assert.IsFalse(IsNullGuid(EcomSalesLine."Membership Id"), 'The issued membership id should be written back onto the line.');
        EcomSalesMembershipLink.SetRange("Source Line System Id", EcomSalesLine.SystemId);
        _Assert.AreEqual(1, EcomSalesMembershipLink.Count(), 'Exactly one membership should have been issued for the line.');
        EcomSalesMembershipLink.FindFirst();
        _Assert.IsTrue(Membership.GetBySystemId(EcomSalesMembershipLink."Membership System Id"), 'The link should resolve to a real membership.');

        // [Then] the conversion job queue's own precondition holds - it only takes virtual-item documents whose
        // Virtual Items Process Status has reached Processed, which the membership process recalculates on success
        _Assert.AreEqual(EcomSalesHeader."Virtual Items Process Status"::Processed, EcomSalesHeader."Virtual Items Process Status", 'Precondition for conversion: virtual-item processing should be Processed.');

        // [Then] and conversion was not merely attempted and failed. Asserting the message is empty rather than
        // just checking the status surfaces the reason in the assertion output when it is not.
        _Assert.AreEqual('', EcomSalesHeader."Last Error Message", 'Conversion should not have recorded a failure.');

        // [Then] and the document converted, exactly once
        _Assert.AreEqual(EcomSalesHeader."Creation Status"::Created, EcomSalesHeader."Creation Status", 'The conversion job queue should have created the sales document.');
        _Assert.AreEqual(1, _LibEcom.CountSalesDocumentsFor(EcomSalesHeader), 'Exactly one sales document should exist for the membership order.');
    end;

    [Test]
    procedure CouponOrderReachesCreatedThroughTheJobQueues()
    var
        CouponType: Record "NPR NpDc Coupon Type";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesCouponLink: Record "NPR Ecom Sales Coupon Link";
        NpDcCoupon: Record "NPR NpDc Coupon";
        ExternalNo: Code[20];
        ExternalPaymentCode: Code[50];
        ItemNo: Code[20];
    begin
        Initialize();

        // [Scenario] A paid coupon order across the whole asynchronous chain: capture settles through the
        // gateway, the coupon job queue issues, conversion takes the document. EcomCouponTests covers the coupon
        // implementation directly but never the glue - the API deciding the line is a coupon, "Coupons Exist"
        // being stamped, the coupon job queue selecting the document, and the conversion gate.
        // [Given] an item wired to an enabled ON-ECOM-SALE coupon type, paid through the CI test gateway
        ItemNo := _LibEcom.CreateEcomCouponItem(CouponType);
        ExternalPaymentCode := _LibEcom.CreateGatewayCapturedPaymentMapping();
        ExternalNo := NextExternalNo();
        _LibEcom.InsertEcomDocumentWithItemLineAndPayment(ExternalNo, ItemNo, _LibEcom.CreateCustomer(), ExternalPaymentCode, 100, EcomSalesHeader);

        // [Then] the API classified it as a coupon line. This assertion is the whole reason the test exists in
        // this suite: if the coupon type were disabled or its setup row missing, nothing would error - the line
        // would simply become a plain item and the coupon job queue would never select the document.
        _Assert.IsTrue(EcomSalesHeader."Coupons Exist", 'Precondition: the API should have classified the item as a coupon line.');
        _Assert.AreEqual(EcomSalesHeader."Creation Status"::Pending, EcomSalesHeader."Creation Status", 'Precondition: the API must leave the document Pending.');

        // [When] the FastLane job queues run in scheduler order
        _LibEcom.RunEcomJobQueueOnce(Codeunit::"NPR EcomSaleCaptureJQ", EcomSalesHeader);
        _LibEcom.RunEcomJobQueueOnce(Codeunit::"NPR EcomCreateCouponJQ", EcomSalesHeader);
        _LibEcom.RunEcomJobQueueOnce(Codeunit::"NPR EcomSalesOrderProcJQ", EcomSalesHeader);

        // [Then] the coupon job queue processed the document
        EcomSalesHeader.Get(EcomSalesHeader."Entry No.");
        _Assert.AreEqual(EcomSalesHeader."Coupon Processing Status"::Processed, EcomSalesHeader."Coupon Processing Status", 'The coupon job queue should have processed the document.');

        // [Then] and a real coupon was issued - the link alone would not prove the coupon exists, so follow it
        // through to the coupon record and check it carries an issued reference number
        EcomSalesCouponLink.SetRange("Source System Id", EcomSalesHeader.SystemId);
        _Assert.AreEqual(1, EcomSalesCouponLink.Count(), 'Exactly one coupon should have been issued for the document.');
        EcomSalesCouponLink.FindFirst();
        _Assert.IsTrue(NpDcCoupon.GetBySystemId(EcomSalesCouponLink."Coupon System Id"), 'The link should resolve to a real coupon.');
        _Assert.AreNotEqual('', NpDcCoupon."Reference No.", 'The issued coupon should carry a reference number.');

        // [Then] and the document converted, exactly once
        _Assert.AreEqual(EcomSalesHeader."Creation Status"::Created, EcomSalesHeader."Creation Status", 'The conversion job queue should have created the sales document.');
        _Assert.AreEqual(1, _LibEcom.CountSalesDocumentsFor(EcomSalesHeader), 'Exactly one sales document should exist for the coupon order.');
    end;

    [Test]
    procedure NotificationJobQueueAttemptsAQueuedEntry()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        DigitalNotifEntry: Record "NPR Digital Notification Entry";
        HeaderDims: JsonArray;
        LineDims: JsonArray;
    begin
        Initialize();

        // [Scenario] The tests above prove an order-confirmation entry is WRITTEN during the request and stamped
        // with the document's bucket, but nothing ever ran EcomDigitalNotifJQ, so no test had ever shown the
        // queue picking an entry up at all. This runs it. The entry it selects satisfies all four conditions
        // the queue narrows on - Document Type, Sent = false, Attempt Count < Max Attempts, and the
        // notification-type filter it applies when only one of the two toggles is on - and the arrangement is
        // deliberate about each: Max Attempts is pinned above zero by EnableEcomOrderConfirmation, and
        // Initialize() leaves digital assets off so the single-toggle branch is the one taken.
        // What this does NOT show is that any of those four excludes anything; see the note on
        // RunEcomJobQueueOnce for why a one-entry pass cannot.
        //
        // Deliberately the ORDER CONFIRMATION type rather than DIGITAL ASSETS, and that is a real limitation
        // rather than a convenience. A digital-assets entry is only created once a manifest exists:
        // DigitalOrderNotifMgt.ProcessSalesDocument requires NPDesignerManifestFacade.CreateManifest to return a
        // manifest AND Context.AssetsAdded() > 0, which needs NP Designer configured - a subsystem well outside
        // this suite. Order-confirmation entries skip the manifest branch entirely and reach
        // CreateNotificationEntry directly, so they exercise the same job queue without it. The digital-assets
        // half of this path therefore remains uncovered; it is recorded as a gap rather than faked here.
        //
        // The template id deliberately does not resolve, so the send must FAIL. That failure is the evidence:
        // an entry the job queue never selected would still be sitting at Attempt Count 0.
        _LibEcom.EnableEcomOrderConfirmation(true);
        _LibEcom.InsertEcomDocumentWithDimensions(NextExternalNo(), 'order', _LibEcom.CreateItem(), _LibEcom.CreateCustomer(), HeaderDims, LineDims, EcomSalesHeader);

        // [Then] the request queued exactly one entry, unsent and never attempted
        DigitalNotifEntry.SetRange("Source Document Id", EcomSalesHeader.SystemId);
        DigitalNotifEntry.SetRange("Notification Type", DigitalNotifEntry."Notification Type"::"Order Confirmation");
        _Assert.AreEqual(1, DigitalNotifEntry.Count(), 'Precondition: the request should have queued exactly one order-confirmation notification.');
        DigitalNotifEntry.FindFirst();
        _Assert.IsFalse(DigitalNotifEntry.Sent, 'Precondition: the entry should not be sent yet.');
        _Assert.AreEqual(0, DigitalNotifEntry."Attempt Count", 'Precondition: no send should have been attempted yet.');

        // [When] the digital-notification job queue runs
        _LibEcom.RunEcomJobQueueOnce(Codeunit::"NPR EcomDigitalNotifJQ", EcomSalesHeader);

        // [Then] it selected the entry and attempted the send. The attempt count and the still-unsent flag are
        // the subject - together they prove the entry passed every filter and was actually processed rather than
        // silently skipped.
        DigitalNotifEntry.Find();
        _Assert.AreEqual(1, DigitalNotifEntry."Attempt Count", 'The job queue should have attempted the send exactly once.');
        _Assert.IsFalse(DigitalNotifEntry.Sent, 'A send against a template that does not resolve must not be marked Sent.');

        // [Then] and it failed for the reason this test arranged, rather than merely failing somehow. "Some error
        // was recorded" would be satisfied by an unrelated cause - no email account, a bad recipient - which
        // would leave the test green while proving nothing about template resolution.
        // The recorded message names the template the entry pointed at: DigitalNotificationSend.SendNotification
        // stores GetLastErrorText verbatim, and NPEmailDynTemplateImpl.SendEmail opens with
        // NPEmailTemplate.Get(TemplateId), so an unresolvable id is the FIRST thing that can fail and the
        // platform's message carries the id it could not find.
        // Asserted against the entry's own field rather than a repeated literal, so this cannot drift from the
        // placeholder EnableEcomOrderConfirmation supplies. Only that id is asserted, never the surrounding
        // 'does not exist' wording, which is platform-owned and varies across the version matrix - the same
        // discipline as the retry tests naming the blocked item instead of the base-app text.
        _Assert.AreNotEqual('', DigitalNotifEntry."Email Template Id", 'Precondition: the entry must carry a template id, or the message assertion below would be vacuous.');
        _Assert.IsTrue(DigitalNotifEntry."Error Message".Contains(DigitalNotifEntry."Email Template Id"), 'The failure should record that the entry''s own email template could not be resolved.');
    end;

    [Test]
    procedure TicketOrderReachesCreatedThroughTheJobQueues()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        Ticket: Record "NPR TM Ticket";
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        ExternalNo: Code[20];
        ExternalPaymentCode: Code[50];
        ItemNo: Code[20];
    begin
        Initialize();

        // [Scenario] A paid ticket order has to travel the whole asynchronous chain: capture settles the payment
        // through the gateway, the ticket job queue issues the tickets, and only then may conversion take the
        // document. Nothing covered this before - EcommerceTicketTests builds its ecom document directly and
        // calls EcomCreateTicketImpl by hand, so it never exercises the API's subtype classification, the
        // "Tickets Exist" stamping, the ticket job queue selecting the document, or the conversion gate.
        // [Given] a fully set up ticket item, paid for through the CI test payment gateway
        ItemNo := _LibTicket.CreateScenario_SmokeTest();
        ExternalPaymentCode := _LibEcom.CreateGatewayCapturedPaymentMapping();
        ExternalNo := NextExternalNo();
        _LibEcom.InsertEcomDocumentWithItemLineAndPayment(ExternalNo, ItemNo, _LibEcom.CreateCustomer(), ExternalPaymentCode, 100, EcomSalesHeader);

        // [Then] the API recognised it as a ticket line. This is the precondition the ticket job queue selects
        // on, and it is the half EcommerceTicketTests can never check because it sets the flag itself.
        _Assert.IsTrue(EcomSalesHeader."Tickets Exist", 'Precondition: the API should have classified the item as a ticket line.');
        _Assert.AreEqual(EcomSalesHeader."Creation Status"::Pending, EcomSalesHeader."Creation Status", 'Precondition: the API must leave the document Pending.');

        // [When] the FastLane job queues run in the order the scheduler would run them
        _LibEcom.RunEcomJobQueueOnce(Codeunit::"NPR EcomSaleCaptureJQ", EcomSalesHeader);
        _LibEcom.RunEcomJobQueueOnce(Codeunit::"NPR EcomCreateTicketJQ", EcomSalesHeader);
        _LibEcom.RunEcomJobQueueOnce(Codeunit::"NPR EcomSalesOrderProcJQ", EcomSalesHeader);

        // [Then] the ticket job queue processed the document
        EcomSalesHeader.Get(EcomSalesHeader."Entry No.");
        _Assert.AreEqual(EcomSalesHeader."Ticket Processing Status"::Processed, EcomSalesHeader."Ticket Processing Status", 'The ticket job queue should have processed the document.');

        // [Then] and a real ticket exists. Status flags alone would not prove issuance, so follow the document's
        // handles through to the ticket - BOTH of them, because the product treats them as a pair and validates
        // exactly that before conversion: once the header carries a reservation token, every ticket line must
        // carry a reservation line id, or EcomSalesDocUtils errors with '%1 is set on the document, but ticket
        // line %2 is missing %3'. Asserting one and not the other would leave half of that invariant unpinned.
        // Each is read here the way the product reads it:
        //   * the TOKEN is the session handle, and every product read guards it against blank before filtering
        //     requests on "Session Token ID" - EcomCreateTicketImpl, EcomCreateTicketTryProcess,
        //     EcomSaleDocCaptureProcess all do. That guard is the point rather than ceremony: a blank token
        //     turns a token filter into a match-anything filter.
        //   * the LINE id is the row handle - the request's SystemId, resolved with IsNullGuid-then-
        //     GetBySystemId as in DigNotifTicketImpl, EcomCreateWalletMgt and EcomCreateTicketImpl. It lands on
        //     this line's PRIMARY request row, where a token filter plus FindFirst would return whichever row
        //     of the session sorted first - not necessarily this line's, since a multi-admission item inserts
        //     several rows under one token.
        _Assert.AreNotEqual('', EcomSalesHeader."Ticket Reservation Token", 'The ticket job queue should have stamped the reservation token on the header.');
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        _Assert.IsTrue(EcomSalesLine.FindFirst(), 'The document should have a line.');
        _Assert.IsFalse(IsNullGuid(EcomSalesLine."Ticket Reservation Line Id"), 'The issued reservation id should be written back onto the line.');
        _Assert.IsTrue(TicketRequest.GetBySystemId(EcomSalesLine."Ticket Reservation Line Id"), 'The line should resolve to a real ticket reservation request.');
        _Assert.AreEqual(EcomSalesHeader."Ticket Reservation Token", TicketRequest."Session Token ID", 'The line''s reservation should belong to this document''s reservation session.');
        _Assert.AreEqual(TicketRequest."Request Status"::Confirmed, TicketRequest."Request Status", 'The ticket job queue should have confirmed the reservation.');
        Ticket.SetRange("Ticket Reservation Entry No.", TicketRequest."Entry No.");
        _Assert.IsTrue(Ticket.FindFirst(), 'A ticket should have been issued against the confirmed reservation.');

        // [Then] and the document converted, exactly once
        _Assert.AreEqual(EcomSalesHeader."Creation Status"::Created, EcomSalesHeader."Creation Status", 'The conversion job queue should have created the sales document.');
        _Assert.AreEqual(1, _LibEcom.CountSalesDocumentsFor(EcomSalesHeader), 'Exactly one sales document should exist for the ticket order.');
    end;

    [Test]
    procedure CreateLeavesReturnOrderPendingWithBucketId()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        SalesHeader: Record "Sales Header";
        HeaderDims: JsonArray;
        LineDims: JsonArray;
    begin
        Initialize();

        // [Scenario] The async contract has to hold for return orders too, not just orders - they are
        // converted by their own job queue (EcomSalesRetOrderProcJQ) and were previously converted inline by
        // the same removed call, so the request must leave them Pending and visible to that job queue.
        // [Given] a return order for a fully configured customer
        // [When] it is created through the API
        _LibEcom.InsertEcomDocumentWithDimensions(NextExternalNo(), 'returnOrder', _LibEcom.CreateItem(), _LibEcom.CreateCustomer(), HeaderDims, LineDims, EcomSalesHeader);

        // [Then] it is a return order, left Pending, with nothing converted during the request
        _Assert.AreEqual(EcomSalesHeader."Document Type"::"Return Order", EcomSalesHeader."Document Type", 'Precondition: the document should be a return order.');
        _Assert.AreEqual(EcomSalesHeader."Creation Status"::Pending, EcomSalesHeader."Creation Status", 'A return order should be left Pending for its job queue.');
        _Assert.AreEqual('', EcomSalesHeader."Created Doc No.", 'No sales document should be created during the API request.');
        SalesHeader.SetRange("NPR Inc Ecom Sale Id", EcomSalesHeader.SystemId);
        _Assert.RecordIsEmpty(SalesHeader);

        // [Then] and no conversion was attempted - an empty error message separates "not attempted" from "failed"
        _Assert.AreEqual('', EcomSalesHeader."Last Error Message", 'No conversion should have been attempted during the API request.');

        // [Then] and it carries a bucket, without which the return-order job queue would never see it
        _Assert.AreNotEqual(0, EcomSalesHeader."Bucket Id", 'A return order should be stamped with a bucket id.');
    end;

    [Test]
    procedure ReturnOrderReachesCreatedThroughTheReturnJobQueue()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        SalesHeader: Record "Sales Header";
        HeaderDims: JsonArray;
        LineDims: JsonArray;
    begin
        Initialize();

        // [Scenario] The other half of the return-order contract: EcomSalesRetOrderProcJQ must actually pick
        // a Pending return order up and convert it. Nothing tested this path before - the async return-order
        // conversion had zero coverage.
        // [Given] a return order the API left Pending
        _LibEcom.SetMaxDocProcessRetryCount(3);
        _LibEcom.InsertEcomDocumentWithDimensions(NextExternalNo(), 'returnOrder', _LibEcom.CreateItem(), _LibEcom.CreateCustomer(), HeaderDims, LineDims, EcomSalesHeader);
        _Assert.AreEqual(EcomSalesHeader."Creation Status"::Pending, EcomSalesHeader."Creation Status", 'Precondition: the API must leave the return order Pending.');

        // [When] the return-order job queue runs
        _LibEcom.RunEcomJobQueueOnce(Codeunit::"NPR EcomSalesRetOrderProcJQ", EcomSalesHeader);

        // [Then] it converted
        EcomSalesHeader.Get(EcomSalesHeader."Entry No.");
        _Assert.AreEqual(EcomSalesHeader."Creation Status"::Created, EcomSalesHeader."Creation Status", 'The return-order job queue should have converted the document.');
        _Assert.AreNotEqual('', EcomSalesHeader."Created Doc No.", 'A document number should be stamped on the ecom document.');

        // [Then] and what it created is a sales RETURN order, not an order - EcomSalesDocImplV2 maps the ecom
        // document type onto the sales document type, and getting that wrong would post the wrong direction
        SalesHeader.SetRange("NPR Inc Ecom Sale Id", EcomSalesHeader.SystemId);
        _Assert.AreEqual(1, SalesHeader.Count(), 'Exactly one sales document should exist for the return order.');
        SalesHeader.FindFirst();
        _Assert.AreEqual(SalesHeader."Document Type"::"Return Order", SalesHeader."Document Type", 'The created sales document should be a return order.');

        // [Then] and it is left Open, because Release Sale Ret Ord After Prc defaults to false. Initialize()
        // reset the setup, so this is the deterministic not-released branch - the paired test covers the other.
        _Assert.AreEqual(SalesHeader.Status::Open, SalesHeader.Status, 'Without the release setting the sales return order should be left Open.');
    end;

    [Test]
    procedure ReturnOrderIsReleasedAfterConversionWhenConfigured()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        SalesHeader: Record "Sales Header";
        HeaderDims: JsonArray;
        LineDims: JsonArray;
    begin
        Initialize();

        // [Scenario] Conversion releases the sales return order it produced when the setup says so
        // (EcomSalesDocImplV2 calls PerformManualRelease for a Return Order when Release Sale Ret Ord After Prc
        // is set). Nothing in the test app referenced that field before, so a regression that silently stopped
        // releasing would have left every return order sitting Open with no test noticing.
        // [Given] the release setting enabled, and a return order the API left Pending
        _LibEcom.SetMaxDocProcessRetryCount(3);
        _LibEcom.SetReleaseSalesReturnOrderAfterProcessing(true);
        _LibEcom.InsertEcomDocumentWithDimensions(NextExternalNo(), 'returnOrder', _LibEcom.CreateItem(), _LibEcom.CreateCustomer(), HeaderDims, LineDims, EcomSalesHeader);
        // Load-bearing, not decoration: the release setting is arranged BEFORE the insert, so if the API
        // ever converted inline again it would also release, the job queue pass below would be a no-op
        // (EcomSalesRetOrderProcJQ selects Creation Status = Pending), and all three assertions would still
        // hold. This is what makes the test able to say the JOB QUEUE released it rather than the request.
        _Assert.AreEqual(EcomSalesHeader."Creation Status"::Pending, EcomSalesHeader."Creation Status", 'Precondition: the API must leave the return order Pending.');

        // [When] the return-order job queue converts it
        _LibEcom.RunEcomJobQueueOnce(Codeunit::"NPR EcomSalesRetOrderProcJQ", EcomSalesHeader);

        // [Then] it converted, and the sales return order was released rather than left Open
        EcomSalesHeader.Get(EcomSalesHeader."Entry No.");
        _Assert.AreEqual(EcomSalesHeader."Creation Status"::Created, EcomSalesHeader."Creation Status", 'Precondition: the return order should have converted.');
        SalesHeader.SetRange("NPR Inc Ecom Sale Id", EcomSalesHeader.SystemId);
        _Assert.IsTrue(SalesHeader.FindFirst(), 'Precondition: a sales return order should exist.');
        _Assert.AreEqual(SalesHeader.Status::Released, SalesHeader.Status, 'The sales return order should have been released after conversion.');
    end;

    [Test]
    procedure FailedReturnOrderConversionConsumesARetry()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        ItemNo: Code[20];
    begin
        Initialize();

        // [Scenario] The return-order job queue has its own retry filter (Process Retry Count <= Max) and, unlike
        // the order job queue, calls EcomSalesDocProcess.Run bare rather than inside `if ... then;`. Retry
        // accounting on the return path therefore needs its own proof: a failed return conversion must consume a
        // retry and leave the document retryable, exactly as on the order path.
        // [Given] a return order that will fail conversion, because its item is blocked after the document exists
        _LibEcom.SetMaxDocProcessRetryCount(3);
        ItemNo := InsertDocumentThatFailsConversion('returnOrder', EcomSalesHeader);
        Commit();

        // [When] the return-order job queue runs
        _LibEcom.RunEcomJobQueueOnce(Codeunit::"NPR EcomSalesRetOrderProcJQ", EcomSalesHeader);

        // [Then] the attempt was counted and the reason recorded, naming the item this test blocked
        EcomSalesHeader.Get(EcomSalesHeader."Entry No.");
        _Assert.AreEqual(1, EcomSalesHeader."Process Retry Count", 'A failed return-order conversion must consume a retry.');
        _Assert.IsTrue(EcomSalesHeader."Last Error Message".Contains(ItemNo), 'The recorded failure should name the item this test blocked.');

        // [Then] and the document stays Pending while retries remain
        _Assert.AreEqual(EcomSalesHeader."Creation Status"::Pending, EcomSalesHeader."Creation Status", 'The return order should stay Pending while retries remain.');
    end;

    [Test]
    procedure RetryBudgetExhaustionTerminatesTheDocumentAsError()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        ItemNo: Code[20];
    begin
        Initialize();

        // [Scenario] The other half of the retry contract. EcomSalesDocProcess.HandleResponse terminates a
        // document as Error once Process Retry Count >= Max Doc Process Retry Count, while both conversion job
        // queues select on <= Max - a boundary pair that is easy to get off by one in either direction. The
        // tests above only prove a document stays retryable while budget remains; nothing proved the budget
        // actually runs out, so a document could have been retried forever without any test noticing.
        // [Given] a retry budget of exactly one, and an order that will fail conversion
        _LibEcom.SetMaxDocProcessRetryCount(1);
        ItemNo := InsertDocumentThatFailsConversion('order', EcomSalesHeader);
        Commit();

        // [When] the conversion job queue runs once - so the first failure both consumes and exhausts the budget
        _LibEcom.RunEcomJobQueueOnce(Codeunit::"NPR EcomSalesOrderProcJQ", EcomSalesHeader);

        // [Then] the document was terminated rather than left for another attempt
        EcomSalesHeader.Get(EcomSalesHeader."Entry No.");
        _Assert.AreEqual(1, EcomSalesHeader."Process Retry Count", 'The single attempt should have consumed the whole budget.');
        _Assert.AreEqual(EcomSalesHeader."Creation Status"::Error, EcomSalesHeader."Creation Status", 'A document whose retry budget is exhausted must be terminated as Error, not left Pending.');
        _Assert.IsTrue(EcomSalesHeader."Last Error Message".Contains(ItemNo), 'The recorded failure should name the item this test blocked.');
    end;

    [Test]
    procedure OrderJobQueueIgnoresReturnOrders()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        SalesHeader: Record "Sales Header";
        HeaderDims: JsonArray;
        LineDims: JsonArray;
    begin
        Initialize();

        // [Scenario] Orders and return orders are converted by two different job queues, each filtering on
        // Document Type. Picking up the wrong kind would not post the wrong direction - EcomSalesDocImplV2 maps
        // the sales document type from the ecom document, not from the queue - but it would convert the document
        // under the other queue's schedule and locking envelope, collapsing a split that is deliberate. This
        // pins the split from the order side; the return job queue's own filter is covered by the tests above.
        // [Given] a return order the API left Pending
        _LibEcom.SetMaxDocProcessRetryCount(3);
        _LibEcom.InsertEcomDocumentWithDimensions(NextExternalNo(), 'returnOrder', _LibEcom.CreateItem(), _LibEcom.CreateCustomer(), HeaderDims, LineDims, EcomSalesHeader);

        // [When] the ORDER job queue runs against its bucket
        _LibEcom.RunEcomJobQueueOnce(Codeunit::"NPR EcomSalesOrderProcJQ", EcomSalesHeader);

        // [Then] the return order was not converted
        EcomSalesHeader.Get(EcomSalesHeader."Entry No.");
        _Assert.AreEqual(EcomSalesHeader."Creation Status"::Pending, EcomSalesHeader."Creation Status", 'The order job queue must not convert a return order.');
        SalesHeader.SetRange("NPR Inc Ecom Sale Id", EcomSalesHeader.SystemId);
        _Assert.RecordIsEmpty(SalesHeader);

        // [Then] and it was not even attempted. The job queue processes with SetUpdateRetryCount(true), so a
        // retry count still at zero is what distinguishes "filtered out by Document Type" from "tried and failed"
        _Assert.AreEqual(0, EcomSalesHeader."Process Retry Count", 'The order job queue should not have attempted a return order at all.');
    end;

    [Test]
    procedure ReturnOrderWithVoucherLineIsRejectedByApi()
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        CustomerNo: Code[20];
        ExternalNo: Code[20];
        VoucherOnReturnOrderErr: Label 'Property salesDocumentLines[0]/type has incorrect value: voucher.', Locked = true;
    begin
        Initialize();

        // [Scenario] Return orders carry items only - we never issue vouchers, tickets, memberships, coupons or
        // wallets for them. For an explicitly typed voucher line the API refuses the request during
        // deserialization, so the document is never stored at all, which is the strongest place for the rule to
        // live. Two further layers sit behind it: the asset job queues filter Document Type = Order, and
        // EcomCreateVchrImpl / EcomCreateTicketImpl / EcomCreateCouponImpl / EcomCreateMMShipImpl each
        // FieldError on a Return Order line if ever reached directly.
        //
        // Scope, so this test is not read as proving more than it does: it covers the EXPLICIT 'voucher' line
        // type only. An item whose subtype resolves to a virtual item is not refused here, and what happens to
        // such a return order is an open product question tracked outside this PR.
        //
        // The asserted message is the API's generic property-rejection wrapper - the return-order-specific label
        // is swallowed by the TryFunction that raises it - so this pins "a voucher line is refused", not the
        // reason. That a voucher line is still accepted on an ORDER is what keeps it honest, and
        // ConversionJobQueueSkipsDocumentWithUnprocessedVirtualItems above submits exactly that.
        // [Given] a voucher type and a customer, arranged before the failing call rather than inside it
        _LibPOSMasterData.CreatePartialVoucherType(VoucherType, false);
        CustomerNo := _LibEcom.CreateCustomer();
        ExternalNo := NextExternalNo();

        // [When] a return order carrying a voucher line is submitted
        asserterror _LibEcom.InsertEcomDocumentWithVoucherLine(ExternalNo, 'returnOrder', VoucherType.Code, CustomerNo, EcomSalesHeader);

        // [Then] the API rejected the line type. Asserting the specific message rather than merely that it
        // failed - an unrelated failure would otherwise satisfy this test just as well.
        _Assert.ExpectedError(VoucherOnReturnOrderErr);

        // [Then] and nothing was stored
        EcomSalesHeader.Reset();
        EcomSalesHeader.SetRange("External No.", ExternalNo);
        _Assert.RecordIsEmpty(EcomSalesHeader);
    end;

    // An order that cannot convert: the item is blocked after the document exists, so creation succeeds and
    // conversion fails. Each call creates its own item, so blocking one does not affect the others.
    local procedure InsertOrderThatFailsConversion(var EcomSalesHeader: Record "NPR Ecom Sales Header")
    begin
        InsertDocumentThatFailsConversion('order', EcomSalesHeader);
    end;

    // Returns the item it blocked, so callers can assert that the recorded failure names it. The house rule
    // wants the specific failure pinned rather than "some error", but the blocked-item message itself is
    // base-app text whose wording has changed across BC versions - the ItemNo is data the test configured, so
    // it is both specific and stable across the matrix.
    local procedure InsertDocumentThatFailsConversion(DocumentTypeText: Text; var EcomSalesHeader: Record "NPR Ecom Sales Header") ItemNo: Code[20]
    var
        Item: Record Item;
        HeaderDims: JsonArray;
        LineDims: JsonArray;
    begin
        ItemNo := _LibEcom.CreateItem();
        _LibEcom.InsertEcomDocumentWithDimensions(NextExternalNo(), DocumentTypeText, ItemNo, _LibEcom.CreateCustomer(), HeaderDims, LineDims, EcomSalesHeader);
        Item.Get(ItemNo);
        Item.Blocked := true;
        Item.Modify();
    end;

    local procedure InsertOrderThatConverts(var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        HeaderDims: JsonArray;
        LineDims: JsonArray;
    begin
        _LibEcom.InsertEcomDocumentWithDimensions(NextExternalNo(), 'order', _LibEcom.CreateItem(), _LibEcom.CreateCustomer(), HeaderDims, LineDims, EcomSalesHeader);
    end;

    // Every test starts from the same known state. The setup singletons - see ResetEcomSetupToDefaults for
    // which - are committed rows that survive between tests, and the gateway mock is a session singleton
    // whose flags survive too, so without this a test inherits whatever the previous one left behind.
    // Entry, not exit: a failing assertion would skip trailing cleanup, so restoring afterwards protects
    // only the runs that did not need protecting.
    local procedure Initialize()
    begin
        _LibEcom.ResetEcomSetupToDefaults();
        _TestIntegration.Reset();
    end;

    local procedure NextExternalNo(): Code[20]
    begin
        exit(_LibEcom.NextExternalNo('ASYNC'));
    end;
}
