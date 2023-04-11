codeunit 88102 "NPR BCPT Library POSMasterData"
{
    var
        LibraryRandom: Codeunit "NPR BPCT Library - Random";

    procedure OpenPOSUnit(var POSUnit: Record "NPR POS Unit")
    var
        POSOpenPOSUnit: Codeunit "NPR POS Manage POS Unit";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        Setup: Codeunit "NPR POS Setup";
        OpeningEntryNo: Integer;
    begin
        POSOpenPOSUnit.ClosePOSUnitOpenPeriods(POSUnit."POS Store Code", POSUnit."No."); // make sure pos period register is correct
        Commit();
        POSOpenPOSUnit.OpenPOSUnit(POSUnit);
        OpeningEntryNo := POSCreateEntry.InsertUnitOpenEntry(POSUnit."No.", Setup.Salesperson());
        POSOpenPOSUnit.SetOpeningEntryNo(POSUnit."No.", OpeningEntryNo);
        Commit();
    end;

    procedure CreateBarCodeItemReference(var NewItemReference: Record "Item Reference"; Item: Record Item)
    begin
        NewItemReference.SetCurrentKey("Reference Type", "Reference No.");
        NewItemReference.SetRange("Reference Type", NewItemReference."Reference Type"::"Bar Code");
        NewItemReference.SetRange("Item No.", Item."No.");
        if NewItemReference.Count() > 1 then
            NewItemReference.DeleteAll();

        if not NewItemReference.FindFirst() then begin
            NewItemReference.Init();
            NewItemReference."Item No." := Item."No.";
            NewItemReference."Reference Type" := NewItemReference."Reference Type"::"Bar Code";
            NewItemReference."Reference No." := CopyStr(LibraryRandom.RandText(50), 1, MaxStrLen(NewItemReference."Reference No."));
            NewItemReference.Insert(true);
        end;
    end;
}

