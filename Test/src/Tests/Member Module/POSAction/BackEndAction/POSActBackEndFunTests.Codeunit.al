codeunit 85135 "NPR POS Act. Backend Fun Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "Assert";
        Initialized: Boolean;
        POSUnit: Record "NPR POS Unit";
        POSSession: Codeunit "NPR POS Session";
        POSStore: Record "NPR POS Store";
        InfoCapture: Record "NPR MM Member Info Capture";
        ItemNo: Code[20];

    [Test]
    [HandlerFunctions('PageHandler_MemberInfoCapture,ConfirmYesHandler')]
    procedure BackEndFun()
    var
        POSActionBackEndFun: Codeunit "NPR POS Action: MM BackEnd B";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSSetup: Codeunit "NPR POS Setup";
        MemberLibrary: Codeunit "NPR Library - Member Module";
        Membership: Record "NPR MM Membership";
        SalePOS: Record "NPR POS Sale";
    begin
        //[GIVEN] given
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore, POSPaymentMethod);
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        ItemNo := MemberLibrary.CreateScenario_SmokeTest();

        POSSession.GetSetup(POSSetup);
        POSActionBackEndFun.CreateMember(ItemNo, POSSetup);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        Membership.FindLast();

        Assert.IsTrue(SalePOS."Customer No." = Membership."Customer No.", 'Customer No. inserted.');
    end;

    [ModalPageHandler]
    procedure PageHandler_MemberInfoCapture(var MemberInfoCapturePage: Page "NPR MM Member Info Capture"; var ActionResponse: Action)
    var
        LibraryMemberModule: Codeunit "NPR Library - Member Module";
    begin
        LibraryMemberModule.SetRandomMemberInfoData(InfoCapture);
        InfoCapture.Validate("Phone No.", '012');
        InfoCapture.Validate("E-Mail Address", 'test99@test.com');
        InfoCapture.Validate("Item No.", ItemNo);
        InfoCapture.Validate(Quantity, 1);
        InfoCapture.Insert();
        MemberInfoCapturePage.SetRecord(InfoCapture);
        ActionResponse := Action::LookupOK;
    end;

    [ConfirmHandler]
    procedure ConfirmYesHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;
}