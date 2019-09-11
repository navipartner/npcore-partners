codeunit 6060161 "Event Word Layout Upg."
{
    // NPR5.51/TJ  /20190717 CASE 361677 Upgrade object

    Subtype = Upgrade;

    trigger OnRun()
    begin
    end;

    [TableSyncSetup]
    procedure SetTableSyncSetup(var TableSynchSetup: Record "Table Synch. Setup")
    var
        DataUpgradeMgt: Codeunit "Data Upgrade Mgt.";
    begin
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"Event Word Layout",0,TableSynchSetup.Mode::Force);
    end;
}

