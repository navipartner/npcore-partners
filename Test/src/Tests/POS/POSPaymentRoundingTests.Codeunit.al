codeunit 85023 "NPR POS Payment Rounding Tests"
{
    // // [Feature] POS Payment rounding scenarios
    //This codeunit will test all edge payment cases listed in spreadsheet https://navipartner1-my.sharepoint.com/:x:/r/personal/mmv_navipartner_dk/_layouts/15/Doc.aspx?sourcedoc=%7BE4D9A202-8503-4707-AA65-F33EBD5D5F18%7D&file=Rounding%20sheet.xlsx&action=default&mobileredir
    Subtype = Test;

    var
        _Initialized: Boolean;
        _POSUnit: Record "NPR POS Unit";
        _POSPaymentMethodDKK: Record "NPR POS Payment Method";
        _POSPaymentMethodCash: Record "NPR POS Payment Method";
        _POSPaymentMethodEUR: Record "NPR POS Payment Method";
        _POSSession: Codeunit "NPR POS Session";
        _POSStore: Record "NPR POS Store";
        _POSSetup: Record "NPR POS Setup";
        _Item: Record "Item";

    [Test]
    procedure RoundingScenario1()
    begin
        NewTransactionPartialPay(100, 0.51, 99.5);
    end;

    [Test]
    procedure RoundingScenario2()
    begin
        NewTransactionPartialPay(99.96, 0.01, 100);
    end;

    [Test]
    procedure RoundingScenario3()
    begin
        NewTransactionFinish(99.76, 109.52, 10, -0.24);
    end;

    [Test]
    procedure RoundingScenario4()
    begin
        NewTransactionPartialPay(99.76, 0.02, 99.5);
    end;

    [Test]
    procedure RoundingScenario5()
    begin
        NewTransactionPartialPay(99.76, 99, 1);
    end;

    [Test]
    procedure RoundingScenario6()
    begin
        NewTransactionFinish(99.75, 105, 5, 0.25);
    end;

    [Test]
    procedure RoundingScenario7()
    begin
        NewTransactionPartialPay(99.75, 99, 1);
    end;

    [Test]
    procedure RoundingScenario8()
    begin
        NewTransactionFinish(99.74, 99.5, 0, -0.24);
    end;

    [Test]
    procedure RoundingScenario9()
    begin
        NewTransactionPartialPay(99.74, 99, 0.5);
    end;

    [Test]
    procedure RoundingScenario10()
    begin
        NewTransactionPartialPay(-3.07, -5.1, 2);
    end;

    [Test]
    procedure RoundingScenario11()
    begin
        NewTransactionPartialPay(-3.07, -2.1, -1);
    end;

    [Test]
    procedure RoundingScenario12()
    begin
        NewTransactionPartialPay(-99, -99.5, 0.5);
    end;

    [Test]
    procedure RoundingScenario13()
    begin
        NewTransactionPartialPay(-99.01, -200, 101);
    end;

    [Test]
    procedure RoundingScenario14()
    begin
        NewTransactionPartialPay(-99.01, -99.5, 0.5);
    end;

    [Test]
    procedure RoundingScenario15()
    begin
        NewTransactionPartialPay(-99.74, -200, 100.5);
    end;

    [Test]
    procedure RoundingScenario16()
    begin
        NewTransactionPartialPay(-99.74, -99, -0.5);
    end;

    [Test]
    procedure RoundingScenario17()
    begin
        NewTransactionPartialPay(-99.74, 0, -99.5);
    end;

    [Test]
    procedure RoundingScenario18()
    begin
        NewTransactionPartialPay(-99.75, -200, 100);
    end;

    [Test]
    procedure RoundingScenario19()
    begin
        NewTransactionPartialPay(-99.75, -99, -1);
    end;

    [Test]
    procedure RoundingScenario20()
    begin
        NewTransactionPartialPay(-99.75, -110, 10);
    end;

    [Test]
    procedure RoundingScenario21()
    begin
        NewTransactionPartialPay(-99.75, 0, -100);
    end;

    [Test]
    procedure RoundingScenario22()
    begin
        NewTransactionPartialPay(-99.76, -200, 100);
    end;

    [Test]
    procedure RoundingScenario23()
    begin
        NewTransactionPartialPay(-99.76, -99, -1);
    end;

    [Test]
    procedure RoundingScenario24()
    begin
        NewTransactionPartialPay(-99.76, 0, -100);
    end;

    [Test]
    procedure RoundingScenario25()
    begin
        NewTransactionPartialPay(-99.99, -200, 100);
    end;

    [Test]
    procedure RoundingScenario26()
    begin
        NewTransactionPartialPay(-100.24, 0, -100);
    end;

    [Test]
    procedure RoundingScenario27()
    begin
        NewTransactionPartialPay(-100.25, 0, -100.5);
    end;

    [Test]
    procedure RoundingScenario28()
    begin
        NewTransactionPartialPay(-100.26, 0, -100.5);
    end;

    [Test]
    procedure RoundingScenario29()
    begin
        NewTransactionPartialPay(-499.49, -510, 10.5);
    end;

    [Test]
    procedure RoundingScenario30()
    begin
        NewTransactionPartialPay(-499.49, 0, -499.5);
    end;

    [Test]
    procedure RoundingScenario31()
    begin
        NewTransactionFinish(499.49, 510, 10.5, 0.01);
    end;

    [Test]
    procedure RoundingScenario32()
    begin
        NewTransactionPartialPay(100, 99.51, 0.5);
    end;

    [Test]
    procedure RoundingScenario33()
    begin
        NewTransactionFinish(100, 100.51, 0.5, 0.01);
    end;

    [Test]
    procedure RoundingScenario34()
    begin
        NewTransactionFinish(99.99, 200, 100, 0.01);
    end;

    [Test]
    procedure RoundingScenario35()
    begin
        NewTransactionFinish(99.98, 100, 0, 0.02);
    end;

    [Test]
    procedure RoundingScenario36()
    begin
        NewTransactionFinish(99.97, 100, 0, 0.03);
    end;

    [Test]
    procedure RoundingScenario37()
    begin
        NewTransactionPartialPay(99.76, 99.5, 0.5);
    end;

    [Test]
    procedure RoundingScenario38()
    begin
        NewTransactionFinish(99.76, 100, 0, 0.24);
    end;

    [Test]
    procedure RoundingScenario39()
    begin
        NewTransactionFinish(99.76, 200, 100, 0.24);
    end;

    [Test]
    procedure RoundingScenario40()
    begin
        NewTransactionFinish(99.76, 100.02, 0.5, -0.24);
    end;

    [Test]
    procedure RoundingScenario41()
    begin
        NewTransactionFinish(99.76, 99.52, 0, -0.24);
    end;

    [Test]
    procedure RoundingScenario42()
    begin
        NewTransactionPartialPay(99.75, 99.5, 0.5);
    end;

    [Test]
    procedure RoundingScenario43()
    begin
        NewTransactionFinish(99.75, 100, 0, 0.25);
    end;

    [Test]
    procedure RoundingScenario44()
    begin
        NewTransactionFinish(99.75, 200, 100, 0.25);
    end;

    [Test]
    procedure RoundingScenario45()
    begin
        NewTransactionFinish(99.75, 110, 10, 0.25);
    end;

    [Test]
    procedure RoundingScenario46()
    begin
        NewTransactionFinish(99.75, 99.76, 0, 0.01);
    end;

    [Test]
    procedure RoundingScenario47()
    begin
        NewTransactionFinish(99.74, 100, 0.5, -0.24);
    end;

    [Test]
    procedure RoundingScenario48()
    begin
        NewTransactionFinish(99.74, 200, 100.5, -0.24);
    end;

    [Test]
    procedure RoundingScenario49()
    begin
        NewTransactionFinish(99.74, 99.5, 0, -0.24);
    end;

    [Test]
    procedure RoundingScenario50()
    begin
        NewTransactionFinish(99.01, 200, 101, -0.01);
    end;

    [Test]
    procedure RoundingScenario51()
    begin
        NewTransactionFinish(35.67, 135.67, 100, 0);
    end;

    [Test]
    procedure RoundingScenario52()
    begin
        NewTransactionFinish(3.07, 5.1, 2, 0.03);
    end;

    [Test]
    procedure RoundingScenario53()
    begin
        NewTransactionPartialPay(0.49, 0, 0.5);
    end;

    [Test]
    procedure RoundingScenario54()
    begin
        NewTransactionFinish(0.01, 0, 0, -0.01);
    end;

    [Test]
    procedure RoundingScenario55()
    begin
        NewTransactionFinish(-0.01, 0, 0, 0.01);
    end;

    [Test]
    procedure RoundingScenario56()
    begin
        NewTransactionFinish(-3.07, -3.1, 0, -0.03);
    end;

    [Test]
    procedure RoundingScenario57()
    begin
        NewTransactionFinish(-99.75, -100, 0, -0.25);
    end;

    [Test]
    procedure RoundingScenario58()
    begin
        NewTransactionFinish(-99.75, -100, 0, -0.25);
    end;

    [Test]
    procedure RoundingScenario59()
    begin
        NewTransactionPartialPay(-100, -99.51, -0.5);
    end;

    [Test]
    procedure RoundingScenario60()
    begin
        NewTransactionFinish(100, 99.76, 0, -0.24);
    end;

    [Test]
    procedure RoundingScenario61()
    begin
        NewTransactionFinishForeign(100, 14, 5, 0);
    end;

    [Test]
    procedure RoundingScenario62()
    begin
        NewTransactionFinishForeign(100, 15, 12.5, 0);
    end;

    [Test]
    procedure RoundingScenario63()
    begin
        NewTransactionFinishForeign(100, 16, 20, 0);
    end;

    [Test]
    procedure RoundingScenario64()
    begin
        NewTransactionPartialPayForeign(100, 13, 2.5);
    end;

    [Test]
    procedure RoundingScenario65()
    begin
        NewTransactionFinishForeign(99.63, 14, 5.5, -0.13);
    end;

    [Test]
    procedure RoundingScenario66()
    begin
        NewTransactionFinishForeign(97.75, 14, 7, 0.25);
    end;

    [Test]
    procedure RoundingScenario67()
    begin
        NewTransactionFinishForeign(105.24, 14, 0, -0.24);
    end;

    [Test]
    procedure RoundingScenario68()
    begin
        NewTransactionPartialPay(99.74, 0, 99.5);
    end;

    [Test]
    procedure RoundingScenario69()
    begin
        NewTransactionPartialPay(99.75, 0, 100);
    end;

    [Test]
    procedure RoundingScenario70()
    begin
        NewTransactionFinish(900, 900.72, 0.5, 0.22);
    end;

    [Test]
    procedure RoundingScenario71()
    begin
        NewTransactionPartialPay(-0.72, 0, -0.5);
    end;

    [Test]
    procedure RoundingScenario72()
    begin
        NewTransactionFinish(99.76, 109.52, 10, -0.24);
    end;




    local procedure NewTransactionPartialPay(TransactionAmount: Decimal; PaymentAmount: Decimal; ExpectedSuggestion: Decimal)
    var
        SalePOS: Record "NPR Sale POS";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Assert: Codeunit "Assert";
        TransactionEnded: Boolean;
        SalesAmount: Decimal;
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SubTotal: Decimal;
        Suggestion: Decimal;
        ForeignSuggestion: Decimal;
    begin
        InitializeData();

        //Create transaction
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);
        _Item.Get(_Item."No.");
        _Item."Unit Price" := TransactionAmount;
        _Item.Modify;
        NPRLibraryPOSMock.CreateItemLine(_POSSession, _Item."No.", 1);
        NPRLibraryPOSMasterData.OpenPOSUnit(_POSUnit);

        //Pay assigned amount with Payment method with rounding 0.01
        TransactionEnded := NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, PaymentAmount, '');
        if not TransactionEnded then
            TransactionEnded := NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodDKK.Code, 0, '');

        _POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.CalculateBalance(SalesAmount, PaidAmount, ReturnAmount, SubTotal);
        Suggestion := POSPaymentLine.CalculateRemainingPaymentSuggestionInCurrentSale(_POSPaymentMethodDKK);

        // [THEN] Then check 
        Assert.AreEqual(false, TransactionEnded, 'Transaction end not according to test scenario.');
        Assert.AreEqual(TransactionAmount - PaymentAmount, SubTotal, 'Transaction balance not according to test scenario.');
        Assert.AreEqual(ExpectedSuggestion, Suggestion, 'Remaining suggestion not according to test scenario.');
          end;

    local procedure NewTransactionFinish(TransactionAmount: Decimal; PaymentAmount: Decimal; ReturnAmount: Decimal; RoundingAmount: Decimal)
    var
        SalePOS: Record "NPR Sale POS";
        POSPaymentLine: Record "NPR POS Payment Line";
        POSSalesLine: Record "NPR POS Sales Line";
        POSEntry: Record "NPR POS Entry";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Assert: Codeunit "Assert";
        TransactionEnded: Boolean;
    begin
        InitializeData();

        //Create transaction
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);
        _Item.Get(_Item."No.");
        _Item."Unit Price" := TransactionAmount;
        _Item.Modify;
        NPRLibraryPOSMock.CreateItemLine(_POSSession, _Item."No.", 1);
        NPRLibraryPOSMasterData.OpenPOSUnit(_POSUnit);

        //Pay assigned amount with Payment method with rounding 0.01 and auto finish transaction = No
        TransactionEnded := NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, PaymentAmount, '');
        if not TransactionEnded then
            TransactionEnded := NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodDKK.Code, 0, '');

        // [THEN] Then check 
        Assert.AreEqual(true, TransactionEnded, 'Transaction end not according to test scenario.');
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        Assert.IsTrue(POSEntry.FindFirst(), 'Sale was moved to POS Entry');

        if RoundingAmount <> 0 then begin
            POSSalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
            POSSalesLine.SetRange(Type, POSSalesLine.Type::Rounding);
            Assert.IsTrue(POSSalesLine.FindFirst(), 'Rounding line exists');
            Assert.AreEqual(RoundingAmount, POSSalesLine."Amount Incl. VAT (LCY)", 'Rounding amount not according to test scenario.');
        end;

        if ReturnAmount <> 0 then begin
            POSPaymentLine.SetRange("POS Entry No.", POSEntry."Entry No.");
            POSPaymentLine.SetRange("POS Payment Method Code", _POSPaymentMethodCash."Return Payment Method Code");
            POSPaymentLine.SetFilter("Amount (LCY)", '<0');
            Assert.Istrue(POSPaymentLine.FindFirst, 'Payment line exists with matching info for return payment (change)');
            Assert.AreEqual(-ReturnAmount, POSPaymentLine."Amount (LCY)", 'Return amount not according to test scenario.');
        end;
    end;

    local procedure NewTransactionPartialPayForeign(TransactionAmount: Decimal; PaymentAmount: Decimal; ExpectedSubtotal: Decimal)
    var
        SalePOS: Record "NPR Sale POS";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Assert: Codeunit "Assert";
        TransactionEnded: Boolean;
        SalesAmount: Decimal;
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SubTotal: Decimal;
        Suggestion: Decimal;
        ForeignSuggestion: Decimal;
        ExpectedSuggestion: Decimal;
        ExpectedForeignSuggestion: Decimal;
    begin
        InitializeData();

        //Create transaction
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);
        _Item.Get(_Item."No.");
        _Item."Unit Price" := TransactionAmount;
        _Item.Modify;
        NPRLibraryPOSMock.CreateItemLine(_POSSession, _Item."No.", 1);
        NPRLibraryPOSMasterData.OpenPOSUnit(_POSUnit);

        //Pay assigned amount with Foreign currency with rounding 1
        TransactionEnded := NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodEUR.Code, PaymentAmount, '');
        if not TransactionEnded then
            TransactionEnded := NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodDKK.Code, 0, '');

        _POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.CalculateBalance(SalesAmount, PaidAmount, ReturnAmount, SubTotal);
        Suggestion := POSPaymentLine.CalculateRemainingPaymentSuggestionInCurrentSale(_POSPaymentMethodDKK);
        ForeignSuggestion := POSPaymentLine.CalculateRemainingPaymentSuggestionInCurrentSale(_POSPaymentMethodEUR);
        

        // [THEN] Then check 
        Assert.AreEqual(false, TransactionEnded, 'Transaction end not according to test scenario.');
        Assert.AreEqual(ExpectedSubtotal, SubTotal, 'Transaction balance not according to test scenario.');
        ExpectedSuggestion := Round(SubTotal, _POSPaymentMethodDKK."Rounding Precision");
        Assert.AreEqual(ExpectedSuggestion, Suggestion, 'Remaining suggestion not according to test scenario.');
        ExpectedForeignSuggestion := Round(SubTotal / _POSPaymentMethodEUR."Fixed Rate" * 100, _POSPaymentMethodEUR."Rounding Precision", '>');
        Assert.AreEqual(ExpectedForeignSuggestion, ForeignSuggestion, 'Remaining foreign suggestion not according to test scenario.');
    end;

    local procedure NewTransactionFinishForeign(TransactionAmount: Decimal; PaymentAmount: Decimal; ReturnAmount: Decimal; RoundingAmount: Decimal)
    var
        SalePOS: Record "NPR Sale POS";
        POSPaymentLine: Record "NPR POS Payment Line";
        POSSalesLine: Record "NPR POS Sales Line";
        POSEntry: Record "NPR POS Entry";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Assert: Codeunit "Assert";
        TransactionEnded: Boolean;
    begin
        InitializeData();

        //Create transaction
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);
        _Item.Get(_Item."No.");
        _Item."Unit Price" := TransactionAmount;
        _Item.Modify;
        NPRLibraryPOSMock.CreateItemLine(_POSSession, _Item."No.", 1);
        NPRLibraryPOSMasterData.OpenPOSUnit(_POSUnit);

        //Pay assigned amount with Foreign currency with rounding 1
        TransactionEnded := NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodEUR.Code, PaymentAmount, '');
        if not TransactionEnded then
            TransactionEnded := NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodDKK.Code, 0, '');

        // [THEN] Then check 
        Assert.AreEqual(true, TransactionEnded, 'Transaction end not according to test scenario.');
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        Assert.IsTrue(POSEntry.FindFirst(), 'Sale was moved to POS Entry');

        if RoundingAmount <> 0 then begin
            POSSalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
            POSSalesLine.SetRange(Type, POSSalesLine.Type::Rounding);
            Assert.IsTrue(POSSalesLine.FindFirst(), 'Rounding line exists');
            Assert.AreEqual(RoundingAmount, POSSalesLine."Amount Incl. VAT (LCY)", 'Rounding amount not according to test scenario.');
        end;

        if ReturnAmount <> 0 then begin
            POSPaymentLine.SetRange("POS Entry No.", POSEntry."Entry No.");
            POSPaymentLine.SetRange("POS Payment Method Code", _POSPaymentMethodEUR."Return Payment Method Code");
            POSPaymentLine.SetFilter("Amount (LCY)", '<0');
            Assert.Istrue(POSPaymentLine.FindFirst, 'Payment line exists with matching info for return payment (change)');
            Assert.AreEqual(-ReturnAmount, POSPaymentLine."Amount (LCY)", 'Return amount not according to test scenario.');
        end;
    end;

    local procedure CreateDKKPaymentMethod()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
    begin
        NPRLibraryPOSMasterData.CreatePOSPaymentMethod(_POSPaymentMethodDKK, _POSPaymentMethodDKK."Processing Type"::CASH, '', false);
        _POSPaymentMethodDKK."Rounding Precision" := 0.5;
        _POSPaymentMethodDKK."Rounding Type" := _POSPaymentMethodDKK."Rounding Type"::Nearest;
        _POSPaymentMethodDKK.Modify();
    end;

    local procedure CreateCashPaymentMethod()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
    begin
        NPRLibraryPOSMasterData.CreatePOSPaymentMethod(_POSPaymentMethodCash, _POSPaymentMethodCash."Processing Type"::CASH, '', false);
        _POSPaymentMethodCash."Rounding Precision" := 0.01;
        _POSPaymentMethodCash."Rounding Type" := _POSPaymentMethodCash."Rounding Type"::Nearest;
        _POSPaymentMethodCash."Return Payment Method Code" := _POSPaymentMethodDKK.Code;
        _POSPaymentMethodCash."Auto End Sale" := false;
        _POSPaymentMethodCash.Modify();
    end;

    local procedure CreateEURPaymentMethod()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
    begin
        NPRLibraryPOSMasterData.CreatePOSPaymentMethod(_POSPaymentMethodEUR, _POSPaymentMethodEUR."Processing Type"::CASH, '', false);
        _POSPaymentMethodEUR."Rounding Precision" := 1;
        _POSPaymentMethodEUR."Rounding Type" := _POSPaymentMethodEUR."Rounding Type"::Up;
        _POSPaymentMethodEUR."Currency Code" := 'EUR';
        _POSPaymentMethodEUR."Return Payment Method Code" := _POSPaymentMethodDKK.Code;
        _POSPaymentMethodEUR."Fixed Rate" := 750;
        _POSPaymentMethodEUR.Modify();
    end;


    procedure InitializeData()
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
    begin
        if _Initialized then begin
            //Clean any previous mock session
            _POSSession.Destructor();
            Clear(_POSSession);
        end;

        if not _Initialized then begin
            NPRLibraryPOSMasterData.CreatePOSSetup(_POSSetup);
            NPRLibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
            NPRLibraryPOSMasterData.CreatePOSStore(_POSStore, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSUnit(_POSUnit, _POSStore.Code, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(_Item, _POSUnit, _POSStore);
            CreateDKKPaymentMethod();
            CreateCashPaymentMethod();
            CreateEURPaymentMethod();
            _Initialized := true;
        end;

        Commit;
    end;

}