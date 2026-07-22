codeunit 6151158 "NPR New Sales Doc Conf. Exp" implements "NPR Feature Management"
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
        Feature.Validate(Feature, Enum::"NPR Feature"::"New Sales Doc Confirmation Experience");
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

    internal procedure GetFeatureId(): Text[50]
    var
        FeatureIdTok: Label 'NewSalesDocConfirmationExperience', Locked = true, MaxLength = 50;
    begin
        exit(FeatureIdTok);
    end;

    local procedure GetFeatureDescription(): Text[2048]
    var
        FeatureDescriptionLbl: Label 'New Sales Document Confirmation Experience', MaxLength = 2048;
    begin
        exit(FeatureDescriptionLbl);
    end;

    internal procedure InsertReportSelectionRetail()
    var
        ReportSelectionRetail: Record "NPR Report Selection Retail";
    begin
        ReportSelectionRetail.SetRange("Report Type", ReportSelectionRetail."Report Type"::"Sales Doc. Confirmation (POS Entry)");
        ReportSelectionRetail.SetRange("Codeunit ID", Codeunit::"NPR Static Sales Doc Confirm.");
        ReportSelectionRetail.SetRange("Report ID", 0);
        ReportSelectionRetail.SetRange("Print Template", '');
        ReportSelectionRetail.SetRange("Register No.", '');
        ReportSelectionRetail.SetRange(Optional, false);
        if not ReportSelectionRetail.IsEmpty() then
            exit;

        ReportSelectionRetail.Init();
        ReportSelectionRetail."Report Type" := ReportSelectionRetail."Report Type"::"Sales Doc. Confirmation (POS Entry)";
        ReportSelectionRetail.Validate("Codeunit ID", Codeunit::"NPR Static Sales Doc Confirm.");
        ReportSelectionRetail.Sequence := ReportSelectionRetail.GetNextSequence(ReportSelectionRetail."Report Type"::"Sales Doc. Confirmation (POS Entry)");
        ReportSelectionRetail.Insert(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Feature", 'OnBeforeValidateEvent', 'Enabled', false, false)]
    local procedure NPRFeatureOnBeforeValidateEnabled(var Rec: Record "NPR Feature"; var xRec: Record "NPR Feature")
    var
        ReportSelectionRetail: Record "NPR Report Selection Retail";
        ConfirmManagement: Codeunit "Confirm Management";
        WarningLbl: Label 'WARNING: Enabling this feature is an irreversible action. Enabling this action will disable template prints support for Sales Document Confirmation permanently. Are you sure you want to continue?';
        CannotRevertErr: Label 'This feature cannot be disabled once it is enabled.';
        NewSalesDocConfirmationExperienceLabel: Label 'NewSalesDocConfirmationExperience', Locked = true;
    begin
        if not (Rec.Id = NewSalesDocConfirmationExperienceLabel) then
            exit;
        if xRec.Enabled then
            Error(CannotRevertErr);
        if not ConfirmManagement.GetResponseOrDefault(WarningLbl, false) then begin
            Rec.Enabled := false;
            Rec.Modify();
            exit;
        end;
        ReportSelectionRetail.SetRange("Report Type", ReportSelectionRetail."Report Type"::"Sales Doc. Confirmation (POS Entry)");
        ReportSelectionRetail.ModifyAll("Print Template", '');
        ReportSelectionRetail.CleanupEmptyData();

        InsertReportSelectionRetail();
    end;
}
