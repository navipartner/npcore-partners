codeunit 6014693 "NPR Environment Handler"
{
    Access = Internal;
    var
        IssueDetectedNotificationTxt: Label 'Something went wrong and Allow HTTP for extension ''%1'' won''t be enabled.';
        AllowHttpEnabledTxt: Label 'Allow HTTP has been successfully enabled for extension ''%1''';

    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::LogInManagement, 'OnBeforeLogInStart', '', true, true)]
    local procedure OnBeforeLoginStart()
    begin
        EnableAllowHttpInSandbox();
    end;

    internal procedure EnableAllowHttpInSandbox()
    var
        NAVAppSetting: Record "NAV App Setting";
        EnvironmentInfo: Codeunit "Environment Information";
        AppInfo: ModuleInfo;
    begin
        if (EnvironmentInfo.IsSandbox()) then begin

            NavApp.GetCurrentModuleInfo(AppInfo);

            // Trying get/insert first (if there are next fields in futher versions to get them out properly all with get()):
            if not NAVAppSetting.Get(AppInfo.Id) then begin
                NAVAppSetting.Init();
                NAVAppSetting."App ID" := AppInfo.Id;
                if not NAVAppSetting.Insert() then begin
                    // The method should be fail-safe as it will run from the critial place.
                    if not SendNotification(StrSubstNo(IssueDetectedNotificationTxt, AppInfo.Name)) then;
                    exit;
                end;
            end;

            // Now modify only required field (currently the only field available):
            if (not NAVAppSetting."Allow HttpClient Requests") then begin
                NAVAppSetting."Allow HttpClient Requests" := true;
                if not NAVAppSetting.Modify() then begin
                    // The method should be fail-safe as it will run from the critial place.
                    if not SendNotification(StrSubstNo(IssueDetectedNotificationTxt, AppInfo.Name)) then;
                    exit;
                end;

                if not SendNotification(StrSubstNo(AllowHttpEnabledTxt, AppInfo.Name)) then;
            end;

        end;
    end;

    [TryFunction]
    local procedure SendNotification(NotificationMessage: Text)
    var
        IssueDetectedNotification: Notification;
    begin
        if not GuiAllowed then begin
            exit;
        end;

        IssueDetectedNotification.Message := NotificationMessage;
        IssueDetectedNotification.Send();
    end;
}
