codeunit 6151438 "NPR NaviConnect Feature" implements "NPR Feature Management"
{
    Access = Internal;

    procedure AddFeature();
    var
        Feature: Record "NPR Feature";
    begin
        Feature.Init();
        Feature.Id := GetFeatureId();
        Feature.Enabled := true;
        Feature.Description := GetFeatureDescription();
        Feature.Validate(Feature, Enum::"NPR Feature"::NaviConnect);
        Feature.Insert();
    end;

    procedure IsFeatureEnabled(): Boolean
    var
        Feature: Record "NPR Feature";
    begin
        if not Feature.Get(GetFeatureId()) then
            exit(false);

        exit(Feature.Enabled);
    end;

    procedure SetFeatureEnabled(NewEnabled: Boolean);
    var
        Feature: Record "NPR Feature";
    begin
        if not Feature.Get(GetFeatureId()) then
            exit;

        Feature.Enabled := NewEnabled;
        Feature.Modify();
    end;

    local procedure GetFeatureId(): Text[50]
    var
        FeatureIdTok: Label 'NaviConnect', Locked = true, MaxLength = 50;
    begin
        exit(FeatureIdTok);
    end;

    local procedure GetFeatureDescription(): Text[2048]
    var
        FeatureDescriptionLbl: Label 'NaviConnect', MaxLength = 2024;
    begin
        exit(FeatureDescriptionLbl);
    end;
}