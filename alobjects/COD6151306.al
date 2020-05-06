/*
codeunit 6151306 "NpEc Upg. NPR5.54"
{
    // #390380/MHA /20200311  CASE 390380 Object created - Upgrade Codeunit for Np E-commerce [VLOBJUPG] Object may be deleted after upgrade

    Subtype = Upgrade;

    trigger OnRun()
    begin
    end;

    [TableSyncSetup]
    procedure TableSyncSetup(var TableSynchSetup: Record "Table Synch. Setup")
    var
        DataUpgradeMgt: Codeunit "Data Upgrade Mgt.";
    begin
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"Sales Header",DATABASE::Table6151311,TableSynchSetup.Mode::Force);
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"Purchase Header",DATABASE::Table6151312,TableSynchSetup.Mode::Force);
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"Sales Shipment Header",0,TableSynchSetup.Mode::Force);
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"Sales Invoice Header",0,TableSynchSetup.Mode::Force);
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"Sales Cr.Memo Header",0,TableSynchSetup.Mode::Force);
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"Purch. Rcpt. Header",0,TableSynchSetup.Mode::Force);
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"Purch. Inv. Header",0,TableSynchSetup.Mode::Force);
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"Purch. Cr. Memo Hdr.",0,TableSynchSetup.Mode::Force);
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"Return Shipment Header",0,TableSynchSetup.Mode::Force);
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"Return Receipt Header",0,TableSynchSetup.Mode::Force);
    end;
}
*/