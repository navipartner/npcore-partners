#if not BC17
codeunit 85464 "NPR Spfy Gift Card Tests"
{
    // [FEATURE] Shopify Retail Vouchers
    // Tests for "NPR Spfy Send Voucher" driven end-to-end against the reusable mock GraphQL client:
    // which customer Shopify will deliver the gift card to, and when a second recipient is attached.
    // Assertions read the named field out of the GiftCardCreateInput rather than searching the whole
    // request text, so a request that put the right id under the wrong key cannot pass.
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _LibrarySpfyVoucher: Codeunit "NPR Library - Spfy Voucher";
        _Assert: Codeunit "Assert";
        _StoreCodeLbl: Label 'SPFYVCH', Locked = true;
        _VoucherTypeLbl: Label 'SPFYGIFT', Locked = true;

    [Test]
    procedure NoRecipientEmail_DeliversToTheBuyerThroughCustomerId()
    var
        Customer: Record Customer;
        NcTask: Record "NPR Nc Task";
        Voucher: Record "NPR NpRv Voucher";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendVoucher: Codeunit "NPR Spfy Send Voucher";
        SendRequest: Text;
    begin
        // [SCENARIO] A gift card bought without an alternative recipient is delivered to the buyer through customerId alone.
        Initialize();

        // [GIVEN] A voucher for a buyer who is already synced to Shopify, with no alternative recipient e-mail
        _LibrarySpfyVoucher.CreateCustomerWithStoreLink('SPFYC10', _StoreCodeLbl, 'buyer@npretail.test', 'Elke Viehfeger', '555', Customer);
        _LibrarySpfyVoucher.CreateVoucher('SPFYV10', _VoucherTypeLbl, 'SPFYVCHR0010', 100, Voucher);
        _LibrarySpfyVoucher.SetVoucherBuyer(Voucher, Customer."No.", 'buyer@npretail.test', 'Elke Viehfeger');
        _LibrarySpfyVoucher.CreateVoucherNcTask(_StoreCodeLbl, Voucher, NcTask);
        MockClient.AddResponse('giftCardCreate', _LibrarySpfyVoucher.ResponseGiftCardCreated('9001'));

        // [WHEN] The voucher sender runs against the mocked Shopify
        SendVoucher.SetGraphQLClient(MockClient);
        SendVoucher.Run(NcTask);

        // [THEN] The buyer is on the gift card as the customer, which is who Shopify notifies
        SendRequest := MockClient.GetRequestContaining('giftCardCreate');
        _Assert.AreEqual(
            _LibrarySpfyVoucher.CustomerGID('555'), _LibrarySpfyVoucher.GiftCardInputValue(SendRequest, 'customerId'),
            'The buyer must be the customer on the gift card, since that is who Shopify delivers it to.');

        // [THEN] No separate recipient is attached, which would notify the same person a second time
        _Assert.IsFalse(
            _LibrarySpfyVoucher.GiftCardInputHasField(SendRequest, 'recipientAttributes'),
            'With no alternative address the buyer is already the customer, so no second recipient may be attached.');
    end;

    [Test]
    procedure SyncedBuyer_UsesStoreCustomerLinkIdWithoutQueryingShopify()
    var
        Customer: Record Customer;
        NcTask: Record "NPR Nc Task";
        Voucher: Record "NPR NpRv Voucher";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendVoucher: Codeunit "NPR Spfy Send Voucher";
    begin
        // [SCENARIO] The Shopify customer id assigned to the store-customer link is used as-is, without an e-mail search.
        Initialize();

        // [GIVEN] A buyer whose store-customer link already carries a Shopify customer id
        _LibrarySpfyVoucher.CreateCustomerWithStoreLink('SPFYC20', _StoreCodeLbl, 'synced@npretail.test', 'Synced Buyer', '10170906476873', Customer);
        _LibrarySpfyVoucher.CreateVoucher('SPFYV20', _VoucherTypeLbl, 'SPFYVCHR0020', 100, Voucher);
        _LibrarySpfyVoucher.SetVoucherBuyer(Voucher, Customer."No.", 'synced@npretail.test', 'Synced Buyer');
        _LibrarySpfyVoucher.CreateVoucherNcTask(_StoreCodeLbl, Voucher, NcTask);
        MockClient.AddResponse('giftCardCreate', _LibrarySpfyVoucher.ResponseGiftCardCreated('9002'));

        // [WHEN] The voucher sender runs
        SendVoucher.SetGraphQLClient(MockClient);
        SendVoucher.Run(NcTask);

        // [THEN] Shopify was asked to create the gift card and nothing else: no customer lookup was needed
        _Assert.AreEqual(1, MockClient.RequestCount(), 'An already synced buyer must not trigger a customer search in Shopify.');
        _Assert.AreEqual(
            _LibrarySpfyVoucher.CustomerGID('10170906476873'),
            _LibrarySpfyVoucher.GiftCardInputValue(MockClient.GetRequestContaining('giftCardCreate'), 'customerId'),
            'The gift card must use the Shopify customer id assigned to the store-customer link.');
    end;

    [Test]
    procedure UnsyncedBuyer_ResolvesCustomerByEmail()
    var
        Customer: Record Customer;
        NcTask: Record "NPR Nc Task";
        Voucher: Record "NPR NpRv Voucher";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendVoucher: Codeunit "NPR Spfy Send Voucher";
        SendRequest: Text;
    begin
        // [SCENARIO] A buyer with no assigned Shopify id is looked up in Shopify by e-mail and becomes the gift card's customer.
        Initialize();

        // [GIVEN] A buyer whose store-customer link carries no Shopify customer id, but who exists in Shopify
        _LibrarySpfyVoucher.CreateCustomerWithStoreLink('SPFYC30', _StoreCodeLbl, 'unsynced@npretail.test', 'Unsynced Buyer', '', Customer);
        _LibrarySpfyVoucher.CreateVoucher('SPFYV30', _VoucherTypeLbl, 'SPFYVCHR0030', 100, Voucher);
        _LibrarySpfyVoucher.SetVoucherBuyer(Voucher, Customer."No.", 'unsynced@npretail.test', 'Unsynced Buyer');
        _LibrarySpfyVoucher.CreateVoucherNcTask(_StoreCodeLbl, Voucher, NcTask);
        MockClient.AddResponse('FindCustomerByEmail', _LibrarySpfyVoucher.ResponseCustomerSearchHit('777'));
        MockClient.AddResponse('giftCardCreate', _LibrarySpfyVoucher.ResponseGiftCardCreated('9003'));

        // [WHEN] The voucher sender runs
        SendVoucher.SetGraphQLClient(MockClient);
        SendVoucher.Run(NcTask);

        // [THEN] The customer found by e-mail is the one Shopify will deliver to
        _Assert.AreEqual(1, MockClient.CountRequestsContaining('FindCustomerByEmail'), 'The buyer must be looked up in Shopify by e-mail exactly once.');
        SendRequest := MockClient.GetRequestContaining('giftCardCreate');
        _Assert.AreEqual(
            _LibrarySpfyVoucher.CustomerGID('777'), _LibrarySpfyVoucher.GiftCardInputValue(SendRequest, 'customerId'),
            'The buyer found by e-mail must be the customer on the gift card.');
        _Assert.IsFalse(
            _LibrarySpfyVoucher.GiftCardInputHasField(SendRequest, 'recipientAttributes'),
            'The buyer is the customer, so no separate recipient may be attached.');
    end;

    [Test]
    procedure BuyerWithoutOwnEmail_FallsBackToVoucherEmail()
    var
        Customer: Record Customer;
        NcTask: Record "NPR Nc Task";
        Voucher: Record "NPR NpRv Voucher";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendVoucher: Codeunit "NPR Spfy Send Voucher";
    begin
        // [SCENARIO] When the BC customer holds no e-mail address, the one on the voucher is used to find them in Shopify.
        Initialize();

        // [GIVEN] A buyer with no e-mail on the customer card and no assigned Shopify id, whose voucher carries an e-mail
        _LibrarySpfyVoucher.CreateCustomerWithStoreLink('SPFYC70', _StoreCodeLbl, '', 'Emailless Buyer', '', Customer);
        _LibrarySpfyVoucher.CreateVoucher('SPFYV70', _VoucherTypeLbl, 'SPFYVCHR0070', 100, Voucher);
        _LibrarySpfyVoucher.SetVoucherBuyer(Voucher, Customer."No.", 'onvoucheronly@npretail.test', 'Emailless Buyer');
        _LibrarySpfyVoucher.CreateVoucherNcTask(_StoreCodeLbl, Voucher, NcTask);
        MockClient.AddResponse('onvoucheronly@npretail.test', _LibrarySpfyVoucher.ResponseCustomerSearchHit('711'));
        MockClient.AddResponse('giftCardCreate', _LibrarySpfyVoucher.ResponseGiftCardCreated('9007'));

        // [WHEN] The voucher sender runs
        SendVoucher.SetGraphQLClient(MockClient);
        SendVoucher.Run(NcTask);

        // [THEN] The voucher's own e-mail was the search key, and the customer it found is on the gift card
        _Assert.AreEqual(
            1, MockClient.CountRequestsContaining('onvoucheronly@npretail.test'),
            'The e-mail held on the voucher must be used to search Shopify when the customer card has none.');
        _Assert.AreEqual(
            _LibrarySpfyVoucher.CustomerGID('711'),
            _LibrarySpfyVoucher.GiftCardInputValue(MockClient.GetRequestContaining('giftCardCreate'), 'customerId'),
            'The customer found through the voucher e-mail must be associated with the gift card.');
    end;

    [Test]
    procedure PaddedCustomerEmail_IsTrimmedBeforeShopifyLookup()
    var
        Customer: Record Customer;
        NcTask: Record "NPR Nc Task";
        Voucher: Record "NPR NpRv Voucher";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendVoucher: Codeunit "NPR Spfy Send Voucher";
    begin
        // [SCENARIO] An address stored with padding is trimmed before Shopify is asked about it, so the padding cannot create a second customer.
        Initialize();

        // [GIVEN] A buyer with no assigned Shopify id whose store-customer link address carries leading and trailing spaces
        _LibrarySpfyVoucher.CreateCustomerWithStoreLink('SPFYC12', _StoreCodeLbl, '  padded@npretail.test  ', 'Padded Buyer', '', Customer);
        _LibrarySpfyVoucher.CreateVoucher('SPFYV12', _VoucherTypeLbl, 'SPFYVCHR0012', 100, Voucher);
        _LibrarySpfyVoucher.SetVoucherBuyer(Voucher, Customer."No.", '  padded@npretail.test  ', 'Padded Buyer');
        _LibrarySpfyVoucher.CreateVoucherNcTask(_StoreCodeLbl, Voucher, NcTask);
        MockClient.AddResponse('padded@npretail.test', _LibrarySpfyVoucher.ResponseCustomerSearchHit('1212'));
        MockClient.AddResponse('giftCardCreate', _LibrarySpfyVoucher.ResponseGiftCardCreated('9012'));

        // [WHEN] The voucher sender runs
        SendVoucher.SetGraphQLClient(MockClient);
        SendVoucher.Run(NcTask);

        // [THEN] Shopify was searched for the trimmed address, not the padded one
        _Assert.AreEqual(
            'email:padded@npretail.test',
            _LibrarySpfyVoucher.CustomerSearchCriteria(MockClient.GetRequestContaining('FindCustomerByEmail')),
            'The address must be trimmed before it is used to search Shopify.');
    end;

    [Test]
    procedure WhitespaceCustomerEmail_DoesNotBlockTheVoucherEmail()
    var
        Customer: Record Customer;
        NcTask: Record "NPR Nc Task";
        Voucher: Record "NPR NpRv Voucher";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendVoucher: Codeunit "NPR Spfy Send Voucher";
    begin
        // [SCENARIO] A stored address of only spaces counts as no address, so the one on the voucher is used instead.
        Initialize();

        // [GIVEN] A buyer whose stored e-mail is only spaces, on a voucher that carries a real address
        _LibrarySpfyVoucher.CreateCustomerWithStoreLink('SPFYC13', _StoreCodeLbl, '   ', 'Spacey Buyer', '', Customer);
        _LibrarySpfyVoucher.CreateVoucher('SPFYV13', _VoucherTypeLbl, 'SPFYVCHR0013', 100, Voucher);
        _LibrarySpfyVoucher.SetVoucherBuyer(Voucher, Customer."No.", 'onthevoucher@npretail.test', 'Spacey Buyer');
        _LibrarySpfyVoucher.CreateVoucherNcTask(_StoreCodeLbl, Voucher, NcTask);
        MockClient.AddResponse('onthevoucher@npretail.test', _LibrarySpfyVoucher.ResponseCustomerSearchHit('1313'));
        MockClient.AddResponse('giftCardCreate', _LibrarySpfyVoucher.ResponseGiftCardCreated('9013'));

        // [WHEN] The voucher sender runs
        SendVoucher.SetGraphQLClient(MockClient);
        SendVoucher.Run(NcTask);

        // [THEN] The voucher's address was the search key, and the customer it found is on the gift card
        _Assert.AreEqual(
            'email:onthevoucher@npretail.test',
            _LibrarySpfyVoucher.CustomerSearchCriteria(MockClient.GetRequestContaining('FindCustomerByEmail')),
            'An address of only spaces must not stop the voucher e-mail being used.');
        _Assert.AreEqual(
            _LibrarySpfyVoucher.CustomerGID('1313'),
            _LibrarySpfyVoucher.GiftCardInputValue(MockClient.GetRequestContaining('giftCardCreate'), 'customerId'),
            'The customer found through the voucher e-mail must be associated with the gift card.');
    end;

    [Test]
    procedure PaddedCardEmail_IsTrimmedWhenTheLinkIsWhitespace()
    var
        Customer: Record Customer;
        NcTask: Record "NPR Nc Task";
        Voucher: Record "NPR NpRv Voucher";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendVoucher: Codeunit "NPR Spfy Send Voucher";
    begin
        // [SCENARIO] An address taken from the customer card is trimmed before Shopify is asked about it, just as the link's own is.
        Initialize();

        // [GIVEN] A buyer whose customer card address carries padding, behind a link address of only spaces
        // A link address that is empty would simply be refilled from the card, padding and all, by
        // UpdateFromCustomer, so only a whitespace one it declines to overwrite reaches the card candidate.
        _LibrarySpfyVoucher.CreateCustomerWithStoreLink('SPFYC106', _StoreCodeLbl, '  oncard106@npretail.test  ', 'Carded Padded', '', Customer);
        _LibrarySpfyVoucher.SetStoreCustomerLinkEmail(Customer."No.", _StoreCodeLbl, '   ');

        // [GIVEN] A voucher for that buyer carrying no address of its own, so only the card can answer
        _LibrarySpfyVoucher.CreateVoucher('SPFYV106', _VoucherTypeLbl, 'SPFYVCHR0106', 100, Voucher);
        _LibrarySpfyVoucher.SetVoucherBuyer(Voucher, Customer."No.", '', 'Carded Padded');
        _LibrarySpfyVoucher.CreateVoucherNcTask(_StoreCodeLbl, Voucher, NcTask);
        MockClient.AddResponse('FindCustomerByEmail', _LibrarySpfyVoucher.ResponseCustomerSearchHit('776'));
        MockClient.AddResponse('giftCardCreate', _LibrarySpfyVoucher.ResponseGiftCardCreated('9013'));

        // [WHEN] The voucher sender runs
        SendVoucher.SetGraphQLClient(MockClient);
        SendVoucher.Run(NcTask);

        // [THEN] The padding is gone from the search key
        _Assert.AreEqual(
            'email:oncard106@npretail.test',
            _LibrarySpfyVoucher.CustomerSearchCriteria(MockClient.GetRequestContaining('FindCustomerByEmail')),
            'An address taken from the customer card must be trimmed before it becomes a search key.');
    end;

    [Test]
    procedure PaddedVoucherEmail_IsTrimmedBeforeShopifyLookup()
    var
        NcTask: Record "NPR Nc Task";
        Voucher: Record "NPR NpRv Voucher";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendVoucher: Codeunit "NPR Spfy Send Voucher";
    begin
        // [SCENARIO] The address carried on the voucher itself reaches Shopify without its padding.
        Initialize();

        // [GIVEN] A voucher with no customer at all, carrying a padded address of its own
        _LibrarySpfyVoucher.CreateVoucher('SPFYV107', _VoucherTypeLbl, 'SPFYVCHR0107', 100, Voucher);
        _LibrarySpfyVoucher.SetVoucherBuyer(Voucher, '', '  onvoucher107@npretail.test  ', 'Voucher Padded');
        _LibrarySpfyVoucher.CreateVoucherNcTask(_StoreCodeLbl, Voucher, NcTask);
        MockClient.AddResponse('FindCustomerByEmail', _LibrarySpfyVoucher.ResponseCustomerSearchHit('778'));
        MockClient.AddResponse('giftCardCreate', _LibrarySpfyVoucher.ResponseGiftCardCreated('9014'));

        // [WHEN] The voucher sender runs
        SendVoucher.SetGraphQLClient(MockClient);
        SendVoucher.Run(NcTask);

        // [THEN] The padding is gone from the search key
        _Assert.AreEqual(
            'email:onvoucher107@npretail.test',
            _LibrarySpfyVoucher.CustomerSearchCriteria(MockClient.GetRequestContaining('FindCustomerByEmail')),
            'The voucher''s own address must be trimmed before it becomes a search key.');
    end;

    [Test]
    procedure WhitespaceLinkEmail_FallsBackToTheCustomerCard()
    var
        Customer: Record Customer;
        NcTask: Record "NPR Nc Task";
        Voucher: Record "NPR NpRv Voucher";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendVoucher: Codeunit "NPR Spfy Send Voucher";
    begin
        // [SCENARIO] When the store-customer link holds only spaces, the customer card's own address is used rather than none.
        Initialize();

        // [GIVEN] A buyer whose customer card holds a real address while the store-customer link holds only spaces
        _LibrarySpfyVoucher.CreateCustomerWithStoreLink('SPFYC14', _StoreCodeLbl, 'onthecard@npretail.test', 'Carded Buyer', '', Customer);
        _LibrarySpfyVoucher.SetStoreCustomerLinkEmail(Customer."No.", _StoreCodeLbl, '   ');

        // [GIVEN] A voucher for that buyer that carries no e-mail of its own, so nothing else can rescue the lookup
        _LibrarySpfyVoucher.CreateVoucher('SPFYV14', _VoucherTypeLbl, 'SPFYVCHR0014', 100, Voucher);
        _LibrarySpfyVoucher.SetVoucherBuyer(Voucher, Customer."No.", '', 'Carded Buyer');
        _LibrarySpfyVoucher.CreateVoucherNcTask(_StoreCodeLbl, Voucher, NcTask);
        MockClient.AddResponse('onthecard@npretail.test', _LibrarySpfyVoucher.ResponseCustomerSearchHit('1414'));
        MockClient.AddResponse('giftCardCreate', _LibrarySpfyVoucher.ResponseGiftCardCreated('9014'));

        // [WHEN] The voucher sender runs
        SendVoucher.SetGraphQLClient(MockClient);
        SendVoucher.Run(NcTask);

        // [THEN] The customer card's address was used, and the customer it found is on the gift card
        _Assert.AreEqual(
            'email:onthecard@npretail.test',
            _LibrarySpfyVoucher.CustomerSearchCriteria(MockClient.GetRequestContaining('FindCustomerByEmail')),
            'A link address of only spaces must not hide the address on the customer card.');
        _Assert.AreEqual(
            _LibrarySpfyVoucher.CustomerGID('1414'),
            _LibrarySpfyVoucher.GiftCardInputValue(MockClient.GetRequestContaining('giftCardCreate'), 'customerId'),
            'The customer found through the card address must be associated with the gift card.');
    end;

    [Test]
    procedure DanglingCustomerNo_StillResolvesFromTheVoucherEmail()
    var
        NcTask: Record "NPR Nc Task";
        Voucher: Record "NPR NpRv Voucher";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendVoucher: Codeunit "NPR Spfy Send Voucher";
    begin
        // [SCENARIO] A voucher pointing at a customer that no longer exists is still delivered, using the address on the voucher.
        Initialize();

        // [GIVEN] A voucher whose Customer No. names a customer that is not in the database, but which carries an e-mail
        _LibrarySpfyVoucher.CreateVoucher('SPFYV15', _VoucherTypeLbl, 'SPFYVCHR0015', 100, Voucher);
        _LibrarySpfyVoucher.SetVoucherBuyer(Voucher, 'SPFYGONE', 'stillhere@npretail.test', 'Deleted Customer');
        _LibrarySpfyVoucher.CreateVoucherNcTask(_StoreCodeLbl, Voucher, NcTask);
        MockClient.AddResponse('stillhere@npretail.test', _LibrarySpfyVoucher.ResponseCustomerSearchHit('1515'));
        MockClient.AddResponse('giftCardCreate', _LibrarySpfyVoucher.ResponseGiftCardCreated('9015'));

        // [WHEN] The voucher sender runs
        SendVoucher.SetGraphQLClient(MockClient);
        SendVoucher.Run(NcTask);

        // [THEN] The voucher's own address was used to find the buyer, so the gift card still reaches somebody
        _Assert.AreEqual(
            'email:stillhere@npretail.test',
            _LibrarySpfyVoucher.CustomerSearchCriteria(MockClient.GetRequestContaining('FindCustomerByEmail')),
            'A Customer No. that resolves to nothing must not stop the voucher e-mail being used.');
        _Assert.AreEqual(
            _LibrarySpfyVoucher.CustomerGID('1515'),
            _LibrarySpfyVoucher.GiftCardInputValue(MockClient.GetRequestContaining('giftCardCreate'), 'customerId'),
            'The customer found through the voucher e-mail must be the one on the gift card.');
    end;

    [Test]
    procedure VoucherWithEmailButNoCustomer_StillResolvesACustomer()
    var
        NcTask: Record "NPR Nc Task";
        Voucher: Record "NPR NpRv Voucher";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendVoucher: Codeunit "NPR Spfy Send Voucher";
        SendRequest: Text;
    begin
        // [SCENARIO] A voucher carrying an e-mail but no BC customer is still associated with, and delivered to, that person.
        Initialize();

        // [GIVEN] A voucher with an e-mail address but no Customer No.
        _LibrarySpfyVoucher.CreateVoucher('SPFYV80', _VoucherTypeLbl, 'SPFYVCHR0080', 100, Voucher);
        _LibrarySpfyVoucher.SetVoucherBuyer(Voucher, '', 'nocustomer@npretail.test', 'Walk In Buyer');
        _LibrarySpfyVoucher.CreateVoucherNcTask(_StoreCodeLbl, Voucher, NcTask);
        MockClient.AddResponse('FindCustomerByEmail', _LibrarySpfyVoucher.ResponseCustomerSearchHit('811'));
        MockClient.AddResponse('giftCardCreate', _LibrarySpfyVoucher.ResponseGiftCardCreated('9008'));

        // [WHEN] The voucher sender runs
        SendVoucher.SetGraphQLClient(MockClient);
        SendVoucher.Run(NcTask);

        // [THEN] The e-mail alone was enough to resolve the customer Shopify will deliver to
        SendRequest := MockClient.GetRequestContaining('giftCardCreate');
        _Assert.AreEqual(
            _LibrarySpfyVoucher.CustomerGID('811'), _LibrarySpfyVoucher.GiftCardInputValue(SendRequest, 'customerId'),
            'A voucher with an e-mail but no Customer No. must still resolve a customer, or the gift card is never delivered.');
        _Assert.IsFalse(
            _LibrarySpfyVoucher.GiftCardInputHasField(SendRequest, 'recipientAttributes'),
            'Nobody else was nominated, so no separate recipient may be attached.');
    end;

    [Test]
    procedure AlternativeRecipient_AttachedBesideTheBuyer()
    var
        Customer: Record Customer;
        NcTask: Record "NPR Nc Task";
        Voucher: Record "NPR NpRv Voucher";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendVoucher: Codeunit "NPR Spfy Send Voucher";
        SendRequest: Text;
    begin
        // [SCENARIO] When the buyer nominates someone else, the nominee is attached as the recipient and the buyer stays the gift card's customer.
        Initialize();

        // [GIVEN] A synced buyer who nominated a different recipient e-mail and name
        _LibrarySpfyVoucher.CreateCustomerWithStoreLink('SPFYC40', _StoreCodeLbl, 'buyer40@npretail.test', 'Buyer Forty', '444', Customer);
        _LibrarySpfyVoucher.CreateVoucher('SPFYV40', _VoucherTypeLbl, 'SPFYVCHR0040', 100, Voucher);
        _LibrarySpfyVoucher.SetVoucherBuyer(Voucher, Customer."No.", 'buyer40@npretail.test', 'Buyer Forty');
        _LibrarySpfyVoucher.SetVoucherRecipient(Voucher, 'friend@npretail.test', 'Anna Fine');
        _LibrarySpfyVoucher.CreateVoucherNcTask(_StoreCodeLbl, Voucher, NcTask);
        // Keyed on the nominee's address, not on the query name: a regression that searched the buyer's
        // address instead would find no canned response and fail rather than quietly resolving to 888.
        MockClient.AddResponse('FindCustomerByEmail', 'friend@npretail.test', _LibrarySpfyVoucher.ResponseCustomerSearchHit('888'));
        MockClient.AddResponse('giftCardCreate', _LibrarySpfyVoucher.ResponseGiftCardCreated('9004'));

        // [WHEN] The voucher sender runs
        SendVoucher.SetGraphQLClient(MockClient);
        SendVoucher.Run(NcTask);

        // [THEN] customerId is the buyer and recipientAttributes is the nominee, each under its own field
        SendRequest := MockClient.GetRequestContaining('giftCardCreate');
        _Assert.AreEqual(
            _LibrarySpfyVoucher.CustomerGID('444'), _LibrarySpfyVoucher.GiftCardInputValue(SendRequest, 'customerId'),
            'The gift card must stay associated with the buyer.');
        _Assert.AreEqual(
            _LibrarySpfyVoucher.CustomerGID('888'), _LibrarySpfyVoucher.GiftCardInputValue(SendRequest, 'recipientAttributes.id'),
            'The nominated recipient must be the one in recipientAttributes.');
        _Assert.AreEqual(
            'Anna Fine', _LibrarySpfyVoucher.GiftCardInputValue(SendRequest, 'recipientAttributes.preferredName'),
            'The nominated recipient name must be passed as preferredName.');
    end;

    [Test]
    procedure UnknownNominee_IsCreatedWithTheirOwnAddressAndName()
    var
        Customer: Record Customer;
        NcTask: Record "NPR Nc Task";
        Voucher: Record "NPR NpRv Voucher";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendVoucher: Codeunit "NPR Spfy Send Voucher";
        CreateRequest: Text;
        SendRequest: Text;
    begin
        // [SCENARIO] A nominated recipient Shopify does not know is created as themselves, not as the buyer.
        Initialize();

        // [GIVEN] A synced buyer who nominated somebody Shopify has never seen
        _LibrarySpfyVoucher.CreateCustomerWithStoreLink('SPFYC205', _StoreCodeLbl, 'buyer205@npretail.test', 'Buyer Twohundredfive', '890', Customer);
        _LibrarySpfyVoucher.CreateVoucher('SPFYV205', _VoucherTypeLbl, 'SPFYVCHR0205', 100, Voucher);
        _LibrarySpfyVoucher.SetVoucherBuyer(Voucher, Customer."No.", 'buyer205@npretail.test', 'Buyer Twohundredfive');
        _LibrarySpfyVoucher.SetVoucherRecipient(Voucher, 'friend205@npretail.test', 'Anna Fine');
        _LibrarySpfyVoucher.CreateVoucherNcTask(_StoreCodeLbl, Voucher, NcTask);
        MockClient.AddResponse('FindCustomerByEmail', 'friend205@npretail.test', _LibrarySpfyVoucher.ResponseCustomerSearchMiss());
        MockClient.AddResponse('metafieldDefinitions', _LibrarySpfyVoucher.ResponseNoMetafieldDefinitions());
        MockClient.AddResponse('customerCreate', _LibrarySpfyVoucher.ResponseCustomerCreated('885'));
        MockClient.AddResponse('giftCardCreate', _LibrarySpfyVoucher.ResponseGiftCardCreated('9020'));

        // [WHEN] The voucher sender runs
        SendVoucher.SetGraphQLClient(MockClient);
        SendVoucher.Run(NcTask);

        // [THEN] The customer created in Shopify carries the nominee's address, and their name split in two
        CreateRequest := MockClient.GetRequestContaining('customerCreate');
        _Assert.AreEqual(
            'friend205@npretail.test', _LibrarySpfyVoucher.CustomerInputValue(CreateRequest, 'email'),
            'The customer created must be the nominee, not the buyer.');
        _Assert.AreEqual(
            'Anna', _LibrarySpfyVoucher.CustomerInputValue(CreateRequest, 'firstName'),
            'The nominee''s given name must be split out of the name on the voucher.');
        _Assert.AreEqual(
            'Fine', _LibrarySpfyVoucher.CustomerInputValue(CreateRequest, 'lastName'),
            'The nominee''s family name must be split out of the name on the voucher.');

        // [THEN] The gift card keeps the buyer and delivers to the newly created nominee
        SendRequest := MockClient.GetRequestContaining('giftCardCreate');
        _Assert.AreEqual(
            _LibrarySpfyVoucher.CustomerGID('890'), _LibrarySpfyVoucher.GiftCardInputValue(SendRequest, 'customerId'),
            'The buyer must stay the customer on the gift card.');
        _Assert.AreEqual(
            _LibrarySpfyVoucher.CustomerGID('885'), _LibrarySpfyVoucher.GiftCardInputValue(SendRequest, 'recipientAttributes.id'),
            'The gift card must be delivered to the nominee that was just created.');
    end;

    [Test]
    procedure NominationWithMessageAndSendDate_CarriesAllThreeOnTheNominee()
    var
        Customer: Record Customer;
        NcTask: Record "NPR Nc Task";
        Voucher: Record "NPR NpRv Voucher";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendVoucher: Codeunit "NPR Spfy Send Voucher";
        SendRequest: Text;
    begin
        // [SCENARIO] A gift bought for somebody else, with a message and a send date, carries all three to the nominee.
        Initialize();

        // [GIVEN] A synced buyer who nominated a friend, wrote a message and asked for it to go out next week
        _LibrarySpfyVoucher.CreateCustomerWithStoreLink('SPFYC206', _StoreCodeLbl, 'buyer206@npretail.test', 'Buyer Twohundredsix', '891', Customer);
        _LibrarySpfyVoucher.CreateVoucher('SPFYV206', _VoucherTypeLbl, 'SPFYVCHR0206', 100, Voucher);
        _LibrarySpfyVoucher.SetVoucherBuyer(Voucher, Customer."No.", 'buyer206@npretail.test', 'Buyer Twohundredsix');
        _LibrarySpfyVoucher.SetVoucherRecipient(Voucher, 'friend206@npretail.test', 'Bea Long');
        _LibrarySpfyVoucher.SetVoucherMessage(Voucher, 'Happy birthday');
        _LibrarySpfyVoucher.SetVoucherSendOn(Voucher, CreateDateTime(CalcDate('<+7D>', Today()), 120000T));
        _LibrarySpfyVoucher.CreateVoucherNcTask(_StoreCodeLbl, Voucher, NcTask);
        MockClient.AddResponse('FindCustomerByEmail', 'friend206@npretail.test', _LibrarySpfyVoucher.ResponseCustomerSearchHit('892'));
        MockClient.AddResponse('giftCardCreate', _LibrarySpfyVoucher.ResponseGiftCardCreated('9021'));

        // [WHEN] The voucher sender runs
        SendVoucher.SetGraphQLClient(MockClient);
        SendVoucher.Run(NcTask);

        // [THEN] The buyer stays the customer and the nominee is the recipient
        SendRequest := MockClient.GetRequestContaining('giftCardCreate');
        _Assert.AreEqual(
            _LibrarySpfyVoucher.CustomerGID('891'), _LibrarySpfyVoucher.GiftCardInputValue(SendRequest, 'customerId'),
            'The buyer must stay the customer on the gift card.');
        _Assert.AreEqual(
            _LibrarySpfyVoucher.CustomerGID('892'), _LibrarySpfyVoucher.GiftCardInputValue(SendRequest, 'recipientAttributes.id'),
            'The nominated friend must be the recipient.');

        // [THEN] The message, the name and the send date all travel with them
        _Assert.AreEqual(
            'Happy birthday', _LibrarySpfyVoucher.GiftCardInputValue(SendRequest, 'recipientAttributes.message'),
            'The message must reach the nominee, not be dropped because somebody was nominated.');
        _Assert.AreEqual(
            'Bea Long', _LibrarySpfyVoucher.GiftCardInputValue(SendRequest, 'recipientAttributes.preferredName'),
            'The nominee must be greeted by the name the buyer gave for them.');
        _Assert.IsTrue(
            _LibrarySpfyVoucher.GiftCardInputHasField(SendRequest, 'recipientAttributes.sendNotificationAt'),
            'The chosen send date must reach Shopify alongside the nomination.');
    end;

    [Test]
    procedure UnsyncedBuyerWithAlternativeRecipient_OmitsBuyerRatherThanCreatingOne()
    var
        Customer: Record Customer;
        NcTask: Record "NPR Nc Task";
        Voucher: Record "NPR NpRv Voucher";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendVoucher: Codeunit "NPR Spfy Send Voucher";
        SendRequest: Text;
    begin
        // [SCENARIO] A buyer who is unknown to Shopify and who nominated somebody else is left off the gift card rather than created in Shopify.
        Initialize();

        // [GIVEN] A buyer with no assigned Shopify id whose e-mail Shopify does not know, who nominated someone else
        _LibrarySpfyVoucher.CreateCustomerWithStoreLink('SPFYC90', _StoreCodeLbl, 'stranger@npretail.test', 'Unknown Buyer', '', Customer);
        _LibrarySpfyVoucher.CreateVoucher('SPFYV90', _VoucherTypeLbl, 'SPFYVCHR0090', 100, Voucher);
        _LibrarySpfyVoucher.SetVoucherBuyer(Voucher, Customer."No.", 'stranger@npretail.test', 'Unknown Buyer');
        _LibrarySpfyVoucher.SetVoucherRecipient(Voucher, 'nominee@npretail.test', 'Nina Nominee');
        _LibrarySpfyVoucher.CreateVoucherNcTask(_StoreCodeLbl, Voucher, NcTask);
        MockClient.AddResponse('stranger@npretail.test', _LibrarySpfyVoucher.ResponseCustomerSearchMiss());
        MockClient.AddResponse('nominee@npretail.test', _LibrarySpfyVoucher.ResponseCustomerSearchHit('999'));
        MockClient.AddResponse('giftCardCreate', _LibrarySpfyVoucher.ResponseGiftCardCreated('9009'));

        // [WHEN] The voucher sender runs
        SendVoucher.SetGraphQLClient(MockClient);
        SendVoucher.Run(NcTask);

        // [THEN] No Shopify customer was created for the buyer, and the gift card carries no customerId
        _Assert.AreEqual(0, MockClient.CountRequestsContaining('customerCreate'), 'An unknown buyer who nominated somebody else must not be created in Shopify.');
        SendRequest := MockClient.GetRequestContaining('giftCardCreate');
        _Assert.IsFalse(
            _LibrarySpfyVoucher.GiftCardInputHasField(SendRequest, 'customerId'),
            'With no id for the buyer the gift card must simply carry no customerId.');

        // [THEN] The nominated recipient is still resolved, so the gift card is delivered
        _Assert.AreEqual(
            _LibrarySpfyVoucher.CustomerGID('999'), _LibrarySpfyVoucher.GiftCardInputValue(SendRequest, 'recipientAttributes.id'),
            'The nominated recipient must still be resolved so Shopify delivers the gift card.');
    end;

    [Test]
    procedure WhitespaceRecipientFields_TreatedAsNoNomination()
    var
        Customer: Record Customer;
        NcTask: Record "NPR Nc Task";
        Voucher: Record "NPR NpRv Voucher";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendVoucher: Codeunit "NPR Spfy Send Voucher";
        SendRequest: Text;
    begin
        // [SCENARIO] Recipient fields holding only spaces name nobody, so the buyer is used and Shopify is sent no blank address.
        Initialize();

        // [GIVEN] A synced buyer whose voucher has whitespace-only recipient e-mail and name
        _LibrarySpfyVoucher.CreateCustomerWithStoreLink('SPFYC11', _StoreCodeLbl, 'buyer11@npretail.test', 'Buyer Eleven', '111', Customer);
        _LibrarySpfyVoucher.CreateVoucher('SPFYV11', _VoucherTypeLbl, 'SPFYVCHR0011', 100, Voucher);
        _LibrarySpfyVoucher.SetVoucherBuyer(Voucher, Customer."No.", 'buyer11@npretail.test', 'Buyer Eleven');
        _LibrarySpfyVoucher.SetVoucherRecipient(Voucher, '   ', '   ');
        _LibrarySpfyVoucher.CreateVoucherNcTask(_StoreCodeLbl, Voucher, NcTask);
        MockClient.AddResponse('giftCardCreate', _LibrarySpfyVoucher.ResponseGiftCardCreated('9011'));

        // [WHEN] The voucher sender runs
        SendVoucher.SetGraphQLClient(MockClient);
        SendVoucher.Run(NcTask);

        // [THEN] Shopify was never asked about the whitespace address, and the buyer is simply the customer
        _Assert.AreEqual(1, MockClient.RequestCount(), 'A whitespace-only recipient e-mail must not be looked up or created in Shopify.');
        SendRequest := MockClient.GetRequestContaining('giftCardCreate');
        _Assert.AreEqual(
            _LibrarySpfyVoucher.CustomerGID('111'), _LibrarySpfyVoucher.GiftCardInputValue(SendRequest, 'customerId'),
            'With no real nomination the buyer must be the customer on the gift card.');
        _Assert.IsFalse(
            _LibrarySpfyVoucher.GiftCardInputHasField(SendRequest, 'recipientAttributes'),
            'A whitespace-only nomination must not produce a recipient at all.');
    end;

    [Test]
    procedure NoCustomerAndNoEmail_CreatesGiftCardWithoutCustomerOrRecipient()
    var
        NcTask: Record "NPR Nc Task";
        Voucher: Record "NPR NpRv Voucher";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendVoucher: Codeunit "NPR Spfy Send Voucher";
        SendRequest: Text;
    begin
        // [SCENARIO] A voucher with nobody to deliver to still creates the gift card, rather than failing the task.
        Initialize();

        // [GIVEN] A voucher with neither a customer nor an e-mail address
        _LibrarySpfyVoucher.CreateVoucher('SPFYV50', _VoucherTypeLbl, 'SPFYVCHR0050', 100, Voucher);
        _LibrarySpfyVoucher.CreateVoucherNcTask(_StoreCodeLbl, Voucher, NcTask);
        MockClient.AddResponse('giftCardCreate', _LibrarySpfyVoucher.ResponseGiftCardCreated('9005'));

        // [WHEN] The voucher sender runs
        SendVoucher.SetGraphQLClient(MockClient);
        SendVoucher.Run(NcTask);

        // [THEN] The gift card is created, with neither a customer nor a recipient attached
        _Assert.AreEqual(1, MockClient.RequestCount(), 'With no e-mail to search by, Shopify must only be asked to create the gift card.');
        _Assert.AreEqual(1, MockClient.CountRequestsContaining('giftCardCreate'), 'The one request must be the gift card create.');
        SendRequest := MockClient.GetRequestContaining('giftCardCreate');
        _Assert.IsFalse(_LibrarySpfyVoucher.GiftCardInputHasField(SendRequest, 'customerId'), 'There is no customer to associate the gift card with.');
        _Assert.IsFalse(_LibrarySpfyVoucher.GiftCardInputHasField(SendRequest, 'recipientAttributes'), 'There is nobody to deliver the gift card to.');
    end;

    [Test]
    procedure SendFromShopifyDisabled_OmitsCustomerAndRecipient()
    var
        Customer: Record Customer;
        NcTask: Record "NPR Nc Task";
        Voucher: Record "NPR NpRv Voucher";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendVoucher: Codeunit "NPR Spfy Send Voucher";
        SendRequest: Text;
    begin
        // [SCENARIO] A voucher that is not set to be sent from Shopify is created as a plain gift card.
        Initialize();

        // [GIVEN] A synced buyer on a voucher with "Send from Shopify" turned off
        _LibrarySpfyVoucher.CreateCustomerWithStoreLink('SPFYC60', _StoreCodeLbl, 'buyer60@npretail.test', 'Buyer Sixty', '666', Customer);
        _LibrarySpfyVoucher.CreateVoucher('SPFYV60', _VoucherTypeLbl, 'SPFYVCHR0060', 100, Voucher);
        _LibrarySpfyVoucher.SetVoucherBuyer(Voucher, Customer."No.", 'buyer60@npretail.test', 'Buyer Sixty');
        _LibrarySpfyVoucher.SetVoucherSendFromShopify(Voucher, false);
        _LibrarySpfyVoucher.CreateVoucherNcTask(_StoreCodeLbl, Voucher, NcTask);
        MockClient.AddResponse('giftCardCreate', _LibrarySpfyVoucher.ResponseGiftCardCreated('9006'));

        // [WHEN] The voucher sender runs
        SendVoucher.SetGraphQLClient(MockClient);
        SendVoucher.Run(NcTask);

        // [THEN] The gift card is still created in Shopify
        _Assert.AreEqual(1, MockClient.CountRequestsContaining('giftCardCreate'), 'The gift card must still be created in Shopify.');
        SendRequest := MockClient.GetRequestContaining('giftCardCreate');

        // [THEN] Neither the customer nor a recipient is attached
        _Assert.IsFalse(
            _LibrarySpfyVoucher.GiftCardInputHasField(SendRequest, 'customerId'),
            'A voucher not sent from Shopify must not be associated with a customer.');
        _Assert.IsFalse(
            _LibrarySpfyVoucher.GiftCardInputHasField(SendRequest, 'recipientAttributes'),
            'A voucher not sent from Shopify must not carry a recipient.');
    end;

    [Test]
    procedure SelfNominatingUnsyncedBuyer_IsCreatedOnceAndUsedForBothFields()
    var
        NcTask: Record "NPR Nc Task";
        Voucher: Record "NPR NpRv Voucher";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendVoucher: Codeunit "NPR Spfy Send Voucher";
        SendRequest: Text;
    begin
        // [SCENARIO] A buyer who nominates their own address keeps their customerId, and Shopify is told about them once.
        Initialize();

        // [GIVEN] A voucher whose buyer nominated their own address, in a different case, and whom Shopify does not know yet
        _LibrarySpfyVoucher.CreateVoucher('SPFYV100', _VoucherTypeLbl, 'SPFYVCHR0100', 100, Voucher);
        _LibrarySpfyVoucher.SetVoucherBuyer(Voucher, '', 'buyer100@npretail.test', 'Buyer Hundred');
        _LibrarySpfyVoucher.SetVoucherRecipient(Voucher, 'BUYER100@NPRETAIL.TEST', '');
        _LibrarySpfyVoucher.CreateVoucherNcTask(_StoreCodeLbl, Voucher, NcTask);
        MockClient.AddResponse('FindCustomerByEmail', _LibrarySpfyVoucher.ResponseCustomerSearchMiss());
        MockClient.AddResponse('metafieldDefinitions', _LibrarySpfyVoucher.ResponseNoMetafieldDefinitions());
        MockClient.AddResponse('customerCreate', _LibrarySpfyVoucher.ResponseCustomerCreated('777'));
        MockClient.AddResponse('giftCardCreate', _LibrarySpfyVoucher.ResponseGiftCardCreated('9007'));

        // [WHEN] The voucher sender runs
        SendVoucher.SetGraphQLClient(MockClient);
        SendVoucher.Run(NcTask);

        // [THEN] The buyer keeps their own customerId, and the nomination they made is honoured with the same id
        SendRequest := MockClient.GetRequestContaining('giftCardCreate');
        _Assert.AreEqual(
            _LibrarySpfyVoucher.CustomerGID('777'), _LibrarySpfyVoucher.GiftCardInputValue(SendRequest, 'customerId'),
            'The buyer must keep their customerId even when they nominated themselves.');
        _Assert.AreEqual(
            _LibrarySpfyVoucher.CustomerGID('777'), _LibrarySpfyVoucher.GiftCardInputValue(SendRequest, 'recipientAttributes.id'),
            'The nomination the buyer made must still be honoured, with the same id.');

        // [THEN] The buyer's own name stands in for the greeting, since the nomination gave an address only
        _Assert.AreEqual(
            'Buyer Hundred', _LibrarySpfyVoucher.GiftCardInputValue(SendRequest, 'recipientAttributes.preferredName'),
            'A buyer who nominated themselves by address must still be greeted by name.');

        // [THEN] Shopify was searched once and the buyer created once, rather than resolved twice over
        _Assert.AreEqual(1, MockClient.CountRequestsContaining('FindCustomerByEmail'), 'One person must only be looked up once.');
        _Assert.AreEqual(1, MockClient.CountRequestsContaining('customerCreate'), 'One person must only be created once.');
    end;

    [Test]
    procedure SelfNominationIsJudgedOnTheResolvedAddress()
    var
        Customer: Record Customer;
        NcTask: Record "NPR Nc Task";
        Voucher: Record "NPR NpRv Voucher";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendVoucher: Codeunit "NPR Spfy Send Voucher";
        SendRequest: Text;
    begin
        // [SCENARIO] A nomination naming the address the buyer really resolves to counts as self-nomination, even when the voucher's own e-mail says otherwise.
        Initialize();

        // [GIVEN] A synced buyer whose card address differs from the address held on the voucher
        _LibrarySpfyVoucher.CreateCustomerWithStoreLink('SPFYC101', _StoreCodeLbl, 'card101@npretail.test', 'Buyer Hundredone', '771', Customer);
        _LibrarySpfyVoucher.CreateVoucher('SPFYV101', _VoucherTypeLbl, 'SPFYVCHR0101', 100, Voucher);
        _LibrarySpfyVoucher.SetVoucherBuyer(Voucher, Customer."No.", 'voucher101@npretail.test', 'Buyer Hundredone');

        // [GIVEN] ...and a nomination naming the card address, which is the one the buyer resolves to
        _LibrarySpfyVoucher.SetVoucherRecipient(Voucher, 'card101@npretail.test', '');
        _LibrarySpfyVoucher.CreateVoucherNcTask(_StoreCodeLbl, Voucher, NcTask);
        MockClient.AddResponse('FindCustomerByEmail', _LibrarySpfyVoucher.ResponseCustomerSearchHit('881'));
        MockClient.AddResponse('giftCardCreate', _LibrarySpfyVoucher.ResponseGiftCardCreated('9008'));

        // [WHEN] The voucher sender runs
        SendVoucher.SetGraphQLClient(MockClient);
        SendVoucher.Run(NcTask);

        // [THEN] Both fields carry the buyer's own id, not whatever a fresh lookup would have returned
        SendRequest := MockClient.GetRequestContaining('giftCardCreate');
        _Assert.AreEqual(
            _LibrarySpfyVoucher.CustomerGID('771'), _LibrarySpfyVoucher.GiftCardInputValue(SendRequest, 'customerId'),
            'The buyer must stay the customer on the gift card.');
        _Assert.AreEqual(
            _LibrarySpfyVoucher.CustomerGID('771'), _LibrarySpfyVoucher.GiftCardInputValue(SendRequest, 'recipientAttributes.id'),
            'A nomination naming the buyer must resolve to the buyer, not to a fresh lookup.');

        // [THEN] ...and Shopify was never asked, because the buyer's own id already answered the nomination
        _Assert.AreEqual(0, MockClient.CountRequestsContaining('FindCustomerByEmail'), 'The buyer''s own id already answers the nomination.');
    end;

    [Test]
    procedure ScheduledSendWithoutNomination_CarriesTheDateOnTheBuyer()
    var
        Customer: Record Customer;
        NcTask: Record "NPR Nc Task";
        Voucher: Record "NPR NpRv Voucher";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendVoucher: Codeunit "NPR Spfy Send Voucher";
        SendRequest: Text;
    begin
        // [SCENARIO] A send date set without nominating anybody reaches Shopify instead of being dropped.
        Initialize();

        // [GIVEN] A synced buyer who nominated nobody but asked for the gift card to go out next week
        _LibrarySpfyVoucher.CreateCustomerWithStoreLink('SPFYC102', _StoreCodeLbl, 'buyer102@npretail.test', 'Buyer Hundredtwo', '772', Customer);
        _LibrarySpfyVoucher.CreateVoucher('SPFYV102', _VoucherTypeLbl, 'SPFYVCHR0102', 100, Voucher);
        _LibrarySpfyVoucher.SetVoucherBuyer(Voucher, Customer."No.", 'buyer102@npretail.test', 'Buyer Hundredtwo');
        _LibrarySpfyVoucher.SetVoucherSendOn(Voucher, CreateDateTime(CalcDate('<+7D>', Today()), 120000T));
        _LibrarySpfyVoucher.CreateVoucherNcTask(_StoreCodeLbl, Voucher, NcTask);
        MockClient.AddResponse('giftCardCreate', _LibrarySpfyVoucher.ResponseGiftCardCreated('9009'));

        // [WHEN] The voucher sender runs
        SendVoucher.SetGraphQLClient(MockClient);
        SendVoucher.Run(NcTask);

        // [THEN] The buyer is named as the recipient, because that is the only field carrying a send date
        SendRequest := MockClient.GetRequestContaining('giftCardCreate');
        _Assert.AreEqual(
            _LibrarySpfyVoucher.CustomerGID('772'), _LibrarySpfyVoucher.GiftCardInputValue(SendRequest, 'recipientAttributes.id'),
            'With nobody else nominated the send date has to hang on the buyer.');

        // [THEN] The date itself leaves BC
        _Assert.IsTrue(
            _LibrarySpfyVoucher.GiftCardInputHasField(SendRequest, 'recipientAttributes.sendNotificationAt'),
            'The chosen send date must reach Shopify rather than being silently dropped.');
    end;

    [Test]
    procedure VoucherMessageWithoutNomination_CarriedOnTheBuyer()
    var
        Customer: Record Customer;
        NcTask: Record "NPR Nc Task";
        Voucher: Record "NPR NpRv Voucher";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendVoucher: Codeunit "NPR Spfy Send Voucher";
        SendRequest: Text;
    begin
        // [SCENARIO] A voucher message written without nominating anybody reaches Shopify instead of being dropped.
        Initialize();

        // [GIVEN] A synced buyer who nominated nobody but wrote a message on the voucher
        _LibrarySpfyVoucher.CreateCustomerWithStoreLink('SPFYC103', _StoreCodeLbl, 'buyer103@npretail.test', 'Buyer Hundredthree', '773', Customer);
        _LibrarySpfyVoucher.CreateVoucher('SPFYV103', _VoucherTypeLbl, 'SPFYVCHR0103', 100, Voucher);
        _LibrarySpfyVoucher.SetVoucherBuyer(Voucher, Customer."No.", 'buyer103@npretail.test', 'Buyer Hundredthree');
        _LibrarySpfyVoucher.SetVoucherMessage(Voucher, 'Happy birthday');
        _LibrarySpfyVoucher.CreateVoucherNcTask(_StoreCodeLbl, Voucher, NcTask);
        MockClient.AddResponse('giftCardCreate', _LibrarySpfyVoucher.ResponseGiftCardCreated('9010'));

        // [WHEN] The voucher sender runs
        SendVoucher.SetGraphQLClient(MockClient);
        SendVoucher.Run(NcTask);

        // [THEN] The message reaches Shopify, hung on the buyer for want of anybody else
        SendRequest := MockClient.GetRequestContaining('giftCardCreate');
        _Assert.AreEqual(
            'Happy birthday', _LibrarySpfyVoucher.GiftCardInputValue(SendRequest, 'recipientAttributes.message'),
            'The message the buyer wrote must reach Shopify rather than being silently dropped.');
        _Assert.AreEqual(
            _LibrarySpfyVoucher.CustomerGID('773'), _LibrarySpfyVoucher.GiftCardInputValue(SendRequest, 'recipientAttributes.id'),
            'With nobody else nominated the message has to hang on the buyer.');
    end;

    [Test]
    procedure WhitespaceVoucherMessageWithoutNomination_AddsNoRecipient()
    var
        Customer: Record Customer;
        NcTask: Record "NPR Nc Task";
        Voucher: Record "NPR NpRv Voucher";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendVoucher: Codeunit "NPR Spfy Send Voucher";
        SendRequest: Text;
    begin
        // [SCENARIO] A voucher message of only spaces says nothing, so it buys the buyer no second notification.
        Initialize();

        // [GIVEN] A synced buyer who nominated nobody and whose message is a single space
        _LibrarySpfyVoucher.CreateCustomerWithStoreLink('SPFYC105', _StoreCodeLbl, 'buyer105@npretail.test', 'Buyer Hundredfive', '775', Customer);
        _LibrarySpfyVoucher.CreateVoucher('SPFYV105', _VoucherTypeLbl, 'SPFYVCHR0105', 100, Voucher);
        _LibrarySpfyVoucher.SetVoucherBuyer(Voucher, Customer."No.", 'buyer105@npretail.test', 'Buyer Hundredfive');
        _LibrarySpfyVoucher.SetVoucherMessage(Voucher, '   ');
        _LibrarySpfyVoucher.CreateVoucherNcTask(_StoreCodeLbl, Voucher, NcTask);
        MockClient.AddResponse('giftCardCreate', _LibrarySpfyVoucher.ResponseGiftCardCreated('9012'));

        // [WHEN] The voucher sender runs
        SendVoucher.SetGraphQLClient(MockClient);
        SendVoucher.Run(NcTask);

        // [THEN] The gift card is created for the buyer alone
        _Assert.AreEqual(1, MockClient.CountRequestsContaining('giftCardCreate'), 'The gift card must still be created in Shopify.');
        SendRequest := MockClient.GetRequestContaining('giftCardCreate');
        _Assert.AreEqual(
            _LibrarySpfyVoucher.CustomerGID('775'), _LibrarySpfyVoucher.GiftCardInputValue(SendRequest, 'customerId'),
            'The buyer must stay the customer on the gift card.');

        // [THEN] Nothing is hung on a recipient, so no duplicate notification carries a blank message
        _Assert.IsFalse(
            _LibrarySpfyVoucher.GiftCardInputHasField(SendRequest, 'recipientAttributes'),
            'A message of only spaces must not name the buyer a second time.');
    end;

    [Test]
    procedure PastScheduledSendWithoutNomination_AddsNoRecipient()
    var
        Customer: Record Customer;
        NcTask: Record "NPR Nc Task";
        Voucher: Record "NPR NpRv Voucher";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendVoucher: Codeunit "NPR Spfy Send Voucher";
        SendRequest: Text;
    begin
        // [SCENARIO] A send date already in the past buys the buyer no second notification, because there is nothing left to schedule.
        Initialize();

        // [GIVEN] A synced buyer who nominated nobody and whose send date has already passed
        _LibrarySpfyVoucher.CreateCustomerWithStoreLink('SPFYC104', _StoreCodeLbl, 'buyer104@npretail.test', 'Buyer Hundredfour', '774', Customer);
        _LibrarySpfyVoucher.CreateVoucher('SPFYV104', _VoucherTypeLbl, 'SPFYVCHR0104', 100, Voucher);
        _LibrarySpfyVoucher.SetVoucherBuyer(Voucher, Customer."No.", 'buyer104@npretail.test', 'Buyer Hundredfour');
        _LibrarySpfyVoucher.SetVoucherSendOn(Voucher, CreateDateTime(CalcDate('<-1D>', Today()), 120000T));
        _LibrarySpfyVoucher.CreateVoucherNcTask(_StoreCodeLbl, Voucher, NcTask);
        MockClient.AddResponse('giftCardCreate', _LibrarySpfyVoucher.ResponseGiftCardCreated('9011'));

        // [WHEN] The voucher sender runs
        SendVoucher.SetGraphQLClient(MockClient);
        SendVoucher.Run(NcTask);

        // [THEN] The gift card is created for the buyer alone
        _Assert.AreEqual(1, MockClient.CountRequestsContaining('giftCardCreate'), 'The gift card must still be created in Shopify.');
        SendRequest := MockClient.GetRequestContaining('giftCardCreate');
        _Assert.AreEqual(
            _LibrarySpfyVoucher.CustomerGID('774'), _LibrarySpfyVoucher.GiftCardInputValue(SendRequest, 'customerId'),
            'The buyer must stay the customer on the gift card.');

        // [THEN] Nothing is hung on a recipient, so the stale date cannot buy a duplicate notification
        _Assert.IsFalse(
            _LibrarySpfyVoucher.GiftCardInputHasField(SendRequest, 'recipientAttributes'),
            'A date Shopify would act on immediately must not name the buyer a second time.');
    end;

    local procedure Initialize()
    var
        VoucherType: Record "NPR NpRv Voucher Type";
    begin
        _LibrarySpfyVoucher.CreateShopifyStore(_StoreCodeLbl);
        _LibrarySpfyVoucher.CreateVoucherType(_VoucherTypeLbl, _StoreCodeLbl, VoucherType);
    end;
}
#endif
