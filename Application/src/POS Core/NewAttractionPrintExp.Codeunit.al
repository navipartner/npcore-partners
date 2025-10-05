codeunit 6150744 "NPR New Attraction Print Exp" implements "NPR Feature Management"
{
    Access = Internal;
    internal procedure AddFeature()
    var
        Feature: Record "NPR Feature";
    begin
        Feature.Init();
        Feature.Id := GetFeatureId();
        Feature.Enabled := false;
        Feature.Description := GetFeatureDescription();
        Feature.Validate(Feature, Enum::"NPR Feature"::"New Attraction Print Exerience");
        Feature.Insert();
    end;

    internal procedure IsFeatureEnabled(): Boolean
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

    internal procedure GetFeatureId(): Text[50]
    var
        FeatureIdTok: Label 'NewAttractionPrintExperience', Locked = true, MaxLength = 50;
    begin
        exit(FeatureIdTok);
    end;

    local procedure GetFeatureDescription(): Text[2048]
    var
        FeatureDescriptionLbl: Label 'New Attraction Print Experience', MaxLength = 2024;
    begin
        exit(FeatureDescriptionLbl);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Feature", 'OnBeforeValidateEvent', 'Enabled', false, false)]
    local procedure NPRFeatureOnBeforeValidateEnabled(var Rec: Record "NPR Feature"; var xRec: Record "NPR Feature")
    var
        TicketType: Record "NPR TM Ticket Type";
        MembershipSetup: Record "NPR MM Membership Setup";
        ConfirmManagement: Codeunit "Confirm Management";
        WarningLbl: Label 'WARNING: Enabling this feature is an irreversible action. Are you sure you want to continue?';
        TicketTypesTemplateExistErr: Label 'There are existing ticket types where Print Object Type is set to Template. Please change them first, before enabling this feature.';
        MembershipSetupTemplateExistErr: Label 'There are existing membership setups where Receipt Print Object Type is set to Template. Please change them first, before enabling this feature.';
        CannotRevertNewAttractionPrintExperienceFeatureErr: Label 'This feature cannot be disabled once it is enabled.';
        NewAttractionPrintExperienceLbl: Label 'NewAttractionPrintExperience', Locked = true;
    begin
        if not (Rec.Id = NewAttractionPrintExperienceLbl) then
            exit;
        if xRec.Enabled then
            Error(CannotRevertNewAttractionPrintExperienceFeatureErr);
        if not ConfirmManagement.GetResponseOrDefault(WarningLbl, false) then begin
            Rec.Enabled := false;
            Rec.Modify();
            exit;
        end;

        TicketType.SetRange("Print Object Type", TicketType."Print Object Type"::TEMPLATE);
        if TicketType.IsEmpty() then begin
            TicketType.Reset();
            TicketType.ModifyAll("RP Template Code", '')
        end else
            Error(TicketTypesTemplateExistErr);

        MembershipSetup.SetRange("Receipt Print Object Type", MembershipSetup."Receipt Print Object Type"::TEMPLATE);
        if MembershipSetup.IsEmpty() then begin
            MembershipSetup.Reset();
            MembershipSetup.ModifyAll("Receipt Print Template Code", '')
        end else
            Error(MembershipSetupTemplateExistErr);
    end;
}
