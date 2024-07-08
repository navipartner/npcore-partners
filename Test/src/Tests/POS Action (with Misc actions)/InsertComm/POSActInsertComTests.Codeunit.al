codeunit 85071 "NPR POS Act. Insert Com. Tests"
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
    procedure InsertComment()
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryRandom: Codeunit "Library - Random";
        POSSale: Codeunit "NPR POS Sale";
        BusinessLogic: Codeunit "NPR POS Action - Insert Comm B";
        CommentDescription: Text[100];
    begin
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);

        CommentDescription := CopyStr(LibraryRandom.RandText(MaxStrLen(SaleLinePOS.Description)), 1, MaxStrLen(CommentDescription));

        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);

        BusinessLogic.InputPosCommentLine(CommentDescription, POSSaleLine);

        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        Assert.IsTrue(SaleLinePOS.Description = CommentDescription, 'Comment description is not according to test scenario.');
        Assert.IsTrue(SaleLinePOS."Line Type" = SaleLinePOS."Line Type"::Comment, 'Comment line is not inserted.');
    end;
}