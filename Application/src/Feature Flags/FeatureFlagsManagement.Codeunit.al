codeunit 6151495 "NPR Feature Flags Management"
{
    Access = Internal;
    internal procedure IsProdutionEnvironment() IsProduction: Boolean;
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if EnvironmentInformation.IsSaaS() then begin
            if EnvironmentInformation.IsSandbox() then
                exit;
            IsProduction := EnvironmentInformation.IsProduction();
            exit;
        end;

        if EnvironmentInformation.IsOnPrem() then begin
            if IsCraneEnvironment() then
                exit;
            IsProduction := EnvironmentInformation.IsProduction();
        end
    end;

    local procedure IsCraneEnvironment() IsCraneEnv: Boolean;
    var
        Url: Text;
    begin
        Url := GetUrl(ClientType::Web);

        IsCraneEnv := Url.Contains('dynamics-retail.net');
    end;

    internal procedure IsEnabled(FeatureFlagName: Text[50]) Enabled: Boolean;
    var
        FeatureFlag: Record "NPR Feature Flag";
    begin
        if not FeatureFlag.Get(FeatureFlagName) then
            exit;

        if not Evaluate(Enabled, FeatureFlag.Value) then
            exit;
    end;

    internal procedure UpdateFeatureFlagsFromBuffer(var TempFeatureFlag: Record "NPR Feature Flag" temporary)
    begin
        RemoveRedundantFeatureFlags(TempFeatureFlag);
        CreateUpdateFeatureFlagsFromBuffer(TempFeatureFlag);
    end;

    local procedure CreateUpdateFeatureFlagsFromBuffer(var TempFeatureFlag: Record "NPR Feature Flag" temporary)
    var
        FeatureFlag: Record "NPR Feature Flag";
        Modi: Boolean;
    begin
        TempFeatureFlag.Reset();
        if not TempFeatureFlag.FindSet(false) then
            exit;

        repeat
            Modi := false;
            if not FeatureFlag.Get(TempFeatureFlag.RecordId) then begin
                FeatureFlag.Init();
                FeatureFlag := TempFeatureFlag;
                FeatureFlag.Insert(true);
            end else begin
                if (FeatureFlag.Value <> TempFeatureFlag.Value) then begin
                    FeatureFlag.Value := TempFeatureFlag.Value;
                    Modi := true;
                end;

                if FeatureFlag."Variation ID" <> TempFeatureFlag."Variation ID" then begin
                    FeatureFlag."Variation ID" := TempFeatureFlag."Variation ID";
                    Modi := true;
                end;

                if Modi then
                    FeatureFlag.Modify(true);
            end;

        until TempFeatureFlag.Next() = 0;
    end;

    local procedure RemoveRedundantFeatureFlags(var TempFeatureFlag: Record "NPR Feature Flag" temporary)
    var
        FeatureFlag: Record "NPR Feature Flag";
        RedundantFilterText: Text;
    begin
        RedundantFilterText := CreateRedundantFeatureFlagFilterText(TempFeatureFlag);
        if RedundantFilterText = '' then
            exit;

        FeatureFlag.Reset();
        FeatureFlag.SetFilter(Name, RedundantFilterText);
        if not FeatureFlag.IsEmpty then
            FeatureFlag.DeleteAll(true);
    end;

    local procedure CreateRedundantFeatureFlagFilterText(var TempFeatureFlag: Record "NPR Feature Flag" temporary) RedundantFilterText: Text
    var
        RedudnatFilterLbl: Label '&<>%1', Comment = '%1 - Feature Flag Name', Locked = true;
    begin
        if not TempFeatureFlag.FindSet(false) then
            exit;

        repeat
            RedundantFilterText += StrSubstNo(RedudnatFilterLbl, TempFeatureFlag.Name);
        until TempFeatureFlag.Next() = 0;

        RedundantFilterText := CopyStr(RedundantFilterText, 2);
    end;

    internal procedure CreateGetFeatureFlagsJobQueueEntry(var JobQueueEntry: Record "Job Queue Entry") Created: Boolean;
    var
        NPRJobQueueManagement: Codeunit "NPR Job Queue Management";
        DescriptionLbl: Label 'Get Feature Flags Integration';
        StartDateTime: DateTime;
    begin
        StartDateTime := NPRJobQueueManagement.NowWithDelayInSeconds(5);
        NPRJobQueueManagement.SetMaxNoOfAttemptsToRun(999999999);
        NPRJobQueueManagement.SetRerunDelay(10);
        NPRJobQueueManagement.SetAutoRescheduleAndNotifyOnError(true, 20, '');
        NPRJobQueueManagement.SetProtected(true);
        if not NPRJobQueueManagement.InitRecurringJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"NPR Get Feature Flags JQ", '', DescriptionLbl, StartDateTime, 1, '', JobQueueEntry) then
            exit;

        Created := true;
    end;

    internal procedure CheckIfGetFeatureFlagsScheduled(CompanyName: Text) GetFeatureFlagsScheduled: Boolean;
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.Reset();
        if CompanyName <> '' then
            JobQueueEntry.ChangeCompany(CompanyName);
        JobQueueEntry.SetRange(Status, JobQueueEntry.Status::Ready);
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR Get Feature Flags JQ");
        GetFeatureFlagsScheduled := not JobQueueEntry.IsEmpty;
    end;

    internal procedure GetMostUsedCompany(var TempCompany: Record Company temporary)
    var
        Company: Record Company;
        GLEntry: Record "G/L Entry";
        BestGLEntriesCount: Integer;
    begin
        ClearCompanyBuffer(TempCompany);

        Company.Reset();
        Company.SetRange("Evaluation Company", false);
        if Company.Find('-') and (Company.Next() = 0) then begin
            TempCompany := Company;
            TempCompany.Insert();
            exit;
        end;

        Company.SetLoadFields(Name);
        if not Company.FindSet(false) then
            exit;
        repeat
            GLEntry.Reset();
            GLEntry.ChangeCompany(Company.Name);
            if (BestGLEntriesCount < GLEntry.Count) or (TempCompany.IsEmpty) then begin
                ClearCompanyBuffer(TempCompany);
                TempCompany := Company;
                TempCompany.Insert();

                BestGLEntriesCount := GLEntry.Count();
            end;
        until Company.Next() = 0;
    end;

    local procedure ClearCompanyBuffer(var TempCompany: Record Company)
    var
        NotTemporaryParameterErrorLbl: Label 'The provided parameter must be temporary.';
    begin
        if not TempCompany.IsTemporary then
            Error(NotTemporaryParameterErrorLbl);

        TempCompany.Reset();
        if not TempCompany.IsEmpty then
            TempCompany.DeleteAll();
    end;

    internal procedure ScheduleGetFeatureFlagsIntegration()
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueManagement: Codeunit "NPR Job Queue Management";
    begin
        if CheckIfGetFeatureFlagsScheduled('') then
            exit;

        if not CreateGetFeatureFlagsJobQueueEntry(JobQueueEntry) then
            exit;

        JobQueueManagement.StartJobQueueEntry(JobQueueEntry);
    end;

    internal procedure InitFeatureFlagSetup()
    var
        FeatureFlagSetup: Record "NPR Feature Flags Setup";
        EnvironmentInformation: Codeunit "Environment Information";
        AzureADTenant: Codeunit "Azure AD Tenant";
    begin
        FeatureFlagSetup.Reset();
        if not FeatureFlagSetup.IsEmpty then
            exit;

        FeatureFlagSetup.Init();

        if EnvironmentInformation.IsOnPrem() then
            FeatureFlagSetup.Identifier := CreateGuid()
        else
            FeatureFlagSetup.Identifier := AzureADTenant.GetAadTenantId();

        FeatureFlagSetup.Insert();
    end;

    internal procedure InitFeatureFlagSetupConfirm()
    var
        ConfirmManagement: Codeunit "Confirm Management";
        ConfirmInitFeatureFlagSetup: Label 'Are you sure you want to initialize the Feature Flag Setup?';
    begin
        if not ConfirmManagement.GetResponseOrDefault(ConfirmInitFeatureFlagSetup, false) then
            exit;

        InitFeatureFlagSetup();
    end;

#IF NOT (BC17 or BC18 or BC19)
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Initialization", 'OnAfterLogin', '', false, false)]
#ELSE
    [EventSubscriber(ObjectType::Codeunit, Codeunit::LogInManagement, 'OnAfterLogInStart', '', false, false)]
#ENDIF
    local procedure OnAfterLogin()
    var
        SessionId: Integer;
    begin
        if not GuiAllowed then
            exit;

        if not Session.StartSession(SessionId, Codeunit::"NPR Get Feature Flags JQ", CompanyName) then
            exit;
    end;

    internal procedure GetFeatureFlagsManual()
    var
        ConfirmManagement: Codeunit "Confirm Management";
        GetFeatureFlagsJQ: Codeunit "NPR Get Feature Flags JQ";
        ConfirmTextLbl: Label 'Are you sure that you want to retrieve the feature flags?';
    begin
        if not ConfirmManagement.GetResponseOrDefault(ConfirmTextLbl, true) then
            exit;

        GetFeatureFlagsJQ.Run();
    end;

    internal procedure GetFeatureFlagsJobQueueEntry(var JobQueueEntry: Record "Job Queue Entry"; CompanyNameText: Text) Found: Boolean
    begin
        JobQueueEntry.Reset();
        if (CompanyNameText <> '') and (CompanyNameText <> CompanyName) then
            JobQueueEntry.ChangeCompany(CompanyNameText);
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR Get Feature Flags JQ");
        Found := JobQueueEntry.FindFirst();
    end;

    internal procedure CheckIfGetFeatureFlagsExistsInACompany(var JobQueueEntry: Record "Job Queue Entry"; var CompanyNameText: Text) GetFeatureFlagJobExists: Boolean;
    var
        Companies: Record Company;
    begin
        Companies.Reset();
        Companies.SetLoadFields(Name);
        if not Companies.FindSet(false) then
            exit;

        repeat
            GetFeatureFlagJobExists := GetFeatureFlagsJobQueueEntry(JobQueueEntry, Companies.Name);
            if GetFeatureFlagJobExists then
                CompanyNameText := Companies.Name;
        until (Companies.Next() = 0) or GetFeatureFlagJobExists;
    end;

}