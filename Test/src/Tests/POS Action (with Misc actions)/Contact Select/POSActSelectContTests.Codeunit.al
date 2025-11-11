codeunit 85081 "NPR POS Act. SelectCont. Tests"
{
    Subtype = Test;

    var
        POSUnit: Record "NPR POS Unit";
        Contact: Record Contact;
        Assert: Codeunit Assert;
        POSSession: Codeunit "NPR POS Session";
        POSSaleUnit: Codeunit "NPR POS Sale";
        LibraryMarketing: Codeunit "Library - Marketing";

    [Test]
    [HandlerFunctions('ContactListOkModalPageHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SelectContact()
    var
        POSSale: Record "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        ContactSelect: Codeunit "NPR POS Action: Cont. Select-B";
    begin
        // [GIVEN] Contact
        if Contact."No." = '' then
            LibraryMarketing.CreatePersonContact(Contact);

        // [GIVEN] Active POS session & sale
        InitializeData();
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);
        POSSaleUnit.GetCurrentSale(POSSale);

        // [WHEN] Add Contact to active sale        
        ContactSelect.AttachContact(POSSale, '', 0);

        // [THEN] Record POS has Contact No.
        Assert.IsTrue(POSSale."Contact No." = Contact."No.", 'Contact is not selected.');
    end;

    [ModalPageHandler]
    procedure ContactListOkModalPageHandler(var TP_ContactList: TestPage "Contact List")
    begin
        TP_ContactList.GoToRecord(Contact);
        TP_ContactList.OK().Invoke();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RemoveContact()
    var
        POSSale: Record "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        ContactSelect: Codeunit "NPR POS Action: Cont. Select-B";
    begin
        // [GIVEN] Active POS session & sale
        InitializeData();
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);
        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Contact
        if Contact."No." = '' then
            LibraryMarketing.CreatePersonContact(Contact);
        POSSale.Validate("Contact No.", Contact."No.");

        // [WHEN] Remove Contact from active sale     
        ContactSelect.RemoveContact(POSSale);

        // [THEN] Record POS has Contact No.
        Assert.IsTrue(POSSale."Contact No." = '', 'Contact is not deleted.');
    end;

    local procedure InitializeData()
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSSetup: Record "NPR POS Setup";
        POSStore: Record "NPR POS Store";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        _Initialized: Boolean;
    begin
        if _Initialized then begin
            POSSession.ClearAll();
            Clear(POSSession);
        end;

        if not _Initialized then begin
            NPRLibraryPOSMasterData.CreatePOSSetup(POSSetup);
            NPRLibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
            NPRLibraryPOSMasterData.CreatePOSStore(POSStore, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSUnit(POSUnit, POSStore.Code, POSPostingProfile.Code);
            _Initialized := true;
        end;

        Commit;
    end;
}