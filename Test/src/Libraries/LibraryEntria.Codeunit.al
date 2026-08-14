#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 85379 "NPR Library - Entria"
{
    // Test fixtures for the Entria order import: builds the Medusa order payloads the import path
    // reads (list page arrays in their various payment shapes) and seeds the minimal Entria setup
    // and store records the job needs. Kept out of the test codeunit so several test codeunits can
    // share the same payload shapes.
    //
    // The Entria objects only exist from BC23 up, hence the version guard on the whole codeunit.

    var
        _Assert: Codeunit Assert;
        _LibraryInventory: Codeunit "Library - Inventory";
        _LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";

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
        OrderObj.Add('payment_status', 'captured');
        OrderObj.Add('currency_code', '');
        OrderObj.Add('items', ItemsArr);

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

    #endregion

    #region Entria setup fixtures

    procedure EnsureSetupExists()
    var
        EntriaSetup: Record "NPR Entria Integration Setup";
    begin
        if not EntriaSetup.Get() then begin
            EntriaSetup.Init();
            EntriaSetup.Insert();
        end;
        EntriaSetup."Enable Integration" := true;
        EntriaSetup.Modify();
    end;

    /// <summary>
    /// Flips the integration-level switch by direct assignment. Not Validate: the "Enable Integration"
    /// OnValidate calls SetupJobQueues(), which would create real job queue entries in the test database.
    /// </summary>
    procedure SetEnableIntegration(EnableIntegration: Boolean)
    var
        EntriaSetup: Record "NPR Entria Integration Setup";
    begin
        EntriaSetup.Get();
        EntriaSetup."Enable Integration" := EnableIntegration;
        EntriaSetup.Modify();
    end;

    /// <summary>Ensures the integration setup and the given store exist, and leaves the store Enabled.</summary>
    procedure EnableEntriaStore(StoreCode: Code[20])
    var
        EntriaStore: Record "NPR Entria Store";
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
    end;

    /// <summary>
    /// Inserts a store carrying only the url the integration needs, leaving it disabled and without an
    /// import starting point - the state the Enabled OnValidate path is exercised from.
    /// </summary>
    procedure CreateEntriaStoreWithUrl(var EntriaStore: Record "NPR Entria Store"; StoreCode: Code[20])
    begin
        EntriaStore.Init();
        EntriaStore.Code := StoreCode;
        EntriaStore."Entria Url" := 'https://entria.test';
        EntriaStore.Insert();
    end;

    /// <summary>Clears Enabled on every Entria store by direct assignment, so no OnValidate side effect runs.</summary>
    procedure DisableAllStores()
    var
        EntriaStore: Record "NPR Entria Store";
    begin
        if EntriaStore.FindSet() then
            repeat
                EntriaStore.Enabled := false;
                EntriaStore.Modify();
            until EntriaStore.Next() = 0;
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
    /// Returns an active voucher carrying the given reference no., issuing it if the test database has none
    /// yet: the import commits, so a voucher issued by an earlier run of the same test survives and its
    /// reference no. cannot be issued a second time.
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

    #endregion

    #region Order import failure registry fixtures

    /// <summary>
    /// Inserts a registry row directly, so a single retry-eligibility condition can be varied on its own
    /// - going through UpsertOrderFailure would always produce the two parked conditions together.
    /// </summary>
    procedure InsertOrderFailureRow(StoreCode: Code[20]; MedusaOrderId: Text[100]; RetryCount: Integer; NextRetryAt: DateTime)
    var
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
    begin
        EntriaOrderImpFailure.Init();
        EntriaOrderImpFailure."Store Code" := StoreCode;
        EntriaOrderImpFailure."Order Id" := MedusaOrderId;
        EntriaOrderImpFailure."Retry Count" := RetryCount;
        EntriaOrderImpFailure."Next Retry At" := NextRetryAt;
        EntriaOrderImpFailure.Suppressed := false;
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
    end;

    #endregion

    #region Ecom document fixtures

    /// <summary>Inserts a bare Ecom order header, standing in for a document the importer already imported.</summary>
    procedure CreateEcomOrderHeader(StoreCode: Code[20]; ExternalNo: Code[20])
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
    begin
        EcomSalesHeader.Init();
        EcomSalesHeader."Document Type" := EcomSalesHeader."Document Type"::Order;
        EcomSalesHeader."Ecommerce Store Code" := StoreCode;
        EcomSalesHeader."External No." := ExternalNo;
        EcomSalesHeader.Insert();
    end;

    #endregion
}
#endif
