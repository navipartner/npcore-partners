codeunit 85299 "NPR Cust Activity Refresh Test"
{
    Subtype = Test;

    var
        _Library: Codeunit "NPR Library - Customer GDPR";
        _Assert: Codeunit Assert;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Refresh_PicksMaxDateAcrossSources_AndCorrectSourceEnum()
    var
        Refresh: Codeunit "NPR Cust. Activity Refresh";
        Customer: Record Customer;
        CustNo: Code[20];
        OldestDate, MiddleDate, NewestDate : Date;
    begin
        // [SCENARIO] Refresh selects the max date across POS / CLE / ILE and records the matching source enum.
        _Library.EnableCustomerGDPRV2Feature();
        _Library.EnsureGDPRSetup('<+1Y>');
        CustNo := _Library.CreateCustomer();
        OldestDate := CalcDate('<-10D>', Today());
        MiddleDate := CalcDate('<-5D>', Today());
        NewestDate := CalcDate('<-2D>', Today());

        _Library.SeedPOSEntryForCustomer(CustNo, OldestDate);
        _Library.SeedCustLedgerEntryForCustomer(CustNo, MiddleDate);
        _Library.SeedItemLedgerEntryForCustomer(CustNo, NewestDate);

        // [WHEN] Refresh runs for this customer
        Customer.Get(CustNo);
        Refresh.RefreshSingleCustomer(Customer);

        // [THEN] Last Activity = NewestDate (ILE), source = Item Ledger Entry, cleanup date = NewestDate + 1Y
        _Assert.IsTrue(Customer.Get(CustNo), 'Customer not found.');
        _Assert.AreEqual(Customer."NPR Last Activity Source"::"Item Ledger Entry", Customer."NPR Last Activity Source", 'Source mismatch.');
        _Assert.AreEqual(NewestDate, Customer."NPR Last Activity", 'Date mismatch.');
        _Assert.AreEqual(CalcDate('<+1Y>', NewestDate), Customer."NPR Estimated Cleanup Date", 'Cleanup date mismatch.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Refresh_NoPostedActivity_FallsBackToCreationDate()
    var
        Refresh: Codeunit "NPR Cust. Activity Refresh";
        Customer: Record Customer;
        CustNo: Code[20];
    begin
        // [SCENARIO] Customer with no posted activity falls back to "Creation Date" source using SystemCreatedAt.
        _Library.EnableCustomerGDPRV2Feature();
        _Library.EnsureGDPRSetup('<+1Y>');
        CustNo := _Library.CreateCustomer();

        Customer.Get(CustNo);
        Refresh.RefreshSingleCustomer(Customer);

        Customer.Get(CustNo);
        _Assert.AreEqual(Customer."NPR Last Activity Source"::"Creation Date", Customer."NPR Last Activity Source", 'Source should fall back to Creation Date.');
        _Assert.AreEqual(DT2Date(Customer.SystemCreatedAt), Customer."NPR Last Activity", 'Date should equal customer SystemCreatedAt date.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Refresh_FeatureOff_DoesNothing()
    var
        Refresh: Codeunit "NPR Cust. Activity Refresh";
        Customer: Record Customer;
        JobQueueEntry: Record "Job Queue Entry";
        CustNo: Code[20];
    begin
        // [SCENARIO] When the feature is OFF, the OnRun is a no-op.
        _Library.DisableCustomerGDPRV2Feature();
        _Library.EnsureGDPRSetup('<+1Y>');
        CustNo := _Library.CreateCustomer();
        _Library.SeedPOSEntryForCustomer(CustNo, Today());

        // [WHEN] Run the codeunit through its OnRun (TableNo = Job Queue Entry)
        JobQueueEntry.Init();
        Refresh.Run(JobQueueEntry);

        // [THEN] Customer fields remain at defaults — no stamping
        _Assert.IsTrue(Customer.Get(CustNo), 'Customer not found.');
        _Assert.AreEqual(Customer."NPR Last Activity Source"::" ", Customer."NPR Last Activity Source", 'Source must remain blank with feature OFF.');
        _Assert.AreEqual(0D, Customer."NPR Last Activity", 'Date must remain 0D with feature OFF.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Refresh_AnonymizedCustomer_Skipped()
    var
        Refresh: Codeunit "NPR Cust. Activity Refresh";
        Customer: Record Customer;
        CustNo: Code[20];
    begin
        // [SCENARIO] Anonymized customers must be skipped even when RefreshSingleCustomer is invoked directly.
        _Library.EnableCustomerGDPRV2Feature();
        _Library.EnsureGDPRSetup('<+1Y>');
        CustNo := _Library.CreateCustomer();
        Customer.Get(CustNo);
        Customer."NPR Anonymized" := true;
        Customer.Modify(false);
        _Library.SeedPOSEntryForCustomer(CustNo, Today());

        Refresh.RefreshSingleCustomer(Customer);

        Customer.Get(CustNo);
        _Assert.AreEqual(Customer."NPR Last Activity Source"::" ", Customer."NPR Last Activity Source", 'Anonymized customer must not be stamped.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Refresh_NoChange_DoesNotModify()
    var
        Refresh: Codeunit "NPR Cust. Activity Refresh";
        Customer: Record Customer;
        CustNo: Code[20];
        Updated: Boolean;
    begin
        // [SCENARIO] Calling Refresh twice in a row does not re-Modify the customer the second time.
        _Library.EnableCustomerGDPRV2Feature();
        _Library.EnsureGDPRSetup('<+1Y>');
        CustNo := _Library.CreateCustomer();
        _Library.SeedPOSEntryForCustomer(CustNo, Today());

        Customer.Get(CustNo);
        Refresh.RefreshSingleCustomer(Customer);
        Updated := Refresh.RefreshSingleCustomer(Customer);

        _Assert.IsFalse(Updated, 'Second Refresh should report no change.');
    end;

#if not (BC17 or BC18)
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Refresh_SingleCustomer_ErrorsWhenGDPRSetupMissing()
    var
        Refresh: Codeunit "NPR Cust. Activity Refresh";
        Setup: Record "NPR Customer GDPR SetUp";
        Customer: Record Customer;
        CustNo: Code[20];
    begin
        // [SCENARIO] RefreshSingleCustomer raises the "setup missing" error. In production the per-customer
        // runner ("NPR Cust. Act. Refresh Runner") wraps this in a guarded Codeunit.Run so the batch loop
        // continues past a failing customer. We assert the raised error directly: a post-error DB read is not
        // reliable here because the raised error rolls back the test's own setup (the created customer included).
        _Library.EnableCustomerGDPRV2Feature();
        _Library.EnsureGDPRSetup('<+1Y>');
        CustNo := _Library.CreateCustomer();
        _Library.SeedPOSEntryForCustomer(CustNo, Today());

        // Wipe setup so the inner GDPRSetup.Get() raises the error.
        if Setup.Get() then
            Setup.Delete();

        // [WHEN/THEN] RefreshSingleCustomer errors when the setup is missing.
        Customer.Get(CustNo);
        asserterror Refresh.RefreshSingleCustomer(Customer);
        _Assert.ExpectedError('Customer GDPR Setup is missing');
    end;
#endif
}
