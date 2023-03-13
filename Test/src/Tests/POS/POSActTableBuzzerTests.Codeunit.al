codeunit 85131 "NPR POS Act Table Buzzer Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "Assert";
        Initialized: Boolean;
        POSUnit: Record "NPR POS Unit";
        POSSession: Codeunit "NPR POS Session";
        POSStore: Record "NPR POS Store";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure InsertCommentLine()
    var
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        BusinessCodeunit: Codeunit "NPR POS Act:TableBuzzerNo BL";
        SaleLinePOS: Record "NPR POS Sale Line";
        BuzzerText: Label 'Table Buzzer %1';
        InputText: Label 'test';
    begin
        // [Scenario] Insert comment line on pos sale line
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        POSSession.GetSaleLine(POSSaleLine);

        // [When] Insert comment
        BusinessCodeunit.InputPosCommentLine(POSSaleLine, '', InputText);

        // [Then]
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        SaleLinePOS.FindFirst();
        Assert.IsTrue(SaleLinePOS."Line Type" = SaleLinePOS."Line Type"::Comment, 'Comment line is not inserted.');
        Assert.AreEqual(StrSubstNo(BuzzerText, InputText), SaleLinePOS.Description, 'Comment not according to test scenario.');
    end;
}