codeunit 6151212 "NpCs Document upg."
{
    // #364557/MHA /20190821  CASE 364557 Object created - Object Codeunit for Collect Documents [VLOBJUPG] object may be deleted at any time

    Subtype = Upgrade;

    trigger OnRun()
    begin
    end;

    [TableSyncSetup]
    procedure SetupTableSyncSetup(var TableSynchSetup: Record "Table Synch. Setup")
    var
        DataUpgradeMgt: Codeunit "Data Upgrade Mgt.";
    begin
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"NpCs Document",0,TableSynchSetup.Mode::Check);
    end;

    [UpgradePerCompany]
    procedure UpgradeCollectDocuments()
    var
        NpCsDocument: Record "NpCs Document";
        SalesHeader: Record "Sales Header";
        PrevRec: Text;
    begin
        if not NpCsDocument.FindSet then
          exit;

        repeat
          if SalesHeader.Get(NpCsDocument."Document Type",NpCsDocument."Document No.") then begin
            PrevRec := Format(NpCsDocument);

            NpCsDocument."Sell-to Customer Name" := SalesHeader."Sell-to Customer Name";
            NpCsDocument."Location Code" := SalesHeader."Location Code";

            if PrevRec <> Format(NpCsDocument) then
              NpCsDocument.Modify;
          end;
        until NpCsDocument.Next = 0;
    end;
}

