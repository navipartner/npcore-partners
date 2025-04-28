codeunit 6248351 "NPR New Sales Receipt Exp" implements "NPR Feature Management"
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
        Feature.Validate(Feature, Enum::"NPR Feature"::"New Sales Receipt Experience");
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
        FeatureIdTok: Label 'NewSalesReceiptExperience', Locked = true, MaxLength = 50;
    begin
        exit(FeatureIdTok);
    end;

    local procedure GetFeatureDescription(): Text[2048]
    var
        FeatureDescriptionLbl: Label 'New Sales Receipt Experience', MaxLength = 2024;
    begin
        exit(FeatureDescriptionLbl);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Feature", 'OnBeforeValidateEvent', 'Enabled', false, false)]
    local procedure NPRFeatureOnBeforeValidateEnabled(var Rec: Record "NPR Feature"; var xRec: Record "NPR Feature")
    var
        ReportSelectionRetail: Record "NPR Report Selection Retail";
        ConfirmManagement: Codeunit "Confirm Management";
        WarningLbl: Label 'WARNING: Enabling this feature is an irreversible action. Enabling this action will disable template prints support for sales receipts permanently. Are you sure you want to continue?';
        CannotRevertNewSalesReceiptExperienceFeatureErr: Label 'This feature cannot be disabled once it is enabled.';
        NewSalesReceiptExperienceLabel: Label 'NewSalesReceiptExperience', Locked = true;
    begin
        if not (Rec.Id = NewSalesReceiptExperienceLabel) then
            exit;
        if xRec.Enabled then
            Error(CannotRevertNewSalesReceiptExperienceFeatureErr);
        if not ConfirmManagement.GetResponseOrDefault(WarningLbl, false) then begin
            Rec.Enabled := false;
            Rec.Modify();
            exit;
        end;
        ReportSelectionRetail.SetRange("Report Type", ReportSelectionRetail."Report Type"::"Sales Receipt (POS Entry)");
        ReportSelectionRetail.ModifyAll("Print Template", '');

        if ReportSelectionRetail.FindFirst() then begin
            ReportSelectionRetail.Validate("Codeunit ID", Codeunit::"NPR Static Sales Receipt");
            ReportSelectionRetail.Modify();
        end;
    end;
}
