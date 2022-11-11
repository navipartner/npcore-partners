codeunit 85081 "NPR POS Act. SelectCont. Tests"
{
    Subtype = Test;

    var
        POSUnit: Record "NPR POS Unit";
        Contact: Record Contact;
        Assert: Codeunit Assert;
        POSSession: Codeunit "NPR POS Session";
        POSSaleUnit: Codeunit "NPR POS Sale";

    [Test]
    [HandlerFunctions('ContactListOkModalPageHandler')]
    procedure SelectContact()
    var
        POSSale: Record "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        ContactSelect: Codeunit "NPR POS Action: Cont. Select-B";
        LibraryMarketing: Codeunit "Library - Marketing";
    begin
        // [GIVEN] Contact
        LibraryMarketing.CreatePersonContact(Contact);

        // [GIVEN] Active POS session & sale
        InitializeData();
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);
        POSSaleUnit.GetCurrentSale(POSSale);

        // [WHEN] Add Contact to active sale        
        ContactSelect.AttachContact(POSSale, '', 0);

        // [THEN] Record POS has Customer No.
        Assert.IsTrue(POSSale."Customer No." = Contact."No.", 'Contact is not selected.');
    end;

    [ModalPageHandler]
    procedure ContactListOkModalPageHandler(var TP_ContactList: TestPage "Contact List")
    begin
        TP_ContactList.GoToRecord(Contact);
        TP_ContactList.OK().Invoke();
    end;

    [Test]
    procedure RemoveContact()
    var
        POSSale: Record "NPR POS Sale";
        Customer: Record Customer;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        ContactSelect: Codeunit "NPR POS Action: Cont. Select-B";
        LibrarySales: Codeunit "Library - Sales";
    begin
        // [GIVEN] Active POS session & sale
        InitializeData();
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);
        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Customer
        LibrarySales.CreateCustomer(Customer);
        POSSale.Validate("Customer No.", Customer."No.");

        // [WHEN] Remove Contact from active sale     
        ContactSelect.RemoveContact(POSSale);

        // [THEN] Record POS has Customer No.
        Assert.IsTrue(POSSale."Customer No." = '', 'Contact is not deleted.');
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