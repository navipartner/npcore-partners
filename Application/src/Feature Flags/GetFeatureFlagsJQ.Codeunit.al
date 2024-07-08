codeunit 6151499 "NPR Get Feature Flags JQ"
{
    Access = Internal;

    trigger OnRun()
    begin
        GetFeatureFlags();
    end;

    local procedure GetFeatureFlags()
    var
        SentryCron: Codeunit "NPR Sentry Cron";
        ConfigCatAPI: Codeunit "NPR ConfigCat API";
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
        TempFeatureFlag: Record "NPR Feature Flag" temporary;
        CheckInId: Text;
        ErrorText: Text;
        MonitorSlugLbl: Label 'get_feature_flags', Locked = true;
    begin
        CheckInId := SentryCron.CreateCheckIn(SentryCron.GetOrganizationSlug(), MonitorSlugLbl, 'in_progress', '* * * * *', 0, 30, 2, '');
        if not ConfigCatAPI.TryCallApi() then begin
            ErrorText := GetLastErrorText();

            if CheckInId <> '' then
                SentryCron.UpdateCheckIn(SentryCron.GetOrganizationSlug(), MonitorSlugLbl, 'error', CheckInId);

            Error(ErrorText);
        end;

        ConfigCatAPI.GetResponseAsBuffer(TempFeatureFlag);
        FeatureFlagsManagement.UpdateFeatureFlagsFromBuffer(TempFeatureFlag);

        if CheckInId <> '' then
            SentryCron.UpdateCheckIn(SentryCron.GetOrganizationSlug(), MonitorSlugLbl, 'ok', CheckInId);
    end;


}