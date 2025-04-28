codeunit 6248350 "NPR New EFT Receipt Exp" implements "NPR Feature Management"
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
        Feature.Validate(Feature, Enum::"NPR Feature"::"New EFT Receipt Experience");
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
        FeatureIdTok: Label 'NewEFTReceiptExperience', Locked = true, MaxLength = 50;
    begin
        exit(FeatureIdTok);
    end;

    local procedure GetFeatureDescription(): Text[2048]
    var
        FeatureDescriptionLbl: Label 'New EFT Receipt Experience', MaxLength = 2024;
    begin
        exit(FeatureDescriptionLbl);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Feature", 'OnBeforeValidateEvent', 'Enabled', false, false)]
    local procedure NPRFeatureOnBeforeValidateEnabled(var Rec: Record "NPR Feature"; var xRec: Record "NPR Feature")
    var
        ReportSelectionRetail: Record "NPR Report Selection Retail";
        ConfirmManagement: Codeunit "Confirm Management";
        WarningLbl: Label 'WARNING: Enabling this feature is an irreversible action. Enabling this action will disable template prints support for EFT receipts permanently. Are you sure you want to continue?';
        CannotRevertNewEFTReceiptExperienceFeatureErr: Label 'This feature cannot be disabled once it is enabled.';
        NewEFTReceiptExperienceLabel: Label 'NewEFTReceiptExperience', Locked = true;
    begin
        if not (Rec.Id = NewEFTReceiptExperienceLabel) then
            exit;
        if xRec.Enabled then
            Error(CannotRevertNewEFTReceiptExperienceFeatureErr);
        if not ConfirmManagement.GetResponseOrDefault(WarningLbl, false) then begin
            Rec.Enabled := false;
            Rec.Modify();
            exit;
        end;
        ReportSelectionRetail.SetRange("Report Type", ReportSelectionRetail."Report Type"::"Terminal Receipt");
        ReportSelectionRetail.ModifyAll("Print Template", '');

        if ReportSelectionRetail.FindFirst() then begin
            ReportSelectionRetail.Validate("Codeunit ID", Codeunit::"NPR Static EFT Receipt");
            ReportSelectionRetail.Modify();
        end;
    end;
}
