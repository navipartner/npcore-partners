codeunit 6150937 "NPR UPG Tax Calc."
{
    Access = Internal;
    Subtype = Upgrade;


    trigger OnCheckPreconditionsPerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG Tax Calc.', 'OnCheckPreconditionsPerCompany');

        // Check whether the tag has been used before, and if so, don't run upgrade code
        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Tax Calc.")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        // Run upgrade preconditions
        Type2LineTypeInArchive();
        ArchiveActiveSale();

        // Insert the upgrade tag in table 9999 "Upgrade Tags" for future reference
        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Tax Calc."));

        LogMessageStopwatch.LogFinish();
    end;

    local procedure Type2LineTypeInArchive()
    var
        POSArchiveSale: Record "NPR Archive Sale POS";
        POSArchiveSaleLine: Record "NPR Archive Sale Line POS";
    begin
        if POSArchiveSale.IsEmpty() then
            exit;
        POSArchiveSale.FindSet(true);
        repeat
            case POSArchiveSale."Sale type" of
                POSArchiveSale."Sale type"::Sale:
                    POSArchiveSale."Header Type" := POSArchiveSale."Header Type"::Open;
                POSArchiveSale."Sale type"::Annullment:
                    POSArchiveSale."Header Type" := POSArchiveSale."Header Type"::Cancelled;
            end;
            POSArchiveSale.Modify();
            POSArchiveSaleLine.SetRange("Register No.", POSArchiveSale."Register No.");
            POSArchiveSaleLine.SetRange("Sales Ticket No.", POSArchiveSale."Sales Ticket No.");
            if POSArchiveSaleLine.FindSet(true) then
                repeat
                    case POSArchiveSaleLine.Type of
                        POSArchiveSaleLine.Type::"BOM List":
                            begin
                                POSArchiveSaleLine."Line Type" := POSArchiveSaleLine."Line Type"::"BOM List";
                                POSArchiveSaleLine.Modify();
                            end;
                        POSArchiveSaleLine.Type::Comment:
                            begin
                                POSArchiveSaleLine."Line Type" := POSArchiveSaleLine."Line Type"::Comment;
                                POSArchiveSaleLine.Modify();
                            end;
                        POSArchiveSaleLine.Type::Customer:
                            begin
                                POSArchiveSaleLine."Line Type" := POSArchiveSaleLine."Line Type"::"Customer Deposit";
                                POSArchiveSaleLine.Modify();
                            end;
                        POSArchiveSaleLine.Type::"G/L Entry":
                            begin
                                POSArchiveSaleLine."Line Type" := POSArchiveSaleLine."Line Type"::"GL Payment";
                                POSArchiveSaleLine.Modify();
                            end;
                        POSArchiveSaleLine.Type::Item:
                            begin
                                POSArchiveSaleLine."Line Type" := POSArchiveSaleLine."Line Type"::Item;
                                POSArchiveSaleLine.Modify();
                            end;
                        POSArchiveSaleLine.Type::"Item Group":
                            begin
                                POSArchiveSaleLine."Line Type" := POSArchiveSaleLine."Line Type"::"Item Category";
                                POSArchiveSaleLine.Modify();
                            end;
                        POSArchiveSaleLine.Type::Payment:
                            begin
                                POSArchiveSaleLine."Line Type" := POSArchiveSaleLine."Line Type"::"POS Payment";
                                POSArchiveSaleLine.Modify();
                            end;
                    end;
                until POSArchiveSaleLine.Next() = 0;
        until POSArchiveSale.next() = 0;
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
                until POSSaleLine.next() = 0;
            POSSale.Delete();
            if not POSSaleLine.IsEmpty() then
                POSSaleLine.DeleteAll();
        until POSSale.Next() = 0;
    end;
}
