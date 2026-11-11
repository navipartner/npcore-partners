codeunit 85607 "NPR Library POS Deferral"
{
    var
        _Assert: Codeunit Assert;
        _POSSession: Codeunit "NPR POS Session";
        _POSUnit: Record "NPR POS Unit";
        _POSStore: Record "NPR POS Store";
        _POSPaymentMethod: Record "NPR POS Payment Method";
        _POSPostingProfile: Record "NPR POS Posting Profile";
        _SaleStarted: Boolean;

    procedure EnsureGlobalSetup()
    begin
        EnsureAccountingPeriods();
        EnsureSourceCodeSetup();
    end;

    procedure CreatePOSFixture(CompressionMethod: Integer)
    var
        POSAuditProfile: Record "NPR POS Audit Profile";
        POSSetup: Record "NPR POS Setup";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
    begin
        _POSSession.ClearAll();
        Clear(_POSSession);
        _SaleStarted := false;
        ClearPendingPOSEntries();

        LibraryPOSMasterData.CreatePOSSetup(POSSetup);
        LibraryPOSMasterData.CreateDefaultPostingSetup(_POSPostingProfile);
        _POSPostingProfile."Posting Compression" := CompressionMethod;
        if _POSPostingProfile."Posting Compression" = _POSPostingProfile."Posting Compression"::"Per POS Period" then
            _POSPostingProfile."POS Period Register No. Series" := CreateUniqueNoSeries()
        else
            Clear(_POSPostingProfile."POS Period Register No. Series");
        _POSPostingProfile."Source Code" := CreateSourceCode();
        _POSPostingProfile.Modify();
        LibraryPOSMasterData.CreatePOSStore(_POSStore, _POSPostingProfile.Code);
        LibraryPOSMasterData.CreatePOSUnit(_POSUnit, _POSStore.Code, _POSPostingProfile.Code);
        POSAuditProfile.Get(_POSUnit."POS Audit Profile");
        POSAuditProfile."Sales Ticket No. Series" := CreateUniqueNoSeries();
        POSAuditProfile.Modify();
        LibraryPOSMasterData.CreatePOSPaymentMethod(_POSPaymentMethod, _POSPaymentMethod."Processing Type"::CASH, '', false);
        Commit();
    end;

    procedure GetPOSPostingProfile(var POSPostingProfile: Record "NPR POS Posting Profile")
    begin
        POSPostingProfile.Get(_POSPostingProfile.Code);
    end;

    procedure SalePostingDate(): Date
    begin
        exit(20261013D);
    end;

    procedure DEF2651Code(): Code[10]
    begin
        exit('DEF2651');
    end;

    procedure CreateDEF2651(var DeferralTemplate: Record "Deferral Template")
    begin
        CreateDeferralTemplate(DEF2651Code(), 12, DeferralTemplate);
    end;

    procedure CreateDeferralTemplate(DeferralCode: Code[10]; NoOfPeriods: Integer; var DeferralTemplate: Record "Deferral Template")
    var
        LibraryERM: Codeunit "Library - ERM";
    begin
        if not DeferralTemplate.Get(DeferralCode) then begin
            DeferralTemplate.Init();
            DeferralTemplate."Deferral Code" := DeferralCode;
            DeferralTemplate.Insert();
        end;
        DeferralTemplate.Description := DeferralCode;
        DeferralTemplate."Deferral Account" := LibraryERM.CreateGLAccountNo();
        DeferralTemplate."Deferral %" := 100;
        DeferralTemplate."Calc. Method" := DeferralTemplate."Calc. Method"::"Equal per Period";
        DeferralTemplate."Start Date" := DeferralTemplate."Start Date"::"Beginning of Period";
        DeferralTemplate."No. of Periods" := NoOfPeriods;
        DeferralTemplate."Period Description" := CopyStr(DeferralCode + ' %4', 1, MaxStrLen(DeferralTemplate."Period Description"));
        DeferralTemplate.Modify();
    end;

    procedure CreateItem2651(var Item: Record Item)
    var
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
    begin
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        Item."Unit Price" := 437.50;
        Item."Default Deferral Template Code" := DEF2651Code();
        Item.Modify();
    end;

    procedure CreateItem2(var Item: Record Item)
    var
        GenProductPostingGroup: Record "Gen. Product Posting Group";
        LibraryERM: Codeunit "Library - ERM";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
    begin
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        LibraryERM.CreateGenProdPostingGroup(GenProductPostingGroup);
        GenProductPostingGroup."Def. VAT Prod. Posting Group" := Item."VAT Prod. Posting Group";
        GenProductPostingGroup.Modify();
        Item."Gen. Prod. Posting Group" := GenProductPostingGroup.Code;
        Item."Unit Price" := 125;
        Item."Default Deferral Template Code" := '';
        Item.Modify();
        LibraryPOSMasterData.CreatePostingSetupForSaleItem(Item, _POSUnit, _POSStore);
    end;

    procedure CreateGLDEF(var GLAccount: Record "G/L Account"; Item: Record Item)
    var
        LibraryERM: Codeunit "Library - ERM";
    begin
        GLAccount.Get(LibraryERM.CreateGLAccountNo());
        GLAccount."Direct Posting" := true;
        GLAccount."Gen. Posting Type" := GLAccount."Gen. Posting Type"::Sale;
        GLAccount."Gen. Bus. Posting Group" := _POSPostingProfile."Gen. Bus. Posting Group";
        GLAccount."Gen. Prod. Posting Group" := Item."Gen. Prod. Posting Group";
        GLAccount."VAT Bus. Posting Group" := _POSPostingProfile."VAT Bus. Posting Group";
        GLAccount."VAT Prod. Posting Group" := Item."VAT Prod. Posting Group";
        GLAccount."Default Deferral Template Code" := DEF2651Code();
        GLAccount.Modify();
    end;

    procedure CreateSale(ItemNos: List of [Code[20]]; var POSEntry: Record "NPR POS Entry")
    var
        Item: Record Item;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        ItemNo: Code[20];
        TotalAmount: Decimal;
        SaleEndedLbl: Label 'The POS sale of %1 lines must end when paid %2', Locked = true;
    begin
        if not _SaleStarted then begin
            LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
            _SaleStarted := true;
        end;
        foreach ItemNo in ItemNos do begin
            Item.Get(ItemNo);
            LibraryPOSMock.CreateItemLine(_POSSession, ItemNo, 1);
            TotalAmount += Item."Unit Price";
        end;
        _Assert.IsTrue(LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethod.Code, TotalAmount, '', false), StrSubstNo(SaleEndedLbl, ItemNos.Count(), TotalAmount));

        POSEntry.SetRange("POS Unit No.", _POSUnit."No.");
        POSEntry.SetRange("Entry Type", POSEntry."Entry Type"::"Direct Sale");
        POSEntry.FindLast();
        POSEntry.Reset();
        POSEntry."Posting Date" := SalePostingDate();
        POSEntry."Document Date" := SalePostingDate();
        POSEntry.Modify();
        Commit();
    end;

    procedure CreateSaleOfItem(ItemNo: Code[20]; var POSEntry: Record "NPR POS Entry")
    var
        ItemNos: List of [Code[20]];
    begin
        ItemNos.Add(ItemNo);
        CreateSale(ItemNos, POSEntry);
    end;

    procedure ConvertSalesLineToGLAccount(POSEntry: Record "NPR POS Entry"; GLAccountNo: Code[20])
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
    begin
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesLine.SetRange(Type, POSEntrySalesLine.Type::Item);
        POSEntrySalesLine.FindFirst();
        POSEntrySalesLine.Type := POSEntrySalesLine.Type::"G/L Account";
        POSEntrySalesLine."No." := GLAccountNo;
        POSEntrySalesLine.Modify();
    end;

    procedure FindSalesLine(POSEntry: Record "NPR POS Entry"; No: Code[20]; var POSEntrySalesLine: Record "NPR POS Entry Sales Line")
    begin
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesLine.SetRange("No.", No);
        POSEntrySalesLine.FindFirst();
        POSEntrySalesLine.Reset();
    end;

    procedure GetSalesAccount(POSEntrySalesLine: Record "NPR POS Entry Sales Line"): Code[20]
    var
        GeneralPostingSetup: Record "General Posting Setup";
    begin
        if POSEntrySalesLine.Type = POSEntrySalesLine.Type::"G/L Account" then
            exit(POSEntrySalesLine."No.");
        GeneralPostingSetup.Get(POSEntrySalesLine."Gen. Bus. Posting Group", POSEntrySalesLine."Gen. Prod. Posting Group");
        GeneralPostingSetup.TestField("Sales Account");
        exit(GeneralPostingSetup."Sales Account");
    end;

    procedure GetPeriodRegisterDocumentNo(POSEntry: Record "NPR POS Entry"): Code[20]
    var
        POSPeriodRegister: Record "NPR POS Period Register";
    begin
        POSPeriodRegister.Get(POSEntry."POS Period Register No.");
        POSPeriodRegister.TestField("Document No.");
        exit(POSPeriodRegister."Document No.");
    end;

    procedure SetFailureCauseC1(POSEntry: Record "NPR POS Entry"; var DefaultDimension: Record "Default Dimension")
    var
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
        POSPostingSetup: Record "NPR POS Posting Setup";
        POSPostEntries: Codeunit "NPR POS Post Entries";
        NoPostingSetupLbl: Label 'A POS posting setup must exist for payment method %1 of receipt %2', Locked = true;
    begin
        POSEntryPaymentLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntryPaymentLine.FindFirst();
        _Assert.IsTrue(
            POSPostEntries.GetPostingSetup(POSEntryPaymentLine."POS Store Code", POSEntryPaymentLine."POS Payment Method Code", POSEntryPaymentLine."POS Payment Bin Code", POSPostingSetup),
            StrSubstNo(NoPostingSetupLbl, POSEntryPaymentLine."POS Payment Method Code", POSEntry."Document No."));
        case POSPostingSetup."Account Type" of
            POSPostingSetup."Account Type"::"G/L Account":
                SetMandatoryDimension(Database::"G/L Account", POSPostingSetup."Account No.", DefaultDimension);
            POSPostingSetup."Account Type"::"Bank Account":
                SetMandatoryDimension(Database::"Bank Account", POSPostingSetup."Account No.", DefaultDimension);
            POSPostingSetup."Account Type"::Customer:
                SetMandatoryDimension(Database::Customer, POSPostingSetup."Account No.", DefaultDimension);
        end;
    end;

    procedure SetMandatoryDimension(TableID: Integer; No: Code[20]; var DefaultDimension: Record "Default Dimension")
    var
        Dimension: Record Dimension;
        LibraryDimension: Codeunit "Library - Dimension";
    begin
        LibraryDimension.CreateDimension(Dimension);
        LibraryDimension.CreateDefaultDimension(DefaultDimension, TableID, No, Dimension.Code, '');
        DefaultDimension."Value Posting" := DefaultDimension."Value Posting"::"Code Mandatory";
        DefaultDimension.Modify();
    end;

    procedure RemoveFailureCause(DefaultDimension: Record "Default Dimension")
    begin
        DefaultDimension.Get(DefaultDimension."Table ID", DefaultDimension."No.", DefaultDimension."Dimension Code");
        DefaultDimension.Delete();
    end;

    procedure SetGLAccountBlocked(GLAccountNo: Code[20]; Blocked: Boolean)
    var
        GLAccount: Record "G/L Account";
    begin
        GLAccount.Get(GLAccountNo);
        GLAccount.Blocked := Blocked;
        GLAccount.Modify();
    end;

    procedure SetProfileSourceCodeToGeneralJournal()
    var
        SourceCodeSetup: Record "Source Code Setup";
    begin
        SourceCodeSetup.Get();
        SourceCodeSetup.TestField("General Journal");
        SetProfileSourceCode(SourceCodeSetup."General Journal");
    end;

    procedure RunNightlyJob()
    var
        PostGLEntriesJQ: Codeunit "NPR POS Post GL Entries JQ";
    begin
        Commit();
        PostGLEntriesJQ.Run();
    end;

    procedure RunPostAction(POSEntry: Record "NPR POS Entry")
    var
        POSEntryToPost: Record "NPR POS Entry";
        POSPostEntries: Codeunit "NPR POS Post Entries";
    begin
        POSEntryToPost.SetRange("Entry No.", POSEntry."Entry No.");
        POSPostEntries.SetPostPOSEntries(true);
        POSPostEntries.SetStopOnError(true);
        POSPostEntries.SetPostCompressed(false);
        Commit();
        POSPostEntries.Run(POSEntryToPost);
    end;

    procedure RepostFromPOSPostingLog(POSPostingLogEntryNo: Integer)
    var
        POSPostingLog: Record "NPR POS Posting Log";
        POSPostEntries: Codeunit "NPR POS Post Entries";
    begin
        POSPostingLog.Get(POSPostingLogEntryNo);
        Commit();
        POSPostEntries.PostFromPOSPostingLog(POSPostingLog);
    end;

    procedure PostInvoiceI1(Item: Record Item; PostingDate: Date): Code[20]
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        LibrarySales: Codeunit "Library - Sales";
    begin
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Gen. Bus. Posting Group", _POSPostingProfile."Gen. Bus. Posting Group");
        Customer.Validate("VAT Bus. Posting Group", _POSPostingProfile."VAT Bus. Posting Group");
        Customer.Modify(true);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, Customer."No.");
        SalesHeader.Validate("Posting Date", PostingDate);
        SalesHeader.Validate("Prices Including VAT", false);
        SalesHeader.Modify(true);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", 1);
        SalesLine.Validate("Unit Price", 350);
        SalesLine.Modify(true);
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    procedure InsertOldRowsOfFailedRun(DocumentNo: Code[20]; DeferralLineNo: Integer; RevenueAccountNo: Code[20]; DeferralAccountNo: Code[20]; NoOfSaleLines: Integer; NoOfMergedInvoices: Integer)
    var
        Dates: List of [Date];
        Amounts: List of [Decimal];
        MergedDates: List of [Date];
        MergedAmounts: List of [Decimal];
        Amount: Decimal;
        i: Integer;
    begin
        InsertDeferralBufferRow(Enum::"Deferral Document Type"::Sales, DocumentNo, DeferralLineNo, SalePostingDate(), DeferralAccountNo, RevenueAccountNo, -350 * NoOfSaleLines, true);
        GetG1Schedule(NoOfSaleLines, Dates, Amounts);
        GetG2Schedule(MergedDates, MergedAmounts);
        for i := 1 to Dates.Count() do begin
            Amount := Amounts.Get(i);
            if i > 1 then
                Amount += MergedAmounts.Get(i) * NoOfMergedInvoices;
            InsertDeferralBufferRow(Enum::"Deferral Document Type"::Sales, DocumentNo, DeferralLineNo, Dates.Get(i), RevenueAccountNo, DeferralAccountNo, -Amount, false);
        end;
    end;

    procedure InsertDeferralBufferRow(DeferralDocType: Enum "Deferral Document Type"; DocumentNo: Code[20]; DeferralLineNo: Integer; PostingDate: Date; GLAccountNo: Code[20]; DeferralAccountNo: Code[20]; Amount: Decimal; PartialDeferral: Boolean)
    var
        DeferralPostingBuffer: Record "Deferral Posting Buffer";
    begin
        DeferralPostingBuffer.Init();
        DeferralPostingBuffer.Type := DeferralPostingBuffer.Type::Item;
        DeferralPostingBuffer."System-Created Entry" := true;
        DeferralPostingBuffer."Deferral Code" := DEF2651Code();
        DeferralPostingBuffer."Deferral Doc. Type" := DeferralDocType;
        DeferralPostingBuffer."Document No." := DocumentNo;
        DeferralPostingBuffer."Deferral Line No." := DeferralLineNo;
        DeferralPostingBuffer."Posting Date" := PostingDate;
        DeferralPostingBuffer."G/L Account" := GLAccountNo;
        DeferralPostingBuffer."Deferral Account" := DeferralAccountNo;
        DeferralPostingBuffer.Amount := Amount;
        DeferralPostingBuffer."Amount (LCY)" := Amount;
        DeferralPostingBuffer."Sales/Purch Amount" := Amount;
        DeferralPostingBuffer."Sales/Purch Amount (LCY)" := Amount;
        DeferralPostingBuffer."Partial Deferral" := PartialDeferral;
        DeferralPostingBuffer.SetRange("Deferral Doc. Type", DeferralDocType);
        DeferralPostingBuffer.SetRange("Document No.", DocumentNo);
        DeferralPostingBuffer.Update(DeferralPostingBuffer);
    end;

    procedure CountDeferralBufferRows(DocumentNo: Code[20]): Integer
    var
        DeferralPostingBuffer: Record "Deferral Posting Buffer";
    begin
        DeferralPostingBuffer.SetRange("Deferral Doc. Type", Enum::"Deferral Document Type"::Sales);
        DeferralPostingBuffer.SetRange("Document No.", DocumentNo);
        exit(DeferralPostingBuffer.Count());
    end;

    procedure OpenScheduleExists(POSEntrySalesLine: Record "NPR POS Entry Sales Line"): Boolean
    var
        DeferralHeader: Record "Deferral Header";
    begin
        exit(DeferralHeader.Get(Enum::"Deferral Document Type"::"G/L", '', '', Database::"NPR POS Entry Sales Line", Format(POSEntrySalesLine."POS Entry No."), POSEntrySalesLine."Line No."));
    end;

    procedure GetG1Schedule(Multiplier: Integer; var Dates: List of [Date]; var Amounts: List of [Decimal])
    var
        i: Integer;
    begin
        Clear(Dates);
        Clear(Amounts);
        Dates.Add(SalePostingDate());
        Amounts.Add(29.17 * Multiplier);
        for i := 0 to 9 do begin
            Dates.Add(CalcDate(StrSubstNo('<%1M>', i), 20261101D));
            Amounts.Add(29.17 * Multiplier);
        end;
        Dates.Add(20270901D);
        Amounts.Add(29.13 * Multiplier);
    end;

    procedure GetG2Schedule(var Dates: List of [Date]; var Amounts: List of [Decimal])
    var
        i: Integer;
    begin
        Clear(Dates);
        Clear(Amounts);
        for i := 0 to 10 do begin
            Dates.Add(CalcDate(StrSubstNo('<%1M>', i), 20261001D));
            Amounts.Add(29.17);
        end;
        Dates.Add(20270901D);
        Amounts.Add(29.13);
    end;

    procedure GetS6Schedule(var Dates: List of [Date]; var Amounts: List of [Decimal])
    var
        i: Integer;
    begin
        Clear(Dates);
        Clear(Amounts);
        Dates.Add(SalePostingDate());
        Dates.Add(20261101D);
        Dates.Add(20261201D);
        for i := 0 to 4 do
            Dates.Add(CalcDate(StrSubstNo('<%1M>', i), 20270401D));
        for i := 1 to 8 do
            Amounts.Add(38.89);
        Dates.Add(20270901D);
        Amounts.Add(38.88);
    end;

    procedure GetDeferralGLMismatches(RowId: Text; DocumentNo: Code[20]; RevenueAccountNo: Code[20]; DeferralAccountNo: Code[20]; PostingDate: Date; InitialAmount: Decimal; RevenueAmount: Decimal; Dates: List of [Date]; Amounts: List of [Decimal]): Text
    var
        DeferralCredit: Dictionary of [Date, Decimal];
        DeferralDebit: Dictionary of [Date, Decimal];
        RevenueCredit: Dictionary of [Date, Decimal];
        RevenueDebit: Dictionary of [Date, Decimal];
        DeferralCount: Integer;
        RevenueCount: Integer;
        i: Integer;
    begin
        if InitialAmount <> 0 then begin
            AddAmount(DeferralCredit, PostingDate, InitialAmount);
            AddAmount(RevenueDebit, PostingDate, InitialAmount);
            DeferralCount += 1;
            RevenueCount += 1;
        end;
        for i := 1 to Dates.Count() do begin
            AddAmount(DeferralDebit, Dates.Get(i), Amounts.Get(i));
            AddAmount(RevenueCredit, Dates.Get(i), Amounts.Get(i));
        end;
        DeferralCount += Dates.Count();
        RevenueCount += Dates.Count();
        if RevenueAmount <> 0 then begin
            AddAmount(RevenueCredit, PostingDate, RevenueAmount);
            RevenueCount += 1;
        end;
        exit(
            GetAccountMismatches(RowId, 'deferral account', DocumentNo, DeferralAccountNo, DeferralDebit, DeferralCredit, DeferralCount) +
            GetAccountMismatches(RowId, 'revenue account', DocumentNo, RevenueAccountNo, RevenueDebit, RevenueCredit, RevenueCount));
    end;

    procedure GetG1Mismatches(RowId: Text; DocumentNo: Code[20]; RevenueAccountNo: Code[20]; DeferralAccountNo: Code[20]; Multiplier: Integer): Text
    var
        Dates: List of [Date];
        Amounts: List of [Decimal];
    begin
        GetG1Schedule(Multiplier, Dates, Amounts);
        exit(GetDeferralGLMismatches(RowId, DocumentNo, RevenueAccountNo, DeferralAccountNo, SalePostingDate(), 350 * Multiplier, 350 * Multiplier, Dates, Amounts));
    end;

    procedure GetG2Mismatches(RowId: Text; InvoiceNo: Code[20]; PostingDate: Date; RevenueAccountNo: Code[20]; DeferralAccountNo: Code[20]): Text
    var
        Dates: List of [Date];
        Amounts: List of [Decimal];
    begin
        GetG2Schedule(Dates, Amounts);
        exit(GetDeferralGLMismatches(RowId, InvoiceNo, RevenueAccountNo, DeferralAccountNo, PostingDate, 350, 350, Dates, Amounts));
    end;

    procedure GetPostedScheduleMismatches(RowId: Text; POSEntrySalesLine: Record "NPR POS Entry Sales Line"; DeferralCode: Code[10]; Dates: List of [Date]; Amounts: List of [Decimal]) Mismatches: Text
    var
        PostedDeferralHeader: Record "Posted Deferral Header";
        PostedDeferralLine: Record "Posted Deferral Line";
        CurrentLine: Record "NPR POS Entry Sales Line";
        i: Integer;
        NoPostedScheduleLbl: Label '%1: no posted deferral schedule for POS entry %2 line %3; ', Locked = true;
        PostedCodeLbl: Label '%1: posted schedule template code expected %2, actual %3; ', Locked = true;
        PostedCountLbl: Label '%1: posted schedule lines expected %2, actual %3; ', Locked = true;
        PostedLineLbl: Label '%1: posted schedule line %2 expected %3 %4, actual %5 %6; ', Locked = true;
        OpenScheduleLbl: Label '%1: the open deferral schedule of POS entry %2 line %3 still exists; ', Locked = true;
        LineCodeLbl: Label '%1: POS entry sales line deferral code expected %2, actual %3; ', Locked = true;
    begin
        if OpenScheduleExists(POSEntrySalesLine) then
            Mismatches += StrSubstNo(OpenScheduleLbl, RowId, POSEntrySalesLine."POS Entry No.", POSEntrySalesLine."Line No.");
        CurrentLine.Get(POSEntrySalesLine."POS Entry No.", POSEntrySalesLine."Line No.");
        if CurrentLine."Deferral Code" <> DeferralCode then
            Mismatches += StrSubstNo(LineCodeLbl, RowId, DeferralCode, CurrentLine."Deferral Code");
        if not PostedDeferralHeader.Get(Enum::"Deferral Document Type"::"G/L", '', '', Database::"NPR POS Entry Sales Line", Format(POSEntrySalesLine."POS Entry No."), POSEntrySalesLine."Line No.") then
            exit(Mismatches + StrSubstNo(NoPostedScheduleLbl, RowId, POSEntrySalesLine."POS Entry No.", POSEntrySalesLine."Line No."));
        if PostedDeferralHeader."Deferral Code" <> DeferralCode then
            Mismatches += StrSubstNo(PostedCodeLbl, RowId, DeferralCode, PostedDeferralHeader."Deferral Code");
        PostedDeferralLine.SetRange("Deferral Doc. Type", Enum::"Deferral Document Type"::"G/L");
        PostedDeferralLine.SetRange("Gen. Jnl. Document No.", '');
        PostedDeferralLine.SetRange("Account No.", '');
        PostedDeferralLine.SetRange("Document Type", Database::"NPR POS Entry Sales Line");
        PostedDeferralLine.SetRange("Document No.", Format(POSEntrySalesLine."POS Entry No."));
        PostedDeferralLine.SetRange("Line No.", POSEntrySalesLine."Line No.");
        if PostedDeferralLine.Count() <> Dates.Count() then
            Mismatches += StrSubstNo(PostedCountLbl, RowId, Dates.Count(), PostedDeferralLine.Count());
        if PostedDeferralLine.FindSet() then
            repeat
                i += 1;
                if i <= Dates.Count() then
                    if (PostedDeferralLine."Posting Date" <> Dates.Get(i)) or (PostedDeferralLine.Amount <> Amounts.Get(i)) then
                        Mismatches += StrSubstNo(PostedLineLbl, RowId, i, Dates.Get(i), Amounts.Get(i), PostedDeferralLine."Posting Date", PostedDeferralLine.Amount);
            until PostedDeferralLine.Next() = 0;
    end;

    procedure GetStatusMismatch(RowId: Text; POSEntryNo: Integer; ExpectedStatus: Integer): Text
    var
        ExpectedPOSEntry: Record "NPR POS Entry";
        POSEntry: Record "NPR POS Entry";
        StatusLbl: Label '%1: receipt %2 status expected %3, actual %4; ', Locked = true;
    begin
        POSEntry.Get(POSEntryNo);
        ExpectedPOSEntry."Post Entry Status" := ExpectedStatus;
        if POSEntry."Post Entry Status" <> ExpectedPOSEntry."Post Entry Status" then
            exit(StrSubstNo(StatusLbl, RowId, POSEntry."Document No.", ExpectedPOSEntry."Post Entry Status", POSEntry."Post Entry Status"));
    end;

    procedure GetNoRowsMismatch(RowId: Text; DocumentNo: Code[20]): Text
    var
        RowsLbl: Label '%1: table 1706 Sales rows of %2 expected 0, actual %3; ', Locked = true;
    begin
        if CountDeferralBufferRows(DocumentNo) <> 0 then
            exit(StrSubstNo(RowsLbl, RowId, DocumentNo, CountDeferralBufferRows(DocumentNo)));
    end;

    procedure GetNoGLEntriesAnyDateMismatch(RowId: Text; DocumentNo: Code[20]): Text
    var
        GLEntry: Record "G/L Entry";
        GLEntriesLbl: Label '%1: G/L entries of %2 on any date expected 0, actual %3; ', Locked = true;
    begin
        GLEntry.SetRange("Document No.", DocumentNo);
        if not GLEntry.IsEmpty() then
            exit(StrSubstNo(GLEntriesLbl, RowId, DocumentNo, GLEntry.Count()));
    end;

    procedure GetNoEntryOnDateMismatch(RowId: Text; DocumentNo: Code[20]; AccountNo: Code[20]; PostingDate: Date): Text
    var
        GLEntry: Record "G/L Entry";
        DateEntriesLbl: Label '%1: G/L entries of %2 on account %3 on %4 expected 0, actual %5; ', Locked = true;
    begin
        GLEntry.SetRange("Document No.", DocumentNo);
        GLEntry.SetRange("G/L Account No.", AccountNo);
        GLEntry.SetRange("Posting Date", PostingDate);
        if not GLEntry.IsEmpty() then
            exit(StrSubstNo(DateEntriesLbl, RowId, DocumentNo, AccountNo, PostingDate, GLEntry.Count()));
    end;

    procedure FailWithC1(POSEntry: Record "NPR POS Entry"; var C1: Record "Default Dimension")
    begin
        SetFailureCauseC1(POSEntry, C1);
        RunNightlyJob();
        AssertUnpostedAfterFailedRun(POSEntry);
    end;

    procedure AssertUnpostedAfterFailedRun(POSEntry: Record "NPR POS Entry")
    begin
        _Assert.AreEqual('', GetStatusMismatch('failed run', POSEntry."Entry No.", POSEntry."Post Entry Status"::Unposted), 'The failed run leaves the receipt Unposted');
    end;

    procedure GetPostedSaleMismatches(RowId: Text; POSEntry: Record "NPR POS Entry"; SalesLineNo: Code[20]; DeferralAccountNo: Code[20]): Text
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        RevenueAccountNo: Code[20];
        Amounts: List of [Decimal];
        Dates: List of [Date];
    begin
        FindSalesLine(POSEntry, SalesLineNo, POSEntrySalesLine);
        GetG1Schedule(1, Dates, Amounts);
        RevenueAccountNo := GetSalesAccount(POSEntrySalesLine);
        exit(
            GetStatusMismatch(RowId, POSEntry."Entry No.", POSEntry."Post Entry Status"::Posted) +
            GetG1Mismatches(RowId, POSEntry."Document No.", RevenueAccountNo, DeferralAccountNo, 1) +
            GetG1EntryMismatches(RowId, POSEntry."Document No.", RevenueAccountNo, DeferralAccountNo, 1) +
            GetPostedScheduleMismatches(RowId, POSEntrySalesLine, DEF2651Code(), Dates, Amounts) +
            GetOpenScheduleGoneMismatch(RowId, POSEntrySalesLine) +
            GetNoRowsMismatch(RowId, POSEntry."Document No."));
    end;

    procedure GetPeriodPostMismatches(RowId: Text; POSEntry1: Record "NPR POS Entry"; POSEntry2: Record "NPR POS Entry"; ItemNo: Code[20]; DeferralAccountNo: Code[20]): Text
    var
        POSEntrySalesLine1: Record "NPR POS Entry Sales Line";
        POSEntrySalesLine2: Record "NPR POS Entry Sales Line";
        RegisterDocumentNo: Code[20];
        RevenueAccountNo: Code[20];
        Amounts: List of [Decimal];
        Dates: List of [Date];
    begin
        FindSalesLine(POSEntry1, ItemNo, POSEntrySalesLine1);
        FindSalesLine(POSEntry2, ItemNo, POSEntrySalesLine2);
        GetG1Schedule(1, Dates, Amounts);
        RegisterDocumentNo := GetPeriodRegisterDocumentNo(POSEntry1);
        RevenueAccountNo := GetSalesAccount(POSEntrySalesLine1);
        exit(
            GetStatusMismatch(RowId, POSEntry1."Entry No.", POSEntry1."Post Entry Status"::Posted) +
            GetStatusMismatch(RowId, POSEntry2."Entry No.", POSEntry2."Post Entry Status"::Posted) +
            GetG1Mismatches(RowId, RegisterDocumentNo, RevenueAccountNo, DeferralAccountNo, 2) +
            GetG1EntryMismatches(RowId, RegisterDocumentNo, RevenueAccountNo, DeferralAccountNo, 2) +
            GetPostedScheduleMismatches(RowId, POSEntrySalesLine1, DEF2651Code(), Dates, Amounts) +
            GetOpenScheduleGoneMismatch(RowId, POSEntrySalesLine1) +
            GetPostedScheduleMismatches(RowId, POSEntrySalesLine2, DEF2651Code(), Dates, Amounts) +
            GetOpenScheduleGoneMismatch(RowId, POSEntrySalesLine2) +
            GetNoAccountEntriesMismatch(RowId, POSEntry1."Document No.", RevenueAccountNo) +
            GetNoAccountEntriesMismatch(RowId, POSEntry1."Document No.", DeferralAccountNo) +
            GetNoAccountEntriesMismatch(RowId, POSEntry2."Document No.", RevenueAccountNo) +
            GetNoAccountEntriesMismatch(RowId, POSEntry2."Document No.", DeferralAccountNo) +
            GetNoRowsMismatch(RowId, POSEntry1."Document No.") +
            GetNoRowsMismatch(RowId, POSEntry2."Document No.") +
            GetNoRowsMismatch(RowId, RegisterDocumentNo));
    end;

    procedure GetNoAccountEntriesMismatch(RowId: Text; DocumentNo: Code[20]; AccountNo: Code[20]): Text
    var
        GLEntry: Record "G/L Entry";
        AccountEntriesLbl: Label '%1: G/L entries of %2 on account %3 expected 0, actual %4; ', Locked = true;
    begin
        GLEntry.SetRange("Document No.", DocumentNo);
        GLEntry.SetRange("G/L Account No.", AccountNo);
        if not GLEntry.IsEmpty() then
            exit(StrSubstNo(AccountEntriesLbl, RowId, DocumentNo, AccountNo, GLEntry.Count()));
    end;

    procedure GetRowsSnapshot(DeferralDocType: Enum "Deferral Document Type"; DocumentNo: Code[20]) Snapshot: Text
    var
        DeferralPostingBuffer: Record "Deferral Posting Buffer";
        FieldRef: FieldRef;
        RecordRef: RecordRef;
        i: Integer;
    begin
        DeferralPostingBuffer.SetRange("Deferral Doc. Type", DeferralDocType);
        DeferralPostingBuffer.SetRange("Document No.", DocumentNo);
        if DeferralPostingBuffer.FindSet() then
            repeat
                RecordRef.GetTable(DeferralPostingBuffer);
                for i := 1 to RecordRef.FieldCount() do begin
                    FieldRef := RecordRef.FieldIndex(i);
                    if FieldRef.Class = FieldClass::Normal then
                        Snapshot += Format(FieldRef.Number) + '=' + Format(FieldRef.Value, 0, 9) + '|';
                end;
                Snapshot += '; ';
            until DeferralPostingBuffer.Next() = 0;
    end;

    procedure GetDeferralGLEntryMismatches(RowId: Text; DocumentNo: Code[20]; RevenueAccountNo: Code[20]; DeferralAccountNo: Code[20]; PostingDate: Date; InitialAmount: Decimal; RevenueAmount: Decimal; Dates: List of [Date]; Amounts: List of [Decimal]): Text
    var
        DeferralEntries: Dictionary of [Text, Integer];
        RevenueEntries: Dictionary of [Text, Integer];
        i: Integer;
    begin
        if InitialAmount <> 0 then begin
            AddEntry(DeferralEntries, PostingDate, -InitialAmount);
            AddEntry(RevenueEntries, PostingDate, InitialAmount);
        end;
        for i := 1 to Dates.Count() do begin
            AddEntry(DeferralEntries, Dates.Get(i), Amounts.Get(i));
            AddEntry(RevenueEntries, Dates.Get(i), -Amounts.Get(i));
        end;
        if RevenueAmount <> 0 then
            AddEntry(RevenueEntries, PostingDate, -RevenueAmount);
        exit(
            GetAccountEntryMismatches(RowId, 'deferral account', DocumentNo, DeferralAccountNo, DeferralEntries) +
            GetAccountEntryMismatches(RowId, 'revenue account', DocumentNo, RevenueAccountNo, RevenueEntries));
    end;

    procedure GetG1EntryMismatches(RowId: Text; DocumentNo: Code[20]; RevenueAccountNo: Code[20]; DeferralAccountNo: Code[20]; Multiplier: Integer): Text
    var
        Dates: List of [Date];
        Amounts: List of [Decimal];
    begin
        GetG1Schedule(Multiplier, Dates, Amounts);
        exit(GetDeferralGLEntryMismatches(RowId, DocumentNo, RevenueAccountNo, DeferralAccountNo, SalePostingDate(), 350 * Multiplier, 350 * Multiplier, Dates, Amounts));
    end;

    procedure GetOpenScheduleGoneMismatch(RowId: Text; POSEntrySalesLine: Record "NPR POS Entry Sales Line") Mismatches: Text
    var
        DeferralLine: Record "Deferral Line";
        OpenHeaderLbl: Label '%1: the open deferral header of POS entry %2 line %3 still exists; ', Locked = true;
        OpenLinesLbl: Label '%1: %2 open deferral lines of POS entry %3 line %4 still exist; ', Locked = true;
    begin
        if OpenScheduleExists(POSEntrySalesLine) then
            Mismatches += StrSubstNo(OpenHeaderLbl, RowId, POSEntrySalesLine."POS Entry No.", POSEntrySalesLine."Line No.");
        FilterOpenScheduleLines(POSEntrySalesLine, DeferralLine);
        if not DeferralLine.IsEmpty() then
            Mismatches += StrSubstNo(OpenLinesLbl, RowId, DeferralLine.Count(), POSEntrySalesLine."POS Entry No.", POSEntrySalesLine."Line No.");
    end;

    procedure GetOpenScheduleMismatches(RowId: Text; POSEntrySalesLine: Record "NPR POS Entry Sales Line"; DeferralCode: Code[10]; Dates: List of [Date]; Amounts: List of [Decimal]) Mismatches: Text
    var
        DeferralHeader: Record "Deferral Header";
        DeferralLine: Record "Deferral Line";
        i: Integer;
        NoOpenScheduleLbl: Label '%1: the open schedule of POS entry %2 line %3 no longer exists; ', Locked = true;
        OpenCodeLbl: Label '%1: open schedule template code expected %2, actual %3; ', Locked = true;
        OpenCountLbl: Label '%1: open schedule lines expected %2, actual %3; ', Locked = true;
        OpenLineLbl: Label '%1: open schedule line %2 expected %3 %4, actual %5 %6; ', Locked = true;
    begin
        if not DeferralHeader.Get(Enum::"Deferral Document Type"::"G/L", '', '', Database::"NPR POS Entry Sales Line", Format(POSEntrySalesLine."POS Entry No."), POSEntrySalesLine."Line No.") then
            exit(StrSubstNo(NoOpenScheduleLbl, RowId, POSEntrySalesLine."POS Entry No.", POSEntrySalesLine."Line No."));
        if DeferralHeader."Deferral Code" <> DeferralCode then
            Mismatches += StrSubstNo(OpenCodeLbl, RowId, DeferralCode, DeferralHeader."Deferral Code");
        FilterOpenScheduleLines(POSEntrySalesLine, DeferralLine);
        if DeferralLine.Count() <> Dates.Count() then
            Mismatches += StrSubstNo(OpenCountLbl, RowId, Dates.Count(), DeferralLine.Count());
        if DeferralLine.FindSet() then
            repeat
                i += 1;
                if i <= Dates.Count() then
                    if (DeferralLine."Posting Date" <> Dates.Get(i)) or (DeferralLine.Amount <> Amounts.Get(i)) then
                        Mismatches += StrSubstNo(OpenLineLbl, RowId, i, Dates.Get(i), Amounts.Get(i), DeferralLine."Posting Date", DeferralLine.Amount);
            until DeferralLine.Next() = 0;
    end;

    procedure GetMandatoryDimensionErrorText(DefaultDimension: Record "Default Dimension"): Text
    var
        RecRef: RecordRef;
        MandatoryDimensionLbl: Label 'Select a %1 for the %2 %3 for %4 %5.', Locked = true;
    begin
        RecRef.Open(DefaultDimension."Table ID");
        exit(StrSubstNo(MandatoryDimensionLbl, DefaultDimension.FieldCaption("Dimension Value Code"), DefaultDimension.FieldCaption("Dimension Code"), DefaultDimension."Dimension Code", RecRef.Caption(), DefaultDimension."No."));
    end;

    procedure SetProfileSourceCode(SourceCode: Code[10])
    begin
        _POSPostingProfile.Get(_POSPostingProfile.Code);
        _POSPostingProfile."Source Code" := SourceCode;
        _POSPostingProfile.Modify();
    end;

    procedure SetGeneralJournalSourceCode(SourceCode: Code[10]) OldSourceCode: Code[10]
    var
        SourceCodeSetup: Record "Source Code Setup";
    begin
        SourceCodeSetup.Get();
        OldSourceCode := SourceCodeSetup."General Journal";
        SourceCodeSetup."General Journal" := SourceCode;
        SourceCodeSetup.Modify();
    end;

    local procedure FilterOpenScheduleLines(POSEntrySalesLine: Record "NPR POS Entry Sales Line"; var DeferralLine: Record "Deferral Line")
    begin
        DeferralLine.SetRange("Deferral Doc. Type", Enum::"Deferral Document Type"::"G/L");
        DeferralLine.SetRange("Gen. Jnl. Template Name", '');
        DeferralLine.SetRange("Gen. Jnl. Batch Name", '');
        DeferralLine.SetRange("Document Type", Database::"NPR POS Entry Sales Line");
        DeferralLine.SetRange("Document No.", Format(POSEntrySalesLine."POS Entry No."));
        DeferralLine.SetRange("Line No.", POSEntrySalesLine."Line No.");
    end;

    local procedure GetAccountEntryMismatches(RowId: Text; AccountRole: Text; DocumentNo: Code[20]; AccountNo: Code[20]; ExpectedEntries: Dictionary of [Text, Integer]) Mismatches: Text
    var
        GLEntry: Record "G/L Entry";
        ActualEntries: Dictionary of [Text, Integer];
        EntryKey: Text;
        ActualCount: Integer;
        EntryLbl: Label '%1: G/L entries of %2 on the %3 %4 with date and amount %5 expected %6, actual %7; ', Locked = true;
    begin
        GLEntry.SetRange("Document No.", DocumentNo);
        GLEntry.SetRange("G/L Account No.", AccountNo);
        if GLEntry.FindSet() then
            repeat
                AddEntry(ActualEntries, GLEntry."Posting Date", GLEntry.Amount);
            until GLEntry.Next() = 0;
        foreach EntryKey in ExpectedEntries.Keys() do begin
            ActualCount := 0;
            if ActualEntries.ContainsKey(EntryKey) then
                ActualCount := ActualEntries.Get(EntryKey);
            if ActualCount <> ExpectedEntries.Get(EntryKey) then
                Mismatches += StrSubstNo(EntryLbl, RowId, DocumentNo, AccountRole, AccountNo, EntryKey, ExpectedEntries.Get(EntryKey), ActualCount);
        end;
        foreach EntryKey in ActualEntries.Keys() do
            if not ExpectedEntries.ContainsKey(EntryKey) then
                Mismatches += StrSubstNo(EntryLbl, RowId, DocumentNo, AccountRole, AccountNo, EntryKey, 0, ActualEntries.Get(EntryKey));
    end;

    local procedure AddEntry(var Entries: Dictionary of [Text, Integer]; PostingDate: Date; Amount: Decimal)
    var
        EntryKey: Text;
        EntryKeyLbl: Label '%1 %2', Locked = true;
    begin
        EntryKey := StrSubstNo(EntryKeyLbl, Format(PostingDate, 0, 9), Format(Amount, 0, 9));
        if Entries.ContainsKey(EntryKey) then
            Entries.Set(EntryKey, Entries.Get(EntryKey) + 1)
        else
            Entries.Add(EntryKey, 1);
    end;

    local procedure GetAccountMismatches(RowId: Text; AccountRole: Text; DocumentNo: Code[20]; AccountNo: Code[20]; ExpectedDebit: Dictionary of [Date, Decimal]; ExpectedCredit: Dictionary of [Date, Decimal]; ExpectedCount: Integer) Mismatches: Text
    var
        GLEntry: Record "G/L Entry";
        Dates: List of [Date];
        PostingDate: Date;
        ExpectedAmount: Decimal;
        CountLbl: Label '%1: G/L entries of %2 on the %3 %4 expected %5, actual %6; ', Locked = true;
        AmountLbl: Label '%1: %2 of %3 on the %4 %5 on %6 expected %7, actual %8; ', Locked = true;
    begin
        GLEntry.SetRange("Document No.", DocumentNo);
        GLEntry.SetRange("G/L Account No.", AccountNo);
        if GLEntry.Count() <> ExpectedCount then
            Mismatches += StrSubstNo(CountLbl, RowId, DocumentNo, AccountRole, AccountNo, ExpectedCount, GLEntry.Count());
        foreach PostingDate in ExpectedDebit.Keys() do
            Dates.Add(PostingDate);
        foreach PostingDate in ExpectedCredit.Keys() do
            if not Dates.Contains(PostingDate) then
                Dates.Add(PostingDate);
        foreach PostingDate in Dates do begin
            GLEntry.SetRange("Posting Date", PostingDate);
            GLEntry.CalcSums("Debit Amount", "Credit Amount");
            ExpectedAmount := 0;
            if ExpectedDebit.ContainsKey(PostingDate) then
                ExpectedAmount := ExpectedDebit.Get(PostingDate);
            if GLEntry."Debit Amount" <> ExpectedAmount then
                Mismatches += StrSubstNo(AmountLbl, RowId, 'debit', DocumentNo, AccountRole, AccountNo, PostingDate, ExpectedAmount, GLEntry."Debit Amount");
            ExpectedAmount := 0;
            if ExpectedCredit.ContainsKey(PostingDate) then
                ExpectedAmount := ExpectedCredit.Get(PostingDate);
            if GLEntry."Credit Amount" <> ExpectedAmount then
                Mismatches += StrSubstNo(AmountLbl, RowId, 'credit', DocumentNo, AccountRole, AccountNo, PostingDate, ExpectedAmount, GLEntry."Credit Amount");
        end;
    end;

    local procedure AddAmount(var Amounts: Dictionary of [Date, Decimal]; PostingDate: Date; Amount: Decimal)
    begin
        if Amounts.ContainsKey(PostingDate) then
            Amounts.Set(PostingDate, Amounts.Get(PostingDate) + Amount)
        else
            Amounts.Add(PostingDate, Amount);
    end;

    local procedure ClearPendingPOSEntries()
    var
        POSEntry: Record "NPR POS Entry";
    begin
        POSEntry.SetRange("Post Entry Status", POSEntry."Post Entry Status"::Unposted, POSEntry."Post Entry Status"::"Error while Posting");
        if not POSEntry.IsEmpty() then
            POSEntry.DeleteAll();
    end;

    local procedure EnsureAccountingPeriods()
    var
        AccountingPeriod: Record "Accounting Period";
        StartingDate: Date;
        i: Integer;
    begin
        for i := 0 to 35 do begin
            StartingDate := CalcDate(StrSubstNo('<%1M>', i), 20260101D);
            if not AccountingPeriod.Get(StartingDate) then begin
                AccountingPeriod.Init();
                AccountingPeriod."Starting Date" := StartingDate;
                AccountingPeriod."New Fiscal Year" := Date2DMY(StartingDate, 2) = 1;
                AccountingPeriod.Insert();
            end;
        end;
    end;

    local procedure EnsureSourceCodeSetup()
    var
        SourceCodeSetup: Record "Source Code Setup";
    begin
        if not SourceCodeSetup.Get() then begin
            SourceCodeSetup.Init();
            SourceCodeSetup.Insert();
        end;
        if SourceCodeSetup."General Journal" = '' then
            SourceCodeSetup."General Journal" := CreateSourceCode();
        if SourceCodeSetup."Sales Journal" = '' then
            SourceCodeSetup."Sales Journal" := CreateSourceCode();
        if SourceCodeSetup."Purchase Journal" = '' then
            SourceCodeSetup."Purchase Journal" := CreateSourceCode();
        if SourceCodeSetup."Sales Deferral" = '' then
            SourceCodeSetup."Sales Deferral" := CreateSourceCode();
        if SourceCodeSetup."General Deferral" = '' then
            SourceCodeSetup."General Deferral" := CreateSourceCode();
        SourceCodeSetup.Modify();
    end;

    local procedure CreateUniqueNoSeries(): Code[20]
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        LibraryUtility: Codeunit "Library - Utility";
    begin
        NoSeries.Init();
        NoSeries.Code := LibraryUtility.GenerateGUID();
        NoSeries."Default Nos." := true;
        NoSeries.Insert();
        NoSeriesLine.Init();
        NoSeriesLine."Series Code" := NoSeries.Code;
        NoSeriesLine."Starting No." := CopyStr(NoSeries.Code + '000001', 1, MaxStrLen(NoSeriesLine."Starting No."));
        NoSeriesLine.Open := true;
        NoSeriesLine.Insert();
        NoSeriesLine.Validate(Implementation, NoSeriesLine.Implementation::Sequence);
        NoSeriesLine.Modify();
        exit(NoSeries.Code);
    end;

    local procedure CreateSourceCode(): Code[10]
    var
        SourceCode: Record "Source Code";
        LibraryERM: Codeunit "Library - ERM";
    begin
        LibraryERM.CreateSourceCode(SourceCode);
        exit(SourceCode.Code);
    end;
}
