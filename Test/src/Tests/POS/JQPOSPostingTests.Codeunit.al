codeunit 85044 "NPR JQ POS Posting Tests"
{
    // [Feature] POS Posting via job queue

    Subtype = Test;

    var
        _Initialized: Boolean;
        _POSUnit: Record "NPR POS Unit";
        _POSPaymentMethod: Record "NPR POS Payment Method";
        _POSSession: Codeunit "NPR POS Session";
        _POSStore: Record "NPR POS Store";
        _POSSetup: Record "NPR POS Setup";
        _PosUnitNo1: Text;
        _PosUnitNo2: Text;

    [Test]
    procedure GLPostingPeriodRegisterCompressed()
    var
        PostGLEntriesJQ: Codeunit "NPR POS Post GL Entries JQ";
        PeriodRegister: Record "NPR POS Period Register";
        POSEntry: Record "NPR POS Entry";
        Assert: Codeunit Assert;
        GLEntry: Record "G/L Entry";
        PostItemEntriesJQ: Codeunit "NPR POS Post Item Entries JQ";
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        Line1Amount: Decimal;
        Line2Amount: Decimal;
    begin
        // [Given] Completed and item posted pos entries from multiple POS Units        
        InitializeData(POSPostingProfile."Posting Compression"::"Per POS Period");
        _PosUnitNo1 := _POSUnit."No.";
        CreateSales(3);

        _POSSession.Destructor();
        Clear(_POSSession);
        Clear(_Initialized);

        InitializeData(POSPostingProfile."Posting Compression"::"Per POS Period");
        _PosUnitNo2 := _POSUnit."No.";
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
        POSEntry.FindFirst();
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesLine.FindFirst();
        Line1Amount := POSEntrySalesLine."Amount Excl. VAT (LCY)";
        POSEntrySalesLine.Next();
        Line2Amount := POSEntrySalesLine."Amount Excl. VAT (LCY)";
        PeriodRegister.SetRange("POS Unit No.", _PosUnitNo1);
        PeriodRegister.SetRange(Status, PeriodRegister.Status::OPEN);
        PeriodRegister.FindFirst();
        GLEntry.SetRange("Document No.", PeriodRegister."Document No.");
        GLEntry.SetRange(GLEntry."Gen. Posting Type", GLEntry."Gen. Posting Type"::Sale);
        GLEntry.SetRange(Amount, ((Line1Amount * 3) + (Line2Amount * 3)) * -1);
        GLEntry.FindFirst();

        POSEntry.SetRange("POS Unit No.", _PosUnitNo2);
        POSEntry.SetRange("Post Entry Status", POSEntry."Post Entry Status"::Posted);
        Assert.AreEqual(3, POSEntry.Count(), 'Every entry should have GL posted');
        POSEntry.FindFirst();
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesLine.FindFirst();
        Line1Amount := POSEntrySalesLine."Amount Excl. VAT (LCY)";
        POSEntrySalesLine.Next();
        Line2Amount := POSEntrySalesLine."Amount Excl. VAT (LCY)";
        PeriodRegister.SetRange("POS Unit No.", _PosUnitNo2);
        PeriodRegister.SetRange(Status, PeriodRegister.Status::OPEN);
        PeriodRegister.FindFirst();
        GLEntry.SetRange("Document No.", PeriodRegister."Document No.");
        GLEntry.SetRange(GLEntry."Gen. Posting Type", GLEntry."Gen. Posting Type"::Sale);
        GLEntry.SetRange(Amount, ((Line1Amount * 3) + (Line2Amount * 3)) * -1);
        GLEntry.FindFirst();
    end;

    [Test]
    procedure GLPostingPOSEntryCompressed()
    var
        PostGLEntriesJQ: Codeunit "NPR POS Post GL Entries JQ";
        PostItemEntriesJQ: Codeunit "NPR POS Post Item Entries JQ";
        PeriodRegister: Record "NPR POS Period Register";
        POSEntry: Record "NPR POS Entry";
        Assert: Codeunit Assert;
        GLEntry: Record "G/L Entry";
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        // [Given] Completed and item posted pos entries from multiple POS Units, compressed for each   
        InitializeData(POSPostingProfile."Posting Compression"::"Per POS Entry");
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
    procedure GLPostingUncompressed()
    var
        PostGLEntriesJQ: Codeunit "NPR POS Post GL Entries JQ";
        PostItemEntriesJQ: Codeunit "NPR POS Post Item Entries JQ";
        PeriodRegister: Record "NPR POS Period Register";
        POSEntry: Record "NPR POS Entry";
        Assert: Codeunit Assert;
        GLEntry: Record "G/L Entry";
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        // [Given] Completed and item posted pos entries from multiple POS Units, compressed for each   
        InitializeData(POSPostingProfile."Posting Compression"::Uncompressed);
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
        InitializeData(POSPostingProfile."Posting Compression"::"Per POS Period");
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
    procedure ItemPostingContinueOnError()
    var
        PostItemEntriesJQ: Codeunit "NPR POS Post Item Entries JQ";
        PeriodRegister: Record "NPR POS Period Register";
        POSEntry: Record "NPR POS Entry";
        Assert: Codeunit Assert;
        ItemLedgerEntry: Record "Item Ledger Entry";
        POSEntrySaleLine: Record "NPR POS Entry Sales Line";
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        //TODO: At the moment, item posting is never compressed. This appears to be a design choice.

        // [Given] Completed but unposted sales with one of the sales invalid for posting.
        InitializeData(POSPostingProfile."Posting Compression"::"Per POS Period");
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
    procedure GLPostingPeriodRegisterCompressionContinueOnError()
    var
        PostGLEntriesJQ: Codeunit "NPR POS Post GL Entries JQ";
        POSEntry: Record "NPR POS Entry";
        POSEntrySaleLine: Record "NPR POS Entry Sales Line";
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        // [Given] Completed POS sales where one of them cannot post for whatever reason.
        InitializeData(POSPostingProfile."Posting Compression"::"Per POS Period");
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
    procedure GLPostingPOSEntryCompressionError()
    var
        PostGLEntriesJQ: Codeunit "NPR POS Post GL Entries JQ";
        POSEntry: Record "NPR POS Entry";
        POSEntrySaleLine: Record "NPR POS Entry Sales Line";
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        //TODO: The behaviour this test shows is that: The other entries in the same period register are left unposted when there is an error in one of them, EVEN when compression is set to POS Entry level. This might be a bug but a low impact one.

        // [Given] Completed POS sales where one of them cannot post for whatever reason.
        InitializeData(POSPostingProfile."Posting Compression"::"Per POS Entry");
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

    local procedure CreateSales(NoOfSales: Integer)
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        Item1: Record Item;
        Item2: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        Assert: Codeunit "Assert";
        SaleEnded: Boolean;
        POSEntry: Record "NPR POS Entry";
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

    procedure InitializeData(CompressionMethod: Integer)
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        GLSetup: Record "General Ledger Setup";
        POSEntry: Record "NPR POS Entry";
    begin
        if _Initialized then begin
            //Clean any previous mock session
            _POSSession.Destructor();
            Clear(_POSSession);
        end;

        NPRLibraryPOSMasterData.CreatePOSSetup(_POSSetup);
        NPRLibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
        POSPostingProfile."Posting Compression" := CompressionMethod;
        if POSPostingProfile."Posting Compression" <> POSPostingProfile."Posting Compression"::"Per POS Period" then
            Clear(POSPostingProfile."POS Period Register No. Series"); //Stamps POS entry document instead on posted entries.
        POSPostingProfile.Modify();
        NPRLibraryPOSMasterData.CreatePOSStore(_POSStore, POSPostingProfile.Code);
        NPRLibraryPOSMasterData.CreatePOSUnit(_POSUnit, _POSStore.Code, POSPostingProfile.Code);
        NPRLibraryPOSMasterData.CreatePOSPaymentMethod(_POSPaymentMethod, _POSPaymentMethod."Processing Type"::CASH, '', false);
        _Initialized := true;

        Commit();
    end;
}