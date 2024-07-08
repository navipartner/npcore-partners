codeunit 85186 "NPR Library - Feature Flags"
{
    Access = Internal;
    procedure InitializeFeatureFlagsEnabled()
    begin
        InitializeFeatureFlags();
        UpdateFeatureFalgs(true);
    end;

    procedure InitializeFeatureFlagsDisabled()
    var
        NPRFeatureFlag: Record "NPR Feature Flag";
    begin
        InitializeFeatureFlags();
        UpdateFeatureFalgs(false);
    end;

    local procedure InitializeFeatureFlags()
    var
        GetFeatureFlagsJQ: Codeunit "NPR Get Feature Flags JQ";
    begin
        GetFeatureFlagsJQ.Run();
    end;

    local procedure UpdateFeatureFalgs(Value: Boolean)
    var
        NPRFeatureFlag: Record "NPR Feature Flag";
    begin
        NPRFeatureFlag.Reset();
        if NPRFeatureFlag.IsEmpty then
            exit;
        NPRFeatureFlag.ModifyAll(Value, Format(Value));
    end;
}