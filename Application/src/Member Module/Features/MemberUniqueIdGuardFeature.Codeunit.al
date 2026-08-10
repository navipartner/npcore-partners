codeunit 6151279 "NPR MemberUniqueIdGuardFeature" implements "NPR Feature Management"
{
    Access = Internal;

    var
        _FeatureIdTok: Label 'member-uniqueness-concurrency-guard', Locked = true, MaxLength = 50;
        _FeatureDescriptionLbl: Label 'Prevent duplicate members from concurrent create/update requests (per-community unique-identity serialization)', MaxLength = 2024;

    procedure AddFeature();
    var
        Feature: Record "NPR Feature";
    begin
        if (Feature.Get(_FeatureIdTok)) then
            exit;

        Feature.Init();
        Feature.Id := _FeatureIdTok;
        Feature.Enabled := true;
        Feature.Description := _FeatureDescriptionLbl;
        Feature.Validate(Feature, Enum::"NPR Feature"::MemberUniqueIDConcurrencyGuard);
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