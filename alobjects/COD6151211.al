codeunit 6151211 "NpCs Opening Hours upg."
{
    // NPR5.51/MHA /20190719  CASE 362443 Object created - Object Codeunit for Collect Store Opening Hours [VLOBJUPG] object may be deleted at any time

    Subtype = Upgrade;

    trigger OnRun()
    begin
    end;

    [TableSyncSetup]
    procedure SetupNpCsWorkflowSync(var TableSynchSetup: Record "Table Synch. Setup")
    var
        DataUpgradeMgt: Codeunit "Data Upgrade Mgt.";
    begin
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"NpCs Workflow",0,TableSynchSetup.Mode::Force);
    end;

    [UpgradePerCompany]
    procedure UpgradeOpeningHours()
    var
        NpCsOpeningHourSet: Record "NpCs Open. Hour Set";
        NpCsOpeningHourEntry: Record "NpCs Open. Hour Entry";
        NpCsStoreOpeningHoursSetup: Record "NpCs Store Opening Hours Setup";
        NpCsStoreOpeningHoursEntry: Record "NpCs Store Opening Hours Entry";
        NpCsStoreOpeningHoursMgt: Codeunit "NpCs Store Opening Hours Mgt.";
    begin
        if NpCsStoreOpeningHoursSetup.IsEmpty then
          exit;

        if NpCsOpeningHourSet.Get('DEFAULT') then
          exit;

        NpCsOpeningHourSet.Init;
        NpCsOpeningHourSet.Code := 'DEFAULT';
        NpCsOpeningHourSet.Description := 'Default';
        NpCsOpeningHourSet.Insert;

        NpCsStoreOpeningHoursSetup.FindSet;
        repeat
          NpCsOpeningHourEntry.Init;
          NpCsOpeningHourEntry."Set Code" := NpCsOpeningHourSet.Code;
          NpCsOpeningHourEntry."Line No." := NpCsStoreOpeningHoursSetup."Line No.";
          NpCsOpeningHourEntry."Entry Type" := NpCsStoreOpeningHoursSetup."Entry Type";
          NpCsOpeningHourEntry."Start Time" := NpCsStoreOpeningHoursSetup."Start Time";
          NpCsOpeningHourEntry."End Time" := NpCsStoreOpeningHoursSetup."End Time";
          NpCsOpeningHourEntry."Period Type" := NpCsStoreOpeningHoursSetup."Period Type";
          NpCsOpeningHourEntry.Monday := NpCsStoreOpeningHoursSetup.Monday;
          NpCsOpeningHourEntry.Tuesday := NpCsStoreOpeningHoursSetup.Tuesday;
          NpCsOpeningHourEntry.Wednesday := NpCsStoreOpeningHoursSetup.Wednesday;
          NpCsOpeningHourEntry.Thursday := NpCsStoreOpeningHoursSetup.Thursday;
          NpCsOpeningHourEntry.Friday := NpCsStoreOpeningHoursSetup.Friday;
          NpCsOpeningHourEntry.Saturday := NpCsStoreOpeningHoursSetup.Saturday;
          NpCsOpeningHourEntry.Sunday := NpCsStoreOpeningHoursSetup.Sunday;
          NpCsOpeningHourEntry."Entry Date" := NpCsStoreOpeningHoursSetup."Entry Date";
          NpCsOpeningHourEntry."Period Description" := NpCsStoreOpeningHoursSetup."Period Description";
          NpCsOpeningHourEntry.Insert;

          NpCsStoreOpeningHoursSetup.Delete;
        until NpCsStoreOpeningHoursSetup.Next = 0;
    end;
}

