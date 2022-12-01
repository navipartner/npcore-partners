codeunit 88102 "NPR Library - POS Master Data"
{
    procedure OpenPOSUnit(var POSUnit: Record "NPR POS Unit")
    var
        POSOpenPOSUnit: Codeunit "NPR POS Manage POS Unit";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        Setup: Codeunit "NPR POS Setup";
        OpeningEntryNo: Integer;
    begin
        POSOpenPOSUnit.ClosePOSUnitOpenPeriods(POSUnit."POS Store Code", POSUnit."No."); // make sure pos period register is correct
        POSOpenPOSUnit.OpenPOSUnit(POSUnit);
        OpeningEntryNo := POSCreateEntry.InsertUnitOpenEntry(POSUnit."No.", Setup.Salesperson());
        POSOpenPOSUnit.SetOpeningEntryNo(POSUnit."No.", OpeningEntryNo);
        Commit();
    end;
}

