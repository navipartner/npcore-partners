#if not BC17
codeunit 6014405 "NPR PermissionSet Upgrade"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerDatabase()
    begin
        if GetDataVersion() <= Version.Create('9999.9999.9999.9999') then
            UpgradePermissionSets();
    end;

    local procedure UpgradePermissionSets()
    begin
        UpgradePermissionSet('NP RETAIL', 'NPR NP RETAIL');
    end;

    local procedure UpgradePermissionSet(OldPermissionSetCode: Code[20]; NewPermissionSetCode: Code[20])
    var
        UserGroupPermissionSet: Record "User Group Permission Set";
        UserGroupPermissionSet2: Record "User Group Permission Set";
        AccessControl: Record "Access Control";
        AccessControl2: Record "Access Control";
        AppId: Guid;
        CurrentAppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(CurrentAppInfo);
        AppId := CurrentAppInfo.Id();
        UserGroupPermissionSet.SetRange("App ID", AppId);
        UserGroupPermissionSet.SetRange(Scope, UserGroupPermissionSet.Scope::Tenant);
        UserGroupPermissionSet.SetRange("Role ID", OldPermissionSetCode);
        if UserGroupPermissionSet.FindSet() then begin
            repeat
                UserGroupPermissionSet2 := UserGroupPermissionSet;
                UserGroupPermissionSet2.Scope := UserGroupPermissionSet2.Scope::System;
                UserGroupPermissionSet2."Role ID" := NewPermissionSetCode;
                UserGroupPermissionSet2.Insert();
            until UserGroupPermissionSet.Next() = 0;
            UserGroupPermissionSet.DeleteAll();
        end;

        AccessControl.SetRange("App ID", AppId);
        AccessControl.SetRange(Scope, AccessControl.Scope::Tenant);
        AccessControl.SetRange("Role ID", OldPermissionSetCode);
        if AccessControl.FindSet() then begin
            repeat
                AccessControl2 := AccessControl;
                AccessControl2.Scope := AccessControl2.Scope::System;
                AccessControl2."Role ID" := NewPermissionSetCode;
                AccessControl2.Insert();
            until AccessControl.Next() = 0;
            AccessControl.DeleteAll();
        end;
    end;

    local procedure GetDataVersion(): Version
    var
        ModInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(ModInfo);
        exit(ModInfo.DataVersion());
    end;
}
#endif