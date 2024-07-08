codeunit 85129 "NPR POS Chg.Actv.Event Tests"
{
    Subtype = Test;

    var
        Job: Record Job;
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
        SalePOS: Record "NPR POS Sale";
        Assert: Codeunit Assert;
        POSSession: Codeunit "NPR POS Session";
        Initialized: Boolean;
        ActualMessage: Text[1024];

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('PageHandler_JobList')]
    procedure SelectNewEventFromList_ChangeEvent()
    var
        NPRLibraryEvent: Codeunit "NPR Library - Event";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSActionBusinessLogic: Codeunit "NPR POS Act:Chg.Actv.Event BL";
        GetEventTest: Codeunit "NPR POS Get Event Tests";
        POSSale: Codeunit "NPR POS Sale";
        EventNo: Code[20];
    begin
        // [Scenario] New event is selected from the list

        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        GetEventTest.InitializeJobsSetup();
        NPRLibraryEvent.CreateEvent(Job);

        //[When] Select from list and update POS Sale with selected event
        POSActionBusinessLogic.SelectEventFromList(EventNo);
        POSActionBusinessLogic.UpdateCurrentEvent(POSSale, EventNo, true);

        //[Then] Check if Event is changed on Sale POS
        POSSale.GetCurrentSale(SalePOS);
        Assert.IsTrue(SalePOS."Event No." = EventNo, 'Event No. is not modified.');
    end;

    [ModalPageHandler]
    procedure PageHandler_JobList(var EventListPage: TestPage "NPR Event List")
    begin
        EventListPage.GoToRecord(Job);
        EventListPage.OK().Invoke();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('PageHandler_CancelJobList')]
    procedure CancelSelectNewEventFromList_ChangeEvent()
    var
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSActionBusinessLogic: Codeunit "NPR POS Act:Chg.Actv.Event BL";
        POSSale: Codeunit "NPR POS Sale";
        EventNo: Code[20];
        OldEventNo: Code[20];
    begin
        // [Scenario] Cancel event selection list

        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);
        OldEventNo := SalePOS."Event No.";

        //[When]  No event is selected
        POSActionBusinessLogic.SelectEventFromList(EventNo);

        //[Then] Check if POS Sale event is not changed
        POSSale.GetCurrentSale(SalePOS);
        Assert.IsTrue(SalePOS."Event No." = OldEventNo, 'Change Event No is not canceled.');
    end;

    [ModalPageHandler]
    procedure PageHandler_CancelJobList(var EventListPage: TestPage "NPR Event List")
    begin
        EventListPage.Cancel().Invoke();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ClickOnOKMsg')]
    procedure TryToChangeEvent_SameEvent()
    var
        NPRLibraryEvent: Codeunit "NPR Library - Event";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSActionBusinessLogic: Codeunit "NPR POS Act:Chg.Actv.Event BL";
        GetEventTest: Codeunit "NPR POS Get Event Tests";
        POSSale: Codeunit "NPR POS Sale";
        ExpectedtMsg: Label 'The Event ''%1'' has already been set up as active event for %2=''%3''.';
    begin
        // [Scenario] Try to change to event that is already assigned to POS Sale

        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        GetEventTest.InitializeJobsSetup();
        NPRLibraryEvent.CreateEvent(Job);

        POSSale.GetCurrentSale(SalePOS);
        SalePOS."Event No." := Job."No.";
        SalePOS.Modify();
        POSSale.RefreshCurrent();

        // [When] Update with same event that is already on POS Sale
        POSActionBusinessLogic.UpdateCurrentEvent(POSSale, Job."No.", true);

        // [Then] Expected message
        Assert.AreEqual(ActualMessage, StrSubstNo(ExpectedtMsg, Job."No.", SalePOS.FieldCaption("Sales Ticket No."), SalePOS."Sales Ticket No."), 'Does not show expected message.')
    end;

    [MessageHandler]
    procedure ClickOnOKMsg(Msg: Text[1024])
    begin
        ActualMessage := Msg;
    end;
}