codeunit 6059781 "NPR UPG Table Extension Fields"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG Table Extension Fields', 'OnUpgradePerCompany');
        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Table Extension Fields")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        UpdateTableExtensionFieldsToRelationTable();

        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Table Extension Fields"));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpdateTableExtensionFieldsToRelationTable()
    begin
        UpgradeItemAddOnNoToRelationTable();
        UpgradeBilltoCompanyToRelationTable();
    end;

    procedure UpgradeItemAddOnNoToRelationTable()
    var
        FromMigrationRec: Record Item;
        ToMigrationRec: Record "NPR Item Additional Fields";
    begin
        if FromMigrationRec.IsEmpty() then
            exit;

        FromMigrationRec.SetLoadFields("NPR Item AddOn No.");
        FromMigrationRec.SetRange("NPR Item AddOn No.", '<>%1', '');
        if FromMigrationRec.FindSet() then
            repeat
                ToMigrationRec.Id := FromMigrationRec.SystemId;
                ToMigrationRec."Item Addon No." := FromMigrationRec."NPR Item AddOn No.";
                if not ToMigrationRec.Insert() then
                    ToMigrationRec.Modify();
            until FromMigrationRec.Next() = 0;
    end;

    procedure UpgradeBilltoCompanyToRelationTable()
    var
        FromMigrationRec: Record "Sales Header";
        ToMigrationRec: Record "NPR Sales Header Add. Fields";
    begin
        if FromMigrationRec.IsEmpty() then
            exit;

        FromMigrationRec.SetLoadFields("NPR Bill-to Company");
        FromMigrationRec.SetRange("NPR Bill-to Company", '<>%1', '');
        if FromMigrationRec.FindSet() then
            repeat
                ToMigrationRec.Id := FromMigrationRec.SystemId;
                ToMigrationRec."Bill-to Company" := FromMigrationRec."NPR Bill-to Company";
                if not ToMigrationRec.Insert() then
                    ToMigrationRec.Modify();
            until FromMigrationRec.Next() = 0;
    end;
}
