#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 85300 "NPR NPRE Print Header Tests"
{
    // [FEATURE] Restaurant kitchen/pre-receipt print header
    Subtype = Test;

    var
        LibraryUtility: Codeunit "Library - Utility";
        Assert: Codeunit Assert;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetPrintHeaderFromPOSEntryResolvesSeating()
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
        Seating: Record "NPR NPRE Seating";
        POSEntry: Record "NPR POS Entry";
        POSEntryWaiterPadLink: Record "NPR POS Entry Waiter Pad Link";
        TempRestaurantPrintHeader: Record "NPR NPRE Rest. Print Header" temporary;
        KitchenPrintMgt: Codeunit "NPR NPRE Kitchen Print Mgt";
        SeatingDescription: Text[50];
    begin
        // [SCENARIO] A sales receipt starts from a posted POS entry (no waiter-pad context); the header must still resolve the seating of the originating waiter pad
        // [GIVEN] A posted POS entry whose waiter pad is seated at a known seating
        SeatingDescription := 'Table 7';
        CreateBareWaiterPad(WaiterPad);
        CreatePrimarySeatingForWaiterPad(WaiterPad."No.", SeatingDescription, Seating);
        CreatePostedEntryLinkedToWaiterPad(WaiterPad."No.", POSEntry, POSEntryWaiterPadLink);

        // [WHEN] The print header is built from the POS entry (sales-receipt path)
        KitchenPrintMgt.GetPrintHeader(POSEntry, false, TempRestaurantPrintHeader);

        // [THEN] The header carries the seating of the originating waiter pad
        Assert.AreEqual(Seating.Code, TempRestaurantPrintHeader."Seating Code", 'Header should resolve the seating code from the POS entry.');
        Assert.AreEqual(SeatingDescription, TempRestaurantPrintHeader."Seating Description", 'Header should resolve the seating description from the POS entry.');
    end;

    local procedure CreateBareWaiterPad(var WaiterPad: Record "NPR NPRE Waiter Pad")
    begin
        WaiterPad.Init();
        WaiterPad."No." := CopyStr(LibraryUtility.GenerateRandomCode(WaiterPad.FieldNo("No."), Database::"NPR NPRE Waiter Pad"), 1, MaxStrLen(WaiterPad."No."));
        WaiterPad.Insert(true);
    end;

    local procedure CreatePrimarySeatingForWaiterPad(WaiterPadNo: Code[20]; SeatingDescription: Text[50]; var Seating: Record "NPR NPRE Seating")
    var
        SeatWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
    begin
        Seating.Init();
        Seating.Code := CopyStr(LibraryUtility.GenerateRandomCode(Seating.FieldNo(Code), Database::"NPR NPRE Seating"), 1, MaxStrLen(Seating.Code));
        Seating."Seating No." := Seating.Code;
        Seating.Description := SeatingDescription;
        Seating.Insert(false); // bypass dimension / seating-no. triggers not needed here

        SeatWaiterPadLink.Init();
        SeatWaiterPadLink."Seating Code" := Seating.Code;
        SeatWaiterPadLink."Waiter Pad No." := WaiterPadNo;
        SeatWaiterPadLink.Primary := true;
        SeatWaiterPadLink.Insert(false); // set Primary directly, skip its OnValidate reassignment
    end;

    local procedure CreatePostedEntryLinkedToWaiterPad(WaiterPadNo: Code[20]; var POSEntry: Record "NPR POS Entry"; var POSEntryWaiterPadLink: Record "NPR POS Entry Waiter Pad Link")
    begin
        POSEntry.Init();
        POSEntry."Document No." := 'DOC-RCPT-01';
        POSEntry.Insert(false); // Entry No. is AutoIncrement

        POSEntryWaiterPadLink.Init();
        POSEntryWaiterPadLink."POS Entry No." := POSEntry."Entry No.";
        POSEntryWaiterPadLink."POS Entry Sales Line No." := 10000;
        POSEntryWaiterPadLink."Waiter Pad No." := WaiterPadNo;
        POSEntryWaiterPadLink."Waiter Pad Line No." := 10000;
        POSEntryWaiterPadLink.Insert();
    end;
}
#endif
