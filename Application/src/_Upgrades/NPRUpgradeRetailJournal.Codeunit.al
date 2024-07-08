codeunit 6014695 "NPR Upgrade Retail Journal"
{
    Access = Internal;
    Subtype = Upgrade;

    var
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";

    trigger OnUpgradePerCompany()
    begin
        UpgradeDataInRetailJournalLine();
    end;

    local procedure UpgradeDataInRetailJournalLine()
    var
        RetailJournal: Record "NPR Retail Journal Line";
    begin
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Upgrade Retail Journal")) then
            exit;
        if RetailJournal.FindSet() then
            repeat
                RetailJournal."Vend Item No." := RetailJournal."Vendor Item No.";
                RetailJournal."Vend Name" := RetailJournal."Vendor Name";
                RetailJournal."Vend Search Description" := RetailJournal."Vendor Search Description";
                RetailJournal.Modify();
            until RetailJournal.Next() = 0;
        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Upgrade Retail Journal"));
    end;
}
