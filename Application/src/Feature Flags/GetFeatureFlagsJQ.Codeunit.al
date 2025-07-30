codeunit 6151499 "NPR Get Feature Flags JQ"
{
    Access = Internal;

    trigger OnRun()
    begin
        GetFeatureFlags();
    end;

    local procedure GetFeatureFlags()
    var
        ConfigCatAPI: Codeunit "NPR ConfigCat API";
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
        TempFeatureFlag: Record "NPR Feature Flag" temporary;
        ErrorText: Text;
    begin
        if not ConfigCatAPI.TryCallApi() then begin
            ErrorText := GetLastErrorText();
            Error(ErrorText);
        end;

        ConfigCatAPI.GetResponseAsBuffer(TempFeatureFlag);
        FeatureFlagsManagement.UpdateFeatureFlagsFromBuffer(TempFeatureFlag);
    end;


}