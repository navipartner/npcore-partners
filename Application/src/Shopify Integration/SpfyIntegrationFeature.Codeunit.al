#if not BC17
codeunit 6184826 "NPR Spfy Integration Feature" implements "NPR Feature Management"
{
    Access = Internal;

    procedure AddFeature();
    var
        Feature: Record "NPR Feature";
    begin
        Feature.Init();
        Feature.Id := GetFeatureId();
        Feature.Enabled := false;
        Feature.Description := GetFeatureDescription();
        Feature.Validate(Feature, Enum::"NPR Feature"::Shopify);
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
        FeatureIdTok: Label 'Shopify', Locked = true, MaxLength = 50;
    begin
        exit(FeatureIdTok);
    end;

    local procedure GetFeatureDescription(): Text[2048]
    var
        FeatureDescriptionLbl: Label 'Shopify Integration', MaxLength = 2024;
    begin
        exit(FeatureDescriptionLbl);
    end;
}
#endif