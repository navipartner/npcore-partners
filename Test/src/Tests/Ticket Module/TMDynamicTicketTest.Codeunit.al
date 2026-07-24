codeunit 85056 "NPR TM Dynamic Ticket Test"
{
    Subtype = Test;

    var
        Initialized: Boolean;
        TicketItemNo: Code[20];

        TicketBOMElements, RequiredBOMElements : Integer;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MakeDynamicTicketReservationAPI()
    var
        TicketReservationReq: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        TmpCreatedTickets: Record "NPR TM Ticket" temporary;
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        Assert: Codeunit Assert;
        ReservationOk: Boolean;
        ResponseToken, ResponseMessage : Text;
    begin
        InitializeData();

        // Make reservation
        ReservationOk := TicketApiLibrary.MakeDynamicReservation(1, TicketItemNo, 1, '', '', ResponseToken, ResponseMessage);
        Assert.IsTrue(ReservationOk, ResponseMessage);

        // Check Reservation Request
        TicketReservationReq.SetRange("Session Token ID", ResponseToken);
        Assert.AreEqual(TicketBOMElements, TicketReservationReq.Count(), 'Reservation request line count not as expected');

        // Check Ticket
        TicketReservationReq.SetRange(Default, true);
        TicketReservationReq.FindFirst();
        Ticket.SetRange("Ticket Reservation Entry No.", TicketReservationReq."Entry No.");
        Assert.IsTrue(Ticket.FindFirst(), 'Ticket not found');

        // Check Admissions 
        TicketAccessEntry.SetRange("Ticket No.", Ticket."No.");
        Assert.AreEqual(RequiredBOMElements, TicketAccessEntry.Count(), 'Ticket admission line count not as expected');

        //Confirm reservation
        ReservationOk := TicketApiLibrary.ConfirmTicketReservation(ResponseToken, '', '', '', TmpCreatedTickets, ResponseMessage);
        Assert.IsTrue(ReservationOk, ResponseMessage);
    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MakeDynamicTicketReservationAPI_2()
    var
        TicketReservationReq: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        TmpCreatedTickets: Record "NPR TM Ticket" temporary;
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        Assert: Codeunit Assert;
        ReservationOk: Boolean;
        ResponseToken, ResponseMessage : Text;
        OptionalIncludeCount: Integer;
    begin
        InitializeData();
        OptionalIncludeCount := 1;

        // Make reservation
        ReservationOk := TicketApiLibrary.MakeDynamicReservation2(1, TicketItemNo, 1, '', '', OptionalIncludeCount, ResponseToken, ResponseMessage);
        Assert.IsTrue(ReservationOk, ResponseMessage);

        // Check Reservation Request
        TicketReservationReq.SetRange("Session Token ID", ResponseToken);
        Assert.AreEqual(TicketBOMElements, TicketReservationReq.Count(), 'Reservation request line count not as expected');

        // Check Ticket
        TicketReservationReq.SetRange(Default, true);
        TicketReservationReq.FindFirst();
        Ticket.SetRange("Ticket Reservation Entry No.", TicketReservationReq."Entry No.");
        Assert.IsTrue(Ticket.FindFirst(), 'Ticket not found');

        // Check Admissions 
        TicketAccessEntry.SetRange("Ticket No.", Ticket."No.");
        Assert.AreEqual(RequiredBOMElements + OptionalIncludeCount, TicketAccessEntry.Count(), 'Ticket admission line count not as expected');

        //Confirm reservation
        ReservationOk := TicketApiLibrary.ConfirmTicketReservation(ResponseToken, '', 'PAYMENT_REF_01', '', TmpCreatedTickets, ResponseMessage);
        Assert.IsTrue(ReservationOk, ResponseMessage);

        TicketAccessEntry.SetRange("Ticket No.", Ticket."No.");
        TicketAccessEntry.FindSet();
        repeat
            DetTicketAccessEntry.Reset();
            DetTicketAccessEntry.SetRange("Ticket Access Entry No.", TicketAccessEntry."Entry No.");
            DetTicketAccessEntry.SetFilter(Type, '=%1|=%2|=%3', DetTicketAccessEntry.Type::PAYMENT, DetTicketAccessEntry.Type::PREPAID, DetTicketAccessEntry.Type::POSTPAID);
            Assert.AreEqual(1, DetTicketAccessEntry.Count(), StrSubstNo('Expected exactly one payment entry for admission %1', TicketAccessEntry."Admission Code"));
        until (TicketAccessEntry.Next() = 0);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Make2DynamicTicketsReservationAPI()
    var
        TicketReservationReq: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        TmpCreatedTickets: Record "NPR TM Ticket" temporary;
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        Assert: Codeunit Assert;
        ReservationOk: Boolean;
        ResponseToken, ResponseMessage : Text;
    begin
        InitializeData();
        // Make reservation

        ReservationOk := TicketApiLibrary.MakeDynamicReservation(1, TicketItemNo, 2, '', '', ResponseToken, ResponseMessage);
        Assert.IsTrue(ReservationOk, ResponseMessage);
        // Check Reservation Request

        TicketReservationReq.SetRange("Session Token ID", ResponseToken);
        Assert.AreEqual(TicketBOMElements, TicketReservationReq.Count(), 'Reservation request line count not as expected');

        // Check Ticket
        TicketReservationReq.SetRange(Default, true);
        TicketReservationReq.FindFirst();
        Ticket.SetRange("Ticket Reservation Entry No.", TicketReservationReq."Entry No.");
        Assert.IsTrue(Ticket.FindFirst(), 'Ticket not found');

        // Check Admissions
        TicketAccessEntry.SetRange("Ticket No.", Ticket."No.");
        Assert.AreEqual(RequiredBOMElements, TicketAccessEntry.Count(), 'Ticket admission line count not as expected');

        //Confirm reservation
        ReservationOk := TicketApiLibrary.ConfirmTicketReservation(ResponseToken, '', '', '', TmpCreatedTickets, ResponseMessage);
        Assert.IsTrue(ReservationOk, ResponseMessage);
    end;



    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Make2DynamicTicketsReservationAPI_2()
    var
        TicketReservationReq: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        TmpCreatedTickets: Record "NPR TM Ticket" temporary;
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        Assert: Codeunit Assert;
        ReservationOk: Boolean;
        ResponseToken, ResponseMessage : Text;
        OptionalIncludeCount: Integer;
    begin
        InitializeData();
        OptionalIncludeCount := 2;

        // Make reservation
        ReservationOk := TicketApiLibrary.MakeDynamicReservation2(1, TicketItemNo, 2, '', '', OptionalIncludeCount, ResponseToken, ResponseMessage);
        Assert.IsTrue(ReservationOk, ResponseMessage);

        // Check Reservation Request
        TicketReservationReq.SetRange("Session Token ID", ResponseToken);
        Assert.AreEqual(TicketBOMElements, TicketReservationReq.Count(), 'Reservation request line count not as expected');

        // Check Ticket
        TicketReservationReq.SetRange(Default, true);
        TicketReservationReq.FindFirst();
        Ticket.SetRange("Ticket Reservation Entry No.", TicketReservationReq."Entry No.");
        Assert.IsTrue(Ticket.FindFirst(), 'Ticket not found');

        // Check Admissions
        TicketAccessEntry.SetRange("Ticket No.", Ticket."No.");
        Assert.AreEqual(RequiredBOMElements + OptionalIncludeCount, TicketAccessEntry.Count(), 'Ticket admission line count not as expected');

        //Confirm reservation
        ReservationOk := TicketApiLibrary.ConfirmTicketReservation(ResponseToken, '', 'PAYMENT_REF_01', '', TmpCreatedTickets, ResponseMessage);
        Assert.IsTrue(ReservationOk, ResponseMessage);

        TicketAccessEntry.SetRange("Ticket No.", Ticket."No.");
        TicketAccessEntry.FindSet();
        repeat
            DetTicketAccessEntry.Reset();
            DetTicketAccessEntry.SetRange("Ticket Access Entry No.", TicketAccessEntry."Entry No.");
            DetTicketAccessEntry.SetFilter(Type, '=%1|=%2|=%3', DetTicketAccessEntry.Type::PAYMENT, DetTicketAccessEntry.Type::PREPAID, DetTicketAccessEntry.Type::POSTPAID);
            Assert.AreEqual(1, DetTicketAccessEntry.Count(), StrSubstNo('Expected exactly one payment entry for admission %1', TicketAccessEntry."Admission Code"));
        until (TicketAccessEntry.Next() = 0);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Make2DynamicTicketsReservationAPI_3()
    var
        TicketReservationReq: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        TmpCreatedTickets: Record "NPR TM Ticket" temporary;
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        Assert: Codeunit Assert;
        ReservationOk: Boolean;
        ResponseToken, ResponseMessage : Text;
        OptionalIncludeCount: Integer;
    begin
        InitializeData();
        OptionalIncludeCount := 3;

        // Make reservation
        ReservationOk := TicketApiLibrary.MakeDynamicReservation2(1, TicketItemNo, 2, '', '', OptionalIncludeCount, ResponseToken, ResponseMessage);
        Assert.IsTrue(ReservationOk, ResponseMessage);

        // Check Reservation Request
        TicketReservationReq.SetRange("Session Token ID", ResponseToken);
        Assert.AreEqual(TicketBOMElements, TicketReservationReq.Count(), 'Reservation request line count not as expected');

        // Check Ticket
        TicketReservationReq.SetRange(Default, true);
        TicketReservationReq.FindFirst();
        Ticket.SetRange("Ticket Reservation Entry No.", TicketReservationReq."Entry No.");
        Assert.IsTrue(Ticket.FindFirst(), 'Ticket not found');

        // Check Admissions
        TicketAccessEntry.SetRange("Ticket No.", Ticket."No.");
        Assert.AreEqual(RequiredBOMElements + OptionalIncludeCount, TicketAccessEntry.Count(), 'Ticket admission line count not as expected');

        //Confirm reservation
        ReservationOk := TicketApiLibrary.ConfirmTicketReservation(ResponseToken, '', '', '', TmpCreatedTickets, ResponseMessage);
        Assert.IsTrue(ReservationOk, ResponseMessage);
    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MakeDynamicTicketReservationAndChangeAPI()
    var
        TmpCreatedTickets: Record "NPR TM Ticket" temporary;
        TmpCurrentRequest: Record "NPR TM Ticket Reservation Req." temporary;
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        ReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TmpTicketReservationResponse: Record "NPR TM Ticket Reserv. Resp." temporary;
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        Assert: Codeunit Assert;
        ReservationOk: Boolean;
        ChangeToken, ResponseToken, ResponseMessage : Text;
        InitialAdmissionCount, ChangedAmissionCount : Integer;
    begin
        InitializeData();

        // Make reservation
        ReservationOk := TicketApiLibrary.MakeDynamicReservation(1, TicketItemNo, 1, '', '', ResponseToken, ResponseMessage);
        Assert.IsTrue(ReservationOk, ResponseMessage);

        //Confirm reservation
        ReservationOk := TicketApiLibrary.ConfirmTicketReservation(ResponseToken, '', '', '', TmpCreatedTickets, ResponseMessage);
        Assert.IsTrue(ReservationOk, ResponseMessage);

        // Change reservation
        TmpCreatedTickets.FindFirst();
        ReservationRequest.Get(TmpCreatedTickets."Ticket Reservation Entry No.");
        ReservationOk := TicketApiLibrary.GetTicketChangeRequest(TmpCreatedTickets."External Ticket No.", ReservationRequest."Authorization Code", ChangeToken, TmpCurrentRequest, ResponseMessage);
        Assert.IsTrue(ReservationOk, ResponseMessage);
        TicketAccessEntry.SetRange("Ticket No.", TmpCreatedTickets."No.");
        InitialAdmissionCount := TicketAccessEntry.Count();
        Assert.AreEqual(RequiredBOMElements, InitialAdmissionCount, 'Ticket admission line count not as expected');

        //Confirm change with added 1 admission
        ReservationOk := TicketApiLibrary.ConfirmChangeDynamicTicketReservation(ChangeToken, TmpCurrentRequest, TmpTicketReservationResponse, ResponseMessage);
        Assert.IsTrue(ReservationOk, ResponseMessage);

        //Check result
        TicketAccessEntry.SetRange("Ticket No.", TmpCreatedTickets."No.");
        ChangedAmissionCount := TicketAccessEntry.Count();
        Assert.AreEqual(InitialAdmissionCount + 1, ChangedAmissionCount, 'Ticket admission line count not as expected after change');
    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ConfirmAndAdmitFromToken_AdmitsOnSaleAndSecondCallIsNoOp()
    var
        TicketReservationReq: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        TicketMgt: Codeunit "NPR TM Ticket Management";
        Assert: Codeunit Assert;
        ReservationOk: Boolean;
        ResponseToken, ResponseMessage : Text;
        Token: Text[100];
        PosUnitNo: Code[10];
        OptionalIncludeCount: Integer;
        RequiredAdmitOnSale, RequiredScanOnly, SelectedAdmitOnSale : Code[20];
        FirstAmtInclVat, FirstAmtExclVat, SecondAmtInclVat, SecondAmtExclVat : Decimal;
    begin
        // The POS end-of-sale subscriber calls ConfirmAndAdmitTicketsFromToken once per POS sale line, so a ticket carrying an
        // additional-experience (SELECTED) admission - which spawns a second sale line - gets confirmed twice for the same token.

        // The API reservation gives us a token with genuinely SELECTED optional admissions + issued tickets (the selection the POS
        // UX can't be driven headlessly); two direct calls then stand in for the two sale-line invocations.

        InitializeData();
        OptionalIncludeCount := 2;

        PosUnitNo := CreateLegacyAdmitPosUnit();

        // Distinct amounts so a second re-stamp is detectable
        FirstAmtInclVat := 125;
        FirstAmtExclVat := 100;
        SecondAmtInclVat := 999;
        SecondAmtExclVat := 800;

        // Reservation with SELECTED optional admissions + issued (REGISTERED) tickets
        ReservationOk := TicketApiLibrary.MakeDynamicReservation2(1, TicketItemNo, 1, '', '', OptionalIncludeCount, ResponseToken, ResponseMessage);
        Assert.IsTrue(ReservationOk, ResponseMessage);
        Token := CopyStr(ResponseToken, 1, MaxStrLen(Token));

        TicketReservationReq.SetRange("Session Token ID", Token);
        TicketReservationReq.ModifyAll("Receipt No.", 'TEST'); // Assign a receipt number to the reservation request so it behaves like a POS sale line for the purposes of the test

        // Admit one required + one selected admission on-sale; leave a second required one on-scan as a negative control
        TicketReservationReq.SetRange("Admission Inclusion", TicketReservationReq."Admission Inclusion"::REQUIRED);
        TicketReservationReq.FindSet();
        RequiredAdmitOnSale := TicketReservationReq."Admission Code";
        TicketReservationReq.Next();
        RequiredScanOnly := TicketReservationReq."Admission Code";

        TicketReservationReq.SetRange("Admission Inclusion", TicketReservationReq."Admission Inclusion"::SELECTED);
        TicketReservationReq.FindFirst();
        SelectedAdmitOnSale := TicketReservationReq."Admission Code";

        PatchAdmissionToAdmitOnSale(TicketItemNo, RequiredAdmitOnSale);
        PatchAdmissionToAdmitOnSale(TicketItemNo, SelectedAdmitOnSale);

        // Two direct calls stand in for the ticket line + additional-experience line subscriber firings.
        // First (ticket sale line): confirms + stamps + admits the whole token. Receipt/line args are only error-label decoration.
        TicketMgt.ConfirmAndAdmitTicketsFromToken(Token, 0, 'TEST', 1, PosUnitNo, FirstAmtInclVat, FirstAmtExclVat, FirstAmtInclVat, FirstAmtExclVat);

        // Second (additional-experience sale line): token already confirmed -> -1206 -> must exit without re-stamping/re-admitting
        TicketMgt.ConfirmAndAdmitTicketsFromToken(Token, 0, 'TEST', 1, PosUnitNo, SecondAmtInclVat, SecondAmtExclVat, SecondAmtInclVat, SecondAmtExclVat);

        TicketReservationReq.Reset();
        TicketReservationReq.SetRange("Session Token ID", Token);
        TicketReservationReq.SetRange(Default, true);
        TicketReservationReq.FindFirst();
        Ticket.SetRange("Ticket Reservation Entry No.", TicketReservationReq."Entry No.");
        Assert.IsTrue(Ticket.FindFirst(), 'Ticket not found');

        // Validate that each admission has exactly one payment entry, which is the one created by the first call to ConfirmAndAdmitTicketsFromToken
        TicketAccessEntry.SetRange("Ticket No.", Ticket."No.");
        TicketAccessEntry.FindSet();
        repeat
            DetTicketAccessEntry.Reset();
            DetTicketAccessEntry.SetRange("Ticket Access Entry No.", TicketAccessEntry."Entry No.");
            DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::PAYMENT);
            Assert.AreEqual(1, DetTicketAccessEntry.Count(), StrSubstNo('Expected exactly one payment entry for admission %1', TicketAccessEntry."Admission Code"));
        until (TicketAccessEntry.Next() = 0);

        // Already confirmed: the second ConfirmAndAdmitTicketsFromToken call must NOT have re-stamped the ticket with the experience line's amounts
        Assert.AreEqual(FirstAmtInclVat, Ticket.AmountInclVat, 'Second confirm re-stamped the ticket amount - the already confirmed guard is missing');
        Assert.AreEqual(FirstAmtExclVat, Ticket.AmountExclVat, 'Second confirm re-stamped the ticket amount - the already confirmed guard is missing');

        // Admit guard: on-sale (POS activation) admissions admitted exactly once - "once" also proves the second call did not re-admit;
        // the SCAN-activation admission is not admitted at end of sale
        Assert.AreEqual(1, AdmittedEntryCount(Ticket."No.", RequiredAdmitOnSale), 'Required on-sale admission should be admitted exactly once');
        Assert.AreEqual(1, AdmittedEntryCount(Ticket."No.", SelectedAdmitOnSale), 'Selected on-sale admission should be admitted exactly once');
        Assert.AreEqual(0, AdmittedEntryCount(Ticket."No.", RequiredScanOnly), 'SCAN-activation admission must not be admitted at end of sale');

    end;

    local procedure CreateLegacyAdmitPosUnit(): Code[10]
    var
        POSSetup: Record "NPR POS Setup";
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
        POSPostingProfile: Record "NPR POS Posting Profile";
        TicketProfile: Record "NPR TM POS Ticket Profile";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
    begin
        LibraryPOSMasterData.CreatePOSSetup(POSSetup);
        LibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
        LibraryPOSMasterData.CreatePOSStore(POSStore, POSPostingProfile.Code);
        LibraryPOSMasterData.CreatePOSUnit(POSUnit, POSStore.Code, POSPostingProfile.Code);

        if (not TicketProfile.Get('ATF-LEGACY')) then begin
            TicketProfile.Init();
            TicketProfile.Code := 'ATF-LEGACY';
            TicketProfile.EndOfSaleAdmitMethod := TicketProfile.EndOfSaleAdmitMethod::LEGACY;
            TicketProfile.Insert();
        end;

        POSUnit."POS Ticket Profile" := TicketProfile.Code;
        POSUnit.Modify();
        exit(POSUnit."No.");
    end;

    local procedure PatchAdmissionToAdmitOnSale(ItemNo: Code[20]; AdmissionCode: Code[20])
    var
        TicketBom: Record "NPR TM Ticket Admission BOM";
    begin
        TicketBom.Get(ItemNo, '', AdmissionCode);
        TicketBom."Activation Method" := "NPR TM ActivationMethod_Bom"::POS;
        TicketBom.Modify();
    end;

    local procedure AdmittedEntryCount(TicketNo: Code[20]; AdmissionCode: Code[20]): Integer
    var
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
    begin
        TicketAccessEntry.SetRange("Ticket No.", TicketNo);
        TicketAccessEntry.SetRange("Admission Code", AdmissionCode);
        if (not TicketAccessEntry.FindFirst()) then
            exit(0);

        DetTicketAccessEntry.SetRange("Ticket Access Entry No.", TicketAccessEntry."Entry No.");
        DetTicketAccessEntry.SetRange(Type, DetTicketAccessEntry.Type::ADMITTED);
        exit(DetTicketAccessEntry.Count());
    end;

    procedure InitializeData()
    var
        TicketLibrary: Codeunit "NPR Library - Ticket Module";
    begin
        if not Initialized then begin
            TicketBOMElements := 6;
            RequiredBOMElements := 3;

            TicketItemNo := TicketLibrary.CreateDynamicTicketScenario(TicketBOMElements, RequiredBOMElements);
            Initialized := true;
        end;

        Commit();
    end;
}
