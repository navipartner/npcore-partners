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

    [EventSubscriber(ObjectType::Page, Page::"NPR Feature Management", 'OnBeforeValidateEvent', 'Enabled', false, false)]
    local procedure NPRFeatureOnBeforeValidateEnabled(var Rec: Record "NPR Feature"; var xRec: Record "NPR Feature")
    var
        ConfirmManagement: Codeunit "Confirm Management";
        WarningLbl: Label 'WARNING: Enabling this feature is an irreversible action. Are you sure you want to continue?';
        CannotDisableAlreadyEnabledFeatureErr: Label 'This feature cannot be disabled once it is enabled.';
        POSWebserviceSessionsLbl: Label 'POSWebserviceSessions', Locked = true;
    begin
        if not (Rec.Id = POSWebserviceSessionsLbl) then
            exit;
        if xRec.Enabled then
            Error(CannotDisableAlreadyEnabledFeatureErr);
        if not ConfirmManagement.GetResponseOrDefault(WarningLbl, false) then begin
            Rec.Enabled := false;
            Rec.Modify();
        end;
    end;
}