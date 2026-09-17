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

    procedure EnableFeatureFlag(FeatureFlagName: Text[50]) PreviousValue: Boolean
    var
        NPRFeatureFlag: Record "NPR Feature Flag";
    begin
        if not NPRFeatureFlag.Get(FeatureFlagName) then begin
            NPRFeatureFlag.Name := FeatureFlagName;
            NPRFeatureFlag.Value := Format(true);
            NPRFeatureFlag.Insert();
            exit(false);
        end;

        if not Evaluate(PreviousValue, NPRFeatureFlag.Value) then
            PreviousValue := false;

        NPRFeatureFlag.Value := Format(true);
        NPRFeatureFlag.Modify();
    end;

    procedure SetFeatureFlag(FeatureFlagName: Text[50]; Enabled: Boolean)
    var
        NPRFeatureFlag: Record "NPR Feature Flag";
    begin
        if not NPRFeatureFlag.Get(FeatureFlagName) then begin
            NPRFeatureFlag.Name := FeatureFlagName;
            NPRFeatureFlag.Value := Format(Enabled);
            NPRFeatureFlag.Insert();
            exit;
        end;

        NPRFeatureFlag.Value := Format(Enabled);
        NPRFeatureFlag.Modify();
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