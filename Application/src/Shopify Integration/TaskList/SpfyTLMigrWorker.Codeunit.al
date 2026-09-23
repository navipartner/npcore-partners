codeunit 6151246 "NPR Spfy TL Migr Worker"
{
    Access = Internal;

    trigger OnRun()
    var
        SpfyIntegrationSetup: Record "NPR Spfy Integration Setup";
        SpfyTaskListMigration: Codeunit "NPR Spfy Task List Migration";
        NotViaJobQueueErr: Label 'The Shopify task list cutover cannot be started directly. Use the migration action on the Shopify Integration Setup page.';
    begin
        // Access = Internal does not stop the Job Queue dispatcher, so without this handshake a queued entry
        // targeting this codeunit would run the whole one-way cutover unchecked.
        if not SpfyTaskListMigration.CutoverAuthorized() then
            Error(NotViaJobQueueErr);
        SpfyIntegrationSetup.LockTable();
        SpfyIntegrationSetup.GetRecordOnce(true);
        SpfyTaskListMigration.RunEnvironmentCutover(SpfyIntegrationSetup);
    end;
}
