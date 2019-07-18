codeunit 6151423 "Magento Setup upg."
{
    // MAG2.22/MHA /201907017  CASE 362262 Object codeunit for rolling back rapidstart to standard [VLOBJUPG] Delete after upgrade

    Subtype = Upgrade;

    trigger OnRun()
    begin
    end;

    [TableSyncSetup]
    procedure SetupMagentoSetupSync(var TableSynchSetup: Record "Table Synch. Setup")
    var
        DataUpgradeMgt: Codeunit "Data Upgrade Mgt.";
    begin
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"Magento Setup",0,TableSynchSetup.Mode::Force);
    end;
}

