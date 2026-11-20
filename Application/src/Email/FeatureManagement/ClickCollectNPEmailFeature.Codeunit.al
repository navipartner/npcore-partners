#if not (BC17 or BC18 or BC19 or BC20 or BC21)
codeunit 6184695 "NPR CnC NP Email Feature" implements "NPR Feature Management"
{
    Access = Internal;

    procedure AddFeature()
    var
        Feature: Record "NPR Feature";
        FeatureDescriptionLbl: Label 'NP Email for Click & Collect', MaxLength = 2048;
    begin
        Feature.Init();
        Feature.Id := GetFeatureId();
        Feature.Enabled := false;
        Feature.Description := FeatureDescriptionLbl;
        Feature.Validate(Feature, "NPR Feature"::"NP Email for Click & Collect");
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
    begin
        if (not Feature.Get(GetFeatureId())) then begin
            AddFeature();
            Feature.Get(GetFeatureId());
        end;

        Feature.Enabled := NewEnabled;
        Feature.Modify();
    end;

    internal procedure GetFeatureId(): Text[50]
    begin
        exit('ClickCollectNPEmail');
    end;
}
#endif
