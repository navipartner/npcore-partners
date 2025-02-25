codeunit 85224 "NPR AttractionWalletTest"
{
    Subtype = Test;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure WalletCreate()
    var
        WalletFacade: Codeunit "NPR AttractionWalletFacade";
        WalletEntryNo: Integer;
        ReferenceNumber: Text[50];
        AttractionWallet: Record "NPR AttractionWallet";
        Assert: Codeunit "Assert";
    begin
        EnableWallets();
        WalletEntryNo := WalletFacade.CreateWallet('Test Wallet', ReferenceNumber);

        AttractionWallet.Get(WalletEntryNo);
        Assert.IsTrue(AttractionWallet.Description = 'Test Wallet', 'Description should be "Test Wallet"');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure WalletCreate_NotEnabled()
    var
        WalletFacade: Codeunit "NPR AttractionWalletFacade";
        WalletEntryNo: Integer;
        ReferenceNumber: Text[50];
        AttractionWallet: Record "NPR AttractionWallet";
        Assert: Codeunit "Assert";
    begin
        DisableWallets();
        WalletEntryNo := WalletFacade.CreateWallet('Test Wallet', ReferenceNumber);

        asserterror AttractionWallet.Get(WalletEntryNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure WalletCreate_AddTickets()
    var
        WalletFacade: Codeunit "NPR AttractionWalletFacade";
        WalletEntryNo: Integer;
        ReferenceNumber: Text[50];
        AttractionWallet: Record "NPR AttractionWallet";

        TicketIds: List of [Guid];
    begin
        EnableWallets();
        WalletEntryNo := WalletFacade.CreateWallet('Test Wallet', ReferenceNumber);
        AttractionWallet.Get(WalletEntryNo);

        ValidateAddTicketsToWallet(WalletEntryNo, 3);
    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure WalletCreate_AddMemberCards()
    var
        WalletFacade: Codeunit "NPR AttractionWalletFacade";
        WalletEntryNo: Integer;
        ReferenceNumber: Text[50];
        AttractionWallet: Record "NPR AttractionWallet";
        Assert: Codeunit "Assert";
    begin
        EnableWallets();
        WalletEntryNo := WalletFacade.CreateWallet('Test Wallet', ReferenceNumber);
        AttractionWallet.Get(WalletEntryNo);

        ValidateAddMemberCardsToWallet(WalletEntryNo, 3);
    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure WalletCreate_AddTicketMemberCards()
    var
        WalletFacade: Codeunit "NPR AttractionWalletFacade";
        WalletEntryNo: Integer;
        ReferenceNumber: Text[50];
        AttractionWallet: Record "NPR AttractionWallet";
        Assert: Codeunit "Assert";

    begin
        EnableWallets();
        WalletEntryNo := WalletFacade.CreateWallet('Test Wallet', ReferenceNumber);
        AttractionWallet.Get(WalletEntryNo);

        ValidateAddMemberCardsToWallet(WalletEntryNo, 3);
        ValidateAddTicketsToWallet(WalletEntryNo, 5);
    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure WalletCreate_AddWalletReference()
    var
        WalletFacade: Codeunit "NPR AttractionWalletFacade";
        WalletEntryNo: Integer;
        ReferenceNumber: Text[50];
        AttractionWallet: Record "NPR AttractionWallet";
        Assert: Codeunit "Assert";
        ExternalReference: Text[100];
        FindCount: Integer;

        FindWallets: Query "NPR FindAttractionWallets";
    begin
        EnableWallets();
        ExternalReference := StrSubstNo('External Reference %1', Format(CreateGuid(), 0, 4).ToLower());

        WalletEntryNo := WalletFacade.CreateWallet('Test Wallet', ReferenceNumber);
        WalletFacade.SetWalletReferenceNumber(WalletEntryNo, 123, CreateGuid(), ExternalReference);

        AttractionWallet.Get(WalletEntryNo);
        ValidateAddMemberCardsToWallet(WalletEntryNo, 5);
        ValidateAddTicketsToWallet(WalletEntryNo, 3);

        WalletFacade.FindWalletByReferenceNumber(ExternalReference, FindWallets);
        while (FindWallets.Read()) do begin
            Assert.IsTrue(FindWallets.WalletReferenceNumber = AttractionWallet.ReferenceNumber, 'Wallet not found by reference');
            Assert.IsTrue(FindWallets.WalletEntryNo = AttractionWallet.EntryNo, 'Wallet not found by reference');
            FindCount += 1;
        end;

        Assert.IsFalse(FindCount = 0, 'Wallet not found by reference');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure WalletCreate_FindReference()
    var
        WalletFacade: Codeunit "NPR AttractionWalletFacade";
        ExternalReference: Text[100];
        FindWallets: Query "NPR FindAttractionWallets";

        Assert: Codeunit "Assert";
    begin
        ExternalReference := StrSubstNo('not valid %1', Format(CreateGuid(), 0, 4).ToLower());
        WalletFacade.FindWalletByReferenceNumber(ExternalReference, FindWallets);
        Assert.IsFalse(FindWallets.Read(), 'Wallet should not be found');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure WalletCreate_GetWallet()
    var
        WalletFacade: Codeunit "NPR AttractionWalletFacade";
        WalletReference: Text[50];
        WalletAssets: Query "NPR AttractionWalletAssets";

        Assert: Codeunit "Assert";
    begin
        WalletReference := StrSubstNo('not valid %1', Format(CreateGuid(), 0, 4).ToLower());
        WalletFacade.GetWalletAssets(WalletReference, WalletAssets);
        Assert.IsFalse(WalletAssets.Read(), 'Wallet should not be found');
    end;


    procedure EnableWallets()
    var
        Setup: Record "NPR WalletAssetSetup";
    begin
        if (not Setup.Get()) then begin
            Setup.Insert();
        end;

        Setup.Enabled := true;
        Setup.Modify();
    end;

    procedure DisableWallets()
    var
        Setup: Record "NPR WalletAssetSetup";
    begin
        if (not Setup.Get()) then begin
            Setup.Insert();
        end;

        Setup.Enabled := false;
        Setup.Modify();
    end;

    local procedure ValidateAddTicketsToWallet(WalletEntryNo: Integer; QtyToAdd: Integer)
    var
        AttractionWallet: Record "NPR AttractionWallet";
        Ticket: Record "NPR TM Ticket";
        WalletFacade: Codeunit "NPR AttractionWalletFacade";
        WalletAssets: Query "NPR AttractionWalletAssets";
        TicketIds: List of [Guid];
        FindCount: Integer;

        Assert: Codeunit "Assert";
    begin
        AttractionWallet.Get(WalletEntryNo);
        CreateTickets(QtyToAdd);
        Ticket.Find('-');

        repeat
            TicketIds.Add(Ticket.SystemId);
            QtyToAdd -= 1;
            Ticket.Next();
        until (QtyToAdd <= 0);

        WalletFacade.AddTicketsToWallet(WalletEntryNo, TicketIds);

        WalletAssets.SetFilter(WalletAssets.WalletReferenceNumber, '=%1', AttractionWallet.ReferenceNumber);
        WalletAssets.Open;
        while (WalletAssets.Read()) do begin
            if (TicketIds.Contains(WalletAssets.AssetSystemId)) then
                TicketIds.Remove(WalletAssets.AssetSystemId);
            FindCount += 1;
        end;

        Assert.IsTrue((TicketIds.Count() = 0), 'Some tickets seem to be missing the wallet');
        Assert.IsFalse(FindCount = 0, 'Wallet not found by reference');
    end;

    local procedure ValidateAddMemberCardsToWallet(WalletEntryNo: Integer; QtyToAdd: Integer)
    var
        AttractionWallet: Record "NPR AttractionWallet";
        MemberCard: Record "NPR MM Member Card";
        WalletFacade: Codeunit "NPR AttractionWalletFacade";
        WalletAssets: Query "NPR AttractionWalletAssets";
        MemberCardIds: List of [Guid];
        FindCount, i : Integer;
        MemberTests: Codeunit "NPR MM API Smoke Test";


        Assert: Codeunit "Assert";
    begin
        AttractionWallet.Get(WalletEntryNo);

        for i := 1 to QtyToAdd do
            MemberTests.AddMemberCard();

        MemberCard.Find('-');
        repeat
            MemberCardIds.Add(MemberCard.SystemId);
            QtyToAdd -= 1;
            MemberCard.Next();
        until (QtyToAdd <= 0);

        WalletFacade.AddMemberCardsToWallet(WalletEntryNo, MemberCardIds);

        WalletAssets.SetFilter(WalletAssets.WalletReferenceNumber, '=%1', AttractionWallet.ReferenceNumber);
        WalletAssets.Open;
        while (WalletAssets.Read()) do begin
            if (MemberCardIds.Contains(WalletAssets.AssetSystemId)) then
                MemberCardIds.Remove(WalletAssets.AssetSystemId);
            FindCount += 1;
        end;

        Assert.IsTrue((MemberCardIds.Count() = 0), 'Some tickets seem to be missing the wallet');
        Assert.IsFalse(FindCount = 0, 'Wallet not found by reference');
    end;

    [Normal]
    procedure CreateTickets(QtyToAdd: Integer)
    var
        TicketLibrary: Codeunit "NPR Library - Ticket Module";

        TmpCreatedTickets: Record "NPR TM Ticket" temporary;
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        Assert: Codeunit "Assert";
        ItemNo: Code[20];
        ResponseToken: Text;
        ResponseMessage: Text;
        ApiOk: Boolean;
        NumberOfTicketOrders: Integer;
        TicketQuantityPerOrder: Integer;
        MemberNumber: Code[20];
        ScannerStation: Code[10];
        SendNotificationTo: Text;
        ExternalOrderNo: Text;
    begin

        ItemNo := TicketLibrary.CreateScenario_SmokeTest();

        NumberOfTicketOrders := QtyToAdd;
        TicketQuantityPerOrder := 1;

        ApiOk := TicketApiLibrary.MakeReservation(NumberOfTicketOrders, ItemNo, TicketQuantityPerOrder, MemberNumber, ScannerStation, ResponseToken, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);

        ExternalOrderNo := 'abc'; // Note: Without External Order No., the ticket will not be valid for arrival, capacity will be allocated only.
        ApiOk := TicketApiLibrary.ConfirmTicketReservation(ResponseToken, SendNotificationTo, ExternalOrderNo, ScannerStation, TmpCreatedTickets, ResponseMessage);
        Assert.IsTrue(ApiOk, ResponseMessage);
        Assert.AreEqual(TmpCreatedTickets.Count(), NumberOfTicketOrders * TicketQuantityPerOrder, 'Number of tickets confirmed does not match number of tickets requested.');
    end;

}