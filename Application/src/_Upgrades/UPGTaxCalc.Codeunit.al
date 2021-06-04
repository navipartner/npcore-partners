codeunit 6150937 "NPR UPG Tax Calc."
{
    Subtype = Upgrade;


    trigger OnCheckPreconditionsPerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgTagDef: Codeunit "NPR UPG Tax Calc. Tag Def";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG Tax Calc.', 'OnCheckPreconditionsPerCompany');

        // Check whether the tag has been used before, and if so, don't run upgrade code
        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag()) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        // Run upgrade preconditions
        ArchiveActiveSale();

        // Insert the upgrade tag in table 9999 "Upgrade Tags" for future reference
        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag());

        LogMessageStopwatch.LogFinish();
    end;

    local procedure ArchiveActiveSale()
    var
        POSSale: Record "NPR POS Sale";
        POSSaleLine: Record "NPR POS Sale Line";
        POSArchiveSale: Record "NPR Archive Sale POS";
        POSArchiveSaleLine: Record "NPR Archive Sale Line POS";
    begin
        if POSSale.IsEmpty() then
            exit;
        POSSale.FindSet(true);
        repeat
            POSArchiveSale.Init();
            POSArchiveSale.TransferFields(POSSale, true, true);
            if not POSArchiveSale.Find() then
                POSArchiveSale.Insert()
            else
                POSArchiveSale.Modify();
            POSSaleLine.SetRange("Register No.", POSSale."Register No.");
            POSSaleLine.SetRange("Sales Ticket No.", POSSale."Sales Ticket No.");
            if POSSaleLine.FindSet(true) then
                repeat
                    POSArchiveSaleLine.Init();
                    POSArchiveSaleLine.TransferFields(POSSaleLine, true, true);
                    if not POSArchiveSaleLine.Find() then
                        POSArchiveSaleLine.Insert()
                    else
                        POSArchiveSaleLine.Modify();
                    POSSaleLine.Delete();
                until POSSaleLine.next() = 0;
            POSSale.Delete();
        until POSSale.Next() = 0;
    end;
}