codeunit 6060025 "NPR Environment Mgt."
{
    Access = Internal;

    // Codeunit that can be polled for the current environment status.
    // Environment is defined as combo of database name, tenant name and company name.
    // 
    // Main purpose of codeunit being:
    // - To automatically block external integrations until someone has manually verified the environment, in case it changes.
    // - To allow for prompts to clear table data that should not be present in company copies unless they are PROD.
    // 
    // Please beware that the unverified status will not be set on environment change before either a NAS or user session enters a
    // company for the first time.
    // 
    // It locks on purpose when the first user logs in after environment change.
    // This is assumed to be the person that copied the company, or hosting if creating a restore.


    trigger OnRun()
    begin
    end;

    var
        Caption_OptionMessage: Label 'Company: %1 \\The current environment has changed and is no longer verified! \This is caused by a change in database, tenant or company.\Please verify the new company environment type below:';
        Caption_EnvironmentOption: Label 'Production,Demo,Sandbox / Testing / Development';
        Caption_NotProdEnv: Label 'The current environment is not set as production. \Some external integrations are handled differently in this mode. You can change this in page "%1"';
        Caption_UnverifiedWarning: Label 'The current environment has been set to unverified!\Some external integrations are handled differently in this mode. You can change this in page "%1"';
        Caption_MissingPermissions: Label 'You are missing permissions for table %1. \If data scrub is necessary for this table in the new environment, then you must switch user/permissions and handle it manually.';
        Caption_CleanJobQueue: Label 'Disable Job Queue entries in this new environment?';

    procedure IsProd(): Boolean
    var
        NPREnvironmentInfo: Record "NPR Environment Information";
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if EnvironmentInformation.IsSaaS() then
            exit(EnvironmentInformation.IsProduction());

        if NPREnvironmentInfo.Get() then
            exit((NPREnvironmentInfo."Environment Type" = "NPR Environment Type"::PROD) and NPREnvironmentInfo."Environment Verified");
    end;

    procedure IsDemo(): Boolean
    var
        EnvironmentInfo: Record "NPR Environment Information";
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if EnvironmentInformation.IsSaaS() then
            exit(EnvironmentInformation.IsSandbox());

        if EnvironmentInfo.Get() then
            exit((EnvironmentInfo."Environment Type" = "NPR Environment Type"::DEMO) and EnvironmentInfo."Environment Verified");
    end;

    procedure IsTest(): Boolean
    var
        NPREnvironmentInfo: Record "NPR Environment Information";
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if EnvironmentInformation.IsSaaS() then
            exit(not EnvironmentInformation.IsProduction());

        if NPREnvironmentInfo.Get() then
            exit((NPREnvironmentInfo."Environment Type" = "NPR Environment Type"::SANDBOX) and NPREnvironmentInfo."Environment Verified");
    end;

#IF BC17 or BC18 or BC19
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Initialization", 'OnAfterInitialization', '', true, false)]
    local procedure OnAfterInitialization()
    begin
        CheckEnvironment();
    end;
#ELSE
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Initialization", 'OnAfterLogin', '', true, false)]
    local procedure OnAfterLogin()
    begin
        CheckEnvironment();
    end;
#ENDIF
    local procedure CheckEnvironment()
    var
        NPREnvironmentInfo: Record "NPR Environment Information";
        ActiveSession: Record "Active Session";
        NPREnvironmentInfoPage: Page "NPR Environment Information";
        EnvironmentInformation: Codeunit "Environment Information";
        Iterations: Integer;
    begin
        if not GuiAllowed then
            exit;

        if EnvironmentInformation.IsSaaS() then
            exit; //We use microsofts prod/sandbox terminology in saas instead of our own.

        if NavApp.IsInstalling() then
            exit;

        if not (CurrentClientType() in [ClientType::Phone, ClientType::Web, ClientType::Windows, ClientType::Tablet, ClientType::Desktop, ClientType::NAS]) then
            exit;

        if not NPREnvironmentInfo.WritePermission() then
            exit;

        while (not ActiveSession.Get(ServiceInstanceId(), SessionId())) do begin
            Sleep(10);
            Iterations += 1;
            if Iterations > 50 then
                exit;
        end;

        if CheckIfEmpty(NPREnvironmentInfo, ActiveSession) then begin
            Commit();
            exit;
        end;

        if CheckIfTemplate(NPREnvironmentInfo, ActiveSession) then begin
            Commit();
            exit;
        end;

        if CheckIfVerified(NPREnvironmentInfo, ActiveSession) then begin
            if GuiAllowed() then
                if not EnvironmentInformation.IsSandbox() then
                    if NPREnvironmentInfo."Environment Type" = "NPR Environment Type"::SANDBOX then
                        Message(Caption_NotProdEnv, NPREnvironmentInfoPage.Caption);
            exit;
        end;

        HandleEnvironmentChange(NPREnvironmentInfo, ActiveSession);
    end;

    local procedure CheckIfEmpty(var NPREnvironmentInfo: Record "NPR Environment Information"; var ActiveSession: Record "Active Session"): Boolean
    var
        RecFound: Boolean;
        FirstTime: Boolean;
    begin
        //In a completely new environment, assume it is verified PROD to preserve the status-quo as before this module was created.
        SelectLatestVersion();
        RecFound := NPREnvironmentInfo.Get();
        FirstTime := not RecFound;

        if RecFound then
            FirstTime := (StrLen(NPREnvironmentInfo."Environment Company Name") = 0) and (StrLen(NPREnvironmentInfo."Environment Database Name") = 0) and (StrLen(NPREnvironmentInfo."Environment Tenant Name") = 0);

        if FirstTime then begin
            if not RecFound then
                NPREnvironmentInfo.Init();
            NPREnvironmentInfo."Environment Company Name" := CopyStr(CompanyName(), 1, MaxStrLen(NPREnvironmentInfo."Environment Company Name"));
            NPREnvironmentInfo."Environment Database Name" := ActiveSession."Database Name";
            NPREnvironmentInfo."Environment Tenant Name" := CopyStr(TenantId(), 1, MaxStrLen(NPREnvironmentInfo."Environment Tenant Name"));
            NPREnvironmentInfo."Environment Type" := GetDefaultEnvironmentType();
            NPREnvironmentInfo."Environment Verified" := true;
            if RecFound then begin
                if NPREnvironmentInfo.Modify() then;
            end else
                if NPREnvironmentInfo.Insert() then;
            exit(true);
        end;
    end;

    local procedure GetDefaultEnvironmentType(): Enum "NPR Environment Type"
    var
        EnvInfo: Codeunit "Environment Information";
    begin
        if EnvInfo.IsOnPrem() then
            exit("NPR Environment Type"::PROD);
        if EnvInfo.IsSandbox() then
            exit("NPR Environment Type"::SANDBOX);
        exit("NPR Environment Type"::PROD);
    end;

    local procedure CheckIfTemplate(var NPREnvironmentInfo: Record "NPR Environment Information"; var ActiveSession: Record "Active Session"): Boolean
    begin
        if NPREnvironmentInfo."Environment Template" and NPREnvironmentInfo."Environment Verified" then begin
            if (NPREnvironmentInfo."Environment Company Name" <> CompanyName()) or (NPREnvironmentInfo."Environment Database Name" <> ActiveSession."Database Name") or (NPREnvironmentInfo."Environment Tenant Name" <> TenantId()) then begin
                NPREnvironmentInfo."Environment Template" := false;
                NPREnvironmentInfo."Environment Company Name" := CopyStr(CompanyName(), 1, MaxStrLen(NPREnvironmentInfo."Environment Company Name"));
                NPREnvironmentInfo."Environment Database Name" := ActiveSession."Database Name";
                NPREnvironmentInfo."Environment Tenant Name" := CopyStr(TenantId(), 1, MaxStrLen(NPREnvironmentInfo."Environment Tenant Name"));
                if NPREnvironmentInfo.Modify() then;
            end;
            exit(true);
        end;
    end;

    local procedure CheckIfVerified(var NPREnvironmentInfo: Record "NPR Environment Information"; var ActiveSession: Record "Active Session"): Boolean
    begin
        if NPREnvironmentInfo."Environment Verified" then
            if (NPREnvironmentInfo."Environment Company Name" = CompanyName()) and (NPREnvironmentInfo."Environment Database Name" = ActiveSession."Database Name") and (NPREnvironmentInfo."Environment Tenant Name" = TenantId()) then
                exit(true)
            else begin
                NPREnvironmentInfo."Environment Verified" := false;
                if NPREnvironmentInfo.Modify() then;
            end;
    end;

    local procedure HandleEnvironmentChange(var NPREnvironmentInfo: Record "NPR Environment Information"; var ActiveSession: Record "Active Session")
    var
        NPREnvironmentInfoPage: Page "NPR Environment Information";
        EnvironmentInformation: Codeunit "Environment Information";
        EnvironmentType: Integer;
        xEnvironmentType: Enum "NPR Environment Type";
    begin
        xEnvironmentType := NPREnvironmentInfo."Environment Type";

        if GuiAllowed() then begin
            if EnvironmentInformation.IsSandbox() then
                EnvironmentType := "NPR Environment Type"::SANDBOX.AsInteger() + 1
            else
                EnvironmentType := StrMenu(Caption_EnvironmentOption, 3, StrSubstNo(Caption_OptionMessage, CompanyName));
            if EnvironmentType > 0 then begin
                NPREnvironmentInfo."Environment Company Name" := CopyStr(CompanyName(), 1, MaxStrLen(NPREnvironmentInfo."Environment Company Name"));
                NPREnvironmentInfo."Environment Database Name" := ActiveSession."Database Name";
                NPREnvironmentInfo."Environment Tenant Name" := CopyStr(TenantId(), 1, MaxStrLen(NPREnvironmentInfo."Environment Tenant Name"));
                NPREnvironmentInfo."Environment Type" := "NPR Environment Type".FromInteger(EnvironmentType - 1);
                NPREnvironmentInfo."Environment Verified" := true;
                if NPREnvironmentInfo.Modify() then;
            end;

            if not NPREnvironmentInfo."Environment Verified" then
                Message(Caption_UnverifiedWarning, NPREnvironmentInfoPage.Caption);

            if (xEnvironmentType <> NPREnvironmentInfo."Environment Type") and (NPREnvironmentInfo."Environment Type" <> "NPR Environment Type"::PROD) then
                PromptDataScrub();
        end;

        Commit();
    end;

    local procedure PromptDataScrub()
    begin
        DisableNpXmlTransfer();
        CancelJobQueueEntries();
    end;

    local procedure DisableNpXmlTransfer()
    var
        NpXmlTemplate: Record "NPR NpXml Template";
    begin
        if not NpXmlTemplate.WritePermission then
            exit;

        NpXmlTemplate.SetRange("File Transfer", true);
        if NpXmlTemplate.FindFirst() then
            NpXmlTemplate.ModifyAll("File Transfer", false, false);

        NpXmlTemplate.Reset();
        NpXmlTemplate.SetRange("FTP enabled", true);
        if NpXmlTemplate.FindFirst() then
            NpXmlTemplate.ModifyAll("FTP enabled", false, false);

        NpXmlTemplate.Reset();
        NpXmlTemplate.SetRange("SFTP enabled", true);
        if NpXmlTemplate.FindFirst() then
            NpXmlTemplate.ModifyAll("SFTP Enabled", false, false);

        NpXmlTemplate.Reset();
        NpXmlTemplate.SetRange("API Transfer", true);
        if NpXmlTemplate.FindFirst() then
            NpXmlTemplate.ModifyAll("API Transfer", false, false);
    end;

    local procedure CancelJobQueueEntries()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        if not JobQueueEntry.ReadPermission then begin
            Message(Caption_MissingPermissions, JobQueueEntry.TableCaption);
            exit;
        end;

        JobQueueEntry.SetFilter(Status, '%1|%2|%3', JobQueueEntry.Status::Ready, JobQueueEntry.Status::"In Process", JobQueueEntry.Status::Error);
        if JobQueueEntry.IsEmpty then
            exit;

        if not Confirm(Caption_CleanJobQueue) then
            exit;

        if not JobQueueEntry.WritePermission then begin
            Message(Caption_MissingPermissions, JobQueueEntry.TableCaption);
            exit;
        end;

        if JobQueueEntry.FindSet(true) then
            repeat
                JobQueueEntry.SetStatus(JobQueueEntry.Status::"On Hold");
            until JobQueueEntry.Next() = 0;
    end;
}
