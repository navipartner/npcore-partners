#if not BC17
codeunit 85547 "NPR Spfy Pmt Line Alloc Tests"
{
    // [FEATURE] Shopify payment lines from order transactions
    // The capture task rebuilds an invoice's payment lines from the order's Shopify transactions. The card authorization
    // sorts before the gift card here, as it did on the production order, so a line sized in transaction id order alone
    // would take the whole invoice. Both queues are covered: the NC task codeunit and its Shopify Task List sibling.
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _LibrarySpfyLegacyReturn: Codeunit "NPR Library Spfy Legacy Return";
        _Assert: Codeunit Assert;
        _StoreCodeLbl: Label 'SPFYPMTALLOC', Locked = true;
        _AuthorizationTxnId: Text[30];
        _GiftCardTxnId: Text[30];
        _GiftCardRefundTxnId: Text[30];
        _CardSaleTxnId: Text[30];
        _CardRefundTxnId: Text[30];
        _CapturedAuthorizationTxnId: Text[30];
        _PointsTxnId: Text[30];
        _TestSeed: Integer;
        _GiftCardIdLbl: Label '2381009', Locked = true;
        _GatewayLbl: Label 'altapay_mobilepay', Locked = true;

    [Test]
    procedure GiftCardLineOnInvoice_NcQueue_AddsNoCardLine()
    var
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] On the NC task queue, an invoice the gift card already pays in full gets no card line, so nothing is left to capture.
        Initialize();

        // [GIVEN] Invoice 59.95 carrying the gift card's voucher line of 59.95
        InvoiceNo := 'SPFYPA-NC1';
        InsertInvoice(InvoiceNo, 59.95);
        AddInvoicePaymentLine(InvoiceNo, Enum::"NPR Magento Payment Type"::Voucher, 59.95, _GiftCardTxnId);

        // [WHEN] The payment lines are rebuilt from a card authorization of 209.92 and a gift card sale of 300
        UpdatePaymentLines(false, InvoiceRecordId(InvoiceNo), CardAndGiftCardJson(209.92, 300));

        // [THEN] No card line is added and the payment lines still add up to the invoice
        _Assert.AreEqual(0, InvoiceLineCount(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'The gift card already pays the invoice, so the card must get no line.');
        _Assert.AreEqual(59.95, InvoiceLinesTotal(InvoiceNo), 'The payment lines must never add up to more than the invoice.');
    end;

    [Test]
    procedure GiftCardLineOnInvoice_TaskList_AddsNoCardLine()
    var
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] On the Shopify Task List, an invoice the gift card already pays in full gets no card line, so nothing is left to capture.
        Initialize();

        // [GIVEN] Invoice 59.95 carrying the gift card's voucher line of 59.95
        InvoiceNo := 'SPFYPA-TL1';
        InsertInvoice(InvoiceNo, 59.95);
        AddInvoicePaymentLine(InvoiceNo, Enum::"NPR Magento Payment Type"::Voucher, 59.95, _GiftCardTxnId);

        // [WHEN] The payment lines are rebuilt from a card authorization of 209.92 and a gift card sale of 300
        UpdatePaymentLines(true, InvoiceRecordId(InvoiceNo), CardAndGiftCardJson(209.92, 300));

        // [THEN] No card line is added and the payment lines still add up to the invoice
        _Assert.AreEqual(0, InvoiceLineCount(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'The gift card already pays the invoice, so the card must get no line.');
        _Assert.AreEqual(59.95, InvoiceLinesTotal(InvoiceNo), 'The payment lines must never add up to more than the invoice.');
    end;

    [Test]
    procedure EmptyInvoice_NcQueue_GiftCardPaysBeforeCard()
    var
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] On the NC task queue, a gift card the invoice total fits in takes the whole invoice before the card, though the card's transaction sorts first.
        Initialize();

        // [GIVEN] Invoice 59.95 without payment lines
        InvoiceNo := 'SPFYPA-NC2';
        InsertInvoice(InvoiceNo, 59.95);

        // [WHEN] The payment lines are built from a card authorization of 209.92 and a gift card sale of 300
        UpdatePaymentLines(false, InvoiceRecordId(InvoiceNo), CardAndGiftCardJson(209.92, 300));

        // [THEN] The gift card pays the 59.95 and the card gets no line
        _Assert.AreEqual(59.95, InvoiceLinesAmount(InvoiceNo, Enum::"NPR Magento Payment Type"::Voucher), 'Shopify already took the gift card money, so the gift card must pay the invoice first.');
        _Assert.AreEqual(0, InvoiceLineCount(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'Nothing is left for the card once the gift card pays the invoice.');
    end;

    [Test]
    procedure EmptyInvoice_TaskList_GiftCardPaysBeforeCard()
    var
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] On the Shopify Task List, a gift card the invoice total fits in takes the whole invoice before the card, though the card's transaction sorts first.
        Initialize();

        // [GIVEN] Invoice 59.95 without payment lines
        InvoiceNo := 'SPFYPA-TL2';
        InsertInvoice(InvoiceNo, 59.95);

        // [WHEN] The payment lines are built from a card authorization of 209.92 and a gift card sale of 300
        UpdatePaymentLines(true, InvoiceRecordId(InvoiceNo), CardAndGiftCardJson(209.92, 300));

        // [THEN] The gift card pays the 59.95 and the card gets no line
        _Assert.AreEqual(59.95, InvoiceLinesAmount(InvoiceNo, Enum::"NPR Magento Payment Type"::Voucher), 'Shopify already took the gift card money, so the gift card must pay the invoice first.');
        _Assert.AreEqual(0, InvoiceLineCount(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'Nothing is left for the card once the gift card pays the invoice.');
    end;

    [Test]
    procedure GiftCardLinePaysPart_NcQueue_CardGetsTheRest()
    var
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] On the NC task queue, the card line gets only what the gift card line already on the invoice leaves of its total.
        Initialize();

        // [GIVEN] Invoice 400 carrying the gift card's voucher line of 300
        InvoiceNo := 'SPFYPA-NC3';
        InsertInvoice(InvoiceNo, 400);
        AddInvoicePaymentLine(InvoiceNo, Enum::"NPR Magento Payment Type"::Voucher, 300, _GiftCardTxnId);

        // [WHEN] The payment lines are rebuilt from a card authorization of 209.92 and a gift card sale of 300
        UpdatePaymentLines(false, InvoiceRecordId(InvoiceNo), CardAndGiftCardJson(209.92, 300));

        // [THEN] The card line is 100 and keeps the authorized 209.92 as its requested amount
        _Assert.AreEqual(100, InvoiceLinesAmount(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'The card must cover only what the gift card leaves.');
        _Assert.AreEqual(209.92, CardRequestedAmount(InvoiceNo), 'The requested amount stays the authorized amount.');
    end;

    [Test]
    procedure GiftCardLinePaysPart_TaskList_CardGetsTheRest()
    var
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] On the Shopify Task List, the card line gets only what the gift card line already on the invoice leaves of its total.
        Initialize();

        // [GIVEN] Invoice 400 carrying the gift card's voucher line of 300
        InvoiceNo := 'SPFYPA-TL3';
        InsertInvoice(InvoiceNo, 400);
        AddInvoicePaymentLine(InvoiceNo, Enum::"NPR Magento Payment Type"::Voucher, 300, _GiftCardTxnId);

        // [WHEN] The payment lines are rebuilt from a card authorization of 209.92 and a gift card sale of 300
        UpdatePaymentLines(true, InvoiceRecordId(InvoiceNo), CardAndGiftCardJson(209.92, 300));

        // [THEN] The card line is 100 and keeps the authorized 209.92 as its requested amount
        _Assert.AreEqual(100, InvoiceLinesAmount(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'The card must cover only what the gift card leaves.');
        _Assert.AreEqual(209.92, CardRequestedAmount(InvoiceNo), 'The requested amount stays the authorized amount.');
    end;

    [Test]
    procedure InvoiceCoversBoth_NcQueue_BothPaymentsInFull()
    var
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] On the NC task queue, an invoice as large as both payments gets the gift card and the card in full.
        Initialize();

        // [GIVEN] Invoice 509.92 without payment lines
        InvoiceNo := 'SPFYPA-NC4';
        InsertInvoice(InvoiceNo, 509.92);

        // [WHEN] The payment lines are built from a card authorization of 209.92 and a gift card sale of 300
        UpdatePaymentLines(false, InvoiceRecordId(InvoiceNo), CardAndGiftCardJson(209.92, 300));

        // [THEN] The gift card line is 300 and the card line 209.92
        _Assert.AreEqual(300, InvoiceLinesAmount(InvoiceNo, Enum::"NPR Magento Payment Type"::Voucher), 'The gift card line must carry the whole gift card payment.');
        _Assert.AreEqual(209.92, InvoiceLinesAmount(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'The card line must carry the whole authorization.');
    end;

    [Test]
    procedure InvoiceCoversBoth_TaskList_BothPaymentsInFull()
    var
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] On the Shopify Task List, an invoice as large as both payments gets the gift card and the card in full.
        Initialize();

        // [GIVEN] Invoice 509.92 without payment lines
        InvoiceNo := 'SPFYPA-TL4';
        InsertInvoice(InvoiceNo, 509.92);

        // [WHEN] The payment lines are built from a card authorization of 209.92 and a gift card sale of 300
        UpdatePaymentLines(true, InvoiceRecordId(InvoiceNo), CardAndGiftCardJson(209.92, 300));

        // [THEN] The gift card line is 300 and the card line 209.92
        _Assert.AreEqual(300, InvoiceLinesAmount(InvoiceNo, Enum::"NPR Magento Payment Type"::Voucher), 'The gift card line must carry the whole gift card payment.');
        _Assert.AreEqual(209.92, InvoiceLinesAmount(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'The card line must carry the whole authorization.');
    end;

    [Test]
    procedure PartlyRefundedGiftCard_NcQueue_LineTakesNetAmount()
    var
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] On the NC task queue, a gift card partly refunded in Shopify pays only what is left of it after the refund.
        Initialize();

        // [GIVEN] Invoice 509.92 without payment lines
        InvoiceNo := 'SPFYPA-NC5';
        InsertInvoice(InvoiceNo, 509.92);

        // [WHEN] The payment lines are built from a card authorization of 209.92, a gift card sale of 300 and a refund of 100 to the gift card
        UpdatePaymentLines(false, InvoiceRecordId(InvoiceNo), RefundedGiftCardJson(209.92, 300, 100));

        // [THEN] The gift card line is the 200 left after the refund and the card line keeps its whole authorization
        _Assert.AreEqual(200, InvoiceLinesAmount(InvoiceNo, Enum::"NPR Magento Payment Type"::Voucher), 'The gift card line must not include money Shopify gave back to the card.');
        _Assert.AreEqual(209.92, InvoiceLinesAmount(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'The card line must carry the whole authorization.');
    end;

    [Test]
    procedure PartlyRefundedGiftCard_TaskList_LineTakesNetAmount()
    var
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] On the Shopify Task List, a gift card partly refunded in Shopify pays only what is left of it after the refund.
        Initialize();

        // [GIVEN] Invoice 509.92 without payment lines
        InvoiceNo := 'SPFYPA-TL5';
        InsertInvoice(InvoiceNo, 509.92);

        // [WHEN] The payment lines are built from a card authorization of 209.92, a gift card sale of 300 and a refund of 100 to the gift card
        UpdatePaymentLines(true, InvoiceRecordId(InvoiceNo), RefundedGiftCardJson(209.92, 300, 100));

        // [THEN] The gift card line is the 200 left after the refund and the card line keeps its whole authorization
        _Assert.AreEqual(200, InvoiceLinesAmount(InvoiceNo, Enum::"NPR Magento Payment Type"::Voucher), 'The gift card line must not include money Shopify gave back to the card.');
        _Assert.AreEqual(209.92, InvoiceLinesAmount(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'The card line must carry the whole authorization.');
    end;

    [Test]
    procedure SecondInvoice_NcQueue_GiftCardGivesOnlyWhatTheFirstLeft()
    var
        FirstInvoiceNo: Code[20];
        SecondInvoiceNo: Code[20];
    begin
        // [SCENARIO] On the NC task queue, the second invoice of an order gets only what the first invoice left of the gift card.
        Initialize();

        // [GIVEN] A first invoice of the order on which the gift card already paid 59.95
        FirstInvoiceNo := 'SPFYPA-NC10A';
        InsertInvoice(FirstInvoiceNo, 59.95);
        AddInvoicePaymentLine(FirstInvoiceNo, Enum::"NPR Magento Payment Type"::Voucher, 59.95, _GiftCardTxnId);

        // [GIVEN] A second invoice of 449.97 without payment lines
        SecondInvoiceNo := 'SPFYPA-NC10B';
        InsertInvoice(SecondInvoiceNo, 449.97);

        // [WHEN] The second invoice's payment lines are built from the gift card sale of 300
        UpdatePaymentLines(false, InvoiceRecordId(SecondInvoiceNo), GiftCardOnlyJson(300));

        // [THEN] The gift card gives only the 240.05 it has left, not its whole 300 again
        _Assert.AreEqual(240.05, InvoiceLinesAmount(SecondInvoiceNo, Enum::"NPR Magento Payment Type"::Voucher), 'The gift card must not be counted again on a second invoice.');
    end;

    [Test]
    procedure SecondInvoice_TaskList_GiftCardGivesOnlyWhatTheFirstLeft()
    var
        FirstInvoiceNo: Code[20];
        SecondInvoiceNo: Code[20];
    begin
        // [SCENARIO] On the Shopify Task List, the second invoice of an order gets only what the first invoice left of the gift card.
        Initialize();

        // [GIVEN] A first invoice of the order on which the gift card already paid 59.95
        FirstInvoiceNo := 'SPFYPA-TL10A';
        InsertInvoice(FirstInvoiceNo, 59.95);
        AddInvoicePaymentLine(FirstInvoiceNo, Enum::"NPR Magento Payment Type"::Voucher, 59.95, _GiftCardTxnId);

        // [GIVEN] A second invoice of 449.97 without payment lines
        SecondInvoiceNo := 'SPFYPA-TL10B';
        InsertInvoice(SecondInvoiceNo, 449.97);

        // [WHEN] The second invoice's payment lines are built from the gift card sale of 300
        UpdatePaymentLines(true, InvoiceRecordId(SecondInvoiceNo), GiftCardOnlyJson(300));

        // [THEN] The gift card gives only the 240.05 it has left, not its whole 300 again
        _Assert.AreEqual(240.05, InvoiceLinesAmount(SecondInvoiceNo, Enum::"NPR Magento Payment Type"::Voucher), 'The gift card must not be counted again on a second invoice.');
    end;

    [Test]
    procedure GiftCardRefundWithoutCreditDocument_NcQueue_StaysOffTheSecondInvoice()
    var
        FirstInvoiceNo: Code[20];
        SecondInvoiceNo: Code[20];
    begin
        // [SCENARIO] On the NC task queue, a gift card refund no credit document has booked yet stays subtracted from what the gift card pays on a later invoice, and the card pays the rest.
        Initialize();

        // [GIVEN] A first invoice of the order on which the gift card paid 60
        FirstInvoiceNo := 'SPFYPA-NC24A';
        InsertInvoice(FirstInvoiceNo, 60);
        AddInvoicePaymentLine(FirstInvoiceNo, Enum::"NPR Magento Payment Type"::Voucher, 60, _GiftCardTxnId);

        // [GIVEN] A second invoice of 120 without payment lines
        SecondInvoiceNo := 'SPFYPA-NC24B';
        InsertInvoice(SecondInvoiceNo, 120);

        // [WHEN] The second invoice's payment lines are built from a card authorization of 100 and a gift card sale of 100 of which 20 was refunded
        UpdatePaymentLines(false, InvoiceRecordId(SecondInvoiceNo), RefundedGiftCardJson(100, 100, 20));

        // [THEN] The gift card pays the 20 it has left and the card pays 100
        _Assert.AreEqual(20, InvoiceLinesAmount(SecondInvoiceNo, Enum::"NPR Magento Payment Type"::Voucher), 'A refund no credit document booked must stay off the gift card.');
        _Assert.AreEqual(100, InvoiceLinesAmount(SecondInvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'The card must pay what the gift card cannot.');
    end;

    [Test]
    procedure GiftCardRefundOnCreditMemo_NcQueue_IsNotSubtractedTwice()
    var
        FirstInvoiceNo: Code[20];
        SecondInvoiceNo: Code[20];
    begin
        // [SCENARIO] On the NC task queue, a gift card refund a credit memo already booked for goods of the first invoice does not also shrink what the gift card pays on a later invoice.
        Initialize();

        // [GIVEN] A first invoice of the order on which the gift card paid 60
        FirstInvoiceNo := 'SPFYPA-NC25A';
        InsertInvoice(FirstInvoiceNo, 60);
        AddInvoicePaymentLine(FirstInvoiceNo, Enum::"NPR Magento Payment Type"::Voucher, 60, _GiftCardTxnId);

        // [GIVEN] A posted credit memo whose payment line books the gift card refund of 20
        AddCreditMemoPaymentLine('SPFYPA-NC25C', 20, _GiftCardRefundTxnId);

        // [GIVEN] A second invoice of 120 without payment lines
        SecondInvoiceNo := 'SPFYPA-NC25B';
        InsertInvoice(SecondInvoiceNo, 120);

        // [WHEN] The second invoice's payment lines are built from a card authorization of 100 and a gift card sale of 100 of which 20 was refunded
        UpdatePaymentLines(false, InvoiceRecordId(SecondInvoiceNo), RefundedGiftCardJson(100, 100, 20));

        // [THEN] The gift card pays the 40 it still has for this invoice and the card pays 80
        _Assert.AreEqual(40, InvoiceLinesAmount(SecondInvoiceNo, Enum::"NPR Magento Payment Type"::Voucher), 'A refund the credit memo paid back must not be subtracted again.');
        _Assert.AreEqual(80, InvoiceLinesAmount(SecondInvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'The card must pay only what the gift card leaves.');
    end;

    [Test]
    procedure GiftCardRefundWithoutCreditDocument_TaskList_StaysOffTheSecondInvoice()
    var
        FirstInvoiceNo: Code[20];
        SecondInvoiceNo: Code[20];
    begin
        // [SCENARIO] On the Shopify Task List, a gift card refund no credit document has booked yet stays subtracted from what the gift card pays on a later invoice, and the card pays the rest.
        Initialize();

        // [GIVEN] A first invoice of the order on which the gift card paid 60
        FirstInvoiceNo := 'SPFYPA-TL24A';
        InsertInvoice(FirstInvoiceNo, 60);
        AddInvoicePaymentLine(FirstInvoiceNo, Enum::"NPR Magento Payment Type"::Voucher, 60, _GiftCardTxnId);

        // [GIVEN] A second invoice of 120 without payment lines
        SecondInvoiceNo := 'SPFYPA-TL24B';
        InsertInvoice(SecondInvoiceNo, 120);

        // [WHEN] The second invoice's payment lines are built from a card authorization of 100 and a gift card sale of 100 of which 20 was refunded
        UpdatePaymentLines(true, InvoiceRecordId(SecondInvoiceNo), RefundedGiftCardJson(100, 100, 20));

        // [THEN] The gift card pays the 20 it has left and the card pays 100
        _Assert.AreEqual(20, InvoiceLinesAmount(SecondInvoiceNo, Enum::"NPR Magento Payment Type"::Voucher), 'A refund no credit document booked must stay off the gift card.');
        _Assert.AreEqual(100, InvoiceLinesAmount(SecondInvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'The card must pay what the gift card cannot.');
    end;

    [Test]
    procedure GiftCardRefundOnCreditMemo_TaskList_IsNotSubtractedTwice()
    var
        FirstInvoiceNo: Code[20];
        SecondInvoiceNo: Code[20];
    begin
        // [SCENARIO] On the Shopify Task List, a gift card refund a credit memo already booked for goods of the first invoice does not also shrink what the gift card pays on a later invoice.
        Initialize();

        // [GIVEN] A first invoice of the order on which the gift card paid 60
        FirstInvoiceNo := 'SPFYPA-TL25A';
        InsertInvoice(FirstInvoiceNo, 60);
        AddInvoicePaymentLine(FirstInvoiceNo, Enum::"NPR Magento Payment Type"::Voucher, 60, _GiftCardTxnId);

        // [GIVEN] A posted credit memo whose payment line books the gift card refund of 20
        AddCreditMemoPaymentLine('SPFYPA-TL25C', 20, _GiftCardRefundTxnId);

        // [GIVEN] A second invoice of 120 without payment lines
        SecondInvoiceNo := 'SPFYPA-TL25B';
        InsertInvoice(SecondInvoiceNo, 120);

        // [WHEN] The second invoice's payment lines are built from a card authorization of 100 and a gift card sale of 100 of which 20 was refunded
        UpdatePaymentLines(true, InvoiceRecordId(SecondInvoiceNo), RefundedGiftCardJson(100, 100, 20));

        // [THEN] The gift card pays the 40 it still has for this invoice and the card pays 80
        _Assert.AreEqual(40, InvoiceLinesAmount(SecondInvoiceNo, Enum::"NPR Magento Payment Type"::Voucher), 'A refund the credit memo paid back must not be subtracted again.');
        _Assert.AreEqual(80, InvoiceLinesAmount(SecondInvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'The card must pay only what the gift card leaves.');
    end;

    [Test]
    procedure GiftCardRefundOfInvoicedGoodsBeforeItsCreditMemo_NcQueue_LeavesTheRefundOpen()
    var
        FirstInvoiceNo: Code[20];
        SecondInvoiceNo: Code[20];
    begin
        // [SCENARIO] On the NC task queue, a gift card refund for goods of the first invoice whose credit memo the refund import has not created yet stays subtracted, so a later invoice keeps the refund open until that credit memo settles it.
        Initialize();

        // [GIVEN] A first invoice of the order on which the gift card paid 60
        FirstInvoiceNo := 'SPFYPA-NC26A';
        InsertInvoice(FirstInvoiceNo, 60);
        AddInvoicePaymentLine(FirstInvoiceNo, Enum::"NPR Magento Payment Type"::Voucher, 60, _GiftCardTxnId);

        // [GIVEN] A second invoice of 140 for the rest of the order, without payment lines
        SecondInvoiceNo := 'SPFYPA-NC26B';
        InsertInvoice(SecondInvoiceNo, 140);

        // [WHEN] The second invoice's payment lines are built from a card authorization of 100 and a gift card sale of 100 of which 20 was refunded for goods of the first invoice, with no credit memo yet
        UpdatePaymentLines(false, InvoiceRecordId(SecondInvoiceNo), RefundedGiftCardJson(100, 100, 20));

        // [THEN] The gift card pays 20 and the card 100, so the second invoice stays 20 short until the credit memo is applied to it
        _Assert.AreEqual(20, InvoiceLinesAmount(SecondInvoiceNo, Enum::"NPR Magento Payment Type"::Voucher), 'A refund no credit document booked yet must stay off the gift card.');
        _Assert.AreEqual(100, InvoiceLinesAmount(SecondInvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'The card must pay its whole authorization.');
    end;

    [Test]
    procedure GiftCardRefundOfInvoicedGoodsBeforeItsCreditMemo_TaskList_LeavesTheRefundOpen()
    var
        FirstInvoiceNo: Code[20];
        SecondInvoiceNo: Code[20];
    begin
        // [SCENARIO] On the Shopify Task List, a gift card refund for goods of the first invoice whose credit memo the refund import has not created yet stays subtracted, so a later invoice keeps the refund open until that credit memo settles it.
        Initialize();

        // [GIVEN] A first invoice of the order on which the gift card paid 60
        FirstInvoiceNo := 'SPFYPA-TL26A';
        InsertInvoice(FirstInvoiceNo, 60);
        AddInvoicePaymentLine(FirstInvoiceNo, Enum::"NPR Magento Payment Type"::Voucher, 60, _GiftCardTxnId);

        // [GIVEN] A second invoice of 140 for the rest of the order, without payment lines
        SecondInvoiceNo := 'SPFYPA-TL26B';
        InsertInvoice(SecondInvoiceNo, 140);

        // [WHEN] The second invoice's payment lines are built from a card authorization of 100 and a gift card sale of 100 of which 20 was refunded for goods of the first invoice, with no credit memo yet
        UpdatePaymentLines(true, InvoiceRecordId(SecondInvoiceNo), RefundedGiftCardJson(100, 100, 20));

        // [THEN] The gift card pays 20 and the card 100, so the second invoice stays 20 short until the credit memo is applied to it
        _Assert.AreEqual(20, InvoiceLinesAmount(SecondInvoiceNo, Enum::"NPR Magento Payment Type"::Voucher), 'A refund no credit document booked yet must stay off the gift card.');
        _Assert.AreEqual(100, InvoiceLinesAmount(SecondInvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'The card must pay its whole authorization.');
    end;

    [Test]
    procedure RefundedSaleLine_NcQueue_RemovedBeforeGiftCardIsSized()
    var
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] On the NC task queue, the line of a fully refunded sale is removed before the gift card is sized, so the gift card gets the room that line held.
        Initialize();

        // [GIVEN] Invoice 100 carrying a card line of 100 for a card sale whose transaction sorts after the gift card's
        InvoiceNo := 'SPFYPA-NC6';
        InsertInvoice(InvoiceNo, 100);
        AddInvoicePaymentLine(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method", 100, _CardSaleTxnId);

        // [WHEN] The payment lines are rebuilt from a gift card sale of 100 and the card sale of 100 refunded in full
        UpdatePaymentLines(false, InvoiceRecordId(InvoiceNo), GiftCardAndRefundedCardSaleJson(100, 100));

        // [THEN] The refunded card line is gone and the gift card pays the invoice
        _Assert.AreEqual(0, InvoiceLineCount(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'A fully refunded sale must not keep its line.');
        _Assert.AreEqual(100, InvoiceLinesAmount(InvoiceNo, Enum::"NPR Magento Payment Type"::Voucher), 'The gift card must be sized after the refunded line is gone.');
    end;

    [Test]
    procedure RefundedSaleLine_TaskList_RemovedBeforeGiftCardIsSized()
    var
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] On the Shopify Task List, the line of a fully refunded sale is removed before the gift card is sized, so the gift card gets the room that line held.
        Initialize();

        // [GIVEN] Invoice 100 carrying a card line of 100 for a card sale whose transaction sorts after the gift card's
        InvoiceNo := 'SPFYPA-TL6';
        InsertInvoice(InvoiceNo, 100);
        AddInvoicePaymentLine(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method", 100, _CardSaleTxnId);

        // [WHEN] The payment lines are rebuilt from a gift card sale of 100 and the card sale of 100 refunded in full
        UpdatePaymentLines(true, InvoiceRecordId(InvoiceNo), GiftCardAndRefundedCardSaleJson(100, 100));

        // [THEN] The refunded card line is gone and the gift card pays the invoice
        _Assert.AreEqual(0, InvoiceLineCount(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'A fully refunded sale must not keep its line.');
        _Assert.AreEqual(100, InvoiceLinesAmount(InvoiceNo, Enum::"NPR Magento Payment Type"::Voucher), 'The gift card must be sized after the refunded line is gone.');
    end;

    [Test]
    procedure PostedLineOfRefundedGiftCard_NcQueue_IsKept()
    var
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] On the NC task queue, a posted payment line stays on the invoice when its transaction was refunded afterwards, because its money is already booked.
        Initialize();

        // [GIVEN] Invoice 100 carrying a posted voucher line of 100 for the gift card
        InvoiceNo := 'SPFYPA-NC7';
        InsertInvoice(InvoiceNo, 100);
        MarkPosted(AddInvoicePaymentLine(InvoiceNo, Enum::"NPR Magento Payment Type"::Voucher, 100, _GiftCardTxnId));

        // [WHEN] The payment lines are rebuilt from a gift card sale of 300 refunded in full
        UpdatePaymentLines(false, InvoiceRecordId(InvoiceNo), FullyRefundedGiftCardJson(300));

        // [THEN] The posted voucher line is still on the invoice
        _Assert.AreEqual(100, InvoiceLinesAmount(InvoiceNo, Enum::"NPR Magento Payment Type"::Voucher), 'A posted payment line must never be deleted from the invoice.');
    end;

    [Test]
    procedure PostedLineOfRefundedGiftCard_TaskList_IsKept()
    var
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] On the Shopify Task List, a posted payment line stays on the invoice when its transaction was refunded afterwards, because its money is already booked.
        Initialize();

        // [GIVEN] Invoice 100 carrying a posted voucher line of 100 for the gift card
        InvoiceNo := 'SPFYPA-TL7';
        InsertInvoice(InvoiceNo, 100);
        MarkPosted(AddInvoicePaymentLine(InvoiceNo, Enum::"NPR Magento Payment Type"::Voucher, 100, _GiftCardTxnId));

        // [WHEN] The payment lines are rebuilt from a gift card sale of 300 refunded in full
        UpdatePaymentLines(true, InvoiceRecordId(InvoiceNo), FullyRefundedGiftCardJson(300));

        // [THEN] The posted voucher line is still on the invoice
        _Assert.AreEqual(100, InvoiceLinesAmount(InvoiceNo, Enum::"NPR Magento Payment Type"::Voucher), 'A posted payment line must never be deleted from the invoice.');
    end;

    [Test]
    procedure CardLineTheGiftCardCovers_NcQueue_TrimmedToZero()
    var
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] On the NC task queue, an uncaptured card line the gift card line already covers is cut to zero, so the invoice's payment lines add up to its total again.
        Initialize();

        // [GIVEN] Invoice 59.95 carrying a voucher line of 59.95 and an uncaptured card line of 59.95, as on the production invoice
        InvoiceNo := 'SPFYPA-NC8';
        InsertInvoice(InvoiceNo, 59.95);
        AddInvoicePaymentLine(InvoiceNo, Enum::"NPR Magento Payment Type"::Voucher, 59.95, _GiftCardTxnId);
        AddInvoicePaymentLine(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method", 59.95, _AuthorizationTxnId);

        // [WHEN] The payment lines are rebuilt from a card authorization of 209.92 and a gift card sale of 300
        UpdatePaymentLines(false, InvoiceRecordId(InvoiceNo), CardAndGiftCardJson(209.92, 300));

        // [THEN] The card line is cut to zero and the voucher line is left as it was
        _Assert.AreEqual(0, InvoiceLinesAmount(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'An uncaptured card line must be cut to what the invoice leaves for it.');
        _Assert.AreEqual(59.95, InvoiceLinesAmount(InvoiceNo, Enum::"NPR Magento Payment Type"::Voucher), 'Money Shopify already took is never cut.');
    end;

    [Test]
    procedure CardLineTheGiftCardCovers_TaskList_TrimmedToZero()
    var
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] On the Shopify Task List, an uncaptured card line the gift card line already covers is cut to zero, so the invoice's payment lines add up to its total again.
        Initialize();

        // [GIVEN] Invoice 59.95 carrying a voucher line of 59.95 and an uncaptured card line of 59.95, as on the production invoice
        InvoiceNo := 'SPFYPA-TL8';
        InsertInvoice(InvoiceNo, 59.95);
        AddInvoicePaymentLine(InvoiceNo, Enum::"NPR Magento Payment Type"::Voucher, 59.95, _GiftCardTxnId);
        AddInvoicePaymentLine(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method", 59.95, _AuthorizationTxnId);

        // [WHEN] The payment lines are rebuilt from a card authorization of 209.92 and a gift card sale of 300
        UpdatePaymentLines(true, InvoiceRecordId(InvoiceNo), CardAndGiftCardJson(209.92, 300));

        // [THEN] The card line is cut to zero and the voucher line is left as it was
        _Assert.AreEqual(0, InvoiceLinesAmount(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'An uncaptured card line must be cut to what the invoice leaves for it.');
        _Assert.AreEqual(59.95, InvoiceLinesAmount(InvoiceNo, Enum::"NPR Magento Payment Type"::Voucher), 'Money Shopify already took is never cut.');
    end;

    [Test]
    procedure CapturedCardLine_NcQueue_IsNotTrimmed()
    var
        CardPaymentLine: Record "NPR Magento Payment Line";
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] A card line already captured keeps its amount even when the invoice's payment lines add up to more than its total, since the money has been taken.
        Initialize();

        // [GIVEN] Invoice 59.95 carrying a voucher line of 59.95 and a captured card line of 59.95
        InvoiceNo := 'SPFYPA-NC9';
        InsertInvoice(InvoiceNo, 59.95);
        AddInvoicePaymentLine(InvoiceNo, Enum::"NPR Magento Payment Type"::Voucher, 59.95, _GiftCardTxnId);
        CardPaymentLine := AddInvoicePaymentLine(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method", 59.95, _AuthorizationTxnId);
        CardPaymentLine."Date Captured" := WorkDate();
        CardPaymentLine.Modify();

        // [WHEN] The payment lines are rebuilt from a card authorization of 209.92 and a gift card sale of 300
        UpdatePaymentLines(false, InvoiceRecordId(InvoiceNo), CardAndGiftCardJson(209.92, 300));

        // [THEN] The captured card line keeps its 59.95
        _Assert.AreEqual(59.95, InvoiceLinesAmount(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'A captured line must not be cut, its money has already been taken.');
    end;

    [Test]
    procedure StaleCardLineOnReducedOrder_NcQueue_TrimmedToZero()
    var
        OrderNo: Code[20];
    begin
        // [SCENARIO] On the NC task queue, a sales order whose total dropped below its gift card has its uncaptured card line cut to zero when its payment lines are refreshed for posting.
        Initialize();

        // [GIVEN] Sales order 59.95 still carrying the order import's voucher line of 300 and card line of 209.92
        OrderNo := 'SPFYPA-SO1';
        InsertOrder(OrderNo, 59.95);
        AddOrderPaymentLine(OrderNo, Enum::"NPR Magento Payment Type"::Voucher, 300, _GiftCardTxnId);
        AddOrderPaymentLine(OrderNo, Enum::"NPR Magento Payment Type"::"Payment Method", 209.92, _AuthorizationTxnId);

        // [WHEN] The payment lines are refreshed from a card authorization of 209.92 and a gift card sale of 300
        UpdatePaymentLines(false, OrderRecordId(OrderNo), CardAndGiftCardJson(209.92, 300));

        // [THEN] The card line is cut to zero, in the store currency too, and the voucher line is left for the voucher module to apply on release
        _Assert.AreEqual(0, OrderLinesAmount(OrderNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'The card must not pay any part of an order the gift card covers.');
        _Assert.AreEqual(0, OrderLinesStoreCurrencyAmount(OrderNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'The store-currency amount must follow the amount.');
        _Assert.AreEqual(300, OrderLinesAmount(OrderNo, Enum::"NPR Magento Payment Type"::Voucher), 'The voucher line is applied by the voucher module, not cut here.');
    end;

    [Test]
    procedure StaleCardLineOnReducedOrder_TaskList_TrimmedToZero()
    var
        OrderNo: Code[20];
    begin
        // [SCENARIO] On the Shopify Task List, a sales order whose total dropped below its gift card has its uncaptured card line cut to zero when its payment lines are refreshed.
        Initialize();

        // [GIVEN] Sales order 59.95 still carrying the order import's voucher line of 300 and card line of 209.92
        OrderNo := 'SPFYPA-SO2';
        InsertOrder(OrderNo, 59.95);
        AddOrderPaymentLine(OrderNo, Enum::"NPR Magento Payment Type"::Voucher, 300, _GiftCardTxnId);
        AddOrderPaymentLine(OrderNo, Enum::"NPR Magento Payment Type"::"Payment Method", 209.92, _AuthorizationTxnId);

        // [WHEN] The payment lines are refreshed from a card authorization of 209.92 and a gift card sale of 300
        UpdatePaymentLines(true, OrderRecordId(OrderNo), CardAndGiftCardJson(209.92, 300));

        // [THEN] The card line is cut to zero, in the store currency too, and the voucher line is left for the voucher module to apply on release
        _Assert.AreEqual(0, OrderLinesAmount(OrderNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'The card must not pay any part of an order the gift card covers.');
        _Assert.AreEqual(0, OrderLinesStoreCurrencyAmount(OrderNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'The store-currency amount must follow the amount.');
        _Assert.AreEqual(300, OrderLinesAmount(OrderNo, Enum::"NPR Magento Payment Type"::Voucher), 'The voucher line is applied by the voucher module, not cut here.');
    end;

    [Test]
    procedure TrimmedCardLineOnGrownOrder_NcQueue_GrowsBackToWhatIsMissing()
    var
        CardPaymentLine: Record "NPR Magento Payment Line";
        OrderNo: Code[20];
    begin
        // [SCENARIO] On the NC task queue, a card line cut down earlier grows back, up to what was authorized, when the sales order's total grows again.
        Initialize();

        // [GIVEN] Sales order 130 carrying a voucher line of 40 and a card line cut to 0 from an authorization of 100, 75 in the store currency
        OrderNo := 'SPFYPA-SO3';
        InsertOrder(OrderNo, 130);
        AddOrderPaymentLine(OrderNo, Enum::"NPR Magento Payment Type"::Voucher, 40, _GiftCardTxnId);
        CardPaymentLine := AddOrderPaymentLine(OrderNo, Enum::"NPR Magento Payment Type"::"Payment Method", 100, _AuthorizationTxnId);
        CardPaymentLine."Requested Amt. (Store Curr.)" := 75;
        CardPaymentLine.Modify();
        CutToZero(CardPaymentLine);

        // [WHEN] The payment lines are refreshed from a card authorization of 100 and a gift card sale of 40
        UpdatePaymentLines(false, OrderRecordId(OrderNo), CardAndGiftCardJson(100, 40));

        // [THEN] The card line pays the 90 the voucher leaves, 67.50 in the store currency at the authorization's own rate
        _Assert.AreEqual(90, OrderLinesAmount(OrderNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'A card line cut earlier must grow back to what the order is missing.');
        _Assert.AreEqual(67.5, OrderLinesStoreCurrencyAmount(OrderNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'The store-currency amount must follow the amount at the authorization rate.');
    end;

    [Test]
    procedure TrimmedCardLineOnGrownOrder_TaskList_GrowsBackToWhatIsMissing()
    var
        CardPaymentLine: Record "NPR Magento Payment Line";
        OrderNo: Code[20];
    begin
        // [SCENARIO] On the Shopify Task List, a card line cut down earlier grows back, up to what was authorized, when the sales order's total grows again.
        Initialize();

        // [GIVEN] Sales order 130 carrying a voucher line of 40 and a card line cut to 0 from an authorization of 100, 75 in the store currency
        OrderNo := 'SPFYPA-SO4';
        InsertOrder(OrderNo, 130);
        AddOrderPaymentLine(OrderNo, Enum::"NPR Magento Payment Type"::Voucher, 40, _GiftCardTxnId);
        CardPaymentLine := AddOrderPaymentLine(OrderNo, Enum::"NPR Magento Payment Type"::"Payment Method", 100, _AuthorizationTxnId);
        CardPaymentLine."Requested Amt. (Store Curr.)" := 75;
        CardPaymentLine.Modify();
        CutToZero(CardPaymentLine);

        // [WHEN] The payment lines are refreshed from a card authorization of 100 and a gift card sale of 40
        UpdatePaymentLines(true, OrderRecordId(OrderNo), CardAndGiftCardJson(100, 40));

        // [THEN] The card line pays the 90 the voucher leaves, 67.50 in the store currency at the authorization's own rate
        _Assert.AreEqual(90, OrderLinesAmount(OrderNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'A card line cut earlier must grow back to what the order is missing.');
        _Assert.AreEqual(67.5, OrderLinesStoreCurrencyAmount(OrderNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'The store-currency amount must follow the amount at the authorization rate.');
    end;

    [Test]
    procedure PartlyInvoicedOrder_NcQueue_CardDoesNotGrowByTheInvoicedPart()
    var
        OrderNo: Code[20];
    begin
        // [SCENARIO] On the NC task queue, a sales order already invoiced in part only has to cover what is not invoiced yet, so its card line does not grow by the invoiced part.
        Initialize();

        // [GIVEN] Sales order 300, of which 150 is already on a posted invoice, carrying the gift card's remaining voucher line of 150 and a card line cut to 0 from an authorization of 209.92
        OrderNo := 'SPFYPA-SO5';
        InsertOrder(OrderNo, 300);
        InsertInvoiceForOrder('SPFYPA-SO5I', OrderNo, 150);
        AddOrderPaymentLine(OrderNo, Enum::"NPR Magento Payment Type"::Voucher, 150, _GiftCardTxnId);
        CutToZero(AddOrderPaymentLine(OrderNo, Enum::"NPR Magento Payment Type"::"Payment Method", 209.92, _AuthorizationTxnId));

        // [WHEN] The payment lines are refreshed from a card authorization of 209.92 and a gift card sale of 300
        UpdatePaymentLines(false, OrderRecordId(OrderNo), CardAndGiftCardJson(209.92, 300));

        // [THEN] The card line stays at 0, since the voucher line covers what is not invoiced
        _Assert.AreEqual(0, OrderLinesAmount(OrderNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'The invoiced part of the order must not be paid again by the card.');
    end;

    [Test]
    procedure PartlyInvoicedOrder_TaskList_CardDoesNotGrowByTheInvoicedPart()
    var
        OrderNo: Code[20];
    begin
        // [SCENARIO] On the Shopify Task List, a sales order already invoiced in part only has to cover what is not invoiced yet, so its card line does not grow by the invoiced part.
        Initialize();

        // [GIVEN] Sales order 300, of which 150 is already on a posted invoice, carrying the gift card's remaining voucher line of 150 and a card line cut to 0 from an authorization of 209.92
        OrderNo := 'SPFYPA-SO6';
        InsertOrder(OrderNo, 300);
        InsertInvoiceForOrder('SPFYPA-SO6I', OrderNo, 150);
        AddOrderPaymentLine(OrderNo, Enum::"NPR Magento Payment Type"::Voucher, 150, _GiftCardTxnId);
        CutToZero(AddOrderPaymentLine(OrderNo, Enum::"NPR Magento Payment Type"::"Payment Method", 209.92, _AuthorizationTxnId));

        // [WHEN] The payment lines are refreshed from a card authorization of 209.92 and a gift card sale of 300
        UpdatePaymentLines(true, OrderRecordId(OrderNo), CardAndGiftCardJson(209.92, 300));

        // [THEN] The card line stays at 0, since the voucher line covers what is not invoiced
        _Assert.AreEqual(0, OrderLinesAmount(OrderNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'The invoiced part of the order must not be paid again by the card.');
    end;

    [Test]
    procedure SettledCardSaleLine_NcQueue_IsNotCut()
    var
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] On the NC task queue, a card line of a sale Shopify already settled keeps its amount, since the money has been taken.
        Initialize();

        // [GIVEN] Invoice 59.95 carrying a voucher line of 59.95 and a card line of 59.95 for a card sale
        InvoiceNo := 'SPFYPA-NC11';
        InsertInvoice(InvoiceNo, 59.95);
        AddInvoicePaymentLine(InvoiceNo, Enum::"NPR Magento Payment Type"::Voucher, 59.95, _GiftCardTxnId);
        AddInvoicePaymentLine(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method", 59.95, _CardSaleTxnId);

        // [WHEN] The payment lines are rebuilt from a gift card sale of 300 and the card sale of 59.95
        UpdatePaymentLines(false, InvoiceRecordId(InvoiceNo), GiftCardAndCardSaleJson(300, 59.95));

        // [THEN] The card sale line keeps its 59.95
        _Assert.AreEqual(59.95, InvoiceLinesAmount(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'A line of money Shopify has already taken must not be cut.');
    end;

    [Test]
    procedure SettledCardSaleLine_TaskList_IsNotCut()
    var
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] On the Shopify Task List, a card line of a sale Shopify already settled keeps its amount, since the money has been taken.
        Initialize();

        // [GIVEN] Invoice 59.95 carrying a voucher line of 59.95 and a card line of 59.95 for a card sale
        InvoiceNo := 'SPFYPA-TL11';
        InsertInvoice(InvoiceNo, 59.95);
        AddInvoicePaymentLine(InvoiceNo, Enum::"NPR Magento Payment Type"::Voucher, 59.95, _GiftCardTxnId);
        AddInvoicePaymentLine(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method", 59.95, _CardSaleTxnId);

        // [WHEN] The payment lines are rebuilt from a gift card sale of 300 and the card sale of 59.95
        UpdatePaymentLines(true, InvoiceRecordId(InvoiceNo), GiftCardAndCardSaleJson(300, 59.95));

        // [THEN] The card sale line keeps its 59.95
        _Assert.AreEqual(59.95, InvoiceLinesAmount(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'A line of money Shopify has already taken must not be cut.');
    end;

    [Test]
    procedure AuthorizationCapturedInShopify_NcQueue_LineIsNotCut()
    var
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] On the NC task queue, a card line whose authorization Shopify reports as fully captured keeps its amount, even before BC has marked the line captured.
        Initialize();

        // [GIVEN] Invoice 59.95 carrying a voucher line of 59.95 and a card line of 59.95 that BC has not marked captured
        InvoiceNo := 'SPFYPA-NC12';
        InsertInvoice(InvoiceNo, 59.95);
        AddInvoicePaymentLine(InvoiceNo, Enum::"NPR Magento Payment Type"::Voucher, 59.95, _GiftCardTxnId);
        AddInvoicePaymentLine(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method", 59.95, _AuthorizationTxnId);

        // [WHEN] The payment lines are rebuilt from a card authorization of 209.92 with nothing left unsettled and a gift card sale of 300
        UpdatePaymentLines(false, InvoiceRecordId(InvoiceNo), CapturedCardAndGiftCardJson(209.92, 300));

        // [THEN] The card line keeps its 59.95
        _Assert.AreEqual(59.95, InvoiceLinesAmount(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'A line of an authorization Shopify has already captured must not be cut.');
    end;

    [Test]
    procedure AuthorizationCapturedInShopify_TaskList_LineIsNotCut()
    var
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] On the Shopify Task List, a card line whose authorization Shopify reports as fully captured keeps its amount, even before BC has marked the line captured.
        Initialize();

        // [GIVEN] Invoice 59.95 carrying a voucher line of 59.95 and a card line of 59.95 that BC has not marked captured
        InvoiceNo := 'SPFYPA-TL12';
        InsertInvoice(InvoiceNo, 59.95);
        AddInvoicePaymentLine(InvoiceNo, Enum::"NPR Magento Payment Type"::Voucher, 59.95, _GiftCardTxnId);
        AddInvoicePaymentLine(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method", 59.95, _AuthorizationTxnId);

        // [WHEN] The payment lines are rebuilt from a card authorization of 209.92 with nothing left unsettled and a gift card sale of 300
        UpdatePaymentLines(true, InvoiceRecordId(InvoiceNo), CapturedCardAndGiftCardJson(209.92, 300));

        // [THEN] The card line keeps its 59.95
        _Assert.AreEqual(59.95, InvoiceLinesAmount(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'A line of an authorization Shopify has already captured must not be cut.');
    end;

    [Test]
    procedure GiftCardMissingNextToOpenCardLine_NcQueue_TakesTheCardsRoom()
    var
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] On the NC task queue, a gift card missing from an invoice whose open card line already takes the whole total gets its share, and the card line is cut to make room.
        Initialize();

        // [GIVEN] Invoice 59.95 carrying only an uncaptured card line of 59.95, as the rebuild left invoices before this fix
        InvoiceNo := 'SPFYPA-NC13';
        InsertInvoice(InvoiceNo, 59.95);
        AddInvoicePaymentLine(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method", 59.95, _AuthorizationTxnId);

        // [WHEN] The payment lines are rebuilt from a card authorization of 209.92 and a gift card sale of 300
        UpdatePaymentLines(false, InvoiceRecordId(InvoiceNo), CardAndGiftCardJson(209.92, 300));

        // [THEN] The gift card pays the 59.95 and the card line is cut to zero
        _Assert.AreEqual(59.95, InvoiceLinesAmount(InvoiceNo, Enum::"NPR Magento Payment Type"::Voucher), 'Money Shopify already took from the gift card must get its line.');
        _Assert.AreEqual(0, InvoiceLinesAmount(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'The card must give up the room the gift card takes.');
    end;

    [Test]
    procedure GiftCardMissingNextToOpenCardLine_TaskList_TakesTheCardsRoom()
    var
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] On the Shopify Task List, a gift card missing from an invoice whose open card line already takes the whole total gets its share, and the card line is cut to make room.
        Initialize();

        // [GIVEN] Invoice 59.95 carrying only an uncaptured card line of 59.95, as the rebuild left invoices before this fix
        InvoiceNo := 'SPFYPA-TL13';
        InsertInvoice(InvoiceNo, 59.95);
        AddInvoicePaymentLine(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method", 59.95, _AuthorizationTxnId);

        // [WHEN] The payment lines are rebuilt from a card authorization of 209.92 and a gift card sale of 300
        UpdatePaymentLines(true, InvoiceRecordId(InvoiceNo), CardAndGiftCardJson(209.92, 300));

        // [THEN] The gift card pays the 59.95 and the card line is cut to zero
        _Assert.AreEqual(59.95, InvoiceLinesAmount(InvoiceNo, Enum::"NPR Magento Payment Type"::Voucher), 'Money Shopify already took from the gift card must get its line.');
        _Assert.AreEqual(0, InvoiceLinesAmount(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'The card must give up the room the gift card takes.');
    end;

    [Test]
    procedure PartlyCapturedAuthorization_NcQueue_GrowsOnlyToWhatIsUnsettled()
    var
        OrderNo: Code[20];
    begin
        // [SCENARIO] On the NC task queue, a card line grows back only up to what Shopify still holds unsettled on its authorization, not up to the authorized amount.
        Initialize();

        // [GIVEN] Sales order 100 carrying a card line cut to 60 from an authorization of 100
        OrderNo := 'SPFYPA-SO7';
        InsertOrder(OrderNo, 100);
        SetAmount(AddOrderPaymentLine(OrderNo, Enum::"NPR Magento Payment Type"::"Payment Method", 100, _AuthorizationTxnId), 60);

        // [WHEN] The payment lines are refreshed from the authorization of 100, of which Shopify reports 70 unsettled
        UpdatePaymentLines(false, OrderRecordId(OrderNo), PartlyCapturedCardJson(100, 70));

        // [THEN] The card line grows to 70
        _Assert.AreEqual(70, OrderLinesAmount(OrderNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'A card line must not grow beyond what the authorization still holds.');
    end;

    [Test]
    procedure PartlyCapturedAuthorization_TaskList_GrowsOnlyToWhatIsUnsettled()
    var
        OrderNo: Code[20];
    begin
        // [SCENARIO] On the Shopify Task List, a card line grows back only up to what Shopify still holds unsettled on its authorization, not up to the authorized amount.
        Initialize();

        // [GIVEN] Sales order 100 carrying a card line cut to 60 from an authorization of 100
        OrderNo := 'SPFYPA-SO8';
        InsertOrder(OrderNo, 100);
        SetAmount(AddOrderPaymentLine(OrderNo, Enum::"NPR Magento Payment Type"::"Payment Method", 100, _AuthorizationTxnId), 60);

        // [WHEN] The payment lines are refreshed from the authorization of 100, of which Shopify reports 70 unsettled
        UpdatePaymentLines(true, OrderRecordId(OrderNo), PartlyCapturedCardJson(100, 70));

        // [THEN] The card line grows to 70
        _Assert.AreEqual(70, OrderLinesAmount(OrderNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'A card line must not grow beyond what the authorization still holds.');
    end;

    [Test]
    procedure CapturedAuthorizationSortingLater_NcQueue_IsBookedBeforeTheOpenOne()
    var
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] On the NC task queue, an authorization Shopify already captured is booked before one it still holds open, though the open one's transaction sorts first.
        Initialize();

        // [GIVEN] Invoice 100 without payment lines
        InvoiceNo := 'SPFYPA-NC14';
        InsertInvoice(InvoiceNo, 100);

        // [WHEN] The payment lines are built from an open authorization of 100 and a later authorization of 60 that Shopify reports as captured
        UpdatePaymentLines(false, InvoiceRecordId(InvoiceNo), OpenAndCapturedAuthorizationsJson(100, 60));

        // [THEN] The captured authorization keeps its 60 and the open one gets the 40 left
        _Assert.AreEqual(60, InvoiceLineAmountForTransaction(InvoiceNo, _CapturedAuthorizationTxnId), 'Money Shopify has already captured must be booked first.');
        _Assert.AreEqual(40, InvoiceLineAmountForTransaction(InvoiceNo, _AuthorizationTxnId), 'The open authorization gets only what the captured one leaves.');
    end;

    [Test]
    procedure NewLineOfPartlyCapturedAuthorization_NcQueue_TakesOnlyWhatIsUnsettled()
    var
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] On the NC task queue, a new card line for an authorization partly captured in Shopify is no larger than what Shopify still holds unsettled.
        Initialize();

        // [GIVEN] Invoice 100 without payment lines
        InvoiceNo := 'SPFYPA-NC15';
        InsertInvoice(InvoiceNo, 100);

        // [WHEN] The payment lines are built from an authorization of 100 of which Shopify reports 40 unsettled
        UpdatePaymentLines(false, InvoiceRecordId(InvoiceNo), PartlyCapturedCardJson(100, 40));

        // [THEN] The card line is 40
        _Assert.AreEqual(40, InvoiceLinesAmount(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'A card line must never be larger than what its authorization still holds.');
    end;

    [Test]
    procedure CapturedAuthorizationSortingLater_TaskList_IsBookedBeforeTheOpenOne()
    var
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] On the Shopify Task List, an authorization Shopify already captured is booked before one it still holds open, though the open one's transaction sorts first.
        Initialize();

        // [GIVEN] Invoice 100 without payment lines
        InvoiceNo := 'SPFYPA-TL14';
        InsertInvoice(InvoiceNo, 100);

        // [WHEN] The payment lines are built from an open authorization of 100 and a later authorization of 60 that Shopify reports as captured
        UpdatePaymentLines(true, InvoiceRecordId(InvoiceNo), OpenAndCapturedAuthorizationsJson(100, 60));

        // [THEN] The captured authorization keeps its 60 and the open one gets the 40 left
        _Assert.AreEqual(60, InvoiceLineAmountForTransaction(InvoiceNo, _CapturedAuthorizationTxnId), 'Money Shopify has already captured must be booked first.');
        _Assert.AreEqual(40, InvoiceLineAmountForTransaction(InvoiceNo, _AuthorizationTxnId), 'The open authorization gets only what the captured one leaves.');
    end;

    [Test]
    procedure NewLineOfPartlyCapturedAuthorization_TaskList_TakesOnlyWhatIsUnsettled()
    var
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] On the Shopify Task List, a new card line for an authorization partly captured in Shopify is no larger than what Shopify still holds unsettled.
        Initialize();

        // [GIVEN] Invoice 100 without payment lines
        InvoiceNo := 'SPFYPA-TL15';
        InsertInvoice(InvoiceNo, 100);

        // [WHEN] The payment lines are built from an authorization of 100 of which Shopify reports 40 unsettled
        UpdatePaymentLines(true, InvoiceRecordId(InvoiceNo), PartlyCapturedCardJson(100, 40));

        // [THEN] The card line is 40
        _Assert.AreEqual(40, InvoiceLinesAmount(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'A card line must never be larger than what its authorization still holds.');
    end;

    [Test]
    procedure VoidedAuthorization_NcQueue_IsNotBookedAsTaken()
    var
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] On the NC task queue, an authorization with nothing unsettled and nothing captured from it (voided or expired) is not booked as money taken, so the open authorization pays.
        Initialize();

        // [GIVEN] Invoice 100 without payment lines
        InvoiceNo := 'SPFYPA-NC16';
        InsertInvoice(InvoiceNo, 100);

        // [WHEN] The payment lines are built from an open authorization of 100 and a voided authorization of 100
        UpdatePaymentLines(false, InvoiceRecordId(InvoiceNo), OpenAndVoidedAuthorizationsJson(100, 100));

        // [THEN] The open authorization pays the 100 and the voided one gets no line
        _Assert.AreEqual(100, InvoiceLineAmountForTransaction(InvoiceNo, _AuthorizationTxnId), 'The open authorization must pay the invoice.');
        _Assert.AreEqual(0, InvoiceLineAmountForTransaction(InvoiceNo, TransactionId(6)), 'A voided authorization holds no money.');
    end;

    [Test]
    procedure CardLineAboveWhatShopifyHolds_NcQueue_IsCut()
    var
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] On the NC task queue, an uncaptured card line larger than what Shopify still holds unsettled on its authorization is cut to that, so its capture can go through.
        Initialize();

        // [GIVEN] Invoice 100 carrying an uncaptured card line of 100
        InvoiceNo := 'SPFYPA-NC17';
        InsertInvoice(InvoiceNo, 100);
        AddInvoicePaymentLine(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method", 100, _AuthorizationTxnId);

        // [WHEN] The payment lines are rebuilt from the authorization of 100, of which Shopify reports 40 unsettled
        UpdatePaymentLines(false, InvoiceRecordId(InvoiceNo), PartlyCapturedCardJson(100, 40));

        // [THEN] The card line is cut to 40
        _Assert.AreEqual(40, InvoiceLinesAmount(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'A card line must never hold more than its authorization still holds.');
    end;

    [Test]
    procedure VoidedAuthorization_TaskList_IsNotBookedAsTaken()
    var
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] On the Shopify Task List, an authorization with nothing unsettled and nothing captured from it (voided or expired) is not booked as money taken, so the open authorization pays.
        Initialize();

        // [GIVEN] Invoice 100 without payment lines
        InvoiceNo := 'SPFYPA-TL16';
        InsertInvoice(InvoiceNo, 100);

        // [WHEN] The payment lines are built from an open authorization of 100 and a voided authorization of 100
        UpdatePaymentLines(true, InvoiceRecordId(InvoiceNo), OpenAndVoidedAuthorizationsJson(100, 100));

        // [THEN] The open authorization pays the 100 and the voided one gets no line
        _Assert.AreEqual(100, InvoiceLineAmountForTransaction(InvoiceNo, _AuthorizationTxnId), 'The open authorization must pay the invoice.');
        _Assert.AreEqual(0, InvoiceLineAmountForTransaction(InvoiceNo, TransactionId(6)), 'A voided authorization holds no money.');
    end;

    [Test]
    procedure CardLineAboveWhatShopifyHolds_TaskList_IsCut()
    var
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] On the Shopify Task List, an uncaptured card line larger than what Shopify still holds unsettled on its authorization is cut to that, so its capture can go through.
        Initialize();

        // [GIVEN] Invoice 100 carrying an uncaptured card line of 100
        InvoiceNo := 'SPFYPA-TL17';
        InsertInvoice(InvoiceNo, 100);
        AddInvoicePaymentLine(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method", 100, _AuthorizationTxnId);

        // [WHEN] The payment lines are rebuilt from the authorization of 100, of which Shopify reports 40 unsettled
        UpdatePaymentLines(true, InvoiceRecordId(InvoiceNo), PartlyCapturedCardJson(100, 40));

        // [THEN] The card line is cut to 40
        _Assert.AreEqual(40, InvoiceLinesAmount(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'A card line must never hold more than its authorization still holds.');
    end;

    [Test]
    procedure CapturedCardLine_TaskList_IsNotTrimmed()
    var
        CardPaymentLine: Record "NPR Magento Payment Line";
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] On the Shopify Task List, a card line already captured keeps its amount even when the invoice's payment lines add up to more than its total, since the money has been taken.
        Initialize();

        // [GIVEN] Invoice 59.95 carrying a voucher line of 59.95 and a captured card line of 59.95
        InvoiceNo := 'SPFYPA-TL9';
        InsertInvoice(InvoiceNo, 59.95);
        AddInvoicePaymentLine(InvoiceNo, Enum::"NPR Magento Payment Type"::Voucher, 59.95, _GiftCardTxnId);
        CardPaymentLine := AddInvoicePaymentLine(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method", 59.95, _AuthorizationTxnId);
        CardPaymentLine."Date Captured" := WorkDate();
        CardPaymentLine.Modify();

        // [WHEN] The payment lines are rebuilt from a card authorization of 209.92 and a gift card sale of 300
        UpdatePaymentLines(true, InvoiceRecordId(InvoiceNo), CardAndGiftCardJson(209.92, 300));

        // [THEN] The captured card line keeps its 59.95
        _Assert.AreEqual(59.95, InvoiceLinesAmount(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'A captured line must not be cut, its money has already been taken.');
    end;

    [Test]
    procedure TwoOpenCardLinesAboveInvoice_LastLineIsCutFirst()
    var
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] When two uncaptured card lines add up to more than the invoice, the last line is cut first and the first keeps its amount.
        Initialize();

        // [GIVEN] Invoice 100 carrying an uncaptured card line of 60 and, after it, another of 60
        InvoiceNo := 'SPFYPA-NC18';
        InsertInvoice(InvoiceNo, 100);
        AddInvoicePaymentLine(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method", 60, _AuthorizationTxnId);
        AddInvoicePaymentLine(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method", 60, TransactionId(7));

        // [WHEN] The payment lines are rebuilt from the two authorizations of 60, both open
        UpdatePaymentLines(false, InvoiceRecordId(InvoiceNo), TwoOpenAuthorizationsJson(60, 60));

        // [THEN] The second line is cut to 40 and the first keeps 60
        _Assert.AreEqual(60, InvoiceLineAmountForTransaction(InvoiceNo, _AuthorizationTxnId), 'The first card line keeps its amount.');
        _Assert.AreEqual(40, InvoiceLineAmountForTransaction(InvoiceNo, TransactionId(7)), 'The last card line is cut first.');
    end;

    [Test]
    procedure PostedAndRequestedCardLines_AreNotCut()
    var
        PostedPaymentLine: Record "NPR Magento Payment Line";
        RequestedPaymentLine: Record "NPR Magento Payment Line";
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] A posted card line and a card line whose capture was already requested keep their amounts; only an open line BC still controls is cut.
        Initialize();

        // [GIVEN] Invoice 100 carrying a posted card line of 60, a card line of 60 whose capture was requested, and an open card line of 60
        InvoiceNo := 'SPFYPA-NC19';
        InsertInvoice(InvoiceNo, 100);
        PostedPaymentLine := AddInvoicePaymentLine(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method", 60, _AuthorizationTxnId);
        MarkPosted(PostedPaymentLine);
        RequestedPaymentLine := AddInvoicePaymentLine(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method", 60, TransactionId(7));
        RequestedPaymentLine."Capture Requested" := true;
        RequestedPaymentLine.Modify();
        AddInvoicePaymentLine(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method", 60, TransactionId(8));

        // [WHEN] The payment lines are rebuilt from the three authorizations of 60, all open
        UpdatePaymentLines(false, InvoiceRecordId(InvoiceNo), ThreeOpenAuthorizationsJson(60));

        // [THEN] The open line is cut to 0 and the posted and requested lines keep 60
        _Assert.AreEqual(0, InvoiceLineAmountForTransaction(InvoiceNo, TransactionId(8)), 'The open card line gives way.');
        _Assert.AreEqual(60, InvoiceLineAmountForTransaction(InvoiceNo, _AuthorizationTxnId), 'A posted card line must not be cut.');
        _Assert.AreEqual(60, InvoiceLineAmountForTransaction(InvoiceNo, TransactionId(7)), 'A card line whose capture was requested must not be cut.');
    end;

    [Test]
    procedure OpenAuthorizationOnSecondInvoice_TakesOnlyWhatTheFirstLeft()
    var
        FirstInvoiceNo: Code[20];
        SecondInvoiceNo: Code[20];
    begin
        // [SCENARIO] A second invoice's new card line takes only what the first invoice left of the authorization.
        Initialize();

        // [GIVEN] A first invoice of the order carrying a card line of 60 for the authorization
        FirstInvoiceNo := 'SPFYPA-NC20A';
        InsertInvoice(FirstInvoiceNo, 60);
        AddInvoicePaymentLine(FirstInvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method", 60, _AuthorizationTxnId);

        // [GIVEN] A second invoice of 100 without payment lines
        SecondInvoiceNo := 'SPFYPA-NC20B';
        InsertInvoice(SecondInvoiceNo, 100);

        // [WHEN] The second invoice's payment lines are built from the authorization of 100, still all unsettled
        UpdatePaymentLines(false, InvoiceRecordId(SecondInvoiceNo), PartlyCapturedCardJson(100, 100));

        // [THEN] The card line on the second invoice is 40
        _Assert.AreEqual(40, InvoiceLinesAmount(SecondInvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'The authorization must not be counted again on a second invoice.');
    end;

    [Test]
    procedure FinalCaptureOnFirstInvoice_NcQueue_SecondInvoiceGetsNoCardLine()
    var
        FirstInvoiceNo: Code[20];
        SecondInvoiceNo: Code[20];
    begin
        // [SCENARIO] On the NC task queue, once the first invoice's capture was final and Shopify released the rest of the authorization, a second invoice gets no card line for money that was never taken.
        Initialize();

        // [GIVEN] A first invoice of the order carrying a card line of 40 for the authorization
        FirstInvoiceNo := 'SPFYPA-NC21A';
        InsertInvoice(FirstInvoiceNo, 40);
        AddInvoicePaymentLine(FirstInvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method", 40, _AuthorizationTxnId);

        // [GIVEN] A second invoice of 60 without payment lines
        SecondInvoiceNo := 'SPFYPA-NC21B';
        InsertInvoice(SecondInvoiceNo, 60);

        // [WHEN] The second invoice's payment lines are built from the authorization of 100, captured for 40 with nothing left unsettled
        UpdatePaymentLines(false, InvoiceRecordId(SecondInvoiceNo), FinallyCapturedAuthorizationJson(100, 40));

        // [THEN] The second invoice gets no card line
        _Assert.AreEqual(0, InvoiceLinesAmount(SecondInvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'Money Shopify released must not be booked as paid.');
    end;

    [Test]
    procedure FinalCaptureOnFirstInvoice_TaskList_SecondInvoiceGetsNoCardLine()
    var
        FirstInvoiceNo: Code[20];
        SecondInvoiceNo: Code[20];
    begin
        // [SCENARIO] On the Shopify Task List, once the first invoice's capture was final and Shopify released the rest of the authorization, a second invoice gets no card line for money that was never taken.
        Initialize();

        // [GIVEN] A first invoice of the order carrying a card line of 40 for the authorization
        FirstInvoiceNo := 'SPFYPA-TL21A';
        InsertInvoice(FirstInvoiceNo, 40);
        AddInvoicePaymentLine(FirstInvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method", 40, _AuthorizationTxnId);

        // [GIVEN] A second invoice of 60 without payment lines
        SecondInvoiceNo := 'SPFYPA-TL21B';
        InsertInvoice(SecondInvoiceNo, 60);

        // [WHEN] The second invoice's payment lines are built from the authorization of 100, captured for 40 with nothing left unsettled
        UpdatePaymentLines(true, InvoiceRecordId(SecondInvoiceNo), FinallyCapturedAuthorizationJson(100, 40));

        // [THEN] The second invoice gets no card line
        _Assert.AreEqual(0, InvoiceLinesAmount(SecondInvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'Money Shopify released must not be booked as paid.');
    end;

    [Test]
    procedure VoidedAuthorizationLine_IsCutAndTheOpenOnePays()
    var
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] An uncaptured card line of an authorization that was voided is cut to zero before the open authorization is sized, so the open one pays the invoice.
        Initialize();

        // [GIVEN] Invoice 100 carrying an uncaptured card line of 100 for an authorization that was later voided
        InvoiceNo := 'SPFYPA-NC22';
        InsertInvoice(InvoiceNo, 100);
        AddInvoicePaymentLine(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method", 100, TransactionId(6));

        // [WHEN] The payment lines are rebuilt from an open authorization of 100 and the voided authorization of 100
        UpdatePaymentLines(false, InvoiceRecordId(InvoiceNo), OpenAndVoidedAuthorizationsJson(100, 100));

        // [THEN] The voided authorization's line is cut to zero and the open one pays the 100
        _Assert.AreEqual(0, InvoiceLineAmountForTransaction(InvoiceNo, TransactionId(6)), 'A voided authorization holds no money.');
        _Assert.AreEqual(100, InvoiceLineAmountForTransaction(InvoiceNo, _AuthorizationTxnId), 'The open authorization must pay the invoice.');
    end;

    [Test]
    procedure CardLineBeyondInvoice_CaptureIsRefused()
    var
        CardPaymentLine: Record "NPR Magento Payment Line";
        SpfyPaymentGatewayHdlr: Codeunit "NPR Spfy Payment Gateway Hdlr";
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] A card line the gift card line already covers is refused at capture, so the card is never charged beyond the invoice.
        Initialize();

        // [GIVEN] Invoice 59.95 carrying a voucher line of 59.95 and a card line of 59.95, as on the production invoice
        InvoiceNo := 'SPFYPA-G1';
        InsertInvoice(InvoiceNo, 59.95);
        AddInvoicePaymentLine(InvoiceNo, Enum::"NPR Magento Payment Type"::Voucher, 59.95, _GiftCardTxnId);
        CardPaymentLine := AddInvoicePaymentLine(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method", 59.95, _AuthorizationTxnId);

        // [WHEN] The capture checks the card line against the invoice
        asserterror SpfyPaymentGatewayHdlr.CheckCaptureWithinDocumentTotal(CardPaymentLine);

        // [THEN] The capture is refused
        _Assert.ExpectedError('The payment has not been captured.');
    end;

    [Test]
    procedure OrderCardLineBeyondWhatIsNotInvoiced_CaptureIsRefused()
    var
        CardPaymentLine: Record "NPR Magento Payment Line";
        SpfyPaymentGatewayHdlr: Codeunit "NPR Spfy Payment Gateway Hdlr";
        OrderNo: Code[20];
    begin
        // [SCENARIO] On a sales order already invoiced in part, a card line is checked against what is not invoiced yet, so it is refused when the voucher line already covers that.
        Initialize();

        // [GIVEN] Sales order 300, of which 150 is on a posted invoice, carrying a voucher line of 150 and a card line of 100
        OrderNo := 'SPFYPA-SO9';
        InsertOrder(OrderNo, 300);
        InsertInvoiceForOrder('SPFYPA-SO9I', OrderNo, 150);
        AddOrderPaymentLine(OrderNo, Enum::"NPR Magento Payment Type"::Voucher, 150, _GiftCardTxnId);
        CardPaymentLine := AddOrderPaymentLine(OrderNo, Enum::"NPR Magento Payment Type"::"Payment Method", 100, _AuthorizationTxnId);

        // [WHEN] The capture checks the card line against the order
        asserterror SpfyPaymentGatewayHdlr.CheckCaptureWithinDocumentTotal(CardPaymentLine);

        // [THEN] The capture is refused
        _Assert.ExpectedError('The payment has not been captured.');
    end;

    [Test]
    procedure CardLineWithinInvoice_CaptureIsAllowed()
    var
        CardPaymentLine: Record "NPR Magento Payment Line";
        SpfyPaymentGatewayHdlr: Codeunit "NPR Spfy Payment Gateway Hdlr";
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] A card line that pays exactly what the gift card line leaves of the invoice passes the capture check.
        Initialize();

        // [GIVEN] Invoice 400 carrying a voucher line of 300 and a card line of 100
        InvoiceNo := 'SPFYPA-G2';
        InsertInvoice(InvoiceNo, 400);
        AddInvoicePaymentLine(InvoiceNo, Enum::"NPR Magento Payment Type"::Voucher, 300, _GiftCardTxnId);
        CardPaymentLine := AddInvoicePaymentLine(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method", 100, _AuthorizationTxnId);

        // [WHEN] The capture checks the card line against the invoice
        SpfyPaymentGatewayHdlr.CheckCaptureWithinDocumentTotal(CardPaymentLine);

        // [THEN] No error is raised, so the capture goes ahead
    end;

    [Test]
    procedure PointsLineOnInvoice_CaptureIsAllowed()
    var
        CardPaymentLine: Record "NPR Magento Payment Line";
        PointsPaymentLine: Record "NPR Magento Payment Line";
        SpfyPaymentGatewayHdlr: Codeunit "NPR Spfy Payment Gateway Hdlr";
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] A points payment line does not count against the invoice total at capture, as in the order posting's own payment check.
        Initialize();

        // [GIVEN] Invoice 100 carrying a points payment line of 50 and a card line of 100
        InvoiceNo := 'SPFYPA-G3';
        InsertInvoice(InvoiceNo, 100);
        PointsPaymentLine := AddInvoicePaymentLine(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method", 50, _PointsTxnId);
        PointsPaymentLine."Points Payment" := true;
        PointsPaymentLine.Modify();
        CardPaymentLine := AddInvoicePaymentLine(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method", 100, _AuthorizationTxnId);

        // [WHEN] The capture checks the card line against the invoice
        SpfyPaymentGatewayHdlr.CheckCaptureWithinDocumentTotal(CardPaymentLine);

        // [THEN] No error is raised, so the capture goes ahead
    end;

    local procedure Initialize()
    var
        Currency: Record Currency;
        PaymentMapping: Record "NPR Magento Payment Mapping";
        PaymentMethod: Record "Payment Method";
        Voucher: Record "NPR NpRv Voucher";
        VoucherType: Record "NPR NpRv Voucher Type";
        LibraryERM: Codeunit "Library - ERM";
        LibrarySpfyVoucher: Codeunit "NPR Library - Spfy Voucher";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt.";
        LcyCode: Code[10];
        VoucherTypeTok: Label 'SPFYPMTGC', Locked = true;
        VoucherNoTok: Label 'SPFYPMTGC01', Locked = true;
        PaymentMethodTok: Label 'SPFYPMT', Locked = true;
        MappingKeyTok: Label '%1_%2', Locked = true;
    begin
        // Every test gets its own Shopify transaction ids, since the lines earlier tests put on their invoices stay in the database
        // and a transaction's lines on other invoices count against it. The authorization sorts before the gift card, as in production.
        _TestSeed += 1;
        _AuthorizationTxnId := TransactionId(1);
        _GiftCardTxnId := TransactionId(2);
        _GiftCardRefundTxnId := TransactionId(3);
        _CardSaleTxnId := TransactionId(9);
        _CardRefundTxnId := TransactionId(10);
        _CapturedAuthorizationTxnId := TransactionId(5);
        _PointsTxnId := TransactionId(50);

        LibrarySpfyVoucher.CreateShopifyStore(_StoreCodeLbl);
        LibrarySpfyVoucher.CreateVoucherType(VoucherTypeTok, _StoreCodeLbl, VoucherType);
        if not Voucher.Get(VoucherNoTok) then
            LibrarySpfyVoucher.CreateVoucher(VoucherNoTok, VoucherType.Code, 'SPFYPMTGCREF01', 300, Voucher);
        SpfyAssignedIDMgt.AssignShopifyID(Voucher.RecordId(), "NPR Spfy ID Type"::"Entry ID", _GiftCardIdLbl, false);

        // A gift card line cut down to the invoice is rounded in the store currency, which is the local currency here.
        LcyCode := _LibrarySpfyLegacyReturn.Lcy();
        if not Currency.Get(LcyCode) then begin
            Currency.Init();
            Currency.Code := LcyCode;
            Currency."Amount Rounding Precision" := 0.01;
            Currency.Insert();
        end;

        if not PaymentMethod.Get(PaymentMethodTok) then begin
            PaymentMethod.Init();
            PaymentMethod.Code := PaymentMethodTok;
            PaymentMethod.Description := 'Web shop card';
            PaymentMethod."Bal. Account Type" := PaymentMethod."Bal. Account Type"::"G/L Account";
            PaymentMethod."Bal. Account No." := LibraryERM.CreateGLAccountNoWithDirectPosting();
            PaymentMethod.Insert();
        end;
        if not PaymentMapping.Get('Shopify', LowerCase(StrSubstNo(MappingKeyTok, _StoreCodeLbl, _GatewayLbl))) then begin
            PaymentMapping.Init();
            PaymentMapping."External Payment Method Code" := 'Shopify';
            PaymentMapping."External Payment Type" := CopyStr(LowerCase(StrSubstNo(MappingKeyTok, _StoreCodeLbl, _GatewayLbl)), 1, MaxStrLen(PaymentMapping."External Payment Type"));
            PaymentMapping."Payment Method Code" := PaymentMethod.Code;
            PaymentMapping.Insert();
        end;
    end;

    local procedure TransactionId(Offset: Integer): Text[30]
    begin
        exit(Format(238100000 + _TestSeed * 100 + Offset, 0, 9));
    end;

    local procedure InsertInvoice(InvoiceNo: Code[20]; AmountInclVAT: Decimal)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
    begin
        SalesInvoiceHeader.Init();
        SalesInvoiceHeader."No." := InvoiceNo;
        SalesInvoiceHeader."Posting Date" := WorkDate();
        SalesInvoiceHeader."NPR External Order No." := InvoiceNo;
        SalesInvoiceHeader.Insert();

        SalesInvoiceLine.Init();
        SalesInvoiceLine."Document No." := InvoiceNo;
        SalesInvoiceLine."Line No." := 10000;
        SalesInvoiceLine.Quantity := 1;
        SalesInvoiceLine.Amount := AmountInclVAT;
        SalesInvoiceLine."Amount Including VAT" := AmountInclVAT;
        SalesInvoiceLine.Insert();
    end;

    local procedure InsertInvoiceForOrder(InvoiceNo: Code[20]; OrderNo: Code[20]; AmountInclVAT: Decimal)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        InsertInvoice(InvoiceNo, AmountInclVAT);
        SalesInvoiceHeader.Get(InvoiceNo);
        SalesInvoiceHeader."Order No." := OrderNo;
        SalesInvoiceHeader.Modify();
    end;

    /// <summary>
    /// Leaves the line as the payment line rebuild leaves a card line it cut: no amount, the authorized amount kept as requested amount.
    /// </summary>
    local procedure CutToZero(PaymentLine: Record "NPR Magento Payment Line")
    begin
        SetAmount(PaymentLine, 0);
    end;

    local procedure SetAmount(PaymentLine: Record "NPR Magento Payment Line"; NewAmount: Decimal)
    begin
        PaymentLine.Amount := NewAmount;
        PaymentLine."Amount (Store Currency)" := NewAmount;
        PaymentLine.Modify();
    end;

    local procedure InsertOrder(OrderNo: Code[20]; AmountInclVAT: Decimal)
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader."No." := OrderNo;
        SalesHeader."Posting Date" := WorkDate();
        SalesHeader."NPR External Order No." := OrderNo;
        SalesHeader.Insert(false);

        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := OrderNo;
        SalesLine."Line No." := 10000;
        SalesLine.Quantity := 1;
        SalesLine.Amount := AmountInclVAT;
        SalesLine."Amount Including VAT" := AmountInclVAT;
        SalesLine.Insert(false);
    end;

    local procedure AddInvoicePaymentLine(InvoiceNo: Code[20]; PaymentType: Enum "NPR Magento Payment Type"; Amount: Decimal; ShopifyTransactionId: Text[30]): Record "NPR Magento Payment Line"
    begin
        exit(AddPaymentLine(Database::"Sales Invoice Header", Enum::"Sales Document Type".FromInteger(0), InvoiceNo, PaymentType, Amount, ShopifyTransactionId));
    end;

    local procedure AddCreditMemoPaymentLine(CreditMemoNo: Code[20]; Amount: Decimal; ShopifyTransactionId: Text[30]): Record "NPR Magento Payment Line"
    begin
        exit(AddPaymentLine(Database::"Sales Cr.Memo Header", Enum::"Sales Document Type".FromInteger(0), CreditMemoNo, Enum::"NPR Magento Payment Type"::"Payment Method", Amount, ShopifyTransactionId));
    end;

    local procedure AddOrderPaymentLine(OrderNo: Code[20]; PaymentType: Enum "NPR Magento Payment Type"; Amount: Decimal; ShopifyTransactionId: Text[30]): Record "NPR Magento Payment Line"
    begin
        exit(AddPaymentLine(Database::"Sales Header", Enum::"Sales Document Type"::Order, OrderNo, PaymentType, Amount, ShopifyTransactionId));
    end;

    local procedure AddPaymentLine(DocumentTableNo: Integer; DocumentType: Enum "Sales Document Type"; DocumentNo: Code[20]; PaymentType: Enum "NPR Magento Payment Type"; Amount: Decimal; ShopifyTransactionId: Text[30]) PaymentLine: Record "NPR Magento Payment Line"
    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt.";
        LineNo: Integer;
    begin
        PaymentLine.SetRange("Document Table No.", DocumentTableNo);
        PaymentLine.SetRange("Document Type", DocumentType);
        PaymentLine.SetRange("Document No.", DocumentNo);
        if PaymentLine.FindLast() then
            LineNo := PaymentLine."Line No.";
        PaymentLine.Init();
        PaymentLine."Document Table No." := DocumentTableNo;
        PaymentLine."Document Type" := DocumentType;
        PaymentLine."Document No." := DocumentNo;
        PaymentLine."Line No." := LineNo + 10000;
        PaymentLine."Payment Type" := PaymentType;
        PaymentLine."No." := ShopifyTransactionId;
        PaymentLine.Amount := Amount;
        PaymentLine."Requested Amount" := Amount;
        PaymentLine."Amount (Store Currency)" := Amount;
        PaymentLine."Requested Amt. (Store Curr.)" := Amount;
        PaymentLine.Insert();
        SpfyAssignedIDMgt.AssignShopifyID(PaymentLine.RecordId(), "NPR Spfy ID Type"::"Entry ID", ShopifyTransactionId, false);
    end;

    local procedure MarkPosted(PaymentLine: Record "NPR Magento Payment Line")
    begin
        PaymentLine.Posted := true;
        PaymentLine.Modify();
    end;

    local procedure InvoiceRecordId(InvoiceNo: Code[20]): RecordId
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        SalesInvoiceHeader.Get(InvoiceNo);
        exit(SalesInvoiceHeader.RecordId());
    end;

    local procedure OrderRecordId(OrderNo: Code[20]): RecordId
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.Get(SalesHeader."Document Type"::Order, OrderNo);
        exit(SalesHeader.RecordId());
    end;

    /// <summary>
    /// Runs the payment line rebuild of a sales order or posted invoice on the NC task queue or on the Shopify Task List.
    /// </summary>
    local procedure UpdatePaymentLines(TaskList: Boolean; DocumentRecordId: RecordId; TransactionsJson: Text)
    var
        NcTask: Record "NPR Nc Task";
        SpfyTask: Record "NPR Spfy Task";
        TempSpfyTransactionBuffer: Record "NPR Spfy Transaction Buffer" temporary;
        SpfyCapturePayment: Codeunit "NPR Spfy Capture Payment";
        SpfyTaskCapturePayment: Codeunit "NPR Spfy Task Capture Payment";
        Transactions: JsonArray;
        Transaction: JsonToken;
    begin
        Transactions.ReadFrom(TransactionsJson);
        if TaskList then begin
            SpfyTask."Record ID" := DocumentRecordId;
            SpfyTask."Store Code" := CopyStr(_StoreCodeLbl, 1, MaxStrLen(SpfyTask."Store Code"));
            foreach Transaction in Transactions do
                SpfyTaskCapturePayment.ProcessTransaction(Transaction, SpfyTask, TempSpfyTransactionBuffer);
            SpfyTaskCapturePayment.UpdatePmtLines(SpfyTask, Transactions, TempSpfyTransactionBuffer);
        end else begin
            NcTask."Record ID" := DocumentRecordId;
            NcTask."Store Code" := CopyStr(_StoreCodeLbl, 1, MaxStrLen(NcTask."Store Code"));
            foreach Transaction in Transactions do
                SpfyCapturePayment.ProcessTransaction(Transaction, NcTask, TempSpfyTransactionBuffer);
            SpfyCapturePayment.UpdatePmtLines(NcTask, Transactions, TempSpfyTransactionBuffer);
        end;
    end;

    /// <summary>
    /// The order's transactions: a card authorization, whose id sorts first, and a gift card sale.
    /// </summary>
    local procedure CardAndGiftCardJson(AuthorizedAmount: Decimal; GiftCardAmount: Decimal): Text
    var
        TransactionsTok: Label '[%1,%2]', Locked = true;
    begin
        exit(StrSubstNo(TransactionsTok, AuthorizationJson(AuthorizedAmount), GiftCardSaleJson(GiftCardAmount)));
    end;

    /// <summary>
    /// An authorization Shopify still holds open, whose id sorts first, and a later one Shopify reports as fully captured.
    /// </summary>
    local procedure OpenAndCapturedAuthorizationsJson(OpenAmount: Decimal; CapturedAmount: Decimal): Text
    var
        TransactionsTok: Label '[%1,%2,%3]', Locked = true;
    begin
        exit(StrSubstNo(TransactionsTok, AuthorizationJson(_AuthorizationTxnId, OpenAmount, OpenAmount), AuthorizationJson(_CapturedAuthorizationTxnId, CapturedAmount, 0), CaptureJson(TransactionId(12), _CapturedAuthorizationTxnId, CapturedAmount)));
    end;

    local procedure PartlyCapturedCardJson(AuthorizedAmount: Decimal; UnsettledAmount: Decimal): Text
    var
        TransactionsTok: Label '[%1]', Locked = true;
    begin
        exit(StrSubstNo(TransactionsTok, AuthorizationJson(AuthorizedAmount, UnsettledAmount)));
    end;

    local procedure CapturedCardAndGiftCardJson(AuthorizedAmount: Decimal; GiftCardAmount: Decimal): Text
    var
        TransactionsTok: Label '[%1,%2,%3]', Locked = true;
    begin
        exit(StrSubstNo(TransactionsTok, AuthorizationJson(AuthorizedAmount, 0), CaptureJson(TransactionId(11), _AuthorizationTxnId, AuthorizedAmount), GiftCardSaleJson(GiftCardAmount)));
    end;

    local procedure FinallyCapturedAuthorizationJson(AuthorizedAmount: Decimal; CapturedAmount: Decimal): Text
    var
        TransactionsTok: Label '[%1,%2]', Locked = true;
    begin
        exit(StrSubstNo(TransactionsTok, AuthorizationJson(AuthorizedAmount, 0), CaptureJson(TransactionId(13), _AuthorizationTxnId, CapturedAmount)));
    end;

    local procedure OpenAndVoidedAuthorizationsJson(OpenAmount: Decimal; VoidedAmount: Decimal): Text
    var
        TransactionsTok: Label '[%1,%2]', Locked = true;
    begin
        exit(StrSubstNo(TransactionsTok, AuthorizationJson(_AuthorizationTxnId, OpenAmount, OpenAmount), AuthorizationJson(TransactionId(6), VoidedAmount, 0)));
    end;

    local procedure TwoOpenAuthorizationsJson(FirstAmount: Decimal; SecondAmount: Decimal): Text
    var
        TransactionsTok: Label '[%1,%2]', Locked = true;
    begin
        exit(StrSubstNo(TransactionsTok, AuthorizationJson(_AuthorizationTxnId, FirstAmount, FirstAmount), AuthorizationJson(TransactionId(7), SecondAmount, SecondAmount)));
    end;

    local procedure ThreeOpenAuthorizationsJson(Amount: Decimal): Text
    var
        TransactionsTok: Label '[%1,%2,%3]', Locked = true;
    begin
        exit(StrSubstNo(TransactionsTok, AuthorizationJson(_AuthorizationTxnId, Amount, Amount), AuthorizationJson(TransactionId(7), Amount, Amount), AuthorizationJson(TransactionId(8), Amount, Amount)));
    end;

    local procedure CaptureJson(CaptureTxnId: Text; ParentTxnId: Text; Amount: Decimal): Text
    var
        CaptureTok: Label '{"id":"gid://shopify/OrderTransaction/%1","kind":"CAPTURE","status":"SUCCESS","gateway":"%5","processedAt":"2026-10-09T08:00:00Z","parentTransaction":{"id":"gid://shopify/OrderTransaction/%2","kind":"AUTHORIZATION"},"amountSet":{"presentmentMoney":{"amount":"%3","currencyCode":"%4"},"shopMoney":{"amount":"%3","currencyCode":"%4"}},"receiptJson":"{}"}', Locked = true;
    begin
        exit(StrSubstNo(CaptureTok, CaptureTxnId, ParentTxnId, Format(Amount, 0, 9), _LibrarySpfyLegacyReturn.Lcy(), _GatewayLbl));
    end;

    local procedure GiftCardAndCardSaleJson(GiftCardAmount: Decimal; CardSaleAmount: Decimal): Text
    var
        TransactionsTok: Label '[%1,%2]', Locked = true;
    begin
        exit(StrSubstNo(TransactionsTok, GiftCardSaleJson(GiftCardAmount), CardSaleJson(CardSaleAmount)));
    end;

    local procedure RefundedGiftCardJson(AuthorizedAmount: Decimal; GiftCardAmount: Decimal; RefundedAmount: Decimal): Text
    var
        TransactionsTok: Label '[%1,%2,%3]', Locked = true;
    begin
        exit(StrSubstNo(TransactionsTok, AuthorizationJson(AuthorizedAmount), GiftCardSaleJson(GiftCardAmount), RefundJson(_GiftCardRefundTxnId, _GiftCardTxnId, 'gift_card', RefundedAmount)));
    end;

    local procedure GiftCardOnlyJson(GiftCardAmount: Decimal): Text
    var
        TransactionsTok: Label '[%1]', Locked = true;
    begin
        exit(StrSubstNo(TransactionsTok, GiftCardSaleJson(GiftCardAmount)));
    end;

    local procedure FullyRefundedGiftCardJson(GiftCardAmount: Decimal): Text
    var
        TransactionsTok: Label '[%1,%2]', Locked = true;
    begin
        exit(StrSubstNo(TransactionsTok, GiftCardSaleJson(GiftCardAmount), RefundJson(_GiftCardRefundTxnId, _GiftCardTxnId, 'gift_card', GiftCardAmount)));
    end;

    local procedure GiftCardAndRefundedCardSaleJson(GiftCardAmount: Decimal; CardSaleAmount: Decimal): Text
    var
        TransactionsTok: Label '[%1,%2,%3]', Locked = true;
    begin
        exit(StrSubstNo(TransactionsTok, GiftCardSaleJson(GiftCardAmount), CardSaleJson(CardSaleAmount), RefundJson(_CardRefundTxnId, _CardSaleTxnId, _GatewayLbl, CardSaleAmount)));
    end;

    local procedure AuthorizationJson(Amount: Decimal): Text
    begin
        exit(AuthorizationJson(Amount, Amount));
    end;

    local procedure AuthorizationJson(Amount: Decimal; UnsettledAmount: Decimal): Text
    begin
        exit(AuthorizationJson(_AuthorizationTxnId, Amount, UnsettledAmount));
    end;

    local procedure AuthorizationJson(TxnId: Text; Amount: Decimal; UnsettledAmount: Decimal): Text
    var
        AuthorizationTok: Label '{"id":"gid://shopify/OrderTransaction/%1","kind":"AUTHORIZATION","status":"SUCCESS","gateway":"%2","paymentId":"pay-%1","processedAt":"2026-10-08T13:39:20Z","amountSet":{"presentmentMoney":{"amount":"%3","currencyCode":"%4"},"shopMoney":{"amount":"%3","currencyCode":"%4"}},"totalUnsettledSet":{"presentmentMoney":{"amount":"%5","currencyCode":"%4"},"shopMoney":{"amount":"%5","currencyCode":"%4"}},"receiptJson":"{}"}', Locked = true;
    begin
        exit(StrSubstNo(AuthorizationTok, TxnId, _GatewayLbl, Format(Amount, 0, 9), _LibrarySpfyLegacyReturn.Lcy(), Format(UnsettledAmount, 0, 9)));
    end;

    local procedure GiftCardSaleJson(Amount: Decimal): Text
    var
        GiftCardSaleTok: Label '{"id":"gid://shopify/OrderTransaction/%1","kind":"SALE","status":"SUCCESS","gateway":"gift_card","processedAt":"2026-10-08T13:39:19Z","amountSet":{"presentmentMoney":{"amount":"%2","currencyCode":"%3"},"shopMoney":{"amount":"%2","currencyCode":"%3"}},"receiptJson":"{\"gift_card_id\":\"gid://shopify/GiftCard/%4\"}"}', Locked = true;
    begin
        exit(StrSubstNo(GiftCardSaleTok, _GiftCardTxnId, Format(Amount, 0, 9), _LibrarySpfyLegacyReturn.Lcy(), _GiftCardIdLbl));
    end;

    local procedure CardSaleJson(Amount: Decimal): Text
    var
        CardSaleTok: Label '{"id":"gid://shopify/OrderTransaction/%1","kind":"SALE","status":"SUCCESS","gateway":"%2","paymentId":"pay-%1","processedAt":"2026-10-08T13:39:21Z","amountSet":{"presentmentMoney":{"amount":"%3","currencyCode":"%4"},"shopMoney":{"amount":"%3","currencyCode":"%4"}},"receiptJson":"{}"}', Locked = true;
    begin
        exit(StrSubstNo(CardSaleTok, _CardSaleTxnId, _GatewayLbl, Format(Amount, 0, 9), _LibrarySpfyLegacyReturn.Lcy()));
    end;

    local procedure RefundJson(RefundTxnId: Text; ParentTxnId: Text; Gateway: Text; Amount: Decimal): Text
    var
        RefundTok: Label '{"id":"gid://shopify/OrderTransaction/%1","kind":"REFUND","status":"SUCCESS","gateway":"%5","processedAt":"2026-10-09T09:00:00Z","parentTransaction":{"id":"gid://shopify/OrderTransaction/%2","kind":"SALE"},"amountSet":{"presentmentMoney":{"amount":"%3","currencyCode":"%4"},"shopMoney":{"amount":"%3","currencyCode":"%4"}},"receiptJson":"{}"}', Locked = true;
    begin
        exit(StrSubstNo(RefundTok, RefundTxnId, ParentTxnId, Format(Amount, 0, 9), _LibrarySpfyLegacyReturn.Lcy(), Gateway));
    end;

    local procedure InvoiceLineCount(InvoiceNo: Code[20]; PaymentType: Enum "NPR Magento Payment Type"): Integer
    var
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        PaymentLine.SetRange("Document Table No.", Database::"Sales Invoice Header");
        PaymentLine.SetRange("Document No.", InvoiceNo);
        PaymentLine.SetRange("Payment Type", PaymentType);
        exit(PaymentLine.Count());
    end;

    local procedure InvoiceLinesAmount(InvoiceNo: Code[20]; PaymentType: Enum "NPR Magento Payment Type"): Decimal
    var
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        PaymentLine.SetRange("Document Table No.", Database::"Sales Invoice Header");
        PaymentLine.SetRange("Document No.", InvoiceNo);
        PaymentLine.SetRange("Payment Type", PaymentType);
        PaymentLine.CalcSums(Amount);
        exit(PaymentLine.Amount);
    end;

    local procedure InvoiceLinesTotal(InvoiceNo: Code[20]): Decimal
    var
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        PaymentLine.SetRange("Document Table No.", Database::"Sales Invoice Header");
        PaymentLine.SetRange("Document No.", InvoiceNo);
        PaymentLine.CalcSums(Amount);
        exit(PaymentLine.Amount);
    end;

    local procedure OrderLinesAmount(OrderNo: Code[20]; PaymentType: Enum "NPR Magento Payment Type"): Decimal
    var
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        PaymentLine.SetRange("Document Table No.", Database::"Sales Header");
        PaymentLine.SetRange("Document Type", PaymentLine."Document Type"::Order);
        PaymentLine.SetRange("Document No.", OrderNo);
        PaymentLine.SetRange("Payment Type", PaymentType);
        PaymentLine.CalcSums(Amount);
        exit(PaymentLine.Amount);
    end;

    local procedure OrderLinesStoreCurrencyAmount(OrderNo: Code[20]; PaymentType: Enum "NPR Magento Payment Type"): Decimal
    var
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        PaymentLine.SetRange("Document Table No.", Database::"Sales Header");
        PaymentLine.SetRange("Document Type", PaymentLine."Document Type"::Order);
        PaymentLine.SetRange("Document No.", OrderNo);
        PaymentLine.SetRange("Payment Type", PaymentType);
        PaymentLine.CalcSums("Amount (Store Currency)");
        exit(PaymentLine."Amount (Store Currency)");
    end;

    local procedure InvoiceLineAmountForTransaction(InvoiceNo: Code[20]; ShopifyTransactionId: Text[30]): Decimal
    var
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        PaymentLine.SetRange("Document Table No.", Database::"Sales Invoice Header");
        PaymentLine.SetRange("Document No.", InvoiceNo);
        PaymentLine.SetRange("No.", ShopifyTransactionId);
        PaymentLine.CalcSums(Amount);
        exit(PaymentLine.Amount);
    end;

    local procedure CardRequestedAmount(InvoiceNo: Code[20]): Decimal
    var
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        PaymentLine.SetRange("Document Table No.", Database::"Sales Invoice Header");
        PaymentLine.SetRange("Document No.", InvoiceNo);
        PaymentLine.SetRange("Payment Type", PaymentLine."Payment Type"::"Payment Method");
        PaymentLine.FindFirst();
        exit(PaymentLine."Requested Amount");
    end;
}
#endif
