codeunit 85134 "NPR POS Act. MemberArr Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "Assert";
        Initialized: Boolean;
        POSUnit: Record "NPR POS Unit";
        POSSession: Codeunit "NPR POS Session";
        POSStore: Record "NPR POS Store";
        LastMembership: Record "NPR MM Membership";
        LastMember: Record "NPR MM Member";
        ItemNo: Code[20];

    [Test]
    procedure MemberArrival()
    var
        MemberCardNumber: Text[100];
        DialogPrompt: Integer;
        POSWorkflowType: Option;
        AdmissionCode: Code[20];
        DefaultInputValue: Text;
        ShowWelcomeMessage: Boolean;
        POSActionMemberArrival: Codeunit "NPR POS Action: MM Member ArrB";
        DialogMethod: Option CARD_SCAN,FACIAL_RECOGNITION,NO_PROMPT;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSPaymentMethod: Record "NPR POS Payment Method";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        MemberLog: Record "NPR MM Member Arr. Log Entry";
        CardNo: Text[100];
        POSSetup: Codeunit "NPR POS Setup";
    begin
        //[GIVEN] given
        MemberCardNumber := '';
        DefaultInputValue := '';
        DialogPrompt := 1; //Member Card Number
        DialogMethod := DialogMethod::NO_PROMPT;
        ShowWelcomeMessage := false;
        AdmissionCode := '';
        POSWorkflowType := 0; //POSSales

        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore, POSPaymentMethod);
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);

        CardNo := AddMemberCard();
        POSSession.GetSetup(POSSetup);

        POSActionMemberArrival.MemberArrival(ShowWelcomeMessage, DefaultInputValue, DialogMethod, POSWorkflowType, CardNo, AdmissionCode, POSSetup, '');

        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        Assert.IsTrue(SaleLinePOS."No." = ItemNo, 'Member inserted');

        MemberLog.SetRange("Event Type", MemberLog."Event Type"::ARRIVAL);
        MemberLog.SetRange("Local Date", WorkDate());
        MemberLog.SetRange("External Card No.", CardNo);

        Assert.IsTrue(MemberLog.FindFirst(), 'Member log is inserted');
    end;

    procedure CreateMembership()
    var
        MemberApiLibrary: Codeunit "NPR Library - Member XML API";
        MemberLibrary: Codeunit "NPR Library - Member Module";
        LibraryInventory: Codeunit "NPR Library - Inventory";
        ResponseMessage: Text;
        MemberItem: Record Item;
        MemberCommunity: Record "NPR MM Member Community";
        MembershipSetup: Record "NPR MM Membership Setup";
        Membership: Record "NPR MM Membership";
        MembershipEntryNo: Integer;
        MembershipCode: Code[20];
        LoyaltyProgramCode: Code[20];
        Description: Text[50];
        TicketLibrary: Codeunit "NPR Library - Ticket Module";
        Item: Record Item;
        LibraryPOSMaster: Codeunit "NPR Library - POS Master Data";
    begin
        Initialize();
        LibraryInventory.CreateItem(MemberItem);
        MembershipCode := MemberLibrary.GenerateCode20();

        MemberCommunity.Get(MemberLibrary.SetupCommunity_Simple());
        MembershipSetup.Get(MemberLibrary.SetupMembership_Simple(MemberCommunity.Code, MembershipCode, LoyaltyProgramCode, Description));
        MemberLibrary.SetupSimpleMembershipSalesItem(MemberItem."No.", MembershipCode);

        MembershipSetup.Blocked := false;
        ItemNo := TicketLibrary.CreateScenario_SmokeTest();
        Item.Get(ItemNo);
        MembershipSetup.Validate("Ticket Item Barcode", StrSubstNo('IXRF-%1', ItemNo)); // Ticket smoketest scenario creates item cross reference by prefixing item no.
        MembershipSetup.Modify();
        LibraryPOSMaster.CreatePostingSetupForSaleItem(Item, POSUnit, POSStore);
        MemberApiLibrary.CreateMembership(MemberItem."No.", MembershipEntryNo, ResponseMessage);

        Membership.Get(MembershipEntryNo);

        LastMembership := Membership;
    end;

    procedure AddMembershipMember()
    var
        MemberApiLibrary: Codeunit "NPR Library - Member XML API";
        MemberLibrary: Codeunit "NPR Library - Member Module";
        ResponseMessage: Text;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MemberEntryNo: Integer;
    begin
        Initialize();
        CreateMembership();
        MemberLibrary.SetRandomMemberInfoData(MemberInfoCapture);

        MemberApiLibrary.AddMembershipMember(LastMembership, MemberInfoCapture, MemberEntryNo, ResponseMessage);
        LastMember.Get(MemberEntryNo);
    end;

    procedure AddMemberCard(): Text[100];
    var
        MemberApiLibrary: Codeunit "NPR Library - Member XML API";
        ResponseMessage: Text;
        MemberCardEntryNo: Integer;
        CardNumber: Text[100];
    begin
        Initialize();
        CreateMembership();
        AddMembershipMember();

        CardNumber := UpperCase(DelChr(Format(CreateGuid()), '=', '{}-'));
        MemberApiLibrary.AddMemberCard(LastMembership."External Membership No.", LastMember."External Member No.", CardNumber, MemberCardEntryNo, ResponseMessage);
        exit(CardNumber);
    end;

    local procedure Initialize()
    var
        MemberLibrary: Codeunit "NPR Library - Member Module";
    begin
        MemberLibrary.Initialize();
    end;
}