codeunit 85249 "NPR EcomSubscriptionTest"
{
    Subtype = Test;

    var
        LibEcommerce: Codeunit "NPR Library Ecommerce";
        MemberModuleLib: Codeunit "NPR Library - Member Module";
        MemberApiLib: Codeunit "NPR Library - Member XML API";
        Assert: Codeunit Assert;
        IsInitialized: Boolean;
        NextPaymentLineNo: Integer;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure LineLevelSubscriptionOnNonMembershipLineIgnored()
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
    begin
        // [Given] A plain item line flagged as a subscription
        BuildLine(EcomSalesLine, EcomSalesLine.Subtype::Item, EcomSalesLine."Membership Operation"::NoOperationSelected, true);

        // [When/Then] The flag has no meaning on a non-membership line - it is ignored, not an error
        EcomCreateMMShipImpl.ValidateSubscriptionFlag(EcomSalesLine);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure LineLevelSubscriptionOnRenewLineAllowed()
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
    begin
        // [Given] A membership Renew line flagged as a subscription
        BuildLine(EcomSalesLine, EcomSalesLine.Subtype::Membership, EcomSalesLine."Membership Operation"::RenewMembership, true);

        // [When/Then] Allowed — no error
        EcomCreateMMShipImpl.ValidateSubscriptionFlag(EcomSalesLine);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure LineLevelSubscriptionOnCreateLineAllowed()
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
    begin
        // [Given] A membership Create line flagged as a subscription
        BuildLine(EcomSalesLine, EcomSalesLine.Subtype::Membership, EcomSalesLine."Membership Operation"::CreateMembership, true);

        // [When/Then] Allowed — no error
        EcomCreateMMShipImpl.ValidateSubscriptionFlag(EcomSalesLine);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure LineLevelSubscriptionOnConfirmLineAllowed()
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
    begin
        // [Given] A membership Confirm line flagged as a subscription
        BuildLine(EcomSalesLine, EcomSalesLine.Subtype::Membership, EcomSalesLine."Membership Operation"::ConfirmMembership, true);

        // [When/Then] Allowed — no error
        EcomCreateMMShipImpl.ValidateSubscriptionFlag(EcomSalesLine);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure LineLevelFlagOffOnRenewLineAllowed()
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
    begin
        // [Given] A Renew line WITHOUT the subscription flag
        BuildLine(EcomSalesLine, EcomSalesLine.Subtype::Membership, EcomSalesLine."Membership Operation"::RenewMembership, false);

        // [When/Then] Flag off — validation is a no-op
        EcomCreateMMShipImpl.ValidateSubscriptionFlag(EcomSalesLine);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DocLevelSubscriptionLineNoEmailRejected()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
    begin
        // [Given] A subscription membership line + tokenized payment, but no customer email on the header
        LibEcommerce.CreateEcomSalesHeader(EcomSalesHeader);
        EcomSalesHeader."Sell-to Email" := '';
        EcomSalesHeader.Modify();
        InsertSubscriptionMembershipLine(EcomSalesLine, EcomSalesHeader);
        InsertTokenizedPaymentLine(EcomSalesHeader, 'psp-ref-1', 'par-ref-1');

        // [When/Then] Missing email is a hard fail
        asserterror EcomSalesDocUtils.ValidateSubscriptionDocumentRequirements(EcomSalesHeader);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DocLevelSubscriptionLineNoTokenizedPaymentRejected()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
    begin
        // [Given] A subscription membership line + email, but no payment line carrying a token + shopper ref
        LibEcommerce.CreateEcomSalesHeader(EcomSalesHeader);
        EcomSalesHeader."Sell-to Email" := 'buyer@ecommerce.test';
        EcomSalesHeader.Modify();
        InsertSubscriptionMembershipLine(EcomSalesLine, EcomSalesHeader);
        InsertTokenizedPaymentLine(EcomSalesHeader, '', ''); // payment line present but no tokens

        // [When/Then] Missing tokenized card payment is a hard fail
        asserterror EcomSalesDocUtils.ValidateSubscriptionDocumentRequirements(EcomSalesHeader);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DocLevelSubscriptionLineEmailAndTokenPasses()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
    begin
        // [Given] A subscription membership line + email + a tokenized card payment on a subscription-capable gateway
        Initialize();
        LibEcommerce.CreateEcomSalesHeader(EcomSalesHeader);
        EcomSalesHeader."Sell-to Email" := 'buyer@ecommerce.test';
        EcomSalesHeader.Modify();
        InsertSubscriptionMembershipLine(EcomSalesLine, EcomSalesHeader);
        InsertTokenizedPaymentLine(EcomSalesHeader, 'psp-ref-1', 'par-ref-1', MapExternalPaymentMethod(Enum::"NPR PG Integrations"::Adyen));

        // [When/Then] Requirements met — no error
        EcomSalesDocUtils.ValidateSubscriptionDocumentRequirements(EcomSalesHeader);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DocLevelNoSubscriptionLineNoRequirements()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
    begin
        // [Given] A membership line that is NOT a subscription, no email, no tokenized payment
        LibEcommerce.CreateEcomSalesHeader(EcomSalesHeader);
        EcomSalesHeader."Sell-to Email" := '';
        EcomSalesHeader.Modify();
        InsertSubscriptionMembershipLine(EcomSalesLine, EcomSalesHeader);
        EcomSalesLine.Subscription := false;
        EcomSalesLine.Modify();

        // [When/Then] No subscription line → the cross-entity requirements do not apply
        EcomSalesDocUtils.ValidateSubscriptionDocumentRequirements(EcomSalesHeader);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure InitialSaleStoresOriginalPaymentReferenceNotCaptureModRef()
    var
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        PaymentLine: Record "NPR Magento Payment Line";
        Subscription: Record "NPR MM Subscription";
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        MembershipEntryNo: Integer;
        ResponseMessage: Text;
        OriginalPspReference: Code[16];
    begin
        // [Scenario] The ecom Initial Sale must store the webshop's original payment pspReference
        // (the Magento payment line's Transaction ID), not a later capture-modification reference.
        Initialize();
        OriginalPspReference := 'PSP-ORIGINAL-01';

        // [Given] A subscription-capable membership (T-320100 has a Recurring Payment Code) with auto-renew on
        Assert.IsTrue(MemberApiLib.CreateMembership('T-320100', MembershipEntryNo, ResponseMessage), ResponseMessage);
        Membership.Get(MembershipEntryNo);
        GetLastMembershipEntry(Membership, MembershipEntry);
        SetSubscriptionAutoRenewInternal(Membership);

        // [Given] The captured member payment method + the ecom-created Magento payment line whose Transaction ID
        //         holds the ORIGINAL webshop pspReference (this is how EcomSalesDocImplV2 / EcomCaptureImpl map it)
        CreateMemberPaymentMethod(MemberPaymentMethod);
        CreateCapturedMagentoPaymentLine(PaymentLine, OriginalPspReference, 100);

        // [When] The ecom Initial Sale creation runs (the exact procedure the ecom flow invokes)
        EcomCreateMMShipImpl.CreateInitialSaleForMembership(Membership, MemberPaymentMethod, PaymentLine, 100);

        // [Then] The Initial Sale payment request stores the original pspReference
        Subscription.SetRange("Membership Entry No.", Membership."Entry No.");
        Assert.IsTrue(Subscription.FindFirst(), 'Subscription should exist for the membership.');
        SubscriptionRequest.SetRange("Subscription Entry No.", Subscription."Entry No.");
        SubscriptionRequest.SetRange(Type, SubscriptionRequest.Type::"Initial Sale");
        Assert.IsTrue(SubscriptionRequest.FindFirst(), 'An Initial Sale subscription request should have been created.');
        SubscrPaymentRequest.SetRange("Subscr. Request Entry No.", SubscriptionRequest."Entry No.");
        Assert.IsTrue(SubscrPaymentRequest.FindFirst(), 'An Initial Sale payment request should have been created.');
        Assert.AreEqual(OriginalPspReference, SubscrPaymentRequest."PSP Reference", 'Must store the original payment pspReference (payment line Transaction ID), not a capture-modification reference.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure InitialSaleRunTwiceCreatesNoDuplicate()
    var
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        PaymentLine: Record "NPR Magento Payment Line";
        Subscription: Record "NPR MM Subscription";
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        MembershipEntryNo: Integer;
        ResponseMessage: Text;
    begin
        // [Scenario] Reprocessing must not create a second Initial Sale record.
        Initialize();

        Assert.IsTrue(MemberApiLib.CreateMembership('T-320100', MembershipEntryNo, ResponseMessage), ResponseMessage);
        Membership.Get(MembershipEntryNo);
        GetLastMembershipEntry(Membership, MembershipEntry);
        SetSubscriptionAutoRenewInternal(Membership);
        CreateMemberPaymentMethod(MemberPaymentMethod);
        CreateCapturedMagentoPaymentLine(PaymentLine, 'PSP-ORIGINAL-02', 100);

        // [When] The Initial Sale creation runs twice for the same subscription
        EcomCreateMMShipImpl.CreateInitialSaleForMembership(Membership, MemberPaymentMethod, PaymentLine, 100);
        EcomCreateMMShipImpl.CreateInitialSaleForMembership(Membership, MemberPaymentMethod, PaymentLine, 100);

        // [Then] Exactly one Initial Sale subscription request exists
        Subscription.SetRange("Membership Entry No.", Membership."Entry No.");
        Subscription.FindFirst();
        SubscriptionRequest.SetRange("Subscription Entry No.", Subscription."Entry No.");
        SubscriptionRequest.SetRange(Type, SubscriptionRequest.Type::"Initial Sale");
        Assert.AreEqual(1, SubscriptionRequest.Count(), 'Running the Initial Sale creation twice must not create a second Initial Sale request.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SubscriptionOnRecurringItemAllowed()
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
    begin
        // [Scenario] Subscription allowed on a membership item that IS set up for recurring payments (T-320100).
        Initialize();
        BuildLine(EcomSalesLine, EcomSalesLine.Subtype::Membership, EcomSalesLine."Membership Operation"::CreateMembership, true);
        EcomSalesLine."No." := 'T-320100';

        // [When/Then] No error - recurring payment code present
        EcomCreateMMShipImpl.ValidateSubscriptionFlag(EcomSalesLine);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SubscriptionOnNonRecurringItemRejected()
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
    begin
        // [Scenario] Subscription rejected on a membership item that is NOT set up for recurring payments (T-NOSUB-ITEM).
        Initialize();
        BuildLine(EcomSalesLine, EcomSalesLine.Subtype::Membership, EcomSalesLine."Membership Operation"::CreateMembership, true);
        EcomSalesLine."No." := 'T-NOSUB-ITEM';

        // [When/Then] Rejected - membership has no Recurring Payment Code
        asserterror EcomCreateMMShipImpl.ValidateSubscriptionFlag(EcomSalesLine);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SubscriptionOnMultiQuantityLineAllowed()
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
    begin
        // [Scenario] Subscription is allowed on a multi-quantity line; each membership records its own per-membership
        // amount (the whole-line amount is split across memberships in ConfirmAllMembershipsForLine), so no restriction.
        Initialize();
        BuildLine(EcomSalesLine, EcomSalesLine.Subtype::Membership, EcomSalesLine."Membership Operation"::CreateMembership, true);
        EcomSalesLine."No." := 'T-320100';
        EcomSalesLine.Quantity := 2;

        // [When/Then] No error - multi-quantity subscription line is accepted
        EcomCreateMMShipImpl.ValidateSubscriptionFlag(EcomSalesLine);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GateOffDoesNotEnroll()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        Membership: Record "NPR MM Membership";
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        MembershipEntryNo: Integer;
        ResponseMessage: Text;
    begin
        // [Scenario] The exact bug being fixed: with a captured tokenized card present but Subscription = false,
        // processing must NOT save a card or flip auto-renew.
        Initialize();
        Assert.IsTrue(MemberApiLib.CreateMembership('T-320100', MembershipEntryNo, ResponseMessage), ResponseMessage);
        Membership.Get(MembershipEntryNo);

        LibEcommerce.CreateEcomSalesHeader(EcomSalesHeader);
        EcomSalesHeader."Sell-to Email" := UniqueEmail();
        EcomSalesHeader.Modify();
        InsertCapturedConfirmLine(EcomSalesLine, EcomSalesHeader, 'T-320100', Membership, false);
        InsertCapturedTokenPaymentLine(EcomSalesHeader, 'TOKEN-OFF');
        Commit();

        // [When]
        EcomCreateMMShipImpl.Process(EcomSalesLine);

        // [Then] No enrollment
        Membership.Get(MembershipEntryNo);
        Assert.AreEqual(Membership."Auto-Renew"::NO, Membership."Auto-Renew", 'Auto-Renew must stay No when the line is not a subscription.');
        MemberPaymentMethod.SetRange("Payment Token", 'TOKEN-OFF');
        Assert.IsTrue(MemberPaymentMethod.IsEmpty(), 'No member payment method must be created when the line is not a subscription.');
    end;

    #region Recurring rule on alteration lines

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure FlaggedRenewOfNonRecurringType_WhenValidated_ThenRefusedNamingThatType()
    var
        AlterationSetup: Record "NPR MM Members. Alter. Setup";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        Membership: Record "NPR MM Membership";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
    begin
        Initialize();

        // [Given] A flagged renew line on a T-NOSUB membership, whose type has no Recurring Payment Code
        CreateMembershipForItem('T-NOSUB-ITEM', Membership);
        AlterationSetup.Get(AlterationSetup."Alteration Type"::RENEW, 'T-NOSUB', 'T-NOSUB-RENEW');
        BuildAlterationLine(EcomSalesLine, AlterationSetup, Membership, EcomSalesLine."Membership Operation"::RenewMembership, true);

        // [When] The line is validated
        asserterror EcomCreateMMShipImpl.ValidateSubscriptionFlag(EcomSalesLine);

        // [Then] The refusal names the type the renew results in
        Assert.ExpectedError('membership T-NOSUB is not set up for recurring payments (Recurring Payment Code is empty)');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure FlaggedDowngradeToNonRecurringType_WhenValidated_ThenRefusedNamingTargetType()
    var
        AlterationSetup: Record "NPR MM Members. Alter. Setup";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        Membership: Record "NPR MM Membership";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
    begin
        Initialize();

        // [Given] A flagged downgrade line on a recurring-capable GOLD membership, targeting a type without a Recurring Payment Code
        CreateMembershipForItem('T-320100', Membership);
        AlterationSetup.Get(AlterationSetup."Alteration Type"::UPGRADE, 'T-GOLD', 'T-320100-DOWNGR-NS');
        BuildAlterationLine(EcomSalesLine, AlterationSetup, Membership, EcomSalesLine."Membership Operation"::UpgradeMembership, true);

        // [When] The line is validated
        asserterror EcomCreateMMShipImpl.ValidateSubscriptionFlag(EcomSalesLine);

        // [Then] The refusal names the resulting type, not the current one
        Assert.ExpectedError('membership T-SILVER-NOSUB is not set up for recurring payments (Recurring Payment Code is empty)');
    end;

    #endregion

    #region Document-level gateway capability

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SubscriptionLinePaidOnCapableAndNonCapableGateways_WhenDocumentValidated_ThenDocumentAccepted()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        Accepted: Boolean;
        CapablePaymentMethodCode: Text[50];
        NonCapablePaymentMethodCode: Text[50];
    begin
        // [SCENARIO] A document carrying one subscription-capable tokenized card payment is accepted at import even when it also carries a tokenized card payment on a gateway that cannot do subscriptions.
        Initialize();

        // [GIVEN] A flagged membership line, a customer email, and two tokenized card payments - one on a subscription-capable gateway, one not
        CreateOrder(EcomSalesHeader, UniqueEmail(), 'Anna Payer');
        InsertSubscriptionMembershipLine(EcomSalesLine, EcomSalesHeader);
        CapablePaymentMethodCode := MapExternalPaymentMethod(Enum::"NPR PG Integrations"::Adyen);
        NonCapablePaymentMethodCode := MapExternalPaymentMethod(Enum::"NPR PG Integrations"::Stripe);
        InsertTokenizedPaymentLine(EcomSalesHeader, 'psp-token-capable', 'par-token-capable', CapablePaymentMethodCode);
        InsertTokenizedPaymentLine(EcomSalesHeader, 'psp-token-non-capable', 'par-token-non-capable', NonCapablePaymentMethodCode);

        // [WHEN] The document is validated at import
        Accepted := TryValidateSubscriptionDocumentRequirements(EcomSalesHeader);

        // [THEN] The document is accepted - the capable payment satisfies the rule and the non-capable one does not refuse the document
        Assert.IsTrue(Accepted, StrSubstNo('A document paid with both a subscription-capable payment method (%1) and a non-capable one (%2) must pass import validation, but it was refused: %3', CapablePaymentMethodCode, NonCapablePaymentMethodCode, GetLastErrorText()));
    end;

    #endregion

    #region Enrollment on alteration lines

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure FlaggedRenewLine_WhenProcessed_ThenCardStoredAsDefaultAndAutoRenewInternal()
    var
        AlterationSetup: Record "NPR MM Members. Alter. Setup";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipPmtMethodMap: Record "NPR MM MembershipPmtMethodMap";
        Subscription: Record "NPR MM Subscription";
        UserAccount: Record "NPR UserAccount";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        PayerEmail: Text[80];
        Token: Text[64];
        RequestsBefore: Integer;
    begin
        Initialize();

        // [Given] An active GOLD membership with Auto-Renew NO and no stored card
        CreateMembershipForItem('T-320100', Membership);
        Assert.AreEqual(Membership."Auto-Renew"::NO, Membership."Auto-Renew", 'A new membership must start with Auto-Renew NO.');
        GetSubscription(Membership, Subscription);
        RequestsBefore := SubscriptionRequestCount(Subscription);

        // [Given] An order with the sell-to email, a flagged renew line and one qualifying captured card payment
        PayerEmail := UniqueEmail();
        Token := UniqueToken('TOK-A');
        CreateOrder(EcomSalesHeader, PayerEmail, 'Anna Payer');
        AlterationSetup.Get(AlterationSetup."Alteration Type"::RENEW, 'T-GOLD', 'T-320100-RENEW');
        InsertCapturedAlterationLine(EcomSalesLine, EcomSalesHeader, AlterationSetup, Membership, EcomSalesLine."Membership Operation"::RenewMembership, 157, true);
        InsertCapturedTokenPaymentLine(EcomSalesHeader, Token, SubscriptionCapableGateway(), 157);
        Commit();

        // [When] The renew line is processed
        EcomCreateMMShipImpl.Process(EcomSalesLine);

        // [Then] The renewal itself is recorded as one RENEW membership entry
        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.SetRange(Context, MembershipEntry.Context::RENEW);
        Assert.AreEqual(1, MembershipEntry.Count(), 'A flagged renew line must add exactly one RENEW membership entry.');

        // [Then] The order card is stored on the sell-to email's user account and is the membership default
        Assert.IsTrue(FindStoredCard(Token, MemberPaymentMethod), 'The order card must be stored as a member payment method.');
        Assert.IsTrue(FindUserAccount(PayerEmail, UserAccount), 'The sell-to email must have a user account.');
        Assert.AreEqual(UserAccount.SystemId, MemberPaymentMethod."BC Record System ID", 'The card must be stored on the sell-to email''s user account.');
        Assert.IsTrue(MembershipPmtMethodMap.Get(MemberPaymentMethod.SystemId, Membership.SystemId), 'The stored card must be mapped to the membership.');
        Assert.IsTrue(MembershipPmtMethodMap.Default, 'The stored card must be the membership default card.');

        // [Then] Membership and subscription are enrolled in internal auto-renewal on the GOLD type
        Membership.Get(Membership."Entry No.");
        Assert.AreEqual(Membership."Auto-Renew"::YES_INTERNAL, Membership."Auto-Renew", 'Membership Auto-Renew must be YES_INTERNAL after a flagged renew.');
        GetSubscription(Membership, Subscription);
        Assert.AreEqual(Subscription."Auto-Renew"::YES_INTERNAL, Subscription."Auto-Renew", 'Subscription Auto-Renew must be YES_INTERNAL after a flagged renew.');
        Assert.IsFalse(Subscription.Blocked, 'The subscription must not be blocked after a flagged renew.');
        Assert.AreEqual('T-GOLD', Subscription."Membership Code", 'The subscription must carry the membership code the renew results in.');

        // [Then] The line creates no subscription request of any type
        Assert.AreEqual(RequestsBefore, SubscriptionRequestCount(Subscription), 'A flagged renew line must not create any subscription request.');
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure FlaggedExtendLine_WhenProcessed_ThenCardStoredAsDefaultAndAutoRenewInternal()
    var
        AlterationSetup: Record "NPR MM Members. Alter. Setup";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipPmtMethodMap: Record "NPR MM MembershipPmtMethodMap";
        Subscription: Record "NPR MM Subscription";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        ValidUntilBefore: Date;
        PayerEmail: Text[80];
        Token: Text[64];
    begin
        Initialize();

        // [Given] A GOLD membership with Auto-Renew NO and no stored card, nine months into its year, so the
        //         extend option's +9M from today appends to its current period instead of overlapping it
        CreateMembershipActiveSince('T-320100', CalcDate('<-9M>', Today()), Membership);
        ValidUntilBefore := LastEntryValidUntil(Membership);

        // [Given] An order with the sell-to email, a flagged extend line and one qualifying captured card payment
        PayerEmail := UniqueEmail();
        Token := UniqueToken('TOK-A');
        CreateOrder(EcomSalesHeader, PayerEmail, 'Anna Payer');
        AlterationSetup.Get(AlterationSetup."Alteration Type"::EXTEND, 'T-GOLD', 'T-320100-EXTEND');
        InsertCapturedAlterationLine(EcomSalesLine, EcomSalesHeader, AlterationSetup, Membership, EcomSalesLine."Membership Operation"::ExtendMembership, 34, true);
        InsertCapturedTokenPaymentLine(EcomSalesHeader, Token, SubscriptionCapableGateway(), 34);
        Commit();

        // [When] The extend line is processed
        EcomCreateMMShipImpl.Process(EcomSalesLine);

        // [Then] The extension itself is recorded as one EXTEND membership entry that advances the membership
        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.SetRange(Context, MembershipEntry.Context::EXTEND);
        Assert.AreEqual(1, MembershipEntry.Count(), 'A flagged extend line must add exactly one EXTEND membership entry.');
        Assert.IsTrue(LastEntryValidUntil(Membership) > ValidUntilBefore, 'The extension must advance the membership Valid Until Date.');

        // [Then] The order card is stored and becomes the membership default
        Assert.IsTrue(FindStoredCard(Token, MemberPaymentMethod), 'The order card must be stored as a member payment method.');
        Assert.IsTrue(MembershipPmtMethodMap.Get(MemberPaymentMethod.SystemId, Membership.SystemId), 'The stored card must be mapped to the membership.');
        Assert.IsTrue(MembershipPmtMethodMap.Default, 'The stored card must be the membership default card.');

        // [Then] Membership and subscription are enrolled in internal auto-renewal
        Membership.Get(Membership."Entry No.");
        Assert.AreEqual(Membership."Auto-Renew"::YES_INTERNAL, Membership."Auto-Renew", 'Membership Auto-Renew must be YES_INTERNAL after a flagged extend.');
        GetSubscription(Membership, Subscription);
        Assert.AreEqual(Subscription."Auto-Renew"::YES_INTERNAL, Subscription."Auto-Renew", 'Subscription Auto-Renew must be YES_INTERNAL after a flagged extend.');
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure FlaggedUpgradeToRecurringType_WhenProcessed_ThenEnrolledOnTargetType()
    var
        AlterationSetup: Record "NPR MM Members. Alter. Setup";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipPmtMethodMap: Record "NPR MM MembershipPmtMethodMap";
        Subscription: Record "NPR MM Subscription";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        PayerEmail: Text[80];
        Token: Text[64];
    begin
        Initialize();

        // [Given] A SILVER membership whose own type is not recurring-capable, and an upgrade option to recurring-capable GOLD
        CreateMembershipForItem('T-SILVER-NS-ITEM', Membership);
        Assert.AreEqual('T-SILVER-NOSUB', Membership."Membership Code", 'The upgrade must start from the non-recurring SILVER type.');

        // [Given] An order with the sell-to email, a flagged upgrade line and one qualifying captured card payment
        PayerEmail := UniqueEmail();
        Token := UniqueToken('TOK-A');
        CreateOrder(EcomSalesHeader, PayerEmail, 'Anna Payer');
        AlterationSetup.Get(AlterationSetup."Alteration Type"::UPGRADE, 'T-SILVER-NOSUB', 'T-320101-UPGRADE');
        InsertCapturedAlterationLine(EcomSalesLine, EcomSalesHeader, AlterationSetup, Membership, EcomSalesLine."Membership Operation"::UpgradeMembership, 157, true);
        InsertCapturedTokenPaymentLine(EcomSalesHeader, Token, SubscriptionCapableGateway(), 157);
        Commit();

        // [When] The upgrade line is processed
        EcomCreateMMShipImpl.Process(EcomSalesLine);

        // [Then] The membership is upgraded to GOLD with one UPGRADE entry
        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.SetRange(Context, MembershipEntry.Context::UPGRADE);
        Assert.AreEqual(1, MembershipEntry.Count(), 'A flagged upgrade line must add exactly one UPGRADE membership entry.');
        Membership.Get(Membership."Entry No.");
        Assert.AreEqual('T-GOLD', Membership."Membership Code", 'The upgrade must move the membership to the target type.');

        // [Then] The card is stored, is the default, and the subscription carries the target membership code
        Assert.IsTrue(FindStoredCard(Token, MemberPaymentMethod), 'The order card must be stored as a member payment method.');
        Assert.IsTrue(MembershipPmtMethodMap.Get(MemberPaymentMethod.SystemId, Membership.SystemId), 'The stored card must be mapped to the membership.');
        Assert.IsTrue(MembershipPmtMethodMap.Default, 'The stored card must be the membership default card.');
        Assert.AreEqual(Membership."Auto-Renew"::YES_INTERNAL, Membership."Auto-Renew", 'Membership Auto-Renew must be YES_INTERNAL after a flagged upgrade.');
        GetSubscription(Membership, Subscription);
        Assert.AreEqual(Subscription."Auto-Renew"::YES_INTERNAL, Subscription."Auto-Renew", 'Subscription Auto-Renew must be YES_INTERNAL after a flagged upgrade.');
        Assert.AreEqual('T-GOLD', Subscription."Membership Code", 'The subscription must carry the membership code the upgrade results in.');
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure FlaggedRenewPaidWithAnotherCard_WhenProcessed_ThenNewCardBecomesDefault()
    var
        AlterationSetup: Record "NPR MM Members. Alter. Setup";
        CardA: Record "NPR MM Member Payment Method";
        CardB: Record "NPR MM Member Payment Method";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        MapA: Record "NPR MM MembershipPmtMethodMap";
        MapB: Record "NPR MM MembershipPmtMethodMap";
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        Subscription: Record "NPR MM Subscription";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        PayerEmail: Text[80];
        TokenA: Text[64];
        TokenB: Text[64];
        RequestsBefore: Integer;
    begin
        Initialize();

        // [Given] A GOLD membership already enrolled in internal auto-renewal with card A as its default
        CreateMembershipForItem('T-320100', Membership);
        PayerEmail := UniqueEmail();
        TokenA := UniqueToken('TOK-A');
        StoreCardForMembership(PayerEmail, TokenA, Membership);
        SetMembershipAutoRenew(Membership, Membership."Auto-Renew"::YES_INTERNAL);
        GetSubscription(Membership, Subscription);
        RequestsBefore := SubscriptionRequestCount(Subscription);

        // [Given] An order for the same payer with a flagged renew line paid by card B
        TokenB := UniqueToken('TOK-B');
        CreateOrder(EcomSalesHeader, PayerEmail, 'Anna Payer');
        AlterationSetup.Get(AlterationSetup."Alteration Type"::RENEW, 'T-GOLD', 'T-320100-RENEW');
        InsertCapturedAlterationLine(EcomSalesLine, EcomSalesHeader, AlterationSetup, Membership, EcomSalesLine."Membership Operation"::RenewMembership, 157, true);
        InsertCapturedTokenPaymentLine(EcomSalesHeader, TokenB, SubscriptionCapableGateway(), 157);
        Commit();

        // [When] The renew line is processed
        EcomCreateMMShipImpl.Process(EcomSalesLine);

        // [Then] Card B is stored and becomes the default, card A stays stored but is no longer the default
        Assert.IsTrue(FindStoredCard(TokenB, CardB), 'The card that paid the renewal must be stored as a member payment method.');
        Assert.IsTrue(MapB.Get(CardB.SystemId, Membership.SystemId), 'The new card must be mapped to the membership.');
        Assert.IsTrue(MapB.Default, 'The new card must become the membership default card.');
        Assert.IsTrue(FindStoredCard(TokenA, CardA), 'The previously stored card must stay stored.');
        Assert.IsTrue(MapA.Get(CardA.SystemId, Membership.SystemId), 'The previously stored card must stay mapped to the membership.');
        Assert.IsFalse(MapA.Default, 'The previously stored card must no longer be the membership default card.');

        // [Then] Auto-Renew stays YES_INTERNAL, the renewal is applied and no subscription request is created
        Membership.Get(Membership."Entry No.");
        Assert.AreEqual(Membership."Auto-Renew"::YES_INTERNAL, Membership."Auto-Renew", 'Membership Auto-Renew must stay YES_INTERNAL.');
        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.SetRange(Context, MembershipEntry.Context::RENEW);
        Assert.AreEqual(1, MembershipEntry.Count(), 'The renewal must be applied normally.');
        Assert.AreEqual(RequestsBefore, SubscriptionRequestCount(Subscription), 'Replacing the default card must not create a subscription request.');
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure FlaggedRenewPaidWithTheStoredCard_WhenProcessed_ThenNoSecondCardStored()
    var
        AlterationSetup: Record "NPR MM Members. Alter. Setup";
        CardA: Record "NPR MM Member Payment Method";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        MapA: Record "NPR MM MembershipPmtMethodMap";
        Membership: Record "NPR MM Membership";
        UserAccount: Record "NPR UserAccount";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        PayerEmail: Text[80];
        TokenA: Text[64];
    begin
        Initialize();

        // [Given] A GOLD membership already enrolled in internal auto-renewal with card A as its default
        CreateMembershipForItem('T-320100', Membership);
        PayerEmail := UniqueEmail();
        TokenA := UniqueToken('TOK-A');
        StoreCardForMembership(PayerEmail, TokenA, Membership);
        SetMembershipAutoRenew(Membership, Membership."Auto-Renew"::YES_INTERNAL);

        // [Given] An order for the same payer with a flagged renew line paid by the very same card
        CreateOrder(EcomSalesHeader, PayerEmail, 'Anna Payer');
        AlterationSetup.Get(AlterationSetup."Alteration Type"::RENEW, 'T-GOLD', 'T-320100-RENEW');
        InsertCapturedAlterationLine(EcomSalesLine, EcomSalesHeader, AlterationSetup, Membership, EcomSalesLine."Membership Operation"::RenewMembership, 157, true);
        InsertCapturedTokenPaymentLine(EcomSalesHeader, TokenA, SubscriptionCapableGateway(), 157);
        Commit();

        // [When] The renew line is processed
        EcomCreateMMShipImpl.Process(EcomSalesLine);

        // [Then] No second member payment method is created and card A is still the default
        Assert.IsTrue(FindUserAccount(PayerEmail, UserAccount), 'The payer must still have exactly one user account.');
        Assert.AreEqual(1, CardCountForAccount(UserAccount), 'Paying with the already stored card must not create a second member payment method.');
        Assert.IsTrue(FindStoredCard(TokenA, CardA), 'The stored card must still exist.');
        Assert.IsTrue(MapA.Get(CardA.SystemId, Membership.SystemId), 'The stored card must stay mapped to the membership.');
        Assert.IsTrue(MapA.Default, 'The stored card must stay the membership default card.');
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure FlaggedRenewPaidByAnotherPerson_WhenProcessed_ThenCardLandsOnPayerAccount()
    var
        AlterationSetup: Record "NPR MM Members. Alter. Setup";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        MemberAccount: Record "NPR UserAccount";
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        Membership: Record "NPR MM Membership";
        MembershipPmtMethodMap: Record "NPR MM MembershipPmtMethodMap";
        PayerAccount: Record "NPR UserAccount";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        MemberEmail: Text[80];
        PayerEmail: Text[80];
        Token: Text[64];
    begin
        Initialize();

        // [Given] A GOLD membership whose member has a user account of their own
        CreateMembershipForItem('T-320100', Membership);
        MemberEmail := UniqueEmail();
        CreateUserAccount(MemberEmail, 'Anna', 'Member', MemberAccount);

        // [Given] An order paid by someone else, whose email has no account yet
        PayerEmail := UniqueEmail();
        Token := UniqueToken('TOK-A');
        CreateOrder(EcomSalesHeader, PayerEmail, 'Dan Dad');
        AlterationSetup.Get(AlterationSetup."Alteration Type"::RENEW, 'T-GOLD', 'T-320100-RENEW');
        InsertCapturedAlterationLine(EcomSalesLine, EcomSalesHeader, AlterationSetup, Membership, EcomSalesLine."Membership Operation"::RenewMembership, 157, true);
        InsertCapturedTokenPaymentLine(EcomSalesHeader, Token, SubscriptionCapableGateway(), 157);
        Commit();

        // [When] The renew line is processed
        EcomCreateMMShipImpl.Process(EcomSalesLine);

        // [Then] The payer's account is created from the sell-to name and holds the card, which is the membership default
        Assert.IsTrue(FindUserAccount(PayerEmail, PayerAccount), 'The sell-to email must get a user account.');
        Assert.AreEqual('Dan', PayerAccount.FirstName, 'The new account must take its first name from the sell-to name.');
        Assert.AreEqual('Dad', PayerAccount.LastName, 'The new account must take its last name from the sell-to name.');
        Assert.IsTrue(FindStoredCard(Token, MemberPaymentMethod), 'The order card must be stored as a member payment method.');
        Assert.AreEqual(PayerAccount.SystemId, MemberPaymentMethod."BC Record System ID", 'The card must be stored on the payer''s account.');
        Assert.IsTrue(MembershipPmtMethodMap.Get(MemberPaymentMethod.SystemId, Membership.SystemId), 'The stored card must be mapped to the membership.');
        Assert.IsTrue(MembershipPmtMethodMap.Default, 'The stored card must be the membership default card.');

        // [Then] The member's own account is untouched
        Assert.AreEqual(0, CardCountForAccount(MemberAccount), 'The member''s own account must not receive the payer''s card.');
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UnflaggedRenewLineWithQualifyingCard_WhenProcessed_ThenNoEnrollment()
    var
        AlterationSetup: Record "NPR MM Members. Alter. Setup";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        PayerEmail: Text[80];
        Token: Text[64];
    begin
        Initialize();

        // [Given] A GOLD membership with Auto-Renew NO
        CreateMembershipForItem('T-320100', Membership);

        // [Given] An order with a renew line that does NOT carry the flag, paid by a qualifying captured card
        PayerEmail := UniqueEmail();
        Token := UniqueToken('TOK-A');
        CreateOrder(EcomSalesHeader, PayerEmail, 'Anna Payer');
        AlterationSetup.Get(AlterationSetup."Alteration Type"::RENEW, 'T-GOLD', 'T-320100-RENEW');
        InsertCapturedAlterationLine(EcomSalesLine, EcomSalesHeader, AlterationSetup, Membership, EcomSalesLine."Membership Operation"::RenewMembership, 157, false);
        InsertCapturedTokenPaymentLine(EcomSalesHeader, Token, SubscriptionCapableGateway(), 157);
        Commit();

        // [When] The renew line is processed
        EcomCreateMMShipImpl.Process(EcomSalesLine);

        // [Then] The membership is renewed but nothing is enrolled - the line flag is the only trigger
        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.SetRange(Context, MembershipEntry.Context::RENEW);
        Assert.AreEqual(1, MembershipEntry.Count(), 'The renewal must still be applied without the flag.');
        Assert.IsFalse(FindStoredCard(Token, MemberPaymentMethod), 'A tokenized payment alone must not store a card.');
        Assert.AreEqual(0, MembershipCardMapCount(Membership), 'A tokenized payment alone must not create a default card mapping.');
        Membership.Get(Membership."Entry No.");
        Assert.AreEqual(Membership."Auto-Renew"::NO, Membership."Auto-Renew", 'Auto-Renew must stay NO when the line does not carry the flag.');
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure FlaggedCreateAndUnflaggedRenewOnOneOrder_WhenProcessed_ThenOnlyCreatedIsEnrolled()
    var
        AlterationSetup: Record "NPR MM Members. Alter. Setup";
        CreateLine: Record "NPR Ecom Sales Line";
        CreatedMembership: Record "NPR MM Membership";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        RenewLine: Record "NPR Ecom Sales Line";
        RenewedMembership: Record "NPR MM Membership";
        Subscription: Record "NPR MM Subscription";
        MembershipEntry: Record "NPR MM Membership Entry";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        PayerEmail: Text[80];
        Token: Text[64];
    begin
        Initialize();

        // [Given] An existing GOLD membership to be renewed without the flag
        CreateMembershipForItem('T-320100', RenewedMembership);

        // [Given] One order: a flagged create line and an unflagged renew line, both paid by one card
        PayerEmail := UniqueEmail();
        Token := UniqueToken('TOK-A');
        CreateOrder(EcomSalesHeader, PayerEmail, 'Anna Payer');
        InsertCapturedCreateLine(CreateLine, EcomSalesHeader, 'T-320100', 157, true);
        AlterationSetup.Get(AlterationSetup."Alteration Type"::RENEW, 'T-GOLD', 'T-320100-RENEW');
        InsertCapturedAlterationLine(RenewLine, EcomSalesHeader, AlterationSetup, RenewedMembership, RenewLine."Membership Operation"::RenewMembership, 157, false);
        InsertCapturedTokenPaymentLine(EcomSalesHeader, Token, SubscriptionCapableGateway(), 314);
        Commit();

        // [When] Both lines are processed
        EcomCreateMMShipImpl.Process(CreateLine);
        EcomCreateMMShipImpl.Process(RenewLine);

        // [Then] The created membership is enrolled with exactly one Initial Sale request
        CreateLine.Get(CreateLine.RecordId);
        Assert.IsTrue(CreatedMembership.GetBySystemId(CreateLine."Membership Id"), 'The create line must have issued a membership.');
        Assert.AreEqual(CreatedMembership."Auto-Renew"::YES_INTERNAL, CreatedMembership."Auto-Renew", 'The flagged create line must enroll its membership.');
        Assert.IsTrue(IsDefaultCardForMembership(CreatedMembership, Token), 'The order card must be the created membership''s default card.');
        GetSubscription(CreatedMembership, Subscription);
        Assert.AreEqual(1, SubscriptionRequestCount(Subscription, Enum::"NPR MM Subscr. Request Type"::"Initial Sale"), 'The flagged create line must record exactly one Initial Sale request.');

        // [Then] The renewed membership is renewed only - no card, no default, no auto-renewal
        MembershipEntry.SetRange("Membership Entry No.", RenewedMembership."Entry No.");
        MembershipEntry.SetRange(Context, MembershipEntry.Context::RENEW);
        Assert.AreEqual(1, MembershipEntry.Count(), 'The unflagged renew line must still renew its membership.');
        RenewedMembership.Get(RenewedMembership."Entry No.");
        Assert.AreEqual(RenewedMembership."Auto-Renew"::NO, RenewedMembership."Auto-Renew", 'The unflagged renew line must not enroll its membership.');
        Assert.AreEqual(0, MembershipCardMapCount(RenewedMembership), 'The unflagged renew line must not map a card to its membership.');
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UnflaggedCreateAndFlaggedRenewOnOneOrder_WhenProcessed_ThenOnlyRenewedIsEnrolled()
    var
        AlterationSetup: Record "NPR MM Members. Alter. Setup";
        CreateLine: Record "NPR Ecom Sales Line";
        CreatedMembership: Record "NPR MM Membership";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        RenewLine: Record "NPR Ecom Sales Line";
        RenewedMembership: Record "NPR MM Membership";
        Subscription: Record "NPR MM Subscription";
        MembershipEntry: Record "NPR MM Membership Entry";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        PayerEmail: Text[80];
        Token: Text[64];
    begin
        Initialize();

        // [Given] An existing GOLD membership to be renewed with the flag
        CreateMembershipForItem('T-320100', RenewedMembership);

        // [Given] One order: an unflagged create line and a flagged renew line, both paid by one card
        PayerEmail := UniqueEmail();
        Token := UniqueToken('TOK-A');
        CreateOrder(EcomSalesHeader, PayerEmail, 'Anna Payer');
        InsertCapturedCreateLine(CreateLine, EcomSalesHeader, 'T-320100', 157, false);
        AlterationSetup.Get(AlterationSetup."Alteration Type"::RENEW, 'T-GOLD', 'T-320100-RENEW');
        InsertCapturedAlterationLine(RenewLine, EcomSalesHeader, AlterationSetup, RenewedMembership, RenewLine."Membership Operation"::RenewMembership, 157, true);
        InsertCapturedTokenPaymentLine(EcomSalesHeader, Token, SubscriptionCapableGateway(), 314);
        Commit();

        // [When] Both lines are processed
        EcomCreateMMShipImpl.Process(CreateLine);
        EcomCreateMMShipImpl.Process(RenewLine);

        // [Then] The renewed membership is enrolled, without any Initial Sale request
        MembershipEntry.SetRange("Membership Entry No.", RenewedMembership."Entry No.");
        MembershipEntry.SetRange(Context, MembershipEntry.Context::RENEW);
        Assert.AreEqual(1, MembershipEntry.Count(), 'The flagged renew line must renew its membership.');
        RenewedMembership.Get(RenewedMembership."Entry No.");
        Assert.AreEqual(RenewedMembership."Auto-Renew"::YES_INTERNAL, RenewedMembership."Auto-Renew", 'The flagged renew line must enroll its membership.');
        Assert.IsTrue(IsDefaultCardForMembership(RenewedMembership, Token), 'The order card must be the renewed membership''s default card.');
        GetSubscription(RenewedMembership, Subscription);
        Assert.AreEqual(0, SubscriptionRequestCount(Subscription, Enum::"NPR MM Subscr. Request Type"::"Initial Sale"), 'An alteration line must not record an Initial Sale request.');

        // [Then] The created membership is not enrolled
        CreateLine.Get(CreateLine.RecordId);
        Assert.IsTrue(CreatedMembership.GetBySystemId(CreateLine."Membership Id"), 'The create line must have issued a membership.');
        Assert.AreEqual(CreatedMembership."Auto-Renew"::NO, CreatedMembership."Auto-Renew", 'The unflagged create line must not enroll its membership.');
        Assert.AreEqual(0, MembershipCardMapCount(CreatedMembership), 'The unflagged create line must not map a card to its membership.');
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure FlaggedRenewLine_WhenProcessed_ThenNoInitialSaleAndNoPaymentRequest()
    var
        AlterationSetup: Record "NPR MM Members. Alter. Setup";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        Membership: Record "NPR MM Membership";
        Subscription: Record "NPR MM Subscription";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        PayerEmail: Text[80];
        Token: Text[64];
    begin
        Initialize();

        // [Given] A GOLD membership and an order with a flagged renew line paid by a qualifying captured card
        CreateMembershipForItem('T-320100', Membership);
        PayerEmail := UniqueEmail();
        Token := UniqueToken('TOK-A');
        CreateOrder(EcomSalesHeader, PayerEmail, 'Anna Payer');
        AlterationSetup.Get(AlterationSetup."Alteration Type"::RENEW, 'T-GOLD', 'T-320100-RENEW');
        InsertCapturedAlterationLine(EcomSalesLine, EcomSalesHeader, AlterationSetup, Membership, EcomSalesLine."Membership Operation"::RenewMembership, 157, true);
        InsertCapturedTokenPaymentLine(EcomSalesHeader, Token, SubscriptionCapableGateway(), 157);
        Commit();

        // [When] The renew line is processed
        EcomCreateMMShipImpl.Process(EcomSalesLine);

        // [Then] The renewal is not billed through the subscription engine
        Membership.Get(Membership."Entry No.");
        GetSubscription(Membership, Subscription);
        Assert.AreEqual(0, SubscriptionRequestCount(Subscription, Enum::"NPR MM Subscr. Request Type"::"Initial Sale"), 'An alteration line must not record an Initial Sale request.');
        Assert.AreEqual(0, SubscriptionPaymentRequestCount(Subscription), 'An alteration line must not create a subscription payment request.');
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure FlaggedRenewOnTerminationRequested_WhenProcessed_ThenTerminationCancelledAndEnrolled()
    var
        AlterationSetup: Record "NPR MM Members. Alter. Setup";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        Membership: Record "NPR MM Membership";
        Subscription: Record "NPR MM Subscription";
        TerminateRequest: Record "NPR MM Subscr. Request";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        PayerEmail: Text[80];
        Token: Text[64];
    begin
        Initialize();

        // [Given] A GOLD membership pending termination, with a Pending Terminate request and no refund in progress
        CreateMembershipForItem('T-320100', Membership);
        SetMembershipAutoRenew(Membership, Membership."Auto-Renew"::TERMINATION_REQUESTED);
        GetSubscription(Membership, Subscription);
        TerminateRequest.SetRange("Subscription Entry No.", Subscription."Entry No.");
        TerminateRequest.SetRange(Type, TerminateRequest.Type::Terminate);
        Assert.IsTrue(TerminateRequest.FindFirst(), 'Requesting termination must leave a Terminate subscription request.');
        Assert.AreEqual(TerminateRequest."Processing Status"::Pending, TerminateRequest."Processing Status", 'The Terminate request must start Pending.');

        // [Given] An order with a flagged renew line paid by a qualifying captured card
        PayerEmail := UniqueEmail();
        Token := UniqueToken('TOK-A');
        CreateOrder(EcomSalesHeader, PayerEmail, 'Anna Payer');
        AlterationSetup.Get(AlterationSetup."Alteration Type"::RENEW, 'T-GOLD', 'T-320100-RENEW');
        InsertCapturedAlterationLine(EcomSalesLine, EcomSalesHeader, AlterationSetup, Membership, EcomSalesLine."Membership Operation"::RenewMembership, 157, true);
        InsertCapturedTokenPaymentLine(EcomSalesHeader, Token, SubscriptionCapableGateway(), 157);
        Commit();

        // [When] The renew line is processed
        EcomCreateMMShipImpl.Process(EcomSalesLine);

        // [Then] The membership and its subscription are back on internal auto-renewal
        Membership.Get(Membership."Entry No.");
        Assert.AreEqual(Membership."Auto-Renew"::YES_INTERNAL, Membership."Auto-Renew", 'Membership Auto-Renew must be YES_INTERNAL after a flagged renew.');
        GetSubscription(Membership, Subscription);
        Assert.AreEqual(Subscription."Auto-Renew"::YES_INTERNAL, Subscription."Auto-Renew", 'Subscription Auto-Renew must be YES_INTERNAL after a flagged renew.');

        // [Then] The pending termination is cancelled and the order card is the default
        TerminateRequest.Get(TerminateRequest."Entry No.");
        Assert.AreEqual(TerminateRequest.Status::Cancelled, TerminateRequest.Status, 'Enrolling again must cancel the pending Terminate request.');
        Assert.IsTrue(IsDefaultCardForMembership(Membership, Token), 'The order card must be the membership default card.');
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AppliedFlaggedRenewLine_WhenProcessedAgain_ThenSecondRunDoesNothing()
    var
        AlterationSetup: Record "NPR MM Members. Alter. Setup";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        PayerEmail: Text[80];
        Token: Text[64];
    begin
        Initialize();

        // [Given] A flagged renew line that has already been processed once
        CreateMembershipForItem('T-320100', Membership);
        PayerEmail := UniqueEmail();
        Token := UniqueToken('TOK-A');
        CreateOrder(EcomSalesHeader, PayerEmail, 'Anna Payer');
        AlterationSetup.Get(AlterationSetup."Alteration Type"::RENEW, 'T-GOLD', 'T-320100-RENEW');
        InsertCapturedAlterationLine(EcomSalesLine, EcomSalesHeader, AlterationSetup, Membership, EcomSalesLine."Membership Operation"::RenewMembership, 157, true);
        InsertCapturedTokenPaymentLine(EcomSalesHeader, Token, SubscriptionCapableGateway(), 157);
        Commit();
        EcomCreateMMShipImpl.Process(EcomSalesLine);

        // [When] The same line is processed a second time
        EcomSalesLine.Get(EcomSalesLine.RecordId);
        EcomCreateMMShipImpl.Process(EcomSalesLine);

        // [Then] Nothing is duplicated: one RENEW entry, one stored card, one default mapping
        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.SetRange(Context, MembershipEntry.Context::RENEW);
        Assert.AreEqual(1, MembershipEntry.Count(), 'Reprocessing must not add a second RENEW membership entry.');
        Assert.AreEqual(1, StoredCardCount(Token), 'Reprocessing must not store the card twice.');
        Assert.AreEqual(1, MembershipCardMapCount(Membership), 'Reprocessing must not add a second card mapping.');
        Assert.IsTrue(IsDefaultCardForMembership(Membership, Token), 'The order card must stay the membership default card.');
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure FlaggedRenewPaidOnlyWithNonCapableCard_WhenProcessed_ThenCardStoredAsDefaultAndAutoRenewInternal()
    var
        AlterationSetup: Record "NPR MM Members. Alter. Setup";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipPmtMethodMap: Record "NPR MM MembershipPmtMethodMap";
        UserAccount: Record "NPR UserAccount";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        PayerEmail: Text[80];
        Token: Text[64];
    begin
        // [SCENARIO] A flagged renew line whose only captured card payment is on a gateway that cannot do subscriptions is processed, and that card is stored as the membership default.
        Initialize();

        // [GIVEN] An active GOLD membership with Auto-Renew NO
        CreateMembershipForItem('T-320100', Membership);

        // [GIVEN] An order with a flagged renew line paid only by a card captured on a gateway that cannot do subscriptions
        PayerEmail := UniqueEmail();
        Token := UniqueToken('TOK-NONCAPABLE');
        CreateOrder(EcomSalesHeader, PayerEmail, 'Anna Payer');
        AlterationSetup.Get(AlterationSetup."Alteration Type"::RENEW, 'T-GOLD', 'T-320100-RENEW');
        InsertCapturedAlterationLine(EcomSalesLine, EcomSalesHeader, AlterationSetup, Membership, EcomSalesLine."Membership Operation"::RenewMembership, 157, true);
        InsertCapturedTokenPaymentLine(EcomSalesHeader, Token, GatewayCodeForIntegration(Enum::"NPR PG Integrations"::Stripe), 157);
        Commit();

        // [WHEN] The renew line is processed
        EcomCreateMMShipImpl.Process(EcomSalesLine);

        // [THEN] The renewal is applied
        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.SetRange(Context, MembershipEntry.Context::RENEW);
        Assert.AreEqual(1, MembershipEntry.Count(), 'A flagged renew line paid on a gateway that cannot do subscriptions must still add exactly one RENEW membership entry.');

        // [THEN] The order card is stored on the payer account and is the membership default
        Assert.IsTrue(FindUserAccount(PayerEmail, UserAccount), 'The sell-to email must have a user account.');
        Assert.IsTrue(FindStoredCard(Token, MemberPaymentMethod), StrSubstNo('The card captured on a gateway that cannot do subscriptions (token %1) must be stored as a member payment method.', Token));
        Assert.AreEqual(UserAccount.SystemId, MemberPaymentMethod."BC Record System ID", 'The card must be stored on the sell-to email''s user account.');
        Assert.IsTrue(MembershipPmtMethodMap.Get(MemberPaymentMethod.SystemId, Membership.SystemId), 'The stored card must be mapped to the membership.');
        Assert.IsTrue(MembershipPmtMethodMap.Default, 'The stored card must be the membership default card.');

        // [THEN] The membership is enrolled in internal auto-renewal
        Membership.Get(Membership."Entry No.");
        Assert.AreEqual(Membership."Auto-Renew"::YES_INTERNAL, Membership."Auto-Renew", 'Membership Auto-Renew must be YES_INTERNAL after a flagged renew, whatever gateway the card was captured on.');
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure FlaggedRenewPaidWithTwoCapableCards_WhenProcessed_ThenBothStoredAndTheLastOneIsDefault()
    var
        AlterationSetup: Record "NPR MM Members. Alter. Setup";
        CardA: Record "NPR MM Member Payment Method";
        CardB: Record "NPR MM Member Payment Method";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        MapA: Record "NPR MM MembershipPmtMethodMap";
        MapB: Record "NPR MM MembershipPmtMethodMap";
        Membership: Record "NPR MM Membership";
        UserAccount: Record "NPR UserAccount";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        PayerEmail: Text[80];
        TokenA: Text[64];
        TokenB: Text[64];
    begin
        // [SCENARIO] A flagged renew line paid with two distinct subscription-capable cards stores both on the payer account and leaves the card processed last as the membership default.
        Initialize();

        // [GIVEN] An active GOLD membership with Auto-Renew NO
        CreateMembershipForItem('T-320100', Membership);

        // [GIVEN] An order with a flagged renew line paid by two distinct cards, both captured on the subscription-capable gateway
        PayerEmail := UniqueEmail();
        TokenA := UniqueToken('TOK-A');
        TokenB := UniqueToken('TOK-B');
        CreateOrder(EcomSalesHeader, PayerEmail, 'Anna Payer');
        AlterationSetup.Get(AlterationSetup."Alteration Type"::RENEW, 'T-GOLD', 'T-320100-RENEW');
        InsertCapturedAlterationLine(EcomSalesLine, EcomSalesHeader, AlterationSetup, Membership, EcomSalesLine."Membership Operation"::RenewMembership, 157, true);
        InsertCapturedTokenPaymentLine(EcomSalesHeader, TokenA, SubscriptionCapableGateway(), 100);
        InsertCapturedTokenPaymentLine(EcomSalesHeader, TokenB, SubscriptionCapableGateway(), 57);
        Commit();

        // [WHEN] The renew line is processed
        EcomCreateMMShipImpl.Process(EcomSalesLine);

        // [THEN] Both cards are stored on the payer account
        Assert.IsTrue(FindUserAccount(PayerEmail, UserAccount), 'The sell-to email must have a user account.');
        Assert.IsTrue(FindStoredCard(TokenA, CardA), StrSubstNo('The card paid first (token %1) must be stored as a member payment method.', TokenA));
        Assert.IsTrue(FindStoredCard(TokenB, CardB), StrSubstNo('The card paid last (token %1) must be stored as a member payment method.', TokenB));
        Assert.AreEqual(2, CardCountForAccount(UserAccount), StrSubstNo('Both order cards (tokens %1 and %2) must be stored on the payer account.', TokenA, TokenB));

        // [THEN] The card processed last is the membership default and the first one is not
        Assert.IsTrue(MapB.Get(CardB.SystemId, Membership.SystemId), 'The card paid last must be mapped to the membership.');
        Assert.IsTrue(MapB.Default, StrSubstNo('The card processed last (token %1) must be the membership default card.', TokenB));
        Assert.IsTrue(MapA.Get(CardA.SystemId, Membership.SystemId), 'The card paid first must stay mapped to the membership.');
        Assert.IsFalse(MapA.Default, StrSubstNo('The card processed first (token %1) must not be the membership default card.', TokenA));
    end;

    #endregion

    #region Enrollment refusals on alteration lines

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure FlaggedRenewOnBlockedSubscription_WhenProcessed_ThenRefusedAndNothingApplied()
    var
        AlterationSetup: Record "NPR MM Members. Alter. Setup";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        Subscription: Record "NPR MM Subscription";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        PayerEmail: Text[80];
        Token: Text[64];
        SubscriptionBlockedErr: Label '%1 is enabled on line %2, but the %3 of membership %4 is blocked, so it could never auto-renew.', Locked = true;
    begin
        Initialize();

        // [Given] A GOLD membership whose subscription is blocked
        CreateMembershipForItem('T-320100', Membership);
        GetSubscription(Membership, Subscription);
        Subscription.Blocked := true;
        Subscription.Modify(true);

        // [Given] An order with a flagged renew line paid by a qualifying captured card
        PayerEmail := UniqueEmail();
        Token := UniqueToken('TOK-A');
        CreateOrder(EcomSalesHeader, PayerEmail, 'Anna Payer');
        AlterationSetup.Get(AlterationSetup."Alteration Type"::RENEW, 'T-GOLD', 'T-320100-RENEW');
        InsertCapturedAlterationLine(EcomSalesLine, EcomSalesHeader, AlterationSetup, Membership, EcomSalesLine."Membership Operation"::RenewMembership, 157, true);
        InsertCapturedTokenPaymentLine(EcomSalesHeader, Token, SubscriptionCapableGateway(), 157);
        Commit();

        // [When] The renew line is processed
        asserterror EcomCreateMMShipImpl.Process(EcomSalesLine);

        // [Then] The line fails, naming the membership and its blocked subscription
        Assert.ExpectedError(StrSubstNo(SubscriptionBlockedErr, EcomSalesLine.FieldCaption(Subscription), EcomSalesLine."Line No.", Subscription.TableCaption(), Membership."External Membership No."));

        // [Then] Nothing of the line persists
        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.SetRange(Context, MembershipEntry.Context::RENEW);
        Assert.AreEqual(0, MembershipEntry.Count(), 'A refused line must not renew the membership.');
        Assert.IsFalse(FindStoredCard(Token, MemberPaymentMethod), 'A refused line must not store the order card.');
        Assert.AreEqual(0, MembershipCardMapCount(Membership), 'A refused line must not map a card to the membership.');
        Membership.Get(Membership."Entry No.");
        Assert.AreEqual(Membership."Auto-Renew"::NO, Membership."Auto-Renew", 'A refused line must leave Auto-Renew unchanged.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure FlaggedRenewWithPendingPartialRegret_WhenProcessed_ThenRefusedAndRefundLeftPending()
    var
        AlterationSetup: Record "NPR MM Members. Alter. Setup";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        PartialRegretRequest: Record "NPR MM Subscr. Request";
        Subscription: Record "NPR MM Subscription";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        PayerEmail: Text[80];
        Token: Text[64];
        PendingPartialRegretErr: Label '%1 is enabled on line %2, but membership %3 has a pending termination with a refund in progress, so it cannot be enrolled in auto-renewal. Process or cancel the refund first.', Locked = true;
    begin
        Initialize();

        // [Given] A GOLD membership pending termination with an unprocessed Partial Regret refund
        CreateMembershipForItem('T-320100', Membership);
        SetMembershipAutoRenew(Membership, Membership."Auto-Renew"::TERMINATION_REQUESTED);
        GetSubscription(Membership, Subscription);
        InsertPartialRegretRequest(Subscription, PartialRegretRequest);

        // [Given] An order with a flagged renew line paid by a qualifying captured card
        PayerEmail := UniqueEmail();
        Token := UniqueToken('TOK-A');
        CreateOrder(EcomSalesHeader, PayerEmail, 'Anna Payer');
        AlterationSetup.Get(AlterationSetup."Alteration Type"::RENEW, 'T-GOLD', 'T-320100-RENEW');
        InsertCapturedAlterationLine(EcomSalesLine, EcomSalesHeader, AlterationSetup, Membership, EcomSalesLine."Membership Operation"::RenewMembership, 157, true);
        InsertCapturedTokenPaymentLine(EcomSalesHeader, Token, SubscriptionCapableGateway(), 157);
        Commit();

        // [When] The renew line is processed
        asserterror EcomCreateMMShipImpl.Process(EcomSalesLine);

        // [Then] The line fails, naming the membership and the refund in progress
        Assert.ExpectedError(StrSubstNo(PendingPartialRegretErr, EcomSalesLine.FieldCaption(Subscription), EcomSalesLine."Line No.", Membership."External Membership No."));

        // [Then] The pending termination and refund are untouched and nothing of the line persists
        PartialRegretRequest.Get(PartialRegretRequest."Entry No.");
        Assert.AreEqual(PartialRegretRequest."Processing Status"::Pending, PartialRegretRequest."Processing Status", 'A refused line must leave the Partial Regret request Pending.');
        Membership.Get(Membership."Entry No.");
        Assert.AreEqual(Membership."Auto-Renew"::TERMINATION_REQUESTED, Membership."Auto-Renew", 'A refused line must leave Auto-Renew unchanged.');
        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.SetRange(Context, MembershipEntry.Context::RENEW);
        Assert.AreEqual(0, MembershipEntry.Count(), 'A refused line must not renew the membership.');
        Assert.IsFalse(FindStoredCard(Token, MemberPaymentMethod), 'A refused line must not store the order card.');
        Assert.AreEqual(0, MembershipCardMapCount(Membership), 'A refused line must not map a card to the membership.');
    end;

    #endregion

    [ConfirmHandler]
    procedure ConfirmYesHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    local procedure InsertCapturedConfirmLine(var EcomSalesLine: Record "NPR Ecom Sales Line"; EcomSalesHeader: Record "NPR Ecom Sales Header"; ItemNo: Code[20]; Membership: Record "NPR MM Membership"; SubscriptionFlag: Boolean)
    begin
        EcomSalesLine.Init();
        EcomSalesLine."Document Entry No." := EcomSalesHeader."Entry No.";
        EcomSalesLine."Document Type" := EcomSalesHeader."Document Type";
        EcomSalesLine."Line No." := 10000;
        EcomSalesLine.Type := EcomSalesLine.Type::Item;
        EcomSalesLine.Subtype := EcomSalesLine.Subtype::Membership;
        EcomSalesLine."No." := ItemNo;
        EcomSalesLine."Membership Id" := Membership.SystemId;
        EcomSalesLine.Quantity := 1;
        EcomSalesLine."Unit Price" := 100;
        EcomSalesLine."Line Amount" := 100;
        EcomSalesLine."Membership Operation" := EcomSalesLine."Membership Operation"::ConfirmMembership;
        EcomSalesLine.Captured := true;
        EcomSalesLine.Subscription := SubscriptionFlag;
        EcomSalesLine.Insert(true);
    end;

    local procedure InsertCapturedTokenPaymentLine(EcomSalesHeader: Record "NPR Ecom Sales Header"; Token: Text[64])
    begin
        InsertCapturedTokenPaymentLine(EcomSalesHeader, Token, '', 100);
    end;

    local procedure InsertCapturedTokenPaymentLine(EcomSalesHeader: Record "NPR Ecom Sales Header"; Token: Text[64]; GatewayCode: Code[10]; PaymentAmount: Decimal)
    var
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        NextPaymentLineNo += 10000;
        PaymentLine.Init();
        PaymentLine."Document Table No." := Database::"NPR Ecom Sales Header";
        PaymentLine."Line No." := NextPaymentLineNo;
        PaymentLine."NPR Inc Ecom Sale Id" := EcomSalesHeader.SystemId;
        PaymentLine."Payment Token" := Token;
        PaymentLine."Payment Gateway Shopper Ref." := 'TEST-SHOPPER-REF';
        PaymentLine."Payment Gateway Code" := GatewayCode;
        PaymentLine."Transaction ID" := 'TEST-PSP-REF';
        PaymentLine.Amount := PaymentAmount;
        PaymentLine."Date Captured" := Today();
        PaymentLine.Insert(true);
    end;

    local procedure UniqueEmail(): Text[80]
    var
        Email: Text[80];
    begin
        Email := CopyStr(LowerCase(DelChr(Format(CreateGuid()), '=', '{}-')) + '@t.example.com', 1, MaxStrLen(Email));
        exit(Email);
    end;

    local procedure UniqueToken(Prefix: Text): Text[64]
    var
        Token: Text[64];
    begin
        Token := CopyStr(Prefix + '-' + DelChr(Format(CreateGuid()), '=', '{}-'), 1, MaxStrLen(Token));
        exit(Token);
    end;

    local procedure BuildLine(var EcomSalesLine: Record "NPR Ecom Sales Line"; LineSubtype: Enum "NPR Ecom Sales Line Subtype"; Operation: Enum "NPR Ecom Membership Operation"; SubscriptionFlag: Boolean)
    begin
        Clear(EcomSalesLine);
        EcomSalesLine.Init();
        EcomSalesLine.Type := EcomSalesLine.Type::Item;
        EcomSalesLine.Subtype := LineSubtype;
        EcomSalesLine."Membership Operation" := Operation;
        EcomSalesLine."Line No." := 10000;
        EcomSalesLine.Quantity := 1;
        EcomSalesLine.Subscription := SubscriptionFlag;
    end;

    local procedure InsertSubscriptionMembershipLine(var EcomSalesLine: Record "NPR Ecom Sales Line"; EcomSalesHeader: Record "NPR Ecom Sales Header")
    begin
        EcomSalesLine.Init();
        EcomSalesLine."Document Entry No." := EcomSalesHeader."Entry No.";
        EcomSalesLine."Document Type" := EcomSalesHeader."Document Type";
        EcomSalesLine."Line No." := 10000;
        EcomSalesLine.Type := EcomSalesLine.Type::Item;
        EcomSalesLine.Subtype := EcomSalesLine.Subtype::Membership;
        EcomSalesLine."Membership Operation" := EcomSalesLine."Membership Operation"::CreateMembership;
        EcomSalesLine."No." := 'SUB-ITEM';
        EcomSalesLine.Quantity := 1;
        EcomSalesLine."Unit Price" := 100;
        EcomSalesLine."Line Amount" := 100;
        EcomSalesLine.Subscription := true;
        EcomSalesLine.Insert(true);
    end;

    local procedure InsertTokenizedPaymentLine(EcomSalesHeader: Record "NPR Ecom Sales Header"; PspToken: Text[64]; ParToken: Text[50])
    begin
        InsertTokenizedPaymentLine(EcomSalesHeader, PspToken, ParToken, '');
    end;

    local procedure InsertTokenizedPaymentLine(EcomSalesHeader: Record "NPR Ecom Sales Header"; PspToken: Text[64]; ParToken: Text[50]; ExternalPaymentMethodCode: Text[50])
    var
        EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line";
    begin
        EcomSalesPmtLine.Init();
        EcomSalesPmtLine."Document Entry No." := EcomSalesHeader."Entry No.";
        EcomSalesPmtLine."Line No." := NextPmtLineNo(EcomSalesHeader);
        EcomSalesPmtLine."Payment Method Type" := EcomSalesPmtLine."Payment Method Type"::"Payment Method";
        EcomSalesPmtLine."External Payment Method Code" := ExternalPaymentMethodCode;
        EcomSalesPmtLine."PSP Token" := PspToken;
        EcomSalesPmtLine."PAR Token" := ParToken;
        EcomSalesPmtLine.Amount := 100;
        EcomSalesPmtLine.Insert(true);
    end;

    local procedure Initialize()
    var
        MembershipSetup: Record "NPR MM Membership Setup";
        MemberCommunity: Record "NPR MM Member Community";
        LibPaymentGateway: Codeunit "NPR Library - Payment Gateway";
    begin
        if IsInitialized then
            exit;
        MemberModuleLib.Initialize();
        MemberModuleLib.CreateScenario_SmokeTest(); // T-320100 (GOLD) is set up WITH a Recurring Payment Code.

        // A membership item WITHOUT a recurring payment code, for the recurring-rule reject test.
        MembershipSetup.Get('T-GOLD');
        MemberCommunity.Get(MembershipSetup."Community Code");
        MemberModuleLib.SetupMembership_Simple(MemberCommunity.Code, 'T-NOSUB', '', 'Non-subscription membership');
        MemberModuleLib.CreateItem('T-NOSUB-ITEM', '', 'Non-subscription membership item', 100);
        MemberModuleLib.SetupSimpleMembershipSalesItem('T-NOSUB-ITEM', 'T-NOSUB');
        MemberModuleLib.SetupRenew_NoGraceNotStackable('T-NOSUB', MemberModuleLib.CreateItem('T-NOSUB-RENEW', '', 'Renew Non-subscription Membership', 100), '', 'Renew Non-subscription Membership');

        // A SILVER copy without a recurring payment code, upgradable to GOLD and reachable by a GOLD downgrade.
        MemberModuleLib.SetupMembership_Simple(MemberCommunity.Code, 'T-SILVER-NOSUB', '', 'Silver Membership without recurring payments');
        MemberModuleLib.CreateItem('T-SILVER-NS-ITEM', '', 'Silver Membership without recurring payments item', 147);
        MemberModuleLib.SetupSimpleMembershipSalesItem('T-SILVER-NS-ITEM', 'T-SILVER-NOSUB');
        MemberModuleLib.SetupUpgrade('T-SILVER-NOSUB', 'T-320101-UPGRADE', 'T-GOLD', '', 'Upgrade from SILVER without recurring payments to GOLD');
        MemberModuleLib.SetupUpgrade('T-GOLD', MemberModuleLib.CreateItem('T-320100-DOWNGR-NS', '', 'Downgrade from GOLD to SILVER-NOSUB', 147), 'T-SILVER-NOSUB', '', 'Downgrade from GOLD to SILVER without recurring payments');

        // Gateways: one that supports subscriptions and one that does not.
        LibPaymentGateway.CreatePaymentGateway(Enum::"NPR PG Integrations"::Adyen);
        LibPaymentGateway.CreatePaymentGateway(Enum::"NPR PG Integrations"::Stripe);

        IsInitialized := true;
    end;

    local procedure SubscriptionCapableGateway(): Code[10]
    begin
        exit(GatewayCodeForIntegration(Enum::"NPR PG Integrations"::Adyen));
    end;

    local procedure GatewayCodeForIntegration(IntegrationType: Enum "NPR PG Integrations"): Code[10]
    var
        PaymentGateway: Record "NPR Magento Payment Gateway";
    begin
        PaymentGateway.SetRange("Integration Type", IntegrationType);
        Assert.IsTrue(PaymentGateway.FindFirst(), 'A payment gateway for this integration type is missing from the fixture.');
        exit(PaymentGateway.Code);
    end;

    local procedure MapExternalPaymentMethod(IntegrationType: Enum "NPR PG Integrations") ExternalPaymentMethodCode: Text[50]
    var
        PaymentMapping: Record "NPR Magento Payment Mapping";
    begin
        ExternalPaymentMethodCode := CopyStr(Format(IntegrationType) + '-' + DelChr(Format(CreateGuid()), '=', '{}-'), 1, MaxStrLen(ExternalPaymentMethodCode));
        PaymentMapping.Init();
        PaymentMapping."External Payment Method Code" := ExternalPaymentMethodCode;
        PaymentMapping."Payment Gateway Code" := GatewayCodeForIntegration(IntegrationType);
        PaymentMapping."Captured Externally" := true;
        PaymentMapping.Insert(true);
    end;

    local procedure CreateOrder(var EcomSalesHeader: Record "NPR Ecom Sales Header"; PayerEmail: Text[80]; PayerName: Text[150])
    begin
        LibEcommerce.CreateEcomSalesHeader(EcomSalesHeader);
        EcomSalesHeader."Sell-to Email" := PayerEmail;
        EcomSalesHeader."Sell-to Name" := PayerName;
        EcomSalesHeader.Modify();
    end;

    local procedure CreateMembershipForItem(MembershipSalesItemNo: Code[20]; var Membership: Record "NPR MM Membership")
    var
        MembershipEntryNo: Integer;
        ResponseMessage: Text;
    begin
        Assert.IsTrue(MemberApiLib.CreateMembership(MembershipSalesItemNo, MembershipEntryNo, ResponseMessage), ResponseMessage);
        Membership.Get(MembershipEntryNo);
    end;

    local procedure CreateMembershipActiveSince(MembershipSalesItemNo: Code[20]; ActivationDate: Date; var Membership: Record "NPR MM Membership")
    var
        AttributeCode: array[10] of Code[10];
        AttributeValue: array[10] of Code[10];
        MembershipEntryNo: Integer;
        ResponseMessage: Text;
    begin
        Assert.IsTrue(MemberApiLib.CreateMembership(MembershipSalesItemNo, ActivationDate, '', '', AttributeCode, AttributeValue, '', MembershipEntryNo, ResponseMessage), ResponseMessage);
        Membership.Get(MembershipEntryNo);
    end;

    local procedure BuildAlterationLine(var EcomSalesLine: Record "NPR Ecom Sales Line"; AlterationSetup: Record "NPR MM Members. Alter. Setup"; Membership: Record "NPR MM Membership"; Operation: Enum "NPR Ecom Membership Operation"; SubscriptionFlag: Boolean)
    begin
        BuildLine(EcomSalesLine, EcomSalesLine.Subtype::Membership, Operation, SubscriptionFlag);
        EcomSalesLine."No." := AlterationSetup."Sales Item No.";
        EcomSalesLine."Membership Id" := Membership.SystemId;
        EcomSalesLine."Alteration Option System Id" := AlterationSetup.SystemId;
    end;

    local procedure InsertCapturedAlterationLine(var EcomSalesLine: Record "NPR Ecom Sales Line"; EcomSalesHeader: Record "NPR Ecom Sales Header"; AlterationSetup: Record "NPR MM Members. Alter. Setup"; Membership: Record "NPR MM Membership"; Operation: Enum "NPR Ecom Membership Operation"; UnitPrice: Decimal; SubscriptionFlag: Boolean)
    begin
        EcomSalesLine.Init();
        EcomSalesLine."Document Entry No." := EcomSalesHeader."Entry No.";
        EcomSalesLine."Document Type" := EcomSalesHeader."Document Type";
        EcomSalesLine."External Document No." := CopyStr(EcomSalesHeader."External No.", 1, MaxStrLen(EcomSalesLine."External Document No."));
        EcomSalesLine."Line No." := NextLineNo(EcomSalesHeader);
        EcomSalesLine.Type := EcomSalesLine.Type::Item;
        EcomSalesLine.Subtype := EcomSalesLine.Subtype::Membership;
        EcomSalesLine."No." := AlterationSetup."Sales Item No.";
        EcomSalesLine."Membership Id" := Membership.SystemId;
        EcomSalesLine."Alteration Option System Id" := AlterationSetup.SystemId;
        EcomSalesLine.Quantity := 1;
        EcomSalesLine."Unit Price" := UnitPrice;
        EcomSalesLine."Line Amount" := UnitPrice;
        EcomSalesLine."Membership Operation" := Operation;
        EcomSalesLine.Captured := true;
        EcomSalesLine.Subscription := SubscriptionFlag;
        EcomSalesLine.Insert(true);
    end;

    local procedure InsertCapturedCreateLine(var EcomSalesLine: Record "NPR Ecom Sales Line"; EcomSalesHeader: Record "NPR Ecom Sales Header"; ItemNo: Code[20]; UnitPrice: Decimal; SubscriptionFlag: Boolean)
    begin
        EcomSalesLine.Init();
        EcomSalesLine."Document Entry No." := EcomSalesHeader."Entry No.";
        EcomSalesLine."Document Type" := EcomSalesHeader."Document Type";
        EcomSalesLine."External Document No." := CopyStr(EcomSalesHeader."External No.", 1, MaxStrLen(EcomSalesLine."External Document No."));
        EcomSalesLine."Line No." := NextLineNo(EcomSalesHeader);
        EcomSalesLine.Type := EcomSalesLine.Type::Item;
        EcomSalesLine.Subtype := EcomSalesLine.Subtype::Membership;
        EcomSalesLine."No." := ItemNo;
        EcomSalesLine."Member First Name" := 'Test';
        EcomSalesLine."Member Last Name" := 'User';
        EcomSalesLine."Member Email" := UniqueEmail();
        EcomSalesLine.Quantity := 1;
        EcomSalesLine."Unit Price" := UnitPrice;
        EcomSalesLine."Line Amount" := UnitPrice;
        EcomSalesLine."Membership Operation" := EcomSalesLine."Membership Operation"::CreateMembership;
        EcomSalesLine.Captured := true;
        EcomSalesLine.Subscription := SubscriptionFlag;
        EcomSalesLine.Insert(true);
    end;

    local procedure NextLineNo(EcomSalesHeader: Record "NPR Ecom Sales Header"): Integer
    var
        ExistingLine: Record "NPR Ecom Sales Line";
    begin
        ExistingLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        if ExistingLine.FindLast() then
            exit(ExistingLine."Line No." + 10000);
        exit(10000);
    end;

    local procedure NextPmtLineNo(EcomSalesHeader: Record "NPR Ecom Sales Header"): Integer
    var
        ExistingPmtLine: Record "NPR Ecom Sales Pmt. Line";
    begin
        ExistingPmtLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        if ExistingPmtLine.FindLast() then
            exit(ExistingPmtLine."Line No." + 10000);
        exit(10000);
    end;

    [Normal]
    [TryFunction]
    local procedure TryValidateSubscriptionDocumentRequirements(EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
    begin
        EcomSalesDocUtils.ValidateSubscriptionDocumentRequirements(EcomSalesHeader);
    end;

    local procedure GetSubscription(Membership: Record "NPR MM Membership"; var Subscription: Record "NPR MM Subscription")
    begin
        Subscription.Reset();
        Subscription.SetRange("Membership Entry No.", Membership."Entry No.");
        Assert.IsTrue(Subscription.FindFirst(), 'The membership must have a subscription record.');
    end;

    local procedure SubscriptionRequestCount(Subscription: Record "NPR MM Subscription"): Integer
    var
        SubscriptionRequest: Record "NPR MM Subscr. Request";
    begin
        SubscriptionRequest.SetRange("Subscription Entry No.", Subscription."Entry No.");
        exit(SubscriptionRequest.Count());
    end;

    local procedure SubscriptionRequestCount(Subscription: Record "NPR MM Subscription"; RequestType: Enum "NPR MM Subscr. Request Type"): Integer
    var
        SubscriptionRequest: Record "NPR MM Subscr. Request";
    begin
        SubscriptionRequest.SetRange("Subscription Entry No.", Subscription."Entry No.");
        SubscriptionRequest.SetRange(Type, RequestType);
        exit(SubscriptionRequest.Count());
    end;

    local procedure SubscriptionPaymentRequestCount(Subscription: Record "NPR MM Subscription") PaymentRequests: Integer
    var
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
    begin
        SubscriptionRequest.SetRange("Subscription Entry No.", Subscription."Entry No.");
        if not SubscriptionRequest.FindSet() then
            exit(0);
        repeat
            SubscrPaymentRequest.SetRange("Subscr. Request Entry No.", SubscriptionRequest."Entry No.");
            PaymentRequests += SubscrPaymentRequest.Count();
        until SubscriptionRequest.Next() = 0;
    end;

    local procedure InsertPartialRegretRequest(Subscription: Record "NPR MM Subscription"; var PartialRegretRequest: Record "NPR MM Subscr. Request")
    begin
        PartialRegretRequest.Init();
        PartialRegretRequest."Entry No." := 0;
        PartialRegretRequest.Type := PartialRegretRequest.Type::"Partial Regret";
        PartialRegretRequest.Status := PartialRegretRequest.Status::New;
        PartialRegretRequest."Processing Status" := PartialRegretRequest."Processing Status"::Pending;
        PartialRegretRequest."Subscription Entry No." := Subscription."Entry No.";
        PartialRegretRequest."Membership Code" := Subscription."Membership Code";
        PartialRegretRequest."Terminate At" := CalcDate('<+7D>', Today());
        PartialRegretRequest.Insert(true);
    end;

    local procedure SetMembershipAutoRenew(var Membership: Record "NPR MM Membership"; AutoRenew: Enum "NPR MM MembershipAutoRenew")
    begin
        Membership."Auto-Renew" := AutoRenew;
        Membership.Modify(true);
    end;

    local procedure LastEntryValidUntil(Membership: Record "NPR MM Membership"): Date
    var
        MembershipEntry: Record "NPR MM Membership Entry";
    begin
        GetLastMembershipEntry(Membership, MembershipEntry);
        exit(MembershipEntry."Valid Until Date");
    end;

    local procedure FindStoredCard(Token: Text[64]; var MemberPaymentMethod: Record "NPR MM Member Payment Method"): Boolean
    begin
        MemberPaymentMethod.Reset();
        MemberPaymentMethod.SetRange("Payment Token", Token);
        exit(MemberPaymentMethod.FindFirst());
    end;

    local procedure StoredCardCount(Token: Text[64]): Integer
    var
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
    begin
        MemberPaymentMethod.SetRange("Payment Token", Token);
        exit(MemberPaymentMethod.Count());
    end;

    local procedure IsDefaultCardForMembership(Membership: Record "NPR MM Membership"; Token: Text[64]): Boolean
    var
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        MembershipPmtMethodMap: Record "NPR MM MembershipPmtMethodMap";
    begin
        if not FindStoredCard(Token, MemberPaymentMethod) then
            exit(false);
        if not MembershipPmtMethodMap.Get(MemberPaymentMethod.SystemId, Membership.SystemId) then
            exit(false);
        exit(MembershipPmtMethodMap.Default);
    end;

    local procedure MembershipCardMapCount(Membership: Record "NPR MM Membership"): Integer
    var
        MembershipPmtMethodMap: Record "NPR MM MembershipPmtMethodMap";
    begin
        MembershipPmtMethodMap.SetRange(MembershipId, Membership.SystemId);
        exit(MembershipPmtMethodMap.Count());
    end;

    local procedure CardCountForAccount(UserAccount: Record "NPR UserAccount"): Integer
    var
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
    begin
        MemberPaymentMethod.SetRange("BC Record System ID", UserAccount.SystemId);
        exit(MemberPaymentMethod.Count());
    end;

    local procedure FindUserAccount(Email: Text[80]; var UserAccount: Record "NPR UserAccount"): Boolean
    begin
        UserAccount.Reset();
        UserAccount.SetRange(EmailAddress, Email);
        exit(UserAccount.FindFirst());
    end;

    local procedure CreateUserAccount(Email: Text[80]; FirstName: Text[100]; LastName: Text[100]; var UserAccount: Record "NPR UserAccount")
    var
        UserAccountMgt: Codeunit "NPR UserAccountMgtImpl";
    begin
        Clear(UserAccount);
        UserAccount.Init();
        UserAccount.EmailAddress := Email;
        UserAccount.FirstName := FirstName;
        UserAccount.LastName := LastName;
        UserAccountMgt.CreateAccount(UserAccount);
    end;

    local procedure StoreCardForMembership(Email: Text[80]; Token: Text[64]; Membership: Record "NPR MM Membership")
    var
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        MembershipPmtMethodMap: Record "NPR MM MembershipPmtMethodMap";
        UserAccount: Record "NPR UserAccount";
    begin
        CreateUserAccount(Email, 'Anna', 'Payer', UserAccount);

        MemberPaymentMethod.Init();
        MemberPaymentMethod."Entry No." := 0;
        MemberPaymentMethod."Table No." := UserAccount.RecordId().TableNo();
        MemberPaymentMethod."BC Record ID" := UserAccount.RecordId();
        MemberPaymentMethod."BC Record System ID" := UserAccount.SystemId;
        MemberPaymentMethod.PSP := MemberPaymentMethod.PSP::Adyen;
        MemberPaymentMethod.Status := MemberPaymentMethod.Status::Active;
        MemberPaymentMethod."Payment Token" := Token;
        MemberPaymentMethod."Shopper Reference" := 'TEST-SHOPPER-REF';
        MemberPaymentMethod."PAN Last 4 Digits" := '4242';
        MemberPaymentMethod."Masked PAN" := '************4242';
        MemberPaymentMethod.Insert(true);

        MembershipPmtMethodMap.Init();
        MembershipPmtMethodMap.PaymentMethodId := MemberPaymentMethod.SystemId;
        MembershipPmtMethodMap.MembershipId := Membership.SystemId;
        MembershipPmtMethodMap.Status := MembershipPmtMethodMap.Status::Active;
        MembershipPmtMethodMap.Default := true;
        MembershipPmtMethodMap.Insert(true);
    end;

    local procedure GetLastMembershipEntry(Membership: Record "NPR MM Membership"; var MembershipEntry: Record "NPR MM Membership Entry")
    begin
        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.SetRange(Blocked, false);
        MembershipEntry.SetFilter(Context, '<>%1', MembershipEntry.Context::REGRET);
        Assert.IsTrue(MembershipEntry.FindLast(), 'Membership should have at least one active membership entry.');
    end;

    local procedure SetSubscriptionAutoRenewInternal(Membership: Record "NPR MM Membership")
    var
        Subscription: Record "NPR MM Subscription";
    begin
        Subscription.SetRange("Membership Entry No.", Membership."Entry No.");
        Assert.IsTrue(Subscription.FindFirst(), 'Creating a membership should have created a subscription record.');
        Subscription."Auto-Renew" := Subscription."Auto-Renew"::YES_INTERNAL;
        Subscription.Modify(true);
    end;

    local procedure CreateMemberPaymentMethod(var MemberPaymentMethod: Record "NPR MM Member Payment Method")
    begin
        MemberPaymentMethod.Init();
        MemberPaymentMethod."Entry No." := 0;
        MemberPaymentMethod.PSP := MemberPaymentMethod.PSP::Adyen;
        MemberPaymentMethod.Status := MemberPaymentMethod.Status::Active;
        MemberPaymentMethod."Payment Token" := CopyStr('TOKEN-' + Format(CreateGuid()), 1, MaxStrLen(MemberPaymentMethod."Payment Token"));
        MemberPaymentMethod."PAN Last 4 Digits" := '4242';
        MemberPaymentMethod."Masked PAN" := '************4242';
        MemberPaymentMethod.Insert(true);
    end;

    local procedure CreateCapturedMagentoPaymentLine(var PaymentLine: Record "NPR Magento Payment Line"; TransactionId: Code[50]; LineAmount: Decimal)
    begin
        NextPaymentLineNo += 10000;
        PaymentLine.Init();
        PaymentLine."Document Table No." := Database::"NPR Ecom Sales Header";
        PaymentLine."Line No." := NextPaymentLineNo;
        PaymentLine."Transaction ID" := TransactionId;
        PaymentLine.Amount := LineAmount;
        PaymentLine."Date Captured" := Today();
        PaymentLine.Insert(true);
    end;
}
