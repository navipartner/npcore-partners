codeunit 85071 "NPR POS Act. Insert Com. Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "Assert";
        Initialized: Boolean;
        POSUnit: Record "NPR POS Unit";
        POSSession: Codeunit "NPR POS Session";
        POSStore: Record "NPR POS Store";
        _ItemAddOn: Record "NPR NpIa Item AddOn";
        _LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        _LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        _ConfirmCount: Integer;
        _ConfirmQuestion: Text;
        _ConfirmReply: Boolean;
        AddOnDeleteQst: Label 'There are one or more Item AddOn dependent lines, linked with the current line. Those will be deleted as well. Are you sure you want to continue?', Locked = true;
        AttachedToTxt: Label '"%1" attached to %2', Locked = true, Comment = '%1 = comment text, %2 = description of the line it is attached to';
        AutoSplitErr: Label 'Autosplit key can''t insert the new line %1 as it already exists. Highlight a different line before selling next item.', Locked = true, Comment = '%1 = line number';
        BetweenTxt: Label 'between %1 and %2', Locked = true, Comment = '%1 = line number before, %2 = line number after';
        CommentNotInsertedTxt: Label '"%1" was not inserted, the current line is "%2"', Locked = true, Comment = '%1 = comment text, %2 = description of the current line';
        LastLineAfterTxt: Label 'after %1, last line of the sale', Locked = true, Comment = '%1 = line number';
        NotAttachedAtTheEndTxt: Label '"%1" not attached, at the end', Locked = true, Comment = '%1 = comment text';
        NotAttachedNotAtTheEndTxt: Label '"%1" not attached, not at the end', Locked = true, Comment = '%1 = comment text';
        PlacementTxt: Label '"%1": %2, indentation %3, No. %4, quantity %5, attached to %6', Locked = true, Comment = '%1 = comment text, %2 = position, %3 = indentation, %4 = No., %5 = quantity, %6 = line it is attached to';
        PositionAtLineTxt: Label 'at line %1', Locked = true, Comment = '%1 = line number';
        RowMismatchTxt: Label '%1: expected <%2>, actual <%3>. ', Locked = true, Comment = '%1 = scenario row, %2 = expected value, %3 = actual value';
        VATRemovedCommentTxt: Label 'VAT removed from sale: %1', Locked = true, Comment = '%1 = VAT amount removed';

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure InsertComment()
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryRandom: Codeunit "Library - Random";
        POSSale: Codeunit "NPR POS Sale";
        BusinessLogic: Codeunit "NPR POS Action - Insert Comm B";
        CommentDescription: Text[100];
    begin
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);

        CommentDescription := CopyStr(LibraryRandom.RandText(MaxStrLen(SaleLinePOS.Description)), 1, MaxStrLen(CommentDescription));

        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);

        BusinessLogic.InputPosCommentLine(CommentDescription, POSSaleLine);

        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        Assert.IsTrue(SaleLinePOS.Description = CommentDescription, 'Comment description is not according to test scenario.');
        Assert.IsTrue(SaleLinePOS."Line Type" = SaleLinePOS."Line Type"::Comment, 'Comment line is not inserted.');
    end;

    #region Indent parameter

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure InsertCommentAction_Registered_IndentIsAYesNoParameterThatDefaultsToNo()
    var
        TempPOSActionParameter: Record "NPR POS Action Parameter" temporary;
        POSActionInsertComm: Codeunit "NPR POS Action - Insert Comm.";
        WorkflowConfig: Codeunit "NPR POS Workflow Config";
    begin
        // [SCENARIO] A button without an Indent value gets the default No, so it inserts an ordinary comment as today
        // [GIVEN] The Insert Comment action
        // [WHEN] Its workflow is registered
        POSActionInsertComm.Register(WorkflowConfig);

        // [THEN] Indent is one of its parameters, a Yes/No parameter with the default No
        WorkflowConfig.GetWorkflowActionParameters(TempPOSActionParameter);
        TempPOSActionParameter.SetRange(Name, 'Indent');
        Assert.IsTrue(TempPOSActionParameter.FindFirst(), 'S1.a: the Insert Comment action should register an Indent parameter.');
        Assert.AreEqual(
            TempPOSActionParameter."Data Type"::Boolean, TempPOSActionParameter."Data Type", 'S1.a: the Indent parameter should be a Yes/No parameter.');
        Assert.AreEqual(Format(false, 0, 9), TempPOSActionParameter."Default Value", 'S1.a: the Indent parameter should default to No.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure InsertCommentButton_IndentNoOrYes_CommentAttachedToTheSelectedDishOnlyWithIndentYes()
    var
        Mismatches: Text;
    begin
        // [SCENARIO] A comment button with Indent No inserts an ordinary comment at the end; with Indent Yes it attaches the text it sends to the selected dish
        Initialize();

        // [GIVEN] Per row, a sale with a DISH line that is selected
        // [WHEN] The Insert Comment workflow runs with the row's Indent value and the text the button sends
        // [THEN] The comment is inserted as the row says
        CheckRow('S1.b', StrSubstNo(NotAttachedAtTheEndTxt, 'No onions'), RunInsertCommentOnNewDish(false, 'No onions'), Mismatches);
        CheckRow('S1.c', StrSubstNo(AttachedToTxt, 'No onions', 'DISH'), RunInsertCommentOnNewDish(true, 'No onions'), Mismatches);
        CheckRow('S1.d', StrSubstNo(AttachedToTxt, 'No onions, no garlic', 'DISH'), RunInsertCommentOnNewDish(true, 'No onions, no garlic'), Mismatches);
        Assert.AreEqual('', Mismatches, 'Rows S1.b, S1.c and S1.d: the Indent parameter decides whether the comment is attached to the selected DISH.');
    end;

    #endregion

    #region The order-note marker

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure InsertComment_NoIndent_MarkedWithStar()
    var
        DishSaleLinePOS: Record "NPR POS Sale Line";
        NewSaleLinePOS: Record "NPR POS Sale Line";
        BusinessLogic: Codeunit "NPR POS Action - Insert Comm B";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        Mismatches: Text;
    begin
        // [SCENARIO] A comment inserted without Indent gets No. "*" and stays an ordinary comment at the end of the sale
        Initialize();

        // [GIVEN] A sale with DISH
        StartSale();
        AddItemLine('DISH', 0, DishSaleLinePOS);

        // [WHEN] The waiter inserts the comment "Milk allergy" without Indent
        POSSession.GetSaleLine(POSSaleLine);
        BusinessLogic.InputPosCommentLine('Milk allergy', false, POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(NewSaleLinePOS);

        // [THEN] The comment is the last line of the sale, not attached, at indentation 0, with No. "*"
        CheckRow('S14.a placement', StrSubstNo(NotAttachedAtTheEndTxt, 'Milk allergy'), DescribeInsertedComment(NewSaleLinePOS, 'Milk allergy'), Mismatches);
        CheckRow('S14.a indentation', '0', Format(NewSaleLinePOS.Indentation), Mismatches);
        CheckRow('S14.a No.', '*', NewSaleLinePOS."No.", Mismatches);
        Assert.AreEqual('', Mismatches, 'Row S14.a: a comment inserted without Indent gets No. "*" and stays an ordinary comment at the end.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SetSaleVAT_CommentLine_NotMarked()
    var
        CommentSaleLinePOS: Record "NPR POS Sale Line";
        Item: Record Item;
        ItemVATPostingSetup: Record "VAT Posting Setup";
        NoVATPostingSetup: Record "VAT Posting Setup";
        SalePOS: Record "NPR POS Sale";
        LibraryERM: Codeunit "Library - ERM";
        SetSaleVATB: Codeunit "NPR POS Action-Set Sale VAT-B.";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        Mismatches: Text;
    begin
        // [SCENARIO] The Set Sale VAT action writes its comment line with a blank No., as before the order-note marker
        Initialize();

        // [GIVEN] A sale with an item priced 12.00 including 25% VAT, and a VAT business posting group with 0% VAT for that item
        StartSale();
        _LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Item."Unit Price" := 12;
        Item.Modify();
        _LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);
        LibraryERM.CreateVATPostingSetupWithAccounts(NoVATPostingSetup, NoVATPostingSetup."VAT Calculation Type"::"Normal VAT", 0);
        LibraryERM.CreateVATPostingSetup(ItemVATPostingSetup, NoVATPostingSetup."VAT Bus. Posting Group", Item."VAT Prod. Posting Group");
        ItemVATPostingSetup."VAT %" := 0;
        ItemVATPostingSetup."VAT Calculation Type" := ItemVATPostingSetup."VAT Calculation Type"::"Normal VAT";
        ItemVATPostingSetup.Validate("Sales VAT Account", LibraryERM.CreateGLAccountNo());
        ItemVATPostingSetup.Validate("Purchase VAT Account", LibraryERM.CreateGLAccountNo());
        ItemVATPostingSetup.Modify();

        // [WHEN] Set Sale VAT moves the sale to that group and adds its comment line
        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        SetSaleVATB.ChangeSaleVATBusPostingGroup(POSSale, POSSaleLine, '', NoVATPostingSetup."VAT Bus. Posting Group", true);

        // [THEN] The sale has the comment "VAT removed from sale: 2.40" with a blank No.
        POSSale.GetCurrentSale(SalePOS);
        CommentSaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        CommentSaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        CommentSaleLinePOS.SetRange("Line Type", CommentSaleLinePOS."Line Type"::Comment);
        Assert.IsTrue(CommentSaleLinePOS.FindFirst(), 'S14.c: Set Sale VAT should have added a comment line to the sale.');
        CheckRow('S14.c comment text', StrSubstNo(VATRemovedCommentTxt, 2.40), CommentSaleLinePOS.Description, Mismatches);
        CheckRow('S14.c No.', '', CommentSaleLinePOS."No.", Mismatches);
        Assert.AreEqual('', Mismatches, 'Row S14.c: the Set Sale VAT comment keeps a blank No., as today.');
    end;

    #endregion

    #region Which line the comment attaches to

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IndentedComment_ItemLineOrAttachedCommentSelected_AttachedToTheItemLine()
    var
        AddOnKSaleLinePOS: Record "NPR POS Sale Line";
        AddOnMSaleLinePOS: Record "NPR POS Sale Line";
        DishSaleLinePOS: Record "NPR POS Sale Line";
        ExtraHotSaleLinePOS: Record "NPR POS Sale Line";
        NewSaleLinePOS: Record "NPR POS Sale Line";
        NoOnionsSaleLinePOS: Record "NPR POS Sale Line";
        TableVIPSaleLinePOS: Record "NPR POS Sale Line";
        Mismatches: Text;
    begin
        // [SCENARIO] An indented comment attaches to the selected item line, or to the line an attached comment belongs to when one is selected
        Initialize();

        // [GIVEN] A sale: DISH, ADDON-K and ADDON-M attached to DISH, "No onions" attached to DISH, "extra hot" attached to ADDON-M, and an ordinary "Table 6 VIP"
        CreateSaleWithAttachedLines(TableVIPSaleLinePOS, DishSaleLinePOS, AddOnKSaleLinePOS, AddOnMSaleLinePOS, NoOnionsSaleLinePOS, ExtraHotSaleLinePOS);

        // [WHEN] Per row, the waiter selects a line and inserts an indented comment
        // [THEN] The comment is attached to the row's line
        InsertIndentedCommentOnSelectedLine(DishSaleLinePOS, 'no ice', NewSaleLinePOS);
        CheckRow('S2.a', StrSubstNo(AttachedToTxt, 'no ice', 'DISH'), DescribeInsertedComment(NewSaleLinePOS, 'no ice'), Mismatches);
        InsertIndentedCommentOnSelectedLine(AddOnKSaleLinePOS, 'well done', NewSaleLinePOS);
        CheckRow('S2.b', StrSubstNo(AttachedToTxt, 'well done', 'ADDON-K'), DescribeInsertedComment(NewSaleLinePOS, 'well done'), Mismatches);
        InsertIndentedCommentOnSelectedLine(AddOnMSaleLinePOS, 'extra hot', NewSaleLinePOS);
        CheckRow('S2.c', StrSubstNo(AttachedToTxt, 'extra hot', 'ADDON-M'), DescribeInsertedComment(NewSaleLinePOS, 'extra hot'), Mismatches);
        InsertIndentedCommentOnSelectedLine(NoOnionsSaleLinePOS, 'no garlic', NewSaleLinePOS);
        CheckRow('S2.d', StrSubstNo(AttachedToTxt, 'no garlic', 'DISH'), DescribeInsertedComment(NewSaleLinePOS, 'no garlic'), Mismatches);
        InsertIndentedCommentOnSelectedLine(ExtraHotSaleLinePOS, 'on the side', NewSaleLinePOS);
        CheckRow('S2.e', StrSubstNo(AttachedToTxt, 'on the side', 'ADDON-M'), DescribeInsertedComment(NewSaleLinePOS, 'on the side'), Mismatches);
        Assert.AreEqual('', Mismatches, 'Rows S2.a, S2.b, S2.c, S2.d and S2.e: an indented comment attaches to the selected item line or to the parent of the selected attached comment.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IndentedComment_OrdinaryCommentOrNothingSelected_OrdinaryCommentAtTheEnd()
    var
        AddOnKSaleLinePOS: Record "NPR POS Sale Line";
        AddOnMSaleLinePOS: Record "NPR POS Sale Line";
        DishSaleLinePOS: Record "NPR POS Sale Line";
        ExtraHotSaleLinePOS: Record "NPR POS Sale Line";
        NewSaleLinePOS: Record "NPR POS Sale Line";
        NoOnionsSaleLinePOS: Record "NPR POS Sale Line";
        TableVIPSaleLinePOS: Record "NPR POS Sale Line";
        Mismatches: Text;
    begin
        // [SCENARIO] With an ordinary comment or no line selected, an indented comment is an ordinary comment at the end of the sale
        Initialize();

        // [GIVEN] The sale with attached lines and the ordinary "Table 6 VIP", which is selected
        CreateSaleWithAttachedLines(TableVIPSaleLinePOS, DishSaleLinePOS, AddOnKSaleLinePOS, AddOnMSaleLinePOS, NoOnionsSaleLinePOS, ExtraHotSaleLinePOS);

        // [WHEN] The waiter inserts the indented comment "birthday"
        InsertIndentedCommentOnSelectedLine(TableVIPSaleLinePOS, 'birthday', NewSaleLinePOS);

        // [THEN] It is an ordinary comment at the end of the sale
        CheckRow('S2.f', StrSubstNo(NotAttachedAtTheEndTxt, 'birthday'), DescribeInsertedComment(NewSaleLinePOS, 'birthday'), Mismatches);

        // [GIVEN] An empty sale
        StartSale();

        // [WHEN] The waiter inserts the indented comment "no ice"
        InsertIndentedComment('no ice', NewSaleLinePOS);

        // [THEN] It is an ordinary comment at the end of the sale
        CheckRow('S2.g', StrSubstNo(NotAttachedAtTheEndTxt, 'no ice'), DescribeInsertedComment(NewSaleLinePOS, 'no ice'), Mismatches);
        Assert.AreEqual('', Mismatches, 'Rows S2.f and S2.g: without an item line to attach to, an indented comment is an ordinary comment at the end.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IndentedComment_SelectedLineDeletedJustBefore_LineThePOSSelectsInsteadDecides()
    var
        BeerSaleLinePOS: Record "NPR POS Sale Line";
        DishSaleLinePOS: Record "NPR POS Sale Line";
        NewSaleLinePOS: Record "NPR POS Sale Line";
        Mismatches: Text;
    begin
        // [SCENARIO] After the selected line is deleted, an indented comment follows the line the POS selects instead, or is ordinary when none is left
        Initialize();

        // [GIVEN] A sale with DISH and BEER, where BEER is selected and deleted, so the POS selects DISH
        StartSale();
        AddItemLine('DISH', 0, DishSaleLinePOS);
        AddItemLine('BEER', 0, BeerSaleLinePOS);
        DeleteLineAsTheDeleteActionDoes(BeerSaleLinePOS);

        // [WHEN] The waiter inserts the indented comment "no ice"
        InsertIndentedComment('no ice', NewSaleLinePOS);

        // [THEN] It is attached to DISH
        CheckRow('S2.h', StrSubstNo(AttachedToTxt, 'no ice', 'DISH'), DescribeInsertedComment(NewSaleLinePOS, 'no ice'), Mismatches);

        // [GIVEN] A sale with DISH only, where DISH is selected and deleted, so the sale is empty
        StartSale();
        AddItemLine('DISH', 0, DishSaleLinePOS);
        DeleteLineAsTheDeleteActionDoes(DishSaleLinePOS);

        // [WHEN] The waiter inserts the indented comment "no ice"
        InsertIndentedComment('no ice', NewSaleLinePOS);

        // [THEN] It is an ordinary comment at the end of the sale
        CheckRow('S2.i', StrSubstNo(NotAttachedAtTheEndTxt, 'no ice'), DescribeInsertedComment(NewSaleLinePOS, 'no ice'), Mismatches);
        Assert.AreEqual('', Mismatches, 'Rows S2.h and S2.i: the line the POS selects after a delete is the line the comment attaches to.');
    end;

    #endregion

    #region Content and position of an attached comment

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IndentedComment_TargetWithAttachedLines_PlacedAfterTheTargetsGroupOneLevelDeeper()
    var
        AddOnKSaleLinePOS: Record "NPR POS Sale Line";
        AddOnMSaleLinePOS: Record "NPR POS Sale Line";
        BeerSaleLinePOS: Record "NPR POS Sale Line";
        DishSaleLinePOS: Record "NPR POS Sale Line";
        NewSaleLinePOS: Record "NPR POS Sale Line";
        WellDoneSaleLinePOS: Record "NPR POS Sale Line";
        Mismatches: Text;
    begin
        // [SCENARIO] An attached comment is a "*" line with quantity 0, one level below its target, placed directly after the target's whole group
        Initialize();

        // [GIVEN] Per row, a sale with the row's lines and line numbers, and the row's target selected
        // [WHEN] The waiter inserts the indented comment "no ice"
        // [THEN] The comment has the row's position and indentation
        StartSale();
        AddItemLine('DISH', 10000, DishSaleLinePOS);
        InsertIndentedCommentOnSelectedLine(DishSaleLinePOS, 'no ice', NewSaleLinePOS);
        CheckRow(
            'S3.a', StrSubstNo(PlacementTxt, 'no ice', StrSubstNo(LastLineAfterTxt, 10000), 1, '*', 0, 'DISH'),
            DescribeCommentPlacement(NewSaleLinePOS, 'no ice', 10000, 0), Mismatches);

        StartSale();
        AddItemLine('DISH', 10000, DishSaleLinePOS);
        AddAttachedAddOnLine('ADDON-K', 15000, DishSaleLinePOS, AddOnKSaleLinePOS);
        AddItemLine('BEER', 20000, BeerSaleLinePOS);
        InsertIndentedCommentOnSelectedLine(DishSaleLinePOS, 'no ice', NewSaleLinePOS);
        CheckRow(
            'S3.b', StrSubstNo(PlacementTxt, 'no ice', StrSubstNo(BetweenTxt, 15000, 20000), 1, '*', 0, 'DISH'),
            DescribeCommentPlacement(NewSaleLinePOS, 'no ice', 15000, 20000), Mismatches);

        StartSale();
        AddItemLine('DISH', 10000, DishSaleLinePOS);
        AddAttachedAddOnLine('ADDON-K', 15000, DishSaleLinePOS, AddOnKSaleLinePOS);
        _LibraryPOSMock.CreateAttachedCommentLine(AddOnKSaleLinePOS, 'well done', 17500, WellDoneSaleLinePOS);
        AddItemLine('BEER', 20000, BeerSaleLinePOS);
        InsertIndentedCommentOnSelectedLine(DishSaleLinePOS, 'no ice', NewSaleLinePOS);
        CheckRow(
            'S3.c', StrSubstNo(PlacementTxt, 'no ice', StrSubstNo(BetweenTxt, 17500, 20000), 1, '*', 0, 'DISH'),
            DescribeCommentPlacement(NewSaleLinePOS, 'no ice', 17500, 20000), Mismatches);

        StartSale();
        AddItemLine('DISH', 10000, DishSaleLinePOS);
        AddAttachedAddOnLine('ADDON-K', 15000, DishSaleLinePOS, AddOnKSaleLinePOS);
        AddItemLine('BEER', 20000, BeerSaleLinePOS);
        InsertIndentedCommentOnSelectedLine(AddOnKSaleLinePOS, 'no ice', NewSaleLinePOS);
        CheckRow(
            'S3.d', StrSubstNo(PlacementTxt, 'no ice', StrSubstNo(BetweenTxt, 15000, 20000), 2, '*', 0, 'ADDON-K'),
            DescribeCommentPlacement(NewSaleLinePOS, 'no ice', 15000, 20000), Mismatches);

        StartSale();
        AddItemLine('DISH', 10000, DishSaleLinePOS);
        AddAttachedAddOnLine('ADDON-K', 15000, DishSaleLinePOS, AddOnKSaleLinePOS);
        AddAttachedAddOnLine('ADDON-M', 17500, DishSaleLinePOS, AddOnMSaleLinePOS);
        AddItemLine('BEER', 20000, BeerSaleLinePOS);
        InsertIndentedCommentOnSelectedLine(AddOnKSaleLinePOS, 'no ice', NewSaleLinePOS);
        CheckRow(
            'S3.f', StrSubstNo(PlacementTxt, 'no ice', StrSubstNo(BetweenTxt, 15000, 17500), 2, '*', 0, 'ADDON-K'),
            DescribeCommentPlacement(NewSaleLinePOS, 'no ice', 15000, 17500), Mismatches);
        Assert.AreEqual('', Mismatches, 'Rows S3.a, S3.b, S3.c, S3.d and S3.f: position, indentation, No. and quantity of the attached comment.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IndentedComment_NoFreeLineNoAfterTheGroup_SameErrorAsAnItemAddOnAndNothingInserted()
    var
        AddOnKSaleLinePOS: Record "NPR POS Sale Line";
        BeerSaleLinePOS: Record "NPR POS Sale Line";
        DishSaleLinePOS: Record "NPR POS Sale Line";
        NewSaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        // [SCENARIO] When no line number is free after the target's group, the comment is refused with the error an item add-on gets there
        Initialize();

        // [GIVEN] A sale with DISH 10000, ADDON-K 10001 attached to DISH and BEER 10002, with DISH selected
        StartSale();
        AddItemLine('DISH', 10000, DishSaleLinePOS);
        AddAttachedAddOnLine('ADDON-K', 10001, DishSaleLinePOS, AddOnKSaleLinePOS);
        AddItemLine('BEER', 10002, BeerSaleLinePOS);

        // [WHEN] The waiter inserts the indented comment "no ice"
        asserterror InsertIndentedCommentOnSelectedLine(DishSaleLinePOS, 'no ice', NewSaleLinePOS);

        // [THEN] The item add-on error for line 10002 is raised and no comment is on the sale
        Assert.ExpectedError(StrSubstNo(AutoSplitErr, 10002));
        SaleLinePOS.SetRange("Register No.", DishSaleLinePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", DishSaleLinePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Line Type", SaleLinePOS."Line Type"::Comment);
        Assert.IsTrue(SaleLinePOS.IsEmpty(), 'S3.e: no comment should be inserted when no line number is free between 10001 and 10002.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IndentedComment_TargetGroupWithCyclicLinks_FinishesAndPlacedAfterTheGroup()
    var
        AddOnKSaleLinePOS: Record "NPR POS Sale Line";
        BeerSaleLinePOS: Record "NPR POS Sale Line";
        DishSaleLinePOS: Record "NPR POS Sale Line";
        NewSaleLinePOS: Record "NPR POS Sale Line";
        WellDoneSaleLinePOS: Record "NPR POS Sale Line";
    begin
        // [SCENARIO] An indented comment on a dish whose add-on links form a cycle is inserted without an error, directly after the dish's group
        Initialize();

        // [GIVEN] A sale with DISH 10000, ADDON-K 15000 attached to DISH, "well done" 17500 attached to ADDON-K and BEER 20000
        StartSale();
        AddItemLine('DISH', 10000, DishSaleLinePOS);
        AddAttachedAddOnLine('ADDON-K', 15000, DishSaleLinePOS, AddOnKSaleLinePOS);
        _LibraryPOSMock.CreateAttachedCommentLine(AddOnKSaleLinePOS, 'well done', 17500, WellDoneSaleLinePOS);
        AddItemLine('BEER', 20000, BeerSaleLinePOS);

        // [GIVEN] Corrupt links: DISH attached to ADDON-K, which closes a cycle, and ADDON-K attached to itself
        _LibraryPOSMock.InsertSaleLineLink(DishSaleLinePOS, AddOnKSaleLinePOS, 10000);
        _LibraryPOSMock.InsertSaleLineLink(AddOnKSaleLinePOS, AddOnKSaleLinePOS, 20000);

        // [WHEN] The waiter selects DISH and inserts the indented comment "no ice"
        InsertIndentedCommentOnSelectedLine(DishSaleLinePOS, 'no ice', NewSaleLinePOS);

        // [THEN] The comment is a "*" line of quantity 0, attached to DISH one level deeper, between 17500 and 20000
        Assert.AreEqual(
            StrSubstNo(PlacementTxt, 'no ice', StrSubstNo(BetweenTxt, 17500, 20000), 1, '*', 0, 'DISH'),
            DescribeCommentPlacement(NewSaleLinePOS, 'no ice', 17500, 20000),
            'The indented comment on DISH should go directly after the group of DISH, also when the links of the group form a cycle.');
    end;

    #endregion

    #region Deleting lines with attached comments

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure LineWithOnlyAttachedComments_Deleted_NoAddOnQuestionAndItsCommentsGoWithIt()
    var
        AddOnMSaleLinePOS: Record "NPR POS Sale Line";
        DishSaleLinePOS: Record "NPR POS Sale Line";
        ExtraHotSaleLinePOS: Record "NPR POS Sale Line";
        NoOnionsSaleLinePOS: Record "NPR POS Sale Line";
        Mismatches: Text;
    begin
        // [SCENARIO] Deleting a line that has only comments attached asks no add-on question and deletes the comments with it
        Initialize();

        // [GIVEN] A sale with DISH and "No onions" attached to it
        StartSale();
        AddItemLine('DISH', 0, DishSaleLinePOS);
        _LibraryPOSMock.CreateAttachedCommentLine(DishSaleLinePOS, 'No onions', 0, NoOnionsSaleLinePOS);

        // [WHEN] The waiter deletes DISH
        DeleteLineAsTheDeleteActionDoes(DishSaleLinePOS);

        // [THEN] No line is left
        CheckRow('S4.a', '', SaleLineDescriptions(DishSaleLinePOS), Mismatches);

        // [GIVEN] A sale with DISH, ADDON-M attached to DISH and "extra hot" attached to ADDON-M
        StartSale();
        AddItemLine('DISH', 0, DishSaleLinePOS);
        AddAttachedAddOnLine('ADDON-M', 0, DishSaleLinePOS, AddOnMSaleLinePOS);
        _LibraryPOSMock.CreateAttachedCommentLine(AddOnMSaleLinePOS, 'extra hot', 0, ExtraHotSaleLinePOS);

        // [WHEN] The waiter deletes ADDON-M
        DeleteLineAsTheDeleteActionDoes(AddOnMSaleLinePOS);

        // [THEN] Only DISH is left
        CheckRow('S4.c', 'DISH', SaleLineDescriptions(DishSaleLinePOS), Mismatches);
        Assert.AreEqual('', Mismatches, 'Rows S4.a and S4.c: the deleted line takes its attached comments with it, without the add-on question.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ConfirmHandler')]
    procedure DishWithAddOnAndComment_DeletedAndTheQuestionConfirmed_AllThreeLinesDeleted()
    var
        AddOnKSaleLinePOS: Record "NPR POS Sale Line";
        DishSaleLinePOS: Record "NPR POS Sale Line";
        NoOnionsSaleLinePOS: Record "NPR POS Sale Line";
    begin
        // [SCENARIO] A dish with an item add-on still gets the add-on question when a comment is attached as well, and a confirm deletes all three lines
        Initialize();

        // [GIVEN] A sale with DISH, ADDON-K and "No onions" attached to DISH, and the waiter confirms the question
        CreateDishWithAddOnAndComment(DishSaleLinePOS, AddOnKSaleLinePOS, NoOnionsSaleLinePOS);
        _ConfirmReply := true;

        // [WHEN] The waiter deletes DISH
        DeleteLineAsTheDeleteActionDoes(DishSaleLinePOS);

        // [THEN] The add-on question was asked once and no line is left
        Assert.AreEqual(1, _ConfirmCount, 'S4.b: deleting DISH with ADDON-K attached should ask the add-on question once.');
        Assert.AreEqual(AddOnDeleteQst, _ConfirmQuestion, 'S4.b: the question should be the existing add-on question.');
        Assert.AreEqual('', SaleLineDescriptions(DishSaleLinePOS), 'S4.b: when the waiter confirms, DISH, ADDON-K and "No onions" should all be deleted.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ConfirmHandler')]
    procedure DishWithAddOnAndComment_DeletedAndTheQuestionDeclined_AllThreeLinesStay()
    var
        AddOnKSaleLinePOS: Record "NPR POS Sale Line";
        DishSaleLinePOS: Record "NPR POS Sale Line";
        NoOnionsSaleLinePOS: Record "NPR POS Sale Line";
    begin
        // [SCENARIO] A dish with an item add-on still gets the add-on question when a comment is attached as well, and declining it keeps all three lines
        Initialize();

        // [GIVEN] A sale with DISH, ADDON-K and "No onions" attached to DISH, and the waiter declines the question
        CreateDishWithAddOnAndComment(DishSaleLinePOS, AddOnKSaleLinePOS, NoOnionsSaleLinePOS);
        Commit();
        _ConfirmReply := false;

        // [WHEN] The waiter deletes DISH
        asserterror DeleteLineAsTheDeleteActionDoes(DishSaleLinePOS);

        // [THEN] The add-on question was asked once and every line is left
        Assert.ExpectedErrorCode('Dialog');
        Assert.AreEqual(1, _ConfirmCount, 'S4.b: deleting DISH with ADDON-K attached should ask the add-on question once.');
        Assert.AreEqual(
            'DISH, ADDON-K, No onions', SaleLineDescriptions(DishSaleLinePOS), 'S4.b: when the waiter declines, DISH, ADDON-K and "No onions" should all stay.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AttachedComment_Deleted_OnlyTheCommentIsDeletedWithoutAQuestion()
    var
        DishSaleLinePOS: Record "NPR POS Sale Line";
        NoOnionsSaleLinePOS: Record "NPR POS Sale Line";
    begin
        // [SCENARIO] Deleting an attached comment deletes only that comment and asks nothing
        Initialize();

        // [GIVEN] A sale with DISH and "No onions" attached to it
        StartSale();
        AddItemLine('DISH', 0, DishSaleLinePOS);
        _LibraryPOSMock.CreateAttachedCommentLine(DishSaleLinePOS, 'No onions', 0, NoOnionsSaleLinePOS);

        // [WHEN] The waiter deletes "No onions"
        DeleteLineAsTheDeleteActionDoes(NoOnionsSaleLinePOS);

        // [THEN] DISH is left
        Assert.AreEqual('DISH', SaleLineDescriptions(DishSaleLinePOS), 'S4.d: deleting "No onions" should leave DISH alone on the sale.');
    end;

    #endregion

    #region Helpers

    local procedure Initialize()
    var
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
    begin
        _LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);
        if _ItemAddOn."No." = '' then begin
            LibraryRestaurant.CreateItemAddon(_ItemAddOn);
            Commit();
        end;
        _ConfirmCount := 0;
        _ConfirmQuestion := '';
        _ConfirmReply := false;
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text; var Reply: Boolean)
    begin
        _ConfirmCount += 1;
        _ConfirmQuestion := Question;
        Reply := _ConfirmReply;
    end;

    local procedure StartSale()
    var
        POSSale: Codeunit "NPR POS Sale";
    begin
        _LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
    end;

    local procedure AddItemLine(Description: Text[100]; LineNo: Integer; var SaleLinePOS: Record "NPR POS Sale Line")
    var
        Item: Record Item;
        POSSaleLine: Codeunit "NPR POS Sale Line";
    begin
        _LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Item.Description := Description;
        Item.Modify();

        Clear(SaleLinePOS);
        SaleLinePOS."Line No." := LineNo;
        SaleLinePOS."Line Type" := SaleLinePOS."Line Type"::Item;
        SaleLinePOS."No." := Item."No.";
        SaleLinePOS.Quantity := 1;
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetUsePresetLineNo(LineNo <> 0);
        POSSaleLine.InsertLine(SaleLinePOS);
        POSSaleLine.SetUsePresetLineNo(false);
    end;

    local procedure AddAttachedAddOnLine(Description: Text[100]; LineNo: Integer; ParentSaleLinePOS: Record "NPR POS Sale Line"; var AddOnSaleLinePOS: Record "NPR POS Sale Line")
    begin
        AddItemLine(Description, LineNo, AddOnSaleLinePOS);
        _LibraryPOSMock.AttachSaleLineAsItemAddOn(AddOnSaleLinePOS, ParentSaleLinePOS, _ItemAddOn."No.");
    end;

    local procedure CreateSaleWithAttachedLines(var TableVIPSaleLinePOS: Record "NPR POS Sale Line"; var DishSaleLinePOS: Record "NPR POS Sale Line"; var AddOnKSaleLinePOS: Record "NPR POS Sale Line"; var AddOnMSaleLinePOS: Record "NPR POS Sale Line"; var NoOnionsSaleLinePOS: Record "NPR POS Sale Line"; var ExtraHotSaleLinePOS: Record "NPR POS Sale Line")
    var
        BusinessLogic: Codeunit "NPR POS Action - Insert Comm B";
        POSSaleLine: Codeunit "NPR POS Sale Line";
    begin
        StartSale();
        AddItemLine('DISH', 0, DishSaleLinePOS);
        AddAttachedAddOnLine('ADDON-K', 0, DishSaleLinePOS, AddOnKSaleLinePOS);
        AddAttachedAddOnLine('ADDON-M', 0, DishSaleLinePOS, AddOnMSaleLinePOS);
        _LibraryPOSMock.CreateAttachedCommentLine(DishSaleLinePOS, 'No onions', 0, NoOnionsSaleLinePOS);
        _LibraryPOSMock.CreateAttachedCommentLine(AddOnMSaleLinePOS, 'extra hot', 0, ExtraHotSaleLinePOS);
        POSSession.GetSaleLine(POSSaleLine);
        BusinessLogic.InputPosCommentLine('Table 6 VIP', POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(TableVIPSaleLinePOS);
    end;

    local procedure CreateDishWithAddOnAndComment(var DishSaleLinePOS: Record "NPR POS Sale Line"; var AddOnKSaleLinePOS: Record "NPR POS Sale Line"; var NoOnionsSaleLinePOS: Record "NPR POS Sale Line")
    begin
        StartSale();
        AddItemLine('DISH', 0, DishSaleLinePOS);
        AddAttachedAddOnLine('ADDON-K', 0, DishSaleLinePOS, AddOnKSaleLinePOS);
        _LibraryPOSMock.CreateAttachedCommentLine(DishSaleLinePOS, 'No onions', 0, NoOnionsSaleLinePOS);
    end;

    local procedure RunInsertCommentOnNewDish(Indent: Boolean; TextSentByTheButton: Text): Text
    var
        DishSaleLinePOS: Record "NPR POS Sale Line";
        NewSaleLinePOS: Record "NPR POS Sale Line";
        Context: Codeunit "NPR POS JSON Helper";
        FrontEnd: Codeunit "NPR POS Front End Management";
        POSActionInsertComm: Codeunit "NPR POS Action - Insert Comm.";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSetup: Codeunit "NPR POS Setup";
        Parameters: JsonObject;
        Root: JsonObject;
    begin
        StartSale();
        AddItemLine('DISH', 0, DishSaleLinePOS);

        Parameters.Add('Indent', Indent);
        Root.Add('parameters', Parameters);
        Root.Add('NewDescription', TextSentByTheButton);
        Context.InitializeJObjectParser(Root);

        POSSession.GetFrontEnd(FrontEnd, true);
        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSession.GetPaymentLine(POSPaymentLine);
        POSSession.GetSetup(POSSetup);
        POSSaleLine.SetPosition(DishSaleLinePOS.GetPosition());
        POSActionInsertComm.RunWorkflow('InsertComment', Context, FrontEnd, POSSale, POSSaleLine, POSPaymentLine, POSSetup);

        POSSaleLine.GetCurrentSaleLine(NewSaleLinePOS);
        exit(DescribeInsertedComment(NewSaleLinePOS, TextSentByTheButton));
    end;

    local procedure InsertIndentedCommentOnSelectedLine(SelectedSaleLinePOS: Record "NPR POS Sale Line"; CommentText: Text[100]; var NewSaleLinePOS: Record "NPR POS Sale Line")
    var
        POSSaleLine: Codeunit "NPR POS Sale Line";
    begin
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetPosition(SelectedSaleLinePOS.GetPosition());
        InsertIndentedComment(CommentText, NewSaleLinePOS);
    end;

    local procedure InsertIndentedComment(CommentText: Text[100]; var NewSaleLinePOS: Record "NPR POS Sale Line")
    var
        BusinessLogic: Codeunit "NPR POS Action - Insert Comm B";
        POSSaleLine: Codeunit "NPR POS Sale Line";
    begin
        POSSession.GetSaleLine(POSSaleLine);
        BusinessLogic.InputPosCommentLine(CommentText, true, POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(NewSaleLinePOS);
    end;

    local procedure DeleteLineAsTheDeleteActionDoes(SaleLinePOS: Record "NPR POS Sale Line")
    var
        DeletePOSLineB: Codeunit "NPR POSAct:Delete POS Line-B";
        POSActionDeleteLine: Codeunit "NPR POSAction: Delete POS Line";
        POSSaleLine: Codeunit "NPR POS Sale Line";
    begin
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetPosition(SaleLinePOS.GetPosition());
        POSActionDeleteLine.OnBeforeDeleteSaleLinePOS(POSSaleLine);
        DeletePOSLineB.DeleteSaleLine(POSSaleLine);
    end;

    local procedure DescribeInsertedComment(SaleLinePOS: Record "NPR POS Sale Line"; CommentText: Text): Text
    var
        ParentSaleLinePOS: Record "NPR POS Sale Line";
    begin
        if (SaleLinePOS."Line Type" <> SaleLinePOS."Line Type"::Comment) or (SaleLinePOS.Description <> CommentText) then
            exit(StrSubstNo(CommentNotInsertedTxt, CommentText, SaleLinePOS.Description));
        if FindParentLine(SaleLinePOS, ParentSaleLinePOS) then
            exit(StrSubstNo(AttachedToTxt, CommentText, ParentSaleLinePOS.Description));
        if IsLastLineOfTheSale(SaleLinePOS) then
            exit(StrSubstNo(NotAttachedAtTheEndTxt, CommentText));
        exit(StrSubstNo(NotAttachedNotAtTheEndTxt, CommentText));
    end;

    local procedure DescribeCommentPlacement(SaleLinePOS: Record "NPR POS Sale Line"; CommentText: Text; AfterLineNo: Integer; BeforeLineNo: Integer): Text
    var
        ParentSaleLinePOS: Record "NPR POS Sale Line";
        Position: Text;
    begin
        if (SaleLinePOS."Line Type" <> SaleLinePOS."Line Type"::Comment) or (SaleLinePOS.Description <> CommentText) then
            exit(StrSubstNo(CommentNotInsertedTxt, CommentText, SaleLinePOS.Description));

        Position := StrSubstNo(PositionAtLineTxt, SaleLinePOS."Line No.");
        if SaleLinePOS."Line No." > AfterLineNo then
            if BeforeLineNo = 0 then begin
                if IsLastLineOfTheSale(SaleLinePOS) then
                    Position := StrSubstNo(LastLineAfterTxt, AfterLineNo);
            end else
                if SaleLinePOS."Line No." < BeforeLineNo then
                    Position := StrSubstNo(BetweenTxt, AfterLineNo, BeforeLineNo);

        if not FindParentLine(SaleLinePOS, ParentSaleLinePOS) then
            Clear(ParentSaleLinePOS);
        exit(StrSubstNo(PlacementTxt, CommentText, Position, SaleLinePOS.Indentation, SaleLinePOS."No.", SaleLinePOS.Quantity, ParentSaleLinePOS.Description));
    end;

    local procedure FindParentLine(SaleLinePOS: Record "NPR POS Sale Line"; var ParentSaleLinePOS: Record "NPR POS Sale Line"): Boolean
    var
        SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
    begin
        SaleLinePOSAddOn.SetRange("Register No.", SaleLinePOS."Register No.");
        SaleLinePOSAddOn.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        SaleLinePOSAddOn.SetRange("Sale Date", SaleLinePOS.Date);
        SaleLinePOSAddOn.SetRange("Sale Line No.", SaleLinePOS."Line No.");
        SaleLinePOSAddOn.SetFilter("Applies-to Line No.", '<>%1', 0);
        if not SaleLinePOSAddOn.FindFirst() then
            exit(false);
        exit(ParentSaleLinePOS.Get(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Sale Type", SaleLinePOSAddOn."Applies-to Line No."));
    end;

    local procedure IsLastLineOfTheSale(SaleLinePOS: Record "NPR POS Sale Line"): Boolean
    var
        LaterSaleLinePOS: Record "NPR POS Sale Line";
    begin
        LaterSaleLinePOS.SetRange("Register No.", SaleLinePOS."Register No.");
        LaterSaleLinePOS.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        LaterSaleLinePOS.SetFilter("Line No.", '>%1', SaleLinePOS."Line No.");
        exit(LaterSaleLinePOS.IsEmpty());
    end;

    local procedure SaleLineDescriptions(AnySaleLinePOS: Record "NPR POS Sale Line") Descriptions: Text
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        SaleLinePOS.SetCurrentKey("Register No.", "Sales Ticket No.", "Line No.");
        SaleLinePOS.SetRange("Register No.", AnySaleLinePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", AnySaleLinePOS."Sales Ticket No.");
        if SaleLinePOS.FindSet() then
            repeat
                if Descriptions <> '' then
                    Descriptions += ', ';
                Descriptions += SaleLinePOS.Description;
            until SaleLinePOS.Next() = 0;
    end;

    local procedure CheckRow(RowId: Text; Expected: Text; Actual: Text; var Mismatches: Text)
    begin
        if Expected <> Actual then
            Mismatches += StrSubstNo(RowMismatchTxt, RowId, Expected, Actual);
    end;

    #endregion
}
