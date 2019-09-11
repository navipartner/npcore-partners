codeunit 6151425 "IDS Upg. (Remove)"
{
    // NPR5.51/MHA /20190820  CASE 365377 Upgrade codeunit for removal of IDS [VLOBJUPG] Object may be deleted after upgrade

    Subtype = Upgrade;

    trigger OnRun()
    begin
    end;

    [TableSyncSetup]
    procedure SetupTableSyncSetup(var TableSynchSetup: Record "Table Synch. Setup")
    var
        DataUpgradeMgt: Codeunit "Data Upgrade Mgt.";
    begin
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"Item Wizard Template",0,TableSynchSetup.Mode::Force);
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"Item Wizard Batch",0,TableSynchSetup.Mode::Force);
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"Item Wizard Line",0,TableSynchSetup.Mode::Force);
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"IDS Data Package (Record)",0,TableSynchSetup.Mode::Force);
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"IDS Data Package (Field)",0,TableSynchSetup.Mode::Force);
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"IDS Item Buffer",0,TableSynchSetup.Mode::Force);
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"IDS Item Buffer Variant",0,TableSynchSetup.Mode::Force);
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"IDS Order",0,TableSynchSetup.Mode::Force);
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"IDS Order Line",0,TableSynchSetup.Mode::Force);
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"IDS Order Archive",0,TableSynchSetup.Mode::Force);
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"IDS Order Line Archive",0,TableSynchSetup.Mode::Force);
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"Order Link",0,TableSynchSetup.Mode::Force);
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"IDS Profile",0,TableSynchSetup.Mode::Force);
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"Item Wizard Mapping Setup",0,TableSynchSetup.Mode::Force);
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"IDS Packages",0,TableSynchSetup.Mode::Force);
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"IDS Setup",0,TableSynchSetup.Mode::Force);
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"IDS Flow Setup",0,TableSynchSetup.Mode::Force);
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"IDS Flow Send",0,TableSynchSetup.Mode::Force);
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"IDS Flow Receive",0,TableSynchSetup.Mode::Force);
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"IDS Item Buffer Att Value Set",0,TableSynchSetup.Mode::Force);
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"IDS - NPR Attribute Mapping",0,TableSynchSetup.Mode::Force);
    end;
}

