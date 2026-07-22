codeunit 85250 "NPR Customer GDPR Test"
{
    Subtype = Test;

    var
        _Library: Codeunit "NPR Library - Customer GDPR";
        _Assert: Codeunit Assert;

    // region DoAnonymization - Permission checks

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DoAnon_PermissionDisabled_ThrowsError()
    var
        NPGDPRMgt: Codeunit "NPR NP GDPR Management";
        CustNo: Code[20];
        ReasonTxt: Text;
    begin
        // [SCENARIO] DoAnonymization errors when user has NPR Anonymize Customers = false
        // [GIVEN] Customer exists, User Setup has permission disabled
        CustNo := _Library.CreateCustomer();
        _Library.SetupUserPermissionDisabled();
        _Library.SetupForcePermissionDisabled();

        // [WHEN] DoAnonymization is called
        asserterror NPGDPRMgt.DoAnonymization(CustNo, ReasonTxt);

        // [THEN] Permission error is raised
        _Assert.ExpectedError('You do not have permission to anonymize customers');
    end;

    // endregion

    // region DoAnonymization - Negative response values (customer state)

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DoAnon_CustNotFound_ReturnsFalse()
    var
        NPGDPRMgt: Codeunit "NPR NP GDPR Management";
        NonExistentCustNo: Code[20];
        ReasonTxt: Text;
        Result: Boolean;
    begin
        // [SCENARIO] DoAnonymization returns false with reason when customer does not exist
        // [GIVEN] Non-existent customer number
        _Library.EnableCustomerGDPRV2Feature();
        _Library.EnsureGDPRSetup('5Y');
        NonExistentCustNo := 'DOESNOTEXIST';
        _Library.SetupUserPermission();

        // [WHEN] DoAnonymization is called
        Result := NPGDPRMgt.DoAnonymization(NonExistentCustNo, ReasonTxt);

        // [THEN] Returns false with appropriate reason
        _Assert.IsFalse(Result, 'Should return false for non-existent customer.');
        _Assert.IsTrue(StrPos(ReasonTxt, 'Customer does not exist') > 0,
            StrSubstNo('Reason should indicate customer not found, but was: %1', ReasonTxt));
        _Library.Assert_LogEntryExists(NonExistentCustNo, false);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DoAnon_AlreadyAnonymized_ReturnsFalse()
    var
        NPGDPRMgt: Codeunit "NPR NP GDPR Management";
        CustNo: Code[20];
        ReasonTxt: Text;
        Result: Boolean;
    begin
        // [SCENARIO] DoAnonymization returns false when customer is already anonymized
        // [GIVEN] Already-anonymized customer
        _Library.EnableCustomerGDPRV2Feature();
        _Library.EnsureGDPRSetup('5Y');
        CustNo := _Library.CreateAnonymizedCustomer();
        _Library.SetupUserPermission();

        // [WHEN] DoAnonymization is called
        Result := NPGDPRMgt.DoAnonymization(CustNo, ReasonTxt);

        // [THEN] Returns false with appropriate reason
        _Assert.IsFalse(Result, 'Should return false for already-anonymized customer.');
        _Assert.IsTrue(StrPos(ReasonTxt, 'already been anonymized') > 0,
            StrSubstNo('Reason should indicate already anonymized, but was: %1', ReasonTxt));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DoAnon_FutureCleanup_ReturnsFalse()
    var
        NPGDPRMgt: Codeunit "NPR NP GDPR Management";
        CustNo: Code[20];
        ReasonTxt: Text;
        Result: Boolean;
    begin
        // [SCENARIO] DoAnonymization returns false when customer has future cleanup date
        // [GIVEN] Customer with NPR Estimated Cleanup Date in the future
        _Library.EnableCustomerGDPRV2Feature();
        _Library.EnsureGDPRSetup('5Y');
        CustNo := _Library.CreateCustomerWithFutureCleanupDate();
        _Library.SetupUserPermission();

        // [WHEN] DoAnonymization is called
        Result := NPGDPRMgt.DoAnonymization(CustNo, ReasonTxt);

        // [THEN] Returns false with appropriate reason
        _Assert.IsFalse(Result, 'Should return false for customer not yet due.');
        _Assert.IsTrue(StrPos(ReasonTxt, 'not yet due') > 0,
            StrSubstNo('Reason should indicate not yet due, but was: %1', ReasonTxt));
    end;

    // endregion

    // region DoAnonymization - Blocking conditions

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DoAnon_OpenSalesDoc_ReturnsFalse()
    var
        NPGDPRMgt: Codeunit "NPR NP GDPR Management";
        CustNo: Code[20];
        ReasonTxt: Text;
        Result: Boolean;
    begin
        // [SCENARIO] DoAnonymization returns false when customer has open sales documents
        // [GIVEN] Customer with an open sales order
        CustNo := _Library.CreateCustomer();
        _Library.SetupUserPermission();
        _Library.CreateSalesOrder(CustNo);

        // [WHEN] DoAnonymization is called
        Result := NPGDPRMgt.DoAnonymization(CustNo, ReasonTxt);

        // [THEN] Returns false, customer not anonymized
        _Assert.IsFalse(Result, 'Should return false for customer with open sales doc.');
        _Library.Assert_CustomerIsNotAnonymized(CustNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DoAnon_OpenCLE_ReturnsFalse()
    var
        NPGDPRMgt: Codeunit "NPR NP GDPR Management";
        CustNo: Code[20];
        ReasonTxt: Text;
        Result: Boolean;
    begin
        // [SCENARIO] DoAnonymization returns false when customer has open ledger entries
        // [GIVEN] Customer with an open cust. ledger entry
        CustNo := _Library.CreateCustomer();
        _Library.SetupUserPermission();
        _Library.CreateOpenCustLedgerEntry(CustNo);

        // [WHEN] DoAnonymization is called
        Result := NPGDPRMgt.DoAnonymization(CustNo, ReasonTxt);

        // [THEN] Returns false, customer not anonymized
        _Assert.IsFalse(Result, 'Should return false for customer with open CLE.');
        _Library.Assert_CustomerIsNotAnonymized(CustNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DoAnon_IsMember_ReturnsFalse()
    var
        NPGDPRMgt: Codeunit "NPR NP GDPR Management";
        CustNo: Code[20];
        ReasonTxt: Text;
        Result: Boolean;
    begin
        // [SCENARIO] DoAnonymization returns false when customer has an active membership
        // [GIVEN] Customer linked to a membership
        CustNo := _Library.CreateCustomer();
        _Library.SetupUserPermission();
        _Library.CreateMembershipForCustomer(CustNo);

        // [WHEN] DoAnonymization is called
        Result := NPGDPRMgt.DoAnonymization(CustNo, ReasonTxt);

        // [THEN] Returns false with member-specific reason
        _Assert.IsFalse(Result, 'Should return false for customer who is a member.');
        _Assert.IsTrue(StrPos(ReasonTxt, 'is a member') > 0,
            StrSubstNo('Reason should indicate member, but was: %1', ReasonTxt));
        _Library.Assert_CustomerIsNotAnonymized(CustNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DoAnon_OpenJournal_ReturnsFalse()
    var
        NPGDPRMgt: Codeunit "NPR NP GDPR Management";
        CustNo: Code[20];
        ReasonTxt: Text;
        Result: Boolean;
    begin
        // [SCENARIO] DoAnonymization returns false when customer has pending journal entries
        // [GIVEN] Customer with a gen. journal line
        CustNo := _Library.CreateCustomer();
        _Library.SetupUserPermission();
        _Library.CreateGenJnlLine(CustNo);

        // [WHEN] DoAnonymization is called
        Result := NPGDPRMgt.DoAnonymization(CustNo, ReasonTxt);

        // [THEN] Returns false, customer not anonymized
        _Assert.IsFalse(Result, 'Should return false for customer with open journal.');
        _Library.Assert_CustomerIsNotAnonymized(CustNo);
    end;

    // endregion

    // region DoAnonymization - Success path

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DoAnon_CleanCustomer_Anonymized()
    var
        NPGDPRMgt: Codeunit "NPR NP GDPR Management";
        CustNo: Code[20];
        ReasonTxt: Text;
        Result: Boolean;
    begin
        // [SCENARIO] DoAnonymization succeeds for a clean customer with no blocking conditions
        // [GIVEN] Clean customer with permission
        CustNo := _Library.CreateCustomer();
        _Library.SetupUserPermission();

        // [WHEN] DoAnonymization is called
        Result := NPGDPRMgt.DoAnonymization(CustNo, ReasonTxt);

        // [THEN] Returns true, customer is anonymized, success log entry created
        _Assert.IsTrue(Result, 'Should return true for clean customer.');
        _Assert.IsTrue(StrPos(ReasonTxt, 'has been anonymized') > 0,
            StrSubstNo('Reason should indicate success, but was: %1', ReasonTxt));
        _Library.Assert_CustomerIsAnonymized(CustNo);
        _Library.Assert_LogEntryExists(CustNo, true);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DoAnon_Failure_LogEntryCreated()
    var
        NPGDPRMgt: Codeunit "NPR NP GDPR Management";
        GDPRLogEntry: Record "NPR Customer GDPR Log Entries";
        CustNo: Code[20];
        ReasonTxt: Text;
    begin
        // [SCENARIO] Failed anonymization creates a log entry with correct validation flags
        // [GIVEN] Customer with open sales document
        _Library.EnableCustomerGDPRV2Feature();
        _Library.EnsureGDPRSetup('5Y');
        CustNo := _Library.CreateCustomerWithPastCleanupDate();
        // Seed activity older than the 5Y retention so RecalculateForAnonymization recomputes a PAST cleanup
        // date, keeping the customer past the "not yet due" (-3) gate so the open-sales-document path is exercised.
        _Library.SeedPOSEntryForCustomer(CustNo, CalcDate('<-6Y>', Today()));
        _Library.SetupUserPermission();
        _Library.CreateSalesOrder(CustNo);

        // [WHEN] DoAnonymization is called
        NPGDPRMgt.DoAnonymization(CustNo, ReasonTxt);

        // [THEN] Failure log entry exists with OpenSalesDocuments = true
        _Library.Assert_LogEntryExists(CustNo, false);

        GDPRLogEntry.SetRange("Customer No", CustNo);
        GDPRLogEntry.FindLast();
        _Assert.IsTrue(GDPRLogEntry."Open Sales Documents", 'Log should indicate open sales documents.');
        _Assert.IsFalse(GDPRLogEntry."Customer is a Member", 'Log should not indicate member.');
        _Assert.IsTrue(StrPos(GDPRLogEntry.Reason, 'open entries') > 0,
            StrSubstNo('Log reason should mention open entries, but was: %1', GDPRLogEntry.Reason));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DoAnon_TwoCustomers_DistinctLogs()
    var
        NPGDPRMgt: Codeunit "NPR NP GDPR Management";
        LogEntry1: Record "NPR Customer GDPR Log Entries";
        LogEntry2: Record "NPR Customer GDPR Log Entries";
        CustNo1: Code[20];
        CustNo2: Code[20];
        ReasonTxt: Text;
    begin
        // [SCENARIO] Two consecutive anonymizations produce distinct log entries (no PK collision)
        // [GIVEN] Two clean customers
        CustNo1 := _Library.CreateCustomer();
        CustNo2 := _Library.CreateCustomer();
        _Library.SetupUserPermission();

        // [WHEN] Both are anonymized via the same codeunit instance
        NPGDPRMgt.DoAnonymization(CustNo1, ReasonTxt);
        NPGDPRMgt.DoAnonymization(CustNo2, ReasonTxt);

        // [THEN] Each customer has a distinct log entry
        LogEntry1.SetRange("Customer No", CustNo1);
        _Assert.IsTrue(LogEntry1.FindFirst(), 'Log entry for customer 1 not found.');

        LogEntry2.SetRange("Customer No", CustNo2);
        _Assert.IsTrue(LogEntry2.FindFirst(), 'Log entry for customer 2 not found.');

        _Assert.AreNotEqual(LogEntry1."Entry No", LogEntry2."Entry No", 'Log entries should have distinct Entry No values.');
    end;

    // endregion

    // region Anonymization Request - Non-member flow (mirrors page AnonymizeCustomer logic)

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Request_Company_NonMember_Anonymized()
    var
        NPGDPRMgt: Codeunit "NPR NP GDPR Management";
        CustNo: Code[20];
        ReasonTxt: Text;
        Result: Boolean;
    begin
        // [SCENARIO] Non-member company request is ANONYMIZED when customer is clean
        // [GIVEN] Clean customer
        CustNo := _Library.CreateCustomer();
        _Library.SetupUserPermission();

        // [WHEN] DoAnonymization processes the customer
        Result := NPGDPRMgt.DoAnonymization(CustNo, ReasonTxt);

        // [THEN] Returns true, customer is anonymized, reason indicates success
        _Assert.IsTrue(Result, 'Customer should be anonymized.');
        _Library.Assert_CustomerIsAnonymized(CustNo);
        _Assert.IsTrue(StrPos(ReasonTxt, 'has been anonymized') > 0,
            StrSubstNo('Reason should indicate success, but was: %1', ReasonTxt));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Request_Company_NonMember_Rejected()
    var
        NPGDPRMgt: Codeunit "NPR NP GDPR Management";
        CustNo: Code[20];
        ReasonTxt: Text;
        Result: Boolean;
    begin
        // [SCENARIO] Non-member company request is REJECTED when customer has open sales documents
        // [GIVEN] Customer with open sales order
        CustNo := _Library.CreateCustomer();
        _Library.SetupUserPermission();
        _Library.CreateSalesOrder(CustNo);

        // [WHEN] DoAnonymization processes the customer
        Result := NPGDPRMgt.DoAnonymization(CustNo, ReasonTxt);

        // [THEN] Returns false, customer is not anonymized
        _Assert.IsFalse(Result, 'Customer should not be anonymized.');
        _Library.Assert_CustomerIsNotAnonymized(CustNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Request_CustNotFound_Rejected()
    var
        NPGDPRMgt: Codeunit "NPR NP GDPR Management";
        ReasonTxt: Text;
        Result: Boolean;
    begin
        // [SCENARIO] Request is REJECTED when customer does not exist
        // [GIVEN] Non-existent customer
        _Library.EnableCustomerGDPRV2Feature();
        _Library.EnsureGDPRSetup('5Y');
        _Library.SetupUserPermission();

        // [WHEN] DoAnonymization processes the non-existent customer
        Result := NPGDPRMgt.DoAnonymization('DOESNOTEXIST', ReasonTxt);

        // [THEN] Returns false with reason indicating customer not found
        _Assert.IsFalse(Result, 'Should not be anonymized.');
        _Assert.IsTrue(StrPos(ReasonTxt, 'Customer does not exist') > 0,
            StrSubstNo('Reason should indicate not found, but was: %1', ReasonTxt));
    end;

    // endregion

    // region MMGDPRManagement - Member with linked Customer

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AnonymizeMembership_CustNotAnonymized()
    var
        LibraryMemberGDPR: Codeunit "NPR Library - Member GDPR";
        Membership: Record "NPR MM Membership";
        CustNo: Code[20];
        MembershipEntryNo: Integer;
        MemberEntryNo: Integer;
    begin
        // [SCENARIO] Anonymizing a membership does NOT anonymize the linked customer record
        // This documents the known design gap: membership PII is cleared but customer PII remains.
        // [GIVEN] V2 gating is OFF (orthogonal to this scenario); customer linked to an expired membership
        _Library.DisableCustomerGDPRV2Feature();
        CustNo := _Library.CreateCustomer();
        MembershipEntryNo := LibraryMemberGDPR.CreatePlainMembership(CalcDate('<-10D>'));
        MemberEntryNo := LibraryMemberGDPR.AddAdminMember(MembershipEntryNo);
        Membership.Get(MembershipEntryNo);
        Membership."Customer No." := CustNo;
        Membership.Modify(false);

        // [WHEN] Membership is anonymized
        LibraryMemberGDPR.AnonymizeMembership(MembershipEntryNo);

        // [THEN] Membership and member are anonymized
        LibraryMemberGDPR.Assert_AllIsAnonymized(MembershipEntryNo, MemberEntryNo);

        // [THEN] Customer record is NOT anonymized (known design gap)
        _Library.Assert_CustomerIsNotAnonymized(CustNo);
    end;

    // endregion

    // region AnonymizeCompanyNo - Shared company contact guard

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DoAnon_CompanyContact_Exclusive_GetsWiped()
    var
        NPGDPRMgt: Codeunit "NPR NP GDPR Management";
        CustNo: Code[20];
        ContactNo: Code[20];
        ReasonTxt: Text;
    begin
        // [SCENARIO] When the customer is the only entity linked to its company contact, the company contact is wiped.
        // [GIVEN] Customer + Company contact + Customer-Contact business relation, no other references
        CustNo := _Library.CreateCustomer();
        ContactNo := _Library.CreateCompanyContact();
        _Library.LinkCustomerToContact(CustNo, ContactNo);
        _Library.SetupUserPermission();

        // [WHEN] DoAnonymization runs
        NPGDPRMgt.DoAnonymization(CustNo, ReasonTxt);

        // [THEN] Customer is anonymized AND the company contact is wiped
        _Library.Assert_CustomerIsAnonymized(CustNo);
        _Library.Assert_ContactWiped(ContactNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DoAnon_CompanyContact_SharedWithLiveCustomer_NotWiped()
    var
        NPGDPRMgt: Codeunit "NPR NP GDPR Management";
        CustNoA, CustNoB : Code[20];
        ContactNo: Code[20];
        ReasonTxt: Text;
    begin
        // [SCENARIO] Two customers share one company contact. Anonymizing one must NOT wipe the shared contact.
        // [GIVEN] CustomerA and CustomerB both linked via business relation to the same Company contact
        CustNoA := _Library.CreateCustomer();
        CustNoB := _Library.CreateCustomer();
        ContactNo := _Library.CreateCompanyContact();
        _Library.LinkCustomerToContact(CustNoA, ContactNo);
        _Library.LinkCustomerToContact(CustNoB, ContactNo);
        _Library.SetupUserPermission();

        // [WHEN] Only CustomerA is anonymized
        NPGDPRMgt.DoAnonymization(CustNoA, ReasonTxt);

        // [THEN] CustomerA is anonymized but the shared company contact remains intact (still owned by CustomerB)
        _Library.Assert_CustomerIsAnonymized(CustNoA);
        _Library.Assert_CustomerIsNotAnonymized(CustNoB);
        _Library.Assert_ContactNotWiped(ContactNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DoAnon_CompanyContact_SharedWithAnonymizedCustomer_GetsWiped()
    var
        NPGDPRMgt: Codeunit "NPR NP GDPR Management";
        CustNoA, CustNoB : Code[20];
        ContactNo: Code[20];
        ReasonTxt: Text;
    begin
        // [SCENARIO] A peer customer pinning the company is already anonymized, so it does NOT keep the company alive.
        // [GIVEN] CustomerA linked to a Company contact; CustomerB already anonymized and also linked to the same contact
        CustNoA := _Library.CreateCustomer();
        CustNoB := _Library.CreateAnonymizedCustomer();
        ContactNo := _Library.CreateCompanyContact();
        _Library.LinkCustomerToContact(CustNoA, ContactNo);
        _Library.LinkCustomerToContact(CustNoB, ContactNo);
        _Library.SetupUserPermission();

        // [WHEN] CustomerA is anonymized
        NPGDPRMgt.DoAnonymization(CustNoA, ReasonTxt);

        // [THEN] The company contact is wiped — the already-anonymized peer does not count as a live reference
        _Library.Assert_CustomerIsAnonymized(CustNoA);
        _Library.Assert_ContactWiped(ContactNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DoAnon_CompanyContact_SharedWithVendor_NotWiped()
    var
        NPGDPRMgt: Codeunit "NPR NP GDPR Management";
        CustNo: Code[20];
        ContactNo: Code[20];
        ReasonTxt: Text;
    begin
        // [SCENARIO] The company contact is also linked to a Vendor via business relation. Anonymizing the customer must NOT wipe it.
        // [GIVEN] Customer + Company contact + a Vendor-link business relation on the same contact
        CustNo := _Library.CreateCustomer();
        ContactNo := _Library.CreateCompanyContact();
        _Library.LinkCustomerToContact(CustNo, ContactNo);
        _Library.LinkVendorToContact('VEND-SHARED', ContactNo);
        _Library.SetupUserPermission();

        // [WHEN] DoAnonymization runs
        NPGDPRMgt.DoAnonymization(CustNo, ReasonTxt);

        // [THEN] Customer is anonymized but the company contact is preserved (vendor-side still depends on it)
        _Library.Assert_CustomerIsAnonymized(CustNo);
        _Library.Assert_ContactNotWiped(ContactNo);
    end;

    // endregion

    // region DoAnonymization / ForceAnonymization - Bill-to reference guard

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DoAnon_ReferencedAsBillToByLiveCustomer_Rejected()
    var
        NPGDPRMgt: Codeunit "NPR NP GDPR Management";
        CustNoA, CustNoC : Code[20];
        ReasonTxt: Text;
        Result: Boolean;
    begin
        // [SCENARIO] Customer A is set as Bill-to on a live peer Customer C. Anonymizing A must be rejected so C's posting workflow isn't broken.
        // [GIVEN] Customer A (subject) and a live Customer C whose Bill-to Customer No. points at A
        _Library.EnableCustomerGDPRV2Feature();
        _Library.EnsureGDPRSetup('5Y');
        CustNoA := _Library.CreateCustomerWithPastCleanupDate();
        // Seed activity older than the 5Y retention so RecalculateForAnonymization recomputes a PAST cleanup
        // date, keeping A past the "not yet due" (-3) gate so the Bill-to (-4) guard is the one that rejects.
        _Library.SeedPOSEntryForCustomer(CustNoA, CalcDate('<-6Y>', Today()));
        CustNoC := _Library.CreateCustomer();
        _Library.SetBillToCustomer(CustNoC, CustNoA);
        _Library.SetupUserPermission();

        // [WHEN] DoAnonymization runs on A
        Result := NPGDPRMgt.DoAnonymization(CustNoA, ReasonTxt);

        // [THEN] Rejected with a Bill-to reason; A remains intact; failure log entry created
        _Assert.IsFalse(Result, 'Should be rejected when referenced as Bill-to by a live customer.');
        _Assert.IsTrue(StrPos(ReasonTxt, 'Bill-to Customer') > 0,
            StrSubstNo('Reason should mention Bill-to, but was: %1', ReasonTxt));
        _Library.Assert_CustomerIsNotAnonymized(CustNoA);
        _Library.Assert_LogEntryExists(CustNoA, false);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DoAnon_ReferencedAsBillToByAnonymizedCustomer_Succeeds()
    var
        NPGDPRMgt: Codeunit "NPR NP GDPR Management";
        CustNoA, CustNoC : Code[20];
        ReasonTxt: Text;
        Result: Boolean;
    begin
        // [SCENARIO] The customer referencing A as Bill-to is itself already anonymized, so it must not pin A.
        // [GIVEN] Customer A; already-anonymized Customer C whose Bill-to Customer No. is A
        _Library.EnableCustomerGDPRV2Feature();
        _Library.EnsureGDPRSetup('5Y');
        CustNoA := _Library.CreateCustomerWithPastCleanupDate();
        // Seed activity older than the 5Y retention so RecalculateForAnonymization recomputes a PAST cleanup
        // date, keeping A past the "not yet due" (-3) gate so the anonymized-peer success path is exercised.
        _Library.SeedPOSEntryForCustomer(CustNoA, CalcDate('<-6Y>', Today()));
        CustNoC := _Library.CreateAnonymizedCustomer();
        _Library.SetBillToCustomer(CustNoC, CustNoA);
        _Library.SetupUserPermission();

        // [WHEN] DoAnonymization runs on A
        Result := NPGDPRMgt.DoAnonymization(CustNoA, ReasonTxt);

        // [THEN] Succeeds — anonymized peers are not treated as live references
        _Assert.IsTrue(Result, 'An anonymized peer should not pin the customer.');
        _Library.Assert_CustomerIsAnonymized(CustNoA);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DoAnon_SelfReferencedAsBillTo_Succeeds()
    var
        NPGDPRMgt: Codeunit "NPR NP GDPR Management";
        CustNoA: Code[20];
        ReasonTxt: Text;
        Result: Boolean;
    begin
        // [SCENARIO] A customer set as its own Bill-to must not pin its own anonymization.
        // [GIVEN] Customer A with Bill-to Customer No. pointing at itself
        _Library.EnableCustomerGDPRV2Feature();
        _Library.EnsureGDPRSetup('5Y');
        CustNoA := _Library.CreateCustomerWithPastCleanupDate();
        // Seed activity older than the 5Y retention so RecalculateForAnonymization recomputes a PAST cleanup
        // date, keeping A past the "not yet due" (-3) gate so the self-Bill-to success path is exercised.
        _Library.SeedPOSEntryForCustomer(CustNoA, CalcDate('<-6Y>', Today()));
        _Library.SetBillToCustomer(CustNoA, CustNoA);
        _Library.SetupUserPermission();

        // [WHEN] DoAnonymization runs
        Result := NPGDPRMgt.DoAnonymization(CustNoA, ReasonTxt);

        // [THEN] Succeeds — self-references are filtered out by the guard
        _Assert.IsTrue(Result, 'Self-bill-to must not block its own anonymization.');
        _Library.Assert_CustomerIsAnonymized(CustNoA);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Force_ReferencedAsBillToByLiveCustomer_Rejected()
    var
        NPGDPRMgt: Codeunit "NPR NP GDPR Management";
        CustNoA, CustNoC : Code[20];
        ReasonTxt: Text;
        Result: Boolean;
    begin
        // [SCENARIO] ForceAnonymization must not bypass the Bill-to gate — forcing through would still break the referencing customer.
        // [GIVEN] Customer A; live Customer C referencing A as Bill-to
        CustNoA := _Library.CreateCustomer();
        CustNoC := _Library.CreateCustomer();
        _Library.SetBillToCustomer(CustNoC, CustNoA);
        _Library.SetupUserPermission();
        _Library.SetupForcePermission();

        // [WHEN] ForceAnonymization runs on A
        Result := NPGDPRMgt.ForceAnonymization(CustNoA, ReasonTxt);

        // [THEN] Rejected with a Bill-to reason; A remains intact
        _Assert.IsFalse(Result, 'Force should not bypass the Bill-to reference gate.');
        _Assert.IsTrue(StrPos(ReasonTxt, 'Bill-to Customer') > 0,
            StrSubstNo('Reason should mention Bill-to, but was: %1', ReasonTxt));
        _Library.Assert_CustomerIsNotAnonymized(CustNoA);
    end;

    // endregion

    // region Anonymization-time activity re-verify

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Recalc_ExternalActivityNewerThanInternal_Preserved()
    var
        ActivityRefresh: Codeunit "NPR Cust. Activity Refresh";
        Customer: Record Customer;
        CustNo: Code[20];
    begin
        // [SCENARIO] RecalculateForAnonymization keeps a newer external activity and recomputes the cleanup date from it.
        // [GIVEN] Feature on, 5Y retention, a customer with OLD internal activity but a recent external push
        _Library.EnableCustomerGDPRV2Feature();
        _Library.EnsureGDPRSetup('5Y');
        CustNo := _Library.CreateCustomer();
        _Library.SeedPOSEntryForCustomer(CustNo, CalcDate('<-6Y>', Today()));

        Customer.Get(CustNo);
        Customer."NPR Last Activity" := Today();
        Customer."NPR Last Activity Source" := Customer."NPR Last Activity Source"::"External System";
        Customer."NPR Estimated Cleanup Date" := CalcDate('<-1D>', Today());
        Customer.Modify(false);

        // [WHEN] recalculation runs
        ActivityRefresh.RecalculateForAnonymization(CustNo);

        // [THEN] external date/source preserved, cleanup date recomputed from it
        Customer.Get(CustNo);
        _Assert.AreEqual(Today(), Customer."NPR Last Activity", 'External activity date must be preserved.');
        _Assert.AreEqual(Customer."NPR Last Activity Source"::"External System", Customer."NPR Last Activity Source", 'Source must remain External System.');
        _Assert.AreEqual(CalcDate('<5Y>', Today()), Customer."NPR Estimated Cleanup Date", 'Cleanup date must be recomputed from the external activity date.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DoAnon_FeatureOn_RecentActivity_NotAnonymized()
    var
        NPGDPRMgt: Codeunit "NPR NP GDPR Management";
        Customer: Record Customer;
        CustNo: Code[20];
        ReasonTxt: Text;
        Result: Boolean;
    begin
        // [SCENARIO] A candidate with a stale past cleanup date but recent live activity is re-verified and NOT anonymized.
        _Library.EnableCustomerGDPRV2Feature();
        _Library.EnsureGDPRSetup('5Y');
        _Library.SetupUserPermission();
        CustNo := _Library.CreateCustomerWithPastCleanupDate();
        _Library.SeedPOSEntryForCustomer(CustNo, Today());

        // [WHEN]
        Result := NPGDPRMgt.DoAnonymization(CustNo, ReasonTxt);

        // [THEN] re-verify recomputed a future cleanup date and skipped
        _Assert.IsFalse(Result, 'Customer with recent activity must not be anonymized.');
        _Library.Assert_CustomerIsNotAnonymized(CustNo);
        Customer.Get(CustNo);
        _Assert.AreEqual(CalcDate('<5Y>', Today()), Customer."NPR Estimated Cleanup Date", 'Cleanup date must be recomputed to the future.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DoAnon_FeatureOn_NoRecentActivity_Anonymized()
    var
        NPGDPRMgt: Codeunit "NPR NP GDPR Management";
        CustNo: Code[20];
        ReasonTxt: Text;
        Result: Boolean;
    begin
        // [SCENARIO] A candidate whose only activity is older than the retention period is anonymized.
        _Library.EnableCustomerGDPRV2Feature();
        _Library.EnsureGDPRSetup('5Y');
        _Library.SetupUserPermission();
        CustNo := _Library.CreateCustomer();
        _Library.SeedPOSEntryForCustomer(CustNo, CalcDate('<-6Y>', Today()));

        // [WHEN]
        Result := NPGDPRMgt.DoAnonymization(CustNo, ReasonTxt);

        // [THEN]
        _Assert.IsTrue(Result, 'Customer past retention must be anonymized.');
        _Library.Assert_CustomerIsAnonymized(CustNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DoAnon_FeatureOn_PeriodLengthened_NotAnonymized()
    var
        NPGDPRMgt: Codeunit "NPR NP GDPR Management";
        CustNo: Code[20];
        ReasonTxt: Text;
        Result: Boolean;
    begin
        // [SCENARIO] A candidate stamped under a short period is re-verified against the CURRENT (longer) period and skipped.
        _Library.EnableCustomerGDPRV2Feature();
        _Library.SetupUserPermission();
        CustNo := _Library.CreateCustomerWithPastCleanupDate();
        _Library.SeedPOSEntryForCustomer(CustNo, CalcDate('<-4Y>', Today()));
        _Library.EnsureGDPRSetup('5Y');

        // [WHEN]
        Result := NPGDPRMgt.DoAnonymization(CustNo, ReasonTxt);

        // [THEN] recompute with the current 5Y period pushes the date into the future
        _Assert.IsFalse(Result, 'Lengthened period must defer anonymization.');
        _Library.Assert_CustomerIsNotAnonymized(CustNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Force_FeatureOn_RecentActivity_StillAnonymizes()
    var
        NPGDPRMgt: Codeunit "NPR NP GDPR Management";
        CustNo: Code[20];
        ReasonTxt: Text;
        Result: Boolean;
    begin
        // [SCENARIO] ForceAnonymization is a manual override and is NOT gated by the activity re-verify.
        _Library.EnableCustomerGDPRV2Feature();
        _Library.EnsureGDPRSetup('5Y');
        _Library.SetupUserPermission();
        _Library.SetupForcePermission();
        CustNo := _Library.CreateCustomer();
        _Library.SeedPOSEntryForCustomer(CustNo, Today());

        // [WHEN]
        Result := NPGDPRMgt.ForceAnonymization(CustNo, ReasonTxt);

        // [THEN]
        _Assert.IsTrue(Result, 'ForceAnonymization must bypass the activity re-verify.');
        _Library.Assert_CustomerIsAnonymized(CustNo);
    end;

    // endregion

    // region Request-page runners - atomic rollback + reason capture

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Runner_Customer_MidWipeError_RollsBack_NotAnonymized()
    var
        AnonRunner: Codeunit "NPR NP GDPR Anon. Runner";
        FaultInjector: Codeunit "NPR GDPR Anon Fault Inject";
        CustNo: Code[20];
        RunOk: Boolean;
    begin
        // [SCENARIO] An error partway through the customer wipe must roll back every write (guarded Run),
        // leave the customer un-anonymized, and produce no log entry.
        _Library.EnableCustomerGDPRV2Feature();
        _Library.EnsureGDPRSetup('5Y');
        CustNo := _Library.CreateCustomerWithPastCleanupDate();
        _Library.SeedPOSEntryForCustomer(CustNo, CalcDate('<-6Y>', Today()));
        _Library.SetupUserPermission();
        Commit(); // guarded Codeunit.Run requires no uncommitted writes; isolation runner rolls this back per-test

        // [GIVEN] A subscriber that errors after AnonymizeCustomer has written its changes
        BindSubscription(FaultInjector);

        // [WHEN] The customer is processed through the guarded runner
        AnonRunner.SetCheckPeriod(false);
        AnonRunner.SetCustomer(CustNo);
        RunOk := AnonRunner.Run();

        UnbindSubscription(FaultInjector);

        // [THEN] The run reports failure and NOTHING was persisted
        _Assert.IsFalse(RunOk, 'Runner.Run must report failure when the wipe errors.');
        _Library.Assert_CustomerIsNotAnonymized(CustNo);
        _Library.Assert_LogEntryCount(CustNo, 0);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Runner_Customer_Clean_Anonymized_ReasonCaptured()
    var
        AnonRunner: Codeunit "NPR NP GDPR Anon. Runner";
        CustNo: Code[20];
        RunOk: Boolean;
    begin
        // [SCENARIO] A clean, due customer is anonymized through the runner; the success reason is captured.
        _Library.EnableCustomerGDPRV2Feature();
        _Library.EnsureGDPRSetup('5Y');
        CustNo := _Library.CreateCustomerWithPastCleanupDate();
        _Library.SeedPOSEntryForCustomer(CustNo, CalcDate('<-6Y>', Today()));
        _Library.SetupUserPermission();
        Commit(); // guarded Codeunit.Run requires no uncommitted writes; isolation runner rolls this back per-test

        // [WHEN]
        AnonRunner.SetCheckPeriod(false);
        AnonRunner.SetCustomer(CustNo);
        RunOk := AnonRunner.Run();

        // [THEN]
        _Assert.IsTrue(RunOk, 'Runner.Run must succeed for a clean customer.');
        _Assert.IsTrue(AnonRunner.WasAnonymized(), 'WasAnonymized must be true for a clean customer.');
        _Library.Assert_CustomerIsAnonymized(CustNo);
        _Assert.IsTrue(StrPos(AnonRunner.GetReason(), 'has been anonymized') > 0,
            StrSubstNo('GetReason should indicate success, but was: %1', AnonRunner.GetReason()));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Runner_Customer_OpenDocs_NotAnonymized_ReasonCaptured()
    var
        AnonRunner: Codeunit "NPR NP GDPR Anon. Runner";
        CustNo: Code[20];
        RunOk: Boolean;
    begin
        // [SCENARIO] A due customer with an open sales order is a legitimate business rejection: the guarded
        // Run SUCCEEDS (no error thrown), WasAnonymized is false, the reason is captured, the customer is not
        // wiped, and the "could not" log entry legitimately persists (it is not partial data).
        _Library.EnableCustomerGDPRV2Feature();
        _Library.EnsureGDPRSetup('5Y');
        CustNo := _Library.CreateCustomerWithPastCleanupDate();
        _Library.SeedPOSEntryForCustomer(CustNo, CalcDate('<-6Y>', Today()));
        _Library.SetupUserPermission();
        _Library.CreateSalesOrder(CustNo);
        Commit(); // guarded Codeunit.Run requires no uncommitted writes; isolation runner rolls this back per-test

        // [WHEN]
        AnonRunner.SetCheckPeriod(false);
        AnonRunner.SetCustomer(CustNo);
        RunOk := AnonRunner.Run();

        // [THEN]
        _Assert.IsTrue(RunOk, 'Runner.Run must succeed (no error) for a business rejection.');
        _Assert.IsFalse(AnonRunner.WasAnonymized(), 'WasAnonymized must be false when the customer has open documents.');
        _Library.Assert_CustomerIsNotAnonymized(CustNo);
        _Assert.IsTrue(StrPos(AnonRunner.GetReason(), 'open entries') > 0,
            StrSubstNo('GetReason should mention open entries, but was: %1', AnonRunner.GetReason()));
        _Library.Assert_LogEntryExists(CustNo, false);
    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Runner_MemberCombined_FailedStep_RollsBack_NothingAnonymized()
    var
        LibraryMemberGDPR: Codeunit "NPR Library - Member GDPR";
        MemberCustRunner: Codeunit "NPR GDPR Cust-Member Anon Run";
        Membership: Record "NPR MM Membership";
        CustNo: Code[20];
        MembershipEntryNo: Integer;
        RunOk: Boolean;
    begin
        // [SCENARIO] The combined member+customer runner is atomic: if any step fails, the guarded Run rolls
        // back the cancel and any partial membership writes, so neither the membership nor the customer is
        // anonymized. Here the step that fails is the membership cancellation (the fixture membership has no
        // cancel Alteration Setup / sales item) - the exact partial-data hazard the guarded runner exists to
        // prevent (the old [TryFunction] would have left the membership blocked while the request was rejected).
        _Library.EnableCustomerGDPRV2Feature();
        _Library.EnsureGDPRSetup('<+1Y>');
        CustNo := _Library.CreateCustomerWithFutureCleanupDate();
        _Library.SetupUserPermission();
        MembershipEntryNo := LibraryMemberGDPR.CreatePlainMembership(CalcDate('<-10D>'));
        LibraryMemberGDPR.AddAdminMember(MembershipEntryNo);
        Membership.Get(MembershipEntryNo);
        Membership."Customer No." := CustNo;
        Membership.Modify(false);
        Commit(); // guarded Codeunit.Run requires no uncommitted writes; isolation runner rolls this back per-test

        // [WHEN]
        MemberCustRunner.SetCustomer(CustNo);
        MemberCustRunner.SetMembership(MembershipEntryNo);
        RunOk := MemberCustRunner.Run();

        // [THEN] Nothing persisted - the whole combined operation rolled back atomically
        _Assert.IsFalse(RunOk, 'Runner.Run must report failure and roll back when the combined operation cannot complete.');
        _Library.Assert_CustomerIsNotAnonymized(CustNo);
        LibraryMemberGDPR.Assert_MembershipIsNotAnonymized(MembershipEntryNo);
    end;

    // endregion

    // region Customer Card action - blocking guard regression (PR #9828)

    [Test]
    [HandlerFunctions('AnonymizeConfirmHandler,AnonymizeMessageHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CardAction_OpenSalesDoc_NotAnonymized()
    var
        CustomerCard: TestPage "Customer Card";
        CustNo: Code[20];
    begin
        // [SCENARIO] The Customer Card "Customer Anonymization" action must NOT wipe a customer
        // that still has an open sales document (regression guard for PR #9828).
        // [GIVEN] A customer with permission and an open sales order
        CustNo := _Library.CreateCustomer();
        _Library.SetupUserPermission();
        _Library.CreateSalesOrder(CustNo);

        // [WHEN] the operator runs the Customer Card anonymization action and confirms
        CustomerCard.OpenEdit();
        CustomerCard.GoToKey(CustNo);
        CustomerCard."NPR Customer Anonymization".Invoke();
        CustomerCard.Close();

        // [THEN] the customer is left intact - the blocking guard was enforced
        _Library.Assert_CustomerIsNotAnonymized(CustNo);
    end;

    [ConfirmHandler]
    procedure AnonymizeConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [MessageHandler]
    procedure AnonymizeMessageHandler(Message: Text[1024])
    begin
    end;

    // endregion

    // region Gated force (retention override)

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Force_FeatureOn_NotDue_NoHardGates_Anonymizes()
    var
        NPGDPRMgt: Codeunit "NPR NP GDPR Management";
        CustNo: Code[20];
        ReasonTxt: Text;
        Result: Boolean;
    begin
        // [SCENARIO] Gated force overrides the soft not-yet-due retention gate for a customer with no hard blockers.
        _Library.EnableCustomerGDPRV2Feature();
        _Library.EnsureGDPRSetup('<+1Y>');
        CustNo := _Library.CreateCustomerWithFutureCleanupDate();
        _Library.SetupUserPermission();
        _Library.SetupForcePermission();

        // [WHEN]
        Result := NPGDPRMgt.ForceAnonymization(CustNo, ReasonTxt);

        // [THEN]
        _Assert.IsTrue(Result, 'Gated force must anonymize a not-yet-due customer with no hard blockers.');
        _Library.Assert_CustomerIsAnonymized(CustNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Force_FeatureOn_OpenSalesDoc_Rejected()
    var
        NPGDPRMgt: Codeunit "NPR NP GDPR Management";
        CustNo: Code[20];
        ReasonTxt: Text;
        Result: Boolean;
    begin
        // [SCENARIO] Gated force still refuses a hard integrity gate: an open sales document blocks even a forced erasure.
        _Library.EnableCustomerGDPRV2Feature();
        _Library.EnsureGDPRSetup('<+1Y>');
        CustNo := _Library.CreateCustomerWithFutureCleanupDate();
        _Library.SetupUserPermission();
        _Library.SetupForcePermission();
        _Library.CreateSalesOrder(CustNo);

        // [WHEN]
        Result := NPGDPRMgt.ForceAnonymization(CustNo, ReasonTxt);

        // [THEN]
        _Assert.IsFalse(Result, 'Gated force must not bypass the open-document gate.');
        _Library.Assert_CustomerIsNotAnonymized(CustNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Force_NoForcePermission_Errors()
    var
        NPGDPRMgt: Codeunit "NPR NP GDPR Management";
        CustNo: Code[20];
        ReasonTxt: Text;
    begin
        // [SCENARIO] ForceAnonymization requires the dedicated force permission; the ordinary anonymize permission is not enough.
        _Library.EnableCustomerGDPRV2Feature();
        _Library.EnsureGDPRSetup('<+1Y>');
        CustNo := _Library.CreateCustomerWithFutureCleanupDate();
        _Library.SetupUserPermission();
        _Library.SetupForcePermissionDisabled();

        // [WHEN/THEN] Force is refused for a user without the force permission
        asserterror NPGDPRMgt.ForceAnonymization(CustNo, ReasonTxt);
        _Assert.ExpectedError('permission to force');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DoAnon_FeatureOff_BillTo_Rejected()
    var
        NPGDPRMgt: Codeunit "NPR NP GDPR Management";
        CustNoA, CustNoB : Code[20];
        ReasonTxt: Text;
        Result: Boolean;
    begin
        // [SCENARIO] Bill-to is a data-integrity gate enforced regardless of the feature flag: with the feature
        // OFF, a customer still referenced as Bill-to by a live customer must NOT be anonymized (regression guard
        // for the negative-reason-code decode - a -4 must never fall through to the bit-decoder).
        _Library.DisableCustomerGDPRv2Feature();
        CustNoA := _Library.CreateCustomer();
        CustNoB := _Library.CreateCustomer();
        _Library.SetBillToCustomer(CustNoB, CustNoA);
        _Library.SetupUserPermission();

        // [WHEN]
        Result := NPGDPRMgt.DoAnonymization(CustNoA, ReasonTxt);

        // [THEN] Rejected; A remains intact
        _Assert.IsFalse(Result, 'Feature-off Bill-to customer must not be anonymized.');
        _Assert.IsTrue(StrPos(ReasonTxt, 'Bill-to Customer') > 0,
            StrSubstNo('Reason should mention Bill-to, but was: %1', ReasonTxt));
        _Library.Assert_CustomerIsNotAnonymized(CustNoA);
    end;

    // endregion
}
