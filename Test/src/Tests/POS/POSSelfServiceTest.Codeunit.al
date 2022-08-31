codeunit 85073 "NPR POS Self Service Test"
{
    Subtype = Test;

    var
        Assert: Codeunit "Assert";
        Initialized: Boolean;
        POSUnit: Record "NPR POS Unit";
        POSSession: Codeunit "NPR POS Session";
        POSSetup: Record "NPR POS Setup";
        POSStore: Record "NPR POS Store";

    [Test]
    procedure ChangeViewSale()
    var
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        CurrentView: Codeunit "NPR POS View";
    begin
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session
        LibraryPOSMock.InitializePOSSession(POSSession, POSUnit);

        //[When]
        POSSession.ChangeViewSale();

        //[Then]
        POSSession.GetCurrentView(CurrentView);
        Assert.IsTrue(CurrentView.Type() = CurrentView.Type() ::Sale, Format(CurrentView.Type()));

    end;

    [Test]
    procedure ChangeViewPayment()
    var
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        CurrentView: Codeunit "NPR POS View";
    begin
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session
        LibraryPOSMock.InitializePOSSession(POSSession, POSUnit);

        //[When]
        POSSession.ChangeViewPayment();

        //[Then]
        POSSession.GetCurrentView(CurrentView);
        Assert.IsTrue(CurrentView.Type() = CurrentView.Type() ::Payment, Format(CurrentView.Type()));

    end;
}
