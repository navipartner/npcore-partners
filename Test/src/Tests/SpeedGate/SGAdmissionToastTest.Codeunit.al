codeunit 85303 "NPR SG Admission Toast Test"
{
    Subtype = Test;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ToastIncludesItemDescription()
    var
        Ticket: Record "NPR TM Ticket";
        Item: Record Item;
        SpeedGate: Codeunit "NPR SG SpeedGate";
        SpeedGateLibrary: Codeunit "NPR Library - SG Ticket";
        SGTicketTest: Codeunit "NPR SG TicketTest";
        POSActionSGAdmission: Codeunit "NPR POS Action SG Admission";
        Assert: Codeunit Assert;
        ExternalTicketNumber: Code[30];
        AdmitToken: Guid;
    begin
        // [SCENARIO] After admission, the toast message includes the item description
        // resolved via AdmittedReferenceId (not EntityId).

        // [GIVEN] A valid ticket admitted through SpeedGate
        SpeedGateLibrary.DefaultSetup(false, true, '', '');
        ExternalTicketNumber := SGTicketTest.GetOneTicket();
        AdmitToken := SpeedGate.CreateAdmitToken(ExternalTicketNumber, '', '');
        SpeedGate.Admit(AdmitToken, 1);

        // [GIVEN] The expected item description from the ticket
        Ticket.SetFilter("External Ticket No.", '=%1', ExternalTicketNumber);
        Ticket.FindFirst();
        Item.Get(Ticket."Item No.");

        // [THEN] GetItemDescription returns the correct item description
        Assert.AreEqual(Item.Description, POSActionSGAdmission.GetItemDescription(AdmitToken),
            'Toast description should match the admitted ticket item.');
    end;
}
