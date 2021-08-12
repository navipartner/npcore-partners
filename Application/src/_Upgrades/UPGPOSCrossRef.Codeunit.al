codeunit 6014653 "NPR UPG POS Cross Ref"
{
    Subtype = Upgrade;


    trigger OnCheckPreconditionsPerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS Cross Ref', 'OnCheckPreconditionsPerCompany');

        // Check whether the tag has been used before, and if so, don't run upgrade code
        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG POS Cross Ref")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        // Run upgrade
        UpgradePOSCrossRef();

        // Insert the upgrade tag in table 9999 "Upgrade Tags" for future reference
        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG POS Cross Ref"));

        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpgradePOSCrossRef()
    var
        RetailCrossRefSetup: Record "NPR Retail Cross Ref. Setup";
        POSCrossRefSetup: Record "NPR POS Cross Ref. Setup";
        TableName: Text[30];
    begin
        if not POSCrossRefSetup.IsEmpty() then
            exit;
        if RetailCrossRefSetup.FindSet() then
            repeat
                TableName := FindTableName(RetailCrossRefSetup."Table ID");
                if TableName <> '' then begin
                    POSCrossRefSetup."Table Name" := TableName;
                    POSCrossRefSetup.Init();
                    POSCrossRefSetup."Pattern Guide" := RetailCrossRefSetup."Pattern Guide";
                    POSCrossRefSetup."Reference No. Pattern" := RetailCrossRefSetup."Reference No. Pattern";
                    POSCrossRefSetup.Insert();
                end;
            until RetailCrossRefSetup.next() = 0;
    end;

    local procedure FindTableName(TableId: Integer): Text[30]
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        if TableId = 0 then
            exit;
        AllObjWithCaption."Object Type" := AllObjWithCaption."Object Type"::Table;
        AllObjWithCaption."Object ID" := TableId;
        if AllObjWithCaption.Find() then
            exit(AllObjWithCaption."Object Name");
    end;
}