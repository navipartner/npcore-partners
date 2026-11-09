codeunit 85629 "NPR APIInventoryItem Get"
{
    // [FEATURE] GET /inventory/item and /inventory/item/:id - productType classification for Entria

    Subtype = Test;

    var
        _Assert: Codeunit Assert;
        _LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        _LibraryEntria: Codeunit "NPR Library - Entria";
        _LibraryInventory: Codeunit "NPR Library - Inventory";
        _LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        _LibraryEcommerce: Codeunit "NPR Library Ecommerce";
        _LibraryCoupon: Codeunit "NPR Library Coupon";
        _LibraryUtility: Codeunit "Library - Utility";
        _LibraryAPIBI: Codeunit "NPR Library - API BI";
        _ItemChangeMgt: Codeunit "NPR Inventory Item Change Mgt.";
        _BoundarySeam: Codeunit "NPR Spfy RowVer Boundary Seam";
        _BoundarySeamBound: Boolean;
        _EntriaStoreCode: Code[20];

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetItem_WalletFlagAndTicket_ReturnsAttractionPackage()
    var
        Item: Record Item;
        ItemNo: Code[20];
    begin
        // [SCENARIO] An item flagged to create an attraction wallet is ATTRACTION_PACKAGE even when it is also a ticket.

        // [GIVEN] API permission and an enabled Entria store
        Initialize();

        // [GIVEN] An Entria-product ticket item that also has "NPR CreateAttractionWallet" set
        ItemNo := _LibraryInventory.CreateItemNo();
        _LibrarySpfyImport.MakeItemATicketItem(ItemNo);
        Item.Get(ItemNo);
        Item."NPR CreateAttractionWallet" := true;
        Item.Modify();
        MarkEntriaProduct(ItemNo);

        // [WHEN] The single item endpoint is called
        // [THEN] productType is ATTRACTION_PACKAGE
        _Assert.AreEqual('ATTRACTION_PACKAGE', GetSingleItemProductType(ItemNo), 'Wallet flag must win over ticket');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetItem_TicketAndMembershipSalesSetup_ReturnsTicket()
    var
        ItemNo: Code[20];
    begin
        // [SCENARIO] A ticket item that also has a membership sales setup is TICKET.

        // [GIVEN] API permission and an enabled Entria store
        Initialize();

        // [GIVEN] An Entria-product ticket item with a membership sales setup row
        ItemNo := CreateTicketItem();
        InsertMembershipSalesSetup(ItemNo);
        MarkEntriaProduct(ItemNo);

        // [WHEN] The single item endpoint is called
        // [THEN] productType is TICKET
        _Assert.AreEqual('TICKET', GetSingleItemProductType(ItemNo), 'Ticket must win over membership');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetItem_MembershipSalesSetupAndAlteration_ReturnsMembership()
    var
        MembersAlterSetup: Record "NPR MM Members. Alter. Setup";
        ItemNo: Code[20];
    begin
        // [SCENARIO] An item with both a membership sales setup and a renewal alteration is MEMBERSHIP.

        // [GIVEN] API permission and an enabled Entria store
        Initialize();

        // [GIVEN] An Entria-product item with a membership sales setup row, then a RENEW alteration row
        ItemNo := _LibraryInventory.CreateItemNo();
        InsertMembershipSalesSetup(ItemNo);
        InsertMembershipAlterSetup(ItemNo, MembersAlterSetup."Alteration Type"::RENEW);
        MarkEntriaProduct(ItemNo);

        // [WHEN] The single item endpoint is called
        // [THEN] productType is MEMBERSHIP
        _Assert.AreEqual('MEMBERSHIP', GetSingleItemProductType(ItemNo), 'Membership sales setup must win over alteration setup');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetItem_MembershipSalesSetupOnly_ReturnsMembership()
    var
        ItemNo: Code[20];
    begin
        // [SCENARIO] An item whose only signal is a membership sales setup row is MEMBERSHIP.

        // [GIVEN] API permission and an enabled Entria store
        Initialize();

        // [GIVEN] An Entria-product item with only a membership sales setup row
        ItemNo := _LibraryInventory.CreateItemNo();
        InsertMembershipSalesSetup(ItemNo);
        MarkEntriaProduct(ItemNo);

        // [WHEN] The single item endpoint is called
        // [THEN] productType is MEMBERSHIP
        _Assert.AreEqual('MEMBERSHIP', GetSingleItemProductType(ItemNo), 'Membership sales setup must classify the item as MEMBERSHIP');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetItem_AccountTypeMembershipSalesSetup_ReturnsItem()
    var
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        ItemNo: Code[20];
    begin
        // [SCENARIO] A membership sales setup row of type ACCOUNT whose "No." equals an item number does not classify that item.

        // [GIVEN] API permission and an enabled Entria store
        Initialize();

        // [GIVEN] A plain Entria-product item and an ACCOUNT-type membership sales setup row with the same number
        ItemNo := _LibraryInventory.CreateItemNo();
        InsertMembershipSalesSetupOfType(ItemNo, MembershipSalesSetup.Type::ACCOUNT);
        MarkEntriaProduct(ItemNo);

        // [WHEN] The single item endpoint is called
        // [THEN] productType is ITEM
        _Assert.AreEqual('ITEM', GetSingleItemProductType(ItemNo), 'An ACCOUNT-type membership sales setup row must not classify the item as MEMBERSHIP');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetItem_UpgradeAlterationOnly_ReturnsMembershipUpgrade()
    var
        MembersAlterSetup: Record "NPR MM Members. Alter. Setup";
        ItemNo: Code[20];
    begin
        // [SCENARIO] An item whose only signal is an UPGRADE alteration row is MEMBERSHIP_UPGRADE.

        // [GIVEN] API permission and an enabled Entria store
        Initialize();

        // [GIVEN] An Entria-product item with only an UPGRADE alteration row
        ItemNo := _LibraryInventory.CreateItemNo();
        InsertMembershipAlterSetup(ItemNo, MembersAlterSetup."Alteration Type"::UPGRADE);
        MarkEntriaProduct(ItemNo);

        // [WHEN] The single item endpoint is called
        // [THEN] productType is MEMBERSHIP_UPGRADE
        _Assert.AreEqual('MEMBERSHIP_UPGRADE', GetSingleItemProductType(ItemNo), 'An UPGRADE alteration must classify the item as MEMBERSHIP_UPGRADE');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetItem_UpgradeAlterationAndEcomCoupon_ReturnsMembershipUpgrade()
    var
        CouponType: Record "NPR NpDc Coupon Type";
        MembersAlterSetup: Record "NPR MM Members. Alter. Setup";
        ItemNo: Code[20];
    begin
        // [SCENARIO] An item with an UPGRADE alteration row and an enabled ecom-sale coupon setup is MEMBERSHIP_UPGRADE;
        // every alteration type wins over coupon.

        // [GIVEN] API permission and an enabled Entria store
        Initialize();

        // [GIVEN] An Entria-product ecom-sale coupon item with an enabled coupon type, plus an UPGRADE alteration row on the same item
        ItemNo := _LibraryEcommerce.CreateEcomCouponItem(CouponType);
        InsertMembershipAlterSetup(ItemNo, MembersAlterSetup."Alteration Type"::UPGRADE);
        MarkEntriaProduct(ItemNo);

        // [WHEN] The single item endpoint is called
        // [THEN] productType is MEMBERSHIP_UPGRADE
        _Assert.AreEqual('MEMBERSHIP_UPGRADE', GetSingleItemProductType(ItemNo), 'An UPGRADE alteration must win over coupon');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetItem_CancelAlterationAndEcomCoupon_ReturnsMembershipCancel()
    var
        CouponType: Record "NPR NpDc Coupon Type";
        MembersAlterSetup: Record "NPR MM Members. Alter. Setup";
        ItemNo: Code[20];
    begin
        // [SCENARIO] An item with a CANCEL alteration row and an enabled ecom-sale coupon setup is MEMBERSHIP_CANCEL;
        // CANCEL is the last alteration type in the order and still wins over coupon.

        // [GIVEN] API permission and an enabled Entria store
        Initialize();

        // [GIVEN] An Entria-product ecom-sale coupon item with an enabled coupon type, plus a CANCEL alteration row on the same item
        ItemNo := _LibraryEcommerce.CreateEcomCouponItem(CouponType);
        InsertMembershipAlterSetup(ItemNo, MembersAlterSetup."Alteration Type"::CANCEL);
        MarkEntriaProduct(ItemNo);

        // [WHEN] The single item endpoint is called
        // [THEN] productType is MEMBERSHIP_CANCEL
        _Assert.AreEqual('MEMBERSHIP_CANCEL', GetSingleItemProductType(ItemNo), 'A CANCEL alteration must win over coupon');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetItem_EcomSaleCoupon_ReturnsCoupon()
    var
        CouponType: Record "NPR NpDc Coupon Type";
        ItemNo: Code[20];
    begin
        // [SCENARIO] An item mapped to an enabled ON-ECOM-SALE coupon type is COUPON.

        // [GIVEN] API permission and an enabled Entria store
        Initialize();

        // [GIVEN] An Entria-product ecom-sale coupon item with an enabled coupon type
        ItemNo := _LibraryEcommerce.CreateEcomCouponItem(CouponType);
        MarkEntriaProduct(ItemNo);

        // [WHEN] The single item endpoint is called
        // [THEN] productType is COUPON
        _Assert.AreEqual('COUPON', GetSingleItemProductType(ItemNo), 'Ecom-sale coupon setup must classify the item as COUPON');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetItem_WalletCouponTrigger_ReturnsCoupon()
    var
        CouponType: Record "NPR NpDc Coupon Type";
        ItemNo: Code[20];
    begin
        // [SCENARIO] An item that triggers an enabled wallet coupon type is COUPON.

        // [GIVEN] API permission and an enabled Entria store
        Initialize();

        // [GIVEN] An enabled coupon type and a wallet coupon setup row triggered by a new Entria-product item
        ItemNo := CreateWalletCouponItem(CouponType);
        MarkEntriaProduct(ItemNo);

        // [WHEN] The single item endpoint is called
        // [THEN] productType is COUPON
        _Assert.AreEqual('COUPON', GetSingleItemProductType(ItemNo), 'Wallet coupon trigger must classify the item as COUPON');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetItem_DisabledCouponType_ReturnsItem()
    var
        ItemNo: Code[20];
    begin
        // [SCENARIO] An item mapped only to a disabled coupon type is ITEM.

        // [GIVEN] API permission and an enabled Entria store
        Initialize();

        // [GIVEN] An Entria-product ecom-sale coupon item whose coupon type is then disabled
        ItemNo := CreateDisabledEcomCouponItem();
        MarkEntriaProduct(ItemNo);

        // [WHEN] The single item endpoint is called
        // [THEN] productType is ITEM
        _Assert.AreEqual('ITEM', GetSingleItemProductType(ItemNo), 'A disabled coupon type must not classify the item as COUPON');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetItem_WalletTriggerDisabledCouponType_ReturnsItem()
    var
        CouponType: Record "NPR NpDc Coupon Type";
        ItemNo: Code[20];
    begin
        // [SCENARIO] An item that triggers only a disabled wallet coupon type is ITEM.

        // [GIVEN] API permission and an enabled Entria store
        Initialize();

        // [GIVEN] A wallet coupon setup row triggered by a new Entria-product item, with its coupon type then disabled
        ItemNo := CreateWalletCouponItem(CouponType);
        CouponType.Enabled := false;
        CouponType.Modify();
        MarkEntriaProduct(ItemNo);

        // [WHEN] The single item endpoint is called
        // [THEN] productType is ITEM
        _Assert.AreEqual('ITEM', GetSingleItemProductType(ItemNo), 'A wallet trigger on a disabled coupon type must not classify the item as COUPON');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetItem_UnsupportedIssueCouponModule_ReturnsCouponWithoutError()
    var
        CouponType: Record "NPR NpDc Coupon Type";
        AttractionWalletCoupon: Codeunit "NPR AttractionWalletCoupon";
        OnEcomSaleCouponModule: Codeunit "NPR OnEcomSaleCouponModule";
        ItemNo: Code[20];
    begin
        // [SCENARIO] An item mapped to an enabled coupon type with an issue module the ecom import rejects is still COUPON,
        // and the endpoint does not run the import's module eligibility check.

        // [GIVEN] API permission and an enabled Entria store
        Initialize();

        // [GIVEN] An enabled coupon type on the library's DEFAULT issue module, mapped to a new Entria-product item on the ecom-sale setup
        _LibraryCoupon.CreateDiscountAmountCouponType(GenerateCouponTypeCode(), CouponType, 10);
        _Assert.AreNotEqual(OnEcomSaleCouponModule.ModuleCode(), CouponType."Issue Coupon Module", 'Precondition: issue module must be unsupported');
        _Assert.AreNotEqual(AttractionWalletCoupon.ModuleCode(), CouponType."Issue Coupon Module", 'Precondition: issue module must be unsupported');
        ItemNo := _LibraryEcommerce.CreateEcomCouponItemForType(CouponType.Code);
        MarkEntriaProduct(ItemNo);

        // [WHEN] The single item endpoint is called
        // [THEN] The call succeeds and productType is COUPON
        _Assert.AreEqual('COUPON', GetSingleItemProductType(ItemNo), 'The issue module must not affect classification');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetItem_VariantSpecificCouponRowOnly_ReturnsItem()
    var
        CouponType: Record "NPR NpDc Coupon Type";
        EcomSalesCouponSetupLine: Record "NPR NpDc Iss.OnEcomSale S.Line";
        ItemNo: Code[20];
    begin
        // [SCENARIO] An item whose only coupon setup row is for a specific variant is ITEM; item-level classification reads blank-variant rows only.

        // [GIVEN] API permission and an enabled Entria store
        Initialize();

        // [GIVEN] An Entria-product ecom-sale coupon item whose single setup row is moved to a non-blank variant code
        ItemNo := _LibraryEcommerce.CreateEcomCouponItem(CouponType);
        EcomSalesCouponSetupLine.SetRange(Type, EcomSalesCouponSetupLine.Type::Item);
        EcomSalesCouponSetupLine.SetRange("No.", ItemNo);
        _Assert.AreEqual(1, EcomSalesCouponSetupLine.Count(), 'Precondition: exactly one coupon setup row for the item');
        EcomSalesCouponSetupLine.FindFirst();
        EcomSalesCouponSetupLine."Variant Code" := 'V1';
        EcomSalesCouponSetupLine.Modify();
        MarkEntriaProduct(ItemNo);

        // [WHEN] The single item endpoint is called
        // [THEN] productType is ITEM
        _Assert.AreEqual('ITEM', GetSingleItemProductType(ItemNo), 'A variant-specific coupon row must not classify the item as COUPON');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetItem_PlainItem_ReturnsItem()
    var
        ItemNo: Code[20];
    begin
        // [SCENARIO] An item without any product setup is ITEM.

        // [GIVEN] API permission and an enabled Entria store
        Initialize();

        // [GIVEN] A plain Entria-product item
        ItemNo := _LibraryInventory.CreateItemNo();
        MarkEntriaProduct(ItemNo);

        // [WHEN] The single item endpoint is called
        // [THEN] productType is ITEM
        _Assert.AreEqual('ITEM', GetSingleItemProductType(ItemNo), 'A plain item must be ITEM');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetItem_NoEnabledEntriaStore_OmitsProductType()
    var
        Item: Record Item;
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        // [SCENARIO] Without an enabled Entria store an Entria-product item carries neither entriaProduct nor productType.

        // [GIVEN] API permission and no enabled Entria store
        _LibraryNPRetailAPI.CreateAPIPermission(UserSecurityId(), CompanyName(), 'NPR API Inventory');
        _LibraryEntria.DisableAllStores();

        // [GIVEN] An Entria-product ticket item
        Item.Get(CreateTicketItem());
        MarkEntriaProduct(Item."No.");
        SelectLatestVersion();

        // [WHEN] The single item endpoint is called
        Response := _LibraryNPRetailAPI.CallApi('GET', '/inventory/item/' + Format(Item.SystemId, 0, 4).ToLower(), Body, QueryParams, Headers);

        // [THEN] The call succeeds and returns the item
        _Assert.IsTrue(_LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'GET /inventory/item/:id should succeed');
        Body := _LibraryNPRetailAPI.GetResponseBody(Response);
        _Assert.AreEqual(Item."No.", GetText(Body, 'code'), 'Response must return the requested item');

        // [THEN] Neither entriaProduct nor productType is present
        _Assert.IsFalse(Body.Contains('entriaProduct'), 'entriaProduct must be omitted without an enabled Entria store');
        _Assert.IsFalse(Body.Contains('productType'), 'productType must be omitted without an enabled Entria store');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetItem_NonEntriaProduct_OmitsProductType()
    var
        Item: Record Item;
        Response: JsonObject;
        Body: JsonObject;
        JToken: JsonToken;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        // [SCENARIO] With an enabled Entria store an item that is not an Entria product carries entriaProduct = false and no productType.

        // [GIVEN] API permission and an enabled Entria store
        Initialize();

        // [GIVEN] A ticket item that is not an Entria product
        Item.Get(CreateTicketItem());
        _Assert.IsFalse(Item."NPR Entria Product", 'Precondition: the item must not be an Entria product');
        SelectLatestVersion();

        // [WHEN] The single item endpoint is called
        Response := _LibraryNPRetailAPI.CallApi('GET', '/inventory/item/' + Format(Item.SystemId, 0, 4).ToLower(), Body, QueryParams, Headers);

        // [THEN] The call succeeds and returns the item
        _Assert.IsTrue(_LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'GET /inventory/item/:id should succeed');
        Body := _LibraryNPRetailAPI.GetResponseBody(Response);
        _Assert.AreEqual(Item."No.", GetText(Body, 'code'), 'Response must return the requested item');

        // [THEN] entriaProduct is present and false
        _Assert.IsTrue(Body.Get('entriaProduct', JToken), 'entriaProduct must be present with an enabled Entria store');
        _Assert.IsFalse(JToken.AsValue().AsBoolean(), 'entriaProduct must be false for a non-Entria item');

        // [THEN] productType is absent
        _Assert.IsFalse(Body.Contains('productType'), 'productType must be omitted for a non-Entria item');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ListItems_MixedTypesOnOnePage_ClassifiesEachItem()
    var
        CouponType: Record "NPR NpDc Coupon Type";
        WalletCouponType: Record "NPR NpDc Coupon Type";
        MembersAlterSetup: Record "NPR MM Members. Alter. Setup";
        Item: Record Item;
        Expected: Dictionary of [Code[20], Text];
        ItemNo: Code[20];
    begin
        // [SCENARIO] One list page with items of several types classifies each Entria-product item on its own; all items share one
        // request-level map. An item that is not an Entria product gets no productType.

        // [GIVEN] API permission and an enabled Entria store
        Initialize();

        // [GIVEN] An Entria-product attraction package item (wallet flag on a ticket item)
        ItemNo := CreateTicketItem();
        Item.Get(ItemNo);
        Item."NPR CreateAttractionWallet" := true;
        Item.Modify();
        Expected.Add(MarkEntriaProduct(ItemNo), 'ATTRACTION_PACKAGE');

        // [GIVEN] An Entria-product ticket item with a membership sales setup row
        ItemNo := CreateTicketItem();
        InsertMembershipSalesSetup(ItemNo);
        Expected.Add(MarkEntriaProduct(ItemNo), 'TICKET');

        // [GIVEN] An Entria-product membership sales setup item
        ItemNo := _LibraryInventory.CreateItemNo();
        InsertMembershipSalesSetup(ItemNo);
        Expected.Add(MarkEntriaProduct(ItemNo), 'MEMBERSHIP');

        // [GIVEN] An Entria-product UPGRADE alteration item
        ItemNo := _LibraryInventory.CreateItemNo();
        InsertMembershipAlterSetup(ItemNo, MembersAlterSetup."Alteration Type"::UPGRADE);
        Expected.Add(MarkEntriaProduct(ItemNo), 'MEMBERSHIP_UPGRADE');

        // [GIVEN] An Entria-product enabled ecom-sale coupon item
        Expected.Add(MarkEntriaProduct(_LibraryEcommerce.CreateEcomCouponItem(CouponType)), 'COUPON');

        // [GIVEN] An Entria-product item that triggers an enabled wallet coupon type
        Expected.Add(MarkEntriaProduct(CreateWalletCouponItem(WalletCouponType)), 'COUPON');

        // [GIVEN] An Entria-product coupon item whose coupon type is disabled
        Expected.Add(MarkEntriaProduct(CreateDisabledEcomCouponItem()), 'ITEM');

        // [GIVEN] A plain Entria-product item
        Expected.Add(MarkEntriaProduct(_LibraryInventory.CreateItemNo()), 'ITEM');

        // [GIVEN] An Entria-product ticket-only item
        Expected.Add(MarkEntriaProduct(CreateTicketItem()), 'TICKET');

        // [GIVEN] A ticket item that is not an Entria product
        Expected.Add(CreateTicketItem(), '');

        // [WHEN] The item list is requested
        // [THEN] Every fixture item is listed with its expected productType; the non-Entria item has none
        AssertListedProductTypes(Expected);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ListItems_EachAlterationType_MapsToItsProductType()
    var
        MembersAlterSetup: Record "NPR MM Members. Alter. Setup";
        Expected: Dictionary of [Code[20], Text];
    begin
        // [SCENARIO] Each alteration type classifies its sales item as MEMBERSHIP_<alteration type>.

        // [GIVEN] API permission and an enabled Entria store
        Initialize();

        // [GIVEN] Six Entria-product items, each with one alteration row of a different alteration type
        Expected.Add(MarkEntriaProduct(CreateAlterationItem(MembersAlterSetup."Alteration Type"::RENEW)), 'MEMBERSHIP_RENEW');
        Expected.Add(MarkEntriaProduct(CreateAlterationItem(MembersAlterSetup."Alteration Type"::EXTEND)), 'MEMBERSHIP_EXTEND');
        Expected.Add(MarkEntriaProduct(CreateAlterationItem(MembersAlterSetup."Alteration Type"::UPGRADE)), 'MEMBERSHIP_UPGRADE');
        Expected.Add(MarkEntriaProduct(CreateAlterationItem(MembersAlterSetup."Alteration Type"::AUTORENEW)), 'MEMBERSHIP_AUTORENEW');
        Expected.Add(MarkEntriaProduct(CreateAlterationItem(MembersAlterSetup."Alteration Type"::REGRET)), 'MEMBERSHIP_REGRET');
        Expected.Add(MarkEntriaProduct(CreateAlterationItem(MembersAlterSetup."Alteration Type"::CANCEL)), 'MEMBERSHIP_CANCEL');

        // [WHEN] The list endpoint is called without filters
        // [THEN] Every fixture item is on the page with the productType of its alteration type
        AssertListedProductTypes(Expected);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ListItems_ItemOnSeveralAlterationTypes_UsesFixedOrder()
    var
        MembersAlterSetup: Record "NPR MM Members. Alter. Setup";
        Expected: Dictionary of [Code[20], Text];
        ItemNo: Code[20];
    begin
        // [SCENARIO] An item on several alteration types gets the type that comes first in the order
        // RENEW, EXTEND, UPGRADE, AUTORENEW, REGRET, CANCEL.

        // [GIVEN] API permission and an enabled Entria store
        Initialize();

        // [GIVEN] Five Entria-product items, each with alteration rows of two neighbouring alteration types
        ItemNo := CreateAlterationItem(MembersAlterSetup."Alteration Type"::RENEW);
        InsertMembershipAlterSetup(ItemNo, MembersAlterSetup."Alteration Type"::EXTEND);
        Expected.Add(MarkEntriaProduct(ItemNo), 'MEMBERSHIP_RENEW');

        ItemNo := CreateAlterationItem(MembersAlterSetup."Alteration Type"::EXTEND);
        InsertMembershipAlterSetup(ItemNo, MembersAlterSetup."Alteration Type"::UPGRADE);
        Expected.Add(MarkEntriaProduct(ItemNo), 'MEMBERSHIP_EXTEND');

        ItemNo := CreateAlterationItem(MembersAlterSetup."Alteration Type"::UPGRADE);
        InsertMembershipAlterSetup(ItemNo, MembersAlterSetup."Alteration Type"::AUTORENEW);
        Expected.Add(MarkEntriaProduct(ItemNo), 'MEMBERSHIP_UPGRADE');

        ItemNo := CreateAlterationItem(MembersAlterSetup."Alteration Type"::AUTORENEW);
        InsertMembershipAlterSetup(ItemNo, MembersAlterSetup."Alteration Type"::REGRET);
        Expected.Add(MarkEntriaProduct(ItemNo), 'MEMBERSHIP_AUTORENEW');

        ItemNo := CreateAlterationItem(MembersAlterSetup."Alteration Type"::REGRET);
        InsertMembershipAlterSetup(ItemNo, MembersAlterSetup."Alteration Type"::CANCEL);
        Expected.Add(MarkEntriaProduct(ItemNo), 'MEMBERSHIP_REGRET');

        // [WHEN] The list endpoint is called without filters
        // [THEN] Every fixture item is on the page with the productType of its first alteration type in the order
        AssertListedProductTypes(Expected);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetItem_TicketOnly_ReturnsTicket()
    var
        ItemNo: Code[20];
    begin
        // [SCENARIO] A ticket item with no membership or coupon setup rows is TICKET.

        // [GIVEN] API permission and an enabled Entria store
        Initialize();

        // [GIVEN] An Entria-product ticket item and nothing else
        ItemNo := CreateTicketItem();
        MarkEntriaProduct(ItemNo);

        // [WHEN] The single item endpoint is called
        // [THEN] productType is TICKET
        _Assert.AreEqual('TICKET', GetSingleItemProductType(ItemNo), 'A ticket item without setup rows must be TICKET');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Sync_MembershipSalesSetupOfTypeItem_ReturnsOnlyThatItem()
    var
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        ProductTypes: Dictionary of [Code[20], Text];
        RowVersions: Dictionary of [Code[20], BigInteger];
        ItemP: Code[20];
        ItemN: Code[20];
        ItemQ: Code[20];
        NextPageKey: Text;
        Cursor: BigInteger;
        RowVersionP: BigInteger;
    begin
        // [SCENARIO] B1: a membership sales setup row of type ITEM returns its item as MEMBERSHIP, a row of another type returns nothing, and the next call from the returned rowVersion does not return the item again.

        // [GIVEN] Entria items P, N and Q
        Initialize();
        ItemP := MarkEntriaProduct(_LibraryInventory.CreateItemNo());
        ItemN := MarkEntriaProduct(_LibraryInventory.CreateItemNo());
        ItemQ := MarkEntriaProduct(_LibraryInventory.CreateItemNo());
        Cursor := Database.LastUsedRowVersion();

        // [GIVEN] After the cursor: a sales setup row of type ITEM for P and one of type ACCOUNT for N
        InsertMembershipSalesSetup(ItemP);
        InsertMembershipSalesSetupOfType(ItemN, MembershipSalesSetup.Type::ACCOUNT);
        Commit();

        // [WHEN] The items are synced from the cursor
        ReadSyncPage(Cursor, '', 0, '', ProductTypes, RowVersions, NextPageKey);

        // [THEN] P is returned as MEMBERSHIP above the cursor, and N is not returned and has no change row in the window
        _Assert.IsTrue(ProductTypes.ContainsKey(ItemP), 'P must be returned with a productType.');
        _Assert.AreEqual('MEMBERSHIP', ProductTypes.Get(ItemP), 'P must be MEMBERSHIP.');
        RowVersionP := RowVersions.Get(ItemP);
        _Assert.IsTrue(RowVersionP > Cursor, 'P must be returned above the cursor.');
        AssertChangePathGuards(ItemP, Cursor);
        _Assert.IsFalse(RowVersions.ContainsKey(ItemN), 'A sales setup row of another type must not return N.');
        _Assert.IsTrue(_ItemChangeMgt.GetChangeRowVersion(ItemN) <= Cursor, 'A sales setup row of another type must not mark N.');

        // [GIVEN] A sales setup row of type ITEM for Q
        InsertMembershipSalesSetup(ItemQ);
        Commit();

        // [WHEN] The items are synced from P's returned rowVersion
        _Assert.IsFalse(ReadSyncPage(RowVersionP, '', 0, '', ProductTypes, RowVersions, NextPageKey), 'Call 2 must be the last page.');

        // [THEN] Q is returned as MEMBERSHIP, and P is not returned again
        _Assert.IsTrue(ProductTypes.ContainsKey(ItemQ), 'Q must be returned with a productType.');
        _Assert.AreEqual('MEMBERSHIP', ProductTypes.Get(ItemQ), 'Q must be MEMBERSHIP.');
        _Assert.IsFalse(RowVersions.ContainsKey(ItemP), 'P must not be returned again.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Sync_MembershipSalesSetupDeleted_ReturnsItemAsItem()
    var
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        ProductTypes: Dictionary of [Code[20], Text];
        RowVersions: Dictionary of [Code[20], BigInteger];
        ItemA: Code[20];
        NextPageKey: Text;
        Cursor: BigInteger;
    begin
        // [SCENARIO] B2: deleting the membership sales setup row of an Entria item returns the item as ITEM.

        // [GIVEN] Entria item A with a membership sales setup row
        Initialize();
        ItemA := MarkEntriaProduct(_LibraryInventory.CreateItemNo());
        InsertMembershipSalesSetup(ItemA);
        Cursor := Database.LastUsedRowVersion();

        // [GIVEN] After the cursor the setup row is deleted
        MembershipSalesSetup.Get(MembershipSalesSetup.Type::ITEM, ItemA);
        MembershipSalesSetup.Delete();
        Commit();

        // [WHEN] The items are synced from the cursor
        ReadSyncPage(Cursor, '', 0, '', ProductTypes, RowVersions, NextPageKey);

        // [THEN] A is returned as ITEM
        _Assert.IsTrue(ProductTypes.ContainsKey(ItemA), 'A must be returned with a productType.');
        _Assert.AreEqual('ITEM', ProductTypes.Get(ItemA), 'A must be ITEM after its setup row is deleted.');
        AssertChangePathGuards(ItemA, Cursor);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Sync_MembershipSalesSetupRenamed_ReturnsOldAndNewItem()
    var
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        ProductTypes: Dictionary of [Code[20], Text];
        RowVersions: Dictionary of [Code[20], BigInteger];
        ItemA: Code[20];
        ItemB: Code[20];
        NextPageKey: Text;
        Cursor: BigInteger;
    begin
        // [SCENARIO] B3: renaming a membership sales setup row from item A to item B returns A as ITEM and B as MEMBERSHIP.

        // [GIVEN] Entria items A and B, and a membership sales setup row for A
        Initialize();
        ItemA := MarkEntriaProduct(_LibraryInventory.CreateItemNo());
        ItemB := MarkEntriaProduct(_LibraryInventory.CreateItemNo());
        InsertMembershipSalesSetup(ItemA);
        Cursor := Database.LastUsedRowVersion();

        // [GIVEN] After the cursor the setup row is renamed to B
        MembershipSalesSetup.Get(MembershipSalesSetup.Type::ITEM, ItemA);
        MembershipSalesSetup.Rename(MembershipSalesSetup.Type::ITEM, ItemB);
        Commit();

        // [WHEN] The items are synced from the cursor
        ReadSyncPage(Cursor, '', 0, '', ProductTypes, RowVersions, NextPageKey);

        // [THEN] A is ITEM and B is MEMBERSHIP
        _Assert.IsTrue(ProductTypes.ContainsKey(ItemA), 'A must be returned with a productType.');
        _Assert.AreEqual('ITEM', ProductTypes.Get(ItemA), 'A must be ITEM after the rename.');
        _Assert.IsTrue(ProductTypes.ContainsKey(ItemB), 'B must be returned with a productType.');
        _Assert.AreEqual('MEMBERSHIP', ProductTypes.Get(ItemB), 'B must be MEMBERSHIP after the rename.');
        AssertChangePathGuards(ItemA, Cursor);
        AssertChangePathGuards(ItemB, Cursor);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Sync_MembershipAlterSetupInserted_ReturnsAlterationType()
    var
        MembersAlterSetup: Record "NPR MM Members. Alter. Setup";
        ProductTypes: Dictionary of [Code[20], Text];
        RowVersions: Dictionary of [Code[20], BigInteger];
        ItemA: Code[20];
        NextPageKey: Text;
        Cursor: BigInteger;
    begin
        // [SCENARIO] B4: inserting a RENEW alteration setup row returns its sales item as MEMBERSHIP_RENEW.

        // [GIVEN] Entria item A
        Initialize();
        ItemA := MarkEntriaProduct(_LibraryInventory.CreateItemNo());
        Cursor := Database.LastUsedRowVersion();

        // [GIVEN] After the cursor a RENEW alteration setup row for A
        InsertMembershipAlterSetup(ItemA, MembersAlterSetup."Alteration Type"::RENEW);
        Commit();

        // [WHEN] The items are synced from the cursor
        ReadSyncPage(Cursor, '', 0, '', ProductTypes, RowVersions, NextPageKey);

        // [THEN] A is MEMBERSHIP_RENEW
        _Assert.IsTrue(ProductTypes.ContainsKey(ItemA), 'A must be returned with a productType.');
        _Assert.AreEqual('MEMBERSHIP_RENEW', ProductTypes.Get(ItemA), 'A must be MEMBERSHIP_RENEW.');
        AssertChangePathGuards(ItemA, Cursor);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Sync_MembershipAlterSetupRenamedToCancelOnOtherItem_ReturnsOldAndNewItem()
    var
        MembersAlterSetup: Record "NPR MM Members. Alter. Setup";
        ProductTypes: Dictionary of [Code[20], Text];
        RowVersions: Dictionary of [Code[20], BigInteger];
        ItemA: Code[20];
        ItemB: Code[20];
        NextPageKey: Text;
        Cursor: BigInteger;
    begin
        // [SCENARIO] B5: renaming a RENEW alteration setup row for item A to a CANCEL row for item B returns A as ITEM and B as MEMBERSHIP_CANCEL.

        // [GIVEN] Entria items A and B, and a RENEW alteration setup row for A
        Initialize();
        ItemA := MarkEntriaProduct(_LibraryInventory.CreateItemNo());
        ItemB := MarkEntriaProduct(_LibraryInventory.CreateItemNo());
        InsertMembershipAlterSetup(ItemA, MembersAlterSetup."Alteration Type"::RENEW);
        Cursor := Database.LastUsedRowVersion();

        // [GIVEN] After the cursor the row is renamed to CANCEL for B, keeping its from-membership code
        MembersAlterSetup.SetRange("Sales Item No.", ItemA);
        MembersAlterSetup.FindFirst();
        MembersAlterSetup.Rename(MembersAlterSetup."Alteration Type"::CANCEL, MembersAlterSetup."From Membership Code", ItemB);
        Commit();

        // [WHEN] The items are synced from the cursor
        ReadSyncPage(Cursor, '', 0, '', ProductTypes, RowVersions, NextPageKey);

        // [THEN] A is ITEM and B is MEMBERSHIP_CANCEL
        _Assert.IsTrue(ProductTypes.ContainsKey(ItemA), 'A must be returned with a productType.');
        _Assert.AreEqual('ITEM', ProductTypes.Get(ItemA), 'A must be ITEM after the row moved to B.');
        _Assert.IsTrue(ProductTypes.ContainsKey(ItemB), 'B must be returned with a productType.');
        _Assert.AreEqual('MEMBERSHIP_CANCEL', ProductTypes.Get(ItemB), 'B must be MEMBERSHIP_CANCEL after the rename.');
        AssertChangePathGuards(ItemA, Cursor);
        AssertChangePathGuards(ItemB, Cursor);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Sync_MembershipAlterSetupDeleted_ReturnsItemAsItem()
    var
        MembersAlterSetup: Record "NPR MM Members. Alter. Setup";
        ProductTypes: Dictionary of [Code[20], Text];
        RowVersions: Dictionary of [Code[20], BigInteger];
        ItemA: Code[20];
        NextPageKey: Text;
        Cursor: BigInteger;
    begin
        // [SCENARIO] B6: deleting the alteration setup row of an Entria item returns the item as ITEM.

        // [GIVEN] Entria item A with a RENEW alteration setup row
        Initialize();
        ItemA := MarkEntriaProduct(_LibraryInventory.CreateItemNo());
        InsertMembershipAlterSetup(ItemA, MembersAlterSetup."Alteration Type"::RENEW);
        Cursor := Database.LastUsedRowVersion();

        // [GIVEN] After the cursor the row is deleted
        MembersAlterSetup.SetRange("Sales Item No.", ItemA);
        MembersAlterSetup.FindFirst();
        MembersAlterSetup.Delete(true);
        Commit();

        // [WHEN] The items are synced from the cursor
        ReadSyncPage(Cursor, '', 0, '', ProductTypes, RowVersions, NextPageKey);

        // [THEN] A is ITEM
        _Assert.IsTrue(ProductTypes.ContainsKey(ItemA), 'A must be returned with a productType.');
        _Assert.AreEqual('ITEM', ProductTypes.Get(ItemA), 'A must be ITEM after its alteration setup row is deleted.');
        AssertChangePathGuards(ItemA, Cursor);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Sync_WalletCouponSetupInsertedThenMovedToOtherItem_ReturnsBothItems()
    var
        WalletCouponSetup: Record "NPR WalletCouponSetup";
        ProductTypes: Dictionary of [Code[20], Text];
        RowVersions: Dictionary of [Code[20], BigInteger];
        CouponTypeCode: Code[20];
        ItemA: Code[20];
        ItemB: Code[20];
        NextPageKey: Text;
        Cursor: BigInteger;
        SecondCursor: BigInteger;
    begin
        // [SCENARIO] B7: a wallet coupon setup row returns its item as COUPON, and moving it to another item returns the old item as ITEM and the new one as COUPON.

        // [GIVEN] An enabled coupon type and Entria items A and B
        Initialize();
        CouponTypeCode := GenerateCouponTypeCode();
        InsertCouponType(CouponTypeCode, true);
        ItemA := MarkEntriaProduct(_LibraryInventory.CreateItemNo());
        ItemB := MarkEntriaProduct(_LibraryInventory.CreateItemNo());
        Cursor := Database.LastUsedRowVersion();

        // [GIVEN] After the cursor a wallet coupon setup row for A
        InsertWalletCouponSetup(CouponTypeCode, ItemA);
        Commit();

        // [WHEN] The items are synced from the cursor
        ReadSyncPage(Cursor, '', 0, '', ProductTypes, RowVersions, NextPageKey);

        // [THEN] A is COUPON
        _Assert.IsTrue(ProductTypes.ContainsKey(ItemA), 'A must be returned with a productType.');
        _Assert.AreEqual('COUPON', ProductTypes.Get(ItemA), 'A must be COUPON after the wallet row insert.');
        AssertChangePathGuards(ItemA, Cursor);

        // [GIVEN] After a second cursor the wallet row is moved from A to B
        SecondCursor := Database.LastUsedRowVersion();
        WalletCouponSetup.Get(CouponTypeCode);
        WalletCouponSetup.TriggerOnItemNo := ItemB;
        WalletCouponSetup.Modify();
        Commit();

        // [WHEN] The items are synced from the second cursor
        ReadSyncPage(SecondCursor, '', 0, '', ProductTypes, RowVersions, NextPageKey);

        // [THEN] A is ITEM and B is COUPON
        _Assert.IsTrue(ProductTypes.ContainsKey(ItemA), 'A must be returned with a productType.');
        _Assert.AreEqual('ITEM', ProductTypes.Get(ItemA), 'A must be ITEM after the wallet row moved away.');
        _Assert.IsTrue(ProductTypes.ContainsKey(ItemB), 'B must be returned with a productType.');
        _Assert.AreEqual('COUPON', ProductTypes.Get(ItemB), 'B must be COUPON after the wallet row moved to it.');
        AssertChangePathGuards(ItemA, SecondCursor);
        AssertChangePathGuards(ItemB, SecondCursor);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Sync_WalletCouponSetupDeleted_ReturnsItemAsItem()
    var
        WalletCouponSetup: Record "NPR WalletCouponSetup";
        ProductTypes: Dictionary of [Code[20], Text];
        RowVersions: Dictionary of [Code[20], BigInteger];
        CouponTypeCode: Code[20];
        ItemA: Code[20];
        NextPageKey: Text;
        Cursor: BigInteger;
    begin
        // [SCENARIO] B8: deleting the wallet coupon setup row of an Entria item returns the item as ITEM.

        // [GIVEN] An enabled coupon type with a wallet coupon setup row for Entria item A
        Initialize();
        CouponTypeCode := GenerateCouponTypeCode();
        InsertCouponType(CouponTypeCode, true);
        ItemA := MarkEntriaProduct(_LibraryInventory.CreateItemNo());
        InsertWalletCouponSetup(CouponTypeCode, ItemA);
        Cursor := Database.LastUsedRowVersion();

        // [GIVEN] After the cursor the wallet row is deleted
        WalletCouponSetup.Get(CouponTypeCode);
        WalletCouponSetup.Delete(true);
        Commit();

        // [WHEN] The items are synced from the cursor
        ReadSyncPage(Cursor, '', 0, '', ProductTypes, RowVersions, NextPageKey);

        // [THEN] A is ITEM
        _Assert.IsTrue(ProductTypes.ContainsKey(ItemA), 'A must be returned with a productType.');
        _Assert.AreEqual('ITEM', ProductTypes.Get(ItemA), 'A must be ITEM after its wallet row is deleted.');
        AssertChangePathGuards(ItemA, Cursor);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Sync_WalletCouponSetupRenamedToDisabledCouponType_ReturnsItemAsItem()
    var
        WalletCouponSetup: Record "NPR WalletCouponSetup";
        ProductTypes: Dictionary of [Code[20], Text];
        RowVersions: Dictionary of [Code[20], BigInteger];
        EnabledCouponTypeCode: Code[20];
        DisabledCouponTypeCode: Code[20];
        ItemX: Code[20];
        NextPageKey: Text;
        Cursor: BigInteger;
    begin
        // [SCENARIO] Renaming a wallet coupon setup row from an enabled to a disabled coupon type returns its item as ITEM.

        // [GIVEN] An enabled coupon type CT1, a disabled coupon type CT2 without a wallet row, and a CT1 wallet row for Entria item X
        Initialize();
        EnabledCouponTypeCode := GenerateCouponTypeCode();
        InsertCouponType(EnabledCouponTypeCode, true);
        DisabledCouponTypeCode := GenerateCouponTypeCode();
        InsertCouponType(DisabledCouponTypeCode, false);
        ItemX := MarkEntriaProduct(_LibraryInventory.CreateItemNo());
        InsertWalletCouponSetup(EnabledCouponTypeCode, ItemX);
        _Assert.AreEqual('COUPON', GetSingleItemProductType(ItemX), 'Test setup: X must be COUPON before the rename.');
        Cursor := Database.LastUsedRowVersion();

        // [GIVEN] After the cursor the wallet row is renamed to CT2
        WalletCouponSetup.Get(EnabledCouponTypeCode);
        WalletCouponSetup.Rename(DisabledCouponTypeCode);
        Commit();

        // [WHEN] The items are synced from the cursor
        ReadSyncPage(Cursor, '', 0, '', ProductTypes, RowVersions, NextPageKey);

        // [THEN] X is ITEM
        _Assert.IsTrue(ProductTypes.ContainsKey(ItemX), 'X must be returned with a productType.');
        _Assert.AreEqual('ITEM', ProductTypes.Get(ItemX), 'X must be ITEM once its wallet row belongs to a disabled coupon type.');
        AssertChangePathGuards(ItemX, Cursor);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Sync_EcomCouponLineInserted_ReturnsItemAsCoupon()
    var
        ProductTypes: Dictionary of [Code[20], Text];
        RowVersions: Dictionary of [Code[20], BigInteger];
        CouponTypeCode: Code[20];
        ItemX: Code[20];
        NextPageKey: Text;
        Cursor: BigInteger;
    begin
        // [SCENARIO] B9: inserting an ecommerce coupon line for an enabled coupon type returns its item as COUPON.

        // [GIVEN] An enabled coupon type and Entria item X
        Initialize();
        CouponTypeCode := GenerateCouponTypeCode();
        InsertCouponType(CouponTypeCode, true);
        ItemX := MarkEntriaProduct(_LibraryInventory.CreateItemNo());
        Cursor := Database.LastUsedRowVersion();

        // [GIVEN] After the cursor an ecommerce coupon line for X
        _LibraryEcommerce.CreateEcomCouponLine(CouponTypeCode, ItemX);
        Commit();

        // [WHEN] The items are synced from the cursor
        ReadSyncPage(Cursor, '', 0, '', ProductTypes, RowVersions, NextPageKey);

        // [THEN] X is COUPON
        _Assert.IsTrue(ProductTypes.ContainsKey(ItemX), 'X must be returned with a productType.');
        _Assert.AreEqual('COUPON', ProductTypes.Get(ItemX), 'X must be COUPON after the ecommerce coupon line insert.');
        AssertChangePathGuards(ItemX, Cursor);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Sync_EcomCouponLineVariantCodeSet_ReturnsItemAsItem()
    var
        EcomSaleCouponLine: Record "NPR NpDc Iss.OnEcomSale S.Line";
        ProductTypes: Dictionary of [Code[20], Text];
        RowVersions: Dictionary of [Code[20], BigInteger];
        CouponTypeCode: Code[20];
        ItemX: Code[20];
        NextPageKey: Text;
        Cursor: BigInteger;
    begin
        // [SCENARIO] B10: setting a variant code on an ecommerce coupon line returns its item as ITEM, because only lines without a variant code classify the item.

        // [GIVEN] An enabled coupon type with an ecommerce coupon line for Entria item X
        Initialize();
        CouponTypeCode := GenerateCouponTypeCode();
        InsertCouponType(CouponTypeCode, true);
        ItemX := MarkEntriaProduct(_LibraryInventory.CreateItemNo());
        _LibraryEcommerce.CreateEcomCouponLine(CouponTypeCode, ItemX);
        Cursor := Database.LastUsedRowVersion();

        // [GIVEN] After the cursor the line gets a variant code
        EcomSaleCouponLine.SetRange("Coupon Type", CouponTypeCode);
        EcomSaleCouponLine.FindFirst();
        EcomSaleCouponLine."Variant Code" := 'V1';
        EcomSaleCouponLine.Modify();
        Commit();

        // [WHEN] The items are synced from the cursor
        ReadSyncPage(Cursor, '', 0, '', ProductTypes, RowVersions, NextPageKey);

        // [THEN] X is ITEM
        _Assert.IsTrue(ProductTypes.ContainsKey(ItemX), 'X must be returned with a productType.');
        _Assert.AreEqual('ITEM', ProductTypes.Get(ItemX), 'X must be ITEM once its line has a variant code.');
        AssertChangePathGuards(ItemX, Cursor);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Sync_EcomCouponLineVariantCodeCleared_ReturnsItemAsCoupon()
    var
        EcomSaleCouponLine: Record "NPR NpDc Iss.OnEcomSale S.Line";
        ProductTypes: Dictionary of [Code[20], Text];
        RowVersions: Dictionary of [Code[20], BigInteger];
        CouponTypeCode: Code[20];
        ItemX: Code[20];
        NextPageKey: Text;
        Cursor: BigInteger;
    begin
        // [SCENARIO] Clearing the variant code on an ecommerce coupon line returns its item as COUPON. Only the after-modify side can mark the item.

        // [GIVEN] An enabled coupon type and an ecommerce coupon line with variant code V1 for Entria item X
        Initialize();
        CouponTypeCode := GenerateCouponTypeCode();
        InsertCouponType(CouponTypeCode, true);
        ItemX := MarkEntriaProduct(_LibraryInventory.CreateItemNo());
        EcomSaleCouponLine.Init();
        EcomSaleCouponLine."Coupon Type" := CouponTypeCode;
        EcomSaleCouponLine."Line No." := 10000;
        EcomSaleCouponLine.Type := EcomSaleCouponLine.Type::Item;
        EcomSaleCouponLine."No." := ItemX;
        EcomSaleCouponLine."Variant Code" := 'V1';
        EcomSaleCouponLine.Insert();
        _Assert.AreEqual('ITEM', GetSingleItemProductType(ItemX), 'Test setup: X must be ITEM while its line has a variant code.');
        Cursor := Database.LastUsedRowVersion();

        // [GIVEN] After the cursor the variant code is cleared
        EcomSaleCouponLine.Get(CouponTypeCode, 10000);
        EcomSaleCouponLine."Variant Code" := '';
        EcomSaleCouponLine.Modify();
        Commit();

        // [WHEN] The items are synced from the cursor
        ReadSyncPage(Cursor, '', 0, '', ProductTypes, RowVersions, NextPageKey);

        // [THEN] X is COUPON
        _Assert.IsTrue(ProductTypes.ContainsKey(ItemX), 'X must be returned with a productType.');
        _Assert.AreEqual('COUPON', ProductTypes.Get(ItemX), 'X must be COUPON once its line has no variant code.');
        AssertChangePathGuards(ItemX, Cursor);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Sync_EcomCouponLineRenamedToOtherCouponType_ReturnsItemAsCoupon()
    var
        EcomSaleCouponLine: Record "NPR NpDc Iss.OnEcomSale S.Line";
        ProductTypes: Dictionary of [Code[20], Text];
        RowVersions: Dictionary of [Code[20], BigInteger];
        CouponTypeCode: Code[20];
        OtherCouponTypeCode: Code[20];
        ItemX: Code[20];
        NextPageKey: Text;
        Cursor: BigInteger;
    begin
        // [SCENARIO] Renaming an ecommerce coupon line to another enabled coupon type returns its item as COUPON.

        // [GIVEN] Enabled coupon types CT1 and CT2, and a CT1 ecommerce coupon line for Entria item X
        Initialize();
        CouponTypeCode := GenerateCouponTypeCode();
        InsertCouponType(CouponTypeCode, true);
        OtherCouponTypeCode := GenerateCouponTypeCode();
        InsertCouponType(OtherCouponTypeCode, true);
        ItemX := MarkEntriaProduct(_LibraryInventory.CreateItemNo());
        _LibraryEcommerce.CreateEcomCouponLine(CouponTypeCode, ItemX);
        Cursor := Database.LastUsedRowVersion();

        // [GIVEN] After the cursor the line is renamed to CT2
        EcomSaleCouponLine.SetRange("Coupon Type", CouponTypeCode);
        EcomSaleCouponLine.FindFirst();
        EcomSaleCouponLine.Rename(OtherCouponTypeCode, EcomSaleCouponLine."Line No.");
        Commit();

        // [WHEN] The items are synced from the cursor
        ReadSyncPage(Cursor, '', 0, '', ProductTypes, RowVersions, NextPageKey);

        // [THEN] X is COUPON
        _Assert.IsTrue(ProductTypes.ContainsKey(ItemX), 'X must be returned with a productType.');
        _Assert.AreEqual('COUPON', ProductTypes.Get(ItemX), 'X must be COUPON after its line moved to CT2.');
        AssertChangePathGuards(ItemX, Cursor);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Sync_EcomCouponLinesDeletedWithoutTrigger_ReturnsItemsAsItem()
    var
        EcomSaleCouponLine: Record "NPR NpDc Iss.OnEcomSale S.Line";
        ProductTypes: Dictionary of [Code[20], Text];
        RowVersions: Dictionary of [Code[20], BigInteger];
        CouponTypeCode: Code[20];
        ItemX: Code[20];
        ItemY: Code[20];
        NextPageKey: Text;
        Cursor: BigInteger;
    begin
        // [SCENARIO] B11: removing a coupon type's ecommerce coupon lines with DeleteAll() and no trigger returns their items as ITEM.

        // [GIVEN] An enabled coupon type with ecommerce coupon lines for Entria items X and Y
        Initialize();
        CouponTypeCode := GenerateCouponTypeCode();
        InsertCouponType(CouponTypeCode, true);
        ItemX := MarkEntriaProduct(_LibraryInventory.CreateItemNo());
        ItemY := MarkEntriaProduct(_LibraryInventory.CreateItemNo());
        _LibraryEcommerce.CreateEcomCouponLine(CouponTypeCode, ItemX);
        _LibraryEcommerce.CreateEcomCouponLine(CouponTypeCode, ItemY);
        Cursor := Database.LastUsedRowVersion();

        // [GIVEN] After the cursor the lines are removed as the coupon module's cleanup does
        EcomSaleCouponLine.SetRange("Coupon Type", CouponTypeCode);
        EcomSaleCouponLine.DeleteAll();
        Commit();

        // [WHEN] The items are synced from the cursor
        ReadSyncPage(Cursor, '', 0, '', ProductTypes, RowVersions, NextPageKey);

        // [THEN] X and Y are ITEM
        _Assert.IsTrue(ProductTypes.ContainsKey(ItemX), 'X must be returned with a productType.');
        _Assert.AreEqual('ITEM', ProductTypes.Get(ItemX), 'X must be ITEM after its line is deleted.');
        _Assert.IsTrue(ProductTypes.ContainsKey(ItemY), 'Y must be returned with a productType.');
        _Assert.AreEqual('ITEM', ProductTypes.Get(ItemY), 'Y must be ITEM after its line is deleted.');
        AssertChangePathGuards(ItemX, Cursor);
        AssertChangePathGuards(ItemY, Cursor);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Sync_CouponTypeDisabled_ReturnsChildItemsAsItem()
    var
        CouponType: Record "NPR NpDc Coupon Type";
        ProductTypes: Dictionary of [Code[20], Text];
        RowVersions: Dictionary of [Code[20], BigInteger];
        CouponTypeCode: Code[20];
        WalletItem: Code[20];
        EcomItem: Code[20];
        NextPageKey: Text;
        Cursor: BigInteger;
    begin
        // [SCENARIO] B12: disabling a coupon type returns the items of its wallet row and ecommerce line as ITEM.

        // [GIVEN] An enabled coupon type with a wallet row and an ecommerce line, each for an Entria item
        Initialize();
        CouponTypeCode := GenerateCouponTypeCode();
        InsertCouponType(CouponTypeCode, true);
        WalletItem := MarkEntriaProduct(_LibraryInventory.CreateItemNo());
        EcomItem := MarkEntriaProduct(_LibraryInventory.CreateItemNo());
        InsertWalletCouponSetup(CouponTypeCode, WalletItem);
        _LibraryEcommerce.CreateEcomCouponLine(CouponTypeCode, EcomItem);
        Cursor := Database.LastUsedRowVersion();

        // [GIVEN] After the cursor the coupon type is disabled
        CouponType.Get(CouponTypeCode);
        CouponType.Enabled := false;
        CouponType.Modify(false);
        Commit();

        // [WHEN] The items are synced from the cursor
        ReadSyncPage(Cursor, '', 0, '', ProductTypes, RowVersions, NextPageKey);

        // [THEN] Both items are ITEM
        _Assert.IsTrue(ProductTypes.ContainsKey(WalletItem), 'The wallet item must be returned with a productType.');
        _Assert.AreEqual('ITEM', ProductTypes.Get(WalletItem), 'The wallet item must be ITEM after the coupon type is disabled.');
        _Assert.IsTrue(ProductTypes.ContainsKey(EcomItem), 'The ecommerce item must be returned with a productType.');
        _Assert.AreEqual('ITEM', ProductTypes.Get(EcomItem), 'The ecommerce item must be ITEM after the coupon type is disabled.');
        AssertChangePathGuards(WalletItem, Cursor);
        AssertChangePathGuards(EcomItem, Cursor);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Sync_CouponTypeEnabled_ReturnsChildItemsAsCoupon()
    var
        CouponType: Record "NPR NpDc Coupon Type";
        ProductTypes: Dictionary of [Code[20], Text];
        RowVersions: Dictionary of [Code[20], BigInteger];
        CouponTypeCode: Code[20];
        WalletItem: Code[20];
        EcomItem: Code[20];
        NextPageKey: Text;
        Cursor: BigInteger;
    begin
        // [SCENARIO] B13: enabling a coupon type returns the items of its wallet row and ecommerce line as COUPON.

        // [GIVEN] A disabled coupon type with a wallet row and an ecommerce line, each for an Entria item
        Initialize();
        CouponTypeCode := GenerateCouponTypeCode();
        InsertCouponType(CouponTypeCode, false);
        WalletItem := MarkEntriaProduct(_LibraryInventory.CreateItemNo());
        EcomItem := MarkEntriaProduct(_LibraryInventory.CreateItemNo());
        InsertWalletCouponSetup(CouponTypeCode, WalletItem);
        _LibraryEcommerce.CreateEcomCouponLine(CouponTypeCode, EcomItem);
        Cursor := Database.LastUsedRowVersion();

        // [GIVEN] After the cursor the coupon type is enabled
        CouponType.Get(CouponTypeCode);
        CouponType.Enabled := true;
        CouponType.Modify(false);
        Commit();

        // [WHEN] The items are synced from the cursor
        ReadSyncPage(Cursor, '', 0, '', ProductTypes, RowVersions, NextPageKey);

        // [THEN] Both items are COUPON
        _Assert.IsTrue(ProductTypes.ContainsKey(WalletItem), 'The wallet item must be returned with a productType.');
        _Assert.AreEqual('COUPON', ProductTypes.Get(WalletItem), 'The wallet item must be COUPON after the coupon type is enabled.');
        _Assert.IsTrue(ProductTypes.ContainsKey(EcomItem), 'The ecommerce item must be returned with a productType.');
        _Assert.AreEqual('COUPON', ProductTypes.Get(EcomItem), 'The ecommerce item must be COUPON after the coupon type is enabled.');
        AssertChangePathGuards(WalletItem, Cursor);
        AssertChangePathGuards(EcomItem, Cursor);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Sync_CouponTypeDeletedWithoutTrigger_ReturnsChildItemsAsItem()
    var
        CouponType: Record "NPR NpDc Coupon Type";
        ProductTypes: Dictionary of [Code[20], Text];
        RowVersions: Dictionary of [Code[20], BigInteger];
        CouponTypeCode: Code[20];
        WalletItem: Code[20];
        EcomItem: Code[20];
        NextPageKey: Text;
        Cursor: BigInteger;
    begin
        // [SCENARIO] B14: deleting an enabled coupon type with Delete(false) returns its children's items as ITEM, including the item of the ecommerce line left behind.

        // [GIVEN] An enabled coupon type with a wallet row and an ecommerce line, each for an Entria item
        Initialize();
        CouponTypeCode := GenerateCouponTypeCode();
        InsertCouponType(CouponTypeCode, true);
        WalletItem := MarkEntriaProduct(_LibraryInventory.CreateItemNo());
        EcomItem := MarkEntriaProduct(_LibraryInventory.CreateItemNo());
        InsertWalletCouponSetup(CouponTypeCode, WalletItem);
        _LibraryEcommerce.CreateEcomCouponLine(CouponTypeCode, EcomItem);
        Cursor := Database.LastUsedRowVersion();

        // [GIVEN] After the cursor the coupon type is deleted without its trigger
        CouponType.Get(CouponTypeCode);
        CouponType.Delete(false);
        Commit();

        // [WHEN] The items are synced from the cursor
        ReadSyncPage(Cursor, '', 0, '', ProductTypes, RowVersions, NextPageKey);

        // [THEN] Both items are ITEM
        _Assert.IsTrue(ProductTypes.ContainsKey(WalletItem), 'The wallet item must be returned with a productType.');
        _Assert.AreEqual('ITEM', ProductTypes.Get(WalletItem), 'The wallet item must be ITEM after the coupon type is deleted.');
        _Assert.IsTrue(ProductTypes.ContainsKey(EcomItem), 'The ecommerce item must be returned with a productType.');
        _Assert.AreEqual('ITEM', ProductTypes.Get(EcomItem), 'The item of the orphaned ecommerce line must be ITEM.');
        AssertChangePathGuards(WalletItem, Cursor);
        AssertChangePathGuards(EcomItem, Cursor);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Sync_CouponTypeInsertedOverOrphanEcomLine_ReturnsItemAsCoupon()
    var
        ProductTypes: Dictionary of [Code[20], Text];
        RowVersions: Dictionary of [Code[20], BigInteger];
        CouponTypeCode: Code[20];
        ItemX: Code[20];
        NextPageKey: Text;
        Cursor: BigInteger;
    begin
        // [SCENARIO] B15: inserting an enabled coupon type whose code already has an orphan ecommerce line returns the line's item as COUPON.

        // [GIVEN] Entria item X and an ecommerce coupon line for a coupon type code that has no coupon type yet
        Initialize();
        CouponTypeCode := GenerateCouponTypeCode();
        ItemX := MarkEntriaProduct(_LibraryInventory.CreateItemNo());
        _LibraryEcommerce.CreateEcomCouponLine(CouponTypeCode, ItemX);
        Cursor := Database.LastUsedRowVersion();

        // [GIVEN] After the cursor an enabled coupon type with that code is inserted
        InsertCouponType(CouponTypeCode, true);
        Commit();

        // [WHEN] The items are synced from the cursor
        ReadSyncPage(Cursor, '', 0, '', ProductTypes, RowVersions, NextPageKey);

        // [THEN] X is COUPON
        _Assert.IsTrue(ProductTypes.ContainsKey(ItemX), 'X must be returned with a productType.');
        _Assert.AreEqual('COUPON', ProductTypes.Get(ItemX), 'X must be COUPON once its coupon type exists and is enabled.');
        AssertChangePathGuards(ItemX, Cursor);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Sync_CouponTypeRenamed_ReturnsChildItems()
    var
        CouponType: Record "NPR NpDc Coupon Type";
        ProductTypes: Dictionary of [Code[20], Text];
        RowVersions: Dictionary of [Code[20], BigInteger];
        CouponTypeCode: Code[20];
        WalletItem: Code[20];
        EcomItem: Code[20];
        NextPageKey: Text;
        Cursor: BigInteger;
    begin
        // [SCENARIO] B17: renaming an enabled coupon type returns the items of its wallet row and ecommerce line as COUPON.

        // [GIVEN] An enabled coupon type with a wallet row and an ecommerce line, each for an Entria item
        Initialize();
        CouponTypeCode := GenerateCouponTypeCode();
        InsertCouponType(CouponTypeCode, true);
        WalletItem := MarkEntriaProduct(_LibraryInventory.CreateItemNo());
        EcomItem := MarkEntriaProduct(_LibraryInventory.CreateItemNo());
        InsertWalletCouponSetup(CouponTypeCode, WalletItem);
        _LibraryEcommerce.CreateEcomCouponLine(CouponTypeCode, EcomItem);
        Cursor := Database.LastUsedRowVersion();

        // [GIVEN] After the cursor the coupon type is renamed
        CouponType.Get(CouponTypeCode);
        CouponType.Rename(GenerateCouponTypeCode());
        Commit();

        // [WHEN] The items are synced from the cursor
        ReadSyncPage(Cursor, '', 0, '', ProductTypes, RowVersions, NextPageKey);

        // [THEN] Both items are COUPON, as the rename cascades to the children through their table relation
        _Assert.IsTrue(ProductTypes.ContainsKey(WalletItem), 'The wallet item must be returned with a productType.');
        _Assert.AreEqual('COUPON', ProductTypes.Get(WalletItem), 'The wallet item must be COUPON after the rename.');
        _Assert.IsTrue(ProductTypes.ContainsKey(EcomItem), 'The ecommerce item must be returned with a productType.');
        _Assert.AreEqual('COUPON', ProductTypes.Get(EcomItem), 'The ecommerce item must be COUPON after the rename.');
        AssertChangePathGuards(WalletItem, Cursor);
        AssertChangePathGuards(EcomItem, Cursor);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Sync_EntriaStoreDisabledThenEnabled_OnlyEntriaFlagDecidesMarking()
    var
        ProductTypes: Dictionary of [Code[20], Text];
        RowVersions: Dictionary of [Code[20], BigInteger];
        ItemA: Code[20];
        ItemB: Code[20];
        ItemN: Code[20];
        ItemM: Code[20];
        NextPageKey: Text;
        Cursor: BigInteger;
    begin
        // [SCENARIO] B18: setup changes mark Entria items whether or not an Entria store is enabled, and never mark other items.

        // [GIVEN] No enabled Entria store, Entria items A and B, and non-Entria items N and M
        Initialize();
        _LibraryEntria.DisableAllStores();
        ItemA := MarkEntriaProduct(_LibraryInventory.CreateItemNo());
        ItemB := MarkEntriaProduct(_LibraryInventory.CreateItemNo());
        ItemN := _LibraryInventory.CreateItemNo();
        ItemM := _LibraryInventory.CreateItemNo();
        Cursor := Database.LastUsedRowVersion();

        // [GIVEN] After the cursor membership sales setup rows for A and N
        InsertMembershipSalesSetup(ItemA);
        InsertMembershipSalesSetup(ItemN);
        Commit();

        // [WHEN] The items are synced from the cursor
        ReadSyncPage(Cursor, '', 0, '', ProductTypes, RowVersions, NextPageKey);

        // [THEN] A is returned without productType, and N is not returned
        _Assert.IsTrue(RowVersions.ContainsKey(ItemA), 'A must be returned while no Entria store is enabled.');
        _Assert.IsFalse(ProductTypes.ContainsKey(ItemA), 'productType must be omitted while no Entria store is enabled.');
        _Assert.IsFalse(RowVersions.ContainsKey(ItemN), 'Non-Entria item N must not be returned.');

        // [GIVEN] The Entria store is enabled again, then membership sales setup rows for B and M
        _LibraryEntria.EnableEntriaStore(_EntriaStoreCode);
        InsertMembershipSalesSetup(ItemB);
        InsertMembershipSalesSetup(ItemM);
        Commit();

        // [WHEN] The items are synced from the cursor again
        ReadSyncPage(Cursor, '', 0, '', ProductTypes, RowVersions, NextPageKey);

        // [THEN] A and B are MEMBERSHIP, and N and M are neither returned nor marked
        _Assert.IsTrue(ProductTypes.ContainsKey(ItemA), 'A must be returned with a productType.');
        _Assert.AreEqual('MEMBERSHIP', ProductTypes.Get(ItemA), 'A must be MEMBERSHIP.');
        _Assert.IsTrue(ProductTypes.ContainsKey(ItemB), 'B must be returned with a productType.');
        _Assert.AreEqual('MEMBERSHIP', ProductTypes.Get(ItemB), 'B must be MEMBERSHIP.');
        _Assert.IsFalse(RowVersions.ContainsKey(ItemN), 'Non-Entria item N must not be returned.');
        _Assert.IsFalse(RowVersions.ContainsKey(ItemM), 'Non-Entria item M must not be returned.');
        AssertChangePathGuards(ItemA, Cursor);
        AssertChangePathGuards(ItemB, Cursor);
        _Assert.IsTrue(_ItemChangeMgt.GetChangeRowVersion(ItemN) <= Cursor, 'Non-Entria item N must not be marked.');
        _Assert.IsTrue(_ItemChangeMgt.GetChangeRowVersion(ItemM) <= Cursor, 'Non-Entria item M must not be marked.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Sync_CouponTypeEnabledBySubscriberDuringModify_ReturnsChildItemAsCoupon()
    var
        CouponType: Record "NPR NpDc Coupon Type";
        CouponTypeEnableHook: Codeunit "NPR Coupon Type Enable Hook";
        ProductTypes: Dictionary of [Code[20], Text];
        RowVersions: Dictionary of [Code[20], BigInteger];
        CouponTypeCode: Code[20];
        ItemX: Code[20];
        NextPageKey: Text;
        Cursor: BigInteger;
    begin
        // [SCENARIO] B19: a subscriber that enables a disabled coupon type while another field is modified still gets the child item returned as COUPON.

        // [GIVEN] A disabled coupon type with a wallet row for Entria item X
        Initialize();
        CouponTypeCode := GenerateCouponTypeCode();
        InsertCouponType(CouponTypeCode, false);
        ItemX := MarkEntriaProduct(_LibraryInventory.CreateItemNo());
        InsertWalletCouponSetup(CouponTypeCode, ItemX);
        Cursor := Database.LastUsedRowVersion();

        // [GIVEN] After the cursor, with the enable hook bound, "Max Use per Sale" of the coupon type is changed
        CouponTypeEnableHook.SetCouponTypeCode(CouponTypeCode);
        BindSubscription(CouponTypeEnableHook);
        CouponType.Get(CouponTypeCode);
        CouponType."Max Use per Sale" += 1;
        CouponType.Modify();
        UnbindSubscription(CouponTypeEnableHook);
        Commit();

        // [WHEN] The items are synced from the cursor
        ReadSyncPage(Cursor, '', 0, '', ProductTypes, RowVersions, NextPageKey);

        // [THEN] The hook enabled the coupon type, and X is COUPON
        CouponType.Get(CouponTypeCode);
        _Assert.IsTrue(CouponType.Enabled, 'Test setup: the hook must have enabled the coupon type.');
        _Assert.IsTrue(ProductTypes.ContainsKey(ItemX), 'X must be returned with a productType.');
        _Assert.AreEqual('COUPON', ProductTypes.Get(ItemX), 'X must be COUPON after the hook enabled its coupon type.');
        AssertChangePathGuards(ItemX, Cursor);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Sync_NonEntriaAndMissingItemsAreNotMarked_FlagFlipReturnsCurrentType()
    var
        CouponType: Record "NPR NpDc Coupon Type";
        ProductTypes: Dictionary of [Code[20], Text];
        RowVersions: Dictionary of [Code[20], BigInteger];
        CouponTypeCode: Code[20];
        ItemP: Code[20];
        ItemQ: Code[20];
        ItemN: Code[20];
        ItemM: Code[20];
        ItemNoZ: Code[20];
        NextPageKey: Text;
        Cursor: BigInteger;
        HighestRowVersion: BigInteger;
        RowVersion: BigInteger;
    begin
        // [SCENARIO] B20: setup rows and the coupon type fan-out mark only Entria items, a setup row for a missing item marks nothing, and an item flagged later is returned with its current type.

        // [GIVEN] Entria items P and Q, non-Entria items N and M, and an item no. Z without an item
        Initialize();
        ItemP := MarkEntriaProduct(_LibraryInventory.CreateItemNo());
        ItemQ := MarkEntriaProduct(_LibraryInventory.CreateItemNo());
        ItemN := _LibraryInventory.CreateItemNo();
        ItemM := _LibraryInventory.CreateItemNo();
        ItemNoZ := GetUnusedItemNo();

        // [GIVEN] A disabled coupon type with a wallet row for P and an ecommerce line for N
        CouponTypeCode := GenerateCouponTypeCode();
        InsertCouponType(CouponTypeCode, false);
        InsertWalletCouponSetup(CouponTypeCode, ItemP);
        _LibraryEcommerce.CreateEcomCouponLine(CouponTypeCode, ItemN);
        Cursor := Database.LastUsedRowVersion();

        // [GIVEN] After the cursor: membership sales setup rows for Q, M and Z, and the coupon type enabled
        InsertMembershipSalesSetup(ItemQ);
        InsertMembershipSalesSetup(ItemM);
        InsertMembershipSalesSetup(ItemNoZ);
        CouponType.Get(CouponTypeCode);
        CouponType.Enabled := true;
        CouponType.Modify(false);
        Commit();

        // [WHEN] The items are synced from the cursor
        ReadSyncPage(Cursor, '', 0, '', ProductTypes, RowVersions, NextPageKey);

        // [THEN] P is COUPON and Q is MEMBERSHIP; N, M and Z are neither returned nor marked
        _Assert.IsTrue(ProductTypes.ContainsKey(ItemP), 'P must be returned with a productType.');
        _Assert.AreEqual('COUPON', ProductTypes.Get(ItemP), 'P must be COUPON after the coupon type is enabled.');
        _Assert.IsTrue(ProductTypes.ContainsKey(ItemQ), 'Q must be returned with a productType.');
        _Assert.AreEqual('MEMBERSHIP', ProductTypes.Get(ItemQ), 'Q must be MEMBERSHIP.');
        AssertChangePathGuards(ItemP, Cursor);
        AssertChangePathGuards(ItemQ, Cursor);
        _Assert.IsFalse(RowVersions.ContainsKey(ItemN), 'Non-Entria item N must not be returned.');
        _Assert.IsFalse(RowVersions.ContainsKey(ItemM), 'Non-Entria item M must not be returned.');
        _Assert.IsTrue(_ItemChangeMgt.GetChangeRowVersion(ItemN) <= Cursor, 'The coupon type fan-out must not mark non-Entria item N.');
        _Assert.IsTrue(_ItemChangeMgt.GetChangeRowVersion(ItemM) <= Cursor, 'A sales setup row must not mark non-Entria item M.');
        _Assert.IsTrue(_ItemChangeMgt.GetChangeRowVersion(ItemNoZ) <= Cursor, 'A sales setup row for a missing item must not mark it.');
        foreach RowVersion in RowVersions.Values() do
            if RowVersion > HighestRowVersion then
                HighestRowVersion := RowVersion;

        // [GIVEN] N becomes an Entria product
        MarkEntriaProduct(ItemN);
        Commit();

        // [WHEN] The items are synced from the highest rowVersion of the first call
        _Assert.IsFalse(ReadSyncPage(HighestRowVersion, '', 0, '', ProductTypes, RowVersions, NextPageKey), 'Call 2 must be the last page.');

        // [THEN] Only N is returned, as COUPON
        _Assert.AreEqual(1, RowVersions.Count(), 'Only N must be returned by call 2.');
        _Assert.IsTrue(ProductTypes.ContainsKey(ItemN), 'N must be returned with a productType.');
        _Assert.AreEqual('COUPON', ProductTypes.Get(ItemN), 'N must be COUPON once it is an Entria product.');
    end;

    local procedure Initialize()
    var
        EntriaStore: Record "NPR Entria Store";
    begin
        // Without the seam the open test transaction pins the sync boundary below every fixture.
        if not _BoundarySeamBound then begin
            BindSubscription(_BoundarySeam);
            _BoundarySeamBound := true;
        end;
        _BoundarySeam.UseLastAllocatedBoundary();

        _LibraryNPRetailAPI.CreateAPIPermission(UserSecurityId(), CompanyName(), 'NPR API Inventory');
        if _EntriaStoreCode = '' then
            _EntriaStoreCode := _LibraryUtility.GenerateRandomCode20(EntriaStore.FieldNo(Code), Database::"NPR Entria Store");
        _LibraryEntria.EnableEntriaStore(_EntriaStoreCode);
    end;

    // Asserts success and the returned item code before handing back productType, so a wrong item or a failed
    // call cannot pass as a classification result.
    local procedure GetSingleItemProductType(ItemNo: Code[20]): Text
    var
        Item: Record Item;
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        Item.Get(ItemNo);
        SelectLatestVersion();
        Response := _LibraryNPRetailAPI.CallApi('GET', '/inventory/item/' + Format(Item.SystemId, 0, 4).ToLower(), Body, QueryParams, Headers);
        _Assert.IsTrue(_LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'GET /inventory/item/:id should succeed');
        Body := _LibraryNPRetailAPI.GetResponseBody(Response);
        _Assert.AreEqual(ItemNo, GetText(Body, 'code'), 'Response must return the requested item');
        _Assert.IsTrue(Body.Contains('productType'), 'productType must be present with an enabled Entria store');
        exit(GetText(Body, 'productType'));
    end;

    local procedure AssertListedProductTypes(Expected: Dictionary of [Code[20], Text])
    var
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        DataToken: JsonToken;
        ItemToken: JsonToken;
        Actual: Dictionary of [Code[20], Text];
        ItemNo: Code[20];
    begin
        SelectLatestVersion();
        Response := _LibraryNPRetailAPI.CallApi('GET', '/inventory/item', Body, QueryParams, Headers);
        _Assert.IsTrue(_LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'GET /inventory/item should succeed');
        Body := _LibraryNPRetailAPI.GetResponseBody(Response);
        _Assert.IsTrue(Body.Get('data', DataToken), 'Response must contain data');
        foreach ItemToken in DataToken.AsArray() do
            Actual.Add(CopyStr(GetText(ItemToken.AsObject(), 'code'), 1, 20), GetText(ItemToken.AsObject(), 'productType'));

        foreach ItemNo in Expected.Keys() do begin
            _Assert.IsTrue(Actual.ContainsKey(ItemNo), StrSubstNo('Item %1 must be in the list response', ItemNo));
            _Assert.AreEqual(Expected.Get(ItemNo), Actual.Get(ItemNo), StrSubstNo('productType of item %1', ItemNo));
        end;
    end;

    local procedure GetText(JObject: JsonObject; PropertyName: Text): Text
    var
        JToken: JsonToken;
    begin
        if not JObject.Get(PropertyName, JToken) then
            exit('');
        exit(JToken.AsValue().AsText());
    end;

    // Plain assignment without touching Unit Price, so the Entria item webhook subscriber does nothing.
    local procedure MarkEntriaProduct(ItemNo: Code[20]): Code[20]
    var
        Item: Record Item;
    begin
        Item.Get(ItemNo);
        Item."NPR Entria Product" := true;
        Item.Modify();
        exit(ItemNo);
    end;

    local procedure CreateTicketItem() ItemNo: Code[20]
    begin
        ItemNo := _LibraryInventory.CreateItemNo();
        _LibrarySpfyImport.MakeItemATicketItem(ItemNo);
    end;

    local procedure CreateDisabledEcomCouponItem() ItemNo: Code[20]
    var
        CouponType: Record "NPR NpDc Coupon Type";
    begin
        ItemNo := _LibraryEcommerce.CreateEcomCouponItem(CouponType);
        CouponType.Enabled := false;
        CouponType.Modify();
    end;

    local procedure GenerateCouponTypeCode(): Code[20]
    var
        CouponType: Record "NPR NpDc Coupon Type";
    begin
        exit(_LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"));
    end;

    local procedure CreateWalletCouponItem(var CouponType: Record "NPR NpDc Coupon Type") ItemNo: Code[20]
    begin
        _LibraryCoupon.CreateDiscountAmountCouponType(GenerateCouponTypeCode(), CouponType, 10);
        ItemNo := _LibraryInventory.CreateItemNo();
        InsertWalletCouponSetup(CouponType.Code, ItemNo);
    end;

    local procedure InsertWalletCouponSetup(CouponTypeCode: Code[20]; ItemNo: Code[20])
    var
        WalletCouponSetup: Record "NPR WalletCouponSetup";
    begin
        WalletCouponSetup.Init();
        WalletCouponSetup."Coupon Type" := CouponTypeCode;
        WalletCouponSetup.TriggerOnItemNo := ItemNo;
        WalletCouponSetup.Insert();
    end;

    // Plain insert, so the coupon type's OnInsert trigger does not run.
    local procedure InsertCouponType(CouponTypeCode: Code[20]; Enabled: Boolean)
    var
        CouponType: Record "NPR NpDc Coupon Type";
    begin
        CouponType.Init();
        CouponType.Code := CouponTypeCode;
        CouponType.Enabled := Enabled;
        CouponType.Insert();
    end;

    local procedure InsertMembershipSalesSetup(ItemNo: Code[20])
    var
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
    begin
        InsertMembershipSalesSetupOfType(ItemNo, MembershipSalesSetup.Type::ITEM);
    end;

    local procedure InsertMembershipSalesSetupOfType(No: Code[20]; SalesSetupType: Integer)
    var
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
    begin
        MembershipSalesSetup.Init();
        MembershipSalesSetup.Type := SalesSetupType;
        MembershipSalesSetup."No." := No;
        MembershipSalesSetup.Insert();
    end;

    // Plain Insert: OnInsert runs ValidateRec, which needs fields the classification never reads.
    local procedure InsertMembershipAlterSetup(ItemNo: Code[20]; AlterationType: Integer)
    var
        MembersAlterSetup: Record "NPR MM Members. Alter. Setup";
    begin
        MembersAlterSetup.Init();
        MembersAlterSetup."Alteration Type" := AlterationType;
        MembersAlterSetup."From Membership Code" := _LibraryUtility.GenerateRandomCode20(MembersAlterSetup.FieldNo("From Membership Code"), Database::"NPR MM Members. Alter. Setup");
        MembersAlterSetup."Sales Item No." := ItemNo;
        MembersAlterSetup.Insert();
    end;

    local procedure CreateAlterationItem(AlterationType: Integer) ItemNo: Code[20]
    begin
        ItemNo := _LibraryInventory.CreateItemNo();
        InsertMembershipAlterSetup(ItemNo, AlterationType);
    end;

    // An item is returned when it is in RowVersions. ProductTypes holds only the items that carry productType.
    local procedure ReadSyncPage(LastRowVersion: BigInteger; ItemCode: Code[20]; PageSize: Integer; PageKey: Text; var ProductTypes: Dictionary of [Code[20], Text]; var RowVersions: Dictionary of [Code[20], BigInteger]; var NextPageKey: Text) MorePages: Boolean
    var
        Response: JsonObject;
        RequestBody: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        DataToken: JsonToken;
        ElementToken: JsonToken;
        Element: JsonObject;
        ItemNo: Code[20];
        RowVersion: BigInteger;
        HighestRowVersion: BigInteger;
    begin
        Clear(ProductTypes);
        Clear(RowVersions);
        QueryParams.Add('sync', 'true');
        QueryParams.Add('lastRowVersion', Format(LastRowVersion, 0, 9));
        if ItemCode <> '' then
            QueryParams.Add('itemCode', ItemCode);
        if PageSize > 0 then
            QueryParams.Add('pageSize', Format(PageSize, 0, 9));
        if PageKey <> '' then
            QueryParams.Add('pageKey', PageKey);
        Response := _LibraryNPRetailAPI.CallApi('GET', '/inventory/item', RequestBody, QueryParams, Headers);
        _Assert.IsTrue(_LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'GET /inventory/item with sync=true should succeed');
        Body := _LibraryNPRetailAPI.GetResponseBody(Response);

        _Assert.IsTrue(Body.Get('data', DataToken), 'The sync page must carry data.');
        foreach ElementToken in DataToken.AsArray() do begin
            Element := ElementToken.AsObject();
            ItemNo := CopyStr(GetText(Element, 'code'), 1, MaxStrLen(ItemNo));
            _Assert.IsFalse(RowVersions.ContainsKey(ItemNo), StrSubstNo('Item %1 must appear at most once on a sync page.', ItemNo));
            _Assert.IsTrue(Element.Contains('rowVersion'), StrSubstNo('Item %1 must carry a rowVersion on a sync page.', ItemNo));
            RowVersion := _LibraryAPIBI.GetBigInteger(Element, 'rowVersion');
            _Assert.IsTrue(RowVersion > HighestRowVersion, 'rowVersion must increase strictly along a sync page.');
            HighestRowVersion := RowVersion;
            RowVersions.Add(ItemNo, RowVersion);
            if Element.Contains('productType') then
                ProductTypes.Add(ItemNo, GetText(Element, 'productType'));
        end;
        MorePages := _LibraryAPIBI.GetRequiredBoolean(Body, 'morePages');
        NextPageKey := GetText(Body, 'nextPageKey');

        _Assert.IsFalse(Body.Contains('syncRowVersion'), 'A sync page must not carry syncRowVersion.');
        _Assert.AreEqual(MorePages, NextPageKey <> '', 'nextPageKey must be set exactly when morePages is true.');
        if MorePages and (PageSize > 0) then
            _Assert.AreEqual(PageSize, DataToken.AsArray().Count(), 'A page with morePages = true must hold pageSize items.');
    end;

    // The Item row did not carry the change, and the mark did.
    local procedure AssertChangePathGuards(ItemNo: Code[20]; Cursor: BigInteger)
    var
        Item: Record Item;
    begin
        Item.Get(ItemNo);
        _Assert.IsTrue(Item.SystemRowVersion <= Cursor, StrSubstNo('Test setup: the Item row of %1 must lie below the cursor.', ItemNo));
        _Assert.IsTrue(_ItemChangeMgt.GetChangeRowVersion(ItemNo) > Cursor, StrSubstNo('Test setup: the change row of %1 must lie above the cursor.', ItemNo));
    end;

    // Change rows survive between cases, so each case needs its own unused item no.
    local procedure GetUnusedItemNo() ItemNo: Code[20]
    var
        Item: Record Item;
    begin
        ItemNo := CopyStr('Z' + DelChr(Format(CreateGuid()), '=', '{}-'), 1, MaxStrLen(ItemNo));
        _Assert.IsFalse(Item.Get(ItemNo), 'The generated item no. is already in use.');
    end;
}
