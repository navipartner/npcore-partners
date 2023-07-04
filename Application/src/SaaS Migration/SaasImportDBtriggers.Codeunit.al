codeunit 6150938 "NPR Saas Import DB triggers"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GlobalTriggerManagement, 'OnAfterGetDatabaseTableTriggerSetup', '', true, true)]
    local procedure GlobalTriggerManagementOnAfterGetDatabaseTableTriggerSetup(TableId: Integer; var OnDatabaseInsert: Boolean; var OnDatabaseModify: Boolean; var OnDatabaseDelete: Boolean; var OnDatabaseRename: Boolean)
    var
        SaaSImportSetup: Record "NPR SaaS Import Setup";
    begin
        if not SaaSImportSetup.ReadPermission() then
            exit;
        if not SaaSImportSetup.Get() then
            exit;
        if not SaaSImportSetup."Disable Database Triggers" then
            exit;

        OnDatabaseInsert := false;
        OnDatabaseModify := false;
        OnDatabaseDelete := false;
        OnDatabaseRename := false;
    end;
}