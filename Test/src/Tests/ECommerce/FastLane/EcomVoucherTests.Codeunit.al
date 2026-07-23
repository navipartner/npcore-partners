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

    #region GET issuedAssets — end-to-end resolvability
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetSalesDocument_IssuedAssets_VoucherIdResolvesToRealVoucher()
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        NpRvVoucher: Record "NPR NpRv Voucher";
        VchrImpl: Codeunit "NPR EcomCreateVchrImpl";
        ApiAgent: Codeunit "NPR EcomSalesDocApiAgentV2";
        RootObject: JsonObject;
        LineObject: JsonObject;
        AssetObject: JsonObject;
        LinesArray: JsonArray;
        AssetsArray: JsonArray;
        JToken: JsonToken;
        LineToken: JsonToken;
        AssetToken: JsonToken;
        AssetId: Guid;
        AssetCount: Integer;
    begin
        // [Scenario] A processed qty=1 voucher line issues a voucher + link row. The GET response must
        // emit that voucher under salesDocumentLines[].issuedAssets[], and the emitted id must round-trip:
        // GetBySystemId resolves it to a real voucher whose referenceNo matches. This guards the hoisted
        // per-doc link buffer path (LoadDocVoucherLinks + the in-memory per-line filter) end-to-end.
        _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
        _LibPOSMasterData.CreateDefaultVoucherType(VoucherType, false);
        CreateCapturedVoucherLine(EcomSalesLine, EcomSalesHeader, VoucherType.Code, 1, 100);
        VchrImpl.Process(EcomSalesLine);

        // [When] the document is read back through the GET handler
        RootObject.ReadFrom(ApiAgent.GetSalesDocumentJsonObject(EcomSalesHeader).BuildAsText());

        // [Then] there is exactly one line with exactly one issued asset (StartObject('salesDocument') is
        // ignored at the root, so salesDocumentLines sits directly on the root object).
        RootObject.Get('salesDocumentLines', JToken);
        LinesArray := JToken.AsArray();
        _Assert.AreEqual(1, LinesArray.Count(), 'Expected exactly one sales document line.');

        LinesArray.Get(0, LineToken);
        LineObject := LineToken.AsObject();
        LineObject.Get('issuedAssets', JToken);
        AssetsArray := JToken.AsArray();
        _Assert.AreEqual(1, AssetsArray.Count(), 'Expected exactly one issued asset for the qty=1 voucher line.');

        foreach AssetToken in AssetsArray do begin
            AssetObject := AssetToken.AsObject();

            AssetObject.Get('type', JToken);
            _Assert.AreEqual('voucher', JToken.AsValue().AsText(), 'Issued asset type should be voucher.');

            AssetObject.Get('id', JToken);
            _Assert.IsTrue(Evaluate(AssetId, JToken.AsValue().AsText()), 'issuedAssets id must be a valid Guid.');

            _Assert.IsTrue(NpRvVoucher.GetBySystemId(AssetId), 'GetBySystemId must resolve the emitted issuedAssets id to a real voucher.');
            AssetObject.Get('referenceNo', JToken);
            _Assert.AreEqual(NpRvVoucher."Reference No.", JToken.AsValue().AsText(), 'issuedAssets referenceNo must match the resolved voucher.');

            AssetCount += 1;
        end;
        _Assert.AreEqual(1, AssetCount, 'Exactly one issued asset should have been asserted.');
    end;
    #endregion

    #region FCY vouchers (CORE-1158 - voucher processing in foreign currencies)
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure FaceValueLCY_LCYDocument_NoConversion()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        VchrImpl: Codeunit "NPR EcomCreateVchrImpl";
        FaceValueLCY: Decimal;
    begin
        // [Scenario] Document without a currency code (LCY) → face value is the unit price, no conversion.
        _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
        InitVoucherLineForCalc(EcomSalesLine, 50, 0);

        FaceValueLCY := VchrImpl.CalculateVoucherFaceValueLCY(EcomSalesHeader, EcomSalesLine);

        _Assert.AreEqual(50, FaceValueLCY, 'LCY document: face value must equal the unit price (no conversion).');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure FaceValueLCY_FCYDocument_ConvertsUsingHeaderRate()
    var
        Currency: Record Currency;
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        VchrImpl: Codeunit "NPR EcomCreateVchrImpl";
        FaceValueLCY: Decimal;
    begin
        // [Scenario] FCY document with the exchange-rate factor carried on the ecom header (factor 0.1: AmountLCY = AmountFCY / factor)
        //            → 50 FCY becomes 500 LCY. The exchange-rate table is deliberately seeded with a DIFFERENT rate (0.2) so the
        //            assertion fails if the header factor is ignored and the table is used instead (that would give 250, not 500).
        _LibEcom.CreateFCYCurrency(Currency, 0.2);
        CreateFCYEcomSalesHeader(EcomSalesHeader, Currency.Code, 0.1);
        InitVoucherLineForCalc(EcomSalesLine, 50, 0);

        FaceValueLCY := VchrImpl.CalculateVoucherFaceValueLCY(EcomSalesHeader, EcomSalesLine);

        _Assert.AreEqual(500, FaceValueLCY, 'FCY document: the header factor 0.1 must take precedence (500 LCY), not the table rate 0.2 (which would give 250).');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure FaceValueLCY_FCYDocument_PriceExclVAT_GrossedUpThenConverted()
    var
        Currency: Record Currency;
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        VchrImpl: Codeunit "NPR EcomCreateVchrImpl";
        FaceValueLCY: Decimal;
    begin
        // [Scenario] Price Excl. VAT document: face value is grossed up by VAT % before conversion.
        //            50 FCY * 1.25 = 62.5 FCY → / 0.1 = 625 LCY.
        _LibEcom.CreateFCYCurrency(Currency, 0.1);
        CreateFCYEcomSalesHeader(EcomSalesHeader, Currency.Code, 0.1);
        EcomSalesHeader."Price Excl. VAT" := true;
        EcomSalesHeader.Modify();
        InitVoucherLineForCalc(EcomSalesLine, 50, 25);

        FaceValueLCY := VchrImpl.CalculateVoucherFaceValueLCY(EcomSalesHeader, EcomSalesLine);

        _Assert.AreEqual(625, FaceValueLCY, 'Price Excl. VAT: 50 FCY grossed up by 25% VAT then converted at factor 0.1 must be 625 LCY.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure FaceValueLCY_FCYDocument_MissingHeaderRate_FallsBackToExchRateTable()
    var
        Currency: Record Currency;
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        VchrImpl: Codeunit "NPR EcomCreateVchrImpl";
        FaceValueLCY: Decimal;
    begin
        // [Scenario] FCY document whose header carries no exchange-rate factor (0) → the calculation
        //            falls back to the BC Currency Exchange Rate table on the Received Date.
        _LibEcom.CreateFCYCurrency(Currency, 0.1);
        CreateFCYEcomSalesHeader(EcomSalesHeader, Currency.Code, 0);
        InitVoucherLineForCalc(EcomSalesLine, 50, 0);

        FaceValueLCY := VchrImpl.CalculateVoucherFaceValueLCY(EcomSalesHeader, EcomSalesLine);

        _Assert.AreEqual(500, FaceValueLCY, 'Missing header rate: conversion must fall back to the exchange-rate table (0.1 → 500 LCY).');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VoucherProcess_FCYDocument_VoucherEntryInLCY()
    var
        Currency: Record Currency;
        VoucherType: Record "NPR NpRv Voucher Type";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomSalesVoucherLink: Record "NPR Ecom Sales Voucher Link";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        NpRvVoucherEntry: Record "NPR NpRv Voucher Entry";
        VchrImpl: Codeunit "NPR EcomCreateVchrImpl";
    begin
        // [Scenario] Voucher issued from an FCY ecom document (unit price 50 FCY, factor 0.1) →
        //            the voucher entry and the NpRv sales line both carry the LCY amount (500),
        //            never the FCY unit price. Retail vouchers are an LCY instrument.
        _LibEcom.CreateFCYCurrency(Currency, 0.1);
        CreateFCYEcomSalesHeader(EcomSalesHeader, Currency.Code, 0.1);
        _LibPOSMasterData.CreateDefaultVoucherType(VoucherType, false);
        CreateCapturedVoucherLine(EcomSalesLine, EcomSalesHeader, VoucherType.Code, 1, 50);

        VchrImpl.Process(EcomSalesLine);

        EcomSalesVoucherLink.SetRange("Source Line System Id", EcomSalesLine.SystemId);
        _Assert.IsTrue(EcomSalesVoucherLink.FindFirst(), 'Voucher link row expected for the FCY voucher line.');

        NpRvVoucherEntry.SetRange("Voucher No.", EcomSalesVoucherLink."Voucher No.");
        _Assert.IsTrue(NpRvVoucherEntry.FindFirst(), 'Issue voucher entry expected.');
        _Assert.AreEqual(500, NpRvVoucherEntry.Amount, 'Voucher entry amount must be in LCY (50 FCY / 0.1 = 500), not the FCY unit price.');

        NpRvSalesLine.SetRange("Voucher No.", EcomSalesVoucherLink."Voucher No.");
        NpRvSalesLine.SetRange(Type, NpRvSalesLine.Type::"New Voucher");
        _Assert.IsTrue(NpRvSalesLine.FindFirst(), 'NpRv sales line expected.');
        _Assert.AreEqual(500, NpRvSalesLine.Amount, 'NpRv sales line amount must be in LCY (500), not the FCY unit price.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VoucherProcess_FCYDocument_Qty3_EachVoucherEntryInLCY()
    var
        Currency: Record Currency;
        VoucherType: Record "NPR NpRv Voucher Type";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomSalesVoucherLink: Record "NPR Ecom Sales Voucher Link";
        NpRvVoucherEntry: Record "NPR NpRv Voucher Entry";
        VchrImpl: Codeunit "NPR EcomCreateVchrImpl";
    begin
        // [Scenario] qty=3 on an FCY document → 3 vouchers, each with the per-unit LCY face value (500).
        _LibEcom.CreateFCYCurrency(Currency, 0.1);
        CreateFCYEcomSalesHeader(EcomSalesHeader, Currency.Code, 0.1);
        _LibPOSMasterData.CreateDefaultVoucherType(VoucherType, false);
        CreateCapturedVoucherLine(EcomSalesLine, EcomSalesHeader, VoucherType.Code, 3, 50);

        VchrImpl.Process(EcomSalesLine);

        EcomSalesVoucherLink.SetRange("Source Line System Id", EcomSalesLine.SystemId);
        _Assert.AreEqual(3, EcomSalesVoucherLink.Count(), 'Expected 3 vouchers for qty=3 FCY line.');
        EcomSalesVoucherLink.FindSet();
        repeat
            NpRvVoucherEntry.SetRange("Voucher No.", EcomSalesVoucherLink."Voucher No.");
            _Assert.IsTrue(NpRvVoucherEntry.FindFirst(), 'Issue voucher entry expected for each issued voucher.');
            _Assert.AreEqual(500, NpRvVoucherEntry.Amount, 'Each voucher entry must carry the per-unit LCY face value (500).');
        until EcomSalesVoucherLink.Next() = 0;
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CaptureRedemption_FCYDocument_PostsLCYVoucherEntry()
    var
        Currency: Record Currency;
        VoucherType: Record "NPR NpRv Voucher Type";
        IssueEcomSalesHeader: Record "NPR Ecom Sales Header";
        RedeemEcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomSalesVoucherLink: Record "NPR Ecom Sales Voucher Link";
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        NpRvVoucherEntry: Record "NPR NpRv Voucher Entry";
        PaymentLine: Record "NPR Magento Payment Line";
        VchrImpl: Codeunit "NPR EcomCreateVchrImpl";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
    begin
        // [Scenario] Fastlane capture redemption of a voucher used as payment on a FCY document
        _LibEcom.CreateFCYCurrency(Currency, 0.1);
        CreateFCYEcomSalesHeader(IssueEcomSalesHeader, Currency.Code, 0.1);
        _LibPOSMasterData.CreateDefaultVoucherType(VoucherType, false);
        CreateCapturedVoucherLine(EcomSalesLine, IssueEcomSalesHeader, VoucherType.Code, 1, 50);
        VchrImpl.Process(EcomSalesLine);
        EcomSalesVoucherLink.SetRange("Source Line System Id", EcomSalesLine.SystemId);
        _Assert.IsTrue(EcomSalesVoucherLink.FindFirst(), 'Voucher expected from the FCY issuance document.');
        NpRvVoucher.Get(EcomSalesVoucherLink."Voucher No.");

        CreateFCYEcomSalesHeader(RedeemEcomSalesHeader, Currency.Code, 0.1);

        PaymentLine.Init();
        PaymentLine."Document Table No." := Database::"NPR Ecom Sales Header";
        PaymentLine."Document Type" := PaymentLine."Document Type"::Order;
        PaymentLine."Document No." := CopyStr(RedeemEcomSalesHeader."External No.", 1, MaxStrLen(PaymentLine."Document No."));
        PaymentLine."Line No." := 10000;
        PaymentLine."Payment Type" := PaymentLine."Payment Type"::Voucher;
        PaymentLine."No." := NpRvVoucher."Reference No.";
        PaymentLine."Posting Date" := WorkDate();
        PaymentLine."Source Table No." := Database::"NPR NpRv Voucher";
        PaymentLine."Source No." := NpRvVoucher."No.";
        PaymentLine.Amount := 20; // Document (foreign) currency - partial payment (20 FCY = 200 LCY of the 500 LCY balance)
        PaymentLine."NPR Inc Ecom Sale Id" := RedeemEcomSalesHeader.SystemId;
        PaymentLine.Insert();

        NpRvSalesLine.Init();
        NpRvSalesLine.Id := CreateGuid();
        NpRvSalesLine."External Document No." := RedeemEcomSalesHeader."External No.";
        NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::"Payment Line";
        NpRvSalesLine."Document Type" := NpRvSalesLine."Document Type"::Order;
        NpRvSalesLine."Document No." := CopyStr(RedeemEcomSalesHeader."External No.", 1, MaxStrLen(NpRvSalesLine."Document No."));
        NpRvSalesLine."Document Line No." := PaymentLine."Line No.";
        NpRvSalesLine.Type := NpRvSalesLine.Type::Payment;
        NpRvSalesLine."Voucher Type" := NpRvVoucher."Voucher Type";
        NpRvSalesLine."Voucher No." := NpRvVoucher."No.";
        NpRvSalesLine."Reference No." := NpRvVoucher."Reference No.";
        NpRvSalesLine.Amount := PaymentLine.Amount;
        NpRvSalesLine."NPR Inc Ecom Sale Id" := RedeemEcomSalesHeader.SystemId;
        NpRvSalesLine."Reservation Line Id" := PaymentLine.SystemId;
        NpRvSalesLine.Insert(true);

        NpRvVoucherMgt.PostIncEcomPayment(NpRvSalesLine, PaymentLine);

        NpRvVoucherEntry.SetRange("Voucher No.", NpRvVoucher."No.");
        NpRvVoucherEntry.SetRange("Entry Type", NpRvVoucherEntry."Entry Type"::Payment);
        _Assert.IsTrue(NpRvVoucherEntry.FindFirst(), 'Payment voucher entry expected after capture redemption.');
        _Assert.AreEqual(-200, NpRvVoucherEntry.Amount, 'Capture redemption must post the LCY amount (20 FCY / 0.1 = -200), not the raw FCY payment amount.');

        NpRvVoucher.CalcFields(Amount);
        _Assert.AreEqual(300, NpRvVoucher.Amount, 'Voucher balance must be 300 LCY (500 issued - 200 redeemed).');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ReserveVoucher_FCYDocument_ReservedAmountInLCY()
    var
        Currency: Record Currency;
        VoucherType: Record "NPR NpRv Voucher Type";
        IssueEcomSalesHeader: Record "NPR Ecom Sales Header";
        ReserveEcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line";
        EcomSalesVoucherLink: Record "NPR Ecom Sales Voucher Link";
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        VchrImpl: Codeunit "NPR EcomCreateVchrImpl";
        ApiAgent: Codeunit "NPR EcomSalesDocApiAgentV2";
        OtherConsumerReservationId: Guid;
    begin
        // [Scenario] A voucher reserved as payment on an FCY document must store the reservation in LCY, so the voucher
        //            "Reserved Amount" flowfield (LCY) stays consistent for concurrent consumers: a 20 FCY reservation at
        //            factor 0.1 reserves 200 LCY of the 500 LCY voucher, not the raw FCY 20.
        _LibEcom.CreateFCYCurrency(Currency, 0.1);
        CreateFCYEcomSalesHeader(IssueEcomSalesHeader, Currency.Code, 0.1);
        _LibPOSMasterData.CreateDefaultVoucherType(VoucherType, false);
        VoucherType."Apply Payment Module" := ''; // Partial-payment voucher: usable as ecommerce payment (a full-payment module - DEFAULT/LIMIT - is blocked at reservation)
        VoucherType.Modify();
        CreateCapturedVoucherLine(EcomSalesLine, IssueEcomSalesHeader, VoucherType.Code, 1, 50);
        VchrImpl.Process(EcomSalesLine);
        EcomSalesVoucherLink.SetRange("Source Line System Id", EcomSalesLine.SystemId);
        _Assert.IsTrue(EcomSalesVoucherLink.FindFirst(), 'Voucher expected from the FCY issuance document.');
        NpRvVoucher.Get(EcomSalesVoucherLink."Voucher No.");

        // [Given] A voucher payment line on a second FCY order (20 FCY payment)
        CreateFCYEcomSalesHeader(ReserveEcomSalesHeader, Currency.Code, 0.1);
        EcomSalesPmtLine.Init();
        EcomSalesPmtLine."Document Entry No." := ReserveEcomSalesHeader."Entry No.";
        EcomSalesPmtLine."Line No." := 10000;
        EcomSalesPmtLine."Payment Method Type" := EcomSalesPmtLine."Payment Method Type"::Voucher;
        EcomSalesPmtLine."Payment Reference" := NpRvVoucher."Reference No.";
        EcomSalesPmtLine.Amount := 20; // Document (foreign) currency
        EcomSalesPmtLine.Insert();

        // [When] Reserve the voucher for that payment line
        ApiAgent.ReserveVoucher(ReserveEcomSalesHeader, EcomSalesPmtLine);

        // [Then] The reservation line carries the LCY amount (20 FCY / 0.1 = 200), not the raw FCY amount
        NpRvSalesLine.SetRange("Voucher No.", NpRvVoucher."No.");
        NpRvSalesLine.SetRange(Type, NpRvSalesLine.Type::Payment);
        NpRvSalesLine.SetRange("Document Source", NpRvSalesLine."Document Source"::"Sales Document");
        _Assert.IsTrue(NpRvSalesLine.FindFirst(), 'Reservation line expected after ReserveVoucher.');
        _Assert.AreEqual(200, NpRvSalesLine.Amount, 'Reservation must be stored in LCY (200), not the FCY payment amount.');

        // [Then] The voucher "Reserved Amount" flowfield (as a concurrent consumer sees it) reflects the LCY reservation
        OtherConsumerReservationId := CreateGuid();
        NpRvVoucher.SetFilter("Reservation Line Id Filter", '<>%1', OtherConsumerReservationId);
        NpRvVoucher.CalcFields("Reserved Amount");
        _Assert.AreEqual(200, NpRvVoucher."Reserved Amount", 'Voucher "Reserved Amount" must be LCY (200), keeping availability consistent for concurrent consumers.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Capture_FCYDocument_ClearsReservationInLCY()
    var
        Currency: Record Currency;
        VoucherType: Record "NPR NpRv Voucher Type";
        IssueEcomSalesHeader: Record "NPR Ecom Sales Header";
        CaptureEcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        CaptureItemLine: Record "NPR Ecom Sales Line";
        EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line";
        EcomSalesVoucherLink: Record "NPR Ecom Sales Voucher Link";
        NpRvVoucher: Record "NPR NpRv Voucher";
        ReservationLine: Record "NPR NpRv Sales Line";
        VchrImpl: Codeunit "NPR EcomCreateVchrImpl";
        ApiAgent: Codeunit "NPR EcomSalesDocApiAgentV2";
        EcomCaptureImpl: Codeunit "NPR EcomCaptureImpl";
        OtherConsumerReservationId: Guid;
        Success: Boolean;
        ErrorText: Text;
    begin
        // [Scenario] Full fastlane capture (EcomCaptureImpl.Process -> InsertPaymentLineVoucherPmt) of a voucher paying an FCY
        //            document must settle the reservation in LCY: a 20 FCY payment at factor 0.1 clears the 200 LCY reservation
        //            exactly, leaving no phantom "Reserved Amount". Currency mixing here (TCY vs the LCY reservation) previously
        //            left a residual reservation and understated the voucher balance.
        _LibEcom.CreateFCYCurrency(Currency, 0.1);

        // [Given] A 500 LCY voucher issued from an FCY document, usable as (partial) ecommerce payment
        CreateFCYEcomSalesHeader(IssueEcomSalesHeader, Currency.Code, 0.1);
        _LibPOSMasterData.CreateDefaultVoucherType(VoucherType, false);
        VoucherType."Apply Payment Module" := ''; // Partial-payment voucher: usable as ecommerce payment
        VoucherType.Modify();
        CreateCapturedVoucherLine(EcomSalesLine, IssueEcomSalesHeader, VoucherType.Code, 1, 50);
        VchrImpl.Process(EcomSalesLine);
        EcomSalesVoucherLink.SetRange("Source Line System Id", EcomSalesLine.SystemId);
        _Assert.IsTrue(EcomSalesVoucherLink.FindFirst(), 'Voucher expected from the FCY issuance document.');
        NpRvVoucher.Get(EcomSalesVoucherLink."Voucher No.");

        // [Given] A second FCY order with a virtual-item line to capture (20 FCY) paid by the voucher (20 FCY), with the voucher reserved
        CreateFCYEcomSalesHeader(CaptureEcomSalesHeader, Currency.Code, 0.1);
        CaptureItemLine.Init();
        CaptureItemLine."Document Entry No." := CaptureEcomSalesHeader."Entry No.";
        CaptureItemLine."Document Type" := CaptureEcomSalesHeader."Document Type";
        CaptureItemLine."Line No." := 10000;
        CaptureItemLine.Type := CaptureItemLine.Type::Item;
        CaptureItemLine.Subtype := CaptureItemLine.Subtype::Ticket; // a virtual item so there is an amount to capture (CalculateAmountToCapture)
        CaptureItemLine.Quantity := 1;
        CaptureItemLine."Unit Price" := 20;
        CaptureItemLine."Line Amount" := 20; // document (foreign) currency
        CaptureItemLine.Captured := true;
        CaptureItemLine.Insert(true);

        EcomSalesPmtLine.Init();
        EcomSalesPmtLine."Document Entry No." := CaptureEcomSalesHeader."Entry No.";
        EcomSalesPmtLine."Line No." := 10000;
        EcomSalesPmtLine."Payment Method Type" := EcomSalesPmtLine."Payment Method Type"::Voucher;
        EcomSalesPmtLine."Payment Reference" := NpRvVoucher."Reference No.";
        EcomSalesPmtLine.Amount := 20; // document (foreign) currency
        EcomSalesPmtLine.Insert();

        ApiAgent.ReserveVoucher(CaptureEcomSalesHeader, EcomSalesPmtLine);
        ReservationLine.SetRange("Voucher No.", NpRvVoucher."No.");
        ReservationLine.SetRange(Type, ReservationLine.Type::Payment);
        ReservationLine.SetRange("Document Source", ReservationLine."Document Source"::"Sales Document");
        ReservationLine.SetRange("Document Line No.", 0);
        _Assert.IsTrue(ReservationLine.FindFirst(), 'Reservation line expected after ReserveVoucher.');
        _Assert.AreEqual(200, ReservationLine.Amount, 'Reservation must be 200 LCY (20 FCY / 0.1).');

        // [When] The document is captured
        EcomCaptureImpl.Process(CaptureEcomSalesHeader, Success, ErrorText);
        _Assert.IsTrue(Success, ErrorText);

        // [Then] The reservation is cleared exactly (no phantom residual), so the voucher balance is fully available again
        ReservationLine.Reset();
        ReservationLine.SetRange("Voucher No.", NpRvVoucher."No.");
        ReservationLine.SetRange(Type, ReservationLine.Type::Payment);
        ReservationLine.SetRange("Document Source", ReservationLine."Document Source"::"Sales Document");
        ReservationLine.SetRange("Document Line No.", 0);
        _Assert.IsFalse(ReservationLine.FindFirst(), 'The ingest reservation must be deleted after full capture (200 LCY reservation - 200 LCY captured = 0).');

        OtherConsumerReservationId := CreateGuid();
        NpRvVoucher.SetFilter("Reservation Line Id Filter", '<>%1', OtherConsumerReservationId);
        NpRvVoucher.CalcFields("Reserved Amount");
        _Assert.AreEqual(0, NpRvVoucher."Reserved Amount", 'No phantom reservation must survive the completed capture (Reserved Amount = 0).');
    end;
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

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure FaceValueLCY_FCYDocument_FixedBothRate_HeaderRateMatchesTable_ConvertsViaTable()
    var
        Currency: Record Currency;
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        CurrExchRate: Record "Currency Exchange Rate";
        VchrImpl: Codeunit "NPR EcomCreateVchrImpl";
        FaceValueLCY: Decimal;
    begin
        // [Scenario] Exchange-rate row is Fix Exchange Rate Amount = Both (100 FCY = 1000 LCY → 50 FCY = 500 LCY). The header
        //            carries the SAME effective factor as the table, so the conversion proceeds and uses the table (Both) amounts.
        _LibEcom.CreateFCYCurrencyFixedBoth(Currency, 100, 1000);
        CreateFCYEcomSalesHeader(EcomSalesHeader, Currency.Code, CurrExchRate.ExchangeRate(WorkDate(), Currency.Code));
        InitVoucherLineForCalc(EcomSalesLine, 50, 0);

        FaceValueLCY := VchrImpl.CalculateVoucherFaceValueLCY(EcomSalesHeader, EcomSalesLine);

        _Assert.AreEqual(500, FaceValueLCY, 'Both rate with a matching header factor must convert via the table (50 FCY at 100=1000 → 500 LCY).');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure FixedBothRate_SuppliedRateDiffersFromTable_RejectedAtIngest()
    var
        Currency: Record Currency;
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
    begin
        // [Scenario] Exchange-rate row is Fix Exchange Rate Amount = Both (effective factor 0.1), but the document supplies a
        //            different rate (0.5). Because Both makes the platform ignore the supplied factor on posting, ingest must reject
        //            the document instead of persisting a rate the posting will not use.
        _LibEcom.CreateFCYCurrencyFixedBoth(Currency, 100, 1000);

        asserterror EcomSalesDocUtils.CheckSuppliedRateMatchesFixedBothRate(Currency.Code, WorkDate(), 0.5);

        _Assert.ExpectedError('does not match the fixed exchange rate');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure FixedBothRate_SuppliedRateMatchesTable_PassesIngest()
    var
        Currency: Record Currency;
        CurrExchRate: Record "Currency Exchange Rate";
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
    begin
        // [Scenario] Both-configured rate; the supplied factor equals the table's effective factor → ingest guard passes (no error).
        _LibEcom.CreateFCYCurrencyFixedBoth(Currency, 100, 1000);

        EcomSalesDocUtils.CheckSuppliedRateMatchesFixedBothRate(Currency.Code, WorkDate(), CurrExchRate.ExchangeRate(WorkDate(), Currency.Code));
        // No error expected: a supplied rate that agrees with the Both row must be accepted at ingest.
    end;

    local procedure CreateFCYEcomSalesHeader(var EcomSalesHeader: Record "NPR Ecom Sales Header"; CurrencyCode: Code[10]; CurrencyExchangeRate: Decimal)
    begin
        _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
        EcomSalesHeader."Currency Code" := CurrencyCode;
        EcomSalesHeader."Currency Exchange Rate" := CurrencyExchangeRate;
        EcomSalesHeader."Received Date" := WorkDate();
        EcomSalesHeader.Modify();
    end;

    local procedure InitVoucherLineForCalc(var EcomSalesLine: Record "NPR Ecom Sales Line"; UnitPrice: Decimal; VatPct: Decimal)
    begin
        // Calculation-only line: CalculateVoucherFaceValueLCY reads "Unit Price" and "VAT %" — no insert needed.
        EcomSalesLine.Init();
        EcomSalesLine."Unit Price" := UnitPrice;
        EcomSalesLine."VAT %" := VatPct;
    end;
    #endregion
}
#endif
