codeunit 6151237 "NPR Spfy Sync State Seeding"
{
    Access = Internal;
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        RunSeedingSweep(false);
    end;

    procedure SeedSyncState()
    var
        SpfyScheduleSeedingJQ: Codeunit "NPR Spfy Schedule Seeding JQ";
        RunInForeground: Boolean;
        ModeQst: Label 'Seed the Shopify RowVersion baselines now?\\Yes = run in this session now (blocking, with a progress dialog) — fine for a small integration.\No = schedule a background Job Queue entry (recommended for a large existing integration).';
        BackgroundStartedMsg: Label 'The baseline seeding has been started in the background. Its status is shown on the Shopify Integration Setup page while it runs.';
        BackgroundNeedsActivationMsg: Label 'The baseline seeding job has been created, but your user cannot start scheduled tasks. Ask an administrator to set the job to Ready on the Job Queue Entries page; the seeding will then run in the background.';
    begin
        RunInForeground := Confirm(ModeQst, false);
        if RunInForeground then
            RunSeedingSweep(true)
        else begin
            SpfyScheduleSeedingJQ.ScheduleSeedingJob();
            if SpfyScheduleSeedingJQ.SeedingEntryIsOnHold() then
                Message(BackgroundNeedsActivationMsg)
            else
                Message(BackgroundStartedMsg);
        end;
    end;

    procedure RunSeedingSweep(ShowProgressDialog: Boolean)
    var
        SeedingWorker: Codeunit "NPR Spfy Sync St. Seed Worker";
        LastError: Text;
    begin
        MarkSeedingInProgress();
        SeedingWorker.SetShowProgress(ShowProgressDialog);
        if SeedingWorker.Run() then begin
            MarkSeedingCompleted();
            exit;
        end;
        // Persist Failed (committed) then RE-RAISE — else the background JQ looks "Finished" and the cutover goes live on an incomplete seed.
        LastError := GetLastErrorText();
        MarkSeedingFailed(CopyStr(LastError, 1, 250));
        Error(LastError);
    end;

    local procedure MarkSeedingInProgress()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
    begin
        ShopifySetup.GetRecordOnce(true);
        ShopifySetup."RowVersion Migration Status" := ShopifySetup."RowVersion Migration Status"::Seeding;
        ShopifySetup."RowVersion Seeding Started At" := CurrentDateTime();
        Clear(ShopifySetup."RowVersion Seeding Compl. At");
        Clear(ShopifySetup."RowVersion Seeding Error Text");
        ShopifySetup.Modify();
        Commit();   // Commit before Codeunit.Run (no pending writes allowed); a crashed run stays visibly not Completed.
    end;

    local procedure MarkSeedingCompleted()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
        SpfySyncStateMgt: Codeunit "NPR Spfy Sync State Mgt";
    begin
        ShopifySetup.GetRecordOnce(true);
        ShopifySetup."RowVersion Migration Status" := ShopifySetup."RowVersion Migration Status"::Seeded;
        ShopifySetup."RowVersion Seeding Compl. At" := CurrentDateTime();
        ShopifySetup."RowVersion Pld. Ver. Seeded" := SpfySyncStateMgt.PayloadVersion();   // the cutover gates on this == current PayloadVersion()
        Clear(ShopifySetup."RowVersion Seeding Error Text");
        ShopifySetup.Modify();
        Commit();
    end;

    local procedure MarkSeedingFailed(ErrorText: Text[250])
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
    begin
        ShopifySetup.GetRecordOnce(true);
        ShopifySetup."RowVersion Migration Status" := ShopifySetup."RowVersion Migration Status"::Failed;
        ShopifySetup."RowVersion Seeding Error Text" := ErrorText;
        ShopifySetup.Modify();
        Commit();
    end;
}
