codeunit 6151423 "Npm Upg. (Remove)"
{
    // NPR5.51/MHA /20190816  CASE 365332 Upgrade codeunit for removal of Npm - NaviPartner Page Manager [VLOBJUPG] Object may be deleted after upgrade

    Subtype = Upgrade;

    trigger OnRun()
    begin
    end;

    [TableSyncSetup]
    procedure SetupTableSyncSetup(var TableSynchSetup: Record "Table Synch. Setup")
    var
        DataUpgradeMgt: Codeunit "Data Upgrade Mgt.";
    begin
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"Npm Page",0,TableSynchSetup.Mode::Force);
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"Npm View",0,TableSynchSetup.Mode::Force);
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"Npm Field",0,TableSynchSetup.Mode::Force);
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"Npm View Condition",0,TableSynchSetup.Mode::Force);
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"Npm Page View",0,TableSynchSetup.Mode::Force);
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"Npm Field Caption",0,TableSynchSetup.Mode::Force);
    end;
}

