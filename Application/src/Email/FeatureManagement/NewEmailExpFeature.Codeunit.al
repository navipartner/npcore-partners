#if not (BC17 or BC18 or BC19 or BC20 or BC21)
codeunit 6248406 "NPR NewEmailExpFeature" implements "NPR Feature Management"
{
    Access = Internal;

    procedure AddFeature()
    var
        Feature: Record "NPR Feature";
        FeatureDescriptionLbl: Label 'New Email Experience', MaxLength = 2048;
    begin
        Feature.Init();
        Feature.Id := GetFeatureId();
        Feature.Enabled := false;
        Feature.Description := FeatureDescriptionLbl;
        Feature.Validate(Feature, "NPR Feature"::"New Email Experience");
        Feature.Insert();
    end;

    procedure IsFeatureEnabled(): Boolean
    var
        Feature: Record "NPR Feature";
    begin
        if (not Feature.Get(GetFeatureId())) then
            exit(false);

        exit(Feature.Enabled);
    end;

    procedure SetFeatureEnabled(NewEnabled: Boolean)
    var
        Feature: Record "NPR Feature";
        NPEmailFeature: Codeunit "NPR NP Email Feature";
    begin
        if (not Feature.Get(GetFeatureId())) then begin
            AddFeature();
            Feature.Get(GetFeatureId());
        end;

        if (Feature.Enabled = NewEnabled) then
            exit;

        // We need this other feature to be enabled
        if (NewEnabled) then
            NPEmailFeature.SetFeatureEnabled(true);

        Feature.Enabled := NewEnabled;
        Feature.Modify();
    end;

    internal procedure GetFeatureId(): Text[50]
    begin
        exit('NewEmailExp');
    end;
}
#endif