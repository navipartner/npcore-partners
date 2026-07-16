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
    procedure LineLevelSubscriptionOnRenewLineRejected()
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
    begin
        // [Given] A membership Renew line flagged as a subscription
        BuildLine(EcomSalesLine, EcomSalesLine.Subtype::Membership, EcomSalesLine."Membership Operation"::RenewMembership, true);

        // [When/Then] Only Create/Confirm may be subscriptions — Renew is rejected
        asserterror EcomCreateMMShipImpl.ValidateSubscriptionFlag(EcomSalesLine);
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
        // [Given] A subscription membership line + email + a tokenized card payment
        LibEcommerce.CreateEcomSalesHeader(EcomSalesHeader);
        EcomSalesHeader."Sell-to Email" := 'buyer@ecommerce.test';
        EcomSalesHeader.Modify();
        InsertSubscriptionMembershipLine(EcomSalesLine, EcomSalesHeader);
        InsertTokenizedPaymentLine(EcomSalesHeader, 'psp-ref-1', 'par-ref-1');

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
        PaymentLine."Transaction ID" := 'TEST-PSP-REF';
        PaymentLine.Amount := 100;
        PaymentLine."Date Captured" := Today();
        PaymentLine.Insert(true);
    end;

    local procedure UniqueEmail(): Text[80]
    var
        Email: Text[80];
    begin
        Email := CopyStr(DelChr(Format(CreateGuid()), '=', '{}-') + '@t.example.com', 1, MaxStrLen(Email));
        exit(Email);
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
    var
        EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line";
    begin
        EcomSalesPmtLine.Init();
        EcomSalesPmtLine."Document Entry No." := EcomSalesHeader."Entry No.";
        EcomSalesPmtLine."Line No." := 10000;
        EcomSalesPmtLine."Payment Method Type" := EcomSalesPmtLine."Payment Method Type"::"Payment Method";
        EcomSalesPmtLine."PSP Token" := PspToken;
        EcomSalesPmtLine."PAR Token" := ParToken;
        EcomSalesPmtLine.Amount := 100;
        EcomSalesPmtLine.Insert(true);
    end;

    local procedure Initialize()
    var
        MembershipSetup: Record "NPR MM Membership Setup";
        MemberCommunity: Record "NPR MM Member Community";
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

        IsInitialized := true;
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
