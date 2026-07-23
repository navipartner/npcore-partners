codeunit 6151141 "NPR New Begin Workshift Exp" implements "NPR Feature Management"
{
    Access = Internal;

    procedure AddFeature()
    var
        Feature: Record "NPR Feature";
    begin
        Feature.Init();
        Feature.Id := GetFeatureId();
        Feature.Enabled := false;
        Feature.Description := GetFeatureDescription();
        Feature.Validate(Feature, Enum::"NPR Feature"::"New Begin Workshift Experience");
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

    procedure SetFeatureEnabled(NewEnabled: Boolean)
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
        FeatureIdTok: Label 'NewBeginWorkshiftExperience', Locked = true, MaxLength = 50;
    begin
        exit(FeatureIdTok);
    end;

    local procedure GetFeatureDescription(): Text[2048]
    var
        FeatureDescriptionLbl: Label 'New Begin Workshift Experience', MaxLength = 2024;
    begin
        exit(FeatureDescriptionLbl);
    end;

    internal procedure InsertReportSelectionRetail()
    var
        ReportSelectionRetail: Record "NPR Report Selection Retail";
    begin
        ReportSelectionRetail.SetRange("Report Type", ReportSelectionRetail."Report Type"::"Begin Workshift (POS Entry)");
        ReportSelectionRetail.SetRange("Codeunit ID", Codeunit::"NPR Static Begin Workshift");
        ReportSelectionRetail.SetRange("Report ID", 0);
        ReportSelectionRetail.SetRange("Print Template", '');
        ReportSelectionRetail.SetRange("Register No.", '');
        ReportSelectionRetail.SetRange(Optional, false);
        if not ReportSelectionRetail.IsEmpty() then
            exit;

        ReportSelectionRetail.Init();
        ReportSelectionRetail."Report Type" := ReportSelectionRetail."Report Type"::"Begin Workshift (POS Entry)";
        ReportSelectionRetail.Validate("Codeunit ID", Codeunit::"NPR Static Begin Workshift");
        ReportSelectionRetail.Sequence := ReportSelectionRetail.GetNextSequence(ReportSelectionRetail."Report Type"::"Begin Workshift (POS Entry)");
        ReportSelectionRetail.Insert(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Feature", 'OnBeforeValidateEvent', 'Enabled', false, false)]
    local procedure NPRFeatureOnBeforeValidateEnabled(var Rec: Record "NPR Feature"; var xRec: Record "NPR Feature")
    var
        ReportSelectionRetail: Record "NPR Report Selection Retail";
        ConfirmManagement: Codeunit "Confirm Management";
        WarningLbl: Label 'WARNING: Enabling this feature is an irreversible action. Enabling this action will disable template prints support for begin workshift permanently. Are you sure you want to continue?';
        CannotRevertErr: Label 'This feature cannot be disabled once it is enabled.';
        NewBeginWorkshiftExperienceLbl: Label 'NewBeginWorkshiftExperience', Locked = true;
    begin
        if Rec.Id <> NewBeginWorkshiftExperienceLbl then
            exit;
        if xRec.Enabled then
            Error(CannotRevertErr);
        if not ConfirmManagement.GetResponseOrDefault(WarningLbl, false) then begin
            Rec.Enabled := false;
            Rec.Modify();
            exit;
        end;

        ReportSelectionRetail.SetRange("Report Type", ReportSelectionRetail."Report Type"::"Begin Workshift (POS Entry)");
        ReportSelectionRetail.ModifyAll("Print Template", '');
        ReportSelectionRetail.CleanupEmptyData();

        InsertReportSelectionRetail();
    end;
}
