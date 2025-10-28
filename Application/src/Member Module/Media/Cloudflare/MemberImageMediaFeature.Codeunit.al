codeunit 6248562 "NPR MemberImageMediaFeature" implements "NPR Feature Management"
{
    Access = Internal;

    var
        _FeatureIdTok: Label 'member-media-in-cloudflare', Locked = true, MaxLength = 50;
        _FeatureDescriptionLbl: Label 'Member Media in Cloudflare R2 Storage', MaxLength = 2024;

    procedure AddFeature();
    var
        Feature: Record "NPR Feature";
    begin
        if (Feature.Get(_FeatureIdTok)) then
            exit;

        Feature.Init();
        Feature.Id := _FeatureIdTok;
        Feature.Enabled := false;
        Feature.Description := _FeatureDescriptionLbl;
        Feature.Validate(Feature, Enum::"NPR Feature"::MemberMediaInCloudflare);
        Feature.Insert();
    end;

    procedure IsFeatureEnabled(): Boolean
    var
        Feature: Record "NPR Feature";
    begin
        if (not Feature.Get(_FeatureIdTok)) then
            exit(false);

        exit(Feature.Enabled);
    end;

    procedure SetFeatureEnabled(NewEnabled: Boolean);
    var
        Feature: Record "NPR Feature";
    begin
        if (not Feature.Get(_FeatureIdTok)) then
            exit;

        Feature.Enabled := NewEnabled;
        Feature.Modify();
    end;

}
