codeunit 85007 "NPR POS Saved Sale Tests"
{
    Subtype = Test;

    var
        _Initialized: Boolean;
        _POSUnit: Record "NPR POS Unit";
        _POSPaymentMethod: Record "NPR POS Payment Method";
        _POSSession: Codeunit "NPR POS Session";
        _POSStore: Record "NPR POS Store";
        _POSSetup: Record "NPR POS Setup";
        _ItemAddOn: Record "NPR NpIa Item AddOn";
        AttachedEntryTxt: Label '%1 > %2', Locked = true, Comment = '%1 = line entry, %2 = description of the line it is attached to';
        IndentedEntryTxt: Label '%1 (indentation %2)', Locked = true, Comment = '%1 = line entry, %2 = indentation';
        CommentEntryTxt: Label '%1 (No. "%2", indentation %3)', Locked = true, Comment = '%1 = line entry, %2 = No., %3 = indentation';
        RowMismatchTxt: Label '%1: expected <%2>, actual <%3>. ', Locked = true, Comment = '%1 = scenario row, %2 = expected value, %3 = actual value';

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SaleWithAttachedCommentsAndAddOns_ParkedAndResumed_EveryLineAttachedAndIndentedAgain()
    var
        AddOnMSaleLinePOS: Record "NPR POS Sale Line";
        CommentSaleLinePOS: Record "NPR POS Sale Line";
        DishSaleLinePOS: Record "NPR POS Sale Line";
        Assert: Codeunit Assert;
        Mismatches: Text;
    begin
        // [SCENARIO] Resuming a parked sale attaches every comment and add-on to its line again, indented and with the comment's "*"
        InitializeData();
        CreateItemAddOnOnce();

        // [GIVEN] Per row, a sale with the row's attached lines that is parked
        // [WHEN] The parked sale is resumed
        // [THEN] Every attached line is attached and indented again
        StartSaleForAttachedLines();
        AddRoleItemLine('DISH', DishSaleLinePOS);
        AddAttachedComment(DishSaleLinePOS, 'No onions', CommentSaleLinePOS);
        CheckRow('S11.a', 'DISH (indentation 0); No onions > DISH (No. "*", indentation 1)', ParkAndResume(), Mismatches);

        StartSaleForAttachedLines();
        AddRoleItemLine('DISH', DishSaleLinePOS);
        AddRoleItemLine('ADDON-M', AddOnMSaleLinePOS);
        AttachAddOn(AddOnMSaleLinePOS, DishSaleLinePOS);
        AddAttachedComment(AddOnMSaleLinePOS, 'extra hot', CommentSaleLinePOS);
        CheckRow(
            'S11.b', 'DISH (indentation 0); ADDON-M > DISH (indentation 1); extra hot > ADDON-M (No. "*", indentation 2)', ParkAndResume(), Mismatches);
        Assert.AreEqual('', Mismatches, 'Rows S11.a and S11.b: after resuming, comments and add-ons are attached and indented as before parking.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SaveAndLoadPOSSale()
    begin
        POSQuote_SaveAndLoad(Today, Today);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SaveAndLoadPOSSaleFromPreviousDate()
    begin
        POSQuote_SaveAndLoad(CalcDate('<-2D>', Today), Today);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SaveAndLoadAndFinishPOSSale()
    var
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
    begin
        POSQuote_SaveAndLoad(Today, Today);
        NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethod.Code, 10, '');
    end;

    local procedure POSQuote_SaveAndLoad(InitialSaleDate: Date; LoadSaleDate: Date)
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        POSActionSavePOSQuote: codeunit "NPR POS Action: SavePOSSvSl B";
        POSActionLoadPOSQuote: codeunit "NPR POS Action: LoadPOSSvSl B";
        POSQuoteEntry: Record "NPR POS Saved Sale Entry";
        POSQuoteLine: Record "NPR POS Saved Sale Line";
        PreviousSaleSystemId: Guid;
        PreviousSaleLineSystemId: Guid;
    begin
        // [Given] POS & Payment setup
        WorkDate(InitialSaleDate);
        InitializeData();

        // [Given] Active POS session & sale
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] Item line worth 10 LCY
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        Item."Unit Price" := 10;
        Item.Modify;
        NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.FindFirst();
        PreviousSaleLineSystemId := SaleLinePOS.SystemId;
        PreviousSaleSystemId := SalePOS.SystemId;

        // [When] Saving to POS quote
        POSActionSavePOSQuote.SaveSaleAndStartNewSale(POSQuoteEntry);

        // [Then] Correct data is saved
        POSQuoteEntry.TestField(SystemId, SalePOS.SystemId);
        POSQuoteEntry.TestField("Sales Ticket No.", SalePOS."Sales Ticket No.");
        POSQuoteLine.SetRange("Quote Entry No.", POSQuoteEntry."Entry No.");
        POSQuoteLine.FindFirst();
        POSQuoteLine.TestField("No.", Item."No.");
        POSQuoteLine.TestField("Unit Price", 10);
        POSQuoteLine.TestField(SystemId, PreviousSaleLineSystemId);

        // [When] Loading POS Quote in another POS session
        _POSSession.ClearAll();
        Clear(_POSSession);
        WorkDate(LoadSaleDate);

        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSActionLoadPOSQuote.LoadFromQuote(POSQuoteEntry, SalePOS);

        // [Then] Sale loaded correct data
        SalePOS.TestField(SystemId, PreviousSaleSystemId);
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange(Date, SalePOS.Date);
        SaleLinePOS.FindFirst();
        SaleLinePOS.TestField("No.", Item."No.");
        SaleLinePOS.TestField("Unit Price", 10);
        SaleLinePOS.TestField(SystemId, PreviousSaleLineSystemId);
    end;

    procedure InitializeData()
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
    begin
        //Clean any previous mock session
        _POSSession.ClearAll();
        Clear(_POSSession);

        if not _Initialized then begin
            NPRLibraryPOSMasterData.CreatePOSSetup(_POSSetup);
            NPRLibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
            NPRLibraryPOSMasterData.CreatePOSStore(_POSStore, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSUnit(_POSUnit, _POSStore.Code, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSPaymentMethod(_POSPaymentMethod, _POSPaymentMethod."Processing Type"::CASH, '', false);
            _Initialized := true;
        end;

        Commit;
    end;

    local procedure CreateItemAddOnOnce()
    var
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
    begin
        if _ItemAddOn."No." <> '' then
            exit;
        LibraryRestaurant.CreateItemAddon(_ItemAddOn);
        Commit();
    end;

    local procedure StartSaleForAttachedLines()
    var
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
    begin
        _POSSession.ClearAll();
        Clear(_POSSession);
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
    end;

    local procedure AddRoleItemLine(Description: Text[100]; var SaleLinePOS: Record "NPR POS Sale Line")
    var
        Item: Record Item;
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleLine: Codeunit "NPR POS Sale Line";
    begin
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        Item.Description := Description;
        Item.Modify();
        NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
    end;

    local procedure AttachAddOn(var AddOnSaleLinePOS: Record "NPR POS Sale Line"; ParentSaleLinePOS: Record "NPR POS Sale Line")
    var
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
    begin
        NPRLibraryPOSMock.AttachSaleLineAsItemAddOn(AddOnSaleLinePOS, ParentSaleLinePOS, _ItemAddOn."No.");
    end;

    local procedure AddAttachedComment(ParentSaleLinePOS: Record "NPR POS Sale Line"; CommentText: Text; var CommentSaleLinePOS: Record "NPR POS Sale Line")
    var
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
    begin
        NPRLibraryPOSMock.CreateAttachedCommentLine(ParentSaleLinePOS, CommentText, 0, CommentSaleLinePOS);
    end;

    local procedure ParkAndResume(): Text
    var
        POSQuoteEntry: Record "NPR POS Saved Sale Entry";
        SalePOS: Record "NPR POS Sale";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSActionLoadPOSQuote: Codeunit "NPR POS Action: LoadPOSSvSl B";
        POSActionSavePOSQuote: Codeunit "NPR POS Action: SavePOSSvSl B";
        POSSale: Codeunit "NPR POS Sale";
    begin
        POSActionSavePOSQuote.SaveSaleAndStartNewSale(POSQuoteEntry);

        _POSSession.ClearAll();
        Clear(_POSSession);
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSActionLoadPOSQuote.LoadFromQuote(POSQuoteEntry, SalePOS);
        exit(SaleLineSequence(SalePOS));
    end;

    local procedure SaleLineSequence(SalePOS: Record "NPR POS Sale") Sequence: Text
    var
        ParentSaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
        Entry: Text;
    begin
        SaleLinePOS.SetCurrentKey("Register No.", "Sales Ticket No.", "Line No.");
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        if not SaleLinePOS.FindSet() then
            exit;
        repeat
            Entry := SaleLinePOS.Description;
            SaleLinePOSAddOn.SetRange("Register No.", SaleLinePOS."Register No.");
            SaleLinePOSAddOn.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
            SaleLinePOSAddOn.SetRange("Sale Date", SaleLinePOS.Date);
            SaleLinePOSAddOn.SetRange("Sale Line No.", SaleLinePOS."Line No.");
            SaleLinePOSAddOn.SetFilter("Applies-to Line No.", '<>%1', 0);
            if SaleLinePOSAddOn.FindFirst() then
                if ParentSaleLinePOS.Get(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Sale Type", SaleLinePOSAddOn."Applies-to Line No.") then
                    Entry := StrSubstNo(AttachedEntryTxt, Entry, ParentSaleLinePOS.Description);
            if SaleLinePOS."Line Type" = SaleLinePOS."Line Type"::Comment then
                Entry := StrSubstNo(CommentEntryTxt, Entry, SaleLinePOS."No.", SaleLinePOS.Indentation)
            else
                Entry := StrSubstNo(IndentedEntryTxt, Entry, SaleLinePOS.Indentation);
            if Sequence <> '' then
                Sequence += '; ';
            Sequence += Entry;
        until SaleLinePOS.Next() = 0;
    end;

    local procedure CheckRow(RowId: Text; Expected: Text; Actual: Text; var Mismatches: Text)
    begin
        if Expected <> Actual then
            Mismatches += StrSubstNo(RowMismatchTxt, RowId, Expected, Actual);
    end;
}