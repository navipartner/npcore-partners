codeunit 85374 "NPR POS Line No. Posting Tests"
{
    // [FEATURE] POS entry sales line numbering

    Subtype = Test;

    var
        _POSStore: Record "NPR POS Store";
        _POSUnit: Record "NPR POS Unit";
        _Assert: Codeunit "Assert";
        _LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        _LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        _POSSession: Codeunit "NPR POS Session";
        _Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PostSale_NoCollidingLineNos_PostedLineNosMatchTheSourceLineNos()
    var
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        SaleLine: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
    begin
        // [SCENARIO] An ordinary sale posts every sale line under its own line number

        // [GIVEN] A sale with three item lines that all have distinct line numbers
        InitializeSale(SalePOS);
        CreateItemLines(3);
        FindSaleLines(SalePOS, SaleLine);
        _Assert.AreEqual(3, SaleLine.Count(), 'Test prerequisite: the sale must contain three sale lines.');

        // [WHEN] The sale is posted
        PostSale(SalePOS, POSEntry);

        // [THEN] Every sale line is posted once, under the line number it already had
        _Assert.AreEqual(3, PostedSalesLineCount(POSEntry), 'Every sale line must be posted exactly once.');
        SaleLine.FindSet();
        repeat
            POSEntrySalesLine.GetBySystemId(SaleLine.SystemId);
            _Assert.AreEqual(POSEntry."Entry No.", POSEntrySalesLine."POS Entry No.", 'A sale line was posted to another POS entry.');
            _Assert.AreEqual(SaleLine."Line No.", POSEntrySalesLine."Line No.", 'A sale line without a colliding line number must keep its line number.');
        until SaleLine.Next() = 0;
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PostSale_TwoSaleLinesShareLineNo_SecondPostedLineNoAdvancesBy10000()
    var
        EarlierSaleLine: Record "NPR POS Sale Line";
        LaterSaleLine: Record "NPR POS Sale Line";
        POSEntry: Record "NPR POS Entry";
        SalePOS: Record "NPR POS Sale";
    begin
        // [SCENARIO] Two sale lines that share a line number across two sale dates are posted under distinct line numbers

        // [GIVEN] A sale line, and a copy of it on the previous date that keeps the same line number
        InitializeSale(SalePOS);
        CreateItemLines(1);
        FindFirstSaleLine(SalePOS, LaterSaleLine);
        CloneSaleLine(LaterSaleLine, CalcDate('<-1D>', LaterSaleLine.Date), LaterSaleLine."Line No.", EarlierSaleLine);
        _Assert.AreEqual(LaterSaleLine."Line No.", EarlierSaleLine."Line No.", 'Test prerequisite: the sale lines must share a line number.');
        _Assert.AreNotEqual(LaterSaleLine.Date, EarlierSaleLine.Date, 'Test prerequisite: the sale lines must be distinguished by date.');

        // [WHEN] The sale is posted
        PostSale(SalePOS, POSEntry);

        // [THEN] Both lines are posted, and the second one is moved up a full line-number step
        _Assert.AreEqual(2, PostedSalesLineCount(POSEntry), 'Both sale lines must be posted.');
        AssertPostedLineNo(POSEntry, EarlierSaleLine, EarlierSaleLine."Line No.", 'The line posted first must keep its line number.');
        AssertPostedLineNo(POSEntry, LaterSaleLine, LaterSaleLine."Line No." + 10000, 'The colliding line number must advance by 10,000.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PostSale_ThreeSaleLinesShareLineNo_PostedLineNosAdvanceInSteps()
    var
        FirstSaleLine: Record "NPR POS Sale Line";
        POSEntry: Record "NPR POS Entry";
        SalePOS: Record "NPR POS Sale";
        SecondSaleLine: Record "NPR POS Sale Line";
        ThirdSaleLine: Record "NPR POS Sale Line";
        SharedLineNo: Integer;
    begin
        // [SCENARIO] A line number shared by three sale lines is resolved by stepping up until a free slot is found

        // [GIVEN] Three sale lines on three consecutive dates that all carry the same line number
        InitializeSale(SalePOS);
        CreateItemLines(1);
        FindFirstSaleLine(SalePOS, ThirdSaleLine);
        SharedLineNo := ThirdSaleLine."Line No.";
        CloneSaleLine(ThirdSaleLine, CalcDate('<-2D>', ThirdSaleLine.Date), SharedLineNo, FirstSaleLine);
        CloneSaleLine(ThirdSaleLine, CalcDate('<-1D>', ThirdSaleLine.Date), SharedLineNo, SecondSaleLine);

        // [WHEN] The sale is posted
        PostSale(SalePOS, POSEntry);

        // [THEN] Each line is posted one step above the previous one, in sale line order
        _Assert.AreEqual(3, PostedSalesLineCount(POSEntry), 'All three sale lines must be posted.');
        AssertPostedLineNo(POSEntry, FirstSaleLine, SharedLineNo, 'The line posted first must keep the shared line number.');
        AssertPostedLineNo(POSEntry, SecondSaleLine, SharedLineNo + 10000, 'The second colliding line must advance by 10,000.');
        AssertPostedLineNo(POSEntry, ThirdSaleLine, SharedLineNo + 20000, 'The third colliding line must advance by 20,000.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PostSale_DisplacedLineNoMeetsALaterSourceLineNo_EveryPostedLineNoStaysUnique()
    var
        DisplacedSaleLine: Record "NPR POS Sale Line";
        EarlierSaleLine: Record "NPR POS Sale Line";
        OccupyingSaleLine: Record "NPR POS Sale Line";
        POSEntry: Record "NPR POS Entry";
        SalePOS: Record "NPR POS Sale";
        SharedLineNo: Integer;
    begin
        // [SCENARIO] A displaced line number that lands on a line number a later sale line still needs is stepped up again

        // [GIVEN] A colliding pair of sale lines whose free slot is already claimed by a third sale line
        InitializeSale(SalePOS);
        CreateItemLines(1);
        FindFirstSaleLine(SalePOS, DisplacedSaleLine);
        SharedLineNo := DisplacedSaleLine."Line No.";
        CloneSaleLine(DisplacedSaleLine, CalcDate('<-1D>', DisplacedSaleLine.Date), SharedLineNo, EarlierSaleLine);
        CloneSaleLine(DisplacedSaleLine, DisplacedSaleLine.Date, SharedLineNo + 10000, OccupyingSaleLine);

        // [WHEN] The sale is posted
        PostSale(SalePOS, POSEntry);

        // [THEN] No line is dropped or overwritten - the chain resolves into three consecutive slots
        _Assert.AreEqual(3, PostedSalesLineCount(POSEntry), 'All three sale lines must be posted.');
        AssertPostedLineNo(POSEntry, EarlierSaleLine, SharedLineNo, 'The line posted first must keep the shared line number.');
        AssertPostedLineNo(POSEntry, DisplacedSaleLine, SharedLineNo + 10000, 'The displaced line must advance by 10,000.');
        AssertPostedLineNo(POSEntry, OccupyingSaleLine, SharedLineNo + 20000, 'The line whose slot was taken must advance past the displaced line.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PostSale_CommentLineCollidesWithItemLine_BothPostedUnderDistinctLineNos()
    var
        CommentSaleLine: Record "NPR POS Sale Line";
        ItemSaleLine: Record "NPR POS Sale Line";
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        SalePOS: Record "NPR POS Sale";
    begin
        // [SCENARIO] Comment lines share the line-number space of the item lines they are posted with

        // [GIVEN] An item line and a comment line on the previous date that carry the same line number
        InitializeSale(SalePOS);
        CreateItemLines(1);
        FindFirstSaleLine(SalePOS, ItemSaleLine);
        InsertCommentLine(CalcDate('<-1D>', ItemSaleLine.Date), ItemSaleLine."Line No.", CommentSaleLine);

        // [WHEN] The sale is posted
        PostSale(SalePOS, POSEntry);

        // [THEN] Both lines are posted under distinct line numbers, each keeping its own type
        _Assert.AreEqual(2, PostedSalesLineCount(POSEntry), 'The comment line and the item line must both be posted.');
        AssertPostedLineNo(POSEntry, CommentSaleLine, CommentSaleLine."Line No.", 'The comment line posted first must keep its line number.');
        AssertPostedLineNo(POSEntry, ItemSaleLine, ItemSaleLine."Line No." + 10000, 'The item line must advance past the comment line.');
        POSEntrySalesLine.GetBySystemId(CommentSaleLine.SystemId);
        _Assert.AreEqual(POSEntrySalesLine.Type::Comment, POSEntrySalesLine.Type, 'The comment line must be posted as a comment.');
        POSEntrySalesLine.GetBySystemId(ItemSaleLine.SystemId);
        _Assert.AreEqual(POSEntrySalesLine.Type::Item, POSEntrySalesLine.Type, 'The item line must be posted as an item.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PostSale_PaymentLinePresent_DoesNotConsumeASalesLineNo()
    var
        ItemSaleLine: Record "NPR POS Sale Line";
        PaymentSaleLine: Record "NPR POS Sale Line";
        POSEntry: Record "NPR POS Entry";
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
        SalePOS: Record "NPR POS Sale";
    begin
        // [SCENARIO] Payment lines are numbered in their own table and do not displace the sales lines of the same sale

        // [GIVEN] A paid sale whose payment line carries the same line number as its item line
        InitializeSale(SalePOS);
        CreateItemLines(1);
        FindFirstSaleLine(SalePOS, ItemSaleLine);
        InsertPaymentLine(CalcDate('<-1D>', ItemSaleLine.Date), ItemSaleLine."Line No.", PaymentSaleLine);

        // [WHEN] The sale is posted
        PostSale(SalePOS, POSEntry);

        // [THEN] The item line keeps its line number and the payment is posted to the payment line table
        _Assert.AreEqual(1, PostedSalesLineCount(POSEntry), 'Only the item line must be posted as a sales line.');
        AssertPostedLineNo(POSEntry, ItemSaleLine, ItemSaleLine."Line No.", 'A payment line must not displace the sales line numbering.');
        POSEntryPaymentLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        _Assert.AreEqual(1, POSEntryPaymentLine.Count(), 'The payment line must be posted to the POS entry payment lines.');
    end;

    local procedure InitializeSale(var SalePOS: Record "NPR POS Sale")
    var
        POSSale: Codeunit "NPR POS Sale";
    begin
        _LibraryPOSMock.InitializeData(_Initialized, _POSUnit, _POSStore);
        _LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);
    end;

    local procedure CreateItemLines(LineCount: Integer)
    var
        Item: Record Item;
        LineIndex: Integer;
    begin
        for LineIndex := 1 to LineCount do begin
            Clear(Item);
            _LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
            _LibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);
        end;
    end;

    local procedure CloneSaleLine(SourceSaleLine: Record "NPR POS Sale Line"; SaleDate: Date; LineNo: Integer; var ClonedSaleLine: Record "NPR POS Sale Line")
    begin
        ClonedSaleLine.Init();
        ClonedSaleLine.TransferFields(SourceSaleLine, true);
        ClonedSaleLine.Date := SaleDate;
        ClonedSaleLine."Line No." := LineNo;
        Clear(ClonedSaleLine.SystemId);
        ClonedSaleLine.Insert();
    end;

    local procedure InsertCommentLine(SaleDate: Date; LineNo: Integer; var CommentSaleLine: Record "NPR POS Sale Line")
    var
        POSSaleLine: Codeunit "NPR POS Sale Line";
    begin
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetNewSaleLine(CommentSaleLine);
        CommentSaleLine.Date := SaleDate;
        CommentSaleLine."Line No." := LineNo;
        CommentSaleLine."Line Type" := CommentSaleLine."Line Type"::Comment;
        CommentSaleLine.Description := 'Line number collision comment';
        Clear(CommentSaleLine.SystemId);
        CommentSaleLine.Insert();
    end;

    local procedure InsertPaymentLine(SaleDate: Date; LineNo: Integer; var PaymentSaleLine: Record "NPR POS Sale Line")
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSSaleLine: Codeunit "NPR POS Sale Line";
    begin
        _LibraryPOSMasterData.CreatePOSPaymentMethod(POSPaymentMethod, POSPaymentMethod."Processing Type"::CASH, '', false);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetNewSaleLine(PaymentSaleLine);
        PaymentSaleLine.Date := SaleDate;
        PaymentSaleLine."Line No." := LineNo;
        PaymentSaleLine."Line Type" := PaymentSaleLine."Line Type"::"POS Payment";
        PaymentSaleLine."No." := POSPaymentMethod.Code;
        PaymentSaleLine.Description := POSPaymentMethod.Description;
        PaymentSaleLine.Amount := 1;
        PaymentSaleLine."Amount Including VAT" := 1;
        Clear(PaymentSaleLine.SystemId);
        PaymentSaleLine.Insert();
    end;

    local procedure PostSale(var SalePOS: Record "NPR POS Sale"; var POSEntry: Record "NPR POS Entry")
    var
        POSCreateEntry: Codeunit "NPR POS Create Entry";
    begin
        POSCreateEntry.Run(SalePOS);
        POSCreateEntry.GetCreatedPOSEntry(POSEntry);
    end;

    local procedure FindSaleLines(SalePOS: Record "NPR POS Sale"; var SaleLine: Record "NPR POS Sale Line")
    begin
        SaleLine.Reset();
        SaleLine.SetRange("Register No.", SalePOS."Register No.");
        SaleLine.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLine.SetRange("Line Type", SaleLine."Line Type"::Item);
    end;

    local procedure FindFirstSaleLine(SalePOS: Record "NPR POS Sale"; var SaleLine: Record "NPR POS Sale Line")
    begin
        FindSaleLines(SalePOS, SaleLine);
        SaleLine.FindFirst();
    end;

    local procedure PostedSalesLineCount(POSEntry: Record "NPR POS Entry"): Integer
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
    begin
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        exit(POSEntrySalesLine.Count());
    end;

    local procedure AssertPostedLineNo(POSEntry: Record "NPR POS Entry"; SaleLine: Record "NPR POS Sale Line"; ExpectedLineNo: Integer; Message: Text)
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
    begin
        POSEntrySalesLine.GetBySystemId(SaleLine.SystemId);
        _Assert.AreEqual(POSEntry."Entry No.", POSEntrySalesLine."POS Entry No.", 'The sale line was posted to another POS entry.');
        _Assert.AreEqual(ExpectedLineNo, POSEntrySalesLine."Line No.", Message);
    end;
}
