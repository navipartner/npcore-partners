codeunit 6151384 "NPR PayByLinkNPEmailFeature" implements "NPR Feature Management"
{
    Access = Internal;

    procedure AddFeature()
    var
        Feature: Record "NPR Feature";
        FeatureDescriptionLbl: Label 'Pay by Link Notifications via NP Email', MaxLength = 2048;
    begin
        Feature.Init();
        Feature.Id := GetFeatureId();
        Feature.Enabled := false;
        Feature.Description := FeatureDescriptionLbl;
        Feature.Validate(Feature, "NPR Feature"::"Pay by Link Notif. via NP Email");
        Feature.Insert();
    end;

    procedure IsFeatureEnabled(): Boolean
    var
        Feature: Record "NPR Feature";
        NewEmailExperienceFeature: Codeunit "NPR NewEmailExpFeature";
    begin
        if not Feature.Get(GetFeatureId()) then
            exit(false);
        if not Feature.Enabled then
            exit(false);
        exit(NewEmailExperienceFeature.IsFeatureEnabled());
    end;

    procedure SetFeatureEnabled(NewEnabled: Boolean)
    var
        Feature: Record "NPR Feature";
    begin
        if not Feature.Get(GetFeatureId()) then begin
            AddFeature();
            Feature.Get(GetFeatureId());
        end;

        if Feature.Enabled = NewEnabled then
            exit;

        Feature.Enabled := NewEnabled;
        Feature.Modify();
    end;

    internal procedure EnableIfNoLegacySetupInUse()
    var
        NewEmailExperienceFeature: Codeunit "NPR NewEmailExpFeature";
    begin
        EnableIfNoLegacySetupInUse(NewEmailExperienceFeature.IsFeatureEnabled());
    end;

    internal procedure EnableIfNoLegacySetupInUse(NewEmailExperienceEnabled: Boolean)
    begin
        if not NewEmailExperienceEnabled then
            exit;
        if LegacyOnlySetupInUse() then
            exit;
        SetFeatureEnabled(true);
    end;

    internal procedure GetFeatureId(): Text[50]
    begin
        exit('PayByLinkNPEmail');
    end;

    local procedure LegacyOnlySetupInUse(): Boolean
    var
        AdyenSetup: Record "NPR Adyen Setup";
    begin
        if not AdyenSetup.Get() then
            exit(false);
        if not AdyenSetup."Enable Pay by Link" then
            exit(false);
        if AdyenSetup."Pay By Link NP Email Template" <> '' then
            exit(false);
        exit(AdyenSetup."Pay By Link E-Mail Template" <> '');
    end;

    local procedure UnconfiguredSetupExists(): Boolean
    var
        AdyenSetup: Record "NPR Adyen Setup";
    begin
        if not AdyenSetup.Get() then
            exit(false);
        if not AdyenSetup."Enable Pay by Link" then
            exit(false);
        exit(AdyenSetup."Pay By Link NP Email Template" = '');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Feature", 'OnBeforeValidateEvent', 'Enabled', false, false)]
    local procedure GuardEnableOnBeforeValidate(var Rec: Record "NPR Feature"; var xRec: Record "NPR Feature")
    var
        AdyenSetup: Record "NPR Adyen Setup";
        ConfirmManagement: Codeunit "Confirm Management";
        NewEmailExperienceFeature: Codeunit "NPR NewEmailExpFeature";
        RequiresNewEmailExpErr: Label 'This feature requires the New Email Experience feature to be enabled first.';
        UnconfiguredSetupQst: Label 'No %1 is selected in %2. Pay by Link e-mails will not be sent until a template is selected.\Do you want to continue?', Comment = '%1 = Pay By Link NP Email Template field caption, %2 = Adyen Setup table caption';
    begin
        if Rec.Id <> GetFeatureId() then
            exit;
        if not Rec.Enabled then
            exit;
        if xRec.Enabled then
            exit;

        if not NewEmailExperienceFeature.IsFeatureEnabled() then
            Error(RequiresNewEmailExpErr);

        if not UnconfiguredSetupExists() then
            exit;

        if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(UnconfiguredSetupQst, AdyenSetup.FieldCaption("Pay By Link NP Email Template"), AdyenSetup.TableCaption), false) then begin
            Rec.Enabled := false;
            Rec.Modify();
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Feature", 'OnBeforeValidateEvent', 'Enabled', false, false)]
    local procedure SyncWithNewEmailExperienceOnValidate(var Rec: Record "NPR Feature"; var xRec: Record "NPR Feature")
    var
        NewEmailExperienceFeature: Codeunit "NPR NewEmailExpFeature";
    begin
        if Rec.Id <> NewEmailExperienceFeature.GetFeatureId() then
            exit;
        if Rec.Enabled = xRec.Enabled then
            exit;

        if Rec.Enabled then
            EnableIfNoLegacySetupInUse(true)
        else
            SetFeatureEnabled(false);
    end;
}
