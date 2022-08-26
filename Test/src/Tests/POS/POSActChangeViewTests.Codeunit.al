codeunit 85070 "NPR POS Act. Change View Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "Assert";
        Quantity: Decimal;
        Initialized: Boolean;
        POSUnit: Record "NPR POS Unit";
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSSession: Codeunit "NPR POS Session";
        POSStore: Record "NPR POS Store";
        POSSetup: Record "NPR POS Setup";

    [Test]
    procedure ChangeViewLogin()
    var
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSActionChangeViewB: Codeunit "NPR POS Action: Change View-B";
        CurrentView: Codeunit "NPR POS View";
        ViewType: Option Login,Sale,Payment,Balance,Locked;
        ViewCode: Code[10];
    begin
        //Parameters:
        //ViewCode := ''
        //ViewType := Login

        // [Given] POS & Payment setup
        InitializeData();
        ViewType := ViewType::Login;
        ViewCode := '';

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);

        POSActionChangeViewB.ChangeView(ViewType, ViewCode);
        POSSession.GetCurrentView(CurrentView);

        Assert.IsTrue(CurrentView.Type() = CurrentView.Type() ::Login, Format(CurrentView.Type()));

    end;

    [Test]
    procedure ChangeViewSale()
    var
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSActionChangeViewB: Codeunit "NPR POS Action: Change View-B";
        CurrentView: Codeunit "NPR POS View";
        ViewType: Option Login,Sale,Payment,Balance,Locked;
        ViewCode: Code[10];
    begin
        //Parameters:
        //ViewCode := ''
        //ViewType := Sale

        // [Given] POS & Payment setup
        InitializeData();
        ViewType := ViewType::Sale;
        ViewCode := '';


        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);


        POSActionChangeViewB.ChangeView(ViewType, ViewCode);
        POSSession.GetCurrentView(CurrentView);

        Assert.IsTrue(CurrentView.Type() = CurrentView.Type() ::Sale, Format(CurrentView.Type()));

    end;

    [Test]
    procedure ChangeViewPayment()
    var
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSActionChangeViewB: Codeunit "NPR POS Action: Change View-B";
        CurrentView: Codeunit "NPR POS View";
        ViewType: Option Login,Sale,Payment,Balance,Locked;
        ViewCode: Code[10];
    begin
        //Parameters:
        //ViewCode := ''
        //ViewType := Payment

        // [Given] POS & Payment setup
        InitializeData();
        ViewType := ViewType::Payment;
        ViewCode := '';

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);

        POSActionChangeViewB.ChangeView(ViewType, ViewCode);
        POSSession.GetCurrentView(CurrentView);

        Assert.IsTrue(CurrentView.Type() = CurrentView.Type() ::Payment, Format(CurrentView.Type()));
    end;

    [Test]
    procedure ChangeViewBalance()
    var
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSActionChangeViewB: Codeunit "NPR POS Action: Change View-B";
        CurrentView: Codeunit "NPR POS View";
        ViewType: Option Login,Sale,Payment,Balance,Locked;
        ViewCode: Code[10];
    begin
        //Parameters:
        //ViewCode := ''
        //ViewType := Balance

        // [Given] POS & Payment setup
        InitializeData();
        ViewType := ViewType::Balance;
        ViewCode := '';

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);

        POSActionChangeViewB.ChangeView(ViewType, ViewCode);
        POSSession.GetCurrentView(CurrentView);

        Assert.IsTrue(CurrentView.Type() = CurrentView.Type() ::BalanceRegister, Format(CurrentView.Type()));
    end;

    [Test]
    procedure ChangeViewLocked()
    var
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSActionChangeViewB: Codeunit "NPR POS Action: Change View-B";
        CurrentView: Codeunit "NPR POS View";
        ViewType: Option Login,Sale,Payment,Balance,Locked;
        ViewCode: Code[10];
    begin
        //Parameters:
        //ViewCode := ''
        //ViewType := Locked

        // [Given] POS & Payment setup
        InitializeData();
        ViewType := ViewType::Locked;
        ViewCode := '';

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);

        POSActionChangeViewB.ChangeView(ViewType, ViewCode);
        POSSession.GetCurrentView(CurrentView);

        Assert.IsTrue(CurrentView.Type() = CurrentView.Type() ::Locked, Format(CurrentView.Type()));
    end;



    procedure InitializeData()
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
    begin
        if Initialized then begin
            //Clean any previous mock session
            POSSession.ClearAll();
            Clear(POSSession);
        end;

        if not Initialized then begin
            NPRLibraryPOSMasterData.CreatePOSSetup(POSSetup);
            NPRLibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
            NPRLibraryPOSMasterData.CreatePOSStore(POSStore, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSUnit(POSUnit, POSStore.Code, POSPostingProfile.Code);
            Initialized := true;
        end;

        Commit();
    end;
}