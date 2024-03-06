codeunit 85107 "NPR MM Loyalty Test"
{
    Subtype = Test;

    var
        _LastMembership: Record "NPR MM Membership";
        _LastMember: Record "NPR MM Member";
        _LastMemberCard: Record "NPR MM Member Card";
        _POSUnit: Record "NPR POS Unit";
        _POSPaymentMethod: Record "NPR POS Payment Method";
        _POSStore: Record "NPR POS Store";
        _LoyaltySetup: Record "NPR MM Loyalty Setup";
        _POSSession: Codeunit "NPR POS Session";
        _POSSale: Codeunit "NPR POS Sale";
        _Assert: Codeunit "Assert";
        _IsMembershipInitialized: Boolean;
        _isSalesInitialized: Boolean;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PosEndOfSale_GenericAward()
    var
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSActionMemberMgt: Codeunit "NPR POS Action Member MgtWF3-B";

        Item: Record Item;
        DialogMethod: Option CARD_SCAN,FACIAL_RECOGNITION,NO_PROMPT;
        SaleEnded: Boolean;
        UnitPrice: Decimal;
    begin
        UnitPrice := 100;

        InitializeSales();
        InitializeFixedMembershipSetup();
        CreateMembership('T-320102');

        LibraryPOSMock.CreateItemLine(_POSSession, CreateItem(Item, UnitPrice), 1);

        _LastMembership.Find();
        _LastMembership.TestField("Awarded Points (Sale)", 0);

        if POSActionMemberMgt.SelectMembership(DialogMethod::NO_PROMPT, _LastMemberCard."External Card No.", '', false) = 0 then
            Error('Error assigning membership to sales.');

        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethod.Code, UnitPrice, '');

        _LastMembership.Find();
        _LastMembership.TestField("Awarded Points (Sale)", CalculateEarnPointsFromAmount(UnitPrice, _LoyaltySetup."Amount Factor", 1));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PosEndOfSale_ItemRule_NotApplicable()
    var
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSActionMemberMgt: Codeunit "NPR POS Action Member MgtWF3-B";

        Item: Record Item;
        ItemLoyalty: Record "NPR MM Loy. Item Point Setup";
        DialogMethod: Option CARD_SCAN,FACIAL_RECOGNITION,NO_PROMPT;
        SaleEnded: Boolean;
        UnitPrice: Decimal;
    begin
        UnitPrice := 100;

        InitializeFixedMembershipSetup();
        InitializeSales();
        CreateMembership('T-320102');
        CreateItem(Item, UnitPrice);

        _LoyaltySetup."Point Base" := _LoyaltySetup."Point Base"::AMOUNT_ITEM_SETUP;
        _LoyaltySetup.Modify();

        ItemLoyalty.Code := _LoyaltySetup.Code;
        ItemLoyalty."Line No." := 1;
        ItemLoyalty.Type := ItemLoyalty.Type::Item;
        ItemLoyalty."No." := Item."No.";
        // When award is set to Not Applicable, amount factor and points should be ignored - numbers from Loyalty Setup should apply
        ItemLoyalty.Award := ItemLoyalty.Award::NA;
        ItemLoyalty."Amount Factor" := 3.14;
        ItemLoyalty.Points := 117;
        ItemLoyalty.Constraint := ItemLoyalty.Constraint::INCLUDE;
        ItemLoyalty.Insert();

        _LastMembership.Find();
        _LastMembership.TestField("Awarded Points (Sale)", 0);

        LibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);
        if POSActionMemberMgt.SelectMembership(DialogMethod::NO_PROMPT, _LastMemberCard."External Card No.", '', false) = 0 then
            Error('Error assigning membership to sales.');

        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethod.Code, UnitPrice, '');

        _LastMembership.Find();
        _LastMembership.TestField("Awarded Points (Sale)", CalculateEarnPointsFromAmount(UnitPrice, _LoyaltySetup."Amount Factor", 1));
        _LastMembership.TestField("Remaining Points", CalculateEarnPointsFromAmount(UnitPrice, _LoyaltySetup."Amount Factor", 1));

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PosEndOfSale_ItemRule_Amount()
    var
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSActionMemberMgt: Codeunit "NPR POS Action Member MgtWF3-B";

        Item: Record Item;
        ItemLoyalty: Record "NPR MM Loy. Item Point Setup";
        DialogMethod: Option CARD_SCAN,FACIAL_RECOGNITION,NO_PROMPT;
        SaleEnded: Boolean;
        UnitPrice: Decimal;
    begin
        UnitPrice := 100;

        InitializeSales();
        InitializeFixedMembershipSetup();
        CreateMembership('T-320102');
        CreateItem(Item, UnitPrice);

        _LoyaltySetup."Point Base" := _LoyaltySetup."Point Base"::AMOUNT_ITEM_SETUP;
        _LoyaltySetup.Modify();

        ItemLoyalty.Code := _LoyaltySetup.Code;
        ItemLoyalty."Line No." := 1;
        ItemLoyalty.Type := ItemLoyalty.Type::Item;
        ItemLoyalty."No." := Item."No.";
        ItemLoyalty.Award := ItemLoyalty.Award::AMOUNT;
        ItemLoyalty."Amount Factor" := 3.14;
        ItemLoyalty.Points := 117;
        ItemLoyalty.Constraint := ItemLoyalty.Constraint::INCLUDE;
        ItemLoyalty.Insert();

        _LastMembership.Find();
        _LastMembership.TestField("Awarded Points (Sale)", 0);

        LibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);
        if POSActionMemberMgt.SelectMembership(DialogMethod::NO_PROMPT, _LastMemberCard."External Card No.", '', false) = 0 then
            Error('Error assigning membership to sales.');

        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethod.Code, UnitPrice, '');

        _LastMembership.Find();
        _LastMembership.TestField("Awarded Points (Sale)", CalculateEarnPointsFromAmount(UnitPrice, ItemLoyalty."Amount Factor" * _LoyaltySetup."Amount Factor", 1));

    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PosEndOfSale_ItemRule_AmountItemPoints()
    var
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSActionMemberMgt: Codeunit "NPR POS Action Member MgtWF3-B";

        Item: Record Item;
        ItemLoyalty: Record "NPR MM Loy. Item Point Setup";
        DialogMethod: Option CARD_SCAN,FACIAL_RECOGNITION,NO_PROMPT;
        SaleEnded: Boolean;
        UnitPrice: Decimal;
    begin
        UnitPrice := 100;

        InitializeSales();
        InitializeFixedMembershipSetup();
        CreateMembership('T-320102');
        CreateItem(Item, UnitPrice);

        _LoyaltySetup."Point Base" := _LoyaltySetup."Point Base"::AMOUNT_ITEM_SETUP;
        _LoyaltySetup.Modify();

        ItemLoyalty.Code := _LoyaltySetup.Code;
        ItemLoyalty."Line No." := 1;
        ItemLoyalty.Type := ItemLoyalty.Type::Item;
        ItemLoyalty."No." := Item."No.";
        ItemLoyalty.Award := ItemLoyalty.Award::POINTS_AND_AMOUNT;
        ItemLoyalty."Amount Factor" := 3.14;
        ItemLoyalty.Points := 117;
        ItemLoyalty.Constraint := ItemLoyalty.Constraint::INCLUDE;
        ItemLoyalty.Insert();

        _LastMembership.Find();
        _LastMembership.TestField("Awarded Points (Sale)", 0);

        LibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);
        if POSActionMemberMgt.SelectMembership(DialogMethod::NO_PROMPT, _LastMemberCard."External Card No.", '', false) = 0 then
            Error('Error assigning membership to sales.');

        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethod.Code, UnitPrice, '');

        _LastMembership.Find();
        _LastMembership.TestField("Awarded Points (Sale)", CalculateEarnPointsFromAmount(UnitPrice, ItemLoyalty."Amount Factor" * _LoyaltySetup."Amount Factor", 1) + ItemLoyalty.Points);

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PosEndOfSale_ItemRule_ItemPoints()
    var
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSActionMemberMgt: Codeunit "NPR POS Action Member MgtWF3-B";
        Item: Record Item;
        ItemLoyalty: Record "NPR MM Loy. Item Point Setup";
        DialogMethod: Option CARD_SCAN,FACIAL_RECOGNITION,NO_PROMPT;
        SaleEnded: Boolean;
        UnitPrice: Decimal;
    begin
        UnitPrice := 100;

        InitializeSales();
        InitializeFixedMembershipSetup();
        CreateMembership('T-320102');
        CreateItem(Item, UnitPrice);

        _LoyaltySetup."Point Base" := _LoyaltySetup."Point Base"::AMOUNT_ITEM_SETUP;
        _LoyaltySetup.Modify();

        ItemLoyalty.Code := _LoyaltySetup.Code;
        ItemLoyalty."Line No." := 1;
        ItemLoyalty.Type := ItemLoyalty.Type::Item;
        ItemLoyalty."No." := Item."No.";
        ItemLoyalty.Award := ItemLoyalty.Award::POINTS;
        ItemLoyalty."Amount Factor" := 3.23;
        ItemLoyalty.Points := 117;
        ItemLoyalty.Constraint := ItemLoyalty.Constraint::INCLUDE;
        ItemLoyalty.Insert();

        _LastMembership.Find();

        _Assert.AreEqual(0, _LastMembership."Awarded Points (Sale)", 'Unexpected initial value.');
        _Assert.AreEqual(0, _LastMembership."Awarded Points (Refund)", 'Unexpected initial value.');
        // Sale
        LibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);
        if POSActionMemberMgt.SelectMembership(DialogMethod::NO_PROMPT, _LastMemberCard."External Card No.", '', false) = 0 then
            Error('Error assigning membership to sales.');

        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethod.Code, UnitPrice, '');

        _LastMembership.Find();
        _Assert.AreEqual(ItemLoyalty.Points, _LastMembership."Awarded Points (Sale)", 'Incorrect points after sale.');
        _Assert.AreEqual(0, _LastMembership."Awarded Points (Refund)", 'Incorrect points after sale.');

        // Refund
        InitializeSales();
        LibraryPOSMock.CreateItemLine(_POSSession, Item."No.", -1);
        if POSActionMemberMgt.SelectMembership(DialogMethod::NO_PROMPT, _LastMemberCard."External Card No.", '', false) = 0 then
            Error('Error assigning membership to sales.');

        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethod.Code, -1 * UnitPrice, '');

        _LastMembership.Find();
        _Assert.AreEqual(ItemLoyalty.Points, _LastMembership."Awarded Points (Sale)", 'Incorrect points after refund.');
        _Assert.AreEqual(ItemLoyalty.Points * -1, _LastMembership."Awarded Points (Refund)", 'Incorrect points after refund.');
        _Assert.AreEqual(0, _LastMembership."Remaining Points", 'Incorrect points after refund.');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RemoteMaster_AsYouGo_Earn()
    var
        LibraryLoyalty: Codeunit "NPR Library MemberLoyalty";

        ClientLoyaltyPointsMgr: Codeunit "NPR MM Loy. Point Mgr (Client)";
        TempAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary;
        TempSalesLinesRequest: Record "NPR MM Reg. Sales Buffer" temporary;
        TempPaymentLinesRequest: Record "NPR MM Reg. Sales Buffer" temporary;
        TempPointsResponse: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary;
        ImportEntry: Record "NPR Nc Import Entry";
        RequestXmlText: Text;
        ResponseCode: Code[20];
        ResponseMessage: Text;
        DocumentId: Text;
    begin
        SetScenario_100(TempAuthorization, TempSalesLinesRequest, TempPaymentLinesRequest);

        RequestXmlText := ClientLoyaltyPointsMgr.CreateRegisterSaleTestXml(TempAuthorization, TempSalesLinesRequest, TempPaymentLinesRequest);
        LibraryLoyalty.Simulate_RegisterSale_SOAPAction(RequestXmlText, ResponseCode, ResponseMessage, TempPointsResponse, DocumentId);

        TempPointsResponse.FindFirst();

        ImportEntry.SetFilter("Document ID", '=%1', DocumentId);
        ImportEntry.FindFirst();
        ImportEntry.TestField(Imported, true);
        ImportEntry.TestField("Runtime Error", false);

        if (ResponseCode <> 'OK') then
            Error(ResponseMessage);

        _LastMembership.CalcFields("Remaining Points", "Awarded Points (Sale)");
        _Assert.AreEqual(TempSalesLinesRequest."Total Points", _LastMembership."Remaining Points", 'Membership remaining points does not matched earned points.');
        _Assert.AreEqual(TempSalesLinesRequest."Total Points", _LastMembership."Awarded Points (Sale)", 'Membership awarded points does not matched earned points.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RemoteMaster_AsYouGo_Reserve()
    var
        LibraryLoyalty: Codeunit "NPR Library MemberLoyalty";

        ClientLoyaltyPointsMgr: Codeunit "NPR MM Loy. Point Mgr (Client)";
        TempAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary;
        TempSalesLinesRequest: Record "NPR MM Reg. Sales Buffer" temporary;
        TempPaymentLinesRequest: Record "NPR MM Reg. Sales Buffer" temporary;
        TempPointsResponse: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary;
        ImportEntry: Record "NPR Nc Import Entry";
        RequestXmlText: Text;
        ResponseCode: Code[20];
        ResponseMessage: Text;
        DocumentId: Text;
    begin
        SetScenario_100(TempAuthorization, TempSalesLinesRequest, TempPaymentLinesRequest);

        TempPaymentLinesRequest.FindFirst();
        TempPaymentLinesRequest."Total Points" := 100;
        TempPaymentLinesRequest.Modify();

        RequestXmlText := ClientLoyaltyPointsMgr.CreateReservePointsTestXml(TempAuthorization, TempPaymentLinesRequest);
        LibraryLoyalty.Simulate_ReservePoints_SOAPAction(RequestXmlText, ResponseCode, ResponseMessage, TempPointsResponse, DocumentId);

        ImportEntry.SetFilter("Document ID", '=%1', DocumentId);
        ImportEntry.FindFirst();
        ImportEntry.TestField(Imported, true);
        ImportEntry.TestField("Runtime Error", false);

        if (ResponseCode = 'OK') then
            Error('This test should fail because membership has no points yet.');
    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RemoteMaster_AsYouGo_EarnAndBurn_01()
    var
        LibraryLoyalty: Codeunit "NPR Library MemberLoyalty";

        ClientLoyaltyPointsMgr: Codeunit "NPR MM Loy. Point Mgr (Client)";
        TempAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary;
        TempSalesLinesRequest: Record "NPR MM Reg. Sales Buffer" temporary;
        TempPaymentLinesRequest: Record "NPR MM Reg. Sales Buffer" temporary;
        TempPointsResponse: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary;
        RequestXmlText: Text;
        ResponseCode: Code[20];
        ResponseMessage: Text;
        DocumentId: Text;
        PointsToEarn, PointsToBurn : Integer;
        ReservationToken: Text[40];
        LoyaltyCode: Code[20];
        Qty: Decimal;
        Amount: Decimal;
        Points: Integer;
    begin
        LoyaltyCode := SetScenario_100(TempAuthorization, TempSalesLinesRequest, TempPaymentLinesRequest);

        // This test over-reserves amount of points it then uses to pay. All reserved points are spent.
        // Earn points on sale
        PointsToEarn := SetPointsToEarn(Random(1000) + 10000, TempSalesLinesRequest); // Earn more point then we will burn
        RequestXmlText := ClientLoyaltyPointsMgr.CreateRegisterSaleTestXml(TempAuthorization, TempSalesLinesRequest, TempPaymentLinesRequest);
        LibraryLoyalty.Simulate_RegisterSale_SOAPAction(RequestXmlText, ResponseCode, ResponseMessage, TempPointsResponse, DocumentId);

        if (ResponseCode <> 'OK') then
            Error('Earn points failed: %1 - %2', ResponseCode, ResponseMessage);

        TempPointsResponse.FindFirst();
        _LastMembership.CalcFields("Remaining Points", "Awarded Points (Sale)");
        _Assert.AreEqual(TempSalesLinesRequest."Total Points", _LastMembership."Remaining Points", 'Membership remaining points does not matched earned points.');
        _Assert.AreEqual(TempSalesLinesRequest."Total Points", _LastMembership."Awarded Points (Sale)", 'Membership awarded points does not matched earned points.');

        // Prepare next request
        TempSalesLinesRequest.DeleteAll();
        TempPaymentLinesRequest.DeleteAll();
        TempPointsResponse.DeleteAll();

        TempAuthorization."Reference Number" := GenerateSafeCode20();
        TempAuthorization.Modify();

        // Reserve points to burn
        PointsToBurn := PointsToEarn; // Reserve all point available
        LibraryLoyalty.CreatePaymentLine(0, PointsToBurn, '', TempPaymentLinesRequest);
        RequestXmlText := ClientLoyaltyPointsMgr.CreateReservePointsTestXml(TempAuthorization, TempPaymentLinesRequest);
        LibraryLoyalty.Simulate_ReservePoints_SOAPAction(RequestXmlText, ResponseCode, ResponseMessage, TempPointsResponse, DocumentId);

        if (ResponseCode <> 'OK') then
            Error('Reserve points failed: %1 - %2', ResponseCode, ResponseMessage);

        TempPointsResponse.FindFirst();
        ReservationToken := TempPointsResponse."Authorization Code";

        // Prepare next request
        TempSalesLinesRequest.DeleteAll();
        TempPaymentLinesRequest.DeleteAll();
        TempPointsResponse.DeleteAll();

        TempAuthorization."Reference Number" := GenerateSafeCode20();
        TempAuthorization.Modify();

        // Pay with points on sale. "Overpay" with points. 
        LibraryLoyalty.GenerateQtyAmtPointsBurn(LoyaltyCode, Qty, Amount, Points);
        LibraryLoyalty.CreateSaleLine(GenerateSafeCode20(), GenerateSafeCode10(), Qty, Amount, Points, TempSalesLinesRequest);
        LibraryLoyalty.CreatePaymentLine(Amount, PointsToBurn, ReservationToken, TempPaymentLinesRequest);

        RequestXmlText := ClientLoyaltyPointsMgr.CreateRegisterSaleTestXml(TempAuthorization, TempSalesLinesRequest, TempPaymentLinesRequest);
        LibraryLoyalty.Simulate_RegisterSale_SOAPAction(RequestXmlText, ResponseCode, ResponseMessage, TempPointsResponse, DocumentId);

        if (ResponseCode <> 'OK') then
            Error('Earn and burn points failed: %1 - %2', ResponseCode, ResponseMessage);

        _LastMembership.CalcFields("Remaining Points", "Awarded Points (Sale)");
        _Assert.AreEqual(0, _LastMembership."Remaining Points", 'Membership remaining points does not matched earned points.');
        _Assert.AreEqual(PointsToEarn + Points, _LastMembership."Awarded Points (Sale)", 'Membership awarded points does not matched earned points.');

    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RemoteMaster_AsYouGo_EarnAndBurn_03()
    var
        LibraryLoyalty: Codeunit "NPR Library MemberLoyalty";

        ClientLoyaltyPointsMgr: Codeunit "NPR MM Loy. Point Mgr (Client)";
        TempAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary;
        TempSalesLinesRequest: Record "NPR MM Reg. Sales Buffer" temporary;
        TempPaymentLinesRequest: Record "NPR MM Reg. Sales Buffer" temporary;
        TempPointsResponse: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary;
        RequestXmlText: Text;
        ResponseCode: Code[20];
        ResponseMessage: Text;
        DocumentId: Text;
        PointsToEarn, PointsToBurn : Integer;
        ReservationToken: Text[40];
        LoyaltyCode: Code[20];
        Qty: Decimal;
        Amount: Decimal;
        Points: Integer;
    begin
        LoyaltyCode := SetScenario_100(TempAuthorization, TempSalesLinesRequest, TempPaymentLinesRequest);

        // Earn points on sale
        PointsToEarn := 170;
        SetPointsToEarn(PointsToEarn, TempSalesLinesRequest);
        RequestXmlText := ClientLoyaltyPointsMgr.CreateRegisterSaleTestXml(TempAuthorization, TempSalesLinesRequest, TempPaymentLinesRequest);
        LibraryLoyalty.Simulate_RegisterSale_SOAPAction(RequestXmlText, ResponseCode, ResponseMessage, TempPointsResponse, DocumentId);

        if (ResponseCode <> 'OK') then
            Error('Earn points failed: %1 - %2', ResponseCode, ResponseMessage);

        TempPointsResponse.FindFirst();
        _LastMembership.CalcFields("Remaining Points", "Awarded Points (Sale)");
        _Assert.AreEqual(TempSalesLinesRequest."Total Points", _LastMembership."Remaining Points", 'Membership remaining points does not matched earned points (1).');
        _Assert.AreEqual(TempSalesLinesRequest."Total Points", _LastMembership."Awarded Points (Sale)", 'Membership awarded points does not matched earned points (1).');

        // Prepare next request
        TempSalesLinesRequest.DeleteAll();
        TempPaymentLinesRequest.DeleteAll();
        TempPointsResponse.DeleteAll();

        TempAuthorization."Reference Number" := GenerateSafeCode20();
        TempAuthorization.Modify();

        // Reserve points to burn
        PointsToBurn := 47;
        LibraryLoyalty.CreatePaymentLine(0, PointsToBurn, '', TempPaymentLinesRequest);
        RequestXmlText := ClientLoyaltyPointsMgr.CreateReservePointsTestXml(TempAuthorization, TempPaymentLinesRequest);
        LibraryLoyalty.Simulate_ReservePoints_SOAPAction(RequestXmlText, ResponseCode, ResponseMessage, TempPointsResponse, DocumentId);

        if (ResponseCode <> 'OK') then
            Error('Reserve points failed: %1 - %2', ResponseCode, ResponseMessage);

        TempPointsResponse.FindFirst();
        ReservationToken := TempPointsResponse."Authorization Code";

        // Prepare next request
        TempSalesLinesRequest.DeleteAll();
        TempPaymentLinesRequest.DeleteAll();
        TempPointsResponse.DeleteAll();

        TempAuthorization."Reference Number" := GenerateSafeCode20();
        TempAuthorization.Modify();

        Qty := 1;
        Amount := 42.49;
        Points := 55;
        LibraryLoyalty.CreateSaleLine(GenerateSafeCode20(), GenerateSafeCode10(), Qty, Amount, Points, TempSalesLinesRequest);
        LibraryLoyalty.CreatePaymentLine(Amount, PointsToBurn, ReservationToken, TempPaymentLinesRequest);

        RequestXmlText := ClientLoyaltyPointsMgr.CreateRegisterSaleTestXml(TempAuthorization, TempSalesLinesRequest, TempPaymentLinesRequest);
        LibraryLoyalty.Simulate_RegisterSale_SOAPAction(RequestXmlText, ResponseCode, ResponseMessage, TempPointsResponse, DocumentId);

        if (ResponseCode <> 'OK') then
            Error('Earn and burn points failed: %1 - %2', ResponseCode, ResponseMessage);

        _LastMembership.CalcFields("Remaining Points", "Awarded Points (Sale)");
        _Assert.AreEqual((PointsToEarn - PointsToBurn), _LastMembership."Remaining Points", 'Membership remaining points does not matched earned points (2).');
        _Assert.AreEqual(PointsToEarn + Points, _LastMembership."Awarded Points (Sale)", 'Membership awarded points does not matched earned points (2).');

    end;

    local procedure InitializeSales()
    var
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
    begin
        LibraryPOSMock.InitializeData(_isSalesInitialized, _POSUnit, _POSStore, _POSPaymentMethod);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, _POSSale);
    end;

    local procedure InitializeFixedMembershipSetup()
    var
        LibraryLoyalty: Codeunit "NPR Library MemberLoyalty";
        ItemLoyalty: Record "NPR MM Loy. Item Point Setup";
    begin

        if (_IsMembershipInitialized) then begin
            ItemLoyalty.SetFilter(Code, '=%1', _LoyaltySetup.Code);
            ItemLoyalty.DeleteAll();
            exit;
        end;

        _LoyaltySetup.Get(LibraryLoyalty.CreateScenario_AsYouGoLoyalty());
        _IsMembershipInitialized := true;
    end;

    local procedure CreateMembership(ItemNo: Code[20])
    var
        MemberApiLibrary: Codeunit "NPR Library - Member XML API";
        MemberLibrary: Codeunit "NPR Library - Member Module";

        ResponseMessage: Text;
        MembershipEntryNo: Integer;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MemberEntryNo: Integer;
    begin

        // Start loyalty test scenario with a BRONZE membership
        if (not MemberApiLibrary.CreateMembership(ItemNo, MembershipEntryNo, ResponseMessage)) then
            Error(ResponseMessage);

        _LastMembership.Reset();
        _LastMembership.Get(MembershipEntryNo);
        _LastMembership.SetRecFilter();
        _LastMembership.SetAutoCalcFields("Awarded Points (Sale)", "Awarded Points (Refund)", "Remaining Points", "Redeemed Points (Deposit)", "Redeemed Points (Withdrawl)", "Expired Points");
        MemberLibrary.SetRandomMemberInfoData(MemberInfoCapture);
        if (not MemberApiLibrary.AddMembershipMember(_LastMembership, MemberInfoCapture, MemberEntryNo, ResponseMessage)) then
            Error(ResponseMessage);

        _LastMember.Reset();
        _LastMember.Get(MemberEntryNo);
        _LastMember.SetRecFilter();

        _LastMemberCard.Reset();
        _LastMemberCard.SetFilter("Membership Entry No.", '=%1', _LastMembership."Entry No.");
        _LastMemberCard.SetFilter("Member Entry No.", '=%1', _LastMember."Entry No.");
        _LastMemberCard.FindFirst();
        _LastMemberCard.SetRecFilter();

    end;

    local procedure CreateItem(var Item: Record Item; UnitPrice: Decimal): Code[20]
    var
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
    begin
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        Item."Unit Price" := UnitPrice;
        Item."Price Includes VAT" := true;
        Item.Modify();

        exit(Item."No.");
    end;

    [Normal]
    local procedure CalculateEarnPointsFromAmount(Amount: Decimal; Factor: Decimal; Quantity: Integer) Points: Integer
    var
        AwardAmount: Decimal;
    begin
        if (not _IsMembershipInitialized) then
            Error('Membership not initialized.');
        AwardAmount := Amount * Factor;
        AwardAmount *= Quantity;

        if (_LoyaltySetup."Rounding on Earning" = _LoyaltySetup."Rounding on Earning"::NEAREST) then
            Points := Round(AwardAmount, 1, '=');
        if (_LoyaltySetup."Rounding on Earning" = _LoyaltySetup."Rounding on Earning"::UP) then
            Points := Round(AwardAmount, 1, '>');
        if (_LoyaltySetup."Rounding on Earning" = _LoyaltySetup."Rounding on Earning"::DOWN) then
            Points := Round(AwardAmount, 1, '<');
    end;



    [Normal]
    local procedure SetPointsToEarn(PointsToEarn: Integer; var TempSaleLines: Record "NPR MM Reg. Sales Buffer" temporary): Integer
    begin
        TempSaleLines.FindFirst();
        TempSaleLines."Total Points" := PointsToEarn;
        TempSaleLines.Modify();
        exit(PointsToEarn);
    end;

    [Normal]
    local procedure SetScenario_100(var TmpTransactionAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary; var TmpRegisterSaleLines: Record "NPR MM Reg. Sales Buffer" temporary; var TmpRegisterPaymentLines: Record "NPR MM Reg. Sales Buffer" temporary): Code[20]
    var
        LibraryLoyalty: Codeunit "NPR Library MemberLoyalty";
        LoyaltySetup: Record "NPR MM Loyalty Setup";
        MembershipSalesItem: Record "NPR MM Members. Sales Setup";
        MembershipSetup: Record "NPR MM Membership Setup";

        Qty: Decimal;
        Amount: Decimal;
        Points: Integer;
        ItemNo: Code[20];
    begin
        ItemNo := LibraryLoyalty.CreateScenario_Loyalty100(TmpTransactionAuthorization, TmpRegisterSaleLines, TmpRegisterPaymentLines);


        MembershipSalesItem.Get(MembershipSalesItem.Type::ITEM, ItemNo);
        MembershipSetup.Get(MembershipSalesItem."Membership Code");
        LoyaltySetup.Get(MembershipSetup."Loyalty Code");

        CreateMembership(ItemNo);

        TmpTransactionAuthorization."Reference Number" := GenerateSafeCode20();
        TmpTransactionAuthorization."Card Number" := _LastMemberCard."External Card No.";
        TmpTransactionAuthorization.Modify();

        LibraryLoyalty.GenerateQtyAmtPointsBurn(LoyaltySetup.Code, Qty, Amount, Points);
        LibraryLoyalty.CreateSaleLine(GenerateSafeCode20(), GenerateSafeCode10(), Qty, Amount, Points, TmpRegisterSaleLines);
        LibraryLoyalty.CreatePaymentLine(Amount, 0, '', TmpRegisterPaymentLines);

        exit(LoyaltySetup.Code);
    end;


    [Normal]
    local procedure GenerateSafeCode10(): Code[10]
    var
        MembershipLibrary: Codeunit "NPR Library - Member Module";
    begin
        exit(MembershipLibrary.GenerateSafeCode10());
    end;

    [Normal]
    local procedure GenerateSafeCode20(): Code[20]
    var
        MembershipLibrary: Codeunit "NPR Library - Member Module";
    begin
        exit(MembershipLibrary.GenerateSafeCode20());
    end;



    [ConfirmHandler]
    procedure ConfirmYesHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [MessageHandler]
    procedure IgnoreMessageHandler(Message: Text[1024])
    begin
    end;

}