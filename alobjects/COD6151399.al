codeunit 6151399 "Nc RapidStart upg."
{
    // NC2.22/MHA /201907015  CASE 361941 Object codeunit for rolling back rapidstart to standard [VLOBJUPG] Delete after upgrade

    Subtype = Upgrade;

    trigger OnRun()
    begin
    end;

    [TableSyncSetup]
    procedure SetupRapidStartSync(var TableSynchSetup: Record "Table Synch. Setup")
    var
        DataUpgradeMgt: Codeunit "Data Upgrade Mgt.";
    begin
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"Config. Package Field",0,TableSynchSetup.Mode::Force);
    end;

    [UpgradePerCompany]
    procedure UpdateRapidConnectSetup()
    var
        NcRapidConnectSetup: Record "Nc RapidConnect Setup";
    begin
        NcRapidConnectSetup.SetFilter("Export File Type",'<>%1',NcRapidConnectSetup."Export File Type"::".xml");
        if NcRapidConnectSetup.FindFirst then
          NcRapidConnectSetup.ModifyAll("Export File Type",NcRapidConnectSetup."Export File Type"::".xml");
    end;
}

