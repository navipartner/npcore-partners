codeunit 85070 "NPR POS Act. Change View Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "Assert";
        Initialized: Boolean;
        POSUnit: Record "NPR POS Unit";
        POSSession: Codeunit "NPR POS Session";
        POSStore: Record "NPR POS Store";

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
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
        ViewType := ViewType::Login;
        ViewCode := '';

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);

        POSActionChangeViewB.ChangeView(ViewType, ViewCode);
        POSSession.GetCurrentView(CurrentView);

        Assert.IsTrue(CurrentView.Type() = CurrentView.Type() ::Login, Format(CurrentView.Type()));

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
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
        ViewType := ViewType::Sale;
        ViewCode := '';

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);

        POSActionChangeViewB.ChangeView(ViewType, ViewCode);
        POSSession.GetCurrentView(CurrentView);

        Assert.IsTrue(CurrentView.Type() = CurrentView.Type() ::Sale, Format(CurrentView.Type()));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
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
        ViewType := ViewType::Payment;
        ViewCode := '';

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);

        POSActionChangeViewB.ChangeView(ViewType, ViewCode);
        POSSession.GetCurrentView(CurrentView);

        Assert.IsTrue(CurrentView.Type() = CurrentView.Type() ::Payment, Format(CurrentView.Type()));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
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
        ViewType := ViewType::Balance;
        ViewCode := '';

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);

        POSActionChangeViewB.ChangeView(ViewType, ViewCode);
        POSSession.GetCurrentView(CurrentView);

        Assert.IsTrue(CurrentView.Type() = CurrentView.Type() ::BalanceRegister, Format(CurrentView.Type()));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
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
        ViewType := ViewType::Locked;
        ViewCode := '';

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);

        POSActionChangeViewB.ChangeView(ViewType, ViewCode);
        POSSession.GetCurrentView(CurrentView);

        Assert.IsTrue(CurrentView.Type() = CurrentView.Type() ::Locked, Format(CurrentView.Type()));
    end;
}