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

    [Test]
    procedure AuthorizationCapturedInShopify_NcQueue_AmountEventsQueuedAtImport()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        LibBilling: Codeunit "NPR Library - Spfy Billing";
        OrderNo: Code[20];
        StartEntryNo: BigInteger;
    begin
        // [SCENARIO] On the NC task queue, an order whose authorization Shopify has already captured gets its order amount billing events when its payment lines are imported.
        Initialize();

        // [GIVEN] Sales order 100 with no payment lines yet
        OrderNo := 'SPFYPA-B1';
        InsertOrder(OrderNo, 100);
        StartEntryNo := LibBilling.LastBillingQueueEntryNo();

        // [WHEN] The payment lines are imported from a card authorization of 100 that Shopify has fully captured
        UpdatePaymentLines(false, OrderRecordId(OrderNo), FinallyCapturedAuthorizationJson(100, 100));

        // [THEN] The card line is saved as captured
        OrderCardLine(OrderNo, PaymentLine);
        _Assert.AreNotEqual(0D, PaymentLine."Date Captured", 'A line of an authorization Shopify has already captured must be saved as captured.');
        // [THEN] One presentment and one shop currency amount event are queued under the ids stored on the line
        LibBilling.AssertSingleAmountQueueEntry(PaymentLine."NPR Spfy Ord.Amt.PCY Event Id", "NPR Billing Event Type"::ECOM_SHOPIFY_ORDERS_AMOUNT_PRESENTMENT, 100);
        LibBilling.AssertSingleAmountQueueEntry(PaymentLine."NPR Ecom Spfy.Ord.Amt.Event Id", "NPR Billing Event Type"::ECOM_SHOPIFY_ORDERS_AMOUNT_SHOP, 100);
        _Assert.AreEqual(2, LibBilling.AmountQueueEntriesSince(StartEntryNo), 'A captured payment must be billed exactly once in each currency.');
    end;

    [Test]
    procedure AuthorizationCapturedInShopify_TaskList_AmountEventsQueuedAtImport()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        LibBilling: Codeunit "NPR Library - Spfy Billing";
        OrderNo: Code[20];
        StartEntryNo: BigInteger;
    begin
        // [SCENARIO] On the Shopify Task List, an order whose authorization Shopify has already captured gets its order amount billing events when its payment lines are imported.
        Initialize();

        // [GIVEN] Sales order 100 with no payment lines yet
        OrderNo := 'SPFYPA-B2';
        InsertOrder(OrderNo, 100);
        StartEntryNo := LibBilling.LastBillingQueueEntryNo();

        // [WHEN] The payment lines are imported from a card authorization of 100 that Shopify has fully captured
        UpdatePaymentLines(true, OrderRecordId(OrderNo), FinallyCapturedAuthorizationJson(100, 100));

        // [THEN] The card line is saved as captured
        OrderCardLine(OrderNo, PaymentLine);
        _Assert.AreNotEqual(0D, PaymentLine."Date Captured", 'A line of an authorization Shopify has already captured must be saved as captured.');
        // [THEN] One presentment and one shop currency amount event are queued under the ids stored on the line
        LibBilling.AssertSingleAmountQueueEntry(PaymentLine."NPR Spfy Ord.Amt.PCY Event Id", "NPR Billing Event Type"::ECOM_SHOPIFY_ORDERS_AMOUNT_PRESENTMENT, 100);
        LibBilling.AssertSingleAmountQueueEntry(PaymentLine."NPR Ecom Spfy.Ord.Amt.Event Id", "NPR Billing Event Type"::ECOM_SHOPIFY_ORDERS_AMOUNT_SHOP, 100);
        _Assert.AreEqual(2, LibBilling.AmountQueueEntriesSince(StartEntryNo), 'A captured payment must be billed exactly once in each currency.');
    end;

    [Test]
    procedure CapturedLineRefreshedAgain_NcQueue_NoSecondAmountEvent()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        LibBilling: Codeunit "NPR Library - Spfy Billing";
        OrderNo: Code[20];
        StartEntryNo: BigInteger;
    begin
        // [SCENARIO] On the NC task queue, refreshing the payment lines of an order already billed at capture queues no further order amount billing event.
        Initialize();

        // [GIVEN] Sales order 100 whose card line was imported from an authorization of 100 Shopify had already captured, and billed then
        OrderNo := 'SPFYPA-B3';
        InsertOrder(OrderNo, 100);
        UpdatePaymentLines(false, OrderRecordId(OrderNo), FinallyCapturedAuthorizationJson(100, 100));
        OrderCardLine(OrderNo, PaymentLine);
        _Assert.AreNotEqual(0D, PaymentLine."Date Captured", 'Precondition: the card line must have been imported as captured.');
        StartEntryNo := LibBilling.LastBillingQueueEntryNo();

        // [WHEN] The payment lines are refreshed from the same transactions again
        UpdatePaymentLines(false, OrderRecordId(OrderNo), FinallyCapturedAuthorizationJson(100, 100));

        // [THEN] No further order amount billing event is queued
        _Assert.AreEqual(0, LibBilling.AmountQueueEntriesSince(StartEntryNo), 'A payment already billed at capture must not be billed again by a later refresh.');
    end;

    [Test]
    procedure CapturedLineRefreshedAgain_TaskList_NoSecondAmountEvent()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        LibBilling: Codeunit "NPR Library - Spfy Billing";
        OrderNo: Code[20];
        StartEntryNo: BigInteger;
    begin
        // [SCENARIO] On the Shopify Task List, refreshing the payment lines of an order already billed at capture queues no further order amount billing event.
        Initialize();

        // [GIVEN] Sales order 100 whose card line was imported from an authorization of 100 Shopify had already captured, and billed then
        OrderNo := 'SPFYPA-B4';
        InsertOrder(OrderNo, 100);
        UpdatePaymentLines(true, OrderRecordId(OrderNo), FinallyCapturedAuthorizationJson(100, 100));
        OrderCardLine(OrderNo, PaymentLine);
        _Assert.AreNotEqual(0D, PaymentLine."Date Captured", 'Precondition: the card line must have been imported as captured.');
        StartEntryNo := LibBilling.LastBillingQueueEntryNo();

        // [WHEN] The payment lines are refreshed from the same transactions again
        UpdatePaymentLines(true, OrderRecordId(OrderNo), FinallyCapturedAuthorizationJson(100, 100));

        // [THEN] No further order amount billing event is queued
        _Assert.AreEqual(0, LibBilling.AmountQueueEntriesSince(StartEntryNo), 'A payment already billed at capture must not be billed again by a later refresh.');
    end;

    [Test]
    procedure OpenAuthorization_NcQueue_NoAmountEventAtImport()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        LibBilling: Codeunit "NPR Library - Spfy Billing";
        OrderNo: Code[20];
        StartEntryNo: BigInteger;
    begin
        // [SCENARIO] On the NC task queue, an order whose authorization Shopify still holds open is not billed when its payment lines are imported.
        Initialize();

        // [GIVEN] Sales order 100 with no payment lines yet
        OrderNo := 'SPFYPA-B5';
        InsertOrder(OrderNo, 100);
        StartEntryNo := LibBilling.LastBillingQueueEntryNo();

        // [WHEN] The payment lines are imported from a card authorization of 100 that Shopify has not captured
        UpdatePaymentLines(false, OrderRecordId(OrderNo), StrSubstNo('[%1]', AuthorizationJson(100)));

        // [THEN] The card line is not captured and nothing is billed
        OrderCardLine(OrderNo, PaymentLine);
        _Assert.AreEqual(0D, PaymentLine."Date Captured", 'An open authorization must not be marked captured.');
        _Assert.AreEqual(0, LibBilling.AmountQueueEntriesSince(StartEntryNo), 'A payment that is not captured must not be billed at import.');
    end;

    [Test]
    procedure OpenAuthorization_TaskList_NoAmountEventAtImport()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        LibBilling: Codeunit "NPR Library - Spfy Billing";
        OrderNo: Code[20];
        StartEntryNo: BigInteger;
    begin
        // [SCENARIO] On the Shopify Task List, an order whose authorization Shopify still holds open is not billed when its payment lines are imported.
        Initialize();

        // [GIVEN] Sales order 100 with no payment lines yet
        OrderNo := 'SPFYPA-B6';
        InsertOrder(OrderNo, 100);
        StartEntryNo := LibBilling.LastBillingQueueEntryNo();

        // [WHEN] The payment lines are imported from a card authorization of 100 that Shopify has not captured
        UpdatePaymentLines(true, OrderRecordId(OrderNo), StrSubstNo('[%1]', AuthorizationJson(100)));

        // [THEN] The card line is not captured and nothing is billed
        OrderCardLine(OrderNo, PaymentLine);
        _Assert.AreEqual(0D, PaymentLine."Date Captured", 'An open authorization must not be marked captured.');
        _Assert.AreEqual(0, LibBilling.AmountQueueEntriesSince(StartEntryNo), 'A payment that is not captured must not be billed at import.');
    end;

    [Test]
    procedure VoidedAuthorizationLine_NcQueue_IsNotBilledAtImport()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        LibBilling: Codeunit "NPR Library - Spfy Billing";
        OrderNo: Code[20];
        StartEntryNo: BigInteger;
    begin
        // [SCENARIO] On the NC task queue, a card line whose authorization has nothing unsettled and nothing captured from it (voided or expired) is neither saved as captured nor billed when the payment lines are refreshed, since Shopify took no money.
        Initialize();

        // [GIVEN] Sales order 100 carrying a card line of 100 whose capture was requested, for an authorization that was later voided
        OrderNo := 'SPFYPA-B7';
        InsertOrder(OrderNo, 100);
        PaymentLine := AddOrderPaymentLine(OrderNo, Enum::"NPR Magento Payment Type"::"Payment Method", 100, TransactionId(6));
        PaymentLine."Capture Requested" := true;
        PaymentLine.Modify();
        StartEntryNo := LibBilling.LastBillingQueueEntryNo();

        // [WHEN] The payment lines are refreshed from the voided authorization
        UpdatePaymentLines(false, OrderRecordId(OrderNo), StrSubstNo('[%1]', AuthorizationJson(TransactionId(6), 100, 0)));

        // [THEN] The card line is not saved as captured and nothing is billed
        PaymentLine.Find();
        _Assert.AreEqual(0D, PaymentLine."Date Captured", 'A line of an authorization Shopify took no money from must not be saved as captured at import.');
        _Assert.AreEqual(0, LibBilling.AmountQueueEntriesSince(StartEntryNo), 'A line of an authorization Shopify took no money from must not be billed.');
    end;

    [Test]
    procedure VoidedAuthorizationLine_TaskList_IsNotBilledAtImport()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        LibBilling: Codeunit "NPR Library - Spfy Billing";
        OrderNo: Code[20];
        StartEntryNo: BigInteger;
    begin
        // [SCENARIO] On the Shopify Task List, a card line whose authorization has nothing unsettled and nothing captured from it (voided or expired) is neither saved as captured nor billed when the payment lines are refreshed, since Shopify took no money.
        Initialize();

        // [GIVEN] Sales order 100 carrying a card line of 100 whose capture was requested, for an authorization that was later voided
        OrderNo := 'SPFYPA-B8';
        InsertOrder(OrderNo, 100);
        PaymentLine := AddOrderPaymentLine(OrderNo, Enum::"NPR Magento Payment Type"::"Payment Method", 100, TransactionId(6));
        PaymentLine."Capture Requested" := true;
        PaymentLine.Modify();
        StartEntryNo := LibBilling.LastBillingQueueEntryNo();

        // [WHEN] The payment lines are refreshed from the voided authorization
        UpdatePaymentLines(true, OrderRecordId(OrderNo), StrSubstNo('[%1]', AuthorizationJson(TransactionId(6), 100, 0)));

        // [THEN] The card line is not saved as captured and nothing is billed
        PaymentLine.Find();
        _Assert.AreEqual(0D, PaymentLine."Date Captured", 'A line of an authorization Shopify took no money from must not be saved as captured at import.');
        _Assert.AreEqual(0, LibBilling.AmountQueueEntriesSince(StartEntryNo), 'A line of an authorization Shopify took no money from must not be billed.');
    end;

    [Test]
    procedure OrderEditedBelowGiftCard_NcQueue_GiftCardLineKeepsWhatShopifyKept()
    var
        OrderNo: Code[20];
    begin
        // [SCENARIO] On the NC task queue, a sales order edited in Shopify below its gift card payment, with the difference refunded to the gift card, keeps on its voucher line only what Shopify kept on the gift card, and the voucher reservation follows.
        Initialize();

        // [GIVEN] Sales order 16.50 still carrying the import's voucher line of 100, reserved on the voucher, and a card line of 649.10
        OrderNo := 'SPFYPA-SO20';
        InsertOrder(OrderNo, 16.5);
        AddOrderVoucherReservation(AddOrderPaymentLine(OrderNo, Enum::"NPR Magento Payment Type"::Voucher, 100, _GiftCardTxnId));
        AddOrderPaymentLine(OrderNo, Enum::"NPR Magento Payment Type"::"Payment Method", 649.10, _AuthorizationTxnId);

        // [WHEN] The payment lines are refreshed from a card authorization of 649.10, a gift card sale of 100 and a refund of 83.50 to the gift card
        UpdatePaymentLines(false, OrderRecordId(OrderNo), RefundedGiftCardJson(649.10, 100, 83.5));

        // [THEN] The voucher line pays the 16.50 Shopify kept on the gift card and asks for no more, in the store currency too
        _Assert.AreEqual(16.5, OrderLinesAmount(OrderNo, Enum::"NPR Magento Payment Type"::Voucher), 'The voucher line must not keep money Shopify gave back to the gift card.');
        _Assert.AreEqual(16.5, OrderLinesRequestedAmount(OrderNo, Enum::"NPR Magento Payment Type"::Voucher), 'The release must not grow the voucher line back to the refunded amount.');
        _Assert.AreEqual(16.5, OrderLinesStoreCurrencyAmount(OrderNo, Enum::"NPR Magento Payment Type"::Voucher), 'The store-currency amount must follow the amount.');
        // [THEN] The voucher stays reserved for 16.50 only
        _Assert.AreEqual(16.5, OrderVoucherReservation(OrderNo), 'The voucher reservation must follow the voucher line.');
        // [THEN] The card pays nothing
        _Assert.AreEqual(0, OrderLinesAmount(OrderNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'The card must not pay any part of an order the gift card covers.');
    end;

    [Test]
    procedure OrderEditedBelowGiftCard_TaskList_GiftCardLineKeepsWhatShopifyKept()
    var
        OrderNo: Code[20];
    begin
        // [SCENARIO] On the Shopify Task List, a sales order edited in Shopify below its gift card payment, with the difference refunded to the gift card, keeps on its voucher line only what Shopify kept on the gift card, and the voucher reservation follows.
        Initialize();

        // [GIVEN] Sales order 16.50 still carrying the import's voucher line of 100, reserved on the voucher, and a card line of 649.10
        OrderNo := 'SPFYPA-SO21';
        InsertOrder(OrderNo, 16.5);
        AddOrderVoucherReservation(AddOrderPaymentLine(OrderNo, Enum::"NPR Magento Payment Type"::Voucher, 100, _GiftCardTxnId));
        AddOrderPaymentLine(OrderNo, Enum::"NPR Magento Payment Type"::"Payment Method", 649.10, _AuthorizationTxnId);

        // [WHEN] The payment lines are refreshed from a card authorization of 649.10, a gift card sale of 100 and a refund of 83.50 to the gift card
        UpdatePaymentLines(true, OrderRecordId(OrderNo), RefundedGiftCardJson(649.10, 100, 83.5));

        // [THEN] The voucher line pays the 16.50 Shopify kept on the gift card and asks for no more, in the store currency too
        _Assert.AreEqual(16.5, OrderLinesAmount(OrderNo, Enum::"NPR Magento Payment Type"::Voucher), 'The voucher line must not keep money Shopify gave back to the gift card.');
        _Assert.AreEqual(16.5, OrderLinesRequestedAmount(OrderNo, Enum::"NPR Magento Payment Type"::Voucher), 'The release must not grow the voucher line back to the refunded amount.');
        _Assert.AreEqual(16.5, OrderLinesStoreCurrencyAmount(OrderNo, Enum::"NPR Magento Payment Type"::Voucher), 'The store-currency amount must follow the amount.');
        // [THEN] The voucher stays reserved for 16.50 only
        _Assert.AreEqual(16.5, OrderVoucherReservation(OrderNo), 'The voucher reservation must follow the voucher line.');
        // [THEN] The card pays nothing
        _Assert.AreEqual(0, OrderLinesAmount(OrderNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'The card must not pay any part of an order the gift card covers.');
    end;

    [Test]
    procedure OrderEditedBelowGiftCardInOtherStoreCurrency_NcQueue_StoreCurrencyAmountsFollowTheCut()
    var
        GiftCardPaymentLine: Record "NPR Magento Payment Line";
        OrderNo: Code[20];
    begin
        // [SCENARIO] On the NC task queue, a voucher line cut to what Shopify kept on the gift card keeps its store currency amounts at the line's own rate.
        Initialize();

        // [GIVEN] Sales order 16.50 carrying a voucher line of 100, reserved on the voucher, which is 75 in the store currency
        OrderNo := 'SPFYPA-SO30';
        InsertOrder(OrderNo, 16.5);
        GiftCardPaymentLine := AddOrderPaymentLine(OrderNo, Enum::"NPR Magento Payment Type"::Voucher, 100, _GiftCardTxnId);
        GiftCardPaymentLine."Amount (Store Currency)" := 75;
        GiftCardPaymentLine."Requested Amt. (Store Curr.)" := 75;
        GiftCardPaymentLine.Modify();
        AddOrderVoucherReservation(GiftCardPaymentLine);

        // [WHEN] The payment lines are refreshed from a gift card sale of 100 and a refund of 83.50 to the gift card
        UpdatePaymentLines(false, OrderRecordId(OrderNo), PartlyRefundedGiftCardJson(100, 83.5));

        // [THEN] The voucher line pays and asks for 16.50, which is 12.38 in the store currency
        _Assert.AreEqual(16.5, OrderLinesAmount(OrderNo, Enum::"NPR Magento Payment Type"::Voucher), 'The voucher line must not keep money Shopify gave back to the gift card.');
        _Assert.AreEqual(12.38, OrderLinesStoreCurrencyAmount(OrderNo, Enum::"NPR Magento Payment Type"::Voucher), 'The store currency amount must follow the cut at the line''s rate.');
        _Assert.AreEqual(12.38, OrderLinesRequestedStoreCurrencyAmount(OrderNo, Enum::"NPR Magento Payment Type"::Voucher), 'The requested store currency amount must follow the cut at the line''s rate.');
    end;

    [Test]
    procedure GiftCardLineReducedAtReleaseThenRefunded_NcQueue_AsksForNoMoreThanShopifyKept()
    var
        OrderNo: Code[20];
    begin
        // [SCENARIO] On the NC task queue, a voucher line an earlier release already reduced asks, once cut for a gift card refund, for no more than Shopify kept on the gift card, so a later release cannot grow it back.
        Initialize();

        // [GIVEN] Sales order 16.50 carrying a voucher line of 100 that an earlier release reduced to 50
        OrderNo := 'SPFYPA-SO31';
        InsertOrder(OrderNo, 16.5);
        SetAmount(AddOrderPaymentLine(OrderNo, Enum::"NPR Magento Payment Type"::Voucher, 100, _GiftCardTxnId), 50);

        // [WHEN] The payment lines are refreshed from a gift card sale of 100 and a refund of 83.50 to the gift card
        UpdatePaymentLines(false, OrderRecordId(OrderNo), PartlyRefundedGiftCardJson(100, 83.5));

        // [THEN] The voucher line pays and asks for 16.50
        _Assert.AreEqual(16.5, OrderLinesAmount(OrderNo, Enum::"NPR Magento Payment Type"::Voucher), 'The voucher line must not keep money Shopify gave back to the gift card.');
        _Assert.AreEqual(16.5, OrderLinesRequestedAmount(OrderNo, Enum::"NPR Magento Payment Type"::Voucher), 'The voucher line must not ask for more than Shopify kept.');
        // [THEN] The requested store currency amount follows at the rate of the requested amount, not of the reduced amount
        _Assert.AreEqual(16.5, OrderLinesRequestedStoreCurrencyAmount(OrderNo, Enum::"NPR Magento Payment Type"::Voucher), 'The requested store currency amount must be scaled from the requested amount.');
    end;

    [Test]
    procedure GiftCardLineFromEcommerceDocumentRefunded_NcQueue_RequestedAmountsFollowTheCut()
    var
        GiftCardPaymentLine: Record "NPR Magento Payment Line";
        OrderNo: Code[20];
    begin
        // [SCENARIO] On the NC task queue, a voucher line the Ecommerce document created with a store currency amount but neither requested amount gets both requested amounts set in step when it is cut.
        Initialize();

        // [GIVEN] Sales order 16.50 carrying a voucher line of 100, 75 in the store currency, with no requested amount and no requested store currency amount
        OrderNo := 'SPFYPA-SO32';
        InsertOrder(OrderNo, 16.5);
        GiftCardPaymentLine := AddOrderPaymentLine(OrderNo, Enum::"NPR Magento Payment Type"::Voucher, 100, _GiftCardTxnId);
        GiftCardPaymentLine."Requested Amount" := 0;
        GiftCardPaymentLine."Amount (Store Currency)" := 75;
        GiftCardPaymentLine."Requested Amt. (Store Curr.)" := 0;
        GiftCardPaymentLine.Modify();
        AddOrderVoucherReservation(GiftCardPaymentLine);

        // [WHEN] The payment lines are refreshed from a gift card sale of 100 and a refund of 83.50 to the gift card
        UpdatePaymentLines(false, OrderRecordId(OrderNo), PartlyRefundedGiftCardJson(100, 83.5));

        // [THEN] The voucher line pays and asks for 16.50, which is 12.38 in the store currency
        _Assert.AreEqual(16.5, OrderLinesAmount(OrderNo, Enum::"NPR Magento Payment Type"::Voucher), 'The voucher line must not keep money Shopify gave back to the gift card.');
        _Assert.AreEqual(16.5, OrderLinesRequestedAmount(OrderNo, Enum::"NPR Magento Payment Type"::Voucher), 'The voucher line must ask for what it holds.');
        _Assert.AreEqual(12.38, OrderLinesStoreCurrencyAmount(OrderNo, Enum::"NPR Magento Payment Type"::Voucher), 'The store currency amount must follow the cut at the line''s rate.');
        _Assert.AreEqual(12.38, OrderLinesRequestedStoreCurrencyAmount(OrderNo, Enum::"NPR Magento Payment Type"::Voucher), 'The requested store currency amount must be set in step with the requested amount.');
    end;

    [Test]
    procedure GiftCardLineReducedAtReleaseBeforeTheRefund_NcQueue_AsksForNoMoreThanShopifyKept()
    var
        OrderNo: Code[20];
    begin
        // [SCENARIO] On the NC task queue, a voucher line a release already brought down to the order total asks, once Shopify refunded the rest of the gift card, for no more than Shopify kept, although nothing is cut.
        Initialize();

        // [GIVEN] Sales order 50 carrying a voucher line of 100 that a release reduced to 50, still asking for 100
        OrderNo := 'SPFYPA-SO42';
        InsertOrder(OrderNo, 50);
        SetAmount(AddOrderPaymentLine(OrderNo, Enum::"NPR Magento Payment Type"::Voucher, 100, _GiftCardTxnId), 50);

        // [WHEN] The payment lines are refreshed from a gift card sale of 100 and a refund of 50 to the gift card
        UpdatePaymentLines(false, OrderRecordId(OrderNo), PartlyRefundedGiftCardJson(100, 50));

        // [THEN] The voucher line keeps paying 50 and asks for 50, in the store currency too
        _Assert.AreEqual(50, OrderLinesAmount(OrderNo, Enum::"NPR Magento Payment Type"::Voucher), 'The voucher line already fits the order.');
        _Assert.AreEqual(50, OrderLinesRequestedAmount(OrderNo, Enum::"NPR Magento Payment Type"::Voucher), 'A later release must not grow the line beyond what Shopify kept on the gift card.');
        _Assert.AreEqual(50, OrderLinesRequestedStoreCurrencyAmount(OrderNo, Enum::"NPR Magento Payment Type"::Voucher), 'The requested store currency amount must follow the requested amount.');
    end;

    [Test]
    procedure GiftCardRefundWithinWhatTheOrderInvoices_NcQueue_StaysOnTheLine()
    var
        OrderNo: Code[20];
    begin
        // [SCENARIO] On the NC task queue, a gift card refund the order total still covers stays on the voucher line, since it is for goods the order invoices and their credit memo puts it back on the gift card.
        Initialize();

        // [GIVEN] Sales order 200 carrying a voucher line of 200
        OrderNo := 'SPFYPA-SO22';
        InsertOrder(OrderNo, 200);
        AddOrderVoucherReservation(AddOrderPaymentLine(OrderNo, Enum::"NPR Magento Payment Type"::Voucher, 200, _GiftCardTxnId));

        // [WHEN] The payment lines are refreshed from a gift card sale of 200 and a refund of 100 to the gift card
        UpdatePaymentLines(false, OrderRecordId(OrderNo), PartlyRefundedGiftCardJson(200, 100));

        // [THEN] The voucher line and its reservation keep the 200, and the line still asks for its 200
        _Assert.AreEqual(200, OrderLinesAmount(OrderNo, Enum::"NPR Magento Payment Type"::Voucher), 'A refund within what the order invoices must stay on the voucher line.');
        _Assert.AreEqual(200, OrderVoucherReservation(OrderNo), 'The voucher reservation must stay as it is.');
        _Assert.AreEqual(200, OrderLinesRequestedAmount(OrderNo, Enum::"NPR Magento Payment Type"::Voucher), 'A line must keep asking for at least what it holds.');
    end;

    [Test]
    procedure GiftCardRefundBeyondTheExcess_NcQueue_CutsOnlyTheExcess()
    var
        OrderNo: Code[20];
    begin
        // [SCENARIO] On the NC task queue, a voucher line is cut only by what it holds beyond the order total, even when Shopify refunded more of the gift card, because the rest of the refund is for goods the order invoices.
        Initialize();

        // [GIVEN] Sales order 50 carrying a voucher line of 100
        OrderNo := 'SPFYPA-SO23';
        InsertOrder(OrderNo, 50);
        AddOrderVoucherReservation(AddOrderPaymentLine(OrderNo, Enum::"NPR Magento Payment Type"::Voucher, 100, _GiftCardTxnId));

        // [WHEN] The payment lines are refreshed from a gift card sale of 100 and a refund of 83.50 to the gift card
        UpdatePaymentLines(false, OrderRecordId(OrderNo), PartlyRefundedGiftCardJson(100, 83.5));

        // [THEN] The voucher line and its reservation are cut to the order's 50
        _Assert.AreEqual(50, OrderLinesAmount(OrderNo, Enum::"NPR Magento Payment Type"::Voucher), 'The voucher line must be cut by its excess only.');
        _Assert.AreEqual(50, OrderVoucherReservation(OrderNo), 'The voucher reservation must follow the voucher line.');
    end;

    [Test]
    procedure GiftCardRefundSmallerThanTheExcess_NcQueue_CutsOnlyWhatShopifyGaveBack()
    var
        OrderNo: Code[20];
    begin
        // [SCENARIO] On the NC task queue, a voucher line on an order its lines exceed by more than Shopify refunded of the gift card is cut only by the refund, never below what Shopify kept on the gift card.
        Initialize();

        // [GIVEN] Sales order 10 carrying a voucher line of 100
        OrderNo := 'SPFYPA-SO34';
        InsertOrder(OrderNo, 10);
        AddOrderVoucherReservation(AddOrderPaymentLine(OrderNo, Enum::"NPR Magento Payment Type"::Voucher, 100, _GiftCardTxnId));

        // [WHEN] The payment lines are refreshed from a gift card sale of 100 and a refund of 50 to the gift card
        UpdatePaymentLines(false, OrderRecordId(OrderNo), PartlyRefundedGiftCardJson(100, 50));

        // [THEN] The voucher line and its reservation keep the 50 Shopify kept on the gift card
        _Assert.AreEqual(50, OrderLinesAmount(OrderNo, Enum::"NPR Magento Payment Type"::Voucher), 'The voucher line must not be cut below what Shopify kept on the gift card.');
        _Assert.AreEqual(50, OrderVoucherReservation(OrderNo), 'The voucher reservation must follow the voucher line.');
    end;

    [Test]
    procedure OpenCardLineNextToRefundedGiftCard_NcQueue_IsFittedInstead()
    var
        OrderNo: Code[20];
    begin
        // [SCENARIO] On the NC task queue, the card line of an open authorization gives way when an order's lines add up to more than its total, before any gift card refund is taken off the voucher line.
        Initialize();

        // [GIVEN] Sales order 250 carrying a voucher line of 200 and a card line of 100
        OrderNo := 'SPFYPA-SO24';
        InsertOrder(OrderNo, 250);
        AddOrderVoucherReservation(AddOrderPaymentLine(OrderNo, Enum::"NPR Magento Payment Type"::Voucher, 200, _GiftCardTxnId));
        AddOrderPaymentLine(OrderNo, Enum::"NPR Magento Payment Type"::"Payment Method", 100, _AuthorizationTxnId);

        // [WHEN] The payment lines are refreshed from a card authorization of 100, a gift card sale of 200 and a refund of 100 to the gift card
        UpdatePaymentLines(false, OrderRecordId(OrderNo), RefundedGiftCardJson(100, 200, 100));

        // [THEN] The voucher line keeps its 200 and the card line is fitted to the 50 left
        _Assert.AreEqual(200, OrderLinesAmount(OrderNo, Enum::"NPR Magento Payment Type"::Voucher), 'The gift card refund must not be taken off while the card can give way.');
        _Assert.AreEqual(50, OrderLinesAmount(OrderNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'The card must pay only what the voucher leaves.');
    end;

    [Test]
    procedure PartlyRefundedCardSaleOnReducedOrder_NcQueue_IsCutToWhatShopifyKept()
    var
        OrderNo: Code[20];
    begin
        // [SCENARIO] On the NC task queue, the card line of a sale Shopify partly refunded after the order was reduced keeps only what Shopify kept of the sale.
        Initialize();

        // [GIVEN] Sales order 70 carrying a card line of 100 for a card sale
        OrderNo := 'SPFYPA-SO25';
        InsertOrder(OrderNo, 70);
        AddOrderPaymentLine(OrderNo, Enum::"NPR Magento Payment Type"::"Payment Method", 100, _CardSaleTxnId);

        // [WHEN] The payment lines are refreshed from the card sale of 100 and a refund of 30 to the card
        UpdatePaymentLines(false, OrderRecordId(OrderNo), PartlyRefundedCardSaleJson(100, 30));

        // [THEN] The card line pays and asks for 70
        _Assert.AreEqual(70, OrderLinesAmount(OrderNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'The card line must not keep money Shopify gave back to the card.');
        _Assert.AreEqual(70, OrderLinesRequestedAmount(OrderNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'The card line must not ask for the refunded money again.');
    end;

    [Test]
    procedure FullyRefundedLineNextToPartlyRefundedGiftCard_NcQueue_GivesWayFirst()
    var
        OrderNo: Code[20];
    begin
        // [SCENARIO] On the NC task queue, the line of a sale Shopify refunded in full gives up its amount before a partly refunded gift card line is cut, so the gift card keeps what the order still needs from it.
        Initialize();

        // [GIVEN] Sales order 100 carrying a card line of 100 for a card sale and, after it, a voucher line of 100
        OrderNo := 'SPFYPA-SO26';
        InsertOrder(OrderNo, 100);
        AddOrderPaymentLine(OrderNo, Enum::"NPR Magento Payment Type"::"Payment Method", 100, _CardSaleTxnId);
        AddOrderVoucherReservation(AddOrderPaymentLine(OrderNo, Enum::"NPR Magento Payment Type"::Voucher, 100, _GiftCardTxnId));

        // [WHEN] The payment lines are refreshed from the card sale of 100 refunded in full and a gift card sale of 100 with 50 refunded
        UpdatePaymentLines(false, OrderRecordId(OrderNo), FullyRefundedCardSaleAndPartlyRefundedGiftCardJson(100, 100, 50));

        // [THEN] The refunded card line is gone and the voucher line keeps its 100
        _Assert.AreEqual(0, OrderLinesAmount(OrderNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'A fully refunded sale must not keep its line.');
        _Assert.AreEqual(100, OrderLinesAmount(OrderNo, Enum::"NPR Magento Payment Type"::Voucher), 'The gift card must not give up room the refunded card line held.');
        _Assert.AreEqual(100, OrderVoucherReservation(OrderNo), 'The voucher reservation must stay as it is.');
    end;

    [Test]
    procedure RefundedCaptureOnReducedOrder_NcQueue_CardLineKeepsWhatShopifyKept()
    var
        OrderNo: Code[20];
    begin
        // [SCENARIO] On the NC task queue, the card line of an authorization Shopify captured and then partly refunded, after the order was reduced, keeps only what Shopify kept of the capture.
        Initialize();

        // [GIVEN] Sales order 70 carrying a card line of 100 for an authorization
        OrderNo := 'SPFYPA-SO28';
        InsertOrder(OrderNo, 70);
        AddOrderPaymentLine(OrderNo, Enum::"NPR Magento Payment Type"::"Payment Method", 100, _AuthorizationTxnId);

        // [WHEN] The payment lines are refreshed from the authorization of 100, captured in full, and a refund of 30 of that capture
        UpdatePaymentLines(false, OrderRecordId(OrderNo), RefundedCaptureJson(100, 30));

        // [THEN] The card line pays and asks for 70
        _Assert.AreEqual(70, OrderLinesAmount(OrderNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'The card line must not keep money Shopify gave back of the capture.');
        _Assert.AreEqual(70, OrderLinesRequestedAmount(OrderNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'The card line must not ask for the refunded money again.');
    end;

    [Test]
    procedure RefundedCaptureOnReducedOrder_TaskList_CardLineKeepsWhatShopifyKept()
    var
        OrderNo: Code[20];
    begin
        // [SCENARIO] On the Shopify Task List, the card line of an authorization Shopify captured and then partly refunded, after the order was reduced, keeps only what Shopify kept of the capture.
        Initialize();

        // [GIVEN] Sales order 70 carrying a card line of 100 for an authorization
        OrderNo := 'SPFYPA-SO29';
        InsertOrder(OrderNo, 70);
        AddOrderPaymentLine(OrderNo, Enum::"NPR Magento Payment Type"::"Payment Method", 100, _AuthorizationTxnId);

        // [WHEN] The payment lines are refreshed from the authorization of 100, captured in full, and a refund of 30 of that capture
        UpdatePaymentLines(true, OrderRecordId(OrderNo), RefundedCaptureJson(100, 30));

        // [THEN] The card line pays and asks for 70
        _Assert.AreEqual(70, OrderLinesAmount(OrderNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'The card line must not keep money Shopify gave back of the capture.');
        _Assert.AreEqual(70, OrderLinesRequestedAmount(OrderNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'The card line must not ask for the refunded money again.');
    end;

    [Test]
    procedure RefundedCaptureOnEmptyInvoice_NcQueue_NewLineTakesTheCapture()
    var
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] On the NC task queue, a new card line on a posted invoice still takes what Shopify captured when part of the capture was refunded, since a refund of invoiced goods is settled by its credit memo.
        Initialize();

        // [GIVEN] Invoice 100 without payment lines
        InvoiceNo := 'SPFYPA-NC28';
        InsertInvoice(InvoiceNo, 100);

        // [WHEN] The payment lines are built from the authorization of 100, captured in full, and a refund of 30 of that capture
        UpdatePaymentLines(false, InvoiceRecordId(InvoiceNo), RefundedCaptureJson(100, 30));

        // [THEN] The card line pays the whole invoice
        _Assert.AreEqual(100, InvoiceLinesAmount(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'A refund of invoiced goods must be left to its credit memo.');
    end;

    [Test]
    procedure RefundedGiftCardLineOnPostedInvoice_NcQueue_IsNotCut()
    var
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] On the NC task queue, a gift card line on a posted invoice is not cut for a refund to the gift card, because its money is booked and a refund after posting goes through a credit memo.
        Initialize();

        // [GIVEN] Invoice 50 carrying a voucher line of 100
        InvoiceNo := 'SPFYPA-NC29';
        InsertInvoice(InvoiceNo, 50);
        AddInvoicePaymentLine(InvoiceNo, Enum::"NPR Magento Payment Type"::Voucher, 100, _GiftCardTxnId);

        // [WHEN] The payment lines are rebuilt from a gift card sale of 100 and a refund of 83.50 to the gift card
        UpdatePaymentLines(false, InvoiceRecordId(InvoiceNo), PartlyRefundedGiftCardJson(100, 83.5));

        // [THEN] The voucher line keeps its 100
        _Assert.AreEqual(100, InvoiceLinesAmount(InvoiceNo, Enum::"NPR Magento Payment Type"::Voucher), 'A posted invoice''s payment line must not be cut.');
    end;

    [Test]
    procedure RefundedGiftCardLineOnReturnOrder_NcQueue_IsNotCut()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        SalesHeader: Record "Sales Header";
        ReturnOrderNo: Code[20];
    begin
        // [SCENARIO] On the NC task queue, a payment line on a return order is not cut for a refund, because a credit document's lines are refunds themselves.
        Initialize();

        // [GIVEN] Return order 50 carrying a voucher line of 100
        ReturnOrderNo := 'SPFYPA-RO1';
        InsertSalesDocument(SalesHeader."Document Type"::"Return Order", ReturnOrderNo, 50);
        AddPaymentLine(Database::"Sales Header", Enum::"Sales Document Type"::"Return Order", ReturnOrderNo, Enum::"NPR Magento Payment Type"::Voucher, 100, _GiftCardTxnId);
        SalesHeader.Get(SalesHeader."Document Type"::"Return Order", ReturnOrderNo);

        // [WHEN] The payment lines are refreshed from a gift card sale of 100 and a refund of 83.50 to the gift card
        UpdatePaymentLines(false, SalesHeader.RecordId(), PartlyRefundedGiftCardJson(100, 83.5));

        // [THEN] The voucher line keeps its 100
        PaymentLine.SetRange("Document Table No.", Database::"Sales Header");
        PaymentLine.SetRange("Document Type", PaymentLine."Document Type"::"Return Order");
        PaymentLine.SetRange("Document No.", ReturnOrderNo);
        PaymentLine.CalcSums(Amount);
        _Assert.AreEqual(100, PaymentLine.Amount, 'A return order''s payment line must not be cut.');
    end;

    [Test]
    procedure OrderCreatedFromEcommerceDocumentWithoutRefunds_LinesStayAsTheyAre()
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
        SpfyEcomSalesDocImport: Codeunit "NPR Spfy Ecom Sales Doc Import";
        OrderNo: Code[20];
    begin
        // [SCENARIO] A sales order created from its Ecommerce document for an order Shopify has not refunded keeps its payment lines and voucher reservation as the document created them.
        Initialize();

        // [GIVEN] Sales order 749.10 created from the Ecommerce document with the gift card's 100, reserved on the voucher, and a card line of 649.10
        OrderNo := 'SPFYPA-SO33';
        InsertOrder(OrderNo, 749.1);
        AddOrderVoucherReservation(AddOrderPaymentLine(OrderNo, Enum::"NPR Magento Payment Type"::Voucher, 100, _GiftCardTxnId));
        AddOrderPaymentLine(OrderNo, Enum::"NPR Magento Payment Type"::"Payment Method", 649.10, _AuthorizationTxnId);
        // [GIVEN] The Shopify order's event log entry
        LogEntry."Store Code" := CopyStr(_StoreCodeLbl, 1, MaxStrLen(LogEntry."Store Code"));
        LogEntry."Shopify ID" := OrderNo;

        // [WHEN] The created order is refreshed from Shopify's order, whose transactions are a card authorization of 649.10 and a gift card sale of 100
        SpfyEcomSalesDocImport.RefreshCreatedOrderFromJson(OrderHeader(OrderNo), OrderResponseJson(CardAndGiftCardJson(649.10, 100)), LogEntry);

        // [THEN] The voucher line, its reservation and the card line are unchanged
        _Assert.AreEqual(100, OrderLinesAmount(OrderNo, Enum::"NPR Magento Payment Type"::Voucher), 'The voucher line must stay as created.');
        _Assert.AreEqual(100, OrderVoucherReservation(OrderNo), 'The voucher reservation must stay as created.');
        _Assert.AreEqual(649.10, OrderLinesAmount(OrderNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'The card line must stay as created.');
    end;

    [Test]
    procedure OrderCreatedFromEcommerceDocument_GiftCardLineKeepsWhatShopifyKept()
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
        SpfyEcomSalesDocImport: Codeunit "NPR Spfy Ecom Sales Doc Import";
        OrderNo: Code[20];
    begin
        // [SCENARIO] A sales order created from its Ecommerce document for an order Shopify already edited below its gift card payment has the refund taken off its voucher line before it is posted.
        Initialize();

        // [GIVEN] Sales order 16.50 created from the Ecommerce document with the gift card's full 100, reserved on the voucher, and a card line of 649.10
        OrderNo := 'SPFYPA-SO27';
        InsertOrder(OrderNo, 16.5);
        AddOrderVoucherReservation(AddOrderPaymentLine(OrderNo, Enum::"NPR Magento Payment Type"::Voucher, 100, _GiftCardTxnId));
        AddOrderPaymentLine(OrderNo, Enum::"NPR Magento Payment Type"::"Payment Method", 649.10, _AuthorizationTxnId);
        // [GIVEN] The Shopify order's event log entry
        LogEntry."Store Code" := CopyStr(_StoreCodeLbl, 1, MaxStrLen(LogEntry."Store Code"));
        LogEntry."Shopify ID" := OrderNo;

        // [WHEN] The created order is refreshed from Shopify's order, whose transactions are a card authorization of 649.10, a gift card sale of 100 and a refund of 83.50 to the gift card
        SpfyEcomSalesDocImport.RefreshCreatedOrderFromJson(OrderHeader(OrderNo), OrderResponseJson(RefundedGiftCardJson(649.10, 100, 83.5)), LogEntry);

        // [THEN] The voucher line and its reservation are cut to 16.50 and the card pays nothing
        _Assert.AreEqual(16.5, OrderLinesAmount(OrderNo, Enum::"NPR Magento Payment Type"::Voucher), 'The voucher line must not keep money Shopify gave back to the gift card.');
        _Assert.AreEqual(16.5, OrderVoucherReservation(OrderNo), 'The voucher reservation must follow the voucher line.');
        _Assert.AreEqual(0, OrderLinesAmount(OrderNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'The card must not pay any part of an order the gift card covers.');
    end;

    [Test]
    procedure GiftCardOnTwoLinesRefunded_NcQueue_LinesTogetherKeepWhatShopifyKept()
    var
        CapturedLine: Record "NPR Magento Payment Line";
        RestLine: Record "NPR Magento Payment Line";
        OrderNo: Code[20];
    begin
        // [SCENARIO] On the NC task queue, a gift card paid on two voucher lines, one BC captured for virtual items and one for the rest, keeps on the two lines together only what Shopify kept on the gift card.
        Initialize();

        // [GIVEN] Sales order 30 carrying a captured voucher line of 30 and a voucher line of 70, both for the same gift card sale
        OrderNo := 'SPFYPA-SO35';
        InsertOrder(OrderNo, 30);
        CapturedLine := AddOrderPaymentLine(OrderNo, Enum::"NPR Magento Payment Type"::Voucher, 30, _GiftCardTxnId);
        MarkCaptured(CapturedLine);
        RestLine := AddOrderPaymentLine(OrderNo, Enum::"NPR Magento Payment Type"::Voucher, 70, _GiftCardTxnId);

        // [WHEN] The payment lines are refreshed from a gift card sale of 100 and a refund of 70 to the gift card
        UpdatePaymentLines(false, OrderRecordId(OrderNo), PartlyRefundedGiftCardJson(100, 70));

        // [THEN] The voucher lines add up to the 30 Shopify kept: the captured line keeps its 30 and the other line pays nothing
        _Assert.AreEqual(30, OrderLinesAmount(OrderNo, Enum::"NPR Magento Payment Type"::Voucher), 'The lines of one gift card must not hold more than Shopify kept on it.');
        _Assert.AreEqual(30, LineAmount(CapturedLine), 'The captured voucher line must keep what was redeemed at capture.');
        _Assert.AreEqual(0, LineAmount(RestLine), 'The other voucher line must give up what Shopify gave back.');
    end;

    [Test]
    procedure GiftCardOnTwoLinesRefunded_TaskList_LinesTogetherKeepWhatShopifyKept()
    var
        CapturedLine: Record "NPR Magento Payment Line";
        RestLine: Record "NPR Magento Payment Line";
        OrderNo: Code[20];
    begin
        // [SCENARIO] On the Shopify Task List, a gift card paid on two voucher lines, one BC captured for virtual items and one for the rest, keeps on the two lines together only what Shopify kept on the gift card.
        Initialize();

        // [GIVEN] Sales order 30 carrying a captured voucher line of 30 and a voucher line of 70, both for the same gift card sale
        OrderNo := 'SPFYPA-SO43';
        InsertOrder(OrderNo, 30);
        CapturedLine := AddOrderPaymentLine(OrderNo, Enum::"NPR Magento Payment Type"::Voucher, 30, _GiftCardTxnId);
        MarkCaptured(CapturedLine);
        RestLine := AddOrderPaymentLine(OrderNo, Enum::"NPR Magento Payment Type"::Voucher, 70, _GiftCardTxnId);

        // [WHEN] The payment lines are refreshed from a gift card sale of 100 and a refund of 70 to the gift card
        UpdatePaymentLines(true, OrderRecordId(OrderNo), PartlyRefundedGiftCardJson(100, 70));

        // [THEN] The voucher lines add up to the 30 Shopify kept: the captured line keeps its 30 and the other line pays nothing
        _Assert.AreEqual(30, OrderLinesAmount(OrderNo, Enum::"NPR Magento Payment Type"::Voucher), 'The lines of one gift card must not hold more than Shopify kept on it.');
        _Assert.AreEqual(30, LineAmount(CapturedLine), 'The captured voucher line must keep what was redeemed at capture.');
        _Assert.AreEqual(0, LineAmount(RestLine), 'The other voucher line must give up what Shopify gave back.');
    end;

    [Test]
    procedure CapturedGiftCardLineOnReducedOrder_NcQueue_IsNotCut()
    var
        CapturedLine: Record "NPR Magento Payment Line";
        RestLine: Record "NPR Magento Payment Line";
        OrderNo: Code[20];
    begin
        // [SCENARIO] On the NC task queue, a voucher line BC captured keeps its amount when the order shrinks below it, because the voucher was redeemed for it at capture; the refund of that part is left to a credit memo.
        Initialize();

        // [GIVEN] Sales order 15 carrying a captured voucher line of 30 and a voucher line of 70, both for the same gift card sale
        OrderNo := 'SPFYPA-SO36';
        InsertOrder(OrderNo, 15);
        CapturedLine := AddOrderPaymentLine(OrderNo, Enum::"NPR Magento Payment Type"::Voucher, 30, _GiftCardTxnId);
        MarkCaptured(CapturedLine);
        RestLine := AddOrderPaymentLine(OrderNo, Enum::"NPR Magento Payment Type"::Voucher, 70, _GiftCardTxnId);

        // [WHEN] The payment lines are refreshed from a gift card sale of 100 and a refund of 85 to the gift card
        UpdatePaymentLines(false, OrderRecordId(OrderNo), PartlyRefundedGiftCardJson(100, 85));

        // [THEN] The other voucher line pays nothing and the captured line keeps its 30
        _Assert.AreEqual(0, LineAmount(RestLine), 'The voucher line BC did not capture must give way first.');
        _Assert.AreEqual(30, LineAmount(CapturedLine), 'A captured voucher line must not be cut below what was redeemed from the voucher.');
    end;

    [Test]
    procedure RefundedCaptureOfOpenAuthorization_NcQueue_CapturedLineKeepsWhatShopifyKept()
    var
        CardLine: Record "NPR Magento Payment Line";
        OrderNo: Code[20];
    begin
        // [SCENARIO] On the NC task queue, a card line BC captured on an authorization Shopify still holds partly open keeps, after the order was reduced, only what Shopify kept of the capture.
        Initialize();

        // [GIVEN] Sales order 100 carrying a captured card line of 100 for an authorization and a voucher line of 50
        OrderNo := 'SPFYPA-SO37';
        InsertOrder(OrderNo, 100);
        CardLine := AddOrderPaymentLine(OrderNo, Enum::"NPR Magento Payment Type"::"Payment Method", 100, _AuthorizationTxnId);
        MarkCaptured(CardLine);
        AddOrderVoucherReservation(AddOrderPaymentLine(OrderNo, Enum::"NPR Magento Payment Type"::Voucher, 50, _GiftCardTxnId));

        // [WHEN] The payment lines are refreshed from an authorization of 120 with 20 still open, a capture of 100, a refund of 50 of that capture and a gift card sale of 50
        UpdatePaymentLines(false, OrderRecordId(OrderNo), PartlyCapturedRefundedCardAndGiftCardJson(120, 20, 100, 50, 50));

        // [THEN] The card line keeps the 50 Shopify kept of the capture and the voucher line its 50
        _Assert.AreEqual(50, LineAmount(CardLine), 'A captured line must not keep money Shopify gave back of the capture.');
        _Assert.AreEqual(50, OrderLinesAmount(OrderNo, Enum::"NPR Magento Payment Type"::Voucher), 'The gift card Shopify kept in full must keep its line.');
    end;

    [Test]
    procedure CardLineMarkedCapturedWithoutAShopifyCapture_NcQueue_IsNotCut()
    var
        CardLine: Record "NPR Magento Payment Line";
        OrderNo: Code[20];
    begin
        // [SCENARIO] On the NC task queue, a card line marked captured on an authorization Shopify reports no capture for keeps its amount, because nothing shows what Shopify took for it.
        Initialize();

        // [GIVEN] Sales order 50 carrying a card line of 100 marked captured
        OrderNo := 'SPFYPA-SO38';
        InsertOrder(OrderNo, 50);
        CardLine := AddOrderPaymentLine(OrderNo, Enum::"NPR Magento Payment Type"::"Payment Method", 100, _AuthorizationTxnId);
        MarkCaptured(CardLine);

        // [WHEN] The payment lines are refreshed from an open authorization of 100 with no capture
        UpdatePaymentLines(false, OrderRecordId(OrderNo), PartlyCapturedCardJson(100, 100));

        // [THEN] The card line keeps its 100
        _Assert.AreEqual(100, LineAmount(CardLine), 'A line marked captured without a capture in Shopify must be left as it is.');
    end;

    [Test]
    procedure PartlyInvoicedGiftCardRefundedOnReducedOrder_NcQueue_KeepsWhatTheOtherInvoicesLeft()
    var
        OrderNo: Code[20];
        InvoiceNo: Code[20];
        OpenRefundTxnId: Text[30];
    begin
        // [SCENARIO] On the NC task queue, a voucher line on a reduced order keeps what the gift card has left after its refunds and what another invoice took, with a refund a credit memo booked given back to it.
        Initialize();
        OpenRefundTxnId := TransactionId(16);

        // [GIVEN] A posted invoice that took 150 of the gift card, and a credit memo that booked a refund of 50
        InvoiceNo := 'SPFYPA-NC30';
        InsertInvoice(InvoiceNo, 150);
        AddInvoicePaymentLine(InvoiceNo, Enum::"NPR Magento Payment Type"::Voucher, 150, _GiftCardTxnId);
        AddCreditMemoPaymentLine('SPFYPA-CM30', 50, _GiftCardRefundTxnId);
        // [GIVEN] Sales order 60 carrying a voucher line of the 150 the invoice left
        OrderNo := 'SPFYPA-SO39';
        InsertOrder(OrderNo, 60);
        AddOrderVoucherReservation(AddOrderPaymentLine(OrderNo, Enum::"NPR Magento Payment Type"::Voucher, 150, _GiftCardTxnId));

        // [WHEN] The payment lines are refreshed from a gift card sale of 300, the refund of 50 the credit memo booked and a refund of 40 no credit document booked
        UpdatePaymentLines(false, OrderRecordId(OrderNo), GiftCardWithBookedAndOpenRefundJson(300, 50, OpenRefundTxnId, 40));

        // [THEN] The voucher line keeps 110: the 300 less the 150 invoiced, the 40 refund not booked yet, and nothing for the booked refund
        _Assert.AreEqual(110, OrderLinesAmount(OrderNo, Enum::"NPR Magento Payment Type"::Voucher), 'The line must keep what the gift card has left after other invoices and open refunds.');
        _Assert.AreEqual(110, OrderVoucherReservation(OrderNo), 'The voucher reservation must follow the voucher line.');
    end;

    [Test]
    procedure PartlyInvoicedCaptureRefundedOnReducedOrder_NcQueue_KeepsWhatTheOtherInvoicesLeft()
    var
        FirstCaptureTxnId: Text[30];
        OpenRefundTxnId: Text[30];
        SecondCaptureTxnId: Text[30];
        OrderNo: Code[20];
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] On the NC task queue, the card line of an authorization captured in two parts keeps, on a reduced order, what the captures have left after their refunds and what another invoice took, with a refund a credit memo booked given back to it.
        Initialize();
        FirstCaptureTxnId := TransactionId(17);
        SecondCaptureTxnId := TransactionId(18);
        OpenRefundTxnId := TransactionId(16);

        // [GIVEN] A posted invoice that took 150 of the authorization, and a credit memo that booked a refund of 50 of the first capture
        InvoiceNo := 'SPFYPA-NC31';
        InsertInvoice(InvoiceNo, 150);
        AddInvoicePaymentLine(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method", 150, _AuthorizationTxnId);
        AddCreditMemoPaymentLine('SPFYPA-CM31', 50, _CardRefundTxnId);
        // [GIVEN] Sales order 60 carrying a card line of the 150 the invoice left
        OrderNo := 'SPFYPA-SO40';
        InsertOrder(OrderNo, 60);
        AddOrderPaymentLine(OrderNo, Enum::"NPR Magento Payment Type"::"Payment Method", 150, _AuthorizationTxnId);

        // [WHEN] The payment lines are refreshed from an authorization of 300 captured as 200 and 100, the refund of 50 of the first capture the credit memo booked and a refund of 40 of the second no credit document booked
        UpdatePaymentLines(false, OrderRecordId(OrderNo), TwoCapturesWithBookedAndOpenRefundJson(FirstCaptureTxnId, 200, SecondCaptureTxnId, 100, 50, OpenRefundTxnId, 40));

        // [THEN] The card line keeps 110: the 300 captured less the 150 invoiced, the 40 refund not booked yet, and nothing for the booked refund
        _Assert.AreEqual(110, OrderLinesAmount(OrderNo, Enum::"NPR Magento Payment Type"::"Payment Method"), 'The line must keep what the captures have left after other invoices and open refunds.');
    end;

    [Test]
    procedure OpenAuthorizationWithUncapturedInvoiceLine_NcQueue_CapturedOrderLineKeepsItsCapture()
    var
        CardLine: Record "NPR Magento Payment Line";
        CaptureTxnId: Text[30];
        OrderNo: Code[20];
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] On the NC task queue, an invoice line of an authorization Shopify still holds open does not count against the captures until BC captured it, so a captured order line keeps what Shopify captured for it.
        Initialize();
        CaptureTxnId := TransactionId(19);

        // [GIVEN] A posted invoice carrying an uncaptured card line of 100 for the authorization
        InvoiceNo := 'SPFYPA-NC32';
        InsertInvoice(InvoiceNo, 100);
        AddInvoicePaymentLine(InvoiceNo, Enum::"NPR Magento Payment Type"::"Payment Method", 100, _AuthorizationTxnId);
        // [GIVEN] Sales order 40 carrying a captured card line of 200 for the same authorization
        OrderNo := 'SPFYPA-SO41';
        InsertOrder(OrderNo, 40);
        CardLine := AddOrderPaymentLine(OrderNo, Enum::"NPR Magento Payment Type"::"Payment Method", 200, _AuthorizationTxnId);
        MarkCaptured(CardLine);

        // [WHEN] The payment lines are refreshed from an authorization of 300 with 100 still open, a capture of 200 and a refund of 50 of that capture
        UpdatePaymentLines(false, OrderRecordId(OrderNo), PartlyCapturedRefundedJson(300, 100, CaptureTxnId, 200, 50));

        // [THEN] The card line keeps the 150 Shopify kept of its capture
        _Assert.AreEqual(150, LineAmount(CardLine), 'An uncaptured invoice line must not count against what Shopify captured.');
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
    begin
        InsertSalesDocument(SalesHeader."Document Type"::Order, OrderNo, AmountInclVAT);
    end;

    local procedure InsertSalesDocument(DocumentType: Enum "Sales Document Type"; OrderNo: Code[20]; AmountInclVAT: Decimal)
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        SalesHeader.Init();
        SalesHeader."Document Type" := DocumentType;
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

    /// <summary>
    /// Reserves the voucher for the voucher line, as the order import does when it adds the gift card's payment line.
    /// </summary>
    local procedure AddOrderVoucherReservation(PaymentLine: Record "NPR Magento Payment Line")
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Voucher: Record "NPR NpRv Voucher";
        VoucherNoTok: Label 'SPFYPMTGC01', Locked = true;
    begin
        Voucher.Get(VoucherNoTok);
        NpRvSalesLine.Init();
        NpRvSalesLine.Id := CreateGuid();
        NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::"Payment Line";
        NpRvSalesLine."Document Type" := PaymentLine."Document Type";
        NpRvSalesLine."Document No." := PaymentLine."Document No.";
        NpRvSalesLine."Document Line No." := PaymentLine."Line No.";
        NpRvSalesLine.Type := NpRvSalesLine.Type::Payment;
        NpRvSalesLine."Voucher Type" := Voucher."Voucher Type";
        NpRvSalesLine."Voucher No." := Voucher."No.";
        NpRvSalesLine."Reference No." := Voucher."Reference No.";
        NpRvSalesLine.Amount := PaymentLine.Amount;
        NpRvSalesLine."Reservation Line Id" := PaymentLine.SystemId;
        NpRvSalesLine.Insert();
    end;

    local procedure OrderVoucherReservation(OrderNo: Code[20]): Decimal
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
    begin
        NpRvSalesLine.SetRange("Document Source", NpRvSalesLine."Document Source"::"Payment Line");
        NpRvSalesLine.SetRange("Document Type", NpRvSalesLine."Document Type"::Order);
        NpRvSalesLine.SetRange("Document No.", OrderNo);
        NpRvSalesLine.SetRange(Type, NpRvSalesLine.Type::Payment);
        NpRvSalesLine.CalcSums(Amount);
        exit(NpRvSalesLine.Amount);
    end;

    local procedure MarkPosted(PaymentLine: Record "NPR Magento Payment Line")
    begin
        PaymentLine.Posted := true;
        PaymentLine.Modify();
    end;

    /// <summary>
    /// Marks the line captured by BC; for a voucher line that means the voucher was redeemed for it at capture.
    /// </summary>
    local procedure MarkCaptured(PaymentLine: Record "NPR Magento Payment Line")
    begin
        PaymentLine."Date Captured" := WorkDate();
        PaymentLine.Modify();
    end;

    local procedure LineAmount(PaymentLine: Record "NPR Magento Payment Line"): Decimal
    begin
        PaymentLine.Find();
        exit(PaymentLine.Amount);
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

    local procedure PartlyRefundedGiftCardJson(GiftCardAmount: Decimal; RefundedAmount: Decimal): Text
    var
        TransactionsTok: Label '[%1,%2]', Locked = true;
    begin
        exit(StrSubstNo(TransactionsTok, GiftCardSaleJson(GiftCardAmount), RefundJson(_GiftCardRefundTxnId, _GiftCardTxnId, 'gift_card', RefundedAmount)));
    end;

    /// <summary>
    /// An authorization Shopify captured in full, and a refund of that capture, which Shopify parents to the capture.
    /// </summary>
    local procedure RefundedCaptureJson(AuthorizedAmount: Decimal; RefundedAmount: Decimal): Text
    var
        TransactionsTok: Label '[%1,%2,%3]', Locked = true;
    begin
        exit(StrSubstNo(TransactionsTok,
            AuthorizationJson(AuthorizedAmount, 0), CaptureJson(TransactionId(14), _AuthorizationTxnId, AuthorizedAmount),
            RefundJson(_CardRefundTxnId, TransactionId(14), _GatewayLbl, RefundedAmount)));
    end;

    /// <summary>
    /// An authorization Shopify still holds partly open, a capture of part of it, a refund of that capture, which Shopify parents to the capture, and a gift card sale.
    /// </summary>
    local procedure PartlyCapturedRefundedCardAndGiftCardJson(AuthorizedAmount: Decimal; UnsettledAmount: Decimal; CapturedAmount: Decimal; RefundedAmount: Decimal; GiftCardAmount: Decimal): Text
    var
        TransactionsTok: Label '[%1,%2,%3,%4]', Locked = true;
    begin
        exit(StrSubstNo(TransactionsTok,
            AuthorizationJson(AuthorizedAmount, UnsettledAmount), CaptureJson(TransactionId(15), _AuthorizationTxnId, CapturedAmount),
            RefundJson(_CardRefundTxnId, TransactionId(15), _GatewayLbl, RefundedAmount), GiftCardSaleJson(GiftCardAmount)));
    end;

    /// <summary>
    /// An authorization Shopify still holds partly open, a capture of part of it, and a refund of that capture.
    /// </summary>
    local procedure PartlyCapturedRefundedJson(AuthorizedAmount: Decimal; UnsettledAmount: Decimal; CaptureTxnId: Text; CapturedAmount: Decimal; RefundedAmount: Decimal): Text
    var
        TransactionsTok: Label '[%1,%2,%3]', Locked = true;
    begin
        exit(StrSubstNo(TransactionsTok,
            AuthorizationJson(AuthorizedAmount, UnsettledAmount), CaptureJson(CaptureTxnId, _AuthorizationTxnId, CapturedAmount),
            RefundJson(_CardRefundTxnId, CaptureTxnId, _GatewayLbl, RefundedAmount)));
    end;

    /// <summary>
    /// A gift card sale with two refunds: the gift card refund transaction a credit memo books in the test, and another one.
    /// </summary>
    local procedure GiftCardWithBookedAndOpenRefundJson(GiftCardAmount: Decimal; BookedRefundAmount: Decimal; OpenRefundTxnId: Text; OpenRefundAmount: Decimal): Text
    var
        TransactionsTok: Label '[%1,%2,%3]', Locked = true;
    begin
        exit(StrSubstNo(TransactionsTok, GiftCardSaleJson(GiftCardAmount),
            RefundJson(_GiftCardRefundTxnId, _GiftCardTxnId, 'gift_card', BookedRefundAmount), RefundJson(OpenRefundTxnId, _GiftCardTxnId, 'gift_card', OpenRefundAmount)));
    end;

    /// <summary>
    /// An authorization Shopify captured in full in two captures, a refund of the first capture (the card refund transaction a credit memo books in the test)
    /// and a refund of the second.
    /// </summary>
    local procedure TwoCapturesWithBookedAndOpenRefundJson(FirstCaptureTxnId: Text; FirstCaptureAmount: Decimal; SecondCaptureTxnId: Text; SecondCaptureAmount: Decimal; BookedRefundAmount: Decimal; OpenRefundTxnId: Text; OpenRefundAmount: Decimal): Text
    var
        TransactionsTok: Label '[%1,%2,%3,%4,%5]', Locked = true;
    begin
        exit(StrSubstNo(TransactionsTok,
            AuthorizationJson(FirstCaptureAmount + SecondCaptureAmount, 0),
            CaptureJson(FirstCaptureTxnId, _AuthorizationTxnId, FirstCaptureAmount), CaptureJson(SecondCaptureTxnId, _AuthorizationTxnId, SecondCaptureAmount),
            RefundJson(_CardRefundTxnId, FirstCaptureTxnId, _GatewayLbl, BookedRefundAmount), RefundJson(OpenRefundTxnId, SecondCaptureTxnId, _GatewayLbl, OpenRefundAmount)));
    end;

    local procedure FullyRefundedCardSaleAndPartlyRefundedGiftCardJson(CardSaleAmount: Decimal; GiftCardAmount: Decimal; GiftCardRefundedAmount: Decimal): Text
    var
        TransactionsTok: Label '[%1,%2,%3,%4]', Locked = true;
    begin
        exit(StrSubstNo(TransactionsTok,
            CardSaleJson(CardSaleAmount), RefundJson(_CardRefundTxnId, _CardSaleTxnId, _GatewayLbl, CardSaleAmount),
            GiftCardSaleJson(GiftCardAmount), RefundJson(_GiftCardRefundTxnId, _GiftCardTxnId, 'gift_card', GiftCardRefundedAmount)));
    end;

    /// <summary>
    /// Shopify's order as the Ecommerce import reads it, with no line items, fulfillments or shipping lines and the given transactions.
    /// </summary>
    local procedure OrderResponseJson(TransactionsJson: Text): JsonToken
    var
        Response: JsonToken;
        OrderTok: Label '{"data":{"order":{"lineItems":[],"fulfillments":[],"shippingLines":[],"transactions":%1}}}', Locked = true;
    begin
        Response.ReadFrom(StrSubstNo(OrderTok, TransactionsJson));
        exit(Response);
    end;

    local procedure OrderHeader(OrderNo: Code[20]): Record "Sales Header"
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.Get(SalesHeader."Document Type"::Order, OrderNo);
        exit(SalesHeader);
    end;

    local procedure PartlyRefundedCardSaleJson(CardSaleAmount: Decimal; RefundedAmount: Decimal): Text
    var
        TransactionsTok: Label '[%1,%2]', Locked = true;
    begin
        exit(StrSubstNo(TransactionsTok, CardSaleJson(CardSaleAmount), RefundJson(_CardRefundTxnId, _CardSaleTxnId, _GatewayLbl, RefundedAmount)));
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

    local procedure OrderLinesRequestedAmount(OrderNo: Code[20]; PaymentType: Enum "NPR Magento Payment Type"): Decimal
    var
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        PaymentLine.SetRange("Document Table No.", Database::"Sales Header");
        PaymentLine.SetRange("Document Type", PaymentLine."Document Type"::Order);
        PaymentLine.SetRange("Document No.", OrderNo);
        PaymentLine.SetRange("Payment Type", PaymentType);
        PaymentLine.CalcSums("Requested Amount");
        exit(PaymentLine."Requested Amount");
    end;

    local procedure OrderLinesRequestedStoreCurrencyAmount(OrderNo: Code[20]; PaymentType: Enum "NPR Magento Payment Type"): Decimal
    var
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        PaymentLine.SetRange("Document Table No.", Database::"Sales Header");
        PaymentLine.SetRange("Document Type", PaymentLine."Document Type"::Order);
        PaymentLine.SetRange("Document No.", OrderNo);
        PaymentLine.SetRange("Payment Type", PaymentType);
        PaymentLine.CalcSums("Requested Amt. (Store Curr.)");
        exit(PaymentLine."Requested Amt. (Store Curr.)");
    end;

    local procedure OrderCardLine(OrderNo: Code[20]; var PaymentLine: Record "NPR Magento Payment Line")
    begin
        PaymentLine.SetRange("Document Table No.", Database::"Sales Header");
        PaymentLine.SetRange("Document Type", PaymentLine."Document Type"::Order);
        PaymentLine.SetRange("Document No.", OrderNo);
        PaymentLine.SetRange("Payment Type", PaymentLine."Payment Type"::"Payment Method");
        PaymentLine.FindFirst();
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
