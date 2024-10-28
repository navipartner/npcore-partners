codeunit 85082 "NPR POS Action MemberMgt Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LastMember: Record "NPR MM Member";
        LastMembership: Record "NPR MM Membership";
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSActionMemberMgtWF3B: Codeunit "NPR POS Action Member MgtWF3-B";
        POSSession: Codeunit "NPR POS Session";

        _IsInitialized: Boolean;
        Initialized: Boolean;
        ItemNo: Code[20];

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SelectMembership()
    var
        MMMembership: Record "NPR MM Membership";
        POSSale: Record "NPR POS Sale";
        Assert: Codeunit Assert;
        SalePOS: Codeunit "NPR POS Sale";
        DialogMethod: Option CARD_SCAN,FACIAL_RECOGNITION,NO_PROMPT;
        CardNo: Text[100];
        SelectReq: Boolean;
    begin
        // [Given] 
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore, POSPaymentMethod);
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, SalePOS);
        DialogMethod := DialogMethod::NO_PROMPT;
        SelectReq := false;
        CardNo := AddMemberCard();
        // [When]
        POSActionMemberMgtWF3B.SelectMembership(DialogMethod, CardNo, '', SelectReq);
        // [Then]
        POSSession.GetSale(SalePOS);
        SalePOS.GetCurrentSale(POSSale);
        MMMembership.Get(LastMembership."Entry No.");
        Assert.AreEqual(POSSale."Customer No.", MMMembership."Customer No.", 'Customer was not updated.');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MemberRegisterArrival()
    var
        MemberLog: Record "NPR MM Member Arr. Log Entry";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        DialogMethod: Option CARD_SCAN,FACIAL_RECOGNITION,NO_PROMPT;
        CardNo: Text[100];
    begin
        // [Given] 
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore, POSPaymentMethod);
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        DialogMethod := DialogMethod::NO_PROMPT;
        CardNo := AddMemberCard();
        // [When]
        POSActionMemberMgtWF3B.POSMemberArrival(DialogMethod, CardNo, '');
        // [Then]
        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        Assert.IsTrue(SaleLinePOS."No." = ItemNo, 'Member not inserted');

        MemberLog.SetRange("Event Type", MemberLog."Event Type"::ARRIVAL);
        MemberLog.SetRange("Local Date", WorkDate());
        MemberLog.SetRange("External Card No.", CardNo);

        Assert.IsTrue(MemberLog.FindFirst(), 'Member log not inserted');
    end;



    [Test]
    [HandlerFunctions('MemberList_CancelOnLookup')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ShowMemberWithoutCardNo()
    var
        POSSale: Codeunit "NPR POS Sale";
        DialogMethod: Option CARD_SCAN,FACIAL_RECOGNITION,NO_PROMPT;
        CardNo: Text[100];
    begin
        // [Given]
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore, POSPaymentMethod);
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        DialogMethod := DialogMethod::NO_PROMPT;
        // [When] Card No is not provided
        asserterror POSActionMemberMgtWF3B.ShowMember(DialogMethod, CardNo, '');
        // Card is not selected, error is expected
    end;

    [Test]
    [HandlerFunctions('MemberCard_OnLookup')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EditActiveMembership()
    var
        POSSale: Codeunit "NPR POS Sale";
        DialogMethod: Option CARD_SCAN,FACIAL_RECOGNITION,NO_PROMPT;
        CardNo: Text[100];
        SelectReq: Boolean;
    begin
        // [Given]
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore, POSPaymentMethod);
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        DialogMethod := DialogMethod::NO_PROMPT;
        CardNo := AddMemberCard();
        SelectReq := false;
        // [When]
        POSActionMemberMgtWF3B.SelectMembership(DialogMethod, CardNo, '', SelectReq);
        POSActionMemberMgtWF3B.EditActiveMembership();
        // [Then]
        //page is opened
    end;

    procedure AddMemberCard(): Text[100];
    var
        MemberApiLibrary: Codeunit "NPR Library - Member XML API";
        MemberCardEntryNo: Integer;
        ResponseMessage: Text;
        CardNumber: Text[100];
    begin
        Initialize();
        CreateMembership();
        AddMembershipMember();

        CardNumber := UpperCase(DelChr(Format(CreateGuid()), '=', '{}-'));
        MemberApiLibrary.AddMemberCard(LastMembership."External Membership No.", LastMember."External Member No.", CardNumber, MemberCardEntryNo, ResponseMessage);
        exit(CardNumber);
    end;

    procedure AddMembershipMember()
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MemberLibrary: Codeunit "NPR Library - Member Module";
        MemberApiLibrary: Codeunit "NPR Library - Member XML API";
        MemberEntryNo: Integer;
        ResponseMessage: Text;
    begin
        Initialize();
        CreateMembership();
        MemberLibrary.SetRandomMemberInfoData(MemberInfoCapture);

        MemberApiLibrary.AddMembershipMember(LastMembership, MemberInfoCapture, MemberEntryNo, ResponseMessage);
        LastMember.Get(MemberEntryNo);
    end;

    procedure CreateMembership()
    var
        Item: Record Item;
        MemberItem: Record Item;
        MemberCommunity: Record "NPR MM Member Community";
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        LibrarySales: Codeunit "Library - Sales";
        LibraryInventory: Codeunit "NPR Library - Inventory";
        MemberLibrary: Codeunit "NPR Library - Member Module";
        MemberApiLibrary: Codeunit "NPR Library - Member XML API";
        LibraryPOSMaster: Codeunit "NPR Library - POS Master Data";
        TicketLibrary: Codeunit "NPR Library - Ticket Module";
        LoyaltyProgramCode: Code[20];
        MembershipCode: Code[20];
        MembershipEntryNo: Integer;
        ResponseMessage: Text;
        Description: Text[50];
    begin
        Initialize();
        LibraryInventory.CreateItem(MemberItem);
        LibrarySales.CreateCustomerNo;
        MembershipCode := MemberLibrary.GenerateCode20();

        MemberCommunity.Get(MemberLibrary.SetupCommunity_Simple());
        MembershipSetup.Get(MemberLibrary.SetupMembership_Simple(MemberCommunity.Code, MembershipCode, LoyaltyProgramCode, Description));
        MemberLibrary.SetupSimpleMembershipSalesItem(MemberItem."No.", MembershipCode);

        MembershipSetup.Blocked := false;
        ItemNo := TicketLibrary.CreateScenario_SmokeTest();
        Item.Get(ItemNo);
        MembershipSetup."Ticket Item Type" := MembershipSetup."Ticket Item Type"::ITEM;
        MembershipSetup.Validate("Ticket Item Barcode", ItemNo);
        MembershipSetup.Modify();
        LibraryPOSMaster.CreatePostingSetupForSaleItem(Item, POSUnit, POSStore);
        MemberApiLibrary.CreateMembership(MemberItem."No.", MembershipEntryNo, ResponseMessage);

        Membership.Get(MembershipEntryNo);
        Membership."Customer No." := LibrarySales.CreateCustomerNo;
        Membership.Modify();
        LastMembership := Membership;
    end;

    local procedure Initialize()
    var
        MemberLibrary: Codeunit "NPR Library - Member Module";
    begin
        if (_IsInitialized) then
            exit;

        MemberLibrary.Initialize();
        _IsInitialized := true;

    end;


    [ModalPageHandler]
    procedure MemberList_CancelOnLookup(var MemberList: Page "NPR MM Members"; var ActionResponse: Action)
    begin
        ActionResponse := ActionResponse::Cancel;
    end;


    [ModalPageHandler]
    procedure MemberList_OnLookup(var MemberList: Page "NPR MM Members"; var ActionResponse: Action)
    begin
        ActionResponse := ActionResponse::OK;
    end;


    [ModalPageHandler]
    procedure MemberCard_OnLookup(var MemberCard: Page "NPR MM Membership Card"; var ActionResponse: Action)
    begin
        ActionResponse := ActionResponse::OK;
    end;

}

