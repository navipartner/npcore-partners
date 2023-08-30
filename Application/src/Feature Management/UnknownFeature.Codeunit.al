codeunit 6151478 "NPR Unknown Feature" implements "NPR Feature Management"
{
    Access = Internal;

    procedure AddFeature();
    var
        AddUnknownFeatureErr: Label 'Cannot add unknown feature.';
    begin
        Error(AddUnknownFeatureErr);
    end;

    procedure IsFeatureEnabled(): Boolean;
    var
        IsUnknownFeatureEnabledErr: Label 'Cannot check is unknown feature enabled';
    begin
        Error(IsUnknownFeatureEnabledErr);
    end;

    procedure SetFeatureEnabled(NewEnabled: Boolean);
    var
        SetUnknownFeatureEnabledErr: Label 'Cannot set enabled for unknown feature.';
    begin
        Error(SetUnknownFeatureEnabledErr);
    end;
}