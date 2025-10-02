#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248537 "NPR POS License Billing Feat." implements "NPR Feature Management"
{
    Access = Internal;

    var
        FeatureIdTok: Label 'POSLicenseBilling', Locked = true, MaxLength = 50;
        FeatureDescriptionLbl: Label 'POS License Billing Integration', MaxLength = 2024;

    procedure AddFeature();
    var
        Feature: Record "NPR Feature";
    begin
        if (Feature.Get(FeatureIdTok)) then
            exit;

        Feature.Init();
        Feature.Id := FeatureIdTok;
        Feature.Enabled := false;
        Feature.Description := FeatureDescriptionLbl;
        Feature.Validate(Feature, Enum::"NPR Feature"::"POS License Billing Integration");
        Feature.Insert();
    end;

    procedure IsFeatureEnabled(): Boolean
    var
        Feature: Record "NPR Feature";
    begin
        if (not Feature.Get(FeatureIdTok)) then
            exit(false);

        exit(Feature.Enabled);
    end;

    procedure SetFeatureEnabled(NewEnabled: Boolean);
    var
        Feature: Record "NPR Feature";
    begin
        if (not Feature.Get(FeatureIdTok)) then begin
            AddFeature();
            Feature.Get(FeatureIdTok);
        end;

        if (Feature.Enabled <> NewEnabled) then begin
            Feature.Enabled := NewEnabled;
            Feature.Modify();
        end;
    end;
}
#endif