#if not (BC17 or BC18 or BC19 or BC20 or BC21)
codeunit 6248525 "NPR UPG NP Email"
{
    Access = Internal;
    Subtype = Upgrade;

    var
        _UpgradeTag: Codeunit "Upgrade Tag";
        _UpgradeTagDef: Codeunit "NPR Upgrade Tag Definitions";

    trigger OnUpgradePerCompany()
    begin
        RemoveSenderIdentityUpdateJQ();
    end;

    local procedure RemoveSenderIdentityUpdateJQ()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        if (_UpgradeTag.HasUpgradeTag(_UpgradeTagDef.GetUpgradeTag(Codeunit::"NPR UPG NP Email", 'RemoveSenderIdentityUpdateJQ'))) then
            exit;

        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", 6248273);
        JobQueueEntry.DeleteAll(true);

        _UpgradeTag.SetUpgradeTag(_UpgradeTagDef.GetUpgradeTag(Codeunit::"NPR UPG NP Email", 'RemoveSenderIdentityUpdateJQ'));
    end;
}
#endif