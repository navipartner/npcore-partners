codeunit 85039 "NPR French Compliance Tests"
{
    // // [Feature] French NF 525 compliance tests 

    Subtype = Test;

    var
        _Initialized: Boolean;
        _POSUnit: Record "NPR POS Unit";
        _POSPaymentMethod: Record "NPR POS Payment Method";
        _POSSession: Codeunit "NPR POS Session";
        _POSStore: Record "NPR POS Store";
        _POSSetup: Record "NPR POS Setup";
        _Item: Record "Item";
        _VoucherType: Record "NPR NpRv Voucher Type";
        _Salesperson: Record "Salesperson/Purchaser";
        _ReturnReason: Record "Return Reason";
        _FRAuditMgt: Codeunit "NPR FR Audit Mgt.";

    [Test]
    procedure PurchaseSignature()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        Assert: Codeunit "Assert";
        SaleEnded: Boolean;
        POSEntry: Record "NPR POS Entry";
        EntryNumber1: Integer;
        EntryNumber2: Integer;
        EntryNumber3: Integer;
        POSAuditLog: Record "NPR POS Audit Log";
        SignatureBaseValue: Text;
        SignatureBaseValueParts: List of [Text];
        PreviousSignature: Text;
    begin
        // [Scenario] Check that multiple successful cash sales are signed correctly in a chain when FR audit handler is enabled on POS unit.

        // [Given] POS and FR audit setup, and initialized JET 
        InitializeData();

        // [When] Ending 3 normal cash sales in a row
        EntryNumber1 := DoItemSale();
        EntryNumber2 := DoItemSale();
        EntryNumber3 := DoItemSale();

        // [Then] All 3 sales have been signed in a chain      
        POSAuditLog.SetRange("Acted on POS Entry No.", EntryNumber1);
        POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::DIRECT_SALE_END);
        POSAuditLog.FindFirst();
        Assert.IsTrue(POSAuditLog."Electronic Signature".HasValue, 'Event must be signed');
        PreviousSignature := GetSignatureValue(POSAuditLog);

        POSAuditLog.SetRange("Acted on POS Entry No.", EntryNumber2);
        POSAuditLog.FindFirst();
        Assert.IsTrue(POSAuditLog."Electronic Signature".HasValue, 'Event must be signed');
        SignatureBaseValue := GetSignatureBaseValue(POSAuditLog);
        SignatureBaseValueParts := SignatureBaseValue.Split(',');
        Assert.AreEqual(PreviousSignature, SignatureBaseValueParts.Get(SignatureBaseValueParts.Count), 'Last chunk of signed data must be equal to previous event signature');
        PreviousSignature := GetSignatureValue(POSAuditLog);

        POSAuditLog.SetRange("Acted on POS Entry No.", EntryNumber3);
        POSAuditLog.FindFirst();
        Assert.IsTrue(POSAuditLog."Electronic Signature".HasValue, 'Event must be signed');
        SignatureBaseValue := GetSignatureBaseValue(POSAuditLog);
        SignatureBaseValueParts := SignatureBaseValue.Split(',');
        Assert.AreEqual(PreviousSignature, SignatureBaseValueParts.Get(SignatureBaseValueParts.Count), 'Last chunk of signed data must be equal to previous event signature');

        _FRAuditMgt.Destruct();
    end;

    [Test]
    procedure TicketGrandTotalSignature()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        Assert: Codeunit "Assert";
        SaleEnded: Boolean;
        POSEntry: Record "NPR POS Entry";
        EntryNumber1: Integer;
        EntryNumber2: Integer;
        EntryNumber3: Integer;
        POSAuditLog: Record "NPR POS Audit Log";
        SignatureBaseValue: Text;
        SignatureBaseValueParts: List of [Text];
        PreviousSignature: Text;
    begin
        // [Scenario] Check that grand total events from multiple successful cash sales are signed correctly in a chain when FR audit handler is enabled on POS unit.

        // [Given] POS and FR audit setup, and initialized JET 
        InitializeData();

        // [When] Ending 3 normal cash sales in a row
        EntryNumber1 := DoItemSale();
        EntryNumber2 := DoItemSale();
        EntryNumber3 := DoItemSale();

        // [Then] All 3 sales have been signed in a chain      
        POSAuditLog.SetRange("Acted on POS Entry No.", EntryNumber1);
        POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::GRANDTOTAL);
        POSAuditLog.FindFirst();
        Assert.IsTrue(POSAuditLog."Electronic Signature".HasValue, 'Event must be signed');
        PreviousSignature := GetSignatureValue(POSAuditLog);

        POSAuditLog.SetRange("Acted on POS Entry No.", EntryNumber2);
        POSAuditLog.FindFirst();
        Assert.IsTrue(POSAuditLog."Electronic Signature".HasValue, 'Event must be signed');
        SignatureBaseValue := GetSignatureBaseValue(POSAuditLog);
        SignatureBaseValueParts := SignatureBaseValue.Split(',');
        Assert.AreEqual(PreviousSignature, SignatureBaseValueParts.Get(SignatureBaseValueParts.Count), 'Last chunk of signed data must be equal to previous event signature');
        PreviousSignature := GetSignatureValue(POSAuditLog);

        POSAuditLog.SetRange("Acted on POS Entry No.", EntryNumber3);
        POSAuditLog.FindFirst();
        Assert.IsTrue(POSAuditLog."Electronic Signature".HasValue, 'Event must be signed');
        SignatureBaseValue := GetSignatureBaseValue(POSAuditLog);
        SignatureBaseValueParts := SignatureBaseValue.Split(',');
        Assert.AreEqual(PreviousSignature, SignatureBaseValueParts.Get(SignatureBaseValueParts.Count), 'Last chunk of signed data must be equal to previous event signature');
        _FRAuditMgt.Destruct();
    end;

    [Test]
    procedure ReprintSignature()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        Assert: Codeunit "Assert";
        SaleEnded: Boolean;
        POSEntry: Record "NPR POS Entry";
        EntryNo: Integer;
        POSAuditLog: Record "NPR POS Audit Log";
        SignatureBaseValue: Text;
        SignatureBaseValueParts: List of [Text];
        PreviousSignature: Text;
        POSEntryManagement: Codeunit "NPR POS Entry Management";

    begin
        // [Scenario] Check that reprints of tickets are correctly signed

        // [Given] POS and FR audit setup, and initialized JET
        InitializeData();

        // [When] Ending a normal cashsales and reprinting it 3 times in new sale.
        EntryNo := DoItemSale();
        POSEntry.Get(EntryNo);
        NPRLibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(_POSSession, _POSUnit, POSSale);
        POSEntryManagement.PrintEntry(POSEntry, false);
        POSEntryManagement.PrintEntry(POSEntry, false);
        POSEntryManagement.PrintEntry(POSEntry, false);

        // [Then] All 3 reprints have been signed in a chain      
        POSAuditLog.SetRange("Acted on POS Entry No.", EntryNo);
        POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::RECEIPT_COPY);
        POSAuditLog.FindSet();
        Assert.IsTrue(POSAuditLog."Electronic Signature".HasValue, 'Event must be signed');
        PreviousSignature := GetSignatureValue(POSAuditLog);

        POSAuditLog.Next();
        Assert.IsTrue(POSAuditLog."Electronic Signature".HasValue, 'Event must be signed');
        SignatureBaseValue := GetSignatureBaseValue(POSAuditLog);
        SignatureBaseValueParts := SignatureBaseValue.Split(',');
        Assert.AreEqual(PreviousSignature, SignatureBaseValueParts.Get(SignatureBaseValueParts.Count), 'Last chunk of signed data must be equal to previous event signature');
        PreviousSignature := GetSignatureValue(POSAuditLog);

        POSAuditLog.Next();
        Assert.IsTrue(POSAuditLog."Electronic Signature".HasValue, 'Event must be signed');
        SignatureBaseValue := GetSignatureBaseValue(POSAuditLog);
        SignatureBaseValueParts := SignatureBaseValue.Split(',');
        Assert.AreEqual(PreviousSignature, SignatureBaseValueParts.Get(SignatureBaseValueParts.Count), 'Last chunk of signed data must be equal to previous event signature');
        _FRAuditMgt.Destruct();
    end;

    [Test]
    procedure VoidSignature()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        Assert: Codeunit "Assert";
        SaleEnded: Boolean;
        POSEntry: Record "NPR POS Entry";
        EntryNo1: Integer;
        EntryNo2: Integer;
        EntryNo3: Integer;
        ReturnEntryNo1: Integer;
        ReturnEntryNo2: Integer;
        ReturnEntryNo3: Integer;
        POSAuditLog: Record "NPR POS Audit Log";
        SignatureBaseValue: Text;
        SignatureBaseValueParts: List of [Text];
        PreviousSignature: Text;
    begin
        // [Scenario] Check that return of tickets are correctly signed

        // [Given] POS and FR audit setup, and initialized JET 
        InitializeData();

        // [When] Ending and returning 3 receipts in a row.
        EntryNo1 := DoItemSale();
        POSEntry.Get(EntryNo1);
        ReturnEntryNo1 := DoReturnSale(POSEntry."Document No.");
        EntryNo2 := DoItemSale();
        POSEntry.Get(EntryNo2);
        ReturnEntryNo2 := DoReturnSale(POSEntry."Document No.");
        EntryNo3 := DoItemSale();
        POSEntry.Get(EntryNo3);
        ReturnEntryNo3 := DoReturnSale(POSEntry."Document No.");

        // [Then] All 6 sales have been signed in a DIRECT_SALE_END chain
        POSAuditLog.SetRange("Acted on POS Entry No.", EntryNo1);
        POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::DIRECT_SALE_END);
        POSAuditLog.SetRange("External Description", 'Sale (Ticket)');
        PreviousSignature := ValidateNextSignature(POSAuditLog, '', false);

        POSAuditLog.SetRange("Acted on POS Entry No.", ReturnEntryNo1);
        POSAuditLog.SetRange("External Description", 'Cancellation (Ticket)');
        PreviousSignature := ValidateNextSignature(POSAuditLog, PreviousSignature, true);

        POSAuditLog.SetRange("Acted on POS Entry No.", EntryNo2);
        POSAuditLog.SetRange("External Description", 'Sale (Ticket)');
        PreviousSignature := ValidateNextSignature(POSAuditLog, PreviousSignature, true);

        POSAuditLog.SetRange("Acted on POS Entry No.", ReturnEntryNo2);
        POSAuditLog.SetRange("External Description", 'Cancellation (Ticket)');
        PreviousSignature := ValidateNextSignature(POSAuditLog, PreviousSignature, true);

        POSAuditLog.SetRange("Acted on POS Entry No.", EntryNo3);
        POSAuditLog.SetRange("External Description", 'Sale (Ticket)');
        PreviousSignature := ValidateNextSignature(POSAuditLog, PreviousSignature, true);

        POSAuditLog.SetRange("Acted on POS Entry No.", ReturnEntryNo3);
        POSAuditLog.SetRange("External Description", 'Cancellation (Ticket)');
        PreviousSignature := ValidateNextSignature(POSAuditLog, PreviousSignature, true);

        // [Then] we have JET events for individual returned item lines.
        POSAuditLog.Reset();
        POSAuditLog.SetRange("Acted on POS Entry No.", ReturnEntryNo1);
        POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::ITEM_RMA);
        POSAuditLog.SetRange("External Code", '190');
        POSAuditLog.SetRange("External Type", 'JET');
        PreviousSignature := ValidateNextSignature(POSAuditLog, '', false);

        POSAuditLog.SetRange("Acted on POS Entry No.", ReturnEntryNo2);
        PreviousSignature := ValidateNextSignature(POSAuditLog, PreviousSignature, true);

        POSAuditLog.SetRange("Acted on POS Entry No.", ReturnEntryNo3);
        PreviousSignature := ValidateNextSignature(POSAuditLog, PreviousSignature, true);

        _FRAuditMgt.Destruct();
    end;

    [Test]
    [HandlerFunctions('PageHandler_POSPaymentBinCheckpoint_LookupOK')]
    procedure DailyZReportSignature()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        Assert: Codeunit "Assert";
        SaleEnded: Boolean;
        POSEntry: Record "NPR POS Entry";
        EntryNo: Integer;
        POSAuditLog: Record "NPR POS Audit Log";
        SignatureBaseValue: Text;
        SignatureBaseValueParts: List of [Text];
        PreviousSignature: Text;
        POSActionEndOfDayV3: Codeunit "NPR POS Action: EndOfDay V3";
        POSSaleWrapper: Codeunit "NPR POS Sale";
        POSSaleRecord: Record "NPR POS Sale";
        POSWorkshiftCheckpoint: Codeunit "NPR POS Workshift Checkpoint";
    begin
        // [Scenario] Check that daily Z reports are correctly signed

        // [Given] POS and FR audit setup, and initialized JET 
        InitializeData();

        // [Given] a POS that has sold at least 1 receipt
        DoItemSale();

        // [When] Doing balancing        
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, _Salesperson, POSSaleWrapper);
        EntryNo := POSWorkshiftCheckpoint.EndWorkshift(1, _POSUnit."No.", 0);

        // [Then] Balancing has been signed correctly        
        POSAuditLog.SetRange("Acted on POS Entry No.", EntryNo);
        POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::WORKSHIFT_END);
        POSAuditLog.FindFirst();
        Assert.IsTrue(POSAuditLog."Electronic Signature".HasValue, 'Event must be signed');
        _FRAuditMgt.Destruct();
    end;

    [Test]
    [HandlerFunctions('PageHandler_POSPaymentBinCheckpoint_LookupOK')]
    procedure MonthlyPeriodSignature()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        Assert: Codeunit "Assert";
        SaleEnded: Boolean;
        POSEntry: Record "NPR POS Entry";
        EntryNo: Integer;
        POSAuditLog: Record "NPR POS Audit Log";
        SignatureBaseValue: Text;
        SignatureBaseValueParts: List of [Text];
        PreviousSignature: Text;
        POSActionEndOfDayV3: Codeunit "NPR POS Action: EndOfDay V3";
        POSSaleWrapper: Codeunit "NPR POS Sale";
        POSSaleRecord: Record "NPR POS Sale";
        FRAuditSetup: Record "NPR FR Audit Setup";
        POSWorkshiftCheckpoint: Codeunit "NPR POS Workshift Checkpoint";
    begin
        // [Scenario] Check that monthly reports are correctly signed

        // [Given] POS and FR audit setup, and initialized JET . We trigger the monthly workshift by setting a minus workshift duration
        InitializeData();
        FRAuditSetup.Get();
        Evaluate(FRAuditSetup."Monthly Workshift Duration", '<-1D>');
        FRAuditSetup.Modify();
        _FRAuditMgt.Destruct();

        // [Given] a POS that has sold at least 1 receipt
        DoItemSale();

        // [When] Doing balancing        
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, _Salesperson, POSSaleWrapper);
        EntryNo := POSWorkshiftCheckpoint.EndWorkshift(1, _POSUnit."No.", 0);

        // [Then] Balancing has been signed correctly        
        POSAuditLog.SetRange("Acted on POS Entry No.", EntryNo);
        POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::GRANDTOTAL);
        POSAuditLog.SetRange("External Description", 'Monthly Grand Total');
        POSAuditLog.FindFirst();
        Assert.IsTrue(POSAuditLog."Electronic Signature".HasValue, 'Event must be signed');
        _FRAuditMgt.Destruct();
    end;

    [Test]
    [HandlerFunctions('PageHandler_POSPaymentBinCheckpoint_LookupOK')]
    procedure YearlyPeriodSignature()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        Assert: Codeunit "Assert";
        SaleEnded: Boolean;
        POSEntry: Record "NPR POS Entry";
        EntryNo: Integer;
        POSAuditLog: Record "NPR POS Audit Log";
        SignatureBaseValue: Text;
        SignatureBaseValueParts: List of [Text];
        PreviousSignature: Text;
        POSActionEndOfDayV3: Codeunit "NPR POS Action: EndOfDay V3";
        POSSaleWrapper: Codeunit "NPR POS Sale";
        POSSaleRecord: Record "NPR POS Sale";
        FRAuditSetup: Record "NPR FR Audit Setup";
        POSWorkshiftCheckpoint: Codeunit "NPR POS Workshift Checkpoint";
    begin
        // [Scenario] Check that yearly reports are correctly signed

        // [Given] POS and FR audit setup, and initialized JET . We trigger the yearly workshift by setting a minus workshift duration
        InitializeData();
        FRAuditSetup.Get();
        Evaluate(FRAuditSetup."Yearly Workshift Duration", '<-1D>');
        FRAuditSetup.Modify();
        _FRAuditMgt.Destruct();

        // [Given] a POS that has sold at least 1 receipt
        DoItemSale();

        // [When] Doing balancing        
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, _Salesperson, POSSaleWrapper);
        EntryNo := POSWorkshiftCheckpoint.EndWorkshift(1, _POSUnit."No.", 0);

        // [Then] Balancing has been signed correctly        
        POSAuditLog.SetRange("Acted on POS Entry No.", EntryNo);
        POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::GRANDTOTAL);
        POSAuditLog.SetRange("External Description", 'Yearly Grand Total');
        POSAuditLog.FindFirst();
        Assert.IsTrue(POSAuditLog."Electronic Signature".HasValue, 'Event must be signed');
        _FRAuditMgt.Destruct();
    end;

    [Test]
    [HandlerFunctions('PageHandler_POSPaymentBinCheckpoint_LookupOK')]
    procedure MonthlyPeriodArchiveSignature()
    var
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
        WorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        Assert: Codeunit "Assert";
        SaleEnded: Boolean;
        POSEntry: Record "NPR POS Entry";
        EntryNo: Integer;
        POSAuditLog: Record "NPR POS Audit Log";
        SignatureBaseValue: Text;
        SignatureBaseValueParts: List of [Text];
        PreviousSignature: Text;
        POSActionEndOfDayV3: Codeunit "NPR POS Action: EndOfDay V3";
        POSSaleWrapper: Codeunit "NPR POS Sale";
        POSSaleRecord: Record "NPR POS Sale";
        FRAuditSetup: Record "NPR FR Audit Setup";
        POSWorkshiftCheckpoint: Codeunit "NPR POS Workshift Checkpoint";
        FrenchArchiveHandler: Codeunit "NPR French Archive Handler";
    begin
        // [Scenario] Check that monthly reports archives are correctly signed

        // [Given] A monthly period
        InitializeData();
        FRAuditSetup.Get();
        Evaluate(FRAuditSetup."Monthly Workshift Duration", '<-1D>');
        FRAuditSetup.Modify();
        _FRAuditMgt.Destruct();
        DoItemSale();
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, _Salesperson, POSSaleWrapper);
        POSSaleWrapper.GetCurrentSale(POSSaleRecord);
        EntryNo := POSWorkshiftCheckpoint.EndWorkshift(1, _POSUnit."No.", 0);

        // [When] Archiving the period
        WorkshiftCheckpoint.SetRange("POS Entry No.", EntryNo);
        WorkshiftCheckpoint.SetRange("Period Type", 'FR_NF525_MONTH');
        WorkshiftCheckpoint.FindFirst();
        BindSubscription(FrenchArchiveHandler);
        POSAuditLogMgt.ArchiveWorkshiftPeriod(WorkshiftCheckpoint);

        // [Then] The archival is signed correctly
        POSAuditLog.SetRange("Record ID", WorkshiftCheckpoint.RecordId);
        POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::ARCHIVE_ATTEMPT);
        POSAuditLog.FindLast();
        Assert.IsTrue(POSAuditLog."Electronic Signature".HasValue, 'Archive attempt must be signed');

        POSAuditLog.SetRange("Record ID", WorkshiftCheckpoint.RecordId);
        POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::ARCHIVE_CREATE);
        POSAuditLog.FindLast();
        Assert.IsTrue(POSAuditLog."Electronic Signature".HasValue, 'Archive file must be signed');
        _FRAuditMgt.Destruct();
    end;

    [Test]
    procedure LoginSetupValidation()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        Assert: Codeunit "Assert";
        SaleEnded: Boolean;
        POSEntry: Record "NPR POS Entry";
        EntryNo: Integer;
        POSAuditLog: Record "NPR POS Audit Log";
        SignatureBaseValue: Text;
        SignatureBaseValueParts: List of [Text];
        PreviousSignature: Text;
        POSActionEndOfDayV3: Codeunit "NPR POS Action: EndOfDay V3";
        POSSaleWrapper: Codeunit "NPR POS Sale";
        POSSaleRecord: Record "NPR POS Sale";
        FRAuditSetup: Record "NPR FR Audit Setup";
        POSAuditProfile: Record "NPR POS Audit Profile";
    begin
        // [Scenario] Check that POS logins is correctly safeguarded against non-compliant setup

        // [Given] POS and FR audit setup, and initialized JET. But someone switches setup to a non-compliant state
        InitializeData();
        POSAuditProfile.Get(_POSUnit."POS Audit Profile");
        POSAuditProfile."Require Item Return Reason" := false;
        POSAUditProfile.Modify();

        // [When] We log into a new sale on POS
        // [Then] Error
        AssertError NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, _Salesperson, POSSaleWrapper);
        _FRAuditMgt.Destruct();
    end;

    [Test]
    procedure LoginSignature()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        Assert: Codeunit "Assert";
        SaleEnded: Boolean;
        POSEntry: Record "NPR POS Entry";
        EntryNo: Integer;
        POSAuditLog: Record "NPR POS Audit Log";
        SignatureBaseValue: Text;
        SignatureBaseValueParts: List of [Text];
        PreviousSignature: Text;
        POSActionEndOfDayV3: Codeunit "NPR POS Action: EndOfDay V3";
        POSSaleWrapper: Codeunit "NPR POS Sale";
        POSSaleRecord: Record "NPR POS Sale";
        FRAuditSetup: Record "NPR FR Audit Setup";
        POSActionLogin: Codeunit "NPR POS Action - Login";
        POSSetup: Codeunit "NPR POS Setup";
    begin
        // [Scenario] Check that POS logins are correctly signed

        // [Given] POS and FR audit setup, and initialized JET. 
        InitializeData();
        SalePOS.DeleteAll(true);

        // [When] Logging into POS sale      
        NPRLibraryPOSMock.InitializePOSSession(_POSSession, _POSUnit);
        _POSSession.GetSetup(POSSetup);
        POSSetup.SetSalesperson(_Salesperson);
        Commit();
        POSActionLogin.StartPOS(_POSSession);

        // [Then] Login is signed
        POSSaleWrapper.GetCurrentSale(POSSaleRecord);
        POSAuditLog.SetRange("Active POS Sale SystemId", POSSaleRecord.SystemId);
        POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::SIGN_IN);
        POSAuditLog.FindFirst();
        Assert.IsTrue(POSAuditLog."Electronic Signature".HasValue, 'Event must be signed');
        _FRAuditMgt.Destruct();
    end;

    [Test]
    procedure CancelSaleSignature()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        Assert: Codeunit "Assert";
        SaleEnded: Boolean;
        POSEntry: Record "NPR POS Entry";
        EntryNo: Integer;
        POSAuditLog: Record "NPR POS Audit Log";
        SignatureBaseValue: Text;
        SignatureBaseValueParts: List of [Text];
        PreviousSignature: Text;
        POSActionEndOfDayV3: Codeunit "NPR POS Action: EndOfDay V3";
        POSSaleWrapper: Codeunit "NPR POS Sale";
        POSSaleRecord: Record "NPR POS Sale";
        FRAuditSetup: Record "NPR FR Audit Setup";
        ActionCancelSale: Codeunit "NPR POSAction: Cancel Sale";
    begin
        // [Scenario] Check that POS sale cancellations are correctly signed

        // [Given] POS and FR audit setup, initialized JET and active sale
        InitializeData();
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, _Salesperson, POSSaleWrapper);
        POSSaleWrapper.GetCurrentSale(POSSaleRecord);

        // [When] Cancelling sale
        ActionCancelSale.CancelSale(_POSSession);

        // [Then] Cancellation is signed;        
        POSAuditLog.SetRange("Active POS Sale SystemId", POSSaleRecord.SystemId);
        POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::CANCEL_SALE_END);
        POSAuditLog.FindFirst();
        Assert.IsTrue(POSAuditLog."Electronic Signature".HasValue, 'Event must be signed');
        _FRAuditMgt.Destruct();
    end;

    [Test]
    procedure VoucherAndItemPurchaseSignature()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        Assert: Codeunit "Assert";
        SaleEnded: Boolean;
        POSEntry: Record "NPR POS Entry";
        EntryNo: Integer;
        POSAuditLog: Record "NPR POS Audit Log";
        SignatureBaseValue: Text;
        SignatureBaseValueParts: List of [Text];
        PreviousSignature: Text;
    begin
        // [Scenario] Check that a sale with both voucher and item has correctly signed events

        // [Given] POS and FR audit setup, initialized JET 
        InitializeData();

        // [When] Ending 3 normal cash sales in a row
        EntryNo := DoItemAndVoucherSale();

        // [Then] All 3 sales have been signed in a chain      
        POSAuditLog.SetRange("Acted on POS Entry No.", EntryNo);
        POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::DIRECT_SALE_END);
        POSAuditLog.FindFirst();
        Assert.IsTrue(POSAuditLog."Electronic Signature".HasValue, 'Event must be signed');

        POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::CUSTOM);
        POSAuditLog.SetRange("Action Custom Subtype", 'NON_ITEM_AMOUNT');
        POSAuditLog.FindFirst();
        Assert.IsTrue(POSAuditLog."Electronic Signature".HasValue, 'Event must be signed');
        _FRAuditMgt.Destruct();
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure BrokenTicketSignatureChain()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        Assert: Codeunit "Assert";
        SaleEnded: Boolean;
        POSEntry: Record "NPR POS Entry";
        EntryNo: Integer;
        POSAuditLog: Record "NPR POS Audit Log";
        SignatureBaseValue: Text;
        SignatureBaseValueParts: List of [Text];
        PreviousSignature: Text;
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
    begin
        // [Scenario] Check that a broken signature chain can be detected

        // [Given] POS and FR audit setup, initialized JET, 3 completed sales with a valid chain
        PurchaseSignature();
        POSAuditLog.SetRange("Handled by External Impl.", true);
        POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::DIRECT_SALE_END);
        ClearLastError();
        AssertError POSAuditLogMgt.ValidateLog(POSAuditLog);
        Assert.IsTrue(GetLastErrorText() = '', 'Validation must happen without actual error before data tamper');

        // [When] Editing 
        Clear(POSAuditLog);
        POSAuditLog.SetRange("Handled by External Impl.", true);
        POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::DIRECT_SALE_END);
        POSAuditLog.FindLast;
        POSEntry.Get(POSAuditLog."Acted on POS Entry No.");
        POSEntry."Amount Incl. Tax" := 0;
        POSEntry.Modify();

        // [Then] Signature chain does not validate
        ClearLastError();
        AssertError POSAuditLogMgt.ValidateLog(POSAuditLog);
        Assert.IsTrue(GetLastErrorText() <> '', 'Validation must happen with error after data tamper');
        _FRAuditMgt.Destruct();
    end;

    [Test]
    procedure PartnerModificationSignature()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        Assert: Codeunit "Assert";
        SaleEnded: Boolean;
        POSEntry: Record "NPR POS Entry";
        EntryNo: Integer;
        POSAuditLog: Record "NPR POS Audit Log";
        SignatureBaseValue: Text;
        SignatureBaseValueParts: List of [Text];
        PreviousSignature: Text;
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
    begin
        // [Scenario] Check that partner modification logs are signed correctly

        // [Given] POS and FR audit setup, initialized JET,
        InitializeData();

        // [When] Logging a partner modification
        POSAuditLogMgt.LogPartnerModification(_POSUnit."No.", 'Test');

        // [Then] Event is signed correctly
        POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::PARTNER_MODIFICATION);
        POSAuditLog.FindFirst();
        Assert.IsTrue(POSAuditLog."Electronic Signature".HasValue, 'Event must be signed');
        _FRAuditMgt.Destruct();
    end;

    [Test]
    [HandlerFunctions('PageHandler_POSPaymentBinCheckpoint_LookupOK')]
    procedure ArchiveSchemaTest()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        Assert: Codeunit "Assert";
        SaleEnded: Boolean;
        POSEntry: Record "NPR POS Entry";
        EntryNo: Integer;
        POSAuditLog: Record "NPR POS Audit Log";
        SignatureBaseValue: Text;
        SignatureBaseValueParts: List of [Text];
        PreviousSignature: Text;
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
        XmlValidation: Codeunit "Xml Validation";
        FrenchArchiveHandler: Codeunit "NPR French Archive Handler";
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        Chunk: Text;
        XmlArchive: Text;
    begin
        // [Scenario] Check that monthly archive is validating against the schema provided to InfoCert 

        // [Given] Finished monthly period
        MonthlyPeriodSignature();

        // [When] Creating archive
        BindSubscription(FrenchArchiveHandler);
        POSWorkshiftCheckpoint.SetRange(Open, false);
        POSWorkshiftCheckpoint.SetRange(Type, POSWorkshiftCheckpoint.Type::PREPORT);
        POSWorkshiftCheckpoint.SetRange("Period Type", 'FR_NF525_MONTH');
        POSWorkshiftCheckpoint.FindLast();
        POSAuditLogMgt.ArchiveWorkshiftPeriod(POSWorkshiftCheckpoint);
        FrenchArchiveHandler.GetBlob(TempBlob);
        TempBlob.CreateInStream(InStream, TextEncoding::UTF8);
        while (not InStream.EOS) do begin
            InStream.ReadText(Chunk);
            XmlArchive += Chunk;
        end;

        // [Then] Archive validates against schema       
        XmlValidation.TryValidateAgainstSchema(XmlArchive, GetArchiveSchema(), 'http://www.w3.org/2001/XMLSchema');
        _FRAuditMgt.Destruct();
    end;

    [Test]
    procedure JETInitSignatureTest()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        Assert: Codeunit "Assert";
        SaleEnded: Boolean;
        POSEntry: Record "NPR POS Entry";
        ReceiptNumber1: Integer;
        ReceiptNumber2: Integer;
        ReceiptNumber3: Integer;
        POSAuditLog: Record "NPR POS Audit Log";
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
    begin
        // [Scenario] Check that JET init is signed

        // [Given] POS, FR audit setup and JET init
        InitializeData();

        // [When] JET has been initialized (done via InitializeData())        

        // [Then] The event is signed correctly
        POSAuditLog.SetRange("Acted on POS Unit No.", _POSUnit."No.");
        POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::LOG_INIT);
        POSAuditLog.FindFirst();
        Assert.IsTrue(POSAuditLog."Electronic Signature".HasValue(), 'Electronic signature must be filled for JET init event');
        _FRAuditMgt.Destruct();
    end;

    local procedure DoItemSale(): Integer
    var
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleWrapper: Codeunit "NPR POS Sale";
        POSSaleRecord: Record "NPR POS Sale";
        POSEntry: Record "NPR POS Entry";
    begin
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, _Salesperson, POSSaleWrapper);
        POSSaleWrapper.GetCurrentSale(POSSaleRecord);
        NPRLibraryPOSMock.CreateItemLine(_POSSession, _Item."No.", 1);
        if not (NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethod.Code, _Item."Unit Price", '')) then begin
            error('Sale did not end as expected');
        end;
        POSEntry.SetRange("Document No.", POSSaleRecord."Sales Ticket No.");
        POSEntry.FindFirst();
        _POSSession.Destructor();
        Clear(_POSSession);
        Exit(POSEntry."Entry No.");
    end;

    local procedure DoItemAndVoucherSale(): Integer
    var
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleWrapper: Codeunit "NPR POS Sale";
        POSSaleRecord: Record "NPR POS Sale";
        POSEntry: Record "NPR POS Entry";
        SalesAmount: Decimal;
        PaidAmount: Decimal;
        ChangeAmount: Decimal;
        RoundingAmount: Decimal;
    begin
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, _Salesperson, POSSaleWrapper);
        NPRLibraryPOSMock.CreateItemLine(_POSSession, _Item."No.", 1);
        NPRLibraryPOSMock.CreateVoucherLine(_POSSession, _VoucherType.Code, 1, 100, '', 0);
        POSSaleWrapper.GetCurrentSale(POSSaleRecord);
        POSSaleWrapper.GetTotals(SalesAmount, PaidAmount, ChangeAmount, RoundingAmount);
        if not (NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethod.Code, SalesAmount, '')) then begin
            error('Sale did not end as expected');
        end;
        POSEntry.SetRange("Document No.", POSSaleRecord."Sales Ticket No.");
        POSEntry.FindFirst();
        _POSSession.Destructor();
        Clear(_POSSession);
        Exit(POSEntry."Entry No.");
    end;

    local procedure DoReturnSale(ReceiptNumberToReturn: Code[20]): Integer
    var
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleWrapper: Codeunit "NPR POS Sale";
        POSSaleRecord: Record "NPR POS Sale";
        POSEntry: Record "NPR POS Entry";
        POSActionRevDirSale: Codeunit "NPR POS Action: Rev. Dir. Sale";
        SalesAmount: Decimal;
        PaidAmount: Decimal;
        ChangeAmount: Decimal;
        RoundingAmount: Decimal;
    begin
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, _Salesperson, POSSaleWrapper);
        POSSaleWrapper.GetCurrentSale(POSSaleRecord);
        POSActionRevDirSale.ReverseSalesTicket(POSSaleRecord, ReceiptNumberToReturn, _ReturnReason.Code);
        POSSaleWrapper.GetTotals(SalesAmount, PaidAmount, ChangeAmount, RoundingAmount);
        if not (NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethod.Code, SalesAmount, '')) then begin
            error('Sale did not end as expected');
        end;
        POSEntry.SetRange("Document No.", POSSaleRecord."Sales Ticket No.");
        POSEntry.FindFirst();
        _POSSession.Destructor();
        Clear(_POSSession);
        Exit(POSEntry."Entry No.");
    end;

    local procedure InitializeData()
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        POSAuditProfile: Record "NPR POS Audit Profile";
        NPRLibraryFRNF525: Codeunit "NPR Library FR NF525";
        LibraryERM: Codeunit "Library - ERM";
        VATPostingSetup: Record "VAT Posting Setup";
        GLAccount: Record "G/L Account";
        POSAuditLog: Record "NPR POS Audit Log";
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
        POSEndOfDayProfile: Record "NPR POS End Of Day Profile";
        ReportSelectionRetail: Record "NPR Report Selection Retail";
        LibraryRPTemplate: Codeunit "NPR Library - RP Template Data";
        TemplateHeader: Record "NPR RP Template Header";
        ObjectOutputSelection: Record "NPR Object Output Selection";
        GeneralPostingSetup: Record "General Posting Setup";
        VATPostingSetup2: Record "VAT Posting Setup";
    begin
        if _Initialized then begin
            //Clean any previous mock session
            _POSSession.Destructor();
            Clear(_POSSession);
        end else begin
            NPRLibraryPOSMasterData.CreatePOSSetup(_POSSetup);
            NPRLibraryPOSMasterData.CreateDefaultVoucherType(_VoucherType, false);
            NPRLibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
            POSPostingProfile."POS Period Register No. Series" := '';
            POSPostingProfile.Modify();
            NPRLibraryPOSMasterData.CreatePOSStore(_POSStore, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSUnit(_POSUnit, _POSStore.Code, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSPaymentMethod(_POSPaymentMethod, _POSPaymentMethod."Processing Type"::CASH, '', false);
            NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(_Item, _POSUnit, _POSStore);
            NPRLibraryPOSMasterData.CreateSalespersonForPOSUsage(_Salesperson);

            POSEndOfDayProfile.Code := 'EOD-TEST';
            POSEndOfDayProfile."Z-Report UI" := POSEndOfDayProfile."Z-Report UI"::BALANCING;
            POSEndOfDayProfile.Insert();
            _POSUnit."POS End of Day Profile" := POSEndOfDayProfile.Code;
            _POSUnit.Modify();

            LibraryERM.CreateReturnReasonCode(_ReturnReason);
            _Item."Unit Price" := 10;
            _Item.Modify();

            VATPostingSetup.SetRange("VAT Prod. Posting Group", _Item."VAT Prod. Posting Group");
            VATPostingSetup.SetRange("VAT Bus. Posting Group", POSPostingProfile."VAT Bus. Posting Group");
            VATPostingSetup.SetFilter("VAT %", '<>%1', 0);
            VATPostingSetup.FindFirst();
            NPRLibraryFRNF525.CreateAuditProfileAndFRSetup(POSAuditProfile, VATPostingSetup."VAT Identifier", _POSUnit);

            ReportSelectionRetail.SetRange("Report Type", ReportSelectionRetail."Report Type"::"Sales Receipt (POS Entry)");
            ReportSelectionRetail.DeleteAll();
            ObjectOutputSelection.DeleteAll();

            LibraryRPTemplate.CreateDummySalesReceipt(TemplateHeader);
            LibraryRPTemplate.ConfigureReportSelection(ReportSelectionRetail."Report Type"::"Sales Receipt (POS Entry)", TemplateHeader);

            _FRAuditMgt.Destruct();
            _Initialized := true;
        end;

        POSAuditLog.DeleteAll(true); //Clean in between tests        
        POSAuditLogMgt.InitializeLog(_POSUnit."No.");
        Commit();
    end;

    local procedure GetSignatureValue(POSAuditLog: Record "NPR POS Audit Log"): Text
    var
        Stream: InStream;
        Signature: Text;
    begin
        POSAuditLog.CalcFields("Electronic Signature");
        POSAuditLog."Electronic Signature".CreateInStream(stream);
        while (not Stream.EOS) do begin
            Stream.Read(Signature);
        end;
        Exit(Signature);
    end;

    local procedure GetSignatureBaseValue(POSAuditLog: Record "NPR POS Audit Log"): Text
    var
        Stream: InStream;
        SignatureBaseValue: Text;
    begin
        POSAuditLog.CalcFields("Signature Base Value");
        POSAuditLog."Signature Base Value".CreateInStream(stream);
        while (not Stream.EOS) do begin
            Stream.Read(SignatureBaseValue);
        end;
        Exit(SignatureBaseValue);
    end;

    local procedure GetArchiveSchema(): Text
    var
        Base64: Codeunit "Base64 Convert";
    begin
        Exit(Base64.FromBase64(
            'PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0idXRmLTgiPz4NCjx4czpzY2hlbWEgYXR0cmlidXRlRm9ybURlZmF1bHQ9InVucXVhbGlmaWVkIiBlbGVtZW50Rm9ybURlZmF1bHQ9InF1YWxpZmllZCIgeG1sbnM6eHM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDEvWE1MU2NoZW1hIj4NCiAgPHhzOmVsZW1lbnQgbmFtZT0iR3JhbmRQZXJpb2QiPg0KICAgIDx4czpjb21wbGV4VHlwZT4NCiAgICAgIDx4czpzZXF1ZW5jZT4NCiAgICAgICAgPHhzOmVsZW1lbnQgbmFtZT0iU3lzdGVtRW50cnlLZXkiIHR5cGU9InhzOnVuc2lnbmVkQnl0ZSIgLz4NCiAgICAgICAgPHhzOmVsZW1lbnQgbmFtZT0iSUQiIHR5cGU9InhzOnVuc2lnbmVkQnl0ZSIgLz4NCiAgICAgICAgPHhzOmVsZW1lbnQgbmFtZT0iQ3JlYXRlZEF0IiB0eXBlPSJ4czpkYXRlVGltZSIgLz4NCiAgICAgICAgPHhzOmVsZW1lbnQgbmFtZT0iR3JhbmRUb3RhbCIgdHlwZT0ieHM6ZGVjaW1hbCIgLz4NCiAgICAgICAgPHhzOmVsZW1lbnQgbmFtZT0iUGVycGV0dWFsR3JhbmRUb3RhbCIgdHlwZT0ieHM6ZGVjaW1hbCIgLz4NCiAgICAgICAgPHhzOmVsZW1lbnQgbmFtZT0iU2lnbmF0dXJlIiB0eXBlPSJ4czpzdHJpbmciIC8+DQogICAgICAgIDx4czplbGVtZW50IG5hbWU9IlRheExpbmVzIj4NCiAgICAgICAgICA8eHM6Y29tcGxleFR5cGU+DQogICAgICAgICAgICA8eHM6c2VxdWVuY2U+DQogICAgICAgICAgICAgIDx4czplbGVtZW50IG1heE9jY3Vycz0idW5ib3VuZGVkIiBuYW1lPSJUYXhMaW5lIj4NCiAgICAgICAgICAgICAgICA8eHM6Y29tcGxleFR5cGU+DQogICAgICAgICAgICAgICAgICA8eHM6c2VxdWVuY2U+DQogICAgICAgICAgICAgICAgICAgIDx4czplbGVtZW50IG5hbWU9IlRheElkZW50aWZpZXIiIHR5cGU9InhzOnN0cmluZyIgLz4NCiAgICAgICAgICAgICAgICAgICAgPHhzOmVsZW1lbnQgbmFtZT0iVGF4UmF0ZSIgdHlwZT0ieHM6dW5zaWduZWRCeXRlIiAvPg0KICAgICAgICAgICAgICAgICAgICA8eHM6ZWxlbWVudCBuYW1lPSJUYXhCYXNlQW1vdW50IiB0eXBlPSJ4czpkZWNpbWFsIiAvPg0KICAgICAgICAgICAgICAgICAgICA8eHM6ZWxlbWVudCBuYW1lPSJUYXhBbW91bnQiIHR5cGU9InhzOmRlY2ltYWwiIC8+DQogICAgICAgICAgICAgICAgICA8L3hzOnNlcXVlbmNlPg0KICAgICAgICAgICAgICAgIDwveHM6Y29tcGxleFR5cGU+DQogICAgICAgICAgICAgIDwveHM6ZWxlbWVudD4NCiAgICAgICAgICAgIDwveHM6c2VxdWVuY2U+DQogICAgICAgICAgPC94czpjb21wbGV4VHlwZT4NCiAgICAgICAgPC94czplbGVtZW50Pg0KICAgICAgICA8eHM6ZWxlbWVudCBtYXhPY2N1cnM9InVuYm91bmRlZCIgbmFtZT0iUGVyaW9kIj4NCiAgICAgICAgICA8eHM6Y29tcGxleFR5cGU+DQogICAgICAgICAgICA8eHM6c2VxdWVuY2U+DQogICAgICAgICAgICAgIDx4czplbGVtZW50IG5hbWU9IlN5c3RlbUVudHJ5S2V5IiB0eXBlPSJ4czp1bnNpZ25lZEJ5dGUiIC8+DQogICAgICAgICAgICAgIDx4czplbGVtZW50IG5hbWU9IklEIiB0eXBlPSJ4czp1bnNpZ25lZEJ5dGUiIC8+DQogICAgICAgICAgICAgIDx4czplbGVtZW50IG5hbWU9IkNyZWF0ZWRBdCIgdHlwZT0ieHM6ZGF0ZVRpbWUiIC8+DQogICAgICAgICAgICAgIDx4czplbGVtZW50IG5hbWU9IkdyYW5kVG90YWwiIHR5cGU9InhzOmRlY2ltYWwiIC8+DQogICAgICAgICAgICAgIDx4czplbGVtZW50IG5hbWU9IlBlcnBldHVhbEdyYW5kVG90YWwiIHR5cGU9InhzOmRlY2ltYWwiIC8+DQogICAgICAgICAgICAgIDx4czplbGVtZW50IG5hbWU9IlNpZ25hdHVyZSIgdHlwZT0ieHM6c3RyaW5nIiAvPg0KICAgICAgICAgICAgICA8eHM6ZWxlbWVudCBuYW1lPSJUYXhMaW5lcyI+DQogICAgICAgICAgICAgICAgPHhzOmNvbXBsZXhUeXBlPg0KICAgICAgICAgICAgICAgICAgPHhzOnNlcXVlbmNlIG1pbk9jY3Vycz0iMCI+DQogICAgICAgICAgICAgICAgICAgIDx4czplbGVtZW50IG1heE9jY3Vycz0idW5ib3VuZGVkIiBuYW1lPSJUYXhMaW5lIj4NCiAgICAgICAgICAgICAgICAgICAgICA8eHM6Y29tcGxleFR5cGU+DQogICAgICAgICAgICAgICAgICAgICAgICA8eHM6c2VxdWVuY2U+DQogICAgICAgICAgICAgICAgICAgICAgICAgIDx4czplbGVtZW50IG5hbWU9IlRheElkZW50aWZpZXIiIHR5cGU9InhzOnN0cmluZyIgLz4NCiAgICAgICAgICAgICAgICAgICAgICAgICAgPHhzOmVsZW1lbnQgbmFtZT0iVGF4UmF0ZSIgdHlwZT0ieHM6dW5zaWduZWRCeXRlIiAvPg0KICAgICAgICAgICAgICAgICAgICAgICAgICA8eHM6ZWxlbWVudCBuYW1lPSJUYXhCYXNlQW1vdW50IiB0eXBlPSJ4czpkZWNpbWFsIiAvPg0KICAgICAgICAgICAgICAgICAgICAgICAgICA8eHM6ZWxlbWVudCBuYW1lPSJUYXhBbW91bnQiIHR5cGU9InhzOmRlY2ltYWwiIC8+DQogICAgICAgICAgICAgICAgICAgICAgICA8L3hzOnNlcXVlbmNlPg0KICAgICAgICAgICAgICAgICAgICAgIDwveHM6Y29tcGxleFR5cGU+DQogICAgICAgICAgICAgICAgICAgIDwveHM6ZWxlbWVudD4NCiAgICAgICAgICAgICAgICAgIDwveHM6c2VxdWVuY2U+DQogICAgICAgICAgICAgICAgPC94czpjb21wbGV4VHlwZT4NCiAgICAgICAgICAgICAgPC94czplbGVtZW50Pg0KICAgICAgICAgICAgICA8eHM6ZWxlbWVudCBtaW5PY2N1cnM9IjAiIG1heE9jY3Vycz0idW5ib3VuZGVkIiBuYW1lPSJUaWNrZXQiPg0KICAgICAgICAgICAgICAgIDx4czpjb21wbGV4VHlwZT4NCiAgICAgICAgICAgICAgICAgIDx4czpzZXF1ZW5jZT4NCiAgICAgICAgICAgICAgICAgICAgPHhzOmVsZW1lbnQgbmFtZT0iU3lzdGVtRW50cnlLZXkiIHR5cGU9InhzOnVuc2lnbmVkU2hvcnQiIC8+DQogICAgICAgICAgICAgICAgICAgIDx4czplbGVtZW50IG5hbWU9IkRvY3VtZW50TnVtYmVyIiB0eXBlPSJ4czpzdHJpbmciIC8+DQogICAgICAgICAgICAgICAgICAgIDx4czplbGVtZW50IG5hbWU9Ik5vT2ZQcmludHMiIHR5cGU9InhzOnVuc2lnbmVkQnl0ZSIgLz4NCiAgICAgICAgICAgICAgICAgICAgPHhzOmVsZW1lbnQgbmFtZT0iU2FsZXNwZXJzb25Db2RlIiB0eXBlPSJ4czp1bnNpZ25lZEJ5dGUiIC8+DQogICAgICAgICAgICAgICAgICAgIDx4czplbGVtZW50IG5hbWU9IlBPU0NvZGUiIHR5cGU9InhzOnVuc2lnbmVkQnl0ZSIgLz4NCiAgICAgICAgICAgICAgICAgICAgPHhzOmVsZW1lbnQgbmFtZT0iRGF0ZSIgdHlwZT0ieHM6ZGF0ZSIgLz4NCiAgICAgICAgICAgICAgICAgICAgPHhzOmVsZW1lbnQgbmFtZT0iVGltZSIgdHlwZT0ieHM6dGltZSIgLz4NCiAgICAgICAgICAgICAgICAgICAgPHhzOmVsZW1lbnQgbmFtZT0iT3BlcmF0aW9uVHlwZSIgdHlwZT0ieHM6dW5zaWduZWRCeXRlIiAvPg0KICAgICAgICAgICAgICAgICAgICA8eHM6ZWxlbWVudCBuYW1lPSJEb2N1bWVudFR5cGUiIHR5cGU9InhzOnN0cmluZyIgLz4NCiAgICAgICAgICAgICAgICAgICAgPHhzOmVsZW1lbnQgbmFtZT0iTm9PZlNhbGVMaW5lcyIgdHlwZT0ieHM6dW5zaWduZWRCeXRlIiAvPg0KICAgICAgICAgICAgICAgICAgICA8eHM6ZWxlbWVudCBuYW1lPSJTaWduYXR1cmUiIHR5cGU9InhzOnN0cmluZyIgLz4NCiAgICAgICAgICAgICAgICAgICAgPHhzOmVsZW1lbnQgbmFtZT0iUmVsYXRlZEluZm8iPg0KICAgICAgICAgICAgICAgICAgICAgIDx4czpjb21wbGV4VHlwZT4NCiAgICAgICAgICAgICAgICAgICAgICAgIDx4czpzZXF1ZW5jZT4NCiAgICAgICAgICAgICAgICAgICAgICAgICAgPHhzOmVsZW1lbnQgbmFtZT0iU29mdHdhcmVWZXJzaW9uIiB0eXBlPSJ4czpkZWNpbWFsIiAvPg0KICAgICAgICAgICAgICAgICAgICAgICAgICA8eHM6ZWxlbWVudCBuYW1lPSJTdG9yZU5hbWUiIHR5cGU9InhzOnN0cmluZyIgLz4NCiAgICAgICAgICAgICAgICAgICAgICAgICAgPHhzOmVsZW1lbnQgbmFtZT0iU3RvcmVOYW1lMiIgLz4NCiAgICAgICAgICAgICAgICAgICAgICAgICAgPHhzOmVsZW1lbnQgbmFtZT0iU3RvcmVBZGRyZXNzIiB0eXBlPSJ4czpzdHJpbmciIC8+DQogICAgICAgICAgICAgICAgICAgICAgICAgIDx4czplbGVtZW50IG5hbWU9IlN0b3JlQWRkcmVzczIiIC8+DQogICAgICAgICAgICAgICAgICAgICAgICAgIDx4czplbGVtZW50IG5hbWU9IlN0b3JlUG9zdENvZGUiIHR5cGU9InhzOnVuc2lnbmVkU2hvcnQiIC8+DQogICAgICAgICAgICAgICAgICAgICAgICAgIDx4czplbGVtZW50IG5hbWU9IlN0b3JlQ2l0eSIgdHlwZT0ieHM6c3RyaW5nIiAvPg0KICAgICAgICAgICAgICAgICAgICAgICAgICA8eHM6ZWxlbWVudCBuYW1lPSJTaXJldCIgdHlwZT0ieHM6c3RyaW5nIiAvPg0KICAgICAgICAgICAgICAgICAgICAgICAgICA8eHM6ZWxlbWVudCBuYW1lPSJBUEUiIHR5cGU9InhzOnN0cmluZyIgLz4NCiAgICAgICAgICAgICAgICAgICAgICAgICAgPHhzOmVsZW1lbnQgbmFtZT0iSW50cmFDb21tVkFUSWRlbnRpZmllciIgdHlwZT0ieHM6c3RyaW5nIiAvPg0KICAgICAgICAgICAgICAgICAgICAgICAgICA8eHM6ZWxlbWVudCBuYW1lPSJTYWxlc3BlcnNvbk5hbWUiIHR5cGU9InhzOnN0cmluZyIgLz4NCiAgICAgICAgICAgICAgICAgICAgICAgIDwveHM6c2VxdWVuY2U+DQogICAgICAgICAgICAgICAgICAgICAgPC94czpjb21wbGV4VHlwZT4NCiAgICAgICAgICAgICAgICAgICAgPC94czplbGVtZW50Pg0KICAgICAgICAgICAgICAgICAgICA8eHM6ZWxlbWVudCBuYW1lPSJTYWxlc0xpbmVzIj4NCiAgICAgICAgICAgICAgICAgICAgICA8eHM6Y29tcGxleFR5cGU+DQogICAgICAgICAgICAgICAgICAgICAgICA8eHM6c2VxdWVuY2U+DQogICAgICAgICAgICAgICAgICAgICAgICAgIDx4czplbGVtZW50IG1heE9jY3Vycz0idW5ib3VuZGVkIiBuYW1lPSJTYWxlc0xpbmUiPg0KICAgICAgICAgICAgICAgICAgICAgICAgICAgIDx4czpjb21wbGV4VHlwZT4NCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIDx4czpzZXF1ZW5jZT4NCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgPHhzOmVsZW1lbnQgbmFtZT0iTGluZU5vIiB0eXBlPSJ4czp1bnNpZ25lZFNob3J0IiAvPg0KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICA8eHM6ZWxlbWVudCBuYW1lPSJQcm9kdWN0Q29kZSIgdHlwZT0ieHM6dW5zaWduZWRJbnQiIC8+DQogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIDx4czplbGVtZW50IG5hbWU9IlByb2R1Y3RMYWJlbCIgdHlwZT0ieHM6c3RyaW5nIiAvPg0KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICA8eHM6ZWxlbWVudCBuYW1lPSJRdWFudGl0eSIgdHlwZT0ieHM6ZGVjaW1hbCIgLz4NCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgPHhzOmVsZW1lbnQgbmFtZT0iVGF4SWRlbnRpZmllciIgdHlwZT0ieHM6c3RyaW5nIiAvPg0KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICA8eHM6ZWxlbWVudCBuYW1lPSJUYXhSYXRlIiB0eXBlPSJ4czpkZWNpbWFsIiAvPg0KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICA8eHM6ZWxlbWVudCBuYW1lPSJVbml0UHJpY2VJbmNsVGF4IiB0eXBlPSJ4czpkZWNpbWFsIiAvPg0KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICA8eHM6ZWxlbWVudCBuYW1lPSJEaXNjb3VudENvZGUiIC8+DQogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIDx4czplbGVtZW50IG5hbWU9IkRpc2NvdW50UGVyY2VudGFnZSIgdHlwZT0ieHM6ZGVjaW1hbCIgLz4NCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgPHhzOmVsZW1lbnQgbmFtZT0iRGlzY291bnRBbW91bnQiIHR5cGU9InhzOmRlY2ltYWwiIC8+DQogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIDx4czplbGVtZW50IG5hbWU9IlRvdGFsRXhjbFRheCIgdHlwZT0ieHM6ZGVjaW1hbCIgLz4NCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgPHhzOmVsZW1lbnQgbmFtZT0iVG90YWxJbmNsVGF4IiB0eXBlPSJ4czpkZWNpbWFsIiAvPg0KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICA8eHM6ZWxlbWVudCBuYW1lPSJCYXNlUXVhbnRpdHkiIHR5cGU9InhzOmRlY2ltYWwiIC8+DQogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIDx4czplbGVtZW50IG5hbWU9IlVuaXRPZk1lYXN1cmVDb2RlIiB0eXBlPSJ4czpzdHJpbmciIC8+DQogICAgICAgICAgICAgICAgICAgICAgICAgICAgICA8L3hzOnNlcXVlbmNlPg0KICAgICAgICAgICAgICAgICAgICAgICAgICAgIDwveHM6Y29tcGxleFR5cGU+DQogICAgICAgICAgICAgICAgICAgICAgICAgIDwveHM6ZWxlbWVudD4NCiAgICAgICAgICAgICAgICAgICAgICAgIDwveHM6c2VxdWVuY2U+DQogICAgICAgICAgICAgICAgICAgICAgPC94czpjb21wbGV4VHlwZT4NCiAgICAgICAgICAgICAgICAgICAgPC94czplbGVtZW50Pg0KICAgICAgICAgICAgICAgICAgICA8eHM6ZWxlbWVudCBuYW1lPSJUYXhMaW5lcyI+DQogICAgICAgICAgICAgICAgICAgICAgPHhzOmNvbXBsZXhUeXBlPg0KICAgICAgICAgICAgICAgICAgICAgICAgPHhzOnNlcXVlbmNlPg0KICAgICAgICAgICAgICAgICAgICAgICAgICA8eHM6ZWxlbWVudCBtYXhPY2N1cnM9InVuYm91bmRlZCIgbmFtZT0iVGF4TGluZSI+DQogICAgICAgICAgICAgICAgICAgICAgICAgICAgPHhzOmNvbXBsZXhUeXBlPg0KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgPHhzOnNlcXVlbmNlPg0KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICA8eHM6ZWxlbWVudCBuYW1lPSJUYXhJZGVudGlmaWVyIiB0eXBlPSJ4czpzdHJpbmciIC8+DQogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIDx4czplbGVtZW50IG5hbWU9IlRheEJhc2VBbW91bnQiIHR5cGU9InhzOmRlY2ltYWwiIC8+DQogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIDx4czplbGVtZW50IG5hbWU9IlRheFJhdGUiIHR5cGU9InhzOnVuc2lnbmVkQnl0ZSIgLz4NCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgPHhzOmVsZW1lbnQgbmFtZT0iVGF4QW1vdW50IiB0eXBlPSJ4czpkZWNpbWFsIiAvPg0KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICA8eHM6ZWxlbWVudCBuYW1lPSJBbW91bnRJbmNsVGF4IiB0eXBlPSJ4czpkZWNpbWFsIiAvPg0KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgPC94czpzZXF1ZW5jZT4NCiAgICAgICAgICAgICAgICAgICAgICAgICAgICA8L3hzOmNvbXBsZXhUeXBlPg0KICAgICAgICAgICAgICAgICAgICAgICAgICA8L3hzOmVsZW1lbnQ+DQogICAgICAgICAgICAgICAgICAgICAgICA8L3hzOnNlcXVlbmNlPg0KICAgICAgICAgICAgICAgICAgICAgIDwveHM6Y29tcGxleFR5cGU+DQogICAgICAgICAgICAgICAgICAgIDwveHM6ZWxlbWVudD4NCiAgICAgICAgICAgICAgICAgICAgPHhzOmVsZW1lbnQgbmFtZT0iVGlja2V0VG90YWxzIj4NCiAgICAgICAgICAgICAgICAgICAgICA8eHM6Y29tcGxleFR5cGU+DQogICAgICAgICAgICAgICAgICAgICAgICA8eHM6c2VxdWVuY2U+DQogICAgICAgICAgICAgICAgICAgICAgICAgIDx4czplbGVtZW50IG5hbWU9IlRvdGFsSW5jbFRheCIgdHlwZT0ieHM6ZGVjaW1hbCIgLz4NCiAgICAgICAgICAgICAgICAgICAgICAgICAgPHhzOmVsZW1lbnQgbmFtZT0iVG90YWxFeGNsVGF4IiB0eXBlPSJ4czpkZWNpbWFsIiAvPg0KICAgICAgICAgICAgICAgICAgICAgICAgICA8eHM6ZWxlbWVudCBuYW1lPSJQZXJwZXR1YWxHcmFuZFRvdGFsIiB0eXBlPSJ4czpkZWNpbWFsIiAvPg0KICAgICAgICAgICAgICAgICAgICAgICAgICA8eHM6ZWxlbWVudCBuYW1lPSJHcmFuZFRvdGFsU2lnbmF0dXJlIiB0eXBlPSJ4czpzdHJpbmciIC8+DQogICAgICAgICAgICAgICAgICAgICAgICA8L3hzOnNlcXVlbmNlPg0KICAgICAgICAgICAgICAgICAgICAgIDwveHM6Y29tcGxleFR5cGU+DQogICAgICAgICAgICAgICAgICAgIDwveHM6ZWxlbWVudD4NCiAgICAgICAgICAgICAgICAgICAgPHhzOmVsZW1lbnQgbmFtZT0iUGF5bWVudExpbmVzIj4NCiAgICAgICAgICAgICAgICAgICAgICA8eHM6Y29tcGxleFR5cGU+DQogICAgICAgICAgICAgICAgICAgICAgICA8eHM6c2VxdWVuY2U+DQogICAgICAgICAgICAgICAgICAgICAgICAgIDx4czplbGVtZW50IG1heE9jY3Vycz0idW5ib3VuZGVkIiBuYW1lPSJQYXltZW50TGluZSI+DQogICAgICAgICAgICAgICAgICAgICAgICAgICAgPHhzOmNvbXBsZXhUeXBlPg0KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgPHhzOnNlcXVlbmNlPg0KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICA8eHM6ZWxlbWVudCBuYW1lPSJDb2RlIiB0eXBlPSJ4czpzdHJpbmciIC8+DQogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIDx4czplbGVtZW50IG5hbWU9IlR5cGUiIHR5cGU9InhzOnN0cmluZyIgLz4NCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgPHhzOmVsZW1lbnQgbmFtZT0iRGVzY3JpcHRpb24iIHR5cGU9InhzOnN0cmluZyIgLz4NCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgPHhzOmVsZW1lbnQgbmFtZT0iQW1vdW50IiB0eXBlPSJ4czpkZWNpbWFsIiAvPg0KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICA8eHM6ZWxlbWVudCBuYW1lPSJDdXJyZW5jeSIgdHlwZT0ieHM6c3RyaW5nIiAvPg0KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICA8eHM6ZWxlbWVudCBuYW1lPSJDdXJyZW5jeUFtb3VudCIgdHlwZT0ieHM6ZGVjaW1hbCIgLz4NCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgPHhzOmVsZW1lbnQgbmFtZT0iRXhjaGFuZ2VSYXRlIiB0eXBlPSJ4czp1bnNpZ25lZEJ5dGUiIC8+DQogICAgICAgICAgICAgICAgICAgICAgICAgICAgICA8L3hzOnNlcXVlbmNlPg0KICAgICAgICAgICAgICAgICAgICAgICAgICAgIDwveHM6Y29tcGxleFR5cGU+DQogICAgICAgICAgICAgICAgICAgICAgICAgIDwveHM6ZWxlbWVudD4NCiAgICAgICAgICAgICAgICAgICAgICAgIDwveHM6c2VxdWVuY2U+DQogICAgICAgICAgICAgICAgICAgICAgPC94czpjb21wbGV4VHlwZT4NCiAgICAgICAgICAgICAgICAgICAgPC94czplbGVtZW50Pg0KICAgICAgICAgICAgICAgICAgICA8eHM6ZWxlbWVudCBuYW1lPSJQcmludER1cGxpY2F0ZXMiPg0KICAgICAgICAgICAgICAgICAgICAgIDx4czpjb21wbGV4VHlwZT4NCiAgICAgICAgICAgICAgICAgICAgICAgIDx4czpzZXF1ZW5jZSBtaW5PY2N1cnM9IjAiPg0KICAgICAgICAgICAgICAgICAgICAgICAgICA8eHM6ZWxlbWVudCBtYXhPY2N1cnM9InVuYm91bmRlZCIgbmFtZT0iUHJpbnREdXBsaWNhdGUiPg0KICAgICAgICAgICAgICAgICAgICAgICAgICAgIDx4czpjb21wbGV4VHlwZT4NCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIDx4czpzZXF1ZW5jZT4NCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgPHhzOmVsZW1lbnQgbmFtZT0iSUQiIHR5cGU9InhzOnN0cmluZyIgLz4NCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgPHhzOmVsZW1lbnQgbmFtZT0iUmVwcmludE51bWJlciIgdHlwZT0ieHM6dW5zaWduZWRCeXRlIiAvPg0KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICA8eHM6ZWxlbWVudCBuYW1lPSJTYWxlc3BlcnNvbkNvZGUiIHR5cGU9InhzOnVuc2lnbmVkQnl0ZSIgLz4NCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgPHhzOmVsZW1lbnQgbmFtZT0iVXNlckNvZGUiIHR5cGU9InhzOnN0cmluZyIgLz4NCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgPHhzOmVsZW1lbnQgbmFtZT0iVGltZXN0YW1wIiB0eXBlPSJ4czpkYXRlVGltZSIgLz4NCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgPHhzOmVsZW1lbnQgbmFtZT0iU2lnbmF0dXJlIiB0eXBlPSJ4czpzdHJpbmciIC8+DQogICAgICAgICAgICAgICAgICAgICAgICAgICAgICA8L3hzOnNlcXVlbmNlPg0KICAgICAgICAgICAgICAgICAgICAgICAgICAgIDwveHM6Y29tcGxleFR5cGU+DQogICAgICAgICAgICAgICAgICAgICAgICAgIDwveHM6ZWxlbWVudD4NCiAgICAgICAgICAgICAgICAgICAgICAgIDwveHM6c2VxdWVuY2U+DQogICAgICAgICAgICAgICAgICAgICAgPC94czpjb21wbGV4VHlwZT4NCiAgICAgICAgICAgICAgICAgICAgPC94czplbGVtZW50Pg0KICAgICAgICAgICAgICAgICAgICA8eHM6ZWxlbWVudCBuYW1lPSJBc3NvY2lhdGVkRG9jdW1lbnRzIj4NCiAgICAgICAgICAgICAgICAgICAgICA8eHM6Y29tcGxleFR5cGU+DQogICAgICAgICAgICAgICAgICAgICAgICA8eHM6c2VxdWVuY2UgbWluT2NjdXJzPSIwIj4NCiAgICAgICAgICAgICAgICAgICAgICAgICAgPHhzOmVsZW1lbnQgbWluT2NjdXJzPSIwIiBuYW1lPSJBcHBsaWVkQ3JlZGl0Vm91Y2hlciI+DQogICAgICAgICAgICAgICAgICAgICAgICAgICAgPHhzOmNvbXBsZXhUeXBlPg0KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgPHhzOnNlcXVlbmNlPg0KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICA8eHM6ZWxlbWVudCBuYW1lPSJWb3VjaGVyTm8iIHR5cGU9InhzOnVuc2lnbmVkTG9uZyIgLz4NCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgPHhzOmVsZW1lbnQgbmFtZT0iQW1vdW50IiB0eXBlPSJ4czpkZWNpbWFsIiAvPg0KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgPC94czpzZXF1ZW5jZT4NCiAgICAgICAgICAgICAgICAgICAgICAgICAgICA8L3hzOmNvbXBsZXhUeXBlPg0KICAgICAgICAgICAgICAgICAgICAgICAgICA8L3hzOmVsZW1lbnQ+DQogICAgICAgICAgICAgICAgICAgICAgICAgIDx4czplbGVtZW50IG1pbk9jY3Vycz0iMCIgbmFtZT0iSXNzdWVkQ3JlZGl0Vm91Y2hlciI+DQogICAgICAgICAgICAgICAgICAgICAgICAgICAgPHhzOmNvbXBsZXhUeXBlPg0KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgPHhzOnNlcXVlbmNlPg0KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICA8eHM6ZWxlbWVudCBuYW1lPSJWb3VjaGVyTm8iIHR5cGU9InhzOnVuc2lnbmVkTG9uZyIgLz4NCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgPHhzOmVsZW1lbnQgbmFtZT0iQW1vdW50IiB0eXBlPSJ4czpkZWNpbWFsIiAvPg0KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgPC94czpzZXF1ZW5jZT4NCiAgICAgICAgICAgICAgICAgICAgICAgICAgICA8L3hzOmNvbXBsZXhUeXBlPg0KICAgICAgICAgICAgICAgICAgICAgICAgICA8L3hzOmVsZW1lbnQ+DQogICAgICAgICAgICAgICAgICAgICAgICAgIDx4czplbGVtZW50IG1pbk9jY3Vycz0iMCIgbmFtZT0iQXBwbGllZEdpZnRWb3VjaGVyIj4NCiAgICAgICAgICAgICAgICAgICAgICAgICAgICA8eHM6Y29tcGxleFR5cGU+DQogICAgICAgICAgICAgICAgICAgICAgICAgICAgICA8eHM6c2VxdWVuY2U+DQogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIDx4czplbGVtZW50IG5hbWU9IlZvdWNoZXJObyIgdHlwZT0ieHM6dW5zaWduZWRMb25nIiAvPg0KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICA8eHM6ZWxlbWVudCBuYW1lPSJBbW91bnQiIHR5cGU9InhzOmRlY2ltYWwiIC8+DQogICAgICAgICAgICAgICAgICAgICAgICAgICAgICA8L3hzOnNlcXVlbmNlPg0KICAgICAgICAgICAgICAgICAgICAgICAgICAgIDwveHM6Y29tcGxleFR5cGU+DQogICAgICAgICAgICAgICAgICAgICAgICAgIDwveHM6ZWxlbWVudD4NCiAgICAgICAgICAgICAgICAgICAgICAgICAgPHhzOmVsZW1lbnQgbWluT2NjdXJzPSIwIiBuYW1lPSJJc3N1ZWRHaWZ0Vm91Y2hlciI+DQogICAgICAgICAgICAgICAgICAgICAgICAgICAgPHhzOmNvbXBsZXhUeXBlPg0KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgPHhzOnNlcXVlbmNlPg0KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICA8eHM6ZWxlbWVudCBuYW1lPSJWb3VjaGVyTm8iIHR5cGU9InhzOnVuc2lnbmVkTG9uZyIgLz4NCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgPHhzOmVsZW1lbnQgbmFtZT0iQW1vdW50IiB0eXBlPSJ4czpkZWNpbWFsIiAvPg0KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgPC94czpzZXF1ZW5jZT4NCiAgICAgICAgICAgICAgICAgICAgICAgICAgICA8L3hzOmNvbXBsZXhUeXBlPg0KICAgICAgICAgICAgICAgICAgICAgICAgICA8L3hzOmVsZW1lbnQ+DQogICAgICAgICAgICAgICAgICAgICAgICA8L3hzOnNlcXVlbmNlPg0KICAgICAgICAgICAgICAgICAgICAgIDwveHM6Y29tcGxleFR5cGU+DQogICAgICAgICAgICAgICAgICAgIDwveHM6ZWxlbWVudD4NCiAgICAgICAgICAgICAgICAgIDwveHM6c2VxdWVuY2U+DQogICAgICAgICAgICAgICAgPC94czpjb21wbGV4VHlwZT4NCiAgICAgICAgICAgICAgPC94czplbGVtZW50Pg0KICAgICAgICAgICAgPC94czpzZXF1ZW5jZT4NCiAgICAgICAgICA8L3hzOmNvbXBsZXhUeXBlPg0KICAgICAgICA8L3hzOmVsZW1lbnQ+DQogICAgICAgIDx4czplbGVtZW50IG5hbWU9IkpFVCI+DQogICAgICAgICAgPHhzOmNvbXBsZXhUeXBlPg0KICAgICAgICAgICAgPHhzOnNlcXVlbmNlPg0KICAgICAgICAgICAgICA8eHM6ZWxlbWVudCBtYXhPY2N1cnM9InVuYm91bmRlZCIgbmFtZT0iSkVURW50cnkiPg0KICAgICAgICAgICAgICAgIDx4czpjb21wbGV4VHlwZT4NCiAgICAgICAgICAgICAgICAgIDx4czpzZXF1ZW5jZT4NCiAgICAgICAgICAgICAgICAgICAgPHhzOmVsZW1lbnQgbmFtZT0iSUQiIHR5cGU9InhzOnN0cmluZyIgLz4NCiAgICAgICAgICAgICAgICAgICAgPHhzOmVsZW1lbnQgbmFtZT0iQ29kZSIgdHlwZT0ieHM6dW5zaWduZWRCeXRlIiAvPg0KICAgICAgICAgICAgICAgICAgICA8eHM6ZWxlbWVudCBuYW1lPSJEZXNjcmlwdGlvbiIgdHlwZT0ieHM6c3RyaW5nIiAvPg0KICAgICAgICAgICAgICAgICAgICA8eHM6ZWxlbWVudCBuYW1lPSJTYWxlc3BlcnNvbiIgdHlwZT0ieHM6dW5zaWduZWRCeXRlIiAvPg0KICAgICAgICAgICAgICAgICAgICA8eHM6ZWxlbWVudCBuYW1lPSJUaW1lc3RhbXAiIHR5cGU9InhzOmRhdGVUaW1lIiAvPg0KICAgICAgICAgICAgICAgICAgICA8eHM6ZWxlbWVudCBuYW1lPSJBZGRpdGlvbmFsSW5mbyIgLz4NCiAgICAgICAgICAgICAgICAgICAgPHhzOmVsZW1lbnQgbmFtZT0iU2lnbmF0dXJlIiB0eXBlPSJ4czpzdHJpbmciIC8+DQogICAgICAgICAgICAgICAgICA8L3hzOnNlcXVlbmNlPg0KICAgICAgICAgICAgICAgIDwveHM6Y29tcGxleFR5cGU+DQogICAgICAgICAgICAgIDwveHM6ZWxlbWVudD4NCiAgICAgICAgICAgIDwveHM6c2VxdWVuY2U+DQogICAgICAgICAgPC94czpjb21wbGV4VHlwZT4NCiAgICAgICAgPC94czplbGVtZW50Pg0KICAgICAgPC94czpzZXF1ZW5jZT4NCiAgICA8L3hzOmNvbXBsZXhUeXBlPg0KICA8L3hzOmVsZW1lbnQ+DQo8L3hzOnNjaGVtYT4='
        ));
    end;

    local procedure ValidateNextSignature(var POSAuditLog: Record "NPR POS Audit Log"; PreviousSignature: Text; ValidateSignatureChunk: Boolean): Text
    var
        Assert: Codeunit Assert;
        SignatureBaseValueParts: List of [Text];
    begin
        POSAuditLog.FindFirst();
        Assert.IsTrue(POSAuditLog."Electronic Signature".HasValue, 'Event must be signed');
        if ValidateSignatureChunk then begin
            SignatureBaseValueParts := GetSignatureBaseValue(POSAuditLog).Split(',');
            Assert.AreEqual(PreviousSignature, SignatureBaseValueParts.Get(SignatureBaseValueParts.Count), 'Last chunk of signed data must be equal to previous event signature');
        end;
        exit(GetSignatureValue(POSAuditLog));
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;

    [ModalPageHandler]
    procedure PageHandler_POSPaymentBinCheckpoint_LookupOK(var UIEndOfDay: Page "NPR POS Payment Bin Checkpoint"; var ActionResponse: Action)
    begin
        UIEndOfDay.DoOnOpenPageProcessing();
        UIEndOfDay.DoOnClosePageProcessing();
        ActionResponse := Action::LookupOK;
    end;
}