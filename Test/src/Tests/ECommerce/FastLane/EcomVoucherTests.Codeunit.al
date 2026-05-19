#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 85246 "NPR Ecom Voucher Tests"
{
    Subtype = Test;

    var
        _Assert: Codeunit "Assert";
        _LibEcom: Codeunit "NPR Library Ecommerce";
        _LibPOSMasterData: Codeunit "NPR Library - POS Master Data";

    #region Happy paths
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VoucherProcess_Qty1_HappyPath_OneLinkRow()
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomSalesVoucherLink: Record "NPR Ecom Sales Voucher Link";
        VchrImpl: Codeunit "NPR EcomCreateVchrImpl";
    begin
        // [Scenario] qty=1 voucher line is processed → exactly 1 link row exists for the line.
        _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
        _LibPOSMasterData.CreateDefaultVoucherType(VoucherType, false);
        CreateCapturedVoucherLine(EcomSalesLine, EcomSalesHeader, VoucherType.Code, 1, 100);

        VchrImpl.Process(EcomSalesLine);

        EcomSalesVoucherLink.SetRange("Source Line System Id", EcomSalesLine.SystemId);
        _Assert.AreEqual(1, EcomSalesVoucherLink.Count(), 'Expected exactly 1 link row for qty=1 voucher line.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VoucherProcess_Qty5_MultiIssue_FiveLinkRows()
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomSalesVoucherLink: Record "NPR Ecom Sales Voucher Link";
        VchrImpl: Codeunit "NPR EcomCreateVchrImpl";
    begin
        // [Scenario] qty=5 → 5 vouchers issued, 5 link rows; line "No." and "Barcode No." left blank
        // (qty>1 doesn't write back to the ecom line — link table is the source of truth).
        _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
        _LibPOSMasterData.CreateDefaultVoucherType(VoucherType, false);
        CreateCapturedVoucherLine(EcomSalesLine, EcomSalesHeader, VoucherType.Code, 5, 100);

        VchrImpl.Process(EcomSalesLine);
        EcomSalesLine.Get(EcomSalesLine."Document Entry No.", EcomSalesLine."Line No.");

        EcomSalesVoucherLink.SetRange("Source Line System Id", EcomSalesLine.SystemId);
        _Assert.AreEqual(5, EcomSalesVoucherLink.Count(), 'Expected 5 link rows for qty=5 voucher line.');
        _Assert.AreEqual('', EcomSalesLine."No.", 'qty>1 line should not have "No." written back.');
        _Assert.AreEqual('', EcomSalesLine."Barcode No.", 'qty>1 line should not have "Barcode No." written back.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VoucherProcess_Qty1_NewIssuance_LineWritebackPopulated()
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        VchrImpl: Codeunit "NPR EcomCreateVchrImpl";
    begin
        // [Scenario] qty=1 new issuance → line carries first voucher's Barcode No., No., Voucher Type (API back-compat).
        _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
        _LibPOSMasterData.CreateDefaultVoucherType(VoucherType, false);
        CreateCapturedVoucherLine(EcomSalesLine, EcomSalesHeader, VoucherType.Code, 1, 100);

        VchrImpl.Process(EcomSalesLine);
        EcomSalesLine.Get(EcomSalesLine."Document Entry No.", EcomSalesLine."Line No.");

        _Assert.AreNotEqual('', EcomSalesLine."No.", 'qty=1 line should have "No." written back.');
        _Assert.AreNotEqual('', EcomSalesLine."Barcode No.", 'qty=1 line should have "Barcode No." (Reference No.) written back.');
        _Assert.AreEqual(VoucherType.Code, EcomSalesLine."Voucher Type", 'Voucher Type should be set to issued voucher''s type.');
    end;
    #endregion

    #region Top-up
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VoucherProcess_TopUpQty1_LinksExistingVoucher()
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        ExistingVoucher: Record "NPR NpRv Voucher";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomSalesVoucherLink: Record "NPR Ecom Sales Voucher Link";
        VchrImpl: Codeunit "NPR EcomCreateVchrImpl";
    begin
        // [Scenario] Top-up of an existing voucher → 1 link row pointing at the existing voucher.
        _LibPOSMasterData.CreateDefaultVoucherType(VoucherType, true);
        CreateExistingActiveVoucher(ExistingVoucher, VoucherType.Code);

        _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
        CreateCapturedVoucherLine(EcomSalesLine, EcomSalesHeader, VoucherType.Code, 1, 50);
        EcomSalesLine."Barcode No." := ExistingVoucher."Reference No.";
        EcomSalesLine.Modify();

        VchrImpl.Process(EcomSalesLine);

        EcomSalesVoucherLink.SetRange("Source Line System Id", EcomSalesLine.SystemId);
        _Assert.AreEqual(1, EcomSalesVoucherLink.Count(), 'Top-up should produce exactly 1 link row.');
        EcomSalesVoucherLink.FindFirst();
        _Assert.AreEqual(ExistingVoucher."No.", EcomSalesVoucherLink."Voucher No.", 'Top-up link should point at the existing voucher.');
    end;
    #endregion

    #region Quantity validation
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VoucherProcess_FractionalQty_Rejected()
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        VchrImpl: Codeunit "NPR EcomCreateVchrImpl";
    begin
        // [Scenario] Fractional Quantity (e.g., 2.5) is rejected by CheckIfLineCanBeProcessed.
        _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
        _LibPOSMasterData.CreateDefaultVoucherType(VoucherType, false);
        CreateCapturedVoucherLine(EcomSalesLine, EcomSalesHeader, VoucherType.Code, 1, 100);
        EcomSalesLine.Quantity := 2.5;
        EcomSalesLine.Modify();

        asserterror VchrImpl.Process(EcomSalesLine);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VoucherProcess_ZeroQty_Rejected()
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        VchrImpl: Codeunit "NPR EcomCreateVchrImpl";
    begin
        // [Scenario] Quantity = 0 is rejected (subsumed by < 1 check).
        _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
        _LibPOSMasterData.CreateDefaultVoucherType(VoucherType, false);
        CreateCapturedVoucherLine(EcomSalesLine, EcomSalesHeader, VoucherType.Code, 1, 100);
        EcomSalesLine.Quantity := 0;
        EcomSalesLine.Modify();

        asserterror VchrImpl.Process(EcomSalesLine);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VoucherProcess_TopUpWithQtyGreaterThan1_Rejected()
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        VchrImpl: Codeunit "NPR EcomCreateVchrImpl";
    begin
        // [Scenario] Top-up (Barcode No. set) with Quantity > 1 is rejected — top-up always implies qty=1.
        _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
        _LibPOSMasterData.CreateDefaultVoucherType(VoucherType, true);
        CreateCapturedVoucherLine(EcomSalesLine, EcomSalesHeader, VoucherType.Code, 2, 100);
        EcomSalesLine."Barcode No." := 'SOMEREFERENCE';
        EcomSalesLine.Modify();

        asserterror VchrImpl.Process(EcomSalesLine);
    end;
    #endregion

    #region Link-count guard branches
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VoucherProcess_AlreadyLinkedExceedsQty_Errors()
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        VchrImpl: Codeunit "NPR EcomCreateVchrImpl";
        i: Integer;
    begin
        // [Scenario] More links than quantity → hard error (data corruption / programming bug).
        _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
        _LibPOSMasterData.CreateDefaultVoucherType(VoucherType, false);
        CreateCapturedVoucherLine(EcomSalesLine, EcomSalesHeader, VoucherType.Code, 2, 100);
        for i := 1 to 5 do
            InsertCorruptLinkRow(EcomSalesHeader, EcomSalesLine);

        asserterror VchrImpl.Process(EcomSalesLine);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VoucherProcess_PartialLinkState_Errors()
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        VchrImpl: Codeunit "NPR EcomCreateVchrImpl";
    begin
        // [Scenario] 0 < AlreadyLinked < QtyToIssue → hard error (invariant break, not a resume scenario).
        _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
        _LibPOSMasterData.CreateDefaultVoucherType(VoucherType, false);
        CreateCapturedVoucherLine(EcomSalesLine, EcomSalesHeader, VoucherType.Code, 5, 100);
        InsertCorruptLinkRow(EcomSalesHeader, EcomSalesLine);
        InsertCorruptLinkRow(EcomSalesHeader, EcomSalesLine);

        asserterror VchrImpl.Process(EcomSalesLine);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VoucherProcess_RaceRecovery_NoOpExit()
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomSalesVoucherLink: Record "NPR Ecom Sales Voucher Link";
        VchrImpl: Codeunit "NPR EcomCreateVchrImpl";
        i: Integer;
    begin
        // [Scenario] Pre-populate AlreadyLinked = QtyToIssue (simulating the post-inner-commit /
        // pre-HandleResponse race window) → CreateVoucher exits cleanly without issuing duplicates.
        _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
        _LibPOSMasterData.CreateDefaultVoucherType(VoucherType, false);
        CreateCapturedVoucherLine(EcomSalesLine, EcomSalesHeader, VoucherType.Code, 3, 100);
        for i := 1 to 3 do
            InsertCorruptLinkRow(EcomSalesHeader, EcomSalesLine);

        VchrImpl.Process(EcomSalesLine);

        EcomSalesVoucherLink.SetRange("Source Line System Id", EcomSalesLine.SystemId);
        _Assert.AreEqual(3, EcomSalesVoucherLink.Count(), 'Race recovery: link count must remain at 3 — no duplicates issued.');
    end;
    #endregion

    #region Archive / unarchive lifecycle
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VoucherArchive_FlipsLinkStateToArchived()
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomSalesVoucherLink: Record "NPR Ecom Sales Voucher Link";
        NpRvVoucher: Record "NPR NpRv Voucher";
        VoucherFilter: Record "NPR NpRv Voucher";
        VoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        VchrImpl: Codeunit "NPR EcomCreateVchrImpl";
    begin
        // [Scenario] Archiving an issued voucher flips its link row's Voucher State to Archived.
        _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
        _LibPOSMasterData.CreateDefaultVoucherType(VoucherType, false);
        CreateCapturedVoucherLine(EcomSalesLine, EcomSalesHeader, VoucherType.Code, 1, 100);
        VchrImpl.Process(EcomSalesLine);

        EcomSalesVoucherLink.SetRange("Source Line System Id", EcomSalesLine.SystemId);
        EcomSalesVoucherLink.FindFirst();
        NpRvVoucher.GetBySystemId(EcomSalesVoucherLink."Voucher System Id");

        VoucherFilter := NpRvVoucher;
        VoucherFilter.SetRecFilter();
        VoucherMgt.ArchiveVouchers(VoucherFilter);

        EcomSalesVoucherLink.Find();
        _Assert.AreEqual(EcomSalesVoucherLink."Voucher State"::Archived, EcomSalesVoucherLink."Voucher State", 'Link state should flip to Archived after archive.');
    end;
    #endregion

    #region Notification manifest
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure NotificationManifest_Qty3Active_ThreeManifestEntries()
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomSalesVoucherLink: Record "NPR Ecom Sales Voucher Link";
        VchrImpl: Codeunit "NPR EcomCreateVchrImpl";
        ActiveLinkCount: Integer;
    begin
        // [Scenario] qty=3 with all active vouchers — the link table will produce 3 active rows
        // for the manifest builder to enumerate. (End-to-end manifest assertion requires Digital
        // Notification setup configured; we verify the data shape that ProcessVoucherAssets reads.)
        _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
        _LibPOSMasterData.CreateDefaultVoucherType(VoucherType, false);
        CreateCapturedVoucherLine(EcomSalesLine, EcomSalesHeader, VoucherType.Code, 3, 100);
        VchrImpl.Process(EcomSalesLine);

        EcomSalesVoucherLink.SetRange("Source System Id", EcomSalesHeader.SystemId);
        EcomSalesVoucherLink.SetRange("Source Line System Id", EcomSalesLine.SystemId);
        EcomSalesVoucherLink.SetRange("Voucher State", EcomSalesVoucherLink."Voucher State"::Active);
        ActiveLinkCount := EcomSalesVoucherLink.Count();

        _Assert.AreEqual(3, ActiveLinkCount, 'Expected 3 Active link rows feeding the manifest.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure NotificationManifest_Qty3OneArchived_TwoActiveTwoFiltered()
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomSalesVoucherLink: Record "NPR Ecom Sales Voucher Link";
        VchrImpl: Codeunit "NPR EcomCreateVchrImpl";
        ActiveLinkCount: Integer;
        ArchivedLinkCount: Integer;
    begin
        // [Scenario] qty=3 then 1 archived — manifest's Active-only filter on the link query
        // returns 2 rows. (Spec §4.4: archived vouchers excluded from customer-facing email.)
        _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
        _LibPOSMasterData.CreateDefaultVoucherType(VoucherType, false);
        CreateCapturedVoucherLine(EcomSalesLine, EcomSalesHeader, VoucherType.Code, 3, 100);
        VchrImpl.Process(EcomSalesLine);

        EcomSalesVoucherLink.SetRange("Source Line System Id", EcomSalesLine.SystemId);
        EcomSalesVoucherLink.FindFirst();
        EcomSalesVoucherLink."Voucher State" := EcomSalesVoucherLink."Voucher State"::Archived;
        EcomSalesVoucherLink.Modify();

        // Mirror the §4.4 manifest query.
        EcomSalesVoucherLink.Reset();
        EcomSalesVoucherLink.SetRange("Source Line System Id", EcomSalesLine.SystemId);
        EcomSalesVoucherLink.SetRange("Voucher State", EcomSalesVoucherLink."Voucher State"::Active);
        ActiveLinkCount := EcomSalesVoucherLink.Count();

        EcomSalesVoucherLink.SetRange("Voucher State", EcomSalesVoucherLink."Voucher State"::Archived);
        ArchivedLinkCount := EcomSalesVoucherLink.Count();

        _Assert.AreEqual(2, ActiveLinkCount, 'Active filter should return 2 rows (3 minus 1 archived).');
        _Assert.AreEqual(1, ArchivedLinkCount, 'Archived filter should return 1 row.');
    end;
    #endregion

    #region Show Related — line-level AssistEdit
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure BuildVoucherTempBufferForLine_NoLinkRows_NoLegacyVoucher_EmptyBuffer()
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        TempVoucher: Record "NPR NpRv Voucher" temporary;
        VchrImpl: Codeunit "NPR EcomCreateVchrImpl";
    begin
        // [Scenario] N=0: a line with no link rows and no legacy "No." → builder returns an empty buffer.
        //            The line-level AssistEdit handler then shows the "no vouchers" message.
        _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
        _LibPOSMasterData.CreateDefaultVoucherType(VoucherType, false);
        CreateCapturedVoucherLine(EcomSalesLine, EcomSalesHeader, VoucherType.Code, 1, 100);

        VchrImpl.BuildVoucherTempBufferForLine(EcomSalesHeader, EcomSalesLine, TempVoucher);

        _Assert.IsTrue(TempVoucher.IsEmpty(), 'Buffer should be empty when no link rows and no legacy voucher.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure BuildVoucherTempBufferForLine_OneActive_OneRow()
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        TempVoucher: Record "NPR NpRv Voucher" temporary;
        VchrImpl: Codeunit "NPR EcomCreateVchrImpl";
    begin
        // [Scenario] N=1 (active): builder returns the issued voucher.
        _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
        _LibPOSMasterData.CreateDefaultVoucherType(VoucherType, false);
        CreateCapturedVoucherLine(EcomSalesLine, EcomSalesHeader, VoucherType.Code, 1, 100);
        VchrImpl.Process(EcomSalesLine);

        VchrImpl.BuildVoucherTempBufferForLine(EcomSalesHeader, EcomSalesLine, TempVoucher);

        _Assert.AreEqual(1, TempVoucher.Count(), 'Buffer should contain exactly 1 voucher.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure BuildVoucherTempBufferForLine_FiveActive_FiveRows()
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        TempVoucher: Record "NPR NpRv Voucher" temporary;
        VchrImpl: Codeunit "NPR EcomCreateVchrImpl";
    begin
        // [Scenario] N>1 (qty=5 issued, all active): builder returns all 5 vouchers.
        _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
        _LibPOSMasterData.CreateDefaultVoucherType(VoucherType, false);
        CreateCapturedVoucherLine(EcomSalesLine, EcomSalesHeader, VoucherType.Code, 5, 100);
        VchrImpl.Process(EcomSalesLine);

        VchrImpl.BuildVoucherTempBufferForLine(EcomSalesHeader, EcomSalesLine, TempVoucher);

        _Assert.AreEqual(5, TempVoucher.Count(), 'Buffer should contain 5 vouchers for qty=5 line.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure BuildVoucherTempBufferForDoc_MixedActiveAndArchived_AllReturnedWithPrefix()
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomSalesVoucherLink: Record "NPR Ecom Sales Voucher Link";
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvArchVoucher: Record "NPR NpRv Arch. Voucher";
        TempVoucher: Record "NPR NpRv Voucher" temporary;
        VchrImpl: Codeunit "NPR EcomCreateVchrImpl";
        ArchivedFound: Boolean;
        ActiveFound: Boolean;
    begin
        // [Scenario] qty=3, then move 1 voucher into archive (preserving SystemId) and flip its link
        // to Archived → builder returns 3 entries; archived row prefixed [Archived].
        // We synthesize the archived state directly instead of calling VoucherMgt.ArchiveVouchers,
        // because the Arch. No. Series state isn't isolated across [Test] procs in the same codeunit
        // (BC26 PS Test Runner) — the live archive flow's first GetNextNo collides with leftover
        // 'DA00000000' rows from prior tests in this codeunit. The OnAfterArchiveVoucher subscriber
        // wiring is covered separately by VoucherArchive_FlipsLinkStateToArchived.
        _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
        _LibPOSMasterData.CreateDefaultVoucherType(VoucherType, false);
        CreateCapturedVoucherLine(EcomSalesLine, EcomSalesHeader, VoucherType.Code, 3, 100);
        VchrImpl.Process(EcomSalesLine);

        EcomSalesVoucherLink.SetRange("Source Line System Id", EcomSalesLine.SystemId);
        EcomSalesVoucherLink.FindFirst();
        NpRvVoucher.GetBySystemId(EcomSalesVoucherLink."Voucher System Id");

        NpRvArchVoucher.Init();
        NpRvArchVoucher.TransferFields(NpRvVoucher);
        NpRvArchVoucher."No." := CopyStr('TST-ARCH-' + NpRvVoucher."No.", 1, MaxStrLen(NpRvArchVoucher."No."));
        NpRvArchVoucher."Arch. No." := NpRvVoucher."No.";
        NpRvArchVoucher.SystemId := NpRvVoucher.SystemId;
        NpRvArchVoucher.Insert(true, true);
        NpRvVoucher.Delete();

        EcomSalesVoucherLink."Voucher State" := EcomSalesVoucherLink."Voucher State"::Archived;
        EcomSalesVoucherLink.Modify();

        VchrImpl.BuildVoucherTempBufferForDoc(EcomSalesHeader, TempVoucher);

        _Assert.AreEqual(3, TempVoucher.Count(), 'Buffer should contain all 3 entries (active + archived).');
        if TempVoucher.FindSet() then
            repeat
                if VchrImpl.IsArchivedTempDescription(TempVoucher.Description) then
                    ArchivedFound := true
                else
                    ActiveFound := true;
            until TempVoucher.Next() = 0;
        _Assert.IsTrue(ArchivedFound, 'Archived row should be present with [Archived] description prefix.');
        _Assert.IsTrue(ActiveFound, 'Active rows should be present without prefix.');
    end;
    #endregion

    #region Sales-line bridge + voucher-entry posting
    // Test #14 (sales-line bridge with qty>1 patches all NpRvSalesLine rows) and Test #15
    // (voucher-entry posting patch with qty>1 updates all N voucher entries) require an
    // end-to-end ecom→sales-doc→post-invoice fixture. Those flows are exercised by the
    // existing ecom posting tests in this test app together with the rev 6 spec changes.
    // Manual QA: verify by processing a qty=5 voucher payload and posting the resulting
    // sales invoice — assert all 5 NpRvSalesLine rows have matching Document No./Document
    // Line No., and all 5 NpRvVoucherEntry rows have the posted invoice line's identifiers.

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UpdateVchrEntryPostingInfo_DocNoAlreadySet_Preserved()
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        NpRvVoucherEntry: Record "NPR NpRv Voucher Entry";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvLine: Record "Sales Invoice Line";
        VchrImpl: Codeunit "NPR EcomCreateVchrImpl";
        FirstInvoiceNo: Code[20];
        SecondInvoiceNo: Code[20];
        FirstInvoiceLineNo: Integer;
    begin
        // [Scenario] CORE-364: ecom voucher line is auto-invoiced as INV001, then user manually
        // posts the remaining items as INV002. Sales-Post.OnAfterPostSalesLine re-fires for the
        // already-fully-posted voucher SalesLine; the handler must NOT overwrite the voucher
        // entry's "Document No." with INV002's number.
        FirstInvoiceNo := 'INV001';
        FirstInvoiceLineNo := 10000;
        SecondInvoiceNo := 'INV002';

        _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
        _LibPOSMasterData.CreateDefaultVoucherType(VoucherType, false);
        CreateCapturedVoucherLine(EcomSalesLine, EcomSalesHeader, VoucherType.Code, 1, 100);
        VchrImpl.Process(EcomSalesLine);

        NpRvVoucherEntry.SetRange("External Document No.", EcomSalesHeader."External No.");
        NpRvVoucherEntry.SetFilter("Entry Type", '%1|%2', NpRvVoucherEntry."Entry Type"::"Issue Voucher", NpRvVoucherEntry."Entry Type"::"Top-up");
        NpRvVoucherEntry.FindFirst();
        NpRvVoucherEntry."Document No." := FirstInvoiceNo;
        NpRvVoucherEntry."Document Line No." := FirstInvoiceLineNo;
        NpRvVoucherEntry.Modify();

        SalesHeader.Init();
        SalesHeader.Invoice := true;
        SalesHeader."NPR External Order No." := CopyStr(EcomSalesHeader."External No.", 1, MaxStrLen(SalesHeader."NPR External Order No."));

        SalesLine.Init();
        SalesLine."NPR Inc Ecom Sales Line Id" := EcomSalesLine.SystemId;

        SalesInvLine.Init();
        SalesInvLine."Document No." := SecondInvoiceNo;
        SalesInvLine."Line No." := 20000;

        VchrImpl.UpdateVoucherEntryPostingInformationSalesInvoice(SalesHeader, SalesLine, SalesInvLine);

        NpRvVoucherEntry.Find();
        _Assert.AreEqual(FirstInvoiceNo, NpRvVoucherEntry."Document No.", 'Voucher entry Document No. must remain pinned to the first invoice.');
        _Assert.AreEqual(FirstInvoiceLineNo, NpRvVoucherEntry."Document Line No.", 'Voucher entry Document Line No. must remain pinned to the first invoice line.');
    end;
    #endregion

    #region Voucher-in-wallet regression guard (CORE-209 keeps the existing block in place)
    // Test #16 — the existing EcomSalesDocUtils.EnsureNoUnsupportedAssetsInWalletComponentLines
    // continues to error with VoucherNotSupportedAsWalletComponentErr at API ingest. CORE-209
    // does not modify that validation; voucher-in-wallet support is explicitly out of scope.
    // Covered by the existing API ingest tests in this test app.
    #endregion

    #region Helpers
    local procedure CreateCapturedVoucherLine(var EcomSalesLine: Record "NPR Ecom Sales Line"; EcomSalesHeader: Record "NPR Ecom Sales Header"; VoucherTypeCode: Code[20]; Qty: Decimal; UnitPrice: Decimal)
    begin
        EcomSalesLine.Init();
        EcomSalesLine."Document Entry No." := EcomSalesHeader."Entry No.";
        EcomSalesLine."Document Type" := EcomSalesHeader."Document Type";
        EcomSalesLine."External Document No." := EcomSalesHeader."External No.";
        EcomSalesLine."Line No." := GetNextLineNo(EcomSalesHeader);
        EcomSalesLine.Type := EcomSalesLine.Type::Voucher;
        EcomSalesLine.Subtype := EcomSalesLine.Subtype::Voucher;
        EcomSalesLine."Voucher Type" := VoucherTypeCode;
        EcomSalesLine.Quantity := Qty;
        EcomSalesLine."Unit Price" := UnitPrice;
        EcomSalesLine."Line Amount" := Qty * UnitPrice;
        EcomSalesLine.Captured := true;
        EcomSalesLine.Insert(true);
    end;

    local procedure CreateExistingActiveVoucher(var NpRvVoucher: Record "NPR NpRv Voucher"; VoucherTypeCode: Code[20])
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        VoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        TempVoucher: Record "NPR NpRv Voucher" temporary;
    begin
        VoucherType.Get(VoucherTypeCode);
        VoucherMgt.GenerateTempVoucher(VoucherType, TempVoucher);
        VoucherMgt.InitVoucher(VoucherType, TempVoucher."No.", TempVoucher."Reference No.", 0DT, true, NpRvVoucher);
        NpRvVoucher.Modify();
    end;

    local procedure InsertCorruptLinkRow(EcomSalesHeader: Record "NPR Ecom Sales Header"; EcomSalesLine: Record "NPR Ecom Sales Line")
    var
        EcomSalesVoucherLink: Record "NPR Ecom Sales Voucher Link";
    begin
        EcomSalesVoucherLink.Init();
        EcomSalesVoucherLink."Source System Id" := EcomSalesHeader.SystemId;
        EcomSalesVoucherLink."Source Line System Id" := EcomSalesLine.SystemId;
        EcomSalesVoucherLink."Voucher System Id" := CreateGuid();
        EcomSalesVoucherLink."Voucher No." := 'CORRUPT';
        EcomSalesVoucherLink."Voucher State" := EcomSalesVoucherLink."Voucher State"::Active;
        EcomSalesVoucherLink.Insert(true);
    end;

    local procedure GetNextLineNo(EcomSalesHeader: Record "NPR Ecom Sales Header"): Integer
    var
        ExistingLine: Record "NPR Ecom Sales Line";
    begin
        ExistingLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        if ExistingLine.FindLast() then
            exit(ExistingLine."Line No." + 10000);
        exit(10000);
    end;
    #endregion
}
#endif
