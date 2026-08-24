#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 85379 "NPR Library - Entria"
{
    // Test fixtures for the Entria integration. Three groups live here: the Medusa order payloads the
    // import path reads (list page arrays in their various payment shapes), the minimal Entria setup and
    // store records the job needs, and the order import job queue fixture together with the job queue
    // hold subscriber that fixture depends on. Kept out of the test codeunit so several test
    // codeunits can share the same payload shapes.
    //
    // EventSubscriberInstance = Manual: the hold subscriber must be inert unless a test explicitly binds it.
    // Callers are expected to bracket each call into production with BindSubscription/UnbindSubscription. The
    // helper procedures are ordinary calls and need no binding.
    //
    // The Entria objects only exist from BC23 up, hence the version guard on the whole codeunit.

    EventSubscriberInstance = Manual;

    var
        _Assert: Codeunit Assert;
        _LibraryInventory: Codeunit "Library - Inventory";
        _LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";

    #region Job queue hold subscriber

    // Guard rail keeping the platform scheduler out of tests that drive the production setup path.
    //
    // Production SetupJobQueue calls StartJobQueueEntry, and that chain ends in the platform scheduler:
    //   StartJobQueueEntry -> ActivateJobQueueEntry -> JobQueueEntry.Restart()
    //     -> base app SetStatusValue(Ready) -> EnqueueTask()
    //     -> Codeunit.Run(Codeunit::"Job Queue - Enqueue") -> JobQueueEntry.ScheduleTask()
    //     -> TaskScheduler.CreateTask(Codeunit::"Job Queue Dispatcher", ...)
    //
    // From a test that is two separate problems:
    //   1) TaskScheduler.CreateTask hands the Entria order import codeunit to the platform. Its OnRun loops for
    //      up to six hours (repeat ... Sleep(1000) until DurationLimitReached) and issues outbound HTTP calls for
    //      every enabled Entria store. On CI tenants where the job queue scheduler is active this is a live risk.
    //   2) "Job Queue - Enqueue" declares TableNo, and it is invoked via Codeunit.Run *after*
    //      InitRecurringJobQueueEntry has already inserted the job queue entry in this same transaction.
    //      AL forbids that from a test without a preceding Commit() - and Commit() is exactly what would turn
    //      problem 1 from theoretical into real: TaskScheduler.CreateTask is transactional, and with the only
    //      rollback at the codeunit boundary a pending task outlives every later test in the run, so the first
    //      Commit() any of them issues hands it to the scheduler.
    //
    // JobQueueMgt.ActivateJobQueueEntry exits BEFORE Restart() when the entry is On Hold and
    // "NPR Manually Set On Hold" is set, and InitRecurringJobQueueEntry always leaves a fresh or updated entry
    // On Hold. Stamping the flag on the way in therefore skips activation altogether: no Codeunit.Run and no
    // platform task, so the job queue setup path itself never forces a Commit().
    //
    // Narrowed to the Entria order import codeunit on purpose. Callers bracket each production call with
    // BindSubscription/UnbindSubscription, but an error inside that call skips the unbind, so a leaked binding
    // must be incapable of changing the behaviour of any other test suite running in the same session.

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", OnBeforeInsertRecurringJobQueueEntry, '', false, false)]
    local procedure HoldNewEntriaJobQueueEntry(var JobQueueEntry: Record "Job Queue Entry")
    begin
        SetManualHold(JobQueueEntry);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", OnBeforeModifyUpdatedJobQueueEntry, '', false, false)]
    local procedure HoldUpdatedEntriaJobQueueEntry(var JobQueueEntry: Record "Job Queue Entry")
    begin
        // The update path (JQEntryExists -> UpdateJobQueueEntry) needs the same treatment as the insert path,
        // otherwise an existing entry updated in place would be activated.
        SetManualHold(JobQueueEntry);
    end;

    local procedure SetManualHold(var JobQueueEntry: Record "Job Queue Entry")
    var
        EntriaOrderImportJQ: Codeunit "NPR Entria Order Import JQ";
    begin
        if JobQueueEntry."Object Type to Run" <> JobQueueEntry."Object Type to Run"::Codeunit then
            exit;
        if JobQueueEntry."Object ID to Run" <> EntriaOrderImportJQ.GetCodeunitId() then
            exit;
        JobQueueEntry."NPR Manually Set On Hold" := true;
    end;

    #endregion

    #region Medusa order payload fixtures

    /// <summary>One order carrying no "payment_collections" property at all.</summary>
    procedure BuildOrderArrayWithNoPaymentLines(var OrdersArr: JsonArray; DocumentNo: Code[20]; MedusaOrderId: Text; CreatedAt: DateTime; UpdatedAt: DateTime; ItemTotal: Decimal)
    var
        OrderObj: JsonObject;
        ItemsArr: JsonArray;
        ItemObj: JsonObject;
        CreatedAtText: Text;
        UpdatedAtText: Text;
    begin
        Clear(OrdersArr);

        ItemObj.Add('title', 'Test Item');
        ItemObj.Add('quantity', 1);
        ItemObj.Add('unit_price', ItemTotal);
        ItemObj.Add('total', ItemTotal);
        ItemObj.Add('tax_total', 0);
        ItemObj.Add('product_type', 'physical');
        ItemObj.Add('is_giftcard', false);
        ItemsArr.Add(ItemObj);

        CreatedAtText := Format(CreatedAt, 0, 9);
        UpdatedAtText := Format(UpdatedAt, 0, 9);

        OrderObj.Add('id', MedusaOrderId);
        OrderObj.Add('custom_display_id', DocumentNo);
        OrderObj.Add('display_id', 360);
        OrderObj.Add('created_at', CreatedAtText);
        OrderObj.Add('updated_at', UpdatedAtText);
        OrderObj.Add('bc_status', 'pending');
        OrderObj.Add('bc_status_updated_at', CreatedAtText);
        OrderObj.Add('payment_status', 'captured');
        OrderObj.Add('currency_code', '');
        OrderObj.Add('items', ItemsArr);

        OrdersArr.Add(OrderObj);
    end;

    /// <summary>Replaces bc_status_updated_at on the array's first order, so a test can separate the
    /// marker dimension from created_at.</summary>
    procedure OverrideBcStatusUpdatedAt(var OrdersArr: JsonArray; BcStatusUpdatedAt: DateTime)
    var
        OrderTkn: JsonToken;
        OrderObj: JsonObject;
    begin
        OrdersArr.Get(0, OrderTkn);
        OrderObj := OrderTkn.AsObject();
        OrderObj.Remove('bc_status_updated_at');
        OrderObj.Add('bc_status_updated_at', Format(BcStatusUpdatedAt, 0, 9));

        Clear(OrdersArr);
        OrdersArr.Add(OrderObj);
    end;

    /// <summary>One order whose "payment_collections" carries a single card payment.</summary>
    procedure BuildOrderArrayWithPayments(var OrdersArr: JsonArray; DocumentNo: Code[20]; MedusaOrderId: Text; CreatedAt: DateTime; UpdatedAt: DateTime; ItemTotal: Decimal; PaymentAmount: Decimal; PaymentReference: Text)
    var
        OrderTkn: JsonToken;
        OrderObj: JsonObject;
        CollectionsArr: JsonArray;
        CollectionObj: JsonObject;
        PaymentsArr: JsonArray;
        PaymentObj: JsonObject;
        DataObj: JsonObject;
    begin
        BuildOrderArrayWithNoPaymentLines(OrdersArr, DocumentNo, MedusaOrderId, CreatedAt, UpdatedAt, ItemTotal);
        OrdersArr.Get(0, OrderTkn);
        OrderObj := OrderTkn.AsObject();

        DataObj.Add('pspReference', PaymentReference);
        DataObj.Add('paymentMethod', 'visa');

        PaymentObj.Add('provider_id', 'pp_test');
        PaymentObj.Add('amount', PaymentAmount);
        PaymentObj.Add('data', DataObj);
        PaymentsArr.Add(PaymentObj);

        CollectionObj.Add('payments', PaymentsArr);
        CollectionsArr.Add(CollectionObj);
        OrderObj.Add('payment_collections', CollectionsArr);

        Clear(OrdersArr);
        OrdersArr.Add(OrderObj);
    end;

    /// <summary>
    /// One order whose single payment is a voucher payment: its "data" carries "voucher_code" instead of
    /// "pspReference", which is what makes the importer classify the line as a Voucher and reserve it.
    /// </summary>
    procedure BuildOrderArrayWithVoucherPayment(var OrdersArr: JsonArray; DocumentNo: Code[20]; MedusaOrderId: Text; CreatedAt: DateTime; UpdatedAt: DateTime; ItemTotal: Decimal; PaymentAmount: Decimal; ProviderId: Text; VoucherCode: Text)
    var
        OrderTkn: JsonToken;
        OrderObj: JsonObject;
        CollectionsArr: JsonArray;
        CollectionObj: JsonObject;
        PaymentsArr: JsonArray;
        PaymentObj: JsonObject;
        DataObj: JsonObject;
    begin
        BuildOrderArrayWithNoPaymentLines(OrdersArr, DocumentNo, MedusaOrderId, CreatedAt, UpdatedAt, ItemTotal);
        OrdersArr.Get(0, OrderTkn);
        OrderObj := OrderTkn.AsObject();

        DataObj.Add('voucher_code', VoucherCode);

        PaymentObj.Add('provider_id', ProviderId);
        PaymentObj.Add('amount', PaymentAmount);
        PaymentObj.Add('data', DataObj);
        PaymentsArr.Add(PaymentObj);

        CollectionObj.Add('payments', PaymentsArr);
        CollectionsArr.Add(CollectionObj);
        OrderObj.Add('payment_collections', CollectionsArr);

        Clear(OrdersArr);
        OrdersArr.Add(OrderObj);
    end;

    /// <summary>
    /// One order whose "payment_collections" is an empty array - zero collections, as opposed to
    /// BuildOrderArrayWithEmptyPaymentCollections, which builds one collection with no payments.
    /// </summary>
    procedure BuildOrderArrayWithZeroPaymentCollections(var OrdersArr: JsonArray; DocumentNo: Code[20]; MedusaOrderId: Text; CreatedAt: DateTime; UpdatedAt: DateTime; ItemTotal: Decimal)
    var
        OrderTkn: JsonToken;
        OrderObj: JsonObject;
        EmptyCollectionsArr: JsonArray;
    begin
        BuildOrderArrayWithNoPaymentLines(OrdersArr, DocumentNo, MedusaOrderId, CreatedAt, UpdatedAt, ItemTotal);
        OrdersArr.Get(0, OrderTkn);
        OrderObj := OrderTkn.AsObject();

        OrderObj.Add('payment_collections', EmptyCollectionsArr);

        Clear(OrdersArr);
        OrdersArr.Add(OrderObj);
    end;

    /// <summary>
    /// One order whose single "payment_collections" entry carries two card payments, each with its own
    /// amount and pspReference, so payment lines colliding on one "Line No." are detectable.
    /// </summary>
    procedure BuildOrderArrayWithTwoPaymentsInOneCollection(var OrdersArr: JsonArray; DocumentNo: Code[20]; MedusaOrderId: Text; CreatedAt: DateTime; UpdatedAt: DateTime; ItemTotal: Decimal; FirstPaymentAmount: Decimal; FirstPaymentReference: Text; SecondPaymentAmount: Decimal; SecondPaymentReference: Text)
    var
        OrderTkn: JsonToken;
        OrderObj: JsonObject;
        CollectionsArr: JsonArray;
        CollectionObj: JsonObject;
        PaymentsArr: JsonArray;
    begin
        BuildOrderArrayWithNoPaymentLines(OrdersArr, DocumentNo, MedusaOrderId, CreatedAt, UpdatedAt, ItemTotal);
        OrdersArr.Get(0, OrderTkn);
        OrderObj := OrderTkn.AsObject();

        PaymentsArr.Add(BuildCardPaymentJson(FirstPaymentAmount, FirstPaymentReference));
        PaymentsArr.Add(BuildCardPaymentJson(SecondPaymentAmount, SecondPaymentReference));

        CollectionObj.Add('payments', PaymentsArr);
        CollectionsArr.Add(CollectionObj);
        OrderObj.Add('payment_collections', CollectionsArr);

        Clear(OrdersArr);
        OrdersArr.Add(OrderObj);
    end;

    /// <summary>
    /// One card payment: "data" is an object carrying paymentMethod, and pspReference makes it a Payment
    /// Method rather than a Voucher, which would otherwise try to reserve a real voucher.
    /// </summary>
    local procedure BuildCardPaymentJson(PaymentAmount: Decimal; PaymentReference: Text) PaymentObj: JsonObject
    var
        DataObj: JsonObject;
    begin
        DataObj.Add('pspReference', PaymentReference);
        DataObj.Add('paymentMethod', 'visa');

        PaymentObj.Add('provider_id', 'pp_test');
        PaymentObj.Add('amount', PaymentAmount);
        PaymentObj.Add('data', DataObj);
    end;

    /// <summary>One order whose "payment_collections" is present but carries an empty "payments" array.</summary>
    procedure BuildOrderArrayWithEmptyPaymentCollections(var OrdersArr: JsonArray; DocumentNo: Code[20]; MedusaOrderId: Text; CreatedAt: DateTime; UpdatedAt: DateTime; ItemTotal: Decimal)
    var
        OrderTkn: JsonToken;
        OrderObj: JsonObject;
        CollectionsArr: JsonArray;
        CollectionObj: JsonObject;
        EmptyPaymentsArr: JsonArray;
    begin
        BuildOrderArrayWithNoPaymentLines(OrdersArr, DocumentNo, MedusaOrderId, CreatedAt, UpdatedAt, ItemTotal);
        OrdersArr.Get(0, OrderTkn);
        OrderObj := OrderTkn.AsObject();

        CollectionObj.Add('payments', EmptyPaymentsArr);
        CollectionsArr.Add(CollectionObj);
        OrderObj.Add('payment_collections', CollectionsArr);

        Clear(OrdersArr);
        OrdersArr.Add(OrderObj);
    end;

    /// <summary>One order carrying no "custom_display_id" property at all.</summary>
    procedure BuildOrderArrayWithoutDisplayId(var OrdersArr: JsonArray; MedusaOrderId: Text; CreatedAt: DateTime; ItemTotal: Decimal)
    var
        OrderObj: JsonObject;
        ItemsArr: JsonArray;
        ItemObj: JsonObject;
    begin
        Clear(OrdersArr);

        ItemObj.Add('title', 'Test Item');
        ItemObj.Add('quantity', 1);
        ItemObj.Add('unit_price', ItemTotal);
        ItemObj.Add('total', ItemTotal);
        ItemObj.Add('tax_total', 0);
        ItemObj.Add('product_type', 'physical');
        ItemObj.Add('is_giftcard', false);
        ItemsArr.Add(ItemObj);

        OrderObj.Add('id', MedusaOrderId);
        OrderObj.Add('created_at', Format(CreatedAt, 0, 9));
        OrderObj.Add('updated_at', Format(CreatedAt, 0, 9));
        OrderObj.Add('bc_status', 'pending');
        OrderObj.Add('bc_status_updated_at', Format(CreatedAt, 0, 9));
        OrderObj.Add('payment_status', 'captured');
        OrderObj.Add('currency_code', '');
        OrderObj.Add('items', ItemsArr);

        OrdersArr.Add(OrderObj);
    end;

    /// <summary>
    /// Builds one "items" entry whose quantity, unit_price and total are supplied independently of each
    /// other, so a mapping that reads one JSON property where it should read another is detectable.
    /// An empty TaxRates list leaves the line with no "tax_lines" property at all.
    /// </summary>
    procedure BuildItemLineJson(var ItemObj: JsonObject; Title: Text; ItemNo: Code[20]; Quantity: Decimal; UnitPrice: Decimal; LineTotal: Decimal; TaxTotal: Decimal; Subtotal: Decimal; TaxRates: List of [Decimal])
    var
        MetadataObj: JsonObject;
        TaxLinesArr: JsonArray;
        TaxRate: Decimal;
    begin
        Clear(ItemObj);

        ItemObj.Add('title', Title);
        ItemObj.Add('quantity', Quantity);
        ItemObj.Add('unit_price', UnitPrice);
        ItemObj.Add('total', LineTotal);
        ItemObj.Add('subtotal', Subtotal);
        ItemObj.Add('tax_total', TaxTotal);
        ItemObj.Add('product_type', 'physical');
        ItemObj.Add('is_giftcard', false);

        // metadata.external_id is where the importer reads the line's "No." from, and the "No." is what
        // decides the line's Subtype. Left out entirely when no item is supplied.
        if ItemNo <> '' then begin
            MetadataObj.Add('external_id', ItemNo);
            ItemObj.Add('metadata', MetadataObj);
        end;

        if TaxRates.Count() = 0 then
            exit;

        foreach TaxRate in TaxRates do
            TaxLinesArr.Add(BuildTaxLineJson(TaxRate));
        ItemObj.Add('tax_lines', TaxLinesArr);
    end;

    local procedure BuildTaxLineJson(TaxRate: Decimal) TaxLineObj: JsonObject
    begin
        TaxLineObj.Add('rate', TaxRate);
    end;

    /// <summary>
    /// Wraps one item line built by BuildItemLineJson in an order carrying the given currency_code and a
    /// single card payment, so an order with non-zero line amounts still passes the payment guard.
    /// </summary>
    procedure BuildOrderArrayForItemLine(var OrdersArr: JsonArray; DocumentNo: Code[20]; MedusaOrderId: Text; CreatedAt: DateTime; CurrencyCode: Code[10]; ItemObj: JsonObject; PaymentAmount: Decimal)
    var
        OrderObj: JsonObject;
        ItemsArr: JsonArray;
        CollectionsArr: JsonArray;
        CollectionObj: JsonObject;
        PaymentsArr: JsonArray;
        PaymentObj: JsonObject;
        DataObj: JsonObject;
        CreatedAtText: Text;
    begin
        Clear(OrdersArr);

        ItemsArr.Add(ItemObj);

        // Same card-payment shape as BuildOrderArrayWithPayments: "data" must be an object and carry
        // paymentMethod, and pspReference makes it a Payment Method rather than a Voucher.
        DataObj.Add('pspReference', 'psp-' + MedusaOrderId);
        DataObj.Add('paymentMethod', 'visa');

        PaymentObj.Add('provider_id', 'pp_test');
        PaymentObj.Add('amount', PaymentAmount);
        PaymentObj.Add('data', DataObj);
        PaymentsArr.Add(PaymentObj);

        CollectionObj.Add('payments', PaymentsArr);
        CollectionsArr.Add(CollectionObj);

        CreatedAtText := Format(CreatedAt, 0, 9);

        OrderObj.Add('id', MedusaOrderId);
        OrderObj.Add('custom_display_id', DocumentNo);
        OrderObj.Add('display_id', 360);
        OrderObj.Add('created_at', CreatedAtText);
        OrderObj.Add('updated_at', CreatedAtText);
        OrderObj.Add('payment_status', 'captured');
        OrderObj.Add('currency_code', CurrencyCode);
        OrderObj.Add('items', ItemsArr);
        OrderObj.Add('payment_collections', CollectionsArr);

        OrdersArr.Add(OrderObj);
    end;

    /// <summary>
    /// One page carrying two orders whose document no., Medusa order id and created_at are supplied
    /// independently of each other, so the page's array order can be varied against its timestamps - and
    /// so the very same order can be placed in one page twice.
    /// </summary>
    procedure BuildTwoOrderPage(var OrdersArr: JsonArray; FirstDocumentNo: Code[20]; FirstMedusaOrderId: Text; FirstCreatedAt: DateTime; SecondDocumentNo: Code[20]; SecondMedusaOrderId: Text; SecondCreatedAt: DateTime; ItemTotal: Decimal)
    var
        FirstOrderArr: JsonArray;
        SecondOrderArr: JsonArray;
        FirstOrderTkn: JsonToken;
        SecondOrderTkn: JsonToken;
    begin
        BuildOrderArrayWithNoPaymentLines(FirstOrderArr, FirstDocumentNo, FirstMedusaOrderId, FirstCreatedAt, FirstCreatedAt, ItemTotal);
        BuildOrderArrayWithNoPaymentLines(SecondOrderArr, SecondDocumentNo, SecondMedusaOrderId, SecondCreatedAt, SecondCreatedAt, ItemTotal);
        FirstOrderArr.Get(0, FirstOrderTkn);
        SecondOrderArr.Get(0, SecondOrderTkn);

        Clear(OrdersArr);
        OrdersArr.Add(FirstOrderTkn.AsObject());
        OrdersArr.Add(SecondOrderTkn.AsObject());
    end;

    /// <summary>
    /// One page carrying OrderCount distinct orders, returning the generated Medusa order ids and document
    /// nos. in the same order as the page declares them, so a test can pick the order that lands in a
    /// specific filter chunk. Every id is padded to exactly MedusaOrderIdLength characters, and every
    /// custom_display_id to exactly DocumentNoLength characters when that is greater than zero - the two
    /// lengths decide how many values fit one filter chunk, so a page that spans several chunks can be
    /// built without needing an unreasonable order count. DocumentNoLength 0 keeps the natural display id
    /// length. ItemTotal 0 keeps every order importable, a non-zero one makes every order fail the
    /// payment guard.
    /// </summary>
    procedure BuildOrderPageWithManyOrders(var OrdersArr: JsonArray; OrderCount: Integer; MedusaOrderIdLength: Integer; DocumentNoLength: Integer; CreatedAt: DateTime; ItemTotal: Decimal; var GeneratedOrderIds: List of [Text]; var GeneratedDocumentNos: List of [Code[20]])
    var
        OrderArr: JsonArray;
        OrderTkn: JsonToken;
        DocumentNo: Code[20];
        MedusaOrderId: Text;
        i: Integer;
    begin
        Clear(OrdersArr);
        Clear(GeneratedOrderIds);
        Clear(GeneratedDocumentNos);

        for i := 1 to OrderCount do begin
            DocumentNo := ManyOrderDocumentNo(i, DocumentNoLength);
            MedusaOrderId := ManyOrderMedusaOrderId(i, MedusaOrderIdLength);

            BuildOrderArrayWithNoPaymentLines(OrderArr, DocumentNo, MedusaOrderId, CreatedAt, CreatedAt, ItemTotal);
            OrderArr.Get(0, OrderTkn);
            OrdersArr.Add(OrderTkn.AsObject());

            GeneratedOrderIds.Add(MedusaOrderId);
            GeneratedDocumentNos.Add(DocumentNo);
        end;
    end;

    /// <summary>
    /// The custom_display_id of the OrderIndex'th order of a BuildOrderPageWithManyOrders page, right-padded
    /// with a non-digit filler to exactly DocumentNoLength characters when that is greater than zero - the
    /// distinct part stays at the front, so display ids remain distinct whatever the requested length. Kept
    /// within Code[20]: production reads custom_display_id into a Code[20] field, and an over-length one
    /// would trip a separate, unrelated production defect.
    /// </summary>
    local procedure ManyOrderDocumentNo(OrderIndex: Integer; DocumentNoLength: Integer) DocumentNo: Code[20]
    var
        DocumentNoText: Text;
        DocumentNoPrefixLbl: Label 'ENT-MANY-', Locked = true;
        FillerCharLbl: Label '-', Locked = true;
    begin
        DocumentNoText := DocumentNoPrefixLbl + Format(OrderIndex);
        _Assert.IsTrue(StrLen(DocumentNoText) <= MaxStrLen(DocumentNo),
            'Setup: the generated custom_display_id must fit Code[20], otherwise the orders of the page would not stay distinct.');

        if DocumentNoLength > 0 then begin
            _Assert.IsTrue(DocumentNoLength <= MaxStrLen(DocumentNo),
                'Setup: the requested custom_display_id length must fit Code[20] - an over-length display id trips a separate, unrelated production defect.');
            _Assert.IsTrue(StrLen(DocumentNoText) <= DocumentNoLength,
                'Setup: the requested custom_display_id length must fit the distinct part of the generated display id.');
            DocumentNoText := PadStr(DocumentNoText, DocumentNoLength, FillerCharLbl);
        end;

        DocumentNo := CopyStr(DocumentNoText, 1, MaxStrLen(DocumentNo));
    end;

    /// <summary>
    /// The id of the OrderIndex'th order of a BuildOrderPageWithManyOrders page, right-padded with a
    /// non-digit filler to exactly MedusaOrderIdLength characters - the distinct part stays at the front,
    /// so ids remain distinct whatever the requested length.
    /// </summary>
    local procedure ManyOrderMedusaOrderId(OrderIndex: Integer; MedusaOrderIdLength: Integer): Text
    var
        MedusaOrderId: Text;
        MedusaOrderIdPrefixLbl: Label 'ord-many-', Locked = true;
        FillerCharLbl: Label '-', Locked = true;
    begin
        MedusaOrderId := MedusaOrderIdPrefixLbl + Format(OrderIndex);
        _Assert.IsTrue(StrLen(MedusaOrderId) <= MedusaOrderIdLength,
            'Setup: the requested Medusa order id length must fit the distinct part of the generated id.');
        exit(PadStr(MedusaOrderId, MedusaOrderIdLength, FillerCharLbl));
    end;

    /// <summary>
    /// One order carrying the identity, billing address, shipping address and shipment method properties the
    /// importer maps onto the Ecom Sales Header. Every shipping value differs from its billing counterpart,
    /// so a mapping that reads one where it should read the other is detectable. The expected values are
    /// exposed by the Expected* accessors below.
    /// </summary>
    procedure BuildOrderArrayWithAddresses(var OrdersArr: JsonArray; DocumentNo: Code[20]; MedusaOrderId: Text; CreatedAt: DateTime; ItemTotal: Decimal)
    var
        OrderTkn: JsonToken;
        OrderObj: JsonObject;
        BillingAddressObj: JsonObject;
        ShippingAddressObj: JsonObject;
        ShippingMethodsArr: JsonArray;
        ShippingMethodObj: JsonObject;
    begin
        BuildOrderArrayWithNoPaymentLines(OrdersArr, DocumentNo, MedusaOrderId, CreatedAt, CreatedAt, ItemTotal);
        OrdersArr.Get(0, OrderTkn);
        OrderObj := OrderTkn.AsObject();

        BillingAddressObj.Add('first_name', ExpectedBillingFirstName());
        BillingAddressObj.Add('last_name', ExpectedBillingLastName());
        BillingAddressObj.Add('address_1', ExpectedBillingAddress1());
        BillingAddressObj.Add('address_2', ExpectedBillingAddress2());
        BillingAddressObj.Add('city', ExpectedBillingCity());
        BillingAddressObj.Add('postal_code', ExpectedBillingPostCode());
        BillingAddressObj.Add('province', ExpectedBillingProvince());
        BillingAddressObj.Add('country_code', ExpectedBillingCountryCode());
        BillingAddressObj.Add('company', ExpectedBillingCompany());
        BillingAddressObj.Add('phone', ExpectedBillingPhoneNo());

        ShippingAddressObj.Add('first_name', ExpectedShippingFirstName());
        ShippingAddressObj.Add('last_name', ExpectedShippingLastName());
        ShippingAddressObj.Add('address_1', ExpectedShippingAddress1());
        ShippingAddressObj.Add('address_2', ExpectedShippingAddress2());
        ShippingAddressObj.Add('city', ExpectedShippingCity());
        ShippingAddressObj.Add('postal_code', ExpectedShippingPostCode());
        ShippingAddressObj.Add('province', ExpectedShippingProvince());
        ShippingAddressObj.Add('country_code', ExpectedShippingCountryCode());
        ShippingAddressObj.Add('company', ExpectedShippingCompany());

        // Read as "shipping_methods[0].name": only the array's first element is mapped.
        ShippingMethodObj.Add('name', ExpectedShipmentMethodName());
        ShippingMethodsArr.Add(ShippingMethodObj);

        OrderObj.Add('email', ExpectedEmail());
        OrderObj.Add('billing_address', BillingAddressObj);
        OrderObj.Add('shipping_address', ShippingAddressObj);
        OrderObj.Add('shipping_methods', ShippingMethodsArr);

        Clear(OrdersArr);
        OrdersArr.Add(OrderObj);
    end;

    procedure ExpectedEmail(): Text
    var
        EmailLbl: Label 'billing@entria.test', Locked = true;
    begin
        exit(EmailLbl);
    end;

    procedure ExpectedBillingFirstName(): Text
    var
        FirstNameLbl: Label 'Bill', Locked = true;
    begin
        exit(FirstNameLbl);
    end;

    procedure ExpectedBillingLastName(): Text
    var
        LastNameLbl: Label 'Billing', Locked = true;
    begin
        exit(LastNameLbl);
    end;

    /// <summary>The full name the importer composes out of the billing first and last name.</summary>
    procedure ExpectedSellToName(): Text
    begin
        exit(ExpectedBillingFirstName() + ' ' + ExpectedBillingLastName());
    end;

    procedure ExpectedBillingAddress1(): Text
    var
        Address1Lbl: Label 'Billing Street 1', Locked = true;
    begin
        exit(Address1Lbl);
    end;

    procedure ExpectedBillingAddress2(): Text
    var
        Address2Lbl: Label 'Billing Suite 11', Locked = true;
    begin
        exit(Address2Lbl);
    end;

    procedure ExpectedBillingCity(): Text
    var
        CityLbl: Label 'Billingtown', Locked = true;
    begin
        exit(CityLbl);
    end;

    procedure ExpectedBillingProvince(): Text
    var
        ProvinceLbl: Label 'Billing County', Locked = true;
    begin
        exit(ProvinceLbl);
    end;

    procedure ExpectedBillingCompany(): Text
    var
        CompanyLbl: Label 'Billing Company A/S', Locked = true;
    begin
        exit(CompanyLbl);
    end;

    procedure ExpectedBillingPostCode(): Text
    var
        PostCodeLbl: Label '1111', Locked = true;
    begin
        exit(PostCodeLbl);
    end;

    procedure ExpectedBillingCountryCode(): Text
    var
        CountryCodeLbl: Label 'DK', Locked = true;
    begin
        exit(CountryCodeLbl);
    end;

    procedure ExpectedBillingPhoneNo(): Text
    var
        PhoneNoLbl: Label '11111111', Locked = true;
    begin
        exit(PhoneNoLbl);
    end;

    procedure ExpectedShippingFirstName(): Text
    var
        FirstNameLbl: Label 'Ship', Locked = true;
    begin
        exit(FirstNameLbl);
    end;

    procedure ExpectedShippingLastName(): Text
    var
        LastNameLbl: Label 'Shipping', Locked = true;
    begin
        exit(LastNameLbl);
    end;

    /// <summary>The full name the importer composes out of the shipping first and last name.</summary>
    procedure ExpectedShipToName(): Text
    begin
        exit(ExpectedShippingFirstName() + ' ' + ExpectedShippingLastName());
    end;

    procedure ExpectedShippingAddress1(): Text
    var
        Address1Lbl: Label 'Shipping Street 2', Locked = true;
    begin
        exit(Address1Lbl);
    end;

    procedure ExpectedShippingAddress2(): Text
    var
        Address2Lbl: Label 'Shipping Suite 22', Locked = true;
    begin
        exit(Address2Lbl);
    end;

    procedure ExpectedShippingCity(): Text
    var
        CityLbl: Label 'Shippingtown', Locked = true;
    begin
        exit(CityLbl);
    end;

    procedure ExpectedShippingProvince(): Text
    var
        ProvinceLbl: Label 'Shipping County', Locked = true;
    begin
        exit(ProvinceLbl);
    end;

    procedure ExpectedShippingCompany(): Text
    var
        CompanyLbl: Label 'Shipping Company AB', Locked = true;
    begin
        exit(CompanyLbl);
    end;

    procedure ExpectedShippingPostCode(): Text
    var
        PostCodeLbl: Label '2222', Locked = true;
    begin
        exit(PostCodeLbl);
    end;

    procedure ExpectedShippingCountryCode(): Text
    var
        CountryCodeLbl: Label 'SE', Locked = true;
    begin
        exit(CountryCodeLbl);
    end;

    procedure ExpectedShipmentMethodName(): Text
    var
        ShipmentMethodNameLbl: Label 'STD', Locked = true;
    begin
        exit(ShipmentMethodNameLbl);
    end;

    #endregion

    #region Entria setup fixtures

    /// <summary>Ensures the integration setup record exists and leaves the integration switched on.</summary>
    procedure EnsureSetupExists()
    begin
        SetEnableIntegration(true);
    end;

    /// <summary>
    /// Flips the integration-level switch by direct assignment, creating the setup record if the tenant has
    /// none. Direct assignment rather than Validate because the two are equivalent here: the whole
    /// "Enable Integration" OnValidate body sits behind CurrFieldNo = FieldNo("Enable Integration"), and
    /// CurrFieldNo is 0 for a code-driven Validate, so the trigger never runs from a test either way.
    /// </summary>
    procedure SetEnableIntegration(EnableIntegration: Boolean)
    var
        EntriaSetup: Record "NPR Entria Integration Setup";
        EntriaIntegrationMgt: Codeunit "NPR Entria Integration Mgt.";
    begin
        if not EntriaSetup.Get() then begin
            EntriaSetup.Init();
            EntriaSetup.Insert();
        end;
        EntriaSetup."Enable Integration" := EnableIntegration;
        EntriaSetup.Modify();

        EntriaIntegrationMgt.SetRereadSetup();
    end;

    /// <summary>Ensures the integration setup and the given store exist, and leaves the store Enabled.</summary>
    procedure EnableEntriaStore(StoreCode: Code[20])
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaIntegrationMgt: Codeunit "NPR Entria Integration Mgt.";
    begin
        EnsureSetupExists();
        if not EntriaStore.Get(StoreCode) then begin
            EntriaStore.Init();
            EntriaStore.Code := StoreCode;
            EntriaStore."Entria Url" := 'https://entria.test';
            EntriaStore.Insert();
        end;
        EntriaStore.Enabled := true;
        EntriaStore."Sales Order Integration" := true;
        EntriaStore.Modify();

        EntriaIntegrationMgt.SetRereadSetup();
    end;

    /// <summary>
    /// Creates the given store if it is missing and sets exactly the two flags that decide the sales order
    /// integration master switch, so a caller can express any of its four states. Direct assignment is needed
    /// here, unlike on the setup record: EntriaStore.Enabled's OnValidate calls SetupJobQueues() unconditionally,
    /// outside any CurrFieldNo guard, so validating it would run the production job setup path outside the
    /// BindSubscription bracket that keeps the platform scheduler out.
    /// </summary>
    procedure SetStore(StoreCode: Code[20]; StoreEnabled: Boolean; SalesOrderIntegration: Boolean)
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaIntegrationMgt: Codeunit "NPR Entria Integration Mgt.";
    begin
        if not EntriaStore.Get(StoreCode) then begin
            EntriaStore.Init();
            EntriaStore.Code := StoreCode;
            EntriaStore.Insert();
        end;
        //A reserved-TLD URL and no API key at all, on purpose: if the importer ever did get scheduled despite
        //the hold subscriber, GetAPIKey() fails on the null token before a socket is opened, so a mistake here
        //cannot reach a live Entria backend.
        EntriaStore."Entria Url" := 'https://entria.invalid';
        EntriaStore.Enabled := StoreEnabled;
        EntriaStore."Sales Order Integration" := SalesOrderIntegration;
        EntriaStore.Modify();

        EntriaIntegrationMgt.SetRereadSetup();
    end;

    /// <summary>
    /// Inserts a store carrying only the url the integration needs, leaving it disabled and without an
    /// import starting point - the state the Enabled OnValidate path is exercised from.
    /// </summary>
    procedure CreateEntriaStoreWithUrl(var EntriaStore: Record "NPR Entria Store"; StoreCode: Code[20])
    var
        EntriaIntegrationMgt: Codeunit "NPR Entria Integration Mgt.";
    begin
        EntriaStore.Init();
        EntriaStore.Code := StoreCode;
        EntriaStore."Entria Url" := 'https://entria.test';
        EntriaStore.Insert();

        EntriaIntegrationMgt.SetRereadSetup();
    end;

    /// <summary>Clears Enabled on every Entria store by direct assignment, so no OnValidate side effect runs.</summary>
    procedure DisableAllStores()
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaIntegrationMgt: Codeunit "NPR Entria Integration Mgt.";
    begin
        if EntriaStore.FindSet() then
            repeat
                EntriaStore.Enabled := false;
                EntriaStore.Modify();
            until EntriaStore.Next() = 0;

        EntriaIntegrationMgt.SetRereadSetup();
    end;

    /// <summary>
    /// Switches off every enabled Entria store except the one the caller owns, so the caller's own fixture
    /// decides the sales-order-integration master switch rather than whatever else exists on the tenant.
    /// </summary>
    procedure DisableStoresExcept(KeepStoreCode: Code[20])
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaIntegrationMgt: Codeunit "NPR Entria Integration Mgt.";
    begin
        EntriaStore.SetFilter(Code, '<>%1', KeepStoreCode);
        EntriaStore.SetRange(Enabled, true);
        if EntriaStore.FindSet() then
            repeat
                EntriaStore.Enabled := false;
                EntriaStore.Modify();
            until EntriaStore.Next() = 0;

        EntriaIntegrationMgt.SetRereadSetup();
    end;

    /// <summary>
    /// Runs the production job queue setup with the hold subscriber bound for the duration of the call.
    /// </summary>
    /// <remarks>
    /// The entry is left On Hold, so IsJobQueueReadyToRun() is false afterwards and no platform task is created.
    /// </remarks>
    procedure RunSetupJobQueues()
    var
        EntriaIntegrationMgt: Codeunit "NPR Entria Integration Mgt.";
        LibraryEntria: Codeunit "NPR Library - Entria";
    begin
        BindSubscription(LibraryEntria);
        EntriaIntegrationMgt.SetupJobQueues();
        UnbindSubscription(LibraryEntria);
    end;

    /// <summary>
    /// Deletes the given Entria store with the hold subscriber bound for the duration of the delete, so the job
    /// queue setup that the OnDelete trigger reaches cannot get to the platform scheduler.
    /// </summary>
    /// <remarks>
    /// Binds a local instance rather than a caller-held global, exactly as RunSetupJobQueues does. Per the
    /// BindSubscription documentation a manually bound instance is unbound when its variable goes out of scope, so
    /// an error inside the bracket cannot leave the subscriber bound; a caller-held global has no such guarantee.
    /// </remarks>
    procedure DeleteStore(StoreCode: Code[20])
    var
        EntriaStore: Record "NPR Entria Store";
        LibraryEntria: Codeunit "NPR Library - Entria";
    begin
        EntriaStore.Get(StoreCode);
        BindSubscription(LibraryEntria);
        EntriaStore.Delete(true);
        UnbindSubscription(LibraryEntria);
    end;

    /// <summary>
    /// Deletes every Entria store matching the given Code filter with the hold subscriber bound, for callers that
    /// tear down a set of stores rather than one.
    /// </summary>
    procedure DeleteStores(StoreCodeFilter: Text)
    var
        EntriaStore: Record "NPR Entria Store";
        LibraryEntria: Codeunit "NPR Library - Entria";
    begin
        EntriaStore.SetFilter(Code, StoreCodeFilter);
        if EntriaStore.IsEmpty() then
            exit;
        BindSubscription(LibraryEntria);
        EntriaStore.DeleteAll(true);
        UnbindSubscription(LibraryEntria);
    end;

    /// <summary>
    /// Writes "Enable Integration" WITHOUT invalidating the single-instance setup cache, so a caller can put the
    /// session in the state a cross-session write leaves it in.
    /// </summary>
    /// <remarks>
    /// The deliberate opposite of SetEnableIntegration. "NPR Entria Integration Mgt." is SingleInstance and
    /// ReadySetup() reads the setup through GetRecordOnce, so production code that does not call SetRereadSetup()
    /// first will read whatever this session cached earlier. Every other setter here invalidates the cache, which
    /// is precisely why they cannot be used to test that production invalidates it.
    /// </remarks>
    procedure SetEnableIntegrationLeavingCacheStale(EnableIntegration: Boolean)
    var
        EntriaSetup: Record "NPR Entria Integration Setup";
    begin
        if not EntriaSetup.Get() then begin
            EntriaSetup.Init();
            EntriaSetup.Insert();
        end;
        EntriaSetup."Enable Integration" := EnableIntegration;
        EntriaSetup.Modify();
    end;

    /// <summary>Creates an item with the given Unit Price and "NPR Entria Product" flag.</summary>
    procedure CreateItem(var Item: Record Item; UnitPrice: Decimal; EntriaProduct: Boolean)
    begin
        _LibraryInventory.CreateItem(Item);
        Item.Validate("Unit Price", UnitPrice);
        Item."NPR Entria Product" := EntriaProduct;
        Item.Modify(true);
    end;

    /// <summary>
    /// Returns the General Ledger Setup "LCY Code" the importer compares the payload's currency_code
    /// against, setting a deterministic one first if the test database carries none - with a blank
    /// LCY Code the LCY case would pass on the empty-currency_code guard instead of the comparison.
    /// </summary>
    procedure EnsureLcyCode(): Code[10]
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        FallbackLcyCodeLbl: Label 'ZZLCY', Locked = true;
    begin
        GeneralLedgerSetup.Get();
        if GeneralLedgerSetup."LCY Code" = '' then begin
            GeneralLedgerSetup."LCY Code" := FallbackLcyCodeLbl;
            GeneralLedgerSetup.Modify();
        end;
        exit(GeneralLedgerSetup."LCY Code");
    end;

    /// <summary>
    /// Returns a voucher carrying the given reference no., issuing it if none carries it yet: nothing is
    /// undone between tests - the rollback comes at the codeunit boundary - so a voucher issued earlier in
    /// this codeunit's run is still there, and its reference no. cannot be issued a second time.
    /// </summary>
    procedure EnsureIssuedVoucher(VoucherReferenceNo: Text[50]; VoucherAmount: Decimal; var Voucher: Record "NPR NpRv Voucher")
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        VoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        PartialPaymentModuleLbl: Label 'PARTIAL', Locked = true;
    begin
        _LibraryPOSMasterData.CreateDefaultVoucherType(VoucherType, false);
        VoucherType."Apply Payment Module" := PartialPaymentModuleLbl;
        VoucherType.Modify();

        // Same lookup the importer resolves a voucher code with: reference no. only, last one wins.
        Voucher.SetRange("Reference No.", VoucherReferenceNo);
        if not Voucher.FindLast() then begin
            VoucherMgt.IssueVoucher(VoucherType.Code, VoucherReferenceNo, VoucherAmount);
            Voucher.FindLast();
        end;
    end;

    /// <summary>
    /// The Entria api handler refuses to send at all unless the NP Retail extension is allowed to make
    /// HttpClient requests, and that guard is what makes every refetch in the suite fail deterministically.
    /// A scenario that needs a live refetch switches it on; Initialize() switches it back off, because the
    /// production code commits and the enabling write therefore outlives the test that made it.
    /// </summary>
    procedure SetHttpClientRequestsAllowed(Allowed: Boolean)
    var
        NAVAppSetting: Record "NAV App Setting";
        NPRetailAppId: Guid;
    begin
        Evaluate(NPRetailAppId, '992c2309-cca4-43cb-9e41-911f482ec088');
        if not NAVAppSetting.Get(NPRetailAppId) then begin
            if not Allowed then
                exit;
            NAVAppSetting.Init();
            NAVAppSetting."App ID" := NPRetailAppId;
            NAVAppSetting.Insert();
        end;
        if NAVAppSetting."Allow HttpClient Requests" = Allowed then
            exit;
        NAVAppSetting."Allow HttpClient Requests" := Allowed;
        NAVAppSetting.Modify();
    end;

    /// <summary>
    /// Drops a store's api key from isolated storage, which the request builder reads and which no
    /// per-test rollback removes once the production code has committed.
    /// </summary>
    procedure ClearStoreAPIKey(StoreCode: Code[20])
    var
        EntriaStore: Record "NPR Entria Store";
    begin
        if not EntriaStore.Get(StoreCode) then
            exit;
        if not EntriaStore.HasAPIKey() then
            exit;

        EntriaStore.DeleteAPIKey();
        Clear(EntriaStore."Entria API Key Token");
        EntriaStore.Modify();
    end;

    /// <summary>Gives a store the api key the request builder needs before it can send anything.</summary>
    procedure EnsureStoreAPIKey(StoreCode: Code[20])
    var
        EntriaStore: Record "NPR Entria Store";
    begin
        EntriaStore.Get(StoreCode);
        if EntriaStore.HasAPIKey() then
            exit;

        EntriaStore.SetAPIKey('entria-test-api-key');
        EntriaStore.Modify();
    end;

    #endregion

    #region Order import failure registry fixtures

    /// <summary>
    /// Inserts a registry row directly, so a single retry-eligibility condition can be varied on its own
    /// - going through UpsertOrderFailure would always produce the two parked conditions together.
    /// </summary>
    procedure InsertOrderFailureRow(StoreCode: Code[20]; MedusaOrderId: Text[100]; RetryCount: Integer; NextRetryAt: DateTime)
    begin
        InsertOrderFailureRowWithStatus(StoreCode, MedusaOrderId, RetryCount, NextRetryAt, Enum::"NPR Entria Order Imp. Status"::Pending);
    end;
    procedure InsertOrderFailureRowWithStatus(StoreCode: Code[20]; MedusaOrderId: Text[100]; RetryCount: Integer; NextRetryAt: DateTime; Status: Enum "NPR Entria Order Imp. Status")
    begin
        InsertOrderFailureRowWithTimestamp(StoreCode, MedusaOrderId, RetryCount, NextRetryAt, Status, 0DT);
    end;

    /// <summary>
    /// As InsertOrderFailureRowWithStatus, plus the row's stored "Order Updated At" - the baseline the
    /// freshness check judges a refetched payload against. Seeded here rather than by the caller so a
    /// scenario does not have to insert, re-read and modify the row to place one field.
    /// </summary>
    procedure InsertOrderFailureRowWithTimestamp(StoreCode: Code[20]; MedusaOrderId: Text[100]; RetryCount: Integer; NextRetryAt: DateTime; Status: Enum "NPR Entria Order Imp. Status"; OrderUpdatedAt: DateTime)
    var
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
    begin
        EntriaOrderImpFailure.Init();
        EntriaOrderImpFailure."Store Code" := StoreCode;
        EntriaOrderImpFailure."Order Id" := MedusaOrderId;
        EntriaOrderImpFailure."Retry Count" := RetryCount;
        EntriaOrderImpFailure."Next Retry At" := NextRetryAt;
        EntriaOrderImpFailure.Status := Status;
        EntriaOrderImpFailure."Order Updated At" := OrderUpdatedAt;
        EntriaOrderImpFailure.Insert();
    end;

    /// <summary>
    /// Burns a registry row's whole retry budget so it ends up PARKED: the first failure creates the
    /// row at Retry Count 0 and each further one counts a failed retry, so the last of them brings
    /// Retry Count to MaxRetries() and SetFailureFields writes the 0DT sentinel into "Next Retry At".
    /// Because that last write always lands the 0DT sentinel, how far in the past the intermediate
    /// "Next Retry At" values were scheduled makes no difference to the parked end state.
    /// </summary>
    procedure ParkOrderAtMaxRetries(StoreCode: Code[20]; DocumentNo: Code[20]; MedusaOrderId: Text[100]; OrderUpdatedAt: DateTime)
    var
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        i: Integer;
    begin
        for i := 1 to EntriaJQ.MaxRetries() + 1 do
            EntriaJQ.UpsertOrderFailure(StoreCode, DocumentNo, MedusaOrderId, OrderUpdatedAt, 'boom', 0, CurrentDateTime() - 60000);

        EntriaOrderImpFailure.Get(StoreCode, MedusaOrderId);
        _Assert.AreEqual(EntriaJQ.MaxRetries(), EntriaOrderImpFailure."Retry Count", 'Setup: row must be parked at MaxRetries().');
        // All three markers of the parked state are asserted together on purpose: every caller of this
        // fixture builds on all three, and a row whose Status and retry budget ever disagreed would let
        // those tests pass while the production row was in a state the retry pass reads differently.
        _Assert.AreEqual(EntriaOrderImpFailure.Status::Error, EntriaOrderImpFailure.Status, 'Setup: a row parked at MaxRetries() must read as Error, or it stays invisible in the Error cue tile.');
        _Assert.AreEqual(0DT, EntriaOrderImpFailure."Next Retry At", 'Setup: a parked row must carry the 0DT sentinel, or it is still scheduled for an automatic retry it has no budget for.');
    end;

    /// <summary>
    /// Runs the same "Skip" a human triggers from the failures list page, through the production
    /// procedure the page action calls - the page only adds the Modify, which is done here too.
    /// </summary>
    procedure SkipOrder(StoreCode: Code[20]; MedusaOrderId: Text[100])
    var
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
    begin
        EntriaOrderImpFailure.Get(StoreCode, MedusaOrderId);
        EntriaJQ.SkipOrder(EntriaOrderImpFailure);
        EntriaOrderImpFailure.Modify();
    end;

    #endregion

    #region Ecom document fixtures

    /// <summary>Inserts a bare Ecom order header, standing in for a document the importer already imported.</summary>
    procedure CreateEcomOrderHeader(StoreCode: Code[20]; ExternalNo: Code[20])
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
    begin
        CreateEcomDocumentHeader(StoreCode, ExternalNo, EcomSalesHeader."Document Type"::Order);
    end;

    /// <summary>
    /// Inserts a bare Ecom document header of the given document type, so a document of another type - or one
    /// under another store - can stand in for something the duplicate guard should or should not match.
    /// </summary>
    procedure CreateEcomDocumentHeader(StoreCode: Code[20]; ExternalNo: Code[20]; DocumentType: Enum "NPR Ecom Sales Doc Type")
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
    begin
        EcomSalesHeader.Init();
        EcomSalesHeader."Document Type" := DocumentType;
        EcomSalesHeader."Ecommerce Store Code" := StoreCode;
        EcomSalesHeader."External No." := ExternalNo;
        EcomSalesHeader.Insert();
    end;

    #endregion

    #region Order import job queue fixtures

    procedure ClearOrderImportJobQueueState()
    var
        JobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
    begin
        //Monitored rows first, so their OnDelete cascade removes the companion Managed-By-App rows while the
        //job queue entry IDs they reference are still resolvable. Scoped by object identity rather than by a
        //parameter-string prefix, because the Entria job's Parameter String is empty.
        FilterOrderImportMonitoredRows(MonitoredJQEntry);
        if not MonitoredJQEntry.IsEmpty() then
            MonitoredJQEntry.DeleteAll(true);

        FilterOrderImportJobs(JobQueueEntry);
        while JobQueueEntry.FindFirst() do begin
            //An In Process entry cannot be deleted, and a dev tenant may well have one running.
            JobQueueEntry.SetStatus(JobQueueEntry.Status::"On Hold");
            JobQueueEntry.Delete(true);
        end;
    end;

    /// <summary>
    /// Inserts the legacy shape of the order import job: NP-protected, recurring, no monitored row.
    /// Manually Set On Hold keeps the platform scheduler away from it before the hold subscriber is even bound.
    /// </summary>
    procedure CreateLegacyProtectedJob(var JobQueueEntry: Record "Job Queue Entry")
    var
        EntriaOrderImportJQ: Codeunit "NPR Entria Order Import JQ";
    begin
        JobQueueEntry.Init();
        JobQueueEntry.ID := CreateGuid();
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := EntriaOrderImportJQ.GetCodeunitId();
        JobQueueEntry.Description := CopyStr(EntriaOrderImportJQ.GetJQDescription(), 1, MaxStrLen(JobQueueEntry.Description));
        JobQueueEntry."Recurring Job" := true;
        JobQueueEntry."No. of Minutes between Runs" := 1;
        JobQueueEntry.Status := JobQueueEntry.Status::"On Hold";
        JobQueueEntry."NPR NP Protected Job" := true;
        JobQueueEntry."NPR Manually Set On Hold" := true;
        JobQueueEntry.Insert(true);
    end;

    /// <summary>
    /// Builds an uninserted job queue entry for the given codeunit. Deliberately not inserted: the refresher-gate
    /// predicate only inspects the record it is handed.
    /// </summary>
    procedure BuildJobQueueEntryFor(CodeunitId: Integer; var JobQueueEntry: Record "Job Queue Entry")
    begin
        Clear(JobQueueEntry);
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := CodeunitId;
    end;

    /// <summary>
    /// Builds an uninserted job queue entry whose "Object Type to Run" is Report rather than Codeunit, so a caller
    /// can exercise the object-type half of a subscriber guard independently of the object-id half.
    /// </summary>
    procedure BuildReportJobQueueEntryFor(ObjectIdToRun: Integer; var JobQueueEntry: Record "Job Queue Entry")
    begin
        Clear(JobQueueEntry);
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Report;
        JobQueueEntry."Object ID to Run" := ObjectIdToRun;
    end;

    /// <summary>
    /// Deletes a job queue entry the way support does when a job is stuck, leaving its monitored row orphaned.
    /// </summary>
    procedure DeleteJobQueueEntry(var JobQueueEntry: Record "Job Queue Entry")
    begin
        JobQueueEntry.SetStatus(JobQueueEntry.Status::"On Hold");
        JobQueueEntry.Delete(true);
    end;

    procedure FilterOrderImportJobs(var JobQueueEntry: Record "Job Queue Entry")
    var
        EntriaOrderImportJQ: Codeunit "NPR Entria Order Import JQ";
    begin
        JobQueueEntry.Reset();
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", EntriaOrderImportJQ.GetCodeunitId());
    end;

    procedure FilterOrderImportMonitoredRows(var MonitoredJQEntry: Record "NPR Monitored Job Queue Entry")
    var
        EntriaOrderImportJQ: Codeunit "NPR Entria Order Import JQ";
    begin
        MonitoredJQEntry.Reset();
        MonitoredJQEntry.SetRange("Object Type to Run", MonitoredJQEntry."Object Type to Run"::Codeunit);
        MonitoredJQEntry.SetRange("Object ID to Run", EntriaOrderImportJQ.GetCodeunitId());
    end;

    procedure CountOrderImportJobs(): Integer
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        FilterOrderImportJobs(JobQueueEntry);
        exit(JobQueueEntry.Count());
    end;

    procedure CountOrderImportMonitoredRows(): Integer
    var
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
    begin
        FilterOrderImportMonitoredRows(MonitoredJQEntry);
        exit(MonitoredJQEntry.Count());
    end;

    procedure FindOrderImportJob(var JobQueueEntry: Record "Job Queue Entry"): Boolean
    begin
        FilterOrderImportJobs(JobQueueEntry);
        exit(JobQueueEntry.FindFirst());
    end;

    procedure FindOrderImportMonitoredRow(var MonitoredJQEntry: Record "NPR Monitored Job Queue Entry"): Boolean
    begin
        FilterOrderImportMonitoredRows(MonitoredJQEntry);
        exit(MonitoredJQEntry.FindFirst());
    end;

    #endregion
}
#endif
