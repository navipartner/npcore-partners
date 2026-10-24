#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 85556 "NPR MM PmtMethodPayerAPITest"
{
    Subtype = Test;

    var
        _Assert: Codeunit Assert;
        _IsInitialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateWithoutPayer_StoresCardOnAdminAccount()
    var
        Membership: Record "NPR MM Membership";
        Admin: Record "NPR MM Member";
        UserAccount: Record "NPR UserAccount";
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        Response: JsonObject;
        Token: Text[64];
    begin
        // [SCENARIO] Without payer fields the card is stored on the admin member's account, as before.
        Initialize();

        // [GIVEN] A membership whose admin member has no user account
        CreateMembershipWithAdmin(Membership, Admin);
        AssertNoAccountForEmail(Admin."E-Mail Address", 'Fixture');
        Token := UniqueToken('NOPAYER');

        // [WHEN] A payment method is posted without payerAccountId and payerEmail
        Response := PostPaymentMethod(Membership, PaymentMethodRequest(Token, true));

        // [THEN] An account is created from the admin member and the card is stored on it
        _Assert.IsTrue(FindUserAccount(AccountEmail(Admin."E-Mail Address"), UserAccount), 'An account for the admin member must be created.');
        AssertCardStoredOnAccount(Response, Membership, Token, UserAccount, MemberPaymentMethod, true);
        _Assert.AreEqual(ExpectedFirstName(Admin), UserAccount.FirstName, 'Account first name must come from the admin member.');
        _Assert.AreEqual(Admin."Last Name", UserAccount.LastName, 'Account last name must come from the admin member.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateWithoutPayerAndWithoutAdmin_RejectedWithoutWrites()
    var
        Membership: Record "NPR MM Membership";
        Response: JsonObject;
        CountsBefore: Text;
        Token: Text[64];
    begin
        // [SCENARIO] Without payer fields a membership without an admin member is rejected and nothing is written.
        Initialize();

        // [GIVEN] A fresh membership without members
        CreateMembershipWithoutAdmin(Membership);
        Token := UniqueToken('NOADMIN');
        CountsBefore := RowCounts();

        // [WHEN] A payment method is posted without payer fields
        Response := PostPaymentMethod(Membership, PaymentMethodRequest(Token, true));

        // [THEN] The request is rejected with the existing message and no rows are written
        AssertErrorResponse(Response, 400, 'generic_error', 'Membership did not contain at least one admin member to assign card to.', 'No admin');
        _Assert.AreEqual(CountsBefore, RowCounts(), 'A rejected request must not write any rows.');
        _Assert.AreEqual(0, StoredCardCount(Token), 'No card must be stored.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateWithPayerAccountId_NoAdmin_StoresCardOnPayerAccount()
    var
        Membership: Record "NPR MM Membership";
        PayerAccount: Record "NPR UserAccount";
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        Body: JsonObject;
        Response: JsonObject;
        AccountCountBefore: Integer;
        Token: Text[64];
    begin
        // [SCENARIO] payerAccountId stores the card on that account even when the membership has no admin member.
        Initialize();

        // [GIVEN] A membership without members and an existing payer account
        CreateMembershipWithoutAdmin(Membership);
        CreateUserAccount(UniqueEmail(), 'Paula', 'Payer', PayerAccount);
        AccountCountBefore := AccountCount();
        Token := UniqueToken('PAYERID');

        // [WHEN] An Adyen payment method with a shopper reference is posted with payerAccountId
        Body := PaymentMethodRequest(Token, true);
        Body.Add('payerAccountId', FormatId(PayerAccount.SystemId));
        Response := PostPaymentMethod(Membership, Body);

        // [THEN] The card is stored on the payer account and linked to the membership
        AssertCardStoredOnAccount(Response, Membership, Token, PayerAccount, MemberPaymentMethod, true);
        _Assert.AreEqual(AccountCountBefore, AccountCount(), 'No account must be created.');

        // [THEN] Shopper recognition exists for the payer account
        _Assert.IsTrue(ShopperRecognitionExists(Format(PayerAccount.AccountNo)), 'Shopper recognition must be created for the payer account.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateWithUnknownPayerAccountId_ReturnsNotFoundWithoutWrites()
    var
        Membership: Record "NPR MM Membership";
        Admin: Record "NPR MM Member";
        Body: JsonObject;
        Response: JsonObject;
        UnknownAccountId: Guid;
        CountsBefore: Text;
        Token: Text[64];
    begin
        // [SCENARIO] An unknown payerAccountId returns 404 and writes nothing, not even an admin account.
        Initialize();

        // [GIVEN] A fresh membership whose admin member has no account, and an account id that does not exist
        CreateMembershipWithAdmin(Membership, Admin);
        UnknownAccountId := CreateGuid();
        Token := UniqueToken('UNKNOWNID');
        CountsBefore := RowCounts();

        // [WHEN] A payment method is posted with the unknown payerAccountId
        Body := PaymentMethodRequest(Token, true);
        Body.Add('payerAccountId', FormatId(UnknownAccountId));
        Response := PostPaymentMethod(Membership, Body);

        // [THEN] 404 with the account-not-found message, and no rows are written
        AssertErrorResponse(Response, 404, 'resource_not_found', StrSubstNo('%1 Not Found', StrSubstNo('User account with id "%1" could not be found', UnknownAccountId)), 'Unknown payerAccountId');
        _Assert.AreEqual(CountsBefore, RowCounts(), 'A rejected request must not write any rows.');
        AssertNoAccountForEmail(Admin."E-Mail Address", 'Unknown payerAccountId');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateWithMalformedPayerAccountId_RejectedWithoutWrites()
    var
        Membership: Record "NPR MM Membership";
        Admin: Record "NPR MM Member";
    begin
        // [SCENARIO] A malformed payerAccountId is rejected with 400 and writes nothing.
        Initialize();

        // [GIVEN] A fresh membership whose admin member has no account
        CreateMembershipWithAdmin(Membership, Admin);

        // [WHEN] Payment methods are posted with each malformed payerAccountId
        // [THEN] Each request returns 400 with the malformed-parameter message and writes no rows
        AssertPayerFieldRejected(Membership, Admin, 'payerAccountId', TextToken(''), 'empty string');
        AssertPayerFieldRejected(Membership, Admin, 'payerAccountId', TextToken('  '), 'whitespace');
        AssertPayerFieldRejected(Membership, Admin, 'payerAccountId', TextToken('abc'), 'not a GUID');
        AssertPayerFieldRejected(Membership, Admin, 'payerAccountId', IntegerToken(123), 'number');
        AssertPayerFieldRejected(Membership, Admin, 'payerAccountId', EmptyObjectToken(), 'object');
        AssertPayerFieldRejected(Membership, Admin, 'payerAccountId', TextToken('00000000-0000-0000-0000-000000000000'), 'null GUID');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateWithNullPayerAccountId_BehavesAsWithoutPayer()
    var
        Membership: Record "NPR MM Membership";
        Admin: Record "NPR MM Member";
        UserAccount: Record "NPR UserAccount";
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        Body: JsonObject;
        Response: JsonObject;
        Token: Text[64];
    begin
        // [SCENARIO] payerAccountId sent as JSON null is treated as not sent.
        Initialize();

        // [GIVEN] A membership whose admin member has no account
        CreateMembershipWithAdmin(Membership, Admin);
        Token := UniqueToken('NULLID');

        // [WHEN] A payment method is posted with payerAccountId = null
        Body := PaymentMethodRequest(Token, true);
        Body.Add('payerAccountId', NullToken());
        Response := PostPaymentMethod(Membership, Body);

        // [THEN] The card is stored on an account created from the admin member
        _Assert.IsTrue(FindUserAccount(AccountEmail(Admin."E-Mail Address"), UserAccount), 'An account for the admin member must be created.');
        AssertCardStoredOnAccount(Response, Membership, Token, UserAccount, MemberPaymentMethod, true);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateWithPayerAccountIdAndPayerEmail_RejectedWithoutWrites()
    var
        Membership: Record "NPR MM Membership";
        Admin: Record "NPR MM Member";
        PayerAccount: Record "NPR UserAccount";
        UserAccount: Record "NPR UserAccount";
        Body: JsonObject;
        Response: JsonObject;
        NewEmail: Text[80];
        CountsBefore: Text;
        Token: Text[64];
    begin
        // [SCENARIO] Sending both payerAccountId and payerEmail is rejected and writes nothing.
        Initialize();

        // [GIVEN] A fresh membership whose admin member has no account, an existing payer account and an unused e-mail
        CreateMembershipWithAdmin(Membership, Admin);
        CreateUserAccount(UniqueEmail(), 'Paula', 'Payer', PayerAccount);
        NewEmail := UniqueEmail();
        Token := UniqueToken('BOTH');
        CountsBefore := RowCounts();

        // [WHEN] A payment method is posted with both payer fields
        Body := PaymentMethodRequest(Token, true);
        Body.Add('payerAccountId', FormatId(PayerAccount.SystemId));
        Body.Add('payerEmail', NewEmail);
        Response := PostPaymentMethod(Membership, Body);

        // [THEN] 400 with the only-one message, no account for the new e-mail and no rows written
        AssertErrorResponse(Response, 400, 'generic_error', 'Only one of payerAccountId or payerEmail can be specified.', 'Both payer fields');
        _Assert.AreEqual(CountsBefore, RowCounts(), 'A rejected request must not write any rows.');
        _Assert.IsFalse(FindUserAccount(NewEmail, UserAccount), 'No account must be created for the new e-mail.');
        AssertNoAccountForEmail(Admin."E-Mail Address", 'Both payer fields');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateWithNullPayerAccountIdAndPayerEmail_UsesPayerEmail()
    var
        Membership: Record "NPR MM Membership";
        Admin: Record "NPR MM Member";
        PayerAccount: Record "NPR UserAccount";
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        Body: JsonObject;
        Response: JsonObject;
        PayerEmail: Text[80];
        Token: Text[64];
    begin
        // [SCENARIO] payerAccountId = null next to a valid payerEmail uses the e-mail path.
        Initialize();

        // [GIVEN] A membership whose admin member has no account, and an unused payer e-mail
        CreateMembershipWithAdmin(Membership, Admin);
        PayerEmail := UniqueEmail();
        Token := UniqueToken('NULLIDEMAIL');

        // [WHEN] A payment method is posted with payerAccountId = null and payerEmail
        Body := PaymentMethodRequest(Token, true);
        Body.Add('payerAccountId', NullToken());
        Body.Add('payerEmail', PayerEmail);
        Response := PostPaymentMethod(Membership, Body);

        // [THEN] The card is stored on a new account for the payer e-mail, and no admin account is created
        _Assert.IsTrue(FindUserAccount(PayerEmail, PayerAccount), 'An account for the payer e-mail must be created.');
        AssertCardStoredOnAccount(Response, Membership, Token, PayerAccount, MemberPaymentMethod, true);
        AssertNoAccountForEmail(Admin."E-Mail Address", 'Null payerAccountId with payerEmail');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateWithPayerEmailCaseAndSpaceVariant_ReusesExistingAccount()
    var
        Membership: Record "NPR MM Membership";
        PayerAccount: Record "NPR UserAccount";
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        Body: JsonObject;
        Response: JsonObject;
        PayerEmail: Text[80];
        AccountCountBefore: Integer;
        Token: Text[64];
    begin
        // [SCENARIO] payerEmail is matched to an existing account regardless of case and surrounding spaces.
        Initialize();

        // [GIVEN] A membership without members and an existing account for the payer e-mail
        CreateMembershipWithoutAdmin(Membership);
        PayerEmail := UniqueEmail();
        CreateUserAccount(PayerEmail, 'Paula', 'Payer', PayerAccount);
        AccountCountBefore := AccountCount();
        Token := UniqueToken('EMAILVARIANT');

        // [WHEN] A payment method is posted with the e-mail in upper case and padded with spaces
        Body := PaymentMethodRequest(Token, true);
        Body.Add('payerEmail', '  ' + UpperCase(PayerEmail) + ' ');
        Response := PostPaymentMethod(Membership, Body);

        // [THEN] The existing account is reused
        AssertCardStoredOnAccount(Response, Membership, Token, PayerAccount, MemberPaymentMethod, true);
        _Assert.AreEqual(AccountCountBefore, AccountCount(), 'No account must be created.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateWithNewPayerEmail_CreatesEmailOnlyAccount()
    var
        Membership: Record "NPR MM Membership";
        Admin: Record "NPR MM Member";
        PayerAccount: Record "NPR UserAccount";
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        Body: JsonObject;
        Response: JsonObject;
        PayerEmail: Text[80];
        Token: Text[64];
    begin
        // [SCENARIO] An unknown payerEmail that is not the admin e-mail creates an account with only the e-mail.
        Initialize();

        // [GIVEN] A membership whose admin member has no account, and an unused payer e-mail
        CreateMembershipWithAdmin(Membership, Admin);
        PayerEmail := UniqueEmail();
        Token := UniqueToken('NEWEMAIL');

        // [WHEN] A payment method is posted with payerEmail
        Body := PaymentMethodRequest(Token, true);
        Body.Add('payerEmail', PayerEmail);
        Response := PostPaymentMethod(Membership, Body);

        // [THEN] An e-mail-only account holds the card, and no admin account is created
        _Assert.IsTrue(FindUserAccount(PayerEmail, PayerAccount), 'An account for the payer e-mail must be created.');
        AssertCardStoredOnAccount(Response, Membership, Token, PayerAccount, MemberPaymentMethod, true);
        _Assert.AreEqual('', PayerAccount.FirstName, 'An e-mail-only account must have no first name.');
        _Assert.AreEqual('', PayerAccount.LastName, 'An e-mail-only account must have no last name.');
        AssertNoAccountForEmail(Admin."E-Mail Address", 'New payerEmail');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateWithAdminEmailAsPayerEmail_CreatesAccountFromAdminMember()
    var
        Membership: Record "NPR MM Membership";
        Admin: Record "NPR MM Member";
        PayerAccount: Record "NPR UserAccount";
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        Body: JsonObject;
        Response: JsonObject;
        Token: Text[64];
    begin
        // [SCENARIO] payerEmail equal to the admin e-mail creates the account from the admin member's details.
        Initialize();

        // [GIVEN] A membership whose admin member has no account
        CreateMembershipWithAdmin(Membership, Admin);
        Token := UniqueToken('ADMINEMAIL');

        // [WHEN] A payment method is posted with the admin e-mail in a different case
        Body := PaymentMethodRequest(Token, true);
        Body.Add('payerEmail', ' ' + UpperCase(Admin."E-Mail Address") + ' ');
        Response := PostPaymentMethod(Membership, Body);

        // [THEN] The account carries the admin member's names and phone number and holds the card
        _Assert.IsTrue(FindUserAccount(AccountEmail(Admin."E-Mail Address"), PayerAccount), 'An account for the admin e-mail must be created.');
        AssertCardStoredOnAccount(Response, Membership, Token, PayerAccount, MemberPaymentMethod, true);
        _Assert.AreEqual(ExpectedFirstName(Admin), PayerAccount.FirstName, 'Account first name must include the member first and middle name.');
        _Assert.AreEqual(Admin."Last Name", PayerAccount.LastName, 'Account last name must come from the admin member.');
        _Assert.AreEqual(Admin."Phone No.".Trim(), PayerAccount.PhoneNo, 'Account phone number must come from the admin member.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateWithPayerEmail_NoAdmin_CreatesEmailOnlyAccount()
    var
        Membership: Record "NPR MM Membership";
        PayerAccount: Record "NPR UserAccount";
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        Body: JsonObject;
        Response: JsonObject;
        PayerEmail: Text[80];
        AccountCountBefore: Integer;
        Token: Text[64];
    begin
        // [SCENARIO] payerEmail works for a membership without an admin member.
        Initialize();

        // [GIVEN] A membership without members and an unused payer e-mail
        CreateMembershipWithoutAdmin(Membership);
        PayerEmail := UniqueEmail();
        AccountCountBefore := AccountCount();
        Token := UniqueToken('EMAILNOADMIN');

        // [WHEN] A payment method is posted with payerEmail
        Body := PaymentMethodRequest(Token, true);
        Body.Add('payerEmail', PayerEmail);
        Response := PostPaymentMethod(Membership, Body);

        // [THEN] One e-mail-only account is created and holds the card
        _Assert.IsTrue(FindUserAccount(PayerEmail, PayerAccount), 'An account for the payer e-mail must be created.');
        AssertCardStoredOnAccount(Response, Membership, Token, PayerAccount, MemberPaymentMethod, true);
        _Assert.AreEqual(AccountCountBefore + 1, AccountCount(), 'Exactly one account must be created.');
        _Assert.AreEqual('', PayerAccount.FirstName, 'An e-mail-only account must have no first name.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateWithInvalidPayerEmail_RejectedWithoutWrites()
    var
        Membership: Record "NPR MM Membership";
        Admin: Record "NPR MM Member";
        TooLongEmail: Text;
        Tab: Text[1];
        Nbsp: Text[1];
    begin
        // [SCENARIO] An invalid payerEmail is rejected with 400 and writes nothing.
        Initialize();
        Tab[1] := 9;
        Nbsp[1] := 160;

        // [GIVEN] A fresh membership whose admin member has no account, and an otherwise valid 81-character e-mail
        CreateMembershipWithAdmin(Membership, Admin);
        TooLongEmail := PadStr('', 69, 'a') + '@example.com';
        _Assert.AreEqual(81, StrLen(TooLongEmail), 'Fixture: the long e-mail must be 81 characters.');

        // [WHEN] Payment methods are posted with each invalid payerEmail
        // [THEN] Each request returns 400 with the malformed-parameter message and writes no rows
        AssertPayerFieldRejected(Membership, Admin, 'payerEmail', TextToken(''), 'empty string');
        AssertPayerFieldRejected(Membership, Admin, 'payerEmail', TextToken('  '), 'whitespace');
        AssertPayerFieldRejected(Membership, Admin, 'payerEmail', TextToken('not-an-email'), 'not an e-mail');
        AssertPayerFieldRejected(Membership, Admin, 'payerEmail', EmptyObjectToken(), 'object');
        AssertPayerFieldRejected(Membership, Admin, 'payerEmail', TextToken(TooLongEmail), '81 characters');
        AssertPayerFieldRejected(Membership, Admin, 'payerEmail', TextToken('Jane <' + UniqueEmail() + '>'), 'display name');
        AssertPayerFieldRejected(Membership, Admin, 'payerEmail', TextToken('<' + UniqueEmail() + '>'), 'angle brackets');
        AssertPayerFieldRejected(Membership, Admin, 'payerEmail', TextToken('jane ' + UniqueEmail()), 'inner space');
        AssertPayerFieldRejected(Membership, Admin, 'payerEmail', TextToken('jane' + Tab + UniqueEmail()), 'tab');
        AssertPayerFieldRejected(Membership, Admin, 'payerEmail', TextToken('"jane"' + UniqueEmail()), 'quoted name');
        AssertPayerFieldRejected(Membership, Admin, 'payerEmail', TextToken(UniqueEmail() + '(jane)'), 'comment');
        AssertPayerFieldRejected(Membership, Admin, 'payerEmail', TextToken('jane' + Nbsp + UniqueEmail()), 'nbsp');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateSameCardTwiceForNewPayerEmail_ReusesAccountAndCard()
    var
        Membership: Record "NPR MM Membership";
        PayerAccount: Record "NPR UserAccount";
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        SecondMemberPaymentMethod: Record "NPR MM Member Payment Method";
        Body: JsonObject;
        Response: JsonObject;
        PayerEmail: Text[80];
        AccountCountAfterFirst: Integer;
        Token: Text[64];
    begin
        // [SCENARIO] Posting the same card twice for a new payerEmail reuses the account and the card.
        Initialize();

        // [GIVEN] A card posted once for a new payer e-mail
        CreateMembershipWithoutAdmin(Membership);
        PayerEmail := UniqueEmail();
        Token := UniqueToken('TWICE');
        Body := PaymentMethodRequest(Token, true);
        Body.Add('payerEmail', PayerEmail);
        Response := PostPaymentMethod(Membership, Body);
        _Assert.IsTrue(FindUserAccount(PayerEmail, PayerAccount), 'Fixture: an account for the payer e-mail must be created.');
        AssertCardStoredOnAccount(Response, Membership, Token, PayerAccount, MemberPaymentMethod, true);
        AccountCountAfterFirst := AccountCount();

        // [WHEN] The same card is posted again for the same payer e-mail
        Body := PaymentMethodRequest(Token, true);
        Body.Add('payerEmail', PayerEmail);
        Response := PostPaymentMethod(Membership, Body);

        // [THEN] No account or card is added and the response points to the same card and account
        AssertCardStoredOnAccount(Response, Membership, Token, PayerAccount, SecondMemberPaymentMethod, true);
        _Assert.AreEqual(AccountCountAfterFirst, AccountCount(), 'No second account must be created.');
        _Assert.AreEqual(1, StoredCardCount(Token), 'The card must be stored once.');
        _Assert.AreEqual(MemberPaymentMethod.SystemId, SecondMemberPaymentMethod.SystemId, 'The second request must reuse the card.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateWithPayer_CardStoredOnOtherAccount_StoresSeparateCardOnPayer()
    var
        Membership: Record "NPR MM Membership";
        OtherAccount: Record "NPR UserAccount";
        PayerAccount: Record "NPR UserAccount";
        OtherMemberPaymentMethod: Record "NPR MM Member Payment Method";
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        OtherMembershipPmtMethodMap: Record "NPR MM MembershipPmtMethodMap";
        Body: JsonObject;
        Response: JsonObject;
        OtherEmail: Text[80];
        Token: Text[64];
    begin
        // [SCENARIO] A card already stored on another account gets its own row on the payer account; the other row is untouched.
        Initialize();

        // [GIVEN] A card stored on account A and linked to the membership as default, and a payer account B
        CreateMembershipWithoutAdmin(Membership);
        OtherEmail := UniqueEmail();
        Token := UniqueToken('OTHERACC');
        StoreCardForMembership(OtherEmail, Token, Membership);
        _Assert.IsTrue(FindUserAccount(OtherEmail, OtherAccount), 'Fixture: account A must exist.');
        _Assert.IsTrue(FindCardOnAccount(Token, OtherAccount, OtherMemberPaymentMethod), 'Fixture: card must be stored on account A.');
        CreateUserAccount(UniqueEmail(), 'Paula', 'Payer', PayerAccount);

        // [WHEN] The same card is posted for payer B as non-default
        Body := PaymentMethodRequest(Token, false);
        Body.Add('payerAccountId', FormatId(PayerAccount.SystemId));
        Response := PostPaymentMethod(Membership, Body);

        // [THEN] B gets its own card row and the response points to B
        AssertCardStoredOnAccount(Response, Membership, Token, PayerAccount, MemberPaymentMethod, false);
        _Assert.AreEqual(2, StoredCardCount(Token), 'The card must exist once on each account.');
        _Assert.AreEqual(1, CardCountForAccount(PayerAccount), 'Payer account must hold one card.');

        // [THEN] A's card and its link stay unchanged
        OtherMemberPaymentMethod.GetBySystemId(OtherMemberPaymentMethod.SystemId);
        _Assert.AreEqual(OtherAccount.SystemId, OtherMemberPaymentMethod."BC Record System ID", 'Card on account A must keep its owner.');
        _Assert.IsTrue(OtherMemberPaymentMethod.Status = OtherMemberPaymentMethod.Status::Active, 'Card on account A must stay active.');
        _Assert.IsTrue(OtherMembershipPmtMethodMap.Get(OtherMemberPaymentMethod.SystemId, Membership.SystemId), 'Link of card A must remain.');
        _Assert.IsTrue(OtherMembershipPmtMethodMap.Status = OtherMembershipPmtMethodMap.Status::Active, 'Link of card A must stay active.');
        _Assert.IsTrue(OtherMembershipPmtMethodMap.Default, 'Link of card A must stay default.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateWithAdminEmailAsPayerEmail_AdminAccountExists_ReusesAccount()
    var
        Membership: Record "NPR MM Membership";
        Admin: Record "NPR MM Member";
        AdminAccount: Record "NPR UserAccount";
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        Body: JsonObject;
        Response: JsonObject;
        AccountCountBefore: Integer;
        Token: Text[64];
    begin
        // [SCENARIO] payerEmail equal to the admin e-mail reuses the admin's existing account.
        Initialize();

        // [GIVEN] A membership whose admin member already has an account
        CreateMembershipWithAdmin(Membership, Admin);
        CreateUserAccount(AccountEmail(Admin."E-Mail Address"), 'Existing', 'Admin', AdminAccount);
        AccountCountBefore := AccountCount();
        Token := UniqueToken('ADMINEXISTS');

        // [WHEN] A payment method is posted with the admin e-mail as payerEmail
        Body := PaymentMethodRequest(Token, true);
        Body.Add('payerEmail', Admin."E-Mail Address");
        Response := PostPaymentMethod(Membership, Body);

        // [THEN] The existing account holds the card and no account is created
        AssertCardStoredOnAccount(Response, Membership, Token, AdminAccount, MemberPaymentMethod, true);
        _Assert.AreEqual(AccountCountBefore, AccountCount(), 'No account must be created.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateWithPayerAccountId_AdminWithoutAccount_CreatesNoAdminAccount()
    var
        Membership: Record "NPR MM Membership";
        Admin: Record "NPR MM Member";
        PayerAccount: Record "NPR UserAccount";
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        Body: JsonObject;
        Response: JsonObject;
        Token: Text[64];
    begin
        // [SCENARIO] With payerAccountId, an admin member without an account does not get one.
        Initialize();

        // [GIVEN] A membership whose admin member has no account, and an existing payer account
        CreateMembershipWithAdmin(Membership, Admin);
        CreateUserAccount(UniqueEmail(), 'Paula', 'Payer', PayerAccount);
        Token := UniqueToken('NOADMINACC');

        // [WHEN] A payment method is posted with payerAccountId
        Body := PaymentMethodRequest(Token, true);
        Body.Add('payerAccountId', FormatId(PayerAccount.SystemId));
        Response := PostPaymentMethod(Membership, Body);

        // [THEN] The card is on the payer account and no account exists for the admin e-mail
        AssertCardStoredOnAccount(Response, Membership, Token, PayerAccount, MemberPaymentMethod, true);
        AssertNoAccountForEmail(Admin."E-Mail Address", 'payerAccountId with admin');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateWithPayerAccountId_CardLinkedToOtherMembership_AddsLinkToSameCard()
    var
        FirstMembership: Record "NPR MM Membership";
        SecondMembership: Record "NPR MM Membership";
        Admin: Record "NPR MM Member";
        AdminAccount: Record "NPR UserAccount";
        PayerAccount: Record "NPR UserAccount";
        StoredMemberPaymentMethod: Record "NPR MM Member Payment Method";
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        FirstMembershipPmtMethodMap: Record "NPR MM MembershipPmtMethodMap";
        Body: JsonObject;
        Response: JsonObject;
        PayerEmail: Text[80];
        Token: Text[64];
    begin
        // [SCENARIO] A card already on the payer account and linked to another membership is reused and gets a new link.
        Initialize();

        // [GIVEN] A card on payer account B, linked to the first membership as default, and a second membership with an admin member
        CreateMembershipWithoutAdmin(FirstMembership);
        CreateMembershipWithAdmin(SecondMembership, Admin);
        PayerEmail := UniqueEmail();
        Token := UniqueToken('SECONDMS');
        StoreCardForMembership(PayerEmail, Token, FirstMembership);
        _Assert.IsTrue(FindUserAccount(PayerEmail, PayerAccount), 'Fixture: payer account must exist.');
        _Assert.IsTrue(FindCardOnAccount(Token, PayerAccount, StoredMemberPaymentMethod), 'Fixture: card must be stored on the payer account.');

        // [GIVEN] The second membership's admin member has its own account
        CreateUserAccount(AccountEmail(Admin."E-Mail Address"), 'Existing', 'Admin', AdminAccount);

        // [WHEN] The same card is posted for the second membership with payerAccountId = B
        Body := PaymentMethodRequest(Token, true);
        Body.Add('payerAccountId', FormatId(PayerAccount.SystemId));
        Response := PostPaymentMethod(SecondMembership, Body);

        // [THEN] The existing card is reused and linked to the second membership
        AssertCardStoredOnAccount(Response, SecondMembership, Token, PayerAccount, MemberPaymentMethod, true);
        _Assert.AreEqual(StoredMemberPaymentMethod.SystemId, MemberPaymentMethod.SystemId, 'The existing card must be reused.');
        _Assert.AreEqual(1, StoredCardCount(Token), 'The card must be stored once.');

        // [THEN] The link to the first membership stays unchanged
        _Assert.IsTrue(FirstMembershipPmtMethodMap.Get(StoredMemberPaymentMethod.SystemId, FirstMembership.SystemId), 'Link to the first membership must remain.');
        _Assert.IsTrue(FirstMembershipPmtMethodMap.Status = FirstMembershipPmtMethodMap.Status::Active, 'Link to the first membership must stay active.');
        _Assert.IsTrue(FirstMembershipPmtMethodMap.Default, 'Link to the first membership must stay default.');

        // [THEN] Shopper recognition is created for the payer account, not for the admin account
        _Assert.IsTrue(ShopperRecognitionExists(Format(PayerAccount.AccountNo)), 'Shopper recognition must be created for the payer account.');
        _Assert.IsFalse(ShopperRecognitionExists(Format(AdminAccount.AccountNo)), 'No shopper recognition must be created for the admin account.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateWithPayerDefault_CardStoredOnOtherAccount_OtherLinkLosesDefault()
    var
        Membership: Record "NPR MM Membership";
        OtherAccount: Record "NPR UserAccount";
        PayerAccount: Record "NPR UserAccount";
        OtherMemberPaymentMethod: Record "NPR MM Member Payment Method";
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        OtherMembershipPmtMethodMap: Record "NPR MM MembershipPmtMethodMap";
        Body: JsonObject;
        Response: JsonObject;
        OtherEmail: Text[80];
        Token: Text[64];
    begin
        // [SCENARIO] A default card for the payer takes the default from the other account's link on the same membership.
        Initialize();

        // [GIVEN] A card stored on account A and linked to the membership as default, and a payer account B
        CreateMembershipWithoutAdmin(Membership);
        OtherEmail := UniqueEmail();
        Token := UniqueToken('OTHERDEF');
        StoreCardForMembership(OtherEmail, Token, Membership);
        _Assert.IsTrue(FindUserAccount(OtherEmail, OtherAccount), 'Fixture: account A must exist.');
        _Assert.IsTrue(FindCardOnAccount(Token, OtherAccount, OtherMemberPaymentMethod), 'Fixture: card must be stored on account A.');
        CreateUserAccount(UniqueEmail(), 'Paula', 'Payer', PayerAccount);

        // [WHEN] The same card is posted for payer B as default
        Body := PaymentMethodRequest(Token, true);
        Body.Add('payerAccountId', FormatId(PayerAccount.SystemId));
        Response := PostPaymentMethod(Membership, Body);

        // [THEN] B gets its own card row, linked to the membership as default
        AssertCardStoredOnAccount(Response, Membership, Token, PayerAccount, MemberPaymentMethod, true);
        _Assert.AreEqual(2, StoredCardCount(Token), 'The card must exist once on each account.');

        // [THEN] A's link stays active but is no longer default
        _Assert.IsTrue(OtherMembershipPmtMethodMap.Get(OtherMemberPaymentMethod.SystemId, Membership.SystemId), 'Link of card A must remain.');
        _Assert.IsTrue(OtherMembershipPmtMethodMap.Status = OtherMembershipPmtMethodMap.Status::Active, 'Link of card A must stay active.');
        _Assert.IsFalse(OtherMembershipPmtMethodMap.Default, 'Link of card A must no longer be default.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateWithoutPayer_AdminHasAccount_ReusesAdminAccount()
    var
        Membership: Record "NPR MM Membership";
        Admin: Record "NPR MM Member";
        AdminAccount: Record "NPR UserAccount";
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        Response: JsonObject;
        AccountCountBefore: Integer;
        Token: Text[64];
    begin
        // [SCENARIO] Without payer fields the card is stored on the admin member's existing account.
        Initialize();

        // [GIVEN] A membership whose admin member already has an account
        CreateMembershipWithAdmin(Membership, Admin);
        CreateUserAccount(AccountEmail(Admin."E-Mail Address"), 'Existing', 'Admin', AdminAccount);
        AccountCountBefore := AccountCount();
        Token := UniqueToken('ADMINHASACC');

        // [WHEN] A payment method is posted without payerAccountId and payerEmail
        Response := PostPaymentMethod(Membership, PaymentMethodRequest(Token, true));

        // [THEN] The existing admin account holds the card and no account is created
        AssertCardStoredOnAccount(Response, Membership, Token, AdminAccount, MemberPaymentMethod, true);
        _Assert.AreEqual(AccountCountBefore, AccountCount(), 'No account must be created.');
    end;

    // === Helper Procedures ===

    local procedure AssertPayerFieldRejected(Membership: Record "NPR MM Membership"; Admin: Record "NPR MM Member"; FieldName: Text; FieldValue: JsonToken; Variant: Text)
    var
        Body: JsonObject;
        Response: JsonObject;
        CountsBefore: Text;
        Token: Text[64];
    begin
        Token := UniqueToken('REJECT');
        Body := PaymentMethodRequest(Token, true);
        Body.Add(FieldName, FieldValue);
        CountsBefore := RowCounts();

        Response := PostPaymentMethod(Membership, Body);

        AssertErrorResponse(Response, 400, 'generic_error', 'Malformed parameter: ' + FieldName, FieldName + ' ' + Variant);
        _Assert.AreEqual(CountsBefore, RowCounts(), StrSubstNo('%1 %2: a rejected request must not write any rows.', FieldName, Variant));
        _Assert.AreEqual(0, StoredCardCount(Token), StrSubstNo('%1 %2: no card must be stored.', FieldName, Variant));
        AssertNoAccountForEmail(Admin."E-Mail Address", FieldName + ' ' + Variant);
    end;

    local procedure AssertCardStoredOnAccount(Response: JsonObject; Membership: Record "NPR MM Membership"; Token: Text[64]; UserAccount: Record "NPR UserAccount"; var MemberPaymentMethod: Record "NPR MM Member Payment Method"; ExpectedDefault: Boolean)
    var
        MembershipPmtMethodMap: Record "NPR MM MembershipPmtMethodMap";
        JsonHelper: Codeunit "NPR Json Helper";
        Body: JsonObject;
    begin
        Body := GetResponseBodyOrError(Response, 'Create payment method failed.');
        _Assert.AreEqual(FormatId(UserAccount.SystemId), JsonHelper.GetJText(Body.AsToken(), 'paymentMethod.accountId', true), 'Response accountId must be the account that holds the card.');
        _Assert.IsTrue(FindCardOnAccount(Token, UserAccount, MemberPaymentMethod), 'The card must be stored on the expected account.');
        _Assert.AreEqual(FormatId(MemberPaymentMethod.SystemId), JsonHelper.GetJText(Body.AsToken(), 'paymentMethod.id', true), 'Response id must be the stored card.');
        _Assert.IsTrue(MembershipPmtMethodMap.Get(MemberPaymentMethod.SystemId, Membership.SystemId), 'The card must be linked to the membership.');
        _Assert.IsTrue(MembershipPmtMethodMap.Status = MembershipPmtMethodMap.Status::Active, 'The card link must be active.');
        _Assert.AreEqual(ExpectedDefault, MembershipPmtMethodMap.Default, 'The card link default flag must match the request.');
        _Assert.AreEqual(ExpectedDefault, JsonHelper.GetJBoolean(Body.AsToken(), 'paymentMethod.default', true), 'Response default must match the request.');
    end;

    local procedure AssertErrorResponse(Response: JsonObject; ExpectedStatusCode: Integer; ExpectedCode: Text; ExpectedMessage: Text; Context: Text)
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        JsonHelper: Codeunit "NPR Json Helper";
        Body: JsonObject;
        JToken: JsonToken;
    begin
        _Assert.IsTrue(Response.Get('statusCode', JToken), Context + ': response must contain a status code.');
        _Assert.AreEqual(ExpectedStatusCode, JToken.AsValue().AsInteger(), Context + ': unexpected status code.');
        Body := LibraryNPRetailAPI.GetResponseBody(Response);
        _Assert.AreEqual(ExpectedCode, JsonHelper.GetJText(Body.AsToken(), 'code', false), Context + ': unexpected error code.');
        _Assert.AreEqual(ExpectedMessage, JsonHelper.GetJText(Body.AsToken(), 'message', false), Context + ': unexpected error message.');
    end;

    local procedure AssertNoAccountForEmail(Email: Text; Context: Text)
    var
        UserAccount: Record "NPR UserAccount";
    begin
        _Assert.IsFalse(FindUserAccount(AccountEmail(Email), UserAccount), Context + ': no account must exist for the admin e-mail.');
    end;

    local procedure PaymentMethodRequest(Token: Text[64]; IsDefault: Boolean) Body: JsonObject
    var
        PaymentMethod: JsonObject;
    begin
        PaymentMethod.Add('PSP', 'Adyen');
        PaymentMethod.Add('paymentToken', Token);
        PaymentMethod.Add('shopperReference', 'TEST-SHOPPER-REF');
        PaymentMethod.Add('maskedPAN', '************4242');
        PaymentMethod.Add('PANLastDigits', '4242');
        PaymentMethod.Add('paymentBrand', 'visa');
        PaymentMethod.Add('default', IsDefault);
        Body.Add('paymentMethod', PaymentMethod);
    end;

    local procedure PostPaymentMethod(Membership: Record "NPR MM Membership"; Body: JsonObject): JsonObject
    begin
        exit(InvokeApi('POST', StrSubstNo('membership/%1/paymentMethods', FormatId(Membership.SystemId)), Body));
    end;

    local procedure CreateMembershipWithAdmin(var Membership: Record "NPR MM Membership"; var Admin: Record "NPR MM Member")
    var
        MembershipId: Text;
        MembershipNumber: Text;
        MemberId: Text;
        MemberNumber: Text;
    begin
        CreateGoldMembership('T-320100', MembershipId, MembershipNumber);
        AddMember(0D, MembershipId, MemberId, MemberNumber);
        Membership.GetBySystemId(MembershipId);
        Admin.GetBySystemId(MemberId);
    end;

    local procedure CreateMembershipWithoutAdmin(var Membership: Record "NPR MM Membership")
    var
        MembershipId: Text;
        MembershipNumber: Text;
    begin
        CreateGoldMembership('T-320100', MembershipId, MembershipNumber);
        Membership.GetBySystemId(MembershipId);
    end;

    local procedure RowCounts(): Text
    var
        UserAccount: Record "NPR UserAccount";
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        MembershipPmtMethodMap: Record "NPR MM MembershipPmtMethodMap";
        EFTShopperRecognition: Record "NPR EFT Shopper Recognition";
    begin
        exit(StrSubstNo('UserAccount=%1, MemberPaymentMethod=%2, MembershipPmtMethodMap=%3, EFTShopperRecognition=%4',
            UserAccount.Count(), MemberPaymentMethod.Count(), MembershipPmtMethodMap.Count(), EFTShopperRecognition.Count()));
    end;

    local procedure AccountCount(): Integer
    var
        UserAccount: Record "NPR UserAccount";
    begin
        exit(UserAccount.Count());
    end;

    local procedure ShopperRecognitionExists(EntityKey: Code[20]): Boolean
    var
        EFTShopperRecognition: Record "NPR EFT Shopper Recognition";
    begin
        EFTShopperRecognition.SetRange("Entity Type", EFTShopperRecognition."Entity Type"::UserAccount);
        EFTShopperRecognition.SetRange("Entity Key", EntityKey);
        exit(not EFTShopperRecognition.IsEmpty());
    end;

    local procedure FindCardOnAccount(Token: Text[64]; UserAccount: Record "NPR UserAccount"; var MemberPaymentMethod: Record "NPR MM Member Payment Method"): Boolean
    begin
        MemberPaymentMethod.Reset();
        MemberPaymentMethod.SetRange("Payment Token", Token);
        MemberPaymentMethod.SetRange("BC Record System ID", UserAccount.SystemId);
        exit(MemberPaymentMethod.FindFirst());
    end;

    local procedure ExpectedFirstName(Member: Record "NPR MM Member"): Text
    begin
        if Member."Middle Name" = '' then
            exit(Member."First Name");
        exit(Member."First Name" + ' ' + Member."Middle Name");
    end;

    local procedure AccountEmail(Email: Text): Text[80]
    begin
        exit(CopyStr(Email.Trim().ToLower(), 1, 80));
    end;

    local procedure FormatId(Id: Guid): Text
    begin
        exit(Format(Id, 0, 4).ToLower());
    end;

    local procedure TextToken(Value: Text): JsonToken
    var
        JValue: JsonValue;
    begin
        JValue.SetValue(Value);
        exit(JValue.AsToken());
    end;

    local procedure IntegerToken(Value: Integer): JsonToken
    var
        JValue: JsonValue;
    begin
        JValue.SetValue(Value);
        exit(JValue.AsToken());
    end;

    local procedure NullToken(): JsonToken
    var
        JValue: JsonValue;
    begin
        JValue.SetValueToNull();
        exit(JValue.AsToken());
    end;

    local procedure EmptyObjectToken(): JsonToken
    var
        JObject: JsonObject;
    begin
        exit(JObject.AsToken());
    end;

    // Copied from codeunit 85171 "NPR MM Subscription Audit Test".

    local procedure Initialize()
    var
        MemberLibrary: Codeunit "NPR Library - Member Module";
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
    begin
        if _IsInitialized then
            exit;

        MemberLibrary.Initialize();
        MemberLibrary.CreateScenario_SmokeTest();

        LibraryNPRetailAPI.CreateAPIPermission(UserSecurityId(), CompanyName(), 'NPR API Membership');

        _IsInitialized := true;
    end;

    local procedure CreateGoldMembership(SalesItem: Code[20]; var MembershipId: Text; var MembershipNumber: Text)
    var
        JsonHelper: Codeunit "NPR Json Helper";
        Body: JsonObject;
        Response: JsonObject;
        ResponseBody: JsonObject;
    begin
        Body.Add('itemNumber', SalesItem);
        Body.Add('activationDate', CalcDate('<-6M>'));

        Response := InvokeApi('POST', 'membership', Body);
        ResponseBody := GetResponseBodyOrError(Response, 'Create membership failed.');

        MembershipId := JsonHelper.GetJText(ResponseBody.AsToken(), 'membership.membershipId', true);
        MembershipNumber := JsonHelper.GetJText(ResponseBody.AsToken(), 'membership.membershipNumber', true);
    end;

    local procedure AddMember(DateOfBirth: Date; MembershipId: Text; var MemberId: Text; var MemberNumber: Text)
    var
        MemberLibrary: Codeunit "NPR Library - Member Module";
        JsonHelper: Codeunit "NPR Json Helper";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        Body: JsonObject;
        MemberJson: JsonObject;
        Response: JsonObject;
        ResponseBody: JsonObject;
    begin
        MemberLibrary.SetRandomMemberInfoData(MemberInfoCapture);
        if (DateOfBirth <> 0D) then
            MemberInfoCapture.Birthday := DateOfBirth;

        MemberJson.Add('firstName', MemberInfoCapture."First Name");
        MemberJson.Add('middleName', MemberInfoCapture."Middle Name");
        MemberJson.Add('lastName', MemberInfoCapture."Last Name");
        MemberJson.Add('email', MemberInfoCapture."E-Mail Address");
        MemberJson.Add('phoneNo', MemberInfoCapture."Phone No.");
        MemberJson.Add('birthday', MemberInfoCapture.Birthday);
        MemberJson.Add('city', MemberInfoCapture.City);
        MemberJson.Add('country', MemberInfoCapture.Country);
        MemberJson.Add('postCode', MemberInfoCapture."Post Code Code");
        MemberJson.Add('preferredLanguage', MemberInfoCapture.PreferredLanguageCode);

        Body.Add('member', MemberJson);

        Response := InvokeApi('POST', StrSubstNo('membership/%1/addMember', MembershipId), Body);
        ResponseBody := GetResponseBodyOrError(Response, 'Add member failed.');

        MemberId := JsonHelper.GetJText(ResponseBody.AsToken(), 'member.memberId', true);
        MemberNumber := JsonHelper.GetJText(ResponseBody.AsToken(), 'member.memberNumber', true);
    end;

    local procedure InvokeApi(Method: Text; Path: Text; Body: JsonObject) Response: JsonObject
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        QueryParameters: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        Headers.Add('x-api-version', Format(Today, 0, 9));
        exit(LibraryNPRetailAPI.CallApi(Method, Path, Body, QueryParameters, Headers));
    end;

    local procedure GetResponseBodyOrError(Response: JsonObject; ErrorText: Text) Body: JsonObject
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        ResponseText: Text;
    begin
        Body := LibraryNPRetailAPI.GetResponseBody(Response);
        if not LibraryNPRetailAPI.IsSuccessStatusCode(Response) then begin
            Body.WriteTo(ResponseText);
            Error('%1 Response: %2', ErrorText, ResponseText);
        end;
    end;

    // Copied from codeunit 85249 "NPR EcomSubscriptionTest".

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

    local procedure StoredCardCount(Token: Text[64]): Integer
    var
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
    begin
        MemberPaymentMethod.SetRange("Payment Token", Token);
        exit(MemberPaymentMethod.Count());
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
}
#endif
