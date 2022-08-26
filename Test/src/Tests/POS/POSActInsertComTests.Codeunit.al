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
    procedure InsertComment()
    var
        POSSaleLine: Codeunit "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryRandom: Codeunit "Library - Random";
        POSSale: Codeunit "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        Line: Record "NPR POS Sale Line";
        NewDesc: Text;
    begin
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);

        NewDesc := LibraryRandom.RandText(MaxStrLen(Line.Description));

        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);

        Line.Type := Line.Type::Comment;
        Line.Description := NewDesc;

        POSSaleLine.InsertLine(Line);

        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        Assert.IsTrue(SaleLinePOS.Description = NewDesc, 'New Description is inserted.');
        Assert.IsTrue(SaleLinePOS.Type = SaleLinePOS.Type::Comment, 'Comment inserted.');
    end;
}