codeunit 6151369 "NPR JQNotifNPEmailFeature" implements "NPR Feature Management"
{
    Access = Internal;

    procedure AddFeature()
    var
        Feature: Record "NPR Feature";
        FeatureDescriptionLbl: Label 'Job Queue Notifications via NP Email', MaxLength = 2048;
    begin
        Feature.Init();
        Feature.Id := GetFeatureId();
        Feature.Enabled := false;
        Feature.Description := FeatureDescriptionLbl;
        Feature.Validate(Feature, "NPR Feature"::"JQ Notifications via NP Email");
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
        exit('JQNotifNPEmail');
    end;

    local procedure LegacyOnlySetupInUse(): Boolean
    var
        JQNotifProfile: Record "NPR Job Queue Notif. Profile";
    begin
        JQNotifProfile.SetRange("Send E-mail", true);
        JQNotifProfile.SetFilter("E-mail Template Id", '<>%1', '');
        if not JQNotifProfile.IsEmpty() then
            exit(false);

        JQNotifProfile.SetRange("E-mail Template Id", '');
        JQNotifProfile.SetFilter("E-mail Template Code", '<>%1', '');
        exit(not JQNotifProfile.IsEmpty());
    end;

    local procedure UnconfiguredProfileExists(): Boolean
    var
        JQNotifProfile: Record "NPR Job Queue Notif. Profile";
    begin
        JQNotifProfile.SetRange("Send E-mail", true);
        JQNotifProfile.SetRange("E-mail Template Id", '');
        exit(not JQNotifProfile.IsEmpty());
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Feature", 'OnBeforeValidateEvent', 'Enabled', false, false)]
    local procedure GuardEnableOnBeforeValidate(var Rec: Record "NPR Feature"; var xRec: Record "NPR Feature")
    var
        JQNotifProfile: Record "NPR Job Queue Notif. Profile";
        ConfirmManagement: Codeunit "Confirm Management";
        NewEmailExperienceFeature: Codeunit "NPR NewEmailExpFeature";
        RequiresNewEmailExpErr: Label 'This feature requires the New Email Experience feature to be enabled first.';
        UnconfiguredProfilesQst: Label 'One or more %1 records have no %2 selected. Notification e-mails for those profiles will not be sent until a template is selected.\Do you want to continue?', Comment = '%1 = Job Queue Notif. Profile table caption, %2 = E-mail Template Id field caption';
    begin
        if Rec.Id <> GetFeatureId() then
            exit;
        if not Rec.Enabled then
            exit;
        if xRec.Enabled then
            exit;

        if not NewEmailExperienceFeature.IsFeatureEnabled() then
            Error(RequiresNewEmailExpErr);

        if not UnconfiguredProfileExists() then
            exit;

        if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(UnconfiguredProfilesQst, JQNotifProfile.TableCaption, JQNotifProfile.FieldCaption("E-mail Template Id")), false) then begin
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
