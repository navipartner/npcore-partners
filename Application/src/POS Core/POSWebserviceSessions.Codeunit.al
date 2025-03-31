codeunit 6248379 "NPR POS Webservice Sessions" implements "NPR Feature Management"
{
    Access = Internal;

    procedure AddFeature()
    var
        Feature: Record "NPR Feature";
        FeatureDescriptionLbl: Label 'POS Webservice Sessions', MaxLength = 2048;
    begin
        Feature.Init();
        Feature.Id := GetFeatureId();
        Feature.Enabled := false;
        Feature.Description := FeatureDescriptionLbl;
        Feature.Validate(Feature, "NPR Feature"::"POS Webservice Sessions");
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
        exit('POSWebserviceSessions');
    end;
}