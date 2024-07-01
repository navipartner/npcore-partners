codeunit 85044 "NPR JQ POS Posting Tests"
{
    // [Feature] POS Posting via job queue

    Subtype = Test;
    Permissions = tabledata "VAT Entry" = rd,
                    tabledata "G/L Entry" = rd,
                    tabledata "Item Ledger Entry" = rd,
                    tabledata "G/L Entry - VAT Entry Link" = rd;

    var
        _Initialized: Boolean;
        _POSUnit: Record "NPR POS Unit";
        _POSPaymentMethod: Record "NPR POS Payment Method";
        _POSSession: Codeunit "NPR POS Session";
        _POSStore: Record "NPR POS Store";
        _POSSetup: Record "NPR POS Setup";
        _PosUnitNo1: Code[10];
        _PosUnitNo2: Code[10];

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GLPostingPeriodRegisterCompressed()
    var
        PostGLEntriesJQ: Codeunit "NPR POS Post GL Entries JQ";
        PostItemEntriesJQ: Codeunit "NPR POS Post Item Entries JQ";
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        // [Given] Completed and item posted pos entries from multiple POS Units        
        InitializeData(POSPostingProfile."Posting Compression"::"Per POS Period", true);
        _PosUnitNo1 := _POSUnit."No.";
        CreateSales(3);

        _POSSession.ClearAll();
        Clear(_POSSession);
        Clear(_Initialized);

        InitializeData(POSPostingProfile."Posting Compression"::"Per POS Period", false);
        _PosUnitNo2 := _POSUnit."No.";
        CreateSales(3);

        Commit();
        PostItemEntriesJQ.Run();

        // [When] Posting GL of pos entry sales
        Commit();
        PostGLEntriesJQ.Run();

        // [Then] POS entry GL is posted per period register
        CheckPostingResults(_PosUnitNo1);
        CheckPostingResults(_PosUnitNo2);
    end;

    local procedure CheckPostingResults(PosUnitNo: Code[10])
    var
        GLEntry: Record "G/L Entry";
        PeriodRegister: Record "NPR POS Period Register";
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSPostingProfile: Record "NPR POS Posting Profile";
        Assert: Codeunit Assert;
        Line1Amount: Decimal;
        Line2Amount: Decimal;
    begin
        POSEntry.SetRange("POS Unit No.", PosUnitNo);
        POSEntry.SetRange("Post Entry Status", POSEntry."Post Entry Status"::Posted);
        Assert.AreEqual(3, POSEntry.Count(), 'Every entry should have GL posted');
        POSEntry.FindFirst();
        POSEntry.TestField("POS Period Register No.");
        POSEntry.SetRange("POS Period Register No.", POSEntry."POS Period Register No.");
        Assert.AreEqual(3, POSEntry.Count(), 'All POS entries should have been created within the same POS period register No.');
        PeriodRegister.Get(POSEntry."POS Period Register No.");
        PeriodRegister.TestField("Document No.");

        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesLine.FindFirst();
        Line1Amount := POSEntrySalesLine."Amount Excl. VAT (LCY)";
        POSEntrySalesLine.Next();
        Line2Amount := POSEntrySalesLine."Amount Excl. VAT (LCY)";

        GLEntry.SetRange("Document No.", PeriodRegister."Document No.");
        GLEntry.SetRange(GLEntry."Gen. Posting Type", GLEntry."Gen. Posting Type"::Sale);
        GLEntry.SetRange(Amount, ((Line1Amount * 3) + (Line2Amount * 3)) * -1);
        GLEntry.FindFirst();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GLPostingPOSEntryCompressed()
    var
        PostGLEntriesJQ: Codeunit "NPR POS Post GL Entries JQ";
        PostItemEntriesJQ: Codeunit "NPR POS Post Item Entries JQ";
        POSEntry: Record "NPR POS Entry";
        Assert: Codeunit Assert;
        GLEntry: Record "G/L Entry";
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        // [Given] Completed and item posted pos entries from multiple POS Units, compressed for each   
        InitializeData(POSPostingProfile."Posting Compression"::"Per POS Entry", true);
        _PosUnitNo1 := _POSUnit."No.";
        CreateSales(3);

        Commit();
        PostItemEntriesJQ.Run();

        // [When] Posting GL of pos entry sales
        Commit();
        PostGLEntriesJQ.Run();

        // [Then] POS entry GL is posted per period register
        POSEntry.SetRange("POS Unit No.", _PosUnitNo1);
        POSEntry.SetRange("Post Entry Status", POSEntry."Post Entry Status"::Posted);
        Assert.AreEqual(3, POSEntry.Count(), 'Every entry should have GL posted');
        POSEntry.FindSet();
        repeat
            GLEntry.SetRange("Document No.", POSEntry."Document No.");
            GLEntry.SetRange(GLEntry."Gen. Posting Type", GLEntry."Gen. Posting Type"::Sale);
            Assert.AreEqual(1, GLEntry.Count(), 'Should be compressed into 1 per pos entry');
        until POSEntry.Next() = 0;
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GLPostingUncompressed()
    var
        PostGLEntriesJQ: Codeunit "NPR POS Post GL Entries JQ";
        PostItemEntriesJQ: Codeunit "NPR POS Post Item Entries JQ";
        POSEntry: Record "NPR POS Entry";
        Assert: Codeunit Assert;
        GLEntry: Record "G/L Entry";
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        // [Given] Completed and item posted pos entries from multiple POS Units, compressed for each   
        InitializeData(POSPostingProfile."Posting Compression"::Uncompressed, true);
        _PosUnitNo1 := _POSUnit."No.";
        CreateSales(3);

        Commit();
        PostItemEntriesJQ.Run();

        // [When] Posting GL of pos entry sales
        Commit();
        PostGLEntriesJQ.Run();

        // [Then] POS entry GL is posted per period register
        POSEntry.SetRange("POS Unit No.", _PosUnitNo1);
        POSEntry.SetRange("Post Entry Status", POSEntry."Post Entry Status"::Posted);
        Assert.AreEqual(3, POSEntry.Count(), 'Every entry should have GL posted');
        POSEntry.FindSet();
        repeat
            GLEntry.SetRange("Document No.", POSEntry."Document No.");
            GLEntry.SetRange(GLEntry."Gen. Posting Type", GLEntry."Gen. Posting Type"::Sale);
            Assert.AreEqual(2, GLEntry.Count(), 'Should be uncompressed');
        until POSEntry.Next() = 0;
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ItemPosting()
    var
        PostItemEntriesJQ: Codeunit "NPR POS Post Item Entries JQ";
        POSEntry: Record "NPR POS Entry";
        Assert: Codeunit Assert;
        ItemLedgerEntry: Record "Item Ledger Entry";
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSPeriodRegister: Record "NPR POS Period Register";
    begin
        // Note: at the moment, item posting is never compressed, hence no test for each compression setting.

        // [Given] Completed but unposted sales from multiple POS Units.
        InitializeData(POSPostingProfile."Posting Compression"::"Per POS Period", true);
        _PosUnitNo1 := _POSUnit."No.";
        CreateSales(3);

        // [When] Posting inventory of pos entry sales
        Commit();
        PostItemEntriesJQ.Run();

        // [Then] POS entry inventory is posted
        POSEntry.SetRange("POS Unit No.", _PosUnitNo1);
        POSEntry.SetRange("Post Item Entry Status", POSEntry."Post Item Entry Status"::Posted);
        Assert.AreEqual(3, POSEntry.Count(), 'Every entry should have items posted');
        POSPeriodRegister.SetRange("POS Unit No.", _PosUnitNo1);
        POSPeriodRegister.SetRange(Status, POSPeriodRegister.Status::OPEN);
        POSPeriodRegister.FindFirst();
        ItemLedgerEntry.SetRange("Document No.", POSPeriodRegister."Document No.");
        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Sale);
        ItemLedgerEntry.SetRange("Invoiced Quantity", -1);
        Assert.AreEqual(6, ItemLedgerEntry.Count(), 'Every entry should have items posted, on 1 qty lines');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ItemPostingContinueOnError()
    var
        PostItemEntriesJQ: Codeunit "NPR POS Post Item Entries JQ";
        POSEntry: Record "NPR POS Entry";
        POSEntrySaleLine: Record "NPR POS Entry Sales Line";
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        //TODO: At the moment, item posting is never compressed. This appears to be a design choice.

        // [Given] Completed but unposted sales with one of the sales invalid for posting.
        InitializeData(POSPostingProfile."Posting Compression"::"Per POS Period", true);
        CreateSales(3);

        POSEntry.SetRange("POS Unit No.", _POSUnit."No.");
        POSEntry.FindSet();
        POSEntry.Next();
        POSEntrySaleLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySaleLine.FindFirst();
        POSEntrySaleLine."No." := 'Non_existing_item';
        POSEntrySaleLine.Modify();

        // [When] Posting inventory of pos entry sales
        Commit();
        AssertError PostItemEntriesJQ.Run();

        // [Then] inventory is posted before and after the invalid POS entry.
        POSEntry.SetRange("POS Unit No.", _PosUnit."No.");
        POSEntry.FindSet();
        POSEntry.TestField("Post Item Entry Status", POSEntry."Post Item Entry Status"::Posted);
        POSEntry.Next();
        POSEntry.TestField("Post Item Entry Status", POSEntry."Post Item Entry Status"::"Error while Posting");
        POSEntry.Next();
        POSEntry.TestField("Post Item Entry Status", POSEntry."Post Item Entry Status"::Posted);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GLPostingPeriodRegisterCompressionContinueOnError()
    var
        PostGLEntriesJQ: Codeunit "NPR POS Post GL Entries JQ";
        POSEntry: Record "NPR POS Entry";
        POSEntrySaleLine: Record "NPR POS Entry Sales Line";
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        // [Given] Completed POS sales where one of them cannot post for whatever reason.
        InitializeData(POSPostingProfile."Posting Compression"::"Per POS Period", true);
        CreateSales(3);

        POSEntry.SetRange("POS Unit No.", _POSUnit."No.");
        POSEntry.FindSet();
        POSEntry.Next();
        POSEntrySaleLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySaleLine.FindFirst();
        POSEntrySaleLine.Delete();

        // [When] Posting to GL
        Commit();
        AssertError PostGLEntriesJQ.Run();

        // [Then] GL is posted before and after the invalid POS entry
        POSEntry.SetRange("POS Unit No.", _PosUnit."No.");
        POSEntry.FindSet();
        POSEntry.TestField("Post Entry Status", POSEntry."Post Entry Status"::"Error while Posting");
        POSEntry.Next();
        POSEntry.TestField("Post Entry Status", POSEntry."Post Entry Status"::"Error while Posting");
        POSEntry.Next();
        POSEntry.TestField("Post Entry Status", POSEntry."Post Entry Status"::"Error while Posting");
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GLPostingPOSEntryCompressionError()
    var
        PostGLEntriesJQ: Codeunit "NPR POS Post GL Entries JQ";
        POSEntry: Record "NPR POS Entry";
        POSEntrySaleLine: Record "NPR POS Entry Sales Line";
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        //TODO: The behaviour this test shows is that: The other entries in the same period register are left unposted when there is an error in one of them, EVEN when compression is set to POS Entry level. This might be a bug but a low impact one.

        // [Given] Completed POS sales where one of them cannot post for whatever reason.
        InitializeData(POSPostingProfile."Posting Compression"::"Per POS Entry", true);
        CreateSales(3);

        POSEntry.SetRange("POS Unit No.", _POSUnit."No.");
        POSEntry.FindSet();
        POSEntry.Next();
        POSEntrySaleLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySaleLine.FindFirst();
        POSEntrySaleLine.Delete();

        // [When] Posting to GL
        Commit();
        AssertError PostGLEntriesJQ.Run();

        // [Then] GL is posted before and after the invalid POS entry
        POSEntry.SetRange("POS Unit No.", _PosUnit."No.");
        POSEntry.FindSet();
        POSEntry.TestField("Post Entry Status", POSEntry."Post Entry Status"::"Unposted");
        POSEntry.Next();
        POSEntry.TestField("Post Entry Status", POSEntry."Post Entry Status"::"Error while Posting");
        POSEntry.Next();
        POSEntry.TestField("Post Entry Status", POSEntry."Post Entry Status"::"Unposted");
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('PageHandler_POSPaymentBinCheckpoint_LookupOK')]
    procedure EnsureOnlySelectedEntriesPostedWhenRunningPostingManually()
    var
        GLEntry: Record "G/L Entry";
        POSEntry: Record "NPR POS Entry";
        POSEndOfDayProfile: Record "NPR POS End of Day Profile";
        POSPostingProfile: Record "NPR POS Posting Profile";
        Assert: Codeunit Assert;
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleWrapper: Codeunit "NPR POS Sale";
        POSWorkshiftCheckpoint: Codeunit "NPR POS Workshift Checkpoint";
        POSPostRange: Report "NPR POS Posting Action";
        BalancingEntryNo: Integer;
    begin
        // [Given] Completed 2 POS sales and EOD balancing
        InitializeData(POSPostingProfile."Posting Compression"::"Per POS Period", true);
        if not POSEndOfDayProfile.Get('EOD-TEST') then begin
            POSEndOfDayProfile.Code := 'EOD-TEST';
            POSEndOfDayProfile.Insert();
        end;
        POSEndOfDayProfile."Z-Report UI" := POSEndOfDayProfile."Z-Report UI"::BALANCING;
        POSEndOfDayProfile.Modify();
        _POSUnit."POS End of Day Profile" := POSEndOfDayProfile.Code;
        _POSUnit.Modify();

        CreateSales(2);

        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSaleWrapper);
        BalancingEntryNo := POSWorkshiftCheckpoint.EndWorkshift(1, _POSUnit."No.", 0);
        Commit();

        // [When] Posting GL of pos entry sales
        POSEntry.SetRange("Entry Type", POSEntry."Entry Type"::"Direct Sale");
        Clear(POSPostRange);
        POSPostRange.SetPOSEntries(POSEntry);
        POSPostRange.SetGlobalValues(false, true, false, false, false, true);
        POSPostRange.UseRequestPage := false;
        POSPostRange.Run();

        // [Then] Balancing entries are left unposted, while direct sale entries are posted
        Clear(POSEntry);
        POSEntry.SetRange("Entry Type", POSEntry."Entry Type"::"Direct Sale");
        POSEntry.SetRange("Post Entry Status", POSEntry."Post Entry Status"::Posted);
        Assert.AreEqual(2, POSEntry.Count(), 'Every direct sale entry should have GL posted');

        POSEntry.SetRange("Entry Type", POSEntry."Entry Type"::Balancing);
        POSEntry.SetRange("Post Entry Status", POSEntry."Post Entry Status"::Unposted);
        Assert.AreEqual(1, POSEntry.Count(), 'Balancing entry should not have GL posted');
        POSEntry.FindFirst();
        GLEntry.SetRange("Document No.", POSEntry."Document No.");
        Assert.IsTrue(GLEntry.IsEmpty(), 'Balancing entry should not have GL posted');
    end;

    [ModalPageHandler]
    procedure PageHandler_POSPaymentBinCheckpoint_LookupOK(var UIEndOfDay: Page "NPR POS Payment Bin Checkpoint"; var ActionResponse: Action)
    begin
        UIEndOfDay.DoOnOpenPageProcessing();
        UIEndOfDay.DoOnClosePageProcessing();
        ActionResponse := Action::LookupOK;
    end;

    local procedure CreateSales(NoOfSales: Integer)
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        Item1: Record Item;
        Item2: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        Assert: Codeunit "Assert";
        SaleEnded: Boolean;
        i: Integer;
    begin
        if NoOfSales < 1 then
            exit;

        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item1, _POSUnit, _POSStore);
        Item1."Unit Price" := 10;
        Item1.Modify();

        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item2, _POSUnit, _POSStore);
        Item2."Unit Price" := 20;
        Item2.Modify();

        for i := 1 to NoOfSales do begin
            NPRLibraryPOSMock.CreateItemLine(_POSSession, Item1."No.", 1);
            NPRLibraryPOSMock.CreateItemLine(_POSSession, Item2."No.", 1);
            SaleEnded := NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethod.Code, 30, '', false);
            Assert.IsTrue(SaleEnded, 'Sale must end when fully paid');
        end;
    end;

    procedure InitializeData(CompressionMethod: Integer; ClearPostedData: Boolean)
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
    begin
        //Clean any previous mock session
        _POSSession.ClearAll();
        Clear(_POSSession);

        NPRLibraryPOSMasterData.CreatePOSSetup(_POSSetup);
        NPRLibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
        POSPostingProfile."Posting Compression" := CompressionMethod;
        if POSPostingProfile."Posting Compression" <> POSPostingProfile."Posting Compression"::"Per POS Period" then
            Clear(POSPostingProfile."POS Period Register No. Series"); //Stamps POS entry document instead on posted entries.
        POSPostingProfile.Modify();
        NPRLibraryPOSMasterData.CreatePOSStore(_POSStore, POSPostingProfile.Code);
        NPRLibraryPOSMasterData.CreatePOSUnit(_POSUnit, _POSStore.Code, POSPostingProfile.Code);
        NPRLibraryPOSMasterData.CreatePOSPaymentMethod(_POSPaymentMethod, _POSPaymentMethod."Processing Type"::CASH, '', false);

        if ClearPostedData then
            DeletePostedEntries();

        _Initialized := true;

        Commit();
    end;

    local procedure DeletePostedEntries()
    var
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
        POSEntryTaxLine: Record "NPR POS Entry Tax Line";
        GLEntry: Record "G/L Entry";
        VATEntry: Record "VAT Entry";
        GLVATEntryLink: Record "G/L Entry - VAT Entry Link";
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        POSEntry.DeleteAll();
        POSEntrySalesLine.DeleteAll();
        POSEntryPaymentLine.DeleteAll();
        POSEntryTaxLine.DeleteAll();
        VATEntry.DeleteAll();
        GLEntry.DeleteAll();
        GLVATEntryLink.DeleteAll();
        ItemLedgerEntry.DeleteAll();
    end;
}