codeunit 6151506 "Nc Gambit Management"
{
    // NC1.01/MH/20150201  CASE 199932 Error-, Status- and Case reporting to NaviPartner
    // NC1.11/MH/20150325  CASE 209616 Replaced ServerInstance Name with Database Name and RetailList with Attachment
    // NC1.13/MH/20150414  CASE 211360 Implemented WebRequest wrapper for exception handling
    // CASE277358/TTH/20151120 CASE 227358 Type replaced with "Import Type" in "NaviConnect Import Entry"
    // NC1.21/MHA/20151120  CASE 227358 NaviConnect
    // NC2.00/MHA/20160525  CASE 240005 NaviConnect
    // NC2.23/MHA/20191018  CASE 369170 Object Marked for deletion [VLOBJDEL] and also used as its own Upgrade Codeunit to enable full remove of Gambit Integration [VLOBJUPG]

    Subtype = Upgrade;

    trigger OnRun()
    begin
    end;

    [TableSyncSetup]
    procedure GambitTableSyncSetup(var TableSynchSetup: Record "Table Synch. Setup")
    var
        DataUpgradeMgt: Codeunit "Data Upgrade Mgt.";
    begin
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"Nc Task",0,TableSynchSetup.Mode::Force);
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"Nc Import Entry",0,TableSynchSetup.Mode::Force);
    end;
}

