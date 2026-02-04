codeunit 6248724 "NPR New Restaurant Print Exp." implements "NPR Feature Management"
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
        Feature.Validate(Feature, Enum::"NPR Feature"::"New Restaurant Print Experience");
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
        FeatureIdTok: Label 'NewRestaurantPrintExperience', Locked = true, MaxLength = 50;
    begin
        exit(FeatureIdTok);
    end;

    local procedure GetFeatureDescription(): Text[2048]
    var
        FeatureDescriptionLbl: Label 'New Restaurant Print Experience', MaxLength = 2024;
    begin
        exit(FeatureDescriptionLbl);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Feature", 'OnBeforeValidateEvent', 'Enabled', false, false)]
    local procedure NPRFeatureOnBeforeValidateEnabled(var Rec: Record "NPR Feature"; var xRec: Record "NPR Feature")
    var
        ConfirmManagement: Codeunit "Confirm Management";
        WarningLbl: Label 'WARNING: Enabling this feature is an irreversible action. Enabling this action will disable template prints support for restaurant receipts permanently. Are you sure you want to continue?';
        CannotRevertNewRestaurantReceiptExperienceFeatureErr: Label 'This feature cannot be disabled once it is enabled.';
        NewRestaurantReceiptExperienceLabel: Label 'NewRestaurantPrintExperience', Locked = true;
    begin
        if not (Rec.Id = NewRestaurantReceiptExperienceLabel) then
            exit;
        if xRec.Enabled then
            Error(CannotRevertNewRestaurantReceiptExperienceFeatureErr);
        if not ConfirmManagement.GetResponseOrDefault(WarningLbl, false) then begin
            Rec.Enabled := false;
            Rec.Modify();
            exit;
        end;

        MigratePrintTemplates();
    end;

    local procedure MigratePrintTemplates()
    var
        OldPrintTempl: Record "NPR NPRE Print Templ.";
        NewPrintTemplate: Record "NPR NPRE Print Template";
        ExistingPrintTemplate: Record "NPR NPRE Print Template";
        CodeunitId: Integer;
    begin
        if OldPrintTempl.IsEmpty() then
            exit;

        if OldPrintTempl.FindSet() then
            repeat
                CodeunitId := GetDefaultCodeunitId(OldPrintTempl."Print Type");

                ExistingPrintTemplate.SetRange("Print Type", OldPrintTempl."Print Type");
                ExistingPrintTemplate.SetRange("Restaurant Code", OldPrintTempl."Restaurant Code");
                ExistingPrintTemplate.SetRange("Seating Location", OldPrintTempl."Seating Location");
                ExistingPrintTemplate.SetRange("Serving Step", OldPrintTempl."Serving Step");
                ExistingPrintTemplate.SetRange("Print Category Code", OldPrintTempl."Print Category Code");
                ExistingPrintTemplate.SetRange("Codeunit ID", CodeunitId);
                if ExistingPrintTemplate.IsEmpty() then begin
                    Clear(NewPrintTemplate);
                    NewPrintTemplate.Init();
                    NewPrintTemplate."Print Type" := OldPrintTempl."Print Type";
                    NewPrintTemplate."Restaurant Code" := OldPrintTempl."Restaurant Code";
                    NewPrintTemplate."Seating Location" := OldPrintTempl."Seating Location";
                    NewPrintTemplate."Serving Step" := OldPrintTempl."Serving Step";
                    NewPrintTemplate."Print Category Code" := OldPrintTempl."Print Category Code";
                    NewPrintTemplate."Split Print Jobs By" := OldPrintTempl."Split Print Jobs By";
                    NewPrintTemplate."Codeunit ID" := CodeunitId;
                    NewPrintTemplate.Insert(true);
                end;
            until OldPrintTempl.Next() = 0;
    end;

    local procedure GetDefaultCodeunitId(PrintType: Option "Kitchen Order","Serving Request","Pre Receipt"): Integer
    begin
        case PrintType of
            PrintType::"Kitchen Order",
            PrintType::"Serving Request":
                exit(Codeunit::"NPR NPRE Static Kitchen Print");
            PrintType::"Pre Receipt":
                exit(Codeunit::"NPR NPRE Static Pre Receipt");
        end;
    end;
}
